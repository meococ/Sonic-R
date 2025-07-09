//+------------------------------------------------------------------+
//|                                             BrokerInterface.mqh |
//|               BrokerInterface.mqh - APEX Pullback EA v5 FINAL   |
//|      Description: Comprehensive broker interface with health    |
//|                   monitoring, connection management, and        |
//|                   execution quality tracking.                   |
//+------------------------------------------------------------------+

#ifndef BROKER_INTERFACE_MQH_
#define BROKER_INTERFACE_MQH_

#include "..\..\00_Core\CommonStructs.mqh"

namespace ApexPullback::v5 {

//+------------------------------------------------------------------+
//| Broker Connection Statistics                                     |
//+------------------------------------------------------------------+
struct SBrokerConnectionStats {
    datetime              LastConnectionCheck;  // Last connection check time
    int                   ConnectionAttempts;   // Number of connection attempts
    int                   SuccessfulConnections; // Successful connections
    int                   FailedConnections;    // Failed connections
    double                AverageLatency;       // Average latency in ms
    datetime              LastDisconnection;    // Last disconnection time
    int                   DisconnectionCount;   // Total disconnections
    bool                  IsStable;             // Connection stability flag
};

//+------------------------------------------------------------------+
//| Execution Quality Statistics                                     |
//+------------------------------------------------------------------+
struct SExecutionQuality {
    int                   TotalOrders;          // Total orders sent
    int                   SuccessfulOrders;     // Successfully executed orders
    int                   RejectedOrders;       // Rejected orders
    int                   RequoteCount;         // Number of requotes
    double                AverageSlippage;      // Average slippage in points
    double                MaxSlippage;          // Maximum slippage observed
    double                AverageExecutionTime; // Average execution time in ms
    double                SuccessRate;          // Success rate percentage
    datetime              LastOrderTime;        // Last order timestamp
};

//+------------------------------------------------------------------+
//| Broker Information Structure                                     |
//+------------------------------------------------------------------+
struct SBrokerInfo {
    string                BrokerName;           // Broker company name
    string                ServerName;           // Server name
    int                   Leverage;             // Account leverage
    double                StopLevel;            // Stop level in points
    double                FreezeLevel;          // Freeze level in points
    ENUM_ACCOUNT_TRADE_MODE TradeMode;          // Trade mode
    bool                  IsECN;                // ECN broker flag
    bool                  AllowsHedging;        // Hedging allowed
    bool                  AllowsScalping;       // Scalping allowed
    double                MinLot;               // Minimum lot size
    double                MaxLot;               // Maximum lot size
    double                LotStep;              // Lot step
    int                   MaxPositions;         // Maximum positions
};

//+------------------------------------------------------------------+
//| Spread Statistics                                                |
//+------------------------------------------------------------------+
struct SSpreadStats {
    double                CurrentSpread;        // Current spread in points
    double                AverageSpread;        // Average spread
    double                MinSpread;            // Minimum spread observed
    double                MaxSpread;            // Maximum spread observed
    datetime              LastSpreadUpdate;     // Last spread update time
    bool                  IsSpreadNormal;       // Spread within normal range
    double                SpreadThreshold;      // Spread threshold for trading
};

//+------------------------------------------------------------------+
//| CBrokerInterface - Comprehensive Broker Management              |
//+------------------------------------------------------------------+
class CBrokerInterface {
private:
    EAContext*            m_pContext;           // Reference to EA context
    bool                  m_bInitialized;      // Initialization status
    
    // Broker information and statistics
    SBrokerInfo           m_BrokerInfo;         // Broker information
    SBrokerConnectionStats m_ConnectionStats;  // Connection statistics
    SExecutionQuality     m_ExecutionStats;    // Execution quality stats
    SSpreadStats          m_SpreadStats;       // Spread statistics
    
    // Monitoring settings
    datetime              m_LastHealthCheck;   // Last health check time
    datetime              m_LastSpreadCheck;   // Last spread check time
    int                   m_HealthCheckInterval; // Health check interval in seconds
    
    // Quality thresholds
    static const double   MAX_ACCEPTABLE_SLIPPAGE;
    static const double   MIN_SUCCESS_RATE;
    static const int      MAX_LATENCY_MS;
    static const double   MAX_SPREAD_MULTIPLIER;
    
public:
    //--- Constructor/Destructor ---
    CBrokerInterface(EAContext* context);
    ~CBrokerInterface();
    
    //--- Core Methods ---
    bool                  Initialize();
    void                  Deinitialize();
    bool                  IsInitialized() const { return m_bInitialized; }
    void                  Update();
    
    //--- Connection Management ---
    bool                  IsConnected();
    bool                  CheckConnection();
    bool                  TestConnection();
    double                GetLatency();
    ENUM_BROKER_HEALTH    GetConnectionHealth();
    
    //--- Broker Information ---
    SBrokerInfo           GetBrokerInfo() const { return m_BrokerInfo; }
    string                GetBrokerName();
    string                GetServerName();
    bool                  IsECNBroker();
    bool                  SupportsHedging();
    
    //--- Execution Quality ---
    bool                  RecordOrderExecution(const bool success, const double slippage, const int execution_time);
    SExecutionQuality     GetExecutionStats() const { return m_ExecutionStats; }
    double                GetAverageSlippage();
    double                GetSuccessRate();
    bool                  IsExecutionQualityGood();
    
    //--- Spread Management ---
    double                GetCurrentSpread(const string& symbol = "");
    double                GetAverageSpread();
    bool                  IsSpreadAcceptable(const string& symbol = "");
    void                  UpdateSpreadStats();
    
    //--- Trading Conditions ---
    bool                  IsTradingAllowed();
    bool                  CanOpenPosition(const string& symbol, const double lot_size);
    bool                  CanClosePosition(const ulong ticket);
    double                GetMinLotSize();
    double                GetMaxLotSize();
    double                NormalizeLotSize(const double lot_size);
    
    //--- Health Monitoring ---
    ENUM_BROKER_HEALTH    GetOverallHealth();
    bool                  PerformHealthCheck();
    string                GetHealthReport();
    bool                  ShouldReduceTrading();
    
    //--- Statistics ---
    string                GetConnectionSummary();
    string                GetExecutionSummary();
    string                GetSpreadSummary();
    
private:
    //--- Internal Methods ---
    void                  LoadBrokerInfo();
    void                  UpdateConnectionStats();
    void                  UpdateExecutionStats();
    bool                  ValidateBrokerSettings();
    void                  CheckTradingConditions();
    double                CalculateLatency();
    bool                  IsConnectionStable();
    void                  LogBrokerEvent(const string& event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO);
    void                  ResetStatistics();
};

// Static constants definition
const double CBrokerInterface::MAX_ACCEPTABLE_SLIPPAGE = 5.0;  // 5 points
const double CBrokerInterface::MIN_SUCCESS_RATE = 95.0;        // 95%
const int CBrokerInterface::MAX_LATENCY_MS = 1000;             // 1 second
const double CBrokerInterface::MAX_SPREAD_MULTIPLIER = 3.0;    // 3x normal spread

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CBrokerInterface::CBrokerInterface(EAContext* context) {
    m_pContext = context;
    m_bInitialized = false;
    m_LastHealthCheck = 0;
    m_LastSpreadCheck = 0;
    m_HealthCheckInterval = 60; // 1 minute
    
    // Initialize statistics
    ZeroMemory(m_ConnectionStats);
    ZeroMemory(m_ExecutionStats);
    ZeroMemory(m_SpreadStats);
    ZeroMemory(m_BrokerInfo);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CBrokerInterface::~CBrokerInterface() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CBrokerInterface::Initialize() {
    if (m_bInitialized) {
        return true;
    }
    
    if (m_pContext == NULL) {
        Print("[BROKER_INTERFACE] Context is NULL");
        return false;
    }
    
    // Load broker information
    LoadBrokerInfo();
    
    // Validate broker settings
    if (!ValidateBrokerSettings()) {
        if (m_pContext.pLogger != NULL) {
            m_pContext.pLogger.LogError("Broker settings validation failed", __FUNCTION__);
        }
        return false;
    }
    
    // Initialize spread statistics
    m_SpreadStats.SpreadThreshold = 3.0; // Default threshold
    UpdateSpreadStats();
    
    // Perform initial health check
    if (!PerformHealthCheck()) {
        if (m_pContext.pLogger != NULL) {
            m_pContext.pLogger.LogWarning("Initial broker health check failed", __FUNCTION__);
        }
    }
    
    m_bInitialized = true;
    
    if (m_pContext.pLogger != NULL) {
        m_pContext.pLogger.LogInfo("BrokerInterface initialized successfully", __FUNCTION__);
        m_pContext.pLogger.LogInfo(GetConnectionSummary(), __FUNCTION__);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CBrokerInterface::Deinitialize() {
    if (!m_bInitialized) {
        return;
    }
    
    if (m_pContext != NULL && m_pContext.pLogger != NULL) {
        m_pContext.pLogger.LogInfo(GetExecutionSummary(), __FUNCTION__);
        m_pContext.pLogger.LogInfo("BrokerInterface shutting down", __FUNCTION__);
    }
    
    m_bInitialized = false;
}

//+------------------------------------------------------------------+
//| Update                                                           |
//+------------------------------------------------------------------+
void CBrokerInterface::Update() {
    if (!m_bInitialized) {
        return;
    }
    
    datetime current_time = TimeCurrent();
    
    // Perform health check
    if (current_time - m_LastHealthCheck >= m_HealthCheckInterval) {
        PerformHealthCheck();
        m_LastHealthCheck = current_time;
    }
    
    // Update spread statistics
    if (current_time - m_LastSpreadCheck >= 10) { // Every 10 seconds
        UpdateSpreadStats();
        m_LastSpreadCheck = current_time;
    }
    
    // Update connection statistics
    UpdateConnectionStats();
}

//+------------------------------------------------------------------+
//| Is Connected                                                     |
//+------------------------------------------------------------------+
bool CBrokerInterface::IsConnected() {
    return TerminalInfoInteger(TERMINAL_CONNECTED);
}

//+------------------------------------------------------------------+
//| Check Connection                                                 |
//+------------------------------------------------------------------+
bool CBrokerInterface::CheckConnection() {
    if (!m_bInitialized) {
        return false;
    }
    
    bool connected = IsConnected();
    
    if (connected) {
        m_ConnectionStats.SuccessfulConnections++;
    } else {
        m_ConnectionStats.FailedConnections++;
        m_ConnectionStats.LastDisconnection = TimeCurrent();
        m_ConnectionStats.DisconnectionCount++;
        
        LogBrokerEvent("Connection lost", LOG_LEVEL_WARNING);
    }
    
    m_ConnectionStats.LastConnectionCheck = TimeCurrent();
    return connected;
}

//+------------------------------------------------------------------+
//| Test Connection                                                  |
//+------------------------------------------------------------------+
bool CBrokerInterface::TestConnection() {
    if (!IsConnected()) {
        return false;
    }
    
    // Test by requesting account information
    double balance = AccountInfoDouble(ACCOUNT_BALANCE);
    if (balance <= 0) {
        return false;
    }
    
    // Test by requesting symbol information
    double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    
    return (bid > 0 && ask > 0 && ask > bid);
}

//+------------------------------------------------------------------+
//| Get Latency                                                      |
//+------------------------------------------------------------------+
double CBrokerInterface::GetLatency() {
    return CalculateLatency();
}

//+------------------------------------------------------------------+
//| Get Connection Health                                             |
//+------------------------------------------------------------------+
ENUM_BROKER_HEALTH CBrokerInterface::GetConnectionHealth() {
    if (!IsConnected()) {
        return BROKER_HEALTH_POOR;
    }
    
    double latency = GetLatency();
    bool stable = IsConnectionStable();
    
    if (latency > MAX_LATENCY_MS || !stable) {
        return BROKER_HEALTH_POOR;
    } else if (latency > MAX_LATENCY_MS / 2) {
        return BROKER_HEALTH_FAIR;
    } else {
        return BROKER_HEALTH_GOOD;
    }
}

//+------------------------------------------------------------------+
//| Get Broker Name                                                  |
//+------------------------------------------------------------------+
string CBrokerInterface::GetBrokerName() {
    return m_BrokerInfo.BrokerName;
}

//+------------------------------------------------------------------+
//| Get Server Name                                                  |
//+------------------------------------------------------------------+
string CBrokerInterface::GetServerName() {
    return m_BrokerInfo.ServerName;
}

//+------------------------------------------------------------------+
//| Record Order Execution                                           |
//+------------------------------------------------------------------+
bool CBrokerInterface::RecordOrderExecution(const bool success, const double slippage, const int execution_time) {
    if (!m_bInitialized) {
        return false;
    }
    
    m_ExecutionStats.TotalOrders++;
    
    if (success) {
        m_ExecutionStats.SuccessfulOrders++;
    } else {
        m_ExecutionStats.RejectedOrders++;
    }
    
    // Update slippage statistics
    if (slippage >= 0) {
        m_ExecutionStats.AverageSlippage = 
            (m_ExecutionStats.AverageSlippage * (m_ExecutionStats.TotalOrders - 1) + slippage) / m_ExecutionStats.TotalOrders;
        
        if (slippage > m_ExecutionStats.MaxSlippage) {
            m_ExecutionStats.MaxSlippage = slippage;
        }
    }
    
    // Update execution time
    if (execution_time > 0) {
        m_ExecutionStats.AverageExecutionTime = 
            (m_ExecutionStats.AverageExecutionTime * (m_ExecutionStats.TotalOrders - 1) + execution_time) / m_ExecutionStats.TotalOrders;
    }
    
    // Calculate success rate
    m_ExecutionStats.SuccessRate = 
        (m_ExecutionStats.TotalOrders > 0) ? 
        (double)m_ExecutionStats.SuccessfulOrders / m_ExecutionStats.TotalOrders * 100.0 : 0.0;
    
    m_ExecutionStats.LastOrderTime = TimeCurrent();
    
    return true;
}

//+------------------------------------------------------------------+
//| Get Current Spread                                               |
//+------------------------------------------------------------------+
double CBrokerInterface::GetCurrentSpread(const string& symbol = "") {
    string sym = (symbol == "") ? _Symbol : symbol;
    
    double bid = SymbolInfoDouble(sym, SYMBOL_BID);
    double ask = SymbolInfoDouble(sym, SYMBOL_ASK);
    
    if (bid <= 0 || ask <= 0) {
        return -1; // Invalid data
    }
    
    int digits = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
    double point = SymbolInfoDouble(sym, SYMBOL_POINT);
    
    return (ask - bid) / point;
}

//+------------------------------------------------------------------+
//| Is Spread Acceptable                                             |
//+------------------------------------------------------------------+
bool CBrokerInterface::IsSpreadAcceptable(const string& symbol = "") {
    double current_spread = GetCurrentSpread(symbol);
    
    if (current_spread < 0) {
        return false; // Invalid spread data
    }
    
    return current_spread <= m_SpreadStats.SpreadThreshold;
}

//+------------------------------------------------------------------+
//| Is Trading Allowed                                               |
//+------------------------------------------------------------------+
bool CBrokerInterface::IsTradingAllowed() {
    if (!IsConnected()) {
        return false;
    }
    
    // Check if trading is allowed for the account
    if (!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)) {
        return false;
    }
    
    // Check if trading is allowed for the symbol
    if (!SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE)) {
        return false;
    }
    
    // Check market status
    if (!SymbolInfoInteger(_Symbol, SYMBOL_TRADE_CALC_MODE)) {
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Can Open Position                                                |
//+------------------------------------------------------------------+
bool CBrokerInterface::CanOpenPosition(const string& symbol, const double lot_size) {
    if (!IsTradingAllowed()) {
        return false;
    }
    
    // Check lot size
    double min_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
    double max_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
    
    if (lot_size < min_lot || lot_size > max_lot) {
        return false;
    }
    
    // Check free margin
    double required_margin = 0;
    if (!OrderCalcMargin(ORDER_TYPE_BUY, symbol, lot_size, SymbolInfoDouble(symbol, SYMBOL_ASK), required_margin)) {
        return false;
    }
    
    double free_margin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
    return free_margin >= required_margin;
}

//+------------------------------------------------------------------+
//| Normalize Lot Size                                               |
//+------------------------------------------------------------------+
double CBrokerInterface::NormalizeLotSize(const double lot_size) {
    double min_lot = m_BrokerInfo.MinLot;
    double max_lot = m_BrokerInfo.MaxLot;
    double lot_step = m_BrokerInfo.LotStep;
    
    double normalized = lot_size;
    
    // Ensure within bounds
    if (normalized < min_lot) {
        normalized = min_lot;
    } else if (normalized > max_lot) {
        normalized = max_lot;
    }
    
    // Round to lot step
    if (lot_step > 0) {
        normalized = MathRound(normalized / lot_step) * lot_step;
    }
    
    return normalized;
}

//+------------------------------------------------------------------+
//| Get Overall Health                                               |
//+------------------------------------------------------------------+
ENUM_BROKER_HEALTH CBrokerInterface::GetOverallHealth() {
    ENUM_BROKER_HEALTH connection_health = GetConnectionHealth();
    bool execution_good = IsExecutionQualityGood();
    bool spread_ok = IsSpreadAcceptable();
    
    if (connection_health == BROKER_HEALTH_POOR || !execution_good || !spread_ok) {
        return BROKER_HEALTH_POOR;
    } else if (connection_health == BROKER_HEALTH_FAIR) {
        return BROKER_HEALTH_FAIR;
    } else {
        return BROKER_HEALTH_GOOD;
    }
}

//+------------------------------------------------------------------+
//| Perform Health Check                                             |
//+------------------------------------------------------------------+
bool CBrokerInterface::PerformHealthCheck() {
    if (!m_bInitialized) {
        return false;
    }
    
    bool overall_health = true;
    
    // Check connection
    if (!CheckConnection()) {
        LogBrokerEvent("Health check: Connection failed", LOG_LEVEL_ERROR);
        overall_health = false;
    }
    
    // Test connection quality
    if (!TestConnection()) {
        LogBrokerEvent("Health check: Connection test failed", LOG_LEVEL_WARNING);
        overall_health = false;
    }
    
    // Check execution quality
    if (!IsExecutionQualityGood()) {
        LogBrokerEvent("Health check: Poor execution quality", LOG_LEVEL_WARNING);
        overall_health = false;
    }
    
    // Check spread
    if (!IsSpreadAcceptable()) {
        LogBrokerEvent(StringFormat("Health check: High spread %.1f", GetCurrentSpread()), LOG_LEVEL_WARNING);
        overall_health = false;
    }
    
    // Update context
    if (m_pContext != NULL) {
        m_pContext.MarketState.BrokerHealth = GetOverallHealth();
    }
    
    return overall_health;
}

//+------------------------------------------------------------------+
//| Internal Methods                                                 |
//+------------------------------------------------------------------+
void CBrokerInterface::LoadBrokerInfo() {
    m_BrokerInfo.BrokerName = AccountInfoString(ACCOUNT_COMPANY);
    m_BrokerInfo.ServerName = AccountInfoString(ACCOUNT_SERVER);
    m_BrokerInfo.Leverage = (int)AccountInfoInteger(ACCOUNT_LEVERAGE);
    m_BrokerInfo.TradeMode = (ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);
    
    // Symbol-specific information
    m_BrokerInfo.StopLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
    m_BrokerInfo.FreezeLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL);
    m_BrokerInfo.MinLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    m_BrokerInfo.MaxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
    m_BrokerInfo.LotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
    
    // Determine broker type
    m_BrokerInfo.IsECN = (m_BrokerInfo.TradeMode == ACCOUNT_TRADE_MODE_DEMO || 
                          m_BrokerInfo.TradeMode == ACCOUNT_TRADE_MODE_REAL);
    m_BrokerInfo.AllowsHedging = AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE) != ACCOUNT_STOPOUT_MODE_PERCENT;
    m_BrokerInfo.AllowsScalping = true; // Assume true unless proven otherwise
}

void CBrokerInterface::UpdateConnectionStats() {
    m_ConnectionStats.IsStable = IsConnectionStable();
    m_ConnectionStats.AverageLatency = CalculateLatency();
}

bool CBrokerInterface::IsConnectionStable() {
    // Consider connection stable if no disconnections in last 5 minutes
    return (TimeCurrent() - m_ConnectionStats.LastDisconnection) > 300;
}

double CBrokerInterface::CalculateLatency() {
    // Simple latency estimation based on tick reception
    static datetime last_tick_time = 0;
    datetime current_time = TimeCurrent();
    
    if (last_tick_time > 0) {
        double latency = (current_time - last_tick_time) * 1000.0; // Convert to milliseconds
        last_tick_time = current_time;
        return MathMin(latency, 5000.0); // Cap at 5 seconds
    }
    
    last_tick_time = current_time;
    return 100.0; // Default latency
}

void CBrokerInterface::UpdateSpreadStats() {
    double current_spread = GetCurrentSpread();
    
    if (current_spread > 0) {
        m_SpreadStats.CurrentSpread = current_spread;
        
        // Update average
        static int spread_count = 0;
        spread_count++;
        m_SpreadStats.AverageSpread = 
            (m_SpreadStats.AverageSpread * (spread_count - 1) + current_spread) / spread_count;
        
        // Update min/max
        if (m_SpreadStats.MinSpread == 0 || current_spread < m_SpreadStats.MinSpread) {
            m_SpreadStats.MinSpread = current_spread;
        }
        
        if (current_spread > m_SpreadStats.MaxSpread) {
            m_SpreadStats.MaxSpread = current_spread;
        }
        
        m_SpreadStats.LastSpreadUpdate = TimeCurrent();
        m_SpreadStats.IsSpreadNormal = (current_spread <= m_SpreadStats.SpreadThreshold);
    }
}

bool CBrokerInterface::IsExecutionQualityGood() {
    if (m_ExecutionStats.TotalOrders < 10) {
        return true; // Not enough data
    }
    
    return (m_ExecutionStats.SuccessRate >= MIN_SUCCESS_RATE) &&
           (m_ExecutionStats.AverageSlippage <= MAX_ACCEPTABLE_SLIPPAGE);
}

string CBrokerInterface::GetConnectionSummary() {
    return StringFormat("Broker: %s | Server: %s | Connected: %s | Health: %s | Latency: %.0fms",
                        m_BrokerInfo.BrokerName,
                        m_BrokerInfo.ServerName,
                        IsConnected() ? "Yes" : "No",
                        EnumToString(GetOverallHealth()),
                        GetLatency());
}

string CBrokerInterface::GetExecutionSummary() {
    return StringFormat("Execution Stats - Orders: %d | Success: %.1f%% | Avg Slippage: %.1f | Max Slippage: %.1f",
                        m_ExecutionStats.TotalOrders,
                        m_ExecutionStats.SuccessRate,
                        m_ExecutionStats.AverageSlippage,
                        m_ExecutionStats.MaxSlippage);
}

void CBrokerInterface::LogBrokerEvent(const string& event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO) {
    if (m_pContext != NULL && m_pContext.pLogger != NULL) {
        switch(level) {
            case LOG_LEVEL_ERROR:
                m_pContext.pLogger.LogError(event, __FUNCTION__);
                break;
            case LOG_LEVEL_WARNING:
                m_pContext.pLogger.LogWarning(event, __FUNCTION__);
                break;
            default:
                m_pContext.pLogger.LogInfo(event, __FUNCTION__);
        }
    }
}

} // namespace ApexPullback::v5

#endif // BROKER_INTERFACE_MQH_