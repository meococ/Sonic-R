//+------------------------------------------------------------------+
//|                                       MarketAnalysisManager.mqh |
//|                                    APEX Pullback EA v5.0 FINAL |
//|                                   Market Analysis Coordinator   |
//+------------------------------------------------------------------+
#ifndef MARKET_ANALYSIS_MANAGER_MQH
#define MARKET_ANALYSIS_MANAGER_MQH

#include "../00_Core/CommonStructs.mqh"
#include "Technical/TechnicalAnalysis.mqh"
#include "Structure/Structure.mqh"
#include "News/NewsAnalysis.mqh"
#include "Sentiment/SentimentAnalysis.mqh"
#include "Volume/VolumeAnalysis.mqh"

//+------------------------------------------------------------------+
//| Market Analysis Enumerations                                     |
//+------------------------------------------------------------------+
enum ENUM_MARKET_BIAS {
    MARKET_BIAS_BULLISH,
    MARKET_BIAS_BEARISH,
    MARKET_BIAS_NEUTRAL,
    MARKET_BIAS_MIXED,
    MARKET_BIAS_UNCERTAIN
};

enum ENUM_MARKET_CONDITION {
    MARKET_TRENDING_UP,
    MARKET_TRENDING_DOWN,
    MARKET_RANGING,
    MARKET_VOLATILE,
    MARKET_QUIET,
    MARKET_BREAKOUT,
    MARKET_REVERSAL
};

enum ENUM_ANALYSIS_WEIGHT {
    WEIGHT_TECHNICAL = 0,
    WEIGHT_STRUCTURE,
    WEIGHT_NEWS,
    WEIGHT_SENTIMENT,
    WEIGHT_VOLUME,
    WEIGHT_COUNT
};

enum ENUM_CONFLUENCE_LEVEL {
    CONFLUENCE_NONE,
    CONFLUENCE_WEAK,
    CONFLUENCE_MODERATE,
    CONFLUENCE_STRONG,
    CONFLUENCE_VERY_STRONG
};

//+------------------------------------------------------------------+
//| Market Analysis Structures                                       |
//+------------------------------------------------------------------+
struct SMarketAnalysisResult {
    // Overall Assessment
    ENUM_MARKET_BIAS      OverallBias;
    ENUM_MARKET_CONDITION MarketCondition;
    ENUM_CONFLUENCE_LEVEL ConfluenceLevel;
    double                ConfidenceScore; // 0-100
    
    // Individual Analysis Scores
    double                TechnicalScore;
    double                StructureScore;
    double                NewsScore;
    double                SentimentScore;
    double                VolumeScore;
    
    // Bias from each analysis
    ENUM_MARKET_BIAS      TechnicalBias;
    ENUM_MARKET_BIAS      StructureBias;
    ENUM_MARKET_BIAS      NewsBias;
    ENUM_MARKET_BIAS      SentimentBias;
    ENUM_MARKET_BIAS      VolumeBias;
    
    // Confluence Analysis
    int                   BullishConfluences;
    int                   BearishConfluences;
    int                   NeutralConfluences;
    
    // Risk Assessment
    double                RiskLevel; // 0-100
    bool                  HighRiskCondition;
    string                RiskFactors;
    
    // Timing
    datetime              AnalysisTime;
    bool                  IsValid;
    string                Summary;
};

struct SAnalysisWeights {
    double                Weights[WEIGHT_COUNT];
    bool                  AdaptiveWeighting;
    double                MinWeight;
    double                MaxWeight;
    
    // Constructor to initialize default weights
    SAnalysisWeights() {
        Weights[WEIGHT_TECHNICAL] = 0.25;
        Weights[WEIGHT_STRUCTURE] = 0.25;
        Weights[WEIGHT_NEWS] = 0.15;
        Weights[WEIGHT_SENTIMENT] = 0.15;
        Weights[WEIGHT_VOLUME] = 0.20;
        AdaptiveWeighting = true;
        MinWeight = 0.05;
        MaxWeight = 0.50;
    }
};

struct SMarketAnalysisConfig {
    // Analysis Settings
    bool                  EnableTechnicalAnalysis;
    bool                  EnableStructureAnalysis;
    bool                  EnableNewsAnalysis;
    bool                  EnableSentimentAnalysis;
    bool                  EnableVolumeAnalysis;
    
    // Weighting
    SAnalysisWeights      Weights;
    bool                  UseConfluenceScoring;
    bool                  RequireMinimumConfluence;
    int                   MinConfluenceCount;
    
    // Update Settings
    int                   UpdateFrequency; // seconds
    bool                  RealTimeUpdates;
    bool                  CacheResults;
    
    // Risk Management
    bool                  EnableRiskAssessment;
    double                MaxRiskThreshold;
    bool                  AdjustForVolatility;
    bool                  ConsiderNewsEvents;
    
    // Performance
    bool                  OptimizePerformance;
    int                   MaxAnalysisTime; // milliseconds
    bool                  ParallelProcessing;
};

struct SMarketAnalysisStats {
    int                   TotalAnalyses;
    int                   BullishSignals;
    int                   BearishSignals;
    int                   NeutralSignals;
    double                AverageConfidence;
    double                AverageConfluence;
    double                AccuracyRate;
    datetime              LastAnalysisTime;
    int                   AnalysisTimeMs;
    bool                  PerformanceOptimal;
};

//+------------------------------------------------------------------+
//| Market Analysis Manager Class                                    |
//+------------------------------------------------------------------+
class CMarketAnalysisManager {
private:
    // Core properties
    EAContext*            m_pContext;
    bool                  m_bInitialized;
    string                m_Symbol;
    ENUM_TIMEFRAMES       m_Timeframe;
    
    // Analysis modules
    CTechnicalAnalysis*   m_pTechnicalAnalysis;
    CStructure*           m_pStructureAnalysis;
    CNewsAnalysis*        m_pNewsAnalysis;
    CSentimentAnalysis*   m_pSentimentAnalysis;
    CVolumeAnalysis*      m_pVolumeAnalysis;
    
    // Configuration and results
    SMarketAnalysisConfig m_Config;
    SMarketAnalysisResult m_CurrentResult;
    SMarketAnalysisStats  m_Stats;
    
    // Analysis state
    datetime              m_LastUpdate;
    bool                  m_AnalysisValid;
    bool                  m_ModulesInitialized;
    
    // Performance tracking
    uint                  m_AnalysisStartTime;
    int                   m_LastAnalysisTime;
    
public:
    //--- Constructor/Destructor ---
    CMarketAnalysisManager();
    ~CMarketAnalysisManager();
    
    //--- Core Methods ---
    bool                  Initialize(EAContext* context, const string& symbol, const ENUM_TIMEFRAMES timeframe, const SMarketAnalysisConfig& config);
    void                  Deinitialize();
    bool                  IsInitialized() const { return m_bInitialized; }
    void                  Update();
    
    //--- Analysis Execution ---
    SMarketAnalysisResult PerformCompleteAnalysis();
    SMarketAnalysisResult GetCurrentAnalysis() const { return m_CurrentResult; }
    bool                  IsAnalysisValid() const { return m_AnalysisValid; }
    
    //--- Individual Analysis Access ---
    CTechnicalAnalysis*   GetTechnicalAnalysis() { return m_pTechnicalAnalysis; }
    CStructure*           GetStructureAnalysis() { return m_pStructureAnalysis; }
    CNewsAnalysis*        GetNewsAnalysis() { return m_pNewsAnalysis; }
    CSentimentAnalysis*   GetSentimentAnalysis() { return m_pSentimentAnalysis; }
    CVolumeAnalysis*      GetVolumeAnalysis() { return m_pVolumeAnalysis; }
    
    //--- Market Assessment ---
    ENUM_MARKET_BIAS      GetOverallBias();
    ENUM_MARKET_CONDITION GetMarketCondition();
    ENUM_CONFLUENCE_LEVEL GetConfluenceLevel();
    double                GetConfidenceScore();
    
    //--- Confluence Analysis ---
    int                   GetBullishConfluences();
    int                   GetBearishConfluences();
    bool                  HasStrongConfluence();
    bool                  HasMinimumConfluence();
    
    //--- Risk Assessment ---
    double                GetRiskLevel();
    bool                  IsHighRiskCondition();
    string                GetRiskFactors();
    bool                  ShouldReduceRisk();
    
    //--- Bias Analysis ---
    ENUM_MARKET_BIAS      GetTechnicalBias();
    ENUM_MARKET_BIAS      GetStructureBias();
    ENUM_MARKET_BIAS      GetNewsBias();
    ENUM_MARKET_BIAS      GetSentimentBias();
    ENUM_MARKET_BIAS      GetVolumeBias();
    
    //--- Score Analysis ---
    double                GetTechnicalScore();
    double                GetStructureScore();
    double                GetNewsScore();
    double                GetSentimentScore();
    double                GetVolumeScore();
    double                GetCompositeScore();
    
    //--- Configuration ---
    bool                  SetConfiguration(const SMarketAnalysisConfig& config);
    SMarketAnalysisConfig GetConfiguration() const { return m_Config; }
    bool                  SetWeights(const SAnalysisWeights& weights);
    SAnalysisWeights      GetWeights() const { return m_Config.Weights; }
    
    //--- Module Control ---
    bool                  EnableModule(const ENUM_ANALYSIS_WEIGHT module, const bool enable);
    bool                  IsModuleEnabled(const ENUM_ANALYSIS_WEIGHT module);
    bool                  InitializeModules();
    void                  DeinitializeModules();
    
    //--- Statistics ---
    SMarketAnalysisStats  GetStatistics() const { return m_Stats; }
    void                  UpdateStatistics();
    double                GetAccuracyRate() const { return m_Stats.AccuracyRate; }
    
    //--- Information ---
    string                GetAnalysisSummary();
    string                GetConfluenceSummary();
    string                GetRiskSummary();
    string                GetPerformanceSummary();
    
private:
    //--- Analysis Processing ---
    void                  PerformTechnicalAnalysis();
    void                  PerformStructureAnalysis();
    void                  PerformNewsAnalysis();
    void                  PerformSentimentAnalysis();
    void                  PerformVolumeAnalysis();
    
    //--- Scoring and Weighting ---
    double                CalculateWeightedScore();
    void                  NormalizeScores();
    void                  ApplyWeights();
    void                  AdjustAdaptiveWeights();
    
    //--- Confluence Calculation ---
    void                  CalculateConfluence();
    int                   CountBullishSignals();
    int                   CountBearishSignals();
    ENUM_CONFLUENCE_LEVEL DetermineConfluenceLevel();
    
    //--- Bias Determination ---
    ENUM_MARKET_BIAS      CalculateOverallBias();
    ENUM_MARKET_BIAS      ConvertScoreToBias(const double score);
    void                  ResolveConflictingBias();
    
    //--- Market Condition Assessment ---
    ENUM_MARKET_CONDITION DetermineMarketCondition();
    bool                  IsTrendingMarket();
    bool                  IsRangingMarket();
    bool                  IsVolatileMarket();
    bool                  IsBreakoutCondition();
    
    //--- Risk Calculation ---
    void                  CalculateRiskLevel();
    void                  IdentifyRiskFactors();
    double                AssessNewsRisk();
    double                AssessVolatilityRisk();
    double                AssessLiquidityRisk();
    
    //--- Confidence Calculation ---
    double                CalculateConfidenceScore();
    double                AssessDataQuality();
    double                AssessConsistency();
    double                AssessTimeliness();
    
    //--- Performance Optimization ---
    void                  OptimizePerformance();
    bool                  ShouldSkipAnalysis(const ENUM_ANALYSIS_WEIGHT module);
    void                  CacheResults();
    bool                  LoadCachedResults();
    
    //--- Validation ---
    bool                  ValidateAnalysisResult();
    bool                  ValidateModuleData();
    bool                  CheckDataConsistency();
    
    //--- Utility Methods ---
    void                  LogAnalysisEvent(const string& event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO);
    string                BiasToString(const ENUM_MARKET_BIAS bias);
    string                ConditionToString(const ENUM_MARKET_CONDITION condition);
    string                ConfluenceToString(const ENUM_CONFLUENCE_LEVEL confluence);
    uint                  GetTickCount();
    
    //--- Module Management ---
    bool                  CreateAnalysisModules();
    void                  DestroyAnalysisModules();
    bool                  ConfigureModules();
    bool                  ValidateModules();
}; // END CLASS CMarketAnalysisManager

#endif // MARKET_ANALYSIS_MANAGER_MQH