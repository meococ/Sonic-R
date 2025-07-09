//+------------------------------------------------------------------+
//|                                                     AssetDNA.mqh |
//|                       APEX PULLBACK EA v5 FINAL - AssetDNA      |
//|      Description: Enhanced AssetDNA with v14 sophistication     |
//+------------------------------------------------------------------+

#ifndef ASSET_DNA_V5_FINAL_MQH
#define ASSET_DNA_V5_FINAL_MQH

#include "..\\..\\00_Core\\Common\\CommonStructs.mqh"
#include "..\\..\\00_Core\\Common\\Enums.mqh"

namespace ApexPullback {

//+------------------------------------------------------------------+
//| Strategy Performance Structure (Enhanced from v14)              |
//+------------------------------------------------------------------+
struct StrategyPerformance {
    ENUM_TRADING_STRATEGY strategy;
    int totalTrades;
    int winningTrades;
    double avgWinRate;
    double profitFactor;
    double expectancy;
    double sharpeRatio;
    double stabilityIndex;
    double overfittingScore;
    
    void Clear() {
        strategy = STRATEGY_UNDEFINED;
        totalTrades = 0;
        winningTrades = 0;
        avgWinRate = 0.0;
        profitFactor = 0.0;
        expectancy = 0.0;
        sharpeRatio = 0.0;
        stabilityIndex = 0.0;
        overfittingScore = 0.0;
    }
};

//+------------------------------------------------------------------+
//| Cross-Validation Result Structure (From v14)                    |
//+------------------------------------------------------------------+
struct CrossValidationResult {
    double avgWinRate;
    double avgProfitFactor;
    double avgExpectancy;
    double winRateVariance;
    double profitFactorVariance;
    double expectancyVariance;
    int validFolds;
    double stabilityIndex;
    
    void Clear() {
        avgWinRate = 0.0;
        avgProfitFactor = 0.0;
        avgExpectancy = 0.0;
        winRateVariance = 0.0;
        profitFactorVariance = 0.0;
        expectancyVariance = 0.0;
        validFolds = 0;
        stabilityIndex = 0.0;
    }
};

//+------------------------------------------------------------------+
//| Enhanced CAssetDNA Class                                         |
//+------------------------------------------------------------------+
class CAssetDNA {
private:
    EAContext* m_pContext;
    string m_symbol;
    ENUM_TIMEFRAMES m_timeframe;
    
    // Performance Analysis
    StrategyPerformance m_strategyStats[ENUM_TRADING_STRATEGY_COUNT];
    CArrayObj* m_tradeHistory;
    
    // Asset Characteristics
    double m_volatilityScore;
    double m_trendScore;
    double m_momentumScore;
    double m_regimeScore;
    
    // Analysis Parameters
    datetime m_cutoffTime;
    double m_decayHalfLife;
    int m_minTradesForAnalysis;
    
public:
    CAssetDNA();
    ~CAssetDNA();
    
    // Initialization
    bool Initialize(EAContext* context, const string symbol);
    void Deinitialize();
    
    // Core Analysis Methods
    bool FullAnalysis();
    void AnalyzeAssetCharacteristics();
    void LoadTradeHistory();
    void AnalyzeStrategyPerformance();
    
    // Strategy Optimization
    ENUM_TRADING_STRATEGY GetOptimalStrategy(const MarketState& currentProfile);
    double GetStrategyScore(ENUM_TRADING_STRATEGY strategy);
    
    // Asset Profile Access
    double GetVolatilityScore() const { return m_volatilityScore; }
    double GetTrendScore() const { return m_trendScore; }
    double GetMomentumScore() const { return m_momentumScore; }
    double GetRegimeScore() const { return m_regimeScore; }
    
    // Performance Metrics
    StrategyPerformance GetStrategyPerformance(ENUM_TRADING_STRATEGY strategy);
    bool IsStrategyReliable(ENUM_TRADING_STRATEGY strategy);
    
private:
    // Analysis Helpers
    double CalculateVolatilityScore(double atrPercent);
    double CalculateTrendScore(double ema20, double ema50, double ema200);
    double CalculateMomentumScore(double rsi, double macd);
    double CalculateTradeDecayWeight(datetime tradeTime);
    
    // Cross-Validation
    CrossValidationResult PerformCrossValidation(ENUM_TRADING_STRATEGY strategy, int folds = 5);
    double CalculateStabilityScore(const CrossValidationResult& cvResult);
    double CalculateOverfittingPenalty(const CrossValidationResult& cvResult);
    
    // Market Suitability
    double CalculateMarketSuitability(ENUM_TRADING_STRATEGY strategy, const MarketState& profile);
    double GetPastPerformanceScore(ENUM_TRADING_STRATEGY strategy);
    
    // Utility Methods
    void PrintAnalysisSummary();
    void UpdateConfiguration();
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CAssetDNA::CAssetDNA() : 
    m_pContext(NULL),
    m_tradeHistory(NULL),
    m_volatilityScore(0.0),
    m_trendScore(0.0),
    m_momentumScore(0.0),
    m_regimeScore(0.0),
    m_cutoffTime(0),
    m_decayHalfLife(30.0),
    m_minTradesForAnalysis(10)
{
    // Initialize strategy stats
    for(int i = 0; i < ENUM_TRADING_STRATEGY_COUNT; i++) {
        m_strategyStats[i].Clear();
        m_strategyStats[i].strategy = (ENUM_TRADING_STRATEGY)i;
    }
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CAssetDNA::~CAssetDNA() {
    if(m_tradeHistory) {
        delete m_tradeHistory;
        m_tradeHistory = NULL;
    }
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CAssetDNA::Initialize(EAContext* context, const string symbol) {
    if(!context || !context->pLogger) return false;
    
    m_pContext = context;
    m_symbol = symbol;
    m_timeframe = context->InputParams.MainTimeframe;
    
    // Initialize trade history
    m_tradeHistory = new CArrayObj();
    if(!m_tradeHistory) {
        if(m_pContext->pLogger) 
            m_pContext->pLogger->LogError("Failed to create trade history array", __FUNCTION__);
        return false;
    }
    m_tradeHistory->FreeMode(true);
    
    // Set analysis parameters from context
    if(context->InputParams.HistoryAnalysisMonths > 0) {
        m_cutoffTime = TimeCurrent() - (context->InputParams.HistoryAnalysisMonths * 30 * 24 * 3600);
    }
    m_decayHalfLife = context->InputParams.DecayHalfLifeDays;
    m_minTradesForAnalysis = context->InputParams.MinTradesForPerformance;
    
    if(m_pContext->pLogger)
        m_pContext->pLogger->LogInfo("AssetDNA initialized for " + m_symbol, __FUNCTION__);
        
    return true;
}

//+------------------------------------------------------------------+
//| Full Analysis Implementation                                     |
//+------------------------------------------------------------------+
bool CAssetDNA::FullAnalysis() {
    if(!m_pContext || !m_pContext->pLogger) return false;
    
    m_pContext->pLogger->LogInfo("Starting comprehensive AssetDNA analysis for " + m_symbol, __FUNCTION__);
    
    // Perform all analysis components
    AnalyzeAssetCharacteristics();
    LoadTradeHistory();
    AnalyzeStrategyPerformance();
    
    if(m_pContext->InputParams.EnableDNAPrinting) {
        PrintAnalysisSummary();
    }
    
    m_pContext->pLogger->LogInfo("AssetDNA analysis completed for " + m_symbol, __FUNCTION__);
    return true;
}

//+------------------------------------------------------------------+
//| Get Optimal Strategy                                             |
//+------------------------------------------------------------------+
ENUM_TRADING_STRATEGY CAssetDNA::GetOptimalStrategy(const MarketState& currentProfile) {
    if(!m_pContext || !m_pContext->pLogger) return STRATEGY_UNDEFINED;
    
    double highestScore = -1.0;
    ENUM_TRADING_STRATEGY bestStrategy = STRATEGY_UNDEFINED;
    
    for(int i = 0; i < ENUM_TRADING_STRATEGY_COUNT; i++) {
        ENUM_TRADING_STRATEGY strategy = (ENUM_TRADING_STRATEGY)i;
        if(strategy == STRATEGY_UNDEFINED) continue;
        
        double marketSuitability = CalculateMarketSuitability(strategy, currentProfile);
        double pastPerformance = GetPastPerformanceScore(strategy);
        
        double finalScore = (marketSuitability * m_pContext->InputParams.MarketSuitabilityWeight) + 
                           (pastPerformance * m_pContext->InputParams.PastPerformanceWeight);
        
        if(finalScore > highestScore) {
            highestScore = finalScore;
            bestStrategy = strategy;
        }
    }
    
    if(m_pContext->pLogger && m_pContext->InputParams.EnableDetailedScoreLogging) {
        m_pContext->pLogger->LogInfo(StringFormat("Optimal strategy: %s (Score: %.3f)", 
                                    EnumToString(bestStrategy), highestScore), __FUNCTION__);
    }
    
    return bestStrategy;
}

} // namespace ApexPullback

#endif // ASSET_DNA_V5_FINAL_MQH