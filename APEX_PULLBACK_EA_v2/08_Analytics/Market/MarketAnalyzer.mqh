//+------------------------------------------------------------------+
//|                                               MarketAnalyzer.mqh |
//|                                    APEX Pullback EA v5.0 FINAL   |
//|                                      Advanced Market Analyzer    |
//+------------------------------------------------------------------+
#property copyright "APEX Trading Systems"
#property version   "5.00"
#property strict

#include "../../01_Core/CommonStructs.mqh"

//+------------------------------------------------------------------+
//| Market condition enumeration                                    |
//+------------------------------------------------------------------+
enum ENUM_MARKET_CONDITION {
    MARKET_CONDITION_UNKNOWN,
    MARKET_CONDITION_TRENDING_UP,
    MARKET_CONDITION_TRENDING_DOWN,
    MARKET_CONDITION_RANGING,
    MARKET_CONDITION_VOLATILE,
    MARKET_CONDITION_CONSOLIDATING,
    MARKET_CONDITION_BREAKOUT_UP,
    MARKET_CONDITION_BREAKOUT_DOWN,
    MARKET_CONDITION_REVERSAL_UP,
    MARKET_CONDITION_REVERSAL_DOWN
};

//+------------------------------------------------------------------+
//| Market strength enumeration                                     |
//+------------------------------------------------------------------+
enum ENUM_MARKET_STRENGTH {
    MARKET_STRENGTH_VERY_WEAK,
    MARKET_STRENGTH_WEAK,
    MARKET_STRENGTH_NEUTRAL,
    MARKET_STRENGTH_STRONG,
    MARKET_STRENGTH_VERY_STRONG
};

//+------------------------------------------------------------------+
//| Volatility level enumeration                                    |
//+------------------------------------------------------------------+
enum ENUM_VOLATILITY_LEVEL {
    VOLATILITY_VERY_LOW,
    VOLATILITY_LOW,
    VOLATILITY_NORMAL,
    VOLATILITY_HIGH,
    VOLATILITY_VERY_HIGH
};

//+------------------------------------------------------------------+
//| Market session enumeration                                      |
//+------------------------------------------------------------------+
enum ENUM_MARKET_SESSION {
    SESSION_ASIAN,
    SESSION_EUROPEAN,
    SESSION_AMERICAN,
    SESSION_OVERLAP_ASIAN_EUROPEAN,
    SESSION_OVERLAP_EUROPEAN_AMERICAN,
    SESSION_WEEKEND
};

//+------------------------------------------------------------------+
//| Market analysis structure                                       |
//+------------------------------------------------------------------+
struct SMarketAnalysis {
    datetime AnalysisTime;
    ENUM_MARKET_CONDITION Condition;
    ENUM_MARKET_STRENGTH Strength;
    ENUM_VOLATILITY_LEVEL Volatility;
    ENUM_MARKET_SESSION Session;
    
    // Trend analysis
    double TrendStrength;
    double TrendDirection; // -1 to 1
    double TrendDuration; // in hours
    double TrendReliability; // 0 to 1
    
    // Support and resistance
    double SupportLevel;
    double ResistanceLevel;
    double SupportStrength;
    double ResistanceStrength;
    
    // Volatility metrics
    double ATR;
    double VolatilityRatio;
    double VolatilityPercentile;
    
    // Momentum indicators
    double RSI;
    double MACD;
    double MACDSignal;
    double MACDHistogram;
    double Stochastic;
    double Williams;
    
    // Volume analysis
    double VolumeRatio;
    double VolumeMA;
    double VolumeTrend;
    
    // Market microstructure
    double BidAskSpread;
    double MarketDepth;
    double OrderFlow;
    
    // Correlation analysis
    double CorrelationToMajors[8]; // Major currency pairs
    double CorrelationToIndices[4]; // Major indices
    double CorrelationToCommodities[4]; // Major commodities
    
    // News and events impact
    double NewsImpactScore;
    string UpcomingEvents;
    double EventRiskLevel;
    
    // Confidence metrics
    double AnalysisConfidence;
    double PredictionAccuracy;
    string AnalysisNotes;
};

//+------------------------------------------------------------------+
//| Market statistics structure                                     |
//+------------------------------------------------------------------+
struct SMarketStats {
    // Historical performance
    double AvgDailyRange;
    double AvgWeeklyRange;
    double AvgMonthlyRange;
    
    // Volatility statistics
    double VolatilityMean;
    double VolatilityStdDev;
    double VolatilitySkewness;
    double VolatilityKurtosis;
    
    // Trend statistics
    double TrendingDaysPercent;
    double RangingDaysPercent;
    double AvgTrendDuration;
    double AvgRangeDuration;
    
    // Session statistics
    double SessionVolatility[4]; // Asian, European, American, Overlap
    double SessionRange[4];
    double SessionVolume[4];
    
    // Correlation statistics
    double AvgCorrelationToMajors;
    double MaxCorrelationToMajors;
    double MinCorrelationToMajors;
    
    // Performance metrics
    int AnalysisCount;
    double AccuracyRate;
    datetime LastUpdate;
};

//+------------------------------------------------------------------+
//| Market regime structure                                         |
//+------------------------------------------------------------------+
struct SMarketRegime {
    ENUM_MARKET_CONDITION CurrentRegime;
    datetime RegimeStartTime;
    double RegimeDuration;
    double RegimeStrength;
    double RegimeStability;
    
    // Regime transition probabilities
    double TransitionProbabilities[10]; // To each market condition
    double RegimePersistence;
    
    // Regime characteristics
    double AvgVolatility;
    double AvgTrendStrength;
    double AvgRange;
    
    // Historical regime data
    ENUM_MARKET_CONDITION RegimeHistory[100];
    datetime RegimeChangeHistory[100];
    int RegimeHistoryCount;
};

//+------------------------------------------------------------------+
//| Market Analyzer Class                                           |
//+------------------------------------------------------------------+
class CMarketAnalyzer {
private:
    EAContext* m_pContext;
    
    // Analysis data
    SMarketAnalysis m_CurrentAnalysis;
    SMarketStats m_Statistics;
    SMarketRegime m_Regime;
    
    // Historical data
    SMarketAnalysis m_AnalysisHistory[1000];
    int m_HistoryCount;
    
    // Indicator handles
    int m_HandleATR;
    int m_HandleRSI;
    int m_HandleMACD;
    int m_HandleStochastic;
    int m_HandleWilliams;
    int m_HandleMA_Fast;
    int m_HandleMA_Slow;
    int m_HandleBB;
    
    // Analysis parameters
    int m_ATRPeriod;
    int m_RSIPeriod;
    int m_MACDFast;
    int m_MACDSlow;
    int m_MACDSignal;
    int m_StochasticK;
    int m_StochasticD;
    int m_WilliamsPeriod;
    int m_MAFastPeriod;
    int m_MASlowPeriod;
    int m_BBPeriod;
    double m_BBDeviation;
    
    // Analysis settings
    bool m_bInitialized;
    bool m_bRealTimeAnalysis;
    int m_AnalysisInterval; // in seconds
    datetime m_LastAnalysisTime;
    
    // Thresholds
    double m_TrendThreshold;
    double m_VolatilityThreshold;
    double m_StrengthThreshold;
    
public:
    CMarketAnalyzer();
    ~CMarketAnalyzer();
    
    // Core methods
    bool Initialize(EAContext* context);
    void Deinitialize();
    
    // Analysis methods
    bool AnalyzeMarket();
    bool UpdateAnalysis();
    SMarketAnalysis GetCurrentAnalysis() const { return m_CurrentAnalysis; }
    SMarketAnalysis GetHistoricalAnalysis(const int index) const;
    
    // Market condition analysis
    ENUM_MARKET_CONDITION DetermineMarketCondition();
    ENUM_MARKET_STRENGTH CalculateMarketStrength();
    ENUM_VOLATILITY_LEVEL AssessVolatilityLevel();
    ENUM_MARKET_SESSION GetCurrentSession();
    
    // Trend analysis
    double CalculateTrendStrength();
    double CalculateTrendDirection();
    double EstimateTrendDuration();
    double AssessTrendReliability();
    
    // Support and resistance
    bool IdentifySupportResistance();
    double FindSupportLevel();
    double FindResistanceLevel();
    double CalculateLevelStrength(const double level);
    
    // Volatility analysis
    double CalculateATR();
    double CalculateVolatilityRatio();
    double CalculateVolatilityPercentile();
    ENUM_VOLATILITY_LEVEL ClassifyVolatility(const double volatility);
    
    // Momentum analysis
    double CalculateRSI();
    bool CalculateMACD(double& macd, double& signal, double& histogram);
    double CalculateStochastic();
    double CalculateWilliams();
    
    // Volume analysis
    double CalculateVolumeRatio();
    double CalculateVolumeMA();
    double AnalyzeVolumeTrend();
    
    // Market microstructure
    double CalculateBidAskSpread();
    double AssessMarketDepth();
    double AnalyzeOrderFlow();
    
    // Correlation analysis
    bool CalculateCorrelations();
    double CalculateCorrelationToSymbol(const string symbol, const int period);
    void UpdateCorrelationMatrix();
    
    // News and events
    double AssessNewsImpact();
    string GetUpcomingEvents();
    double CalculateEventRisk();
    
    // Market regime analysis
    bool AnalyzeMarketRegime();
    bool DetectRegimeChange();
    double CalculateRegimePersistence();
    void UpdateRegimeHistory();
    
    // Statistical analysis
    void UpdateStatistics();
    SMarketStats GetStatistics() const { return m_Statistics; }
    void CalculateHistoricalStats();
    
    // Prediction and forecasting
    ENUM_MARKET_CONDITION PredictNextCondition();
    double PredictVolatility(const int hoursAhead);
    double PredictTrendContinuation();
    
    // Configuration
    void SetAnalysisParameters(const int atrPeriod, const int rsiPeriod, const int macdFast, const int macdSlow);
    void SetThresholds(const double trendThreshold, const double volatilityThreshold, const double strengthThreshold);
    void EnableRealTimeAnalysis(const bool enable, const int intervalSeconds = 60);
    
    // Validation and quality control
    bool ValidateAnalysis(const SMarketAnalysis& analysis);
    double CalculateAnalysisConfidence();
    void UpdateAccuracyMetrics();
    
    // Reporting
    string GenerateAnalysisReport();
    string GenerateMarketSummary();
    void ExportAnalysisData(const string filePath);
    
private:
    // Internal analysis methods
    bool InitializeIndicators();
    void CleanupIndicators();
    
    // Data collection
    bool CollectMarketData();
    bool CollectVolumeData();
    bool CollectNewsData();
    
    // Calculation helpers
    double CalculateMovingAverage(const double& data[], const int period);
    double CalculateStandardDeviation(const double& data[], const int period);
    double CalculateCorrelation(const double& data1[], const double& data2[], const int period);
    double CalculateLinearRegression(const double& data[], const int period);
    
    // Pattern recognition
    bool DetectTrendPattern();
    bool DetectRangePattern();
    bool DetectBreakoutPattern();
    bool DetectReversalPattern();
    
    // Time analysis
    bool IsAsianSession();
    bool IsEuropeanSession();
    bool IsAmericanSession();
    bool IsSessionOverlap();
    
    // Validation helpers
    bool IsValidPrice(const double price);
    bool IsValidVolume(const long volume);
    bool IsValidTime(const datetime time);
    
    // Logging
    void LogAnalysisEvent(const string event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CMarketAnalyzer::CMarketAnalyzer() {
    m_pContext = NULL;
    m_bInitialized = false;
    m_bRealTimeAnalysis = false;
    m_AnalysisInterval = 60;
    m_LastAnalysisTime = 0;
    m_HistoryCount = 0;
    
    // Initialize indicator handles
    m_HandleATR = INVALID_HANDLE;
    m_HandleRSI = INVALID_HANDLE;
    m_HandleMACD = INVALID_HANDLE;
    m_HandleStochastic = INVALID_HANDLE;
    m_HandleWilliams = INVALID_HANDLE;
    m_HandleMA_Fast = INVALID_HANDLE;
    m_HandleMA_Slow = INVALID_HANDLE;
    m_HandleBB = INVALID_HANDLE;
    
    // Set default parameters
    m_ATRPeriod = 14;
    m_RSIPeriod = 14;
    m_MACDFast = 12;
    m_MACDSlow = 26;
    m_MACDSignal = 9;
    m_StochasticK = 5;
    m_StochasticD = 3;
    m_WilliamsPeriod = 14;
    m_MAFastPeriod = 20;
    m_MASlowPeriod = 50;
    m_BBPeriod = 20;
    m_BBDeviation = 2.0;
    
    // Set default thresholds
    m_TrendThreshold = 0.6;
    m_VolatilityThreshold = 1.5;
    m_StrengthThreshold = 0.7;
    
    // Initialize structures
    ZeroMemory(m_CurrentAnalysis);
    ZeroMemory(m_Statistics);
    ZeroMemory(m_Regime);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CMarketAnalyzer::~CMarketAnalyzer() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize Market Analyzer                                      |
//+------------------------------------------------------------------+
bool CMarketAnalyzer::Initialize(EAContext* context) {
    if (context == NULL) {
        Print("[MARKET ANALYZER ERROR] Context is NULL");
        return false;
    }
    
    m_pContext = context;
    
    // Initialize indicators
    if (!InitializeIndicators()) {
        LogAnalysisEvent("Failed to initialize indicators", LOG_LEVEL_ERROR);
        return false;
    }
    
    // Initialize analysis structures
    m_CurrentAnalysis.AnalysisTime = TimeCurrent();
    m_CurrentAnalysis.Condition = MARKET_CONDITION_UNKNOWN;
    m_CurrentAnalysis.Strength = MARKET_STRENGTH_NEUTRAL;
    m_CurrentAnalysis.Volatility = VOLATILITY_NORMAL;
    m_CurrentAnalysis.AnalysisConfidence = 0.0;
    
    // Initialize regime
    m_Regime.CurrentRegime = MARKET_CONDITION_UNKNOWN;
    m_Regime.RegimeStartTime = TimeCurrent();
    m_Regime.RegimeHistoryCount = 0;
    
    // Perform initial analysis
    if (!AnalyzeMarket()) {
        LogAnalysisEvent("Initial market analysis failed", LOG_LEVEL_WARNING);
    }
    
    m_bInitialized = true;
    LogAnalysisEvent("Market Analyzer initialized successfully");
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize Market Analyzer                                    |
//+------------------------------------------------------------------+
void CMarketAnalyzer::Deinitialize() {
    if (m_bInitialized) {
        CleanupIndicators();
        LogAnalysisEvent("Market Analyzer deinitialized");
    }
    
    m_bInitialized = false;
    m_pContext = NULL;
}

//+------------------------------------------------------------------+
//| Initialize indicators                                            |
//+------------------------------------------------------------------+
bool CMarketAnalyzer::InitializeIndicators() {
    string symbol = Symbol();
    ENUM_TIMEFRAMES timeframe = Period();
    
    // Initialize ATR
    m_HandleATR = iATR(symbol, timeframe, m_ATRPeriod);
    if (m_HandleATR == INVALID_HANDLE) {
        LogAnalysisEvent("Failed to initialize ATR indicator", LOG_LEVEL_ERROR);
        return false;
    }
    
    // Initialize RSI
    m_HandleRSI = iRSI(symbol, timeframe, m_RSIPeriod, PRICE_CLOSE);
    if (m_HandleRSI == INVALID_HANDLE) {
        LogAnalysisEvent("Failed to initialize RSI indicator", LOG_LEVEL_ERROR);
        return false;
    }
    
    // Initialize MACD
    m_HandleMACD = iMACD(symbol, timeframe, m_MACDFast, m_MACDSlow, m_MACDSignal, PRICE_CLOSE);
    if (m_HandleMACD == INVALID_HANDLE) {
        LogAnalysisEvent("Failed to initialize MACD indicator", LOG_LEVEL_ERROR);
        return false;
    }
    
    // Initialize Stochastic
    m_HandleStochastic = iStochastic(symbol, timeframe, m_StochasticK, m_StochasticD, 3, MODE_SMA, STO_LOWHIGH);
    if (m_HandleStochastic == INVALID_HANDLE) {
        LogAnalysisEvent("Failed to initialize Stochastic indicator", LOG_LEVEL_ERROR);
        return false;
    }
    
    // Initialize Williams %R
    m_HandleWilliams = iWPR(symbol, timeframe, m_WilliamsPeriod);
    if (m_HandleWilliams == INVALID_HANDLE) {
        LogAnalysisEvent("Failed to initialize Williams %R indicator", LOG_LEVEL_ERROR);
        return false;
    }
    
    // Initialize Moving Averages
    m_HandleMA_Fast = iMA(symbol, timeframe, m_MAFastPeriod, 0, MODE_SMA, PRICE_CLOSE);
    if (m_HandleMA_Fast == INVALID_HANDLE) {
        LogAnalysisEvent("Failed to initialize Fast MA indicator", LOG_LEVEL_ERROR);
        return false;
    }
    
    m_HandleMA_Slow = iMA(symbol, timeframe, m_MASlowPeriod, 0, MODE_SMA, PRICE_CLOSE);
    if (m_HandleMA_Slow == INVALID_HANDLE) {
        LogAnalysisEvent("Failed to initialize Slow MA indicator", LOG_LEVEL_ERROR);
        return false;
    }
    
    // Initialize Bollinger Bands
    m_HandleBB = iBands(symbol, timeframe, m_BBPeriod, 0, m_BBDeviation, PRICE_CLOSE);
    if (m_HandleBB == INVALID_HANDLE) {
        LogAnalysisEvent("Failed to initialize Bollinger Bands indicator", LOG_LEVEL_ERROR);
        return false;
    }
    
    LogAnalysisEvent("All indicators initialized successfully");
    return true;
}

//+------------------------------------------------------------------+
//| Cleanup indicators                                              |
//+------------------------------------------------------------------+
void CMarketAnalyzer::CleanupIndicators() {
    if (m_HandleATR != INVALID_HANDLE) {
        IndicatorRelease(m_HandleATR);
        m_HandleATR = INVALID_HANDLE;
    }
    
    if (m_HandleRSI != INVALID_HANDLE) {
        IndicatorRelease(m_HandleRSI);
        m_HandleRSI = INVALID_HANDLE;
    }
    
    if (m_HandleMACD != INVALID_HANDLE) {
        IndicatorRelease(m_HandleMACD);
        m_HandleMACD = INVALID_HANDLE;
    }
    
    if (m_HandleStochastic != INVALID_HANDLE) {
        IndicatorRelease(m_HandleStochastic);
        m_HandleStochastic = INVALID_HANDLE;
    }
    
    if (m_HandleWilliams != INVALID_HANDLE) {
        IndicatorRelease(m_HandleWilliams);
        m_HandleWilliams = INVALID_HANDLE;
    }
    
    if (m_HandleMA_Fast != INVALID_HANDLE) {
        IndicatorRelease(m_HandleMA_Fast);
        m_HandleMA_Fast = INVALID_HANDLE;
    }
    
    if (m_HandleMA_Slow != INVALID_HANDLE) {
        IndicatorRelease(m_HandleMA_Slow);
        m_HandleMA_Slow = INVALID_HANDLE;
    }
    
    if (m_HandleBB != INVALID_HANDLE) {
        IndicatorRelease(m_HandleBB);
        m_HandleBB = INVALID_HANDLE;
    }
}

//+------------------------------------------------------------------+
//| Analyze market                                                  |
//+------------------------------------------------------------------+
bool CMarketAnalyzer::AnalyzeMarket() {
    if (!m_bInitialized) {
        LogAnalysisEvent("Market Analyzer not initialized", LOG_LEVEL_ERROR);
        return false;
    }
    
    // Check if it's time for analysis
    if (m_bRealTimeAnalysis && (TimeCurrent() - m_LastAnalysisTime) < m_AnalysisInterval) {
        return true; // Skip analysis if interval hasn't passed
    }
    
    LogAnalysisEvent("Starting market analysis...");
    
    // Update analysis time
    m_CurrentAnalysis.AnalysisTime = TimeCurrent();
    m_LastAnalysisTime = TimeCurrent();
    
    // Collect market data
    if (!CollectMarketData()) {
        LogAnalysisEvent("Failed to collect market data", LOG_LEVEL_ERROR);
        return false;
    }
    
    // Determine market condition
    m_CurrentAnalysis.Condition = DetermineMarketCondition();
    
    // Calculate market strength
    m_CurrentAnalysis.Strength = CalculateMarketStrength();
    
    // Assess volatility
    m_CurrentAnalysis.Volatility = AssessVolatilityLevel();
    
    // Get current session
    m_CurrentAnalysis.Session = GetCurrentSession();
    
    // Analyze trend
    m_CurrentAnalysis.TrendStrength = CalculateTrendStrength();
    m_CurrentAnalysis.TrendDirection = CalculateTrendDirection();
    m_CurrentAnalysis.TrendDuration = EstimateTrendDuration();
    m_CurrentAnalysis.TrendReliability = AssessTrendReliability();
    
    // Identify support and resistance
    IdentifySupportResistance();
    
    // Calculate volatility metrics
    m_CurrentAnalysis.ATR = CalculateATR();
    m_CurrentAnalysis.VolatilityRatio = CalculateVolatilityRatio();
    m_CurrentAnalysis.VolatilityPercentile = CalculateVolatilityPercentile();
    
    // Calculate momentum indicators
    m_CurrentAnalysis.RSI = CalculateRSI();
    CalculateMACD(m_CurrentAnalysis.MACD, m_CurrentAnalysis.MACDSignal, m_CurrentAnalysis.MACDHistogram);
    m_CurrentAnalysis.Stochastic = CalculateStochastic();
    m_CurrentAnalysis.Williams = CalculateWilliams();
    
    // Analyze volume
    m_CurrentAnalysis.VolumeRatio = CalculateVolumeRatio();
    m_CurrentAnalysis.VolumeMA = CalculateVolumeMA();
    m_CurrentAnalysis.VolumeTrend = AnalyzeVolumeTrend();
    
    // Market microstructure
    m_CurrentAnalysis.BidAskSpread = CalculateBidAskSpread();
    m_CurrentAnalysis.MarketDepth = AssessMarketDepth();
    m_CurrentAnalysis.OrderFlow = AnalyzeOrderFlow();
    
    // Calculate correlations
    CalculateCorrelations();
    
    // Assess news impact
    m_CurrentAnalysis.NewsImpactScore = AssessNewsImpact();
    m_CurrentAnalysis.UpcomingEvents = GetUpcomingEvents();
    m_CurrentAnalysis.EventRiskLevel = CalculateEventRisk();
    
    // Calculate confidence
    m_CurrentAnalysis.AnalysisConfidence = CalculateAnalysisConfidence();
    
    // Analyze market regime
    AnalyzeMarketRegime();
    
    // Update statistics
    UpdateStatistics();
    
    // Store in history
    if (m_HistoryCount < ArraySize(m_AnalysisHistory)) {
        m_AnalysisHistory[m_HistoryCount] = m_CurrentAnalysis;
        m_HistoryCount++;
    } else {
        // Shift array and add new analysis
        for (int i = 0; i < ArraySize(m_AnalysisHistory) - 1; i++) {
            m_AnalysisHistory[i] = m_AnalysisHistory[i + 1];
        }
        m_AnalysisHistory[ArraySize(m_AnalysisHistory) - 1] = m_CurrentAnalysis;
    }
    
    // Validate analysis
    if (!ValidateAnalysis(m_CurrentAnalysis)) {
        LogAnalysisEvent("Analysis validation failed", LOG_LEVEL_WARNING);
    }
    
    LogAnalysisEvent("Market analysis completed successfully");
    return true;
}

//+------------------------------------------------------------------+
//| Determine market condition                                      |
//+------------------------------------------------------------------+
ENUM_MARKET_CONDITION CMarketAnalyzer::DetermineMarketCondition() {
    double trendStrength = CalculateTrendStrength();
    double trendDirection = CalculateTrendDirection();
    double volatility = CalculateVolatilityRatio();
    
    // Strong trend conditions
    if (trendStrength > m_TrendThreshold) {
        if (trendDirection > 0.3) {
            return MARKET_CONDITION_TRENDING_UP;
        } else if (trendDirection < -0.3) {
            return MARKET_CONDITION_TRENDING_DOWN;
        }
    }
    
    // High volatility conditions
    if (volatility > m_VolatilityThreshold) {
        return MARKET_CONDITION_VOLATILE;
    }
    
    // Range-bound conditions
    if (trendStrength < 0.3 && volatility < 1.2) {
        return MARKET_CONDITION_RANGING;
    }
    
    // Consolidation
    if (volatility < 0.8) {
        return MARKET_CONDITION_CONSOLIDATING;
    }
    
    // Default to unknown
    return MARKET_CONDITION_UNKNOWN;
}

//+------------------------------------------------------------------+
//| Calculate market strength                                       |
//+------------------------------------------------------------------+
ENUM_MARKET_STRENGTH CMarketAnalyzer::CalculateMarketStrength() {
    double rsi = CalculateRSI();
    double trendStrength = CalculateTrendStrength();
    double volumeRatio = CalculateVolumeRatio();
    
    // Combine multiple factors
    double strength = 0;
    
    // RSI contribution
    if (rsi > 70) strength += 0.3;
    else if (rsi > 50) strength += 0.1;
    else if (rsi < 30) strength -= 0.3;
    else if (rsi < 50) strength -= 0.1;
    
    // Trend strength contribution
    strength += trendStrength * 0.4;
    
    // Volume contribution
    if (volumeRatio > 1.5) strength += 0.2;
    else if (volumeRatio > 1.0) strength += 0.1;
    else if (volumeRatio < 0.5) strength -= 0.2;
    
    // Normalize to 0-1 range
    strength = (strength + 1.0) / 2.0;
    
    // Classify strength
    if (strength > 0.8) return MARKET_STRENGTH_VERY_STRONG;
    else if (strength > 0.6) return MARKET_STRENGTH_STRONG;
    else if (strength > 0.4) return MARKET_STRENGTH_NEUTRAL;
    else if (strength > 0.2) return MARKET_STRENGTH_WEAK;
    else return MARKET_STRENGTH_VERY_WEAK;
}

//+------------------------------------------------------------------+
//| Assess volatility level                                         |
//+------------------------------------------------------------------+
ENUM_VOLATILITY_LEVEL CMarketAnalyzer::AssessVolatilityLevel() {
    double volatilityRatio = CalculateVolatilityRatio();
    return ClassifyVolatility(volatilityRatio);
}

//+------------------------------------------------------------------+
//| Get current market session                                      |
//+------------------------------------------------------------------+
ENUM_MARKET_SESSION CMarketAnalyzer::GetCurrentSession() {
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    
    // Convert to GMT
    int hour = dt.hour;
    
    // Asian session: 22:00 - 08:00 GMT
    if ((hour >= 22) || (hour < 8)) {
        return SESSION_ASIAN;
    }
    // European session: 08:00 - 16:00 GMT
    else if (hour >= 8 && hour < 16) {
        return SESSION_EUROPEAN;
    }
    // American session: 13:00 - 22:00 GMT
    else if (hour >= 13 && hour < 22) {
        // Check for overlap
        if (hour >= 13 && hour < 16) {
            return SESSION_OVERLAP_EUROPEAN_AMERICAN;
        }
        return SESSION_AMERICAN;
    }
    
    return SESSION_ASIAN; // Default
}

//+------------------------------------------------------------------+
//| Calculate trend strength                                        |
//+------------------------------------------------------------------+
double CMarketAnalyzer::CalculateTrendStrength() {
    if (m_HandleMA_Fast == INVALID_HANDLE || m_HandleMA_Slow == INVALID_HANDLE) {
        return 0.0;
    }
    
    double maFast[10], maSlow[10];
    
    if (CopyBuffer(m_HandleMA_Fast, 0, 0, 10, maFast) <= 0 ||
        CopyBuffer(m_HandleMA_Slow, 0, 0, 10, maSlow) <= 0) {
        return 0.0;
    }
    
    // Calculate the separation between fast and slow MA
    double separation = MathAbs(maFast[0] - maSlow[0]);
    double avgPrice = (maFast[0] + maSlow[0]) / 2.0;
    
    if (avgPrice == 0) return 0.0;
    
    // Normalize by average price
    double strength = separation / avgPrice;
    
    // Apply additional factors
    double atr = CalculateATR();
    if (atr > 0) {
        strength = strength / atr; // Normalize by volatility
    }
    
    return MathMin(strength, 1.0); // Cap at 1.0
}

//+------------------------------------------------------------------+
//| Calculate trend direction                                       |
//+------------------------------------------------------------------+
double CMarketAnalyzer::CalculateTrendDirection() {
    if (m_HandleMA_Fast == INVALID_HANDLE || m_HandleMA_Slow == INVALID_HANDLE) {
        return 0.0;
    }
    
    double maFast[2], maSlow[2];
    
    if (CopyBuffer(m_HandleMA_Fast, 0, 0, 2, maFast) <= 0 ||
        CopyBuffer(m_HandleMA_Slow, 0, 0, 2, maSlow) <= 0) {
        return 0.0;
    }
    
    // Calculate direction based on MA relationship and slope
    double direction = 0.0;
    
    // MA relationship (50% weight)
    if (maFast[0] > maSlow[0]) {
        direction += 0.5;
    } else {
        direction -= 0.5;
    }
    
    // MA slope (50% weight)
    double fastSlope = maFast[0] - maFast[1];
    double slowSlope = maSlow[0] - maSlow[1];
    
    if (fastSlope > 0 && slowSlope > 0) {
        direction += 0.5;
    } else if (fastSlope < 0 && slowSlope < 0) {
        direction -= 0.5;
    }
    
    return MathMax(-1.0, MathMin(1.0, direction));
}

//+------------------------------------------------------------------+
//| Calculate ATR                                                   |
//+------------------------------------------------------------------+
double CMarketAnalyzer::CalculateATR() {
    if (m_HandleATR == INVALID_HANDLE) {
        return 0.0;
    }
    
    double atr[1];
    if (CopyBuffer(m_HandleATR, 0, 0, 1, atr) <= 0) {
        return 0.0;
    }
    
    return atr[0];
}

//+------------------------------------------------------------------+
//| Calculate volatility ratio                                      |
//+------------------------------------------------------------------+
double CMarketAnalyzer::CalculateVolatilityRatio() {
    double currentATR = CalculateATR();
    
    if (m_HandleATR == INVALID_HANDLE || currentATR == 0) {
        return 1.0;
    }
    
    // Get historical ATR values
    double atrHistory[50];
    if (CopyBuffer(m_HandleATR, 0, 1, 50, atrHistory) <= 0) {
        return 1.0;
    }
    
    // Calculate average ATR
    double avgATR = 0.0;
    for (int i = 0; i < 50; i++) {
        avgATR += atrHistory[i];
    }
    avgATR /= 50.0;
    
    if (avgATR == 0) return 1.0;
    
    return currentATR / avgATR;
}

//+------------------------------------------------------------------+
//| Calculate RSI                                                   |
//+------------------------------------------------------------------+
double CMarketAnalyzer::CalculateRSI() {
    if (m_HandleRSI == INVALID_HANDLE) {
        return 50.0;
    }
    
    double rsi[1];
    if (CopyBuffer(m_HandleRSI, 0, 0, 1, rsi) <= 0) {
        return 50.0;
    }
    
    return rsi[0];
}

//+------------------------------------------------------------------+
//| Calculate MACD                                                  |
//+------------------------------------------------------------------+
bool CMarketAnalyzer::CalculateMACD(double& macd, double& signal, double& histogram) {
    if (m_HandleMACD == INVALID_HANDLE) {
        macd = 0.0;
        signal = 0.0;
        histogram = 0.0;
        return false;
    }
    
    double macdMain[1], macdSignal[1];
    
    if (CopyBuffer(m_HandleMACD, 0, 0, 1, macdMain) <= 0 ||
        CopyBuffer(m_HandleMACD, 1, 0, 1, macdSignal) <= 0) {
        macd = 0.0;
        signal = 0.0;
        histogram = 0.0;
        return false;
    }
    
    macd = macdMain[0];
    signal = macdSignal[0];
    histogram = macd - signal;
    
    return true;
}

//+------------------------------------------------------------------+
//| Calculate Stochastic                                            |
//+------------------------------------------------------------------+
double CMarketAnalyzer::CalculateStochastic() {
    if (m_HandleStochastic == INVALID_HANDLE) {
        return 50.0;
    }
    
    double stoch[1];
    if (CopyBuffer(m_HandleStochastic, 0, 0, 1, stoch) <= 0) {
        return 50.0;
    }
    
    return stoch[0];
}

//+------------------------------------------------------------------+
//| Calculate Williams %R                                           |
//+------------------------------------------------------------------+
double CMarketAnalyzer::CalculateWilliams() {
    if (m_HandleWilliams == INVALID_HANDLE) {
        return -50.0;
    }
    
    double williams[1];
    if (CopyBuffer(m_HandleWilliams, 0, 0, 1, williams) <= 0) {
        return -50.0;
    }
    
    return williams[0];
}

//+------------------------------------------------------------------+
//| Placeholder methods for additional functionality               |
//+------------------------------------------------------------------+
bool CMarketAnalyzer::CollectMarketData() {
    // Placeholder - collect current market data
    return true;
}

double CMarketAnalyzer::EstimateTrendDuration() {
    // Placeholder - estimate how long current trend has been active
    return 4.5; // hours
}

double CMarketAnalyzer::AssessTrendReliability() {
    // Placeholder - assess reliability of current trend
    return 0.75;
}

bool CMarketAnalyzer::IdentifySupportResistance() {
    // Placeholder - identify key support and resistance levels
    m_CurrentAnalysis.SupportLevel = SymbolInfoDouble(Symbol(), SYMBOL_BID) - 100 * SymbolInfoDouble(Symbol(), SYMBOL_POINT);
    m_CurrentAnalysis.ResistanceLevel = SymbolInfoDouble(Symbol(), SYMBOL_ASK) + 100 * SymbolInfoDouble(Symbol(), SYMBOL_POINT);
    m_CurrentAnalysis.SupportStrength = 0.8;
    m_CurrentAnalysis.ResistanceStrength = 0.7;
    return true;
}

double CMarketAnalyzer::CalculateVolatilityPercentile() {
    // Placeholder - calculate volatility percentile
    return 65.0;
}

double CMarketAnalyzer::CalculateVolumeRatio() {
    // Placeholder - calculate volume ratio
    return 1.2;
}

double CMarketAnalyzer::CalculateVolumeMA() {
    // Placeholder - calculate volume moving average
    return 1000.0;
}

double CMarketAnalyzer::AnalyzeVolumeTrend() {
    // Placeholder - analyze volume trend
    return 0.1; // Slight uptrend
}

double CMarketAnalyzer::CalculateBidAskSpread() {
    double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
    double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
    return ask - bid;
}

double CMarketAnalyzer::AssessMarketDepth() {
    // Placeholder - assess market depth
    return 0.8;
}

double CMarketAnalyzer::AnalyzeOrderFlow() {
    // Placeholder - analyze order flow
    return 0.2;
}

bool CMarketAnalyzer::CalculateCorrelations() {
    // Placeholder - calculate correlations to other instruments
    ArrayInitialize(m_CurrentAnalysis.CorrelationToMajors, 0.5);
    ArrayInitialize(m_CurrentAnalysis.CorrelationToIndices, 0.3);
    ArrayInitialize(m_CurrentAnalysis.CorrelationToCommodities, 0.1);
    return true;
}

double CMarketAnalyzer::AssessNewsImpact() {
    // Placeholder - assess news impact
    return 0.3;
}

string CMarketAnalyzer::GetUpcomingEvents() {
    // Placeholder - get upcoming economic events
    return "NFP, FOMC Meeting";
}

double CMarketAnalyzer::CalculateEventRisk() {
    // Placeholder - calculate event risk
    return 0.4;
}

bool CMarketAnalyzer::AnalyzeMarketRegime() {
    // Placeholder - analyze market regime
    return true;
}

void CMarketAnalyzer::UpdateStatistics() {
    // Placeholder - update analysis statistics
    m_Statistics.AnalysisCount++;
    m_Statistics.LastUpdate = TimeCurrent();
}

double CMarketAnalyzer::CalculateAnalysisConfidence() {
    // Placeholder - calculate confidence in analysis
    return 0.85;
}

bool CMarketAnalyzer::ValidateAnalysis(const SMarketAnalysis& analysis) {
    // Basic validation
    if (analysis.AnalysisTime <= 0) return false;
    if (analysis.AnalysisConfidence < 0 || analysis.AnalysisConfidence > 1) return false;
    if (analysis.TrendDirection < -1 || analysis.TrendDirection > 1) return false;
    
    return true;
}

ENUM_VOLATILITY_LEVEL CMarketAnalyzer::ClassifyVolatility(const double volatility) {
    if (volatility < 0.5) return VOLATILITY_VERY_LOW;
    else if (volatility < 0.8) return VOLATILITY_LOW;
    else if (volatility < 1.2) return VOLATILITY_NORMAL;
    else if (volatility < 1.8) return VOLATILITY_HIGH;
    else return VOLATILITY_VERY_HIGH;
}

string CMarketAnalyzer::GenerateAnalysisReport() {
    string report = "=== MARKET ANALYSIS REPORT ===\n";
    report += "Time: " + TimeToString(m_CurrentAnalysis.AnalysisTime) + "\n";
    report += "Condition: " + EnumToString(m_CurrentAnalysis.Condition) + "\n";
    report += "Strength: " + EnumToString(m_CurrentAnalysis.Strength) + "\n";
    report += "Volatility: " + EnumToString(m_CurrentAnalysis.Volatility) + "\n";
    report += "Trend Direction: " + DoubleToString(m_CurrentAnalysis.TrendDirection, 2) + "\n";
    report += "Trend Strength: " + DoubleToString(m_CurrentAnalysis.TrendStrength, 2) + "\n";
    report += "RSI: " + DoubleToString(m_CurrentAnalysis.RSI, 1) + "\n";
    report += "ATR: " + DoubleToString(m_CurrentAnalysis.ATR, 5) + "\n";
    report += "Confidence: " + DoubleToString(m_CurrentAnalysis.AnalysisConfidence * 100, 1) + "%\n";
    
    return report;
}

//+------------------------------------------------------------------+
//| Log analysis event                                              |
//+------------------------------------------------------------------+
void CMarketAnalyzer::LogAnalysisEvent(const string event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO) {
    if (m_pContext != NULL && m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo("[MARKET ANALYZER] " + event);
    } else {
        Print("[MARKET ANALYZER] " + event);
    }
}

//+------------------------------------------------------------------+