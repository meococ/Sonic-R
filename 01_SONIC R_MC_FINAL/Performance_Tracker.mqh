//+------------------------------------------------------------------+
//|                Performance_Tracker.mqh - MVP Implementation      |
//|                  APEX Pullback EA v4.6 - Flat Architecture       |
//|      "Namespace removed for global scope compatibility"          |
//+------------------------------------------------------------------+

#ifndef PERFORMANCE_TRACKER_MQH
#define PERFORMANCE_TRACKER_MQH

#include "Core_Defines.mqh"
#include "Core_Logger.mqh"

// Namespace has been removed.

//+------------------------------------------------------------------+
//| Trade Performance Structure                                       |
//+------------------------------------------------------------------+
struct STradePerformance
{
    ulong       ticket;
    double      profit;
    double      volume;
    int         type;           // ORDER_TYPE_BUY or ORDER_TYPE_SELL
    datetime    openTime;
    datetime    closeTime;
    double      pips;
    double      riskReward;
};

//+------------------------------------------------------------------+
//| CPerformanceTracker - Track and analyze trading performance      |
//+------------------------------------------------------------------+
class CPerformanceTracker
{
private:
    bool                    m_initialized;
    CLogger*               m_pLogger;
    
    // Performance data
    STradePerformance      m_trades[];
    int                    m_totalTrades;
    int                    m_winningTrades;
    int                    m_losingTrades;
    double                 m_totalProfit;
    double                 m_totalLoss;
    double                 m_maxProfit;
    double                 m_maxLoss;
    double                 m_maxDrawdown;
    
    // Statistics
    double                 m_winRate;
    double                 m_avgWin;
    double                 m_avgLoss;
    double                 m_profitFactor;
    double                 m_sharpeRatio;
    
public:
    CPerformanceTracker() : m_initialized(false), m_pLogger(NULL),
                           m_totalTrades(0), m_winningTrades(0), m_losingTrades(0),
                           m_totalProfit(0), m_totalLoss(0), m_maxProfit(0), m_maxLoss(0),
                           m_maxDrawdown(0), m_winRate(0), m_avgWin(0), m_avgLoss(0),
                           m_profitFactor(0), m_sharpeRatio(0)
    {
        ArrayResize(m_trades, 0);
    }
    
    ~CPerformanceTracker()
    {
        if(m_pLogger) LOG_INFO("CPerformanceTracker deinitialized");
    }
    
    bool Initialize(CLogger* pLogger)
    {
        if(!pLogger) {
            LOG_ERROR("Invalid logger");
            return false;
        }
        
        m_pLogger = pLogger;
        m_initialized = true;
        
        LOG_INFO("CPerformanceTracker initialized successfully");
        return true;
    }
    
    void Deinitialize()
    {
        if(m_pLogger && m_totalTrades > 0) {
            LOG_INFO(StringFormat("Performance Summary - Trades: %d, Win Rate: %.1f%%, Profit Factor: %.2f",
                              m_totalTrades, m_winRate, m_profitFactor));
        }
        m_initialized = false;
    }
    
    // Add a completed trade to performance tracking
    void AddTrade(ulong ticket, double profit, double volume, int type, datetime openTime)
    {
        if(!m_initialized) return;
        
        // Resize array to accommodate new trade
        int newSize = ArraySize(m_trades) + 1;
        ArrayResize(m_trades, newSize);
        
        // Fill trade data
        STradePerformance &trade = m_trades[newSize - 1];
        trade.ticket = ticket;
        trade.profit = profit;
        trade.volume = volume;
        trade.type = type;
        trade.openTime = openTime;
        trade.closeTime = TimeCurrent();
        
        // Calculate pips (simplified)
        double pointValue = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
        trade.pips = (pointValue > 0) ? profit / (volume * pointValue * 10) : 0;
        
        // Update statistics
        UpdateStatistics();
        
        if(m_pLogger) {
            LOG_INFO(StringFormat("Trade recorded - Ticket: %d, Profit: %.2f, Pips: %.1f",
                              ticket, profit, trade.pips));
        }
    }
    
    // Update all performance statistics
    void UpdateStatistics()
    {
        if(ArraySize(m_trades) == 0) return;
        
        m_totalTrades = ArraySize(m_trades);
        m_winningTrades = 0;
        m_losingTrades = 0;
        m_totalProfit = 0;
        m_totalLoss = 0;
        m_maxProfit = 0;
        m_maxLoss = 0;
        
        // Calculate basic statistics
        for(int i = 0; i < m_totalTrades; i++) {
            double profit = m_trades[i].profit;
            
            if(profit > 0) {
                m_winningTrades++;
                m_totalProfit += profit;
                if(profit > m_maxProfit) m_maxProfit = profit;
            }
            else if(profit < 0) {
                m_losingTrades++;
                m_totalLoss += MathAbs(profit);
                if(MathAbs(profit) > m_maxLoss) m_maxLoss = MathAbs(profit);
            }
        }
        
        // Calculate derived statistics
        m_winRate = (m_totalTrades > 0) ? (double)m_winningTrades / m_totalTrades * 100.0 : 0.0;
        m_avgWin = (m_winningTrades > 0) ? m_totalProfit / m_winningTrades : 0.0;
        m_avgLoss = (m_losingTrades > 0) ? m_totalLoss / m_losingTrades : 0.0;
        m_profitFactor = (m_totalLoss > 0) ? m_totalProfit / m_totalLoss : 0.0;
        
        // Calculate drawdown (simplified)
        CalculateDrawdown();
    }
    
    // Calculate maximum drawdown
    void CalculateDrawdown()
    {
        if(ArraySize(m_trades) < 2) return;
        
        double runningProfit = 0;
        double peak = 0;
        double maxDD = 0;
        
        for(int i = 0; i < ArraySize(m_trades); i++) {
            runningProfit += m_trades[i].profit;
            
            if(runningProfit > peak) {
                peak = runningProfit;
            }
            
            double currentDD = peak - runningProfit;
            if(currentDD > maxDD) {
                maxDD = currentDD;
            }
        }
        
        m_maxDrawdown = maxDD;
    }
    
    // Generate performance report
    string GetPerformanceReport()
    {
        if(!m_initialized) return "Performance Tracker not initialized";
        
        string report = "\n=== PERFORMANCE REPORT ===\n";
        report += StringFormat("Total Trades: %d\n", m_totalTrades);
        report += StringFormat("Winning Trades: %d (%.1f%%)\n", m_winningTrades, m_winRate);
        report += StringFormat("Losing Trades: %d\n", m_losingTrades);
        report += StringFormat("Total Profit: %.2f\n", m_totalProfit - m_totalLoss);
        report += StringFormat("Gross Profit: %.2f\n", m_totalProfit);
        report += StringFormat("Gross Loss: %.2f\n", m_totalLoss);
        report += StringFormat("Profit Factor: %.2f\n", m_profitFactor);
        report += StringFormat("Average Win: %.2f\n", m_avgWin);
        report += StringFormat("Average Loss: %.2f\n", m_avgLoss);
        report += StringFormat("Max Profit: %.2f\n", m_maxProfit);
        report += StringFormat("Max Loss: %.2f\n", m_maxLoss);
        report += StringFormat("Max Drawdown: %.2f\n", m_maxDrawdown);
        report += "=========================";
        
        return report;
    }
    
    // Event handlers
    void OnTimer() 
    {
        // Update statistics periodically
        if(m_initialized && ArraySize(m_trades) > 0) {
            UpdateStatistics();
        }
    }
    
    // Getters
    bool IsInitialized() const { return m_initialized; }
    int GetTotalTrades() const { return m_totalTrades; }
    int GetWinningTrades() const { return m_winningTrades; }
    int GetLosingTrades() const { return m_losingTrades; }
    double GetWinRate() const { return m_winRate; }
    double GetProfitFactor() const { return m_profitFactor; }
    double GetTotalProfit() const { return m_totalProfit - m_totalLoss; }
    double GetMaxDrawdown() const { return m_maxDrawdown; }
    double GetAverageWin() const { return m_avgWin; }
    double GetAverageLoss() const { return m_avgLoss; }
};

// End of namespace removal

#endif // PERFORMANCE_TRACKER_MQH
