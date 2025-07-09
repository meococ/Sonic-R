//+------------------------------------------------------------------+
//|                                                 EventManager.mqh |
//|                                    APEX Pullback EA v5.0 FINAL   |
//|                                    Advanced Event Management     |
//+------------------------------------------------------------------+
#property copyright "APEX Trading Systems"
#property version   "5.00"
#property strict

#include "../../00_Core/CommonStructs.mqh"

//+------------------------------------------------------------------+
//| Event type enumeration                                          |
//+------------------------------------------------------------------+
enum ENUM_EVENT_TYPE {
    EVENT_TYPE_SYSTEM,
    EVENT_TYPE_TRADE,
    EVENT_TYPE_MARKET,
    EVENT_TYPE_RISK,
    EVENT_TYPE_PERFORMANCE,
    EVENT_TYPE_ERROR,
    EVENT_TYPE_WARNING,
    EVENT_TYPE_INFO,
    EVENT_TYPE_DEBUG,
    EVENT_TYPE_USER,
    EVENT_TYPE_TIMER,
    EVENT_TYPE_NETWORK,
    EVENT_TYPE_DATA,
    EVENT_TYPE_STRATEGY,
    EVENT_TYPE_OPTIMIZATION
};

//+------------------------------------------------------------------+
//| Event priority enumeration                                      |
//+------------------------------------------------------------------+
enum ENUM_EVENT_PRIORITY {
    EVENT_PRIORITY_LOW,
    EVENT_PRIORITY_NORMAL,
    EVENT_PRIORITY_HIGH,
    EVENT_PRIORITY_URGENT,
    EVENT_PRIORITY_CRITICAL
};

//+------------------------------------------------------------------+
//| Event status enumeration                                        |
//+------------------------------------------------------------------+
enum ENUM_EVENT_STATUS {
    EVENT_STATUS_PENDING,
    EVENT_STATUS_PROCESSING,
    EVENT_STATUS_COMPLETED,
    EVENT_STATUS_FAILED,
    EVENT_STATUS_CANCELLED,
    EVENT_STATUS_TIMEOUT
};

//+------------------------------------------------------------------+
//| Event source enumeration                                        |
//+------------------------------------------------------------------+
enum ENUM_EVENT_SOURCE {
    EVENT_SOURCE_EA,
    EVENT_SOURCE_TERMINAL,
    EVENT_SOURCE_BROKER,
    EVENT_SOURCE_MARKET,
    EVENT_SOURCE_USER,
    EVENT_SOURCE_SYSTEM,
    EVENT_SOURCE_EXTERNAL,
    EVENT_SOURCE_TIMER,
    EVENT_SOURCE_INDICATOR,
    EVENT_SOURCE_STRATEGY
};

//+------------------------------------------------------------------+
//| Event structure                                                 |
//+------------------------------------------------------------------+
struct SEvent {
    int ID;
    ENUM_EVENT_TYPE Type;
    ENUM_EVENT_PRIORITY Priority;
    ENUM_EVENT_STATUS Status;
    ENUM_EVENT_SOURCE Source;
    
    datetime CreatedTime;
    datetime ProcessedTime;
    datetime CompletedTime;
    datetime ExpiryTime;
    
    string Name;
    string Description;
    string Category;
    string Module;
    string Function;
    
    // Event data
    string StringData[10];
    double NumericData[10];
    int IntegerData[10];
    bool BooleanData[10];
    
    // Metadata
    string Tags[10];
    int TagCount;
    string CustomProperties[20];
    int PropertyCount;
    
    // Processing info
    int ProcessingAttempts;
    int MaxProcessingAttempts;
    string LastError;
    
    // Relationships
    int ParentEventID;
    int ChildEventIDs[10];
    int ChildEventCount;
    int RelatedEventIDs[10];
    int RelatedEventCount;
    
    // Performance tracking
    double ProcessingTimeMs;
    int MemoryUsageBytes;
    
    // Callback info
    string CallbackFunction;
    bool RequiresCallback;
    bool CallbackExecuted;
};

//+------------------------------------------------------------------+
//| Event handler structure                                         |
//+------------------------------------------------------------------+
struct SEventHandler {
    string Name;
    string Description;
    ENUM_EVENT_TYPE EventType;
    ENUM_EVENT_PRIORITY MinPriority;
    bool IsActive;
    bool IsAsync;
    
    string HandlerFunction;
    string Module;
    
    // Filtering
    string CategoryFilter;
    string SourceFilter;
    string TagFilter;
    
    // Performance
    int ExecutionCount;
    double TotalExecutionTime;
    double AverageExecutionTime;
    datetime LastExecutionTime;
    
    // Error handling
    int ErrorCount;
    string LastError;
    bool StopOnError;
    int MaxRetries;
};

//+------------------------------------------------------------------+
//| Event subscription structure                                    |
//+------------------------------------------------------------------+
struct SEventSubscription {
    int ID;
    string SubscriberName;
    ENUM_EVENT_TYPE EventTypes[15];
    int EventTypeCount;
    ENUM_EVENT_PRIORITY MinPriority;
    
    string CategoryFilter;
    string TagFilter;
    bool IsActive;
    
    datetime CreatedTime;
    datetime LastNotificationTime;
    int NotificationCount;
    
    // Delivery settings
    bool DeliverImmediately;
    bool BatchDelivery;
    int BatchSize;
    int BatchTimeoutSeconds;
    
    // Callback settings
    string CallbackFunction;
    bool RequiresAcknowledgment;
};

//+------------------------------------------------------------------+
//| Event statistics structure                                      |
//+------------------------------------------------------------------+
struct SEventStatistics {
    int TotalEvents;
    int EventsToday;
    int EventsThisWeek;
    int EventsThisMonth;
    
    int EventsByType[15];
    int EventsByPriority[5];
    int EventsByStatus[6];
    int EventsBySource[10];
    
    int TotalProcessed;
    int TotalFailed;
    int TotalCancelled;
    int TotalTimeout;
    
    double AverageProcessingTime;
    double TotalProcessingTime;
    
    datetime LastEventTime;
    datetime LastProcessedTime;
    datetime LastFailedTime;
    
    int CurrentPendingCount;
    int CurrentProcessingCount;
    
    // Performance metrics
    int PeakEventsPerSecond;
    int PeakEventsPerMinute;
    double PeakMemoryUsage;
    
    // Handler statistics
    int ActiveHandlers;
    int TotalHandlerExecutions;
    double AverageHandlerExecutionTime;
};

//+------------------------------------------------------------------+
//| Event queue configuration                                        |
//+------------------------------------------------------------------+
struct SEventQueueConfig {
    int MaxQueueSize;
    int MaxProcessingThreads;
    int ProcessingTimeoutMs;
    int RetryDelayMs;
    int MaxRetries;
    
    bool EnablePriorityProcessing;
    bool EnableBatchProcessing;
    int BatchSize;
    int BatchTimeoutMs;
    
    bool EnableEventPersistence;
    bool EnableEventCompression;
    string PersistenceFile;
    
    bool EnablePerformanceMonitoring;
    bool EnableDetailedLogging;
    
    // Memory management
    int MaxMemoryUsageMB;
    bool EnableAutoCleanup;
    int CleanupIntervalMinutes;
    int EventRetentionDays;
};

//+------------------------------------------------------------------+
//| Event Manager Class                                             |
//+------------------------------------------------------------------+
class CEventManager {
private:
    EAContext* m_pContext;
    
    // Event storage
    SEvent m_Events[10000];
    int m_EventCount;
    int m_NextEventID;
    
    // Event queue
    int m_EventQueue[1000];
    int m_QueueHead;
    int m_QueueTail;
    int m_QueueSize;
    
    // Priority queues
    int m_CriticalQueue[100];
    int m_CriticalQueueSize;
    int m_UrgentQueue[200];
    int m_UrgentQueueSize;
    int m_HighQueue[300];
    int m_HighQueueSize;
    int m_NormalQueue[400];
    int m_NormalQueueSize;
    
    // Handlers and subscriptions
    SEventHandler m_Handlers[100];
    int m_HandlerCount;
    SEventSubscription m_Subscriptions[50];
    int m_SubscriptionCount;
    
    // Configuration and statistics
    SEventQueueConfig m_Config;
    SEventStatistics m_Statistics;
    
    // Status
    bool m_bInitialized;
    bool m_bProcessing;
    bool m_bShuttingDown;
    
    // Performance tracking
    datetime m_LastProcessingTime;
    int m_ProcessingCount;
    double m_TotalProcessingTime;
    
    // Error handling
    string m_LastError;
    int m_ErrorCount;
    
public:
    CEventManager();
    ~CEventManager();
    
    // Core methods
    bool Initialize(EAContext* context);
    void Deinitialize();
    void ProcessEvents();
    void ProcessEventQueue();
    
    // Event creation and management
    int CreateEvent(const ENUM_EVENT_TYPE type, const string name, const string description);
    int CreateSystemEvent(const string name, const string description, const ENUM_EVENT_PRIORITY priority = EVENT_PRIORITY_NORMAL);
    int CreateTradeEvent(const string name, const string description, const string symbol, const double volume);
    int CreateMarketEvent(const string name, const string description, const string symbol, const double price);
    int CreateRiskEvent(const string name, const string description, const double riskLevel);
    int CreatePerformanceEvent(const string name, const string description, const double value);
    int CreateErrorEvent(const string name, const string description, const string errorCode);
    int CreateWarningEvent(const string name, const string description);
    int CreateInfoEvent(const string name, const string description);
    int CreateDebugEvent(const string name, const string description);
    int CreateUserEvent(const string name, const string description, const string userData);
    int CreateTimerEvent(const string name, const string description, const datetime triggerTime);
    
    // Event processing
    bool ProcessEvent(const int eventID);
    bool ProcessEventBatch(const int eventIDs[], const int count);
    bool CancelEvent(const int eventID);
    bool RetryEvent(const int eventID);
    
    // Event queries
    SEvent GetEvent(const int eventID) const;
    int[] GetEventsByType(const ENUM_EVENT_TYPE type) const;
    int[] GetEventsByPriority(const ENUM_EVENT_PRIORITY priority) const;
    int[] GetEventsByStatus(const ENUM_EVENT_STATUS status) const;
    int[] GetEventsBySource(const ENUM_EVENT_SOURCE source) const;
    int[] GetEventsByCategory(const string category) const;
    int[] GetEventsByTimeRange(const datetime startTime, const datetime endTime) const;
    int[] GetPendingEvents() const;
    int[] GetFailedEvents() const;
    
    // Event relationships
    bool LinkEvents(const int parentID, const int childID);
    bool UnlinkEvents(const int parentID, const int childID);
    int[] GetChildEvents(const int parentID) const;
    int[] GetRelatedEvents(const int eventID) const;
    
    // Handler management
    bool RegisterHandler(const SEventHandler& handler);
    bool UnregisterHandler(const string handlerName);
    bool EnableHandler(const string handlerName, const bool enable);
    SEventHandler GetHandler(const string handlerName) const;
    string[] GetHandlerNames() const;
    
    // Subscription management
    int Subscribe(const string subscriberName, const ENUM_EVENT_TYPE eventTypes[], const int typeCount);
    bool Unsubscribe(const int subscriptionID);
    bool UpdateSubscription(const int subscriptionID, const SEventSubscription& subscription);
    SEventSubscription GetSubscription(const int subscriptionID) const;
    int[] GetSubscriptions() const;
    
    // Event data manipulation
    bool SetEventStringData(const int eventID, const int index, const string value);
    bool SetEventNumericData(const int eventID, const int index, const double value);
    bool SetEventIntegerData(const int eventID, const int index, const int value);
    bool SetEventBooleanData(const int eventID, const int index, const bool value);
    bool AddEventTag(const int eventID, const string tag);
    bool RemoveEventTag(const int eventID, const string tag);
    bool SetEventProperty(const int eventID, const string property, const string value);
    
    string GetEventStringData(const int eventID, const int index) const;
    double GetEventNumericData(const int eventID, const int index) const;
    int GetEventIntegerData(const int eventID, const int index) const;
    bool GetEventBooleanData(const int eventID, const int index) const;
    string[] GetEventTags(const int eventID) const;
    string GetEventProperty(const int eventID, const string property) const;
    
    // Queue management
    bool EnqueueEvent(const int eventID);
    int DequeueEvent();
    bool IsQueueEmpty() const;
    bool IsQueueFull() const;
    int GetQueueSize() const { return m_QueueSize; }
    void ClearQueue();
    
    // Priority queue management
    bool EnqueueByPriority(const int eventID);
    int DequeueByPriority();
    
    // Configuration
    void SetConfig(const SEventQueueConfig& config);
    SEventQueueConfig GetConfig() const { return m_Config; }
    void LoadConfig();
    void SaveConfig();
    void ResetConfig();
    
    // Statistics
    SEventStatistics GetStatistics() const { return m_Statistics; }
    void UpdateStatistics();
    void ResetStatistics();
    
    // Utility methods
    bool IsEventValid(const int eventID) const;
    int GetEventCount() const { return m_EventCount; }
    int GetPendingEventCount() const;
    int GetProcessingEventCount() const;
    int GetCompletedEventCount() const;
    int GetFailedEventCount() const;
    
    // Performance monitoring
    double GetAverageProcessingTime() const;
    int GetEventsPerSecond() const;
    double GetMemoryUsage() const;
    
    // Maintenance
    void CleanupOldEvents();
    void CompactEventStorage();
    bool ExportEvents(const string filePath);
    bool ImportEvents(const string filePath);
    
private:
    // Internal methods
    void InitializeDefaultConfig();
    void InitializeDefaultHandlers();
    
    // Event processing helpers
    bool ExecuteEventHandlers(const int eventID);
    bool ExecuteHandler(const SEventHandler& handler, const SEvent& event);
    bool NotifySubscribers(const int eventID);
    bool DeliverEventToSubscriber(const SEventSubscription& subscription, const SEvent& event);
    
    // Queue helpers
    bool AddToQueue(const int eventID);
    bool AddToPriorityQueue(const int eventID, const ENUM_EVENT_PRIORITY priority);
    int GetNextEventFromQueue();
    
    // Validation
    bool ValidateEvent(const SEvent& event);
    bool ValidateHandler(const SEventHandler& handler);
    bool ValidateSubscription(const SEventSubscription& subscription);
    
    // Performance helpers
    void StartPerformanceTimer();
    double StopPerformanceTimer();
    void UpdatePerformanceMetrics(const double processingTime);
    
    // Error handling
    void HandleEventError(const int eventID, const string error);
    void LogEventError(const string error, const ENUM_LOG_LEVEL level = LOG_LEVEL_ERROR);
    
    // Utility helpers
    string GetEventTypeString(const ENUM_EVENT_TYPE type);
    string GetPriorityString(const ENUM_EVENT_PRIORITY priority);
    string GetStatusString(const ENUM_EVENT_STATUS status);
    string GetSourceString(const ENUM_EVENT_SOURCE source);
    
    // File operations
    bool SaveEventHistory();
    bool LoadEventHistory();
    
    // Memory management
    void CheckMemoryUsage();
    void FreeUnusedMemory();
    
    // Logging
    void LogEventActivity(const string activity, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CEventManager::CEventManager() {
    m_pContext = NULL;
    m_bInitialized = false;
    m_bProcessing = false;
    m_bShuttingDown = false;
    
    m_EventCount = 0;
    m_NextEventID = 1;
    m_HandlerCount = 0;
    m_SubscriptionCount = 0;
    
    m_QueueHead = 0;
    m_QueueTail = 0;
    m_QueueSize = 0;
    
    m_CriticalQueueSize = 0;
    m_UrgentQueueSize = 0;
    m_HighQueueSize = 0;
    m_NormalQueueSize = 0;
    
    m_LastProcessingTime = 0;
    m_ProcessingCount = 0;
    m_TotalProcessingTime = 0;
    
    m_LastError = "";
    m_ErrorCount = 0;
    
    // Initialize arrays
    ArrayInitialize(m_EventQueue, 0);
    ArrayInitialize(m_CriticalQueue, 0);
    ArrayInitialize(m_UrgentQueue, 0);
    ArrayInitialize(m_HighQueue, 0);
    ArrayInitialize(m_NormalQueue, 0);
    
    // Initialize default configuration
    InitializeDefaultConfig();
    
    // Initialize statistics
    ZeroMemory(m_Statistics);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CEventManager::~CEventManager() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize Event Manager                                        |
//+------------------------------------------------------------------+
bool CEventManager::Initialize(EAContext* context) {
    if (context == NULL) {
        Print("[EVENT MANAGER ERROR] Context is NULL");
        return false;
    }
    
    m_pContext = context;
    
    // Load configuration
    LoadConfig();
    
    // Initialize default handlers
    InitializeDefaultHandlers();
    
    // Load event history if enabled
    if (m_Config.EnableEventPersistence) {
        LoadEventHistory();
    }
    
    m_bInitialized = true;
    LogEventActivity("Event Manager initialized successfully");
    
    // Create initialization event
    CreateSystemEvent("EventManagerInitialized", "Event Manager has been initialized successfully", EVENT_PRIORITY_NORMAL);
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize Event Manager                                      |
//+------------------------------------------------------------------+
void CEventManager::Deinitialize() {
    if (m_bInitialized) {
        m_bShuttingDown = true;
        
        // Process remaining events
        ProcessEvents();
        
        // Save event history if enabled
        if (m_Config.EnableEventPersistence) {
            SaveEventHistory();
        }
        
        // Save configuration
        SaveConfig();
        
        LogEventActivity("Event Manager deinitialized");
    }
    
    m_bInitialized = false;
    m_pContext = NULL;
}

//+------------------------------------------------------------------+
//| Initialize default configuration                                |
//+------------------------------------------------------------------+
void CEventManager::InitializeDefaultConfig() {
    ZeroMemory(m_Config);
    
    m_Config.MaxQueueSize = 1000;
    m_Config.MaxProcessingThreads = 1;
    m_Config.ProcessingTimeoutMs = 5000;
    m_Config.RetryDelayMs = 1000;
    m_Config.MaxRetries = 3;
    
    m_Config.EnablePriorityProcessing = true;
    m_Config.EnableBatchProcessing = false;
    m_Config.BatchSize = 10;
    m_Config.BatchTimeoutMs = 1000;
    
    m_Config.EnableEventPersistence = false;
    m_Config.EnableEventCompression = false;
    m_Config.PersistenceFile = "events.dat";
    
    m_Config.EnablePerformanceMonitoring = true;
    m_Config.EnableDetailedLogging = false;
    
    m_Config.MaxMemoryUsageMB = 100;
    m_Config.EnableAutoCleanup = true;
    m_Config.CleanupIntervalMinutes = 60;
    m_Config.EventRetentionDays = 7;
}

//+------------------------------------------------------------------+
//| Initialize default handlers                                     |
//+------------------------------------------------------------------+
void CEventManager::InitializeDefaultHandlers() {
    SEventHandler handler;
    
    // System event handler
    ZeroMemory(handler);
    handler.Name = "SystemEventHandler";
    handler.Description = "Handles system events";
    handler.EventType = EVENT_TYPE_SYSTEM;
    handler.MinPriority = EVENT_PRIORITY_LOW;
    handler.IsActive = true;
    handler.IsAsync = false;
    handler.HandlerFunction = "HandleSystemEvent";
    handler.Module = "EventManager";
    handler.StopOnError = false;
    handler.MaxRetries = 3;
    RegisterHandler(handler);
    
    // Error event handler
    ZeroMemory(handler);
    handler.Name = "ErrorEventHandler";
    handler.Description = "Handles error events";
    handler.EventType = EVENT_TYPE_ERROR;
    handler.MinPriority = EVENT_PRIORITY_LOW;
    handler.IsActive = true;
    handler.IsAsync = false;
    handler.HandlerFunction = "HandleErrorEvent";
    handler.Module = "EventManager";
    handler.StopOnError = false;
    handler.MaxRetries = 1;
    RegisterHandler(handler);
    
    // Trade event handler
    ZeroMemory(handler);
    handler.Name = "TradeEventHandler";
    handler.Description = "Handles trade events";
    handler.EventType = EVENT_TYPE_TRADE;
    handler.MinPriority = EVENT_PRIORITY_NORMAL;
    handler.IsActive = true;
    handler.IsAsync = false;
    handler.HandlerFunction = "HandleTradeEvent";
    handler.Module = "EventManager";
    handler.StopOnError = false;
    handler.MaxRetries = 2;
    RegisterHandler(handler);
}

//+------------------------------------------------------------------+
//| Create event                                                    |
//+------------------------------------------------------------------+
int CEventManager::CreateEvent(const ENUM_EVENT_TYPE type, const string name, const string description) {
    if (!m_bInitialized) {
        return -1;
    }
    
    // Check if we have space
    if (m_EventCount >= ArraySize(m_Events)) {
        LogEventActivity("Event storage full", LOG_LEVEL_ERROR);
        return -1;
    }
    
    // Create event
    SEvent event;
    ZeroMemory(event);
    
    event.ID = m_NextEventID++;
    event.Type = type;
    event.Priority = EVENT_PRIORITY_NORMAL;
    event.Status = EVENT_STATUS_PENDING;
    event.Source = EVENT_SOURCE_EA;
    
    event.CreatedTime = TimeCurrent();
    event.ProcessedTime = 0;
    event.CompletedTime = 0;
    event.ExpiryTime = TimeCurrent() + 24 * 3600; // 24 hours
    
    event.Name = name;
    event.Description = description;
    event.Category = "General";
    event.Module = "EventManager";
    event.Function = "CreateEvent";
    
    event.ProcessingAttempts = 0;
    event.MaxProcessingAttempts = m_Config.MaxRetries;
    event.LastError = "";
    
    event.ParentEventID = 0;
    event.ChildEventCount = 0;
    event.RelatedEventCount = 0;
    
    event.ProcessingTimeMs = 0;
    event.MemoryUsageBytes = 0;
    
    event.RequiresCallback = false;
    event.CallbackExecuted = false;
    
    // Validate event
    if (!ValidateEvent(event)) {
        LogEventActivity("Invalid event created", LOG_LEVEL_ERROR);
        return -1;
    }
    
    // Store event
    m_Events[m_EventCount] = event;
    m_EventCount++;
    
    // Enqueue event for processing
    if (m_Config.EnablePriorityProcessing) {
        EnqueueByPriority(event.ID);
    } else {
        EnqueueEvent(event.ID);
    }
    
    // Update statistics
    UpdateStatistics();
    
    LogEventActivity("Event created: ID=" + IntegerToString(event.ID) + ", Type=" + GetEventTypeString(type) + ", Name=" + name);
    
    return event.ID;
}

//+------------------------------------------------------------------+
//| Create system event                                             |
//+------------------------------------------------------------------+
int CEventManager::CreateSystemEvent(const string name, const string description, const ENUM_EVENT_PRIORITY priority = EVENT_PRIORITY_NORMAL) {
    int eventID = CreateEvent(EVENT_TYPE_SYSTEM, name, description);
    if (eventID > 0) {
        // Set priority
        for (int i = 0; i < m_EventCount; i++) {
            if (m_Events[i].ID == eventID) {
                m_Events[i].Priority = priority;
                m_Events[i].Source = EVENT_SOURCE_SYSTEM;
                break;
            }
        }
    }
    return eventID;
}

//+------------------------------------------------------------------+
//| Create trade event                                              |
//+------------------------------------------------------------------+
int CEventManager::CreateTradeEvent(const string name, const string description, const string symbol, const double volume) {
    int eventID = CreateEvent(EVENT_TYPE_TRADE, name, description);
    if (eventID > 0) {
        // Set trade-specific data
        SetEventStringData(eventID, 0, symbol);
        SetEventNumericData(eventID, 0, volume);
        
        for (int i = 0; i < m_EventCount; i++) {
            if (m_Events[i].ID == eventID) {
                m_Events[i].Category = "Trade";
                m_Events[i].Priority = EVENT_PRIORITY_HIGH;
                break;
            }
        }
    }
    return eventID;
}

//+------------------------------------------------------------------+
//| Create market event                                             |
//+------------------------------------------------------------------+
int CEventManager::CreateMarketEvent(const string name, const string description, const string symbol, const double price) {
    int eventID = CreateEvent(EVENT_TYPE_MARKET, name, description);
    if (eventID > 0) {
        // Set market-specific data
        SetEventStringData(eventID, 0, symbol);
        SetEventNumericData(eventID, 0, price);
        
        for (int i = 0; i < m_EventCount; i++) {
            if (m_Events[i].ID == eventID) {
                m_Events[i].Category = "Market";
                m_Events[i].Source = EVENT_SOURCE_MARKET;
                break;
            }
        }
    }
    return eventID;
}

//+------------------------------------------------------------------+
//| Create risk event                                               |
//+------------------------------------------------------------------+
int CEventManager::CreateRiskEvent(const string name, const string description, const double riskLevel) {
    int eventID = CreateEvent(EVENT_TYPE_RISK, name, description);
    if (eventID > 0) {
        // Set risk-specific data
        SetEventNumericData(eventID, 0, riskLevel);
        
        for (int i = 0; i < m_EventCount; i++) {
            if (m_Events[i].ID == eventID) {
                m_Events[i].Category = "Risk";
                m_Events[i].Priority = (riskLevel > 0.8) ? EVENT_PRIORITY_CRITICAL : EVENT_PRIORITY_HIGH;
                break;
            }
        }
    }
    return eventID;
}

//+------------------------------------------------------------------+
//| Create error event                                              |
//+------------------------------------------------------------------+
int CEventManager::CreateErrorEvent(const string name, const string description, const string errorCode) {
    int eventID = CreateEvent(EVENT_TYPE_ERROR, name, description);
    if (eventID > 0) {
        // Set error-specific data
        SetEventStringData(eventID, 0, errorCode);
        
        for (int i = 0; i < m_EventCount; i++) {
            if (m_Events[i].ID == eventID) {
                m_Events[i].Category = "Error";
                m_Events[i].Priority = EVENT_PRIORITY_URGENT;
                break;
            }
        }
    }
    return eventID;
}

//+------------------------------------------------------------------+
//| Process events                                                  |
//+------------------------------------------------------------------+
void CEventManager::ProcessEvents() {
    if (!m_bInitialized || m_bProcessing) {
        return;
    }
    
    m_bProcessing = true;
    StartPerformanceTimer();
    
    int processedCount = 0;
    int maxProcessingCount = 100; // Limit processing per call
    
    // Process events from priority queues
    while (processedCount < maxProcessingCount && !IsQueueEmpty()) {
        int eventID = DequeueByPriority();
        if (eventID > 0) {
            if (ProcessEvent(eventID)) {
                processedCount++;
            }
        } else {
            break;
        }
    }
    
    double processingTime = StopPerformanceTimer();
    UpdatePerformanceMetrics(processingTime);
    
    m_bProcessing = false;
    
    if (processedCount > 0) {
        LogEventActivity("Processed " + IntegerToString(processedCount) + " events in " + DoubleToString(processingTime, 2) + "ms");
    }
}

//+------------------------------------------------------------------+
//| Process single event                                            |
//+------------------------------------------------------------------+
bool CEventManager::ProcessEvent(const int eventID) {
    if (!IsEventValid(eventID)) {
        return false;
    }
    
    // Find event
    int index = -1;
    for (int i = 0; i < m_EventCount; i++) {
        if (m_Events[i].ID == eventID) {
            index = i;
            break;
        }
    }
    
    if (index == -1) {
        return false;
    }
    
    SEvent& event = m_Events[index];
    
    // Check if event can be processed
    if (event.Status != EVENT_STATUS_PENDING) {
        return false;
    }
    
    // Check expiry
    if (event.ExpiryTime > 0 && TimeCurrent() > event.ExpiryTime) {
        event.Status = EVENT_STATUS_TIMEOUT;
        LogEventActivity("Event expired: ID=" + IntegerToString(eventID), LOG_LEVEL_WARNING);
        return false;
    }
    
    // Update status
    event.Status = EVENT_STATUS_PROCESSING;
    event.ProcessedTime = TimeCurrent();
    event.ProcessingAttempts++;
    
    bool success = true;
    
    try {
        // Execute event handlers
        if (!ExecuteEventHandlers(eventID)) {
            success = false;
        }
        
        // Notify subscribers
        if (!NotifySubscribers(eventID)) {
            // Don't fail the event if notification fails
        }
        
        if (success) {
            event.Status = EVENT_STATUS_COMPLETED;
            event.CompletedTime = TimeCurrent();
            LogEventActivity("Event processed successfully: ID=" + IntegerToString(eventID));
        } else {
            event.Status = EVENT_STATUS_FAILED;
            LogEventActivity("Event processing failed: ID=" + IntegerToString(eventID), LOG_LEVEL_ERROR);
            
            // Retry if possible
            if (event.ProcessingAttempts < event.MaxProcessingAttempts) {
                event.Status = EVENT_STATUS_PENDING;
                EnqueueEvent(eventID); // Re-queue for retry
            }
        }
    } catch (...) {
        event.Status = EVENT_STATUS_FAILED;
        event.LastError = "Exception during event processing";
        HandleEventError(eventID, event.LastError);
        success = false;
    }
    
    // Update statistics
    UpdateStatistics();
    
    return success;
}

//+------------------------------------------------------------------+
//| Execute event handlers                                          |
//+------------------------------------------------------------------+
bool CEventManager::ExecuteEventHandlers(const int eventID) {
    SEvent event = GetEvent(eventID);
    if (event.ID <= 0) {
        return false;
    }
    
    bool success = true;
    
    // Find and execute matching handlers
    for (int i = 0; i < m_HandlerCount; i++) {
        SEventHandler& handler = m_Handlers[i];
        
        // Check if handler matches event
        if (!handler.IsActive) continue;
        if (handler.EventType != event.Type) continue;
        if (event.Priority < handler.MinPriority) continue;
        
        // Check filters
        if (handler.CategoryFilter != "" && handler.CategoryFilter != event.Category) continue;
        
        // Execute handler
        if (!ExecuteHandler(handler, event)) {
            success = false;
            if (handler.StopOnError) {
                break;
            }
        }
    }
    
    return success;
}

//+------------------------------------------------------------------+
//| Execute single handler                                          |
//+------------------------------------------------------------------+
bool CEventManager::ExecuteHandler(const SEventHandler& handler, const SEvent& event) {
    datetime startTime = GetMicrosecondCount();
    
    bool success = true;
    
    try {
        // This is a placeholder for actual handler execution
        // In a real implementation, this would call the actual handler function
        LogEventActivity("Executing handler: " + handler.Name + " for event: " + IntegerToString(event.ID));
        
        // Simulate handler execution
        Sleep(1); // Minimal delay to simulate processing
        
    } catch (...) {
        success = false;
        LogEventActivity("Handler execution failed: " + handler.Name, LOG_LEVEL_ERROR);
    }
    
    datetime endTime = GetMicrosecondCount();
    double executionTime = (double)(endTime - startTime) / 1000.0; // Convert to milliseconds
    
    // Update handler statistics (this would need to be implemented properly)
    // handler.ExecutionCount++;
    // handler.TotalExecutionTime += executionTime;
    // handler.AverageExecutionTime = handler.TotalExecutionTime / handler.ExecutionCount;
    // handler.LastExecutionTime = TimeCurrent();
    
    return success;
}

//+------------------------------------------------------------------+
//| Enqueue event by priority                                       |
//+------------------------------------------------------------------+
bool CEventManager::EnqueueByPriority(const int eventID) {
    SEvent event = GetEvent(eventID);
    if (event.ID <= 0) {
        return false;
    }
    
    return AddToPriorityQueue(eventID, event.Priority);
}

//+------------------------------------------------------------------+
//| Add to priority queue                                           |
//+------------------------------------------------------------------+
bool CEventManager::AddToPriorityQueue(const int eventID, const ENUM_EVENT_PRIORITY priority) {
    switch(priority) {
    case EVENT_PRIORITY_CRITICAL:
        if (m_CriticalQueueSize < ArraySize(m_CriticalQueue)) {
            m_CriticalQueue[m_CriticalQueueSize] = eventID;
            m_CriticalQueueSize++;
            return true;
        }
        break;
        
    case EVENT_PRIORITY_URGENT:
        if (m_UrgentQueueSize < ArraySize(m_UrgentQueue)) {
            m_UrgentQueue[m_UrgentQueueSize] = eventID;
            m_UrgentQueueSize++;
            return true;
        }
        break;
        
    case EVENT_PRIORITY_HIGH:
        if (m_HighQueueSize < ArraySize(m_HighQueue)) {
            m_HighQueue[m_HighQueueSize] = eventID;
            m_HighQueueSize++;
            return true;
        }
        break;
        
    case EVENT_PRIORITY_NORMAL:
    case EVENT_PRIORITY_LOW:
    default:
        if (m_NormalQueueSize < ArraySize(m_NormalQueue)) {
            m_NormalQueue[m_NormalQueueSize] = eventID;
            m_NormalQueueSize++;
            return true;
        }
        break;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Dequeue by priority                                             |
//+------------------------------------------------------------------+
int CEventManager::DequeueByPriority() {
    // Check critical queue first
    if (m_CriticalQueueSize > 0) {
        int eventID = m_CriticalQueue[0];
        // Shift array
        for (int i = 0; i < m_CriticalQueueSize - 1; i++) {
            m_CriticalQueue[i] = m_CriticalQueue[i + 1];
        }
        m_CriticalQueueSize--;
        return eventID;
    }
    
    // Check urgent queue
    if (m_UrgentQueueSize > 0) {
        int eventID = m_UrgentQueue[0];
        for (int i = 0; i < m_UrgentQueueSize - 1; i++) {
            m_UrgentQueue[i] = m_UrgentQueue[i + 1];
        }
        m_UrgentQueueSize--;
        return eventID;
    }
    
    // Check high priority queue
    if (m_HighQueueSize > 0) {
        int eventID = m_HighQueue[0];
        for (int i = 0; i < m_HighQueueSize - 1; i++) {
            m_HighQueue[i] = m_HighQueue[i + 1];
        }
        m_HighQueueSize--;
        return eventID;
    }
    
    // Check normal priority queue
    if (m_NormalQueueSize > 0) {
        int eventID = m_NormalQueue[0];
        for (int i = 0; i < m_NormalQueueSize - 1; i++) {
            m_NormalQueue[i] = m_NormalQueue[i + 1];
        }
        m_NormalQueueSize--;
        return eventID;
    }
    
    return 0; // No events in queue
}

//+------------------------------------------------------------------+
//| Check if queue is empty                                         |
//+------------------------------------------------------------------+
bool CEventManager::IsQueueEmpty() const {
    return (m_CriticalQueueSize == 0 && m_UrgentQueueSize == 0 && 
            m_HighQueueSize == 0 && m_NormalQueueSize == 0);
}

//+------------------------------------------------------------------+
//| Get event                                                       |
//+------------------------------------------------------------------+
SEvent CEventManager::GetEvent(const int eventID) const {
    SEvent emptyEvent;
    ZeroMemory(emptyEvent);
    
    for (int i = 0; i < m_EventCount; i++) {
        if (m_Events[i].ID == eventID) {
            return m_Events[i];
        }
    }
    
    return emptyEvent;
}

//+------------------------------------------------------------------+
//| Set event string data                                           |
//+------------------------------------------------------------------+
bool CEventManager::SetEventStringData(const int eventID, const int index, const string value) {
    if (index < 0 || index >= ArraySize(m_Events[0].StringData)) {
        return false;
    }
    
    for (int i = 0; i < m_EventCount; i++) {
        if (m_Events[i].ID == eventID) {
            m_Events[i].StringData[index] = value;
            return true;
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Set event numeric data                                          |
//+------------------------------------------------------------------+
bool CEventManager::SetEventNumericData(const int eventID, const int index, const double value) {
    if (index < 0 || index >= ArraySize(m_Events[0].NumericData)) {
        return false;
    }
    
    for (int i = 0; i < m_EventCount; i++) {
        if (m_Events[i].ID == eventID) {
            m_Events[i].NumericData[index] = value;
            return true;
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Register handler                                                |
//+------------------------------------------------------------------+
bool CEventManager::RegisterHandler(const SEventHandler& handler) {
    if (m_HandlerCount >= ArraySize(m_Handlers)) {
        return false;
    }
    
    if (!ValidateHandler(handler)) {
        return false;
    }
    
    m_Handlers[m_HandlerCount] = handler;
    m_HandlerCount++;
    
    LogEventActivity("Handler registered: " + handler.Name);
    
    return true;
}

//+------------------------------------------------------------------+
//| Validation methods                                              |
//+------------------------------------------------------------------+
bool CEventManager::ValidateEvent(const SEvent& event) {
    if (event.ID <= 0) return false;
    if (event.Name == "") return false;
    if (event.CreatedTime <= 0) return false;
    
    return true;
}

bool CEventManager::ValidateHandler(const SEventHandler& handler) {
    if (handler.Name == "") return false;
    if (handler.HandlerFunction == "") return false;
    
    return true;
}

bool CEventManager::IsEventValid(const int eventID) const {
    for (int i = 0; i < m_EventCount; i++) {
        if (m_Events[i].ID == eventID) {
            return true;
        }
    }
    return false;
}

//+------------------------------------------------------------------+
//| Performance monitoring                                          |
//+------------------------------------------------------------------+
void CEventManager::StartPerformanceTimer() {
    m_LastProcessingTime = GetMicrosecondCount();
}

double CEventManager::StopPerformanceTimer() {
    datetime currentTime = GetMicrosecondCount();
    return (double)(currentTime - m_LastProcessingTime) / 1000.0; // Convert to milliseconds
}

void CEventManager::UpdatePerformanceMetrics(const double processingTime) {
    m_ProcessingCount++;
    m_TotalProcessingTime += processingTime;
}

double CEventManager::GetAverageProcessingTime() const {
    if (m_ProcessingCount == 0) return 0.0;
    return m_TotalProcessingTime / m_ProcessingCount;
}

//+------------------------------------------------------------------+
//| Update statistics                                               |
//+------------------------------------------------------------------+
void CEventManager::UpdateStatistics() {
    m_Statistics.TotalEvents++;
    m_Statistics.EventsToday++;
    m_Statistics.EventsThisWeek++;
    m_Statistics.EventsThisMonth++;
    m_Statistics.LastEventTime = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Utility methods                                                 |
//+------------------------------------------------------------------+
string CEventManager::GetEventTypeString(const ENUM_EVENT_TYPE type) {
    switch(type) {
    case EVENT_TYPE_SYSTEM: return "System";
    case EVENT_TYPE_TRADE: return "Trade";
    case EVENT_TYPE_MARKET: return "Market";
    case EVENT_TYPE_RISK: return "Risk";
    case EVENT_TYPE_PERFORMANCE: return "Performance";
    case EVENT_TYPE_ERROR: return "Error";
    case EVENT_TYPE_WARNING: return "Warning";
    case EVENT_TYPE_INFO: return "Info";
    case EVENT_TYPE_DEBUG: return "Debug";
    case EVENT_TYPE_USER: return "User";
    case EVENT_TYPE_TIMER: return "Timer";
    case EVENT_TYPE_NETWORK: return "Network";
    case EVENT_TYPE_DATA: return "Data";
    case EVENT_TYPE_STRATEGY: return "Strategy";
    case EVENT_TYPE_OPTIMIZATION: return "Optimization";
    default: return "Unknown";
    }
}

string CEventManager::GetPriorityString(const ENUM_EVENT_PRIORITY priority) {
    switch(priority) {
    case EVENT_PRIORITY_LOW: return "Low";
    case EVENT_PRIORITY_NORMAL: return "Normal";
    case EVENT_PRIORITY_HIGH: return "High";
    case EVENT_PRIORITY_URGENT: return "Urgent";
    case EVENT_PRIORITY_CRITICAL: return "Critical";
    default: return "Unknown";
    }
}

string CEventManager::GetStatusString(const ENUM_EVENT_STATUS status) {
    switch(status) {
    case EVENT_STATUS_PENDING: return "Pending";
    case EVENT_STATUS_PROCESSING: return "Processing";
    case EVENT_STATUS_COMPLETED: return "Completed";
    case EVENT_STATUS_FAILED: return "Failed";
    case EVENT_STATUS_CANCELLED: return "Cancelled";
    case EVENT_STATUS_TIMEOUT: return "Timeout";
    default: return "Unknown";
    }
}

string CEventManager::GetSourceString(const ENUM_EVENT_SOURCE source) {
    switch(source) {
    case EVENT_SOURCE_EA: return "EA";
    case EVENT_SOURCE_TERMINAL: return "Terminal";
    case EVENT_SOURCE_BROKER: return "Broker";
    case EVENT_SOURCE_MARKET: return "Market";
    case EVENT_SOURCE_USER: return "User";
    case EVENT_SOURCE_SYSTEM: return "System";
    case EVENT_SOURCE_EXTERNAL: return "External";
    case EVENT_SOURCE_TIMER: return "Timer";
    case EVENT_SOURCE_INDICATOR: return "Indicator";
    case EVENT_SOURCE_STRATEGY: return "Strategy";
    default: return "Unknown";
    }
}

//+------------------------------------------------------------------+
//| Error handling                                                  |
//+------------------------------------------------------------------+
void CEventManager::HandleEventError(const int eventID, const string error) {
    m_ErrorCount++;
    m_LastError = error;
    LogEventActivity("Event error (ID=" + IntegerToString(eventID) + "): " + error, LOG_LEVEL_ERROR);
}

//+------------------------------------------------------------------+
//| Placeholder methods                                             |
//+------------------------------------------------------------------+
bool CEventManager::EnqueueEvent(const int eventID) {
    return AddToQueue(eventID);
}

bool CEventManager::AddToQueue(const int eventID) {
    if (m_QueueSize >= ArraySize(m_EventQueue)) {
        return false;
    }
    
    m_EventQueue[m_QueueTail] = eventID;
    m_QueueTail = (m_QueueTail + 1) % ArraySize(m_EventQueue);
    m_QueueSize++;
    
    return true;
}

bool CEventManager::NotifySubscribers(const int eventID) {
    // Placeholder implementation
    return true;
}

void CEventManager::LoadConfig() {
    // Placeholder implementation
}

void CEventManager::SaveConfig() {
    // Placeholder implementation
}

bool CEventManager::LoadEventHistory() {
    // Placeholder implementation
    return true;
}

bool CEventManager::SaveEventHistory() {
    // Placeholder implementation
    return true;
}

int CEventManager::GetPendingEventCount() const {
    int count = 0;
    for (int i = 0; i < m_EventCount; i++) {
        if (m_Events[i].Status == EVENT_STATUS_PENDING) {
            count++;
        }
    }
    return count;
}

int CEventManager::GetProcessingEventCount() const {
    int count = 0;
    for (int i = 0; i < m_EventCount; i++) {
        if (m_Events[i].Status == EVENT_STATUS_PROCESSING) {
            count++;
        }
    }
    return count;
}

int CEventManager::GetCompletedEventCount() const {
    int count = 0;
    for (int i = 0; i < m_EventCount; i++) {
        if (m_Events[i].Status == EVENT_STATUS_COMPLETED) {
            count++;
        }
    }
    return count;
}

int CEventManager::GetFailedEventCount() const {
    int count = 0;
    for (int i = 0; i < m_EventCount; i++) {
        if (m_Events[i].Status == EVENT_STATUS_FAILED) {
            count++;
        }
    }
    return count;
}

//+------------------------------------------------------------------+
//| Log event activity                                              |
//+------------------------------------------------------------------+
void CEventManager::LogEventActivity(const string activity, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO) {
    if (m_pContext != NULL && m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo("[EVENT MANAGER] " + activity);
    } else {
        Print("[EVENT MANAGER] " + activity);
    }
}

//+------------------------------------------------------------------+