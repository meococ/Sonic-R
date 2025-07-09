//+------------------------------------------------------------------+
//|                                                DataCollector.mqh |
//|                                    APEX Pullback EA v5.0 FINAL   |
//|                                    Advanced Data Collection      |
//+------------------------------------------------------------------+
#property copyright "APEX Trading Systems"
#property version   "5.00"
#property strict

#include "../../00_Core/CommonStructs.mqh"

//+------------------------------------------------------------------+
//| Data type enumeration                                           |
//+------------------------------------------------------------------+
enum ENUM_DATA_TYPE {
    DATA_TYPE_PRICE,
    DATA_TYPE_VOLUME,
    DATA_TYPE_SPREAD,
    DATA_TYPE_TICK,
    DATA_TYPE_BAR,
    DATA_TYPE_INDICATOR,
    DATA_TYPE_TRADE,
    DATA_TYPE_ACCOUNT,
    DATA_TYPE_MARKET_INFO,
    DATA_TYPE_ECONOMIC,
    DATA_TYPE_NEWS,
    DATA_TYPE_SENTIMENT,
    DATA_TYPE_VOLATILITY,
    DATA_TYPE_CORRELATION,
    DATA_TYPE_CUSTOM
};

//+------------------------------------------------------------------+
//| Data source enumeration                                         |
//+------------------------------------------------------------------+
enum ENUM_DATA_SOURCE {
    DATA_SOURCE_TERMINAL,
    DATA_SOURCE_BROKER,
    DATA_SOURCE_EXTERNAL_API,
    DATA_SOURCE_FILE,
    DATA_SOURCE_DATABASE,
    DATA_SOURCE_NETWORK,
    DATA_SOURCE_CALCULATED,
    DATA_SOURCE_CACHED,
    DATA_SOURCE_REAL_TIME,
    DATA_SOURCE_HISTORICAL
};

//+------------------------------------------------------------------+
//| Data quality enumeration                                        |
//+------------------------------------------------------------------+
enum ENUM_DATA_QUALITY {
    DATA_QUALITY_UNKNOWN,
    DATA_QUALITY_POOR,
    DATA_QUALITY_FAIR,
    DATA_QUALITY_GOOD,
    DATA_QUALITY_EXCELLENT,
    DATA_QUALITY_VERIFIED
};

//+------------------------------------------------------------------+
//| Data status enumeration                                         |
//+------------------------------------------------------------------+
enum ENUM_DATA_STATUS {
    DATA_STATUS_PENDING,
    DATA_STATUS_COLLECTING,
    DATA_STATUS_AVAILABLE,
    DATA_STATUS_PROCESSING,
    DATA_STATUS_CACHED,
    DATA_STATUS_EXPIRED,
    DATA_STATUS_ERROR,
    DATA_STATUS_INVALID
};

//+------------------------------------------------------------------+
//| Data collection mode enumeration                                |
//+------------------------------------------------------------------+
enum ENUM_COLLECTION_MODE {
    COLLECTION_MODE_REAL_TIME,
    COLLECTION_MODE_BATCH,
    COLLECTION_MODE_ON_DEMAND,
    COLLECTION_MODE_SCHEDULED,
    COLLECTION_MODE_EVENT_DRIVEN,
    COLLECTION_MODE_CONTINUOUS
};

//+------------------------------------------------------------------+
//| Data point structure                                            |
//+------------------------------------------------------------------+
struct SDataPoint {
    int ID;
    ENUM_DATA_TYPE Type;
    ENUM_DATA_SOURCE Source;
    ENUM_DATA_QUALITY Quality;
    ENUM_DATA_STATUS Status;
    
    datetime Timestamp;
    datetime CollectedTime;
    datetime ExpiryTime;
    
    string Symbol;
    ENUM_TIMEFRAMES Timeframe;
    
    // Data values
    double NumericValue;
    string StringValue;
    int IntegerValue;
    bool BooleanValue;
    
    // Extended data
    double Values[20];
    int ValueCount;
    string Labels[20];
    int LabelCount;
    
    // Metadata
    string Category;
    string Subcategory;
    string Description;
    string Units;
    
    // Quality metrics
    double Accuracy;
    double Reliability;
    double Completeness;
    int ValidationScore;
    
    // Source information
    string SourceName;
    string SourceVersion;
    string CollectionMethod;
    
    // Processing info
    bool IsProcessed;
    bool IsNormalized;
    bool IsFiltered;
    bool IsAggregated;
    
    // Relationships
    int ParentDataID;
    int RelatedDataIDs[10];
    int RelatedDataCount;
    
    // Performance
    double CollectionTimeMs;
    int SizeBytes;
    
    // Validation
    bool IsValidated;
    string ValidationErrors[5];
    int ValidationErrorCount;
};

//+------------------------------------------------------------------+
//| Data series structure                                           |
//+------------------------------------------------------------------+
struct SDataSeries {
    int ID;
    string Name;
    string Description;
    ENUM_DATA_TYPE Type;
    ENUM_DATA_SOURCE Source;
    
    string Symbol;
    ENUM_TIMEFRAMES Timeframe;
    
    // Data points
    int DataPointIDs[10000];
    int DataPointCount;
    int MaxDataPoints;
    
    // Time range
    datetime StartTime;
    datetime EndTime;
    datetime LastUpdateTime;
    
    // Statistics
    double MinValue;
    double MaxValue;
    double AverageValue;
    double StandardDeviation;
    
    // Configuration
    bool AutoUpdate;
    int UpdateIntervalSeconds;
    bool EnableCaching;
    int CacheExpirySeconds;
    
    // Quality metrics
    ENUM_DATA_QUALITY OverallQuality;
    double CompletenessRatio;
    int MissingDataPoints;
    int InvalidDataPoints;
    
    // Performance
    double AverageCollectionTime;
    double TotalCollectionTime;
    int CollectionCount;
    
    // Status
    ENUM_DATA_STATUS Status;
    bool IsActive;
    string LastError;
};

//+------------------------------------------------------------------+
//| Data collection configuration                                   |
//+------------------------------------------------------------------+
struct SDataCollectionConfig {
    ENUM_COLLECTION_MODE Mode;
    
    // Timing settings
    int CollectionIntervalMs;
    int BatchSize;
    int MaxConcurrentCollections;
    int TimeoutMs;
    
    // Quality settings
    ENUM_DATA_QUALITY MinQuality;
    bool EnableValidation;
    bool EnableNormalization;
    bool EnableFiltering;
    
    // Storage settings
    bool EnableCaching;
    int CacheExpirySeconds;
    int MaxCacheSize;
    bool EnablePersistence;
    string PersistenceFile;
    
    // Performance settings
    bool EnableCompression;
    bool EnableBatching;
    int MaxMemoryUsageMB;
    bool EnableAsyncCollection;
    
    // Error handling
    int MaxRetries;
    int RetryDelayMs;
    bool ContinueOnError;
    bool LogErrors;
    
    // Filtering
    string SymbolFilter;
    ENUM_TIMEFRAMES TimeframeFilter;
    datetime StartTimeFilter;
    datetime EndTimeFilter;
    
    // Advanced settings
    bool EnableRealTimeUpdates;
    bool EnableHistoricalData;
    bool EnableDataValidation;
    bool EnableQualityMonitoring;
};

//+------------------------------------------------------------------+
//| Data collection statistics                                      |
//+------------------------------------------------------------------+
struct SDataCollectionStats {
    int TotalDataPoints;
    int DataPointsToday;
    int DataPointsThisWeek;
    int DataPointsThisMonth;
    
    int DataPointsByType[15];
    int DataPointsBySource[10];
    int DataPointsByQuality[6];
    int DataPointsByStatus[8];
    
    int TotalCollections;
    int SuccessfulCollections;
    int FailedCollections;
    int TimeoutCollections;
    
    double AverageCollectionTime;
    double TotalCollectionTime;
    double MinCollectionTime;
    double MaxCollectionTime;
    
    datetime LastCollectionTime;
    datetime LastSuccessfulCollection;
    datetime LastFailedCollection;
    
    // Quality metrics
    double AverageQualityScore;
    double DataCompletenessRatio;
    int ValidationErrors;
    int DataInconsistencies;
    
    // Performance metrics
    int PeakCollectionsPerSecond;
    int PeakCollectionsPerMinute;
    double PeakMemoryUsage;
    
    // Cache statistics
    int CacheHits;
    int CacheMisses;
    double CacheHitRatio;
    int CachedDataPoints;
    
    // Error statistics
    int NetworkErrors;
    int DataErrors;
    int ValidationErrors;
    int TimeoutErrors;
    int UnknownErrors;
};

//+------------------------------------------------------------------+
//| Data collector class                                            |
//+------------------------------------------------------------------+
class CDataCollector {
private:
    EAContext* m_pContext;
    
    // Data storage
    SDataPoint m_DataPoints[50000];
    int m_DataPointCount;
    int m_NextDataPointID;
    
    SDataSeries m_DataSeries[100];
    int m_DataSeriesCount;
    int m_NextSeriesID;
    
    // Configuration and statistics
    SDataCollectionConfig m_Config;
    SDataCollectionStats m_Statistics;
    
    // Collection state
    bool m_bInitialized;
    bool m_bCollecting;
    bool m_bPaused;
    
    // Performance tracking
    datetime m_LastCollectionTime;
    int m_CollectionCount;
    double m_TotalCollectionTime;
    
    // Cache management
    int m_CachedDataIDs[10000];
    int m_CachedDataCount;
    datetime m_CacheLastCleanup;
    
    // Error handling
    string m_LastError;
    int m_ErrorCount;
    
    // Threading simulation
    bool m_bAsyncMode;
    int m_ActiveCollections;
    
public:
    CDataCollector();
    ~CDataCollector();
    
    // Core methods
    bool Initialize(EAContext* context);
    void Deinitialize();
    void Update();
    void ProcessCollections();
    
    // Data collection methods
    int CollectPriceData(const string symbol, const ENUM_TIMEFRAMES timeframe, const int count = 1000);
    int CollectVolumeData(const string symbol, const ENUM_TIMEFRAMES timeframe, const int count = 1000);
    int CollectSpreadData(const string symbol, const int count = 1000);
    int CollectTickData(const string symbol, const int count = 1000);
    int CollectIndicatorData(const string symbol, const ENUM_TIMEFRAMES timeframe, const string indicatorName, const int count = 1000);
    int CollectTradeData(const datetime startTime, const datetime endTime);
    int CollectAccountData();
    int CollectMarketInfo(const string symbol);
    int CollectEconomicData(const datetime startTime, const datetime endTime);
    int CollectNewsData(const datetime startTime, const datetime endTime);
    int CollectSentimentData(const string symbol);
    int CollectVolatilityData(const string symbol, const ENUM_TIMEFRAMES timeframe, const int count = 1000);
    int CollectCorrelationData(const string symbol1, const string symbol2, const ENUM_TIMEFRAMES timeframe, const int count = 1000);
    int CollectCustomData(const string dataName, const string source, const string parameters);
    
    // Batch collection methods
    bool CollectBatchData(const string symbols[], const int symbolCount, const ENUM_TIMEFRAMES timeframe);
    bool CollectMultiTimeframeData(const string symbol, const ENUM_TIMEFRAMES timeframes[], const int timeframeCount);
    bool CollectHistoricalData(const string symbol, const ENUM_TIMEFRAMES timeframe, const datetime startTime, const datetime endTime);
    
    // Data series management
    int CreateDataSeries(const string name, const ENUM_DATA_TYPE type, const string symbol, const ENUM_TIMEFRAMES timeframe);
    bool DeleteDataSeries(const int seriesID);
    bool UpdateDataSeries(const int seriesID);
    SDataSeries GetDataSeries(const int seriesID) const;
    int[] GetDataSeriesList() const;
    
    // Data point management
    int CreateDataPoint(const ENUM_DATA_TYPE type, const string symbol, const double value, const datetime timestamp);
    bool UpdateDataPoint(const int dataPointID, const double value, const datetime timestamp);
    bool DeleteDataPoint(const int dataPointID);
    SDataPoint GetDataPoint(const int dataPointID) const;
    
    // Data queries
    int[] GetDataPointsByType(const ENUM_DATA_TYPE type) const;
    int[] GetDataPointsBySymbol(const string symbol) const;
    int[] GetDataPointsByTimeframe(const ENUM_TIMEFRAMES timeframe) const;
    int[] GetDataPointsByTimeRange(const datetime startTime, const datetime endTime) const;
    int[] GetDataPointsByQuality(const ENUM_DATA_QUALITY quality) const;
    int[] GetDataPointsBySource(const ENUM_DATA_SOURCE source) const;
    
    // Data analysis
    double CalculateAverage(const int dataPointIDs[], const int count) const;
    double CalculateStandardDeviation(const int dataPointIDs[], const int count) const;
    double CalculateMinValue(const int dataPointIDs[], const int count) const;
    double CalculateMaxValue(const int dataPointIDs[], const int count) const;
    double CalculateMedian(const int dataPointIDs[], const int count) const;
    double CalculateCorrelation(const int dataPointIDs1[], const int dataPointIDs2[], const int count) const;
    
    // Data validation
    bool ValidateDataPoint(const SDataPoint& dataPoint);
    bool ValidateDataSeries(const SDataSeries& dataSeries);
    ENUM_DATA_QUALITY AssessDataQuality(const int dataPointID);
    bool FixDataInconsistencies(const int seriesID);
    
    // Data normalization
    bool NormalizeDataPoint(const int dataPointID);
    bool NormalizeDataSeries(const int seriesID);
    bool ApplyDataFilter(const int seriesID, const string filterType, const double parameters[]);
    
    // Cache management
    bool CacheDataPoint(const int dataPointID);
    bool RemoveFromCache(const int dataPointID);
    bool IsCached(const int dataPointID) const;
    void ClearCache();
    void CleanupExpiredCache();
    
    // Configuration
    void SetConfig(const SDataCollectionConfig& config);
    SDataCollectionConfig GetConfig() const { return m_Config; }
    void LoadConfig();
    void SaveConfig();
    void ResetConfig();
    
    // Statistics
    SDataCollectionStats GetStatistics() const { return m_Statistics; }
    void UpdateStatistics();
    void ResetStatistics();
    
    // Control methods
    void StartCollection();
    void StopCollection();
    void PauseCollection();
    void ResumeCollection();
    bool IsCollecting() const { return m_bCollecting; }
    bool IsPaused() const { return m_bPaused; }
    
    // Status methods
    int GetDataPointCount() const { return m_DataPointCount; }
    int GetDataSeriesCount() const { return m_DataSeriesCount; }
    int GetCachedDataCount() const { return m_CachedDataCount; }
    int GetActiveCollectionCount() const { return m_ActiveCollections; }
    
    // Performance monitoring
    double GetAverageCollectionTime() const;
    int GetCollectionsPerSecond() const;
    double GetMemoryUsage() const;
    double GetCacheHitRatio() const;
    
    // Data export/import
    bool ExportData(const string filePath, const int seriesID = -1);
    bool ImportData(const string filePath);
    bool ExportDataToCSV(const string filePath, const int seriesID);
    bool ExportDataToJSON(const string filePath, const int seriesID);
    
    // Maintenance
    void CleanupOldData();
    void CompactDataStorage();
    void OptimizePerformance();
    
private:
    // Internal collection methods
    bool CollectSingleDataPoint(const ENUM_DATA_TYPE type, const string symbol, const ENUM_TIMEFRAMES timeframe);
    bool CollectDataBatch(const ENUM_DATA_TYPE type, const string symbol, const ENUM_TIMEFRAMES timeframe, const int count);
    
    // Data processing helpers
    bool ProcessRawData(SDataPoint& dataPoint);
    bool ApplyQualityFilters(SDataPoint& dataPoint);
    bool NormalizeDataValues(SDataPoint& dataPoint);
    
    // Validation helpers
    bool ValidateNumericValue(const double value, const ENUM_DATA_TYPE type);
    bool ValidateTimestamp(const datetime timestamp);
    bool ValidateSymbol(const string symbol);
    
    // Cache helpers
    int FindCachedData(const int dataPointID);
    bool AddToCache(const int dataPointID);
    bool RemoveCachedData(const int index);
    
    // Performance helpers
    void StartPerformanceTimer();
    double StopPerformanceTimer();
    void UpdatePerformanceMetrics(const double collectionTime);
    
    // Error handling
    void HandleCollectionError(const string error, const ENUM_DATA_TYPE type);
    void LogCollectionError(const string error, const ENUM_LOG_LEVEL level = LOG_LEVEL_ERROR);
    
    // Utility methods
    string GetDataTypeString(const ENUM_DATA_TYPE type);
    string GetDataSourceString(const ENUM_DATA_SOURCE source);
    string GetDataQualityString(const ENUM_DATA_QUALITY quality);
    string GetDataStatusString(const ENUM_DATA_STATUS status);
    
    // File operations
    bool SaveDataHistory();
    bool LoadDataHistory();
    
    // Memory management
    void CheckMemoryUsage();
    void FreeUnusedMemory();
    
    // Configuration helpers
    void InitializeDefaultConfig();
    void ValidateConfig();
    
    // Statistics helpers
    void UpdateDataTypeStatistics(const ENUM_DATA_TYPE type);
    void UpdateQualityStatistics(const ENUM_DATA_QUALITY quality);
    void UpdateSourceStatistics(const ENUM_DATA_SOURCE source);
    
    // Logging
    void LogCollectionActivity(const string activity, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CDataCollector::CDataCollector() {
    m_pContext = NULL;
    m_bInitialized = false;
    m_bCollecting = false;
    m_bPaused = false;
    
    m_DataPointCount = 0;
    m_NextDataPointID = 1;
    m_DataSeriesCount = 0;
    m_NextSeriesID = 1;
    
    m_LastCollectionTime = 0;
    m_CollectionCount = 0;
    m_TotalCollectionTime = 0;
    
    m_CachedDataCount = 0;
    m_CacheLastCleanup = 0;
    
    m_LastError = "";
    m_ErrorCount = 0;
    
    m_bAsyncMode = false;
    m_ActiveCollections = 0;
    
    // Initialize arrays
    ArrayInitialize(m_CachedDataIDs, 0);
    
    // Initialize default configuration
    InitializeDefaultConfig();
    
    // Initialize statistics
    ZeroMemory(m_Statistics);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CDataCollector::~CDataCollector() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize Data Collector                                       |
//+------------------------------------------------------------------+
bool CDataCollector::Initialize(EAContext* context) {
    if (context == NULL) {
        Print("[DATA COLLECTOR ERROR] Context is NULL");
        return false;
    }
    
    m_pContext = context;
    
    // Load configuration
    LoadConfig();
    
    // Load data history if enabled
    if (m_Config.EnablePersistence) {
        LoadDataHistory();
    }
    
    // Initialize cache cleanup timer
    m_CacheLastCleanup = TimeCurrent();
    
    m_bInitialized = true;
    LogCollectionActivity("Data Collector initialized successfully");
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize Data Collector                                     |
//+------------------------------------------------------------------+
void CDataCollector::Deinitialize() {
    if (m_bInitialized) {
        // Stop any active collections
        StopCollection();
        
        // Save data history if enabled
        if (m_Config.EnablePersistence) {
            SaveDataHistory();
        }
        
        // Save configuration
        SaveConfig();
        
        LogCollectionActivity("Data Collector deinitialized");
    }
    
    m_bInitialized = false;
    m_pContext = NULL;
}

//+------------------------------------------------------------------+
//| Initialize default configuration                                |
//+------------------------------------------------------------------+
void CDataCollector::InitializeDefaultConfig() {
    ZeroMemory(m_Config);
    
    m_Config.Mode = COLLECTION_MODE_REAL_TIME;
    m_Config.CollectionIntervalMs = 1000;
    m_Config.BatchSize = 100;
    m_Config.MaxConcurrentCollections = 5;
    m_Config.TimeoutMs = 5000;
    
    m_Config.MinQuality = DATA_QUALITY_FAIR;
    m_Config.EnableValidation = true;
    m_Config.EnableNormalization = true;
    m_Config.EnableFiltering = true;
    
    m_Config.EnableCaching = true;
    m_Config.CacheExpirySeconds = 3600;
    m_Config.MaxCacheSize = 10000;
    m_Config.EnablePersistence = false;
    m_Config.PersistenceFile = "data_history.dat";
    
    m_Config.EnableCompression = false;
    m_Config.EnableBatching = true;
    m_Config.MaxMemoryUsageMB = 200;
    m_Config.EnableAsyncCollection = false;
    
    m_Config.MaxRetries = 3;
    m_Config.RetryDelayMs = 1000;
    m_Config.ContinueOnError = true;
    m_Config.LogErrors = true;
    
    m_Config.SymbolFilter = "";
    m_Config.TimeframeFilter = PERIOD_CURRENT;
    m_Config.StartTimeFilter = 0;
    m_Config.EndTimeFilter = 0;
    
    m_Config.EnableRealTimeUpdates = true;
    m_Config.EnableHistoricalData = true;
    m_Config.EnableDataValidation = true;
    m_Config.EnableQualityMonitoring = true;
}

//+------------------------------------------------------------------+
//| Update method                                                   |
//+------------------------------------------------------------------+
void CDataCollector::Update() {
    if (!m_bInitialized || m_bPaused) {
        return;
    }
    
    // Process any pending collections
    ProcessCollections();
    
    // Cleanup expired cache periodically
    if (TimeCurrent() - m_CacheLastCleanup > 300) { // Every 5 minutes
        CleanupExpiredCache();
        m_CacheLastCleanup = TimeCurrent();
    }
    
    // Update statistics
    UpdateStatistics();
    
    // Check memory usage
    CheckMemoryUsage();
}

//+------------------------------------------------------------------+
//| Process collections                                             |
//+------------------------------------------------------------------+
void CDataCollector::ProcessCollections() {
    if (!m_bCollecting) {
        return;
    }
    
    // This is a placeholder for actual collection processing
    // In a real implementation, this would handle queued collection requests
    
    LogCollectionActivity("Processing collections");
}

//+------------------------------------------------------------------+
//| Collect price data                                              |
//+------------------------------------------------------------------+
int CDataCollector::CollectPriceData(const string symbol, const ENUM_TIMEFRAMES timeframe, const int count = 1000) {
    if (!m_bInitialized) {
        return -1;
    }
    
    StartPerformanceTimer();
    
    // Create data series for price data
    int seriesID = CreateDataSeries("PriceData_" + symbol + "_" + EnumToString(timeframe), DATA_TYPE_PRICE, symbol, timeframe);
    
    if (seriesID <= 0) {
        LogCollectionActivity("Failed to create price data series for " + symbol, LOG_LEVEL_ERROR);
        return -1;
    }
    
    // Collect OHLC data
    MqlRates rates[];
    int copied = CopyRates(symbol, timeframe, 0, count, rates);
    
    if (copied <= 0) {
        LogCollectionActivity("Failed to copy rates for " + symbol + ": " + IntegerToString(GetLastError()), LOG_LEVEL_ERROR);
        return -1;
    }
    
    // Create data points for each rate
    for (int i = 0; i < copied; i++) {
        // Create data point for close price
        int dataPointID = CreateDataPoint(DATA_TYPE_PRICE, symbol, rates[i].close, rates[i].time);
        
        if (dataPointID > 0) {
            // Add additional OHLC data
            SDataPoint& dataPoint = m_DataPoints[dataPointID - 1];
            dataPoint.Values[0] = rates[i].open;
            dataPoint.Values[1] = rates[i].high;
            dataPoint.Values[2] = rates[i].low;
            dataPoint.Values[3] = rates[i].close;
            dataPoint.Values[4] = (double)rates[i].tick_volume;
            dataPoint.ValueCount = 5;
            
            dataPoint.Labels[0] = "Open";
            dataPoint.Labels[1] = "High";
            dataPoint.Labels[2] = "Low";
            dataPoint.Labels[3] = "Close";
            dataPoint.Labels[4] = "Volume";
            dataPoint.LabelCount = 5;
            
            dataPoint.Timeframe = timeframe;
            dataPoint.Source = DATA_SOURCE_TERMINAL;
            dataPoint.Quality = DATA_QUALITY_GOOD;
            dataPoint.Status = DATA_STATUS_AVAILABLE;
            
            // Add to series
            if (m_DataSeries[seriesID - 1].DataPointCount < ArraySize(m_DataSeries[seriesID - 1].DataPointIDs)) {
                m_DataSeries[seriesID - 1].DataPointIDs[m_DataSeries[seriesID - 1].DataPointCount] = dataPointID;
                m_DataSeries[seriesID - 1].DataPointCount++;
            }
        }
    }
    
    // Update series statistics
    if (seriesID > 0) {
        SDataSeries& series = m_DataSeries[seriesID - 1];
        series.LastUpdateTime = TimeCurrent();
        series.Status = DATA_STATUS_AVAILABLE;
        
        // Calculate basic statistics
        if (series.DataPointCount > 0) {
            double sum = 0;
            double minVal = DBL_MAX;
            double maxVal = -DBL_MAX;
            
            for (int i = 0; i < series.DataPointCount; i++) {
                int dpID = series.DataPointIDs[i];
                if (dpID > 0 && dpID <= m_DataPointCount) {
                    double value = m_DataPoints[dpID - 1].NumericValue;
                    sum += value;
                    if (value < minVal) minVal = value;
                    if (value > maxVal) maxVal = value;
                }
            }
            
            series.AverageValue = sum / series.DataPointCount;
            series.MinValue = minVal;
            series.MaxValue = maxVal;
        }
    }
    
    double collectionTime = StopPerformanceTimer();
    UpdatePerformanceMetrics(collectionTime);
    
    LogCollectionActivity("Collected " + IntegerToString(copied) + " price data points for " + symbol + " in " + DoubleToString(collectionTime, 2) + "ms");
    
    return seriesID;
}

//+------------------------------------------------------------------+
//| Create data series                                              |
//+------------------------------------------------------------------+
int CDataCollector::CreateDataSeries(const string name, const ENUM_DATA_TYPE type, const string symbol, const ENUM_TIMEFRAMES timeframe) {
    if (m_DataSeriesCount >= ArraySize(m_DataSeries)) {
        LogCollectionActivity("Data series storage full", LOG_LEVEL_ERROR);
        return -1;
    }
    
    SDataSeries series;
    ZeroMemory(series);
    
    series.ID = m_NextSeriesID++;
    series.Name = name;
    series.Description = "Data series for " + symbol;
    series.Type = type;
    series.Source = DATA_SOURCE_TERMINAL;
    series.Symbol = symbol;
    series.Timeframe = timeframe;
    
    series.DataPointCount = 0;
    series.MaxDataPoints = ArraySize(series.DataPointIDs);
    
    series.StartTime = TimeCurrent();
    series.EndTime = 0;
    series.LastUpdateTime = TimeCurrent();
    
    series.MinValue = DBL_MAX;
    series.MaxValue = -DBL_MAX;
    series.AverageValue = 0;
    series.StandardDeviation = 0;
    
    series.AutoUpdate = true;
    series.UpdateIntervalSeconds = 60;
    series.EnableCaching = m_Config.EnableCaching;
    series.CacheExpirySeconds = m_Config.CacheExpirySeconds;
    
    series.OverallQuality = DATA_QUALITY_UNKNOWN;
    series.CompletenessRatio = 0;
    series.MissingDataPoints = 0;
    series.InvalidDataPoints = 0;
    
    series.AverageCollectionTime = 0;
    series.TotalCollectionTime = 0;
    series.CollectionCount = 0;
    
    series.Status = DATA_STATUS_PENDING;
    series.IsActive = true;
    series.LastError = "";
    
    // Validate series
    if (!ValidateDataSeries(series)) {
        LogCollectionActivity("Invalid data series created", LOG_LEVEL_ERROR);
        return -1;
    }
    
    // Store series
    m_DataSeries[m_DataSeriesCount] = series;
    m_DataSeriesCount++;
    
    LogCollectionActivity("Data series created: ID=" + IntegerToString(series.ID) + ", Name=" + name);
    
    return series.ID;
}

//+------------------------------------------------------------------+
//| Create data point                                               |
//+------------------------------------------------------------------+
int CDataCollector::CreateDataPoint(const ENUM_DATA_TYPE type, const string symbol, const double value, const datetime timestamp) {
    if (m_DataPointCount >= ArraySize(m_DataPoints)) {
        LogCollectionActivity("Data point storage full", LOG_LEVEL_ERROR);
        return -1;
    }
    
    SDataPoint dataPoint;
    ZeroMemory(dataPoint);
    
    dataPoint.ID = m_NextDataPointID++;
    dataPoint.Type = type;
    dataPoint.Source = DATA_SOURCE_TERMINAL;
    dataPoint.Quality = DATA_QUALITY_UNKNOWN;
    dataPoint.Status = DATA_STATUS_PENDING;
    
    dataPoint.Timestamp = timestamp;
    dataPoint.CollectedTime = TimeCurrent();
    dataPoint.ExpiryTime = TimeCurrent() + m_Config.CacheExpirySeconds;
    
    dataPoint.Symbol = symbol;
    dataPoint.Timeframe = PERIOD_CURRENT;
    
    dataPoint.NumericValue = value;
    dataPoint.StringValue = "";
    dataPoint.IntegerValue = 0;
    dataPoint.BooleanValue = false;
    
    dataPoint.ValueCount = 0;
    dataPoint.LabelCount = 0;
    
    dataPoint.Category = GetDataTypeString(type);
    dataPoint.Subcategory = "";
    dataPoint.Description = "Data point for " + symbol;
    dataPoint.Units = "";
    
    dataPoint.Accuracy = 0;
    dataPoint.Reliability = 0;
    dataPoint.Completeness = 0;
    dataPoint.ValidationScore = 0;
    
    dataPoint.SourceName = "MT5 Terminal";
    dataPoint.SourceVersion = "1.0";
    dataPoint.CollectionMethod = "Direct";
    
    dataPoint.IsProcessed = false;
    dataPoint.IsNormalized = false;
    dataPoint.IsFiltered = false;
    dataPoint.IsAggregated = false;
    
    dataPoint.ParentDataID = 0;
    dataPoint.RelatedDataCount = 0;
    
    dataPoint.CollectionTimeMs = 0;
    dataPoint.SizeBytes = sizeof(SDataPoint);
    
    dataPoint.IsValidated = false;
    dataPoint.ValidationErrorCount = 0;
    
    // Validate data point
    if (!ValidateDataPoint(dataPoint)) {
        LogCollectionActivity("Invalid data point created", LOG_LEVEL_ERROR);
        return -1;
    }
    
    // Assess quality
    dataPoint.Quality = AssessDataQuality(dataPoint.ID);
    dataPoint.Status = DATA_STATUS_AVAILABLE;
    
    // Store data point
    m_DataPoints[m_DataPointCount] = dataPoint;
    m_DataPointCount++;
    
    // Cache if enabled
    if (m_Config.EnableCaching) {
        CacheDataPoint(dataPoint.ID);
    }
    
    return dataPoint.ID;
}

//+------------------------------------------------------------------+
//| Validate data point                                             |
//+------------------------------------------------------------------+
bool CDataCollector::ValidateDataPoint(const SDataPoint& dataPoint) {
    if (dataPoint.ID <= 0) return false;
    if (dataPoint.Symbol == "") return false;
    if (dataPoint.Timestamp <= 0) return false;
    if (!ValidateNumericValue(dataPoint.NumericValue, dataPoint.Type)) return false;
    if (!ValidateTimestamp(dataPoint.Timestamp)) return false;
    if (!ValidateSymbol(dataPoint.Symbol)) return false;
    
    return true;
}

//+------------------------------------------------------------------+
//| Validate data series                                            |
//+------------------------------------------------------------------+
bool CDataCollector::ValidateDataSeries(const SDataSeries& dataSeries) {
    if (dataSeries.ID <= 0) return false;
    if (dataSeries.Name == "") return false;
    if (dataSeries.Symbol == "") return false;
    
    return true;
}

//+------------------------------------------------------------------+
//| Assess data quality                                             |
//+------------------------------------------------------------------+
ENUM_DATA_QUALITY CDataCollector::AssessDataQuality(const int dataPointID) {
    if (dataPointID <= 0 || dataPointID > m_DataPointCount) {
        return DATA_QUALITY_UNKNOWN;
    }
    
    SDataPoint& dataPoint = m_DataPoints[dataPointID - 1];
    
    int qualityScore = 0;
    
    // Check timestamp validity
    if (dataPoint.Timestamp > 0 && dataPoint.Timestamp <= TimeCurrent()) {
        qualityScore += 20;
    }
    
    // Check value validity
    if (ValidateNumericValue(dataPoint.NumericValue, dataPoint.Type)) {
        qualityScore += 30;
    }
    
    // Check source reliability
    if (dataPoint.Source == DATA_SOURCE_TERMINAL || dataPoint.Source == DATA_SOURCE_BROKER) {
        qualityScore += 25;
    }
    
    // Check completeness
    if (dataPoint.Symbol != "" && dataPoint.Category != "") {
        qualityScore += 15;
    }
    
    // Check freshness
    if (TimeCurrent() - dataPoint.CollectedTime < 3600) { // Within 1 hour
        qualityScore += 10;
    }
    
    // Determine quality level
    if (qualityScore >= 90) return DATA_QUALITY_EXCELLENT;
    if (qualityScore >= 75) return DATA_QUALITY_GOOD;
    if (qualityScore >= 60) return DATA_QUALITY_FAIR;
    if (qualityScore >= 40) return DATA_QUALITY_POOR;
    
    return DATA_QUALITY_UNKNOWN;
}

//+------------------------------------------------------------------+
//| Validation helpers                                              |
//+------------------------------------------------------------------+
bool CDataCollector::ValidateNumericValue(const double value, const ENUM_DATA_TYPE type) {
    if (value != value) return false; // Check for NaN
    if (value == EMPTY_VALUE) return false;
    
    switch(type) {
    case DATA_TYPE_PRICE:
        return (value > 0 && value < 1000000);
    case DATA_TYPE_VOLUME:
        return (value >= 0);
    case DATA_TYPE_SPREAD:
        return (value >= 0 && value < 1000);
    default:
        return true;
    }
}

bool CDataCollector::ValidateTimestamp(const datetime timestamp) {
    return (timestamp > 0 && timestamp <= TimeCurrent() + 86400); // Allow 1 day in future
}

bool CDataCollector::ValidateSymbol(const string symbol) {
    return (symbol != "" && StringLen(symbol) <= 20);
}

//+------------------------------------------------------------------+
//| Cache management                                                |
//+------------------------------------------------------------------+
bool CDataCollector::CacheDataPoint(const int dataPointID) {
    if (m_CachedDataCount >= ArraySize(m_CachedDataIDs)) {
        return false;
    }
    
    // Check if already cached
    if (IsCached(dataPointID)) {
        return true;
    }
    
    m_CachedDataIDs[m_CachedDataCount] = dataPointID;
    m_CachedDataCount++;
    
    return true;
}

bool CDataCollector::IsCached(const int dataPointID) const {
    return (FindCachedData(dataPointID) >= 0);
}

int CDataCollector::FindCachedData(const int dataPointID) {
    for (int i = 0; i < m_CachedDataCount; i++) {
        if (m_CachedDataIDs[i] == dataPointID) {
            return i;
        }
    }
    return -1;
}

void CDataCollector::CleanupExpiredCache() {
    datetime currentTime = TimeCurrent();
    
    for (int i = m_CachedDataCount - 1; i >= 0; i--) {
        int dataPointID = m_CachedDataIDs[i];
        if (dataPointID > 0 && dataPointID <= m_DataPointCount) {
            SDataPoint& dataPoint = m_DataPoints[dataPointID - 1];
            if (currentTime > dataPoint.ExpiryTime) {
                RemoveCachedData(i);
            }
        }
    }
}

bool CDataCollector::RemoveCachedData(const int index) {
    if (index < 0 || index >= m_CachedDataCount) {
        return false;
    }
    
    // Shift array
    for (int i = index; i < m_CachedDataCount - 1; i++) {
        m_CachedDataIDs[i] = m_CachedDataIDs[i + 1];
    }
    
    m_CachedDataCount--;
    return true;
}

//+------------------------------------------------------------------+
//| Performance monitoring                                          |
//+------------------------------------------------------------------+
void CDataCollector::StartPerformanceTimer() {
    m_LastCollectionTime = GetMicrosecondCount();
}

double CDataCollector::StopPerformanceTimer() {
    datetime currentTime = GetMicrosecondCount();
    return (double)(currentTime - m_LastCollectionTime) / 1000.0; // Convert to milliseconds
}

void CDataCollector::UpdatePerformanceMetrics(const double collectionTime) {
    m_CollectionCount++;
    m_TotalCollectionTime += collectionTime;
}

double CDataCollector::GetAverageCollectionTime() const {
    if (m_CollectionCount == 0) return 0.0;
    return m_TotalCollectionTime / m_CollectionCount;
}

//+------------------------------------------------------------------+
//| Control methods                                                 |
//+------------------------------------------------------------------+
void CDataCollector::StartCollection() {
    m_bCollecting = true;
    m_bPaused = false;
    LogCollectionActivity("Data collection started");
}

void CDataCollector::StopCollection() {
    m_bCollecting = false;
    m_bPaused = false;
    LogCollectionActivity("Data collection stopped");
}

void CDataCollector::PauseCollection() {
    m_bPaused = true;
    LogCollectionActivity("Data collection paused");
}

void CDataCollector::ResumeCollection() {
    m_bPaused = false;
    LogCollectionActivity("Data collection resumed");
}

//+------------------------------------------------------------------+
//| Update statistics                                               |
//+------------------------------------------------------------------+
void CDataCollector::UpdateStatistics() {
    m_Statistics.TotalDataPoints = m_DataPointCount;
    m_Statistics.TotalCollections = m_CollectionCount;
    m_Statistics.AverageCollectionTime = GetAverageCollectionTime();
    m_Statistics.TotalCollectionTime = m_TotalCollectionTime;
    m_Statistics.LastCollectionTime = TimeCurrent();
    m_Statistics.CachedDataPoints = m_CachedDataCount;
    
    // Calculate cache hit ratio
    if (m_Statistics.CacheHits + m_Statistics.CacheMisses > 0) {
        m_Statistics.CacheHitRatio = (double)m_Statistics.CacheHits / (m_Statistics.CacheHits + m_Statistics.CacheMisses);
    }
}

//+------------------------------------------------------------------+
//| Utility methods                                                 |
//+------------------------------------------------------------------+
string CDataCollector::GetDataTypeString(const ENUM_DATA_TYPE type) {
    switch(type) {
    case DATA_TYPE_PRICE: return "Price";
    case DATA_TYPE_VOLUME: return "Volume";
    case DATA_TYPE_SPREAD: return "Spread";
    case DATA_TYPE_TICK: return "Tick";
    case DATA_TYPE_BAR: return "Bar";
    case DATA_TYPE_INDICATOR: return "Indicator";
    case DATA_TYPE_TRADE: return "Trade";
    case DATA_TYPE_ACCOUNT: return "Account";
    case DATA_TYPE_MARKET_INFO: return "MarketInfo";
    case DATA_TYPE_ECONOMIC: return "Economic";
    case DATA_TYPE_NEWS: return "News";
    case DATA_TYPE_SENTIMENT: return "Sentiment";
    case DATA_TYPE_VOLATILITY: return "Volatility";
    case DATA_TYPE_CORRELATION: return "Correlation";
    case DATA_TYPE_CUSTOM: return "Custom";
    default: return "Unknown";
    }
}

string CDataCollector::GetDataSourceString(const ENUM_DATA_SOURCE source) {
    switch(source) {
    case DATA_SOURCE_TERMINAL: return "Terminal";
    case DATA_SOURCE_BROKER: return "Broker";
    case DATA_SOURCE_EXTERNAL_API: return "ExternalAPI";
    case DATA_SOURCE_FILE: return "File";
    case DATA_SOURCE_DATABASE: return "Database";
    case DATA_SOURCE_NETWORK: return "Network";
    case DATA_SOURCE_CALCULATED: return "Calculated";
    case DATA_SOURCE_CACHED: return "Cached";
    case DATA_SOURCE_REAL_TIME: return "RealTime";
    case DATA_SOURCE_HISTORICAL: return "Historical";
    default: return "Unknown";
    }
}

string CDataCollector::GetDataQualityString(const ENUM_DATA_QUALITY quality) {
    switch(quality) {
    case DATA_QUALITY_UNKNOWN: return "Unknown";
    case DATA_QUALITY_POOR: return "Poor";
    case DATA_QUALITY_FAIR: return "Fair";
    case DATA_QUALITY_GOOD: return "Good";
    case DATA_QUALITY_EXCELLENT: return "Excellent";
    case DATA_QUALITY_VERIFIED: return "Verified";
    default: return "Unknown";
    }
}

string CDataCollector::GetDataStatusString(const ENUM_DATA_STATUS status) {
    switch(status) {
    case DATA_STATUS_PENDING: return "Pending";
    case DATA_STATUS_COLLECTING: return "Collecting";
    case DATA_STATUS_AVAILABLE: return "Available";
    case DATA_STATUS_PROCESSING: return "Processing";
    case DATA_STATUS_CACHED: return "Cached";
    case DATA_STATUS_EXPIRED: return "Expired";
    case DATA_STATUS_ERROR: return "Error";
    case DATA_STATUS_INVALID: return "Invalid";
    default: return "Unknown";
    }
}

//+------------------------------------------------------------------+
//| Error handling                                                  |
//+------------------------------------------------------------------+
void CDataCollector::HandleCollectionError(const string error, const ENUM_DATA_TYPE type) {
    m_ErrorCount++;
    m_LastError = error;
    LogCollectionError("Collection error for " + GetDataTypeString(type) + ": " + error);
}

void CDataCollector::LogCollectionError(const string error, const ENUM_LOG_LEVEL level = LOG_LEVEL_ERROR) {
    LogCollectionActivity(error, level);
}

//+------------------------------------------------------------------+
//| Memory management                                               |
//+------------------------------------------------------------------+
void CDataCollector::CheckMemoryUsage() {
    // Placeholder for memory usage monitoring
    // In a real implementation, this would check actual memory usage
}

void CDataCollector::FreeUnusedMemory() {
    // Placeholder for memory cleanup
    // In a real implementation, this would free unused memory
}

//+------------------------------------------------------------------+
//| Placeholder methods                                             |
//+------------------------------------------------------------------+
void CDataCollector::LoadConfig() {
    // Placeholder implementation
}

void CDataCollector::SaveConfig() {
    // Placeholder implementation
}

bool CDataCollector::LoadDataHistory() {
    // Placeholder implementation
    return true;
}

bool CDataCollector::SaveDataHistory() {
    // Placeholder implementation
    return true;
}

double CDataCollector::GetMemoryUsage() const {
    // Placeholder implementation
    return (double)(m_DataPointCount * sizeof(SDataPoint) + m_DataSeriesCount * sizeof(SDataSeries)) / (1024 * 1024);
}

double CDataCollector::GetCacheHitRatio() const {
    return m_Statistics.CacheHitRatio;
}

int CDataCollector::GetCollectionsPerSecond() const {
    // Placeholder implementation
    return 0;
}

//+------------------------------------------------------------------+
//| Log collection activity                                         |
//+------------------------------------------------------------------+
void CDataCollector::LogCollectionActivity(const string activity, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO) {
    if (m_pContext != NULL && m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo("[DATA COLLECTOR] " + activity);
    } else {
        Print("[DATA COLLECTOR] " + activity);
    }
}

//+------------------------------------------------------------------+