//+------------------------------------------------------------------+
//|                                          MarketDataProvider.mqh |
//|            MarketDataProvider.mqh - APEX Pullback EA v5 FINAL   |
//|      Description: Comprehensive market data provider with       |
//|                   multi-timeframe support, data validation,     |
//|                   and intelligent caching system.              |
//+------------------------------------------------------------------+

#ifndef MARKET_DATA_PROVIDER_MQH_
#define MARKET_DATA_PROVIDER_MQH_

#include "..\..\CommonStructs.mqh"

namespace ApexPullback {

//+------------------------------------------------------------------+
//| Market Data Quality Structure                                    |
//+------------------------------------------------------------------+
struct SMarketDataQuality {
    bool                  IsValid;              // Data validity flag
    datetime              LastUpdate;          // Last data update time
    int                   MissingBars;         // Number of missing bars
    int                   InvalidBars;         // Number of invalid bars
    double                DataCompleteness;    // Data completeness percentage
    bool                  HasGaps;             // Data gaps detected
    datetime              FirstGapTime;        // First gap timestamp
    datetime              LastGapTime;         // Last gap timestamp
    int                   GapCount;            // Total number of gaps
};

//+------------------------------------------------------------------+
//| OHLC Data Structure                                              |
//+------------------------------------------------------------------+
struct SOHLCData {
    datetime              Time;                 // Bar time
    double                Open;                // Open price
    double                High;                // High price
    double                Low;                 // Low price
    double                Close;               // Close price
    long                  Volume;              // Volume
    long                  TickVolume;          // Tick volume
    int                   Spread;              // Spread
    bool                  IsValid;             // Data validity
};

//+------------------------------------------------------------------+
//| Multi-Timeframe Data Cache                                       |
//+------------------------------------------------------------------+
struct STimeframeCache {
    ENUM_TIMEFRAMES       Timeframe;           // Timeframe
    SOHLCData             Data[];              // OHLC data array
    int                   Size;                // Current size
    int                   MaxSize;             // Maximum cache size
    datetime              LastUpdate;          // Last update time
    SMarketDataQuality    Quality;             // Data quality metrics
    bool                  IsInitialized;       // Initialization status
};

//+------------------------------------------------------------------+
//| Tick Data Structure                                              |
//+------------------------------------------------------------------+
struct STickData {
    datetime              Time;                 // Tick time
    double                Bid;                 // Bid price
    double                Ask;                 // Ask price
    double                Last;                // Last price
    long                  Volume;              // Volume
    uint                  Flags;               // Tick flags
    bool                  IsValid;             // Tick validity
};

//+------------------------------------------------------------------+
//| Market Statistics                                                |
//+------------------------------------------------------------------+
struct SMarketStatistics {
    double                DailyRange;          // Daily price range
    double                AverageTrueRange;    // Average True Range
    double                Volatility;          // Price volatility
    double                AverageVolume;       // Average volume
    double                VolumeRatio;         // Current vs average volume
    int                   TicksPerMinute;      // Ticks per minute
    double                SpreadAverage;       // Average spread
    double                SpreadCurrent;       // Current spread
    datetime              LastCalculation;     // Last calculation time
};

//+------------------------------------------------------------------+
//| CMarketDataProvider - Comprehensive Market Data Management      |
//+------------------------------------------------------------------+
class CMarketDataProvider {
private:
    EAContext*            m_pContext;           // Reference to EA context
    bool                  m_bInitialized;      // Initialization status
    string                m_Symbol;             // Current symbol
    
    // Multi-timeframe cache
    STimeframeCache       m_TimeframeCache[];   // Cache for different timeframes
    int                   m_CacheCount;         // Number of cached timeframes
    
    // Tick data management
    STickData             m_TickHistory[];      // Recent tick history
    int                   m_TickHistorySize;    // Tick history size
    int                   m_MaxTickHistory;     // Maximum tick history
    
    // Market statistics
    SMarketStatistics     m_Statistics;         // Market statistics
    datetime              m_LastStatsUpdate;    // Last statistics update
    
    // Data validation settings
    static const int      MIN_BARS_REQUIRED;
    static const int      MAX_CACHE_SIZE;
    static const double   MAX_PRICE_DEVIATION;
    static const int      TICK_HISTORY_SIZE;
    
public:
    //--- Constructor/Destructor ---
    CMarketDataProvider();
    ~CMarketDataProvider();
    
    //--- Core Methods ---
    bool                  Initialize(EAContext* context, const string& symbol = "");
    void                  Deinitialize();
    bool                  IsInitialized() const { return m_bInitialized; }
    void                  Update();
    
    //--- Data Access Methods ---
    bool                  GetOHLC(const ENUM_TIMEFRAMES timeframe, const int index, SOHLCData& data);
    bool                  GetOHLCArray(const ENUM_TIMEFRAMES timeframe, const int start, const int count, SOHLCData& data[]);
    bool                  GetCurrentTick(STickData& tick);
    bool                  GetTickHistory(STickData& ticks[], const int count = 100);
    
    //--- Price Data Methods ---
    double                GetPrice(const ENUM_TIMEFRAMES timeframe, const int index, const ENUM_APPLIED_PRICE price_type);
    double                GetOpen(const ENUM_TIMEFRAMES timeframe, const int index = 0);
    double                GetHigh(const ENUM_TIMEFRAMES timeframe, const int index = 0);
    double                GetLow(const ENUM_TIMEFRAMES timeframe, const int index = 0);
    double                GetClose(const ENUM_TIMEFRAMES timeframe, const int index = 0);
    long                  GetVolume(const ENUM_TIMEFRAMES timeframe, const int index = 0);
    
    //--- Multi-Timeframe Support ---
    bool                  AddTimeframe(const ENUM_TIMEFRAMES timeframe, const int cache_size = 1000);
    bool                  RemoveTimeframe(const ENUM_TIMEFRAMES timeframe);
    bool                  IsTimeframeSupported(const ENUM_TIMEFRAMES timeframe);
    int                   GetSupportedTimeframes(ENUM_TIMEFRAMES& timeframes[]);
    
    //--- Data Quality Methods ---
    SMarketDataQuality    GetDataQuality(const ENUM_TIMEFRAMES timeframe);
    bool                  ValidateData(const ENUM_TIMEFRAMES timeframe, const int bars_to_check = 100);
    bool                  HasSufficientData(const ENUM_TIMEFRAMES timeframe, const int required_bars);
    double                GetDataCompleteness(const ENUM_TIMEFRAMES timeframe);
    
    //--- Market Statistics ---
    SMarketStatistics     GetMarketStatistics() { return m_Statistics; }
    void                  UpdateStatistics();
    double                GetVolatility(const ENUM_TIMEFRAMES timeframe, const int periods = 20);
    double                GetAverageTrueRange(const ENUM_TIMEFRAMES timeframe, const int periods = 14);
    double                GetVolumeProfile(const ENUM_TIMEFRAMES timeframe, const int periods = 20);
    
    //--- Utility Methods ---
    datetime              GetBarTime(const ENUM_TIMEFRAMES timeframe, const int index = 0);
    int                   GetBarIndex(const ENUM_TIMEFRAMES timeframe, const datetime time);
    bool                  IsNewBar(const ENUM_TIMEFRAMES timeframe);
    int                   GetAvailableBars(const ENUM_TIMEFRAMES timeframe);
    
    //--- Cache Management ---
    void                  RefreshCache(const ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
    void                  ClearCache(const ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
    int                   GetCacheSize(const ENUM_TIMEFRAMES timeframe);
    datetime              GetLastCacheUpdate(const ENUM_TIMEFRAMES timeframe);
    
    //--- Symbol Information ---
    string                GetSymbol() const { return m_Symbol; }
    bool                  SetSymbol(const string& symbol);
    double                GetPoint();
    int                   GetDigits();
    double                GetTickSize();
    double                GetTickValue();
    
private:
    //--- Internal Methods ---
    int                   FindTimeframeIndex(const ENUM_TIMEFRAMES timeframe);
    bool                  LoadHistoricalData(const ENUM_TIMEFRAMES timeframe, const int bars_count);
    bool                  UpdateTimeframeCache(const ENUM_TIMEFRAMES timeframe);
    bool                  ValidateOHLCData(const SOHLCData& data);
    void                  DetectDataGaps(STimeframeCache& cache);
    void                  CalculateDataQuality(STimeframeCache& cache);
    void                  ProcessNewTick();
    void                  UpdateTickHistory(const STickData& tick);
    bool                  IsValidPrice(const double price);
    bool                  IsValidVolume(const long volume);
    void                  LogDataEvent(const string& event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO);
    void                  ResizeCache(STimeframeCache& cache, const int new_size);
};

// Static constants definition
const int CMarketDataProvider::MIN_BARS_REQUIRED = 100;
const int CMarketDataProvider::MAX_CACHE_SIZE = 5000;
const double CMarketDataProvider::MAX_PRICE_DEVIATION = 0.1; // 10%
const int CMarketDataProvider::TICK_HISTORY_SIZE = 1000;

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CMarketDataProvider::CMarketDataProvider() {
    m_pContext = NULL;
    m_bInitialized = false;
    m_Symbol = "";
    m_CacheCount = 0;
    m_TickHistorySize = 0;
    m_MaxTickHistory = TICK_HISTORY_SIZE;
    m_LastStatsUpdate = 0;
    
    // Initialize statistics
    ZeroMemory(m_Statistics);
    
    // Resize arrays
    ArrayResize(m_TimeframeCache, 10); // Support up to 10 timeframes
    ArrayResize(m_TickHistory, m_MaxTickHistory);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CMarketDataProvider::~CMarketDataProvider() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CMarketDataProvider::Initialize(EAContext* context, const string& symbol = "") {
    if (m_bInitialized) {
        return true;
    }
    
    m_pContext = context;
    if (m_pContext == NULL) {
        Print("[MARKET_DATA] Context is NULL");
        return false;
    }
    
    // Set symbol
    m_Symbol = (symbol == "") ? _Symbol : symbol;
    
    // Validate symbol
    if (!SymbolSelect(m_Symbol, true)) {
        if (m_pContext->pLogger != NULL) {
            m_pContext->pLogger->LogError("Failed to select symbol: " + m_Symbol, __FUNCTION__);
        }
        return false;
    }
    
    // Add default timeframes
    if (!AddTimeframe(PERIOD_M1, 1000)) {
        if (m_pContext->pLogger != NULL) {
            m_pContext->pLogger->LogError("Failed to add M1 timeframe", __FUNCTION__);
        }
        return false;
    }
    
    if (!AddTimeframe(PERIOD_M5, 1000)) {
        if (m_pContext->pLogger != NULL) {
            m_pContext->pLogger->LogError("Failed to add M5 timeframe", __FUNCTION__);
        }
        return false;
    }
    
    if (!AddTimeframe(PERIOD_M15, 1000)) {
        if (m_pContext->pLogger != NULL) {
            m_pContext->pLogger->LogError("Failed to add M15 timeframe", __FUNCTION__);
        }
        return false;
    }
    
    if (!AddTimeframe(PERIOD_H1, 500)) {
        if (m_pContext->pLogger != NULL) {
            m_pContext->pLogger->LogError("Failed to add H1 timeframe", __FUNCTION__);
        }
        return false;
    }
    
    // Initialize statistics
    UpdateStatistics();
    
    m_bInitialized = true;
    
    if (m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo("MarketDataProvider initialized for symbol: " + m_Symbol, __FUNCTION__);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CMarketDataProvider::Deinitialize() {
    if (!m_bInitialized) {
        return;
    }
    
    // Clear all caches
    for (int i = 0; i < m_CacheCount; i++) {
        ArrayFree(m_TimeframeCache[i].Data);
    }
    
    ArrayFree(m_TimeframeCache);
    ArrayFree(m_TickHistory);
    
    m_CacheCount = 0;
    m_TickHistorySize = 0;
    
    if (m_pContext != NULL && m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo("MarketDataProvider deinitialized", __FUNCTION__);
    }
    
    m_bInitialized = false;
}

//+------------------------------------------------------------------+
//| Update                                                           |
//+------------------------------------------------------------------+
void CMarketDataProvider::Update() {
    if (!m_bInitialized) {
        return;
    }
    
    // Process new tick
    ProcessNewTick();
    
    // Update all timeframe caches
    for (int i = 0; i < m_CacheCount; i++) {
        UpdateTimeframeCache(m_TimeframeCache[i].Timeframe);
    }
    
    // Update statistics periodically
    datetime current_time = TimeCurrent();
    if (current_time - m_LastStatsUpdate >= 60) { // Every minute
        UpdateStatistics();
        m_LastStatsUpdate = current_time;
    }
}

//+------------------------------------------------------------------+
//| Get OHLC Data                                                    |
//+------------------------------------------------------------------+
bool CMarketDataProvider::GetOHLC(const ENUM_TIMEFRAMES timeframe, const int index, SOHLCData& data) {
    if (!m_bInitialized) {
        return false;
    }
    
    int tf_index = FindTimeframeIndex(timeframe);
    if (tf_index < 0) {
        return false;
    }
    
    STimeframeCache& cache = m_TimeframeCache[tf_index];
    
    if (index < 0 || index >= cache.Size) {
        return false;
    }
    
    data = cache.Data[index];
    return data.IsValid;
}

//+------------------------------------------------------------------+
//| Get Price                                                        |
//+------------------------------------------------------------------+
double CMarketDataProvider::GetPrice(const ENUM_TIMEFRAMES timeframe, const int index, const ENUM_APPLIED_PRICE price_type) {
    SOHLCData data;
    if (!GetOHLC(timeframe, index, data)) {
        return 0.0;
    }
    
    switch(price_type) {
        case PRICE_OPEN:    return data.Open;
        case PRICE_HIGH:    return data.High;
        case PRICE_LOW:     return data.Low;
        case PRICE_CLOSE:   return data.Close;
        case PRICE_MEDIAN:  return (data.High + data.Low) / 2.0;
        case PRICE_TYPICAL: return (data.High + data.Low + data.Close) / 3.0;
        case PRICE_WEIGHTED: return (data.High + data.Low + 2 * data.Close) / 4.0;
        default:            return data.Close;
    }
}

//+------------------------------------------------------------------+
//| Get Open Price                                                   |
//+------------------------------------------------------------------+
double CMarketDataProvider::GetOpen(const ENUM_TIMEFRAMES timeframe, const int index = 0) {
    return GetPrice(timeframe, index, PRICE_OPEN);
}

//+------------------------------------------------------------------+
//| Get High Price                                                   |
//+------------------------------------------------------------------+
double CMarketDataProvider::GetHigh(const ENUM_TIMEFRAMES timeframe, const int index = 0) {
    return GetPrice(timeframe, index, PRICE_HIGH);
}

//+------------------------------------------------------------------+
//| Get Low Price                                                    |
//+------------------------------------------------------------------+
double CMarketDataProvider::GetLow(const ENUM_TIMEFRAMES timeframe, const int index = 0) {
    return GetPrice(timeframe, index, PRICE_LOW);
}

//+------------------------------------------------------------------+
//| Get Close Price                                                  |
//+------------------------------------------------------------------+
double CMarketDataProvider::GetClose(const ENUM_TIMEFRAMES timeframe, const int index = 0) {
    return GetPrice(timeframe, index, PRICE_CLOSE);
}

//+------------------------------------------------------------------+
//| Get Volume                                                       |
//+------------------------------------------------------------------+
long CMarketDataProvider::GetVolume(const ENUM_TIMEFRAMES timeframe, const int index = 0) {
    SOHLCData data;
    if (!GetOHLC(timeframe, index, data)) {
        return 0;
    }
    return data.Volume;
}

//+------------------------------------------------------------------+
//| Add Timeframe                                                    |
//+------------------------------------------------------------------+
bool CMarketDataProvider::AddTimeframe(const ENUM_TIMEFRAMES timeframe, const int cache_size = 1000) {
    if (!m_bInitialized) {
        return false;
    }
    
    // Check if timeframe already exists
    if (FindTimeframeIndex(timeframe) >= 0) {
        return true; // Already exists
    }
    
    // Check cache limit
    if (m_CacheCount >= ArraySize(m_TimeframeCache)) {
        LogDataEvent("Maximum timeframe cache limit reached", LOG_LEVEL_WARNING);
        return false;
    }
    
    // Initialize new cache
    STimeframeCache& cache = m_TimeframeCache[m_CacheCount];
    cache.Timeframe = timeframe;
    cache.MaxSize = MathMin(cache_size, MAX_CACHE_SIZE);
    cache.Size = 0;
    cache.LastUpdate = 0;
    cache.IsInitialized = false;
    
    ArrayResize(cache.Data, cache.MaxSize);
    ZeroMemory(cache.Quality);
    
    // Load historical data
    if (!LoadHistoricalData(timeframe, cache.MaxSize)) {
        LogDataEvent("Failed to load historical data for timeframe: " + EnumToString(timeframe), LOG_LEVEL_ERROR);
        return false;
    }
    
    cache.IsInitialized = true;
    m_CacheCount++;
    
    LogDataEvent("Added timeframe: " + EnumToString(timeframe) + " with cache size: " + IntegerToString(cache_size), LOG_LEVEL_INFO);
    
    return true;
}

//+------------------------------------------------------------------+
//| Validate Data                                                    |
//+------------------------------------------------------------------+
bool CMarketDataProvider::ValidateData(const ENUM_TIMEFRAMES timeframe, const int bars_to_check = 100) {
    int tf_index = FindTimeframeIndex(timeframe);
    if (tf_index < 0) {
        return false;
    }
    
    STimeframeCache& cache = m_TimeframeCache[tf_index];
    int check_count = MathMin(bars_to_check, cache.Size);
    
    int invalid_count = 0;
    
    for (int i = 0; i < check_count; i++) {
        if (!ValidateOHLCData(cache.Data[i])) {
            invalid_count++;
        }
    }
    
    double validity_ratio = (check_count > 0) ? (double)(check_count - invalid_count) / check_count : 0.0;
    
    cache.Quality.IsValid = (validity_ratio >= 0.95); // 95% validity threshold
    cache.Quality.InvalidBars = invalid_count;
    cache.Quality.DataCompleteness = validity_ratio * 100.0;
    
    return cache.Quality.IsValid;
}

//+------------------------------------------------------------------+
//| Update Statistics                                                |
//+------------------------------------------------------------------+
void CMarketDataProvider::UpdateStatistics() {
    if (!m_bInitialized) {
        return;
    }
    
    // Get current prices
    double current_high = GetHigh(PERIOD_D1, 0);
    double current_low = GetLow(PERIOD_D1, 0);
    
    if (current_high > 0 && current_low > 0) {
        m_Statistics.DailyRange = current_high - current_low;
    }
    
    // Calculate ATR
    m_Statistics.AverageTrueRange = GetAverageTrueRange(PERIOD_H1, 14);
    
    // Calculate volatility
    m_Statistics.Volatility = GetVolatility(PERIOD_H1, 20);
    
    // Update volume statistics
    long current_volume = GetVolume(PERIOD_H1, 0);
    static long volume_sum = 0;
    static int volume_count = 0;
    
    if (current_volume > 0) {
        volume_sum += current_volume;
        volume_count++;
        m_Statistics.AverageVolume = (double)volume_sum / volume_count;
        m_Statistics.VolumeRatio = (m_Statistics.AverageVolume > 0) ? 
                                   (double)current_volume / m_Statistics.AverageVolume : 1.0;
    }
    
    // Update spread statistics
    m_Statistics.SpreadCurrent = SymbolInfoInteger(m_Symbol, SYMBOL_SPREAD);
    
    static double spread_sum = 0;
    static int spread_count = 0;
    
    if (m_Statistics.SpreadCurrent > 0) {
        spread_sum += m_Statistics.SpreadCurrent;
        spread_count++;
        m_Statistics.SpreadAverage = spread_sum / spread_count;
    }
    
    m_Statistics.LastCalculation = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Get Volatility                                                   |
//+------------------------------------------------------------------+
double CMarketDataProvider::GetVolatility(const ENUM_TIMEFRAMES timeframe, const int periods = 20) {
    if (periods <= 1) {
        return 0.0;
    }
    
    double sum = 0.0;
    double sum_squares = 0.0;
    int valid_periods = 0;
    
    for (int i = 0; i < periods; i++) {
        double close_current = GetClose(timeframe, i);
        double close_previous = GetClose(timeframe, i + 1);
        
        if (close_current > 0 && close_previous > 0) {
            double return_rate = (close_current - close_previous) / close_previous;
            sum += return_rate;
            sum_squares += return_rate * return_rate;
            valid_periods++;
        }
    }
    
    if (valid_periods <= 1) {
        return 0.0;
    }
    
    double mean = sum / valid_periods;
    double variance = (sum_squares / valid_periods) - (mean * mean);
    
    return MathSqrt(variance);
}

//+------------------------------------------------------------------+
//| Get Average True Range                                           |
//+------------------------------------------------------------------+
double CMarketDataProvider::GetAverageTrueRange(const ENUM_TIMEFRAMES timeframe, const int periods = 14) {
    if (periods <= 0) {
        return 0.0;
    }
    
    double atr_sum = 0.0;
    int valid_periods = 0;
    
    for (int i = 0; i < periods; i++) {
        double high = GetHigh(timeframe, i);
        double low = GetLow(timeframe, i);
        double close_prev = GetClose(timeframe, i + 1);
        
        if (high > 0 && low > 0 && close_prev > 0) {
            double tr1 = high - low;
            double tr2 = MathAbs(high - close_prev);
            double tr3 = MathAbs(low - close_prev);
            
            double true_range = MathMax(tr1, MathMax(tr2, tr3));
            atr_sum += true_range;
            valid_periods++;
        }
    }
    
    return (valid_periods > 0) ? atr_sum / valid_periods : 0.0;
}

//+------------------------------------------------------------------+
//| Is New Bar                                                       |
//+------------------------------------------------------------------+
bool CMarketDataProvider::IsNewBar(const ENUM_TIMEFRAMES timeframe) {
    static datetime last_bar_time = 0;
    datetime current_bar_time = GetBarTime(timeframe, 0);
    
    if (current_bar_time != last_bar_time) {
        last_bar_time = current_bar_time;
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Get Bar Time                                                     |
//+------------------------------------------------------------------+
datetime CMarketDataProvider::GetBarTime(const ENUM_TIMEFRAMES timeframe, const int index = 0) {
    SOHLCData data;
    if (!GetOHLC(timeframe, index, data)) {
        return 0;
    }
    return data.Time;
}

//+------------------------------------------------------------------+
//| Internal Methods                                                 |
//+------------------------------------------------------------------+
int CMarketDataProvider::FindTimeframeIndex(const ENUM_TIMEFRAMES timeframe) {
    for (int i = 0; i < m_CacheCount; i++) {
        if (m_TimeframeCache[i].Timeframe == timeframe) {
            return i;
        }
    }
    return -1;
}

bool CMarketDataProvider::LoadHistoricalData(const ENUM_TIMEFRAMES timeframe, const int bars_count) {
    int tf_index = FindTimeframeIndex(timeframe);
    if (tf_index < 0) {
        return false;
    }
    
    STimeframeCache& cache = m_TimeframeCache[tf_index];
    
    // Load OHLC data
    datetime time_array[];
    double open_array[], high_array[], low_array[], close_array[];
    long volume_array[], tick_volume_array[];
    int spread_array[];
    
    int copied = CopyTime(m_Symbol, timeframe, 0, bars_count, time_array);
    if (copied <= 0) {
        LogDataEvent("Failed to copy time data for " + EnumToString(timeframe), LOG_LEVEL_ERROR);
        return false;
    }
    
    CopyOpen(m_Symbol, timeframe, 0, copied, open_array);
    CopyHigh(m_Symbol, timeframe, 0, copied, high_array);
    CopyLow(m_Symbol, timeframe, 0, copied, low_array);
    CopyClose(m_Symbol, timeframe, 0, copied, close_array);
    CopyRealVolume(m_Symbol, timeframe, 0, copied, volume_array);
    CopyTickVolume(m_Symbol, timeframe, 0, copied, tick_volume_array);
    CopySpread(m_Symbol, timeframe, 0, copied, spread_array);
    
    // Fill cache
    cache.Size = copied;
    for (int i = 0; i < copied; i++) {
        cache.Data[i].Time = time_array[i];
        cache.Data[i].Open = open_array[i];
        cache.Data[i].High = high_array[i];
        cache.Data[i].Low = low_array[i];
        cache.Data[i].Close = close_array[i];
        cache.Data[i].Volume = (ArraySize(volume_array) > i) ? volume_array[i] : 0;
        cache.Data[i].TickVolume = (ArraySize(tick_volume_array) > i) ? tick_volume_array[i] : 0;
        cache.Data[i].Spread = (ArraySize(spread_array) > i) ? spread_array[i] : 0;
        cache.Data[i].IsValid = ValidateOHLCData(cache.Data[i]);
    }
    
    cache.LastUpdate = TimeCurrent();
    
    // Calculate data quality
    CalculateDataQuality(cache);
    
    LogDataEvent(StringFormat("Loaded %d bars for %s", copied, EnumToString(timeframe)), LOG_LEVEL_INFO);
    
    return true;
}

bool CMarketDataProvider::ValidateOHLCData(const SOHLCData& data) {
    // Check for valid prices
    if (data.Open <= 0 || data.High <= 0 || data.Low <= 0 || data.Close <= 0) {
        return false;
    }
    
    // Check price relationships
    if (data.High < data.Low || data.High < data.Open || data.High < data.Close ||
        data.Low > data.Open || data.Low > data.Close) {
        return false;
    }
    
    // Check for reasonable price ranges
    double range = data.High - data.Low;
    double avg_price = (data.High + data.Low) / 2.0;
    
    if (range / avg_price > MAX_PRICE_DEVIATION) {
        return false; // Unrealistic price movement
    }
    
    return true;
}

void CMarketDataProvider::ProcessNewTick() {
    STickData tick;
    tick.Time = TimeCurrent();
    tick.Bid = SymbolInfoDouble(m_Symbol, SYMBOL_BID);
    tick.Ask = SymbolInfoDouble(m_Symbol, SYMBOL_ASK);
    tick.Last = SymbolInfoDouble(m_Symbol, SYMBOL_LAST);
    tick.Volume = SymbolInfoInteger(m_Symbol, SYMBOL_VOLUME);
    tick.IsValid = (tick.Bid > 0 && tick.Ask > 0 && tick.Ask > tick.Bid);
    
    if (tick.IsValid) {
        UpdateTickHistory(tick);
    }
}

void CMarketDataProvider::UpdateTickHistory(const STickData& tick) {
    if (m_TickHistorySize < m_MaxTickHistory) {
        m_TickHistory[m_TickHistorySize] = tick;
        m_TickHistorySize++;
    } else {
        // Shift array and add new tick
        for (int i = 0; i < m_MaxTickHistory - 1; i++) {
            m_TickHistory[i] = m_TickHistory[i + 1];
        }
        m_TickHistory[m_MaxTickHistory - 1] = tick;
    }
}

void CMarketDataProvider::CalculateDataQuality(STimeframeCache& cache) {
    int valid_bars = 0;
    int total_bars = cache.Size;
    
    for (int i = 0; i < total_bars; i++) {
        if (cache.Data[i].IsValid) {
            valid_bars++;
        }
    }
    
    cache.Quality.DataCompleteness = (total_bars > 0) ? (double)valid_bars / total_bars * 100.0 : 0.0;
    cache.Quality.InvalidBars = total_bars - valid_bars;
    cache.Quality.IsValid = (cache.Quality.DataCompleteness >= 95.0);
    cache.Quality.LastUpdate = TimeCurrent();
    
    DetectDataGaps(cache);
}

void CMarketDataProvider::DetectDataGaps(STimeframeCache& cache) {
    cache.Quality.HasGaps = false;
    cache.Quality.GapCount = 0;
    
    int timeframe_seconds = PeriodSeconds(cache.Timeframe);
    
    for (int i = 1; i < cache.Size; i++) {
        datetime expected_time = cache.Data[i-1].Time + timeframe_seconds;
        if (cache.Data[i].Time > expected_time) {
            if (!cache.Quality.HasGaps) {
                cache.Quality.HasGaps = true;
                cache.Quality.FirstGapTime = cache.Data[i].Time;
            }
            cache.Quality.LastGapTime = cache.Data[i].Time;
            cache.Quality.GapCount++;
        }
    }
}

void CMarketDataProvider::LogDataEvent(const string& event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO) {
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

} // namespace ApexPullback

#endif // MARKET_DATA_PROVIDER_MQH_