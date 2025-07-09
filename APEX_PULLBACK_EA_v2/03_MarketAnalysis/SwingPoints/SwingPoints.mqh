//+------------------------------------------------------------------+
//|                                                   SwingPoints.mqh |
//|                 SwingPoints.mqh - APEX Pullback EA v5 FINAL     |
//|      Description: Advanced Swing Point detection and analysis   |
//|                   system for identifying key market turning     |
//|                   points, support/resistance levels, and trend  |
//|                   structure analysis.                           |
//+------------------------------------------------------------------+

#ifndef SWING_POINTS_MQH_
#define SWING_POINTS_MQH_

#include "..\..\00_Core\CommonStructs.mqh"

namespace ApexPullback::v5 {

//+------------------------------------------------------------------+
//| Swing Point Types                                                |
//+------------------------------------------------------------------+
enum ENUM_SWING_TYPE {
    SWING_NONE,             // No swing point
    SWING_HIGH,             // Swing high
    SWING_LOW,              // Swing low
    SWING_DOUBLE_TOP,       // Double top pattern
    SWING_DOUBLE_BOTTOM,    // Double bottom pattern
    SWING_TRIPLE_TOP,       // Triple top pattern
    SWING_TRIPLE_BOTTOM,    // Triple bottom pattern
    SWING_HIGHER_HIGH,      // Higher high
    SWING_LOWER_HIGH,       // Lower high
    SWING_HIGHER_LOW,       // Higher low
    SWING_LOWER_LOW         // Lower low
};

enum ENUM_SWING_STRENGTH {
    STRENGTH_WEAK,          // Weak swing point
    STRENGTH_MODERATE,      // Moderate swing point
    STRENGTH_STRONG,        // Strong swing point
    STRENGTH_VERY_STRONG,   // Very strong swing point
    STRENGTH_EXTREME        // Extreme swing point
};

enum ENUM_TREND_DIRECTION {
    TREND_UNKNOWN,          // Unknown trend
    TREND_UP,               // Uptrend
    TREND_DOWN,             // Downtrend
    TREND_SIDEWAYS,         // Sideways trend
    TREND_REVERSAL_UP,      // Reversal to uptrend
    TREND_REVERSAL_DOWN     // Reversal to downtrend
};

//+------------------------------------------------------------------+
//| Swing Point Structure                                            |
//+------------------------------------------------------------------+
struct SSwingPoint {
    datetime              Time;             // Time of swing point
    double                Price;            // Price of swing point
    int                   BarIndex;         // Bar index
    ENUM_SWING_TYPE       Type;             // Swing point type
    ENUM_SWING_STRENGTH   Strength;         // Swing point strength
    double                Volume;           // Volume at swing point
    double                Significance;     // Significance score (0-100)
    bool                  IsConfirmed;      // Confirmation status
    bool                  IsBroken;         // Broken status
    datetime              BreakTime;        // Time when broken
    double                BreakPrice;       // Price when broken
    int                   TouchCount;       // Number of times tested
    double                LastTouchPrice;   // Last touch price
    datetime              LastTouchTime;    // Last touch time
    string                Notes;            // Additional notes
};

//+------------------------------------------------------------------+
//| Swing Analysis Result                                            |
//+------------------------------------------------------------------+
struct SSwingAnalysis {
    ENUM_TREND_DIRECTION  TrendDirection;   // Current trend direction
    double                TrendStrength;    // Trend strength (0-100)
    double                TrendAngle;       // Trend angle in degrees
    SSwingPoint           LastSwingHigh;    // Last swing high
    SSwingPoint           LastSwingLow;     // Last swing low
    SSwingPoint           PreviousSwingHigh; // Previous swing high
    SSwingPoint           PreviousSwingLow; // Previous swing low
    double                SwingRange;       // Current swing range
    double                AverageSwingSize; // Average swing size
    int                   SwingCount;       // Total swing count
    bool                  IsStructureBroken; // Structure broken flag
    datetime              LastStructureBreak; // Last structure break time
    string                StructureNotes;   // Structure analysis notes
};

//+------------------------------------------------------------------+
//| Support/Resistance Level                                         |
//+------------------------------------------------------------------+
struct SSRLevel {
    double                Price;            // Price level
    ENUM_SWING_TYPE       Type;             // Level type (high/low)
    ENUM_SWING_STRENGTH   Strength;         // Level strength
    int                   TouchCount;       // Number of touches
    datetime              FirstTouch;       // First touch time
    datetime              LastTouch;        // Last touch time
    bool                  IsActive;         // Active status
    bool                  IsBroken;         // Broken status
    double                BreakVolume;      // Volume when broken
    double                Significance;     // Significance score
    double                ZoneWidth;        // Support/resistance zone width
    string                Description;      // Level description
};

//+------------------------------------------------------------------+
//| Swing Configuration                                              |
//+------------------------------------------------------------------+
struct SSwingConfig {
    int                   LookbackPeriod;   // Lookback period for swing detection
    int                   MinSwingSize;     // Minimum swing size in points
    double                MinSwingPercent;  // Minimum swing size in percentage
    int                   ConfirmationBars; // Bars required for confirmation
    bool                  UseVolume;        // Use volume in analysis
    bool                  DetectPatterns;   // Detect chart patterns
    bool                  TrackSRLevels;    // Track support/resistance levels
    double                SRTolerance;      // S/R level tolerance
    int                   MaxSRLevels;      // Maximum S/R levels to track
    bool                  AutoCleanup;      // Auto cleanup old levels
    int                   MaxSwingHistory;  // Maximum swing history to keep
    bool                  RealTimeUpdate;   // Real-time updates
};

//+------------------------------------------------------------------+
//| Fractal Data                                                     |
//+------------------------------------------------------------------+
struct SFractal {
    datetime              Time;             // Fractal time
    double                Price;            // Fractal price
    int                   BarIndex;         // Bar index
    bool                  IsHigh;           // Is fractal high
    bool                  IsLow;            // Is fractal low
    double                Strength;         // Fractal strength
    bool                  IsConfirmed;      // Confirmation status
};

//+------------------------------------------------------------------+
//| CSwingPoints - Advanced Swing Point Analysis                    |
//+------------------------------------------------------------------+
class CSwingPoints {
private:
    EAContext*            m_pContext;       // Reference to EA context
    bool                  m_bInitialized;  // Initialization status
    
    // Configuration
    SSwingConfig          m_Config;         // Swing configuration
    string                m_Symbol;         // Current symbol
    ENUM_TIMEFRAMES       m_Timeframe;      // Analysis timeframe
    
    // Swing data
    SSwingPoint           m_SwingPoints[];  // Array of swing points
    int                   m_SwingCount;     // Number of swing points
    SSwingAnalysis        m_Analysis;       // Current swing analysis
    
    // Support/Resistance levels
    SSRLevel              m_SRLevels[];     // Support/resistance levels
    int                   m_SRCount;        // Number of S/R levels
    
    // Fractal data
    SFractal              m_Fractals[];     // Fractal points
    int                   m_FractalCount;   // Number of fractals
    
    // Market data
    double                m_HighData[];     // High prices
    double                m_LowData[];      // Low prices
    double                m_CloseData[];    // Close prices
    long                  m_VolumeData[];   // Volume data
    datetime              m_TimeData[];     // Time data
    int                   m_DataCount;      // Data count
    
    // Analysis state
    datetime              m_LastUpdate;     // Last update time
    datetime              m_LastSwingTime;  // Last swing detection time
    bool                  m_StructureChanged; // Structure change flag
    
    // Constants
    static const int      DEFAULT_LOOKBACK;
    static const int      DEFAULT_MIN_SWING_SIZE;
    static const double   DEFAULT_MIN_SWING_PERCENT;
    static const int      MAX_SWING_POINTS;
    static const int      MAX_SR_LEVELS;
    
public:
    //--- Constructor/Destructor ---
    CSwingPoints(EAContext* context);
    ~CSwingPoints();
    
    //--- Core Methods ---
    bool                  Initialize(const string& symbol, const ENUM_TIMEFRAMES timeframe, const SSwingConfig& config);
    void                  Deinitialize();
    bool                  IsInitialized() const { return m_bInitialized; }
    void                  Update();
    
    //--- Swing Detection ---
    bool                  DetectSwingPoints();
    bool                  DetectFractals();
    void                  ConfirmSwingPoints();
    void                  UpdateSwingAnalysis();
    
    //--- Swing Access ---
    SSwingAnalysis        GetSwingAnalysis() const { return m_Analysis; }
    SSwingPoint           GetLastSwingHigh() const { return m_Analysis.LastSwingHigh; }
    SSwingPoint           GetLastSwingLow() const { return m_Analysis.LastSwingLow; }
    SSwingPoint           GetSwingPoint(const int index);
    int                   GetSwingCount() const { return m_SwingCount; }
    
    //--- Trend Analysis ---
    ENUM_TREND_DIRECTION  GetTrendDirection() const { return m_Analysis.TrendDirection; }
    double                GetTrendStrength() const { return m_Analysis.TrendStrength; }
    double                GetTrendAngle() const { return m_Analysis.TrendAngle; }
    bool                  IsUptrend() const { return m_Analysis.TrendDirection == TREND_UP; }
    bool                  IsDowntrend() const { return m_Analysis.TrendDirection == TREND_DOWN; }
    bool                  IsSideways() const { return m_Analysis.TrendDirection == TREND_SIDEWAYS; }
    
    //--- Structure Analysis ---
    bool                  IsStructureBroken() const { return m_Analysis.IsStructureBroken; }
    bool                  IsHigherHigh(const double price);
    bool                  IsLowerHigh(const double price);
    bool                  IsHigherLow(const double price);
    bool                  IsLowerLow(const double price);
    bool                  IsStructureBreak(const double price);
    
    //--- Support/Resistance ---
    int                   GetSRLevels(SSRLevel& levels[]);
    SSRLevel              GetNearestSupport(const double price);
    SSRLevel              GetNearestResistance(const double price);
    bool                  IsSupportLevel(const double price, const double tolerance = 0.0);
    bool                  IsResistanceLevel(const double price, const double tolerance = 0.0);
    double                GetSupportStrength(const double price);
    double                GetResistanceStrength(const double price);
    
    //--- Pattern Detection ---
    bool                  IsDoubleTop(const double tolerance = 0.001);
    bool                  IsDoubleBottom(const double tolerance = 0.001);
    bool                  IsTripleTop(const double tolerance = 0.001);
    bool                  IsTripleBottom(const double tolerance = 0.001);
    bool                  IsHeadAndShoulders();
    bool                  IsInverseHeadAndShoulders();
    
    //--- Swing Measurements ---
    double                GetSwingRange() const { return m_Analysis.SwingRange; }
    double                GetAverageSwingSize() const { return m_Analysis.AverageSwingSize; }
    double                GetSwingRetracement(const SSwingPoint& swing1, const SSwingPoint& swing2);
    double                GetSwingExtension(const SSwingPoint& swing1, const SSwingPoint& swing2);
    
    //--- Fibonacci Levels ---
    bool                  GetFibonacciRetracements(const SSwingPoint& high, const SSwingPoint& low, double& levels[]);
    bool                  GetFibonacciExtensions(const SSwingPoint& swing1, const SSwingPoint& swing2, const SSwingPoint& swing3, double& levels[]);
    double                GetFibonacciLevel(const double start, const double end, const double ratio);
    
    //--- Trading Signals ---
    bool                  IsSwingBreakout(const double price);
    bool                  IsSwingReversal(const double price);
    bool                  IsPullbackComplete();
    bool                  IsRetestSignal(const double price);
    bool                  IsBreakoutConfirmation(const double price);
    
    //--- Validation ---
    bool                  ValidateSwingPoint(const SSwingPoint& swing);
    bool                  IsSignificantSwing(const SSwingPoint& swing);
    double                CalculateSwingStrength(const SSwingPoint& swing);
    
    //--- Configuration ---
    bool                  SetConfiguration(const SSwingConfig& config);
    SSwingConfig          GetConfiguration() const { return m_Config; }
    bool                  SetLookbackPeriod(const int period);
    bool                  SetMinSwingSize(const int size);
    
    //--- Information ---
    string                GetSwingSummary();
    string                GetTrendDescription();
    string                GetStructureDescription();
    string                GetSRLevelDescription();
    
private:
    //--- Data Loading ---
    bool                  LoadMarketData();
    void                  UpdateMarketData();
    
    //--- Swing Detection Implementation ---
    bool                  DetectSwingHigh(const int index);
    bool                  DetectSwingLow(const int index);
    bool                  ValidateSwingHigh(const int index);
    bool                  ValidateSwingLow(const int index);
    SSwingPoint           CreateSwingPoint(const int index, const ENUM_SWING_TYPE type);
    
    //--- Fractal Implementation ---
    bool                  IsFractalHigh(const int index, const int period = 5);
    bool                  IsFractalLow(const int index, const int period = 5);
    SFractal              CreateFractal(const int index, const bool is_high);
    
    //--- Trend Analysis Implementation ---
    ENUM_TREND_DIRECTION  AnalyzeTrendDirection();
    double                CalculateTrendStrength();
    double                CalculateTrendAngle();
    void                  UpdateTrendAnalysis();
    
    //--- Structure Analysis Implementation ---
    void                  AnalyzeMarketStructure();
    bool                  DetectStructureBreak();
    void                  ClassifySwingTypes();
    
    //--- Support/Resistance Implementation ---
    void                  UpdateSRLevels();
    void                  AddSRLevel(const SSwingPoint& swing);
    void                  UpdateSRLevel(SSRLevel& level, const double price, const datetime time);
    void                  CleanupSRLevels();
    bool                  IsPriceNearLevel(const double price, const double level, const double tolerance);
    
    //--- Pattern Detection Implementation ---
    bool                  FindDoublePattern(const ENUM_SWING_TYPE type, const double tolerance);
    bool                  FindTriplePattern(const ENUM_SWING_TYPE type, const double tolerance);
    bool                  FindHeadAndShouldersPattern(const bool inverse = false);
    
    //--- Calculation Methods ---
    double                CalculateSwingSize(const SSwingPoint& swing1, const SSwingPoint& swing2);
    double                CalculateSwingPercent(const SSwingPoint& swing1, const SSwingPoint& swing2);
    double                CalculateSignificance(const SSwingPoint& swing);
    ENUM_SWING_STRENGTH   DetermineSwingStrength(const double significance);
    
    //--- Utility Methods ---
    void                  SortSwingPoints();
    void                  SortSRLevels();
    void                  CleanupOldSwings();
    bool                  IsValidIndex(const int index);
    void                  LogSwingEvent(const string& event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO);
    
    //--- Array Management ---
    void                  ResizeSwingArray(const int new_size);
    void                  ResizeSRArray(const int new_size);
    void                  AddSwingPoint(const SSwingPoint& swing);
    void                  RemoveSwingPoint(const int index);
};

// Static constants definition
const int CSwingPoints::DEFAULT_LOOKBACK = 100;
const int CSwingPoints::DEFAULT_MIN_SWING_SIZE = 10;
const double CSwingPoints::DEFAULT_MIN_SWING_PERCENT = 0.5;
const int CSwingPoints::MAX_SWING_POINTS = 500;
const int CSwingPoints::MAX_SR_LEVELS = 50;

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSwingPoints::CSwingPoints(EAContext* context) {
    m_pContext = context;
    m_bInitialized = false;
    m_Symbol = "";
    m_Timeframe = PERIOD_CURRENT;
    m_SwingCount = 0;
    m_SRCount = 0;
    m_FractalCount = 0;
    m_DataCount = 0;
    m_LastUpdate = 0;
    m_LastSwingTime = 0;
    m_StructureChanged = false;
    
    // Initialize structures
    ZeroMemory(m_Config);
    ZeroMemory(m_Analysis);
    
    // Set default configuration
    m_Config.LookbackPeriod = DEFAULT_LOOKBACK;
    m_Config.MinSwingSize = DEFAULT_MIN_SWING_SIZE;
    m_Config.MinSwingPercent = DEFAULT_MIN_SWING_PERCENT;
    m_Config.ConfirmationBars = 3;
    m_Config.UseVolume = true;
    m_Config.DetectPatterns = true;
    m_Config.TrackSRLevels = true;
    m_Config.SRTolerance = 0.0001;
    m_Config.MaxSRLevels = MAX_SR_LEVELS;
    m_Config.AutoCleanup = true;
    m_Config.MaxSwingHistory = MAX_SWING_POINTS;
    m_Config.RealTimeUpdate = true;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSwingPoints::~CSwingPoints() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CSwingPoints::Initialize(const string& symbol, const ENUM_TIMEFRAMES timeframe, const SSwingConfig& config) {
    if (m_bInitialized) {
        return true;
    }
    
    if (m_pContext == NULL) {
        Print("[SWING_POINTS] Context is NULL");
        return false;
    }
    
    m_Symbol = symbol;
    m_Timeframe = timeframe;
    m_Config = config;
    
    // Validate configuration
    if (m_Config.LookbackPeriod < 10) {
        m_Config.LookbackPeriod = DEFAULT_LOOKBACK;
    }
    
    if (m_Config.MinSwingSize < 1) {
        m_Config.MinSwingSize = DEFAULT_MIN_SWING_SIZE;
    }
    
    if (m_Config.MaxSwingHistory > MAX_SWING_POINTS) {
        m_Config.MaxSwingHistory = MAX_SWING_POINTS;
    }
    
    // Initialize arrays
    ArrayResize(m_SwingPoints, m_Config.MaxSwingHistory);
    ArrayResize(m_SRLevels, m_Config.MaxSRLevels);
    ArrayResize(m_Fractals, m_Config.LookbackPeriod);
    
    // Load initial market data
    if (!LoadMarketData()) {
        LogSwingEvent("Failed to load market data", LOG_LEVEL_ERROR);
        return false;
    }
    
    // Perform initial swing detection
    DetectSwingPoints();
    DetectFractals();
    UpdateSwingAnalysis();
    
    if (m_Config.TrackSRLevels) {
        UpdateSRLevels();
    }
    
    m_bInitialized = true;
    
    if (m_pContext.pLogger != NULL) {
        m_pContext.pLogger.LogInfo("SwingPoints initialized for: " + symbol, __FUNCTION__);
        m_pContext.pLogger.LogInfo(GetSwingSummary(), __FUNCTION__);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CSwingPoints::Deinitialize() {
    if (!m_bInitialized) {
        return;
    }
    
    if (m_pContext != NULL && m_pContext.pLogger != NULL) {
        m_pContext.pLogger.LogInfo(GetStructureDescription(), __FUNCTION__);
        m_pContext.pLogger.LogInfo("SwingPoints shutting down", __FUNCTION__);
    }
    
    m_bInitialized = false;
}

//+------------------------------------------------------------------+
//| Update                                                           |
//+------------------------------------------------------------------+
void CSwingPoints::Update() {
    if (!m_bInitialized) {
        return;
    }
    
    datetime current_time = TimeCurrent();
    
    // Real-time updates
    if (m_Config.RealTimeUpdate) {
        UpdateMarketData();
        
        // Check for new swing points
        if (DetectSwingPoints()) {
            ConfirmSwingPoints();
            UpdateSwingAnalysis();
            
            if (m_Config.TrackSRLevels) {
                UpdateSRLevels();
            }
            
            m_StructureChanged = true;
        }
    }
    
    // Periodic full analysis
    if (current_time - m_LastUpdate >= 3600) { // Every hour
        DetectFractals();
        AnalyzeMarketStructure();
        
        if (m_Config.AutoCleanup) {
            CleanupOldSwings();
            CleanupSRLevels();
        }
        
        m_LastUpdate = current_time;
    }
}

//+------------------------------------------------------------------+
//| Detect Swing Points                                              |
//+------------------------------------------------------------------+
bool CSwingPoints::DetectSwingPoints() {
    if (m_DataCount < m_Config.LookbackPeriod) {
        return false;
    }
    
    bool new_swings_found = false;
    
    // Scan for swing highs and lows
    for (int i = m_Config.ConfirmationBars; i < m_DataCount - m_Config.ConfirmationBars; i++) {
        // Check for swing high
        if (DetectSwingHigh(i) && ValidateSwingHigh(i)) {
            SSwingPoint swing = CreateSwingPoint(i, SWING_HIGH);
            if (ValidateSwingPoint(swing)) {
                AddSwingPoint(swing);
                new_swings_found = true;
                LogSwingEvent(StringFormat("New swing high detected at %.5f", swing.Price));
            }
        }
        
        // Check for swing low
        if (DetectSwingLow(i) && ValidateSwingLow(i)) {
            SSwingPoint swing = CreateSwingPoint(i, SWING_LOW);
            if (ValidateSwingPoint(swing)) {
                AddSwingPoint(swing);
                new_swings_found = true;
                LogSwingEvent(StringFormat("New swing low detected at %.5f", swing.Price));
            }
        }
    }
    
    if (new_swings_found) {
        SortSwingPoints();
        ClassifySwingTypes();
    }
    
    return new_swings_found;
}

//+------------------------------------------------------------------+
//| Get Last Swing High                                              |
//+------------------------------------------------------------------+
SSwingPoint CSwingPoints::GetLastSwingHigh() const {
    return m_Analysis.LastSwingHigh;
}

//+------------------------------------------------------------------+
//| Get Last Swing Low                                               |
//+------------------------------------------------------------------+
SSwingPoint CSwingPoints::GetLastSwingLow() const {
    return m_Analysis.LastSwingLow;
}

//+------------------------------------------------------------------+
//| Is Higher High                                                   |
//+------------------------------------------------------------------+
bool CSwingPoints::IsHigherHigh(const double price) {
    if (m_Analysis.LastSwingHigh.Price <= 0) {
        return false;
    }
    
    return (price > m_Analysis.LastSwingHigh.Price);
}

//+------------------------------------------------------------------+
//| Is Lower Low                                                     |
//+------------------------------------------------------------------+
bool CSwingPoints::IsLowerLow(const double price) {
    if (m_Analysis.LastSwingLow.Price <= 0) {
        return false;
    }
    
    return (price < m_Analysis.LastSwingLow.Price);
}

//+------------------------------------------------------------------+
//| Is Structure Break                                               |
//+------------------------------------------------------------------+
bool CSwingPoints::IsStructureBreak(const double price) {
    // Check if price breaks significant swing levels
    if (m_Analysis.TrendDirection == TREND_UP) {
        return IsLowerLow(price);
    } else if (m_Analysis.TrendDirection == TREND_DOWN) {
        return IsHigherHigh(price);
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Get Nearest Support                                              |
//+------------------------------------------------------------------+
SSRLevel CSwingPoints::GetNearestSupport(const double price) {
    SSRLevel nearest_support;
    ZeroMemory(nearest_support);
    
    double min_distance = DBL_MAX;
    
    for (int i = 0; i < m_SRCount; i++) {
        if (m_SRLevels[i].Type == SWING_LOW && 
            m_SRLevels[i].IsActive && 
            m_SRLevels[i].Price < price) {
            
            double distance = price - m_SRLevels[i].Price;
            if (distance < min_distance) {
                min_distance = distance;
                nearest_support = m_SRLevels[i];
            }
        }
    }
    
    return nearest_support;
}

//+------------------------------------------------------------------+
//| Get Nearest Resistance                                           |
//+------------------------------------------------------------------+
SSRLevel CSwingPoints::GetNearestResistance(const double price) {
    SSRLevel nearest_resistance;
    ZeroMemory(nearest_resistance);
    
    double min_distance = DBL_MAX;
    
    for (int i = 0; i < m_SRCount; i++) {
        if (m_SRLevels[i].Type == SWING_HIGH && 
            m_SRLevels[i].IsActive && 
            m_SRLevels[i].Price > price) {
            
            double distance = m_SRLevels[i].Price - price;
            if (distance < min_distance) {
                min_distance = distance;
                nearest_resistance = m_SRLevels[i];
            }
        }
    }
    
    return nearest_resistance;
}

//+------------------------------------------------------------------+
//| Is Double Top                                                    |
//+------------------------------------------------------------------+
bool CSwingPoints::IsDoubleTop(const double tolerance = 0.001) {
    return FindDoublePattern(SWING_HIGH, tolerance);
}

//+------------------------------------------------------------------+
//| Is Double Bottom                                                 |
//+------------------------------------------------------------------+
bool CSwingPoints::IsDoubleBottom(const double tolerance = 0.001) {
    return FindDoublePattern(SWING_LOW, tolerance);
}

//+------------------------------------------------------------------+
//| Get Swing Summary                                                |
//+------------------------------------------------------------------+
string CSwingPoints::GetSwingSummary() {
    string summary = "=== SWING POINT ANALYSIS ===\n";
    summary += StringFormat("Symbol: %s\n", m_Symbol);
    summary += StringFormat("Timeframe: %s\n", EnumToString(m_Timeframe));
    summary += StringFormat("Trend Direction: %s\n", EnumToString(m_Analysis.TrendDirection));
    summary += StringFormat("Trend Strength: %.1f\n", m_Analysis.TrendStrength);
    summary += StringFormat("Swing Count: %d\n", m_SwingCount);
    summary += StringFormat("Last Swing High: %.5f\n", m_Analysis.LastSwingHigh.Price);
    summary += StringFormat("Last Swing Low: %.5f\n", m_Analysis.LastSwingLow.Price);
    summary += StringFormat("Current Range: %.1f points\n", m_Analysis.SwingRange);
    summary += StringFormat("Average Swing: %.1f points\n", m_Analysis.AverageSwingSize);
    summary += StringFormat("S/R Levels: %d\n", m_SRCount);
    summary += StringFormat("Structure Broken: %s\n", m_Analysis.IsStructureBroken ? "Yes" : "No");
    
    return summary;
}

//+------------------------------------------------------------------+
//| Internal Methods                                                 |
//+------------------------------------------------------------------+
bool CSwingPoints::LoadMarketData() {
    if (m_Symbol == "") {
        return false;
    }
    
    // Load OHLC and volume data
    double high_prices[], low_prices[], close_prices[];
    long volumes[];
    datetime times[];
    
    int copied_high = CopyHigh(m_Symbol, m_Timeframe, 0, m_Config.LookbackPeriod, high_prices);
    int copied_low = CopyLow(m_Symbol, m_Timeframe, 0, m_Config.LookbackPeriod, low_prices);
    int copied_close = CopyClose(m_Symbol, m_Timeframe, 0, m_Config.LookbackPeriod, close_prices);
    int copied_volumes = CopyTickVolume(m_Symbol, m_Timeframe, 0, m_Config.LookbackPeriod, volumes);
    int copied_times = CopyTime(m_Symbol, m_Timeframe, 0, m_Config.LookbackPeriod, times);
    
    if (copied_high < 10 || copied_low < 10 || copied_close < 10) {
        LogSwingEvent("Insufficient market data loaded", LOG_LEVEL_ERROR);
        return false;
    }
    
    // Store data
    m_DataCount = copied_high;
    ArrayResize(m_HighData, m_DataCount);
    ArrayResize(m_LowData, m_DataCount);
    ArrayResize(m_CloseData, m_DataCount);
    ArrayResize(m_VolumeData, m_DataCount);
    ArrayResize(m_TimeData, m_DataCount);
    
    ArrayCopy(m_HighData, high_prices);
    ArrayCopy(m_LowData, low_prices);
    ArrayCopy(m_CloseData, close_prices);
    ArrayCopy(m_TimeData, times);
    
    if (copied_volumes > 0) {
        for (int i = 0; i < m_DataCount; i++) {
            m_VolumeData[i] = (i < copied_volumes) ? volumes[i] : 1;
        }
    } else {
        ArrayInitialize(m_VolumeData, 1);
    }
    
    return true;
}

bool CSwingPoints::DetectSwingHigh(const int index) {
    if (!IsValidIndex(index)) {
        return false;
    }
    
    double current_high = m_HighData[index];
    
    // Check if current high is higher than surrounding highs
    for (int i = 1; i <= m_Config.ConfirmationBars; i++) {
        if (index - i < 0 || index + i >= m_DataCount) {
            return false;
        }
        
        if (current_high <= m_HighData[index - i] || 
            current_high <= m_HighData[index + i]) {
            return false;
        }
    }
    
    return true;
}

bool CSwingPoints::DetectSwingLow(const int index) {
    if (!IsValidIndex(index)) {
        return false;
    }
    
    double current_low = m_LowData[index];
    
    // Check if current low is lower than surrounding lows
    for (int i = 1; i <= m_Config.ConfirmationBars; i++) {
        if (index - i < 0 || index + i >= m_DataCount) {
            return false;
        }
        
        if (current_low >= m_LowData[index - i] || 
            current_low >= m_LowData[index + i]) {
            return false;
        }
    }
    
    return true;
}

SSwingPoint CSwingPoints::CreateSwingPoint(const int index, const ENUM_SWING_TYPE type) {
    SSwingPoint swing;
    ZeroMemory(swing);
    
    if (!IsValidIndex(index)) {
        return swing;
    }
    
    swing.Time = m_TimeData[index];
    swing.BarIndex = index;
    swing.Type = type;
    swing.IsConfirmed = false;
    swing.IsBroken = false;
    swing.TouchCount = 1;
    swing.LastTouchTime = swing.Time;
    
    if (type == SWING_HIGH) {
        swing.Price = m_HighData[index];
        swing.LastTouchPrice = swing.Price;
    } else if (type == SWING_LOW) {
        swing.Price = m_LowData[index];
        swing.LastTouchPrice = swing.Price;
    }
    
    if (m_Config.UseVolume && index < ArraySize(m_VolumeData)) {
        swing.Volume = (double)m_VolumeData[index];
    }
    
    // Calculate significance
    swing.Significance = CalculateSignificance(swing);
    swing.Strength = DetermineSwingStrength(swing.Significance);
    
    return swing;
}

bool CSwingPoints::ValidateSwingPoint(const SSwingPoint& swing) {
    if (swing.Price <= 0 || swing.Time <= 0) {
        return false;
    }
    
    // Check minimum swing size
    if (m_SwingCount > 0) {
        SSwingPoint last_swing = m_SwingPoints[m_SwingCount - 1];
        double swing_size = MathAbs(swing.Price - last_swing.Price);
        
        // Check minimum points
        double min_points = m_Config.MinSwingSize * SymbolInfoDouble(m_Symbol, SYMBOL_POINT);
        if (swing_size < min_points) {
            return false;
        }
        
        // Check minimum percentage
        if (last_swing.Price > 0) {
            double swing_percent = swing_size / last_swing.Price * 100.0;
            if (swing_percent < m_Config.MinSwingPercent) {
                return false;
            }
        }
    }
    
    return true;
}

double CSwingPoints::CalculateSignificance(const SSwingPoint& swing) {
    double significance = 50.0; // Base significance
    
    // Volume factor
    if (m_Config.UseVolume && swing.Volume > 0) {
        // Calculate average volume
        double avg_volume = 0.0;
        int volume_count = 0;
        
        for (int i = MathMax(0, swing.BarIndex - 20); 
             i < MathMin(m_DataCount, swing.BarIndex + 20); i++) {
            if (i < ArraySize(m_VolumeData)) {
                avg_volume += m_VolumeData[i];
                volume_count++;
            }
        }
        
        if (volume_count > 0) {
            avg_volume /= volume_count;
            if (avg_volume > 0) {
                double volume_ratio = swing.Volume / avg_volume;
                significance += (volume_ratio - 1.0) * 20.0; // Max 20 points from volume
            }
        }
    }
    
    // Time factor (older swings are more significant)
    datetime current_time = TimeCurrent();
    int time_diff_hours = (int)((current_time - swing.Time) / 3600);
    if (time_diff_hours > 24) {
        significance += MathMin(time_diff_hours / 24.0 * 5.0, 20.0); // Max 20 points from age
    }
    
    // Touch count factor
    significance += (swing.TouchCount - 1) * 5.0; // 5 points per additional touch
    
    return MathMax(0.0, MathMin(100.0, significance));
}

ENUM_SWING_STRENGTH CSwingPoints::DetermineSwingStrength(const double significance) {
    if (significance >= 90.0) {
        return STRENGTH_EXTREME;
    } else if (significance >= 75.0) {
        return STRENGTH_VERY_STRONG;
    } else if (significance >= 60.0) {
        return STRENGTH_STRONG;
    } else if (significance >= 40.0) {
        return STRENGTH_MODERATE;
    } else {
        return STRENGTH_WEAK;
    }
}

void CSwingPoints::UpdateSwingAnalysis() {
    if (m_SwingCount < 2) {
        return;
    }
    
    // Find last swing high and low
    for (int i = m_SwingCount - 1; i >= 0; i--) {
        if (m_SwingPoints[i].Type == SWING_HIGH && m_Analysis.LastSwingHigh.Time == 0) {
            m_Analysis.LastSwingHigh = m_SwingPoints[i];
        }
        if (m_SwingPoints[i].Type == SWING_LOW && m_Analysis.LastSwingLow.Time == 0) {
            m_Analysis.LastSwingLow = m_SwingPoints[i];
        }
        
        if (m_Analysis.LastSwingHigh.Time > 0 && m_Analysis.LastSwingLow.Time > 0) {
            break;
        }
    }
    
    // Calculate swing range
    if (m_Analysis.LastSwingHigh.Price > 0 && m_Analysis.LastSwingLow.Price > 0) {
        m_Analysis.SwingRange = MathAbs(m_Analysis.LastSwingHigh.Price - m_Analysis.LastSwingLow.Price);
    }
    
    // Calculate average swing size
    double total_swing_size = 0.0;
    int swing_count = 0;
    
    for (int i = 1; i < m_SwingCount; i++) {
        double swing_size = MathAbs(m_SwingPoints[i].Price - m_SwingPoints[i-1].Price);
        total_swing_size += swing_size;
        swing_count++;
    }
    
    if (swing_count > 0) {
        m_Analysis.AverageSwingSize = total_swing_size / swing_count;
    }
    
    // Update trend analysis
    UpdateTrendAnalysis();
    
    // Update swing count
    m_Analysis.SwingCount = m_SwingCount;
}

void CSwingPoints::UpdateTrendAnalysis() {
    m_Analysis.TrendDirection = AnalyzeTrendDirection();
    m_Analysis.TrendStrength = CalculateTrendStrength();
    m_Analysis.TrendAngle = CalculateTrendAngle();
}

ENUM_TREND_DIRECTION CSwingPoints::AnalyzeTrendDirection() {
    if (m_SwingCount < 4) {
        return TREND_UNKNOWN;
    }
    
    // Analyze last few swings to determine trend
    int highs_count = 0, lows_count = 0;
    int higher_highs = 0, lower_highs = 0;
    int higher_lows = 0, lower_lows = 0;
    
    // Look at last 6 swings
    int start_index = MathMax(0, m_SwingCount - 6);
    
    for (int i = start_index; i < m_SwingCount - 1; i++) {
        if (m_SwingPoints[i].Type == SWING_HIGH) {
            highs_count++;
            if (i > 0 && m_SwingPoints[i].Price > m_SwingPoints[i-1].Price) {
                higher_highs++;
            } else if (i > 0) {
                lower_highs++;
            }
        } else if (m_SwingPoints[i].Type == SWING_LOW) {
            lows_count++;
            if (i > 0 && m_SwingPoints[i].Price > m_SwingPoints[i-1].Price) {
                higher_lows++;
            } else if (i > 0) {
                lower_lows++;
            }
        }
    }
    
    // Determine trend based on swing pattern
    if (higher_highs > lower_highs && higher_lows > lower_lows) {
        return TREND_UP;
    } else if (lower_highs > higher_highs && lower_lows > higher_lows) {
        return TREND_DOWN;
    } else {
        return TREND_SIDEWAYS;
    }
}

bool CSwingPoints::FindDoublePattern(const ENUM_SWING_TYPE type, const double tolerance) {
    if (m_SwingCount < 3) {
        return false;
    }
    
    // Look for two similar swing levels
    for (int i = m_SwingCount - 1; i >= 2; i--) {
        if (m_SwingPoints[i].Type == type) {
            for (int j = i - 2; j >= 0; j--) {
                if (m_SwingPoints[j].Type == type) {
                    double price_diff = MathAbs(m_SwingPoints[i].Price - m_SwingPoints[j].Price);
                    double avg_price = (m_SwingPoints[i].Price + m_SwingPoints[j].Price) / 2.0;
                    
                    if (price_diff / avg_price <= tolerance) {
                        return true;
                    }
                }
            }
        }
    }
    
    return false;
}

void CSwingPoints::AddSwingPoint(const SSwingPoint& swing) {
    if (m_SwingCount >= ArraySize(m_SwingPoints)) {
        // Remove oldest swing if array is full
        for (int i = 0; i < m_SwingCount - 1; i++) {
            m_SwingPoints[i] = m_SwingPoints[i + 1];
        }
        m_SwingCount--;
    }
    
    m_SwingPoints[m_SwingCount] = swing;
    m_SwingCount++;
}

bool CSwingPoints::IsValidIndex(const int index) {
    return (index >= 0 && index < m_DataCount);
}

void CSwingPoints::LogSwingEvent(const string& event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO) {
    if (m_pContext != NULL && m_pContext.pLogger != NULL) {
        switch(level) {
            case LOG_LEVEL_ERROR:
                m_pContext.pLogger.LogError(event, __FUNCTION__);
                break;
            case LOG_LEVEL_WARNING:
                m_pContext.pLogger.LogWarning(event, __FUNCTION__);
                break;
            default:
                m_pContext.pLogger.LogInfo(event, __FUNCTION__);
        }
    }
}

} // namespace ApexPullback::v5

#endif // SWING_POINTS_MQH_