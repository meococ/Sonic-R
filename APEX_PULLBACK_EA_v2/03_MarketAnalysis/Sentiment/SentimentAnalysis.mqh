//+------------------------------------------------------------------+
//|                                           SentimentAnalysis.mqh |
//|                                    APEX Pullback EA v5.0 FINAL |
//|                                   Advanced Sentiment Analysis   |
//+------------------------------------------------------------------+
#ifndef SENTIMENT_ANALYSIS_MQH
#define SENTIMENT_ANALYSIS_MQH

#include "../../01_Framework/CommonStructs.mqh"

//+------------------------------------------------------------------+
//| Sentiment Analysis Enumerations                                  |
//+------------------------------------------------------------------+
enum ENUM_SENTIMENT_TYPE {
    SENTIMENT_BULLISH,
    SENTIMENT_BEARISH,
    SENTIMENT_NEUTRAL,
    SENTIMENT_EXTREME_BULLISH,
    SENTIMENT_EXTREME_BEARISH,
    SENTIMENT_MIXED,
    SENTIMENT_UNKNOWN
};

enum ENUM_SENTIMENT_STRENGTH {
    SENTIMENT_STRENGTH_WEAK,
    SENTIMENT_STRENGTH_MODERATE,
    SENTIMENT_STRENGTH_STRONG,
    SENTIMENT_STRENGTH_VERY_STRONG,
    SENTIMENT_STRENGTH_EXTREME
};

enum ENUM_SENTIMENT_SOURCE {
    SOURCE_COT_REPORT,
    SOURCE_VIX_INDEX,
    SOURCE_PUT_CALL_RATIO,
    SOURCE_MARGIN_DEBT,
    SOURCE_INSIDER_TRADING,
    SOURCE_FUND_FLOWS,
    SOURCE_SURVEY_DATA,
    SOURCE_SOCIAL_MEDIA,
    SOURCE_NEWS_SENTIMENT,
    SOURCE_TECHNICAL_INDICATORS,
    SOURCE_POSITIONING_DATA
};

enum ENUM_MARKET_PHASE {
    PHASE_ACCUMULATION,
    PHASE_MARKUP,
    PHASE_DISTRIBUTION,
    PHASE_MARKDOWN,
    PHASE_CONSOLIDATION,
    PHASE_REVERSAL,
    PHASE_BREAKOUT
};

enum ENUM_CROWD_BEHAVIOR {
    CROWD_EUPHORIA,
    CROWD_OPTIMISM,
    CROWD_HOPE,
    CROWD_RELIEF,
    CROWD_FEAR,
    CROWD_DESPERATION,
    CROWD_PANIC,
    CROWD_CAPITULATION,
    CROWD_DEPRESSION,
    CROWD_SKEPTICISM,
    CROWD_CAUTIOUS_OPTIMISM
};

//+------------------------------------------------------------------+
//| Sentiment Analysis Structures                                    |
//+------------------------------------------------------------------+
struct SSentimentReading {
    ENUM_SENTIMENT_TYPE   Type;
    ENUM_SENTIMENT_STRENGTH Strength;
    ENUM_SENTIMENT_SOURCE Source;
    double                Value;
    double                NormalizedValue; // -100 to +100
    datetime              Time;
    bool                  IsReliable;
    double                Confidence;
    string                Description;
};

struct SSentimentComposite {
    ENUM_SENTIMENT_TYPE   OverallSentiment;
    ENUM_SENTIMENT_STRENGTH OverallStrength;
    double                CompositeScore; // -100 to +100
    double                BullishPercentage;
    double                BearishPercentage;
    double                NeutralPercentage;
    int                   DataPoints;
    double                Reliability;
    datetime              LastUpdate;
    bool                  IsExtremeReading;
    bool                  IsContrarianSignal;
};

struct SCOTData {
    // Commitment of Traders data
    double                CommercialLong;
    double                CommercialShort;
    double                CommercialNet;
    double                NonCommercialLong;
    double                NonCommercialShort;
    double                NonCommercialNet;
    double                RetailLong;
    double                RetailShort;
    double                RetailNet;
    double                OpenInterest;
    datetime              ReportDate;
    bool                  IsValid;
};

struct SFearGreedIndex {
    double                Index; // 0-100
    ENUM_SENTIMENT_TYPE   Classification;
    double                VIXComponent;
    double                MomentumComponent;
    double                StockPriceComponent;
    double                JunkBondComponent;
    double                MarketVolatilityComponent;
    double                SafeHavenComponent;
    datetime              Time;
    bool                  IsExtreme;
};

struct SPositioningData {
    double                LongPositions;
    double                ShortPositions;
    double                NetPositions;
    double                LongPercentage;
    double                ShortPercentage;
    double                PositionRatio;
    double                ExtremeLevel;
    bool                  IsExtremePositioning;
    ENUM_SENTIMENT_TYPE   PositioningSentiment;
    datetime              Time;
};

struct SMarketPsychology {
    ENUM_CROWD_BEHAVIOR   CrowdBehavior;
    ENUM_MARKET_PHASE     MarketPhase;
    double                EmotionIndex; // 0-100
    double                GreedLevel;
    double                FearLevel;
    double                EuphoriaLevel;
    double                PanicLevel;
    bool                  IsEmotionalExtreme;
    bool                  IsContrarianOpportunity;
    datetime              Time;
};

struct SSentimentConfig {
    // Data Sources
    bool                  UseCOTData;
    bool                  UseVIXData;
    bool                  UsePutCallRatio;
    bool                  UsePositioningData;
    bool                  UseFundFlows;
    bool                  UseSurveyData;
    bool                  UseNewsAnalysis;
    
    // Analysis Settings
    int                   LookbackPeriod;
    int                   SmoothingPeriod;
    bool                  UseNormalization;
    bool                  DetectExtremes;
    bool                  GenerateSignals;
    
    // Thresholds
    double                ExtremeBullishThreshold;
    double                ExtremeBearishThreshold;
    double                ContrarianThreshold;
    double                ReliabilityThreshold;
    
    // Weights
    double                COTWeight;
    double                VIXWeight;
    double                PutCallWeight;
    double                PositioningWeight;
    double                NewsWeight;
    double                TechnicalWeight;
    
    // Update Settings
    int                   UpdateFrequency; // minutes
    bool                  RealTimeUpdates;
    bool                  HistoricalAnalysis;
};

struct SSentimentStats {
    int                   TotalReadings;
    int                   BullishReadings;
    int                   BearishReadings;
    int                   ExtremeReadings;
    int                   ContrarianSignals;
    double                AverageScore;
    double                Volatility;
    double                Accuracy;
    datetime              LastExtremeReading;
    datetime              LastUpdate;
};

//+------------------------------------------------------------------+
//| Sentiment Analysis Class                                          |
//+------------------------------------------------------------------+
class CSentimentAnalysis {
private:
    // Core properties
    EAContext*            m_pContext;
    bool                  m_bInitialized;
    string                m_Symbol;
    
    // Configuration
    SSentimentConfig      m_Config;
    SSentimentStats       m_Stats;
    
    // Sentiment data
    SSentimentReading     m_Readings[];
    int                   m_ReadingCount;
    SSentimentComposite   m_CompositeSentiment;
    
    // Specialized data
    SCOTData              m_COTData;
    SFearGreedIndex       m_FearGreedIndex;
    SPositioningData      m_PositioningData;
    SMarketPsychology     m_MarketPsychology;
    
    // Historical data
    double                m_HistoricalScores[];
    int                   m_HistoryCount;
    
    // Analysis state
    datetime              m_LastUpdate;
    bool                  m_DataValid;
    bool                  m_ExtremeDetected;
    bool                  m_ContrarianSignal;
    
    // Constants
    static const int      MAX_READINGS;
    static const int      MAX_HISTORY;
    static const double   EXTREME_THRESHOLD;
    
public:
    //--- Constructor/Destructor ---
    CSentimentAnalysis();
    ~CSentimentAnalysis();
    
    //--- Core Methods ---
    bool                  Initialize(EAContext* context, const string& symbol, const SSentimentConfig& config);
    void                  Deinitialize();
    bool                  IsInitialized() const { return m_bInitialized; }
    void                  Update();
    
    //--- Data Collection ---
    bool                  CollectSentimentData();
    bool                  UpdateCOTData();
    bool                  UpdateVIXData();
    bool                  UpdatePutCallRatio();
    bool                  UpdatePositioningData();
    bool                  UpdateFundFlows();
    bool                  UpdateSurveyData();
    
    //--- Sentiment Analysis ---
    SSentimentComposite   AnalyzeCompositeSentiment();
    SSentimentComposite   GetCompositeSentiment() const { return m_CompositeSentiment; }
    ENUM_SENTIMENT_TYPE   GetCurrentSentiment();
    ENUM_SENTIMENT_STRENGTH GetSentimentStrength();
    double                GetSentimentScore();
    
    //--- Extreme Detection ---
    bool                  IsExtremeSentiment();
    bool                  IsExtremeBullish();
    bool                  IsExtremeBearish();
    bool                  DetectSentimentExtreme();
    double                GetExtremeLevel();
    
    //--- Contrarian Analysis ---
    bool                  IsContrarianSignal();
    bool                  GenerateContrarianSignal();
    double                GetContrarianStrength();
    ENUM_SENTIMENT_TYPE   GetContrarianBias();
    
    //--- Market Psychology ---
    SMarketPsychology     AnalyzeMarketPsychology();
    ENUM_CROWD_BEHAVIOR   GetCrowdBehavior();
    ENUM_MARKET_PHASE     GetMarketPhase();
    double                GetEmotionIndex();
    double                GetFearGreedRatio();
    
    //--- COT Analysis ---
    SCOTData              GetCOTData() const { return m_COTData; }
    ENUM_SENTIMENT_TYPE   AnalyzeCOTSentiment();
    double                GetCommercialBias();
    double                GetRetailBias();
    bool                  IsExtremePositioning();
    
    //--- VIX Analysis ---
    double                GetVIXLevel();
    ENUM_SENTIMENT_TYPE   AnalyzeVIXSentiment();
    bool                  IsVIXExtreme();
    double                GetVIXPercentile();
    
    //--- Put/Call Analysis ---
    double                GetPutCallRatio();
    ENUM_SENTIMENT_TYPE   AnalyzePutCallSentiment();
    bool                  IsPutCallExtreme();
    
    //--- Positioning Analysis ---
    SPositioningData      GetPositioningData() const { return m_PositioningData; }
    ENUM_SENTIMENT_TYPE   AnalyzePositioning();
    double                GetPositioningBias();
    bool                  IsPositioningExtreme();
    
    //--- Historical Analysis ---
    void                  AnalyzeHistoricalSentiment();
    double                GetSentimentPercentile(const int periods = 252);
    double                GetAverageSentiment(const int periods = 20);
    double                GetSentimentVolatility(const int periods = 20);
    bool                  CompareToPreviousCycles();
    
    //--- Signal Generation ---
    bool                  GenerateBullishSignal();
    bool                  GenerateBearishSignal();
    bool                  GenerateNeutralSignal();
    double                GetSignalStrength();
    double                GetSignalReliability();
    
    //--- Risk Assessment ---
    double                GetSentimentRisk();
    double                GetContrarianRisk();
    bool                  ShouldReduceRisk();
    bool                  ShouldIncreaseRisk();
    double                GetRiskMultiplier();
    
    //--- Statistics ---
    SSentimentStats       GetStatistics() const { return m_Stats; }
    void                  UpdateStatistics();
    double                GetAccuracy() const { return m_Stats.Accuracy; }
    
    //--- Configuration ---
    bool                  SetConfiguration(const SSentimentConfig& config);
    SSentimentConfig      GetConfiguration() const { return m_Config; }
    bool                  SetWeights(const double cot_weight, const double vix_weight, 
                                   const double putcall_weight, const double positioning_weight);
    
    //--- Information ---
    string                GetSentimentSummary();
    string                GetExtremeSummary();
    string                GetContrarianSummary();
    string                GetPsychologySummary();
    
private:
    //--- Data Processing ---
    void                  ProcessSentimentReading(const SSentimentReading& reading);
    double                NormalizeSentimentValue(const double value, const ENUM_SENTIMENT_SOURCE source);
    double                CalculateCompositeScore();
    void                  UpdateCompositeSentiment();
    
    //--- COT Processing ---
    bool                  LoadCOTData();
    void                  ProcessCOTData();
    double                CalculateCOTSentiment();
    bool                  ValidateCOTData();
    
    //--- VIX Processing ---
    bool                  LoadVIXData();
    void                  ProcessVIXData();
    double                CalculateVIXSentiment();
    double                GetVIXHistoricalPercentile();
    
    //--- Put/Call Processing ---
    bool                  LoadPutCallData();
    void                  ProcessPutCallData();
    double                CalculatePutCallSentiment();
    
    //--- Positioning Processing ---
    bool                  LoadPositioningData();
    void                  ProcessPositioningData();
    double                CalculatePositioningSentiment();
    
    //--- Extreme Detection ---
    void                  DetectExtremes();
    bool                  IsHistoricalExtreme(const double value, const int lookback = 252);
    double                CalculateZScore(const double value, const int periods = 20);
    
    //--- Psychology Analysis ---
    void                  AnalyzeCrowdBehavior();
    void                  DetermineMarketPhase();
    double                CalculateEmotionIndex();
    void                  UpdateMarketPsychology();
    
    //--- Signal Processing ---
    void                  ProcessSignals();
    bool                  ValidateSignal(const ENUM_SENTIMENT_TYPE signal);
    double                CalculateSignalConfidence();
    
    //--- Utility Methods ---
    double                Smooth(const double values[], const int count, const int period);
    double                CalculatePercentile(const double values[], const int count, const double percentile);
    double                CalculateStandardDeviation(const double values[], const int count);
    void                  LogSentimentEvent(const string& event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO);
    string                SentimentTypeToString(const ENUM_SENTIMENT_TYPE type);
    string                SentimentStrengthToString(const ENUM_SENTIMENT_STRENGTH strength);
    string                CrowdBehaviorToString(const ENUM_CROWD_BEHAVIOR behavior);
    string                MarketPhaseToString(const ENUM_MARKET_PHASE phase);
    
    //--- Array Management ---
    void                  AddReadingToArray(const SSentimentReading& reading);
    void                  AddScoreToHistory(const double score);
    void                  ResizeReadingArray(const int new_size);
    void                  ResizeHistoryArray(const int new_size);
    void                  CleanupOldData();
};

// Static constants definition
const int CSentimentAnalysis::MAX_READINGS = 1000;
const int CSentimentAnalysis::MAX_HISTORY = 5000;
const double CSentimentAnalysis::EXTREME_THRESHOLD = 80.0;

#endif // SENTIMENT_ANALYSIS_MQH