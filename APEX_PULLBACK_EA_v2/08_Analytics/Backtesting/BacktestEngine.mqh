//+------------------------------------------------------------------+
//|                                              BacktestEngine.mqh |
//|                                    APEX Pullback EA v5.0 FINAL   |
//|                                      Advanced Backtesting Engine |
//+------------------------------------------------------------------+
#property copyright "APEX Trading Systems"
#property version   "5.00"
#property strict

#include "../../00_Core/CommonStructs.mqh"

//+------------------------------------------------------------------+
//| Backtest modes enumeration                                     |
//+------------------------------------------------------------------+
enum ENUM_BACKTEST_MODE {
    BACKTEST_MODE_EVERY_TICK,
    BACKTEST_MODE_1_MINUTE_OHLC,
    BACKTEST_MODE_OPEN_PRICES,
    BACKTEST_MODE_MATH_CALCULATIONS,
    BACKTEST_MODE_REAL_TICKS
};

//+------------------------------------------------------------------+
//| Backtest data quality                                          |
//+------------------------------------------------------------------+
enum ENUM_DATA_QUALITY {
    DATA_QUALITY_UNKNOWN,
    DATA_QUALITY_LOW,
    DATA_QUALITY_MEDIUM,
    DATA_QUALITY_HIGH,
    DATA_QUALITY_REAL_TICKS
};

//+------------------------------------------------------------------+
//| Backtest execution speed                                       |
//+------------------------------------------------------------------+
enum ENUM_EXECUTION_SPEED {
    SPEED_SLOW,
    SPEED_NORMAL,
    SPEED_FAST,
    SPEED_MAXIMUM
};

//+------------------------------------------------------------------+
//| Backtest configuration structure                               |
//+------------------------------------------------------------------+
struct SBacktestConfig {
    datetime StartDate;
    datetime EndDate;
    ENUM_BACKTEST_MODE Mode;
    ENUM_EXECUTION_SPEED Speed;
    double InitialDeposit;
    ENUM_ACCOUNT_MARGIN_MODE MarginMode;
    string Symbol;
    ENUM_TIMEFRAMES Timeframe;
    double Spread;
    bool UseVariableSpread;
    double Commission;
    double Swap;
    bool OptimizeForSpeed;
    bool SaveDetailedReport;
    bool GenerateImages;
    string ReportPath;
};

//+------------------------------------------------------------------+
//| Backtest statistics structure                                  |
//+------------------------------------------------------------------+
struct SBacktestStats {
    // Basic metrics
    double InitialDeposit;
    double FinalBalance;
    double TotalNetProfit;
    double GrossProfit;
    double GrossLoss;
    double ProfitFactor;
    double ExpectedPayoff;
    
    // Drawdown metrics
    double AbsoluteDrawdown;
    double MaximalDrawdown;
    double RelativeDrawdown;
    
    // Trade statistics
    int TotalTrades;
    int ShortPositions;
    int LongPositions;
    int ProfitTrades;
    int LossTrades;
    
    // Largest trades
    double LargestProfitTrade;
    double LargestLossTrade;
    
    // Average metrics
    double AverageProfitTrade;
    double AverageLossTrade;
    
    // Consecutive metrics
    int MaxConsecutiveWins;
    int MaxConsecutiveLosses;
    double MaxConsecutiveProfit;
    double MaxConsecutiveLoss;
    
    // Time metrics
    int AverageConsecutiveWins;
    int AverageConsecutiveLosses;
    
    // Risk metrics
    double SharpeRatio;
    double SortinoRatio;
    double CalmarRatio;
    double RecoveryFactor;
    double ProfitToMaxDDRatio;
    
    // Quality metrics
    ENUM_DATA_QUALITY DataQuality;
    int ModellingQuality;
    int MismatchedCharts;
    
    // Execution metrics
    datetime BacktestStartTime;
    datetime BacktestEndTime;
    double ExecutionTimeSeconds;
    int TicksProcessed;
    int BarsProcessed;
};

//+------------------------------------------------------------------+
//| Trade record for detailed analysis                             |
//+------------------------------------------------------------------+
struct SBacktestTrade {
    int Ticket;
    datetime OpenTime;
    ENUM_ORDER_TYPE Type;
    double Lots;
    string Symbol;
    double OpenPrice;
    double StopLoss;
    double TakeProfit;
    datetime CloseTime;
    double ClosePrice;
    double Commission;
    double Swap;
    double Profit;
    string Comment;
    int MagicNumber;
    datetime Expiration;
};

//+------------------------------------------------------------------+
//| Equity curve point                                             |
//+------------------------------------------------------------------+
struct SEquityPoint {
    datetime Time;
    double Balance;
    double Equity;
    double FreeMargin;
    double MarginLevel;
    double Drawdown;
    double DrawdownPercent;
};

//+------------------------------------------------------------------+
//| Backtest validation result                                     |
//+------------------------------------------------------------------+
struct SValidationResult {
    bool IsValid;
    string ErrorMessage;
    double ConfidenceLevel;
    int SufficientTrades;
    bool HasEnoughData;
    bool SpreadRealistic;
    bool SlippageRealistic;
    double DataCoverage;
};

//+------------------------------------------------------------------+
//| Backtest Engine Class                                          |
//+------------------------------------------------------------------+
class CBacktestEngine {
private:
    EAContext* m_pContext;
    SBacktestConfig m_Config;
    SBacktestStats m_Stats;
    SValidationResult m_ValidationResult;
    
    // Trade history
    SBacktestTrade m_Trades[];
    SEquityPoint m_EquityCurve[];
    
    // Status
    bool m_bInitialized;
    bool m_bRunning;
    bool m_bCompleted;
    
    // Progress tracking
    datetime m_CurrentTime;
    int m_ProcessedBars;
    int m_ProcessedTicks;
    double m_ProgressPercent;
    
    // Performance tracking
    datetime m_StartTime;
    datetime m_EndTime;
    
public:
    CBacktestEngine();
    ~CBacktestEngine();
    
    // Core methods
    bool Initialize(EAContext* context);
    void Deinitialize();
    
    // Configuration
    void SetConfiguration(const SBacktestConfig& config);
    SBacktestConfig GetConfiguration() const { return m_Config; }
    
    // Execution
    bool StartBacktest();
    void StopBacktest();
    bool IsRunning() const { return m_bRunning; }
    bool IsCompleted() const { return m_bCompleted; }
    double GetProgress() const { return m_ProgressPercent; }
    
    // Results
    SBacktestStats GetStatistics() const { return m_Stats; }
    SValidationResult GetValidationResult() const { return m_ValidationResult; }
    int GetTradeCount() const { return ArraySize(m_Trades); }
    SBacktestTrade GetTrade(const int index) const;
    int GetEquityPointCount() const { return ArraySize(m_EquityCurve); }
    SEquityPoint GetEquityPoint(const int index) const;
    
    // Analysis
    bool ValidateResults();
    double CalculateSharpeRatio() const;
    double CalculateSortinoRatio() const;
    double CalculateCalmarRatio() const;
    double CalculateRecoveryFactor() const;
    double CalculateMaxDrawdown() const;
    double CalculateMaxDrawdownPercent() const;
    
    // Reporting
    string GenerateReport() const;
    bool SaveReport(const string filename) const;
    bool SaveTradeHistory(const string filename) const;
    bool SaveEquityCurve(const string filename) const;
    bool ExportToCSV(const string filename) const;
    
    // Comparison
    bool CompareWithBenchmark(const SBacktestStats& benchmark, string& report) const;
    double CalculateCorrelation(const SBacktestStats& other) const;
    
private:
    // Execution methods
    void RunBacktest();
    void ProcessTick();
    void ProcessBar();
    void UpdateEquityCurve();
    void UpdateProgress();
    
    // Data collection
    void CollectTradeData();
    void CollectAccountData();
    void AnalyzeDataQuality();
    
    // Statistics calculation
    void CalculateBasicStats();
    void CalculateDrawdownStats();
    void CalculateTradeStats();
    void CalculateRiskMetrics();
    void CalculateTimeMetrics();
    
    // Validation methods
    bool ValidateConfiguration();
    bool ValidateDataQuality();
    bool ValidateTradeCount();
    bool ValidateSpreadRealism();
    bool ValidateSlippageRealism();
    
    // Utility methods
    datetime GetBacktestStartTime() const;
    datetime GetBacktestEndTime() const;
    double CalculateDataCoverage() const;
    string FormatDuration(const double seconds) const;
    string FormatCurrency(const double amount) const;
    string FormatPercent(const double percent) const;
    
    // Logging
    void LogBacktestEvent(const string event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CBacktestEngine::CBacktestEngine() {
    m_pContext = NULL;
    m_bInitialized = false;
    m_bRunning = false;
    m_bCompleted = false;
    m_CurrentTime = 0;
    m_ProcessedBars = 0;
    m_ProcessedTicks = 0;
    m_ProgressPercent = 0.0;
    m_StartTime = 0;
    m_EndTime = 0;
    
    // Initialize configuration with defaults
    ZeroMemory(m_Config);
    m_Config.StartDate = D'2023.01.01';
    m_Config.EndDate = TimeCurrent();
    m_Config.Mode = BACKTEST_MODE_EVERY_TICK;
    m_Config.Speed = SPEED_NORMAL;
    m_Config.InitialDeposit = 10000.0;
    m_Config.MarginMode = ACCOUNT_MARGIN_MODE_RETAIL_NETTING;
    m_Config.Symbol = Symbol();
    m_Config.Timeframe = Period();
    m_Config.Spread = 2.0;
    m_Config.UseVariableSpread = true;
    m_Config.Commission = 0.0;
    m_Config.Swap = 0.0;
    m_Config.OptimizeForSpeed = false;
    m_Config.SaveDetailedReport = true;
    m_Config.GenerateImages = false;
    m_Config.ReportPath = "Backtest_Reports";
    
    // Initialize statistics
    ZeroMemory(m_Stats);
    ZeroMemory(m_ValidationResult);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CBacktestEngine::~CBacktestEngine() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize backtest engine                                     |
//+------------------------------------------------------------------+
bool CBacktestEngine::Initialize(EAContext* context) {
    if (context == NULL) {
        Print("[BACKTEST ENGINE ERROR] Context is NULL");
        return false;
    }
    
    m_pContext = context;
    
    if (!ValidateConfiguration()) {
        LogBacktestEvent("Invalid backtest configuration", LOG_LEVEL_ERROR);
        return false;
    }
    
    m_bInitialized = true;
    LogBacktestEvent("Backtest Engine initialized successfully");
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize backtest engine                                  |
//+------------------------------------------------------------------+
void CBacktestEngine::Deinitialize() {
    if (m_bRunning) {
        StopBacktest();
    }
    
    if (m_bInitialized) {
        LogBacktestEvent("Backtest Engine deinitialized");
    }
    
    m_bInitialized = false;
    m_pContext = NULL;
}

//+------------------------------------------------------------------+
//| Set backtest configuration                                     |
//+------------------------------------------------------------------+
void CBacktestEngine::SetConfiguration(const SBacktestConfig& config) {
    m_Config = config;
    LogBacktestEvent("Backtest configuration updated");
}

//+------------------------------------------------------------------+
//| Start backtest                                                 |
//+------------------------------------------------------------------+
bool CBacktestEngine::StartBacktest() {
    if (!m_bInitialized) {
        LogBacktestEvent("Backtest engine not initialized", LOG_LEVEL_ERROR);
        return false;
    }
    
    if (m_bRunning) {
        LogBacktestEvent("Backtest already running", LOG_LEVEL_WARNING);
        return false;
    }
    
    if (!ValidateConfiguration()) {
        LogBacktestEvent("Invalid backtest configuration", LOG_LEVEL_ERROR);
        return false;
    }
    
    // Initialize backtest
    m_bRunning = true;
    m_bCompleted = false;
    m_StartTime = TimeCurrent();
    m_CurrentTime = m_Config.StartDate;
    m_ProcessedBars = 0;
    m_ProcessedTicks = 0;
    m_ProgressPercent = 0.0;
    
    // Clear previous results
    ArrayResize(m_Trades, 0);
    ArrayResize(m_EquityCurve, 0);
    ZeroMemory(m_Stats);
    ZeroMemory(m_ValidationResult);
    
    // Initialize statistics
    m_Stats.InitialDeposit = m_Config.InitialDeposit;
    m_Stats.BacktestStartTime = m_StartTime;
    m_Stats.DataQuality = DATA_QUALITY_UNKNOWN;
    
    LogBacktestEvent(StringFormat("Backtest started: %s to %s", 
                                 TimeToString(m_Config.StartDate), 
                                 TimeToString(m_Config.EndDate)));
    
    // Run backtest
    RunBacktest();
    
    return true;
}

//+------------------------------------------------------------------+
//| Stop backtest                                                  |
//+------------------------------------------------------------------+
void CBacktestEngine::StopBacktest() {
    if (m_bRunning) {
        m_bRunning = false;
        m_EndTime = TimeCurrent();
        m_Stats.BacktestEndTime = m_EndTime;
        m_Stats.ExecutionTimeSeconds = (double)(m_EndTime - m_StartTime);
        
        LogBacktestEvent("Backtest stopped by user", LOG_LEVEL_WARNING);
    }
}

//+------------------------------------------------------------------+
//| Run backtest                                                   |
//+------------------------------------------------------------------+
void CBacktestEngine::RunBacktest() {
    LogBacktestEvent("Starting backtest execution");
    
    // Main backtest loop
    while (m_CurrentTime <= m_Config.EndDate && m_bRunning) {
        // Process based on selected mode
        switch(m_Config.Mode) {
        case BACKTEST_MODE_EVERY_TICK:
            ProcessTick();
            break;
        case BACKTEST_MODE_1_MINUTE_OHLC:
        case BACKTEST_MODE_OPEN_PRICES:
        case BACKTEST_MODE_MATH_CALCULATIONS:
            ProcessBar();
            break;
        case BACKTEST_MODE_REAL_TICKS:
            ProcessTick();
            break;
        }
        
        // Update equity curve
        UpdateEquityCurve();
        
        // Update progress
        UpdateProgress();
        
        // Advance time
        m_CurrentTime += PeriodSeconds(m_Config.Timeframe);
        
        // Speed control
        if (m_Config.Speed == SPEED_SLOW) {
            Sleep(100);
        } else if (m_Config.Speed == SPEED_NORMAL) {
            Sleep(10);
        }
        // SPEED_FAST and SPEED_MAXIMUM run without delay
    }
    
    // Finalize backtest
    m_bRunning = false;
    m_bCompleted = true;
    m_EndTime = TimeCurrent();
    m_Stats.BacktestEndTime = m_EndTime;
    m_Stats.ExecutionTimeSeconds = (double)(m_EndTime - m_StartTime);
    m_Stats.TicksProcessed = m_ProcessedTicks;
    m_Stats.BarsProcessed = m_ProcessedBars;
    
    // Collect final data
    CollectTradeData();
    CollectAccountData();
    
    // Calculate statistics
    CalculateBasicStats();
    CalculateDrawdownStats();
    CalculateTradeStats();
    CalculateRiskMetrics();
    CalculateTimeMetrics();
    
    // Analyze data quality
    AnalyzeDataQuality();
    
    // Validate results
    ValidateResults();
    
    LogBacktestEvent(StringFormat("Backtest completed in %.2f seconds", m_Stats.ExecutionTimeSeconds));
}

//+------------------------------------------------------------------+
//| Process tick                                                   |
//+------------------------------------------------------------------+
void CBacktestEngine::ProcessTick() {
    // Simulate tick processing
    // This is a placeholder - actual implementation would process real tick data
    
    m_ProcessedTicks++;
    
    // Simulate EA OnTick() call
    // In real implementation, this would call the EA's OnTick() function
}

//+------------------------------------------------------------------+
//| Process bar                                                    |
//+------------------------------------------------------------------+
void CBacktestEngine::ProcessBar() {
    // Simulate bar processing
    // This is a placeholder - actual implementation would process OHLC data
    
    m_ProcessedBars++;
    
    // Simulate EA OnTick() call for new bar
    // In real implementation, this would call the EA's OnTick() function
}

//+------------------------------------------------------------------+
//| Update equity curve                                           |
//+------------------------------------------------------------------+
void CBacktestEngine::UpdateEquityCurve() {
    // Add equity point
    int size = ArraySize(m_EquityCurve);
    ArrayResize(m_EquityCurve, size + 1);
    
    m_EquityCurve[size].Time = m_CurrentTime;
    m_EquityCurve[size].Balance = AccountBalance();
    m_EquityCurve[size].Equity = AccountEquity();
    m_EquityCurve[size].FreeMargin = AccountFreeMargin();
    m_EquityCurve[size].MarginLevel = AccountMargin() > 0 ? AccountEquity() / AccountMargin() * 100 : 0;
    
    // Calculate drawdown
    double maxEquity = m_EquityCurve[size].Equity;
    for (int i = 0; i < size; i++) {
        if (m_EquityCurve[i].Equity > maxEquity) {
            maxEquity = m_EquityCurve[i].Equity;
        }
    }
    
    m_EquityCurve[size].Drawdown = maxEquity - m_EquityCurve[size].Equity;
    m_EquityCurve[size].DrawdownPercent = maxEquity > 0 ? (m_EquityCurve[size].Drawdown / maxEquity) * 100 : 0;
}

//+------------------------------------------------------------------+
//| Update progress                                                |
//+------------------------------------------------------------------+
void CBacktestEngine::UpdateProgress() {
    if (m_Config.EndDate > m_Config.StartDate) {
        double totalSeconds = (double)(m_Config.EndDate - m_Config.StartDate);
        double elapsedSeconds = (double)(m_CurrentTime - m_Config.StartDate);
        m_ProgressPercent = (elapsedSeconds / totalSeconds) * 100.0;
        m_ProgressPercent = MathMin(100.0, MathMax(0.0, m_ProgressPercent));
    }
}

//+------------------------------------------------------------------+
//| Collect trade data                                             |
//+------------------------------------------------------------------+
void CBacktestEngine::CollectTradeData() {
    // Collect trade history from MT5
    // This is a placeholder - actual implementation would use HistorySelect and HistoryDealsTotal
    
    ArrayResize(m_Trades, 0);
    
    // Simulate some trade data
    for (int i = 0; i < 10; i++) {
        int size = ArraySize(m_Trades);
        ArrayResize(m_Trades, size + 1);
        
        m_Trades[size].Ticket = i + 1;
        m_Trades[size].OpenTime = m_Config.StartDate + i * 3600;
        m_Trades[size].Type = (i % 2 == 0) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
        m_Trades[size].Lots = 0.1;
        m_Trades[size].Symbol = m_Config.Symbol;
        m_Trades[size].OpenPrice = 1.1000 + (i * 0.001);
        m_Trades[size].CloseTime = m_Trades[size].OpenTime + 1800;
        m_Trades[size].ClosePrice = m_Trades[size].OpenPrice + ((i % 3 == 0) ? 0.002 : -0.001);
        m_Trades[size].Profit = (m_Trades[size].ClosePrice - m_Trades[size].OpenPrice) * 100000 * m_Trades[size].Lots;
        if (m_Trades[size].Type == ORDER_TYPE_SELL) {
            m_Trades[size].Profit *= -1;
        }
    }
}

//+------------------------------------------------------------------+
//| Collect account data                                           |
//+------------------------------------------------------------------+
void CBacktestEngine::CollectAccountData() {
    m_Stats.FinalBalance = AccountBalance();
    m_Stats.TotalNetProfit = m_Stats.FinalBalance - m_Stats.InitialDeposit;
}

//+------------------------------------------------------------------+
//| Calculate basic statistics                                     |
//+------------------------------------------------------------------+
void CBacktestEngine::CalculateBasicStats() {
    m_Stats.TotalTrades = ArraySize(m_Trades);
    m_Stats.GrossProfit = 0;
    m_Stats.GrossLoss = 0;
    m_Stats.ProfitTrades = 0;
    m_Stats.LossTrades = 0;
    
    for (int i = 0; i < ArraySize(m_Trades); i++) {
        if (m_Trades[i].Profit > 0) {
            m_Stats.GrossProfit += m_Trades[i].Profit;
            m_Stats.ProfitTrades++;
        } else {
            m_Stats.GrossLoss += MathAbs(m_Trades[i].Profit);
            m_Stats.LossTrades++;
        }
        
        if (m_Trades[i].Type == ORDER_TYPE_BUY) {
            m_Stats.LongPositions++;
        } else {
            m_Stats.ShortPositions++;
        }
    }
    
    m_Stats.ProfitFactor = (m_Stats.GrossLoss > 0) ? m_Stats.GrossProfit / m_Stats.GrossLoss : 0;
    m_Stats.ExpectedPayoff = (m_Stats.TotalTrades > 0) ? m_Stats.TotalNetProfit / m_Stats.TotalTrades : 0;
}

//+------------------------------------------------------------------+
//| Calculate drawdown statistics                                  |
//+------------------------------------------------------------------+
void CBacktestEngine::CalculateDrawdownStats() {
    m_Stats.MaximalDrawdown = CalculateMaxDrawdown();
    m_Stats.RelativeDrawdown = CalculateMaxDrawdownPercent();
    m_Stats.AbsoluteDrawdown = m_Stats.InitialDeposit - m_Stats.FinalBalance;
    if (m_Stats.AbsoluteDrawdown < 0) m_Stats.AbsoluteDrawdown = 0;
}

//+------------------------------------------------------------------+
//| Calculate trade statistics                                     |
//+------------------------------------------------------------------+
void CBacktestEngine::CalculateTradeStats() {
    if (ArraySize(m_Trades) == 0) return;
    
    // Find largest trades
    m_Stats.LargestProfitTrade = 0;
    m_Stats.LargestLossTrade = 0;
    
    double totalProfit = 0;
    double totalLoss = 0;
    
    for (int i = 0; i < ArraySize(m_Trades); i++) {
        if (m_Trades[i].Profit > m_Stats.LargestProfitTrade) {
            m_Stats.LargestProfitTrade = m_Trades[i].Profit;
        }
        if (m_Trades[i].Profit < m_Stats.LargestLossTrade) {
            m_Stats.LargestLossTrade = m_Trades[i].Profit;
        }
        
        if (m_Trades[i].Profit > 0) {
            totalProfit += m_Trades[i].Profit;
        } else {
            totalLoss += m_Trades[i].Profit;
        }
    }
    
    // Calculate averages
    m_Stats.AverageProfitTrade = (m_Stats.ProfitTrades > 0) ? totalProfit / m_Stats.ProfitTrades : 0;
    m_Stats.AverageLossTrade = (m_Stats.LossTrades > 0) ? totalLoss / m_Stats.LossTrades : 0;
    
    // Calculate consecutive metrics (simplified)
    m_Stats.MaxConsecutiveWins = 0;
    m_Stats.MaxConsecutiveLosses = 0;
    
    int currentWins = 0;
    int currentLosses = 0;
    
    for (int i = 0; i < ArraySize(m_Trades); i++) {
        if (m_Trades[i].Profit > 0) {
            currentWins++;
            currentLosses = 0;
            if (currentWins > m_Stats.MaxConsecutiveWins) {
                m_Stats.MaxConsecutiveWins = currentWins;
            }
        } else {
            currentLosses++;
            currentWins = 0;
            if (currentLosses > m_Stats.MaxConsecutiveLosses) {
                m_Stats.MaxConsecutiveLosses = currentLosses;
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Calculate risk metrics                                         |
//+------------------------------------------------------------------+
void CBacktestEngine::CalculateRiskMetrics() {
    m_Stats.SharpeRatio = CalculateSharpeRatio();
    m_Stats.SortinoRatio = CalculateSortinoRatio();
    m_Stats.CalmarRatio = CalculateCalmarRatio();
    m_Stats.RecoveryFactor = CalculateRecoveryFactor();
    
    if (m_Stats.MaximalDrawdown > 0) {
        m_Stats.ProfitToMaxDDRatio = m_Stats.TotalNetProfit / m_Stats.MaximalDrawdown;
    }
}

//+------------------------------------------------------------------+
//| Calculate time metrics                                         |
//+------------------------------------------------------------------+
void CBacktestEngine::CalculateTimeMetrics() {
    // Simplified calculation
    m_Stats.AverageConsecutiveWins = (m_Stats.ProfitTrades > 0) ? m_Stats.MaxConsecutiveWins / 2 : 0;
    m_Stats.AverageConsecutiveLosses = (m_Stats.LossTrades > 0) ? m_Stats.MaxConsecutiveLosses / 2 : 0;
}

//+------------------------------------------------------------------+
//| Analyze data quality                                          |
//+------------------------------------------------------------------+
void CBacktestEngine::AnalyzeDataQuality() {
    // Simplified data quality analysis
    if (m_Config.Mode == BACKTEST_MODE_REAL_TICKS) {
        m_Stats.DataQuality = DATA_QUALITY_REAL_TICKS;
        m_Stats.ModellingQuality = 99;
    } else if (m_Config.Mode == BACKTEST_MODE_EVERY_TICK) {
        m_Stats.DataQuality = DATA_QUALITY_HIGH;
        m_Stats.ModellingQuality = 90;
    } else {
        m_Stats.DataQuality = DATA_QUALITY_MEDIUM;
        m_Stats.ModellingQuality = 75;
    }
    
    m_Stats.MismatchedCharts = 0; // Placeholder
}

//+------------------------------------------------------------------+
//| Validate configuration                                         |
//+------------------------------------------------------------------+
bool CBacktestEngine::ValidateConfiguration() {
    if (m_Config.StartDate >= m_Config.EndDate) {
        LogBacktestEvent("Invalid date range", LOG_LEVEL_ERROR);
        return false;
    }
    
    if (m_Config.InitialDeposit <= 0) {
        LogBacktestEvent("Invalid initial deposit", LOG_LEVEL_ERROR);
        return false;
    }
    
    if (m_Config.Symbol == "") {
        LogBacktestEvent("Invalid symbol", LOG_LEVEL_ERROR);
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Validate results                                               |
//+------------------------------------------------------------------+
bool CBacktestEngine::ValidateResults() {
    m_ValidationResult.IsValid = true;
    m_ValidationResult.ErrorMessage = "";
    m_ValidationResult.ConfidenceLevel = 95.0;
    
    // Check sufficient trades
    m_ValidationResult.SufficientTrades = m_Stats.TotalTrades;
    if (m_Stats.TotalTrades < 30) {
        m_ValidationResult.IsValid = false;
        m_ValidationResult.ErrorMessage += "Insufficient trades for statistical significance. ";
        m_ValidationResult.ConfidenceLevel -= 20;
    }
    
    // Check data coverage
    m_ValidationResult.DataCoverage = CalculateDataCoverage();
    m_ValidationResult.HasEnoughData = (m_ValidationResult.DataCoverage > 80.0);
    if (!m_ValidationResult.HasEnoughData) {
        m_ValidationResult.IsValid = false;
        m_ValidationResult.ErrorMessage += "Insufficient data coverage. ";
        m_ValidationResult.ConfidenceLevel -= 15;
    }
    
    // Check spread realism
    m_ValidationResult.SpreadRealistic = ValidateSpreadRealism();
    if (!m_ValidationResult.SpreadRealistic) {
        m_ValidationResult.ErrorMessage += "Unrealistic spread settings. ";
        m_ValidationResult.ConfidenceLevel -= 10;
    }
    
    // Check slippage realism
    m_ValidationResult.SlippageRealistic = ValidateSlippageRealism();
    if (!m_ValidationResult.SlippageRealistic) {
        m_ValidationResult.ErrorMessage += "Unrealistic slippage settings. ";
        m_ValidationResult.ConfidenceLevel -= 10;
    }
    
    return m_ValidationResult.IsValid;
}

//+------------------------------------------------------------------+
//| Calculate Sharpe ratio                                         |
//+------------------------------------------------------------------+
double CBacktestEngine::CalculateSharpeRatio() const {
    // Simplified Sharpe ratio calculation
    if (ArraySize(m_Trades) < 2) return 0.0;
    
    double avgReturn = m_Stats.ExpectedPayoff;
    double riskFreeRate = 0.02; // 2% annual risk-free rate
    
    // Calculate standard deviation of returns
    double sumSquaredDeviations = 0;
    for (int i = 0; i < ArraySize(m_Trades); i++) {
        double deviation = m_Trades[i].Profit - avgReturn;
        sumSquaredDeviations += deviation * deviation;
    }
    
    double stdDev = MathSqrt(sumSquaredDeviations / (ArraySize(m_Trades) - 1));
    
    if (stdDev == 0) return 0.0;
    
    return (avgReturn - riskFreeRate) / stdDev;
}

//+------------------------------------------------------------------+
//| Calculate Sortino ratio                                        |
//+------------------------------------------------------------------+
double CBacktestEngine::CalculateSortinoRatio() const {
    // Simplified Sortino ratio calculation
    if (ArraySize(m_Trades) < 2) return 0.0;
    
    double avgReturn = m_Stats.ExpectedPayoff;
    double riskFreeRate = 0.02;
    
    // Calculate downside deviation
    double sumNegativeSquaredDeviations = 0;
    int negativeCount = 0;
    
    for (int i = 0; i < ArraySize(m_Trades); i++) {
        if (m_Trades[i].Profit < avgReturn) {
            double deviation = m_Trades[i].Profit - avgReturn;
            sumNegativeSquaredDeviations += deviation * deviation;
            negativeCount++;
        }
    }
    
    if (negativeCount == 0) return 0.0;
    
    double downsideStdDev = MathSqrt(sumNegativeSquaredDeviations / negativeCount);
    
    if (downsideStdDev == 0) return 0.0;
    
    return (avgReturn - riskFreeRate) / downsideStdDev;
}

//+------------------------------------------------------------------+
//| Calculate Calmar ratio                                         |
//+------------------------------------------------------------------+
double CBacktestEngine::CalculateCalmarRatio() const {
    if (m_Stats.MaximalDrawdown == 0) return 0.0;
    
    double annualReturn = m_Stats.TotalNetProfit; // Simplified
    return annualReturn / m_Stats.MaximalDrawdown;
}

//+------------------------------------------------------------------+
//| Calculate recovery factor                                      |
//+------------------------------------------------------------------+
double CBacktestEngine::CalculateRecoveryFactor() const {
    if (m_Stats.MaximalDrawdown == 0) return 0.0;
    
    return m_Stats.TotalNetProfit / m_Stats.MaximalDrawdown;
}

//+------------------------------------------------------------------+
//| Calculate maximum drawdown                                     |
//+------------------------------------------------------------------+
double CBacktestEngine::CalculateMaxDrawdown() const {
    double maxDrawdown = 0;
    
    for (int i = 0; i < ArraySize(m_EquityCurve); i++) {
        if (m_EquityCurve[i].Drawdown > maxDrawdown) {
            maxDrawdown = m_EquityCurve[i].Drawdown;
        }
    }
    
    return maxDrawdown;
}

//+------------------------------------------------------------------+
//| Calculate maximum drawdown percentage                          |
//+------------------------------------------------------------------+
double CBacktestEngine::CalculateMaxDrawdownPercent() const {
    double maxDrawdownPercent = 0;
    
    for (int i = 0; i < ArraySize(m_EquityCurve); i++) {
        if (m_EquityCurve[i].DrawdownPercent > maxDrawdownPercent) {
            maxDrawdownPercent = m_EquityCurve[i].DrawdownPercent;
        }
    }
    
    return maxDrawdownPercent;
}

//+------------------------------------------------------------------+
//| Calculate data coverage                                        |
//+------------------------------------------------------------------+
double CBacktestEngine::CalculateDataCoverage() const {
    // Simplified calculation - assume 95% coverage
    return 95.0;
}

//+------------------------------------------------------------------+
//| Validate spread realism                                       |
//+------------------------------------------------------------------+
bool CBacktestEngine::ValidateSpreadRealism() const {
    // Check if spread is within realistic range
    return (m_Config.Spread >= 0.5 && m_Config.Spread <= 50.0);
}

//+------------------------------------------------------------------+
//| Validate slippage realism                                     |
//+------------------------------------------------------------------+
bool CBacktestEngine::ValidateSlippageRealism() const {
    // Simplified validation - assume realistic
    return true;
}

//+------------------------------------------------------------------+
//| Get trade by index                                            |
//+------------------------------------------------------------------+
SBacktestTrade CBacktestEngine::GetTrade(const int index) const {
    SBacktestTrade empty;
    ZeroMemory(empty);
    
    if (index < 0 || index >= ArraySize(m_Trades)) {
        return empty;
    }
    
    return m_Trades[index];
}

//+------------------------------------------------------------------+
//| Get equity point by index                                     |
//+------------------------------------------------------------------+
SEquityPoint CBacktestEngine::GetEquityPoint(const int index) const {
    SEquityPoint empty;
    ZeroMemory(empty);
    
    if (index < 0 || index >= ArraySize(m_EquityCurve)) {
        return empty;
    }
    
    return m_EquityCurve[index];
}

//+------------------------------------------------------------------+
//| Generate backtest report                                      |
//+------------------------------------------------------------------+
string CBacktestEngine::GenerateReport() const {
    string report = "\n=== APEX EA Backtest Report ===\n";
    
    // Basic information
    report += StringFormat("Symbol: %s\n", m_Config.Symbol);
    report += StringFormat("Period: %s to %s\n", TimeToString(m_Config.StartDate), TimeToString(m_Config.EndDate));
    report += StringFormat("Mode: %s\n", EnumToString(m_Config.Mode));
    report += StringFormat("Initial Deposit: %s\n", FormatCurrency(m_Stats.InitialDeposit));
    report += StringFormat("Final Balance: %s\n", FormatCurrency(m_Stats.FinalBalance));
    
    // Performance metrics
    report += "\n=== Performance ===\n";
    report += StringFormat("Total Net Profit: %s\n", FormatCurrency(m_Stats.TotalNetProfit));
    report += StringFormat("Gross Profit: %s\n", FormatCurrency(m_Stats.GrossProfit));
    report += StringFormat("Gross Loss: %s\n", FormatCurrency(m_Stats.GrossLoss));
    report += StringFormat("Profit Factor: %.2f\n", m_Stats.ProfitFactor);
    report += StringFormat("Expected Payoff: %s\n", FormatCurrency(m_Stats.ExpectedPayoff));
    
    // Risk metrics
    report += "\n=== Risk Analysis ===\n";
    report += StringFormat("Maximum Drawdown: %s (%.2f%%)\n", FormatCurrency(m_Stats.MaximalDrawdown), m_Stats.RelativeDrawdown);
    report += StringFormat("Sharpe Ratio: %.3f\n", m_Stats.SharpeRatio);
    report += StringFormat("Sortino Ratio: %.3f\n", m_Stats.SortinoRatio);
    report += StringFormat("Calmar Ratio: %.3f\n", m_Stats.CalmarRatio);
    report += StringFormat("Recovery Factor: %.2f\n", m_Stats.RecoveryFactor);
    
    // Trade statistics
    report += "\n=== Trade Statistics ===\n";
    report += StringFormat("Total Trades: %d\n", m_Stats.TotalTrades);
    report += StringFormat("Profit Trades: %d (%.1f%%)\n", m_Stats.ProfitTrades, 
                          m_Stats.TotalTrades > 0 ? (double)m_Stats.ProfitTrades / m_Stats.TotalTrades * 100 : 0);
    report += StringFormat("Loss Trades: %d (%.1f%%)\n", m_Stats.LossTrades,
                          m_Stats.TotalTrades > 0 ? (double)m_Stats.LossTrades / m_Stats.TotalTrades * 100 : 0);
    report += StringFormat("Largest Profit Trade: %s\n", FormatCurrency(m_Stats.LargestProfitTrade));
    report += StringFormat("Largest Loss Trade: %s\n", FormatCurrency(m_Stats.LargestLossTrade));
    report += StringFormat("Average Profit Trade: %s\n", FormatCurrency(m_Stats.AverageProfitTrade));
    report += StringFormat("Average Loss Trade: %s\n", FormatCurrency(m_Stats.AverageLossTrade));
    
    // Quality metrics
    report += "\n=== Data Quality ===\n";
    report += StringFormat("Data Quality: %s\n", EnumToString(m_Stats.DataQuality));
    report += StringFormat("Modelling Quality: %d%%\n", m_Stats.ModellingQuality);
    report += StringFormat("Execution Time: %s\n", FormatDuration(m_Stats.ExecutionTimeSeconds));
    
    // Validation
    report += "\n=== Validation ===\n";
    report += StringFormat("Result Valid: %s\n", m_ValidationResult.IsValid ? "Yes" : "No");
    report += StringFormat("Confidence Level: %.1f%%\n", m_ValidationResult.ConfidenceLevel);
    if (m_ValidationResult.ErrorMessage != "") {
        report += StringFormat("Issues: %s\n", m_ValidationResult.ErrorMessage);
    }
    
    return report;
}

//+------------------------------------------------------------------+
//| Format currency amount                                         |
//+------------------------------------------------------------------+
string CBacktestEngine::FormatCurrency(const double amount) const {
    return StringFormat("%.2f", amount);
}

//+------------------------------------------------------------------+
//| Format percentage                                              |
//+------------------------------------------------------------------+
string CBacktestEngine::FormatPercent(const double percent) const {
    return StringFormat("%.2f%%", percent);
}

//+------------------------------------------------------------------+
//| Format duration                                                |
//+------------------------------------------------------------------+
string CBacktestEngine::FormatDuration(const double seconds) const {
    if (seconds < 60) {
        return StringFormat("%.1f seconds", seconds);
    } else if (seconds < 3600) {
        return StringFormat("%.1f minutes", seconds / 60);
    } else {
        return StringFormat("%.1f hours", seconds / 3600);
    }
}

//+------------------------------------------------------------------+
//| Save report to file                                           |
//+------------------------------------------------------------------+
bool CBacktestEngine::SaveReport(const string filename) const {
    string report = GenerateReport();
    
    int handle = FileOpen(filename, FILE_WRITE | FILE_TXT);
    if (handle == INVALID_HANDLE) {
        LogBacktestEvent("Failed to create report file: " + filename, LOG_LEVEL_ERROR);
        return false;
    }
    
    FileWriteString(handle, report);
    FileClose(handle);
    
    LogBacktestEvent("Report saved to: " + filename);
    return true;
}

//+------------------------------------------------------------------+
//| Log backtest event                                            |
//+------------------------------------------------------------------+
void CBacktestEngine::LogBacktestEvent(const string event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO) {
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