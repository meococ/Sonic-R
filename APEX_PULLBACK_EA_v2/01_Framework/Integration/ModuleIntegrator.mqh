//+------------------------------------------------------------------+
//|                                            ModuleIntegrator.mqh |
//|                   ModuleIntegrator - APEX Pullback EA v5 FINAL  |
//|      Description: Integration Layer for all modules,            |
//|                   dependency resolution, and component          |
//|                   communication management                      |
//+------------------------------------------------------------------+

#ifndef MODULE_INTEGRATOR_MQH_
#define MODULE_INTEGRATOR_MQH_

#include "..\..\00_Core\CommonStructs.mqh"

namespace ApexPullback::v5 {

//+------------------------------------------------------------------+
//| Integration Status Types                                         |
//+------------------------------------------------------------------+
enum ENUM_INTEGRATION_STATUS {
    INTEGRATION_UNINITIALIZED,
    INTEGRATION_INITIALIZING,
    INTEGRATION_PARTIAL,
    INTEGRATION_COMPLETE,
    INTEGRATION_ERROR,
    INTEGRATION_DISCONNECTED
};

enum ENUM_MODULE_STATUS {
    MODULE_UNINITIALIZED,
    MODULE_INITIALIZING,
    MODULE_READY,
    MODULE_ERROR,
    MODULE_DISABLED
};

//+------------------------------------------------------------------+
//| Module Connection Status                                         |
//+------------------------------------------------------------------+
struct SModuleStatus {
    string                moduleName;        // Module name
    ENUM_MODULE_STATUS    status;            // Current status
    bool                  isRequired;        // Is required for operation
    bool                  isConnected;       // Connection status
    datetime              lastUpdate;        // Last status update
    string                errorMessage;      // Error message if any
    int                   retryCount;        // Retry attempts
    
    void Clear() {
        moduleName = "";
        status = MODULE_UNINITIALIZED;
        isRequired = false;
        isConnected = false;
        lastUpdate = 0;
        errorMessage = "";
        retryCount = 0;
    }
};

struct SIntegrationHealth {
    ENUM_INTEGRATION_STATUS overallStatus;   // Overall integration status
    int                   totalModules;      // Total number of modules
    int                   readyModules;      // Ready modules count
    int                   errorModules;      // Error modules count
    double                healthScore;       // Health score (0-1)
    datetime              lastHealthCheck;   // Last health check time
    bool                  canTrade;          // Can execute trades
    string                statusMessage;     // Status message
    
    void Clear() {
        overallStatus = INTEGRATION_UNINITIALIZED;
        totalModules = 0;
        readyModules = 0;
        errorModules = 0;
        healthScore = 0.0;
        lastHealthCheck = 0;
        canTrade = false;
        statusMessage = "";
    }
};

//+------------------------------------------------------------------+
//| CModuleIntegrator - Central Integration Manager                 |
//+------------------------------------------------------------------+
class CModuleIntegrator {
private:
    EAContext*            m_pContext;        // Reference to EA context
    bool                  m_bInitialized;   // Initialization status
    
    // Module tracking
    SModuleStatus         m_ModuleStatus[]; // Status of all modules
    SIntegrationHealth    m_Health;         // Integration health
    int                   m_ModuleCount;    // Number of modules
    
    // Integration timing
    datetime              m_LastIntegrationCheck;
    datetime              m_LastHealthCheck;
    int                   m_IntegrationRetries;
    
    // Module dependencies map
    string                m_Dependencies[][2]; // [module][dependency]
    int                   m_DependencyCount;
    
    // Constants
    static const int      MAX_MODULES = 20;
    static const int      MAX_DEPENDENCIES = 50;
    static const int      MAX_RETRIES = 3;
    static const int      HEALTH_CHECK_INTERVAL = 30; // seconds
    
public:
    //--- Constructor/Destructor ---
    CModuleIntegrator();
    ~CModuleIntegrator();
    
    //--- Initialization ---
    bool                  Initialize(EAContext* pContext);
    void                  Deinitialize();
    bool                  IsInitialized() const { return m_bInitialized; }
    
    //--- Integration Management ---
    bool                  IntegrateAllModules();
    bool                  ValidateIntegration();
    void                  UpdateIntegrationStatus();
    bool                  RepairBrokenConnections();
    
    //--- Module Management ---
    bool                  RegisterModule(const string& moduleName, bool isRequired = true);
    bool                  ConnectModule(const string& moduleName);
    bool                  DisconnectModule(const string& moduleName);
    bool                  IsModuleReady(const string& moduleName);
    ENUM_MODULE_STATUS    GetModuleStatus(const string& moduleName);
    
    //--- Dependency Management ---
    bool                  AddDependency(const string& module, const string& dependency);
    bool                  ResolveDependencies();
    bool                  CheckDependency(const string& module, const string& dependency);
    string                GetDependencyChain(const string& module);
    
    //--- Health Monitoring ---
    SIntegrationHealth    GetIntegrationHealth();
    bool                  PerformHealthCheck();
    double                CalculateHealthScore();
    bool                  CanExecuteTrades();
    
    //--- Signal Routing ---
    bool                  RouteSignal(const string& fromModule, const string& toModule, const string& signal, const string& data = "");
    bool                  BroadcastSignal(const string& fromModule, const string& signal, const string& data = "");
    
    //--- Error Handling ---
    void                  HandleModuleError(const string& moduleName, const string& error);
    bool                  AttemptModuleRecovery(const string& moduleName);
    void                  LogIntegrationEvent(const string& event, ENUM_LOG_LEVEL level = LOG_LEVEL_INFO);
    
    //--- Status Information ---
    string                GetIntegrationSummary();
    string                GetModuleStatusReport();
    void                  PrintIntegrationDashboard();
    
private:
    //--- Internal Methods ---
    void                  InitializeModuleRegistry();
    void                  SetupDependencyMap();
    int                   FindModuleIndex(const string& moduleName);
    bool                  ValidateModuleConnections();
    
    //--- Core Module Connections ---
    bool                  ConnectCoreModules();
    bool                  ConnectMarketAnalysis();
    bool                  ConnectSignalGeneration();
    bool                  ConnectRiskManagement();
    bool                  ConnectTradeManagement();
    bool                  ConnectAnalytics();
    bool                  ConnectUI();
    
    //--- Connection Validation ---
    bool                  ValidateLogger();
    bool                  ValidateErrorHandler();
    bool                  ValidateSymbolManager();
    bool                  ValidateTimeManager();
    bool                  ValidateMarketProfile();
    bool                  ValidateAssetDNA();
    bool                  ValidateSignalEngine();
    bool                  ValidateRiskManager();
    bool                  ValidateTradeManager();
    bool                  ValidatePerformanceTracker();
    bool                  ValidateDashboard();
    
    //--- Utility Methods ---
    void                  UpdateModuleStatus(const string& moduleName, ENUM_MODULE_STATUS status, const string& message = "");
    bool                  IsModuleRequired(const string& moduleName);
    void                  ResetIntegrationState();
    string                StatusToString(ENUM_MODULE_STATUS status);
    string                IntegrationStatusToString(ENUM_INTEGRATION_STATUS status);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CModuleIntegrator::CModuleIntegrator() {
    m_pContext = NULL;
    m_bInitialized = false;
    m_ModuleCount = 0;
    m_DependencyCount = 0;
    m_LastIntegrationCheck = 0;
    m_LastHealthCheck = 0;
    m_IntegrationRetries = 0;
    
    // Initialize arrays
    ArrayResize(m_ModuleStatus, MAX_MODULES);
    ArrayResize(m_Dependencies, MAX_DEPENDENCIES);
    
    // Clear health status
    m_Health.Clear();
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CModuleIntegrator::~CModuleIntegrator() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize Integration Layer                                     |
//+------------------------------------------------------------------+
bool CModuleIntegrator::Initialize(EAContext* pContext) {
    if (m_bInitialized) {
        return true;
    }
    
    if (pContext == NULL) {
        Print("[ModuleIntegrator] ERROR: Context is NULL");
        return false;
    }
    
    m_pContext = pContext;
    
    LogIntegrationEvent("Initializing Module Integration Layer...", LOG_LEVEL_INFO);
    
    // Initialize module registry
    InitializeModuleRegistry();
    
    // Setup dependency map
    SetupDependencyMap();
    
    // Reset integration state
    ResetIntegrationState();
    
    m_bInitialized = true;
    
    LogIntegrationEvent("Module Integration Layer initialized successfully", LOG_LEVEL_INFO);
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize Integration Layer                                   |
//+------------------------------------------------------------------+
void CModuleIntegrator::Deinitialize() {
    if (!m_bInitialized) {
        return;
    }
    
    LogIntegrationEvent("Deinitializing Module Integration Layer...", LOG_LEVEL_INFO);
    
    // Disconnect all modules gracefully
    for (int i = 0; i < m_ModuleCount; i++) {
        if (m_ModuleStatus[i].isConnected) {
            DisconnectModule(m_ModuleStatus[i].moduleName);
        }
    }
    
    m_bInitialized = false;
    m_pContext = NULL;
    
    LogIntegrationEvent("Module Integration Layer deinitialized", LOG_LEVEL_INFO);
}

//+------------------------------------------------------------------+
//| Integrate All Modules                                           |
//+------------------------------------------------------------------+
bool CModuleIntegrator::IntegrateAllModules() {
    if (!m_bInitialized) {
        return false;
    }
    
    LogIntegrationEvent("Starting full module integration...", LOG_LEVEL_INFO);
    
    m_Health.overallStatus = INTEGRATION_INITIALIZING;
    
    // Step 1: Connect core modules first
    if (!ConnectCoreModules()) {
        LogIntegrationEvent("Failed to connect core modules", LOG_LEVEL_ERROR);
        m_Health.overallStatus = INTEGRATION_ERROR;
        return false;
    }
    
    // Step 2: Resolve all dependencies
    if (!ResolveDependencies()) {
        LogIntegrationEvent("Failed to resolve module dependencies", LOG_LEVEL_ERROR);
        m_Health.overallStatus = INTEGRATION_PARTIAL;
    }
    
    // Step 3: Connect remaining modules in dependency order
    bool allConnected = true;
    allConnected &= ConnectMarketAnalysis();
    allConnected &= ConnectSignalGeneration();
    allConnected &= ConnectRiskManagement();
    allConnected &= ConnectTradeManagement();
    allConnected &= ConnectAnalytics();
    allConnected &= ConnectUI();
    
    // Step 4: Validate integration
    if (!ValidateIntegration()) {
        LogIntegrationEvent("Integration validation failed", LOG_LEVEL_ERROR);
        m_Health.overallStatus = INTEGRATION_PARTIAL;
        allConnected = false;
    }
    
    // Update final status
    if (allConnected) {
        m_Health.overallStatus = INTEGRATION_COMPLETE;
        LogIntegrationEvent("All modules integrated successfully", LOG_LEVEL_INFO);
    } else {
        LogIntegrationEvent("Partial integration completed with some errors", LOG_LEVEL_WARNING);
    }
    
    // Perform initial health check
    PerformHealthCheck();
    
    return allConnected;
}

//+------------------------------------------------------------------+
//| Initialize Module Registry                                       |
//+------------------------------------------------------------------+
void CModuleIntegrator::InitializeModuleRegistry() {
    // Register all modules in dependency order
    
    // Core Infrastructure (Level 0)
    RegisterModule("Logger", true);
    RegisterModule("ErrorHandler", true);
    RegisterModule("ParameterStore", true);
    RegisterModule("StateManager", false);
    
    // Framework (Level 1)
    RegisterModule("SymbolManager", true);
    RegisterModule("TimeManager", true);
    RegisterModule("BrokerHealth", false);
    
    // Market Analysis (Level 2)
    RegisterModule("MarketProfile", false);
    RegisterModule("AssetDNA", false);
    RegisterModule("NewsAnalysis", false);
    RegisterModule("Patterns", false);
    
    // Signal Generation (Level 3)
    RegisterModule("SignalEngine", true);
    
    // Risk & Trade Management (Level 4)
    RegisterModule("RiskManager", true);
    RegisterModule("TradeManager", true);
    RegisterModule("PositionManager", false);
    
    // Analytics (Level 5)
    RegisterModule("PerformanceTracker", false);
    
    // UI (Level 6)
    RegisterModule("Dashboard", false);
    
    LogIntegrationEvent(StringFormat("Registered %d modules", m_ModuleCount), LOG_LEVEL_INFO);
}

//+------------------------------------------------------------------+
//| Setup Dependency Map                                             |
//+------------------------------------------------------------------+
void CModuleIntegrator::SetupDependencyMap() {
    // Define module dependencies
    
    // Core dependencies
    AddDependency("ErrorHandler", "Logger");
    AddDependency("ParameterStore", "Logger");
    AddDependency("StateManager", "Logger");
    
    // Framework dependencies
    AddDependency("SymbolManager", "Logger");
    AddDependency("SymbolManager", "ErrorHandler");
    AddDependency("TimeManager", "Logger");
    AddDependency("TimeManager", "SymbolManager");
    AddDependency("BrokerHealth", "Logger");
    AddDependency("BrokerHealth", "SymbolManager");
    
    // Market Analysis dependencies
    AddDependency("MarketProfile", "Logger");
    AddDependency("MarketProfile", "SymbolManager");
    AddDependency("MarketProfile", "TimeManager");
    AddDependency("AssetDNA", "Logger");
    AddDependency("AssetDNA", "SymbolManager");
    AddDependency("AssetDNA", "MarketProfile");
    AddDependency("NewsAnalysis", "Logger");
    AddDependency("NewsAnalysis", "TimeManager");
    AddDependency("Patterns", "Logger");
    AddDependency("Patterns", "SymbolManager");
    
    // Signal Generation dependencies
    AddDependency("SignalEngine", "Logger");
    AddDependency("SignalEngine", "SymbolManager");
    AddDependency("SignalEngine", "TimeManager");
    AddDependency("SignalEngine", "AssetDNA");
    
    // Risk Management dependencies
    AddDependency("RiskManager", "Logger");
    AddDependency("RiskManager", "SymbolManager");
    AddDependency("RiskManager", "PerformanceTracker");
    
    // Trade Management dependencies
    AddDependency("TradeManager", "Logger");
    AddDependency("TradeManager", "SymbolManager");
    AddDependency("TradeManager", "RiskManager");
    AddDependency("TradeManager", "SignalEngine");
    AddDependency("PositionManager", "Logger");
    AddDependency("PositionManager", "SymbolManager");
    AddDependency("PositionManager", "TradeManager");
    
    // Analytics dependencies
    AddDependency("PerformanceTracker", "Logger");
    AddDependency("PerformanceTracker", "TradeManager");
    
    // UI dependencies
    AddDependency("Dashboard", "Logger");
    AddDependency("Dashboard", "PerformanceTracker");
    AddDependency("Dashboard", "TradeManager");
    AddDependency("Dashboard", "RiskManager");
    
    LogIntegrationEvent(StringFormat("Setup %d dependencies", m_DependencyCount), LOG_LEVEL_INFO);
}

//+------------------------------------------------------------------+
//| Register Module                                                  |
//+------------------------------------------------------------------+
bool CModuleIntegrator::RegisterModule(const string& moduleName, bool isRequired = true) {
    if (m_ModuleCount >= MAX_MODULES) {
        LogIntegrationEvent("Maximum modules limit reached", LOG_LEVEL_ERROR);
        return false;
    }
    
    m_ModuleStatus[m_ModuleCount].Clear();
    m_ModuleStatus[m_ModuleCount].moduleName = moduleName;
    m_ModuleStatus[m_ModuleCount].isRequired = isRequired;
    m_ModuleStatus[m_ModuleCount].status = MODULE_UNINITIALIZED;
    m_ModuleStatus[m_ModuleCount].lastUpdate = TimeCurrent();
    
    m_ModuleCount++;
    
    return true;
}

//+------------------------------------------------------------------+
//| Connect Core Modules                                             |
//+------------------------------------------------------------------+
bool CModuleIntegrator::ConnectCoreModules() {
    LogIntegrationEvent("Connecting core modules...", LOG_LEVEL_INFO);
    
    bool success = true;
    
    // Connect in dependency order
    success &= ValidateLogger();
    success &= ValidateErrorHandler();
    success &= ValidateSymbolManager();
    success &= ValidateTimeManager();
    
    if (success) {
        LogIntegrationEvent("Core modules connected successfully", LOG_LEVEL_INFO);
    } else {
        LogIntegrationEvent("Failed to connect some core modules", LOG_LEVEL_ERROR);
    }
    
    return success;
}

//+------------------------------------------------------------------+
//| Validate Logger                                                  |
//+------------------------------------------------------------------+
bool CModuleIntegrator::ValidateLogger() {
    if (m_pContext->pLogger == NULL) {
        UpdateModuleStatus("Logger", MODULE_ERROR, "Logger is NULL");
        return false;
    }
    
    UpdateModuleStatus("Logger", MODULE_READY, "Logger connected");
    return true;
}

//+------------------------------------------------------------------+
//| Validate Error Handler                                           |
//+------------------------------------------------------------------+
bool CModuleIntegrator::ValidateErrorHandler() {
    if (m_pContext->pErrorHandler == NULL) {
        UpdateModuleStatus("ErrorHandler", MODULE_ERROR, "ErrorHandler is NULL");
        return false;
    }
    
    UpdateModuleStatus("ErrorHandler", MODULE_READY, "ErrorHandler connected");
    return true;
}

//+------------------------------------------------------------------+
//| Validate Symbol Manager                                          |
//+------------------------------------------------------------------+
bool CModuleIntegrator::ValidateSymbolManager() {
    if (m_pContext->pSymbolManager == NULL) {
        UpdateModuleStatus("SymbolManager", MODULE_ERROR, "SymbolManager is NULL");
        return false;
    }
    
    UpdateModuleStatus("SymbolManager", MODULE_READY, "SymbolManager connected");
    return true;
}

//+------------------------------------------------------------------+
//| Validate Time Manager                                            |
//+------------------------------------------------------------------+
bool CModuleIntegrator::ValidateTimeManager() {
    if (m_pContext->pTimeManager == NULL) {
        UpdateModuleStatus("TimeManager", MODULE_ERROR, "TimeManager is NULL");
        return false;
    }
    
    UpdateModuleStatus("TimeManager", MODULE_READY, "TimeManager connected");
    return true;
}

//+------------------------------------------------------------------+
//| Connect Market Analysis Modules                                  |
//+------------------------------------------------------------------+
bool CModuleIntegrator::ConnectMarketAnalysis() {
    LogIntegrationEvent("Connecting market analysis modules...", LOG_LEVEL_INFO);
    
    bool success = true;
    
    success &= ValidateMarketProfile();
    success &= ValidateAssetDNA();
    
    return success;
}

//+------------------------------------------------------------------+
//| Validate Market Profile                                          |
//+------------------------------------------------------------------+
bool CModuleIntegrator::ValidateMarketProfile() {
    if (m_pContext->pMarketProfile == NULL) {
        UpdateModuleStatus("MarketProfile", MODULE_ERROR, "MarketProfile is NULL");
        return false;
    }
    
    UpdateModuleStatus("MarketProfile", MODULE_READY, "MarketProfile connected");
    return true;
}

//+------------------------------------------------------------------+
//| Validate Asset DNA                                               |
//+------------------------------------------------------------------+
bool CModuleIntegrator::ValidateAssetDNA() {
    if (m_pContext->pAssetDNA == NULL) {
        UpdateModuleStatus("AssetDNA", MODULE_ERROR, "AssetDNA is NULL");
        return false;
    }
    
    UpdateModuleStatus("AssetDNA", MODULE_READY, "AssetDNA connected");
    return true;
}

//+------------------------------------------------------------------+
//| Connect Signal Generation                                        |
//+------------------------------------------------------------------+
bool CModuleIntegrator::ConnectSignalGeneration() {
    LogIntegrationEvent("Connecting signal generation...", LOG_LEVEL_INFO);
    
    return ValidateSignalEngine();
}

//+------------------------------------------------------------------+
//| Validate Signal Engine                                           |
//+------------------------------------------------------------------+
bool CModuleIntegrator::ValidateSignalEngine() {
    if (m_pContext->pSignalEngine == NULL) {
        UpdateModuleStatus("SignalEngine", MODULE_ERROR, "SignalEngine is NULL");
        return false;
    }
    
    UpdateModuleStatus("SignalEngine", MODULE_READY, "SignalEngine connected");
    return true;
}

//+------------------------------------------------------------------+
//| Connect Risk Management                                          |
//+------------------------------------------------------------------+
bool CModuleIntegrator::ConnectRiskManagement() {
    LogIntegrationEvent("Connecting risk management...", LOG_LEVEL_INFO);
    
    return ValidateRiskManager();
}

//+------------------------------------------------------------------+
//| Validate Risk Manager                                            |
//+------------------------------------------------------------------+
bool CModuleIntegrator::ValidateRiskManager() {
    if (m_pContext->pRiskManager == NULL) {
        UpdateModuleStatus("RiskManager", MODULE_ERROR, "RiskManager is NULL");
        return false;
    }
    
    UpdateModuleStatus("RiskManager", MODULE_READY, "RiskManager connected");
    return true;
}

//+------------------------------------------------------------------+
//| Connect Trade Management                                         |
//+------------------------------------------------------------------+
bool CModuleIntegrator::ConnectTradeManagement() {
    LogIntegrationEvent("Connecting trade management...", LOG_LEVEL_INFO);
    
    return ValidateTradeManager();
}

//+------------------------------------------------------------------+
//| Validate Trade Manager                                           |
//+------------------------------------------------------------------+
bool CModuleIntegrator::ValidateTradeManager() {
    if (m_pContext->pTradeManager == NULL) {
        UpdateModuleStatus("TradeManager", MODULE_ERROR, "TradeManager is NULL");
        return false;
    }
    
    UpdateModuleStatus("TradeManager", MODULE_READY, "TradeManager connected");
    return true;
}

//+------------------------------------------------------------------+
//| Connect Analytics                                                |
//+------------------------------------------------------------------+
bool CModuleIntegrator::ConnectAnalytics() {
    LogIntegrationEvent("Connecting analytics...", LOG_LEVEL_INFO);
    
    return ValidatePerformanceTracker();
}

//+------------------------------------------------------------------+
//| Validate Performance Tracker                                     |
//+------------------------------------------------------------------+
bool CModuleIntegrator::ValidatePerformanceTracker() {
    if (m_pContext->pPerformanceTracker == NULL) {
        UpdateModuleStatus("PerformanceTracker", MODULE_ERROR, "PerformanceTracker is NULL");
        return false;
    }
    
    UpdateModuleStatus("PerformanceTracker", MODULE_READY, "PerformanceTracker connected");
    return true;
}

//+------------------------------------------------------------------+
//| Connect UI                                                       |
//+------------------------------------------------------------------+
bool CModuleIntegrator::ConnectUI() {
    LogIntegrationEvent("Connecting UI modules...", LOG_LEVEL_INFO);
    
    return ValidateDashboard();
}

//+------------------------------------------------------------------+
//| Validate Dashboard                                               |
//+------------------------------------------------------------------+
bool CModuleIntegrator::ValidateDashboard() {
    if (m_pContext->pDashboard == NULL) {
        UpdateModuleStatus("Dashboard", MODULE_ERROR, "Dashboard is NULL");
        return false;
    }
    
    UpdateModuleStatus("Dashboard", MODULE_READY, "Dashboard connected");
    return true;
}

//+------------------------------------------------------------------+
//| Validate Integration                                             |
//+------------------------------------------------------------------+
bool CModuleIntegrator::ValidateIntegration() {
    LogIntegrationEvent("Validating integration...", LOG_LEVEL_INFO);
    
    bool isValid = true;
    int requiredModules = 0;
    int readyRequired = 0;
    
    for (int i = 0; i < m_ModuleCount; i++) {
        if (m_ModuleStatus[i].isRequired) {
            requiredModules++;
            if (m_ModuleStatus[i].status == MODULE_READY) {
                readyRequired++;
            }
        }
    }
    
    isValid = (readyRequired == requiredModules);
    
    LogIntegrationEvent(StringFormat("Integration validation: %d/%d required modules ready", 
        readyRequired, requiredModules), isValid ? LOG_LEVEL_INFO : LOG_LEVEL_ERROR);
    
    return isValid;
}

//+------------------------------------------------------------------+
//| Perform Health Check                                             |
//+------------------------------------------------------------------+
bool CModuleIntegrator::PerformHealthCheck() {
    m_Health.Clear();
    m_Health.lastHealthCheck = TimeCurrent();
    
    // Count module status
    for (int i = 0; i < m_ModuleCount; i++) {
        m_Health.totalModules++;
        
        switch (m_ModuleStatus[i].status) {
            case MODULE_READY:
                m_Health.readyModules++;
                break;
            case MODULE_ERROR:
                m_Health.errorModules++;
                break;
        }
    }
    
    // Calculate health score
    m_Health.healthScore = CalculateHealthScore();
    
    // Determine overall status
    if (m_Health.errorModules == 0 && m_Health.readyModules == m_Health.totalModules) {
        m_Health.overallStatus = INTEGRATION_COMPLETE;
        m_Health.canTrade = true;
        m_Health.statusMessage = "All systems operational";
    } else if (m_Health.readyModules >= m_Health.totalModules * 0.8) {
        m_Health.overallStatus = INTEGRATION_PARTIAL;
        m_Health.canTrade = ValidateIntegration(); // Check if required modules are ready
        m_Health.statusMessage = "Partial integration - some optional modules offline";
    } else {
        m_Health.overallStatus = INTEGRATION_ERROR;
        m_Health.canTrade = false;
        m_Health.statusMessage = "Critical integration errors detected";
    }
    
    return m_Health.canTrade;
}

//+------------------------------------------------------------------+
//| Calculate Health Score                                           |
//+------------------------------------------------------------------+
double CModuleIntegrator::CalculateHealthScore() {
    if (m_Health.totalModules == 0) {
        return 0.0;
    }
    
    double score = 0.0;
    
    // Ready modules weight
    score += ((double)m_Health.readyModules / m_Health.totalModules) * 0.7;
    
    // Error penalty
    if (m_Health.errorModules > 0) {
        score -= ((double)m_Health.errorModules / m_Health.totalModules) * 0.3;
    }
    
    // Required modules bonus
    int requiredReady = 0;
    int totalRequired = 0;
    
    for (int i = 0; i < m_ModuleCount; i++) {
        if (m_ModuleStatus[i].isRequired) {
            totalRequired++;
            if (m_ModuleStatus[i].status == MODULE_READY) {
                requiredReady++;
            }
        }
    }
    
    if (totalRequired > 0 && requiredReady == totalRequired) {
        score += 0.3; // Bonus for all required modules ready
    }
    
    return MathMax(0.0, MathMin(1.0, score));
}

//+------------------------------------------------------------------+
//| Update Module Status                                             |
//+------------------------------------------------------------------+
void CModuleIntegrator::UpdateModuleStatus(const string& moduleName, ENUM_MODULE_STATUS status, const string& message = "") {
    int index = FindModuleIndex(moduleName);
    if (index >= 0) {
        m_ModuleStatus[index].status = status;
        m_ModuleStatus[index].isConnected = (status == MODULE_READY);
        m_ModuleStatus[index].lastUpdate = TimeCurrent();
        m_ModuleStatus[index].errorMessage = message;
        
        LogIntegrationEvent(StringFormat("Module %s: %s - %s", 
            moduleName, StatusToString(status), message), 
            (status == MODULE_ERROR) ? LOG_LEVEL_ERROR : LOG_LEVEL_INFO);
    }
}

//+------------------------------------------------------------------+
//| Find Module Index                                                |
//+------------------------------------------------------------------+
int CModuleIntegrator::FindModuleIndex(const string& moduleName) {
    for (int i = 0; i < m_ModuleCount; i++) {
        if (m_ModuleStatus[i].moduleName == moduleName) {
            return i;
        }
    }
    return -1;
}

//+------------------------------------------------------------------+
//| Get Integration Health                                           |
//+------------------------------------------------------------------+
SIntegrationHealth CModuleIntegrator::GetIntegrationHealth() {
    // Update health if needed
    if (TimeCurrent() - m_Health.lastHealthCheck > HEALTH_CHECK_INTERVAL) {
        PerformHealthCheck();
    }
    
    return m_Health;
}

//+------------------------------------------------------------------+
//| Get Integration Summary                                          |
//+------------------------------------------------------------------+
string CModuleIntegrator::GetIntegrationSummary() {
    SIntegrationHealth health = GetIntegrationHealth();
    
    string summary = "=== INTEGRATION SUMMARY ===\n";
    summary += StringFormat("Status: %s\n", IntegrationStatusToString(health.overallStatus));
    summary += StringFormat("Health Score: %.1f%%\n", health.healthScore * 100);
    summary += StringFormat("Modules: %d/%d Ready, %d Errors\n", 
        health.readyModules, health.totalModules, health.errorModules);
    summary += StringFormat("Can Trade: %s\n", health.canTrade ? "Yes" : "No");
    summary += StringFormat("Message: %s\n", health.statusMessage);
    summary += "========================\n";
    
    return summary;
}

//+------------------------------------------------------------------+
//| Status to String                                                 |
//+------------------------------------------------------------------+
string CModuleIntegrator::StatusToString(ENUM_MODULE_STATUS status) {
    switch (status) {
        case MODULE_UNINITIALIZED: return "UNINITIALIZED";
        case MODULE_INITIALIZING: return "INITIALIZING";
        case MODULE_READY: return "READY";
        case MODULE_ERROR: return "ERROR";
        case MODULE_DISABLED: return "DISABLED";
        default: return "UNKNOWN";
    }
}

//+------------------------------------------------------------------+
//| Integration Status to String                                     |
//+------------------------------------------------------------------+
string CModuleIntegrator::IntegrationStatusToString(ENUM_INTEGRATION_STATUS status) {
    switch (status) {
        case INTEGRATION_UNINITIALIZED: return "UNINITIALIZED";
        case INTEGRATION_INITIALIZING: return "INITIALIZING";
        case INTEGRATION_PARTIAL: return "PARTIAL";
        case INTEGRATION_COMPLETE: return "COMPLETE";
        case INTEGRATION_ERROR: return "ERROR";
        case INTEGRATION_DISCONNECTED: return "DISCONNECTED";
        default: return "UNKNOWN";
    }
}

//+------------------------------------------------------------------+
//| Log Integration Event                                            |
//+------------------------------------------------------------------+
void CModuleIntegrator::LogIntegrationEvent(const string& event, ENUM_LOG_LEVEL level = LOG_LEVEL_INFO) {
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
        }
    } else {
        Print("[ModuleIntegrator] " + event);
    }
}

//+------------------------------------------------------------------+
//| Reset Integration State                                          |
//+------------------------------------------------------------------+
void CModuleIntegrator::ResetIntegrationState() {
    m_Health.Clear();
    m_IntegrationRetries = 0;
    
    // Reset all module status
    for (int i = 0; i < m_ModuleCount; i++) {
        m_ModuleStatus[i].status = MODULE_UNINITIALIZED;
        m_ModuleStatus[i].isConnected = false;
        m_ModuleStatus[i].errorMessage = "";
        m_ModuleStatus[i].retryCount = 0;
    }
}

//+------------------------------------------------------------------+
//| Add Dependency                                                   |
//+------------------------------------------------------------------+
bool CModuleIntegrator::AddDependency(const string& module, const string& dependency) {
    if (m_DependencyCount >= MAX_DEPENDENCIES) {
        return false;
    }
    
    ArrayResize(m_Dependencies[m_DependencyCount], 2);
    m_Dependencies[m_DependencyCount][0] = module;
    m_Dependencies[m_DependencyCount][1] = dependency;
    m_DependencyCount++;
    
    return true;
}

//+------------------------------------------------------------------+
//| Resolve Dependencies                                             |
//+------------------------------------------------------------------+
bool CModuleIntegrator::ResolveDependencies() {
    LogIntegrationEvent("Resolving module dependencies...", LOG_LEVEL_INFO);
    
    bool allResolved = true;
    
    // Check each module's dependencies
    for (int i = 0; i < m_ModuleCount; i++) {
        string moduleName = m_ModuleStatus[i].moduleName;
        
        // Check all dependencies for this module
        for (int j = 0; j < m_DependencyCount; j++) {
            if (m_Dependencies[j][0] == moduleName) {
                string dependency = m_Dependencies[j][1];
                
                if (!IsModuleReady(dependency)) {
                    LogIntegrationEvent(StringFormat("Dependency not met: %s requires %s", 
                        moduleName, dependency), LOG_LEVEL_WARNING);
                    allResolved = false;
                }
            }
        }
    }
    
    if (allResolved) {
        LogIntegrationEvent("All dependencies resolved", LOG_LEVEL_INFO);
    } else {
        LogIntegrationEvent("Some dependencies not resolved", LOG_LEVEL_WARNING);
    }
    
    return allResolved;
}

//+------------------------------------------------------------------+
//| Is Module Ready                                                  |
//+------------------------------------------------------------------+
bool CModuleIntegrator::IsModuleReady(const string& moduleName) {
    int index = FindModuleIndex(moduleName);
    if (index >= 0) {
        return (m_ModuleStatus[index].status == MODULE_READY);
    }
    return false;
}

//+------------------------------------------------------------------+
//| Can Execute Trades                                               |
//+------------------------------------------------------------------+
bool CModuleIntegrator::CanExecuteTrades() {
    SIntegrationHealth health = GetIntegrationHealth();
    return health.canTrade;
}

} // namespace ApexPullback::v5

#endif // MODULE_INTEGRATOR_MQH_ 