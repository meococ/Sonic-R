//+------------------------------------------------------------------+
//|                                         PerformanceTracker.mqh |
//|                          Copyright 2023, Apex Pullback EA Team |
//|                                  https://www.apexpullbackea.com |
//+------------------------------------------------------------------+
#ifndef PERFORMANCETRACKER_MQH
#define PERFORMANCETRACKER_MQH

#include "CommonStructs.mqh" // For EAContext
#include <Arrays/ArrayDouble.mqh>
#include <Math/Stat/Math.mqh>

//+------------------------------------------------------------------+
//| Cấu trúc lưu trữ dữ liệu giao dịch chi tiết                     |
//+------------------------------------------------------------------+
struct TradeData {
    long ticket;
    datetime openTime;
    datetime closeTime;
    double profit;
    double volume;
    int type; // 0=Buy, 1=Sell
    double openPrice;
    double closePrice;
    double commission;
    double swap;
    string symbol;
    
    // Execution Quality Metrics - Nâng cấp mới
    double requestedPrice;      // Giá yêu cầu ban đầu
    double executedPrice;       // Giá thực thi thực tế
    double slippage;            // Độ trượt giá (pips)
    ulong executionLatency;     // Độ trễ thực thi (milliseconds)
    datetime requestTime;       // Thời gian gửi lệnh
    datetime executionTime;     // Thời gian thực thi
    int requotes;               // Số lần requote
    int executionAttempts;      // Số lần thử thực thi
    
    TradeData() {
        ticket = 0;
        openTime = 0;
        closeTime = 0;
        profit = 0.0;
        volume = 0.0;
        type = 0;
        openPrice = 0.0;
        closePrice = 0.0;
        commission = 0.0;
        swap = 0.0;
        symbol = "";
        
        // Khởi tạo execution quality metrics
        requestedPrice = 0.0;
        executedPrice = 0.0;
        slippage = 0.0;
        executionLatency = 0;
        requestTime = 0;
        executionTime = 0;
        requotes = 0;
        executionAttempts = 1;
    }
};

//+------------------------------------------------------------------+
//| Cấu trúc lưu trữ metrics hiệu suất                              |
//+------------------------------------------------------------------+
struct PerformanceMetrics {
    double sharpeRatio;
    double sortinoRatio;
    double calmarRatio;
    double maxDrawdown;
    double maxDrawdownPercent;
    double profitFactor;
    double winRate;
    double averageWin;
    double averageLoss;
    double expectancy;
    double recoveryFactor;
    double ulcerIndex;
    double sterlingRatio;
    double burkeRatio;
    double kRatio;
    
    PerformanceMetrics() {
        sharpeRatio = 0.0;
        sortinoRatio = 0.0;
        calmarRatio = 0.0;
        maxDrawdown = 0.0;
        maxDrawdownPercent = 0.0;
        profitFactor = 0.0;
        winRate = 0.0;
        averageWin = 0.0;
        averageLoss = 0.0;
        expectancy = 0.0;
        recoveryFactor = 0.0;
        ulcerIndex = 0.0;
        sterlingRatio = 0.0;
        burkeRatio = 0.0;
        kRatio = 0.0;
    }
};

//+------------------------------------------------------------------+
//| Lớp CPerformanceTracker - Theo dõi hiệu suất giao dịch nâng cao |
//+------------------------------------------------------------------+
namespace ApexPullback {

class CPerformanceTracker {
private:
    CLogger* m_Logger;                    // Logger
    EAContext* m_Context;                 // EA Context
    
    // Dữ liệu giao dịch chi tiết
    TradeData m_TradeHistory[];
    int m_TradeCount;
    
    // Thống kê tổng quan
    int m_TotalTrades;                   // Tổng số giao dịch
    int m_WinningTrades;                 // Số giao dịch thắng
    int m_LosingTrades;                  // Số giao dịch thua
    int m_BreakEvenTrades;               // Số giao dịch hòa vốn
    
    double m_GrossProfit;                // Lợi nhuận gộp
    double m_GrossLoss;                  // Thua lỗ gộp
    double m_NetProfit;                  // Lợi nhuận ròng
    
    double m_MaxDrawdown;                // Drawdown tối đa
    double m_MaxDrawdownPercent;         // Drawdown tối đa theo %
    double m_CurrentDrawdown;            // Drawdown hiện tại
    
    // Advanced Performance Metrics
    PerformanceMetrics m_Metrics;
    
    // Equity curve data
    CArrayDouble m_EquityCurve;
    CArrayDouble m_DailyReturns;
    CArrayDouble m_DrawdownCurve;
    
    // Risk-free rate for Sharpe calculation
    double m_RiskFreeRate;
    
    // Thống kê theo thời gian
    double m_DailyProfit[];              // Lợi nhuận theo ngày
    double m_WeeklyProfit[];             // Lợi nhuận theo tuần
    double m_MonthlyProfit[];            // Lợi nhuận theo tháng
    
    // Phân tích giao dịch
    int m_ConsecutiveWins;               // Số lần thắng liên tiếp
    int m_ConsecutiveLosses;             // Số lần thua liên tiếp
    int m_MaxConsecutiveWins;            // Số lần thắng liên tiếp tối đa
    int m_MaxConsecutiveLosses;          // Số lần thua liên tiếp tối đa
    
    double m_LargestWin;                 // Giao dịch thắng lớn nhất
    double m_LargestLoss;                // Giao dịch thua lớn nhất
    double m_AverageWin;                 // Thắng trung bình
    double m_AverageLoss;                // Thua trung bình
    
    // Phân tích theo thời gian
    int m_TradesByHour[24];              // Số giao dịch theo giờ
    double m_ProfitByHour[24];           // Lợi nhuận theo giờ
    
    int m_TradesByDay[7];                // Số giao dịch theo ngày trong tuần
    double m_ProfitByDay[7];             // Lợi nhuận theo ngày trong tuần
    
    // Real-time tracking
    datetime m_LastUpdateTime;
    double m_LastEquityValue;
    double m_PeakEquity;
    
    // Execution Quality Tracking - Nâng cấp mới
    double m_TotalSlippage;              // Tổng độ trượt giá
    double m_AverageSlippage;            // Độ trượt giá trung bình
    double m_MaxSlippage;                // Độ trượt giá tối đa
    double m_MinSlippage;                // Độ trượt giá tối thiểu
    
    ulong m_TotalLatency;                // Tổng độ trễ thực thi
    ulong m_AverageLatency;              // Độ trễ thực thi trung bình
    ulong m_MaxLatency;                  // Độ trễ thực thi tối đa
    ulong m_MinLatency;                  // Độ trễ thực thi tối thiểu
    
    int m_TotalRequotes;                 // Tổng số requotes
    int m_TotalExecutionAttempts;        // Tổng số lần thử thực thi
    double m_ExecutionSuccessRate;       // Tỷ lệ thành công thực thi
    
    // Execution Quality by Time Period
    double m_SlippageByHour[24];         // Độ trượt giá theo giờ
    ulong m_LatencyByHour[24];           // Độ trễ theo giờ
    int m_RequotesByHour[24];            // Requotes theo giờ
    
    // Performance calculation helpers
    double CalculateStandardDeviation(const double& returns[]);
    double CalculateDownsideDeviation(const double& returns[], double threshold = 0.0);
    double CalculateMaxDrawdownFromEquity();
    void UpdateEquityCurve(double newEquity);
    void UpdateDailyReturns();
    bool IsNewDay(datetime currentTime);
    
public:
    // Constructor và Destructor
    CPerformanceTracker();
    ~CPerformanceTracker();
    
    // Khởi tạo
    bool Initialize(CLogger* logger, EAContext* context);
    void SetRiskFreeRate(double rate) { m_RiskFreeRate = rate; }
    
    // Cập nhật dữ liệu real-time
    void AddTrade(long ticket, double profit, double volume, int type, 
                  datetime openTime, datetime closeTime, double openPrice, 
                  double closePrice, double commission, double swap, string symbol);
    
    // Nâng cấp: AddTrade với execution quality metrics
    void AddTradeWithExecutionMetrics(long ticket, double profit, double volume, int type,
                                     datetime openTime, datetime closeTime, double openPrice,
                                     double closePrice, double commission, double swap, string symbol,
                                     double requestedPrice, double executedPrice, ulong latency,
                                     datetime requestTime, datetime executionTime, int requotes, int attempts);
    
    void UpdateEquity(double currentEquity);
    void UpdateDrawdown(double currentEquity);
    void OnTick(); // Real-time update
    
    // Execution Quality Analysis - Phương thức mới
    void CalculateExecutionQualityMetrics();
    void RecordExecutionMetrics(double requestedPrice, double executedPrice, ulong latency, int requotes, int attempts);
    void UpdateSlippageStatistics(double slippage);
    void UpdateLatencyStatistics(ulong latency);
    
    // Tính toán thống kê nâng cao
    void CalculateStatistics();
    void CalculateAdvancedMetrics();
    double CalculateSharpeRatio();
    double CalculateSortinoRatio();
    double CalculateCalmarRatio();
    double CalculateRecoveryFactor();
    double CalculateUlcerIndex();
    double CalculateSterlingRatio();
    double CalculateBurkeRatio();
    double CalculateKRatio();
    
    // Getters cho metrics cơ bản
    double GetWinRate() const { return m_Metrics.winRate; }
    double GetProfitFactor() const { return m_Metrics.profitFactor; }
    double GetSharpeRatio() const { return m_Metrics.sharpeRatio; }
    double GetSortinoRatio() const { return m_Metrics.sortinoRatio; }
    double GetCalmarRatio() const { return m_Metrics.calmarRatio; }
    double GetMaxDrawdown() const { return m_Metrics.maxDrawdown; }
    double GetMaxDrawdownPercent() const { return m_Metrics.maxDrawdownPercent; }
    double GetNetProfit() const { return m_NetProfit; }
    int GetTotalTrades() const { return m_TotalTrades; }
    double GetExpectancy() const { return m_Metrics.expectancy; }
    double GetRecoveryFactor() const { return m_Metrics.recoveryFactor; }
    double GetUlcerIndex() const { return m_Metrics.ulcerIndex; }
    double GetCurrentDrawdown() const { return m_CurrentDrawdown; }
    
    // Getters cho Execution Quality Metrics - Nâng cấp mới
    double GetAverageSlippage() const { return m_AverageSlippage; }
    double GetMaxSlippage() const { return m_MaxSlippage; }
    double GetMinSlippage() const { return m_MinSlippage; }
    ulong GetAverageLatency() const { return m_AverageLatency; }
    ulong GetMaxLatency() const { return m_MaxLatency; }
    ulong GetMinLatency() const { return m_MinLatency; }
    int GetTotalRequotes() const { return m_TotalRequotes; }
    double GetExecutionSuccessRate() const { return m_ExecutionSuccessRate; }
    
    // Getters cho time-based execution metrics
    double GetSlippageByHour(int hour) const { return (hour >= 0 && hour < 24) ? m_SlippageByHour[hour] : 0.0; }
    ulong GetLatencyByHour(int hour) const { return (hour >= 0 && hour < 24) ? m_LatencyByHour[hour] : 0; }
    int GetRequotesByHour(int hour) const { return (hour >= 0 && hour < 24) ? m_RequotesByHour[hour] : 0; }
    
    // Getters cho dữ liệu chi tiết
    PerformanceMetrics GetAllMetrics() const { return m_Metrics; }
    const CArrayDouble* GetEquityCurve() const { return &m_EquityCurve; }
    const CArrayDouble* GetDailyReturns() const { return &m_DailyReturns; }
    const CArrayDouble* GetDrawdownCurve() const { return &m_DrawdownCurve; }
    
    // Phân tích theo thời gian
    void AnalyzeTimeBasedPerformance();
    double GetProfitByHour(int hour) const;
    double GetProfitByDay(int dayOfWeek) const;
    int GetTradesByHour(int hour) const;
    int GetTradesByDay(int dayOfWeek) const;
    
    // Báo cáo
    string GetSummaryReport();
    string GetDetailedReport();
    string GetRealTimeMetrics();
    string GetAdvancedMetricsReport();
    
    // Export/Import
    bool ExportToCSV(string filename);
    bool SavePerformanceData(string filename);
    bool LoadPerformanceData(string filename);
    
    // Reset dữ liệu
    void Reset();
    void ResetMetrics();
    
    // Validation và Quality Check
    bool ValidateData();
    double GetDataQualityScore();
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPerformanceTracker::CPerformanceTracker() {
    m_Logger = NULL;
    m_Context = NULL;
    m_TradeCount = 0;
    m_RiskFreeRate = 0.02; // Default 2% annual risk-free rate
    m_LastUpdateTime = 0;
    m_LastEquityValue = 0;
    m_PeakEquity = 0;
    
    // Khởi tạo Execution Quality Metrics - Nâng cấp mới
    m_TotalSlippage = 0.0;
    m_AverageSlippage = 0.0;
    m_MaxSlippage = 0.0;
    m_MinSlippage = DBL_MAX;
    
    m_TotalLatency = 0;
    m_AverageLatency = 0;
    m_MaxLatency = 0;
    m_MinLatency = ULONG_MAX;
    
    m_TotalRequotes = 0;
    m_TotalExecutionAttempts = 0;
    m_ExecutionSuccessRate = 0.0;
    
    Reset();
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPerformanceTracker::~CPerformanceTracker() {
    m_EquityCurve.Clear();
    m_DailyReturns.Clear();
    m_DrawdownCurve.Clear();
}

//+------------------------------------------------------------------+
//| Khởi tạo tracker với context                                    |
//+------------------------------------------------------------------+
bool CPerformanceTracker::Initialize(CLogger* logger, EAContext* context) {
    if (logger == NULL || context == NULL) {
        Print("[PerformanceTracker] ERROR: Logger or Context is NULL");
        return false;
    }
    
    m_Logger = logger;
    m_Context = context;
    Reset();
    
    // Initialize arrays
    m_EquityCurve.Clear();
    m_DailyReturns.Clear();
    m_DrawdownCurve.Clear();
    
    m_LastUpdateTime = TimeCurrent();
    m_LastEquityValue = AccountInfoDouble(ACCOUNT_EQUITY);
    m_PeakEquity = m_LastEquityValue;
    
    m_Logger->LogInfo("PerformanceTracker initialized successfully with advanced metrics");
    return true;
}

//+------------------------------------------------------------------+
//| Thêm giao dịch mới với thông tin đầy đủ                        |
//+------------------------------------------------------------------+
void CPerformanceTracker::AddTrade(long ticket, double profit, double volume, int type,
                                   datetime openTime, datetime closeTime, double openPrice,
                                   double closePrice, double commission, double swap, string symbol) {
    // Resize array if needed
    if (m_TradeCount >= ArraySize(m_TradeHistory)) {
        ArrayResize(m_TradeHistory, m_TradeCount + 100);
    }
    
    // Store trade data
    m_TradeHistory[m_TradeCount].ticket = ticket;
    m_TradeHistory[m_TradeCount].openTime = openTime;
    m_TradeHistory[m_TradeCount].closeTime = closeTime;
    m_TradeHistory[m_TradeCount].profit = profit + commission + swap;
    m_TradeHistory[m_TradeCount].volume = volume;
    m_TradeHistory[m_TradeCount].type = type;
    m_TradeHistory[m_TradeCount].openPrice = openPrice;
    m_TradeHistory[m_TradeCount].closePrice = closePrice;
    m_TradeHistory[m_TradeCount].commission = commission;
    m_TradeHistory[m_TradeCount].swap = swap;
    m_TradeHistory[m_TradeCount].symbol = symbol;
    
    m_TradeCount++;
    m_TotalTrades++;
    
    double totalProfit = profit + commission + swap;
    
    if (totalProfit > 0.01) {
        m_WinningTrades++;
        m_GrossProfit += totalProfit;
        m_ConsecutiveWins++;
        m_ConsecutiveLosses = 0;
        
        if (m_ConsecutiveWins > m_MaxConsecutiveWins)
            m_MaxConsecutiveWins = m_ConsecutiveWins;
            
        if (totalProfit > m_LargestWin)
            m_LargestWin = totalProfit;
    }
    else if (totalProfit < -0.01) {
        m_LosingTrades++;
        m_GrossLoss += MathAbs(totalProfit);
        m_ConsecutiveLosses++;
        m_ConsecutiveWins = 0;
        
        if (m_ConsecutiveLosses > m_MaxConsecutiveLosses)
            m_MaxConsecutiveLosses = m_ConsecutiveLosses;
            
        if (MathAbs(totalProfit) > m_LargestLoss)
            m_LargestLoss = MathAbs(totalProfit);
    }
    else {
        m_BreakEvenTrades++;
    }
    
    m_NetProfit = m_GrossProfit - m_GrossLoss;
    
    // Update time-based statistics
    MqlDateTime dt;
    TimeToStruct(closeTime, dt);
    
    m_TradesByHour[dt.hour]++;
    m_ProfitByHour[dt.hour] += totalProfit;
    
    m_TradesByDay[dt.day_of_week]++;
    m_ProfitByDay[dt.day_of_week] += totalProfit;
    
    // Update equity curve
    UpdateEquityCurve(AccountInfoDouble(ACCOUNT_EQUITY));
    
    if (m_Logger != NULL)
        m_Logger->LogInfo(StringFormat("Trade added: #%d, P/L=%.2f, Total=%d", 
                         ticket, totalProfit, m_TotalTrades));
}

//+------------------------------------------------------------------+
//| Thêm giao dịch với execution quality metrics - Nâng cấp mới    |
//+------------------------------------------------------------------+
void CPerformanceTracker::AddTradeWithExecutionMetrics(long ticket, double profit, double volume, int type,
                                                       datetime openTime, datetime closeTime, double openPrice,
                                                       double closePrice, double commission, double swap, string symbol,
                                                       double requestedPrice, double executedPrice, ulong latency,
                                                       datetime requestTime, datetime executionTime, int requotes, int attempts) {
    // Gọi phương thức AddTrade cơ bản trước
    AddTrade(ticket, profit, volume, type, openTime, closeTime, openPrice, closePrice, commission, swap, symbol);
    
    // Cập nhật execution quality metrics cho trade vừa thêm
    TradeData& lastTrade = m_TradeHistory[m_TradeCount - 1];
    lastTrade.requestedPrice = requestedPrice;
    lastTrade.executedPrice = executedPrice;
    lastTrade.requestTime = requestTime;
    lastTrade.executionTime = executionTime;
    lastTrade.executionLatency = latency;
    lastTrade.requotes = requotes;
    lastTrade.executionAttempts = attempts;
    
    // Tính toán slippage (độ trượt giá)
    double pointValue = SymbolInfoDouble(symbol, SYMBOL_POINT);
    if (pointValue > 0) {
        lastTrade.slippage = MathAbs(executedPrice - requestedPrice) / pointValue;
    } else {
        lastTrade.slippage = 0.0;
    }
    
    // Cập nhật execution quality statistics
    RecordExecutionMetrics(requestedPrice, executedPrice, latency, requotes, attempts);
    
    if (m_Logger != NULL) {
        m_Logger->LogInfo(StringFormat("Trade with execution metrics added: #%d, Slippage=%.1f pips, Latency=%d ms, Requotes=%d",
                         ticket, lastTrade.slippage, latency, requotes));
    }
}

//+------------------------------------------------------------------+
//| Ghi lại execution metrics - Phương thức mới                     |
//+------------------------------------------------------------------+
void CPerformanceTracker::RecordExecutionMetrics(double requestedPrice, double executedPrice, ulong latency, int requotes, int attempts) {
    // Tính toán slippage
    double slippage = MathAbs(executedPrice - requestedPrice);
    
    // Cập nhật slippage statistics
    UpdateSlippageStatistics(slippage);
    
    // Cập nhật latency statistics
    UpdateLatencyStatistics(latency);
    
    // Cập nhật requotes và execution attempts
    m_TotalRequotes += requotes;
    m_TotalExecutionAttempts += attempts;
    
    // Tính toán execution success rate
    if (m_TotalExecutionAttempts > 0) {
        int successfulExecutions = m_TotalTrades; // Số trades thành công
        m_ExecutionSuccessRate = (double)successfulExecutions / m_TotalExecutionAttempts * 100.0;
    }
    
    // Cập nhật time-based metrics
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    int hour = dt.hour;
    
    if (hour >= 0 && hour < 24) {
        m_SlippageByHour[hour] = (m_SlippageByHour[hour] + slippage) / 2.0; // Moving average
        m_LatencyByHour[hour] = (m_LatencyByHour[hour] + latency) / 2; // Moving average
        m_RequotesByHour[hour] += requotes;
    }
}

//+------------------------------------------------------------------+
//| Cập nhật slippage statistics - Phương thức mới                  |
//+------------------------------------------------------------------+
void CPerformanceTracker::UpdateSlippageStatistics(double slippage) {
    m_TotalSlippage += slippage;
    
    if (m_TotalTrades > 0) {
        m_AverageSlippage = m_TotalSlippage / m_TotalTrades;
    }
    
    if (slippage > m_MaxSlippage || m_TotalTrades == 1) {
        m_MaxSlippage = slippage;
    }
    
    if (slippage < m_MinSlippage || m_TotalTrades == 1) {
        m_MinSlippage = slippage;
    }
}

//+------------------------------------------------------------------+
//| Cập nhật latency statistics - Phương thức mới                   |
//+------------------------------------------------------------------+
void CPerformanceTracker::UpdateLatencyStatistics(ulong latency) {
    m_TotalLatency += latency;
    
    if (m_TotalTrades > 0) {
        m_AverageLatency = m_TotalLatency / m_TotalTrades;
    }
    
    if (latency > m_MaxLatency || m_TotalTrades == 1) {
        m_MaxLatency = latency;
    }
    
    if (latency < m_MinLatency || m_TotalTrades == 1) {
        m_MinLatency = latency;
    }
}

//+------------------------------------------------------------------+
//| Tính toán execution quality metrics - Phương thức mới           |
//+------------------------------------------------------------------+
void CPerformanceTracker::CalculateExecutionQualityMetrics() {
    if (m_TotalTrades == 0) return;
    
    // Reset các giá trị
    m_TotalSlippage = 0.0;
    m_TotalLatency = 0;
    m_TotalRequotes = 0;
    m_TotalExecutionAttempts = 0;
    
    double maxSlip = 0.0, minSlip = DBL_MAX;
    ulong maxLat = 0, minLat = ULONG_MAX;
    
    // Duyệt qua tất cả trades để tính toán
    for (int i = 0; i < m_TradeCount; i++) {
        TradeData& trade = m_TradeHistory[i];
        
        m_TotalSlippage += trade.slippage;
        m_TotalLatency += trade.executionLatency;
        m_TotalRequotes += trade.requotes;
        m_TotalExecutionAttempts += trade.executionAttempts;
        
        if (trade.slippage > maxSlip) maxSlip = trade.slippage;
        if (trade.slippage < minSlip) minSlip = trade.slippage;
        
        if (trade.executionLatency > maxLat) maxLat = trade.executionLatency;
        if (trade.executionLatency < minLat) minLat = trade.executionLatency;
    }
    
    // Cập nhật các metrics
    m_AverageSlippage = m_TotalSlippage / m_TotalTrades;
    m_MaxSlippage = maxSlip;
    m_MinSlippage = (minSlip == DBL_MAX) ? 0.0 : minSlip;
    
    m_AverageLatency = m_TotalLatency / m_TotalTrades;
    m_MaxLatency = maxLat;
    m_MinLatency = (minLat == ULONG_MAX) ? 0 : minLat;
    
    // Tính execution success rate
    if (m_TotalExecutionAttempts > 0) {
        m_ExecutionSuccessRate = (double)m_TotalTrades / m_TotalExecutionAttempts * 100.0;
    }
    
    if (m_Logger != NULL) {
        m_Logger->LogInfo(StringFormat("Execution Quality Metrics calculated: Avg Slippage=%.2f, Avg Latency=%d ms, Success Rate=%.1f%%",
                         m_AverageSlippage, m_AverageLatency, m_ExecutionSuccessRate));
    }
}

//+------------------------------------------------------------------+
//| Cập nhật equity curve                                           |
//+------------------------------------------------------------------+
void CPerformanceTracker::UpdateEquityCurve(double newEquity) {
    m_EquityCurve.Add(newEquity);
    
    if (newEquity > m_PeakEquity) {
        m_PeakEquity = newEquity;
    }
    
    // Calculate current drawdown
    m_CurrentDrawdown = m_PeakEquity - newEquity;
    double currentDrawdownPercent = (m_PeakEquity > 0) ? (m_CurrentDrawdown / m_PeakEquity) * 100 : 0;
    
    // Update max drawdown
    if (m_CurrentDrawdown > m_MaxDrawdown) {
        m_MaxDrawdown = m_CurrentDrawdown;
        m_MaxDrawdownPercent = currentDrawdownPercent;
    }
    
    m_DrawdownCurve.Add(m_CurrentDrawdown);
    
    // Update daily returns if new day
    if (IsNewDay(TimeCurrent())) {
        UpdateDailyReturns();
    }
    
    m_LastEquityValue = newEquity;
}

//+------------------------------------------------------------------+
//| Cập nhật daily returns                                          |
//+------------------------------------------------------------------+
void CPerformanceTracker::UpdateDailyReturns() {
    if (m_EquityCurve.Total() < 2) return;
    
    double previousEquity = m_EquityCurve.At(m_EquityCurve.Total() - 2);
    double currentEquity = m_EquityCurve.At(m_EquityCurve.Total() - 1);
    
    if (previousEquity > 0) {
        double dailyReturn = (currentEquity - previousEquity) / previousEquity;
        m_DailyReturns.Add(dailyReturn);
    }
}

//+------------------------------------------------------------------+
//| Kiểm tra ngày mới                                               |
//+------------------------------------------------------------------+
bool CPerformanceTracker::IsNewDay(datetime currentTime) {
    if (m_LastUpdateTime == 0) {
        m_LastUpdateTime = currentTime;
        return false;
    }
    
    MqlDateTime current, last;
    TimeToStruct(currentTime, current);
    TimeToStruct(m_LastUpdateTime, last);
    
    bool newDay = (current.day != last.day || current.mon != last.mon || current.year != last.year);
    
    if (newDay) {
        m_LastUpdateTime = currentTime;
    }
    
    return newDay;
}

//+------------------------------------------------------------------+
//| Real-time update                                                |
//+------------------------------------------------------------------+
void CPerformanceTracker::OnTick() {
    double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    UpdateEquity(currentEquity);
}

//+------------------------------------------------------------------+
//| Cập nhật equity                                                 |
//+------------------------------------------------------------------+
void CPerformanceTracker::UpdateEquity(double currentEquity) {
    UpdateEquityCurve(currentEquity);
}

//+------------------------------------------------------------------+
//| Cập nhật drawdown                                               |
//+------------------------------------------------------------------+
void CPerformanceTracker::UpdateDrawdown(double currentEquity) {
    UpdateEquityCurve(currentEquity);
}

//+------------------------------------------------------------------+
//| Tính toán các thống kê                                          |
//+------------------------------------------------------------------+
void CPerformanceTracker::CalculateStatistics() {
    if (m_TotalTrades == 0) return;
    
    // Tỷ lệ thắng
    m_Metrics.winRate = (double)m_WinningTrades / m_TotalTrades * 100;
    
    // Hệ số lợi nhuận
    m_Metrics.profitFactor = (m_GrossLoss > 0) ? m_GrossProfit / m_GrossLoss : 0;
    
    // Kỳ vọng trung bình
    m_Metrics.expectancy = m_NetProfit / m_TotalTrades;
    
    // Thắng/thua trung bình
    m_Metrics.averageWin = (m_WinningTrades > 0) ? m_GrossProfit / m_WinningTrades : 0;
    m_Metrics.averageLoss = (m_LosingTrades > 0) ? m_GrossLoss / m_LosingTrades : 0;
    
    // Update metrics structure
    m_Metrics.maxDrawdown = m_MaxDrawdown;
    m_Metrics.maxDrawdownPercent = m_MaxDrawdownPercent;
    
    if (m_Logger != NULL)
        m_Logger->LogInfo("Performance statistics calculated");
}

//+------------------------------------------------------------------+
//| Tính toán advanced metrics                                      |
//+------------------------------------------------------------------+
void CPerformanceTracker::CalculateAdvancedMetrics() {
    m_Metrics.sharpeRatio = CalculateSharpeRatio();
    m_Metrics.sortinoRatio = CalculateSortinoRatio();
    m_Metrics.calmarRatio = CalculateCalmarRatio();
    m_Metrics.recoveryFactor = CalculateRecoveryFactor();
    m_Metrics.ulcerIndex = CalculateUlcerIndex();
    m_Metrics.sterlingRatio = CalculateSterlingRatio();
    m_Metrics.burkeRatio = CalculateBurkeRatio();
    m_Metrics.kRatio = CalculateKRatio();
}

//+------------------------------------------------------------------+
//| Tính toán Sharpe Ratio                                          |
//+------------------------------------------------------------------+
double CPerformanceTracker::CalculateSharpeRatio() {
    if (m_DailyReturns.Total() < 2) return 0.0;
    
    // Convert daily returns to array
    double returns[];
    ArrayResize(returns, m_DailyReturns.Total());
    for (int i = 0; i < m_DailyReturns.Total(); i++) {
        returns[i] = m_DailyReturns.At(i);
    }
    
    // Calculate mean return
    double meanReturn = 0;
    for (int i = 0; i < ArraySize(returns); i++) {
        meanReturn += returns[i];
    }
    meanReturn /= ArraySize(returns);
    
    // Calculate standard deviation
    double stdDev = CalculateStandardDeviation(returns);
    
    if (stdDev == 0) return 0.0;
    
    // Daily risk-free rate
    double dailyRiskFreeRate = m_RiskFreeRate / 365.0;
    
    // Sharpe ratio
    double sharpeRatio = (meanReturn - dailyRiskFreeRate) / stdDev;
    
    // Annualize
    return sharpeRatio * MathSqrt(252); // 252 trading days per year
}

//+------------------------------------------------------------------+
//| Tính toán Sortino Ratio                                         |
//+------------------------------------------------------------------+
double CPerformanceTracker::CalculateSortinoRatio() {
    if (m_DailyReturns.Total() < 2) return 0.0;
    
    // Convert daily returns to array
    double returns[];
    ArrayResize(returns, m_DailyReturns.Total());
    for (int i = 0; i < m_DailyReturns.Total(); i++) {
        returns[i] = m_DailyReturns.At(i);
    }
    
    // Calculate mean return
    double meanReturn = 0;
    for (int i = 0; i < ArraySize(returns); i++) {
        meanReturn += returns[i];
    }
    meanReturn /= ArraySize(returns);
    
    // Calculate downside deviation
    double downsideDeviation = CalculateDownsideDeviation(returns, 0.0);
    
    if (downsideDeviation == 0) return 0.0;
    
    // Daily risk-free rate
    double dailyRiskFreeRate = m_RiskFreeRate / 365.0;
    
    // Sortino ratio
    double sortinoRatio = (meanReturn - dailyRiskFreeRate) / downsideDeviation;
    
    // Annualize
    return sortinoRatio * MathSqrt(252);
}

//+------------------------------------------------------------------+
//| Tính toán Calmar Ratio                                          |
//+------------------------------------------------------------------+
double CPerformanceTracker::CalculateCalmarRatio() {
    if (m_MaxDrawdownPercent == 0 || m_DailyReturns.Total() < 2) return 0.0;
    
    // Calculate annualized return
    double totalReturn = 0;
    for (int i = 0; i < m_DailyReturns.Total(); i++) {
        totalReturn += m_DailyReturns.At(i);
    }
    
    double annualizedReturn = totalReturn * 252 / m_DailyReturns.Total();
    
    // Calmar ratio = Annualized Return / Max Drawdown
    return annualizedReturn / (m_MaxDrawdownPercent / 100.0);
}

//+------------------------------------------------------------------+
//| Tính toán Recovery Factor                                        |
//+------------------------------------------------------------------+
double CPerformanceTracker::CalculateRecoveryFactor() {
    if (m_MaxDrawdown == 0) return 0.0;
    return m_NetProfit / m_MaxDrawdown;
}

//+------------------------------------------------------------------+
//| Tính toán Ulcer Index                                           |
//+------------------------------------------------------------------+
double CPerformanceTracker::CalculateUlcerIndex() {
    if (m_DrawdownCurve.Total() < 2) return 0.0;
    
    double sumSquaredDrawdowns = 0;
    for (int i = 0; i < m_DrawdownCurve.Total(); i++) {
        double drawdownPercent = 0;
        if (m_PeakEquity > 0) {
            drawdownPercent = (m_DrawdownCurve.At(i) / m_PeakEquity) * 100;
        }
        sumSquaredDrawdowns += drawdownPercent * drawdownPercent;
    }
    
    return MathSqrt(sumSquaredDrawdowns / m_DrawdownCurve.Total());
}

//+------------------------------------------------------------------+
//| Tính toán Sterling Ratio                                        |
//+------------------------------------------------------------------+
double CPerformanceTracker::CalculateSterlingRatio() {
    if (m_MaxDrawdownPercent == 0 || m_DailyReturns.Total() < 2) return 0.0;
    
    // Calculate annualized return
    double totalReturn = 0;
    for (int i = 0; i < m_DailyReturns.Total(); i++) {
        totalReturn += m_DailyReturns.At(i);
    }
    
    double annualizedReturn = totalReturn * 252 / m_DailyReturns.Total();
    
    // Sterling ratio = (Annualized Return - Risk Free Rate) / Max Drawdown
    return (annualizedReturn - m_RiskFreeRate) / (m_MaxDrawdownPercent / 100.0);
}

//+------------------------------------------------------------------+
//| Tính toán Burke Ratio                                           |
//+------------------------------------------------------------------+
double CPerformanceTracker::CalculateBurkeRatio() {
    if (m_DailyReturns.Total() < 2) return 0.0;
    
    // Calculate annualized return
    double totalReturn = 0;
    for (int i = 0; i < m_DailyReturns.Total(); i++) {
        totalReturn += m_DailyReturns.At(i);
    }
    
    double annualizedReturn = totalReturn * 252 / m_DailyReturns.Total();
    
    // Calculate square root of sum of squared drawdowns
    double sumSquaredDrawdowns = 0;
    for (int i = 0; i < m_DrawdownCurve.Total(); i++) {
        double drawdownPercent = 0;
        if (m_PeakEquity > 0) {
            drawdownPercent = (m_DrawdownCurve.At(i) / m_PeakEquity) * 100;
        }
        sumSquaredDrawdowns += drawdownPercent * drawdownPercent;
    }
    
    double burkeDrawdown = MathSqrt(sumSquaredDrawdowns);
    
    if (burkeDrawdown == 0) return 0.0;
    
    return (annualizedReturn - m_RiskFreeRate) / burkeDrawdown;
}

//+------------------------------------------------------------------+
//| Tính toán K-Ratio                                               |
//+------------------------------------------------------------------+
double CPerformanceTracker::CalculateKRatio() {
    if (m_EquityCurve.Total() < 10) return 0.0;
    
    // Linear regression of equity curve
    int n = m_EquityCurve.Total();
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    
    for (int i = 0; i < n; i++) {
        double x = i + 1; // Time index
        double y = m_EquityCurve.At(i); // Equity value
        
        sumX += x;
        sumY += y;
        sumXY += x * y;
        sumX2 += x * x;
    }
    
    // Calculate slope (trend)
    double slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    
    // Calculate standard error of slope
    double meanX = sumX / n;
    double meanY = sumY / n;
    
    double sumSquaredErrors = 0;
    for (int i = 0; i < n; i++) {
        double x = i + 1;
        double y = m_EquityCurve.At(i);
        double predictedY = slope * x + (meanY - slope * meanX);
        sumSquaredErrors += (y - predictedY) * (y - predictedY);
    }
    
    double standardError = MathSqrt(sumSquaredErrors / (n - 2));
    double slopeStandardError = standardError / MathSqrt(sumX2 - sumX * sumX / n);
    
    if (slopeStandardError == 0) return 0.0;
    
    // K-Ratio = slope / standard error of slope
    return slope / slopeStandardError;
}

//+------------------------------------------------------------------+
//| Tính toán Standard Deviation                                    |
//+------------------------------------------------------------------+
double CPerformanceTracker::CalculateStandardDeviation(const double& returns[]) {
    int size = ArraySize(returns);
    if (size < 2) return 0.0;
    
    // Calculate mean
    double mean = 0;
    for (int i = 0; i < size; i++) {
        mean += returns[i];
    }
    mean /= size;
    
    // Calculate variance
    double variance = 0;
    for (int i = 0; i < size; i++) {
        variance += (returns[i] - mean) * (returns[i] - mean);
    }
    variance /= (size - 1);
    
    return MathSqrt(variance);
}

//+------------------------------------------------------------------+
//| Tính toán Downside Deviation                                    |
//+------------------------------------------------------------------+
double CPerformanceTracker::CalculateDownsideDeviation(const double& returns[], double threshold = 0.0) {
    int size = ArraySize(returns);
    if (size < 2) return 0.0;
    
    double sumSquaredDownsideDeviations = 0;
    int downsideCount = 0;
    
    for (int i = 0; i < size; i++) {
        if (returns[i] < threshold) {
            double deviation = returns[i] - threshold;
            sumSquaredDownsideDeviations += deviation * deviation;
            downsideCount++;
        }
    }
    
    if (downsideCount == 0) return 0.0;
    
    return MathSqrt(sumSquaredDownsideDeviations / downsideCount);
}

//+------------------------------------------------------------------+
//| Tính toán Max Drawdown từ Equity Curve                         |
//+------------------------------------------------------------------+
double CPerformanceTracker::CalculateMaxDrawdownFromEquity() {
    if (m_EquityCurve.Total() < 2) return 0.0;
    
    double maxDrawdown = 0;
    double peak = m_EquityCurve.At(0);
    
    for (int i = 1; i < m_EquityCurve.Total(); i++) {
        double current = m_EquityCurve.At(i);
        
        if (current > peak) {
            peak = current;
        }
        
        double drawdown = peak - current;
        if (drawdown > maxDrawdown) {
            maxDrawdown = drawdown;
        }
    }
    
    return maxDrawdown;
}

//+------------------------------------------------------------------+
//| Phân tích hiệu suất theo thời gian                             |
//+------------------------------------------------------------------+
void CPerformanceTracker::AnalyzeTimeBasedPerformance() {
    // This method can be expanded to provide more detailed time-based analysis
    if (m_Logger != NULL)
        m_Logger->LogInfo("Time-based performance analysis completed");
}

//+------------------------------------------------------------------+
//| Lấy lợi nhuận theo giờ                                         |
//+------------------------------------------------------------------+
double CPerformanceTracker::GetProfitByHour(int hour) const {
    if (hour < 0 || hour >= 24) return 0.0;
    return m_ProfitByHour[hour];
}

//+------------------------------------------------------------------+
//| Lấy lợi nhuận theo ngày trong tuần                             |
//+------------------------------------------------------------------+
double CPerformanceTracker::GetProfitByDay(int dayOfWeek) const {
    if (dayOfWeek < 0 || dayOfWeek >= 7) return 0.0;
    return m_ProfitByDay[dayOfWeek];
}

//+------------------------------------------------------------------+
//| Lấy số giao dịch theo giờ                                      |
//+------------------------------------------------------------------+
int CPerformanceTracker::GetTradesByHour(int hour) const {
    if (hour < 0 || hour >= 24) return 0;
    return m_TradesByHour[hour];
}

//+------------------------------------------------------------------+
//| Lấy số giao dịch theo ngày trong tuần                          |
//+------------------------------------------------------------------+
int CPerformanceTracker::GetTradesByDay(int dayOfWeek) const {
    if (dayOfWeek < 0 || dayOfWeek >= 7) return 0;
    return m_TradesByDay[dayOfWeek];
}

//+------------------------------------------------------------------+
//| Lấy báo cáo tóm tắt                                             |
//+------------------------------------------------------------------+
string CPerformanceTracker::GetSummaryReport() {
    CalculateStatistics();
    
    string report = "\n=== PERFORMANCE SUMMARY ===\n";
    report += StringFormat("Total Trades: %d\n", m_TotalTrades);
    report += StringFormat("Winning Trades: %d (%.1f%%)\n", m_WinningTrades, m_Metrics.winRate);
    report += StringFormat("Losing Trades: %d\n", m_LosingTrades);
    report += StringFormat("Break-even Trades: %d\n", m_BreakEvenTrades);
    report += StringFormat("Net Profit: %.2f\n", m_NetProfit);
    report += StringFormat("Gross Profit: %.2f\n", m_GrossProfit);
    report += StringFormat("Gross Loss: %.2f\n", m_GrossLoss);
    report += StringFormat("Profit Factor: %.2f\n", m_Metrics.profitFactor);
    report += StringFormat("Expectancy: %.2f\n", m_Metrics.expectancy);
    report += StringFormat("Max Drawdown: %.2f (%.2f%%)\n", m_MaxDrawdown, m_MaxDrawdownPercent);
    report += StringFormat("Largest Win: %.2f\n", m_LargestWin);
    report += StringFormat("Largest Loss: %.2f\n", m_LargestLoss);
    report += StringFormat("Average Win: %.2f\n", m_Metrics.averageWin);
    report += StringFormat("Average Loss: %.2f\n", m_Metrics.averageLoss);
    report += StringFormat("Max Consecutive Wins: %d\n", m_MaxConsecutiveWins);
    report += StringFormat("Max Consecutive Losses: %d\n", m_MaxConsecutiveLosses);
    
    // Execution Quality Metrics - Nâng cấp mới
    report += "\n=== EXECUTION QUALITY METRICS ===\n";
    report += StringFormat("Average Slippage: %.2f pips\n", m_AverageSlippage);
    report += StringFormat("Max Slippage: %.2f pips\n", m_MaxSlippage);
    report += StringFormat("Min Slippage: %.2f pips\n", (m_MinSlippage == DBL_MAX) ? 0.0 : m_MinSlippage);
    report += StringFormat("Average Latency: %d ms\n", m_AverageLatency);
    report += StringFormat("Max Latency: %d ms\n", m_MaxLatency);
    report += StringFormat("Min Latency: %d ms\n", (m_MinLatency == ULONG_MAX) ? 0 : m_MinLatency);
    report += StringFormat("Total Requotes: %d\n", m_TotalRequotes);
    report += StringFormat("Execution Success Rate: %.1f%%\n", m_ExecutionSuccessRate);
    report += StringFormat("Total Execution Attempts: %d\n", m_TotalExecutionAttempts);
    
    return report;
}

//+------------------------------------------------------------------+
//| Lấy báo cáo chi tiết                                            |
//+------------------------------------------------------------------+
string CPerformanceTracker::GetDetailedReport() {
    string report = GetSummaryReport();
    
    report += "\n=== TIME-BASED ANALYSIS ===\n";
    report += "Trades by Hour:\n";
    for (int i = 0; i < 24; i++) {
        if (m_TradesByHour[i] > 0) {
            report += StringFormat("%02d:00 - Trades: %d, Profit: %.2f\n", 
                                 i, m_TradesByHour[i], m_ProfitByHour[i]);
        }
    }
    
    report += "\nTrades by Day of Week:\n";
    string dayNames[] = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};
    for (int i = 0; i < 7; i++) {
        if (m_TradesByDay[i] > 0) {
            report += StringFormat("%s - Trades: %d, Profit: %.2f\n", 
                                 dayNames[i], m_TradesByDay[i], m_ProfitByDay[i]);
        }
    }
    
    return report;
}

//+------------------------------------------------------------------+
//| Lấy real-time metrics                                           |
//+------------------------------------------------------------------+
string CPerformanceTracker::GetRealTimeMetrics() {
    string report = "\n=== REAL-TIME METRICS ===\n";
    report += StringFormat("Current Equity: %.2f\n", AccountInfoDouble(ACCOUNT_EQUITY));
    report += StringFormat("Peak Equity: %.2f\n", m_PeakEquity);
    report += StringFormat("Current Drawdown: %.2f\n", m_CurrentDrawdown);
    report += StringFormat("Last Update: %s\n", TimeToString(m_LastUpdateTime));
    
    return report;
}

//+------------------------------------------------------------------+
//| Lấy báo cáo advanced metrics                                    |
//+------------------------------------------------------------------+
string CPerformanceTracker::GetAdvancedMetricsReport() {
    CalculateAdvancedMetrics();
    
    string report = "\n=== ADVANCED METRICS ===\n";
    report += StringFormat("Sharpe Ratio: %.3f\n", m_Metrics.sharpeRatio);
    report += StringFormat("Sortino Ratio: %.3f\n", m_Metrics.sortinoRatio);
    report += StringFormat("Calmar Ratio: %.3f\n", m_Metrics.calmarRatio);
    report += StringFormat("Recovery Factor: %.3f\n", m_Metrics.recoveryFactor);
    report += StringFormat("Ulcer Index: %.3f\n", m_Metrics.ulcerIndex);
    report += StringFormat("Sterling Ratio: %.3f\n", m_Metrics.sterlingRatio);
    report += StringFormat("Burke Ratio: %.3f\n", m_Metrics.burkeRatio);
    report += StringFormat("K-Ratio: %.3f\n", m_Metrics.kRatio);
    
    return report;
}

//+------------------------------------------------------------------+
//| Export to CSV                                                   |
//+------------------------------------------------------------------+
bool CPerformanceTracker::ExportToCSV(string filename) {
    // Implementation for CSV export
    if (m_Logger != NULL)
        m_Logger->LogInfo("CSV export functionality not yet implemented");
    return false;
}

//+------------------------------------------------------------------+
//| Save performance data                                           |
//+------------------------------------------------------------------+
bool CPerformanceTracker::SavePerformanceData(string filename) {
    // Implementation for saving performance data
    if (m_Logger != NULL)
        m_Logger->LogInfo("Save performance data functionality not yet implemented");
    return false;
}

//+------------------------------------------------------------------+
//| Load performance data                                           |
//+------------------------------------------------------------------+
bool CPerformanceTracker::LoadPerformanceData(string filename) {
    // Implementation for loading performance data
    if (m_Logger != NULL)
        m_Logger->LogInfo("Load performance data functionality not yet implemented");
    return false;
}

//+------------------------------------------------------------------+
//| Reset tất cả dữ liệu                                            |
//+------------------------------------------------------------------+
void CPerformanceTracker::Reset() {
    m_TotalTrades = 0;
    m_WinningTrades = 0;
    m_LosingTrades = 0;
    m_BreakEvenTrades = 0;
    
    m_GrossProfit = 0;
    m_GrossLoss = 0;
    m_NetProfit = 0;
    
    m_MaxDrawdown = 0;
    m_MaxDrawdownPercent = 0;
    m_CurrentDrawdown = 0;
    
    m_ConsecutiveWins = 0;
    m_ConsecutiveLosses = 0;
    m_MaxConsecutiveWins = 0;
    m_MaxConsecutiveLosses = 0;
    
    m_LargestWin = 0;
    m_LargestLoss = 0;
    
    // Reset arrays
    ArrayInitialize(m_TradesByHour, 0);
    ArrayInitialize(m_ProfitByHour, 0);
    ArrayInitialize(m_TradesByDay, 0);
    ArrayInitialize(m_ProfitByDay, 0);
    
    // Reset Execution Quality Metrics - Nâng cấp mới
    m_TotalSlippage = 0.0;
    m_AverageSlippage = 0.0;
    m_MaxSlippage = 0.0;
    m_MinSlippage = DBL_MAX;
    
    m_TotalLatency = 0;
    m_AverageLatency = 0;
    m_MaxLatency = 0;
    m_MinLatency = ULONG_MAX;
    
    m_TotalRequotes = 0;
    m_TotalExecutionAttempts = 0;
    m_ExecutionSuccessRate = 0.0;
    
    // Reset time-based execution quality arrays
    ArrayInitialize(m_SlippageByHour, 0.0);
    ArrayInitialize(m_LatencyByHour, 0);
    ArrayInitialize(m_RequotesByHour, 0);
    
    // Reset metrics
    ResetMetrics();
    
    // Clear dynamic arrays
    m_EquityCurve.Clear();
    m_DailyReturns.Clear();
    m_DrawdownCurve.Clear();
    
    if (m_Logger != NULL)
        m_Logger->LogInfo("PerformanceTracker reset completed");
}

//+------------------------------------------------------------------+
//| Reset metrics                                                   |
//+------------------------------------------------------------------+
void CPerformanceTracker::ResetMetrics() {
    m_Metrics.sharpeRatio = 0.0;
    m_Metrics.sortinoRatio = 0.0;
    m_Metrics.calmarRatio = 0.0;
    m_Metrics.maxDrawdown = 0.0;
    m_Metrics.maxDrawdownPercent = 0.0;
    m_Metrics.profitFactor = 0.0;
    m_Metrics.winRate = 0.0;
    m_Metrics.averageWin = 0.0;
    m_Metrics.averageLoss = 0.0;
    m_Metrics.expectancy = 0.0;
    m_Metrics.recoveryFactor = 0.0;
    m_Metrics.ulcerIndex = 0.0;
    m_Metrics.sterlingRatio = 0.0;
    m_Metrics.burkeRatio = 0.0;
    m_Metrics.kRatio = 0.0;
}

//+------------------------------------------------------------------+
//| Validate data                                                   |
//+------------------------------------------------------------------+
bool CPerformanceTracker::ValidateData() {
    // Basic validation checks
    if (m_TotalTrades < 0) return false;
    if (m_WinningTrades < 0 || m_LosingTrades < 0 || m_BreakEvenTrades < 0) return false;
    if (m_WinningTrades + m_LosingTrades + m_BreakEvenTrades != m_TotalTrades) return false;
    if (m_GrossProfit < 0 || m_GrossLoss < 0) return false;
    
    return true;
}

//+------------------------------------------------------------------+
//| Get data quality score                                          |
//+------------------------------------------------------------------+
double CPerformanceTracker::GetDataQualityScore() {
    double score = 100.0;
    
    // Deduct points for various issues
    if (!ValidateData()) score -= 50.0;
    if (m_TotalTrades < 10) score -= 20.0;
    if (m_EquityCurve.Total() < 10) score -= 15.0;
    if (m_DailyReturns.Total() < 5) score -= 15.0;
    
    return MathMax(0.0, score);
}

} // End namespace ApexPullback

#endif // PERFORMANCETRACKER_MQH_
