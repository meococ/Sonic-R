#pragma once

//+------------------------------------------------------------------+
//|              TradeHistoryOptimizer.mqh - APEX Pullback EA v14.0 |
//|                           Copyright 2023-2024, APEX Forex        |
//|                             https://www.apexpullback.com         |
//+------------------------------------------------------------------+
#ifndef TRADEHISTORYOPTIMIZER_MQH_
#define TRADEHISTORYOPTIMIZER_MQH_

#include "CommonStructs.mqh"

namespace ApexPullback {

// Forward declaration
class CLogger;

//+------------------------------------------------------------------+
//| Cấu trúc thống kê giao dịch tóm tắt                             |
//+------------------------------------------------------------------+
struct TradeStatsSummary {
    int totalTrades;      
    int winningTrades;    
    int losingTrades;     
    double totalProfit;   
    double totalLoss;     
    double winRate;       
    double profitFactor;  
    double averageWin;    
    double averageLoss;   
    double maxWin;        
    double maxLoss;       
    double maxDrawdown;   
    
    TradeStatsSummary() {
        totalTrades = 0;
        winningTrades = 0;
        losingTrades = 0;
        totalProfit = 0.0;
        totalLoss = 0.0;
        winRate = 0.0;
        profitFactor = 0.0;
        averageWin = 0.0;
        averageLoss = 0.0;
        maxWin = 0.0;
        maxLoss = 0.0;
        maxDrawdown = 0.0;
    }
};

//+------------------------------------------------------------------+
//| Cấu trúc giao dịch đơn giản                                     |
//+------------------------------------------------------------------+
struct SimpleTrade {
    ulong ticket;         
    datetime openTime;    
    datetime closeTime;   
    double profit;        
    double volume;        
    string symbol;        
    int type;             
    
    SimpleTrade() {
        ticket = 0;
        openTime = 0;
        closeTime = 0;
        profit = 0.0;
        volume = 0.0;
        symbol = "";
        type = -1;
    }
};

//+------------------------------------------------------------------+
//| Cấu trúc lưu trữ ma trận hiệu suất                              |
//+------------------------------------------------------------------+
struct PerformanceMatrix {
    TradeStatsSummary stats[ENUM_TRADING_STRATEGY_COUNT][ENUM_MARKET_REGIME_COUNT];

    void Initialize() {
        for(int i = 0; i < ENUM_TRADING_STRATEGY_COUNT; i++) {
            for(int j = 0; j < ENUM_MARKET_REGIME_COUNT; j++) {
                stats[i][j] = TradeStatsSummary();
            }
        }
    }
};

//+------------------------------------------------------------------+
//| Lớp tối ưu hóa phân tích lịch sử giao dịch                      |
//+------------------------------------------------------------------+
class CTradeHistoryOptimizer {
private:
    EAContext* m_context;  
    bool m_EnableOptimization;
    int m_MaxTradesAnalyze;       
    int m_MaxDaysAnalyze;         
    bool m_QuickAnalysisMode;     
    bool m_CacheResults;          
    string m_CacheFile;           
    
    SimpleTrade m_RecentTrades[]; 
    TradeStatsSummary m_CachedStats; 
    datetime m_LastCacheUpdate;   
    
public:
    CTradeHistoryOptimizer(EAContext* context);
    ~CTradeHistoryOptimizer();
    
    bool Initialize(bool enableOptimization = true); 
    bool AnalyzePerformanceByContext(PerformanceMatrix &matrix);

private:
    void Cleanup();
    bool LoadTradeHistoryOptimized(int maxTrades = 1000, int maxDays = 30);
    bool LoadTradesFromHistory(datetime fromDate, datetime toDate, int maxTrades);
    bool LoadTradesQuick(int maxTrades);
    void CalculateStatistics();
    string GetCacheFileName();
    bool IsCacheValid(int maxAgeMinutes = 60);
    bool SaveStatsToCache();
    bool LoadStatsFromCache();
    void ClearCache();
};

// Hàm này nên là một phần của một lớp tiện ích hoặc của chính CTradeHistoryOptimizer
// để truy cập vào context một cách an toàn.
ENUM_MARKET_REGIME GetMarketRegimeAtTime(datetime time) {
    // Implementation will be moved inside the class or a utility class
    // For now, just return a default value to allow compilation
    return REGIME_UNDEFINED;
}

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTradeHistoryOptimizer::CTradeHistoryOptimizer(EAContext* context) : m_context(context) {
    m_EnableOptimization = true;
    m_MaxTradesAnalyze = 1000;
    m_MaxDaysAnalyze = 30;
    m_QuickAnalysisMode = true;
    m_CacheResults = true;
    m_CacheFile = "trade_stats_cache.dat";
    m_LastCacheUpdate = 0;
    ArrayResize(m_RecentTrades, 0);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTradeHistoryOptimizer::~CTradeHistoryOptimizer() {
    Cleanup();
}

//+------------------------------------------------------------------+
//| Khởi tạo                                                        |
//+------------------------------------------------------------------+
bool CTradeHistoryOptimizer::Initialize(bool enableOptimization = true) {
    if (m_context.Logger == NULL) {
        printf("Error: Logger is NULL in CTradeHistoryOptimizer::Initialize");
        return false;
    }

    m_EnableOptimization = enableOptimization;
    m_context.Logger->LogInfo(StringFormat("TradeHistoryOptimizer initialized - Optimization: %s", m_EnableOptimization ? "Enabled" : "Disabled"));
    
    if (m_CacheResults && IsCacheValid()) {
        LoadStatsFromCache();
    }
    return true;
}

//+------------------------------------------------------------------+
//| Dọn dẹp                                                          |
//+------------------------------------------------------------------+
void CTradeHistoryOptimizer::Cleanup() {
    if (m_CacheResults && ArraySize(m_RecentTrades) > 0) {
        SaveStatsToCache();
    }
    ArrayFree(m_RecentTrades);
    if (m_context.Logger) {
        m_context.Logger->LogInfo("TradeHistoryOptimizer cleanup completed");
    }
}

//+------------------------------------------------------------------+
//| Phân tích hiệu suất dựa trên bối cảnh                           |
//+------------------------------------------------------------------+
bool CTradeHistoryOptimizer::AnalyzePerformanceByContext(PerformanceMatrix &matrix) {
    if (!m_context.Logger) return false;

    m_context.Logger->LogInfo("Starting performance analysis by context...");
    matrix.Initialize();

    if (!HistorySelect(0, TimeCurrent())) {
        m_context.Logger->LogError("Failed to select trade history!");
        return false;
    }

    int totalDeals = HistoryDealsTotal();
    for (int i = 0; i < totalDeals; i++) {
        long deal_ticket = HistoryDealGetTicket(i);
        if (deal_ticket <= 0) continue;

        if (HistoryDealGetInteger(deal_ticket, DEAL_MAGIC) != m_context->MagicNumber) continue;
        if (HistoryDealGetInteger(deal_ticket, DEAL_ENTRY) != DEAL_ENTRY_OUT) continue;

        datetime closeTime = (datetime)HistoryDealGetInteger(deal_ticket, DEAL_TIME);
        double profit = HistoryDealGetDouble(deal_ticket, DEAL_PROFIT);
        
        ENUM_TRADING_STRATEGY strategy = STRATEGY_PULLBACK_TREND; // Placeholder
        ENUM_MARKET_REGIME regime = GetMarketRegimeAtTime(m_context, closeTime);

        if (strategy == STRATEGY_UNDEFINED || regime == REGIME_UNDEFINED) continue;

        TradeStatsSummary &stats = matrix.stats[strategy][regime];
        stats.totalTrades++;
        if (profit > 0) {
            stats.winningTrades++;
            stats.totalProfit += profit;
            if(profit > stats.maxWin) stats.maxWin = profit;
        } else if (profit < 0) {
            stats.losingTrades++;
            stats.totalLoss += profit;
            if(profit < stats.maxLoss) stats.maxLoss = profit;
        }
    }

    for (int i = 0; i < ENUM_TRADING_STRATEGY_COUNT; i++) {
        for (int j = 0; j < ENUM_MARKET_REGIME_COUNT; j++) {
            TradeStatsSummary &stats = matrix.stats[i][j];
            if (stats.totalTrades > 0) {
                stats.winRate = (double)stats.winningTrades / stats.totalTrades * 100.0;
                double totalLossAbs = MathAbs(stats.totalLoss);
                stats.profitFactor = (totalLossAbs > 0) ? stats.totalProfit / totalLossAbs : 0;
                stats.averageWin = (stats.winningTrades > 0) ? stats.totalProfit / stats.winningTrades : 0;
                stats.averageLoss = (stats.losingTrades > 0) ? stats.totalLoss / stats.losingTrades : 0;
            }
        }
    }

    m_context->Logger->LogInfo("Performance analysis by context finished.");
    return true;
}

//+------------------------------------------------------------------+
//| Tải lịch sử giao dịch                                           |
//+------------------------------------------------------------------+
bool CTradeHistoryOptimizer::LoadTradesFromHistory(datetime fromDate, datetime toDate, int maxTrades) {
    if (!HistorySelect(fromDate, toDate)) {
        if (m_context && m_context->Logger) m_context->Logger->LogError("Failed to select history");
        return false;
    }

    ArrayFree(m_RecentTrades);
    int totalDeals = HistoryDealsTotal();
    int tradesLoaded = 0;

    for (int i = totalDeals - 1; i >= 0; i--) {
        long deal_ticket = HistoryDealGetTicket(i);
        if (deal_ticket <= 0) continue;
        if (HistoryDealGetInteger(deal_ticket, DEAL_MAGIC) != m_context->MagicNumber) continue;
        if (HistoryDealGetInteger(deal_ticket, DEAL_ENTRY) != DEAL_ENTRY_OUT) continue;

        SimpleTrade trade;
        trade.ticket = (ulong)deal_ticket;
        trade.closeTime = (datetime)HistoryDealGetInteger(deal_ticket, DEAL_TIME);
        trade.profit = HistoryDealGetDouble(deal_ticket, DEAL_PROFIT);
        trade.symbol = HistoryDealGetString(deal_ticket, DEAL_SYMBOL);
        trade.volume = HistoryDealGetDouble(deal_ticket, DEAL_VOLUME);
        trade.type = (int)HistoryDealGetInteger(deal_ticket, DEAL_TYPE);

        ArrayInsert(m_RecentTrades, trade, 0);
        tradesLoaded++;

        if (maxTrades > 0 && tradesLoaded >= maxTrades) break;
    }
    return true;
}

//+------------------------------------------------------------------+
//| Tính toán thống kê                                              |
//+------------------------------------------------------------------+
void CTradeHistoryOptimizer::CalculateStatistics() {
    int totalTrades = ArraySize(m_RecentTrades);
    if (totalTrades == 0) return;

    m_CachedStats = TradeStatsSummary();
    double balance = 0, peak = 0;

    for (int i = 0; i < totalTrades; i++) {
        SimpleTrade &trade = m_RecentTrades[i];
        m_CachedStats.totalTrades++;
        if (trade.profit > 0) {
            m_CachedStats.winningTrades++;
            m_CachedStats.totalProfit += trade.profit;
        } else {
            m_CachedStats.losingTrades++;
            m_CachedStats.totalLoss += trade.profit;
        }
        balance += trade.profit;
        if (balance > peak) peak = balance;
        double drawdown = peak - balance;
        if (drawdown > m_CachedStats.maxDrawdown) {
            m_CachedStats.maxDrawdown = drawdown;
        }
    }

    if (m_CachedStats.totalTrades > 0) {
        m_CachedStats.winRate = (double)m_CachedStats.winningTrades / m_CachedStats.totalTrades * 100.0;
        double totalLossAbs = MathAbs(m_CachedStats.totalLoss);
        m_CachedStats.profitFactor = (totalLossAbs > 0) ? m_CachedStats.totalProfit / totalLossAbs : 0;
    }
}

//+------------------------------------------------------------------+
//| Lấy tên file cache                                              |
//+------------------------------------------------------------------+
string CTradeHistoryOptimizer::GetCacheFileName() {
    return StringFormat("%s_%d.cache", m_context->Symbol, m_context->MagicNumber);
}

//+------------------------------------------------------------------+
//| Kiểm tra cache có hợp lệ không                                  |
//+------------------------------------------------------------------+
bool CTradeHistoryOptimizer::IsCacheValid(int maxAgeMinutes = 60) {
    if (m_LastCacheUpdate == 0) return false;
    return (TimeCurrent() - m_LastCacheUpdate) < (maxAgeMinutes * 60);
}

//+------------------------------------------------------------------+
//| Lưu thống kê vào cache                                          |
//+------------------------------------------------------------------+
bool CTradeHistoryOptimizer::SaveStatsToCache() {
    string filename = GetCacheFileName();
    int handle = FileOpen(filename, FILE_WRITE | FILE_BIN | FILE_COMMON);
    if (handle == INVALID_HANDLE) return false;

    FileWriteLong(handle, TimeCurrent());
    FileWriteStruct(handle, m_CachedStats);
    FileClose(handle);
    m_LastCacheUpdate = TimeCurrent();
    return true;
}

//+------------------------------------------------------------------+
//| Tải thống kê từ cache                                           |
//+------------------------------------------------------------------+
bool CTradeHistoryOptimizer::LoadStatsFromCache() {
    string filename = GetCacheFileName();
    if (!FileIsExist(filename, FILE_COMMON)) return false;

    int handle = FileOpen(filename, FILE_READ | FILE_BIN | FILE_COMMON);
    if (handle == INVALID_HANDLE) return false;

    m_LastCacheUpdate = (datetime)FileReadLong(handle);
    if (!IsCacheValid()) {
        FileClose(handle);
        return false;
    }
    FileReadStruct(handle, m_CachedStats);
    FileClose(handle);
    
    if (m_context && m_context->Logger) {
        m_context->Logger->LogInfo("Loaded trade statistics from cache.");
    }
    return true;
}

//+------------------------------------------------------------------+
//| Xóa cache                                                        |
//+------------------------------------------------------------------+
void CTradeHistoryOptimizer::ClearCache() {
    string filename = GetCacheFileName();
    if (FileIsExist(filename, FILE_COMMON)) {
        FileDelete(filename, FILE_COMMON);
    }
    m_LastCacheUpdate = 0;
}

} // end namespace ApexPullback

#endif // TRADEHISTORYOPTIMIZER_MQH_