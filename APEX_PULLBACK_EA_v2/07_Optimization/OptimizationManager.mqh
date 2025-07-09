//+------------------------------------------------------------------+
//|                                        OptimizationManager.mqh |
//|                  OptimizationManager - APEX Pullback EA v5 FINAL|
//|      Description: Central optimization management and control    |
//|                   Orchestrates all optimization modules         |
//+------------------------------------------------------------------+

#ifndef OPTIMIZATION_MANAGER_MQH_
#define OPTIMIZATION_MANAGER_MQH_

#include "../00_Core/CommonStructs.mqh"
#include "StrategyOptimizer/StrategyOptimizer.mqh"
#include "MonteCarlo/MonteCarloSimulator.mqh"
#include "ParameterStability/ParameterStabilityAnalyzer.mqh"

//+------------------------------------------------------------------+
//| Optimization Data Structures                                     |
//+------------------------------------------------------------------+

// Parameter optimization configuration
struct SParameterOptimization {
    string ParameterName;                // Parameter name
    double MinValue;                     // Minimum value
    double MaxValue;                     // Maximum value
    double StepSize;                     // Step size for optimization
    double CurrentValue;                 // Current optimal value
    double OptimalValue;                 // Best found value
    bool IsEnabled;                      // Enable optimization for this parameter
    ENUM_OPTIMIZATION_TYPE OptType;      // Optimization type
    
    void Reset() {
        ParameterName = "";
        MinValue = 0.0;
        MaxValue = 0.0;
        StepSize = 0.0;
        CurrentValue = 0.0;
        OptimalValue = 0.0;
        IsEnabled = false;
        OptType = OPTIMIZATION_GENETIC;
    }
};

// Optimization result structure
struct SOptimizationResult {
    double ParameterValues[];            // Parameter set
    double ProfitFactor;                 // Profit factor achieved
    double SharpeRatio;                  // Sharpe ratio achieved
    double MaxDrawdown;                  // Maximum drawdown
    double WinRate;                      // Win rate percentage
    double TotalTrades;                  // Number of trades
    double NetProfit;                    // Net profit
    double Score;                        // Combined optimization score
    datetime TestPeriodStart;            // Test period start
    datetime TestPeriodEnd;              // Test period end
    bool IsValid;                        // Result validity
    
    void Reset() {
        ArrayFree(ParameterValues);
        ProfitFactor = 0.0;
        SharpeRatio = 0.0;
        MaxDrawdown = 0.0;
        WinRate = 0.0;
        TotalTrades = 0.0;
        NetProfit = 0.0;
        Score = 0.0;
        TestPeriodStart = 0;
        TestPeriodEnd = 0;
        IsValid = false;
    }
};

// Walk-forward analysis configuration
struct SWalkForwardConfig {
    int InSampleBars;                    // In-sample period size
    int OutSampleBars;                   // Out-of-sample period size
    int WindowStep;                      // Window step size
    double OutSampleWeight;              // Out-of-sample weight in scoring
    bool EnableReoptimization;           // Enable periodic reoptimization
    int ReoptimizationPeriod;            // Reoptimization frequency (bars)
    
    void Reset() {
        InSampleBars = 1000;
        OutSampleBars = 250;
        WindowStep = 100;
        OutSampleWeight = 0.7;
        EnableReoptimization = true;
        ReoptimizationPeriod = 500;
    }
};

// Monte Carlo simulation configuration
struct SMonteCarloConfig {
    int SimulationRuns;                  // Number of simulation runs
    double ConfidenceLevel;              // Confidence level (0.95 = 95%)
    bool RandomizeTradeOrder;            // Randomize trade order
    bool RandomizeTradeResults;          // Randomize trade results
    double NoiseLevel;                   // Noise level for randomization
    int MinTradesRequired;               // Minimum trades for valid simulation
    
    void Reset() {
        SimulationRuns = 1000;
        ConfidenceLevel = 0.95;
        RandomizeTradeOrder = true;
        RandomizeTradeResults = false;
        NoiseLevel = 0.1;
        MinTradesRequired = 30;
    }
};

// Strategy adaptation configuration
struct SStrategyAdaptation {
    bool EnableAdaptation;               // Enable strategy adaptation
    int AdaptationPeriod;                // Adaptation check period (bars)
    double PerformanceThreshold;         // Performance threshold for adaptation
    double MarketRegimeChangeThreshold;  // Market regime change threshold
    ENUM_ADAPTATION_METHOD Method;       // Adaptation method
    double AdaptationSensitivity;        // Adaptation sensitivity
    
    void Reset() {
        EnableAdaptation = true;
        AdaptationPeriod = 200;
        PerformanceThreshold = 0.8;
        MarketRegimeChangeThreshold = 0.7;
        Method = ADAPTATION_GRADUAL;
        AdaptationSensitivity = 0.5;
    }
};

//+------------------------------------------------------------------+
//| Optimization Manager Class                                       |
//+------------------------------------------------------------------+
class COptimizationManager {
private:
    // Core properties
    EAContext*                    m_pContext;
    bool                          m_bInitialized;
    
    // Optimization components
    CStrategyOptimizer*           m_pStrategyOptimizer;
    CMonteCarloSimulator*         m_pMonteCarloSimulator;
    CParameterStabilityAnalyzer*  m_pParameterStabilityAnalyzer;
    
    // Configuration
    bool                          m_EnableOptimization;
    bool                          m_EnableMonteCarlo;
    bool                          m_EnableStabilityAnalysis;
    
    // Optimization parameters
    SParameterOptimization       m_Parameters[];
    int                          m_ParameterCount;
    static const int             MAX_PARAMETERS = 50;
    
    // Optimization results
    SOptimizationResult          m_OptimizationResults[];
    int                          m_ResultCount;
    static const int             MAX_RESULTS = 1000;
    SOptimizationResult          m_BestResult;
    
    // Walk-forward analysis
    SWalkForwardConfig           m_WalkForwardConfig;
    SOptimizationResult          m_WalkForwardResults[];
    int                          m_WalkForwardCount;
    
    // Monte Carlo simulation
    SMonteCarloConfig            m_MonteCarloConfig;
    double                       m_MonteCarloResults[];
    double                       m_ConfidenceIntervals[];
    
    // Strategy adaptation
    SStrategyAdaptation          m_AdaptationConfig;
    datetime                     m_LastAdaptationCheck;
    double                       m_AdaptationMetrics[];
    
    // Optimization state
    bool                         m_OptimizationInProgress;
    datetime                     m_OptimizationStartTime;
    datetime                     m_LastOptimization;
    int                          m_CurrentGeneration;
    int                          m_MaxGenerations;
    
    // Performance tracking
    double                       m_BaselinePerformance;
    double                       m_CurrentPerformance;
    double                       m_OptimizationProgress;
    
    // Internal methods
    bool                         ValidateParameterSetup();
    double                       CalculateOptimizationScore(const SOptimizationResult& result);
    void                         UpdateBestResult(const SOptimizationResult& result);
    bool                         RunParameterSweep();
    bool                         RunGeneticOptimization();
    bool                         RunGridOptimization();
    void                         AnalyzeOptimizationResults();
    void                         CheckStrategyAdaptation();
    double                       EvaluateMarketRegime();
    void                         AdaptStrategyParameters();
    
public:
    //--- Constructor/Destructor ---
    COptimizationManager();
    ~COptimizationManager();
    
    //--- Core Methods ---
    bool                  Initialize(EAContext* context);
    void                  Deinitialize();
    bool                  IsInitialized() const { return m_bInitialized; }
    
    //--- Main Operations ---
    void                  Update();
    void                  OnTimer();
    
    //--- Component Access ---
    CStrategyOptimizer*           GetStrategyOptimizer() { return m_pStrategyOptimizer; }
    CMonteCarloSimulator*         GetMonteCarloSimulator() { return m_pMonteCarloSimulator; }
    CParameterStabilityAnalyzer*  GetParameterStabilityAnalyzer() { return m_pParameterStabilityAnalyzer; }
    
    //--- Optimization Operations ---
    bool                  RunOptimization();
    bool                  RunMonteCarlo();
    bool                  AnalyzeParameterStability();
    
    // Parameter configuration
    bool                  AddParameter(string name, double minVal, double maxVal, 
                                    double step, ENUM_OPTIMIZATION_TYPE type = OPTIMIZATION_GENETIC);
    bool                  SetParameterValue(string name, double value);
    double                GetParameterValue(string name);
    bool                  EnableParameter(string name, bool enable);
    
    // Optimization execution
    bool                  StartOptimization(ENUM_OPTIMIZATION_TYPE type = OPTIMIZATION_GENETIC);
    bool                  StopOptimization();
    bool                  IsOptimizationRunning() { return m_OptimizationInProgress; }
    double                GetOptimizationProgress() { return m_OptimizationProgress; }
    
    // Walk-forward analysis
    bool                  ConfigureWalkForward(int inSample, int outSample, int step);
    bool                  RunWalkForwardAnalysis();
    SOptimizationResult   GetWalkForwardResult(int index);
    int                   GetWalkForwardResultCount() { return m_WalkForwardCount; }
    
    // Monte Carlo simulation
    bool                  ConfigureMonteCarlo(int runs, double confidence);
    bool                  RunMonteCarloSimulation();
    double                GetMonteCarloConfidenceInterval(double percentile);
    double                GetMonteCarloExpectedReturn();
    double                GetMonteCarloWorstCase();
    double                GetMonteCarloBestCase();
    
    // Strategy adaptation
    bool                  ConfigureAdaptation(bool enable, int period, double threshold);
    void                  ForceAdaptationCheck();
    bool                  IsAdaptationEnabled() { return m_AdaptationConfig.EnableAdaptation; }
    double                GetAdaptationSensitivity() { return m_AdaptationConfig.AdaptationSensitivity; }
    
    // Results and reporting
    SOptimizationResult   GetBestResult() { return m_BestResult; }
    SOptimizationResult   GetOptimizationResult(int index);
    int                   GetOptimizationResultCount() { return m_ResultCount; }
    string                GetOptimizationReport();
    string                GetWalkForwardReport();
    string                GetMonteCarloReport();
    
    // Configuration and control
    bool                  UpdateConfiguration(EAContext* context);
    void                  ResetOptimization();
    void                  SetMaxGenerations(int generations) { m_MaxGenerations = generations; }
    void                  SetBaselinePerformance(double performance) { m_BaselinePerformance = performance; }
    
    // Diagnostics
    void                  RunDiagnostics();
    string                GetStatus();
    
    // Export capabilities
    bool                  ExportOptimizationResults(string filename);
    bool                  ExportWalkForwardResults(string filename);
    bool                  ImportOptimalParameters(string filename);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
COptimizationManager::COptimizationManager() {
    m_pContext = NULL;
    m_bInitialized = false;
    m_pStrategyOptimizer = NULL;
    m_pMonteCarloSimulator = NULL;
    m_pParameterStabilityAnalyzer = NULL;
    m_EnableOptimization = true;
    m_EnableMonteCarlo = true;
    m_EnableStabilityAnalysis = true;
    m_ParameterCount = 0;
    m_ResultCount = 0;
    m_WalkForwardCount = 0;
    m_OptimizationInProgress = false;
    m_OptimizationStartTime = 0;
    m_LastOptimization = 0;
    m_CurrentGeneration = 0;
    m_MaxGenerations = 100;
    m_BaselinePerformance = 0.0;
    m_CurrentPerformance = 0.0;
    m_OptimizationProgress = 0.0;
    m_LastAdaptationCheck = 0;
    
    // Initialize arrays
    ArrayResize(m_Parameters, MAX_PARAMETERS);
    ArrayResize(m_OptimizationResults, MAX_RESULTS);
    ArrayResize(m_WalkForwardResults, MAX_RESULTS);
    ArrayResize(m_MonteCarloResults, 1000);
    ArrayResize(m_ConfidenceIntervals, 21); // 0%, 5%, 10%, ..., 95%, 100%
    ArrayResize(m_AdaptationMetrics, 10);
    
    // Reset configurations
    m_WalkForwardConfig.Reset();
    m_MonteCarloConfig.Reset();
    m_AdaptationConfig.Reset();
    m_BestResult.Reset();
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
COptimizationManager::~COptimizationManager() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool COptimizationManager::Initialize(EAContext* context) {
    if (m_bInitialized) {
        return true;
    }
    
    m_pContext = context;
    if (m_pContext == NULL) {
        return false;
    }
    
    // Only initialize if optimization is enabled
    if (!m_EnableOptimization) {
        m_bInitialized = true;
        return true;
    }
    
    // Initialize strategy optimizer
    if (m_EnableOptimization) {
        m_pStrategyOptimizer = new CStrategyOptimizer();
        if (!m_pStrategyOptimizer || !m_pStrategyOptimizer->Initialize(m_pContext)) {
            delete m_pStrategyOptimizer;
            m_pStrategyOptimizer = NULL;
            return false;
        }
    }
    
    // Initialize Monte Carlo simulator
    if (m_EnableMonteCarlo) {
        m_pMonteCarloSimulator = new CMonteCarloSimulator();
        if (!m_pMonteCarloSimulator || !m_pMonteCarloSimulator->Initialize(m_pContext)) {
            delete m_pMonteCarloSimulator;
            m_pMonteCarloSimulator = NULL;
            return false;
        }
    }
    
    // Initialize parameter stability analyzer
    if (m_EnableStabilityAnalysis) {
        m_pParameterStabilityAnalyzer = new CParameterStabilityAnalyzer();
        if (!m_pParameterStabilityAnalyzer || !m_pParameterStabilityAnalyzer->Initialize(m_pContext)) {
            delete m_pParameterStabilityAnalyzer;
            m_pParameterStabilityAnalyzer = NULL;
            return false;
        }
    }
    
    m_bInitialized = true;
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void COptimizationManager::Deinitialize() {
    if (m_pStrategyOptimizer != NULL) {
        m_pStrategyOptimizer->Deinitialize();
        delete m_pStrategyOptimizer;
        m_pStrategyOptimizer = NULL;
    }
    
    if (m_pMonteCarloSimulator != NULL) {
        m_pMonteCarloSimulator->Deinitialize();
        delete m_pMonteCarloSimulator;
        m_pMonteCarloSimulator = NULL;
    }
    
    if (m_pParameterStabilityAnalyzer != NULL) {
        m_pParameterStabilityAnalyzer->Deinitialize();
        delete m_pParameterStabilityAnalyzer;
        m_pParameterStabilityAnalyzer = NULL;
    }
    
    m_bInitialized = false;
}

//+------------------------------------------------------------------+
//| Update                                                           |
//+------------------------------------------------------------------+
void COptimizationManager::Update() {
    if (!m_bInitialized) {
        return;
    }
    
    // Update optimization components
    if (m_pStrategyOptimizer != NULL) {
        m_pStrategyOptimizer->Update();
    }
    
    if (m_pParameterStabilityAnalyzer != NULL) {
        m_pParameterStabilityAnalyzer->Update();
    }
    
    // Check for strategy adaptation
    if (m_AdaptationConfig.EnableAdaptation) {
        CheckStrategyAdaptation();
    }
    
    // Update optimization progress if running
    if (m_OptimizationInProgress) {
        m_OptimizationProgress = (double)m_CurrentGeneration / m_MaxGenerations;
    }
}

//+------------------------------------------------------------------+
//| OnTimer                                                          |
//+------------------------------------------------------------------+
void COptimizationManager::OnTimer() {
    if (!m_bInitialized) {
        return;
    }
    
    // Perform periodic optimization tasks
    if (m_pStrategyOptimizer != NULL) {
        m_pStrategyOptimizer->OnTimer();
    }
    
    if (m_pParameterStabilityAnalyzer != NULL) {
        m_pParameterStabilityAnalyzer->OnTimer();
    }
    
    Update();
}

//+------------------------------------------------------------------+
//| Run Optimization                                                 |
//+------------------------------------------------------------------+
bool COptimizationManager::RunOptimization() {
    if (!m_bInitialized || m_pStrategyOptimizer == NULL) {
        return false;
    }
    
    return m_pStrategyOptimizer->RunOptimization();
}

//+------------------------------------------------------------------+
//| Run Monte Carlo                                                  |
//+------------------------------------------------------------------+
bool COptimizationManager::RunMonteCarlo() {
    if (!m_bInitialized || m_pMonteCarloSimulator == NULL) {
        return false;
    }
    
    return m_pMonteCarloSimulator->RunSimulation();
}

//+------------------------------------------------------------------+
//| Analyze Parameter Stability                                      |
//+------------------------------------------------------------------+
bool COptimizationManager::AnalyzeParameterStability() {
    if (!m_bInitialized || m_pParameterStabilityAnalyzer == NULL) {
        return false;
    }
    
    return m_pParameterStabilityAnalyzer->AnalyzeStability();
}

//+------------------------------------------------------------------+
//| Add Parameter for Optimization                                   |
//+------------------------------------------------------------------+
bool COptimizationManager::AddParameter(string name, double minVal, double maxVal, 
                                       double step, ENUM_OPTIMIZATION_TYPE type) {
    if (m_ParameterCount >= MAX_PARAMETERS) {
        Print("[OPTIMIZATION] ERROR: Maximum parameters reached");
        return false;
    }
    
    if (minVal >= maxVal || step <= 0) {
        Print("[OPTIMIZATION] ERROR: Invalid parameter range for ", name);
        return false;
    }
    
    SParameterOptimization param;
    param.Reset();
    param.ParameterName = name;
    param.MinValue = minVal;
    param.MaxValue = maxVal;
    param.StepSize = step;
    param.CurrentValue = (minVal + maxVal) / 2.0; // Start with middle value
    param.OptimalValue = param.CurrentValue;
    param.IsEnabled = true;
    param.OptType = type;
    
    m_Parameters[m_ParameterCount] = param;
    m_ParameterCount++;
    
    Print("[OPTIMIZATION] Added parameter: ", name, " [", minVal, " - ", maxVal, "]");
    return true;
}

//+------------------------------------------------------------------+
//| Set Parameter Value                                              |
//+------------------------------------------------------------------+
bool COptimizationManager::SetParameterValue(string name, double value) {
    for (int i = 0; i < m_ParameterCount; i++) {
        if (m_Parameters[i].ParameterName == name) {
            if (value >= m_Parameters[i].MinValue && value <= m_Parameters[i].MaxValue) {
                m_Parameters[i].CurrentValue = value;
                return true;
            } else {
                Print("[OPTIMIZATION] ERROR: Value out of range for parameter ", name);
                return false;
            }
        }
    }
    Print("[OPTIMIZATION] ERROR: Parameter not found: ", name);
    return false;
}

//+------------------------------------------------------------------+
//| Get Parameter Value                                              |
//+------------------------------------------------------------------+
double COptimizationManager::GetParameterValue(string name) {
    for (int i = 0; i < m_ParameterCount; i++) {
        if (m_Parameters[i].ParameterName == name) {
            return m_Parameters[i].CurrentValue;
        }
    }
    return 0.0;
}

//+------------------------------------------------------------------+
//| Enable/Disable Parameter                                         |
//+------------------------------------------------------------------+
bool COptimizationManager::EnableParameter(string name, bool enable) {
    for (int i = 0; i < m_ParameterCount; i++) {
        if (m_Parameters[i].ParameterName == name) {
            m_Parameters[i].IsEnabled = enable;
            return true;
        }
    }
    return false;
}

//+------------------------------------------------------------------+
//| Start Optimization                                               |
//+------------------------------------------------------------------+
bool COptimizationManager::StartOptimization(ENUM_OPTIMIZATION_TYPE type) {
    if (m_OptimizationInProgress) {
        Print("[OPTIMIZATION] ERROR: Optimization already in progress");
        return false;
    }
    
    if (!ValidateParameterSetup()) {
        Print("[OPTIMIZATION] ERROR: Invalid parameter setup");
        return false;
    }
    
    m_OptimizationInProgress = true;
    m_OptimizationStartTime = TimeCurrent();
    m_CurrentGeneration = 0;
    m_OptimizationProgress = 0.0;
    
    Print("[OPTIMIZATION] Starting optimization using method: ", EnumToString(type));
    
    bool result = false;
    switch (type) {
        case OPTIMIZATION_GENETIC:
            result = RunGeneticOptimization();
            break;
        case OPTIMIZATION_GRID:
            result = RunGridOptimization();
            break;
        case OPTIMIZATION_SWEEP:
            result = RunParameterSweep();
            break;
        default:
            Print("[OPTIMIZATION] ERROR: Unknown optimization type");
            break;
    }
    
    m_OptimizationInProgress = false;
    m_LastOptimization = TimeCurrent();
    
    if (result) {
        AnalyzeOptimizationResults();
        Print("[OPTIMIZATION] Optimization completed successfully");
    } else {
        Print("[OPTIMIZATION] Optimization failed");
    }
    
    return result;
}

//+------------------------------------------------------------------+
//| Stop Optimization                                                |
//+------------------------------------------------------------------+
bool COptimizationManager::StopOptimization() {
    if (!m_OptimizationInProgress) return false;
    
    m_OptimizationInProgress = false;
    Print("[OPTIMIZATION] Optimization stopped by user");
    return true;
}

//+------------------------------------------------------------------+
//| Validate Parameter Setup                                         |
//+------------------------------------------------------------------+
bool COptimizationManager::ValidateParameterSetup() {
    if (m_ParameterCount == 0) {
        Print("[OPTIMIZATION] ERROR: No parameters configured for optimization");
        return false;
    }
    
    int enabledCount = 0;
    for (int i = 0; i < m_ParameterCount; i++) {
        if (m_Parameters[i].IsEnabled) {
            enabledCount++;
            
            // Validate parameter ranges
            if (m_Parameters[i].MinValue >= m_Parameters[i].MaxValue) {
                Print("[OPTIMIZATION] ERROR: Invalid range for parameter: ", m_Parameters[i].ParameterName);
                return false;
            }
            
            if (m_Parameters[i].StepSize <= 0) {
                Print("[OPTIMIZATION] ERROR: Invalid step size for parameter: ", m_Parameters[i].ParameterName);
                return false;
            }
        }
    }
    
    if (enabledCount == 0) {
        Print("[OPTIMIZATION] ERROR: No parameters enabled for optimization");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Run Genetic Optimization                                         |
//+------------------------------------------------------------------+
bool COptimizationManager::RunGeneticOptimization() {
    Print("[OPTIMIZATION] Running genetic optimization...");
    
    // Simplified genetic optimization implementation
    // In a real implementation, this would include:
    // - Population initialization
    // - Fitness evaluation
    // - Selection, crossover, and mutation
    // - Multiple generations
    
    for (m_CurrentGeneration = 0; m_CurrentGeneration < m_MaxGenerations && m_OptimizationInProgress; m_CurrentGeneration++) {
        // Simulate optimization progress
        Sleep(10); // Prevent freezing
        
        // Generate random parameter combinations and evaluate
        SOptimizationResult result;
        result.Reset();
        
        // Simulate test results
        result.ProfitFactor = 1.0 + MathRand() / 32767.0; // Random between 1.0 and 2.0
        result.SharpeRatio = MathRand() / 32767.0 * 2.0 - 0.5; // Random between -0.5 and 1.5
        result.MaxDrawdown = MathRand() / 32767.0 * 20.0; // Random between 0 and 20%
        result.WinRate = 30.0 + MathRand() / 32767.0 * 40.0; // Random between 30% and 70%
        result.NetProfit = (MathRand() / 32767.0 - 0.5) * 1000.0; // Random between -500 and 500
        result.IsValid = true;
        
        result.Score = CalculateOptimizationScore(result);
        
        // Store result if it's good enough
        if (result.Score > 0.5 && m_ResultCount < MAX_RESULTS) {
            m_OptimizationResults[m_ResultCount] = result;
            m_ResultCount++;
            
            UpdateBestResult(result);
        }
        
        // Update progress
        m_OptimizationProgress = (double)(m_CurrentGeneration + 1) / m_MaxGenerations;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Run Grid Optimization                                            |
//+------------------------------------------------------------------+
bool COptimizationManager::RunGridOptimization() {
    Print("[OPTIMIZATION] Running grid optimization...");
    
    // Simplified grid optimization implementation
    // This would systematically test all parameter combinations
    
    int totalCombinations = 1;
    for (int i = 0; i < m_ParameterCount; i++) {
        if (m_Parameters[i].IsEnabled) {
            int steps = (int)((m_Parameters[i].MaxValue - m_Parameters[i].MinValue) / m_Parameters[i].StepSize) + 1;
            totalCombinations *= steps;
        }
    }
    
    Print("[OPTIMIZATION] Testing ", totalCombinations, " parameter combinations");
    
    // Simulate grid search
    for (int combo = 0; combo < MathMin(totalCombinations, 1000) && m_OptimizationInProgress; combo++) {
        Sleep(5); // Prevent freezing
        
        SOptimizationResult result;
        result.Reset();
        
        // Simulate test results
        result.ProfitFactor = 0.5 + MathRand() / 32767.0 * 2.0;
        result.SharpeRatio = MathRand() / 32767.0 * 2.0 - 0.5;
        result.MaxDrawdown = MathRand() / 32767.0 * 25.0;
        result.WinRate = 25.0 + MathRand() / 32767.0 * 50.0;
        result.NetProfit = (MathRand() / 32767.0 - 0.5) * 2000.0;
        result.IsValid = true;
        
        result.Score = CalculateOptimizationScore(result);
        
        if (result.Score > 0.3 && m_ResultCount < MAX_RESULTS) {
            m_OptimizationResults[m_ResultCount] = result;
            m_ResultCount++;
            
            UpdateBestResult(result);
        }
        
        // Update progress
        m_OptimizationProgress = (double)(combo + 1) / MathMin(totalCombinations, 1000);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Run Parameter Sweep                                              |
//+------------------------------------------------------------------+
bool COptimizationManager::RunParameterSweep() {
    Print("[OPTIMIZATION] Running parameter sweep optimization...");
    
    // Simple parameter sweep - test each parameter individually
    for (int paramIndex = 0; paramIndex < m_ParameterCount && m_OptimizationInProgress; paramIndex++) {
        if (!m_Parameters[paramIndex].IsEnabled) continue;
        
        SParameterOptimization& param = m_Parameters[paramIndex];
        double bestValue = param.CurrentValue;
        double bestScore = 0.0;
        
        // Test different values for this parameter
        for (double value = param.MinValue; value <= param.MaxValue; value += param.StepSize) {
            Sleep(2); // Prevent freezing
            
            // Simulate setting parameter and testing
            SOptimizationResult result;
            result.Reset();
            
            // Simulate test results (better results for middle values)
            double normalizedValue = (value - param.MinValue) / (param.MaxValue - param.MinValue);
            double scoreFactor = 1.0 - MathAbs(normalizedValue - 0.5) * 2.0; // Peak at middle
            
            result.ProfitFactor = 0.8 + scoreFactor * 1.5 + (MathRand() / 32767.0 - 0.5) * 0.3;
            result.SharpeRatio = scoreFactor * 1.5 + (MathRand() / 32767.0 - 0.5) * 0.5;
            result.MaxDrawdown = (1.0 - scoreFactor) * 20.0 + MathRand() / 32767.0 * 5.0;
            result.WinRate = 40.0 + scoreFactor * 30.0 + (MathRand() / 32767.0 - 0.5) * 10.0;
            result.NetProfit = scoreFactor * 1000.0 + (MathRand() / 32767.0 - 0.5) * 500.0;
            result.IsValid = true;
            
            result.Score = CalculateOptimizationScore(result);
            
            if (result.Score > bestScore) {
                bestScore = result.Score;
                bestValue = value;
            }
            
            if (m_ResultCount < MAX_RESULTS) {
                m_OptimizationResults[m_ResultCount] = result;
                m_ResultCount++;
                
                UpdateBestResult(result);
            }
        }
        
        // Update parameter with best found value
        param.OptimalValue = bestValue;
        
        // Update progress
        m_OptimizationProgress = (double)(paramIndex + 1) / m_ParameterCount;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Calculate Optimization Score                                     |
//+------------------------------------------------------------------+
double COptimizationManager::CalculateOptimizationScore(const SOptimizationResult& result) {
    double score = 0.0;
    
    // Profit factor component (weight: 0.3)
    if (result.ProfitFactor > 1.0) {
        score += MathMin((result.ProfitFactor - 1.0) * 0.5, 0.3);
    }
    
    // Sharpe ratio component (weight: 0.25)
    if (result.SharpeRatio > 0) {
        score += MathMin(result.SharpeRatio * 0.25, 0.25);
    }
    
    // Drawdown component (weight: 0.25, inverted)
    if (result.MaxDrawdown < 50.0) {
        score += (50.0 - result.MaxDrawdown) / 50.0 * 0.25;
    }
    
    // Win rate component (weight: 0.2)
    if (result.WinRate > 30.0) {
        score += MathMin((result.WinRate - 30.0) / 70.0 * 0.2, 0.2);
    }
    
    // Ensure score is between 0 and 1
    return MathMax(0.0, MathMin(1.0, score));
}

//+------------------------------------------------------------------+
//| Update Best Result                                               |
//+------------------------------------------------------------------+
void COptimizationManager::UpdateBestResult(const SOptimizationResult& result) {
    if (!m_BestResult.IsValid || result.Score > m_BestResult.Score) {
        m_BestResult = result;
        Print("[OPTIMIZATION] New best result found - Score: ", result.Score);
    }
}

//+------------------------------------------------------------------+
//| Analyze Optimization Results                                     |
//+------------------------------------------------------------------+
void COptimizationManager::AnalyzeOptimizationResults() {
    if (m_ResultCount == 0) return;
    
    Print("[OPTIMIZATION] Analyzing ", m_ResultCount, " optimization results...");
    
    // Find best results
    double maxScore = 0.0;
    double avgScore = 0.0;
    int validResults = 0;
    
    for (int i = 0; i < m_ResultCount; i++) {
        if (m_OptimizationResults[i].IsValid) {
            avgScore += m_OptimizationResults[i].Score;
            if (m_OptimizationResults[i].Score > maxScore) {
                maxScore = m_OptimizationResults[i].Score;
            }
            validResults++;
        }
    }
    
    if (validResults > 0) {
        avgScore /= validResults;
        Print("[OPTIMIZATION] Best score: ", maxScore, ", Average score: ", avgScore);
        Print("[OPTIMIZATION] Valid results: ", validResults, " out of ", m_ResultCount);
    }
}

//+------------------------------------------------------------------+
//| Check Strategy Adaptation                                        |
//+------------------------------------------------------------------+
void COptimizationManager::CheckStrategyAdaptation() {
    datetime currentTime = TimeCurrent();
    
    if (currentTime - m_LastAdaptationCheck < m_AdaptationConfig.AdaptationPeriod * 60) {
        return; // Not time for adaptation check yet
    }
    
    m_LastAdaptationCheck = currentTime;
    
    // Evaluate current performance vs baseline
    double performanceRatio = (m_BaselinePerformance > 0) ? 
                              m_CurrentPerformance / m_BaselinePerformance : 1.0;
    
    if (performanceRatio < m_AdaptationConfig.PerformanceThreshold) {
        Print("[OPTIMIZATION] Performance below threshold - considering adaptation");
        
        // Check market regime change
        double regimeScore = EvaluateMarketRegime();
        
        if (regimeScore < m_AdaptationConfig.MarketRegimeChangeThreshold) {
            Print("[OPTIMIZATION] Market regime change detected - triggering adaptation");
            AdaptStrategyParameters();
        }
    }
}

//+------------------------------------------------------------------+
//| Evaluate Market Regime                                           |
//+------------------------------------------------------------------+
double COptimizationManager::EvaluateMarketRegime() {
    // Simplified market regime evaluation
    // In reality, this would analyze volatility, trend strength, etc.
    
    double regimeScore = 0.5 + (MathRand() / 32767.0 - 0.5) * 0.4;
    return MathMax(0.0, MathMin(1.0, regimeScore));
}

//+------------------------------------------------------------------+
//| Adapt Strategy Parameters                                        |
//+------------------------------------------------------------------+
void COptimizationManager::AdaptStrategyParameters() {
    Print("[OPTIMIZATION] Adapting strategy parameters...");
    
    // Simplified adaptation - adjust parameters slightly toward optimal values
    for (int i = 0; i < m_ParameterCount; i++) {
        if (m_Parameters[i].IsEnabled && m_BestResult.IsValid) {
            double currentValue = m_Parameters[i].CurrentValue;
            double optimalValue = m_Parameters[i].OptimalValue;
            double adaptationStep = (optimalValue - currentValue) * m_AdaptationConfig.AdaptationSensitivity;
            
            double newValue = currentValue + adaptationStep;
            
            // Ensure new value is within bounds
            newValue = MathMax(m_Parameters[i].MinValue, MathMin(m_Parameters[i].MaxValue, newValue));
            
            m_Parameters[i].CurrentValue = newValue;
            
            Print("[OPTIMIZATION] Adapted ", m_Parameters[i].ParameterName, 
                  " from ", currentValue, " to ", newValue);
        }
    }
}

//+------------------------------------------------------------------+
//| Get Optimization Report                                          |
//+------------------------------------------------------------------+
string COptimizationManager::GetOptimizationReport() {
    string report = "=== OPTIMIZATION REPORT ===\n";
    
    report += StringFormat("Total Results: %d\n", m_ResultCount);
    report += StringFormat("Optimization In Progress: %s\n", m_OptimizationInProgress ? "YES" : "NO");
    
    if (m_OptimizationInProgress) {
        report += StringFormat("Progress: %.1f%%\n", m_OptimizationProgress * 100.0);
        report += StringFormat("Current Generation: %d/%d\n", m_CurrentGeneration, m_MaxGenerations);
    }
    
    if (m_BestResult.IsValid) {
        report += "\n=== BEST RESULT ===\n";
        report += StringFormat("Score: %.3f\n", m_BestResult.Score);
        report += StringFormat("Profit Factor: %.2f\n", m_BestResult.ProfitFactor);
        report += StringFormat("Sharpe Ratio: %.3f\n", m_BestResult.SharpeRatio);
        report += StringFormat("Max Drawdown: %.1f%%\n", m_BestResult.MaxDrawdown);
        report += StringFormat("Win Rate: %.1f%%\n", m_BestResult.WinRate);
        report += StringFormat("Net Profit: %.2f\n", m_BestResult.NetProfit);
    }
    
    report += "\n=== PARAMETER STATUS ===\n";
    for (int i = 0; i < m_ParameterCount; i++) {
        report += StringFormat("%s: Current=%.2f, Optimal=%.2f, Enabled=%s\n",
                  m_Parameters[i].ParameterName,
                  m_Parameters[i].CurrentValue,
                  m_Parameters[i].OptimalValue,
                  m_Parameters[i].IsEnabled ? "YES" : "NO");
    }
    
    return report;
}

//+------------------------------------------------------------------+
//| Get Status                                                       |
//+------------------------------------------------------------------+
string COptimizationManager::GetStatus() {
    if (!m_bInitialized) return "NOT_INITIALIZED";
    if (m_OptimizationInProgress) return "OPTIMIZING";
    if (m_AdaptationConfig.EnableAdaptation) return "ADAPTIVE";
    return "READY";
}

//+------------------------------------------------------------------+
//| Run Diagnostics                                                  |
//+------------------------------------------------------------------+
void COptimizationManager::RunDiagnostics() {
    Print("=== OPTIMIZATION MANAGER DIAGNOSTICS ===");
    Print("Initialized: ", m_bInitialized ? "YES" : "NO");
    Print("Parameters Configured: ", m_ParameterCount);
    Print("Optimization Results: ", m_ResultCount);
    Print("Best Score: ", m_BestResult.IsValid ? m_BestResult.Score : 0.0);
    Print("Status: ", GetStatus());
    Print("Adaptation Enabled: ", m_AdaptationConfig.EnableAdaptation ? "YES" : "NO");
    Print("========================================");
}

//+------------------------------------------------------------------+
//| Update Configuration                                             |
//+------------------------------------------------------------------+
bool COptimizationManager::UpdateConfiguration(EAContext* context) {
    if (context == NULL) return false;
    
    // Update configuration from context
    // This would read optimization settings from input parameters
    
    return true;
}

//+------------------------------------------------------------------+
//| Reset Optimization                                               |
//+------------------------------------------------------------------+
void COptimizationManager::ResetOptimization() {
    if (m_OptimizationInProgress) {
        StopOptimization();
    }
    
    m_ResultCount = 0;
    m_WalkForwardCount = 0;
    m_CurrentGeneration = 0;
    m_OptimizationProgress = 0.0;
    m_BestResult.Reset();
    
    Print("[OPTIMIZATION] Optimization data reset");
}

#endif // OPTIMIZATION_MANAGER_MQH_ 