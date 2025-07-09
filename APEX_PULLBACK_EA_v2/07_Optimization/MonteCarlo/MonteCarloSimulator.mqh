//+------------------------------------------------------------------+
//|                                           MonteCarloSimulator.mqh |
//|               MonteCarloSimulator.mqh - APEX Pullback EA v5 FINAL |
//|      Description: Advanced Monte Carlo Analysis & Risk Simulation |
//|                    Ported from v14 with enhanced capabilities     |
//+------------------------------------------------------------------+

#ifndef MONTE_CARLO_SIMULATOR_MQH_
#define MONTE_CARLO_SIMULATOR_MQH_

#include "..\..\00_Core\CommonStructs.mqh"



//+------------------------------------------------------------------+
//| Monte Carlo Enumerations                                         |
//+------------------------------------------------------------------+
enum ENUM_STRESS_SCENARIO {
    STRESS_NORMAL,              // Normal market conditions
    STRESS_HIGH_SLIPPAGE,       // High slippage environment
    STRESS_HIGH_LATENCY,        // High latency execution
    STRESS_MARKET_CRASH,        // Market crash scenario
    STRESS_LOW_LIQUIDITY,       // Low liquidity conditions
    STRESS_BROKER_ISSUES,       // Broker execution issues
    STRESS_EXTREME_VOLATILITY,  // Extreme volatility
    STRESS_NEWS_EVENTS,         // Major news events
    STRESS_FLASH_CRASH,         // Flash crash scenario
    STRESS_WEEKEND_GAPS,        // Weekend gap scenario
    STRESS_CORRELATION_BREAKDOWN, // Asset correlation breakdown
    STRESS_LIQUIDITY_CRISIS,    // Liquidity crisis
    STRESS_INTEREST_RATE_SHOCK, // Interest rate shock
    STRESS_CURRENCY_DEVALUATION // Currency devaluation
};

enum ENUM_DISTRIBUTION_TYPE {
    DIST_NORMAL,                // Normal distribution
    DIST_LOG_NORMAL,            // Log-normal distribution
    DIST_T_STUDENT,             // Student's t-distribution
    DIST_LAPLACE,               // Laplace distribution
    DIST_PARETO,                // Pareto distribution
    DIST_WEIBULL,               // Weibull distribution
    DIST_CUSTOM                 // Custom distribution
};

enum ENUM_SIMULATION_TYPE {
    SIM_STANDARD,               // Standard Monte Carlo
    SIM_LATIN_HYPERCUBE,        // Latin Hypercube Sampling
    SIM_QUASI_RANDOM,           // Quasi-random sequences
    SIM_ANTITHETIC,             // Antithetic variates
    SIM_CONTROL_VARIATES,       // Control variates method
    SIM_IMPORTANCE_SAMPLING     // Importance sampling
};

//+------------------------------------------------------------------+
//| Monte Carlo Structures                                           |
//+------------------------------------------------------------------+
struct STradeScenario {
    double                WinRate;              // Win rate (0.0-1.0)
    double                AvgWin;               // Average winning trade
    double                AvgLoss;              // Average losing trade
    double                WinStdDev;            // Win standard deviation
    double                LossStdDev;           // Loss standard deviation
    int                   MaxConsecutiveLosses; // Max consecutive losses
    int                   MaxConsecutiveWins;   // Max consecutive wins
    int                   TotalTrades;          // Total trades in period
    double                SlippagePercent;      // Average slippage %
    double                CommissionPerTrade;   // Commission per trade
    double                SwapPerDay;           // Swap per day
    ENUM_DISTRIBUTION_TYPE WinDistribution;    // Win distribution type
    ENUM_DISTRIBUTION_TYPE LossDistribution;   // Loss distribution type
};

struct SMarketConditions {
    double                VolatilityMultiplier; // Volatility adjustment
    double                TrendStrength;        // Trend strength (0-1)
    double                LiquidityFactor;      // Liquidity factor (0-1)
    double                CorrelationFactor;    // Cross-asset correlation
    double                SpreadMultiplier;     // Spread adjustment
    double                NewsImpactFactor;     // News impact factor
    bool                  IsSessionActive;      // Trading session active
    ENUM_STRESS_SCENARIO  StressScenario;      // Applied stress scenario
};

struct SMonteCarloResult {
    // Basic Statistics
    double                ExpectedReturn;       // Expected return
    double                StandardDeviation;    // Standard deviation
    double                Variance;             // Variance
    double                MedianReturn;         // Median return
    double                ModeReturn;           // Mode return
    
    // Risk Metrics
    double                MaxDrawdown;          // Maximum drawdown
    double                MaxDrawdownDuration;  // Max DD duration (days)
    double                VaR95;                // Value at Risk 95%
    double                VaR99;                // Value at Risk 99%
    double                VaR999;               // Value at Risk 99.9%
    double                CVaR95;               // Conditional VaR 95%
    double                CVaR99;               // Conditional VaR 99%
    double                CVaR999;              // Conditional VaR 99.9%
    
    // Performance Metrics
    double                SharpeRatio;          // Sharpe ratio
    double                SortinoRatio;         // Sortino ratio
    double                CalmarRatio;          // Calmar ratio
    double                SterlingRatio;        // Sterling ratio
    double                BurkeRatio;           // Burke ratio
    double                TreynorRatio;         // Treynor ratio
    
    // Distribution Metrics
    double                Skewness;             // Skewness
    double                Kurtosis;             // Kurtosis
    double                JarqueBeraTest;       // Jarque-Bera normality test
    bool                  IsNormalDistribution; // Is normally distributed
    
    // Probability Metrics
    double                ProbabilityOfProfit;  // Probability of profit
    double                ProbabilityOfLoss;    // Probability of loss
    double                ProbabilityOfRuin;    // Probability of ruin
    double                ProbabilityTarget50;  // Prob of 50% gain
    double                ProbabilityTarget100; // Prob of 100% gain
    
    // Extreme Scenarios
    double                WorstCaseScenario;    // Worst case scenario
    double                BestCaseScenario;     // Best case scenario
    double                Percentile1;          // 1st percentile
    double                Percentile5;          // 5th percentile
    double                Percentile95;         // 95th percentile
    double                Percentile99;         // 99th percentile
    
    // Recovery Analysis
    double                MaxConsecutiveLoss;   // Max consecutive loss
    double                RecoveryTime;         // Expected recovery time
    double                TimeToTarget;         // Time to reach target
    double                UnderwaterPeriods;    // Underwater periods count
    
    // Confidence & Quality
    double                ConfidenceLevel;      // Confidence level
    double                StandardError;        // Standard error
    double                MonteCarloError;      // MC estimation error
    int                   TotalSimulations;     // Total simulations run
    ENUM_STRESS_SCENARIO  StressScenario;      // Applied stress scenario
    
    // Assessment & Recommendations
    string                RiskAssessment;       // Risk assessment text
    string                PerformanceGrade;     // Performance grade (A-F)
    string                ActionableInsights;   // Actionable insights
    string                WarningFlags;         // Warning flags
    datetime              CalculationTime;      // When calculated
    int                   CalculationDuration;  // Calculation time (ms)
};

struct SSimulationConfig {
    int                   TotalSimulations;     // Number of simulations
    ENUM_SIMULATION_TYPE  SimulationType;      // Simulation methodology
    ENUM_DISTRIBUTION_TYPE DefaultDistribution; // Default distribution
    bool                  UseAntitheticVariates; // Use antithetic variates
    bool                  UseControlVariates;   // Use control variates
    double                ConfidenceLevel;      // Confidence level
    int                   WarmupPeriod;         // Warmup period
    int                   MaxIterations;        // Maximum iterations
    double                ConvergenceTolerance; // Convergence tolerance
    bool                  EnableParallelProcessing; // Enable parallel processing
    bool                  UseProgressiveRefinement; // Progressive refinement
    int                   RandomSeed;           // Random seed (0 = auto)
    bool                  SaveIntermediateResults; // Save intermediate results
    string                OutputPath;           // Output file path
};

//+------------------------------------------------------------------+
//| CMonteCarloSimulator - Advanced Risk Simulation Engine          |
//+------------------------------------------------------------------+
class CMonteCarloSimulator {
private:
    EAContext*            m_pContext;           // Reference to EA context
    bool                  m_bInitialized;      // Initialization status
    
    // Configuration
    SSimulationConfig     m_Config;             // Simulation configuration
    STradeScenario        m_BaseScenario;       // Base trading scenario
    SMarketConditions     m_MarketConditions;   // Market conditions
    
    // Simulation Data
    double                m_Results[];          // Simulation results array
    double                m_DrawdownSeries[];   // Drawdown time series
    double                m_EquityCurve[];      // Equity curve data
    double                m_Returns[];          // Returns series
    
    // Statistical Buffers
    double                m_SortedResults[];    // Sorted results for VaR
    double                m_CumulativeReturns[]; // Cumulative returns
    int                   m_PositiveCount;      // Positive outcomes count
    int                   m_NegativeCount;      // Negative outcomes count
    
    // Performance Tracking
    datetime              m_StartTime;          // Simulation start time
    datetime              m_EndTime;            // Simulation end time
    int                   m_CurrentIteration;   // Current iteration
    double                m_ConvergenceValue;   // Convergence value
    bool                  m_HasConverged;       // Convergence flag
    
    // Random Number Generation
    int                   m_RandomSeed;         // Current random seed
    double                m_NormalSpare;        // Spare normal variate
    bool                  m_HasNormalSpare;     // Has spare flag
    
    // Memory Management
    int                   m_MaxArraySize;       // Maximum array size
    bool                  m_MemoryOptimized;    // Memory optimization flag
    
public:
    //--- Constructor/Destructor ---
    CMonteCarloSimulator();
    ~CMonteCarloSimulator();
    
    //--- Core Methods ---
    bool                  Initialize(EAContext* pContext, const SSimulationConfig& config);
    void                  Deinitialize();
    bool                  IsInitialized() const { return m_bInitialized; }
    
    //--- Configuration ---
    bool                  SetBaseScenario(const STradeScenario& scenario);
    bool                  SetMarketConditions(const SMarketConditions& conditions);
    bool                  SetConfiguration(const SSimulationConfig& config);
    STradeScenario        GetBaseScenario() const { return m_BaseScenario; }
    SMarketConditions     GetMarketConditions() const { return m_MarketConditions; }
    SSimulationConfig     GetConfiguration() const { return m_Config; }
    
    //--- Main Simulation Methods ---
    bool                  RunStandardSimulation(SMonteCarloResult& result);
    bool                  RunStressTest(SMonteCarloResult& result, ENUM_STRESS_SCENARIO scenario);
    bool                  RunOptimisticScenario(SMonteCarloResult& result);
    bool                  RunPessimisticScenario(SMonteCarloResult& result);
    bool                  RunCustomScenario(SMonteCarloResult& result, const STradeScenario& custom_scenario);
    
    //--- Advanced Analysis ---
    bool                  RunMultiScenarioAnalysis(SMonteCarloResult results[], int& count);
    bool                  RunSensitivityAnalysis(SMonteCarloResult& result, const string& parameter);
    bool                  RunStabilityTest(SMonteCarloResult& result);
    bool                  ValidateStrategyRobustness(double min_sharpe = 1.0, double max_drawdown = 0.20);
    
    //--- Risk Assessment ---
    bool                  CalculateRiskMetrics(SMonteCarloResult& result);
    bool                  CalculateAdvancedMetrics(SMonteCarloResult& result);
    bool                  AnalyzeExtremeScenarios(SMonteCarloResult& result);
    bool                  EstimateRecoveryMetrics(SMonteCarloResult& result);
    
    //--- Reporting & Output ---
    string                GenerateDetailedReport(const SMonteCarloResult& result);
    string                GenerateExecutiveSummary(const SMonteCarloResult& result);
    string                GenerateRiskReport(const SMonteCarloResult& result);
    bool                  SaveResults(const SMonteCarloResult& result, const string& filename = "");
    bool                  ExportToCSV(const SMonteCarloResult& result, const string& filename = "");
    
    //--- Utility Methods ---
    void                  Reset();
    double                GetProgress() const;
    bool                  IsConverged() const { return m_HasConverged; }
    int                   GetCurrentIteration() const { return m_CurrentIteration; }
    
private:
    //--- Internal Simulation Logic ---
    double                SimulateTradingSequence(const STradeScenario& scenario, const SMarketConditions& conditions);
    double                GenerateTradeOutcome(const STradeScenario& scenario, bool is_win);
    bool                  SimulateMarketStress(SMarketConditions& conditions, ENUM_STRESS_SCENARIO scenario);
    
    //--- Statistical Calculations ---
    void                  CalculateBasicStatistics(SMonteCarloResult& result);
    void                  CalculateRiskStatistics(SMonteCarloResult& result);
    void                  CalculatePerformanceRatios(SMonteCarloResult& result);
    void                  CalculateDistributionMetrics(SMonteCarloResult& result);
    void                  CalculateProbabilityMetrics(SMonteCarloResult& result);
    
    //--- Distribution Functions ---
    double                GenerateNormal(double mean, double std_dev);
    double                GenerateLogNormal(double mean, double std_dev);
    double                GenerateStudentT(double degrees_freedom);
    double                GenerateLaplace(double mean, double scale);
    double                GeneratePareto(double scale, double shape);
    double                GenerateWeibull(double scale, double shape);
    
    //--- Value at Risk Calculations ---
    double                CalculateVaR(double confidence_level);
    double                CalculateConditionalVaR(double confidence_level);
    double                CalculateExpectedShortfall(double confidence_level);
    
    //--- Performance Ratios ---
    double                CalculateSharpeRatio(double mean_return, double std_dev, double risk_free_rate = 0.0);
    double                CalculateSortinoRatio(double mean_return, double downside_deviation);
    double                CalculateCalmarRatio(double mean_return, double max_drawdown);
    double                CalculateSterlingRatio(double mean_return, double max_drawdown);
    double                CalculateBurkeRatio(double mean_return, double drawdown_squared_sum);
    
    //--- Statistical Tests ---
    double                CalculateJarqueBeraTest();
    bool                  TestNormality(double significance_level = 0.05);
    double                CalculateSkewness();
    double                CalculateKurtosis();
    
    //--- Risk Assessment ---
    string                GenerateRiskAssessment(const SMonteCarloResult& result);
    string                GeneratePerformanceGrade(const SMonteCarloResult& result);
    string                GenerateActionableInsights(const SMonteCarloResult& result);
    string                GenerateWarningFlags(const SMonteCarloResult& result);
    
    //--- Convergence & Optimization ---
    bool                  CheckConvergence();
    void                  UpdateConvergenceMetrics();
    bool                  OptimizeMemoryUsage();
    
    //--- Utility Functions ---
    void                  LogSimulationEvent(const string& event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO);
    void                  ValidateInputs();
    void                  InitializeArrays();
    void                  CleanupArrays();
    double                NormalCDF(double x);
    double                InverseNormalCDF(double p);
    
    //--- Memory Management ---
    bool                  AllocateMemory();
    void                  FreeMemory();
    bool                  ResizeArrays(int new_size);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CMonteCarloSimulator::CMonteCarloSimulator() : 
    m_pContext(NULL),
    m_bInitialized(false),
    m_CurrentIteration(0),
    m_HasConverged(false),
    m_PositiveCount(0),
    m_NegativeCount(0),
    m_MaxArraySize(1000000),
    m_MemoryOptimized(false),
    m_HasNormalSpare(false),
    m_NormalSpare(0.0),
    m_RandomSeed(0),
    m_ConvergenceValue(0.0)
{
    // Initialize with default configuration
    ZeroMemory(m_Config);
    ZeroMemory(m_BaseScenario);
    ZeroMemory(m_MarketConditions);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CMonteCarloSimulator::~CMonteCarloSimulator() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CMonteCarloSimulator::Initialize(EAContext* pContext, const SSimulationConfig& config) {
    if (m_bInitialized) {
        return true;
    }
    
    m_pContext = pContext;
    if (m_pContext == NULL) {
        Print("[MONTE_CARLO] Context is NULL");
        return false;
    }
    
    // Set configuration
    m_Config = config;

    // Set default base scenario if not provided
    m_BaseScenario.WinRate = 0.55;
    m_BaseScenario.AvgWin = 100.0;
    m_BaseScenario.AvgLoss = -80.0;
    m_BaseScenario.WinStdDev = 30.0;
    m_BaseScenario.LossStdDev = 20.0;
    m_BaseScenario.MaxConsecutiveLosses = 8;
    m_BaseScenario.MaxConsecutiveWins = 12;
    m_BaseScenario.TotalTrades = 1000;
    m_BaseScenario.WinDistribution = DIST_NORMAL;
    m_BaseScenario.LossDistribution = DIST_NORMAL;
    
    // Set default market conditions
    m_MarketConditions.VolatilityMultiplier = 1.0;
    m_MarketConditions.TrendStrength = 0.5;
    m_MarketConditions.LiquidityFactor = 1.0;
    m_MarketConditions.SpreadMultiplier = 1.0;
    m_MarketConditions.IsSessionActive = true;
    m_MarketConditions.StressScenario = STRESS_NORMAL;

    ValidateInputs();
    
    // Initialize random seed
    if (m_Config.RandomSeed == 0) {
        m_RandomSeed = (int)TimeCurrent();
    } else {
        m_RandomSeed = m_Config.RandomSeed;
    }
    MathSrand(m_RandomSeed);
    
    // Allocate memory
    if (!AllocateMemory()) {
        LogSimulationEvent("Failed to allocate memory", LOG_LEVEL_ERROR);
        return false;
    }
    
    // Initialize arrays
    InitializeArrays();
    
    m_bInitialized = true;
    
    if (m_pContext->pLogger != NULL) {
        string init_msg = StringFormat("Monte Carlo Simulator initialized: %d simulations, Type: %d, Seed: %d",
                                      m_Config.TotalSimulations, (int)m_Config.SimulationType, m_RandomSeed);
        m_pContext->pLogger->LogInfo(init_msg, __FUNCTION__);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CMonteCarloSimulator::Deinitialize() {
    if (!m_bInitialized) {
        return;
    }
    
    // Log final statistics
    if (m_pContext != NULL && m_pContext->pLogger != NULL) {
        string final_msg = StringFormat("Monte Carlo completed: %d iterations, Converged: %s",
                                       m_CurrentIteration, m_HasConverged ? "Yes" : "No");
        m_pContext->pLogger->LogInfo(final_msg, __FUNCTION__);
    }
    
    // Free memory
    FreeMemory();
    
    m_bInitialized = false;
}

//+------------------------------------------------------------------+
//| Run Standard Simulation                                          |
//+------------------------------------------------------------------+
bool CMonteCarloSimulator::RunStandardSimulation(SMonteCarloResult& result) {
    if (!m_bInitialized) {
        LogSimulationEvent("Simulator not initialized", LOG_LEVEL_ERROR);
        return false;
    }
    
    m_StartTime = TimeCurrent();
    
    LogSimulationEvent(StringFormat("Starting standard Monte Carlo simulation: %d runs", 
                                   m_Config.TotalSimulations), LOG_LEVEL_INFO);
    
    // Reset counters
    m_CurrentIteration = 0;
    m_PositiveCount = 0;
    m_NegativeCount = 0;
    m_HasConverged = false;
    
    // Run simulations
    for (int i = 0; i < m_Config.TotalSimulations; i++) {
        m_Results[i] = SimulateTradingSequence(m_BaseScenario, m_MarketConditions);
        
        if (m_Results[i] > 0) {
            m_PositiveCount++;
        } else {
            m_NegativeCount++;
        }
        
        m_CurrentIteration = i + 1;
        
        // Check convergence periodically
        if (m_Config.ConvergenceTolerance > 0 && (i + 1) % 1000 == 0) {
            if (CheckConvergence()) {
                m_HasConverged = true;
                LogSimulationEvent(StringFormat("Converged after %d iterations", i + 1), LOG_LEVEL_INFO);
                break;
            }
        }
        
        // Log progress
        if (m_pContext->pLogger != NULL && (i + 1) % 2000 == 0) {
            double progress = (double)(i + 1) / m_Config.TotalSimulations * 100.0;
            string progress_msg = StringFormat("Progress: %.1f%% (%d/%d)", 
                                             progress, i + 1, m_Config.TotalSimulations);
            m_pContext->pLogger->LogDebug(progress_msg, __FUNCTION__);
        }
    }
    
    m_EndTime = TimeCurrent();
    
    // Calculate all statistics
    CalculateBasicStatistics(result);
    CalculateRiskStatistics(result);
    CalculatePerformanceRatios(result);
    CalculateDistributionMetrics(result);
    CalculateProbabilityMetrics(result);
    
    // Generate assessments
    result.RiskAssessment = GenerateRiskAssessment(result);
    result.PerformanceGrade = GeneratePerformanceGrade(result);
    result.ActionableInsights = GenerateActionableInsights(result);
    result.WarningFlags = GenerateWarningFlags(result);
    
    // Set metadata
    result.TotalSimulations = m_CurrentIteration;
    result.CalculationTime = m_EndTime;
    result.CalculationDuration = (int)(m_EndTime - m_StartTime);
    result.StressScenario = m_MarketConditions.StressScenario;
    
    LogSimulationEvent(StringFormat("Simulation completed: Expected Return=%.2f, Sharpe=%.3f, Max DD=%.2f%%",
                                   result.ExpectedReturn, result.SharpeRatio, result.MaxDrawdown * 100),
                      LOG_LEVEL_INFO);
    
    return true;
}

//+------------------------------------------------------------------+
//| Internal Methods Implementation                                  |
//+------------------------------------------------------------------+

double CMonteCarloSimulator::SimulateTradingSequence(const STradeScenario& scenario, const SMarketConditions& conditions) {
    double balance = AccountInfoDouble(ACCOUNT_BALANCE);
    if (balance <= 0) balance = 10000.0; // Default balance
    
    double starting_balance = balance;
    double peak_balance = balance;
    double max_drawdown = 0.0;
    
    int consecutive_wins = 0;
    int consecutive_losses = 0;
    
    // Simulate trades
    for (int i = 0; i < scenario.TotalTrades; i++) {
        bool is_win = (MathRand() / 32767.0) <= scenario.WinRate;
        
        // Apply consecutive limits
        if (is_win) {
            consecutive_wins++;
            consecutive_losses = 0;
            
            if (consecutive_wins > scenario.MaxConsecutiveWins) {
                is_win = false;
                consecutive_wins = 0;
                consecutive_losses = 1;
            }
        } else {
            consecutive_losses++;
            consecutive_wins = 0;
            
            if (consecutive_losses > scenario.MaxConsecutiveLosses) {
                is_win = true;
                consecutive_losses = 0;
                consecutive_wins = 1;
            }
        }
        
        // Generate trade outcome
        double trade_result = GenerateTradeOutcome(scenario, is_win);
        
        // Apply market conditions stress
        trade_result *= conditions.VolatilityMultiplier;
        if (!conditions.IsSessionActive) {
            trade_result *= 0.8; // Reduced performance outside session
        }
        
        // Apply slippage and commission
        if (trade_result > 0) {
            trade_result *= (1.0 - scenario.SlippagePercent / 100.0);
        } else {
            trade_result *= (1.0 + scenario.SlippagePercent / 100.0);
        }
        trade_result -= scenario.CommissionPerTrade;
        
        balance += trade_result;
        
        // Update peak and drawdown
        if (balance > peak_balance) {
            peak_balance = balance;
        } else {
            double current_dd = (peak_balance - balance) / peak_balance;
            if (current_dd > max_drawdown) {
                max_drawdown = current_dd;
            }
        }
        
        // Check for margin call
        if (balance <= starting_balance * 0.1) {
            break; // Stop simulation if severely undercapitalized
        }
    }
    
    return balance - starting_balance;
}

double CMonteCarloSimulator::GenerateTradeOutcome(const STradeScenario& scenario, bool is_win) {
    if (is_win) {
        switch (scenario.WinDistribution) {
            case DIST_NORMAL:
                return GenerateNormal(scenario.AvgWin, scenario.WinStdDev);
            case DIST_LOG_NORMAL:
                return GenerateLogNormal(scenario.AvgWin, scenario.WinStdDev);
            default:
                return GenerateNormal(scenario.AvgWin, scenario.WinStdDev);
        }
    } else {
        switch (scenario.LossDistribution) {
            case DIST_NORMAL:
                return GenerateNormal(scenario.AvgLoss, scenario.LossStdDev);
            case DIST_LOG_NORMAL:
                return -MathAbs(GenerateLogNormal(MathAbs(scenario.AvgLoss), scenario.LossStdDev));
            default:
                return GenerateNormal(scenario.AvgLoss, scenario.LossStdDev);
        }
    }
}

double CMonteCarloSimulator::GenerateNormal(double mean, double std_dev) {
    if (m_HasNormalSpare) {
        m_HasNormalSpare = false;
        return m_NormalSpare * std_dev + mean;
    }
    
    m_HasNormalSpare = true;
    
    double u = (double)MathRand() / 32767.0;
    double v = (double)MathRand() / 32767.0;
    
    double mag = std_dev * MathSqrt(-2.0 * MathLog(u));
    m_NormalSpare = mag * MathCos(2.0 * M_PI * v);
    
    return mag * MathSin(2.0 * M_PI * v) + mean;
}

void CMonteCarloSimulator::CalculateBasicStatistics(SMonteCarloResult& result) {
    // Sort results for percentile calculations
    ArrayCopy(m_SortedResults, m_Results, 0, 0, m_CurrentIteration);
    ArraySort(m_SortedResults, m_CurrentIteration);
    
    // Basic statistics
    double sum = 0.0;
    double sum_squares = 0.0;
    
    for (int i = 0; i < m_CurrentIteration; i++) {
        sum += m_Results[i];
        sum_squares += m_Results[i] * m_Results[i];
    }
    
    result.ExpectedReturn = sum / m_CurrentIteration;
    result.Variance = (sum_squares / m_CurrentIteration) - (result.ExpectedReturn * result.ExpectedReturn);
    result.StandardDeviation = MathSqrt(result.Variance);
    
    // Median
    int median_idx = m_CurrentIteration / 2;
    if (m_CurrentIteration % 2 == 0) {
        result.MedianReturn = (m_SortedResults[median_idx - 1] + m_SortedResults[median_idx]) / 2.0;
    } else {
        result.MedianReturn = m_SortedResults[median_idx];
    }
    
    // Extremes
    result.WorstCaseScenario = m_SortedResults[0];
    result.BestCaseScenario = m_SortedResults[m_CurrentIteration - 1];
    
    // Percentiles
    result.Percentile1 = m_SortedResults[(int)(m_CurrentIteration * 0.01)];
    result.Percentile5 = m_SortedResults[(int)(m_CurrentIteration * 0.05)];
    result.Percentile95 = m_SortedResults[(int)(m_CurrentIteration * 0.95)];
    result.Percentile99 = m_SortedResults[(int)(m_CurrentIteration * 0.99)];
}

void CMonteCarloSimulator::LogSimulationEvent(const string& event, const ENUM_LOG_LEVEL level) {
    if (m_pContext != NULL && m_pContext->pLogger != NULL) {
        switch(level) {
            case LOG_LEVEL_ERROR:
                m_pContext->pLogger->LogError(event, __FUNCTION__);
                break;
            case LOG_LEVEL_WARNING:
                m_pContext->pLogger->LogWarning(event, __FUNCTION__);
                break;
            case LOG_LEVEL_DEBUG:
                m_pContext->pLogger->LogDebug(event, __FUNCTION__);
                break;
            default:
                m_pContext->pLogger->LogInfo(event, __FUNCTION__);
        }
    }
}



#endif // MONTE_CARLO_SIMULATOR_MQH_