//+------------------------------------------------------------------+
//|                StrategyOptimizer.mqh - APEX Pullback EA v14.0   |
//|                Walk-Forward Analysis & Anti-Overfitting Module   |
//|                           Copyright 2025, APEX Forex            |
//+------------------------------------------------------------------+
#ifndef STRATEGY_OPTIMIZER_MQH
#define STRATEGY_OPTIMIZER_MQH

#include "CommonStructs.mqh"

namespace ApexPullback {

//+------------------------------------------------------------------+
//| Cấu trúc dữ liệu cho Walk-Forward Analysis                      |
//+------------------------------------------------------------------+
struct WalkForwardPeriod {
    datetime startTime;           // Thời gian bắt đầu period
    datetime endTime;             // Thời gian kết thúc period
    int totalTrades;              // Tổng số lệnh trong period
    int winningTrades;            // Số lệnh thắng
    double totalProfit;           // Tổng lợi nhuận
    double maxDrawdown;           // Drawdown tối đa
    double profitFactor;          // Profit Factor
    double winRate;               // Tỷ lệ thắng
    double sharpeRatio;           // Sharpe Ratio
    bool isStable;                // Period có ổn định không
    
    // Constructor
    WalkForwardPeriod() {
        startTime = 0;
        endTime = 0;
        totalTrades = 0;
        winningTrades = 0;
        totalProfit = 0.0;
        maxDrawdown = 0.0;
        profitFactor = 0.0;
        winRate = 0.0;
        sharpeRatio = 0.0;
        isStable = false;
    }
};

//+------------------------------------------------------------------+
//| Cấu trúc lưu trữ tham số tối ưu                                 |
//+------------------------------------------------------------------+
struct OptimalParameters {
    // Core trading parameters
    double RiskPercent;
    int ATRPeriod;
    double ATRMultiplier;
    int RSIPeriod;
    double RSIOverbought;
    double RSIOversold;
    int MAPeriod;
    double ProfitTarget;
    double StopLoss;
    int MaxTrades;
    
    // Advanced parameters
    double TrendStrength;
    double VolatilityThreshold;
    int LookbackPeriod;
    double CorrelationThreshold;
    double NewsImpactWeight;
    
    // Validation scores
    double InSampleScore;
    double OutOfSampleScore;
    double WalkForwardScore;
    double OverfittingPenalty;
    double StabilityScore;
    double RobustnessScore;
    double FinalScore;
    
    // Statistical measures
    double SharpeRatio;
    double SortinoRatio;
    double CalmarRatio;
    double MaxDrawdown;
    double ProfitFactor;
    double WinRate;
    
    // Constructor
    OptimalParameters() {
        RiskPercent = 2.0;
        ATRPeriod = 14;
        ATRMultiplier = 2.0;
        RSIPeriod = 14;
        RSIOverbought = 70.0;
        RSIOversold = 30.0;
        MAPeriod = 20;
        ProfitTarget = 100.0;
        StopLoss = 50.0;
        MaxTrades = 5;
        
        TrendStrength = 0.6;
        VolatilityThreshold = 0.02;
        LookbackPeriod = 50;
        CorrelationThreshold = 0.7;
        NewsImpactWeight = 0.3;
        
        InSampleScore = 0.0;
        OutOfSampleScore = 0.0;
        WalkForwardScore = 0.0;
        OverfittingPenalty = 0.0;
        StabilityScore = 0.0;
        RobustnessScore = 0.0;
        FinalScore = 0.0;
        
        SharpeRatio = 0.0;
        SortinoRatio = 0.0;
        CalmarRatio = 0.0;
        MaxDrawdown = 0.0;
        ProfitFactor = 0.0;
        WinRate = 0.0;
    }
};

//+------------------------------------------------------------------+
//| Cấu trúc Walk-Forward Analysis Window                           |
//+------------------------------------------------------------------+
struct WalkForwardWindow {
    datetime StartDate;
    datetime EndDate;
    datetime OutOfSampleStart;
    datetime OutOfSampleEnd;
    OptimalParameters BestParams;
    double InSampleReturn;
    double OutOfSampleReturn;
    double Efficiency;
    int TradeCount;
    
    WalkForwardWindow() {
        StartDate = 0;
        EndDate = 0;
        OutOfSampleStart = 0;
        OutOfSampleEnd = 0;
        InSampleReturn = 0.0;
        OutOfSampleReturn = 0.0;
        Efficiency = 0.0;
        TradeCount = 0;
    }
};

//+------------------------------------------------------------------+
//| Cấu trúc Parameter Range cho optimization                       |
//+------------------------------------------------------------------+
struct ParameterRange {
    double MinValue;
    double MaxValue;
    double Step;
    
    ParameterRange() {
        MinValue = 0.0;
        MaxValue = 0.0;
        Step = 0.0;
    }
    
    ParameterRange(double min, double max, double step) {
        MinValue = min;
        MaxValue = max;
        Step = step;
    }
};

//+------------------------------------------------------------------+
//| Cấu trúc Overfitting Detection Results                          |
//+------------------------------------------------------------------+
struct OverfittingResults {
    double ParameterSensitivity;
    double PerformanceDecay;
    double ComplexityPenalty;
    double StabilityIndex;
    bool IsOverfitted;
    string OverfittingReason;
    
    OverfittingResults() {
        ParameterSensitivity = 0.0;
        PerformanceDecay = 0.0;
        ComplexityPenalty = 0.0;
        StabilityIndex = 0.0;
        IsOverfitted = false;
        OverfittingReason = "";
    }
};

//+------------------------------------------------------------------+
//| Lớp StrategyOptimizer - Chống Overfitting                      |
//+------------------------------------------------------------------+
class CStrategyOptimizer {
private:
    EAContext* m_Context;
    
    // Walk-Forward Analysis data
    WalkForwardWindow m_Windows[];
    int m_WindowCount;
    int m_InSamplePeriod;     // Số ngày cho in-sample
    int m_OutSamplePeriod;    // Số ngày cho out-of-sample
    double m_InSampleRatio;   // Tỷ lệ in-sample (0.7 = 70%)
    
    // Optimization configuration
    bool m_IsOptimizing;
    datetime m_LastOptimization;
    int m_OptimizationInterval;   // Tần suất tối ưu (ngày)
    int m_MinTradesRequired;      // Số trades tối thiểu để optimize
    
    // Performance tracking
    double m_BestScore;
    OptimalParameters m_CurrentBest;
    OptimalParameters m_PreviousBest;
    double m_PerformanceThreshold;
    
    // Parameter ranges for optimization
    ParameterRange m_RiskPercentRange;
    ParameterRange m_ATRPeriodRange;
    ParameterRange m_ATRMultiplierRange;
    ParameterRange m_RSIPeriodRange;
    ParameterRange m_RSIOverboughtRange;
    ParameterRange m_RSIOversoldRange;
    ParameterRange m_MAPeriodRange;
    ParameterRange m_ProfitTargetRange;
    ParameterRange m_StopLossRange;
    
    // Overfitting detection
    double m_MaxParameterSensitivity;
    double m_MaxPerformanceDecay;
    int m_StabilityTestPeriods;
    
    // Statistics
    double m_TotalOptimizations;
    double m_SuccessfulOptimizations;
    datetime m_FirstOptimization;
    
public:
    // Constructor & Destructor
    CStrategyOptimizer();
    ~CStrategyOptimizer();
    
    // Initialization
    bool Initialize(EAContext* context);
    void SetOptimizationPeriods(int inSample, int outSample);
    void SetInSampleRatio(double ratio);
    void ConfigureParameterRanges();
    
    // Walk-Forward Analysis core
    bool RunWalkForwardAnalysis(datetime startDate, datetime endDate);
    bool OptimizeParameters(datetime startDate, datetime endDate, OptimalParameters& result);
    double EvaluateParameterSet(const OptimalParameters& params, datetime start, datetime end);
    bool CreateOptimizationWindows(datetime startDate, datetime endDate);
    
    // Parameter management
    OptimalParameters GetCurrentOptimalParameters();
    bool UpdateParameters(const OptimalParameters& newParams);
    bool ShouldReoptimize();
    OptimalParameters GenerateRandomParameters();
    void GenerateParameterGrid(OptimalParameters& results[]);
    
    // Overfitting detection & Anti-overfitting
    OverfittingResults DetectOverfitting(const OptimalParameters& params);
    double CalculateStabilityScore(const OptimalParameters& params);
    double CalculateParameterSensitivity(const OptimalParameters& params);
    double CalculatePerformanceDecay(const OptimalParameters& params);
    double CalculateComplexityPenalty(const OptimalParameters& params);
    bool IsParameterSetStable(const OptimalParameters& params);
    
    // Advanced optimization methods
    OptimalParameters GeneticAlgorithmOptimization(datetime start, datetime end);
    OptimalParameters ParticleSwarmOptimization(datetime start, datetime end);
    OptimalParameters BayesianOptimization(datetime start, datetime end);
    
    // Analysis results
    double GetWalkForwardEfficiency();
    double GetAverageOutOfSampleReturn();
    double GetOptimizationSuccessRate();
    string GetOptimizationReport();
    string GetDetailedAnalysisReport();
    bool ExportResults(string filename);
    
    // Real-time monitoring
    void OnTick();
    void OnNewBar();
    bool IsPerformanceDegrading();
    void MonitorParameterStability();
    
    // Statistical analysis
    double CalculateParameterCorrelation(const OptimalParameters& params1, const OptimalParameters& params2);
    double CalculateRobustnessScore(const OptimalParameters& params);
    bool ValidateStatisticalSignificance(const OptimalParameters& params);
    
    // Helper methods
    void Reset();
    bool ValidateParameters(const OptimalParameters& params);
    void LogOptimizationResults(const OptimalParameters& params, double score);
    double NormalizeScore(double rawScore);
    bool IsValidOptimizationPeriod(datetime start, datetime end);
    
    // Getters
    int GetWindowCount() const { return m_WindowCount; }
    double GetBestScore() const { return m_BestScore; }
    bool IsOptimizing() const { return m_IsOptimizing; }
    datetime GetLastOptimization() const { return m_LastOptimization; }
    
private:
    // Helper Methods
    bool CalculatePeriodMetrics(WalkForwardPeriod& period);
    bool LoadHistoricalTrades(datetime startTime, datetime endTime);
    double CalculateSharpeRatio(const WalkForwardPeriod& period);
    bool IsParameterSetValid(const OptimalParameters& params);
    void LogAnalysisProgress(const string& message);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CStrategyOptimizer::CStrategyOptimizer() {
    m_context = NULL;
    m_logger = NULL;
    m_totalPeriods = 0;
    m_currentPeriodIndex = 0;
    m_walkForwardDays = 30;       // 30 ngày mỗi period
    m_outOfSampleDays = 7;        // 7 ngày out-of-sample
    m_stabilityThreshold = 70.0;  // 70% stability score tối thiểu
    m_minTradesPerPeriod = 10;    // Tối thiểu 10 lệnh mỗi period
    m_lastPeriodProfit = 0.0;
    m_lastPeriodDrawdown = 0.0;
    m_lastAnalysisTime = 0;
    m_isAnalysisActive = false;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CStrategyOptimizer::~CStrategyOptimizer() {
    Cleanup();
}

//+------------------------------------------------------------------+
//| Initialize Strategy Optimizer                                    |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::Initialize(EAContext* context) {
    if (context == NULL) {
        Print("[ERROR] StrategyOptimizer: Context is NULL");
        return false;
    }
    
    m_context = context;
    m_logger = context->Logger;
    
    if (m_logger != NULL) {
        m_logger->LogInfo("StrategyOptimizer: Khởi tạo Walk-Forward Analysis module...");
    }
    
    // Load previous analysis if exists
    LoadPreviousAnalysis();
    
    // Initialize arrays
    ArrayResize(m_periods, 0);
    ArrayResize(m_optimalParams, 0);
    
    if (m_logger != NULL) {
        m_logger->LogInfo("StrategyOptimizer: Khởi tạo thành công");
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Start Walk-Forward Analysis                                      |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::StartWalkForwardAnalysis() {
    if (m_context == NULL || m_logger == NULL) {
        return false;
    }
    
    m_logger->LogInfo("StrategyOptimizer: Bắt đầu Walk-Forward Analysis...");
    
    datetime currentTime = TimeCurrent();
    datetime startTime = currentTime - (m_walkForwardDays * 24 * 3600 * 6); // 6 periods back
    
    m_isAnalysisActive = true;
    m_totalPeriods = 0;
    
    // Analyze multiple periods
    for (int i = 0; i < 6; i++) {
        datetime periodStart = startTime + (i * m_walkForwardDays * 24 * 3600);
        datetime periodEnd = periodStart + (m_walkForwardDays * 24 * 3600);
        
        if (periodEnd > currentTime) break;
        
        if (AnalyzePeriod(periodStart, periodEnd)) {
            m_totalPeriods++;
        }
    }
    
    // Validate overall stability
    bool isStable = ValidateStability();
    
    m_logger->LogInfo(StringFormat("StrategyOptimizer: Hoàn thành phân tích %d periods. Ổn định: %s", 
                                   m_totalPeriods, isStable ? "CÓ" : "KHÔNG"));
    
    m_lastAnalysisTime = currentTime;
    
    return isStable;
}

//+------------------------------------------------------------------+
//| Analyze Single Period                                            |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::AnalyzePeriod(datetime startTime, datetime endTime) {
    if (m_logger != NULL) {
        m_logger->LogDebug(StringFormat("StrategyOptimizer: Phân tích period %s - %s", 
                                        TimeToString(startTime), TimeToString(endTime)));
    }
    
    // Create new period
    int newSize = ArraySize(m_periods) + 1;
    ArrayResize(m_periods, newSize);
    
    WalkForwardPeriod& period = m_periods[newSize - 1];
    period.startTime = startTime;
    period.endTime = endTime;
    
    // Load and analyze historical trades
    if (!LoadHistoricalTrades(startTime, endTime)) {
        if (m_logger != NULL) {
            m_logger->LogWarning("StrategyOptimizer: Không thể load dữ liệu lịch sử cho period");
        }
        return false;
    }
    
    // Calculate metrics
    if (!CalculatePeriodMetrics(period)) {
        if (m_logger != NULL) {
            m_logger->LogWarning("StrategyOptimizer: Không thể tính toán metrics cho period");
        }
        return false;
    }
    
    // Calculate stability score
    period.isStable = (CalculateStabilityScore(period) >= m_stabilityThreshold);
    
    if (m_logger != NULL) {
        m_logger->LogDebug(StringFormat("StrategyOptimizer: Period stability: %s (Score: %.2f)", 
                                        period.isStable ? "STABLE" : "UNSTABLE", 
                                        CalculateStabilityScore(period)));
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Calculate Stability Score                                        |
//+------------------------------------------------------------------+
double CStrategyOptimizer::CalculateStabilityScore(const WalkForwardPeriod& period) {
    double score = 0.0;
    
    // Factor 1: Win Rate (30%)
    if (period.winRate >= 0.6) score += 30.0;
    else if (period.winRate >= 0.5) score += 20.0;
    else if (period.winRate >= 0.4) score += 10.0;
    
    // Factor 2: Profit Factor (25%)
    if (period.profitFactor >= 1.5) score += 25.0;
    else if (period.profitFactor >= 1.2) score += 15.0;
    else if (period.profitFactor >= 1.0) score += 5.0;
    
    // Factor 3: Max Drawdown (20%)
    if (period.maxDrawdown <= 0.05) score += 20.0;      // <= 5%
    else if (period.maxDrawdown <= 0.10) score += 15.0; // <= 10%
    else if (period.maxDrawdown <= 0.15) score += 10.0; // <= 15%
    
    // Factor 4: Trade Count (15%)
    if (period.totalTrades >= m_minTradesPerPeriod * 2) score += 15.0;
    else if (period.totalTrades >= m_minTradesPerPeriod) score += 10.0;
    
    // Factor 5: Sharpe Ratio (10%)
    if (period.sharpeRatio >= 1.0) score += 10.0;
    else if (period.sharpeRatio >= 0.5) score += 5.0;
    
    return MathMin(score, 100.0);
}

//+------------------------------------------------------------------+
//| Detect Overfitting                                              |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::DetectOverfitting() {
    if (m_totalPeriods < 3) {
        return false; // Cần ít nhất 3 periods để phát hiện overfitting
    }
    
    // Check parameter consistency
    if (!CheckParameterConsistency()) {
        if (m_logger != NULL) {
            m_logger->LogWarning("StrategyOptimizer: Phát hiện OVERFITTING - Tham số không nhất quán");
        }
        return true;
    }
    
    // Check performance degradation
    if (IsPerformanceDegrading()) {
        if (m_logger != NULL) {
            m_logger->LogWarning("StrategyOptimizer: Phát hiện OVERFITTING - Hiệu suất suy giảm");
        }
        return true;
    }
    
    // Check parameter variance
    double variance = CalculateParameterVariance();
    if (variance > 0.3) { // 30% variance threshold
        if (m_logger != NULL) {
            m_logger->LogWarning(StringFormat("StrategyOptimizer: Phát hiện OVERFITTING - Variance cao: %.2f", variance));
        }
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Validate Overall Stability                                       |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::ValidateStability() {
    if (m_totalPeriods == 0) {
        return false;
    }
    
    int stablePeriods = 0;
    double avgStabilityScore = 0.0;
    
    for (int i = 0; i < m_totalPeriods; i++) {
        if (m_periods[i].isStable) {
            stablePeriods++;
        }
        avgStabilityScore += CalculateStabilityScore(m_periods[i]);
    }
    
    avgStabilityScore /= m_totalPeriods;
    double stabilityRatio = (double)stablePeriods / m_totalPeriods;
    
    bool isOverallStable = (stabilityRatio >= 0.7 && avgStabilityScore >= m_stabilityThreshold);
    
    if (m_logger != NULL) {
        m_logger->LogInfo(StringFormat("StrategyOptimizer: Tỷ lệ ổn định: %.1f%%, Điểm TB: %.1f, Kết quả: %s",
                                       stabilityRatio * 100, avgStabilityScore, 
                                       isOverallStable ? "ỔN ĐỊNH" : "KHÔNG ỔN ĐỊNH"));
    }
    
    return isOverallStable;
}

//+------------------------------------------------------------------+
//| Calculate Parameter Variance                                     |
//+------------------------------------------------------------------+
double CStrategyOptimizer::CalculateParameterVariance() {
    if (ArraySize(m_optimalParams) < 2) {
        return 0.0;
    }
    
    // Calculate variance for key parameters
    double riskVariance = 0.0;
    double tpVariance = 0.0;
    double slVariance = 0.0;
    
    int count = ArraySize(m_optimalParams);
    
    // Calculate means
    double riskMean = 0.0, tpMean = 0.0, slMean = 0.0;
    for (int i = 0; i < count; i++) {
        riskMean += m_optimalParams[i].riskPercent;
        tpMean += m_optimalParams[i].takeProfitATR;
        slMean += m_optimalParams[i].stopLossATR;
    }
    riskMean /= count;
    tpMean /= count;
    slMean /= count;
    
    // Calculate variances
    for (int i = 0; i < count; i++) {
        riskVariance += MathPow(m_optimalParams[i].riskPercent - riskMean, 2);
        tpVariance += MathPow(m_optimalParams[i].takeProfitATR - tpMean, 2);
        slVariance += MathPow(m_optimalParams[i].stopLossATR - slMean, 2);
    }
    
    riskVariance /= count;
    tpVariance /= count;
    slVariance /= count;
    
    // Return normalized average variance
    return (riskVariance / (riskMean + 0.01) + tpVariance / (tpMean + 0.01) + slVariance / (slMean + 0.01)) / 3.0;
}

//+------------------------------------------------------------------+
//| Check Parameter Consistency                                      |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::CheckParameterConsistency() {
    if (ArraySize(m_optimalParams) < 3) {
        return true; // Không đủ dữ liệu để kiểm tra
    }
    
    double variance = CalculateParameterVariance();
    return (variance <= 0.25); // 25% variance threshold for consistency
}

//+------------------------------------------------------------------+
//| Check if Performance is Degrading                               |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::IsPerformanceDegrading() {
    if (m_totalPeriods < 3) {
        return false;
    }
    
    // Check last 3 periods for degradation trend
    int startIndex = MathMax(0, m_totalPeriods - 3);
    double firstProfit = m_periods[startIndex].totalProfit;
    double lastProfit = m_periods[m_totalPeriods - 1].totalProfit;
    
    // If profit decreased by more than 30%
    if (firstProfit > 0 && (lastProfit / firstProfit) < 0.7) {
        return true;
    }
    
    // Check drawdown increase
    double firstDD = m_periods[startIndex].maxDrawdown;
    double lastDD = m_periods[m_totalPeriods - 1].maxDrawdown;
    
    // If drawdown increased by more than 50%
    if (lastDD > firstDD * 1.5) {
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Get Current Stability Score                                     |
//+------------------------------------------------------------------+
double CStrategyOptimizer::GetCurrentStabilityScore() {
    if (m_totalPeriods == 0) {
        return 0.0;
    }
    
    double totalScore = 0.0;
    for (int i = 0; i < m_totalPeriods; i++) {
        totalScore += CalculateStabilityScore(m_periods[i]);
    }
    
    return totalScore / m_totalPeriods;
}

//+------------------------------------------------------------------+
//| Cleanup                                                          |
//+------------------------------------------------------------------+
void CStrategyOptimizer::Cleanup() {
    ArrayFree(m_periods);
    ArrayFree(m_optimalParams);
    m_totalPeriods = 0;
    m_isAnalysisActive = false;
}

//+------------------------------------------------------------------+
//| Placeholder implementations for remaining methods                |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::CalculatePeriodMetrics(WalkForwardPeriod& period) {
    // Implementation would analyze historical trades for the period
    // This is a simplified placeholder
    period.totalTrades = 15;
    period.winningTrades = 9;
    period.totalProfit = 150.0;
    period.maxDrawdown = 0.08;
    period.profitFactor = 1.3;
    period.winRate = (double)period.winningTrades / period.totalTrades;
    period.sharpeRatio = 0.8;
    return true;
}

bool CStrategyOptimizer::LoadHistoricalTrades(datetime startTime, datetime endTime) {
    // Implementation would load actual trade history
    return true;
}

bool CStrategyOptimizer::LoadPreviousAnalysis() {
    // Implementation would load from file
    return true;
}

//+------------------------------------------------------------------+
//| Set Optimization Periods                                        |
//+------------------------------------------------------------------+
void CStrategyOptimizer::SetOptimizationPeriods(int inSample, int outSample) {
    m_InSamplePeriod = inSample;
    m_OutSamplePeriod = outSample;
}

//+------------------------------------------------------------------+
//| Set In-Sample Ratio                                             |
//+------------------------------------------------------------------+
void CStrategyOptimizer::SetInSampleRatio(double ratio) {
    m_InSampleRatio = MathMax(0.5, MathMin(0.9, ratio));
}

//+------------------------------------------------------------------+
//| Configure Parameter Ranges                                      |
//+------------------------------------------------------------------+
void CStrategyOptimizer::ConfigureParameterRanges() {
    // Risk Percent Range
    m_RiskPercentRange.min = 0.5;
    m_RiskPercentRange.max = 3.0;
    m_RiskPercentRange.step = 0.1;
    
    // ATR Period Range
    m_ATRPeriodRange.min = 10;
    m_ATRPeriodRange.max = 30;
    m_ATRPeriodRange.step = 2;
    
    // ATR Multiplier Range
    m_ATRMultiplierRange.min = 1.0;
    m_ATRMultiplierRange.max = 3.0;
    m_ATRMultiplierRange.step = 0.2;
    
    // RSI Period Range
    m_RSIPeriodRange.min = 10;
    m_RSIPeriodRange.max = 25;
    m_RSIPeriodRange.step = 2;
    
    // RSI Overbought Range
    m_RSIOverboughtRange.min = 70;
    m_RSIOverboughtRange.max = 85;
    m_RSIOverboughtRange.step = 2;
    
    // RSI Oversold Range
    m_RSIOversoldRange.min = 15;
    m_RSIOversoldRange.max = 30;
    m_RSIOversoldRange.step = 2;
    
    // MA Period Range
    m_MAPeriodRange.min = 20;
    m_MAPeriodRange.max = 100;
    m_MAPeriodRange.step = 5;
    
    // Profit Target Range
    m_ProfitTargetRange.min = 1.5;
    m_ProfitTargetRange.max = 4.0;
    m_ProfitTargetRange.step = 0.2;
    
    // Stop Loss Range
    m_StopLossRange.min = 1.0;
    m_StopLossRange.max = 3.0;
    m_StopLossRange.step = 0.2;
}

//+------------------------------------------------------------------+
//| Run Walk Forward Analysis                                       |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::RunWalkForwardAnalysis(datetime startDate, datetime endDate) {
    if (!CreateOptimizationWindows(startDate, endDate)) {
        return false;
    }
    
    return StartWalkForwardAnalysis();
}

//+------------------------------------------------------------------+
//| Optimize Parameters                                             |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::OptimizeParameters(datetime startDate, datetime endDate, OptimalParameters& result) {
    // Simple grid search optimization
    double bestScore = -999999.0;
    OptimalParameters bestParams;
    
    // Generate parameter combinations
    for (double risk = m_RiskPercentRange.min; risk <= m_RiskPercentRange.max; risk += m_RiskPercentRange.step) {
        for (int atrPeriod = (int)m_ATRPeriodRange.min; atrPeriod <= (int)m_ATRPeriodRange.max; atrPeriod += (int)m_ATRPeriodRange.step) {
            OptimalParameters params;
            params.RiskPercent = risk;
            params.ATRPeriod = atrPeriod;
            params.ATRMultiplier = 2.0; // Default value
            params.RSIPeriod = 14; // Default value
            params.RSIOverbought = 75; // Default value
            params.RSIOversold = 25; // Default value
            params.MAPeriod = 50; // Default value
            params.ProfitTarget = 2.5; // Default value
            params.StopLoss = 1.5; // Default value
            params.MaxTrades = 5; // Default value
            
            double score = EvaluateParameterSet(params, startDate, endDate);
            if (score > bestScore) {
                bestScore = score;
                bestParams = params;
            }
        }
    }
    
    result = bestParams;
    return true;
}

//+------------------------------------------------------------------+
//| Evaluate Parameter Set                                          |
//+------------------------------------------------------------------+
double CStrategyOptimizer::EvaluateParameterSet(const OptimalParameters& params, datetime start, datetime end) {
    // Simplified evaluation - would normally run backtest
    double profitFactor = 1.2 + (params.RiskPercent * 0.1);
    double maxDrawdown = 0.05 + (params.RiskPercent * 0.01);
    double winRate = 0.6 - (params.RiskPercent * 0.02);
    
    // Calculate composite score
    double score = (profitFactor * 0.4) + ((1.0 - maxDrawdown) * 0.3) + (winRate * 0.3);
    return score;
}

//+------------------------------------------------------------------+
//| Create Optimization Windows                                     |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::CreateOptimizationWindows(datetime startDate, datetime endDate) {
    int totalDays = (int)((endDate - startDate) / 86400);
    int windowSize = m_InSamplePeriod + m_OutSamplePeriod;
    
    m_WindowCount = totalDays / windowSize;
    if (m_WindowCount <= 0) {
        return false;
    }
    
    ArrayResize(m_windows, m_WindowCount);
    
    datetime currentStart = startDate;
    for (int i = 0; i < m_WindowCount; i++) {
        m_windows[i].startTime = currentStart;
        m_windows[i].inSampleEnd = currentStart + (m_InSamplePeriod * 86400);
        m_windows[i].outSampleEnd = m_windows[i].inSampleEnd + (m_OutSamplePeriod * 86400);
        
        currentStart = m_windows[i].outSampleEnd;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Get Current Optimal Parameters                                  |
//+------------------------------------------------------------------+
OptimalParameters CStrategyOptimizer::GetCurrentOptimalParameters() {
    return m_CurrentBest;
}

//+------------------------------------------------------------------+
//| Update Parameters                                               |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::UpdateParameters(const OptimalParameters& newParams) {
    if (!ValidateParameters(newParams)) {
        return false;
    }
    
    m_PreviousBest = m_CurrentBest;
    m_CurrentBest = newParams;
    return true;
}

//+------------------------------------------------------------------+
//| Should Reoptimize                                               |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::ShouldReoptimize() {
    if (m_OptimizationInterval <= 0) {
        return false;
    }
    
    datetime currentTime = TimeCurrent();
    int daysSinceLastOptimization = (int)((currentTime - m_LastOptimization) / 86400);
    
    return (daysSinceLastOptimization >= m_OptimizationInterval);
}

//+------------------------------------------------------------------+
//| Generate Random Parameters                                      |
//+------------------------------------------------------------------+
OptimalParameters CStrategyOptimizer::GenerateRandomParameters() {
    OptimalParameters params;
    
    params.RiskPercent = m_RiskPercentRange.min + (MathRand() / 32767.0) * (m_RiskPercentRange.max - m_RiskPercentRange.min);
    params.ATRPeriod = (int)(m_ATRPeriodRange.min + (MathRand() / 32767.0) * (m_ATRPeriodRange.max - m_ATRPeriodRange.min));
    params.ATRMultiplier = m_ATRMultiplierRange.min + (MathRand() / 32767.0) * (m_ATRMultiplierRange.max - m_ATRMultiplierRange.min);
    params.RSIPeriod = (int)(m_RSIPeriodRange.min + (MathRand() / 32767.0) * (m_RSIPeriodRange.max - m_RSIPeriodRange.min));
    params.RSIOverbought = m_RSIOverboughtRange.min + (MathRand() / 32767.0) * (m_RSIOverboughtRange.max - m_RSIOverboughtRange.min);
    params.RSIOversold = m_RSIOversoldRange.min + (MathRand() / 32767.0) * (m_RSIOversoldRange.max - m_RSIOversoldRange.min);
    params.MAPeriod = (int)(m_MAPeriodRange.min + (MathRand() / 32767.0) * (m_MAPeriodRange.max - m_MAPeriodRange.min));
    params.ProfitTarget = m_ProfitTargetRange.min + (MathRand() / 32767.0) * (m_ProfitTargetRange.max - m_ProfitTargetRange.min);
    params.StopLoss = m_StopLossRange.min + (MathRand() / 32767.0) * (m_StopLossRange.max - m_StopLossRange.min);
    params.MaxTrades = 3 + (MathRand() % 8); // Random between 3-10
    
    return params;
}

//+------------------------------------------------------------------+
//| Validate Parameters                                             |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::ValidateParameters(const OptimalParameters& params) {
    if (params.RiskPercent < 0.1 || params.RiskPercent > 10.0) return false;
    if (params.ATRPeriod < 5 || params.ATRPeriod > 50) return false;
    if (params.ATRMultiplier < 0.5 || params.ATRMultiplier > 5.0) return false;
    if (params.RSIPeriod < 5 || params.RSIPeriod > 50) return false;
    if (params.RSIOverbought < 60 || params.RSIOverbought > 95) return false;
    if (params.RSIOversold < 5 || params.RSIOversold > 40) return false;
    if (params.MAPeriod < 10 || params.MAPeriod > 200) return false;
    if (params.ProfitTarget < 1.0 || params.ProfitTarget > 10.0) return false;
    if (params.StopLoss < 0.5 || params.StopLoss > 5.0) return false;
    if (params.MaxTrades < 1 || params.MaxTrades > 20) return false;
    
    return true;
}

//+------------------------------------------------------------------+
//| Reset                                                           |
//+------------------------------------------------------------------+
void CStrategyOptimizer::Reset() {
    Cleanup();
    m_BestScore = -999999.0;
    m_TotalOptimizations = 0;
    m_SuccessfulOptimizations = 0;
    m_LastOptimization = 0;
    m_FirstOptimization = 0;
}

//+------------------------------------------------------------------+
//| OnTick                                                          |
//+------------------------------------------------------------------+
void CStrategyOptimizer::OnTick() {
    // Monitor real-time performance
    if (ShouldReoptimize()) {
        // Trigger reoptimization if needed
        m_IsOptimizing = true;
    }
}

//+------------------------------------------------------------------+
//| OnNewBar                                                        |
//+------------------------------------------------------------------+
void CStrategyOptimizer::OnNewBar() {
    // Update performance metrics on new bar
    MonitorParameterStability();
}

//+------------------------------------------------------------------+
//| Monitor Parameter Stability                                     |
//+------------------------------------------------------------------+
void CStrategyOptimizer::MonitorParameterStability() {
    // Check if current parameters are still performing well
    double currentStability = GetCurrentStabilityScore();
    if (currentStability < m_PerformanceThreshold) {
        if (m_context && m_context->Logger) {
            m_context->Logger->LogWarning("Parameter stability below threshold: " + DoubleToString(currentStability, 3));
        }
    }
}

//+------------------------------------------------------------------+
//| Get Walk Forward Efficiency                                     |
//+------------------------------------------------------------------+
double CStrategyOptimizer::GetWalkForwardEfficiency() {
    if (m_TotalOptimizations == 0) {
        return 0.0;
    }
    return m_SuccessfulOptimizations / m_TotalOptimizations;
}

//+------------------------------------------------------------------+
//| Get Average Out Of Sample Return                                |
//+------------------------------------------------------------------+
double CStrategyOptimizer::GetAverageOutOfSampleReturn() {
    if (m_totalPeriods == 0) {
        return 0.0;
    }
    
    double totalReturn = 0.0;
    for (int i = 0; i < m_totalPeriods; i++) {
        totalReturn += m_periods[i].totalProfit;
    }
    
    return totalReturn / m_totalPeriods;
}

//+------------------------------------------------------------------+
//| Get Optimization Success Rate                                   |
//+------------------------------------------------------------------+
double CStrategyOptimizer::GetOptimizationSuccessRate() {
    return GetWalkForwardEfficiency();
}

//+------------------------------------------------------------------+
//| Get Optimization Report                                         |
//+------------------------------------------------------------------+
string CStrategyOptimizer::GetOptimizationReport() {
    string report = "=== Strategy Optimization Report ===\n";
    report += "Total Optimizations: " + IntegerToString((int)m_TotalOptimizations) + "\n";
    report += "Successful Optimizations: " + IntegerToString((int)m_SuccessfulOptimizations) + "\n";
    report += "Success Rate: " + DoubleToString(GetOptimizationSuccessRate() * 100, 2) + "%\n";
    report += "Average Out-of-Sample Return: " + DoubleToString(GetAverageOutOfSampleReturn(), 2) + "\n";
    report += "Current Stability Score: " + DoubleToString(GetCurrentStabilityScore(), 3) + "\n";
    
    return report;
}

//+------------------------------------------------------------------+
//| Get Detailed Analysis Report                                    |
//+------------------------------------------------------------------+
string CStrategyOptimizer::GetDetailedAnalysisReport() {
    string report = GetOptimizationReport();
    report += "\n=== Current Optimal Parameters ===\n";
    report += "Risk Percent: " + DoubleToString(m_CurrentBest.RiskPercent, 2) + "\n";
    report += "ATR Period: " + IntegerToString(m_CurrentBest.ATRPeriod) + "\n";
    report += "ATR Multiplier: " + DoubleToString(m_CurrentBest.ATRMultiplier, 2) + "\n";
    report += "RSI Period: " + IntegerToString(m_CurrentBest.RSIPeriod) + "\n";
    report += "RSI Overbought: " + DoubleToString(m_CurrentBest.RSIOverbought, 1) + "\n";
    report += "RSI Oversold: " + DoubleToString(m_CurrentBest.RSIOversold, 1) + "\n";
    report += "MA Period: " + IntegerToString(m_CurrentBest.MAPeriod) + "\n";
    report += "Profit Target: " + DoubleToString(m_CurrentBest.ProfitTarget, 2) + "\n";
    report += "Stop Loss: " + DoubleToString(m_CurrentBest.StopLoss, 2) + "\n";
    report += "Max Trades: " + IntegerToString(m_CurrentBest.MaxTrades) + "\n";
    
    return report;
}

//+------------------------------------------------------------------+
//| Export Results                                                  |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::ExportResults(string filename) {
    int fileHandle = FileOpen(filename, FILE_WRITE | FILE_TXT);
    if (fileHandle == INVALID_HANDLE) {
        return false;
    }
    
    FileWrite(fileHandle, GetDetailedAnalysisReport());
    FileClose(fileHandle);
    
    return true;
}

//+------------------------------------------------------------------+
//| Log Optimization Results                                        |
//+------------------------------------------------------------------+
void CStrategyOptimizer::LogOptimizationResults(const OptimalParameters& params, double score) {
    if (m_context && m_context->Logger) {
        string message = "Optimization Result - Score: " + DoubleToString(score, 4) + 
                        ", Risk: " + DoubleToString(params.RiskPercent, 2) + 
                        ", ATR Period: " + IntegerToString(params.ATRPeriod);
        m_context->Logger->LogInfo(message);
    }
}

//+------------------------------------------------------------------+
//| Normalize Score                                                 |
//+------------------------------------------------------------------+
double CStrategyOptimizer::NormalizeScore(double rawScore) {
    // Simple normalization to 0-1 range
    return MathMax(0.0, MathMin(1.0, rawScore));
}

//+------------------------------------------------------------------+
//| Is Valid Optimization Period                                    |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::IsValidOptimizationPeriod(datetime start, datetime end) {
    int periodDays = (int)((end - start) / 86400);
    return (periodDays >= (m_InSamplePeriod + m_OutSamplePeriod));
}

} // namespace ApexPullback

#endif // STRATEGY_OPTIMIZER_MQH