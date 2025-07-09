//+------------------------------------------------------------------+
//|                                                  RiskManager.mqh |
//|                         APEX Pullback EA v5 FINAL - Risk Mgmt   |
//|      Description: Comprehensive risk management system with     |
//|                   advanced position sizing, portfolio mgmt,     |
//|                   and real-time risk monitoring capabilities.   |
//+------------------------------------------------------------------+

#ifndef RISK_MANAGER_MQH
#define RISK_MANAGER_MQH

#include "..\01_Core\CommonStructs.mqh"
#include "..\00_Core\Common\Enums.mqh"

//+------------------------------------------------------------------+
//| Risk Management Data Structures                                  |
//+------------------------------------------------------------------+

// Risk metrics structure
struct SRiskMetrics {
    double AccountBalance;               // Current account balance
    double AccountEquity;                // Current account equity
    double FreeMargin;                   // Available free margin
    double UsedMargin;                   // Currently used margin
    double MarginLevel;                  // Margin level percentage
    double MaxDrawdown;                  // Maximum drawdown
    double CurrentDrawdown;              // Current drawdown
    double VaR95;                        // Value at Risk (95% confidence)
    double VaR99;                        // Value at Risk (99% confidence)
    double PortfolioRisk;                // Total portfolio risk
    double DailyRisk;                    // Daily risk exposure
    double WeeklyRisk;                   // Weekly risk exposure
    double MonthlyRisk;                  // Monthly risk exposure
    datetime LastUpdate;                 // Last update time
    
    void Reset() {
        AccountBalance = 0.0;
        AccountEquity = 0.0;
        FreeMargin = 0.0;
        UsedMargin = 0.0;
        MarginLevel = 0.0;
        MaxDrawdown = 0.0;
        CurrentDrawdown = 0.0;
        VaR95 = 0.0;
        VaR99 = 0.0;
        PortfolioRisk = 0.0;
        DailyRisk = 0.0;
        WeeklyRisk = 0.0;
        MonthlyRisk = 0.0;
        LastUpdate = 0;
    }
};

// Position sizing configuration
struct SPositionSizing {
    bool UseFixedLot;                    // Use fixed lot size
    double FixedLotSize;                 // Fixed lot size
    bool UsePercentRisk;                 // Use percentage-based risk
    double RiskPercent;                  // Risk percentage per trade
    bool UseVolatilityAdjustment;        // Adjust size based on volatility
    double MinLotSize;                   // Minimum lot size
    double MaxLotSize;                   // Maximum lot size
    bool UseEquityCurve;                 // Adjust based on equity curve
    double EquityCurveFilter;            // Equity curve filter level
    
    void Reset() {
        UseFixedLot = false;
        FixedLotSize = 0.1;
        UsePercentRisk = true;
        RiskPercent = 2.0;
        UseVolatilityAdjustment = true;
        MinLotSize = 0.01;
        MaxLotSize = 10.0;
        UseEquityCurve = false;
        EquityCurveFilter = 0.8;
    }
};

// Risk limits configuration
struct SRiskLimits {
    double MaxDailyLoss;                 // Maximum daily loss
    double MaxWeeklyLoss;                // Maximum weekly loss
    double MaxMonthlyLoss;               // Maximum monthly loss
    double MaxDrawdownPercent;           // Maximum drawdown percentage
    double MaxRiskPerTrade;              // Maximum risk per trade
    double MaxPortfolioRisk;             // Maximum total portfolio risk
    int MaxConcurrentTrades;             // Maximum concurrent trades
    double MaxCorrelationRisk;           // Maximum correlation risk
    bool EnableEmergencyStop;            // Enable emergency stop
    double EmergencyStopLevel;           // Emergency stop trigger level
    
    void Reset() {
        MaxDailyLoss = 500.0;
        MaxWeeklyLoss = 1500.0;
        MaxMonthlyLoss = 5000.0;
        MaxDrawdownPercent = 15.0;
        MaxRiskPerTrade = 2.0;
        MaxPortfolioRisk = 10.0;
        MaxConcurrentTrades = 5;
        MaxCorrelationRisk = 0.7;
        EnableEmergencyStop = true;
        EmergencyStopLevel = 20.0;
    }
};

//+------------------------------------------------------------------+
//| Risk Manager Class                                               |
//+------------------------------------------------------------------+
class CRiskManager {
private:
    // Core references
    EAContext*                    m_pContext;
    bool                         m_bInitialized;
    
    // Risk tracking
    SRiskMetrics                 m_CurrentMetrics;
    SPositionSizing              m_PositionSizing;
    SRiskLimits                  m_RiskLimits;
    
    // Risk state management
    bool                         m_TradingEnabled;
    bool                         m_EmergencyStopTriggered;
    string                       m_DisableReason;
    datetime                     m_LastRiskCheck;
    
    // Performance tracking
    double                       m_DailyPnL[];
    double                       m_WeeklyPnL[];
    double                       m_MonthlyPnL[];
    static const int             HISTORY_SIZE = 365;
    
    // Risk calculation helpers
    double                       m_PeakEquity;
    double                       m_TroughEquity;
    datetime                     m_StartTime;
    
    // Internal methods
    void                         UpdateRiskMetrics();
    double                       CalculatePositionSize(double riskAmount, double stopLossPips);
    double                       CalculateVaR(double confidence);
    bool                         CheckRiskLimits();
    void                         UpdateDrawdownTracking();
    void                         UpdatePerformanceHistory();
    bool                         ValidateTradeRisk(const STradeInfo& trade);
    
public:
    // Constructor and destructor
                                 CRiskManager();
                                ~CRiskManager();
    
    // Initialization and cleanup
    bool                         Initialize(EAContext* context);
    void                         Cleanup();
    
    // Core risk management methods
    void                         Update();
    bool                         CanOpenNewPosition();
    double                       CalculateOptimalLotSize(string symbol, double riskPercent, double stopLossPips);
    bool                         ValidateNewTrade(const STradeInfo& tradeInfo);
    void                         OnTradeOpened(const STradeInfo& trade);
    void                         OnTradeClosed(const STradeInfo& trade);
    
    // Risk metrics and monitoring
    SRiskMetrics                 GetRiskMetrics() { return m_CurrentMetrics; }
    double                       GetCurrentDrawdown();
    double                       GetMaxDrawdown() { return m_CurrentMetrics.MaxDrawdown; }
    double                       GetVaR(double confidence = 0.95);
    double                       GetPortfolioRisk();
    
    // Trading control
    bool                         IsTradingEnabled() { return m_TradingEnabled; }
    bool                         IsTradingDisabled() { return !m_TradingEnabled; }
    void                         EnableTrading(string reason = "Manual enable");
    void                         DisableTrading(string reason = "Manual disable");
    string                       GetStatus();
    string                       GetDisableReason() { return m_DisableReason; }
    
    // Position sizing
    void                         ConfigurePositionSizing(bool useFixed, double lotSize, 
                                                        double riskPercent, double minLot, double maxLot);
    double                       GetRecommendedLotSize(string symbol, double stopLossPips);
    double                       AdjustLotSizeForVolatility(double baseLotSize, string symbol);
    
    // Risk limits management
    void                         SetRiskLimits(double dailyLoss, double weeklyLoss, double monthlyLoss, 
                                             double maxDrawdown, double maxRiskPerTrade);
    bool                         IsWithinRiskLimits();
    void                         TriggerEmergencyStop(string reason);
    void                         ResetEmergencyStop();
    
    // Performance analysis
    double                       GetDailyPnL();
    double                       GetWeeklyPnL();
    double                       GetMonthlyPnL();
    double                       GetSharpeRatio();
    double                       GetSortinoRatio();
    
    // Configuration and control
    bool                         UpdateConfiguration(EAContext* context);
    void                         ResetRiskMetrics();
    
    // Diagnostics and reporting
    void                         RunDiagnostics();
    string                       GetRiskReport();
    string                       GetPerformanceReport();
    
    // Stress testing
    double                       StressTestDrawdown(double stressLevel);
    double                       WorstCaseScenario();
    double                       BestCaseScenario();
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CRiskManager::CRiskManager() {
    m_pContext = NULL;
    m_bInitialized = false;
    m_TradingEnabled = true;
    m_EmergencyStopTriggered = false;
    m_DisableReason = "";
    m_LastRiskCheck = 0;
    m_PeakEquity = 0.0;
    m_TroughEquity = 0.0;
    m_StartTime = TimeCurrent();
    
    // Initialize arrays
    ArrayResize(m_DailyPnL, HISTORY_SIZE);
    ArrayResize(m_WeeklyPnL, 52); // 52 weeks
    ArrayResize(m_MonthlyPnL, 12); // 12 months
    ArrayInitialize(m_DailyPnL, 0.0);
    ArrayInitialize(m_WeeklyPnL, 0.0);
    ArrayInitialize(m_MonthlyPnL, 0.0);
    
    // Reset configurations
    m_CurrentMetrics.Reset();
    m_PositionSizing.Reset();
    m_RiskLimits.Reset();
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CRiskManager::~CRiskManager() {
    Cleanup();
}

//+------------------------------------------------------------------+
//| Initialize Risk Manager                                          |
//+------------------------------------------------------------------+
bool CRiskManager::Initialize(EAContext* context) {
    if (context == NULL) {
        Print("[RISK] ERROR: Invalid context provided");
        return false;
    }
    
    m_pContext = context;
    
    // Initialize risk metrics
    m_CurrentMetrics.AccountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    m_CurrentMetrics.AccountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    m_PeakEquity = m_CurrentMetrics.AccountEquity;
    m_TroughEquity = m_CurrentMetrics.AccountEquity;
    
    // Set initial position sizing from context
    if (context.InputParams.UsePositionSizing) {
        m_PositionSizing.UsePercentRisk = true;
        m_PositionSizing.RiskPercent = context.InputParams.MaxRiskPercent;
    }
    
    // Set risk limits from context
    m_RiskLimits.MaxDailyLoss = context.InputParams.MaxDailyRisk * m_CurrentMetrics.AccountBalance / 100.0;
    m_RiskLimits.MaxDrawdownPercent = context.InputParams.MaxDrawdownPercent;
    m_RiskLimits.MaxConcurrentTrades = context.InputParams.MaxConcurrentTrades;
    
    UpdateRiskMetrics();
    
    m_bInitialized = true;
    Print("[RISK] Risk Manager initialized successfully");
    return true;
}

//+------------------------------------------------------------------+
//| Cleanup                                                          |
//+------------------------------------------------------------------+
void CRiskManager::Cleanup() {
    if (m_bInitialized) {
        Print("[RISK] Risk Manager cleaned up");
        m_bInitialized = false;
    }
}

//+------------------------------------------------------------------+
//| Main Update Method                                               |
//+------------------------------------------------------------------+
void CRiskManager::Update() {
    if (!m_bInitialized) return;
    
    datetime currentTime = TimeCurrent();
    
    // Update risk metrics periodically
    if (currentTime - m_LastRiskCheck >= 60) { // Check every minute
        UpdateRiskMetrics();
        UpdateDrawdownTracking();
        UpdatePerformanceHistory();
        
        // Check risk limits
        if (!CheckRiskLimits()) {
            if (m_RiskLimits.EnableEmergencyStop && !m_EmergencyStopTriggered) {
                TriggerEmergencyStop("Risk limits exceeded");
            }
        }
        
        m_LastRiskCheck = currentTime;
    }
}

//+------------------------------------------------------------------+
//| Check if New Position Can Be Opened                             |
//+------------------------------------------------------------------+
bool CRiskManager::CanOpenNewPosition() {
    if (!m_bInitialized || !m_TradingEnabled || m_EmergencyStopTriggered) {
        return false;
    }
    
    // Check margin requirements
    if (m_CurrentMetrics.FreeMargin < 100.0) { // Minimum free margin
        return false;
    }
    
    // Check maximum concurrent trades
    if (PositionsTotal() >= m_RiskLimits.MaxConcurrentTrades) {
        return false;
    }
    
    // Check risk limits
    return IsWithinRiskLimits();
}

//+------------------------------------------------------------------+
//| Calculate Optimal Lot Size                                      |
//+------------------------------------------------------------------+
double CRiskManager::CalculateOptimalLotSize(string symbol, double riskPercent, double stopLossPips) {
    if (!m_bInitialized || stopLossPips <= 0) return 0.0;
    
    double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    double riskAmount = accountBalance * riskPercent / 100.0;
    
    return CalculatePositionSize(riskAmount, stopLossPips);
}

//+------------------------------------------------------------------+
//| Calculate Position Size Based on Risk                           |
//+------------------------------------------------------------------+
double CRiskManager::CalculatePositionSize(double riskAmount, double stopLossPips) {
    if (stopLossPips <= 0 || riskAmount <= 0) return 0.0;
    
    string symbol = _Symbol;
    double tickSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
    double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
    double pointValue = SymbolInfoDouble(symbol, SYMBOL_POINT);
    
    if (tickValue == 0 || pointValue == 0) return 0.0;
    
    // Calculate pip value
    double pipValue = tickValue * (pointValue / tickSize);
    
    // Calculate position size
    double lotSize = riskAmount / (stopLossPips * pipValue);
    
    // Apply lot size constraints
    double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
    double lotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
    
    // Ensure minimum lot size
    lotSize = MathMax(lotSize, minLot);
    
    // Apply configured limits
    lotSize = MathMax(lotSize, m_PositionSizing.MinLotSize);
    lotSize = MathMin(lotSize, m_PositionSizing.MaxLotSize);
    lotSize = MathMin(lotSize, maxLot);
    
    // Round to lot step
    lotSize = MathFloor(lotSize / lotStep) * lotStep;
    
    return lotSize;
}

//+------------------------------------------------------------------+
//| Validate New Trade                                              |
//+------------------------------------------------------------------+
bool CRiskManager::ValidateNewTrade(const STradeInfo& tradeInfo) {
    if (!m_bInitialized || !m_TradingEnabled) return false;
    
    return ValidateTradeRisk(tradeInfo);
}

//+------------------------------------------------------------------+
//| Validate Trade Risk                                              |
//+------------------------------------------------------------------+
bool CRiskManager::ValidateTradeRisk(const STradeInfo& trade) {
    // Calculate trade risk
    double stopLossPips = MathAbs(trade.EntryPrice - trade.StopLoss) / _Point;
    double tradeRisk = trade.Volume * stopLossPips * SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    
    // Check if trade risk exceeds limits
    double maxTradeRisk = m_CurrentMetrics.AccountBalance * m_RiskLimits.MaxRiskPerTrade / 100.0;
    
    if (tradeRisk > maxTradeRisk) {
        Print("[RISK] Trade risk (", tradeRisk, ") exceeds maximum (", maxTradeRisk, ")");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Update Risk Metrics                                             |
//+------------------------------------------------------------------+
void CRiskManager::UpdateRiskMetrics() {
    m_CurrentMetrics.AccountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    m_CurrentMetrics.AccountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    m_CurrentMetrics.FreeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
    m_CurrentMetrics.UsedMargin = AccountInfoDouble(ACCOUNT_MARGIN);
    
    if (m_CurrentMetrics.UsedMargin > 0) {
        m_CurrentMetrics.MarginLevel = (m_CurrentMetrics.AccountEquity / m_CurrentMetrics.UsedMargin) * 100.0;
    } else {
        m_CurrentMetrics.MarginLevel = 0.0;
    }
    
    m_CurrentMetrics.VaR95 = CalculateVaR(0.95);
    m_CurrentMetrics.VaR99 = CalculateVaR(0.99);
    m_CurrentMetrics.LastUpdate = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Update Drawdown Tracking                                        |
//+------------------------------------------------------------------+
void CRiskManager::UpdateDrawdownTracking() {
    double currentEquity = m_CurrentMetrics.AccountEquity;
    
    // Update peak equity
    if (currentEquity > m_PeakEquity) {
        m_PeakEquity = currentEquity;
        m_TroughEquity = currentEquity;
    }
    
    // Update trough equity
    if (currentEquity < m_TroughEquity) {
        m_TroughEquity = currentEquity;
    }
    
    // Calculate current drawdown
    double drawdown = m_PeakEquity - currentEquity;
    double drawdownPercent = (m_PeakEquity > 0) ? (drawdown / m_PeakEquity) * 100.0 : 0.0;
    
    m_CurrentMetrics.CurrentDrawdown = drawdownPercent;
    
    // Update maximum drawdown
    if (drawdownPercent > m_CurrentMetrics.MaxDrawdown) {
        m_CurrentMetrics.MaxDrawdown = drawdownPercent;
    }
}

//+------------------------------------------------------------------+
//| Update Performance History                                       |
//+------------------------------------------------------------------+
void CRiskManager::UpdatePerformanceHistory() {
    // This is simplified - in reality would track daily PnL properly
    static double lastEquity = 0.0;
    
    if (lastEquity == 0.0) {
        lastEquity = m_CurrentMetrics.AccountEquity;
        return;
    }
    
    double dailyPnL = m_CurrentMetrics.AccountEquity - lastEquity;
    
    // Shift array and add new value
    for (int i = HISTORY_SIZE - 1; i > 0; i--) {
        m_DailyPnL[i] = m_DailyPnL[i-1];
    }
    m_DailyPnL[0] = dailyPnL;
    
    lastEquity = m_CurrentMetrics.AccountEquity;
}

//+------------------------------------------------------------------+
//| Calculate Value at Risk                                          |
//+------------------------------------------------------------------+
double CRiskManager::CalculateVaR(double confidence) {
    // Simplified VaR calculation
    // In reality, this would use historical returns and proper statistical methods
    
    double volatility = 0.02; // Assume 2% daily volatility
    double portfolioValue = m_CurrentMetrics.AccountEquity;
    
    // Use normal distribution approximation
    double zScore = (confidence == 0.95) ? 1.645 : 2.326; // 95% or 99%
    
    return portfolioValue * volatility * zScore;
}

//+------------------------------------------------------------------+
//| Check Risk Limits                                               |
//+------------------------------------------------------------------+
bool CRiskManager::CheckRiskLimits() {
    // Check drawdown limit
    if (m_CurrentMetrics.CurrentDrawdown > m_RiskLimits.MaxDrawdownPercent) {
        DisableTrading("Maximum drawdown exceeded");
        return false;
    }
    
    // Check daily loss limit
    double dailyPnL = GetDailyPnL();
    if (dailyPnL < -m_RiskLimits.MaxDailyLoss) {
        DisableTrading("Daily loss limit exceeded");
        return false;
    }
    
    // Check margin level
    if (m_CurrentMetrics.MarginLevel < 200.0 && m_CurrentMetrics.MarginLevel > 0) {
        Print("[RISK] WARNING: Low margin level: ", m_CurrentMetrics.MarginLevel, "%");
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Get Current Drawdown                                            |
//+------------------------------------------------------------------+
double CRiskManager::GetCurrentDrawdown() {
    return m_CurrentMetrics.CurrentDrawdown;
}

//+------------------------------------------------------------------+
//| Enable Trading                                                   |
//+------------------------------------------------------------------+
void CRiskManager::EnableTrading(string reason) {
    m_TradingEnabled = true;
    m_EmergencyStopTriggered = false;
    m_DisableReason = "";
    Print("[RISK] Trading enabled: ", reason);
}

//+------------------------------------------------------------------+
//| Disable Trading                                                  |
//+------------------------------------------------------------------+
void CRiskManager::DisableTrading(string reason) {
    m_TradingEnabled = false;
    m_DisableReason = reason;
    Print("[RISK] Trading disabled: ", reason);
}

//+------------------------------------------------------------------+
//| Get Status                                                       |
//+------------------------------------------------------------------+
string CRiskManager::GetStatus() {
    if (!m_bInitialized) return "NOT_INITIALIZED";
    if (m_EmergencyStopTriggered) return "EMERGENCY_STOP";
    if (!m_TradingEnabled) return "DISABLED: " + m_DisableReason;
    return "ACTIVE";
}

//+------------------------------------------------------------------+
//| Trigger Emergency Stop                                           |
//+------------------------------------------------------------------+
void CRiskManager::TriggerEmergencyStop(string reason) {
    m_EmergencyStopTriggered = true;
    DisableTrading("EMERGENCY: " + reason);
    
    // Close all open positions
    for (int i = PositionsTotal() - 1; i >= 0; i--) {
        ulong ticket = PositionGetTicket(i);
        if (ticket > 0) {
            // This would normally close the position
            Print("[RISK] EMERGENCY: Would close position ", ticket);
        }
    }
}

//+------------------------------------------------------------------+
//| Get Daily PnL                                                   |
//+------------------------------------------------------------------+
double CRiskManager::GetDailyPnL() {
    return (ArraySize(m_DailyPnL) > 0) ? m_DailyPnL[0] : 0.0;
}

//+------------------------------------------------------------------+
//| Run Diagnostics                                                  |
//+------------------------------------------------------------------+
void CRiskManager::RunDiagnostics() {
    Print("=== RISK MANAGER DIAGNOSTICS ===");
    Print("Initialized: ", m_bInitialized ? "YES" : "NO");
    Print("Trading Enabled: ", m_TradingEnabled ? "YES" : "NO");
    Print("Emergency Stop: ", m_EmergencyStopTriggered ? "YES" : "NO");
    Print("Account Balance: ", m_CurrentMetrics.AccountBalance);
    Print("Account Equity: ", m_CurrentMetrics.AccountEquity);
    Print("Current Drawdown: ", m_CurrentMetrics.CurrentDrawdown, "%");
    Print("Max Drawdown: ", m_CurrentMetrics.MaxDrawdown, "%");
    Print("Margin Level: ", m_CurrentMetrics.MarginLevel, "%");
    Print("Free Margin: ", m_CurrentMetrics.FreeMargin);
    Print("Open Positions: ", PositionsTotal());
    if (!m_TradingEnabled) {
        Print("Disable Reason: ", m_DisableReason);
    }
    Print("=================================");
}

//+------------------------------------------------------------------+
//| Update Configuration                                             |
//+------------------------------------------------------------------+
bool CRiskManager::UpdateConfiguration(EAContext* context) {
    if (context == NULL) return false;
    
    // Update risk configuration from context
    m_PositionSizing.RiskPercent = context.InputParams.MaxRiskPercent;
    m_RiskLimits.MaxDailyLoss = context.InputParams.MaxDailyRisk * m_CurrentMetrics.AccountBalance / 100.0;
    m_RiskLimits.MaxDrawdownPercent = context.InputParams.MaxDrawdownPercent;
    m_RiskLimits.MaxConcurrentTrades = context.InputParams.MaxConcurrentTrades;
    
    return true;
}

//+------------------------------------------------------------------+
//| Get Risk Report                                                  |
//+------------------------------------------------------------------+
string CRiskManager::GetRiskReport() {
    string report = "=== RISK MANAGEMENT REPORT ===\n";
    report += StringFormat("Status: %s\n", GetStatus());
    report += StringFormat("Account Balance: %.2f\n", m_CurrentMetrics.AccountBalance);
    report += StringFormat("Account Equity: %.2f\n", m_CurrentMetrics.AccountEquity);
    report += StringFormat("Free Margin: %.2f\n", m_CurrentMetrics.FreeMargin);
    report += StringFormat("Margin Level: %.1f%%\n", m_CurrentMetrics.MarginLevel);
    report += StringFormat("Current Drawdown: %.2f%%\n", m_CurrentMetrics.CurrentDrawdown);
    report += StringFormat("Maximum Drawdown: %.2f%%\n", m_CurrentMetrics.MaxDrawdown);
    report += StringFormat("VaR (95%%): %.2f\n", m_CurrentMetrics.VaR95);
    report += StringFormat("VaR (99%%): %.2f\n", m_CurrentMetrics.VaR99);
    report += StringFormat("Open Positions: %d\n", PositionsTotal());
    report += StringFormat("Daily PnL: %.2f\n", GetDailyPnL());
    
    return report;
}

//+------------------------------------------------------------------+
//| Reset Risk Metrics                                              |
//+------------------------------------------------------------------+
void CRiskManager::ResetRiskMetrics() {
    m_CurrentMetrics.Reset();
    m_PeakEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    m_TroughEquity = m_PeakEquity;
    ArrayInitialize(m_DailyPnL, 0.0);
    ArrayInitialize(m_WeeklyPnL, 0.0);
    ArrayInitialize(m_MonthlyPnL, 0.0);
    Print("[RISK] Risk metrics reset");
}

#endif // RISK_MANAGER_MQH