//+------------------------------------------------------------------+
//|                                               NewsAnalysis.mqh |
//|                                    APEX Pullback EA v5.0 FINAL |
//|                                      Advanced News Analysis    |
//+------------------------------------------------------------------+
#ifndef NEWS_ANALYSIS_MQH
#define NEWS_ANALYSIS_MQH

#include "../../01_Framework/CommonStructs.mqh"



//+------------------------------------------------------------------+
//| News Analysis Enumerations                                       |
//+------------------------------------------------------------------+
enum ENUM_NEWS_FILTER_LEVEL {
    NEWS_FILTER_NONE,           // No news filtering
    NEWS_FILTER_LOW,            // Filter low impact news only
    NEWS_FILTER_MEDIUM,         // Filter medium+ impact news
    NEWS_FILTER_HIGH,           // Filter high impact news only
    NEWS_FILTER_CRITICAL,       // Filter critical news only
    NEWS_FILTER_ADAPTIVE,       // Adaptive filtering based on volatility
    NEWS_FILTER_CUSTOM          // Custom filtering rules
};

enum ENUM_NEWS_IMPACT_LEVEL {
    NEWS_IMPACT_NONE,           // No impact
    NEWS_IMPACT_LOW,            // Low impact (1 star)
    NEWS_IMPACT_MEDIUM,         // Medium impact (2 stars)
    NEWS_IMPACT_HIGH,           // High impact (3 stars)
    NEWS_IMPACT_CRITICAL,       // Critical impact (market moving)
    NEWS_IMPACT_UNKNOWN         // Unknown impact
};

enum ENUM_NEWS_SOURCE {
    NEWS_SOURCE_FOREXFACTORY,   // Forex Factory
    NEWS_SOURCE_INVESTING,      // Investing.com
    NEWS_SOURCE_MYFXBOOK,       // MyFxBook
    NEWS_SOURCE_FXStreet,       // FXStreet
    NEWS_SOURCE_DAILYFX,        // DailyFX
    NEWS_SOURCE_ECONOMIC_CALENDAR, // Economic Calendar
    NEWS_SOURCE_CUSTOM,         // Custom source
    NEWS_SOURCE_API             // API source
};

enum ENUM_NEWS_CATEGORY {
    NEWS_CAT_MONETARY_POLICY,   // Central bank decisions
    NEWS_CAT_EMPLOYMENT,        // Employment data
    NEWS_CAT_INFLATION,         // Inflation/CPI data
    NEWS_CAT_GDP,               // GDP and growth
    NEWS_CAT_RETAIL_SALES,      // Consumer spending
    NEWS_CAT_MANUFACTURING,     // Manufacturing data
    NEWS_CAT_TRADE_BALANCE,     // Trade and current account
    NEWS_CAT_CONFIDENCE,        // Consumer/Business confidence
    NEWS_CAT_HOUSING,           // Housing market data
    NEWS_CAT_POLITICAL,         // Political events
    NEWS_CAT_GEOPOLITICAL,      // Geopolitical events
    NEWS_CAT_EARNINGS,          // Corporate earnings
    NEWS_CAT_OTHER              // Other events
};

//+------------------------------------------------------------------+
//| News Analysis Structures                                         |
//+------------------------------------------------------------------+
struct SNewsEvent {
    datetime              Time;                 // Event time
    string                Currency;             // Affected currency
    string                CountryCode;          // Country code (US, EU, etc.)
    string                EventName;            // Event name
    string                Description;          // Event description
    ENUM_NEWS_IMPACT_LEVEL Impact;             // Impact level
    ENUM_NEWS_CATEGORY    Category;             // Event category
    ENUM_NEWS_SOURCE      Source;               // Data source
    string                Previous;             // Previous value
    string                Forecast;             // Forecast value
    string                Actual;               // Actual value (if available)
    bool                  IsProcessed;          // Has been processed
    bool                  IsActive;             // Currently active
    double                VolatilityFactor;     // Expected volatility impact
    double                DirectionalBias;      // Expected directional bias
    datetime              EffectiveStart;       // Effect start time
    datetime              EffectiveEnd;         // Effect end time
    int                   Priority;             // Priority ranking
    string                Tags[];               // Additional tags
};

struct SNewsFilter {
    ENUM_NEWS_FILTER_LEVEL FilterLevel;        // Filter level
    int                   MinImpactLevel;       // Minimum impact level
    int                   MinutesBeforeEvent;   // Minutes before event
    int                   MinutesAfterEvent;    // Minutes after event
    bool                  FilterBySymbol;       // Filter by current symbol
    bool                  FilterBySession;      // Filter by trading session
    bool                  EnableHolidayFilter;  // Filter market holidays
    bool                  EnableVoiceNews;      // Include voice/unscheduled news
    string                ExcludedCurrencies[]; // Excluded currencies
    string                FocusCurrencies[];    // Focus currencies only
    ENUM_NEWS_CATEGORY    ExcludedCategories[]; // Excluded categories
    double                MinVolatilityThreshold; // Min volatility threshold
    bool                  UseMLPredictions;     // Use ML impact predictions
};

struct SNewsImpactAnalysis {
    datetime              AnalysisTime;         // When analysis was done
    ENUM_NEWS_IMPACT_LEVEL CurrentImpact;      // Current news impact
    ENUM_NEWS_IMPACT_LEVEL UpcomingImpact;     // Upcoming impact (next 4 hours)
    bool                  InNewsWindow;         // Currently in news window
    bool                  HasUpcomingNews;      // Has news in next period
    datetime              NextEventTime;        // Next significant event time
    string                NextEventName;        // Next event name
    string                ActiveEvents[];       // Currently active events
    double                VolatilityMultiplier; // Expected volatility multiplier
    double                DirectionalBias;      // Market directional bias
    double                RiskScore;            // Overall risk score (0-100)
    string                TradingRecommendation; // Trading recommendation
    bool                  AllowNewTrades;       // Allow new trades
    bool                  AllowScaling;         // Allow position scaling
    bool                  RecommendClose;       // Recommend closing positions
};

struct SNewsSourceConfig {
    ENUM_NEWS_SOURCE      Source;               // News source
    string                DataFile;             // Data file path
    string                URL;                  // API URL (if applicable)
    string                APIKey;               // API key (if required)
    int                   UpdateInterval;       // Update interval (minutes)
    bool                  IsEnabled;            // Source enabled
    datetime              LastUpdate;           // Last successful update
    int                   SuccessfulUpdates;    // Number of successful updates
    int                   FailedUpdates;        // Number of failed updates
    double                ReliabilityScore;     // Reliability score (0-1)
};

struct SMarketImpactModel {
    string                Currency;             // Currency pair
    ENUM_NEWS_CATEGORY    Category;             // News category
    double                ImpactCoefficient;    // Impact coefficient
    double                DecayRate;            // Effect decay rate
    double                VolatilityMultiplier; // Volatility multiplier
    double                DirectionalBias;      // Directional bias
    int                   EffectDuration;       // Effect duration (minutes)
    double                ConfidenceLevel;      // Model confidence (0-1)
    datetime              LastCalibration;      // Last model calibration
    int                   SampleSize;           // Training sample size
};

//+------------------------------------------------------------------+
//| News Analysis Class                                              |
//+------------------------------------------------------------------+
class CNewsAnalysis {
private:
    // Core properties
    EAContext*            m_pContext;
    bool                  m_bInitialized;
    string                m_Symbol;
    string                m_BaseCurrency;
    string                m_QuoteCurrency;
    
    // Configuration
    SNewsFilter           m_Filter;
    SNewsSourceConfig     m_Sources[];
    SMarketImpactModel    m_ImpactModels[];
    
    // News data
    SNewsEvent            m_NewsEvents[];
    int                   m_EventCount;
    datetime              m_LastUpdate;
    datetime              m_NextUpdate;
    
    // Analysis Cache
    SNewsImpactAnalysis   m_CurrentAnalysis;
    datetime              m_LastAnalysisTime;
    bool                  m_AnalysisValid;
    
    // Currency Monitoring
    string                m_MonitoredCurrencies[];
    
    // Performance Tracking
    int                   m_SuccessfulUpdates;
    int                   m_FailedUpdates;
    double                m_PredictionAccuracy;
    datetime              m_LastAccuracyCheck;
    
    // Update Management
    bool                  m_UpdateInProgress;
    int                   m_UpdateThreadID;
    bool                  m_AutoUpdateEnabled;
    int                   m_UpdateIntervalMinutes;
    
    // Holidays & Special Events
    datetime              m_Holidays[];
    string                m_HolidayNames[];
    int                   m_HolidayCount;
    
public:
    //--- Constructor/Destructor ---
    CNewsAnalysis();
    ~CNewsAnalysis();
    
    //--- Core Methods ---
    bool                  Initialize(EAContext* context, const SNewsFilter& filter);
    void                  Deinitialize();
    bool                  IsInitialized() const { return m_bInitialized; }
    
    //--- Configuration ---
    bool                  SetFilter(const SNewsFilter& filter);
    SNewsFilter           GetFilter() const { return m_Filter; }
    bool                  AddNewsSource(const SNewsSourceConfig& source);
    bool                  RemoveNewsSource(ENUM_NEWS_SOURCE source);
    bool                  ConfigureImpactModel(const SMarketImpactModel& model);
    
    //--- Data Updates ---
    bool                  UpdateNewsData();
    bool                  UpdateFromSource(ENUM_NEWS_SOURCE source);
    bool                  LoadNewsFromFile(const string& file_path, ENUM_NEWS_SOURCE source);
    bool                  LoadNewsFromAPI(const string& url, const string& api_key);
    void                  SetAutoUpdate(bool enabled, int interval_minutes = 30);
    
    //--- Analysis Methods ---
    SNewsImpactAnalysis   AnalyzeCurrentSituation();
    bool                  IsInNewsWindow();
    bool                  HasUpcomingNews(int minutes_ahead = 240);
    ENUM_NEWS_IMPACT_LEVEL GetCurrentImpactLevel();
    ENUM_NEWS_IMPACT_LEVEL GetUpcomingImpactLevel(int minutes_ahead = 240);
    
    //--- Event Queries ---
    bool                  HasNewsEvent(int minutes_before, int minutes_after, 
                                      ENUM_NEWS_IMPACT_LEVEL min_impact = NEWS_IMPACT_MEDIUM);
    datetime              GetNextEventTime(ENUM_NEWS_IMPACT_LEVEL min_impact = NEWS_IMPACT_MEDIUM);
    string                GetNextEventName(ENUM_NEWS_IMPACT_LEVEL min_impact = NEWS_IMPACT_MEDIUM);
    SNewsEvent            GetNextEvent(ENUM_NEWS_IMPACT_LEVEL min_impact = NEWS_IMPACT_MEDIUM);
    
    //--- Impact Analysis ---
    double                GetVolatilityMultiplier();
    double                GetDirectionalBias();
    double                GetRiskScore();
    bool                  ShouldAvoidTrading();
    bool                  ShouldClosePositions();
    bool                  AllowNewTrades();
    bool                  AllowPositionScaling();
    
    //--- Event Management ---
    bool                  AddEvent(const SNewsEvent& event);
    bool                  UpdateEvent(int event_id, const SNewsEvent& event);
    bool                  RemoveEvent(int event_id);
    bool                  MarkEventProcessed(int event_id);
    void                  CleanupOldEvents();
    
    //--- Holiday Management ---
    bool                  LoadHolidays(const string& file_path);
    bool                  IsMarketHoliday(datetime time);
    bool                  IsMarketHoliday(); // Check current time
    string                GetHolidayName(datetime time);
    
    //--- Currency Management ---
    void                  SetMonitoredCurrencies(const string& symbol);
    bool                  IsCurrencyRelevant(const string& currency);
    bool                  IsEventRelevant(const SNewsEvent& event);
    
    //--- Reporting & Information ---
    string                GetUpcomingNewsInfo(int hours_ahead = 24);
    string                GetActiveEventsInfo();
    string                GetFilterStatus();
    string                GenerateNewsReport();
    string                GetPerformanceStats();
    
    //--- Calibration & ML ---
    bool                  CalibrateImpactModels();
    double                PredictEventImpact(const SNewsEvent& event);
    bool                  UpdatePredictionAccuracy();
    void                  TrainImpactModel(const string& currency, ENUM_NEWS_CATEGORY category);
    
    //--- Utility Methods ---
    void                  Reset();
    bool                  IsValidEvent(const SNewsEvent& event);
    int                   GetEventCount() const { return m_EventCount; }
    SNewsEvent            GetEvent(int index);
    
private:
    //--- Internal Updates ---
    void                  PerformAnalysis();
    void                  UpdateActiveEvents();
    void                  CalculateImpactMetrics();
    void                  UpdateTradingRecommendations();
    
    //--- Data Processing ---
    bool                  ParseCSVLine(const string& line, SNewsEvent& event, ENUM_NEWS_SOURCE source);
    bool                  ParseJSONEvent(const string& json, SNewsEvent& event);
    ENUM_NEWS_IMPACT_LEVEL ParseImpactLevel(const string& impact_str);
    ENUM_NEWS_CATEGORY    ParseCategory(const string& category_str);
    datetime              ParseEventTime(const string& date_str, const string& time_str);
    
    //--- Filtering Logic ---
    bool                  PassesFilter(const SNewsEvent& event);
    bool                  IsInTimeWindow(const SNewsEvent& event);
    bool                  IsRelevantCurrency(const string& currency);
    bool                  IsRelevantCategory(ENUM_NEWS_CATEGORY category);
    bool                  MeetsImpactThreshold(ENUM_NEWS_IMPACT_LEVEL impact);
    
    //--- Impact Modeling ---
    double                CalculateVolatilityImpact(const SNewsEvent& event);
    double                CalculateDirectionalImpact(const SNewsEvent& event);
    double                CalculateDecayFactor(const SNewsEvent& event, datetime current_time);
    SMarketImpactModel    GetImpactModel(const string& currency, ENUM_NEWS_CATEGORY category);
    
    //--- Risk Assessment ---
    double                CalculateRiskScore();
    bool                  AssessVoiceNewsRisk();
    bool                  AssessHolidayRisk();
    bool                  AssessVolatilityRisk();
    
    //--- Data Management ---
    void                  SortEventsByTime();
    void                  RemoveDuplicateEvents();
    void                  ValidateEventData();
    bool                  SaveEventsToCache();
    bool                  LoadEventsFromCache();
    
    //--- Error Handling ---
    void                  LogNewsEvent(const string& event, ENUM_LOG_LEVEL level = LOG_LEVEL_INFO);
    bool                  HandleUpdateError(ENUM_NEWS_SOURCE source, int error_code);
    void                  RecordUpdateStats(ENUM_NEWS_SOURCE source, bool success);
    
    //--- String Utilities ---
    string                ImpactToString(ENUM_NEWS_IMPACT_LEVEL impact);
    string                CategoryToString(ENUM_NEWS_CATEGORY category);
    string                SourceToString(ENUM_NEWS_SOURCE source);
    string                FormatEventTime(datetime time);
    string                FormatDuration(int minutes);
    
    //--- Time Utilities ---
    bool                  IsMarketOpen(datetime time);
    bool                  IsInTradingSession(datetime time);
    datetime              GetNextTradingSession();
    int                   GetMinutesUntilEvent(const SNewsEvent& event);
    
    //--- Memory Management ---
    void                  CleanupResources();
    bool                  OptimizeMemoryUsage();
    void                  ResizeArrays(int new_size);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CNewsAnalysis::CNewsAnalysis() {
    m_pContext = NULL;
    m_bInitialized = false;
    m_EventCount = 0;
    m_SuccessfulUpdates = 0;
    m_FailedUpdates = 0;
    m_PredictionAccuracy = 0.0;
    m_UpdateInProgress = false;
    m_AutoUpdateEnabled = false;
    m_UpdateIntervalMinutes = 30;
    m_AnalysisValid = false;
    m_HolidayCount = 0;
    
    // Initialize structures
    ZeroMemory(m_Filter);
    ZeroMemory(m_CurrentAnalysis);
    
    // Set default filter configuration
    m_Filter.FilterLevel = NEWS_FILTER_MEDIUM;
    m_Filter.MinImpactLevel = 2;
    m_Filter.MinutesBeforeEvent = 30;
    m_Filter.MinutesAfterEvent = 15;
    m_Filter.FilterBySymbol = true;
    m_Filter.FilterBySession = true;
    m_Filter.EnableHolidayFilter = true;
    m_Filter.EnableVoiceNews = false;
    m_Filter.MinVolatilityThreshold = 0.0;
    m_Filter.UseMLPredictions = false;
    
    // Initialize times
    m_LastUpdate = 0;
    m_NextUpdate = 0;
    m_LastAnalysisTime = 0;
    m_LastAccuracyCheck = 0;
    
    // Resize arrays
    ArrayResize(m_NewsEvents, 1000);
    ArrayResize(m_Sources, 10);
    ArrayResize(m_ImpactModels, 50);
    ArrayResize(m_MonitoredCurrencies, 10);
    ArrayResize(m_Holidays, 500);
    ArrayResize(m_HolidayNames, 500);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CNewsAnalysis::~CNewsAnalysis() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CNewsAnalysis::Initialize(EAContext* context, const SNewsFilter& filter) {
    if(context == NULL) {
        printf("Error: CNewsAnalysis received a null EAContext pointer.");
        return false;
    }
    m_pContext = context;

    if (m_bInitialized) {
        return true;
    }
    
    if (m_pContext == NULL) {
        Print("[NEWS_ANALYSIS] Context is NULL. Call Initialize(EAContext*, SNewsFilter) first.");
        return false;
    }
    
    // Set filter configuration
    m_Filter = filter;
    
    // Setup monitored currencies based on symbol
    SetMonitoredCurrencies(_Symbol);
    
    // Initialize default impact models
    // This would typically load from configuration or historical data
    
    // Load holidays data
    LoadHolidays("market_holidays.csv");
    
    // Setup auto-update if enabled
    if (m_AutoUpdateEnabled) {
        m_NextUpdate = TimeCurrent() + m_UpdateIntervalMinutes * 60;
    }
    
    // Initial news data update
    bool update_success = UpdateNewsData();
    
    m_bInitialized = true;
    
    if (m_pContext->pLogger != NULL) {
        string init_msg = StringFormat("News Analysis initialized: Filter=%d, Sources=%d, Update=%s",
                                      (int)m_Filter.FilterLevel, ArraySize(m_Sources),
                                      update_success ? "Success" : "Failed");
        m_pContext->pLogger->LogInfo(init_msg, __FUNCTION__);
    }
    
    LogNewsEvent("News Analysis initialized successfully", LOG_LEVEL_INFO);
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CNewsAnalysis::Deinitialize() {
    if (!m_bInitialized) {
        return;
    }
    
    // Save current events to cache if enabled
    SaveEventsToCache();
    
    // Log final statistics
    if (m_pContext != NULL && m_pContext->pLogger != NULL) {
        string final_msg = StringFormat("News Analysis shutting down: Events=%d, Updates=%d/%d, Accuracy=%.1f%%",
                                       m_EventCount, m_SuccessfulUpdates, 
                                       m_SuccessfulUpdates + m_FailedUpdates,
                                       m_PredictionAccuracy * 100);
        m_pContext->pLogger->LogInfo(final_msg, __FUNCTION__);
    }
    
    // Cleanup resources
    CleanupResources();
    
    LogNewsEvent("News Analysis deinitialized", LOG_LEVEL_INFO);
    
    m_bInitialized = false;
}

//+------------------------------------------------------------------+
//| Analyze Current Situation                                        |
//+------------------------------------------------------------------+
SNewsImpactAnalysis CNewsAnalysis::AnalyzeCurrentSituation() {
    if (!m_bInitialized) {
        ZeroMemory(m_CurrentAnalysis);
        return m_CurrentAnalysis;
    }
    
    datetime current_time = TimeCurrent();
    
    // Check if analysis is still valid (cache for 1 minute)
    if (m_AnalysisValid && current_time - m_LastAnalysisTime < 60) {
        return m_CurrentAnalysis;
    }
    
    // Update news data if needed
    if (m_AutoUpdateEnabled && current_time >= m_NextUpdate) {
        UpdateNewsData();
        m_NextUpdate = current_time + m_UpdateIntervalMinutes * 60;
    }
    
    // Perform fresh analysis
    PerformAnalysis();
    
    m_LastAnalysisTime = current_time;
    m_AnalysisValid = true;
    
    return m_CurrentAnalysis;
}

//+------------------------------------------------------------------+
//| Check if currently in news window                               |
//+------------------------------------------------------------------+
bool CNewsAnalysis::IsInNewsWindow() {
    if (m_Filter.FilterLevel == NEWS_FILTER_NONE) {
        return false;
    }
    
    SNewsImpactAnalysis analysis = AnalyzeCurrentSituation();
    return analysis.InNewsWindow;
}

//+------------------------------------------------------------------+
//| Internal Methods Implementation                                  |
//+------------------------------------------------------------------+

void CNewsAnalysis::PerformAnalysis() {
    // Reset analysis structure
    ZeroMemory(m_CurrentAnalysis);
    m_CurrentAnalysis.AnalysisTime = TimeCurrent();
    
    // Update active events
    UpdateActiveEvents();
    
    // Calculate impact metrics
    CalculateImpactMetrics();
    
    // Update trading recommendations
    UpdateTradingRecommendations();
    
    // Calculate overall risk score
    m_CurrentAnalysis.RiskScore = CalculateRiskScore();
}

void CNewsAnalysis::SetMonitoredCurrencies(const string& symbol) {
    ArrayResize(m_MonitoredCurrencies, 0);
    
    if (StringLen(symbol) >= 6) {
        m_BaseCurrency = StringSubstr(symbol, 0, 3);
        m_QuoteCurrency = StringSubstr(symbol, 3, 3);
        
        // Add both currencies to monitoring list
        int size = ArraySize(m_MonitoredCurrencies);
        ArrayResize(m_MonitoredCurrencies, size + 2);
        m_MonitoredCurrencies[size] = m_BaseCurrency;
        m_MonitoredCurrencies[size + 1] = m_QuoteCurrency;
        
        LogNewsEvent(StringFormat("Monitoring currencies: %s, %s", 
                                 m_BaseCurrency, m_QuoteCurrency), LOG_LEVEL_DEBUG);
    } else {
        // Handle special symbols like GOLD, SILVER, etc.
        if (symbol == "XAUUSD" || symbol == "GOLD") {
            ArrayResize(m_MonitoredCurrencies, 2);
            m_MonitoredCurrencies[0] = "XAU";
            m_MonitoredCurrencies[1] = "USD";
        } else if (symbol == "XAGUSD" || symbol == "SILVER") {
            ArrayResize(m_MonitoredCurrencies, 2);
            m_MonitoredCurrencies[0] = "XAG";
            m_MonitoredCurrencies[1] = "USD";
        }
    }
}

bool CNewsAnalysis::UpdateNewsData() {
    if (m_UpdateInProgress) {
        return false; // Update already in progress
    }
    
    m_UpdateInProgress = true;
    bool overall_success = false;
    
    LogNewsEvent("Starting news data update", LOG_LEVEL_DEBUG);
    
    // Update from all configured sources
    for (int i = 0; i < ArraySize(m_Sources); i++) {
        if (m_Sources[i].IsEnabled) {
            bool source_success = UpdateFromSource(m_Sources[i].Source);
            if (source_success) {
                overall_success = true;
                m_Sources[i].LastUpdate = TimeCurrent();
                m_Sources[i].SuccessfulUpdates++;
            } else {
                m_Sources[i].FailedUpdates++;
            }
            
            // Update reliability score
            int total_updates = m_Sources[i].SuccessfulUpdates + m_Sources[i].FailedUpdates;
            if (total_updates > 0) {
                m_Sources[i].ReliabilityScore = (double)m_Sources[i].SuccessfulUpdates / total_updates;
            }
        }
    }
    
    if (overall_success) {
        // Clean up old events
        CleanupOldEvents();
        
        // Sort events by time
        SortEventsByTime();
        
        // Remove duplicates
        RemoveDuplicateEvents();
        
        // Validate data
        ValidateEventData();
        
        m_LastUpdate = TimeCurrent();
        m_SuccessfulUpdates++;
        
        LogNewsEvent(StringFormat("News update completed: %d events loaded", m_EventCount), LOG_LEVEL_INFO);
    } else {
        m_FailedUpdates++;
        LogNewsEvent("News update failed from all sources", LOG_LEVEL_WARNING);
    }
    
    m_UpdateInProgress = false;
    return overall_success;
}

void CNewsAnalysis::LogNewsEvent(const string& event, ENUM_LOG_LEVEL level) {
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

#endif // NEWS_ANALYSIS_MQH