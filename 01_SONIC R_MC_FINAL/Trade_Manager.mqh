//+------------------------------------------------------------------+
//|                                               Trade_Manager.mqh |
//|                        APEX Pullback EA v5 - Trade Management   |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, APEX Trading Systems"
#property link      "https://apex-trading.com"
#property version   "5.00"

#include "Core_Defines.mqh"
#include "Core_Context.mqh"
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>

//+------------------------------------------------------------------+
//| Trade Manager Class                                              |
//+------------------------------------------------------------------+
class CTradeManager {
private:
    CEaContext*         m_pContext; // Pointer to the global EA context
    CTrade              m_trade;
    CSymbolInfo         m_symbolInfo;
    CPositionInfo       m_positionInfo;
    COrderInfo          m_orderInfo;
    
    // Trade settings
    string              m_symbol;
    double              m_lotSize;
    int                 m_slippage;
    int                 m_magicNumber;
    string              m_comment;
    
    // Risk management
    double              m_maxRiskPercent;
    double              m_maxLotSize;
    double              m_minLotSize;
    
    // Trade statistics
    int                 m_totalTrades;
    int                 m_winningTrades;
    int                 m_losingTrades;
    double              m_totalProfit;
    double              m_totalLoss;
    
    bool                m_isInitialized;
    
public:
    // Constructor
    CTradeManager() {
        m_pContext = NULL;
        m_symbol = "";
        m_lotSize = 0.01;
        m_slippage = 3;
        m_magicNumber = 12345;
        m_comment = "APEX_EA";
        m_maxRiskPercent = 2.0;
        m_maxLotSize = 10.0;
        m_minLotSize = 0.01;
        m_totalTrades = 0;
        m_winningTrades = 0;
        m_losingTrades = 0;
        m_totalProfit = 0.0;
        m_totalLoss = 0.0;
        m_isInitialized = false;
    }
    
    // Destructor
    ~CTradeManager() {
        // Cleanup if needed
    }
    
    // Initialize trade manager
    bool Initialize(CEaContext* context) {
        m_pContext = context;
        if (!m_pContext) return false;

        m_symbol = m_pContext->pSymbol->Symbol();
        m_magicNumber = m_pContext->pSettings->MagicNumber();
        
        // Initialize symbol info
        if(!m_symbolInfo.Name(m_symbol)) {
            if(m_pContext && m_pContext->pLogger) m_pContext->pLogger->LogError("Failed to initialize symbol: " + m_symbol, __FUNCTION__);
            return false;
        }
        
        // Set trade parameters
        m_trade.SetExpertMagicNumber(m_magicNumber);
        m_trade.SetMarginMode();
        m_trade.SetTypeFillingBySymbol(m_symbol);
        m_trade.SetDeviationInPoints(m_slippage);
        
        // Refresh symbol info
        if(!m_symbolInfo.RefreshRates()) {
            if(m_pContext && m_pContext->pLogger) m_pContext->pLogger->LogError("Failed to refresh rates for: " + m_symbol, __FUNCTION__);
            return false;
        }
        
        m_isInitialized = true;
        
        if(m_pContext && m_pContext->pLogger) m_pContext->pLogger->LogInfo("Trade Manager initialized for " + m_symbol, __FUNCTION__);
        if(m_pContext && m_pContext->pLogger) m_pContext->pLogger->LogInfo("Magic Number: " + IntegerToString(m_magicNumber), __FUNCTION__);
        
        return true;
    }
    
    // Open buy position
    bool OpenBuy(double volume, double price = 0.0, double sl = 0.0, double tp = 0.0, string comment = "") {
        if(!m_isInitialized) {
            if(m_pContext && m_pContext->pLogger) m_pContext->pLogger->LogError("Trade Manager not initialized", __FUNCTION__);
            return false;
        }
        
        // Validate volume
        volume = NormalizeVolume(volume);
        if(volume <= 0) {
            if(m_pContext && m_pContext->pLogger) m_pContext->pLogger->LogError("Invalid volume: " + DoubleToString(volume, 2), __FUNCTION__);
            return false;
        }
        
        // Use market price if not specified
        if(price <= 0.0) {
            price = m_symbolInfo.Ask();
        }
        
        // Normalize prices
        price = m_symbolInfo.NormalizePrice(price);
        if(sl > 0) sl = m_symbolInfo.NormalizePrice(sl);
        if(tp > 0) tp = m_symbolInfo.NormalizePrice(tp);
        
        // Set comment
        string tradeComment = (comment == "") ? m_comment : comment;
        
        // Execute trade
        bool result = m_trade.Buy(volume, m_symbol, price, sl, tp, tradeComment);
        
        if(result) {
            m_totalTrades++;
            if(m_pContext && m_pContext->pLogger) m_pContext->pLogger->LogTrade("BUY", m_symbol, volume, price, tradeComment);
            if(m_pContext && m_pContext->pLogger) m_pContext->pLogger->LogInfo("Buy order executed successfully. Ticket: " + IntegerToString(m_trade.ResultOrder()), __FUNCTION__);
        } else {
            if(m_pContext && m_pContext->pLogger) m_pContext->pLogger->LogError("Failed to open buy position. Error: " + IntegerToString(GetLastError()), __FUNCTION__);
            if(m_pContext && m_pContext->pLogger) m_pContext->pLogger->LogError("Trade result: " + IntegerToString(m_trade.ResultRetcode()) + " - " + m_trade.ResultComment(), __FUNCTION__);
        }
        
        return result;
    }
    
    // Open sell position
    bool OpenSell(double volume, double price = 0.0, double sl = 0.0, double tp = 0.0, string comment = "") {
        if(!m_isInitialized) {
            if(m_pContext && m_pContext->pLogger) m_pContext->pLogger->LogError("Trade Manager not initialized", __FUNCTION__);
            return false;
        }
        
        // Validate volume
        volume = NormalizeVolume(volume);
        if(volume <= 0) {
            if(m_pContext && m_pContext->pLogger) m_pContext->pLogger->LogError("Invalid volume: " + DoubleToString(volume, 2), __FUNCTION__);
            return false;
        }
        
        // Use market price if not specified
        if(price <= 0.0) {
            price = m_symbolInfo.Bid();
        }
        
        // Normalize prices
        price = m_symbolInfo.NormalizePrice(price);
        if(sl > 0) sl = m_symbolInfo.NormalizePrice(sl);
        if(tp > 0) tp = m_symbolInfo.NormalizePrice(tp);
        
        // Set comment
        string tradeComment = (comment == "") ? m_comment : comment;
        
        // Execute trade
        bool result = m_trade.Sell(volume, m_symbol, price, sl, tp, tradeComment);
        
        if(result) {
            m_totalTrades++;
            if(m_pContext && m_pContext->pLogger) m_pContext->pLogger->LogTrade("SELL", m_symbol, volume, price, tradeComment);
            if(m_pContext && m_pContext->pLogger) m_pContext->pLogger->LogInfo("Sell order executed successfully. Ticket: " + IntegerToString(m_trade.ResultOrder()), __FUNCTION__);
        } else {
            if(m_pContext && m_pContext->pLogger) m_pContext->pLogger->LogError("Failed to open sell position. Error: " + IntegerToString(GetLastError()), __FUNCTION__);
            if(m_pContext && m_pContext->pLogger) m_pContext->pLogger->LogError("Trade result: " + IntegerToString(m_trade.ResultRetcode()) + " - " + m_trade.ResultComment(), __FUNCTION__);
        }
        
        return result;
    }

    // Execute a trade based on a signal
    bool ExecuteTrade(const SSignalInfo &signal, double volume) {
        if(signal.Direction == SIGNAL_TYPE_BUY) {
            return OpenBuy(volume, 0, signal.StopLoss, signal.TakeProfit, signal.Comment);
        }
        if(signal.Direction == SIGNAL_TYPE_SELL) {
            return OpenSell(volume, 0, signal.StopLoss, signal.TakeProfit, signal.Comment);
        }
        return false;
    }

    // Manage all open positions
    void ManagePositions() {
        // This is a placeholder for more complex position management logic,
        // such as trailing stops, breakeven, etc.
    }
    
    // Close position by ticket
    bool ClosePosition(ulong ticket) {
        if(!m_positionInfo.SelectByTicket(ticket)) {
            if(m_logger) m_logger->LogError("Position not found: " + IntegerToString(ticket), __FUNCTION__);
            return false;
        }
        
        bool result = m_trade.PositionClose(ticket);
        
        if(result) {
            if(m_logger) {
                m_logger->LogInfo("Position closed successfully. Ticket: " + IntegerToString(ticket), __FUNCTION__);
            }
        } else {
            if(m_logger) {
                m_logger->LogError("Failed to close position: " + IntegerToString(ticket), __FUNCTION__);
                m_logger->LogError("Trade result: " + IntegerToString(m_trade.ResultRetcode()) + " - " + m_trade.ResultComment(), __FUNCTION__);
            }
        }
        
        return result;
    }
    
    // Close all positions for this symbol and magic number
    int CloseAllPositions() {
        int closedCount = 0;
        
        for(int i = PositionsTotal() - 1; i >= 0; i--) {
            if(m_positionInfo.SelectByIndex(i)) {
                if(m_positionInfo.Symbol() == m_symbol && m_positionInfo.Magic() == m_magicNumber) {
                    if(ClosePosition(m_positionInfo.Ticket())) {
                        closedCount++;
                    }
                }
            }
        }
        
        if(m_logger && closedCount > 0) {
            m_logger.LogInfo("Closed " + IntegerToString(closedCount) + " positions", __FUNCTION__);
        }
        
        return closedCount;
    }
    
    // Modify position
    bool ModifyPosition(ulong ticket, double sl, double tp) {
        if(!m_positionInfo.SelectByTicket(ticket)) {
            if(m_logger) m_logger->LogError("Position not found: " + IntegerToString(ticket), __FUNCTION__);
            return false;
        }
        
        // Normalize prices
        if(sl > 0) sl = m_symbolInfo.NormalizePrice(sl);
        if(tp > 0) tp = m_symbolInfo.NormalizePrice(tp);
        
        bool result = m_trade.PositionModify(ticket, sl, tp);
        
        if(result) {
            if(m_logger) {
                m_logger->LogInfo("Position modified. Ticket: " + IntegerToString(ticket) + 
                               ", SL: " + DoubleToString(sl, _Digits) + 
                               ", TP: " + DoubleToString(tp, _Digits), __FUNCTION__);
            }
        } else {
            if(m_logger) {
                m_logger->LogError("Failed to modify position: " + IntegerToString(ticket), __FUNCTION__);
                m_logger->LogError("Trade result: " + IntegerToString(m_trade.ResultRetcode()) + " - " + m_trade.ResultComment(), __FUNCTION__);
            }
        }
        
        return result;
    }
    
    // Calculate position size based on risk
    double CalculatePositionSize(double riskPercent, double entryPrice, double stopLoss) {
        if(riskPercent <= 0 || entryPrice <= 0 || stopLoss <= 0) {
            return m_minLotSize;
        }
        
        double balance = AccountInfoDouble(ACCOUNT_BALANCE);
        double riskAmount = balance * (riskPercent / 100.0);
        
        double pointValue = m_symbolInfo.TickValue();
        double stopLossPoints = MathAbs(entryPrice - stopLoss) / m_symbolInfo.Point();
        
        double lotSize = riskAmount / (stopLossPoints * pointValue);
        
        // Normalize and validate lot size
        lotSize = NormalizeVolume(lotSize);
        
        if(m_logger) {
            m_logger.LogDebug("Position size calculation: Risk=" + DoubleToString(riskPercent, 2) + 
                            "%, Amount=" + DoubleToString(riskAmount, 2) + 
                            ", Lots=" + DoubleToString(lotSize, 2), __FUNCTION__);
        }
        
        return lotSize;
    }
    
    // Normalize volume according to symbol specifications
    double NormalizeVolume(double volume) {
        double minLot = m_symbolInfo.LotsMin();
        double maxLot = m_symbolInfo.LotsMax();
        double stepLot = m_symbolInfo.LotsStep();
        
        if(volume < minLot) volume = minLot;
        if(volume > maxLot) volume = maxLot;
        if(volume > m_maxLotSize) volume = m_maxLotSize;
        
        // Round to step
        volume = MathRound(volume / stepLot) * stepLot;
        
        return volume;
    }
    
    // Get current positions count
    int GetPositionsCount() {
        int count = 0;
        
        for(int i = 0; i < PositionsTotal(); i++) {
            if(m_positionInfo.SelectByIndex(i)) {
                if(m_positionInfo.Symbol() == m_symbol && m_positionInfo.Magic() == m_magicNumber) {
                    count++;
                }
            }
        }
        
        return count;
    }
    
    // Get total profit of open positions
    double GetTotalProfit() {
        double totalProfit = 0.0;
        
        for(int i = 0; i < PositionsTotal(); i++) {
            if(m_positionInfo.SelectByIndex(i)) {
                if(m_positionInfo.Symbol() == m_symbol && m_positionInfo.Magic() == m_magicNumber) {
                    totalProfit += m_positionInfo.Profit();
                }
            }
        }
        
        return totalProfit;
    }
    
    // Check if trading is allowed
    bool IsTradingAllowed() {
        if(!m_isInitialized) return false;
        
        // Check if trading is allowed for the account
        if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)) {
            if(m_logger) m_logger.LogWarning("Trading not allowed for account", __FUNCTION__);
            return false;
        }
        
        // Check if trading is allowed for the symbol
        if(!m_symbolInfo.IsTradingAllowed()) {
            if(m_logger) m_logger.LogWarning("Trading not allowed for symbol: " + m_symbol, __FUNCTION__);
            return false;
        }
        
        // Check market hours
        if(!m_symbolInfo.IsTradeAllowed()) {
            if(m_logger) m_logger.LogWarning("Market closed for symbol: " + m_symbol, __FUNCTION__);
            return false;
        }
        
        return true;
    }
    
    // Getters
    bool IsInitialized() const { return m_isInitialized; }
    string GetSymbol() const { return m_symbol; }
    int GetMagicNumber() const { return m_magicNumber; }
    int GetTotalTrades() const { return m_totalTrades; }
    int GetWinningTrades() const { return m_winningTrades; }
    int GetLosingTrades() const { return m_losingTrades; }
    double GetTotalProfitAmount() const { return m_totalProfit; }
    double GetTotalLossAmount() const { return m_totalLoss; }
    
    // Setters
    void SetLotSize(double lotSize) { m_lotSize = NormalizeVolume(lotSize); }
    void SetSlippage(int slippage) { m_slippage = slippage; m_trade.SetDeviationInPoints(slippage); }
    void SetComment(string comment) { m_comment = comment; }
    void SetMaxRisk(double riskPercent) { m_maxRiskPercent = riskPercent; }
    void SetMaxLotSize(double maxLot) { m_maxLotSize = maxLot; }
};

//+------------------------------------------------------------------+
//| Trade Manager Utility Functions                                 |
//+------------------------------------------------------------------+

// Quick position check
bool HasOpenPositions(string symbol, int magicNumber) {
    CPositionInfo posInfo;
    
    for(int i = 0; i < PositionsTotal(); i++) {
        if(posInfo.SelectByIndex(i)) {
            if(posInfo.Symbol() == symbol && posInfo.Magic() == magicNumber) {
                return true;
            }
        }
    }
    
    return false;
}

// Get position type
ENUM_POSITION_TYPE GetPositionType(string symbol, int magicNumber) {
    CPositionInfo posInfo;
    
    for(int i = 0; i < PositionsTotal(); i++) {
        if(posInfo.SelectByIndex(i)) {
            if(posInfo.Symbol() == symbol && posInfo.Magic() == magicNumber) {
                return posInfo.PositionType();
            }
        }
    }
    
    return WRONG_VALUE;
}

//+------------------------------------------------------------------+