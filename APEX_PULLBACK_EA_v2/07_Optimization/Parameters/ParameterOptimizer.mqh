//+------------------------------------------------------------------+
//|                                        ParameterOptimizer.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "../../01_Core/CommonStructs.mqh"

//+------------------------------------------------------------------+
//| Parameter optimization enumerations                            |
//+------------------------------------------------------------------+
enum ENUM_OPTIMIZATION_METHOD {
    OPT_METHOD_GENETIC,             // Genetic algorithm
    OPT_METHOD_GRID_SEARCH,         // Grid search
    OPT_METHOD_RANDOM_SEARCH,       // Random search
    OPT_METHOD_BAYESIAN,            // Bayesian optimization
    OPT_METHOD_PARTICLE_SWARM,      // Particle swarm optimization
    OPT_METHOD_SIMULATED_ANNEALING, // Simulated annealing
    OPT_METHOD_DIFFERENTIAL_EVOLUTION, // Differential evolution
    OPT_METHOD_GRADIENT_DESCENT,    // Gradient descent
    OPT_METHOD_NELDER_MEAD,         // Nelder-Mead simplex
    OPT_METHOD_HYBRID               // Hybrid approach
};

enum ENUM_PARAMETER_TYPE {
    PARAM_TYPE_INTEGER,             // Integer parameter
    PARAM_TYPE_DOUBLE,              // Double parameter
    PARAM_TYPE_BOOLEAN,             // Boolean parameter
    PARAM_TYPE_ENUM,                // Enumeration parameter
    PARAM_TYPE_STRING,              // String parameter
    PARAM_TYPE_DATETIME,            // DateTime parameter
    PARAM_TYPE_COLOR,               // Color parameter
    PARAM_TYPE_ARRAY                // Array parameter
};

enum ENUM_OPTIMIZATION_STATUS {
    OPT_STATUS_IDLE,                // Idle
    OPT_STATUS_INITIALIZING,        // Initializing
    OPT_STATUS_RUNNING,             // Running
    OPT_STATUS_PAUSED,              // Paused
    OPT_STATUS_COMPLETED,           // Completed
    OPT_STATUS_STOPPED,             // Stopped
    OPT_STATUS_ERROR,               // Error occurred
    OPT_STATUS_CANCELLED            // Cancelled
};

enum ENUM_FITNESS_FUNCTION {
    FITNESS_PROFIT_FACTOR,          // Profit factor
    FITNESS_SHARPE_RATIO,           // Sharpe ratio
    FITNESS_SORTINO_RATIO,          // Sortino ratio
    FITNESS_CALMAR_RATIO,           // Calmar ratio
    FITNESS_MAX_DRAWDOWN,           // Maximum drawdown
    FITNESS_WIN_RATE,               // Win rate
    FITNESS_PROFIT_PER_TRADE,       // Profit per trade
    FITNESS_RECOVERY_FACTOR,        // Recovery factor
    FITNESS_CUSTOM,                 // Custom fitness function
    FITNESS_MULTI_OBJECTIVE         // Multi-objective optimization
};

enum ENUM_CONVERGENCE_CRITERIA {
    CONV_MAX_ITERATIONS,            // Maximum iterations
    CONV_FITNESS_THRESHOLD,         // Fitness threshold
    CONV_NO_IMPROVEMENT,            // No improvement
    CONV_TIME_LIMIT,                // Time limit
    CONV_RELATIVE_CHANGE,           // Relative change
    CONV_ABSOLUTE_CHANGE,           // Absolute change
    CONV_CUSTOM                     // Custom criteria
};

enum ENUM_SELECTION_METHOD {
    SELECT_TOURNAMENT,              // Tournament selection
    SELECT_ROULETTE,                // Roulette wheel selection
    SELECT_RANK,                    // Rank-based selection
    SELECT_ELITIST,                 // Elitist selection
    SELECT_RANDOM,                  // Random selection
    SELECT_BEST                     // Best selection
};

//+------------------------------------------------------------------+
//| Parameter optimization structures                              |
//+------------------------------------------------------------------+
struct SOptimizationParameter {
    string Name;                    // Parameter name
    ENUM_PARAMETER_TYPE Type;       // Parameter type
    
    // Value ranges
    double MinValue;                // Minimum value
    double MaxValue;                // Maximum value
    double StepSize;                // Step size
    double CurrentValue;            // Current value
    double BestValue;               // Best value found
    
    // Integer specific
    int MinInt;                     // Minimum integer value
    int MaxInt;                     // Maximum integer value
    int StepInt;                    // Integer step size
    int CurrentInt;                 // Current integer value
    int BestInt;                    // Best integer value
    
    // Boolean specific
    bool CurrentBool;               // Current boolean value
    bool BestBool;                  // Best boolean value
    
    // String/Enum specific
    string PossibleValues[];        // Possible string/enum values
    string CurrentString;           // Current string value
    string BestString;              // Best string value
    
    // Optimization settings
    bool IsEnabled;                 // Is parameter enabled for optimization
    bool IsFixed;                   // Is parameter fixed
    double Weight;                  // Parameter weight in optimization
    double Sensitivity;             // Parameter sensitivity
    
    // Statistics
    double AverageValue;            // Average value during optimization
    double StandardDeviation;      // Standard deviation
    int TimesChanged;               // Number of times changed
    double ImpactOnFitness;         // Impact on fitness function
    
    // Constraints
    string Constraints;             // Parameter constraints (JSON format)
    bool HasDependencies;           // Has dependencies on other parameters
    string Dependencies[];          // Dependent parameter names
    
    // Metadata
    string Description;             // Parameter description
    string Category;                // Parameter category
    string Units;                   // Parameter units
    datetime LastModified;          // Last modification time
};

struct SOptimizationResult {
    int Generation;                 // Generation number
    int Individual;                 // Individual number
    
    // Parameter values
    SOptimizationParameter Parameters[]; // Parameter set
    
    // Fitness metrics
    double FitnessValue;            // Primary fitness value
    double SecondaryFitness[];      // Secondary fitness values
    double WeightedFitness;         // Weighted fitness
    
    // Performance metrics
    double ProfitFactor;            // Profit factor
    double SharpeRatio;             // Sharpe ratio
    double MaxDrawdown;             // Maximum drawdown
    double WinRate;                 // Win rate
    double TotalTrades;             // Total trades
    double ProfitPerTrade;          // Profit per trade
    
    // Validation metrics
    double InSampleFitness;         // In-sample fitness
    double OutSampleFitness;        // Out-of-sample fitness
    double ValidationScore;         // Validation score
    double RobustnessScore;         // Robustness score
    
    // Execution info
    datetime StartTime;             // Start time
    datetime EndTime;               // End time
    int ExecutionTime;              // Execution time (ms)
    bool IsValid;                   // Is result valid
    
    // Ranking
    int Rank;                       // Result rank
    double Score;                   // Overall score
    bool IsElite;                   // Is elite individual
    bool IsPareto;                  // Is Pareto optimal
    
    // Additional data
    string Notes;                   // Additional notes
    string ExtraData;               // Extra data (JSON format)
};

struct SOptimizationConfig {
    // Method settings
    ENUM_OPTIMIZATION_METHOD Method; // Optimization method
    ENUM_FITNESS_FUNCTION FitnessFunction; // Fitness function
    ENUM_SELECTION_METHOD SelectionMethod; // Selection method
    
    // Population settings
    int PopulationSize;             // Population size
    int MaxGenerations;             // Maximum generations
    int EliteSize;                  // Elite size
    double MutationRate;            // Mutation rate
    double CrossoverRate;           // Crossover rate
    
    // Convergence settings
    ENUM_CONVERGENCE_CRITERIA ConvergenceCriteria; // Convergence criteria
    double FitnessThreshold;        // Fitness threshold
    int NoImprovementLimit;         // No improvement limit
    int TimeLimit;                  // Time limit (seconds)
    double RelativeChangeThreshold; // Relative change threshold
    double AbsoluteChangeThreshold; // Absolute change threshold
    
    // Validation settings
    bool EnableValidation;          // Enable out-of-sample validation
    double ValidationRatio;         // Validation data ratio (0-1)
    bool EnableWalkForward;         // Enable walk-forward analysis
    int WalkForwardSteps;           // Walk-forward steps
    
    // Robustness settings
    bool EnableRobustnessTest;      // Enable robustness testing
    double NoiseLevel;              // Noise level for robustness
    int RobustnessIterations;       // Robustness test iterations
    
    // Multi-objective settings
    bool IsMultiObjective;          // Is multi-objective optimization
    double ObjectiveWeights[];      // Objective weights
    bool UseParetoFront;            // Use Pareto front
    
    // Advanced settings
    bool EnableParallelProcessing;  // Enable parallel processing
    int MaxThreads;                 // Maximum threads
    bool EnableCaching;             // Enable result caching
    bool EnableLogging;             // Enable detailed logging
    
    // Constraints
    bool EnableConstraints;         // Enable parameter constraints
    double PenaltyFactor;           // Constraint penalty factor
    
    // Output settings
    bool SaveAllResults;            // Save all results
    bool SaveBestOnly;              // Save best results only
    string OutputPath;              // Output file path
    bool EnableReporting;           // Enable optimization reporting
};

struct SOptimizationStatistics {
    // General statistics
    int TotalGenerations;           // Total generations completed
    int TotalEvaluations;           // Total fitness evaluations
    int ValidEvaluations;           // Valid fitness evaluations
    int InvalidEvaluations;         // Invalid fitness evaluations
    
    // Best results
    double BestFitness;             // Best fitness found
    double AverageFitness;          // Average fitness
    double WorstFitness;            // Worst fitness
    SOptimizationResult BestResult; // Best result
    
    // Convergence statistics
    int GenerationsToConvergence;   // Generations to convergence
    double ConvergenceRate;         // Convergence rate
    bool HasConverged;              // Has optimization converged
    
    // Performance statistics
    datetime StartTime;             // Optimization start time
    datetime EndTime;               // Optimization end time
    int TotalTime;                  // Total optimization time (seconds)
    double AverageEvaluationTime;   // Average evaluation time (ms)
    
    // Population statistics
    double PopulationDiversity;     // Population diversity
    double SelectionPressure;       // Selection pressure
    double MutationSuccess;         // Mutation success rate
    double CrossoverSuccess;        // Crossover success rate
    
    // Validation statistics
    double ValidationAccuracy;      // Validation accuracy
    double OverfittingRisk;         // Overfitting risk score
    double RobustnessScore;         // Robustness score
    
    // Progress tracking
    double ProgressPercent;         // Progress percentage
    string CurrentStatus;           // Current status description
    int EstimatedTimeRemaining;     // Estimated time remaining (seconds)
    
    // Error statistics
    int TotalErrors;                // Total errors
    int CriticalErrors;             // Critical errors
    string LastError;               // Last error message
    datetime LastErrorTime;         // Last error time
};

struct SOptimizationAlert {
    string Type;                    // Alert type
    string Message;                 // Alert message
    datetime Timestamp;             // Alert timestamp
    double Value;                   // Alert value
    double Threshold;               // Alert threshold
    bool IsUrgent;                  // Is urgent alert
    string Details;                 // Additional details
};

//+------------------------------------------------------------------+
//| Parameter Optimizer Class                                      |
//+------------------------------------------------------------------+
class CParameterOptimizer {
private:
    EAContext* m_pContext;
    
    // Configuration
    SOptimizationConfig m_Config;
    
    // Parameters
    SOptimizationParameter m_Parameters[];
    int m_ParameterCount;
    
    // Results
    SOptimizationResult m_Results[];
    int m_ResultCount;
    SOptimizationResult m_BestResult;
    
    // Population (for genetic algorithms)
    SOptimizationResult m_Population[];
    int m_PopulationSize;
    int m_CurrentGeneration;
    
    // Statistics
    SOptimizationStatistics m_Statistics;
    
    // Internal state
    bool m_bInitialized;
    ENUM_OPTIMIZATION_STATUS m_Status;
    datetime m_StartTime;
    datetime m_LastUpdate;
    
    // Helper methods
    bool ValidateParameters();
    bool InitializePopulation();
    bool EvaluateFitness(SOptimizationResult& result);
    bool SelectParents(SOptimizationResult& parent1, SOptimizationResult& parent2);
    bool Crossover(const SOptimizationResult& parent1, const SOptimizationResult& parent2, SOptimizationResult& offspring);
    bool Mutate(SOptimizationResult& individual);
    bool ReplacePopulation(const SOptimizationResult& newIndividuals[]);
    
    // Optimization methods
    bool RunGeneticAlgorithm();
    bool RunGridSearch();
    bool RunRandomSearch();
    bool RunBayesianOptimization();
    bool RunParticleSwarm();
    bool RunSimulatedAnnealing();
    
    // Fitness functions
    double CalculateProfitFactor(const SOptimizationResult& result);
    double CalculateSharpeRatio(const SOptimizationResult& result);
    double CalculateCustomFitness(const SOptimizationResult& result);
    double CalculateMultiObjectiveFitness(const SOptimizationResult& result);
    
    // Validation methods
    bool ValidateResult(SOptimizationResult& result);
    bool PerformWalkForwardAnalysis(SOptimizationResult& result);
    bool TestRobustness(SOptimizationResult& result);
    
    // Convergence checking
    bool CheckConvergence();
    bool HasImproved();
    bool IsTimeExpired();
    
    // Utility methods
    bool GenerateRandomParameters(SOptimizationResult& result);
    bool CopyParameters(const SOptimizationResult& source, SOptimizationResult& target);
    bool CompareResults(const SOptimizationResult& result1, const SOptimizationResult& result2);
    int FindParameterIndex(const string parameterName);
    bool UpdateStatistics();
    void SendOptimizationAlert(const SOptimizationAlert& alert);
    void LogError(const string message);
    void LogActivity(const string message);
    
public:
    // Constructor/Destructor
    CParameterOptimizer();
    ~CParameterOptimizer();
    
    // Initialization
    bool Initialize(EAContext* context);
    bool Deinitialize();
    bool Configure(const SOptimizationConfig& config);
    
    // Parameter management
    bool AddParameter(const SOptimizationParameter& parameter);
    bool RemoveParameter(const string parameterName);
    bool UpdateParameter(const string parameterName, const SOptimizationParameter& parameter);
    bool GetParameter(const string parameterName, SOptimizationParameter& parameter);
    bool GetAllParameters(SOptimizationParameter& parameters[]);
    bool SetParameterValue(const string parameterName, double value);
    bool SetParameterRange(const string parameterName, double minValue, double maxValue, double stepSize);
    bool EnableParameter(const string parameterName, bool enable = true);
    bool FixParameter(const string parameterName, bool fix = true);
    
    // Optimization control
    bool StartOptimization();
    bool StopOptimization();
    bool PauseOptimization();
    bool ResumeOptimization();
    bool ResetOptimization();
    bool RunSingleIteration();
    
    // Results management
    bool GetBestResult(SOptimizationResult& result);
    bool GetAllResults(SOptimizationResult& results[]);
    bool GetTopResults(int count, SOptimizationResult& results[]);
    bool GetResultsByGeneration(int generation, SOptimizationResult& results[]);
    bool SaveResults(const string filename);
    bool LoadResults(const string filename);
    
    // Analysis methods
    bool AnalyzeParameterSensitivity(const string parameterName, double& sensitivity);
    bool AnalyzeParameterCorrelation(const string param1, const string param2, double& correlation);
    bool AnalyzeConvergence(string& analysis);
    bool AnalyzeRobustness(string& analysis);
    bool GenerateOptimizationReport(string& report);
    
    // Validation methods
    bool ValidateBestResult();
    bool PerformOutOfSampleTest(double& accuracy);
    bool PerformWalkForwardTest(double& accuracy);
    bool PerformRobustnessTest(double& robustness);
    
    // Configuration methods
    bool SetOptimizationMethod(ENUM_OPTIMIZATION_METHOD method);
    bool SetFitnessFunction(ENUM_FITNESS_FUNCTION function);
    bool SetPopulationSize(int size);
    bool SetMaxGenerations(int generations);
    bool SetMutationRate(double rate);
    bool SetCrossoverRate(double rate);
    bool SetConvergenceCriteria(ENUM_CONVERGENCE_CRITERIA criteria, double threshold);
    
    // Multi-objective optimization
    bool EnableMultiObjective(bool enable = true);
    bool SetObjectiveWeights(const double weights[]);
    bool GetParetoFront(SOptimizationResult& paretoResults[]);
    
    // Advanced features
    bool EnableParallelProcessing(bool enable = true, int maxThreads = 0);
    bool EnableCaching(bool enable = true);
    bool SetCustomFitnessFunction(const string functionName);
    bool AddConstraint(const string constraint);
    bool RemoveConstraint(const string constraint);
    
    // Monitoring and alerts
    bool SetProgressCallback(const string callbackFunction);
    bool EnableAlert(const string alertType, double threshold, bool enable = true);
    bool GetOptimizationProgress(double& progress);
    bool GetEstimatedTimeRemaining(int& seconds);
    
    // Import/Export
    bool ExportParameters(const string filename);
    bool ImportParameters(const string filename);
    bool ExportResults(const string filename, const string format = "CSV");
    bool ExportConfiguration(const string filename);
    bool ImportConfiguration(const string filename);
    
    // Information getters
    SOptimizationConfig GetConfiguration() const { return m_Config; }
    SOptimizationStatistics GetStatistics() const { return m_Statistics; }
    int GetParameterCount() const { return m_ParameterCount; }
    int GetResultCount() const { return m_ResultCount; }
    int GetCurrentGeneration() const { return m_CurrentGeneration; }
    
    // Utility methods
    string GetOptimizationMethodName(ENUM_OPTIMIZATION_METHOD method);
    string GetParameterTypeName(ENUM_PARAMETER_TYPE type);
    string GetStatusName(ENUM_OPTIMIZATION_STATUS status);
    string GetFitnessFunctionName(ENUM_FITNESS_FUNCTION function);
    string GetSelectionMethodName(ENUM_SELECTION_METHOD method);
    
    // Status
    bool IsInitialized() const { return m_bInitialized; }
    ENUM_OPTIMIZATION_STATUS GetStatus() const { return m_Status; }
    bool IsRunning() const { return m_Status == OPT_STATUS_RUNNING; }
    bool IsCompleted() const { return m_Status == OPT_STATUS_COMPLETED; }
    datetime GetStartTime() const { return m_StartTime; }
    datetime GetLastUpdate() const { return m_LastUpdate; }
};

//+------------------------------------------------------------------+
//| Constructor                                                     |
//+------------------------------------------------------------------+
CParameterOptimizer::CParameterOptimizer() {
    m_pContext = NULL;
    m_ParameterCount = 0;
    m_ResultCount = 0;
    m_PopulationSize = 0;
    m_CurrentGeneration = 0;
    m_bInitialized = false;
    m_Status = OPT_STATUS_IDLE;
    m_StartTime = 0;
    m_LastUpdate = 0;
    
    ZeroMemory(m_Config);
    ZeroMemory(m_Statistics);
    ZeroMemory(m_BestResult);
    
    // Set default configuration
    m_Config.Method = OPT_METHOD_GENETIC;
    m_Config.FitnessFunction = FITNESS_PROFIT_FACTOR;
    m_Config.SelectionMethod = SELECT_TOURNAMENT;
    
    m_Config.PopulationSize = 50;
    m_Config.MaxGenerations = 100;
    m_Config.EliteSize = 5;
    m_Config.MutationRate = 0.1;
    m_Config.CrossoverRate = 0.8;
    
    m_Config.ConvergenceCriteria = CONV_NO_IMPROVEMENT;
    m_Config.FitnessThreshold = 2.0;       // Profit factor >= 2.0
    m_Config.NoImprovementLimit = 20;      // 20 generations
    m_Config.TimeLimit = 3600;             // 1 hour
    m_Config.RelativeChangeThreshold = 0.01; // 1%
    m_Config.AbsoluteChangeThreshold = 0.1;
    
    m_Config.EnableValidation = true;
    m_Config.ValidationRatio = 0.3;        // 30% for validation
    m_Config.EnableWalkForward = false;
    m_Config.WalkForwardSteps = 10;
    
    m_Config.EnableRobustnessTest = true;
    m_Config.NoiseLevel = 0.05;            // 5% noise
    m_Config.RobustnessIterations = 10;
    
    m_Config.IsMultiObjective = false;
    m_Config.UseParetoFront = false;
    
    m_Config.EnableParallelProcessing = false;
    m_Config.MaxThreads = 4;
    m_Config.EnableCaching = true;
    m_Config.EnableLogging = true;
    
    m_Config.EnableConstraints = false;
    m_Config.PenaltyFactor = 1000.0;
    
    m_Config.SaveAllResults = false;
    m_Config.SaveBestOnly = true;
    m_Config.OutputPath = "";
    m_Config.EnableReporting = true;
}

//+------------------------------------------------------------------+
//| Destructor                                                      |
//+------------------------------------------------------------------+
CParameterOptimizer::~CParameterOptimizer() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize parameter optimizer                                  |
//+------------------------------------------------------------------+
bool CParameterOptimizer::Initialize(EAContext* context) {
    if (context == NULL) {
        LogError("Invalid context provided");
        return false;
    }
    
    m_pContext = context;
    
    // Initialize arrays
    ArrayResize(m_Parameters, 50);         // Support 50 parameters
    ArrayResize(m_Results, 1000);          // Store 1000 results
    ArrayResize(m_Population, m_Config.PopulationSize);
    
    m_ParameterCount = 0;
    m_ResultCount = 0;
    m_PopulationSize = 0;
    m_CurrentGeneration = 0;
    
    // Initialize statistics
    m_Statistics.StartTime = TimeCurrent();
    m_Statistics.LastErrorTime = 0;
    m_Statistics.BestFitness = -DBL_MAX;
    m_Statistics.WorstFitness = DBL_MAX;
    
    m_bInitialized = true;
    m_Status = OPT_STATUS_IDLE;
    
    LogActivity("Parameter optimizer initialized successfully");
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize parameter optimizer                                |
//+------------------------------------------------------------------+
bool CParameterOptimizer::Deinitialize() {
    if (m_bInitialized) {
        StopOptimization();
        
        // Clear arrays
        ArrayFree(m_Parameters);
        ArrayFree(m_Results);
        ArrayFree(m_Population);
        
        m_ParameterCount = 0;
        m_ResultCount = 0;
        m_PopulationSize = 0;
        m_CurrentGeneration = 0;
        
        m_bInitialized = false;
        m_Status = OPT_STATUS_IDLE;
        m_pContext = NULL;
        
        LogActivity("Parameter optimizer deinitialized");
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Configure parameter optimizer                                   |
//+------------------------------------------------------------------+
bool CParameterOptimizer::Configure(const SOptimizationConfig& config) {
    m_Config = config;
    
    // Validate configuration
    if (m_Config.PopulationSize <= 0) {
        LogError("Invalid population size");
        return false;
    }
    
    if (m_Config.MaxGenerations <= 0) {
        LogError("Invalid maximum generations");
        return false;
    }
    
    if (m_Config.MutationRate < 0 || m_Config.MutationRate > 1) {
        LogError("Invalid mutation rate (must be 0-1)");
        return false;
    }
    
    if (m_Config.CrossoverRate < 0 || m_Config.CrossoverRate > 1) {
        LogError("Invalid crossover rate (must be 0-1)");
        return false;
    }
    
    // Resize population array if needed
    if (m_bInitialized && ArraySize(m_Population) != m_Config.PopulationSize) {
        ArrayResize(m_Population, m_Config.PopulationSize);
    }
    
    LogActivity("Parameter optimizer configured successfully");
    return true;
}

//+------------------------------------------------------------------+
//| Add optimization parameter                                      |
//+------------------------------------------------------------------+
bool CParameterOptimizer::AddParameter(const SOptimizationParameter& parameter) {
    if (m_ParameterCount >= ArraySize(m_Parameters)) {
        // Resize array if needed
        int newSize = ArraySize(m_Parameters) + 20;
        if (ArrayResize(m_Parameters, newSize) < 0) {
            LogError("Failed to resize parameters array");
            return false;
        }
    }
    
    // Check if parameter already exists
    if (FindParameterIndex(parameter.Name) >= 0) {
        LogError("Parameter already exists: " + parameter.Name);
        return false;
    }
    
    // Validate parameter
    if (parameter.Name == "") {
        LogError("Parameter name cannot be empty");
        return false;
    }
    
    if (parameter.Type == PARAM_TYPE_DOUBLE || parameter.Type == PARAM_TYPE_INTEGER) {
        if (parameter.MaxValue <= parameter.MinValue) {
            LogError("Invalid parameter range for " + parameter.Name);
            return false;
        }
        
        if (parameter.StepSize <= 0) {
            LogError("Invalid step size for " + parameter.Name);
            return false;
        }
    }
    
    m_Parameters[m_ParameterCount] = parameter;
    m_Parameters[m_ParameterCount].LastModified = TimeCurrent();
    m_ParameterCount++;
    
    LogActivity("Added optimization parameter: " + parameter.Name);
    return true;
}

//+------------------------------------------------------------------+
//| Start optimization                                              |
//+------------------------------------------------------------------+
bool CParameterOptimizer::StartOptimization() {
    if (!m_bInitialized) {
        LogError("Parameter optimizer not initialized");
        return false;
    }
    
    if (m_Status == OPT_STATUS_RUNNING) {
        LogActivity("Optimization already running");
        return true;
    }
    
    if (m_ParameterCount == 0) {
        LogError("No parameters defined for optimization");
        return false;
    }
    
    // Validate parameters
    if (!ValidateParameters()) {
        LogError("Parameter validation failed");
        return false;
    }
    
    // Reset statistics
    ZeroMemory(m_Statistics);
    m_Statistics.StartTime = TimeCurrent();
    m_Statistics.BestFitness = -DBL_MAX;
    m_Statistics.WorstFitness = DBL_MAX;
    
    m_Status = OPT_STATUS_INITIALIZING;
    m_StartTime = TimeCurrent();
    m_CurrentGeneration = 0;
    
    // Initialize population
    if (!InitializePopulation()) {
        LogError("Failed to initialize population");
        m_Status = OPT_STATUS_ERROR;
        return false;
    }
    
    m_Status = OPT_STATUS_RUNNING;
    
    // Run optimization based on selected method
    bool success = false;
    switch (m_Config.Method) {
        case OPT_METHOD_GENETIC:
            success = RunGeneticAlgorithm();
            break;
        case OPT_METHOD_GRID_SEARCH:
            success = RunGridSearch();
            break;
        case OPT_METHOD_RANDOM_SEARCH:
            success = RunRandomSearch();
            break;
        case OPT_METHOD_BAYESIAN:
            success = RunBayesianOptimization();
            break;
        default:
            LogError("Optimization method not implemented: " + GetOptimizationMethodName(m_Config.Method));
            success = false;
            break;
    }
    
    if (success) {
        m_Status = OPT_STATUS_COMPLETED;
        m_Statistics.EndTime = TimeCurrent();
        m_Statistics.TotalTime = (int)(m_Statistics.EndTime - m_Statistics.StartTime);
        m_Statistics.HasConverged = CheckConvergence();
        
        LogActivity(StringFormat("Optimization completed in %d seconds with %d evaluations", 
                                m_Statistics.TotalTime, m_Statistics.TotalEvaluations));
    } else {
        m_Status = OPT_STATUS_ERROR;
        LogError("Optimization failed");
    }
    
    return success;
}

//+------------------------------------------------------------------+
//| Validate parameters                                             |
//+------------------------------------------------------------------+
bool CParameterOptimizer::ValidateParameters() {
    int enabledCount = 0;
    
    for (int i = 0; i < m_ParameterCount; i++) {
        if (m_Parameters[i].IsEnabled && !m_Parameters[i].IsFixed) {
            enabledCount++;
        }
    }
    
    if (enabledCount == 0) {
        LogError("No parameters enabled for optimization");
        return false;
    }
    
    LogActivity(StringFormat("Validated %d parameters (%d enabled)", m_ParameterCount, enabledCount));
    return true;
}

//+------------------------------------------------------------------+
//| Initialize population                                           |
//+------------------------------------------------------------------+
bool CParameterOptimizer::InitializePopulation() {
    m_PopulationSize = m_Config.PopulationSize;
    
    for (int i = 0; i < m_PopulationSize; i++) {
        ZeroMemory(m_Population[i]);
        
        // Generate random parameters
        if (!GenerateRandomParameters(m_Population[i])) {
            LogError(StringFormat("Failed to generate random parameters for individual %d", i));
            return false;
        }
        
        m_Population[i].Generation = 0;
        m_Population[i].Individual = i;
        m_Population[i].StartTime = TimeCurrent();
        
        // Evaluate fitness
        if (!EvaluateFitness(m_Population[i])) {
            LogError(StringFormat("Failed to evaluate fitness for individual %d", i));
            return false;
        }
    }
    
    LogActivity(StringFormat("Initialized population with %d individuals", m_PopulationSize));
    return true;
}

//+------------------------------------------------------------------+
//| Generate random parameters                                      |
//+------------------------------------------------------------------+
bool CParameterOptimizer::GenerateRandomParameters(SOptimizationResult& result) {
    ArrayResize(result.Parameters, m_ParameterCount);
    
    for (int i = 0; i < m_ParameterCount; i++) {
        result.Parameters[i] = m_Parameters[i];
        
        if (!m_Parameters[i].IsEnabled || m_Parameters[i].IsFixed) {
            // Use current value for fixed parameters
            continue;
        }
        
        switch (m_Parameters[i].Type) {
            case PARAM_TYPE_DOUBLE: {
                double range = m_Parameters[i].MaxValue - m_Parameters[i].MinValue;
                result.Parameters[i].CurrentValue = m_Parameters[i].MinValue + 
                    (MathRand() / 32767.0) * range;
                break;
            }
            
            case PARAM_TYPE_INTEGER: {
                int range = m_Parameters[i].MaxInt - m_Parameters[i].MinInt;
                result.Parameters[i].CurrentInt = m_Parameters[i].MinInt + 
                    (MathRand() % (range + 1));
                break;
            }
            
            case PARAM_TYPE_BOOLEAN: {
                result.Parameters[i].CurrentBool = (MathRand() % 2) == 1;
                break;
            }
            
            case PARAM_TYPE_ENUM: {
                int count = ArraySize(m_Parameters[i].PossibleValues);
                if (count > 0) {
                    int index = MathRand() % count;
                    result.Parameters[i].CurrentString = m_Parameters[i].PossibleValues[index];
                }
                break;
            }
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Find parameter index                                           |
//+------------------------------------------------------------------+
int CParameterOptimizer::FindParameterIndex(const string parameterName) {
    for (int i = 0; i < m_ParameterCount; i++) {
        if (m_Parameters[i].Name == parameterName) {
            return i;
        }
    }
    return -1;
}

//+------------------------------------------------------------------+
//| Log error message                                              |
//+------------------------------------------------------------------+
void CParameterOptimizer::LogError(const string message) {
    if (m_pContext != NULL && m_pContext.pLogger != NULL) {
        m_pContext.pLogger.LogError("ParameterOptimizer: " + message);
    } else {
        Print("ParameterOptimizer ERROR: ", message);
    }
    
    m_Statistics.TotalErrors++;
    m_Statistics.LastError = message;
    m_Statistics.LastErrorTime = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Log activity message                                           |
//+------------------------------------------------------------------+
void CParameterOptimizer::LogActivity(const string message) {
    if (m_pContext != NULL && m_pContext.pLogger != NULL) {
        m_pContext.pLogger.LogInfo("ParameterOptimizer: " + message);
    } else {
        Print("ParameterOptimizer: ", message);
    }
}

//+------------------------------------------------------------------+
//| Get optimization method name                                    |
//+------------------------------------------------------------------+
string CParameterOptimizer::GetOptimizationMethodName(ENUM_OPTIMIZATION_METHOD method) {
    switch (method) {
        case OPT_METHOD_GENETIC: return "Genetic Algorithm";
        case OPT_METHOD_GRID_SEARCH: return "Grid Search";
        case OPT_METHOD_RANDOM_SEARCH: return "Random Search";
        case OPT_METHOD_BAYESIAN: return "Bayesian Optimization";
        case OPT_METHOD_PARTICLE_SWARM: return "Particle Swarm";
        case OPT_METHOD_SIMULATED_ANNEALING: return "Simulated Annealing";
        case OPT_METHOD_DIFFERENTIAL_EVOLUTION: return "Differential Evolution";
        case OPT_METHOD_GRADIENT_DESCENT: return "Gradient Descent";
        case OPT_METHOD_NELDER_MEAD: return "Nelder-Mead";
        case OPT_METHOD_HYBRID: return "Hybrid";
        default: return "Unknown";
    }
}

//+------------------------------------------------------------------+
//| Get parameter type name                                        |
//+------------------------------------------------------------------+
string CParameterOptimizer::GetParameterTypeName(ENUM_PARAMETER_TYPE type) {
    switch (type) {
        case PARAM_TYPE_INTEGER: return "Integer";
        case PARAM_TYPE_DOUBLE: return "Double";
        case PARAM_TYPE_BOOLEAN: return "Boolean";
        case PARAM_TYPE_ENUM: return "Enumeration";
        case PARAM_TYPE_STRING: return "String";
        case PARAM_TYPE_DATETIME: return "DateTime";
        case PARAM_TYPE_COLOR: return "Color";
        case PARAM_TYPE_ARRAY: return "Array";
        default: return "Unknown";
    }
}

//+------------------------------------------------------------------+
//| Placeholder implementations for remaining methods              |
//+------------------------------------------------------------------+
bool CParameterOptimizer::EvaluateFitness(SOptimizationResult& result) {
    // Placeholder implementation
    result.FitnessValue = 1.0 + (MathRand() / 32767.0);  // Random fitness 1.0-2.0
    result.IsValid = true;
    result.EndTime = TimeCurrent();
    result.ExecutionTime = (int)((result.EndTime - result.StartTime) * 1000);
    
    m_Statistics.TotalEvaluations++;
    m_Statistics.ValidEvaluations++;
    
    // Update best fitness
    if (result.FitnessValue > m_Statistics.BestFitness) {
        m_Statistics.BestFitness = result.FitnessValue;
        m_BestResult = result;
    }
    
    return true;
}

bool CParameterOptimizer::RunGeneticAlgorithm() {
    // Placeholder implementation
    LogActivity("Running genetic algorithm optimization");
    
    for (int gen = 0; gen < m_Config.MaxGenerations; gen++) {
        m_CurrentGeneration = gen;
        
        // Check convergence
        if (CheckConvergence()) {
            LogActivity(StringFormat("Converged at generation %d", gen));
            break;
        }
        
        // Update progress
        m_Statistics.ProgressPercent = (double)gen / m_Config.MaxGenerations * 100.0;
        
        // Simulate generation processing
        Sleep(10);  // Simulate processing time
    }
    
    m_Statistics.TotalGenerations = m_CurrentGeneration;
    return true;
}

bool CParameterOptimizer::RunGridSearch() {
    // Placeholder implementation
    LogActivity("Running grid search optimization");
    return true;
}

bool CParameterOptimizer::RunRandomSearch() {
    // Placeholder implementation
    LogActivity("Running random search optimization");
    return true;
}

bool CParameterOptimizer::RunBayesianOptimization() {
    // Placeholder implementation
    LogActivity("Running Bayesian optimization");
    return true;
}

bool CParameterOptimizer::CheckConvergence() {
    // Placeholder implementation
    return m_CurrentGeneration >= m_Config.MaxGenerations;
}

bool CParameterOptimizer::UpdateStatistics() {
    // Placeholder implementation
    m_Statistics.LastUpdate = TimeCurrent();
    return true;
}

//+------------------------------------------------------------------+