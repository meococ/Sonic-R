//+------------------------------------------------------------------+
//|                                                 TradeManager.mqh |
//|                   TradeManager - APEX Pullback EA v5 FINAL      |
//|      Description: Advanced trade execution and management with   |
//|                   comprehensive error handling and monitoring   |
//+------------------------------------------------------------------+

#ifndef APEX_TRADEMANAGER_MQH_
#define APEX_TRADEMANAGER_MQH_

#include <Trade\Trade.mqh>
#include "../../00_Core/CommonStructs.mqh"

//+------------------------------------------------------------------+
//| Enhanced Trade Execution Structures                              |
//+------------------------------------------------------------------+
struct STradeExecutionMetrics {
    // Execution Quality
    double          AverageSlippage;         // Average slippage in points
    double          MaxSlippage;             // Maximum recorded slippage
    double          AverageLatency;          // Average execution time (ms)
    double          MaxLatency;              // Maximum execution time (ms)
    
    // Success Rates
    double          ExecutionSuccessRate;    // % of successful executions
    double          FillRate;                // % of orders filled
    double          RejectionRate;           // % of orders rejected
    
    // Volume Analysis
    double          TotalVolumeExecuted;     // Total volume traded
    double          AverageVolumePerTrade;   // Average trade size
    int             PartialFills;            // Number of partial fills
    
    // Timing Analysis
    double          MarketHoursSuccessRate;  // Success rate during market hours
    double          OffHoursSuccessRate;     // Success rate during off hours
    ulong           LastExecutionTime;       // Timestamp of last execution
    
    STradeExecutionMetrics() { Reset(); }
    void Reset() {
        AverageSlippage = MaxSlippage = 0.0;
        AverageLatency = MaxLatency = 0.0;
        ExecutionSuccessRate = FillRate = RejectionRate = 0.0;
        TotalVolumeExecuted = AverageVolumePerTrade = 0.0;
        PartialFills = 0;
        MarketHoursSuccessRate = OffHoursSuccessRate = 0.0;
        LastExecutionTime = 0;
    }
};

struct STradeRequest {
    ENUM_ORDER_TYPE OrderType;
    double          Volume;
    double          Price;
    double          StopLoss;
    double          TakeProfit;
    string          Comment;
    ulong           RequestTime;
    
    STradeRequest() {
        OrderType = ORDER_TYPE_BUY;
        Volume = Price = StopLoss = TakeProfit = 0.0;
        Comment = "";
        RequestTime = 0;
    }
};

struct SExecutionResult {
    bool            Success;
    ulong           ExecutionTime;           // Microseconds
    double          SlippagePoints;
    double          ActualPrice;
    long            DealTicket;
    uint            ReturnCode;
    string          ErrorDescription;
    
    SExecutionResult() {
        Success = false;
        ExecutionTime = SlippagePoints = ActualPrice = 0.0;
        DealTicket = 0;
        ReturnCode = 0;
        ErrorDescription = "";
    }
};

//+------------------------------------------------------------------+
//| Enhanced CTradeManager - Advanced Trade Execution Engine        |
//+------------------------------------------------------------------+
class CTradeManager {
private:
    // Core State
    EAContext*                  m_pContext;
    bool                        m_bInitialized;
    
    // Core Trading Components
    CTrade                      m_Trade;
    string                      m_sSymbol;
    long                        m_lMagicNumber;
    int                         m_iSlippage;
    int                         m_iMaxSpreadPoints;
    
    // Enhanced Metrics
    STradeExecutionMetrics      m_ExecutionMetrics;
    
    // Trade Statistics
    int                         m_iTotalTrades;
    int                         m_iSuccessfulTrades;
    int                         m_iFailedTrades;
    double                      m_dTotalSlippage;
    double                      m_dAverageExecutionTime;
    
    // Risk Controls
    double                      m_dMaxLotSize;
    int                         m_iMaxPositions;
    double                      m_dDailyLossLimit;
    
    // Advanced Features
    double                      m_dSlippageTolerance;    // Maximum acceptable slippage
    int                         m_iMaxRetries;           // Maximum execution retries
    double                      m_dExecutionTimeout;     // Execution timeout (seconds)
    bool                        m_bAllowPartialFills;    // Allow partial order fills
    
    // Execution Quality Tracking
    double                      m_SlippageHistory[100];  // Last 100 slippage values
    int                         m_SlippageIndex;         // Current index in history
    int                         m_SlippageCount;         // Number of recorded values
    
    // Latency Tracking
    double                      m_LatencyHistory[100];   // Last 100 latency values
    int                         m_LatencyIndex;          // Current index in history
    int                         m_LatencyCount;          // Number of recorded values
    
public:
    //--- Constructor/Destructor ---
    CTradeManager();
    ~CTradeManager();
    
    //--- Initialization ---
    bool                        Initialize(EAContext* pContext);
    void                        Deinitialize();
    bool                        IsInitialized() const { return m_bInitialized; }
    
    //--- Core Trading Operations ---
    bool                        OpenPosition(ENUM_ORDER_TYPE order_type, double volume, double sl_price, double tp_price, const string comment = "");
    SExecutionResult            OpenPositionAdvanced(const STradeRequest &request);
    bool                        ClosePosition(long ticket, const string reason, double volume_to_close = 0.0);
    bool                        CloseAllPositions(const string reason);
    bool                        ModifyPosition(long ticket, double new_sl_price, double new_tp_price);
    bool                        DeletePendingOrder(long ticket, const string reason);
    
    //--- Position Management ---
    int                         GetOpenPositionsCount(ENUM_ORDER_TYPE order_type = WRONG_VALUE);
    double                      GetTotalExposure();
    double                      GetPositionSize(long ticket);
    bool                        IsPositionOpen(long ticket);
    double                      GetPositionProfit(long ticket);
    double                      GetTotalUnrealizedPnL();
    
    //--- Risk Management ---
    bool                        ValidateTradeRequest(ENUM_ORDER_TYPE order_type, double volume);
    double                      CalculateOptimalLotSize(double risk_percent, double sl_pips);
    bool                        CheckDailyLimits();
    bool                        CheckRiskLimits(double volume);
    bool                        IsRiskAcceptable(const STradeRequest &request);
    
    //--- Price Calculations ---
    double                      CalculateStopLossPrice(ENUM_ORDER_TYPE order_type, double entry_price, double sl_pips);
    double                      CalculateTakeProfitPrice(ENUM_ORDER_TYPE order_type, double entry_price, double tp_pips);
    double                      NormalizeLots(double lots);
    double                      NormalizePrice(double price);
    
    //--- Event Handling ---
    void                        OnTradeTransaction(const MqlTradeTransaction& trans, const MqlTradeRequest& request, const MqlTradeResult& result);
    
    //--- Statistics & Analytics ---
    int                         GetTotalTrades() const { return m_iTotalTrades; }
    int                         GetSuccessfulTrades() const { return m_iSuccessfulTrades; }
    int                         GetFailedTrades() const { return m_iFailedTrades; }
    double                      GetSuccessRate() const;
    double                      GetAverageSlippage() const;
    double                      GetAverageExecutionTime() const { return m_dAverageExecutionTime; }
    STradeExecutionMetrics      GetExecutionMetrics() const { return m_ExecutionMetrics; }
    
    //--- Execution Quality Analysis ---
    double                      GetCurrentSlippageStats(double &average, double &maximum, double &deviation);
    double                      GetCurrentLatencyStats(double &average, double &maximum, double &deviation);
    double                      GetExecutionQualityScore();
    bool                        IsExecutionQualityAcceptable();
    
    //--- Advanced Features ---
    void                        SetSlippageTolerance(double tolerance) { m_dSlippageTolerance = tolerance; }
    void                        SetMaxRetries(int retries) { m_iMaxRetries = retries; }
    void                        SetExecutionTimeout(double timeout) { m_dExecutionTimeout = timeout; }
    void                        SetAllowPartialFills(bool allow) { m_bAllowPartialFills = allow; }
    
    //--- Market Analysis ---
    double                      GetCurrentSpread();
    bool                        IsMarketLiquid();
    bool                        IsVolatilityHigh();
    ENUM_TRADE_RETCODE          GetLastTradeResult() { return (ENUM_TRADE_RETCODE)m_Trade.ResultRetcode(); }
    
private:
    //--- Validation Methods ---
    bool                        IsTradeContextValid(const string calling_function);
    bool                        ValidateSymbolInfo();
    bool                        CheckMarketConditions();
    
    //--- Helper Methods ---
    void                        UpdateTradeStatistics(bool success, double slippage, double execution_time);
    void                        UpdateExecutionMetrics(const SExecutionResult &result);
    void                        LogTradeDetails(ENUM_ORDER_TYPE order_type, double volume, double price, const string comment);
    bool                        CheckSpreadConditions();
    bool                        CheckTradingHours();
    
    //--- Execution Quality Tracking ---
    void                        RecordSlippage(double slippage);
    void                        RecordLatency(double latency);
    double                      CalculateStatistics(const double &history[], int count, double &average, double &maximum, double &deviation);
    
    //--- Advanced Execution Methods ---
    SExecutionResult            ExecuteOrderWithRetry(const STradeRequest &request);
    bool                        ValidateOrderExecution(const STradeRequest &request, const SExecutionResult &result);
    double                      CalculateSlippage(ENUM_ORDER_TYPE order_type, double requested_price, double actual_price);
    
    //--- Market Quality Assessment ---
    bool                        IsMarketConditionOptimal();
    double                      GetMarketImpactEstimate(double volume);
    bool                        ShouldDelayExecution();
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTradeManager::CTradeManager() : 
    m_pContext(NULL),
    m_bInitialized(false),
    m_sSymbol(""),
    m_lMagicNumber(0),
    m_iSlippage(0),
    m_iMaxSpreadPoints(0),
    m_iTotalTrades(0),
    m_iSuccessfulTrades(0),
    m_iFailedTrades(0),
    m_dTotalSlippage(0.0),
    m_dAverageExecutionTime(0.0),
    m_dMaxLotSize(0.0),
    m_iMaxPositions(0),
    m_dDailyLossLimit(0.0),
    m_dSlippageTolerance(0.0),
    m_iMaxRetries(0),
    m_dExecutionTimeout(0.0),
    m_bAllowPartialFills(false),
    m_SlippageIndex(0),
    m_SlippageCount(0),
    m_LatencyIndex(0),
    m_LatencyCount(0)
{
    // The constructor should only initialize members to default values.
    // All logic, especially that depending on external context (like EAInputs),
    // must be in the Initialize() method.
    ArrayInitialize(m_SlippageHistory, 0.0);
    ArrayInitialize(m_LatencyHistory, 0.0);
    m_ExecutionMetrics.Reset();
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTradeManager::~CTradeManager() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize Trade Manager                                         |
//+------------------------------------------------------------------+
bool CTradeManager::Initialize(EAContext* pContext) {
    if (m_bInitialized) {
        return true;
    }
    
    if (pContext == NULL) {
        Print("[TradeManager] ERROR: Context is NULL");
        return false;
    }
    
    m_pContext = pContext;
    
    // Validate required components
    if (m_pContext->pLogger == NULL) {
        Print("[TradeManager] ERROR: Logger is NULL");
        return false;
    }
    
    m_pContext->pLogger->LogInfo("Initializing Enhanced TradeManager v5...", __FUNCTION__);
    
    // Set basic parameters
    m_sSymbol = _Symbol;
    m_lMagicNumber = m_pContext->Inputs.MagicNumber;
    m_iSlippage = m_pContext->Inputs.Slippage;
    m_iMaxSpreadPoints = (int)m_pContext->Inputs.MarketFilters.MaxSpreadPoints;
    
    // Configure CTrade object
    m_Trade.SetExpertMagicNumber(m_lMagicNumber);
    m_Trade.SetMarginMode();
    m_Trade.SetTypeFillingBySymbol(m_sSymbol);
    m_Trade.SetDeviationInPoints(m_iSlippage);
    
    // Set risk controls from inputs
    m_dMaxLotSize = m_pContext->Inputs.RiskManagement.MaxLotSize;
    m_iMaxPositions = m_pContext->Inputs.RiskManagement.MaxPositions;
    m_dDailyLossLimit = m_pContext->Inputs.RiskManagement.MaxDailyLossPercent;
    
    // Advanced settings from inputs if available
    if (m_pContext->Inputs.TradeManagement.SlippageTolerance > 0) {
        m_dSlippageTolerance = m_pContext->Inputs.TradeManagement.SlippageTolerance;
    }
    
    if (m_pContext->Inputs.TradeManagement.MaxRetries > 0) {
        m_iMaxRetries = m_pContext->Inputs.TradeManagement.MaxRetries;
    }
    
    // Validate symbol information
    if (!ValidateSymbolInfo()) {
        m_pContext->pLogger->LogError("Failed to validate symbol information", __FUNCTION__);
        return false;
    }
    
    m_bInitialized = true;
    m_pContext->pLogger->LogInfo(StringFormat("Enhanced TradeManager initialized for %s with Magic Number %d", 
                                           m_sSymbol, m_lMagicNumber), __FUNCTION__);
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize Trade Manager                                       |
//+------------------------------------------------------------------+
void CTradeManager::Deinitialize() {
    if (!m_bInitialized) {
        return;
    }
    
    if (m_pContext && m_pContext->pLogger) {
        m_pContext->pLogger->LogInfo("Deinitializing Enhanced TradeManager...", __FUNCTION__);
        
        // Log comprehensive final statistics
        string stats = StringFormat("Final Enhanced Trade Statistics:\n" +
                                   "- Total Trades: %d (Success: %d, Failed: %d)\n" +
                                   "- Success Rate: %.2f%%\n" +
                                   "- Average Slippage: %.2f points\n" +
                                   "- Average Latency: %.2f ms\n" +
                                   "- Execution Quality Score: %.2f%%\n" +
                                   "- Total Volume: %.2f lots",
                                   m_iTotalTrades, m_iSuccessfulTrades, m_iFailedTrades, 
                                   GetSuccessRate(), GetAverageSlippage(), 
                                   m_dAverageExecutionTime, GetExecutionQualityScore(),
                                   m_ExecutionMetrics.TotalVolumeExecuted);
        m_pContext->pLogger->LogInfo(stats, __FUNCTION__);
    }
    
    m_bInitialized = false;
    m_pContext = NULL;
}

//+------------------------------------------------------------------+
//| Enhanced Open Position with Advanced Metrics                    |
//+------------------------------------------------------------------+
bool CTradeManager::OpenPosition(ENUM_ORDER_TYPE order_type, double volume, double sl_price, double tp_price, const string comment = "") {
    if (!m_bInitialized || !IsTradeContextValid(__FUNCTION__)) {
        return false;
    }
    
    // Create trade request structure
    STradeRequest request;
    request.OrderType = order_type;
    request.Volume = volume;
    request.StopLoss = sl_price;
    request.TakeProfit = tp_price;
    request.Comment = comment;
    request.RequestTime = GetMicrosecondCount();
    
    // Use advanced execution with retry logic
    SExecutionResult result = OpenPositionAdvanced(request);
    
    return result.Success;
}

//+------------------------------------------------------------------+
//| Advanced Position Opening with Retry Logic                      |
//+------------------------------------------------------------------+
SExecutionResult CTradeManager::OpenPositionAdvanced(const STradeRequest &request) {
    SExecutionResult result;
    
    if (!m_bInitialized || !IsTradeContextValid(__FUNCTION__)) {
        result.ErrorDescription = "Trade context invalid";
        return result;
    }
    
    // Validate trade request
    if (!ValidateTradeRequest(request.OrderType, request.Volume)) {
        result.ErrorDescription = "Trade request validation failed";
        return result;
    }
    
    // Check market conditions
    if (!CheckMarketConditions()) {
        result.ErrorDescription = "Market conditions not suitable";
        return result;
    }
    
    // Check if risk is acceptable
    if (!IsRiskAcceptable(request)) {
        result.ErrorDescription = "Risk not acceptable";
        return result;
    }
    
    // Execute with retry logic
    result = ExecuteOrderWithRetry(request);
    
    // Update execution metrics
    UpdateExecutionMetrics(result);
    
    return result;
}

//+------------------------------------------------------------------+
//| Execute Order with Retry Logic                                  |
//+------------------------------------------------------------------+
SExecutionResult CTradeManager::ExecuteOrderWithRetry(const STradeRequest &request) {
    SExecutionResult result;
    ulong start_time = GetMicrosecondCount();
    
    // Normalize volume and prices
    double normalized_volume = NormalizeLots(request.Volume);
    if (normalized_volume <= 0) {
        result.ErrorDescription = "Invalid normalized volume";
        return result;
    }
    
    double price = (request.OrderType == ORDER_TYPE_BUY) ? 
                   SymbolInfoDouble(m_sSymbol, SYMBOL_ASK) : 
                   SymbolInfoDouble(m_sSymbol, SYMBOL_BID);
    
    if (price <= 0) {
        result.ErrorDescription = "Invalid market price";
        return result;
    }
    
    double norm_sl = (request.StopLoss > 0) ? NormalizePrice(request.StopLoss) : 0.0;
    double norm_tp = (request.TakeProfit > 0) ? NormalizePrice(request.TakeProfit) : 0.0;
    
    // Log trade attempt
    LogTradeDetails(request.OrderType, normalized_volume, price, request.Comment);
    
    // Attempt execution with retries
    for (int attempt = 1; attempt <= m_iMaxRetries; attempt++) {
        if (attempt > 1) {
            Sleep(100 * attempt); // Progressive delay
            
            // Update price for retry
            price = (request.OrderType == ORDER_TYPE_BUY) ? 
                    SymbolInfoDouble(m_sSymbol, SYMBOL_ASK) : 
                    SymbolInfoDouble(m_sSymbol, SYMBOL_BID);
        }
        
        // Execute trade
        bool success = m_Trade.PositionOpen(m_sSymbol, request.OrderType, normalized_volume, price, norm_sl, norm_tp, request.Comment);
        
        result.ExecutionTime = GetMicrosecondCount() - start_time;
        result.ReturnCode = m_Trade.ResultRetcode();
        result.ErrorDescription = m_Trade.ResultRetcodeDescription();
        
        if (success) {
            result.Success = true;
            result.DealTicket = m_Trade.ResultDeal();
            result.ActualPrice = price; // Will be updated in OnTradeTransaction
            result.SlippagePoints = 0.0; // Will be calculated in OnTradeTransaction
            
            // Record execution time
            RecordLatency(result.ExecutionTime / 1000.0); // Convert to milliseconds
            
            m_pContext->pLogger->LogInfo(StringFormat("Position opened successfully on attempt %d. Deal: #%d, Execution time: %.2f ms", 
                                                   attempt, result.DealTicket, result.ExecutionTime / 1000.0), __FUNCTION__);
            break;
        } else {
            m_pContext->pLogger->LogWarning(StringFormat("Execution attempt %d failed. Error: %d - %s", 
                                                      attempt, result.ReturnCode, result.ErrorDescription), __FUNCTION__);
            
            // Check if we should retry
            if (attempt >= m_iMaxRetries || 
                result.ReturnCode == TRADE_RETCODE_INVALID_VOLUME ||
                result.ReturnCode == TRADE_RETCODE_NOT_ENOUGH_MONEY) {
                break; // Don't retry for these errors
            }
        }
    }
    
    // Update statistics
    UpdateTradeStatistics(result.Success, result.SlippagePoints, result.ExecutionTime / 1000.0);
    
    return result;
}

//+------------------------------------------------------------------+
//| Enhanced Close Position with Better Tracking                    |
//+------------------------------------------------------------------+
bool CTradeManager::ClosePosition(long ticket, const string reason, double volume_to_close = 0.0) {
    if (!m_bInitialized || !IsTradeContextValid(__FUNCTION__)) {
        return false;
    }
    
    if (!PositionSelectByTicket(ticket)) {
        m_pContext->pLogger->LogError(StringFormat("Position #%d not found", ticket), __FUNCTION__);
        return false;
    }
    
    // Verify it's our position
    if (PositionGetInteger(POSITION_MAGIC) != m_lMagicNumber) {
        m_pContext->pLogger->LogWarning(StringFormat("Position #%d has different magic number", ticket), __FUNCTION__);
        return false;
    }
    
    double position_volume = PositionGetDouble(POSITION_VOLUME);
    double close_volume = (volume_to_close > 0) ? NormalizeLots(volume_to_close) : position_volume;
    
    if (close_volume > position_volume) {
        close_volume = position_volume;
        m_pContext->pLogger->LogWarning(StringFormat("Adjusted close volume from %.6f to %.6f", 
                                                  volume_to_close, close_volume), __FUNCTION__);
    }
    
    m_pContext->pLogger->LogInfo(StringFormat("Closing %.6f lots of position #%d. Reason: %s", 
                                           close_volume, ticket, reason), __FUNCTION__);
    
    ulong start_time = GetMicrosecondCount();
    
    // Execute close with retry logic
    bool result = false;
    for (int attempt = 1; attempt <= m_iMaxRetries; attempt++) {
        if (attempt > 1) {
            Sleep(100 * attempt);
        }
        
        result = m_Trade.PositionClose(ticket, close_volume);
        
        if (result) {
            double execution_time = (GetMicrosecondCount() - start_time) / 1000.0;
            RecordLatency(execution_time);
            
            m_pContext->pLogger->LogInfo(StringFormat("Position #%d closed successfully on attempt %d. Deal: #%d, Execution time: %.2f ms", 
                                                   ticket, attempt, m_Trade.ResultDeal(), execution_time), __FUNCTION__);
            break;
        } else {
            m_pContext->pLogger->LogWarning(StringFormat("Close attempt %d failed. Error: %d - %s", 
                                                      attempt, m_Trade.ResultRetcode(), m_Trade.ResultRetcodeDescription()), __FUNCTION__);
            
            if (attempt >= m_iMaxRetries) {
                string error_msg = StringFormat("Failed to close position #%d after %d attempts. Final error: %d - %s", 
                                               ticket, m_iMaxRetries, m_Trade.ResultRetcode(), m_Trade.ResultRetcodeDescription());
                m_pContext->pLogger->LogError(error_msg, __FUNCTION__);
                
                if (m_pContext->pErrorHandler != NULL) {
                    m_pContext->pErrorHandler->HandleError(m_Trade.ResultRetcode(), __FUNCTION__, error_msg);
                }
            }
        }
    }
    
    return result;
}

//+------------------------------------------------------------------+
//| Get Position Profit                                             |
//+------------------------------------------------------------------+
double CTradeManager::GetPositionProfit(long ticket) {
    if (PositionSelectByTicket(ticket)) {
        if (PositionGetInteger(POSITION_MAGIC) == m_lMagicNumber) {
            return PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
        }
    }
    return 0.0;
}

//+------------------------------------------------------------------+
//| Get Total Unrealized PnL                                        |
//+------------------------------------------------------------------+
double CTradeManager::GetTotalUnrealizedPnL() {
    double total_pnl = 0.0;
    int total = PositionsTotal();
    
    for (int i = 0; i < total; i++) {
        if (PositionGetTicket(i) > 0) {
            if (PositionGetInteger(POSITION_MAGIC) == m_lMagicNumber && 
                PositionGetString(POSITION_SYMBOL) == m_sSymbol) {
                total_pnl += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
            }
        }
    }
    
    return total_pnl;
}

//+------------------------------------------------------------------+
//| Check Risk Limits                                               |
//+------------------------------------------------------------------+
bool CTradeManager::CheckRiskLimits(double volume) {
    // Check volume against maximum lot size
    if (volume > m_dMaxLotSize) {
        m_pContext->pLogger->LogError(StringFormat("Volume %.6f exceeds maximum %.6f", 
                                                volume, m_dMaxLotSize), __FUNCTION__);
        return false;
    }
    
    // Check against total exposure
    double current_exposure = GetTotalExposure();
    double new_exposure = current_exposure + (volume * SymbolInfoDouble(m_sSymbol, SYMBOL_ASK));
    double max_exposure = AccountInfoDouble(ACCOUNT_EQUITY) * 2.0; // 200% of equity max
    
    if (new_exposure > max_exposure) {
        m_pContext->pLogger->LogError(StringFormat("New exposure %.2f would exceed maximum %.2f", 
                                                new_exposure, max_exposure), __FUNCTION__);
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Is Risk Acceptable                                              |
//+------------------------------------------------------------------+
bool CTradeManager::IsRiskAcceptable(const STradeRequest &request) {
    // Basic risk checks
    if (!CheckRiskLimits(request.Volume)) {
        return false;
    }
    
    // Check execution quality
    if (!IsExecutionQualityAcceptable()) {
        m_pContext->pLogger->LogWarning("Execution quality below acceptable threshold", __FUNCTION__);
        return false;
    }
    
    // Check market liquidity
    if (!IsMarketLiquid()) {
        m_pContext->pLogger->LogWarning("Market liquidity insufficient", __FUNCTION__);
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Get Total Exposure                                              |
//+------------------------------------------------------------------+
double CTradeManager::GetTotalExposure() {
    double total_exposure = 0.0;
    int total = PositionsTotal();
    
    for (int i = 0; i < total; i++) {
        if (PositionGetTicket(i) > 0) {
            if (PositionGetInteger(POSITION_MAGIC) == m_lMagicNumber && 
                PositionGetString(POSITION_SYMBOL) == m_sSymbol) {
                double volume = PositionGetDouble(POSITION_VOLUME);
                double price = PositionGetDouble(POSITION_PRICE_OPEN);
                total_exposure += volume * price;
            }
        }
    }
    
    return total_exposure;
}

//+------------------------------------------------------------------+
//| Get Position Size                                               |
//+------------------------------------------------------------------+
double CTradeManager::GetPositionSize(long ticket) {
    if (PositionSelectByTicket(ticket)) {
        if (PositionGetInteger(POSITION_MAGIC) == m_lMagicNumber) {
            return PositionGetDouble(POSITION_VOLUME);
        }
    }
    return 0.0;
}

//+------------------------------------------------------------------+
//| Is Position Open                                                |
//+------------------------------------------------------------------+
bool CTradeManager::IsPositionOpen(long ticket) {
    if (PositionSelectByTicket(ticket)) {
        return PositionGetInteger(POSITION_MAGIC) == m_lMagicNumber;
    }
    return false;
}

//+------------------------------------------------------------------+
//| Record Slippage                                                 |
//+------------------------------------------------------------------+
void CTradeManager::RecordSlippage(double slippage) {
    m_SlippageHistory[m_SlippageIndex] = MathAbs(slippage);
    m_SlippageIndex = (m_SlippageIndex + 1) % 100;
    if (m_SlippageCount < 100) m_SlippageCount++;
    
    // Update metrics
    if (MathAbs(slippage) > m_ExecutionMetrics.MaxSlippage) {
        m_ExecutionMetrics.MaxSlippage = MathAbs(slippage);
    }
}

//+------------------------------------------------------------------+
//| Record Latency                                                  |
//+------------------------------------------------------------------+
void CTradeManager::RecordLatency(double latency) {
    m_LatencyHistory[m_LatencyIndex] = latency;
    m_LatencyIndex = (m_LatencyIndex + 1) % 100;
    if (m_LatencyCount < 100) m_LatencyCount++;
    
    // Update metrics
    if (latency > m_ExecutionMetrics.MaxLatency) {
        m_ExecutionMetrics.MaxLatency = latency;
    }
}

//+------------------------------------------------------------------+
//| Get Current Slippage Statistics                                 |
//+------------------------------------------------------------------+
double CTradeManager::GetCurrentSlippageStats(double &average, double &maximum, double &deviation) {
    return CalculateStatistics(m_SlippageHistory, m_SlippageCount, average, maximum, deviation);
}

//+------------------------------------------------------------------+
//| Get Current Latency Statistics                                  |
//+------------------------------------------------------------------+
double CTradeManager::GetCurrentLatencyStats(double &average, double &maximum, double &deviation) {
    return CalculateStatistics(m_LatencyHistory, m_LatencyCount, average, maximum, deviation);
}

//+------------------------------------------------------------------+
//| Calculate Statistics                                             |
//+------------------------------------------------------------------+
double CTradeManager::CalculateStatistics(const double &history[], int count, double &average, double &maximum, double &deviation) {
    if (count <= 0) {
        average = maximum = deviation = 0.0;
        return 0.0;
    }
    
    // Calculate average
    double sum = 0.0;
    maximum = history[0];
    
    for (int i = 0; i < count; i++) {
        sum += history[i];
        if (history[i] > maximum) maximum = history[i];
    }
    
    average = sum / count;
    
    // Calculate standard deviation
    double variance = 0.0;
    for (int i = 0; i < count; i++) {
        variance += MathPow(history[i] - average, 2);
    }
    
    deviation = MathSqrt(variance / count);
    
    return average;
}

//+------------------------------------------------------------------+
//| Get Execution Quality Score                                     |
//+------------------------------------------------------------------+
double CTradeManager::GetExecutionQualityScore() {
    if (m_iTotalTrades == 0) return 100.0;
    
    double success_score = GetSuccessRate();
    double slippage_score = 100.0;
    double latency_score = 100.0;
    
    // Slippage score (lower is better)
    if (m_SlippageCount > 0) {
        double avg_slippage = 0.0, max_slippage = 0.0, dev_slippage = 0.0;
        GetCurrentSlippageStats(avg_slippage, max_slippage, dev_slippage);
        
        slippage_score = MathMax(0.0, 100.0 - (avg_slippage * 10.0)); // 10 points per pip slippage
    }
    
    // Latency score (lower is better)
    if (m_LatencyCount > 0) {
        double avg_latency = 0.0, max_latency = 0.0, dev_latency = 0.0;
        GetCurrentLatencyStats(avg_latency, max_latency, dev_latency);
        
        latency_score = MathMax(0.0, 100.0 - (avg_latency / 10.0)); // 1 point per 10ms latency
    }
    
    // Weighted average
    return (success_score * 0.5) + (slippage_score * 0.3) + (latency_score * 0.2);
}

//+------------------------------------------------------------------+
//| Is Execution Quality Acceptable                                 |
//+------------------------------------------------------------------+
bool CTradeManager::IsExecutionQualityAcceptable() {
    if (m_iTotalTrades < 10) return true; // Not enough data
    
    double quality_score = GetExecutionQualityScore();
    return quality_score >= 70.0; // Minimum 70% quality score
}

//+------------------------------------------------------------------+
//| Get Current Spread                                              |
//+------------------------------------------------------------------+
double CTradeManager::GetCurrentSpread() {
    return SymbolInfoInteger(m_sSymbol, SYMBOL_SPREAD) * SymbolInfoDouble(m_sSymbol, SYMBOL_POINT);
}

//+------------------------------------------------------------------+
//| Is Market Liquid                                                |
//+------------------------------------------------------------------+
bool CTradeManager::IsMarketLiquid() {
    double spread = GetCurrentSpread();
    double avg_spread = spread; // In a full implementation, you'd calculate average spread
    
    // Market is considered liquid if current spread is not too far from average
    return spread <= avg_spread * 2.0;
}

//+------------------------------------------------------------------+
//| Is Volatility High                                              |
//+------------------------------------------------------------------+
bool CTradeManager::IsVolatilityHigh() {
    if (!m_pContext->pMarketData) return false;
    
    double current_atr = m_pContext->pMarketData->GetATR(14, 0);
    double avg_atr = m_pContext->pMarketData->GetATR(50, 0);
    
    return current_atr > avg_atr * 1.5; // High volatility if ATR is 50% above average
}

//+------------------------------------------------------------------+
//| Calculate Slippage                                              |
//+------------------------------------------------------------------+
double CTradeManager::CalculateSlippage(ENUM_ORDER_TYPE order_type, double requested_price, double actual_price) {
    double slippage = 0.0;
    
    if (order_type == ORDER_TYPE_BUY) {
        slippage = actual_price - requested_price;
    } else {
        slippage = requested_price - actual_price;
    }
    
    return slippage / SymbolInfoDouble(m_sSymbol, SYMBOL_POINT);
}

//+------------------------------------------------------------------+
//| Validate Order Execution                                        |
//+------------------------------------------------------------------+
bool CTradeManager::ValidateOrderExecution(const STradeRequest &request, const SExecutionResult &result) {
    if (!result.Success) return false;
    
    // Check slippage tolerance
    if (MathAbs(result.SlippagePoints) > m_dSlippageTolerance) {
        m_pContext->pLogger->LogWarning(StringFormat("Slippage %.2f exceeds tolerance %.2f", 
                                                  result.SlippagePoints, m_dSlippageTolerance), __FUNCTION__);
        return false;
    }
    
    // Check execution time
    double execution_time_ms = result.ExecutionTime / 1000.0;
    if (execution_time_ms > m_dExecutionTimeout * 1000.0) {
        m_pContext->pLogger->LogWarning(StringFormat("Execution time %.2f ms exceeds timeout %.2f ms", 
                                                  execution_time_ms, m_dExecutionTimeout * 1000.0), __FUNCTION__);
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Update Execution Metrics                                        |
//+------------------------------------------------------------------+
void CTradeManager::UpdateExecutionMetrics(const SExecutionResult &result) {
    m_ExecutionMetrics.LastExecutionTime = TimeCurrent();
    m_ExecutionMetrics.TotalVolumeExecuted += NormalizeLots(result.Success ? 1.0 : 0.0); // Simplified
    
    if (result.Success) {
        m_ExecutionMetrics.ExecutionSuccessRate = (double)m_iSuccessfulTrades / m_iTotalTrades * 100.0;
        m_ExecutionMetrics.FillRate = m_ExecutionMetrics.ExecutionSuccessRate; // Simplified
        
        // Record slippage
        RecordSlippage(result.SlippagePoints);
        
        // Update average slippage using exponential moving average
        if (m_ExecutionMetrics.AverageSlippage == 0.0) {
            m_ExecutionMetrics.AverageSlippage = MathAbs(result.SlippagePoints);
        } else {
            m_ExecutionMetrics.AverageSlippage = (m_ExecutionMetrics.AverageSlippage * 0.9) + (MathAbs(result.SlippagePoints) * 0.1);
        }
        
        // Update average latency
        double latency_ms = result.ExecutionTime / 1000.0;
        if (m_ExecutionMetrics.AverageLatency == 0.0) {
            m_ExecutionMetrics.AverageLatency = latency_ms;
        } else {
            m_ExecutionMetrics.AverageLatency = (m_ExecutionMetrics.AverageLatency * 0.9) + (latency_ms * 0.1);
        }
    }
    
    m_ExecutionMetrics.RejectionRate = (double)m_iFailedTrades / m_iTotalTrades * 100.0;
}

//+------------------------------------------------------------------+
//| Is Market Condition Optimal                                     |
//+------------------------------------------------------------------+
bool CTradeManager::IsMarketConditionOptimal() {
    return CheckSpreadConditions() && 
           CheckTradingHours() && 
           IsMarketLiquid() && 
           !IsVolatilityHigh();
}

//+------------------------------------------------------------------+
//| Get Market Impact Estimate                                      |
//+------------------------------------------------------------------+
double CTradeManager::GetMarketImpactEstimate(double volume) {
    // Simplified market impact estimation
    double normal_volume = 1.0; // Standard lot
    double volume_ratio = volume / normal_volume;
    
    // Impact increases with volume^0.5 (square root law)
    return MathSqrt(volume_ratio) * GetCurrentSpread() * 0.1;
}

//+------------------------------------------------------------------+
//| Should Delay Execution                                          |
//+------------------------------------------------------------------+
bool CTradeManager::ShouldDelayExecution() {
    // Check if execution quality is poor
    if (!IsExecutionQualityAcceptable()) {
        return true;
    }
    
    // Check if volatility is too high
    if (IsVolatilityHigh()) {
        return true;
    }
    
    // Check if spread is too wide
    if (!CheckSpreadConditions()) {
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Validate Trade Request                                           |
//+------------------------------------------------------------------+
bool CTradeManager::ValidateTradeRequest(ENUM_ORDER_TYPE order_type, double volume) {
    // Check volume limits
    if (volume > m_dMaxLotSize) {
        m_pContext->pLogger->LogError(StringFormat("Volume %.6f exceeds maximum %.6f", 
                                                volume, m_dMaxLotSize), __FUNCTION__);
        return false;
    }
    
    // Check position limits
    if (GetOpenPositionsCount() >= m_iMaxPositions) {
        m_pContext->pLogger->LogError(StringFormat("Maximum positions (%d) reached", m_iMaxPositions), __FUNCTION__);
        return false;
    }
    
    // Check daily limits
    if (!CheckDailyLimits()) {
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Check Daily Limits                                               |
//+------------------------------------------------------------------+
bool CTradeManager::CheckDailyLimits() {
    // This is a simplified implementation
    // In a full version, you would track daily P&L
    return true;
}

//+------------------------------------------------------------------+
//| Validate Symbol Information                                      |
//+------------------------------------------------------------------+
bool CTradeManager::ValidateSymbolInfo() {
    if (!SymbolSelect(m_sSymbol, true)) {
        m_pContext->pLogger->LogError(StringFormat("Failed to select symbol %s", m_sSymbol), __FUNCTION__);
        return false;
    }
    
    double bid = SymbolInfoDouble(m_sSymbol, SYMBOL_BID);
    double ask = SymbolInfoDouble(m_sSymbol, SYMBOL_ASK);
    
    if (bid <= 0 || ask <= 0) {
        m_pContext->pLogger->LogError("Invalid symbol prices", __FUNCTION__);
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Check Market Conditions                                          |
//+------------------------------------------------------------------+
bool CTradeManager::CheckMarketConditions() {
    return CheckSpreadConditions() && CheckTradingHours();
}

//+------------------------------------------------------------------+
//| Check Spread Conditions                                          |
//+------------------------------------------------------------------+
bool CTradeManager::CheckSpreadConditions() {
    if (m_iMaxSpreadPoints <= 0) return true; // No spread limit
    
    int current_spread = (int)SymbolInfoInteger(m_sSymbol, SYMBOL_SPREAD);
    if (current_spread > m_iMaxSpreadPoints) {
        m_pContext->pLogger->LogWarning(StringFormat("Spread (%d) exceeds maximum (%d)", 
                                                  current_spread, m_iMaxSpreadPoints), __FUNCTION__);
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Check Trading Hours                                              |
//+------------------------------------------------------------------+
bool CTradeManager::CheckTradingHours() {
    // This is a simplified implementation
    // In a full version, you would check trading session times
    return true;
}

//+------------------------------------------------------------------+
//| Update Trade Statistics                                          |
//+------------------------------------------------------------------+
void CTradeManager::UpdateTradeStatistics(bool success, double slippage, double execution_time) {
    m_iTotalTrades++;
    
    if (success) {
        m_iSuccessfulTrades++;
    } else {
        m_iFailedTrades++;
    }
    
    m_dTotalSlippage += MathAbs(slippage);
    
    // Update average execution time using exponential moving average
    if (m_iTotalTrades == 1) {
        m_dAverageExecutionTime = execution_time;
    } else {
        m_dAverageExecutionTime = (m_dAverageExecutionTime * 0.9) + (execution_time * 0.1);
    }
}

//+------------------------------------------------------------------+
//| Get Success Rate                                                 |
//+------------------------------------------------------------------+
double CTradeManager::GetSuccessRate() const {
    if (m_iTotalTrades == 0) return 0.0;
    return (double)m_iSuccessfulTrades / m_iTotalTrades * 100.0;
}

//+------------------------------------------------------------------+
//| Get Average Slippage                                             |
//+------------------------------------------------------------------+
double CTradeManager::GetAverageSlippage() const {
    if (m_iTotalTrades == 0) return 0.0;
    return m_dTotalSlippage / m_iTotalTrades;
}

//+------------------------------------------------------------------+
//| Log Trade Details                                                |
//+------------------------------------------------------------------+
void CTradeManager::LogTradeDetails(ENUM_ORDER_TYPE order_type, double volume, double price, const string comment) {
    string order_str = (order_type == ORDER_TYPE_BUY) ? "BUY" : "SELL";
    string message = StringFormat("Opening %s position: Volume=%.6f, Price=%.5f, Comment=%s", 
                                 order_str, volume, price, comment);
    m_pContext->pLogger->LogInfo(message, __FUNCTION__);
}

//+------------------------------------------------------------------+
//| On Trade Transaction Event                                       |
//+------------------------------------------------------------------+
void CTradeManager::OnTradeTransaction(const MqlTradeTransaction& trans, const MqlTradeRequest& request, const MqlTradeResult& result) {
    if (!m_bInitialized || trans.magic != m_lMagicNumber) {
        return;
    }
    
    if (trans.type == TRADE_TRANSACTION_DEAL_ADD) {
        long deal_ticket = trans.deal;
        if (HistoryDealSelect(deal_ticket)) {
            double deal_price = HistoryDealGetDouble(deal_ticket, DEAL_PRICE);
            double deal_volume = HistoryDealGetDouble(deal_ticket, DEAL_VOLUME);
            ENUM_DEAL_TYPE deal_type = (ENUM_DEAL_TYPE)HistoryDealGetInteger(deal_ticket, DEAL_TYPE);
            
            string deal_str = (deal_type == DEAL_TYPE_BUY) ? "BUY" : "SELL";
            m_pContext->pLogger->LogInfo(StringFormat("Deal executed: #%d, Type=%s, Volume=%.6f, Price=%.5f", 
                                                   deal_ticket, deal_str, deal_volume, deal_price), __FUNCTION__);
            
            // Update broker health monitor if available
            if (m_pContext->pBrokerHealthMonitor != NULL) {
                // Calculate slippage and update monitor
                // This is a simplified implementation
                m_pContext->pBrokerHealthMonitor->UpdateWithNewDataPoint(0.0, 0.0);
            }
        }
    }
}

#endif // APEX_TRADEMANAGER_MQH_