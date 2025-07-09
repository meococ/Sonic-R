//+------------------------------------------------------------------+
//|                 TradeManager.mqh - APEX Pullback EA v14.0        |
//|           Author: APEX Trading Team | Date: 2024-07-17           |
//|      Description: Quản lý việc thực thi giao dịch, bao gồm       |
//|        mở, đóng, và sửa đổi lệnh, sử dụng lớp CTrade của MQL5.    |
//+------------------------------------------------------------------+
#ifndef APEX_TRADEMANAGER_MQH_
#define APEX_TRADEMANAGER_MQH_

#include <Trade\Trade.mqh>   // For CTrade class
#include "CommonStructs.mqh" // For EAContext access

namespace ApexPullback
{

//+------------------------------------------------------------------+
//| Manages all trading EXECUTION.                                   |
//| This class does not make decisions. It only executes them.       |
//+------------------------------------------------------------------+
class CTradeManager
{
private:
    // --- State --- 
    bool                m_initialized;      // Initialization flag
private:
    // --- Core Components ---
    EAContext*          m_context;          // Pointer to the global context

    // --- MQL5 Trading Object ---
    CTrade              m_trade;            // MQL5's trading class

    // --- Basic Parameters ---
    string              m_symbol;           // The symbol for trading
    long                m_magic_number;     // The magic number for trades
    int                 m_slippage;         // Allowed slippage in points
    int                 m_max_spread_points; // Maximum allowed spread in points

public:
    // --- Constructor & Destructor ---
                        CTradeManager(void);
                       ~CTradeManager(void);

    // --- Initialization & Deinitialization ---
    bool                Initialize(EAContext* pContext);
    void                Deinitialize(void);

    // --- Core Trading Actions ---
    bool                OpenPosition(ENUM_ORDER_TYPE order_type, double volume, double sl_price, double tp_price, const string comment);
    bool                ClosePosition(long ticket, const string reason, double volume_to_close = 0); // volume=0 means full close
    bool                CloseAllPositions(const string reason);
    bool                ModifyPosition(long ticket, double new_sl_price, double new_tp_price);
    bool                DeletePendingOrder(long ticket, const string reason);

    // --- Event Handling ---
    void                OnTradeTransaction(const MqlTradeTransaction& trans, const MqlTradeRequest& request, const MqlTradeResult& result);

private:
    // --- Pre-flight Checks ---
    bool                IsTradeContextValid(const string calling_function);

    // --- Calculation & Query Helpers ---
    double              NormalizeLots(double lots);
    double              NormalizePrice(double price);
    int                 GetOpenPositionsCount(ENUM_ORDER_TYPE order_type = WRONG_VALUE);
    double              CalculateStopLossPrice(ENUM_ORDER_TYPE order_type, double entry_price, double sl_pips);
    double              CalculateTakeProfitPrice(ENUM_ORDER_TYPE order_type, double entry_price, double tp_pips);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTradeManager::CTradeManager(void) : m_initialized(false),
                                     m_context(NULL),
                                     m_symbol(""),
                                     m_magic_number(0),
                                     m_slippage(10),
                                     m_max_spread_points(0)
{
    // Constructor is light. Initialization in Initialize().
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTradeManager::~CTradeManager(void)
{
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CTradeManager::Deinitialize(void)
{
    if (!m_initialized) return;

    if(m_context && m_context->pLogger)
    {
        m_context->pLogger->LogInfo("TradeManager deinitialized.", __FUNCTION__);
    }
    m_context = NULL;
    m_initialized = false;
}

//+------------------------------------------------------------------+
//| Initialize the trade manager                                     |
//+------------------------------------------------------------------+
bool CTradeManager::Initialize(EAContext* pContext)
{
    m_context = pContext;

    if (!m_context || !m_context->pLogger || !m_context->pErrorHandler || !m_context->pSymbolInfo)
    {
        printf("FATAL: CTradeManager received NULL or incomplete context during initialization.");
        return false;
    }

    m_symbol = m_context->pSymbolInfo->Symbol();
    m_magic_number = m_context->Inputs.MagicNumber;
    m_slippage = m_context->Inputs.Slippage;
    m_max_spread_points = (int)m_context->Inputs.MarketFilters.MaxSpreadPoints;

    m_trade.SetExpertMagicNumber(m_magic_number);
    m_trade.SetMarginMode(); // Use account's default margin mode
    m_trade.SetTypeFillingBySymbol(m_symbol);

    m_context->pLogger->LogInfo("TradeManager initialized for symbol " + m_symbol + " with Magic Number " + (string)m_magic_number, __FUNCTION__);
    m_initialized = true;
    return true;
}

//+------------------------------------------------------------------+
//| Open a new market position                                       |
//+------------------------------------------------------------------+
bool CTradeManager::OpenPosition(ENUM_ORDER_TYPE order_type, double volume, double sl_price, double tp_price, const string comment)
{
    if (!m_initialized || !IsTradeContextValid(__FUNCTION__)) return false;

    // --- Pre-flight checks ---
    m_context->pSymbolInfo->RefreshRates();
    int current_spread = m_context->pSymbolInfo->Spread();
    if (current_spread > m_max_spread_points)
    {
        if(m_context->pErrorHandler) m_context->pErrorHandler->HandleError(ERR_TRADE_HIGH_SPREAD, "OpenPosition", StringFormat("Spread (%d) exceeds max allowed (%d)", current_spread, m_max_spread_points));
        return false;
    }

    double normalized_volume = NormalizeLots(volume);
    if (normalized_volume <= 0)
    {
        if(m_context->pErrorHandler) m_context->pErrorHandler->HandleError(ERR_TRADE_INVALID_VOLUME, "OpenPosition", "Invalid trade volume: " + DoubleToString(volume));
        return false;
    }

    double price = (order_type == ORDER_TYPE_BUY) ? m_context->pSymbolInfo->Ask() : m_context->pSymbolInfo->Bid();

    m_context->pLogger->LogInfo(StringFormat("Attempting to open %s position for %s, Vol: %.2f, Price: %.5f, SL: %.5f, TP: %.5f, Comment: %s",
        EnumToString(order_type), m_symbol, normalized_volume, price, sl_price, tp_price, comment), "OpenPosition");

    // --- Execute Trade --- 
    // We set slippage here specifically for the request
    m_trade.SetDeviationInPoints(m_slippage);
    bool result = m_trade.PositionOpen(m_symbol, order_type, normalized_volume, price, sl_price, tp_price, comment);

    // --- Post-flight analysis --- 
    // The result is now handled by OnTradeTransaction, which will receive the deal details.
    // We only log the immediate synchronous result here.
    if (result)
    {
        m_context->pLogger->LogInfo("Position open request sent successfully. Awaiting transaction confirmation. Result Deal: #" + (string)m_trade.ResultDeal(), "OpenPosition");
    }
    else
    {
        if(m_context->pErrorHandler) m_context->pErrorHandler->HandleError(m_trade.ResultRetcode(), "OpenPosition", "Failed to send position open request: " + m_trade.ResultRetcodeDescription());
    }

    return result;
}

//+------------------------------------------------------------------+
//| Close an existing position (fully or partially)                  |
//+------------------------------------------------------------------+
bool CTradeManager::ClosePosition(long ticket, const string reason, double volume_to_close = 0)
{
    if (!m_initialized || !IsTradeContextValid(__FUNCTION__)) return false;

    if (!PositionSelect(ticket))
    {
        // PositionSelect already logged the error if it failed to find the position
        return false;
    }

    // Double-check if it's our position
    if (m_trade.PositionGetInteger(POSITION_MAGIC) != m_magic_number)
    {
        if(m_context->pLogger) m_context->pLogger->LogWarning("Attempted to close position #" + (string)ticket + " which has a different magic number.", "ClosePosition");
        return false;
    }

    double position_volume = m_trade.PositionGetDouble(POSITION_VOLUME);
    double volume_to_close_normalized = (volume_to_close > 0) ? NormalizeLots(volume_to_close) : position_volume;

    if (volume_to_close_normalized > position_volume)
    {
        if(m_context->pLogger) m_context->pLogger->LogWarning("Volume to close (" + (string)volume_to_close_normalized + ") is greater than position volume (" + (string)position_volume + "). Adjusting to full close.", "ClosePosition");
        volume_to_close_normalized = position_volume;
    }

    if(m_context->pLogger) m_context->pLogger->LogInfo(StringFormat("Attempting to close %.2f lots of position #%d. Reason: %s", volume_to_close_normalized, ticket, reason), "ClosePosition");

    m_trade.SetDeviationInPoints(m_slippage);
    bool result = m_trade.PositionClose(ticket, volume_to_close_normalized);

    if (result)
    {
        if(m_context->pLogger) m_context->pLogger->LogInfo("Position #" + (string)ticket + " close request sent successfully. Awaiting transaction confirmation. Deal: #" + (string)m_trade.ResultDeal(), "ClosePosition");
    }
    else
    {
        if(m_context->pErrorHandler) m_context->pErrorHandler->HandleError(m_trade.ResultRetcode(), "ClosePosition", "Failed to send close request for position #" + (string)ticket + ": " + m_trade.ResultRetcodeDescription());
    }

    return result;
}

//+------------------------------------------------------------------+
//| Close all open positions managed by this EA instance             |
//+------------------------------------------------------------------+
bool CTradeManager::CloseAllPositions(const string reason)
{
    if (!m_initialized || !IsTradeContextValid(__FUNCTION__)) return false;

    int total_positions = PositionsTotal();
    bool all_closed_successfully = true;

    if(m_context->pLogger) m_context->pLogger->LogInfo("Attempting to close all positions. Reason: " + reason, "CloseAllPositions");

    // Iterate backwards because closing positions can change the collection
    for (int i = total_positions - 1; i >= 0; i--)
    {
        ulong ticket = PositionGetTicket(i);
        if (PositionSelectByTicket(ticket))
        {
            if (PositionGetInteger(POSITION_MAGIC) == m_magic_number && PositionGetString(POSITION_SYMBOL) == m_symbol)
            {
                if (!ClosePosition(ticket, reason))
                {
                    all_closed_successfully = false;
                    // Error is already logged by ClosePosition
                }
            }
        }
    }
    return all_closed_successfully;
}

//+------------------------------------------------------------------+
//| Modify SL/TP for an open position                                |
//+------------------------------------------------------------------+
bool CTradeManager::ModifyPosition(long ticket, double new_sl_price, double new_tp_price)
{
    if (!m_initialized || !IsTradeContextValid(__FUNCTION__)) return false;

    if (!m_trade.PositionSelectByTicket(ticket))
    {
        if(m_context && m_context->pLogger) m_context->pLogger->LogError("Failed to select position #" + (string)ticket + " for modification.", "ModifyPosition");
        return false;
    }

    if (m_trade.PositionGetInteger(POSITION_MAGIC) != m_magic_number)
    {
        return false; // Silently ignore positions from other EAs
    }

    double current_sl = m_trade.PositionGetDouble(POSITION_SL);
    double current_tp = m_trade.PositionGetDouble(POSITION_TP);

    // Check if modification is actually needed to avoid unnecessary server calls
    if (m_context && m_context->pSymbolInfo && 
        MathAbs(new_sl_price - current_sl) < m_context->pSymbolInfo->TickSize() &&
        MathAbs(new_tp_price - current_tp) < m_context->pSymbolInfo->TickSize())
    {
        return true; // No significant change needed
    }

    if(m_context && m_context->pLogger) m_context->pLogger->LogInfo(StringFormat("Attempting to modify position #%d: SL from %.5f to %.5f, TP from %.5f to %.5f",
        ticket, current_sl, new_sl_price, current_tp, new_tp_price), "ModifyPosition");

    bool result = m_trade.PositionModify(ticket, new_sl_price, new_tp_price);

    if (result)
    {
        if(m_context && m_context->pLogger) m_context->pLogger->LogInfo("Position #" + (string)ticket + " modified successfully.", "ModifyPosition");
    }
    else
    {
        if(m_context && m_context->pLogger) m_context->pLogger->LogError("Failed to modify position #" + (string)ticket + ". Error: " + (string)m_trade.ResultRetcode() + " - " + m_trade.ResultRetcodeDescription(), "ModifyPosition");
    }

    return result;
}

//+------------------------------------------------------------------+
//| Delete a pending order                                           |
//+------------------------------------------------------------------+
bool CTradeManager::DeletePendingOrder(long ticket, const string reason)
{
    if (!m_initialized || !IsTradeContextValid(__FUNCTION__)) return false;

    if(m_context && m_context->pLogger) m_context->pLogger->LogInfo("Attempting to delete pending order #" + (string)ticket + ". Reason: " + reason, "DeletePendingOrder");

    bool result = m_trade.OrderDelete(ticket);

    if (result)
    {
        if(m_context && m_context->pLogger) m_context->pLogger->LogInfo("Pending order #" + (string)ticket + " deleted successfully.", "DeletePendingOrder");
    }
    else
    {
        if(m_context && m_context->pLogger) m_context->pLogger->LogError("Failed to delete pending order #" + (string)ticket + ". Error: " + (string)m_trade.ResultRetcode() + " - " + m_trade.ResultRetcodeDescription(), "DeletePendingOrder");
    }

    return result;
}

//+------------------------------------------------------------------+
//| Check if the trading context is valid                            |
//+------------------------------------------------------------------+
bool CTradeManager::IsTradeContextValid(const string calling_function)
{
    if (!m_context || !m_context->pLogger || !m_context->pErrorHandler || !m_context->pSymbolInfo)
    {
        // This is a catastrophic failure. We can't even use the logger/error handler.
        printf("FATAL: CTradeManager has NULL context or critical components in %s. EA cannot continue.", calling_function);
        return false;
    }

    // 1. Check Server Connection & Trade Permissions
    if (!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) || !MQLInfoInteger(MQL_TRADE_ALLOWED))
    {
        // Use ErrorHandler for critical errors
        m_context->pErrorHandler->HandleError(ERR_TRADE_CONTEXT_INVALID, calling_function, "Trading is not allowed by terminal or MQL settings.");
        return false;
    }

    // 2. Check for valid prices (moved before spread check)
    m_context->pSymbolInfo->RefreshRates();
    if (m_context->pSymbolInfo->Bid() <= 0 || m_context->pSymbolInfo->Ask() <= 0)
    {
        m_context->pErrorHandler->HandleError(ERR_TRADE_CONTEXT_INVALID, calling_function, "Market prices are zero or negative.");
        return false;
    }

    // 3. Spread check is now done inside OpenPosition to be more contextual

    return true;
}

//+------------------------------------------------------------------+
//| Normalize lot size to be compliant with symbol specification     |
//+------------------------------------------------------------------+
double CTradeManager::NormalizeLots(double lots)
{
    if (!m_context || !m_context->pSymbolInfo) return 0.0;

    double volume_step = m_context->pSymbolInfo->VolumeStep();
    double min_volume = m_context->pSymbolInfo->VolumeMin();
    double max_volume = m_context->pSymbolInfo->VolumeMax();

    // Ensure volume_step is not zero to prevent division by zero error
    if (volume_step <= 0)
    {
        if(m_context->pLogger) m_context->pLogger->LogError("Invalid volume_step: " + (string)volume_step + ". Cannot normalize lots.", "NormalizeLots");
        return 0.0;
    }

    double normalized_lots = MathRound(lots / volume_step) * volume_step;

    // Clamp the value within the min/max limits
    if (normalized_lots < min_volume && lots > 0) normalized_lots = min_volume;
    if (normalized_lots > max_volume) normalized_lots = max_volume;

    return normalized_lots;
}

//+------------------------------------------------------------------+
//| Lấy số lượng vị thế đang mở theo loại                             |
//+------------------------------------------------------------------+
int CTradeManager::GetOpenPositionsCount(ENUM_ORDER_TYPE order_type = WRONG_VALUE)
{
    if (!m_context) return 0;
    int count = 0;
    for(int i = (int)PositionsTotal() - 1; i >= 0; i--)
    {
        if(m_trade.PositionSelectByIndex(i)) // Select by index
        {
            if(m_trade.PositionGetInteger(POSITION_MAGIC) == m_magic_number && m_trade.PositionGetString(POSITION_SYMBOL) == m_symbol)
            {
                if(order_type == WRONG_VALUE || (ENUM_ORDER_TYPE)m_trade.PositionGetInteger(POSITION_TYPE) == order_type)
                {
                    count++;
                }
            }
        }
    }
    return count;
}

//+------------------------------------------------------------------+
//| Tính toán giá Stop Loss                                          |
//+------------------------------------------------------------------+
double CTradeManager::CalculateStopLossPrice(ENUM_ORDER_TYPE order_type, double entry_price, double sl_pips)
{
    if (sl_pips <= 0 || !m_context || !m_context->pSymbolInfo) return 0.0;
    double pips_value = sl_pips * m_context->pSymbolInfo->Point();
    double sl_price = (order_type == ORDER_TYPE_BUY) ? entry_price - pips_value : entry_price + pips_value;
    return NormalizePrice(sl_price);
}

//+------------------------------------------------------------------+
//| Tính toán giá Take Profit                                        |
//+------------------------------------------------------------------+
double CTradeManager::CalculateTakeProfitPrice(ENUM_ORDER_TYPE order_type, double entry_price, double tp_pips)
{
    if (tp_pips <= 0 || !m_context || !m_context->pSymbolInfo) return 0.0;
    double pips_value = tp_pips * m_context->pSymbolInfo->Point();
    double tp_price = (order_type == ORDER_TYPE_BUY) ? entry_price + pips_value : entry_price - pips_value;
    return NormalizePrice(tp_price);
}

//+------------------------------------------------------------------+
//| Event Handler for Trade Transactions                             |
//+------------------------------------------------------------------+
void CTradeManager::OnTradeTransaction(const MqlTradeTransaction& trans, const MqlTradeRequest& request, const MqlTradeResult& result)
{
    if (!m_initialized || !IsTradeContextValid(__FUNCTION__)) return;

    // We are only interested in transactions for our magic number
    if (trans.magic != m_magic_number)
    {
        return;
    }

    // We only care about completed deals (additions to history)
    if (trans.type != TRADE_TRANSACTION_DEAL_ADD)
    {
        return;
    }

    long deal_ticket = trans.deal;
    if (!HistoryDealSelect(deal_ticket))
    {
        m_context->pErrorHandler->HandleError(ERR_HISTORY_DEAL_NOT_FOUND, "OnTradeTransaction", "Could not select deal #" + (string)deal_ticket);
        return;
    }

    // --- Gather Deal Information ---
    long order_ticket = HistoryDealGetInteger(deal_ticket, DEAL_ORDER);
    long position_ticket = HistoryDealGetInteger(deal_ticket, DEAL_POSITION_ID);
    ENUM_DEAL_TYPE deal_type = (ENUM_DEAL_TYPE)HistoryDealGetInteger(deal_ticket, DEAL_TYPE);
    double deal_price = HistoryDealGetDouble(deal_ticket, DEAL_PRICE);
    double deal_volume = HistoryDealGetDouble(deal_ticket, DEAL_VOLUME);
    long deal_time_msc = HistoryDealGetInteger(deal_ticket, DEAL_TIME_MSC);

    // --- Gather Order Information for Slippage/Latency Calculation ---
    if (!HistoryOrderSelect(order_ticket))
    {
        m_context->pErrorHandler->HandleError(ERR_HISTORY_ORDER_NOT_FOUND, "OnTradeTransaction", "Could not select parent order #" + (string)order_ticket + " for deal #" + (string)deal_ticket);
        return;
    }

    double order_price = HistoryOrderGetDouble(order_ticket, ORDER_PRICE_OPEN);
    long order_time_msc = HistoryOrderGetInteger(order_ticket, ORDER_TIME_SETUP_MSC);

    // --- Calculate Slippage and Latency ---
    double slippage_points = 0;
    if (deal_type == DEAL_TYPE_BUY)
    {
        slippage_points = (deal_price - order_price) / m_context->pSymbolInfo->Point();
    }
    else if (deal_type == DEAL_TYPE_SELL)
    {
        slippage_points = (order_price - deal_price) / m_context->pSymbolInfo->Point();
    }

    double slippage_pips = slippage_points / m_context->pSymbolInfo->PipToPointRatio();
    long execution_time_ms = (long)(deal_time_msc - order_time_msc);

    // --- Log and Update Monitors ---
    m_context->pLogger->LogInfo(StringFormat("DEAL CONFIRMED: #%d for Pos #%d. Type: %s, Vol: %.2f, Price: %.5f, Slippage: %.2f pips, Latency: %d ms",
        deal_ticket, position_ticket, EnumToString(deal_type), deal_volume, deal_price, slippage_pips, execution_time_ms), "OnTradeTransaction");

    // Feed the data to the Broker Health Monitor
    if(m_context->pBrokerHealthMonitor)
    {
        m_context->pBrokerHealthMonitor->UpdateWithNewDataPoint(slippage_pips, (double)execution_time_ms);
    }

    // Notify RiskManager about the confirmed deal for statistical updates
    if(m_context->pRiskManager)
    {
        m_context->pRiskManager->OnDealExecuted(deal_ticket);
    }
}

//+------------------------------------------------------------------+
//| Normalize price to be compliant with symbol digits               |
//+------------------------------------------------------------------+
double CTradeManager::NormalizePrice(double price)
{
    if (!m_context || !m_context->pSymbolInfo) return price;
    return NormalizeDouble(price, (int)m_context->pSymbolInfo->Digits());
}

} // END NAMESPACE ApexPullback
#endif // TRADEMANAGER_MQH_