//+------------------------------------------------------------------+
//|                                           PerformanceTracker.mqh |
//|                                    APEX Pullback EA v5.0 FINAL   |
//|                                      Advanced Performance Tracker |
//+------------------------------------------------------------------+
#property copyright "APEX Trading Systems"
#property version   "5.00"
#property strict

#include "../../00_Core/CommonStructs.mqh"

//+------------------------------------------------------------------+
//| Enhanced Performance metrics structure                           |
//+------------------------------------------------------------------+
struct SPerformanceMetrics {
    // Basic metrics
    int TotalTrades;
    int WinningTrades;
    int LosingTrades;
    double WinRate;
    double ProfitFactor;
    double Expectancy;
    
    // Financial metrics
    double TotalProfit;
    double TotalLoss;
    double NetProfit;
    double GrossProfit;
    double GrossLoss;
    double MaxDrawdown;
    double MaxDrawdownPercent;
    double CurrentDrawdown;
    double CurrentDrawdownPercent;
    
    // Risk metrics - Enhanced from v14
    double SharpeRatio;
    double SortinoRatio;
    double CalmarRatio;
    double UlcerIndex;
    double SterlingRatio;
    double BurkeRatio;
    double KellyPercentage;
    double VaR95;                    // Value at Risk 95%
    double CVaR95;                   // Conditional VaR 95%
    double MaxConsecutiveLosses;
    double MaxConsecutiveWins;
    
    // Time-based metrics
    double AverageTradeTime;
    double AverageWinTime;
    double AverageLossTime;
    double HoldingPeriod;
    double TradeFrequency;
    
    // Advanced metrics - Enhanced from v14
    double RecoveryFactor;
    double ProfitToMaxDDRatio;
    double AverageWin;
    double AverageLoss;
    double LargestWin;
    double LargestLoss;
    double AnnualizedReturn;
    double MonthlyReturn;
    double DailyReturn;
    double ReturnStdDev;
    double ReturnSkewness;
    double ReturnKurtosis;
    
    // Execution Quality Metrics - New from v14
    double AverageSlippage;          // Average slippage in pips
    double MaxSlippage;              // Maximum slippage
    double MinSlippage;              // Minimum slippage
    ulong AverageLatency;            // Average execution latency (ms)
    ulong MaxLatency;                // Maximum latency
    ulong MinLatency;                // Minimum latency
    double ExecutionSuccessRate;     // Execution success rate
    int TotalRequotes;               // Total requotes
    double RequoteRate;              // Requote rate
    
    // Benchmark comparison - New from v14
    double Beta;                     // Beta vs benchmark
    double Alpha;                    // Alpha vs benchmark
    double Correlation;              // Correlation with benchmark
    double TreynorRatio;             // Treynor ratio
    double InformationRatio;         // Information ratio
    double TrackingError;            // Tracking error
    
    datetime LastUpdateTime;
    datetime PeriodStartTime;
};

//+------------------------------------------------------------------+
//| Enhanced Trade record structure with execution quality metrics   |
//+------------------------------------------------------------------+
struct STradeRecord {
    // Basic trade information
    ulong Ticket;
    datetime OpenTime;
    datetime CloseTime;
    ENUM_ORDER_TYPE Type;
    double Volume;
    string Symbol;
    string Comment;
    
    // Price information
    double OpenPrice;
    double ClosePrice;
    double StopLoss;
    double TakeProfit;
    
    // Financial results
    double Profit;
    double Commission;
    double Swap;
    double NetProfit;                // Total P&L including costs
    
    // Trade analysis
    int DurationMinutes;
    double MaxFavorableExcursion;    // MFE
    double MaxAdverseExcursion;      // MAE
    bool WasStoppedOut;              // Closed by SL
    bool WasTakenProfit;             // Closed by TP
    bool WasManualClose;             // Manually closed
    
    // Execution quality metrics - Enhanced from v14
    double RequestedPrice;           // Originally requested price
    double ExecutedPrice;            // Actually executed price
    double Slippage;                 // Slippage in pips
    ulong ExecutionLatency;          // Execution latency (ms)
    datetime RequestTime;            // Request timestamp
    datetime ExecutionTime;          // Execution timestamp
    int Requotes;                    // Number of requotes
    int ExecutionAttempts;           // Number of execution attempts
    
    // Market context - New from v14
    double MarketVolatility;         // Market volatility at open
    double Spread;                   // Spread at execution
    int TradingSession;              // Trading session (0=Asian, 1=European, 2=American)
    bool WasNewsTime;                // Opened during news
    
    // Performance attribution - New from v14
    string Strategy;                 // Strategy used
    string Signal;                   // Signal type
    double ConfidenceLevel;          // Signal confidence
    double RiskRewardRatio;          // Expected R:R at entry
    double ActualRiskReward;         // Actual R:R achieved
};

//+------------------------------------------------------------------+
//| Performance Tracker Class                                        |
//+------------------------------------------------------------------+
class CPerformanceTracker {
private:
    EAContext* m_pContext;
    SPerformanceMetrics m_Metrics;
    STradeRecord m_TradeHistory[];
    int m_iTradeCount;
    double m_dEquityPeaks[];
    double m_dEquityValues[];
    datetime m_EquityTimes[];
    int m_iEquityCount;
    
    // Configuration
    bool m_bInitialized;
    bool m_bRealTimeTracking;
    string m_sReportPath;
    
    // Internal calculations
    double m_dRunningSum;
    double m_dRunningSumSquares;
    double m_dLastEquityPeak;
    int m_iConsecutiveWins;
    int m_iConsecutiveLosses;
    int m_iMaxConsecutiveWins;
    int m_iMaxConsecutiveLosses;
    
    // New: Execution Quality Tracking - from v14
    double m_dTotalSlippage;             // Total slippage recorded
    double m_dSlippageSum;               // Sum for average calculation
    double m_dSlippageSumSquares;        // Sum of squares for std dev
    ulong m_ulTotalLatency;              // Total latency recorded
    ulong m_ulLatencySum;                // Sum for average calculation
    ulong m_ulLatencySumSquares;         // Sum of squares for std dev
    int m_iTotalExecutions;              // Total executions tracked
    int m_iTotalSuccessfulExecutions;    // Successful executions
    
    // New: Time-based execution quality - from v14
    double m_dSlippageByHour[24];        // Slippage by hour
    ulong m_ulLatencyByHour[24];         // Latency by hour
    int m_iExecutionsByHour[24];         // Executions by hour
    int m_iSuccessByHour[24];            // Successful executions by hour
    
    // New: Benchmark comparison - from v14
    double m_dBenchmarkReturns[];        // Benchmark return series
    double m_dPortfolioReturns[];        // Portfolio return series
    int m_iReturnCount;                  // Number of return observations
    string m_sBenchmarkSymbol;           // Benchmark symbol
    double m_dRiskFreeRate;              // Risk-free rate
    bool m_bUseBenchmark;                // Enable benchmark comparison
    
    // New: Advanced risk tracking - from v14
    double m_dDailyReturns[];            // Daily returns array
    double m_dDrawdownSeries[];          // Drawdown time series
    datetime m_dtDrawdownStartDates[];   // Drawdown start dates
    int m_iDrawdownCount;                // Number of drawdown periods
    
    // New: Performance by time periods - from v14
    double m_dProfitByHour[24];          // Profit by hour
    double m_dProfitByDay[7];            // Profit by day of week
    double m_dProfitByMonth[12];         // Profit by month
    int m_iTradesByHour[24];             // Trades by hour
    int m_iTradesByDay[7];               // Trades by day of week
    int m_iTradesByMonth[12];            // Trades by month
    
    // New: Data quality and validation - from v14
    datetime m_dtLastDataQualityCheck;   // Last data quality check
    double m_dDataQualityScore;          // Current data quality score
    int m_iAnomalousTradesDetected;      // Number of anomalous trades detected
    int m_iDataValidationErrors;         // Number of validation errors
    
public:
    CPerformanceTracker();
    ~CPerformanceTracker();
    
    // Core methods
    bool Initialize(EAContext* context);
    void Deinitialize();
    void Reset();
    
    // Enhanced trade tracking
    void OnTradeOpen(const ulong ticket, const ENUM_ORDER_TYPE type, const double volume, 
                     const double price, const double sl, const double tp);
    void OnTradeClose(const ulong ticket, const double closePrice, const double profit, 
                      const double commission, const double swap);
    void OnTradeModify(const ulong ticket, const double newSL, const double newTP);
    
    // New: Enhanced trade recording with execution quality - from v14
    void AddTradeWithExecutionMetrics(const ulong ticket, const double profit, const double volume, 
                                     const int type, const datetime openTime, const datetime closeTime,
                                     const double openPrice, const double closePrice, const double commission,
                                     const double swap, const string symbol, const double requestedPrice,
                                     const double executedPrice, const ulong latency, const datetime requestTime,
                                     const datetime executionTime, const int requotes, const int attempts);
    
    // New: Execution quality tracking - from v14
    void RecordExecutionMetrics(const double requestedPrice, const double executedPrice, 
                               const ulong latency, const int requotes, const int attempts);
    void RecordSlippage(const double slippage);
    void RecordLatency(const ulong latency);
    
    // Real-time updates
    void UpdateEquity(const double currentEquity);
    void UpdateDrawdown();
    void CalculateMetrics();
    
    // New: Advanced metrics calculation - from v14
    void CalculateAdvancedRiskMetrics();
    void CalculateExecutionQualityMetrics();
    void CalculateBenchmarkMetrics();
    void CalculateTimeBasedMetrics();
    
    // Enhanced Getters - Basic Metrics
    SPerformanceMetrics GetMetrics() const { return m_Metrics; }
    double GetWinRate() const { return m_Metrics.WinRate; }
    double GetProfitFactor() const { return m_Metrics.ProfitFactor; }
    double GetExpectancy() const { return m_Metrics.Expectancy; }
    double GetMaxDrawdown() const { return m_Metrics.MaxDrawdown; }
    double GetSharpeRatio() const { return m_Metrics.SharpeRatio; }
    double GetNetProfit() const { return m_Metrics.NetProfit; }
    int GetTotalTrades() const { return m_Metrics.TotalTrades; }
    
    // New: Advanced Risk Metrics Getters - from v14
    double GetSortinoRatio() const { return m_Metrics.SortinoRatio; }
    double GetCalmarRatio() const { return m_Metrics.CalmarRatio; }
    double GetUlcerIndex() const { return m_Metrics.UlcerIndex; }
    double GetSterlingRatio() const { return m_Metrics.SterlingRatio; }
    double GetBurkeRatio() const { return m_Metrics.BurkeRatio; }
    double GetKellyPercentage() const { return m_Metrics.KellyPercentage; }
    double GetVaR95() const { return m_Metrics.VaR95; }
    double GetCVaR95() const { return m_Metrics.CVaR95; }
    double GetRecoveryFactor() const { return m_Metrics.RecoveryFactor; }
    
    // New: Return Metrics Getters - from v14
    double GetAnnualizedReturn() const { return m_Metrics.AnnualizedReturn; }
    double GetMonthlyReturn() const { return m_Metrics.MonthlyReturn; }
    double GetDailyReturn() const { return m_Metrics.DailyReturn; }
    double GetReturnStdDev() const { return m_Metrics.ReturnStdDev; }
    double GetReturnSkewness() const { return m_Metrics.ReturnSkewness; }
    double GetReturnKurtosis() const { return m_Metrics.ReturnKurtosis; }
    
    // New: Execution Quality Getters - from v14
    double GetAverageSlippage() const { return m_Metrics.AverageSlippage; }
    double GetMaxSlippage() const { return m_Metrics.MaxSlippage; }
    double GetMinSlippage() const { return m_Metrics.MinSlippage; }
    ulong GetAverageLatency() const { return m_Metrics.AverageLatency; }
    ulong GetMaxLatency() const { return m_Metrics.MaxLatency; }
    ulong GetMinLatency() const { return m_Metrics.MinLatency; }
    double GetExecutionSuccessRate() const { return m_Metrics.ExecutionSuccessRate; }
    int GetTotalRequotes() const { return m_Metrics.TotalRequotes; }
    double GetRequoteRate() const { return m_Metrics.RequoteRate; }
    
    // New: Benchmark Comparison Getters - from v14
    double GetBeta() const { return m_Metrics.Beta; }
    double GetAlpha() const { return m_Metrics.Alpha; }
    double GetCorrelation() const { return m_Metrics.Correlation; }
    double GetTreynorRatio() const { return m_Metrics.TreynorRatio; }
    double GetInformationRatio() const { return m_Metrics.InformationRatio; }
    double GetTrackingError() const { return m_Metrics.TrackingError; }
    
    // Reporting
    string GetPerformanceReport() const;
    string GetDetailedReport() const;
    bool ExportToCSV(const string filename) const;
    bool ExportToHTML(const string filename) const;
    
    // Analysis
    bool IsPerformanceDegrading() const;
    double GetRiskScore() const;
    string GetPerformanceGrade() const;
    
private:
    // Enhanced internal calculations
    void CalculateBasicMetrics();
    void CalculateRiskMetrics();
    void CalculateAdvancedMetrics();
    void UpdateConsecutiveStats(const double profit);
    void AddEquityPoint(const double equity);
    double CalculateStandardDeviation() const;
    double CalculateDownsideDeviation() const;
    
    // New: Advanced statistical calculations - from v14
    double CalculateSharpeRatioAdvanced() const;
    double CalculateSortinoRatioAdvanced() const;
    double CalculateCalmarRatioAdvanced() const;
    double CalculateUlcerIndexAdvanced() const;
    double CalculateVaRAdvanced(const double confidenceLevel) const;
    double CalculateCVaRAdvanced(const double confidenceLevel) const;
    double CalculateSkewness(const double data[], const int size) const;
    double CalculateKurtosis(const double data[], const int size) const;
    double CalculateKellyPercentageAdvanced() const;
    
    // New: Execution quality calculations - from v14
    void UpdateSlippageStatistics(const double slippage);
    void UpdateLatencyStatistics(const ulong latency);
    void CalculateExecutionQualityByTime();
    
    // New: Benchmark analysis - from v14
    void UpdateBenchmarkData();
    double CalculateBetaCoefficient() const;
    double CalculateAlphaCoefficient() const;
    double CalculateCorrelationWithBenchmark() const;
    
    // New: Time-based analysis - from v14
    void AnalyzePerformanceByHour();
    void AnalyzePerformanceByDay();
    void AnalyzePerformanceByMonth();
    void CalculateSeasonalMetrics();
    
    // New: Risk analysis - from v14
    void PerformDrawdownAnalysis();
    void CalculateRiskMetricsAdvanced();
    void AssessRiskProfile();
    
    // Utility methods
    string FormatCurrency(const double value) const;
    string FormatPercentage(const double value) const;
    string FormatLatency(const ulong latency) const;
    string FormatDuration(const int minutes) const;
    void LogPerformanceEvent(const string event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO);
    
    // New: Data validation and quality - from v14
    bool ValidateTradeData(const STradeRecord& trade) const;
    double CalculateDataQualityScore() const;
    void CleanupAnomalousData();
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPerformanceTracker::CPerformanceTracker() {
    m_pContext = NULL;
    m_bInitialized = false;
    m_bRealTimeTracking = true;
    m_iTradeCount = 0;
    m_iEquityCount = 0;
    m_dRunningSum = 0.0;
    m_dRunningSumSquares = 0.0;
    m_dLastEquityPeak = 0.0;
    m_iConsecutiveWins = 0;
    m_iConsecutiveLosses = 0;
    m_iMaxConsecutiveWins = 0;
    m_iMaxConsecutiveLosses = 0;
    
    // Initialize execution quality tracking - Enhanced from v14
    m_dTotalSlippage = 0.0;
    m_dSlippageSum = 0.0;
    m_dSlippageSumSquares = 0.0;
    m_ulTotalLatency = 0;
    m_ulLatencySum = 0;
    m_ulLatencySumSquares = 0;
    m_iTotalExecutions = 0;
    m_iTotalSuccessfulExecutions = 0;
    
    // Initialize time-based arrays - Enhanced from v14
    ArrayInitialize(m_dSlippageByHour, 0.0);
    ArrayInitialize(m_ulLatencyByHour, 0);
    ArrayInitialize(m_iExecutionsByHour, 0);
    ArrayInitialize(m_iSuccessByHour, 0);
    ArrayInitialize(m_dProfitByHour, 0.0);
    ArrayInitialize(m_dProfitByDay, 0.0);
    ArrayInitialize(m_dProfitByMonth, 0.0);
    ArrayInitialize(m_iTradesByHour, 0);
    ArrayInitialize(m_iTradesByDay, 0);
    ArrayInitialize(m_iTradesByMonth, 0);
    
    // Initialize benchmark comparison - Enhanced from v14
    m_iReturnCount = 0;
    m_sBenchmarkSymbol = "";
    m_dRiskFreeRate = 0.02; // Default 2% annual risk-free rate
    m_bUseBenchmark = false;
    
    // Initialize advanced risk tracking - Enhanced from v14
    m_iDrawdownCount = 0;
    
    // Initialize data quality tracking - Enhanced from v14
    m_dtLastDataQualityCheck = 0;
    m_dDataQualityScore = 100.0; // Start with perfect score
    m_iAnomalousTradesDetected = 0;
    m_iDataValidationErrors = 0;
    
    // Initialize metrics with enhanced fields
    ZeroMemory(m_Metrics);
    m_Metrics.ProfitFactor = 1.0;
    m_Metrics.LastUpdateTime = TimeCurrent();
    m_Metrics.PeriodStartTime = TimeCurrent();
    
    // Initialize advanced metrics with default values - Enhanced from v14
    m_Metrics.MinSlippage = DBL_MAX;
    m_Metrics.MinLatency = ULONG_MAX;
    m_Metrics.ExecutionSuccessRate = 100.0;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPerformanceTracker::~CPerformanceTracker() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize performance tracker                                   |
//+------------------------------------------------------------------+
bool CPerformanceTracker::Initialize(EAContext* context) {
    if (context == NULL) {
        Print("[PERFORMANCE TRACKER ERROR] Context is NULL");
        return false;
    }
    
    m_pContext = context;
    
    // Set report path
    m_sReportPath = "Reports\\Performance\\";
    
    // Initialize arrays
    ArrayResize(m_TradeHistory, 1000);
    ArrayResize(m_dEquityPeaks, 1000);
    ArrayResize(m_dEquityValues, 1000);
    ArrayResize(m_EquityTimes, 1000);
    
    // Reset metrics
    Reset();
    
    m_bInitialized = true;
    
    if (m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo("PerformanceTracker initialized successfully", __FUNCTION__);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize performance tracker                                 |
//+------------------------------------------------------------------+
void CPerformanceTracker::Deinitialize() {
    if (m_bInitialized && m_pContext != NULL && m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo(GetPerformanceReport(), __FUNCTION__);
        m_pContext->pLogger->LogInfo("PerformanceTracker deinitialized", __FUNCTION__);
    }
    
    m_bInitialized = false;
    m_pContext = NULL;
}

//+------------------------------------------------------------------+
//| Reset all metrics                                               |
//+------------------------------------------------------------------+
void CPerformanceTracker::Reset() {
    ZeroMemory(m_Metrics);
    m_Metrics.ProfitFactor = 1.0;
    m_Metrics.LastUpdateTime = TimeCurrent();
    m_Metrics.PeriodStartTime = TimeCurrent();
    
    m_iTradeCount = 0;
    m_iEquityCount = 0;
    m_dRunningSum = 0.0;
    m_dRunningSumSquares = 0.0;
    m_dLastEquityPeak = AccountInfoDouble(ACCOUNT_EQUITY);
    m_iConsecutiveWins = 0;
    m_iConsecutiveLosses = 0;
    m_iMaxConsecutiveWins = 0;
    m_iMaxConsecutiveLosses = 0;
    
    ArrayResize(m_TradeHistory, 0);
    ArrayResize(m_dEquityPeaks, 0);
    ArrayResize(m_dEquityValues, 0);
    ArrayResize(m_EquityTimes, 0);
    
    if (m_bInitialized && m_pContext != NULL && m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo("PerformanceTracker reset completed", __FUNCTION__);
    }
}

//+------------------------------------------------------------------+
//| Handle trade opening                                             |
//+------------------------------------------------------------------+
void CPerformanceTracker::OnTradeOpen(const ulong ticket, const ENUM_ORDER_TYPE type, 
                                      const double volume, const double price, 
                                      const double sl, const double tp) {
    if (!m_bInitialized) return;
    
    // Resize array if needed
    if (m_iTradeCount >= ArraySize(m_TradeHistory)) {
        ArrayResize(m_TradeHistory, ArraySize(m_TradeHistory) + 100);
    }
    
    // Record trade opening
    STradeRecord record;
    record.Ticket = ticket;
    record.OpenTime = TimeCurrent();
    record.Type = type;
    record.Volume = volume;
    record.OpenPrice = price;
    record.StopLoss = sl;
    record.TakeProfit = tp;
    record.CloseTime = 0;
    record.ClosePrice = 0;
    record.Profit = 0;
    record.Commission = 0;
    record.Swap = 0;
    record.Comment = "";
    record.DurationMinutes = 0;
    record.MaxFavorableExcursion = 0;
    record.MaxAdverseExcursion = 0;
    
    m_TradeHistory[m_iTradeCount] = record;
    m_iTradeCount++;
    
    LogPerformanceEvent(StringFormat("Trade opened: #%d, Type: %s, Volume: %.2f, Price: %.5f", 
                                    ticket, EnumToString(type), volume, price));
}

//+------------------------------------------------------------------+
//| Handle trade closing                                             |
//+------------------------------------------------------------------+
void CPerformanceTracker::OnTradeClose(const ulong ticket, const double closePrice, 
                                       const double profit, const double commission, 
                                       const double swap) {
    if (!m_bInitialized) return;
    
    // Find the trade record
    for (int i = 0; i < m_iTradeCount; i++) {
        if (m_TradeHistory[i].Ticket == ticket && m_TradeHistory[i].CloseTime == 0) {
            // Update trade record
            m_TradeHistory[i].CloseTime = TimeCurrent();
            m_TradeHistory[i].ClosePrice = closePrice;
            m_TradeHistory[i].Profit = profit;
            m_TradeHistory[i].Commission = commission;
            m_TradeHistory[i].Swap = swap;
            m_TradeHistory[i].DurationMinutes = (int)((m_TradeHistory[i].CloseTime - m_TradeHistory[i].OpenTime) / 60);
            
            // Update consecutive stats
            UpdateConsecutiveStats(profit);
            
            // Recalculate metrics
            CalculateMetrics();
            
            LogPerformanceEvent(StringFormat("Trade closed: #%d, Profit: %.2f, Duration: %d min", 
                                            ticket, profit, m_TradeHistory[i].DurationMinutes));
            break;
        }
    }
}

//+------------------------------------------------------------------+
//| Update equity tracking                                          |
//+------------------------------------------------------------------+
void CPerformanceTracker::UpdateEquity(const double currentEquity) {
    if (!m_bInitialized || !m_bRealTimeTracking) return;
    
    AddEquityPoint(currentEquity);
    UpdateDrawdown();
    
    // Update peak if necessary
    if (currentEquity > m_dLastEquityPeak) {
        m_dLastEquityPeak = currentEquity;
    }
    
    m_Metrics.LastUpdateTime = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Calculate all performance metrics                               |
//+------------------------------------------------------------------+
void CPerformanceTracker::CalculateMetrics() {
    if (!m_bInitialized) return;
    
    CalculateBasicMetrics();
    CalculateRiskMetrics();
    CalculateAdvancedMetrics();
    
    m_Metrics.LastUpdateTime = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Calculate basic performance metrics                             |
//+------------------------------------------------------------------+
void CPerformanceTracker::CalculateBasicMetrics() {
    m_Metrics.TotalTrades = 0;
    m_Metrics.WinningTrades = 0;
    m_Metrics.LosingTrades = 0;
    m_Metrics.TotalProfit = 0;
    m_Metrics.TotalLoss = 0;
    m_Metrics.LargestWin = 0;
    m_Metrics.LargestLoss = 0;
    
    double totalWinTime = 0;
    double totalLossTime = 0;
    double totalTradeTime = 0;
    
    for (int i = 0; i < m_iTradeCount; i++) {
        if (m_TradeHistory[i].CloseTime == 0) continue; // Skip open trades
        
        m_Metrics.TotalTrades++;
        double netProfit = m_TradeHistory[i].Profit + m_TradeHistory[i].Commission + m_TradeHistory[i].Swap;
        
        totalTradeTime += m_TradeHistory[i].DurationMinutes;
        
        if (netProfit > 0) {
            m_Metrics.WinningTrades++;
            m_Metrics.TotalProfit += netProfit;
            totalWinTime += m_TradeHistory[i].DurationMinutes;
            if (netProfit > m_Metrics.LargestWin) {
                m_Metrics.LargestWin = netProfit;
            }
        } else if (netProfit < 0) {
            m_Metrics.LosingTrades++;
            m_Metrics.TotalLoss += MathAbs(netProfit);
            totalLossTime += m_TradeHistory[i].DurationMinutes;
            if (MathAbs(netProfit) > m_Metrics.LargestLoss) {
                m_Metrics.LargestLoss = MathAbs(netProfit);
            }
        }
    }
    
    // Calculate derived metrics
    m_Metrics.NetProfit = m_Metrics.TotalProfit - m_Metrics.TotalLoss;
    m_Metrics.WinRate = (m_Metrics.TotalTrades > 0) ? (double)m_Metrics.WinningTrades / m_Metrics.TotalTrades * 100.0 : 0.0;
    m_Metrics.ProfitFactor = (m_Metrics.TotalLoss > 0) ? m_Metrics.TotalProfit / m_Metrics.TotalLoss : 
                            (m_Metrics.TotalProfit > 0 ? 999.0 : 1.0);
    
    m_Metrics.AverageWin = (m_Metrics.WinningTrades > 0) ? m_Metrics.TotalProfit / m_Metrics.WinningTrades : 0.0;
    m_Metrics.AverageLoss = (m_Metrics.LosingTrades > 0) ? m_Metrics.TotalLoss / m_Metrics.LosingTrades : 0.0;
    m_Metrics.Expectancy = (m_Metrics.TotalTrades > 0) ? m_Metrics.NetProfit / m_Metrics.TotalTrades : 0.0;
    
    // Time-based metrics
    m_Metrics.AverageTradeTime = (m_Metrics.TotalTrades > 0) ? totalTradeTime / m_Metrics.TotalTrades : 0.0;
    m_Metrics.AverageWinTime = (m_Metrics.WinningTrades > 0) ? totalWinTime / m_Metrics.WinningTrades : 0.0;
    m_Metrics.AverageLossTime = (m_Metrics.LosingTrades > 0) ? totalLossTime / m_Metrics.LosingTrades : 0.0;
    
    // Consecutive stats
    m_Metrics.MaxConsecutiveWins = m_iMaxConsecutiveWins;
    m_Metrics.MaxConsecutiveLosses = m_iMaxConsecutiveLosses;
}

//+------------------------------------------------------------------+
//| Get performance report                                          |
//+------------------------------------------------------------------+
string CPerformanceTracker::GetPerformanceReport() const {
    string report = "\n=== PERFORMANCE REPORT ===\n";
    report += StringFormat("Period: %s to %s\n", 
                          TimeToString(m_Metrics.PeriodStartTime), 
                          TimeToString(m_Metrics.LastUpdateTime));
    report += StringFormat("Total Trades: %d\n", m_Metrics.TotalTrades);
    report += StringFormat("Win Rate: %.2f%% (%d/%d)\n", 
                          m_Metrics.WinRate, m_Metrics.WinningTrades, m_Metrics.TotalTrades);
    report += StringFormat("Net Profit: %s\n", FormatCurrency(m_Metrics.NetProfit));
    report += StringFormat("Profit Factor: %.2f\n", m_Metrics.ProfitFactor);
    report += StringFormat("Expectancy: %s\n", FormatCurrency(m_Metrics.Expectancy));
    report += StringFormat("Max Drawdown: %s (%.2f%%)\n", 
                          FormatCurrency(m_Metrics.MaxDrawdown), m_Metrics.MaxDrawdownPercent);
    report += StringFormat("Sharpe Ratio: %.2f\n", m_Metrics.SharpeRatio);
    report += "========================\n";
    
    return report;
}

//+------------------------------------------------------------------+
//| Format currency value                                           |
//+------------------------------------------------------------------+
string CPerformanceTracker::FormatCurrency(const double value) const {
    return StringFormat("%.2f %s", value, AccountInfoString(ACCOUNT_CURRENCY));
}

//+------------------------------------------------------------------+
//| Format percentage value                                         |
//+------------------------------------------------------------------+
string CPerformanceTracker::FormatPercentage(const double value) const {
    return StringFormat("%.2f%%", value);
}

//+------------------------------------------------------------------+
//| Log performance event                                           |
//+------------------------------------------------------------------+
void CPerformanceTracker::LogPerformanceEvent(const string event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO) {
    if (m_pContext != NULL && m_pContext->pLogger != NULL) {
        switch(level) {
        case LOG_LEVEL_ERROR:
            m_pContext->pLogger->LogError(event, __FUNCTION__);
            break;
        case LOG_LEVEL_WARNING:
            m_pContext->pLogger->LogWarning(event, __FUNCTION__);
            break;
        default:
            m_pContext->pLogger->LogInfo(event, __FUNCTION__);
            break;
        }
    }
}

//+------------------------------------------------------------------+
//| Update consecutive statistics                                   |
//+------------------------------------------------------------------+
void CPerformanceTracker::UpdateConsecutiveStats(const double profit) {
    if (profit > 0) {
        m_iConsecutiveWins++;
        m_iConsecutiveLosses = 0;
        if (m_iConsecutiveWins > m_iMaxConsecutiveWins) {
            m_iMaxConsecutiveWins = m_iConsecutiveWins;
        }
    } else if (profit < 0) {
        m_iConsecutiveLosses++;
        m_iConsecutiveWins = 0;
        if (m_iConsecutiveLosses > m_iMaxConsecutiveLosses) {
            m_iMaxConsecutiveLosses = m_iConsecutiveLosses;
        }
    }
}

//+------------------------------------------------------------------+
//| Add equity point for tracking                                   |
//+------------------------------------------------------------------+
void CPerformanceTracker::AddEquityPoint(const double equity) {
    if (m_iEquityCount >= ArraySize(m_dEquityValues)) {
        ArrayResize(m_dEquityValues, ArraySize(m_dEquityValues) + 100);
        ArrayResize(m_EquityTimes, ArraySize(m_EquityTimes) + 100);
    }
    
    m_dEquityValues[m_iEquityCount] = equity;
    m_EquityTimes[m_iEquityCount] = TimeCurrent();
    m_iEquityCount++;
}

//+------------------------------------------------------------------+
//| Update drawdown calculations                                    |
//+------------------------------------------------------------------+
void CPerformanceTracker::UpdateDrawdown() {
    if (m_iEquityCount == 0) return;
    
    double currentEquity = m_dEquityValues[m_iEquityCount - 1];
    
    // Update current drawdown
    m_Metrics.CurrentDrawdown = m_dLastEquityPeak - currentEquity;
    
    // Update max drawdown
    if (m_Metrics.CurrentDrawdown > m_Metrics.MaxDrawdown) {
        m_Metrics.MaxDrawdown = m_Metrics.CurrentDrawdown;
        if (m_dLastEquityPeak > 0) {
            m_Metrics.MaxDrawdownPercent = (m_Metrics.MaxDrawdown / m_dLastEquityPeak) * 100.0;
        }
    }
}

//+------------------------------------------------------------------+
//| Calculate risk metrics                                          |
//+------------------------------------------------------------------+
void CPerformanceTracker::CalculateRiskMetrics() {
    if (m_Metrics.TotalTrades < 2) {
        m_Metrics.SharpeRatio = 0.0;
        m_Metrics.SortinoRatio = 0.0;
        return;
    }
    
    double stdDev = CalculateStandardDeviation();
    double downsideDev = CalculateDownsideDeviation();
    
    // Sharpe Ratio (assuming risk-free rate = 0)
    m_Metrics.SharpeRatio = (stdDev > 0) ? (m_Metrics.Expectancy / stdDev) : 0.0;
    
    // Sortino Ratio
    m_Metrics.SortinoRatio = (downsideDev > 0) ? (m_Metrics.Expectancy / downsideDev) : 0.0;
    
    // Calmar Ratio
    m_Metrics.CalmarRatio = (m_Metrics.MaxDrawdown > 0) ? 
                           (m_Metrics.NetProfit / m_Metrics.MaxDrawdown) : 0.0;
}

//+------------------------------------------------------------------+
//| Calculate standard deviation of returns                         |
//+------------------------------------------------------------------+
double CPerformanceTracker::CalculateStandardDeviation() const {
    if (m_Metrics.TotalTrades < 2) return 0.0;
    
    double sumSquaredDeviations = 0.0;
    
    for (int i = 0; i < m_iTradeCount; i++) {
        if (m_TradeHistory[i].CloseTime == 0) continue;
        
        double netProfit = m_TradeHistory[i].Profit + m_TradeHistory[i].Commission + m_TradeHistory[i].Swap;
        double deviation = netProfit - m_Metrics.Expectancy;
        sumSquaredDeviations += deviation * deviation;
    }
    
    return MathSqrt(sumSquaredDeviations / (m_Metrics.TotalTrades - 1));
}

//+------------------------------------------------------------------+
//| Calculate downside deviation                                    |
//+------------------------------------------------------------------+
double CPerformanceTracker::CalculateDownsideDeviation() const {
    if (m_Metrics.TotalTrades < 2) return 0.0;
    
    double sumSquaredDownsideDeviations = 0.0;
    int downsideCount = 0;
    
    for (int i = 0; i < m_iTradeCount; i++) {
        if (m_TradeHistory[i].CloseTime == 0) continue;
        
        double netProfit = m_TradeHistory[i].Profit + m_TradeHistory[i].Commission + m_TradeHistory[i].Swap;
        if (netProfit < 0) {
            double deviation = netProfit - 0; // Target return = 0
            sumSquaredDownsideDeviations += deviation * deviation;
            downsideCount++;
        }
    }
    
    return (downsideCount > 0) ? MathSqrt(sumSquaredDownsideDeviations / downsideCount) : 0.0;
}

//+------------------------------------------------------------------+
//| Calculate advanced metrics                                      |
//+------------------------------------------------------------------+
void CPerformanceTracker::CalculateAdvancedMetrics() {
    // Recovery Factor
    m_Metrics.RecoveryFactor = (m_Metrics.MaxDrawdown > 0) ? 
                              (m_Metrics.NetProfit / m_Metrics.MaxDrawdown) : 0.0;
    
    // Profit to Max DD Ratio
    m_Metrics.ProfitToMaxDDRatio = m_Metrics.RecoveryFactor;
}

//+------------------------------------------------------------------+
//| Check if performance is degrading                              |
//+------------------------------------------------------------------+
bool CPerformanceTracker::IsPerformanceDegrading() const {
    if (m_Metrics.TotalTrades < 10) return false;
    
    // Check recent performance vs overall
    int recentTrades = MathMin(10, m_Metrics.TotalTrades);
    int recentWins = 0;
    double recentProfit = 0.0;
    
    for (int i = m_iTradeCount - recentTrades; i < m_iTradeCount; i++) {
        if (m_TradeHistory[i].CloseTime == 0) continue;
        
        double netProfit = m_TradeHistory[i].Profit + m_TradeHistory[i].Commission + m_TradeHistory[i].Swap;
        recentProfit += netProfit;
        if (netProfit > 0) recentWins++;
    }
    
    double recentWinRate = (double)recentWins / recentTrades * 100.0;
    double recentExpectancy = recentProfit / recentTrades;
    
    // Performance is degrading if recent metrics are significantly worse
    return (recentWinRate < m_Metrics.WinRate * 0.7 || 
            recentExpectancy < m_Metrics.Expectancy * 0.5);
}

//+------------------------------------------------------------------+
//| Get risk score (0-100, higher = riskier)                      |
//+------------------------------------------------------------------+
double CPerformanceTracker::GetRiskScore() const {
    double score = 0.0;
    
    // Drawdown component (0-40 points)
    if (m_Metrics.MaxDrawdownPercent > 20) score += 40;
    else score += (m_Metrics.MaxDrawdownPercent / 20.0) * 40;
    
    // Win rate component (0-30 points, inverted)
    if (m_Metrics.WinRate < 30) score += 30;
    else if (m_Metrics.WinRate > 70) score += 0;
    else score += (70 - m_Metrics.WinRate) / 40.0 * 30;
    
    // Profit factor component (0-30 points, inverted)
    if (m_Metrics.ProfitFactor < 1.0) score += 30;
    else if (m_Metrics.ProfitFactor > 2.0) score += 0;
    else score += (2.0 - m_Metrics.ProfitFactor) * 30;
    
    return MathMin(100.0, score);
}

//+------------------------------------------------------------------+
//| Get performance grade                                           |
//+------------------------------------------------------------------+
string CPerformanceTracker::GetPerformanceGrade() const {
    double riskScore = GetRiskScore();
    
    if (m_Metrics.NetProfit > 0 && m_Metrics.ProfitFactor > 1.5 && riskScore < 20) return "A+";
    if (m_Metrics.NetProfit > 0 && m_Metrics.ProfitFactor > 1.3 && riskScore < 30) return "A";
    if (m_Metrics.NetProfit > 0 && m_Metrics.ProfitFactor > 1.2 && riskScore < 40) return "B+";
    if (m_Metrics.NetProfit > 0 && m_Metrics.ProfitFactor > 1.1 && riskScore < 50) return "B";
    if (m_Metrics.NetProfit > 0 && m_Metrics.ProfitFactor > 1.0 && riskScore < 60) return "C+";
    if (m_Metrics.NetProfit > 0 && riskScore < 70) return "C";
    if (m_Metrics.NetProfit >= 0) return "D";
    
    return "F";
}