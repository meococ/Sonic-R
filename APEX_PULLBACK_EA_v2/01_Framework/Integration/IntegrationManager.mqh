//+------------------------------------------------------------------+
//|                                          IntegrationManager.mqh |
//|                 IntegrationManager - APEX Pullback EA v5 FINAL  |
//|      Description: High-level integration management layer       |
//|                   that coordinates module integration,          |
//|                   dependency resolution, and system health      |
//+------------------------------------------------------------------+

#ifndef INTEGRATION_MANAGER_MQH_
#define INTEGRATION_MANAGER_MQH_

#include "ModuleIntegrator.mqh"
#include "..\..\00_Core\CommonStructs.mqh"

//+------------------------------------------------------------------+
//| Integration Events                                               |
//+------------------------------------------------------------------+
enum ENUM_INTEGRATION_EVENT {
    INTEGRATION_EVENT_STARTED,
    INTEGRATION_EVENT_MODULE_CONNECTED,
    INTEGRATION_EVENT_MODULE_DISCONNECTED,
    INTEGRATION_EVENT_DEPENDENCY_RESOLVED,
    INTEGRATION_EVENT_DEPENDENCY_FAILED,
    INTEGRATION_EVENT_HEALTH_CHECK,
    INTEGRATION_EVENT_ERROR_DETECTED,
    INTEGRATION_EVENT_RECOVERY_STARTED,
    INTEGRATION_EVENT_RECOVERY_COMPLETED,
    INTEGRATION_EVENT_COMPLETE
};

struct SIntegrationEvent {
    ENUM_INTEGRATION_EVENT eventType;      // Event type
    string                module;          // Module name
    string                message;         // Event message
    datetime              timestamp;       // Event timestamp
    ENUM_LOG_LEVEL        severity;        // Event severity
    
    void Clear() {
        eventType = INTEGRATION_EVENT_STARTED;
        module = "";
        message = "";
        timestamp = 0;
        severity = LOG_LEVEL_INFO;
    }
};

//+------------------------------------------------------------------+
//| Integration Configuration                                        |
//+------------------------------------------------------------------+
struct SIntegrationConfig {
    bool                  autoRecovery;         // Enable automatic recovery
    int                   healthCheckInterval;  // Health check interval (seconds)
    int                   maxRetries;           // Maximum retry attempts
    int                   retryDelay;           // Delay between retries (seconds)
    bool                  strictMode;           // Strict dependency checking
    bool                  enableLogging;        // Enable detailed logging
    bool                  enableDashboard;      // Enable integration dashboard
    
    void SetDefaults() {
        autoRecovery = true;
        healthCheckInterval = 30;
        maxRetries = 3;
        retryDelay = 5;
        strictMode = true;
        enableLogging = true;
        enableDashboard = true;
    }
};

//+------------------------------------------------------------------+
//| CIntegrationManager - High-Level Integration Controller         |
//+------------------------------------------------------------------+
class CIntegrationManager {
private:
    EAContext*            m_pContext;        // Reference to EA context
    CModuleIntegrator*    m_pIntegrator;     // Module integrator instance
    bool                  m_bInitialized;   // Initialization status
    
    // Configuration
    SIntegrationConfig    m_Config;          // Integration configuration
    
    // Event tracking
    SIntegrationEvent     m_EventHistory[];  // Event history
    int                   m_EventCount;      // Number of events
    
    // Status tracking
    bool                  m_SystemReady;     // System ready status
    bool                  m_TradingEnabled;  // Trading enabled status
    datetime              m_LastHealthCheck; // Last health check time
    datetime              m_IntegrationStartTime; // Integration start time
    
    // Constants
    static const int      MAX_EVENTS = 100;
    
public:
    //--- Constructor/Destructor ---
    CIntegrationManager();
    ~CIntegrationManager();
    
    //--- Initialization ---
    bool                  Initialize(EAContext* pContext, const SIntegrationConfig& config);
    void                  Deinitialize();
    bool                  IsInitialized() const { return m_bInitialized; }
    
    //--- Integration Control ---
    bool                  StartIntegration();
    bool                  StopIntegration();
    bool                  RestartIntegration();
    bool                  ValidateSystem();
    
    //--- System Status ---
    bool                  IsSystemReady() const { return m_SystemReady; }
    bool                  IsTradingEnabled() const { return m_TradingEnabled; }
    bool                  CanExecuteTrades();
    SIntegrationHealth    GetSystemHealth();
    
    //--- Module Management ---
    bool                  IsModuleConnected(const string& moduleName);
    ENUM_MODULE_STATUS    GetModuleStatus(const string& moduleName);
    bool                  ReconnectModule(const string& moduleName);
    bool                  DisableModule(const string& moduleName);
    
    //--- Health Monitoring ---
    void                  UpdateSystemHealth();
    bool                  PerformSystemCheck();
    void                  HandleSystemError(const string& error);
    bool                  AttemptSystemRecovery();
    
    //--- Event Management ---
    void                  LogIntegrationEvent(ENUM_INTEGRATION_EVENT eventType, 
                                            const string& module, 
                                            const string& message, 
                                            ENUM_LOG_LEVEL severity = LOG_LEVEL_INFO);
    SIntegrationEvent     GetLastEvent();
    int                   GetEventCount() const { return m_EventCount; }
    
    //--- Configuration ---
    void                  SetConfiguration(const SIntegrationConfig& config) { m_Config = config; }
    SIntegrationConfig    GetConfiguration() const { return m_Config; }
    void                  EnableAutoRecovery(bool enable) { m_Config.autoRecovery = enable; }
    void                  SetHealthCheckInterval(int seconds) { m_Config.healthCheckInterval = seconds; }
    
    //--- Status Information ---
    string                GetSystemSummary();
    string                GetIntegrationReport();
    void                  PrintSystemDashboard();
    
    //--- Core Interface Methods ---
    bool                  OnTick();           // Called from Core::OnTick()
    bool                  OnTimer();          // Called from Core::OnTimer()
    void                  OnNewBar();         // Called when new bar detected
    
private:
    //--- Internal Methods ---
    void                  InitializeEventHistory();
    void                  AddEvent(const SIntegrationEvent& event);
    void                  PerformPeriodicChecks();
    void                  UpdateTradingStatus();
    
    //--- Recovery Methods ---
    bool                  DiagnoseSystemIssues();
    bool                  RecoverCriticalModules();
    bool                  RestoreConnections();
    
    //--- Utility Methods ---
    string                EventTypeToString(ENUM_INTEGRATION_EVENT eventType);
    bool                  IsTimeForHealthCheck();
    void                  NotifySystemEvent(const string& message, ENUM_LOG_LEVEL level);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CIntegrationManager::CIntegrationManager() {
    m_pContext = NULL;
    m_pIntegrator = NULL;
    m_bInitialized = false;
    m_SystemReady = false;
    m_TradingEnabled = false;
    m_EventCount = 0;
    m_LastHealthCheck = 0;
    m_IntegrationStartTime = 0;
    
    // Set default configuration
    m_Config.SetDefaults();
    
    // Initialize event history
    ArrayResize(m_EventHistory, MAX_EVENTS);
    InitializeEventHistory();
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CIntegrationManager::~CIntegrationManager() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize Integration Manager                                   |
//+------------------------------------------------------------------+
bool CIntegrationManager::Initialize(EAContext* pContext, const SIntegrationConfig& config) {
    if (m_bInitialized) {
        return true;
    }
    
    if (pContext == NULL) {
        Print("[IntegrationManager] ERROR: Context is NULL");
        return false;
    }
    
    m_pContext = pContext;
    m_Config = config;
    
    // Create module integrator
    m_pIntegrator = new CModuleIntegrator();
    if (m_pIntegrator == NULL) {
        NotifySystemEvent("Failed to create ModuleIntegrator", LOG_LEVEL_ERROR);
        return false;
    }
    
    // Initialize module integrator
    if (!m_pIntegrator.Initialize(pContext)) {
        NotifySystemEvent("Failed to initialize ModuleIntegrator", LOG_LEVEL_ERROR);
        delete m_pIntegrator;
        m_pIntegrator = NULL;
        return false;
    }
    
    m_bInitialized = true;
    m_IntegrationStartTime = TimeCurrent();
    
    LogIntegrationEvent(INTEGRATION_EVENT_STARTED, "System", 
        "Integration Manager initialized", LOG_LEVEL_INFO);
    
    NotifySystemEvent("Integration Manager initialized successfully", LOG_LEVEL_INFO);
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize Integration Manager                                 |
//+------------------------------------------------------------------+
void CIntegrationManager::Deinitialize() {
    if (!m_bInitialized) {
        return;
    }
    
    NotifySystemEvent("Shutting down Integration Manager", LOG_LEVEL_INFO);
    
    // Stop integration
    StopIntegration();
    
    // Clean up integrator
    if (m_pIntegrator != NULL) {
        m_pIntegrator.Deinitialize();
        delete m_pIntegrator;
        m_pIntegrator = NULL;
    }
    
    m_bInitialized = false;
    m_SystemReady = false;
    m_TradingEnabled = false;
    
    NotifySystemEvent("Integration Manager shutdown complete", LOG_LEVEL_INFO);
}

//+------------------------------------------------------------------+
//| Start Integration Process                                        |
//+------------------------------------------------------------------+
bool CIntegrationManager::StartIntegration() {
    if (!m_bInitialized || m_pIntegrator == NULL) {
        return false;
    }
    
    LogIntegrationEvent(INTEGRATION_EVENT_STARTED, "System", 
        "Starting system integration", LOG_LEVEL_INFO);
    
    NotifySystemEvent("Starting system integration...", LOG_LEVEL_INFO);
    
    // Start module integration
    bool success = m_pIntegrator.IntegrateAllModules();
    
    if (success) {
        m_SystemReady = true;
        LogIntegrationEvent(INTEGRATION_EVENT_COMPLETE, "System", 
            "System integration completed successfully", LOG_LEVEL_INFO);
        NotifySystemEvent("System integration completed successfully", LOG_LEVEL_INFO);
    } else {
        LogIntegrationEvent(INTEGRATION_EVENT_ERROR_DETECTED, "System", 
            "System integration completed with errors", LOG_LEVEL_WARNING);
        NotifySystemEvent("System integration completed with errors", LOG_LEVEL_WARNING);
    }
    
    // Update trading status
    UpdateTradingStatus();
    
    // Perform initial health check
    PerformSystemCheck();
    
    return success;
}

//+------------------------------------------------------------------+
//| Stop Integration                                                 |
//+------------------------------------------------------------------+
bool CIntegrationManager::StopIntegration() {
    if (!m_bInitialized) {
        return false;
    }
    
    NotifySystemEvent("Stopping system integration", LOG_LEVEL_INFO);
    
    m_SystemReady = false;
    m_TradingEnabled = false;
    
    LogIntegrationEvent(INTEGRATION_EVENT_COMPLETE, "System", 
        "System integration stopped", LOG_LEVEL_INFO);
    
    return true;
}

//+------------------------------------------------------------------+
//| Restart Integration                                              |
//+------------------------------------------------------------------+
bool CIntegrationManager::RestartIntegration() {
    NotifySystemEvent("Restarting system integration", LOG_LEVEL_INFO);
    
    StopIntegration();
    Sleep(m_Config.retryDelay * 1000); // Wait before restart
    
    return StartIntegration();
}

//+------------------------------------------------------------------+
//| Validate System                                                  |
//+------------------------------------------------------------------+
bool CIntegrationManager::ValidateSystem() {
    if (!m_bInitialized || m_pIntegrator == NULL) {
        return false;
    }
    
    return m_pIntegrator.ValidateIntegration();
}

//+------------------------------------------------------------------+
//| Can Execute Trades                                               |
//+------------------------------------------------------------------+
bool CIntegrationManager::CanExecuteTrades() {
    if (!m_bInitialized || m_pIntegrator == NULL) {
        return false;
    }
    
    return m_SystemReady && m_TradingEnabled && m_pIntegrator.CanExecuteTrades();
}

//+------------------------------------------------------------------+
//| Get System Health                                                |
//+------------------------------------------------------------------+
SIntegrationHealth CIntegrationManager::GetSystemHealth() {
    if (!m_bInitialized || m_pIntegrator == NULL) {
        SIntegrationHealth health;
        health.Clear();
        return health;
    }
    
    return m_pIntegrator.GetIntegrationHealth();
}

//+------------------------------------------------------------------+
//| Update System Health                                             |
//+------------------------------------------------------------------+
void CIntegrationManager::UpdateSystemHealth() {
    if (!m_bInitialized) {
        return;
    }
    
    // Perform health check if needed
    if (IsTimeForHealthCheck()) {
        PerformSystemCheck();
    }
    
    // Update trading status
    UpdateTradingStatus();
}

//+------------------------------------------------------------------+
//| Perform System Check                                             |
//+------------------------------------------------------------------+
bool CIntegrationManager::PerformSystemCheck() {
    if (!m_bInitialized || m_pIntegrator == NULL) {
        return false;
    }
    
    bool healthy = m_pIntegrator.PerformHealthCheck();
    m_LastHealthCheck = TimeCurrent();
    
    LogIntegrationEvent(INTEGRATION_EVENT_HEALTH_CHECK, "System", 
        StringFormat("Health check completed - Status: %s", healthy ? "Healthy" : "Issues detected"), 
        healthy ? LOG_LEVEL_INFO : LOG_LEVEL_WARNING);
    
    // Attempt recovery if needed
    if (!healthy && m_Config.autoRecovery) {
        AttemptSystemRecovery();
    }
    
    return healthy;
}

//+------------------------------------------------------------------+
//| Update Trading Status                                            |
//+------------------------------------------------------------------+
void CIntegrationManager::UpdateTradingStatus() {
    bool previousStatus = m_TradingEnabled;
    
    m_TradingEnabled = m_SystemReady && CanExecuteTrades();
    
    // Log status change
    if (previousStatus != m_TradingEnabled) {
        string message = m_TradingEnabled ? "Trading enabled" : "Trading disabled";
        LogIntegrationEvent(m_TradingEnabled ? INTEGRATION_EVENT_MODULE_CONNECTED : INTEGRATION_EVENT_MODULE_DISCONNECTED,
            "Trading", message, LOG_LEVEL_INFO);
    }
}

//+------------------------------------------------------------------+
//| Attempt System Recovery                                          |
//+------------------------------------------------------------------+
bool CIntegrationManager::AttemptSystemRecovery() {
    LogIntegrationEvent(INTEGRATION_EVENT_RECOVERY_STARTED, "System", 
        "Starting system recovery", LOG_LEVEL_INFO);
    
    NotifySystemEvent("Attempting system recovery...", LOG_LEVEL_WARNING);
    
    bool recovered = false;
    
    // Step 1: Diagnose issues
    if (DiagnoseSystemIssues()) {
        // Step 2: Recover critical modules
        if (RecoverCriticalModules()) {
            // Step 3: Restore connections
            if (RestoreConnections()) {
                recovered = true;
            }
        }
    }
    
    if (recovered) {
        LogIntegrationEvent(INTEGRATION_EVENT_RECOVERY_COMPLETED, "System", 
            "System recovery completed successfully", LOG_LEVEL_INFO);
        NotifySystemEvent("System recovery completed successfully", LOG_LEVEL_INFO);
    } else {
        LogIntegrationEvent(INTEGRATION_EVENT_ERROR_DETECTED, "System", 
            "System recovery failed", LOG_LEVEL_ERROR);
        NotifySystemEvent("System recovery failed", LOG_LEVEL_ERROR);
    }
    
    return recovered;
}

//+------------------------------------------------------------------+
//| Diagnose System Issues                                           |
//+------------------------------------------------------------------+
bool CIntegrationManager::DiagnoseSystemIssues() {
    if (!m_bInitialized || m_pIntegrator == NULL) {
        return false;
    }
    
    NotifySystemEvent("Diagnosing system issues...", LOG_LEVEL_INFO);
    
    SIntegrationHealth health = GetSystemHealth();
    
    if (health.errorModules > 0) {
        NotifySystemEvent(StringFormat("Detected %d module errors", health.errorModules), LOG_LEVEL_WARNING);
        return true;
    }
    
    if (health.healthScore < 0.8) {
        NotifySystemEvent(StringFormat("System health below threshold: %.1f%%", health.healthScore * 100), LOG_LEVEL_WARNING);
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Recover Critical Modules                                         |
//+------------------------------------------------------------------+
bool CIntegrationManager::RecoverCriticalModules() {
    NotifySystemEvent("Recovering critical modules...", LOG_LEVEL_INFO);
    
    // List of critical modules
    string criticalModules[] = {"Logger", "ErrorHandler", "SymbolManager", "TimeManager", "SignalEngine", "RiskManager", "TradeManager"};
    
    bool allRecovered = true;
    
    for (int i = 0; i < ArraySize(criticalModules); i++) {
        if (!IsModuleConnected(criticalModules[i])) {
            if (!ReconnectModule(criticalModules[i])) {
                allRecovered = false;
                NotifySystemEvent(StringFormat("Failed to recover critical module: %s", criticalModules[i]), LOG_LEVEL_ERROR);
            }
        }
    }
    
    return allRecovered;
}

//+------------------------------------------------------------------+
//| Restore Connections                                              |
//+------------------------------------------------------------------+
bool CIntegrationManager::RestoreConnections() {
    NotifySystemEvent("Restoring module connections...", LOG_LEVEL_INFO);
    
    if (m_pIntegrator == NULL) {
        return false;
    }
    
    return m_pIntegrator.RepairBrokenConnections();
}

//+------------------------------------------------------------------+
//| On Tick Event                                                    |
//+------------------------------------------------------------------+
bool CIntegrationManager::OnTick() {
    if (!m_bInitialized) {
        return false;
    }
    
    // Perform periodic checks
    PerformPeriodicChecks();
    
    return true;
}

//+------------------------------------------------------------------+
//| On Timer Event                                                   |
//+------------------------------------------------------------------+
bool CIntegrationManager::OnTimer() {
    if (!m_bInitialized) {
        return false;
    }
    
    // Update system health
    UpdateSystemHealth();
    
    return true;
}

//+------------------------------------------------------------------+
//| Perform Periodic Checks                                          |
//+------------------------------------------------------------------+
void CIntegrationManager::PerformPeriodicChecks() {
    // Check if health check is needed
    if (IsTimeForHealthCheck()) {
        PerformSystemCheck();
    }
}

//+------------------------------------------------------------------+
//| Is Time for Health Check                                         |
//+------------------------------------------------------------------+
bool CIntegrationManager::IsTimeForHealthCheck() {
    return (TimeCurrent() - m_LastHealthCheck >= m_Config.healthCheckInterval);
}

//+------------------------------------------------------------------+
//| Is Module Connected                                              |
//+------------------------------------------------------------------+
bool CIntegrationManager::IsModuleConnected(const string& moduleName) {
    if (!m_bInitialized || m_pIntegrator == NULL) {
        return false;
    }
    
    return m_pIntegrator.IsModuleReady(moduleName);
}

//+------------------------------------------------------------------+
//| Get Module Status                                                |
//+------------------------------------------------------------------+
ENUM_MODULE_STATUS CIntegrationManager::GetModuleStatus(const string& moduleName) {
    if (!m_bInitialized || m_pIntegrator == NULL) {
        return MODULE_ERROR;
    }
    
    return m_pIntegrator.GetModuleStatus(moduleName);
}

//+------------------------------------------------------------------+
//| Reconnect Module                                                 |
//+------------------------------------------------------------------+
bool CIntegrationManager::ReconnectModule(const string& moduleName) {
    if (!m_bInitialized || m_pIntegrator == NULL) {
        return false;
    }
    
    LogIntegrationEvent(INTEGRATION_EVENT_MODULE_CONNECTED, moduleName, 
        "Attempting to reconnect module", LOG_LEVEL_INFO);
    
    bool success = m_pIntegrator.ConnectModule(moduleName);
    
    if (success) {
        LogIntegrationEvent(INTEGRATION_EVENT_MODULE_CONNECTED, moduleName, 
            "Module reconnected successfully", LOG_LEVEL_INFO);
    } else {
        LogIntegrationEvent(INTEGRATION_EVENT_ERROR_DETECTED, moduleName, 
            "Module reconnection failed", LOG_LEVEL_ERROR);
    }
    
    return success;
}

//+------------------------------------------------------------------+
//| Log Integration Event                                            |
//+------------------------------------------------------------------+
void CIntegrationManager::LogIntegrationEvent(ENUM_INTEGRATION_EVENT eventType, 
                                             const string& module, 
                                             const string& message, 
                                             ENUM_LOG_LEVEL severity = LOG_LEVEL_INFO) {
    SIntegrationEvent event;
    event.eventType = eventType;
    event.module = module;
    event.message = message;
    event.timestamp = TimeCurrent();
    event.severity = severity;
    
    AddEvent(event);
    
    // Log to system logger
    NotifySystemEvent(StringFormat("[%s] %s: %s", module, EventTypeToString(eventType), message), severity);
}

//+------------------------------------------------------------------+
//| Add Event to History                                             |
//+------------------------------------------------------------------+
void CIntegrationManager::AddEvent(const SIntegrationEvent& event) {
    if (m_EventCount >= MAX_EVENTS) {
        // Shift array to make room for new event
        for (int i = 0; i < MAX_EVENTS - 1; i++) {
            m_EventHistory[i] = m_EventHistory[i + 1];
        }
        m_EventCount = MAX_EVENTS - 1;
    }
    
    m_EventHistory[m_EventCount] = event;
    m_EventCount++;
}

//+------------------------------------------------------------------+
//| Initialize Event History                                         |
//+------------------------------------------------------------------+
void CIntegrationManager::InitializeEventHistory() {
    for (int i = 0; i < MAX_EVENTS; i++) {
        m_EventHistory[i].Clear();
    }
    m_EventCount = 0;
}

//+------------------------------------------------------------------+
//| Get System Summary                                               |
//+------------------------------------------------------------------+
string CIntegrationManager::GetSystemSummary() {
    string summary = "=== SYSTEM INTEGRATION STATUS ===\n";
    summary += StringFormat("System Ready: %s\n", m_SystemReady ? "Yes" : "No");
    summary += StringFormat("Trading Enabled: %s\n", m_TradingEnabled ? "Yes" : "No");
    summary += StringFormat("Can Execute Trades: %s\n", CanExecuteTrades() ? "Yes" : "No");
    
    if (m_pIntegrator != NULL) {
        SIntegrationHealth health = GetSystemHealth();
        summary += StringFormat("Health Score: %.1f%%\n", health.healthScore * 100);
        summary += StringFormat("Modules Ready: %d/%d\n", health.readyModules, health.totalModules);
        summary += StringFormat("Integration Status: %s\n", health.statusMessage);
    }
    
    summary += "==============================\n";
    
    return summary;
}

//+------------------------------------------------------------------+
//| Event Type to String                                             |
//+------------------------------------------------------------------+
string CIntegrationManager::EventTypeToString(ENUM_INTEGRATION_EVENT eventType) {
    switch (eventType) {
        case INTEGRATION_EVENT_STARTED: return "STARTED";
        case INTEGRATION_EVENT_MODULE_CONNECTED: return "MODULE_CONNECTED";
        case INTEGRATION_EVENT_MODULE_DISCONNECTED: return "MODULE_DISCONNECTED";
        case INTEGRATION_EVENT_DEPENDENCY_RESOLVED: return "DEPENDENCY_RESOLVED";
        case INTEGRATION_EVENT_DEPENDENCY_FAILED: return "DEPENDENCY_FAILED";
        case INTEGRATION_EVENT_HEALTH_CHECK: return "HEALTH_CHECK";
        case INTEGRATION_EVENT_ERROR_DETECTED: return "ERROR_DETECTED";
        case INTEGRATION_EVENT_RECOVERY_STARTED: return "RECOVERY_STARTED";
        case INTEGRATION_EVENT_RECOVERY_COMPLETED: return "RECOVERY_COMPLETED";
        case INTEGRATION_EVENT_COMPLETE: return "COMPLETE";
        default: return "UNKNOWN";
    }
}

//+------------------------------------------------------------------+
//| Notify System Event                                              |
//+------------------------------------------------------------------+
void CIntegrationManager::NotifySystemEvent(const string& message, ENUM_LOG_LEVEL level) {
    if (m_pContext != NULL && m_pContext->pLogger != NULL) {
        switch(level) {
            case LOG_LEVEL_ERROR:
                m_pContext->pLogger->LogError(message, __FUNCTION__);
                break;
            case LOG_LEVEL_WARNING:
                m_pContext->pLogger->LogWarning(message, __FUNCTION__);
                break;
            default:
                m_pContext->pLogger->LogInfo(message, __FUNCTION__);
        }
    } else {
        Print("[IntegrationManager] " + message);
    }
}

} // namespace ApexPullback::v5

#endif // INTEGRATION_MANAGER_MQH_ 