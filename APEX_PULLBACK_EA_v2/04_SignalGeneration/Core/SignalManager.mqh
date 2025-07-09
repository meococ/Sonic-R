//+------------------------------------------------------------------+
//|                                                SignalManager.mqh |
//|                   APEX Pullback EA v5 FINAL - Signal Manager    |
//|      Description: Comprehensive signal generation and           |
//|                   management system with advanced filtering,    |
//|                   validation, and quality assessment.           |
//+------------------------------------------------------------------+

#ifndef SIGNAL_MANAGER_MQH
#define SIGNAL_MANAGER_MQH

#include "..\..\01_Core\CommonStructs.mqh"
#include "..\..\00_Core\Common\Enums.mqh"

//+------------------------------------------------------------------+
//| Signal Data Structures                                           |
//+------------------------------------------------------------------+

// Signal generation result
struct SSignalResult {
    ESignalDirection Direction;          // Signal direction
    double Confidence;                   // Signal confidence (0-1)
    double EntryPrice;                   // Suggested entry price
    double StopLoss;                     // Suggested stop loss
    double TakeProfit;                   // Suggested take profit
    string Reason;                       // Signal generation reason
    datetime Timestamp;                  // Signal timestamp
    bool IsValid;                        // Signal validity
    double RiskReward;                   // Risk/reward ratio
    int Priority;                        // Signal priority (1-10)
    
    void Reset() {
        Direction = DIRECTION_NONE;
        Confidence = 0.0;
        EntryPrice = 0.0;
        StopLoss = 0.0;
        TakeProfit = 0.0;
        Reason = "";
        Timestamp = 0;
        IsValid = false;
        RiskReward = 0.0;
        Priority = 0;
    }
};

// Signal configuration
struct SSignalConfig {
    bool EnableBuySignals;               // Enable buy signals
    bool EnableSellSignals;              // Enable sell signals
    double MinConfidence;                // Minimum signal confidence
    double MinRiskReward;                // Minimum risk/reward ratio
    bool UseTimeFilter;                  // Use time-based filtering
    bool UseSpreadFilter;                // Use spread filtering
    bool UseVolatilityFilter;            // Use volatility filtering
    bool UseNewsFilter;                  // Use news filtering
    int MaxSignalsPerDay;                // Maximum signals per day
    int SignalCooldownMinutes;           // Cooldown between signals
    
    void Reset() {
        EnableBuySignals = true;
        EnableSellSignals = true;
        MinConfidence = 0.6;
        MinRiskReward = 1.5;
        UseTimeFilter = true;
        UseSpreadFilter = true;
        UseVolatilityFilter = true;
        UseNewsFilter = true;
        MaxSignalsPerDay = 10;
        SignalCooldownMinutes = 30;
    }
};

//+------------------------------------------------------------------+
//| Signal Manager Class                                             |
//+------------------------------------------------------------------+
class CSignalManager {
private:
    // Core references
    EAContext*                    m_pContext;
    bool                         m_bInitialized;
    
    // Signal configuration
    SSignalConfig                m_Config;
    
    // Signal tracking
    SSignalResult                m_LastSignal;
    SSignalResult                m_SignalHistory[];
    int                          m_SignalCount;
    static const int             MAX_SIGNAL_HISTORY = 1000;
    
    // Signal generation state
    datetime                     m_LastSignalTime;
    int                          m_DailySignalCount;
    datetime                     m_LastDayTracked;
    
    // Technical analysis helpers
    double                       m_MA_Fast[];
    double                       m_MA_Slow[];
    double                       m_RSI[];
    double                       m_ATR[];
    static const int             INDICATOR_BUFFER_SIZE = 100;
    
    // Internal methods
    SSignalResult                GeneratePullbackSignal();
    SSignalResult                GenerateBreakoutSignal();
    SSignalResult                GenerateMeanReversionSignal();
    bool                         ValidateSignal(const SSignalResult& signal);
    double                       CalculateSignalConfidence(const SSignalResult& signal);
    bool                         CheckSignalFilters();
    void                         UpdateTechnicalIndicators();
    bool                         IsBullishPullback();
    bool                         IsBearishPullback();
    double                       CalculateStopLoss(ESignalDirection direction, double entryPrice);
    double                       CalculateTakeProfit(ESignalDirection direction, double entryPrice, double stopLoss);
    
public:
    // Constructor and destructor
                                 CSignalManager();
                                ~CSignalManager();
    
    // Initialization and cleanup
    bool                         Initialize(EAContext* context);
    void                         Cleanup();
    
    // Core signal methods
    void                         Update();
    SSignalResult                CheckForSignals();
    SSignalResult                GetLastSignal() { return m_LastSignal; }
    
    // Signal generation
    SSignalResult                GenerateSignal(ETradingStrategy strategy);
    bool                         HasValidSignal();
    double                       GetSignalStrength();
    
    // Signal history and tracking
    int                          GetSignalCount() { return m_SignalCount; }
    SSignalResult                GetSignalFromHistory(int index);
    int                          GetDailySignalCount() { return m_DailySignalCount; }
    
    // Signal configuration
    void                         ConfigureSignals(bool enableBuy, bool enableSell, 
                                                  double minConfidence, double minRiskReward);
    void                         SetSignalFilters(bool useTime, bool useSpread, 
                                                 bool useVolatility, bool useNews);
    void                         SetSignalLimits(int maxPerDay, int cooldownMinutes);
    
    // Signal validation and quality
    bool                         IsSignalValid(const SSignalResult& signal);
    double                       AssessSignalQuality(const SSignalResult& signal);
    string                       GetSignalAnalysis(const SSignalResult& signal);
    
    // Configuration and control
    bool                         UpdateConfiguration(EAContext* context);
    void                         ResetSignalHistory();
    
    // Diagnostics and reporting
    void                         RunDiagnostics();
    string                       GetSignalReport();
    string                       GetPerformanceReport();
    
    // Utility methods
    bool                         CanGenerateSignal();
    datetime                     GetNextSignalTime();
    double                       GetCurrentTrend();
    double                       GetCurrentVolatility();
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSignalManager::CSignalManager() {
    m_pContext = NULL;
    m_bInitialized = false;
    m_SignalCount = 0;
    m_LastSignalTime = 0;
    m_DailySignalCount = 0;
    m_LastDayTracked = 0;
    
    // Initialize arrays
    ArrayResize(m_SignalHistory, MAX_SIGNAL_HISTORY);
    ArrayResize(m_MA_Fast, INDICATOR_BUFFER_SIZE);
    ArrayResize(m_MA_Slow, INDICATOR_BUFFER_SIZE);
    ArrayResize(m_RSI, INDICATOR_BUFFER_SIZE);
    ArrayResize(m_ATR, INDICATOR_BUFFER_SIZE);
    
    // Reset configurations
    m_Config.Reset();
    m_LastSignal.Reset();
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSignalManager::~CSignalManager() {
    Cleanup();
}

//+------------------------------------------------------------------+
//| Initialize Signal Manager                                        |
//+------------------------------------------------------------------+
bool CSignalManager::Initialize(EAContext* context) {
    if (context == NULL) {
        Print("[SIGNAL] ERROR: Invalid context provided");
        return false;
    }
    
    m_pContext = context;
    
    // Configure from input parameters
    m_Config.MinConfidence = context.InputParams.ConfidenceThreshold;
    m_Config.MinRiskReward = context.InputParams.MinRiskReward;
    m_Config.UseTimeFilter = context.InputParams.UseTradingHours;
    m_Config.UseNewsFilter = context.InputParams.UseNewsFilter;
    
    // Initialize technical indicators
    UpdateTechnicalIndicators();
    
    m_bInitialized = true;
    Print("[SIGNAL] Signal Manager initialized successfully");
    return true;
}

//+------------------------------------------------------------------+
//| Cleanup                                                          |
//+------------------------------------------------------------------+
void CSignalManager::Cleanup() {
    if (m_bInitialized) {
        Print("[SIGNAL] Signal Manager cleaned up");
        m_bInitialized = false;
    }
}

//+------------------------------------------------------------------+
//| Main Update Method                                               |
//+------------------------------------------------------------------+
void CSignalManager::Update() {
    if (!m_bInitialized) return;
    
    // Update technical indicators
    UpdateTechnicalIndicators();
    
    // Reset daily signal count if new day
    datetime currentDay = iTime(_Symbol, PERIOD_D1, 0);
    if (currentDay != m_LastDayTracked) {
        m_DailySignalCount = 0;
        m_LastDayTracked = currentDay;
    }
}

//+------------------------------------------------------------------+
//| Check for Signals                                               |
//+------------------------------------------------------------------+
SSignalResult CSignalManager::CheckForSignals() {
    SSignalResult signal;
    signal.Reset();
    
    if (!m_bInitialized || !CanGenerateSignal()) {
        return signal;
    }
    
    // Generate signal based on configured strategy
    if (m_pContext != NULL) {
        signal = GenerateSignal(m_pContext.InputParams.Strategy);
    }
    
    // Validate and process signal
    if (ValidateSignal(signal)) {
        signal.Confidence = CalculateSignalConfidence(signal);
        
        if (signal.Confidence >= m_Config.MinConfidence) {
            // Store in history
            if (m_SignalCount < MAX_SIGNAL_HISTORY) {
                m_SignalHistory[m_SignalCount] = signal;
                m_SignalCount++;
            }
            
            m_LastSignal = signal;
            m_LastSignalTime = TimeCurrent();
            m_DailySignalCount++;
            
            Print("[SIGNAL] New signal generated: ", EnumToString(signal.Direction), 
                  " with confidence ", signal.Confidence);
        }
    }
    
    return signal;
}

//+------------------------------------------------------------------+
//| Generate Signal Based on Strategy                               |
//+------------------------------------------------------------------+
SSignalResult CSignalManager::GenerateSignal(ETradingStrategy strategy) {
    SSignalResult signal;
    signal.Reset();
    
    switch (strategy) {
        case STRATEGY_PULLBACK_TREND:
            signal = GeneratePullbackSignal();
            break;
        case STRATEGY_BREAKOUT:
            signal = GenerateBreakoutSignal();
            break;
        case STRATEGY_MEAN_REVERSION:
            signal = GenerateMeanReversionSignal();
            break;
        default:
            Print("[SIGNAL] Unknown strategy: ", EnumToString(strategy));
            break;
    }
    
    return signal;
}

//+------------------------------------------------------------------+
//| Generate Pullback Signal                                         |
//+------------------------------------------------------------------+
SSignalResult CSignalManager::GeneratePullbackSignal() {
    SSignalResult signal;
    signal.Reset();
    
    if (ArraySize(m_MA_Fast) < 3 || ArraySize(m_MA_Slow) < 3 || ArraySize(m_RSI) < 3) {
        return signal;
    }
    
    double currentPrice = iClose(_Symbol, _Period, 0);
    double ma_fast_current = m_MA_Fast[0];
    double ma_slow_current = m_MA_Slow[0];
    double rsi_current = m_RSI[0];
    
    // Check for bullish pullback
    if (IsBullishPullback()) {
        signal.Direction = DIRECTION_LONG;
        signal.EntryPrice = iClose(_Symbol, _Period, 0);
        signal.StopLoss = CalculateStopLoss(DIRECTION_LONG, signal.EntryPrice);
        signal.TakeProfit = CalculateTakeProfit(DIRECTION_LONG, signal.EntryPrice, signal.StopLoss);
        signal.Reason = "Bullish pullback in uptrend";
        signal.Timestamp = TimeCurrent();
        signal.IsValid = true;
        signal.Priority = 7;
    }
    // Check for bearish pullback
    else if (IsBearishPullback()) {
        signal.Direction = DIRECTION_SHORT;
        signal.EntryPrice = iClose(_Symbol, _Period, 0);
        signal.StopLoss = CalculateStopLoss(DIRECTION_SHORT, signal.EntryPrice);
        signal.TakeProfit = CalculateTakeProfit(DIRECTION_SHORT, signal.EntryPrice, signal.StopLoss);
        signal.Reason = "Bearish pullback in downtrend";
        signal.Timestamp = TimeCurrent();
        signal.IsValid = true;
        signal.Priority = 7;
    }
    
    return signal;
}

//+------------------------------------------------------------------+
//| Generate Breakout Signal                                         |
//+------------------------------------------------------------------+
SSignalResult CSignalManager::GenerateBreakoutSignal() {
    SSignalResult signal;
    signal.Reset();
    
    // Simplified breakout logic
    double currentPrice = iClose(_Symbol, _Period, 0);
    double high_1 = iHigh(_Symbol, _Period, 1);
    double high_2 = iHigh(_Symbol, _Period, 2);
    double low_1 = iLow(_Symbol, _Period, 1);
    double low_2 = iLow(_Symbol, _Period, 2);
    
    // Bullish breakout
    if (currentPrice > high_1 && high_1 > high_2) {
        signal.Direction = DIRECTION_LONG;
        signal.EntryPrice = currentPrice;
        signal.StopLoss = low_1;
        signal.TakeProfit = currentPrice + (currentPrice - low_1) * 2.0; // 2:1 RR
        signal.Reason = "Bullish breakout detected";
        signal.Timestamp = TimeCurrent();
        signal.IsValid = true;
        signal.Priority = 8;
    }
    // Bearish breakout
    else if (currentPrice < low_1 && low_1 < low_2) {
        signal.Direction = DIRECTION_SHORT;
        signal.EntryPrice = currentPrice;
        signal.StopLoss = high_1;
        signal.TakeProfit = currentPrice - (high_1 - currentPrice) * 2.0; // 2:1 RR
        signal.Reason = "Bearish breakout detected";
        signal.Timestamp = TimeCurrent();
        signal.IsValid = true;
        signal.Priority = 8;
    }
    
    return signal;
}

//+------------------------------------------------------------------+
//| Generate Mean Reversion Signal                                   |
//+------------------------------------------------------------------+
SSignalResult CSignalManager::GenerateMeanReversionSignal() {
    SSignalResult signal;
    signal.Reset();
    
    if (ArraySize(m_RSI) < 3) return signal;
    
    double rsi_current = m_RSI[0];
    double currentPrice = iClose(_Symbol, _Period, 0);
    
    // Oversold condition
    if (rsi_current < 30.0) {
        signal.Direction = DIRECTION_LONG;
        signal.EntryPrice = currentPrice;
        signal.StopLoss = currentPrice - GetCurrentVolatility() * 2.0;
        signal.TakeProfit = currentPrice + GetCurrentVolatility() * 3.0;
        signal.Reason = "Mean reversion - oversold";
        signal.Timestamp = TimeCurrent();
        signal.IsValid = true;
        signal.Priority = 5;
    }
    // Overbought condition
    else if (rsi_current > 70.0) {
        signal.Direction = DIRECTION_SHORT;
        signal.EntryPrice = currentPrice;
        signal.StopLoss = currentPrice + GetCurrentVolatility() * 2.0;
        signal.TakeProfit = currentPrice - GetCurrentVolatility() * 3.0;
        signal.Reason = "Mean reversion - overbought";
        signal.Timestamp = TimeCurrent();
        signal.IsValid = true;
        signal.Priority = 5;
    }
    
    return signal;
}

//+------------------------------------------------------------------+
//| Check if Bullish Pullback                                       |
//+------------------------------------------------------------------+
bool CSignalManager::IsBullishPullback() {
    if (ArraySize(m_MA_Fast) < 5 || ArraySize(m_MA_Slow) < 5 || ArraySize(m_RSI) < 5) {
        return false;
    }
    
    // Check if overall trend is up
    bool trendUp = m_MA_Fast[0] > m_MA_Slow[0] && m_MA_Fast[1] > m_MA_Slow[1];
    
    // Check for pullback (price coming back to fast MA)
    double currentPrice = iClose(_Symbol, _Period, 0);
    double previousPrice = iClose(_Symbol, _Period, 1);
    
    bool pullback = (currentPrice < m_MA_Fast[0] && previousPrice > m_MA_Fast[1]) ||
                    (currentPrice <= m_MA_Fast[0] && m_RSI[0] < 50.0 && m_RSI[1] > 50.0);
    
    // Check for bounce signal
    bool bounceSignal = currentPrice > iOpen(_Symbol, _Period, 0); // Current candle is green
    
    return trendUp && pullback && bounceSignal;
}

//+------------------------------------------------------------------+
//| Check if Bearish Pullback                                       |
//+------------------------------------------------------------------+
bool CSignalManager::IsBearishPullback() {
    if (ArraySize(m_MA_Fast) < 5 || ArraySize(m_MA_Slow) < 5 || ArraySize(m_RSI) < 5) {
        return false;
    }
    
    // Check if overall trend is down
    bool trendDown = m_MA_Fast[0] < m_MA_Slow[0] && m_MA_Fast[1] < m_MA_Slow[1];
    
    // Check for pullback (price coming back to fast MA)
    double currentPrice = iClose(_Symbol, _Period, 0);
    double previousPrice = iClose(_Symbol, _Period, 1);
    
    bool pullback = (currentPrice > m_MA_Fast[0] && previousPrice < m_MA_Fast[1]) ||
                    (currentPrice >= m_MA_Fast[0] && m_RSI[0] > 50.0 && m_RSI[1] < 50.0);
    
    // Check for rejection signal
    bool rejectionSignal = currentPrice < iOpen(_Symbol, _Period, 0); // Current candle is red
    
    return trendDown && pullback && rejectionSignal;
}

//+------------------------------------------------------------------+
//| Calculate Stop Loss                                              |
//+------------------------------------------------------------------+
double CSignalManager::CalculateStopLoss(ESignalDirection direction, double entryPrice) {
    double atr = GetCurrentVolatility();
    double stopDistance = atr * 2.0; // 2 ATR stop loss
    
    if (direction == DIRECTION_LONG) {
        return entryPrice - stopDistance;
    } else {
        return entryPrice + stopDistance;
    }
}

//+------------------------------------------------------------------+
//| Calculate Take Profit                                            |
//+------------------------------------------------------------------+
double CSignalManager::CalculateTakeProfit(ESignalDirection direction, double entryPrice, double stopLoss) {
    double stopDistance = MathAbs(entryPrice - stopLoss);
    double targetDistance = stopDistance * m_Config.MinRiskReward; // Use configured RR ratio
    
    if (direction == DIRECTION_LONG) {
        return entryPrice + targetDistance;
    } else {
        return entryPrice - targetDistance;
    }
}

//+------------------------------------------------------------------+
//| Update Technical Indicators                                      |
//+------------------------------------------------------------------+
void CSignalManager::UpdateTechnicalIndicators() {
    if (m_pContext == NULL) return;
    
    // Update moving averages
    for (int i = 0; i < INDICATOR_BUFFER_SIZE; i++) {
        m_MA_Fast[i] = iMA(_Symbol, _Period, m_pContext.InputParams.EMA_Fast, 0, MODE_EMA, PRICE_CLOSE, i);
        m_MA_Slow[i] = iMA(_Symbol, _Period, m_pContext.InputParams.EMA_Slow, 0, MODE_EMA, PRICE_CLOSE, i);
        m_RSI[i] = iRSI(_Symbol, _Period, m_pContext.InputParams.RSI_Period, PRICE_CLOSE, i);
        m_ATR[i] = iATR(_Symbol, _Period, m_pContext.InputParams.ATR_Period, i);
    }
}

//+------------------------------------------------------------------+
//| Validate Signal                                                  |
//+------------------------------------------------------------------+
bool CSignalManager::ValidateSignal(const SSignalResult& signal) {
    if (!signal.IsValid) return false;
    
    // Check direction filter
    if (signal.Direction == DIRECTION_LONG && !m_Config.EnableBuySignals) return false;
    if (signal.Direction == DIRECTION_SHORT && !m_Config.EnableSellSignals) return false;
    
    // Check risk/reward ratio
    if (signal.StopLoss != 0 && signal.TakeProfit != 0) {
        double risk = MathAbs(signal.EntryPrice - signal.StopLoss);
        double reward = MathAbs(signal.TakeProfit - signal.EntryPrice);
        signal.RiskReward = (risk > 0) ? reward / risk : 0.0;
        
        if (signal.RiskReward < m_Config.MinRiskReward) return false;
    }
    
    // Check filters
    if (!CheckSignalFilters()) return false;
    
    return true;
}

//+------------------------------------------------------------------+
//| Calculate Signal Confidence                                      |
//+------------------------------------------------------------------+
double CSignalManager::CalculateSignalConfidence(const SSignalResult& signal) {
    double confidence = 0.5; // Base confidence
    
    // Add confidence based on trend strength
    double trendStrength = GetCurrentTrend();
    confidence += MathAbs(trendStrength) * 0.2;
    
    // Add confidence based on signal priority
    confidence += signal.Priority * 0.03;
    
    // Add confidence based on risk/reward ratio
    if (signal.RiskReward > 2.0) {
        confidence += 0.1;
    }
    
    // Reduce confidence for high volatility
    double volatility = GetCurrentVolatility();
    if (volatility > SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 100) {
        confidence -= 0.1;
    }
    
    // Ensure confidence is within bounds
    return MathMax(0.0, MathMin(1.0, confidence));
}

//+------------------------------------------------------------------+
//| Check Signal Filters                                             |
//+------------------------------------------------------------------+
bool CSignalManager::CheckSignalFilters() {
    // Time filter
    if (m_Config.UseTimeFilter) {
        // Simplified - would check trading hours
        MqlDateTime dt;
        TimeToStruct(TimeCurrent(), dt);
        if (dt.hour < 8 || dt.hour > 18) return false;
    }
    
    // Spread filter
    if (m_Config.UseSpreadFilter) {
        double spread = (SymbolInfoDouble(_Symbol, SYMBOL_ASK) - SymbolInfoDouble(_Symbol, SYMBOL_BID)) / _Point;
        if (spread > 5.0) return false; // Max 5 pip spread
    }
    
    // Daily signal limit
    if (m_DailySignalCount >= m_Config.MaxSignalsPerDay) return false;
    
    // Cooldown period
    if (TimeCurrent() - m_LastSignalTime < m_Config.SignalCooldownMinutes * 60) return false;
    
    return true;
}

//+------------------------------------------------------------------+
//| Check if Can Generate Signal                                     |
//+------------------------------------------------------------------+
bool CSignalManager::CanGenerateSignal() {
    return m_bInitialized && CheckSignalFilters();
}

//+------------------------------------------------------------------+
//| Get Current Trend                                                |
//+------------------------------------------------------------------+
double CSignalManager::GetCurrentTrend() {
    if (ArraySize(m_MA_Fast) < 2 || ArraySize(m_MA_Slow) < 2) return 0.0;
    
    double fastMA = m_MA_Fast[0];
    double slowMA = m_MA_Slow[0];
    
    if (fastMA > slowMA) return 1.0;  // Uptrend
    if (fastMA < slowMA) return -1.0; // Downtrend
    return 0.0; // Sideways
}

//+------------------------------------------------------------------+
//| Get Current Volatility                                           |
//+------------------------------------------------------------------+
double CSignalManager::GetCurrentVolatility() {
    if (ArraySize(m_ATR) < 1) {
        return SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 50; // Default 50 points
    }
    return m_ATR[0];
}

//+------------------------------------------------------------------+
//| Run Diagnostics                                                  |
//+------------------------------------------------------------------+
void CSignalManager::RunDiagnostics() {
    Print("=== SIGNAL MANAGER DIAGNOSTICS ===");
    Print("Initialized: ", m_bInitialized ? "YES" : "NO");
    Print("Total Signals Generated: ", m_SignalCount);
    Print("Daily Signal Count: ", m_DailySignalCount);
    Print("Last Signal Direction: ", EnumToString(m_LastSignal.Direction));
    Print("Last Signal Confidence: ", m_LastSignal.Confidence);
    Print("Current Trend: ", GetCurrentTrend());
    Print("Current Volatility: ", GetCurrentVolatility());
    Print("Can Generate Signal: ", CanGenerateSignal() ? "YES" : "NO");
    Print("Buy Signals Enabled: ", m_Config.EnableBuySignals ? "YES" : "NO");
    Print("Sell Signals Enabled: ", m_Config.EnableSellSignals ? "YES" : "NO");
    Print("Min Confidence: ", m_Config.MinConfidence);
    Print("Min Risk/Reward: ", m_Config.MinRiskReward);
    Print("===================================");
}

//+------------------------------------------------------------------+
//| Update Configuration                                             |
//+------------------------------------------------------------------+
bool CSignalManager::UpdateConfiguration(EAContext* context) {
    if (context == NULL) return false;
    
    // Update configuration from context
    m_Config.MinConfidence = context.InputParams.ConfidenceThreshold;
    m_Config.MinRiskReward = context.InputParams.MinRiskReward;
    m_Config.UseTimeFilter = context.InputParams.UseTradingHours;
    m_Config.UseNewsFilter = context.InputParams.UseNewsFilter;
    
    return true;
}

//+------------------------------------------------------------------+
//| Get Signal Report                                                |
//+------------------------------------------------------------------+
string CSignalManager::GetSignalReport() {
    string report = "=== SIGNAL MANAGER REPORT ===\n";
    report += StringFormat("Total Signals: %d\n", m_SignalCount);
    report += StringFormat("Daily Signal Count: %d/%d\n", m_DailySignalCount, m_Config.MaxSignalsPerDay);
    report += StringFormat("Last Signal: %s\n", EnumToString(m_LastSignal.Direction));
    report += StringFormat("Last Signal Confidence: %.2f\n", m_LastSignal.Confidence);
    report += StringFormat("Current Trend: %.1f\n", GetCurrentTrend());
    report += StringFormat("Current Volatility: %.5f\n", GetCurrentVolatility());
    report += StringFormat("Can Generate Signal: %s\n", CanGenerateSignal() ? "YES" : "NO");
    
    if (m_LastSignal.IsValid) {
        report += StringFormat("\n=== LAST SIGNAL DETAILS ===\n");
        report += StringFormat("Direction: %s\n", EnumToString(m_LastSignal.Direction));
        report += StringFormat("Entry: %.5f\n", m_LastSignal.EntryPrice);
        report += StringFormat("Stop Loss: %.5f\n", m_LastSignal.StopLoss);
        report += StringFormat("Take Profit: %.5f\n", m_LastSignal.TakeProfit);
        report += StringFormat("Risk/Reward: %.2f\n", m_LastSignal.RiskReward);
        report += StringFormat("Reason: %s\n", m_LastSignal.Reason);
    }
    
    return report;
}

//+------------------------------------------------------------------+
//| Reset Signal History                                             |
//+------------------------------------------------------------------+
void CSignalManager::ResetSignalHistory() {
    m_SignalCount = 0;
    m_DailySignalCount = 0;
    m_LastSignalTime = 0;
    m_LastSignal.Reset();
    Print("[SIGNAL] Signal history reset");
}

#endif // SIGNAL_MANAGER_MQH 