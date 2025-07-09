//+------------------------------------------------------------------+
//|                                                 SignalEngine.mqh |
//|                   SignalEngine - APEX Pullback EA v5 FINAL      |
//|      Description: Enhanced signal generation engine with         |
//|                   multi-strategy support, confidence scoring,    |
//|                   and advanced market context analysis (v14)     |
//+------------------------------------------------------------------+

#ifndef APEX_SIGNALENGINE_MQH_
#define APEX_SIGNALENGINE_MQH_

#include "../../01_Framework/CommonStructs.mqh"


//+------------------------------------------------------------------+
//| Enhanced Signal Structures (v14 Features)                       |
//+------------------------------------------------------------------+
struct SSignalContext {
    // Basic signal information
    ENUM_SIGNAL_TYPE      signalType;         // Signal type
    ENUM_TRADING_STRATEGY strategy;           // Strategy that generated signal
    double                confidenceScore;    // Confidence score (0-1)
    double                entryPrice;         // Suggested entry price
    double                stopLoss;           // Suggested stop loss
    double                takeProfit;         // Suggested take profit
    
    // Market context
    ENUM_MARKET_REGIME    marketRegime;       // Current market regime
    double                volatility;         // Current volatility (ATR)
    double                spread;             // Current spread
    double                trendStrength;      // Trend strength (0-1)
    
    // Signal quality metrics
    double                riskRewardRatio;    // Risk/reward ratio
    double                expectedPips;       // Expected profit in pips
    double                maxRiskPips;        // Maximum risk in pips
    int                   urgencyLevel;       // Urgency level (1-5)
    
    // Timing and validation
    datetime              signalTime;         // Signal generation time
    datetime              expiryTime;         // Signal expiry time
    bool                  isValidated;        // Validation status
    string                signalReason;       // Reason for signal
    
    // Multi-timeframe analysis
    bool                  mtfAlignment;       // Multi-timeframe alignment
    double                mtfStrength;        // MTF strength score
    ENUM_TREND_DIRECTION  h1Trend;           // H1 trend direction
    ENUM_TREND_DIRECTION  h4Trend;           // H4 trend direction
    
    void Clear() {
        signalType = SIGNAL_NONE;
        strategy = STRATEGY_UNDEFINED;
        confidenceScore = 0.0;
        entryPrice = 0.0;
        stopLoss = 0.0;
        takeProfit = 0.0;
        marketRegime = REGIME_UNKNOWN;
        volatility = 0.0;
        spread = 0.0;
        trendStrength = 0.0;
        riskRewardRatio = 0.0;
        expectedPips = 0.0;
        maxRiskPips = 0.0;
        urgencyLevel = 1;
        signalTime = 0;
        expiryTime = 0;
        isValidated = false;
        signalReason = "";
        mtfAlignment = false;
        mtfStrength = 0.0;
        h1Trend = TREND_UNKNOWN;
        h4Trend = TREND_UNKNOWN;
    }
};

struct SSignalQuality {
    double                overallScore;       // Overall quality score (0-1)
    double                technicalScore;     // Technical analysis score
    double                timingScore;        // Timing quality score
    double                marketConditionScore; // Market condition score
    double                riskScore;          // Risk assessment score
    double                consistencyScore;   // Signal consistency score
    
    void Clear() {
        overallScore = 0.0;
        technicalScore = 0.0;
        timingScore = 0.0;
        marketConditionScore = 0.0;
        riskScore = 0.0;
        consistencyScore = 0.0;
    }
};

struct SSignalStatistics {
    int                   totalSignals;       // Total signals generated
    int                   bullishSignals;     // Number of bullish signals
    int                   bearishSignals;     // Number of bearish signals
    double                avgConfidence;      // Average confidence score
    double                avgRiskReward;      // Average risk/reward ratio
    int                   validatedSignals;   // Number of validated signals
    double                validationRate;     // Validation success rate
    datetime              lastSignalTime;     // Last signal generation time
    ENUM_SIGNAL_TYPE      lastSignalType;     // Last signal type
    
    void Clear() {
        totalSignals = 0;
        bullishSignals = 0;
        bearishSignals = 0;
        avgConfidence = 0.0;
        avgRiskReward = 0.0;
        validatedSignals = 0;
        validationRate = 0.0;
        lastSignalTime = 0;
        lastSignalType = SIGNAL_NONE;
    }
};

//+------------------------------------------------------------------+
//| Enhanced CSignalEngine - Multi-Strategy Signal Generation (v14) |
//+------------------------------------------------------------------+
class CSignalEngine {
private:
    EAContext*            m_pContext;
    bool                  m_bInitialized;
    
    // Enhanced indicator handles (v14)
    int                   m_hTrendEMA;       // Trend EMA (e.g., 200)
    int                   m_hPullbackEMA;    // Pullback EMA (e.g., 21)
    int                   m_hRSI;            // RSI for momentum confirmation
    int                   m_hATR;            // ATR for volatility measurement
    int                   m_hMACD;           // MACD for momentum analysis
    int                   m_hStochastic;     // Stochastic for overbought/oversold
    int                   m_hBollinger;      // Bollinger Bands for volatility
    
    // Multi-timeframe handles
    int                   m_hH1_EMA;         // H1 timeframe EMA
    int                   m_hH4_EMA;         // H4 timeframe EMA
    int                   m_hH1_RSI;         // H1 timeframe RSI
    int                   m_hH4_RSI;         // H4 timeframe RSI
    
    // Enhanced signal management (v14)
    SSignalContext        m_CurrentSignal;   // Current signal context
    SSignalQuality        m_SignalQuality;   // Current signal quality
    SSignalStatistics     m_Statistics;      // Signal statistics
    
    // Signal validation and timing
    datetime              m_dtLastSignalTime;
    ENUM_SIGNAL_TYPE      m_LastSignalType;
    int                   m_iSignalCount;
    double                m_MinConfidenceThreshold;
    
    // Missing fields for signal tracking
    double                m_trendEMA;         // Current trend EMA value
    double                m_pullbackEMA;      // Current pullback EMA value  
    double                m_rsiValue;         // Current RSI value
    
    // Strategy-specific parameters
    ENUM_TRADING_STRATEGY m_CurrentStrategy;
    bool                  m_UseAssetDNA;
    
public:
    //--- Constructor/Destructor ---
    CSignalEngine();
    ~CSignalEngine();
    
    //--- Initialization ---
    bool                  Initialize(EAContext* pContext);
    void                  Deinitialize();
    bool                  IsInitialized() const { return m_bInitialized; }
    
    //--- Enhanced Signal Generation (v14) ---
    SSignalContext        GenerateSignal();
    ENUM_SIGNAL_TYPE      CheckForSignal();
    bool                  CheckPullbackSignal(SSignalContext& signal);
    bool                  CheckMomentumSignal(SSignalContext& signal);
    bool                  CheckReversalSignal(SSignalContext& signal);
    bool                  CheckBreakoutSignal(SSignalContext& signal);
    
    //--- Signal Quality Assessment (v14) ---
    SSignalQuality        CalculateSignalQuality(const SSignalContext& signal);
    double                CalculateConfidenceScore(const SSignalContext& signal);
    double                CalculateTechnicalScore(const SSignalContext& signal);
    double                CalculateTimingScore(const SSignalContext& signal);
    double                CalculateMarketConditionScore(const SSignalContext& signal);
    
    //--- Signal Validation (v14) ---
    bool                  ValidateSignal(SSignalContext& signal);
    bool                  ValidateMarketConditions(const SSignalContext& signal);
    bool                  ValidateRiskParameters(const SSignalContext& signal);
    bool                  ValidateNews(const SSignalContext& signal);
    bool                  ValidateCorrelation(const SSignalContext& signal);
    
    //--- Enhanced Multi-timeframe Analysis (v14) ---
    bool                  AnalyzeMultiTimeframe(SSignalContext& signal);
    ENUM_TREND_DIRECTION  GetTrendDirection(ENUM_TIMEFRAMES timeframe);
    double                GetTrendStrength(ENUM_TIMEFRAMES timeframe);
    bool                  IsMultiTimeframeAligned(ENUM_SIGNAL_TYPE signal_type);
    double                CalculateMultiTimeframeScore(ENUM_SIGNAL_TYPE signal_type);
    
    //--- Market Context Analysis (v14) ---
    ENUM_MARKET_REGIME    DetectMarketRegime();
    double                CalculateVolatilityIndex();
    bool                  IsMarketConditionSuitable(ENUM_TRADING_STRATEGY strategy);
    double                CalculateMarketNoise();
    bool                  IsLiquidityAdequate();
    
    //--- Strategy Selection (v14) ---
    ENUM_TRADING_STRATEGY SelectOptimalStrategy();
    double                GetStrategyScore(ENUM_TRADING_STRATEGY strategy);
    bool                  IsStrategyValid(ENUM_TRADING_STRATEGY strategy);
    
    //--- Signal Analysis ---
    ENUM_SIGNAL_STRENGTH  GetSignalStrength(ENUM_SIGNAL_TYPE signal_type);
    bool                  IsUptrend();
    bool                  IsDowntrend();
    bool                  IsPullbackCondition();
    bool                  IsRSIValid(ENUM_SIGNAL_TYPE signal_type);
    bool                  CheckSpreadConditions();
    bool                  CheckVolatilityConditions();
    bool                  CheckNewsEvents();
    
    //--- Enhanced Getters (v14) ---
    SSignalContext        GetCurrentSignal() const { return m_CurrentSignal; }
    SSignalQuality        GetSignalQuality() const { return m_SignalQuality; }
    SSignalStatistics     GetStatistics() const { return m_Statistics; }
    int                   GetSignalCount() const { return m_iSignalCount; }
    datetime              GetLastSignalTime() const { return m_dtLastSignalTime; }
    ENUM_SIGNAL_TYPE      GetLastSignalType() const { return m_LastSignalType; }
    double                GetMinConfidenceThreshold() const { return m_MinConfidenceThreshold; }
    
    //--- Configuration ---
    void                  SetMinConfidenceThreshold(double threshold) { m_MinConfidenceThreshold = threshold; }
    void                  SetCurrentStrategy(ENUM_TRADING_STRATEGY strategy) { m_CurrentStrategy = strategy; }
    void                  EnableAssetDNA(bool enable) { m_UseAssetDNA = enable; }
    
private:
    //--- Enhanced Helper Methods (v14) ---
    bool                  CreateIndicators();
    bool                  CreateMultiTimeframeIndicators();
    void                  ReleaseIndicators();
    bool                  GetIndicatorValues(double& trend_ema, double& pullback_ema, double& rsi_value, double& atr_value);
    bool                  GetEnhancedIndicatorValues(double values[]);
    bool                  GetMultiTimeframeValues(double h1_values[], double h4_values[]);
    
    //--- Signal Processing ---
    void                  ProcessSignal(SSignalContext& signal);
    void                  CalculateSignalParameters(SSignalContext& signal);
    void                  ApplyRiskManagement(SSignalContext& signal);
    void                  OptimizeEntryTiming(SSignalContext& signal);
    
    //--- Validation Helpers ---
    bool                  CheckSignalTiming();
    bool                  CheckSpreadConditions();
    bool                  CheckVolatilityConditions();
    bool                  CheckNewsEvents();
    
    //--- Statistics and Logging ---
    void                  UpdateSignalStatistics(const SSignalContext& signal);
    void                  LogSignalDetails(const SSignalContext& signal);
    void                  LogSignalQuality(const SSignalQuality& quality);
    
    //--- Utility Methods ---
    double                NormalizeScore(double value, double min_val, double max_val);
    string                SignalTypeToString(ENUM_SIGNAL_TYPE signal_type);
    string                StrategyToString(ENUM_TRADING_STRATEGY strategy);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSignalEngine::CSignalEngine() : 
    m_pContext(NULL),
    m_bInitialized(false),
    m_hTrendEMA(INVALID_HANDLE),
    m_hPullbackEMA(INVALID_HANDLE),
    m_hRSI(INVALID_HANDLE),
    m_hATR(INVALID_HANDLE),
    m_hMACD(INVALID_HANDLE),
    m_hStochastic(INVALID_HANDLE),
    m_hBollinger(INVALID_HANDLE),
    m_hH1_EMA(INVALID_HANDLE),
    m_hH4_EMA(INVALID_HANDLE),
    m_hH1_RSI(INVALID_HANDLE),
    m_hH4_RSI(INVALID_HANDLE),
    m_dtLastSignalTime(0),
    m_LastSignalType(SIGNAL_NONE),
    m_iSignalCount(0),
    m_MinConfidenceThreshold(0.6),
    m_CurrentStrategy(STRATEGY_PULLBACK_TREND),
    m_UseAssetDNA(true)
{
    m_CurrentSignal.Clear();
    m_SignalQuality.Clear();
    m_Statistics.Clear();
}
    
    // Basic indicators
    m_hTrendEMA = INVALID_HANDLE;
    m_hPullbackEMA = INVALID_HANDLE;
    m_hRSI = INVALID_HANDLE;
    m_hATR = INVALID_HANDLE;
    m_hMACD = INVALID_HANDLE;
    m_hStochastic = INVALID_HANDLE;
    m_hBollinger = INVALID_HANDLE;
    
    // Multi-timeframe indicators
    m_hH1_EMA = INVALID_HANDLE;
    m_hH4_EMA = INVALID_HANDLE;
    m_hH1_RSI = INVALID_HANDLE;
    m_hH4_RSI = INVALID_HANDLE;
    
    // Signal management
    m_CurrentSignal.Clear();
    m_SignalQuality.Clear();
    m_Statistics.Clear();
    
    // Initialize parameters
    m_dtLastSignalTime = 0;
    m_LastSignalType = SIGNAL_NONE;
    m_iSignalCount = 0;
    m_MinConfidenceThreshold = 0.6;
    m_CurrentStrategy = STRATEGY_PULLBACK_TREND;
    m_UseAssetDNA = true;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSignalEngine::~CSignalEngine() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Enhanced Initialize Signal Engine (v14)                         |
//+------------------------------------------------------------------+
bool CSignalEngine::Initialize(EAContext* pContext)
{
    if (m_bInitialized) return true;
    if (pContext == NULL)
    {
        PrintFormat("%s: EAContext is null", __FUNCTION__);
        return false;
    }
    m_pContext = pContext;
    
    // Enhanced validation with more robust null pointer checks
    if (m_pContext->pLogger == NULL || m_pContext->pErrorHandler == NULL || 
        m_pContext->pSymbolManager == NULL || m_pContext->pTimeManager == NULL) {
        string errorMsg = "Critical context pointer is NULL: ";
        if(m_pContext->pLogger == NULL) errorMsg += "Logger ";
        if(m_pContext->pErrorHandler == NULL) errorMsg += "ErrorHandler ";
        if(m_pContext->pSymbolManager == NULL) errorMsg += "SymbolManager ";
        if(m_pContext->pTimeManager == NULL) errorMsg += "TimeManager ";
        
        Print("[SignalEngine] ERROR: " + errorMsg);
        
        if(m_pContext->pErrorHandler != NULL) {
            m_pContext->pErrorHandler->HandleError(ERR_INVALID_POINTER, __FUNCTION__, errorMsg);
        }
        return false;
    }
    
    m_pContext->pLogger->LogInfo("Initializing Enhanced SignalEngine v14...", __FUNCTION__);
    
    // Create enhanced indicators
    if (!CreateIndicators()) {
        m_pContext->pLogger->LogError("Failed to create indicators", __FUNCTION__);
        return false;
    }
    
    // Create multi-timeframe indicators
    if (!CreateMultiTimeframeIndicators()) {
        m_pContext->pLogger->LogError("Failed to create multi-timeframe indicators", __FUNCTION__);
        return false;
    }
    
    // Initialize enhanced signal management
    m_CurrentSignal.Clear();
    m_SignalQuality.Clear();
    m_Statistics.Clear();
    
    m_dtLastSignalTime = 0;
    m_LastSignalType = SIGNAL_NONE;
    m_iSignalCount = 0;
    
    // Set configuration from inputs
    m_MinConfidenceThreshold = 0.6; // Default, can be adjusted
    m_CurrentStrategy = STRATEGY_PULLBACK_TREND; // Default strategy
    m_UseAssetDNA = true; // Enable AssetDNA integration
    
    m_bInitialized = true;
    m_pContext->pLogger->LogInfo("Enhanced SignalEngine v14 initialized successfully", __FUNCTION__);
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize Signal Engine                                       |
//+------------------------------------------------------------------+
void CSignalEngine::Deinitialize() {
    if (!m_bInitialized) {
        return;
    }
    
    if (m_pContext != NULL && m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo("Deinitializing Enhanced SignalEngine...", __FUNCTION__);
    }
    
    ReleaseIndicators();
    
    m_bInitialized = false;
    
    if (m_pContext != NULL && m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo("Enhanced SignalEngine deinitialized", __FUNCTION__);
    }
    
    m_pContext = NULL;
}

//+------------------------------------------------------------------+
//| Enhanced Generate Signal (v14 Main Method)                      |
//+------------------------------------------------------------------+
SSignalContext CSignalEngine::GenerateSignal() {
    SSignalContext signal;
    signal.Clear();
    
    if (!m_bInitialized || !m_pContext) {
        return signal;
    }
    
    // Check timing constraints
    if (!CheckSignalTiming()) {
        return signal;
    }
    
    // Select optimal strategy based on market conditions and AssetDNA
    if (m_UseAssetDNA && m_pContext->pAssetDNA != NULL) {
        m_CurrentStrategy = m_pContext->pAssetDNA->GetOptimalStrategy();
    }
    
    if (m_CurrentStrategy == STRATEGY_UNDEFINED) {
        m_CurrentStrategy = SelectOptimalStrategy();
    }
    
    // Generate signal based on current strategy
    bool signalFound = false;
    
    switch (m_CurrentStrategy) {
        case STRATEGY_PULLBACK_TREND:
        case STRATEGY_SHALLOW_PULLBACK:
            signalFound = CheckPullbackSignal(signal);
            break;
            
        case STRATEGY_MOMENTUM_BREAKOUT:
            signalFound = CheckMomentumSignal(signal);
            break;
            
        case STRATEGY_MEAN_REVERSION:
            signalFound = CheckReversalSignal(signal);
            break;
            
        case STRATEGY_BREAKOUT:
            signalFound = CheckBreakoutSignal(signal);
            break;
            
        default:
            signalFound = CheckPullbackSignal(signal); // Default to pullback
            break;
    }
    
    if (!signalFound || signal.signalType == SIGNAL_NONE) {
        return signal;
    }
    
    // Set strategy and basic info
    signal.strategy = m_CurrentStrategy;
    signal.signalTime = TimeCurrent();
    signal.expiryTime = signal.signalTime + 300; // 5 minutes expiry
    
    // Analyze multi-timeframe alignment
    AnalyzeMultiTimeframe(signal);
    
    // Calculate signal quality and confidence
    m_SignalQuality = CalculateSignalQuality(signal);
    signal.confidenceScore = CalculateConfidenceScore(signal);
    
    // Process and optimize signal
    ProcessSignal(signal);
    
    // Validate signal
    if (ValidateSignal(signal)) {
        signal.isValidated = true;
        m_CurrentSignal = signal;
        
        // Update statistics
        UpdateSignalStatistics(signal);
        
        // Log signal details
        LogSignalDetails(signal);
        LogSignalQuality(m_SignalQuality);
        
        m_pContext->pLogger->LogInfo(StringFormat("Enhanced signal generated: %s %s (Confidence: %.2f)", 
            SignalTypeToString(signal.signalType), StrategyToString(signal.strategy), signal.confidenceScore), __FUNCTION__);
    } else {
        signal.Clear(); // Clear invalid signal
        m_pContext->pLogger->LogInfo("Signal failed validation", __FUNCTION__);
    }
    
    return signal;
}

//+------------------------------------------------------------------+
//| Check for Trading Signal (Backward Compatibility)               |
//+------------------------------------------------------------------+
ENUM_SIGNAL_TYPE CSignalEngine::CheckForSignal() {
    SSignalContext signal = GenerateSignal();
    return signal.signalType;
}

//+------------------------------------------------------------------+
//| Create Indicators                                                |
//+------------------------------------------------------------------+
bool CSignalEngine::CreateIndicators() {
    string symbol = _Symbol;
    ENUM_TIMEFRAMES timeframe = m_pContext->Inputs.MainTimeframe;
    
    // Create Trend EMA
    m_hTrendEMA = iMA(symbol, timeframe, m_pContext->Inputs.EMA_Slow, 0, MODE_EMA, PRICE_CLOSE);
    if (m_hTrendEMA == INVALID_HANDLE) {
        m_pContext->pLogger->LogError("Failed to create Trend EMA", __FUNCTION__);
        return false;
    }
    
    // Create Pullback EMA
    m_hPullbackEMA = iMA(symbol, timeframe, m_pContext->Inputs.EMA_Fast, 0, MODE_EMA, PRICE_CLOSE);
    if (m_hPullbackEMA == INVALID_HANDLE) {
        m_pContext->pLogger->LogError("Failed to create Pullback EMA", __FUNCTION__);
        return false;
    }
    
    // Create RSI
    m_hRSI = iRSI(symbol, timeframe, 14, PRICE_CLOSE);
    if (m_hRSI == INVALID_HANDLE) {
        m_pContext->pLogger->LogError("Failed to create RSI", __FUNCTION__);
        return false;
    }
    
    // Create ATR
    m_hATR = iATR(symbol, timeframe, 14);
    if (m_hATR == INVALID_HANDLE) {
        m_pContext->pLogger->LogError("Failed to create ATR", __FUNCTION__);
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Create Multi-timeframe Indicators                                |
//+------------------------------------------------------------------+
bool CSignalEngine::CreateMultiTimeframeIndicators() {
    string symbol = _Symbol;
    ENUM_TIMEFRAMES timeframe = m_pContext->Inputs.MainTimeframe;
    
    // Create H1 EMA
    m_hH1_EMA = iMA(symbol, timeframe, 100, 0, MODE_EMA, PRICE_CLOSE);
    if (m_hH1_EMA == INVALID_HANDLE) {
        m_pContext->pLogger->LogError("Failed to create H1 EMA", __FUNCTION__);
        return false;
    }
    
    // Create H4 EMA
    m_hH4_EMA = iMA(symbol, timeframe, 200, 0, MODE_EMA, PRICE_CLOSE);
    if (m_hH4_EMA == INVALID_HANDLE) {
        m_pContext->pLogger->LogError("Failed to create H4 EMA", __FUNCTION__);
        return false;
    }
    
    // Create H1 RSI
    m_hH1_RSI = iRSI(symbol, timeframe, 14, PRICE_CLOSE);
    if (m_hH1_RSI == INVALID_HANDLE) {
        m_pContext->pLogger->LogError("Failed to create H1 RSI", __FUNCTION__);
        return false;
    }
    
    // Create H4 RSI
    m_hH4_RSI = iRSI(symbol, timeframe, 14, PRICE_CLOSE);
    if (m_hH4_RSI == INVALID_HANDLE) {
        m_pContext->pLogger->LogError("Failed to create H4 RSI", __FUNCTION__);
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Release Indicators                                               |
//+------------------------------------------------------------------+
void CSignalEngine::ReleaseIndicators() {
    if (m_hTrendEMA != INVALID_HANDLE) {
        IndicatorRelease(m_hTrendEMA);
        m_hTrendEMA = INVALID_HANDLE;
    }
    
    if (m_hPullbackEMA != INVALID_HANDLE) {
        IndicatorRelease(m_hPullbackEMA);
        m_hPullbackEMA = INVALID_HANDLE;
    }
    
    if (m_hRSI != INVALID_HANDLE) {
        IndicatorRelease(m_hRSI);
        m_hRSI = INVALID_HANDLE;
    }
    
    if (m_hATR != INVALID_HANDLE) {
        IndicatorRelease(m_hATR);
        m_hATR = INVALID_HANDLE;
    }
    
    if (m_hH1_EMA != INVALID_HANDLE) {
        IndicatorRelease(m_hH1_EMA);
        m_hH1_EMA = INVALID_HANDLE;
    }
    
    if (m_hH4_EMA != INVALID_HANDLE) {
        IndicatorRelease(m_hH4_EMA);
        m_hH4_EMA = INVALID_HANDLE;
    }
    
    if (m_hH1_RSI != INVALID_HANDLE) {
        IndicatorRelease(m_hH1_RSI);
        m_hH1_RSI = INVALID_HANDLE;
    }
    
    if (m_hH4_RSI != INVALID_HANDLE) {
        IndicatorRelease(m_hH4_RSI);
        m_hH4_RSI = INVALID_HANDLE;
    }
}

//+------------------------------------------------------------------+
//| Get Indicator Values                                             |
//+------------------------------------------------------------------+
bool CSignalEngine::GetIndicatorValues(double& trend_ema, double& pullback_ema, double& rsi_value, double& atr_value) {
    double trend_buffer[1], pullback_buffer[1], rsi_buffer[1], atr_buffer[1];
    
    // Get Trend EMA
    if (CopyBuffer(m_hTrendEMA, 0, 1, 1, trend_buffer) <= 0) {
        return false;
    }
    trend_ema = trend_buffer[0];
    
    // Get Pullback EMA
    if (CopyBuffer(m_hPullbackEMA, 0, 1, 1, pullback_buffer) <= 0) {
        return false;
    }
    pullback_ema = pullback_buffer[0];
    
    // Get RSI
    if (CopyBuffer(m_hRSI, 0, 1, 1, rsi_buffer) <= 0) {
        return false;
    }
    rsi_value = rsi_buffer[0];
    
    // Get ATR
    if (CopyBuffer(m_hATR, 0, 1, 1, atr_buffer) <= 0) {
        return false;
    }
    atr_value = atr_buffer[0];
    
    return true;
}

//+------------------------------------------------------------------+
//| Check Signal Timing                                              |
//+------------------------------------------------------------------+
bool CSignalEngine::CheckSignalTiming() {
    datetime current_time = TimeCurrent();
    
    // Avoid signals too close together (minimum 1 minute)
    if (current_time - m_dtLastSignalTime < 60) {
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Update Signal Statistics                                         |
//+------------------------------------------------------------------+
void CSignalEngine::UpdateSignalStatistics(const SSignalContext& signal) {
    m_dtLastSignalTime = TimeCurrent();
    m_LastSignalType = signal.signalType;
    m_iSignalCount++;
}

//+------------------------------------------------------------------+
//| Log Signal Details                                               |
//+------------------------------------------------------------------+
void CSignalEngine::LogSignalDetails(const SSignalContext& signal) {
    string signal_str = (signal.signalType == SIGNAL_BUY) ? "BUY" : "SELL";
    string message = StringFormat("%s SIGNAL: TrendEMA=%.5f, PullbackEMA=%.5f, RSI=%.2f", 
                                 signal_str, signal.trendEMA, signal.pullbackEMA, signal.rsiValue);
    
    m_pContext->pLogger->LogInfo(message, __FUNCTION__);
}

//+------------------------------------------------------------------+
//| Get Signal Strength                                              |
//+------------------------------------------------------------------+
ENUM_SIGNAL_STRENGTH CSignalEngine::GetSignalStrength(ENUM_SIGNAL_TYPE signal_type) {
    if (!m_bInitialized || signal_type == SIGNAL_NONE) {
        return SIGNAL_STRENGTH_WEAK;
    }
    
    double trend_ema, pullback_ema, rsi_value, atr_value;
    if (!GetIndicatorValues(trend_ema, pullback_ema, rsi_value, atr_value)) {
        return SIGNAL_STRENGTH_WEAK;
    }
    
    double current_price = (signal_type == SIGNAL_BUY) ? 
                          SymbolInfoDouble(_Symbol, SYMBOL_ASK) : 
                          SymbolInfoDouble(_Symbol, SYMBOL_BID);
    
    // Calculate strength factors
    double ema_distance = MathAbs(pullback_ema - trend_ema) / trend_ema * 100;
    double price_distance = MathAbs(current_price - pullback_ema) / pullback_ema * 100;
    
    // Strong signal criteria
    if (ema_distance > 0.5 && price_distance < 0.2) {
        if ((signal_type == SIGNAL_BUY && rsi_value < 40) ||
            (signal_type == SIGNAL_SELL && rsi_value > 60)) {
            return SIGNAL_STRENGTH_STRONG;
        }
    }
    
    // Medium signal criteria
    if (ema_distance > 0.2 && price_distance < 0.5) {
        return SIGNAL_STRENGTH_MEDIUM;
    }
    
    return SIGNAL_STRENGTH_WEAK;
}

//+------------------------------------------------------------------+
//| Check Higher Timeframe Alignment                                 |
//+------------------------------------------------------------------+
bool CSignalEngine::CheckHigherTimeframeAlignment(ENUM_SIGNAL_TYPE signal_type) {
    // This is a simplified implementation
    // In a full implementation, you would check the trend on higher timeframes
    return true;
}

//+------------------------------------------------------------------+
//| Validate Signal                                                  |
//+------------------------------------------------------------------+
bool CSignalEngine::ValidateSignal(SSignalContext& signal) {
    if (!m_bInitialized || signal.signalType == SIGNAL_NONE) {
        return false;
    }
    
    // Check allowed direction
    if (m_pContext->Inputs.AllowedDirection == DIRECTION_LONG_ONLY && signal.signalType == SIGNAL_SELL) {
        return false;
    }
    if (m_pContext->Inputs.AllowedDirection == DIRECTION_SHORT_ONLY && signal.signalType == SIGNAL_BUY) {
        return false;
    }
    
    // Check higher timeframe alignment if enabled
    if (m_pContext->Inputs.UseMultiTimeframe) {
        if (!CheckHigherTimeframeAlignment(signal.signalType)) {
            return false;
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Analyze Multi-timeframe Alignment                                |
//+------------------------------------------------------------------+
bool CSignalEngine::AnalyzeMultiTimeframe(SSignalContext& signal) {
    // This is a simplified implementation
    // In a full implementation, you would analyze the trend on higher timeframes
    signal.mtfAlignment = true;
    signal.mtfStrength = 0.8; // Placeholder value
    return true;
}

//+------------------------------------------------------------------+
//| Get Trend Direction                                              |
//+------------------------------------------------------------------+
ENUM_TREND_DIRECTION CSignalEngine::GetTrendDirection(ENUM_TIMEFRAMES timeframe) {
    // This is a simplified implementation
    // In a full implementation, you would analyze the trend on the specified timeframe
    return TREND_UNKNOWN;
}

//+------------------------------------------------------------------+
//| Get Trend Strength                                              |
//+------------------------------------------------------------------+
double CSignalEngine::GetTrendStrength(ENUM_TIMEFRAMES timeframe) {
    // This is a simplified implementation
    // In a full implementation, you would analyze the trend on the specified timeframe
    return 0.0;
}

//+------------------------------------------------------------------+
//| Is Multi-timeframe Aligned                                        |
//+------------------------------------------------------------------+
bool CSignalEngine::IsMultiTimeframeAligned(ENUM_SIGNAL_TYPE signal_type) {
    // This is a simplified implementation
    // In a full implementation, you would check the alignment on higher timeframes
    return true;
}

//+------------------------------------------------------------------+
//| Calculate Multi-timeframe Score                                    |
//+------------------------------------------------------------------+
double CSignalEngine::CalculateMultiTimeframeScore(ENUM_SIGNAL_TYPE signal_type) {
    // This is a simplified implementation
    // In a full implementation, you would calculate the score based on multi-timeframe alignment
    return 0.0;
}

//+------------------------------------------------------------------+
//| Detect Market Regime                                             |
//+------------------------------------------------------------------+
ENUM_MARKET_REGIME CSignalEngine::DetectMarketRegime() {
    // This is a simplified implementation
    // In a full implementation, you would analyze market conditions to detect the regime
    return REGIME_UNKNOWN;
}

//+------------------------------------------------------------------+
//| Calculate Volatility Index                                       |
//+------------------------------------------------------------------+
double CSignalEngine::CalculateVolatilityIndex() {
    // This is a simplified implementation
    // In a full implementation, you would calculate the volatility index based on historical data
    return 0.0;
}

//+------------------------------------------------------------------+
//| Is Market Condition Suitable                                    |
//+------------------------------------------------------------------+
bool CSignalEngine::IsMarketConditionSuitable(ENUM_TRADING_STRATEGY strategy) {
    // This is a simplified implementation
    // In a full implementation, you would check if the current market conditions are suitable for the strategy
    return true;
}

//+------------------------------------------------------------------+
//| Calculate Market Noise                                           |
//+------------------------------------------------------------------+
double CSignalEngine::CalculateMarketNoise() {
    // This is a simplified implementation
    // In a full implementation, you would calculate the market noise based on historical data
    return 0.0;
}

//+------------------------------------------------------------------+
//| Is Liquidity Adequate                                            |
//+------------------------------------------------------------------+
bool CSignalEngine::IsLiquidityAdequate() {
    // This is a simplified implementation
    // In a full implementation, you would check if the liquidity is adequate for trading
    return true;
}

//+------------------------------------------------------------------+
//| Select Optimal Strategy                                          |
//+------------------------------------------------------------------+
ENUM_TRADING_STRATEGY CSignalEngine::SelectOptimalStrategy() {
    // This is a simplified implementation
    // In a full implementation, you would select the optimal strategy based on market conditions and AssetDNA
    return STRATEGY_PULLBACK_TREND;
}

//+------------------------------------------------------------------+
//| Get Strategy Score                                              |
//+------------------------------------------------------------------+
double CSignalEngine::GetStrategyScore(ENUM_TRADING_STRATEGY strategy) {
    // This is a simplified implementation
    // In a full implementation, you would calculate the score for the specified strategy
    return 0.0;
}

//+------------------------------------------------------------------+
//| Is Strategy Valid                                               |
//+------------------------------------------------------------------+
bool CSignalEngine::IsStrategyValid(ENUM_TRADING_STRATEGY strategy) {
    // This is a simplified implementation
    // In a full implementation, you would check if the specified strategy is valid
    return true;
}

//+------------------------------------------------------------------+
//| Check Pullback Signal                                           |
//+------------------------------------------------------------------+
bool CSignalEngine::CheckPullbackSignal(SSignalContext& signal) {
    double trend_ema, pullback_ema, rsi_value, atr_value;
    if (!GetIndicatorValues(trend_ema, pullback_ema, rsi_value, atr_value)) {
        return false;
    }
    
    double current_bid = m_pContext->pSymbolManager->GetBid();
    double current_ask = m_pContext->pSymbolManager->GetAsk();
    
    if (current_bid == 0 || current_ask == 0) {
        return false;
    }
    
    // Enhanced pullback logic with better trend detection
    bool is_uptrend = (pullback_ema > trend_ema);
    bool is_downtrend = (pullback_ema < trend_ema);
    
    const double RSI_OVERBOUGHT = 70.0;
    const double RSI_OVERSOLD = 30.0;
    
    // Buy Signal: Pullback in uptrend
    if (is_uptrend && 
        current_bid <= pullback_ema && 
        current_bid > trend_ema &&  // Above long-term trend
        rsi_value > RSI_OVERSOLD && 
        rsi_value < 60.0) {  // Not overbought
        
        signal.signalType = SIGNAL_BUY;
        signal.entryPrice = current_ask;
        signal.stopLoss = trend_ema - (atr_value * 0.5);
        signal.takeProfit = current_ask + (current_ask - signal.stopLoss) * 2.0; // 1:2 RR
        signal.signalReason = "Pullback to EMA in uptrend";
        
        return true;
    }
    // Sell Signal: Pullback in downtrend
    else if (is_downtrend && 
             current_ask >= pullback_ema && 
             current_ask < trend_ema &&  // Below long-term trend
             rsi_value < RSI_OVERBOUGHT && 
             rsi_value > 40.0) {  // Not oversold
        
        signal.signalType = SIGNAL_SELL;
        signal.entryPrice = current_bid;
        signal.stopLoss = trend_ema + (atr_value * 0.5);
        signal.takeProfit = current_bid - (signal.stopLoss - current_bid) * 2.0; // 1:2 RR
        signal.signalReason = "Pullback to EMA in downtrend";
        
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Check Momentum Signal                                            |
//+------------------------------------------------------------------+
bool CSignalEngine::CheckMomentumSignal(SSignalContext& signal) {
    double trend_ema, pullback_ema, rsi_value, atr_value;
    if (!GetIndicatorValues(trend_ema, pullback_ema, rsi_value, atr_value)) {
        return false;
    }
    
    double current_bid = m_pContext->pSymbolManager->GetBid();
    double current_ask = m_pContext->pSymbolManager->GetAsk();
    
    // Momentum signals require strong RSI momentum
    if (rsi_value > 70.0 && pullback_ema > trend_ema) {
        // Strong bullish momentum
        signal.signalType = SIGNAL_BUY;
        signal.entryPrice = current_ask;
        signal.stopLoss = pullback_ema;
        signal.takeProfit = current_ask + (atr_value * 3.0);
        signal.signalReason = "Strong bullish momentum breakout";
        return true;
    }
    else if (rsi_value < 30.0 && pullback_ema < trend_ema) {
        // Strong bearish momentum
        signal.signalType = SIGNAL_SELL;
        signal.entryPrice = current_bid;
        signal.stopLoss = pullback_ema;
        signal.takeProfit = current_bid - (atr_value * 3.0);
        signal.signalReason = "Strong bearish momentum breakout";
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Check Reversal Signal                                            |
//+------------------------------------------------------------------+
bool CSignalEngine::CheckReversalSignal(SSignalContext& signal) {
    double trend_ema, pullback_ema, rsi_value, atr_value;
    if (!GetIndicatorValues(trend_ema, pullback_ema, rsi_value, atr_value)) {
        return false;
    }
    
    double current_bid = m_pContext->pSymbolManager->GetBid();
    double current_ask = m_pContext->pSymbolManager->GetAsk();
    
    // Look for reversal signals at extreme RSI levels
    if (rsi_value > 80.0 && current_ask > pullback_ema) {
        // Potential bearish reversal
        signal.signalType = SIGNAL_SELL;
        signal.entryPrice = current_bid;
        signal.stopLoss = current_ask + (atr_value * 1.0);
        signal.takeProfit = pullback_ema;
        signal.signalReason = "Overbought reversal signal";
        return true;
    }
    else if (rsi_value < 20.0 && current_bid < pullback_ema) {
        // Potential bullish reversal
        signal.signalType = SIGNAL_BUY;
        signal.entryPrice = current_ask;
        signal.stopLoss = current_bid - (atr_value * 1.0);
        signal.takeProfit = pullback_ema;
        signal.signalReason = "Oversold reversal signal";
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Check Breakout Signal                                            |
//+------------------------------------------------------------------+
bool CSignalEngine::CheckBreakoutSignal(SSignalContext& signal) {
    double trend_ema, pullback_ema, rsi_value, atr_value;
    if (!GetIndicatorValues(trend_ema, pullback_ema, rsi_value, atr_value)) {
        return false;
    }
    
    double current_bid = m_pContext->pSymbolManager->GetBid();
    double current_ask = m_pContext->pSymbolManager->GetAsk();
    
    // Check for breakout above resistance or below support
    double resistance = MathMax(trend_ema, pullback_ema);
    double support = MathMin(trend_ema, pullback_ema);
    
    if (current_ask > resistance + (atr_value * 0.2) && rsi_value > 50.0) {
        // Bullish breakout
        signal.signalType = SIGNAL_BUY;
        signal.entryPrice = current_ask;
        signal.stopLoss = resistance;
        signal.takeProfit = current_ask + (atr_value * 2.0);
        signal.signalReason = "Bullish breakout above resistance";
        return true;
    }
    else if (current_bid < support - (atr_value * 0.2) && rsi_value < 50.0) {
        // Bearish breakout
        signal.signalType = SIGNAL_SELL;
        signal.entryPrice = current_bid;
        signal.stopLoss = support;
        signal.takeProfit = current_bid - (atr_value * 2.0);
        signal.signalReason = "Bearish breakout below support";
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Calculate Signal Quality                                         |
//+------------------------------------------------------------------+
SSignalQuality CSignalEngine::CalculateSignalQuality(const SSignalContext& signal) {
    SSignalQuality quality;
    quality.Clear();
    
    if (signal.signalType == SIGNAL_NONE) {
        return quality;
    }
    
    // Calculate individual quality components
    quality.technicalScore = CalculateTechnicalScore(signal);
    quality.timingScore = CalculateTimingScore(signal);
    quality.marketConditionScore = CalculateMarketConditionScore(signal);
    quality.riskScore = (signal.riskRewardRatio >= 2.0) ? 1.0 : signal.riskRewardRatio / 2.0;
    quality.consistencyScore = 0.8; // Placeholder - would need historical consistency data
    
    // Calculate overall score (weighted average)
    double weights[] = {0.3, 0.2, 0.25, 0.15, 0.1};
    double scores[] = {
        quality.technicalScore,
        quality.timingScore,
        quality.marketConditionScore,
        quality.riskScore,
        quality.consistencyScore
    };
    
    quality.overallScore = 0.0;
    for (int i = 0; i < 5; i++) {
        quality.overallScore += scores[i] * weights[i];
    }
    
    return quality;
}

//+------------------------------------------------------------------+
//| Calculate Confidence Score                                       |
//+------------------------------------------------------------------+
double CSignalEngine::CalculateConfidenceScore(const SSignalContext& signal) {
    if (signal.signalType == SIGNAL_NONE) {
        return 0.0;
    }
    
    double confidence = 0.0;
    
    // Base confidence from signal quality
    confidence += m_SignalQuality.overallScore * 0.5;
    
    // Multi-timeframe alignment bonus
    if (signal.mtfAlignment) {
        confidence += signal.mtfStrength * 0.2;
    }
    
    // Risk/reward ratio contribution
    if (signal.riskRewardRatio >= 2.0) {
        confidence += 0.15;
    } else if (signal.riskRewardRatio >= 1.5) {
        confidence += 0.1;
    }
    
    // Market regime bonus
    if (signal.marketRegime != REGIME_UNKNOWN) {
        confidence += 0.1;
    }
    
    // AssetDNA integration bonus
    if (m_UseAssetDNA && m_pContext->pAssetDNA != NULL) {
        if (m_pContext->pAssetDNA->IsStrategyRecommended(signal.strategy)) {
            confidence += 0.05;
        }
    }
    
    return MathMin(confidence, 1.0);
}

//+------------------------------------------------------------------+
//| Calculate Technical Score                                        |
//+------------------------------------------------------------------+
double CSignalEngine::CalculateTechnicalScore(const SSignalContext& signal) {
    double score = 0.0;
    
    double trend_ema, pullback_ema, rsi_value, atr_value;
    if (!GetIndicatorValues(trend_ema, pullback_ema, rsi_value, atr_value)) {
        return 0.0;
    }
    
    // EMA alignment score
    double ema_separation = MathAbs(pullback_ema - trend_ema) / trend_ema;
    if (ema_separation > 0.005) score += 0.3; // 0.5% separation minimum
    
    // RSI score based on signal type
    if (signal.signalType == SIGNAL_BUY) {
        if (rsi_value >= 30 && rsi_value <= 60) score += 0.4;
        else if (rsi_value > 60 && rsi_value <= 70) score += 0.2;
    } else if (signal.signalType == SIGNAL_SELL) {
        if (rsi_value >= 40 && rsi_value <= 70) score += 0.4;
        else if (rsi_value >= 30 && rsi_value < 40) score += 0.2;
    }
    
    // Volatility score (moderate volatility is preferred)
    double atr_percent = (atr_value / SymbolInfoDouble(_Symbol, SYMBOL_BID)) * 100;
    if (atr_percent >= 0.1 && atr_percent <= 0.5) score += 0.3;
    else if (atr_percent > 0.5 && atr_percent <= 1.0) score += 0.15;
    
    return MathMin(score, 1.0);
}

//+------------------------------------------------------------------+
//| Calculate Timing Score                                           |
//+------------------------------------------------------------------+
double CSignalEngine::CalculateTimingScore(const SSignalContext& signal) {
    double score = 0.0;
    
    // Check if signal is during optimal trading hours
    datetime current_time = TimeCurrent();
    MqlDateTime dt;
    TimeToStruct(current_time, dt);
    
    // Prefer signals during major trading sessions
    if ((dt.hour >= 8 && dt.hour <= 12) ||   // London session
        (dt.hour >= 13 && dt.hour <= 17)) {   // New York session
        score += 0.5;
    } else if (dt.hour >= 1 && dt.hour <= 7) {  // Asian session
        score += 0.3;
    } else {
        score += 0.1; // Off-hours
    }
    
    // Prefer signals at beginning of new bars
    if (m_pContext->pTimeManager != NULL) {
        if (m_pContext->pTimeManager->IsNewBar()) {
            score += 0.3;
        }
    }
    
    // Avoid signals too close to previous signals
    if (current_time - m_dtLastSignalTime > 300) { // 5 minutes minimum
        score += 0.2;
    }
    
    return MathMin(score, 1.0);
}

//+------------------------------------------------------------------+
//| Calculate Market Condition Score                                 |
//+------------------------------------------------------------------+
double CSignalEngine::CalculateMarketConditionScore(const SSignalContext& signal) {
    double score = 0.0;
    
    // Check spread conditions
    double spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    double typical_spread = SymbolInfoDouble(_Symbol, SYMBOL_BID) * 0.0001; // Rough estimate
    
    if (spread <= typical_spread * 1.5) {
        score += 0.4; // Good spread
    } else if (spread <= typical_spread * 2.0) {
        score += 0.2; // Acceptable spread
    }
    
    // Check liquidity (simplified)
    double tick_volume = (double)SymbolInfoInteger(_Symbol, SYMBOL_VOLUME);
    if (tick_volume > 100) {
        score += 0.3; // Good liquidity
    } else if (tick_volume > 50) {
        score += 0.15; // Moderate liquidity
    }
    
    // Market hours bonus
    datetime current_time = TimeCurrent();
    MqlDateTime dt;
    TimeToStruct(current_time, dt);
    
    if (dt.day_of_week >= 1 && dt.day_of_week <= 5) { // Weekdays
        if (dt.hour >= 8 && dt.hour <= 17) {
            score += 0.3; // Prime trading hours
        } else {
            score += 0.1; // Off-hours
        }
    }
    
    return MathMin(score, 1.0);
}

//+------------------------------------------------------------------+
//| Process Signal                                                   |
//+------------------------------------------------------------------+
void CSignalEngine::ProcessSignal(SSignalContext& signal) {
    if (signal.signalType == SIGNAL_NONE) {
        return;
    }
    
    // Calculate signal parameters
    CalculateSignalParameters(signal);
    
    // Apply risk management
    ApplyRiskManagement(signal);
    
    // Optimize entry timing
    OptimizeEntryTiming(signal);
    
    // Set market context
    signal.marketRegime = DetectMarketRegime();
    signal.volatility = CalculateVolatilityIndex();
    signal.spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    
    // Calculate risk/reward ratio
    if (signal.stopLoss != 0) {
        double risk = MathAbs(signal.entryPrice - signal.stopLoss);
        double reward = MathAbs(signal.takeProfit - signal.entryPrice);
        signal.riskRewardRatio = (risk > 0) ? reward / risk : 0.0;
    }
    
    // Calculate expected pips
    double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
    double pip_size = (digits == 5 || digits == 3) ? point * 10 : point;
    
    signal.expectedPips = MathAbs(signal.takeProfit - signal.entryPrice) / pip_size;
    signal.maxRiskPips = MathAbs(signal.entryPrice - signal.stopLoss) / pip_size;
    
    // Set urgency level based on signal strength and market conditions
    if (signal.confidenceScore > 0.8) {
        signal.urgencyLevel = 5;
    } else if (signal.confidenceScore > 0.6) {
        signal.urgencyLevel = 4;
    } else if (signal.confidenceScore > 0.4) {
        signal.urgencyLevel = 3;
    } else {
        signal.urgencyLevel = 2;
    }
}

//+------------------------------------------------------------------+
//| Calculate Signal Parameters                                      |
//+------------------------------------------------------------------+
void CSignalEngine::CalculateSignalParameters(SSignalContext& signal) {
    // Basic parameter calculation - already done in signal detection
    // This method can be enhanced with more sophisticated calculations
}

//+------------------------------------------------------------------+
//| Apply Risk Management                                            |
//+------------------------------------------------------------------+
void CSignalEngine::ApplyRiskManagement(SSignalContext& signal) {
    // Ensure minimum risk/reward ratio
    if (signal.riskRewardRatio < 1.5) {
        double risk = MathAbs(signal.entryPrice - signal.stopLoss);
        if (signal.signalType == SIGNAL_BUY) {
            signal.takeProfit = signal.entryPrice + (risk * 2.0);
        } else {
            signal.takeProfit = signal.entryPrice - (risk * 2.0);
        }
    }
    
    // Apply maximum risk limits
    double max_risk_pips = 50.0; // Maximum 50 pips risk
    double pip_size = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    if ((int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) == 5 || (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) == 3) {
        pip_size *= 10;
    }
    
    double current_risk_pips = MathAbs(signal.entryPrice - signal.stopLoss) / pip_size;
    if (current_risk_pips > max_risk_pips) {
        if (signal.signalType == SIGNAL_BUY) {
            signal.stopLoss = signal.entryPrice - (max_risk_pips * pip_size);
        } else {
            signal.stopLoss = signal.entryPrice + (max_risk_pips * pip_size);
        }
    }
}

//+------------------------------------------------------------------+
//| Optimize Entry Timing                                            |
//+------------------------------------------------------------------+
void CSignalEngine::OptimizeEntryTiming(SSignalContext& signal) {
    // This could include more sophisticated timing optimization
    // For now, we'll just set a reasonable expiry time
    signal.expiryTime = signal.signalTime + 300; // 5 minutes
}

//+------------------------------------------------------------------+
//| Enhanced Validation Methods                                      |
//+------------------------------------------------------------------+
bool CSignalEngine::ValidateMarketConditions(const SSignalContext& signal) {
    // Check spread
    double spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    double max_spread = SymbolInfoDouble(_Symbol, SYMBOL_BID) * 0.0005; // 0.05%
    
    if (spread > max_spread) {
        return false;
    }
    
    // Check trading hours
    datetime current_time = TimeCurrent();
    MqlDateTime dt;
    TimeToStruct(current_time, dt);
    
    if (dt.day_of_week == 0 || dt.day_of_week == 6) {
        return false; // No weekend trading
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Validate Risk Parameters                                         |
//+------------------------------------------------------------------+
bool CSignalEngine::ValidateRiskParameters(const SSignalContext& signal) {
    // Check minimum risk/reward ratio
    if (signal.riskRewardRatio < 1.0) {
        return false;
    }
    
    // Check maximum risk
    if (signal.maxRiskPips > 100.0) {
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Validate News Events                                             |
//+------------------------------------------------------------------+
bool CSignalEngine::ValidateNews(const SSignalContext& signal) {
    // Simplified news validation
    // In a full implementation, this would check for upcoming news events
    return true;
}

//+------------------------------------------------------------------+
//| Validate Correlation                                             |
//+------------------------------------------------------------------+
bool CSignalEngine::ValidateCorrelation(const SSignalContext& signal) {
    // Simplified correlation validation
    // In a full implementation, this would check correlation with other open positions
    return true;
}

//+------------------------------------------------------------------+
//| Utility Methods                                                  |
//+------------------------------------------------------------------+
double CSignalEngine::NormalizeScore(double value, double min_val, double max_val) {
    if (max_val <= min_val) return 0.0;
    return MathMax(0.0, MathMin(1.0, (value - min_val) / (max_val - min_val)));
}

//+------------------------------------------------------------------+
//| Signal Type to String                                            |
//+------------------------------------------------------------------+
string CSignalEngine::SignalTypeToString(ENUM_SIGNAL_TYPE signal_type) {
    switch (signal_type) {
        case SIGNAL_BUY: return "BUY";
        case SIGNAL_SELL: return "SELL";
        default: return "NONE";
    }
}

//+------------------------------------------------------------------+
//| Strategy to String                                               |
//+------------------------------------------------------------------+
string CSignalEngine::StrategyToString(ENUM_TRADING_STRATEGY strategy) {
    switch (strategy) {
        case STRATEGY_PULLBACK_TREND: return "PULLBACK_TREND";
        case STRATEGY_SHALLOW_PULLBACK: return "SHALLOW_PULLBACK";
        case STRATEGY_MOMENTUM_BREAKOUT: return "MOMENTUM_BREAKOUT";
        case STRATEGY_MEAN_REVERSION: return "MEAN_REVERSION";
        case STRATEGY_BREAKOUT: return "BREAKOUT";
        default: return "UNDEFINED";
    }
}

//+------------------------------------------------------------------+
//| Log Signal Quality                                               |
//+------------------------------------------------------------------+
void CSignalEngine::LogSignalQuality(const SSignalQuality& quality) {
    if (m_pContext->pLogger != NULL) {
        string message = StringFormat("Signal Quality - Overall: %.2f, Technical: %.2f, Timing: %.2f, Market: %.2f, Risk: %.2f",
            quality.overallScore, quality.technicalScore, quality.timingScore, 
            quality.marketConditionScore, quality.riskScore);
        m_pContext->pLogger->LogInfo(message, __FUNCTION__);
    }
}

//+------------------------------------------------------------------+
//| Missing Method Implementations                                   |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Is Uptrend                                                       |
//+------------------------------------------------------------------+
bool CSignalEngine::IsUptrend() {
    double trend_ema, pullback_ema, rsi_value, atr_value;
    if (!GetIndicatorValues(trend_ema, pullback_ema, rsi_value, atr_value)) {
        return false;
    }
    
    m_trendEMA = trend_ema;
    m_pullbackEMA = pullback_ema;
    m_rsiValue = rsi_value;
    
    return (pullback_ema > trend_ema);
}

//+------------------------------------------------------------------+
//| Is Downtrend                                                     |
//+------------------------------------------------------------------+
bool CSignalEngine::IsDowntrend() {
    double trend_ema, pullback_ema, rsi_value, atr_value;
    if (!GetIndicatorValues(trend_ema, pullback_ema, rsi_value, atr_value)) {
        return false;
    }
    
    m_trendEMA = trend_ema;
    m_pullbackEMA = pullback_ema;
    m_rsiValue = rsi_value;
    
    return (pullback_ema < trend_ema);
}

//+------------------------------------------------------------------+
//| Is Pullback Condition                                            |
//+------------------------------------------------------------------+
bool CSignalEngine::IsPullbackCondition() {
    if (!m_bInitialized) {
        return false;
    }
    
    double current_bid = m_pContext->pSymbolManager->GetBid();
    double current_ask = m_pContext->pSymbolManager->GetAsk();
    
    // Check if price is near EMAs (pullback condition)
    double ema_zone = MathAbs(m_pullbackEMA - m_trendEMA) * 0.5;
    
    return (MathAbs(current_bid - m_pullbackEMA) <= ema_zone || 
            MathAbs(current_ask - m_pullbackEMA) <= ema_zone);
}

//+------------------------------------------------------------------+
//| Is RSI Valid                                                     |
//+------------------------------------------------------------------+
bool CSignalEngine::IsRSIValid(ENUM_SIGNAL_TYPE signal_type) {
    if (signal_type == SIGNAL_BUY) {
        return (m_rsiValue > 30.0 && m_rsiValue < 70.0);
    } else if (signal_type == SIGNAL_SELL) {
        return (m_rsiValue > 30.0 && m_rsiValue < 70.0);
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Get Enhanced Indicator Values                                    |
//+------------------------------------------------------------------+
bool CSignalEngine::GetEnhancedIndicatorValues(double values[]) {
    ArrayResize(values, 10);
    ArrayInitialize(values, 0.0);
    
    double trend_ema, pullback_ema, rsi_value, atr_value;
    if (!GetIndicatorValues(trend_ema, pullback_ema, rsi_value, atr_value)) {
        return false;
    }
    
    values[0] = trend_ema;
    values[1] = pullback_ema;
    values[2] = rsi_value;
    values[3] = atr_value;
    values[4] = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    values[5] = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    values[6] = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    values[7] = (double)SymbolInfoInteger(_Symbol, SYMBOL_VOLUME);
    values[8] = 0.0; // Placeholder for additional indicator
    values[9] = 0.0; // Placeholder for additional indicator
    
    return true;
}

//+------------------------------------------------------------------+
//| Get Multi-Timeframe Values                                       |
//+------------------------------------------------------------------+
bool CSignalEngine::GetMultiTimeframeValues(double h1_values[], double h4_values[]) {
    ArrayResize(h1_values, 5);
    ArrayResize(h4_values, 5);
    ArrayInitialize(h1_values, 0.0);
    ArrayInitialize(h4_values, 0.0);
    
    // Get H1 values
    double h1_ema_buffer[1], h1_rsi_buffer[1];
    if (CopyBuffer(m_hH1_EMA, 0, 1, 1, h1_ema_buffer) > 0) {
        h1_values[0] = h1_ema_buffer[0];
    }
    if (CopyBuffer(m_hH1_RSI, 0, 1, 1, h1_rsi_buffer) > 0) {
        h1_values[1] = h1_rsi_buffer[0];
    }
    
    // Get H4 values
    double h4_ema_buffer[1], h4_rsi_buffer[1];
    if (CopyBuffer(m_hH4_EMA, 0, 1, 1, h4_ema_buffer) > 0) {
        h4_values[0] = h4_ema_buffer[0];
    }
    if (CopyBuffer(m_hH4_RSI, 0, 1, 1, h4_rsi_buffer) > 0) {
        h4_values[1] = h4_rsi_buffer[0];
    }
    
    return true;
}

} // namespace v5
} // namespace ApexPullback

//+------------------------------------------------------------------+
//| Enhanced Methods Implementation (v14 Features)                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Check Pullback Signal                                           |
//+------------------------------------------------------------------+
bool CSignalEngine::CheckPullbackSignal(SSignalContext& signal) {
    double trend_ema, pullback_ema, rsi_value, atr_value;
    if (!GetIndicatorValues(trend_ema, pullback_ema, rsi_value, atr_value)) {
        return false;
    }
    
    double current_bid = m_pContext->pSymbolManager->GetBid();
    double current_ask = m_pContext->pSymbolManager->GetAsk();
    
    if (current_bid == 0 || current_ask == 0) {
        return false;
    }
    
    // Enhanced pullback logic with better trend detection
    bool is_uptrend = (pullback_ema > trend_ema);
    bool is_downtrend = (pullback_ema < trend_ema);
    
    const double RSI_OVERBOUGHT = 70.0;
    const double RSI_OVERSOLD = 30.0;
    
    // Buy Signal: Pullback in uptrend
    if (is_uptrend && 
        current_bid <= pullback_ema && 
        current_bid > trend_ema &&  // Above long-term trend
        rsi_value > RSI_OVERSOLD && 
        rsi_value < 60.0) {  // Not overbought
        
        signal.signalType = SIGNAL_BUY;
        signal.entryPrice = current_ask;
        signal.stopLoss = trend_ema - (atr_value * 0.5);
        signal.takeProfit = current_ask + (current_ask - signal.stopLoss) * 2.0; // 1:2 RR
        signal.signalReason = "Pullback to EMA in uptrend";
        
        return true;
    }
    // Sell Signal: Pullback in downtrend
    else if (is_downtrend && 
             current_ask >= pullback_ema && 
             current_ask < trend_ema &&  // Below long-term trend
             rsi_value < RSI_OVERBOUGHT && 
             rsi_value > 40.0) {  // Not oversold
        
        signal.signalType = SIGNAL_SELL;
        signal.entryPrice = current_bid;
        signal.stopLoss = trend_ema + (atr_value * 0.5);
        signal.takeProfit = current_bid - (signal.stopLoss - current_bid) * 2.0; // 1:2 RR
        signal.signalReason = "Pullback to EMA in downtrend";
        
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Check Momentum Signal                                            |
//+------------------------------------------------------------------+
bool CSignalEngine::CheckMomentumSignal(SSignalContext& signal) {
    double trend_ema, pullback_ema, rsi_value, atr_value;
    if (!GetIndicatorValues(trend_ema, pullback_ema, rsi_value, atr_value)) {
        return false;
    }
    
    double current_bid = m_pContext->pSymbolManager->GetBid();
    double current_ask = m_pContext->pSymbolManager->GetAsk();
    
    // Momentum signals require strong RSI momentum
    if (rsi_value > 70.0 && pullback_ema > trend_ema) {
        // Strong bullish momentum
        signal.signalType = SIGNAL_BUY;
        signal.entryPrice = current_ask;
        signal.stopLoss = pullback_ema;
        signal.takeProfit = current_ask + (atr_value * 3.0);
        signal.signalReason = "Strong bullish momentum breakout";
        return true;
    }
    else if (rsi_value < 30.0 && pullback_ema < trend_ema) {
        // Strong bearish momentum
        signal.signalType = SIGNAL_SELL;
        signal.entryPrice = current_bid;
        signal.stopLoss = pullback_ema;
        signal.takeProfit = current_bid - (atr_value * 3.0);
        signal.signalReason = "Strong bearish momentum breakout";
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Check Reversal Signal                                            |
//+------------------------------------------------------------------+
bool CSignalEngine::CheckReversalSignal(SSignalContext& signal) {
    double trend_ema, pullback_ema, rsi_value, atr_value;
    if (!GetIndicatorValues(trend_ema, pullback_ema, rsi_value, atr_value)) {
        return false;
    }
    
    double current_bid = m_pContext->pSymbolManager->GetBid();
    double current_ask = m_pContext->pSymbolManager->GetAsk();
    
    // Look for reversal signals at extreme RSI levels
    if (rsi_value > 80.0 && current_ask > pullback_ema) {
        // Potential bearish reversal
        signal.signalType = SIGNAL_SELL;
        signal.entryPrice = current_bid;
        signal.stopLoss = current_ask + (atr_value * 1.0);
        signal.takeProfit = pullback_ema;
        signal.signalReason = "Overbought reversal signal";
        return true;
    }
    else if (rsi_value < 20.0 && current_bid < pullback_ema) {
        // Potential bullish reversal
        signal.signalType = SIGNAL_BUY;
        signal.entryPrice = current_ask;
        signal.stopLoss = current_bid - (atr_value * 1.0);
        signal.takeProfit = pullback_ema;
        signal.signalReason = "Oversold reversal signal";
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Check Breakout Signal                                            |
//+------------------------------------------------------------------+
bool CSignalEngine::CheckBreakoutSignal(SSignalContext& signal) {
    double trend_ema, pullback_ema, rsi_value, atr_value;
    if (!GetIndicatorValues(trend_ema, pullback_ema, rsi_value, atr_value)) {
        return false;
    }
    
    double current_bid = m_pContext->pSymbolManager->GetBid();
    double current_ask = m_pContext->pSymbolManager->GetAsk();
    
    // Check for breakout above resistance or below support
    double resistance = MathMax(trend_ema, pullback_ema);
    double support = MathMin(trend_ema, pullback_ema);
    
    if (current_ask > resistance + (atr_value * 0.2) && rsi_value > 50.0) {
        // Bullish breakout
        signal.signalType = SIGNAL_BUY;
        signal.entryPrice = current_ask;
        signal.stopLoss = resistance;
        signal.takeProfit = current_ask + (atr_value * 2.0);
        signal.signalReason = "Bullish breakout above resistance";
        return true;
    }
    else if (current_bid < support - (atr_value * 0.2) && rsi_value < 50.0) {
        // Bearish breakout
        signal.signalType = SIGNAL_SELL;
        signal.entryPrice = current_bid;
        signal.stopLoss = support;
        signal.takeProfit = current_bid - (atr_value * 2.0);
        signal.signalReason = "Bearish breakout below support";
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Calculate Signal Quality                                         |
//+------------------------------------------------------------------+
SSignalQuality CSignalEngine::CalculateSignalQuality(const SSignalContext& signal) {
    SSignalQuality quality;
    quality.Clear();
    
    if (signal.signalType == SIGNAL_NONE) {
        return quality;
    }
    
    // Calculate individual quality components
    quality.technicalScore = CalculateTechnicalScore(signal);
    quality.timingScore = CalculateTimingScore(signal);
    quality.marketConditionScore = CalculateMarketConditionScore(signal);
    quality.riskScore = (signal.riskRewardRatio >= 2.0) ? 1.0 : signal.riskRewardRatio / 2.0;
    quality.consistencyScore = 0.8; // Placeholder - would need historical consistency data
    
    // Calculate overall score (weighted average)
    double weights[] = {0.3, 0.2, 0.25, 0.15, 0.1};
    double scores[] = {
        quality.technicalScore,
        quality.timingScore,
        quality.marketConditionScore,
        quality.riskScore,
        quality.consistencyScore
    };
    
    quality.overallScore = 0.0;
    for (int i = 0; i < 5; i++) {
        quality.overallScore += scores[i] * weights[i];
    }
    
    return quality;
}

//+------------------------------------------------------------------+
//| Calculate Confidence Score                                       |
//+------------------------------------------------------------------+
double CSignalEngine::CalculateConfidenceScore(const SSignalContext& signal) {
    if (signal.signalType == SIGNAL_NONE) {
        return 0.0;
    }
    
    double confidence = 0.0;
    
    // Base confidence from signal quality
    confidence += m_SignalQuality.overallScore * 0.5;
    
    // Multi-timeframe alignment bonus
    if (signal.mtfAlignment) {
        confidence += signal.mtfStrength * 0.2;
    }
    
    // Risk/reward ratio contribution
    if (signal.riskRewardRatio >= 2.0) {
        confidence += 0.15;
    } else if (signal.riskRewardRatio >= 1.5) {
        confidence += 0.1;
    }
    
    // Market regime bonus
    if (signal.marketRegime != REGIME_UNKNOWN) {
        confidence += 0.1;
    }
    
    // AssetDNA integration bonus
    if (m_UseAssetDNA && m_pContext->pAssetDNA != NULL) {
        if (m_pContext->pAssetDNA->IsStrategyRecommended(signal.strategy)) {
            confidence += 0.05;
        }
    }
    
    return MathMin(confidence, 1.0);
}

//+------------------------------------------------------------------+
//| Calculate Technical Score                                        |
//+------------------------------------------------------------------+
double CSignalEngine::CalculateTechnicalScore(const SSignalContext& signal) {
    double score = 0.0;
    
    double trend_ema, pullback_ema, rsi_value, atr_value;
    if (!GetIndicatorValues(trend_ema, pullback_ema, rsi_value, atr_value)) {
        return 0.0;
    }
    
    // EMA alignment score
    double ema_separation = MathAbs(pullback_ema - trend_ema) / trend_ema;
    if (ema_separation > 0.005) score += 0.3; // 0.5% separation minimum
    
    // RSI score based on signal type
    if (signal.signalType == SIGNAL_BUY) {
        if (rsi_value >= 30 && rsi_value <= 60) score += 0.4;
        else if (rsi_value > 60 && rsi_value <= 70) score += 0.2;
    } else if (signal.signalType == SIGNAL_SELL) {
        if (rsi_value >= 40 && rsi_value <= 70) score += 0.4;
        else if (rsi_value >= 30 && rsi_value < 40) score += 0.2;
    }
    
    // Volatility score (moderate volatility is preferred)
    double atr_percent = (atr_value / SymbolInfoDouble(_Symbol, SYMBOL_BID)) * 100;
    if (atr_percent >= 0.1 && atr_percent <= 0.5) score += 0.3;
    else if (atr_percent > 0.5 && atr_percent <= 1.0) score += 0.15;
    
    return MathMin(score, 1.0);
}

//+------------------------------------------------------------------+
//| Calculate Timing Score                                           |
//+------------------------------------------------------------------+
double CSignalEngine::CalculateTimingScore(const SSignalContext& signal) {
    double score = 0.0;
    
    // Check if signal is during optimal trading hours
    datetime current_time = TimeCurrent();
    MqlDateTime dt;
    TimeToStruct(current_time, dt);
    
    // Prefer signals during major trading sessions
    if ((dt.hour >= 8 && dt.hour <= 12) ||   // London session
        (dt.hour >= 13 && dt.hour <= 17)) {   // New York session
        score += 0.5;
    } else if (dt.hour >= 1 && dt.hour <= 7) {  // Asian session
        score += 0.3;
    } else {
        score += 0.1; // Off-hours
    }
    
    // Prefer signals at beginning of new bars
    if (m_pContext->pTimeManager != NULL) {
        if (m_pContext->pTimeManager->IsNewBar()) {
            score += 0.3;
        }
    }
    
    // Avoid signals too close to previous signals
    if (current_time - m_dtLastSignalTime > 300) { // 5 minutes minimum
        score += 0.2;
    }
    
    return MathMin(score, 1.0);
}

//+------------------------------------------------------------------+
//| Calculate Market Condition Score                                 |
//+------------------------------------------------------------------+
double CSignalEngine::CalculateMarketConditionScore(const SSignalContext& signal) {
    double score = 0.0;
    
    // Check spread conditions
    double spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    double typical_spread = SymbolInfoDouble(_Symbol, SYMBOL_BID) * 0.0001; // Rough estimate
    
    if (spread <= typical_spread * 1.5) {
        score += 0.4; // Good spread
    } else if (spread <= typical_spread * 2.0) {
        score += 0.2; // Acceptable spread
    }
    
    // Check liquidity (simplified)
    double tick_volume = (double)SymbolInfoInteger(_Symbol, SYMBOL_VOLUME);
    if (tick_volume > 100) {
        score += 0.3; // Good liquidity
    } else if (tick_volume > 50) {
        score += 0.15; // Moderate liquidity
    }
    
    // Market hours bonus
    datetime current_time = TimeCurrent();
    MqlDateTime dt;
    TimeToStruct(current_time, dt);
    
    if (dt.day_of_week >= 1 && dt.day_of_week <= 5) { // Weekdays
        if (dt.hour >= 8 && dt.hour <= 17) {
            score += 0.3; // Prime trading hours
        } else {
            score += 0.1; // Off-hours
        }
    }
    
    return MathMin(score, 1.0);
}

//+------------------------------------------------------------------+
//| Process Signal                                                   |
//+------------------------------------------------------------------+
void CSignalEngine::ProcessSignal(SSignalContext& signal) {
    if (signal.signalType == SIGNAL_NONE) {
        return;
    }
    
    // Calculate signal parameters
    CalculateSignalParameters(signal);
    
    // Apply risk management
    ApplyRiskManagement(signal);
    
    // Optimize entry timing
    OptimizeEntryTiming(signal);
    
    // Set market context
    signal.marketRegime = DetectMarketRegime();
    signal.volatility = CalculateVolatilityIndex();
    signal.spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    
    // Calculate risk/reward ratio
    if (signal.stopLoss != 0) {
        double risk = MathAbs(signal.entryPrice - signal.stopLoss);
        double reward = MathAbs(signal.takeProfit - signal.entryPrice);
        signal.riskRewardRatio = (risk > 0) ? reward / risk : 0.0;
    }
    
    // Calculate expected pips
    double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
    double pip_size = (digits == 5 || digits == 3) ? point * 10 : point;
    
    signal.expectedPips = MathAbs(signal.takeProfit - signal.entryPrice) / pip_size;
    signal.maxRiskPips = MathAbs(signal.entryPrice - signal.stopLoss) / pip_size;
    
    // Set urgency level based on signal strength and market conditions
    if (signal.confidenceScore > 0.8) {
        signal.urgencyLevel = 5;
    } else if (signal.confidenceScore > 0.6) {
        signal.urgencyLevel = 4;
    } else if (signal.confidenceScore > 0.4) {
        signal.urgencyLevel = 3;
    } else {
        signal.urgencyLevel = 2;
    }
}

//+------------------------------------------------------------------+
//| Calculate Signal Parameters                                      |
//+------------------------------------------------------------------+
void CSignalEngine::CalculateSignalParameters(SSignalContext& signal) {
    // Basic parameter calculation - already done in signal detection
    // This method can be enhanced with more sophisticated calculations
}

//+------------------------------------------------------------------+
//| Apply Risk Management                                            |
//+------------------------------------------------------------------+
void CSignalEngine::ApplyRiskManagement(SSignalContext& signal) {
    // Ensure minimum risk/reward ratio
    if (signal.riskRewardRatio < 1.5) {
        double risk = MathAbs(signal.entryPrice - signal.stopLoss);
        if (signal.signalType == SIGNAL_BUY) {
            signal.takeProfit = signal.entryPrice + (risk * 2.0);
        } else {
            signal.takeProfit = signal.entryPrice - (risk * 2.0);
        }
    }
    
    // Apply maximum risk limits
    double max_risk_pips = 50.0; // Maximum 50 pips risk
    double pip_size = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    if ((int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) == 5 || (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) == 3) {
        pip_size *= 10;
    }
    
    double current_risk_pips = MathAbs(signal.entryPrice - signal.stopLoss) / pip_size;
    if (current_risk_pips > max_risk_pips) {
        if (signal.signalType == SIGNAL_BUY) {
            signal.stopLoss = signal.entryPrice - (max_risk_pips * pip_size);
        } else {
            signal.stopLoss = signal.entryPrice + (max_risk_pips * pip_size);
        }
    }
}

//+------------------------------------------------------------------+
//| Optimize Entry Timing                                            |
//+------------------------------------------------------------------+
void CSignalEngine::OptimizeEntryTiming(SSignalContext& signal) {
    // This could include more sophisticated timing optimization
    // For now, we'll just set a reasonable expiry time
    signal.expiryTime = signal.signalTime + 300; // 5 minutes
}

//+------------------------------------------------------------------+
//| Enhanced Validation Methods                                      |
//+------------------------------------------------------------------+
bool CSignalEngine::ValidateMarketConditions(const SSignalContext& signal) {
    // Check spread
    double spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    double max_spread = SymbolInfoDouble(_Symbol, SYMBOL_BID) * 0.0005; // 0.05%
    
    if (spread > max_spread) {
        return false;
    }
    
    // Check trading hours
    datetime current_time = TimeCurrent();
    MqlDateTime dt;
    TimeToStruct(current_time, dt);
    
    if (dt.day_of_week == 0 || dt.day_of_week == 6) {
        return false; // No weekend trading
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Validate Risk Parameters                                         |
//+------------------------------------------------------------------+
bool CSignalEngine::ValidateRiskParameters(const SSignalContext& signal) {
    // Check minimum risk/reward ratio
    if (signal.riskRewardRatio < 1.0) {
        return false;
    }
    
    // Check maximum risk
    if (signal.maxRiskPips > 100.0) {
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Validate News Events                                             |
//+------------------------------------------------------------------+
bool CSignalEngine::ValidateNews(const SSignalContext& signal) {
    // Simplified news validation
    // In a full implementation, this would check for upcoming news events
    return true;
}

//+------------------------------------------------------------------+
//| Validate Correlation                                             |
//+------------------------------------------------------------------+
bool CSignalEngine::ValidateCorrelation(const SSignalContext& signal) {
    // Simplified correlation validation
    // In a full implementation, this would check correlation with other open positions
    return true;
}

//+------------------------------------------------------------------+
//| Utility Methods                                                  |
//+------------------------------------------------------------------+
double CSignalEngine::NormalizeScore(double value, double min_val, double max_val) {
    if (max_val <= min_val) return 0.0;
    return MathMax(0.0, MathMin(1.0, (value - min_val) / (max_val - min_val)));
}

//+------------------------------------------------------------------+
//| Signal Type to String                                            |
//+------------------------------------------------------------------+
string CSignalEngine::SignalTypeToString(ENUM_SIGNAL_TYPE signal_type) {
    switch (signal_type) {
        case SIGNAL_BUY: return "BUY";
        case SIGNAL_SELL: return "SELL";
        default: return "NONE";
    }
}

//+------------------------------------------------------------------+
//| Strategy to String                                               |
//+------------------------------------------------------------------+
string CSignalEngine::StrategyToString(ENUM_TRADING_STRATEGY strategy) {
    switch (strategy) {
        case STRATEGY_PULLBACK_TREND: return "PULLBACK_TREND";
        case STRATEGY_SHALLOW_PULLBACK: return "SHALLOW_PULLBACK";
        case STRATEGY_MOMENTUM_BREAKOUT: return "MOMENTUM_BREAKOUT";
        case STRATEGY_MEAN_REVERSION: return "MEAN_REVERSION";
        case STRATEGY_BREAKOUT: return "BREAKOUT";
        default: return "UNDEFINED";
    }
}

//+------------------------------------------------------------------+
//| Log Signal Quality                                               |
//+------------------------------------------------------------------+
void CSignalEngine::LogSignalQuality(const SSignalQuality& quality) {
    if (m_pContext->pLogger != NULL) {
        string message = StringFormat("Signal Quality - Overall: %.2f, Technical: %.2f, Timing: %.2f, Market: %.2f, Risk: %.2f",
            quality.overallScore, quality.technicalScore, quality.timingScore, 
            quality.marketConditionScore, quality.riskScore);
        m_pContext->pLogger->LogInfo(message, __FUNCTION__);
    }
}

} // namespace v5
#endif // APEX_SIGNALENGINE_MQH_