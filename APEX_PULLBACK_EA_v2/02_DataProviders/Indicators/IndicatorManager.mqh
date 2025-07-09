//+------------------------------------------------------------------+
//|                                            IndicatorManager.mqh |
//|                IndicatorManager.mqh - APEX Pullback EA v5 FINAL |
//|      Description: Advanced indicator management system with     |
//|                   intelligent caching, multi-timeframe         |
//|                   support, and performance optimization.        |
//+------------------------------------------------------------------+

#ifndef INDICATOR_MANAGER_MQH_
#define INDICATOR_MANAGER_MQH_

#include "..\..\00_Core\CommonStructs.mqh"

//+------------------------------------------------------------------+
//| Indicator Types                                                  |
//+------------------------------------------------------------------+
enum ENUM_INDICATOR_TYPE {
    INDICATOR_MA,           // Moving Average
    INDICATOR_RSI,          // Relative Strength Index
    INDICATOR_MACD,         // MACD
    INDICATOR_BOLLINGER,    // Bollinger Bands
    INDICATOR_STOCHASTIC,   // Stochastic
    INDICATOR_ATR,          // Average True Range
    INDICATOR_ADX,          // Average Directional Index
    INDICATOR_CCI,          // Commodity Channel Index
    INDICATOR_WILLIAMS,     // Williams %R
    INDICATOR_MOMENTUM,     // Momentum
    INDICATOR_CUSTOM        // Custom indicator
};

//+------------------------------------------------------------------+
//| Indicator Status                                                 |
//+------------------------------------------------------------------+
enum ENUM_INDICATOR_STATUS {
    INDICATOR_STATUS_UNINITIALIZED,
    INDICATOR_STATUS_INITIALIZING,
    INDICATOR_STATUS_READY,
    INDICATOR_STATUS_ERROR,
    INDICATOR_STATUS_UPDATING
};

//+------------------------------------------------------------------+
//| Indicator Configuration                                          |
//+------------------------------------------------------------------+
struct SIndicatorConfig {
    ENUM_INDICATOR_TYPE   Type;             // Indicator type
    string                Name;             // Indicator name
    string                Symbol;           // Symbol
    ENUM_TIMEFRAMES       Timeframe;        // Timeframe
    int                   Period;           // Main period
    int                   Period2;          // Secondary period (for MACD, etc.)
    int                   Period3;          // Third period (for MACD signal)
    ENUM_MA_METHOD        MAMethod;         // Moving average method
    ENUM_APPLIED_PRICE    AppliedPrice;     // Applied price
    double                Deviation;        // Deviation (for Bollinger)
    int                   Shift;            // Shift
    string                CustomPath;       // Custom indicator path
    bool                  UseCache;         // Use caching
    int                   CacheSize;        // Cache size
    int                   UpdateInterval;   // Update interval in seconds
};

//+------------------------------------------------------------------+
//| Indicator Data                                                   |
//+------------------------------------------------------------------+
struct SIndicatorData {
    datetime              Time[];           // Time array
    double                Buffer0[];        // Main buffer
    double                Buffer1[];        // Secondary buffer
    double                Buffer2[];        // Third buffer
    double                Buffer3[];        // Fourth buffer
    int                   BufferCount;      // Number of buffers
    int                   DataCount;        // Data count
    datetime              LastUpdate;       // Last update time
    bool                  IsValid;          // Data validity
};

//+------------------------------------------------------------------+
//| Indicator Instance                                               |
//+------------------------------------------------------------------+
struct SIndicatorInstance {
    SIndicatorConfig      Config;           // Configuration
    SIndicatorData        Data;             // Cached data
    int                   Handle;           // Indicator handle
    ENUM_INDICATOR_STATUS Status;           // Current status
    datetime              LastAccess;       // Last access time
    int                   AccessCount;      // Access counter
    string                ErrorMessage;     // Last error message
    bool                  AutoUpdate;       // Auto update flag
};

//+------------------------------------------------------------------+
//| Indicator Statistics                                             |
//+------------------------------------------------------------------+
struct SIndicatorStats {
    int                   TotalIndicators;  // Total indicators
    int                   ActiveIndicators; // Active indicators
    int                   CachedValues;     // Cached values
    int                   CacheHits;        // Cache hits
    int                   CacheMisses;      // Cache misses
    double                CacheHitRatio;    // Cache hit ratio
    int                   UpdatesPerSecond; // Updates per second
    datetime              LastStatsUpdate;  // Last statistics update
};

//+------------------------------------------------------------------+
//| Indicator Cache Entry Structure                                  |
//+------------------------------------------------------------------+
struct SIndicatorCacheEntry {
    double               values[1000];      // Cached values (circular buffer)
    datetime             timestamps[1000];   // Corresponding timestamps
    int                  head;              // Head position in circular buffer
    int                  size;              // Current size of cache
    datetime             lastUpdate;        // Last update timestamp
    bool                 isValid;           // Cache validity flag
    
    void Clear() {
        ArrayInitialize(values, 0.0);
        ArrayInitialize(timestamps, 0);
        head = 0;
        size = 0;
        lastUpdate = 0;
        isValid = false;
    }
    
    void AddValue(double value, datetime time) {
        values[head] = value;
        timestamps[head] = time;
        head = (head + 1) % 1000;
        if (size < 1000) size++;
        lastUpdate = time;
        isValid = true;
    }
    
    bool GetValue(int shift, double& value, datetime& time) {
        if (!isValid || shift >= size) return false;
        
        int index = (head - 1 - shift + 1000) % 1000;
        value = values[index];
        time = timestamps[index];
        return true;
    }
};

//+------------------------------------------------------------------+
//| Indicator Definition Structure                                   |
//+------------------------------------------------------------------+
struct SIndicatorDefinition {
    string               name;              // Indicator name
    int                  handle;            // MT5 indicator handle
    ENUM_TIMEFRAMES      timeframe;         // Timeframe
    int                  period;            // Period parameter
    string               symbol;            // Symbol
    bool                 isActive;          // Active status
    datetime             lastAccess;        // Last access time
    SIndicatorCacheEntry cache;             // Cache for this indicator
    
    void Clear() {
        name = "";
        handle = INVALID_HANDLE;
        timeframe = PERIOD_CURRENT;
        period = 0;
        symbol = "";
        isActive = false;
        lastAccess = 0;
        cache.Clear();
    }
};

//+------------------------------------------------------------------+
//| CIndicatorManager - Advanced Indicator Management               |
//+------------------------------------------------------------------+
class CIndicatorManager {
private:
    EAContext*            m_pContext;       // Reference to EA context
    bool                  m_bInitialized;  // Initialization status
    
    // Indicator storage
    SIndicatorDefinition  m_Indicators[50];   // Array of managed indicators
    int                   m_iIndicatorCount; // Number of active indicators
    
    // Cache management
    bool                  m_bCacheEnabled;   // Cache enable flag
    int                   m_iCacheSize;      // Maximum cache size per indicator
    datetime              m_dtCacheTimeout;  // Cache timeout (seconds)
    
    // Performance metrics
    int                   m_iCacheHits;      // Cache hit counter
    int                   m_iCacheMisses;    // Cache miss counter
    int                   m_iTotalRequests;  // Total requests counter
    
    // Performance tracking
    SIndicatorStats       m_Stats;          // Statistics
    datetime              m_LastCleanup;    // Last cleanup time
    
    // Configuration
    static const int      MAX_INDICATORS;
    static const int      DEFAULT_CACHE_SIZE;
    static const int      CLEANUP_INTERVAL;
    static const int      MAX_CACHE_AGE;
    
public:
    //--- Constructor/Destructor ---
    CIndicatorManager();
    ~CIndicatorManager();
    
    //--- Core Methods ---
    bool                  Initialize(EAContext* context);
    void                  Deinitialize();
    bool                  IsInitialized() const { return m_bInitialized; }
    void                  Update();
    
    //--- Indicator Management ---
    int                   CreateIndicator(const SIndicatorConfig& config);
    bool                  RemoveIndicator(const int indicator_id);
    bool                  IsIndicatorReady(const int indicator_id);
    ENUM_INDICATOR_STATUS GetIndicatorStatus(const int indicator_id);
    
    //--- Standard Indicators ---
    int                   CreateMA(const string& symbol, const ENUM_TIMEFRAMES timeframe,
                                   const int period, const ENUM_MA_METHOD method = MODE_SMA,
                                   const ENUM_APPLIED_PRICE applied = PRICE_CLOSE);
    
    int                   CreateRSI(const string& symbol, const ENUM_TIMEFRAMES timeframe,
                                    const int period, const ENUM_APPLIED_PRICE applied = PRICE_CLOSE);
    
    int                   CreateMACD(const string& symbol, const ENUM_TIMEFRAMES timeframe,
                                     const int fast_period, const int slow_period, const int signal_period,
                                     const ENUM_APPLIED_PRICE applied = PRICE_CLOSE);
    
    int                   CreateBollinger(const string& symbol, const ENUM_TIMEFRAMES timeframe,
                                           const int period, const double deviation = 2.0,
                                           const ENUM_APPLIED_PRICE applied = PRICE_CLOSE);
    
    int                   CreateATR(const string& symbol, const ENUM_TIMEFRAMES timeframe,
                                    const int period);
    
    int                   CreateStochastic(const string& symbol, const ENUM_TIMEFRAMES timeframe,
                                            const int k_period, const int d_period, const int slowing);
    
    int                   CreateADX(const string& symbol, const ENUM_TIMEFRAMES timeframe,
                                    const int period);
    
    //--- Data Access ---
    double                GetValue(const int indicator_id, const int buffer = 0, const int shift = 0);
    bool                  GetValues(const int indicator_id, const int buffer, const int start_pos,
                                    const int count, double& values[]);
    
    datetime              GetTime(const int indicator_id, const int shift = 0);
    bool                  GetTimes(const int indicator_id, const int start_pos, const int count,
                                   datetime& times[]);
    
    //--- Multi-buffer Access ---
    bool                  GetMACD(const int indicator_id, const int shift, double& main, double& signal);
    bool                  GetBollinger(const int indicator_id, const int shift, double& upper,
                                       double& middle, double& lower);
    bool                  GetStochastic(const int indicator_id, const int shift, double& main, double& signal);
    bool                  GetADX(const int indicator_id, const int shift, double& adx, double& plus_di, double& minus_di);
    
    //--- Utility Methods ---
    bool                  IsDataReady(const int indicator_id, const int required_bars = 1);
    int                   GetDataCount(const int indicator_id);
    datetime              GetLastUpdate(const int indicator_id);
    
    //--- Cache Management ---
    void                  ClearCache(const int indicator_id = -1);
    void                  OptimizeCache();
    bool                  PreloadData(const int indicator_id, const int bars_count);
    
    //--- Configuration ---
    bool                  SetUpdateInterval(const int indicator_id, const int interval_seconds);
    bool                  SetCacheSize(const int indicator_id, const int cache_size);

    bool                  SetAutoUpdate(const int indicator_id, const bool auto_update);
    
    //--- Statistics ---
    SIndicatorStats       GetStatistics() const { return m_Stats; }
    void                  ResetStatistics();
    string                GetPerformanceReport();
    
    //--- Information ---
    int                   GetIndicatorCount() const { return m_iIndicatorCount; }
    string                GetIndicatorInfo(const int indicator_id);
    string                GetSystemSummary();
    
private:
    //--- Internal Methods ---
    int                   FindFreeSlot();
    bool                  ValidateConfig(const SIndicatorConfig& config);
    bool                  InitializeIndicator(const int indicator_id);
    void                  UpdateIndicator(const int indicator_id);
    bool                  LoadIndicatorData(const int indicator_id, const int bars_count = 100);
    
    //--- Cache Methods ---
    bool                  IsCacheValid(const int indicator_id);
    void                  InvalidateCache(const int indicator_id);
    void                  UpdateCache(const int indicator_id);
    void                  CleanupOldCache();
    
    //--- Utility ---
    string                IndicatorTypeToString(const ENUM_INDICATOR_TYPE type);
    string                StatusToString(const ENUM_INDICATOR_STATUS status);
    void                  LogIndicatorEvent(const string& event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO);
    void                  UpdateStatistics();
    
    //--- Error Handling ---
    void                  HandleIndicatorError(const int indicator_id, const string& error_msg);
    bool                  RecoverIndicator(const int indicator_id);
    
    //--- Cache Methods ---
    bool                  GetCachedValue(int indicator_id, int buffer_num, int shift, double& value);
    void                  CacheValue(int indicator_id, int buffer_num, int shift, double value);
    void                  UpdateCacheStats(bool hit);
};

// Static constants definition
const int CIndicatorManager::MAX_INDICATORS = 50;
const int CIndicatorManager::DEFAULT_CACHE_SIZE = 1000;
const int CIndicatorManager::CLEANUP_INTERVAL = 300;  // 5 minutes
const int CIndicatorManager::MAX_CACHE_AGE = 3600;    // 1 hour

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CIndicatorManager::CIndicatorManager() {
    m_pContext = NULL;
    m_bInitialized = false;
    m_iIndicatorCount = 0;
    
    // Cache settings
    m_bCacheEnabled = true;
    m_iCacheSize = 100;      // Default cache size
    m_dtCacheTimeout = 300;  // 5 minutes default timeout
    
    // Performance stats
    m_iCacheHits = 0;
    m_iCacheMisses = 0;
    m_iTotalRequests = 0;
    
    // Initialize indicator array
    for (int i = 0; i < ArraySize(m_Indicators); i++) {
        m_Indicators[i].Clear();
    }
    
    // Initialize statistics
    ZeroMemory(m_Stats);
    
    // Initialize all slots
    for (int i = 0; i < MAX_INDICATORS; i++) {
        m_Indicators[i].Status = INDICATOR_STATUS_UNINITIALIZED;
    }
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CIndicatorManager::~CIndicatorManager() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CIndicatorManager::Initialize(EAContext* context) {
    if (m_bInitialized) {
        return true;
    }
    
    m_pContext = context;
    if (m_pContext == NULL) {
        Print("[INDICATOR_MANAGER] Context is NULL");
        return false;
    }
    
    // Initialize cache settings from input parameters
    m_bCacheEnabled = true;
    m_iCacheSize = 200;
    m_dtCacheTimeout = 600; // 10 minutes
    
    m_bInitialized = true;
    
    if (m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo("IndicatorManager initialized with caching enabled", __FUNCTION__);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CIndicatorManager::Deinitialize() {
    if (!m_bInitialized) {
        return;
    }
    
    if (m_pContext != NULL && m_pContext->pLogger != NULL) {
        string perf_report = GetPerformanceReport();
        m_pContext->pLogger->LogInfo("IndicatorManager performance: " + perf_report, __FUNCTION__);
    }
    
    ReleaseAllIndicators();
    
    m_bInitialized = false;
}

//+------------------------------------------------------------------+
//| Update                                                           |
//+------------------------------------------------------------------+
void CIndicatorManager::Update() {
    if (!m_bInitialized) {
        return;
    }
    
    datetime current_time = TimeCurrent();
    
    // Update active indicators
    for (int i = 0; i < MAX_INDICATORS; i++) {
        if (m_Indicators[i].isActive && m_Indicators[i].handle != INVALID_HANDLE) {
            if (current_time - m_Indicators[i].lastAccess >= m_Indicators[i].cache.lastUpdate) {
                UpdateIndicator(i);
            }
        }
    }
    
    // Periodic cleanup
    if (current_time - m_LastCleanup >= CLEANUP_INTERVAL) {
        CleanupOldCache();
        OptimizeCache();
        m_LastCleanup = current_time;
    }
    
    // Update statistics
    UpdateStatistics();
}

//+------------------------------------------------------------------+
//| Create Indicator                                                 |
//+------------------------------------------------------------------+
int CIndicatorManager::CreateIndicator(const SIndicatorConfig& config) {
    if (!m_bInitialized) {
        return -1;
    }
    
    // Validate configuration
    if (!ValidateConfig(config)) {
        LogIndicatorEvent("Invalid indicator configuration", LOG_LEVEL_ERROR);
        return -1;
    }
    
    // Find free slot
    int slot = FindFreeSlot();
    if (slot == -1) {
        LogIndicatorEvent("No free slots available for new indicator", LOG_LEVEL_ERROR);
        return -1;
    }
    
    // Initialize indicator instance
    m_Indicators[slot].name = config.Name;
    m_Indicators[slot].handle = INVALID_HANDLE;
    m_Indicators[slot].timeframe = config.Timeframe;
    m_Indicators[slot].period = config.Period;
    m_Indicators[slot].symbol = config.Symbol;
    m_Indicators[slot].isActive = true;
    m_Indicators[slot].lastAccess = TimeCurrent();
    m_Indicators[slot].cache.Clear();
    
    // Initialize the indicator
    if (!InitializeIndicator(slot)) {
        m_Indicators[slot].isActive = false;
        return -1;
    }
    
    m_iIndicatorCount++;
    
    LogIndicatorEvent(StringFormat("Indicator created: %s [ID: %d]", config.Name, slot), LOG_LEVEL_INFO);
    
    return slot;
}

//+------------------------------------------------------------------+
//| Create Moving Average                                            |
//+------------------------------------------------------------------+
int CIndicatorManager::CreateMA(const string& symbol, const ENUM_TIMEFRAMES timeframe,
                                const int period, const ENUM_MA_METHOD method = MODE_SMA,
                                const ENUM_APPLIED_PRICE applied = PRICE_CLOSE) {
    int slot = FindFreeSlot();
    if (slot == -1) {
        if (m_pContext->pLogger != NULL) {
            m_pContext->pLogger->LogError("No free slots for new indicator", __FUNCTION__);
        }
        return -1;
    }
    
    int handle = iMA(symbol, timeframe, period, 0, method, applied);
    if (handle == INVALID_HANDLE) {
        if (m_pContext->pLogger != NULL) {
            m_pContext->pLogger->LogError("Failed to create MA indicator", __FUNCTION__);
        }
        return -1;
    }
    
    // Setup indicator definition
    m_Indicators[slot].name = GenerateIndicatorName("MA", symbol, timeframe, period);
    m_Indicators[slot].handle = handle;
    m_Indicators[slot].timeframe = timeframe;
    m_Indicators[slot].period = period;
    m_Indicators[slot].symbol = symbol;
    m_Indicators[slot].isActive = true;
    m_Indicators[slot].lastAccess = TimeCurrent();
    m_Indicators[slot].cache.Clear();
    
    m_iIndicatorCount++;
    
    if (m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo("Created MA indicator: " + m_Indicators[slot].name, __FUNCTION__);
    }
    
    return slot;
}

//+------------------------------------------------------------------+
//| Create RSI                                                       |
//+------------------------------------------------------------------+
int CIndicatorManager::CreateRSI(const string& symbol, const ENUM_TIMEFRAMES timeframe,
                                 const int period, const ENUM_APPLIED_PRICE applied = PRICE_CLOSE) {
    int slot = FindFreeSlot();
    if (slot == -1) return -1;
    
    int handle = iRSI(symbol, timeframe, period, applied);
    if (handle == INVALID_HANDLE) return -1;
    
    m_Indicators[slot].name = GenerateIndicatorName("RSI", symbol, timeframe, period);
    m_Indicators[slot].handle = handle;
    m_Indicators[slot].timeframe = timeframe;
    m_Indicators[slot].period = period;
    m_Indicators[slot].symbol = symbol;
    m_Indicators[slot].isActive = true;
    m_Indicators[slot].lastAccess = TimeCurrent();
    m_Indicators[slot].cache.Clear();
    
    m_iIndicatorCount++;
    
    if (m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo("Created RSI indicator: " + m_Indicators[slot].name, __FUNCTION__);
    }
    
    return slot;
}

//+------------------------------------------------------------------+
//| Create MACD                                                      |
//+------------------------------------------------------------------+
int CIndicatorManager::CreateMACD(const string& symbol, const ENUM_TIMEFRAMES timeframe,
                                  const int fast_period, const int slow_period, const int signal_period,
                                  const ENUM_APPLIED_PRICE applied = PRICE_CLOSE) {
    int slot = FindFreeSlot();
    if (slot == -1) return -1;
    
    int handle = iMACD(symbol, timeframe, fast_period, slow_period, signal_period, applied);
    if (handle == INVALID_HANDLE) return -1;
    
    m_Indicators[slot].name = GenerateIndicatorName("MACD", symbol, timeframe, fast_period);
    m_Indicators[slot].handle = handle;
    m_Indicators[slot].timeframe = timeframe;
    m_Indicators[slot].period = fast_period;
    m_Indicators[slot].symbol = symbol;
    m_Indicators[slot].isActive = true;
    m_Indicators[slot].lastAccess = TimeCurrent();
    m_Indicators[slot].cache.Clear();
    
    m_iIndicatorCount++;
    
    if (m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo("Created MACD indicator: " + m_Indicators[slot].name, __FUNCTION__);
    }
    
    return slot;
}

//+------------------------------------------------------------------+
//| Create Bollinger Bands                                          |
//+------------------------------------------------------------------+
int CIndicatorManager::CreateBollinger(const string& symbol, const ENUM_TIMEFRAMES timeframe,
                                        const int period, const double deviation = 2.0,
                                        const ENUM_APPLIED_PRICE applied = PRICE_CLOSE) {
    int slot = FindFreeSlot();
    if (slot == -1) return -1;
    
    int handle = iBands(symbol, timeframe, period, 0, deviation, applied);
    if (handle == INVALID_HANDLE) return -1;
    
    m_Indicators[slot].name = GenerateIndicatorName("BB", symbol, timeframe, period);
    m_Indicators[slot].handle = handle;
    m_Indicators[slot].timeframe = timeframe;
    m_Indicators[slot].period = period;
    m_Indicators[slot].symbol = symbol;
    m_Indicators[slot].isActive = true;
    m_Indicators[slot].lastAccess = TimeCurrent();
    m_Indicators[slot].cache.Clear();
    
    m_iIndicatorCount++;
    
    if (m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo("Created Bollinger indicator: " + m_Indicators[slot].name, __FUNCTION__);
    }
    
    return slot;
}

//+------------------------------------------------------------------+
//| Create ATR                                                       |
//+------------------------------------------------------------------+
int CIndicatorManager::CreateATR(const string& symbol, const ENUM_TIMEFRAMES timeframe,
                                 const int period) {
    int slot = FindFreeSlot();
    if (slot == -1) return -1;
    
    int handle = iATR(symbol, timeframe, period);
    if (handle == INVALID_HANDLE) return -1;
    
    m_Indicators[slot].name = GenerateIndicatorName("ATR", symbol, timeframe, period);
    m_Indicators[slot].handle = handle;
    m_Indicators[slot].timeframe = timeframe;
    m_Indicators[slot].period = period;
    m_Indicators[slot].symbol = symbol;
    m_Indicators[slot].isActive = true;
    m_Indicators[slot].lastAccess = TimeCurrent();
    m_Indicators[slot].cache.Clear();
    
    m_iIndicatorCount++;
    
    if (m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo("Created ATR indicator: " + m_Indicators[slot].name, __FUNCTION__);
    }
    
    return slot;
}

//+------------------------------------------------------------------+
//| Get Value                                                        |
//+------------------------------------------------------------------+
double CIndicatorManager::GetValue(const int indicator_id, const int buffer = 0, const int shift = 0) {
    if (!m_bInitialized || indicator_id < 0 || indicator_id >= MAX_INDICATORS) {
        return EMPTY_VALUE;
    }
    
    if (!m_Indicators[indicator_id].isActive) {
        return EMPTY_VALUE;
    }
    
    // Update access statistics
    m_Indicators[indicator_id].lastAccess = TimeCurrent();
    
    // Check cache first
    if (m_bCacheEnabled && IsCacheValid(indicator_id)) {
        double value = EMPTY_VALUE;
        if (m_Indicators[indicator_id].cache.GetValue(shift, value, m_Indicators[indicator_id].cache.timestamps[m_Indicators[indicator_id].cache.head])) {
            m_Stats.CacheHits++;
            return value;
        }
    }
    
    // Cache miss - get from indicator
    m_Stats.CacheMisses++;
    
    double value = EMPTY_VALUE;
    int handle = m_Indicators[indicator_id].handle;
    
    if (handle != INVALID_HANDLE) {
        double buffer_data[];
        if (CopyBuffer(handle, buffer, shift, 1, buffer_data) > 0) {
            value = buffer_data[0];
            
            // Update cache if enabled
            if (m_bCacheEnabled) {
                CacheValue(indicator_id, buffer, shift, value);
            }
        }
    }
    
    return value;
}

//+------------------------------------------------------------------+
//| Get MACD Values                                                  |
//+------------------------------------------------------------------+
bool CIndicatorManager::GetMACD(const int indicator_id, const int shift, double& main, double& signal) {
    if (!m_bInitialized || indicator_id < 0 || indicator_id >= MAX_INDICATORS) {
        return false;
    }
    
    if (!m_Indicators[indicator_id].isActive || m_Indicators[indicator_id].handle == INVALID_HANDLE) {
        return false;
    }
    
    main = GetValue(indicator_id, 0, shift);
    signal = GetValue(indicator_id, 1, shift);
    
    return (main != EMPTY_VALUE && signal != EMPTY_VALUE);
}

//+------------------------------------------------------------------+
//| Get Bollinger Bands Values                                      |
//+------------------------------------------------------------------+
bool CIndicatorManager::GetBollinger(const int indicator_id, const int shift, double& upper,
                                      double& middle, double& lower) {
    if (!m_bInitialized || indicator_id < 0 || indicator_id >= MAX_INDICATORS) {
        return false;
    }
    
    if (!m_Indicators[indicator_id].isActive || m_Indicators[indicator_id].handle == INVALID_HANDLE) {
        return false;
    }
    
    upper = GetValue(indicator_id, 1, shift);   // Upper band
    middle = GetValue(indicator_id, 0, shift);  // Middle line (MA)
    lower = GetValue(indicator_id, 2, shift);   // Lower band
    
    return (upper != EMPTY_VALUE && middle != EMPTY_VALUE && lower != EMPTY_VALUE);
}

//+------------------------------------------------------------------+
//| Is Data Ready                                                    |
//+------------------------------------------------------------------+
bool CIndicatorManager::IsDataReady(const int indicator_id, const int required_bars = 1) {
    if (!m_bInitialized || indicator_id < 0 || indicator_id >= MAX_INDICATORS) {
        return false;
    }
    
    if (!m_Indicators[indicator_id].isActive || m_Indicators[indicator_id].handle == INVALID_HANDLE) {
        return false;
    }
    
    return BarsCalculated(m_Indicators[indicator_id].handle) >= required_bars;
}

//+------------------------------------------------------------------+
//| Clear Cache                                                      |
//+------------------------------------------------------------------+
void CIndicatorManager::ClearCache(const int indicator_id = -1) {
    if (!m_bInitialized) {
        return;
    }
    
    if (indicator_id == -1) {
        // Clear all caches
        for (int i = 0; i < MAX_INDICATORS; i++) {
            if (m_Indicators[i].isActive) {
                InvalidateCache(i);
            }
        }
        LogIndicatorEvent("All indicator caches cleared", LOG_LEVEL_INFO);
    } else if (indicator_id >= 0 && indicator_id < MAX_INDICATORS) {
        InvalidateCache(indicator_id);
        LogIndicatorEvent(StringFormat("Cache cleared for indicator ID: %d", indicator_id), LOG_LEVEL_INFO);
    }
}

//+------------------------------------------------------------------+
//| Get Performance Report                                           |
//+------------------------------------------------------------------+
string CIndicatorManager::GetPerformanceReport() {
    string report = "=== INDICATOR MANAGER PERFORMANCE REPORT ===\n";
    
    report += StringFormat("Total Indicators: %d\n", m_Stats.TotalIndicators);
    report += StringFormat("Active Indicators: %d\n", m_Stats.ActiveIndicators);
    report += StringFormat("Cached Values: %d\n", m_Stats.CachedValues);
    report += StringFormat("Cache Hits: %d\n", m_Stats.CacheHits);
    report += StringFormat("Cache Misses: %d\n", m_Stats.CacheMisses);
    report += StringFormat("Cache Hit Ratio: %.2f%%\n", m_Stats.CacheHitRatio * 100);
    report += StringFormat("Updates/Second: %d\n", m_Stats.UpdatesPerSecond);
    
    return report;
}

//+------------------------------------------------------------------+
//| Get System Summary                                               |
//+------------------------------------------------------------------+
string CIndicatorManager::GetSystemSummary() {
    return StringFormat("Indicators: %d/%d | Cache: %.1f%% | Updates: %d/s",
                        m_Stats.ActiveIndicators,
                        MAX_INDICATORS,
                        m_Stats.CacheHitRatio * 100,
                        m_Stats.UpdatesPerSecond);
}

//+------------------------------------------------------------------+
//| Internal Methods                                                 |
//+------------------------------------------------------------------+
int CIndicatorManager::FindFreeSlot() {
    for (int i = 0; i < MAX_INDICATORS; i++) {
        if (!m_Indicators[i].isActive) {
            return i;
        }
    }
    return -1;
}

bool CIndicatorManager::ValidateConfig(const SIndicatorConfig& config) {
    if (config.Symbol == "" || config.Period <= 0) {
        return false;
    }
    
    if (config.CacheSize <= 0 || config.CacheSize > 10000) {
        return false;
    }
    
    return true;
}

bool CIndicatorManager::InitializeIndicator(const int indicator_id) {
    if (indicator_id < 0 || indicator_id >= MAX_INDICATORS) {
        return false;
    }
    
    if (m_Indicators[indicator_id].isActive) {
        return true;
    }
    
    int handle = INVALID_HANDLE;
    
    // Create indicator based on type
    switch(m_Indicators[indicator_id].handle) {
        case INVALID_HANDLE:
            // This should never happen, as the handle should be initialized
            break;
            
        default:
            // This should also never happen, as the handle should be initialized
            break;
    }
    
    if (handle == INVALID_HANDLE) {
        HandleIndicatorError(indicator_id, "Failed to create indicator handle");
        return false;
    }
    
    m_Indicators[indicator_id].handle = handle;
    m_Indicators[indicator_id].isActive = true;
    
    // Load initial data
    if (!LoadIndicatorData(indicator_id)) {
        LogIndicatorEvent("Warning: Failed to load initial indicator data", LOG_LEVEL_WARNING);
    }
    
    return true;
}

void CIndicatorManager::UpdateIndicator(const int indicator_id) {
    if (indicator_id < 0 || indicator_id >= MAX_INDICATORS) {
        return;
    }
    
    if (!m_Indicators[indicator_id].isActive) {
        return;
    }
    
    // Update cache if enabled
    if (m_bCacheEnabled) {
        UpdateCache(indicator_id);
    }
    
    m_Indicators[indicator_id].lastAccess = TimeCurrent();
}

bool CIndicatorManager::IsCacheValid(const int indicator_id) {
    if (indicator_id < 0 || indicator_id >= MAX_INDICATORS) {
        return false;
    }
    
    if (!m_bCacheEnabled) {
        return false;
    }
    
    datetime current_time = TimeCurrent();
    datetime last_update = m_Indicators[indicator_id].lastAccess;
    
    // Check if cache is too old
    if (current_time - last_update > m_dtCacheTimeout) {
        return false;
    }
    
    return m_Indicators[indicator_id].cache.isValid;
}

void CIndicatorManager::InvalidateCache(const int indicator_id) {
    if (indicator_id < 0 || indicator_id >= MAX_INDICATORS) {
        return;
    }
    
    m_Indicators[indicator_id].cache.isValid = false;
    m_Indicators[indicator_id].cache.size = 0;
}

void CIndicatorManager::UpdateCache(const int indicator_id) {
    if (indicator_id < 0 || indicator_id >= MAX_INDICATORS) {
        return;
    }
    
    int handle = m_Indicators[indicator_id].handle;
    if (handle == INVALID_HANDLE) {
        return;
    }
    
    int cache_size = m_Indicators[indicator_id].cache.size;
    int buffer_count = m_Indicators[indicator_id].cache.size;
    
    // Copy data from indicator buffers
    for (int buffer = 0; buffer < buffer_count; buffer++) {
        double temp_buffer[];
        int copied = CopyBuffer(handle, buffer, 0, cache_size, temp_buffer);
        
        if (copied > 0) {
            switch(buffer) {
                case 0:
                    ArrayCopy(m_Indicators[indicator_id].cache.values, temp_buffer);
                    break;
                case 1:
                    ArrayCopy(m_Indicators[indicator_id].cache.values + 1000, temp_buffer);
                    break;
                case 2:
                    ArrayCopy(m_Indicators[indicator_id].cache.values + 2000, temp_buffer);
                    break;
                case 3:
                    ArrayCopy(m_Indicators[indicator_id].cache.values + 3000, temp_buffer);
                    break;
            }
        }
    }
    
    // Copy time data
    datetime temp_times[];
    int time_copied = CopyTime(m_Indicators[indicator_id].symbol,
                               m_Indicators[indicator_id].timeframe,
                               0, cache_size, temp_times);
    
    if (time_copied > 0) {
        ArrayCopy(m_Indicators[indicator_id].cache.timestamps, temp_times);
        m_Indicators[indicator_id].cache.size = time_copied;
    }
    
    m_Indicators[indicator_id].cache.isValid = true;
    m_Indicators[indicator_id].lastAccess = TimeCurrent();
}

void CIndicatorManager::CleanupOldCache() {
    datetime current_time = TimeCurrent();
    
    for (int i = 0; i < MAX_INDICATORS; i++) {
        if (m_Indicators[i].isActive) {
            // Check if indicator hasn't been accessed recently
            if (current_time - m_Indicators[i].lastAccess > MAX_CACHE_AGE) {
                InvalidateCache(i);
            }
        }
    }
}

void CIndicatorManager::UpdateStatistics() {
    m_Stats.TotalIndicators = 0;
    m_Stats.ActiveIndicators = 0;
    m_Stats.CachedValues = 0;
    
    for (int i = 0; i < MAX_INDICATORS; i++) {
        if (m_Indicators[i].isActive) {
            m_Stats.TotalIndicators++;
            
            if (m_Indicators[i].isActive) {
                m_Stats.ActiveIndicators++;
            }
            
            if (m_Indicators[i].cache.isValid) {
                m_Stats.CachedValues += m_Indicators[i].cache.size;
            }
        }
    }
    
    // Calculate cache hit ratio
    int total_accesses = m_Stats.CacheHits + m_Stats.CacheMisses;
    if (total_accesses > 0) {
        m_Stats.CacheHitRatio = (double)m_Stats.CacheHits / total_accesses;
    }
    
    m_Stats.LastStatsUpdate = TimeCurrent();
}

string CIndicatorManager::IndicatorTypeToString(const ENUM_INDICATOR_TYPE type) {
    switch(type) {
        case INDICATOR_MA: return "Moving Average";
        case INDICATOR_RSI: return "RSI";
        case INDICATOR_MACD: return "MACD";
        case INDICATOR_BOLLINGER: return "Bollinger Bands";
        case INDICATOR_STOCHASTIC: return "Stochastic";
        case INDICATOR_ATR: return "ATR";
        case INDICATOR_ADX: return "ADX";
        case INDICATOR_CCI: return "CCI";
        case INDICATOR_WILLIAMS: return "Williams %R";
        case INDICATOR_MOMENTUM: return "Momentum";
        case INDICATOR_CUSTOM: return "Custom";
        default: return "Unknown";
    }
}

void CIndicatorManager::LogIndicatorEvent(const string& event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO) {
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
    }
}

void CIndicatorManager::HandleIndicatorError(const int indicator_id, const string& error_msg) {
    if (indicator_id >= 0 && indicator_id < MAX_INDICATORS) {
        m_Indicators[indicator_id].isActive = false;
        m_Indicators[indicator_id].handle = INVALID_HANDLE;
        
        LogIndicatorEvent(StringFormat("Indicator error [ID: %d]: %s", indicator_id, error_msg), LOG_LEVEL_ERROR);
        
        // Attempt recovery
        if (!RecoverIndicator(indicator_id)) {
            LogIndicatorEvent(StringFormat("Failed to recover indicator [ID: %d]", indicator_id), LOG_LEVEL_ERROR);
        }
    }
}

bool CIndicatorManager::RecoverIndicator(const int indicator_id) {
    if (indicator_id < 0 || indicator_id >= MAX_INDICATORS) {
        return false;
    }
    
    // Release old handle
    if (m_Indicators[indicator_id].handle != INVALID_HANDLE) {
        IndicatorRelease(m_Indicators[indicator_id].handle);
        m_Indicators[indicator_id].handle = INVALID_HANDLE;
    }
    
    // Try to reinitialize
    m_Indicators[indicator_id].isActive = true;
    
    if (InitializeIndicator(indicator_id)) {
        LogIndicatorEvent(StringFormat("Indicator recovered [ID: %d]", indicator_id), LOG_LEVEL_INFO);
        return true;
    }
    
    return false;
}

void CIndicatorManager::CacheValue(int indicator_id, int buffer_num, int shift, double value) {
    if (indicator_id < 0 || indicator_id >= MAX_INDICATORS) {
        return;
    }
    
    if (!m_bCacheEnabled) {
        return;
    }
    
    datetime current_time = TimeCurrent();
    m_Indicators[indicator_id].cache.AddValue(value, current_time);
}

string CIndicatorManager::GenerateIndicatorName(const string& type, const string& symbol, 
                                                 ENUM_TIMEFRAMES timeframe, int period) {
    return StringFormat("%s_%s_%s_%d", type, symbol, EnumToString(timeframe), period);
}

void CIndicatorManager::ReleaseAllIndicators() {
    for (int i = 0; i < MAX_INDICATORS; i++) {
        if (m_Indicators[i].isActive && m_Indicators[i].handle != INVALID_HANDLE) {
            IndicatorRelease(m_Indicators[i].handle);
            m_Indicators[i].handle = INVALID_HANDLE;
            m_Indicators[i].isActive = false;
        }
    }
    m_iIndicatorCount = 0;
}

} // namespace ApexPullback::v5

#endif // INDICATOR_MANAGER_MQH_