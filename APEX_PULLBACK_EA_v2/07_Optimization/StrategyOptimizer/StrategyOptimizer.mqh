//+------------------------------------------------------------------+
//|                                            StrategyOptimizer.mqh |
//|                                    APEX PULLBACK EA v5.0 FINAL   |
//|                        Walk-Forward Analysis & Anti-Overfitting  |
//+------------------------------------------------------------------+

#property copyright "APEX PULLBACK EA v5.0 FINAL"
#property version   "1.00"
#property strict

#ifndef APEX_STRATEGY_OPTIMIZER_MQH_
#define APEX_STRATEGY_OPTIMIZER_MQH_

#include "../../00_Core/CommonStructs.mqh"



//+------------------------------------------------------------------+
//| Walk-Forward Analysis Period Structure                           |
//+------------------------------------------------------------------+
struct WalkForwardPeriod {
    datetime StartTime;              // Period start time
    datetime EndTime;                // Period end time
    int TotalTrades;                 // Total trades in period
    int WinningTrades;               // Winning trades count
    double TotalProfit;              // Total profit/loss
    double MaxDrawdown;              // Maximum drawdown
    double ProfitFactor;             // Profit factor
    double WinRate;                  // Win rate percentage
    double SharpeRatio;              // Sharpe ratio
    double SortinoRatio;             // Sortino ratio
    double CalmarRatio;              // Calmar ratio
    double AverageWin;               // Average winning trade
    double AverageLoss;              // Average losing trade
    double LargestWin;               // Largest winning trade
    double LargestLoss;              // Largest losing trade
    double ConsecutiveWins;          // Max consecutive wins
    double ConsecutiveLosses;        // Max consecutive losses
    bool IsStable;                   // Period stability flag
    double StabilityScore;           // Calculated stability score
    
    WalkForwardPeriod() {
        StartTime = 0;
        EndTime = 0;
        TotalTrades = 0;
        WinningTrades = 0;
        TotalProfit = 0.0;
        MaxDrawdown = 0.0;
        ProfitFactor = 0.0;
        WinRate = 0.0;
        SharpeRatio = 0.0;
        SortinoRatio = 0.0;
        CalmarRatio = 0.0;
        AverageWin = 0.0;
        AverageLoss = 0.0;
        LargestWin = 0.0;
        LargestLoss = 0.0;
        ConsecutiveWins = 0;
        ConsecutiveLosses = 0;
        IsStable = false;
        StabilityScore = 0.0;
    }
};

//+------------------------------------------------------------------+
//| Optimal Parameters Structure                                     |
//+------------------------------------------------------------------+
struct OptimalParameters {
    // Core Trading Parameters
    double RiskPercent;              // Risk percentage per trade
    double ATRMultiplierSL;          // ATR multiplier for stop loss
    double ATRMultiplierTP;          // ATR multiplier for take profit
    int ATRPeriod;                   // ATR calculation period
    
    // EMA Parameters
    int EMAFastPeriod;               // Fast EMA period
    int EMASlowPeriod;               // Slow EMA period
    
    // RSI Parameters
    int RSIPeriod;                   // RSI calculation period
    double RSIOverbought;            // RSI overbought level
    double RSIOversold;              // RSI oversold level
    
    // Pullback Parameters
    double PullbackThreshold;        // Pullback detection threshold
    int PullbackLookback;            // Pullback lookback period
    double TrendStrengthMin;         // Minimum trend strength
    
    // Risk Management
    int MaxPositions;                // Maximum concurrent positions
    double MaxDailyLoss;             // Maximum daily loss percentage
    double MaxDrawdown;              // Maximum drawdown percentage
    
    // Market Condition Parameters
    double VolatilityThreshold;      // Volatility threshold
    double SpreadThreshold;          // Maximum spread threshold
    bool EnableNewsFilter;           // Enable news filtering
    
    // Performance Metrics
    double InSampleScore;            // In-sample performance score
    double OutOfSampleScore;         // Out-of-sample performance score
    double WalkForwardScore;         // Walk-forward analysis score
    double OverfittingPenalty;       // Overfitting penalty score
    double StabilityScore;           // Parameter stability score
    double RobustnessScore;          // Robustness score
    double FinalScore;               // Final combined score
    
    // Statistical Measures
    double SharpeRatio;              // Sharpe ratio
    double SortinoRatio;             // Sortino ratio
    double CalmarRatio;              // Calmar ratio
    double MaxDrawdownPercent;       // Maximum drawdown percentage
    double ProfitFactor;             // Profit factor
    double WinRate;                  // Win rate percentage
    double Expectancy;               // Mathematical expectancy
    
    // Validation Flags
    bool IsValid;                    // Parameter set validity
    bool IsStable;                   // Parameter stability
    bool IsRobust;                   // Robustness flag
    datetime LastOptimized;          // Last optimization time
    
    OptimalParameters() {
        RiskPercent = 1.0;
        ATRMultiplierSL = 2.0;
        ATRMultiplierTP = 3.0;
        ATRPeriod = 14;
        
        EMAFastPeriod = 12;
        EMASlowPeriod = 26;
        
        RSIPeriod = 14;
        RSIOverbought = 70.0;
        RSIOversold = 30.0;
        
        PullbackThreshold = 0.618;
        PullbackLookback = 20;
        TrendStrengthMin = 0.6;
        
        MaxPositions = 3;
        MaxDailyLoss = 5.0;
        MaxDrawdown = 15.0;
        
        VolatilityThreshold = 0.02;
        SpreadThreshold = 3.0;
        EnableNewsFilter = true;
        
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
        MaxDrawdownPercent = 0.0;
        ProfitFactor = 0.0;
        WinRate = 0.0;
        Expectancy = 0.0;
        
        IsValid = false;
        IsStable = false;
        IsRobust = false;
        LastOptimized = 0;
    }
};

//+------------------------------------------------------------------+
//| Walk-Forward Window Structure                                    |
//+------------------------------------------------------------------+
struct WalkForwardWindow {
    datetime InSampleStart;          // In-sample period start
    datetime InSampleEnd;            // In-sample period end
    datetime OutOfSampleStart;       // Out-of-sample period start
    datetime OutOfSampleEnd;         // Out-of-sample period end
    OptimalParameters BestParams;    // Best parameters for this window
    double InSampleReturn;           // In-sample return
    double OutOfSampleReturn;        // Out-of-sample return
    double Efficiency;               // Walk-forward efficiency
    int InSampleTrades;              // Number of in-sample trades
    int OutOfSampleTrades;           // Number of out-of-sample trades
    bool IsValid;                    // Window validity
    
    WalkForwardWindow() {
        InSampleStart = 0;
        InSampleEnd = 0;
        OutOfSampleStart = 0;
        OutOfSampleEnd = 0;
        InSampleReturn = 0.0;
        OutOfSampleReturn = 0.0;
        Efficiency = 0.0;
        InSampleTrades = 0;
        OutOfSampleTrades = 0;
        IsValid = false;
    }
};

//+------------------------------------------------------------------+
//| Parameter Range Structure                                        |
//+------------------------------------------------------------------+
struct ParameterRange {
    double MinValue;                 // Minimum parameter value
    double MaxValue;                 // Maximum parameter value
    double Step;                     // Optimization step
    double CurrentValue;             // Current parameter value
    bool IsOptimizable;              // Can this parameter be optimized
    
    ParameterRange() {
        MinValue = 0.0;
        MaxValue = 0.0;
        Step = 0.0;
        CurrentValue = 0.0;
        IsOptimizable = true;
    }
    
    ParameterRange(double min, double max, double step, double current = 0.0) {
        MinValue = min;
        MaxValue = max;
        Step = step;
        CurrentValue = (current == 0.0) ? min : current;
        IsOptimizable = true;
    }
};

//+------------------------------------------------------------------+
//| Overfitting Detection Results                                    |
//+------------------------------------------------------------------+
struct OverfittingResults {
    double ParameterSensitivity;     // Parameter sensitivity score
    double PerformanceDecay;         // Performance decay score
    double ComplexityPenalty;        // Model complexity penalty
    double StabilityIndex;           // Overall stability index
    double VarianceScore;            // Parameter variance score
    double ConsistencyScore;         // Performance consistency score
    bool IsOverfitted;               // Overfitting detected flag
    string OverfittingReason;        // Reason for overfitting detection
    ENUM_OVERFITTING_LEVEL Level;   // Overfitting severity level
    
    OverfittingResults() {
        ParameterSensitivity = 0.0;
        PerformanceDecay = 0.0;
        ComplexityPenalty = 0.0;
        StabilityIndex = 0.0;
        VarianceScore = 0.0;
        ConsistencyScore = 0.0;
        IsOverfitted = false;
        OverfittingReason = "";
        Level = OVERFITTING_NONE;
    }
};

//+------------------------------------------------------------------+
//| Strategy Optimizer Configuration                                 |
//+------------------------------------------------------------------+
struct StrategyOptimizerConfig {
    // Walk-Forward Settings
    int InSampleDays;                // In-sample period in days
    int OutOfSampleDays;             // Out-of-sample period in days
    double InSampleRatio;            // In-sample to total ratio (0.7 = 70%)
    int MinTradesRequired;           // Minimum trades for valid optimization
    int OptimizationInterval;        // Reoptimization interval in days
    
    // Stability Thresholds
    double StabilityThreshold;       // Minimum stability score (0-100)
    double OverfittingThreshold;     // Overfitting detection threshold
    double PerformanceDecayThreshold; // Performance decay threshold
    double ParameterSensitivityThreshold; // Parameter sensitivity threshold
    
    // Optimization Settings
    bool EnableWalkForward;          // Enable walk-forward analysis
    bool EnableOverfittingDetection; // Enable overfitting detection
    bool EnableParameterStability;   // Enable parameter stability monitoring
    bool EnableRobustnessTest;       // Enable robustness testing
    
    // Advanced Settings
    int MaxOptimizationRuns;         // Maximum optimization iterations
    double ConvergenceThreshold;     // Convergence threshold for optimization
    bool UseGeneticAlgorithm;        // Use genetic algorithm optimization
    bool UseParticleSwarm;           // Use particle swarm optimization
    bool UseBayesianOptimization;    // Use Bayesian optimization
    
    // Performance Criteria
    double MinSharpeRatio;           // Minimum acceptable Sharpe ratio
    double MinProfitFactor;          // Minimum acceptable profit factor
    double MaxDrawdown;              // Maximum acceptable drawdown
    double MinWinRate;               // Minimum acceptable win rate
    
    StrategyOptimizerConfig() {
        InSampleDays = 90;
        OutOfSampleDays = 30;
        InSampleRatio = 0.75;
        MinTradesRequired = 20;
        OptimizationInterval = 30;
        
        StabilityThreshold = 70.0;
        OverfittingThreshold = 0.3;
        PerformanceDecayThreshold = 0.2;
        ParameterSensitivityThreshold = 0.25;
        
        EnableWalkForward = true;
        EnableOverfittingDetection = true;
        EnableParameterStability = true;
        EnableRobustnessTest = true;
        
        MaxOptimizationRuns = 1000;
        ConvergenceThreshold = 0.001;
        UseGeneticAlgorithm = false;
        UseParticleSwarm = false;
        UseBayesianOptimization = true;
        
        MinSharpeRatio = 1.0;
        MinProfitFactor = 1.2;
        MaxDrawdown = 20.0;
        MinWinRate = 40.0;
    }
};

//+------------------------------------------------------------------+
//| Strategy Optimizer Class                                         |
//+------------------------------------------------------------------+
class CStrategyOptimizer {
private:
    // Core Components
    EAContext* m_pContext;
    bool m_bInitialized;
    
    // Configuration
    StrategyOptimizerConfig m_Config;
    
    // Walk-Forward Data
    WalkForwardWindow m_Windows[];
    WalkForwardPeriod m_Periods[];
    int m_iWindowCount;
    int m_iPeriodCount;
    
    // Current State
    OptimalParameters m_CurrentBest;
    OptimalParameters m_PreviousBest;
    datetime m_LastOptimization;
    bool m_bIsOptimizing;
    bool m_bOptimizationNeeded;
    
    // Performance Tracking
    double m_dBestScore;
    double m_dCurrentScore;
    double m_dPerformanceThreshold;
    int m_iTotalOptimizations;
    int m_iSuccessfulOptimizations;
    
    // Parameter Ranges
    ParameterRange m_RiskPercentRange;
    ParameterRange m_ATRMultiplierSLRange;
    ParameterRange m_ATRMultiplierTPRange;
    ParameterRange m_ATRPeriodRange;
    ParameterRange m_EMAFastRange;
    ParameterRange m_EMASlowRange;
    ParameterRange m_RSIPeriodRange;
    ParameterRange m_RSIOverboughtRange;
    ParameterRange m_RSIOversoldRange;
    ParameterRange m_PullbackThresholdRange;
    ParameterRange m_PullbackLookbackRange;
    ParameterRange m_TrendStrengthRange;
    
    // Overfitting Detection
    double m_dMaxParameterSensitivity;
    double m_dMaxPerformanceDecay;
    int m_iStabilityTestPeriods;
    OverfittingResults m_LastOverfittingResults;
    
    // Statistics
    datetime m_FirstOptimization;
    double m_dAverageOptimizationTime;
    double m_dTotalOptimizationTime;
    
    // Internal Methods
    bool CreateOptimizationWindows(datetime startDate, datetime endDate);
    bool OptimizeParametersForWindow(WalkForwardWindow& window);
    double EvaluateParameterSet(const OptimalParameters& params, datetime start, datetime end);
    bool CalculatePeriodMetrics(WalkForwardPeriod& period);
    double CalculateStabilityScore(const WalkForwardPeriod& period);
    double CalculateStabilityScore(const OptimalParameters& params);
    bool LoadHistoricalTrades(datetime startTime, datetime endTime);
    bool ValidateParameters(const OptimalParameters& params);
    OptimalParameters GenerateRandomParameters();
    void InitializeParameterRanges();
    
    // Overfitting Detection Methods
    OverfittingResults DetectOverfitting(const OptimalParameters& params);
    double CalculateParameterSensitivity(const OptimalParameters& params);
    double CalculatePerformanceDecay(const OptimalParameters& params);
    double CalculateComplexityPenalty(const OptimalParameters& params);
    double CalculateParameterVariance();
    bool CheckParameterConsistency();
    bool IsPerformanceDegrading();
    
    // Advanced Optimization Methods
    OptimalParameters GeneticAlgorithmOptimization(datetime start, datetime end);
    OptimalParameters ParticleSwarmOptimization(datetime start, datetime end);
    OptimalParameters BayesianOptimization(datetime start, datetime end);
    OptimalParameters GridSearchOptimization(datetime start, datetime end);
    
    // Statistical Analysis
    double CalculateParameterCorrelation(const OptimalParameters& params1, const OptimalParameters& params2);
    double CalculateRobustnessScore(const OptimalParameters& params);
    bool ValidateStatisticalSignificance(const OptimalParameters& params);
    double CalculateSharpeRatio(const WalkForwardPeriod& period);
    double CalculateSortinoRatio(const WalkForwardPeriod& period);
    double CalculateCalmarRatio(const WalkForwardPeriod& period);
    
    // Utility Methods
    void LogOptimizationResults(const OptimalParameters& params, double score);
    double NormalizeScore(double rawScore);
    bool IsValidOptimizationPeriod(datetime start, datetime end);
    void LogAnalysisProgress(const string& message);
    string FormatOptimizationReport();
    
public:
    // Constructor & Destructor
    CStrategyOptimizer();
    ~CStrategyOptimizer();
    
    // Initialization
    bool Initialize(EAContext* context);
    void Deinitialize();
    void SetConfig(const StrategyOptimizerConfig& config);
    
    // Main Functionality
    bool RunWalkForwardAnalysis(datetime startDate, datetime endDate);
    bool OptimizeParameters(datetime startDate, datetime endDate, OptimalParameters& result);
    bool ShouldReoptimize();
    void MonitorParameterStability();
    
    // Parameter Management
    OptimalParameters GetCurrentOptimalParameters() const { return m_CurrentBest; }
    bool UpdateParameters(const OptimalParameters& newParams);
    bool ApplyOptimalParameters();
    void ResetToDefaultParameters();
    
    // Event Handlers
    void OnTick();
    void OnNewBar();
    void OnTradeClose(double profit, double loss);
    
    // Analysis Results
    double GetWalkForwardEfficiency();
    double GetAverageOutOfSampleReturn();
    double GetOptimizationSuccessRate();
    string GetOptimizationReport();
    string GetDetailedAnalysisReport();
    bool ExportResults(string filename);
    
    // Overfitting Detection
    OverfittingResults GetLastOverfittingResults() const { return m_LastOverfittingResults; }
    bool IsCurrentStrategyOverfitted();
    double GetCurrentStabilityScore();
    
    // Getters
    int GetWindowCount() const { return m_iWindowCount; }
    int GetPeriodCount() const { return m_iPeriodCount; }
    double GetBestScore() const { return m_dBestScore; }
    double GetCurrentScore() const { return m_dCurrentScore; }
    bool IsOptimizing() const { return m_bIsOptimizing; }
    datetime GetLastOptimization() const { return m_LastOptimization; }
    StrategyOptimizerConfig GetConfig() const { return m_Config; }
    
    // State Management
    void Reset();
    void Cleanup();
    bool SaveOptimizationResults();
    bool LoadPreviousResults();
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CStrategyOptimizer::CStrategyOptimizer() {
    m_pContext = NULL;
    m_bInitialized = false;
    
    // Initialize arrays
    ArrayResize(m_Windows, 0);
    ArrayResize(m_Periods, 0);
    m_iWindowCount = 0;
    m_iPeriodCount = 0;
    
    // Initialize state
    m_LastOptimization = 0;
    m_bIsOptimizing = false;
    m_bOptimizationNeeded = false;
    
    m_dBestScore = 0.0;
    m_dCurrentScore = 0.0;
    m_dPerformanceThreshold = 0.0;
    m_iTotalOptimizations = 0;
    m_iSuccessfulOptimizations = 0;
    
    m_dMaxParameterSensitivity = 0.25;
    m_dMaxPerformanceDecay = 0.2;
    m_iStabilityTestPeriods = 5;
    
    m_FirstOptimization = 0;
    m_dAverageOptimizationTime = 0.0;
    m_dTotalOptimizationTime = 0.0;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CStrategyOptimizer::~CStrategyOptimizer() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::Initialize(EAContext* context) {
    if (context == NULL) {
        Print("[StrategyOptimizer] ERROR: Context is NULL");
        return false;
    }
    
    m_pContext = context;
    
    // Initialize parameter ranges
    InitializeParameterRanges();
    
    // Load previous results if available
    LoadPreviousResults();
    
    m_bInitialized = true;
    
    if (m_pContext.pLogger != NULL) {
        string msg = StringFormat("StrategyOptimizer initialized: InSample=%d days, OutSample=%d days",
                                m_Config.InSampleDays, m_Config.OutOfSampleDays);
        m_pContext.pLogger.LogInfo(msg, __FUNCTION__);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CStrategyOptimizer::Deinitialize() {
    if (m_bInitialized) {
        SaveOptimizationResults();
        
        if (m_pContext.pLogger != NULL) {
            m_pContext.pLogger.LogInfo("StrategyOptimizer deinitialized", __FUNCTION__);
        }
    }
    
    Cleanup();
    m_bInitialized = false;
    m_pContext = NULL;
}

//+------------------------------------------------------------------+
//| Set Configuration                                                |
//+------------------------------------------------------------------+
void CStrategyOptimizer::SetConfig(const StrategyOptimizerConfig& config) {
    m_Config = config;
    
    if (m_bInitialized && m_pContext.pLogger != NULL) {
        string msg = StringFormat("StrategyOptimizer configuration updated: Stability threshold=%.1f%%",
                                m_Config.StabilityThreshold);
        m_pContext.pLogger.LogInfo(msg, __FUNCTION__);
    }
}

//+------------------------------------------------------------------+
//| Run Walk-Forward Analysis                                        |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::RunWalkForwardAnalysis(datetime startDate, datetime endDate) {
    if (!m_bInitialized || !m_Config.EnableWalkForward) {
        return false;
    }
    
    m_bIsOptimizing = true;
    datetime optimizationStart = GetTickCount();
    
    if (m_pContext.pLogger != NULL) {
        string msg = StringFormat("Starting Walk-Forward Analysis: %s to %s",
                                TimeToString(startDate), TimeToString(endDate));
        m_pContext.pLogger.LogInfo(msg, __FUNCTION__);
    }
    
    // Create optimization windows
    if (!CreateOptimizationWindows(startDate, endDate)) {
        m_bIsOptimizing = false;
        return false;
    }
    
    // Optimize each window
    int successfulWindows = 0;
    for (int i = 0; i < m_iWindowCount; i++) {
        if (OptimizeParametersForWindow(m_Windows[i])) {
            successfulWindows++;
        }
    }
    
    // Calculate overall results
    double efficiency = GetWalkForwardEfficiency();
    double avgOutOfSampleReturn = GetAverageOutOfSampleReturn();
    
    // Update statistics
    m_iTotalOptimizations++;
    if (efficiency > 0.5) { // Consider successful if efficiency > 50%
        m_iSuccessfulOptimizations++;
    }
    
    m_LastOptimization = TimeCurrent();
    m_dTotalOptimizationTime += (GetTickCount() - optimizationStart);
    m_dAverageOptimizationTime = m_dTotalOptimizationTime / m_iTotalOptimizations;
    
    m_bIsOptimizing = false;
    
    if (m_pContext.pLogger != NULL) {
        string msg = StringFormat("Walk-Forward Analysis completed: %d/%d windows successful, Efficiency=%.2f%%",
                                successfulWindows, m_iWindowCount, efficiency * 100);
        m_pContext.pLogger.LogInfo(msg, __FUNCTION__);
    }
    
    return (successfulWindows > 0);
}

//+------------------------------------------------------------------+
//| Optimize Parameters                                              |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::OptimizeParameters(datetime startDate, datetime endDate, OptimalParameters& result) {
    if (!m_bInitialized) {
        return false;
    }
    
    if (!IsValidOptimizationPeriod(startDate, endDate)) {
        if (m_pContext.pLogger != NULL) {
            m_pContext.pLogger.LogWarning("Invalid optimization period", __FUNCTION__);
        }
        return false;
    }
    
    OptimalParameters bestParams;
    double bestScore = -1.0;
    
    // Choose optimization method based on configuration
    if (m_Config.UseBayesianOptimization) {
        bestParams = BayesianOptimization(startDate, endDate);
    } else if (m_Config.UseGeneticAlgorithm) {
        bestParams = GeneticAlgorithmOptimization(startDate, endDate);
    } else if (m_Config.UseParticleSwarm) {
        bestParams = ParticleSwarmOptimization(startDate, endDate);
    } else {
        bestParams = GridSearchOptimization(startDate, endDate);
    }
    
    // Validate and test for overfitting
    if (ValidateParameters(bestParams)) {
        if (m_Config.EnableOverfittingDetection) {
            OverfittingResults overfittingResults = DetectOverfitting(bestParams);
            if (overfittingResults.IsOverfitted) {
                if (m_pContext.pLogger != NULL) {
                    string msg = StringFormat("Overfitting detected: %s", overfittingResults.OverfittingReason);
                    m_pContext.pLogger.LogWarning(msg, __FUNCTION__);
                }
                // Apply penalty to score
                bestParams.FinalScore *= (1.0 - overfittingResults.OverfittingPenalty);
            }
            m_LastOverfittingResults = overfittingResults;
        }
        
        result = bestParams;
        m_CurrentBest = bestParams;
        m_dCurrentScore = bestParams.FinalScore;
        
        if (bestParams.FinalScore > m_dBestScore) {
            m_dBestScore = bestParams.FinalScore;
        }
        
        LogOptimizationResults(bestParams, bestParams.FinalScore);
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Should Reoptimize                                                |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::ShouldReoptimize() {
    if (!m_bInitialized || m_bIsOptimizing) {
        return false;
    }
    
    // Check time-based reoptimization
    if (m_LastOptimization > 0) {
        int daysSinceLastOptimization = (int)((TimeCurrent() - m_LastOptimization) / 86400);
        if (daysSinceLastOptimization >= m_Config.OptimizationInterval) {
            return true;
        }
    } else {
        return true; // First optimization
    }
    
    // Check performance-based reoptimization
    if (m_Config.EnableParameterStability && IsPerformanceDegrading()) {
        return true;
    }
    
    // Check if current strategy is overfitted
    if (m_Config.EnableOverfittingDetection && IsCurrentStrategyOverfitted()) {
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Monitor Parameter Stability                                      |
//+------------------------------------------------------------------+
void CStrategyOptimizer::MonitorParameterStability() {
    if (!m_bInitialized || !m_Config.EnableParameterStability) {
        return;
    }
    
    // Calculate current stability score
    double currentStability = GetCurrentStabilityScore();
    
    if (currentStability < m_Config.StabilityThreshold) {
        m_bOptimizationNeeded = true;
        
        if (m_pContext.pLogger != NULL) {
            string msg = StringFormat("Parameter stability below threshold: %.2f%% < %.2f%%",
                                    currentStability, m_Config.StabilityThreshold);
            m_pContext.pLogger.LogWarning(msg, __FUNCTION__);
        }
    }
}

//+------------------------------------------------------------------+
//| OnTick Event Handler                                             |
//+------------------------------------------------------------------+
void CStrategyOptimizer::OnTick() {
    if (!m_bInitialized) return;
    
    // Periodic stability monitoring (every 100 ticks)
    static int tickCount = 0;
    tickCount++;
    
    if (tickCount >= 100) {
        MonitorParameterStability();
        tickCount = 0;
    }
}

//+------------------------------------------------------------------+
//| OnNewBar Event Handler                                           |
//+------------------------------------------------------------------+
void CStrategyOptimizer::OnNewBar() {
    if (!m_bInitialized) return;
    
    // Check if reoptimization is needed
    if (ShouldReoptimize()) {
        datetime endDate = TimeCurrent();
        datetime startDate = endDate - (m_Config.InSampleDays + m_Config.OutOfSampleDays) * 86400;
        
        OptimalParameters newParams;
        if (OptimizeParameters(startDate, endDate, newParams)) {
            ApplyOptimalParameters();
        }
    }
}

//+------------------------------------------------------------------+
//| OnTradeClose Event Handler                                       |
//+------------------------------------------------------------------+
void CStrategyOptimizer::OnTradeClose(double profit, double loss) {
    if (!m_bInitialized) return;
    
    // Update performance tracking
    // This will be used for stability monitoring and overfitting detection
}

//+------------------------------------------------------------------+
//| Get Walk-Forward Efficiency                                      |
//+------------------------------------------------------------------+
double CStrategyOptimizer::GetWalkForwardEfficiency() {
    if (m_iWindowCount == 0) return 0.0;
    
    double totalEfficiency = 0.0;
    int validWindows = 0;
    
    for (int i = 0; i < m_iWindowCount; i++) {
        if (m_Windows[i].IsValid) {
            totalEfficiency += m_Windows[i].Efficiency;
            validWindows++;
        }
    }
    
    return (validWindows > 0) ? totalEfficiency / validWindows : 0.0;
}

//+------------------------------------------------------------------+
//| Get Average Out-of-Sample Return                                 |
//+------------------------------------------------------------------+
double CStrategyOptimizer::GetAverageOutOfSampleReturn() {
    if (m_iWindowCount == 0) return 0.0;
    
    double totalReturn = 0.0;
    int validWindows = 0;
    
    for (int i = 0; i < m_iWindowCount; i++) {
        if (m_Windows[i].IsValid) {
            totalReturn += m_Windows[i].OutOfSampleReturn;
            validWindows++;
        }
    }
    
    return (validWindows > 0) ? totalReturn / validWindows : 0.0;
}

//+------------------------------------------------------------------+
//| Get Optimization Success Rate                                    |
//+------------------------------------------------------------------+
double CStrategyOptimizer::GetOptimizationSuccessRate() {
    if (m_iTotalOptimizations == 0) return 0.0;
    
    return (double)m_iSuccessfulOptimizations / m_iTotalOptimizations * 100.0;
}

//+------------------------------------------------------------------+
//| Get Optimization Report                                          |
//+------------------------------------------------------------------+
string CStrategyOptimizer::GetOptimizationReport() {
    return FormatOptimizationReport();
}

//+------------------------------------------------------------------+
//| Get Detailed Analysis Report                                     |
//+------------------------------------------------------------------+
string CStrategyOptimizer::GetDetailedAnalysisReport() {
    string report = "";
    
    report += "=== STRATEGY OPTIMIZER DETAILED REPORT ===\n";
    report += StringFormat("Total Optimizations: %d\n", m_iTotalOptimizations);
    report += StringFormat("Successful Optimizations: %d (%.1f%%)\n", 
                          m_iSuccessfulOptimizations, GetOptimizationSuccessRate());
    report += StringFormat("Best Score: %.4f\n", m_dBestScore);
    report += StringFormat("Current Score: %.4f\n", m_dCurrentScore);
    report += StringFormat("Walk-Forward Efficiency: %.2f%%\n", GetWalkForwardEfficiency() * 100);
    report += StringFormat("Average Out-of-Sample Return: %.2f%%\n", GetAverageOutOfSampleReturn() * 100);
    report += StringFormat("Last Optimization: %s\n", TimeToString(m_LastOptimization));
    
    if (m_Config.EnableOverfittingDetection) {
        report += "\n=== OVERFITTING ANALYSIS ===\n";
        report += StringFormat("Overfitting Detected: %s\n", 
                              m_LastOverfittingResults.IsOverfitted ? "YES" : "NO");
        if (m_LastOverfittingResults.IsOverfitted) {
            report += StringFormat("Reason: %s\n", m_LastOverfittingResults.OverfittingReason);
            report += StringFormat("Severity: %s\n", EnumToString(m_LastOverfittingResults.Level));
        }
        report += StringFormat("Parameter Sensitivity: %.3f\n", m_LastOverfittingResults.ParameterSensitivity);
        report += StringFormat("Performance Decay: %.3f\n", m_LastOverfittingResults.PerformanceDecay);
        report += StringFormat("Stability Index: %.3f\n", m_LastOverfittingResults.StabilityIndex);
    }
    
    report += "\n=== CURRENT OPTIMAL PARAMETERS ===\n";
    report += StringFormat("Risk Percent: %.2f%%\n", m_CurrentBest.RiskPercent);
    report += StringFormat("ATR Multiplier SL: %.2f\n", m_CurrentBest.ATRMultiplierSL);
    report += StringFormat("ATR Multiplier TP: %.2f\n", m_CurrentBest.ATRMultiplierTP);
    report += StringFormat("ATR Period: %d\n", m_CurrentBest.ATRPeriod);
    report += StringFormat("EMA Fast: %d\n", m_CurrentBest.EMAFastPeriod);
    report += StringFormat("EMA Slow: %d\n", m_CurrentBest.EMASlowPeriod);
    report += StringFormat("RSI Period: %d\n", m_CurrentBest.RSIPeriod);
    report += StringFormat("Pullback Threshold: %.3f\n", m_CurrentBest.PullbackThreshold);
    
    return report;
}

//+------------------------------------------------------------------+
//| Export Results                                                   |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::ExportResults(string filename) {
    if (!m_bInitialized) return false;
    
    string fullPath = StringFormat("%s\\%s", TerminalInfoString(TERMINAL_DATA_PATH), filename);
    
    int fileHandle = FileOpen(fullPath, FILE_WRITE | FILE_TXT);
    if (fileHandle == INVALID_HANDLE) {
        if (m_pContext.pLogger != NULL) {
            m_pContext.pLogger.LogError("Failed to create export file: " + fullPath, __FUNCTION__);
        }
        return false;
    }
    
    FileWrite(fileHandle, GetDetailedAnalysisReport());
    FileClose(fileHandle);
    
    if (m_pContext.pLogger != NULL) {
        m_pContext.pLogger.LogInfo("Optimization results exported to: " + fullPath, __FUNCTION__);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Is Current Strategy Overfitted                                   |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::IsCurrentStrategyOverfitted() {
    return m_LastOverfittingResults.IsOverfitted;
}

//+------------------------------------------------------------------+
//| Get Current Stability Score                                      |
//+------------------------------------------------------------------+
double CStrategyOptimizer::GetCurrentStabilityScore() {
    return CalculateStabilityScore(m_CurrentBest);
}

//+------------------------------------------------------------------+
//| Update Parameters                                                |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::UpdateParameters(const OptimalParameters& newParams) {
    if (!ValidateParameters(newParams)) {
        return false;
    }
    
    m_PreviousBest = m_CurrentBest;
    m_CurrentBest = newParams;
    
    if (m_pContext.pLogger != NULL) {
        m_pContext.pLogger.LogInfo("Parameters updated successfully", __FUNCTION__);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Apply Optimal Parameters                                         |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::ApplyOptimalParameters() {
    if (!m_bInitialized) return false;
    
    // Apply parameters to the EA context
    // This would update the actual trading parameters used by the EA
    
    if (m_pContext.pLogger != NULL) {
        string msg = StringFormat("Applied optimal parameters: Score=%.4f", m_CurrentBest.FinalScore);
        m_pContext.pLogger.LogInfo(msg, __FUNCTION__);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Reset to Default Parameters                                      |
//+------------------------------------------------------------------+
void CStrategyOptimizer::ResetToDefaultParameters() {
    OptimalParameters defaultParams;
    m_CurrentBest = defaultParams;
    m_dCurrentScore = 0.0;
    
    if (m_pContext.pLogger != NULL) {
        m_pContext.pLogger.LogInfo("Reset to default parameters", __FUNCTION__);
    }
}

//+------------------------------------------------------------------+
//| Reset                                                            |
//+------------------------------------------------------------------+
void CStrategyOptimizer::Reset() {
    ArrayResize(m_Windows, 0);
    ArrayResize(m_Periods, 0);
    m_iWindowCount = 0;
    m_iPeriodCount = 0;
    
    m_LastOptimization = 0;
    m_bIsOptimizing = false;
    m_bOptimizationNeeded = false;
    
    m_dBestScore = 0.0;
    m_dCurrentScore = 0.0;
    m_iTotalOptimizations = 0;
    m_iSuccessfulOptimizations = 0;
    
    ResetToDefaultParameters();
    
    if (m_bInitialized && m_pContext.pLogger != NULL) {
        m_pContext.pLogger.LogInfo("StrategyOptimizer reset completed", __FUNCTION__);
    }
}

//+------------------------------------------------------------------+
//| Cleanup                                                          |
//+------------------------------------------------------------------+
void CStrategyOptimizer::Cleanup() {
    ArrayFree(m_Windows);
    ArrayFree(m_Periods);
}

//+------------------------------------------------------------------+
//| Save Optimization Results                                        |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::SaveOptimizationResults() {
    // Implementation for saving optimization results to file
    // This would save the current state for persistence across EA restarts
    return true;
}

//+------------------------------------------------------------------+
//| Load Previous Results                                            |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::LoadPreviousResults() {
    // Implementation for loading previous optimization results
    // This would restore the state from a previous session
    return true;
}

//+------------------------------------------------------------------+
//| Initialize Parameter Ranges                                      |
//+------------------------------------------------------------------+
void CStrategyOptimizer::InitializeParameterRanges() {
    m_RiskPercentRange = ParameterRange(0.5, 5.0, 0.1, 1.0);
    m_ATRMultiplierSLRange = ParameterRange(1.0, 4.0, 0.1, 2.0);
    m_ATRMultiplierTPRange = ParameterRange(1.5, 6.0, 0.1, 3.0);
    m_ATRPeriodRange = ParameterRange(10, 30, 1, 14);
    m_EMAFastRange = ParameterRange(8, 20, 1, 12);
    m_EMASlowRange = ParameterRange(20, 40, 1, 26);
    m_RSIPeriodRange = ParameterRange(10, 25, 1, 14);
    m_RSIOverboughtRange = ParameterRange(65, 80, 1, 70);
    m_RSIOversoldRange = ParameterRange(20, 35, 1, 30);
    m_PullbackThresholdRange = ParameterRange(0.382, 0.786, 0.01, 0.618);
    m_PullbackLookbackRange = ParameterRange(10, 50, 1, 20);
    m_TrendStrengthRange = ParameterRange(0.4, 0.8, 0.01, 0.6);
}

//+------------------------------------------------------------------+
//| Placeholder implementations for complex methods                  |
//+------------------------------------------------------------------+

// These methods would contain the actual implementation logic
// For now, they are placeholders to maintain compilation

bool CStrategyOptimizer::CreateOptimizationWindows(datetime startDate, datetime endDate) {
    // Implementation for creating walk-forward windows
    return true;
}

bool CStrategyOptimizer::OptimizeParametersForWindow(WalkForwardWindow& window) {
    // Implementation for optimizing parameters for a specific window
    return true;
}

double CStrategyOptimizer::EvaluateParameterSet(const OptimalParameters& params, datetime start, datetime end) {
    // Implementation for evaluating a parameter set
    return 0.0;
}

bool CStrategyOptimizer::CalculatePeriodMetrics(WalkForwardPeriod& period) {
    // Implementation for calculating period metrics
    return true;
}

double CStrategyOptimizer::CalculateStabilityScore(const WalkForwardPeriod& period) {
    // Implementation for calculating stability score
    return 0.0;
}

double CStrategyOptimizer::CalculateStabilityScore(const OptimalParameters& params) {
    // Implementation for calculating parameter stability score
    return 0.0;
}

bool CStrategyOptimizer::LoadHistoricalTrades(datetime startTime, datetime endTime) {
    // Implementation for loading historical trade data
    return true;
}

bool CStrategyOptimizer::ValidateParameters(const OptimalParameters& params) {
    // Implementation for parameter validation
    return true;
}

OptimalParameters CStrategyOptimizer::GenerateRandomParameters() {
    // Implementation for generating random parameters
    OptimalParameters params;
    return params;
}

OverfittingResults CStrategyOptimizer::DetectOverfitting(const OptimalParameters& params) {
    // Implementation for overfitting detection
    OverfittingResults results;
    return results;
}

double CStrategyOptimizer::CalculateParameterSensitivity(const OptimalParameters& params) {
    // Implementation for parameter sensitivity calculation
    return 0.0;
}

double CStrategyOptimizer::CalculatePerformanceDecay(const OptimalParameters& params) {
    // Implementation for performance decay calculation
    return 0.0;
}

double CStrategyOptimizer::CalculateComplexityPenalty(const OptimalParameters& params) {
    // Implementation for complexity penalty calculation
    return 0.0;
}

double CStrategyOptimizer::CalculateParameterVariance() {
    // Implementation for parameter variance calculation
    return 0.0;
}

bool CStrategyOptimizer::CheckParameterConsistency() {
    // Implementation for parameter consistency check
    return true;
}

bool CStrategyOptimizer::IsPerformanceDegrading() {
    // Implementation for performance degradation detection
    return false;
}

OptimalParameters CStrategyOptimizer::GeneticAlgorithmOptimization(datetime start, datetime end) {
    // Implementation for genetic algorithm optimization
    OptimalParameters params;
    return params;
}

OptimalParameters CStrategyOptimizer::ParticleSwarmOptimization(datetime start, datetime end) {
    // Implementation for particle swarm optimization
    OptimalParameters params;
    return params;
}

OptimalParameters CStrategyOptimizer::BayesianOptimization(datetime start, datetime end) {
    // Implementation for Bayesian optimization
    OptimalParameters params;
    return params;
}

OptimalParameters CStrategyOptimizer::GridSearchOptimization(datetime start, datetime end) {
    // Implementation for grid search optimization
    OptimalParameters params;
    return params;
}

double CStrategyOptimizer::CalculateParameterCorrelation(const OptimalParameters& params1, const OptimalParameters& params2) {
    // Implementation for parameter correlation calculation
    return 0.0;
}

double CStrategyOptimizer::CalculateRobustnessScore(const OptimalParameters& params) {
    // Implementation for robustness score calculation
    return 0.0;
}

bool CStrategyOptimizer::ValidateStatisticalSignificance(const OptimalParameters& params) {
    // Implementation for statistical significance validation
    return true;
}

double CStrategyOptimizer::CalculateSharpeRatio(const WalkForwardPeriod& period) {
    // Implementation for Sharpe ratio calculation
    return 0.0;
}

double CStrategyOptimizer::CalculateSortinoRatio(const WalkForwardPeriod& period) {
    // Implementation for Sortino ratio calculation
    return 0.0;
}

double CStrategyOptimizer::CalculateCalmarRatio(const WalkForwardPeriod& period) {
    // Implementation for Calmar ratio calculation
    return 0.0;
}

void CStrategyOptimizer::LogOptimizationResults(const OptimalParameters& params, double score) {
    if (m_pContext.pLogger != NULL) {
        string msg = StringFormat("Optimization completed: Score=%.4f, Risk=%.2f%%, ATR_SL=%.2f",
                                score, params.RiskPercent, params.ATRMultiplierSL);
        m_pContext.pLogger.LogInfo(msg, __FUNCTION__);
    }
}

double CStrategyOptimizer::NormalizeScore(double rawScore) {
    // Implementation for score normalization
    return MathMax(0.0, MathMin(1.0, rawScore));
}

bool CStrategyOptimizer::IsValidOptimizationPeriod(datetime start, datetime end) {
    // Implementation for optimization period validation
    return (end > start) && ((end - start) >= 86400 * m_Config.InSampleDays);
}

void CStrategyOptimizer::LogAnalysisProgress(const string& message) {
    if (m_pContext.pLogger != NULL) {
        m_pContext.pLogger.LogDebug(message, __FUNCTION__);
    }
}

string CStrategyOptimizer::FormatOptimizationReport() {
    string report = "";
    report += "=== STRATEGY OPTIMIZER REPORT ===\n";
    report += StringFormat("Total Optimizations: %d\n", m_iTotalOptimizations);
    report += StringFormat("Success Rate: %.1f%%\n", GetOptimizationSuccessRate());
    report += StringFormat("Best Score: %.4f\n", m_dBestScore);
    report += StringFormat("Walk-Forward Efficiency: %.2f%%\n", GetWalkForwardEfficiency() * 100);
    return report;
}



#endif // APEX_STRATEGY_OPTIMIZER_MQH_