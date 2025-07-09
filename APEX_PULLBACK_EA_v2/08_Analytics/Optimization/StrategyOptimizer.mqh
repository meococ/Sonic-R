//+------------------------------------------------------------------+
//|                                            StrategyOptimizer.mqh |
//|                                    APEX Pullback EA v5.0 FINAL   |
//|                                      Advanced Strategy Optimizer |
//+------------------------------------------------------------------+
#property copyright "APEX Trading Systems"
#property version   "5.00"
#property strict

#include "../../00_Core/CommonStructs.mqh"

//+------------------------------------------------------------------+
//| Optimization methods enumeration                                |
//+------------------------------------------------------------------+
enum ENUM_OPTIMIZATION_METHOD {
    OPT_METHOD_GENETIC_ALGORITHM,
    OPT_METHOD_PARTICLE_SWARM,
    OPT_METHOD_SIMULATED_ANNEALING,
    OPT_METHOD_GRID_SEARCH,
    OPT_METHOD_RANDOM_SEARCH,
    OPT_METHOD_BAYESIAN
};

//+------------------------------------------------------------------+
//| Optimization objectives                                         |
//+------------------------------------------------------------------+
enum ENUM_OPTIMIZATION_OBJECTIVE {
    OPT_OBJECTIVE_PROFIT,
    OPT_OBJECTIVE_SHARPE_RATIO,
    OPT_OBJECTIVE_SORTINO_RATIO,
    OPT_OBJECTIVE_CALMAR_RATIO,
    OPT_OBJECTIVE_MAX_DRAWDOWN,
    OPT_OBJECTIVE_WIN_RATE,
    OPT_OBJECTIVE_PROFIT_FACTOR,
    OPT_OBJECTIVE_CUSTOM
};

//+------------------------------------------------------------------+
//| Parameter types for optimization                               |
//+------------------------------------------------------------------+
enum ENUM_PARAMETER_TYPE {
    PARAM_TYPE_INTEGER,
    PARAM_TYPE_DOUBLE,
    PARAM_TYPE_BOOLEAN,
    PARAM_TYPE_ENUM
};

//+------------------------------------------------------------------+
//| Optimization parameter structure                               |
//+------------------------------------------------------------------+
struct SOptimizationParameter {
    string Name;
    ENUM_PARAMETER_TYPE Type;
    double MinValue;
    double MaxValue;
    double Step;
    double CurrentValue;
    double BestValue;
    bool IsActive;
    int Priority; // 1-10, higher = more important
};

//+------------------------------------------------------------------+
//| Optimization result structure                                  |
//+------------------------------------------------------------------+
struct SOptimizationResult {
    double ObjectiveValue;
    double Profit;
    double MaxDrawdown;
    double SharpeRatio;
    double SortinoRatio;
    double CalmarRatio;
    double WinRate;
    double ProfitFactor;
    int TotalTrades;
    datetime StartTime;
    datetime EndTime;
    SOptimizationParameter Parameters[];
    bool IsValid;
};

//+------------------------------------------------------------------+
//| Optimization configuration                                      |
//+------------------------------------------------------------------+
struct SOptimizationConfig {
    ENUM_OPTIMIZATION_METHOD Method;
    ENUM_OPTIMIZATION_OBJECTIVE Objective;
    int MaxIterations;
    int PopulationSize;
    double ConvergenceThreshold;
    int MaxStagnantIterations;
    bool UseParallelProcessing;
    bool SaveIntermediateResults;
    string ResultsPath;
    datetime OptimizationPeriodStart;
    datetime OptimizationPeriodEnd;
    datetime ValidationPeriodStart;
    datetime ValidationPeriodEnd;
};

//+------------------------------------------------------------------+
//| Genetic Algorithm specific parameters                          |
//+------------------------------------------------------------------+
struct SGeneticAlgorithmParams {
    double MutationRate;
    double CrossoverRate;
    double ElitismRate;
    int TournamentSize;
    bool UseAdaptiveMutation;
};

//+------------------------------------------------------------------+
//| Particle Swarm specific parameters                             |
//+------------------------------------------------------------------+
struct SParticleSwarmParams {
    double InertiaWeight;
    double CognitiveWeight;
    double SocialWeight;
    double MaxVelocity;
    bool UseAdaptiveWeights;
};

//+------------------------------------------------------------------+
//| Optimization statistics                                        |
//+------------------------------------------------------------------+
struct SOptimizationStats {
    int TotalIterations;
    int ValidResults;
    int InvalidResults;
    double BestObjectiveValue;
    double WorstObjectiveValue;
    double AverageObjectiveValue;
    int StagnantIterations;
    datetime StartTime;
    datetime EndTime;
    double ElapsedSeconds;
    bool IsCompleted;
    bool WasTerminated;
};

//+------------------------------------------------------------------+
//| Strategy Optimizer Class                                       |
//+------------------------------------------------------------------+
class CStrategyOptimizer {
private:
    EAContext* m_pContext;
    SOptimizationConfig m_Config;
    SGeneticAlgorithmParams m_GAParams;
    SParticleSwarmParams m_PSParams;
    SOptimizationStats m_Stats;
    
    // Optimization data
    SOptimizationParameter m_Parameters[];
    SOptimizationResult m_Results[];
    SOptimizationResult m_BestResult;
    SOptimizationResult m_CurrentResult;
    
    // Population for evolutionary algorithms
    SOptimizationResult m_Population[];
    double m_Velocities[][]; // For PSO
    
    // Status
    bool m_bInitialized;
    bool m_bRunning;
    bool m_bTerminated;
    
    // Progress tracking
    int m_CurrentIteration;
    double m_LastBestValue;
    int m_StagnantCount;
    
public:
    CStrategyOptimizer();
    ~CStrategyOptimizer();
    
    // Core methods
    bool Initialize(EAContext* context);
    void Deinitialize();
    
    // Configuration
    void SetConfiguration(const SOptimizationConfig& config);
    SOptimizationConfig GetConfiguration() const { return m_Config; }
    void SetGeneticAlgorithmParams(const SGeneticAlgorithmParams& params);
    void SetParticleSwarmParams(const SParticleSwarmParams& params);
    
    // Parameter management
    bool AddParameter(const string name, const ENUM_PARAMETER_TYPE type,
                     const double minValue, const double maxValue, const double step,
                     const int priority = 5);
    bool RemoveParameter(const string name);
    void ClearParameters();
    int GetParameterCount() const { return ArraySize(m_Parameters); }
    SOptimizationParameter GetParameter(const int index) const;
    bool SetParameterValue(const string name, const double value);
    double GetParameterValue(const string name) const;
    
    // Optimization execution
    bool StartOptimization();
    void StopOptimization();
    bool IsRunning() const { return m_bRunning; }
    void UpdateOptimization();
    
    // Results
    SOptimizationResult GetBestResult() const { return m_BestResult; }
    SOptimizationResult GetCurrentResult() const { return m_CurrentResult; }
    int GetResultCount() const { return ArraySize(m_Results); }
    SOptimizationResult GetResult(const int index) const;
    SOptimizationStats GetStatistics() const { return m_Stats; }
    
    // Validation
    bool ValidateResult(const SOptimizationResult& result);
    double CalculateObjectiveValue(const SOptimizationResult& result);
    
    // Reporting
    string GetOptimizationReport() const;
    bool SaveResults(const string filename) const;
    bool LoadResults(const string filename);
    
private:
    // Optimization algorithms
    void RunGeneticAlgorithm();
    void RunParticleSwarm();
    void RunSimulatedAnnealing();
    void RunGridSearch();
    void RunRandomSearch();
    void RunBayesianOptimization();
    
    // Genetic Algorithm methods
    void InitializePopulation();
    void EvaluatePopulation();
    void SelectParents(int& parent1, int& parent2);
    SOptimizationResult Crossover(const SOptimizationResult& parent1, const SOptimizationResult& parent2);
    void Mutate(SOptimizationResult& individual);
    void ReplacePopulation();
    
    // Particle Swarm methods
    void InitializeSwarm();
    void UpdateVelocities();
    void UpdatePositions();
    void UpdateBestPositions();
    
    // Utility methods
    SOptimizationResult CreateRandomSolution();
    SOptimizationResult EvaluateSolution(const SOptimizationParameter& params[]);
    bool ApplyParameters(const SOptimizationParameter& params[]);
    void CopyParameters(const SOptimizationParameter& source[], SOptimizationParameter& dest[]);
    double GenerateRandomValue(const double min, const double max);
    int GenerateRandomInt(const int min, const int max);
    
    // Convergence checking
    bool CheckConvergence();
    void UpdateProgress();
    
    // Logging
    void LogOptimizationEvent(const string event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CStrategyOptimizer::CStrategyOptimizer() {
    m_pContext = NULL;
    m_bInitialized = false;
    m_bRunning = false;
    m_bTerminated = false;
    m_CurrentIteration = 0;
    m_LastBestValue = 0.0;
    m_StagnantCount = 0;
    
    // Initialize configuration with defaults
    ZeroMemory(m_Config);
    m_Config.Method = OPT_METHOD_GENETIC_ALGORITHM;
    m_Config.Objective = OPT_OBJECTIVE_SHARPE_RATIO;
    m_Config.MaxIterations = 1000;
    m_Config.PopulationSize = 50;
    m_Config.ConvergenceThreshold = 0.001;
    m_Config.MaxStagnantIterations = 100;
    m_Config.UseParallelProcessing = false;
    m_Config.SaveIntermediateResults = true;
    m_Config.ResultsPath = "Optimization_Results";
    
    // Initialize GA parameters
    ZeroMemory(m_GAParams);
    m_GAParams.MutationRate = 0.1;
    m_GAParams.CrossoverRate = 0.8;
    m_GAParams.ElitismRate = 0.1;
    m_GAParams.TournamentSize = 3;
    m_GAParams.UseAdaptiveMutation = true;
    
    // Initialize PSO parameters
    ZeroMemory(m_PSParams);
    m_PSParams.InertiaWeight = 0.9;
    m_PSParams.CognitiveWeight = 2.0;
    m_PSParams.SocialWeight = 2.0;
    m_PSParams.MaxVelocity = 0.1;
    m_PSParams.UseAdaptiveWeights = true;
    
    // Initialize statistics
    ZeroMemory(m_Stats);
    ZeroMemory(m_BestResult);
    ZeroMemory(m_CurrentResult);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CStrategyOptimizer::~CStrategyOptimizer() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize optimizer                                            |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::Initialize(EAContext* context) {
    if (context == NULL) {
        Print("[STRATEGY OPTIMIZER ERROR] Context is NULL");
        return false;
    }
    
    m_pContext = context;
    m_bInitialized = true;
    
    LogOptimizationEvent("Strategy Optimizer initialized successfully");
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize optimizer                                         |
//+------------------------------------------------------------------+
void CStrategyOptimizer::Deinitialize() {
    if (m_bRunning) {
        StopOptimization();
    }
    
    if (m_bInitialized) {
        LogOptimizationEvent("Strategy Optimizer deinitialized");
    }
    
    m_bInitialized = false;
    m_pContext = NULL;
}

//+------------------------------------------------------------------+
//| Set optimization configuration                                 |
//+------------------------------------------------------------------+
void CStrategyOptimizer::SetConfiguration(const SOptimizationConfig& config) {
    m_Config = config;
    LogOptimizationEvent("Optimization configuration updated");
}

//+------------------------------------------------------------------+
//| Set genetic algorithm parameters                               |
//+------------------------------------------------------------------+
void CStrategyOptimizer::SetGeneticAlgorithmParams(const SGeneticAlgorithmParams& params) {
    m_GAParams = params;
    LogOptimizationEvent("Genetic Algorithm parameters updated");
}

//+------------------------------------------------------------------+
//| Set particle swarm parameters                                  |
//+------------------------------------------------------------------+
void CStrategyOptimizer::SetParticleSwarmParams(const SParticleSwarmParams& params) {
    m_PSParams = params;
    LogOptimizationEvent("Particle Swarm parameters updated");
}

//+------------------------------------------------------------------+
//| Add optimization parameter                                     |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::AddParameter(const string name, const ENUM_PARAMETER_TYPE type,
                                     const double minValue, const double maxValue, const double step,
                                     const int priority = 5) {
    if (name == "") {
        LogOptimizationEvent("Cannot add parameter with empty name", LOG_LEVEL_ERROR);
        return false;
    }
    
    if (minValue >= maxValue) {
        LogOptimizationEvent("Invalid parameter range: " + name, LOG_LEVEL_ERROR);
        return false;
    }
    
    // Check if parameter already exists
    for (int i = 0; i < ArraySize(m_Parameters); i++) {
        if (m_Parameters[i].Name == name) {
            LogOptimizationEvent("Parameter already exists: " + name, LOG_LEVEL_WARNING);
            return false;
        }
    }
    
    // Add new parameter
    int size = ArraySize(m_Parameters);
    ArrayResize(m_Parameters, size + 1);
    
    m_Parameters[size].Name = name;
    m_Parameters[size].Type = type;
    m_Parameters[size].MinValue = minValue;
    m_Parameters[size].MaxValue = maxValue;
    m_Parameters[size].Step = step;
    m_Parameters[size].CurrentValue = minValue;
    m_Parameters[size].BestValue = minValue;
    m_Parameters[size].IsActive = true;
    m_Parameters[size].Priority = MathMax(1, MathMin(10, priority));
    
    LogOptimizationEvent("Parameter added: " + name);
    
    return true;
}

//+------------------------------------------------------------------+
//| Remove optimization parameter                                  |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::RemoveParameter(const string name) {
    for (int i = 0; i < ArraySize(m_Parameters); i++) {
        if (m_Parameters[i].Name == name) {
            // Shift remaining parameters
            for (int j = i; j < ArraySize(m_Parameters) - 1; j++) {
                m_Parameters[j] = m_Parameters[j + 1];
            }
            ArrayResize(m_Parameters, ArraySize(m_Parameters) - 1);
            
            LogOptimizationEvent("Parameter removed: " + name);
            return true;
        }
    }
    
    LogOptimizationEvent("Parameter not found: " + name, LOG_LEVEL_WARNING);
    return false;
}

//+------------------------------------------------------------------+
//| Clear all parameters                                           |
//+------------------------------------------------------------------+
void CStrategyOptimizer::ClearParameters() {
    ArrayResize(m_Parameters, 0);
    LogOptimizationEvent("All parameters cleared");
}

//+------------------------------------------------------------------+
//| Get parameter by index                                         |
//+------------------------------------------------------------------+
SOptimizationParameter CStrategyOptimizer::GetParameter(const int index) const {
    SOptimizationParameter empty;
    ZeroMemory(empty);
    
    if (index < 0 || index >= ArraySize(m_Parameters)) {
        return empty;
    }
    
    return m_Parameters[index];
}

//+------------------------------------------------------------------+
//| Set parameter value                                            |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::SetParameterValue(const string name, const double value) {
    for (int i = 0; i < ArraySize(m_Parameters); i++) {
        if (m_Parameters[i].Name == name) {
            if (value >= m_Parameters[i].MinValue && value <= m_Parameters[i].MaxValue) {
                m_Parameters[i].CurrentValue = value;
                return true;
            } else {
                LogOptimizationEvent("Parameter value out of range: " + name, LOG_LEVEL_WARNING);
                return false;
            }
        }
    }
    
    LogOptimizationEvent("Parameter not found: " + name, LOG_LEVEL_WARNING);
    return false;
}

//+------------------------------------------------------------------+
//| Get parameter value                                            |
//+------------------------------------------------------------------+
double CStrategyOptimizer::GetParameterValue(const string name) const {
    for (int i = 0; i < ArraySize(m_Parameters); i++) {
        if (m_Parameters[i].Name == name) {
            return m_Parameters[i].CurrentValue;
        }
    }
    
    return 0.0;
}

//+------------------------------------------------------------------+
//| Start optimization                                             |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::StartOptimization() {
    if (!m_bInitialized) {
        LogOptimizationEvent("Optimizer not initialized", LOG_LEVEL_ERROR);
        return false;
    }
    
    if (m_bRunning) {
        LogOptimizationEvent("Optimization already running", LOG_LEVEL_WARNING);
        return false;
    }
    
    if (ArraySize(m_Parameters) == 0) {
        LogOptimizationEvent("No parameters defined for optimization", LOG_LEVEL_ERROR);
        return false;
    }
    
    // Initialize optimization
    m_bRunning = true;
    m_bTerminated = false;
    m_CurrentIteration = 0;
    m_StagnantCount = 0;
    m_LastBestValue = 0.0;
    
    // Initialize statistics
    ZeroMemory(m_Stats);
    m_Stats.StartTime = TimeCurrent();
    
    // Clear previous results
    ArrayResize(m_Results, 0);
    ZeroMemory(m_BestResult);
    
    LogOptimizationEvent("Optimization started using " + EnumToString(m_Config.Method));
    
    // Run optimization based on selected method
    switch(m_Config.Method) {
    case OPT_METHOD_GENETIC_ALGORITHM:
        RunGeneticAlgorithm();
        break;
    case OPT_METHOD_PARTICLE_SWARM:
        RunParticleSwarm();
        break;
    case OPT_METHOD_SIMULATED_ANNEALING:
        RunSimulatedAnnealing();
        break;
    case OPT_METHOD_GRID_SEARCH:
        RunGridSearch();
        break;
    case OPT_METHOD_RANDOM_SEARCH:
        RunRandomSearch();
        break;
    case OPT_METHOD_BAYESIAN:
        RunBayesianOptimization();
        break;
    default:
        LogOptimizationEvent("Unknown optimization method", LOG_LEVEL_ERROR);
        m_bRunning = false;
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Stop optimization                                              |
//+------------------------------------------------------------------+
void CStrategyOptimizer::StopOptimization() {
    if (m_bRunning) {
        m_bTerminated = true;
        m_bRunning = false;
        
        m_Stats.EndTime = TimeCurrent();
        m_Stats.ElapsedSeconds = (double)(m_Stats.EndTime - m_Stats.StartTime);
        m_Stats.WasTerminated = true;
        
        LogOptimizationEvent("Optimization stopped by user", LOG_LEVEL_WARNING);
    }
}

//+------------------------------------------------------------------+
//| Update optimization (called periodically)                     |
//+------------------------------------------------------------------+
void CStrategyOptimizer::UpdateOptimization() {
    if (!m_bRunning) return;
    
    // Check for termination conditions
    if (CheckConvergence()) {
        m_bRunning = false;
        m_Stats.IsCompleted = true;
        m_Stats.EndTime = TimeCurrent();
        m_Stats.ElapsedSeconds = (double)(m_Stats.EndTime - m_Stats.StartTime);
        
        LogOptimizationEvent("Optimization completed - convergence achieved");
    }
    
    UpdateProgress();
}

//+------------------------------------------------------------------+
//| Run Genetic Algorithm                                          |
//+------------------------------------------------------------------+
void CStrategyOptimizer::RunGeneticAlgorithm() {
    LogOptimizationEvent("Starting Genetic Algorithm optimization");
    
    // Initialize population
    InitializePopulation();
    
    // Main evolution loop
    for (m_CurrentIteration = 0; m_CurrentIteration < m_Config.MaxIterations && !m_bTerminated; m_CurrentIteration++) {
        // Evaluate population
        EvaluatePopulation();
        
        // Check for improvement
        UpdateProgress();
        
        // Create new generation
        SOptimizationResult newPopulation[];
        ArrayResize(newPopulation, m_Config.PopulationSize);
        
        // Elitism - keep best individuals
        int eliteCount = (int)(m_Config.PopulationSize * m_GAParams.ElitismRate);
        for (int i = 0; i < eliteCount; i++) {
            newPopulation[i] = m_Population[i];
        }
        
        // Generate offspring
        for (int i = eliteCount; i < m_Config.PopulationSize; i++) {
            int parent1, parent2;
            SelectParents(parent1, parent2);
            
            if (GenerateRandomValue(0, 1) < m_GAParams.CrossoverRate) {
                newPopulation[i] = Crossover(m_Population[parent1], m_Population[parent2]);
            } else {
                newPopulation[i] = m_Population[parent1];
            }
            
            if (GenerateRandomValue(0, 1) < m_GAParams.MutationRate) {
                Mutate(newPopulation[i]);
            }
        }
        
        // Replace population
        ArrayCopy(m_Population, newPopulation);
        
        // Check convergence
        if (CheckConvergence()) break;
    }
    
    m_bRunning = false;
    m_Stats.IsCompleted = true;
    m_Stats.EndTime = TimeCurrent();
    m_Stats.ElapsedSeconds = (double)(m_Stats.EndTime - m_Stats.StartTime);
    
    LogOptimizationEvent("Genetic Algorithm optimization completed");
}

//+------------------------------------------------------------------+
//| Initialize population for GA                                   |
//+------------------------------------------------------------------+
void CStrategyOptimizer::InitializePopulation() {
    ArrayResize(m_Population, m_Config.PopulationSize);
    
    for (int i = 0; i < m_Config.PopulationSize; i++) {
        m_Population[i] = CreateRandomSolution();
    }
    
    LogOptimizationEvent(StringFormat("Population initialized with %d individuals", m_Config.PopulationSize));
}

//+------------------------------------------------------------------+
//| Evaluate population                                            |
//+------------------------------------------------------------------+
void CStrategyOptimizer::EvaluatePopulation() {
    for (int i = 0; i < ArraySize(m_Population); i++) {
        if (!m_Population[i].IsValid) {
            m_Population[i] = EvaluateSolution(m_Population[i].Parameters);
        }
    }
    
    // Sort population by objective value (descending)
    for (int i = 0; i < ArraySize(m_Population) - 1; i++) {
        for (int j = i + 1; j < ArraySize(m_Population); j++) {
            if (m_Population[j].ObjectiveValue > m_Population[i].ObjectiveValue) {
                SOptimizationResult temp = m_Population[i];
                m_Population[i] = m_Population[j];
                m_Population[j] = temp;
            }
        }
    }
    
    // Update best result
    if (ArraySize(m_Population) > 0 && m_Population[0].ObjectiveValue > m_BestResult.ObjectiveValue) {
        m_BestResult = m_Population[0];
    }
}

//+------------------------------------------------------------------+
//| Create random solution                                         |
//+------------------------------------------------------------------+
SOptimizationResult CStrategyOptimizer::CreateRandomSolution() {
    SOptimizationResult solution;
    ZeroMemory(solution);
    
    ArrayResize(solution.Parameters, ArraySize(m_Parameters));
    
    for (int i = 0; i < ArraySize(m_Parameters); i++) {
        solution.Parameters[i] = m_Parameters[i];
        
        // Generate random value within parameter range
        double randomValue = GenerateRandomValue(m_Parameters[i].MinValue, m_Parameters[i].MaxValue);
        
        // Apply step if specified
        if (m_Parameters[i].Step > 0) {
            randomValue = MathRound(randomValue / m_Parameters[i].Step) * m_Parameters[i].Step;
        }
        
        solution.Parameters[i].CurrentValue = randomValue;
    }
    
    solution.IsValid = false; // Will be evaluated later
    
    return solution;
}

//+------------------------------------------------------------------+
//| Generate random value                                          |
//+------------------------------------------------------------------+
double CStrategyOptimizer::GenerateRandomValue(const double min, const double max) {
    return min + (max - min) * ((double)MathRand() / 32767.0);
}

//+------------------------------------------------------------------+
//| Generate random integer                                        |
//+------------------------------------------------------------------+
int CStrategyOptimizer::GenerateRandomInt(const int min, const int max) {
    return min + (MathRand() % (max - min + 1));
}

//+------------------------------------------------------------------+
//| Check convergence                                              |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::CheckConvergence() {
    if (m_CurrentIteration >= m_Config.MaxIterations) {
        return true;
    }
    
    if (m_StagnantCount >= m_Config.MaxStagnantIterations) {
        LogOptimizationEvent("Convergence achieved - no improvement for " + IntegerToString(m_StagnantCount) + " iterations");
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Update progress                                                |
//+------------------------------------------------------------------+
void CStrategyOptimizer::UpdateProgress() {
    if (m_BestResult.ObjectiveValue > m_LastBestValue + m_Config.ConvergenceThreshold) {
        m_LastBestValue = m_BestResult.ObjectiveValue;
        m_StagnantCount = 0;
        LogOptimizationEvent(StringFormat("New best result: %.6f", m_BestResult.ObjectiveValue));
    } else {
        m_StagnantCount++;
    }
    
    m_Stats.TotalIterations = m_CurrentIteration;
    m_Stats.BestObjectiveValue = m_BestResult.ObjectiveValue;
    m_Stats.StagnantIterations = m_StagnantCount;
}

//+------------------------------------------------------------------+
//| Placeholder methods for other optimization algorithms          |
//+------------------------------------------------------------------+
void CStrategyOptimizer::RunParticleSwarm() {
    LogOptimizationEvent("Particle Swarm Optimization not yet implemented", LOG_LEVEL_WARNING);
    m_bRunning = false;
}

void CStrategyOptimizer::RunSimulatedAnnealing() {
    LogOptimizationEvent("Simulated Annealing not yet implemented", LOG_LEVEL_WARNING);
    m_bRunning = false;
}

void CStrategyOptimizer::RunGridSearch() {
    LogOptimizationEvent("Grid Search not yet implemented", LOG_LEVEL_WARNING);
    m_bRunning = false;
}

void CStrategyOptimizer::RunRandomSearch() {
    LogOptimizationEvent("Random Search not yet implemented", LOG_LEVEL_WARNING);
    m_bRunning = false;
}

void CStrategyOptimizer::RunBayesianOptimization() {
    LogOptimizationEvent("Bayesian Optimization not yet implemented", LOG_LEVEL_WARNING);
    m_bRunning = false;
}

//+------------------------------------------------------------------+
//| Placeholder methods for GA operations                          |
//+------------------------------------------------------------------+
void CStrategyOptimizer::SelectParents(int& parent1, int& parent2) {
    // Tournament selection
    parent1 = GenerateRandomInt(0, MathMin(m_GAParams.TournamentSize, ArraySize(m_Population)) - 1);
    parent2 = GenerateRandomInt(0, MathMin(m_GAParams.TournamentSize, ArraySize(m_Population)) - 1);
}

SOptimizationResult CStrategyOptimizer::Crossover(const SOptimizationResult& parent1, const SOptimizationResult& parent2) {
    // Simple uniform crossover
    SOptimizationResult offspring = parent1;
    
    for (int i = 0; i < ArraySize(offspring.Parameters); i++) {
        if (GenerateRandomValue(0, 1) < 0.5) {
            offspring.Parameters[i].CurrentValue = parent2.Parameters[i].CurrentValue;
        }
    }
    
    offspring.IsValid = false;
    return offspring;
}

void CStrategyOptimizer::Mutate(SOptimizationResult& individual) {
    for (int i = 0; i < ArraySize(individual.Parameters); i++) {
        if (GenerateRandomValue(0, 1) < 0.1) { // 10% chance per parameter
            double range = individual.Parameters[i].MaxValue - individual.Parameters[i].MinValue;
            double mutation = GenerateRandomValue(-range * 0.1, range * 0.1);
            individual.Parameters[i].CurrentValue = MathMax(individual.Parameters[i].MinValue,
                                                           MathMin(individual.Parameters[i].MaxValue,
                                                                  individual.Parameters[i].CurrentValue + mutation));
        }
    }
    individual.IsValid = false;
}

//+------------------------------------------------------------------+
//| Evaluate solution (placeholder)                                |
//+------------------------------------------------------------------+
SOptimizationResult CStrategyOptimizer::EvaluateSolution(const SOptimizationParameter& params[]) {
    SOptimizationResult result;
    ZeroMemory(result);
    
    // Copy parameters
    ArrayResize(result.Parameters, ArraySize(params));
    ArrayCopy(result.Parameters, params);
    
    // Apply parameters to EA
    ApplyParameters(params);
    
    // Run backtest or get current performance metrics
    // This is a placeholder - actual implementation would run strategy evaluation
    result.Profit = GenerateRandomValue(-1000, 5000);
    result.MaxDrawdown = GenerateRandomValue(100, 2000);
    result.SharpeRatio = GenerateRandomValue(-2, 3);
    result.WinRate = GenerateRandomValue(30, 80);
    result.ProfitFactor = GenerateRandomValue(0.5, 3.0);
    result.TotalTrades = GenerateRandomInt(10, 1000);
    
    // Calculate objective value
    result.ObjectiveValue = CalculateObjectiveValue(result);
    result.IsValid = ValidateResult(result);
    
    // Add to results history
    int size = ArraySize(m_Results);
    ArrayResize(m_Results, size + 1);
    m_Results[size] = result;
    
    if (result.IsValid) {
        m_Stats.ValidResults++;
    } else {
        m_Stats.InvalidResults++;
    }
    
    return result;
}

//+------------------------------------------------------------------+
//| Apply parameters to EA                                         |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::ApplyParameters(const SOptimizationParameter& params[]) {
    if (m_pContext == NULL) return false;
    
    // Apply parameters to EA context
    // This is a placeholder - actual implementation would set EA parameters
    
    return true;
}

//+------------------------------------------------------------------+
//| Calculate objective value                                      |
//+------------------------------------------------------------------+
double CStrategyOptimizer::CalculateObjectiveValue(const SOptimizationResult& result) {
    switch(m_Config.Objective) {
    case OPT_OBJECTIVE_PROFIT:
        return result.Profit;
    case OPT_OBJECTIVE_SHARPE_RATIO:
        return result.SharpeRatio;
    case OPT_OBJECTIVE_SORTINO_RATIO:
        return result.SortinoRatio;
    case OPT_OBJECTIVE_CALMAR_RATIO:
        return result.CalmarRatio;
    case OPT_OBJECTIVE_MAX_DRAWDOWN:
        return -result.MaxDrawdown; // Minimize drawdown
    case OPT_OBJECTIVE_WIN_RATE:
        return result.WinRate;
    case OPT_OBJECTIVE_PROFIT_FACTOR:
        return result.ProfitFactor;
    case OPT_OBJECTIVE_CUSTOM:
        // Custom objective function
        return result.Profit / MathMax(1.0, result.MaxDrawdown) * result.SharpeRatio;
    default:
        return result.Profit;
    }
}

//+------------------------------------------------------------------+
//| Validate result                                                |
//+------------------------------------------------------------------+
bool CStrategyOptimizer::ValidateResult(const SOptimizationResult& result) {
    // Basic validation
    if (result.TotalTrades < 10) return false;
    if (result.MaxDrawdown > result.Profit * 2) return false;
    if (result.WinRate < 20 || result.WinRate > 90) return false;
    
    return true;
}

//+------------------------------------------------------------------+
//| Get optimization report                                        |
//+------------------------------------------------------------------+
string CStrategyOptimizer::GetOptimizationReport() const {
    string report = "\n=== APEX EA Strategy Optimization Report ===\n";
    
    report += StringFormat("Method: %s\n", EnumToString(m_Config.Objective));
    report += StringFormat("Objective: %s\n", EnumToString(m_Config.Objective));
    report += StringFormat("Total Iterations: %d\n", m_Stats.TotalIterations);
    report += StringFormat("Valid Results: %d\n", m_Stats.ValidResults);
    report += StringFormat("Invalid Results: %d\n", m_Stats.InvalidResults);
    report += StringFormat("Elapsed Time: %.2f seconds\n", m_Stats.ElapsedSeconds);
    
    if (m_BestResult.IsValid) {
        report += "\n=== Best Result ===\n";
        report += StringFormat("Objective Value: %.6f\n", m_BestResult.ObjectiveValue);
        report += StringFormat("Profit: %.2f\n", m_BestResult.Profit);
        report += StringFormat("Max Drawdown: %.2f\n", m_BestResult.MaxDrawdown);
        report += StringFormat("Sharpe Ratio: %.3f\n", m_BestResult.SharpeRatio);
        report += StringFormat("Win Rate: %.2f%%\n", m_BestResult.WinRate);
        report += StringFormat("Profit Factor: %.3f\n", m_BestResult.ProfitFactor);
        report += StringFormat("Total Trades: %d\n", m_BestResult.TotalTrades);
        
        report += "\n=== Best Parameters ===\n";
        for (int i = 0; i < ArraySize(m_BestResult.Parameters); i++) {
            report += StringFormat("%s: %.6f\n", m_BestResult.Parameters[i].Name, m_BestResult.Parameters[i].CurrentValue);
        }
    }
    
    return report;
}

//+------------------------------------------------------------------+
//| Log optimization event                                         |
//+------------------------------------------------------------------+
void CStrategyOptimizer::LogOptimizationEvent(const string event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO) {
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