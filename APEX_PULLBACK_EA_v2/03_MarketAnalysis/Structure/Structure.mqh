//+------------------------------------------------------------------+
//|                                                    Structure.mqh |
//|                  Structure.mqh - APEX Pullback EA v5 FINAL      |
//|      Description: Advanced Market Structure Analysis System     |
//|                   for identifying trend direction, support/     |
//|                   resistance levels, and structural breaks.     |
//+------------------------------------------------------------------+

#ifndef STRUCTURE_MQH_
#define STRUCTURE_MQH_

#include "..\..\00_Core\CommonStructs.mqh"



//+------------------------------------------------------------------+
//| Structure Types                                                  |
//+------------------------------------------------------------------+
enum ENUM_STRUCTURE_TYPE {
    STRUCTURE_NONE,                  // No structure
    STRUCTURE_SUPPORT,               // Support level
    STRUCTURE_RESISTANCE,            // Resistance level
    STRUCTURE_TREND_LINE,            // Trend line
    STRUCTURE_CHANNEL_TOP,           // Channel top
    STRUCTURE_CHANNEL_BOTTOM,        // Channel bottom
    STRUCTURE_PIVOT_HIGH,            // Pivot high
    STRUCTURE_PIVOT_LOW,             // Pivot low
    STRUCTURE_SWING_HIGH,            // Swing high
    STRUCTURE_SWING_LOW,             // Swing low
    STRUCTURE_HIGHER_HIGH,           // Higher high
    STRUCTURE_HIGHER_LOW,            // Higher low
    STRUCTURE_LOWER_HIGH,            // Lower high
    STRUCTURE_LOWER_LOW,             // Lower low
    STRUCTURE_EQUAL_HIGH,            // Equal high
    STRUCTURE_EQUAL_LOW,             // Equal low
    STRUCTURE_BREAK_HIGH,            // Break of high
    STRUCTURE_BREAK_LOW,             // Break of low
    STRUCTURE_LIQUIDITY_POOL,        // Liquidity pool
    STRUCTURE_ORDER_BLOCK,           // Order block
    STRUCTURE_FAIR_VALUE_GAP,        // Fair value gap
    STRUCTURE_IMBALANCE,             // Price imbalance
    STRUCTURE_INSTITUTIONAL_LEVEL    // Institutional level
};

enum ENUM_TREND_DIRECTION {
    TREND_UNDEFINED,                 // Undefined trend
    TREND_BULLISH,                   // Bullish trend
    TREND_BEARISH,                   // Bearish trend
    TREND_SIDEWAYS,                  // Sideways trend
    TREND_REVERSAL_BULL,             // Bullish reversal
    TREND_REVERSAL_BEAR,             // Bearish reversal
    TREND_CONSOLIDATION,             // Consolidation
    TREND_BREAKOUT_BULL,             // Bullish breakout
    TREND_BREAKOUT_BEAR              // Bearish breakout
};

enum ENUM_STRUCTURE_STRENGTH {
    STRENGTH_WEAK,                   // Weak structure (1-2 touches)
    STRENGTH_MODERATE,               // Moderate structure (3-4 touches)
    STRENGTH_STRONG,                 // Strong structure (5-7 touches)
    STRENGTH_VERY_STRONG,            // Very strong structure (8+ touches)
    STRENGTH_INSTITUTIONAL           // Institutional level
};

enum ENUM_STRUCTURE_STATUS {
    STATUS_ACTIVE,                   // Active structure
    STATUS_BROKEN,                   // Broken structure
    STATUS_TESTED,                   // Recently tested
    STATUS_UNTESTED,                 // Untested structure
    STATUS_WEAKENING,                // Weakening structure
    STATUS_STRENGTHENING,            // Strengthening structure
    STATUS_EXPIRED                   // Expired structure
};

enum ENUM_BREAK_TYPE {
    BREAK_NONE,                      // No break
    BREAK_CLEAN,                     // Clean break
    BREAK_FALSE,                     // False break
    BREAK_RETEST,                    // Break and retest
    BREAK_CONTINUATION,              // Continuation break
    BREAK_REVERSAL                   // Reversal break
};

//+------------------------------------------------------------------+
//| Structure Level                                                  |
//+------------------------------------------------------------------+
struct SStructureLevel {
    ENUM_STRUCTURE_TYPE   Type;              // Structure type
    ENUM_STRUCTURE_STRENGTH Strength;       // Structure strength
    ENUM_STRUCTURE_STATUS Status;            // Structure status
    ENUM_BREAK_TYPE       BreakType;         // Break type
    
    double                Price;             // Structure price level
    datetime              FirstTouch;        // First touch time
    datetime              LastTouch;         // Last touch time
    datetime              BreakTime;         // Break time
    datetime              RetestTime;        // Retest time
    
    int                   TouchCount;        // Number of touches
    int                   BarsSinceTouch;    // Bars since last touch
    int                   BarsSinceBreak;    // Bars since break
    
    double                MaxDeviation;      // Maximum price deviation
    double                AverageDeviation;  // Average price deviation
    double                Significance;      // Significance score (0-100)
    double                Reliability;       // Reliability score (0-100)
    
    bool                  IsActive;          // Active status
    bool                  IsBroken;          // Broken status
    bool                  IsRetested;        // Retested status
    bool                  IsInstitutional;   // Institutional level
    
    string                Description;       // Level description
    string                Notes;             // Additional notes
    
    // Touch history (last 10 touches)
    datetime              TouchTimes[10];    // Touch times
    double                TouchPrices[10];   // Touch prices
    int                   TouchHistoryCount; // Touch history count
};

//+------------------------------------------------------------------+
//| Market Structure                                                 |
//+------------------------------------------------------------------+
struct SMarketStructure {
    ENUM_TREND_DIRECTION  PrimaryTrend;      // Primary trend direction
    ENUM_TREND_DIRECTION  SecondaryTrend;    // Secondary trend direction
    ENUM_TREND_DIRECTION  TertiaryTrend;     // Tertiary trend direction
    
    double                TrendStrength;     // Trend strength (0-100)
    double                TrendAngle;        // Trend angle in degrees
    double                TrendVelocity;     // Trend velocity
    int                   TrendAge;          // Trend age in bars
    
    // Key levels
    double                CurrentHigh;       // Current swing high
    double                CurrentLow;        // Current swing low
    double                PreviousHigh;      // Previous swing high
    double                PreviousLow;       // Previous swing low
    
    datetime              HighTime;          // High time
    datetime              LowTime;           // Low time
    datetime              PrevHighTime;      // Previous high time
    datetime              PrevLowTime;       // Previous low time
    
    // Structure breaks
    bool                  HighBroken;        // High broken
    bool                  LowBroken;         // Low broken
    datetime              HighBreakTime;     // High break time
    datetime              LowBreakTime;      // Low break time
    
    // Market character
    bool                  IsImpulsive;       // Impulsive move
    bool                  IsCorrective;      // Corrective move
    bool                  IsConsolidating;   // Consolidating
    bool                  IsBreakingOut;     // Breaking out
    
    double                VolatilityIndex;   // Volatility index
    double                MomentumIndex;     // Momentum index
    double                StructureScore;    // Overall structure score
    
    string                Summary;           // Structure summary
};

//+------------------------------------------------------------------+
//| Swing Point                                                      |
//+------------------------------------------------------------------+
struct SSwingPoint {
    ENUM_STRUCTURE_TYPE   Type;              // Swing type (HIGH/LOW)
    double                Price;             // Swing price
    datetime              Time;              // Swing time
    int                   BarIndex;          // Bar index
    
    double                Strength;          // Swing strength
    double                Significance;      // Swing significance
    int                   LookbackLeft;      // Left lookback period
    int                   LookbackRight;     // Right lookback period
    
    bool                  IsConfirmed;       // Confirmed swing
    bool                  IsBroken;          // Broken swing
    bool                  IsRetested;        // Retested swing
    
    datetime              BreakTime;         // Break time
    datetime              RetestTime;        // Retest time
    double                BreakPrice;        // Break price
    double                RetestPrice;       // Retest price
    
    string                Label;             // Swing label
};

//+------------------------------------------------------------------+
//| Structure Configuration                                           |
//+------------------------------------------------------------------+
struct SStructureConfig {
    // Analysis settings
    int                   LookbackPeriod;    // Lookback period
    int                   SwingLookback;     // Swing detection lookback
    double                MinSwingSize;      // Minimum swing size (points)
    double                LevelTolerance;    // Level tolerance (points)
    
    // Structure detection
    bool                  DetectSupport;     // Detect support levels
    bool                  DetectResistance;  // Detect resistance levels
    bool                  DetectTrendLines;  // Detect trend lines
    bool                  DetectChannels;    // Detect channels
    bool                  DetectSwings;      // Detect swing points
    bool                  DetectBreaks;      // Detect structure breaks
    
    // Advanced features
    bool                  UseOrderBlocks;    // Use order blocks
    bool                  UseFairValueGaps;  // Use fair value gaps
    bool                  UseLiquidityPools; // Use liquidity pools
    bool                  UseInstitutional;  // Use institutional levels
    
    // Filtering
    int                   MinTouchCount;     // Minimum touch count
    double                MinSignificance;   // Minimum significance
    double                MinReliability;    // Minimum reliability
    bool                  UseTimeFilter;     // Use time filters
    bool                  UseVolumeFilter;   // Use volume filters
    
    // Display settings
    bool                  ShowLevels;        // Show structure levels
    bool                  ShowSwings;        // Show swing points
    bool                  ShowBreaks;        // Show structure breaks
    bool                  ShowLabels;        // Show labels
    int                   MaxLevels;         // Maximum levels to track
    
    // Update settings
    bool                  RealTimeUpdate;    // Real-time updates
    bool                  HistoricalScan;    // Historical scan
    int                   UpdateFrequency;   // Update frequency (seconds)
    bool                  AutoCleanup;       // Auto cleanup old levels
};

//+------------------------------------------------------------------+
//| Structure Statistics                                             |
//+------------------------------------------------------------------+
struct SStructureStats {
    int                   TotalLevels;       // Total structure levels
    int                   ActiveLevels;      // Active levels
    int                   BrokenLevels;      // Broken levels
    int                   TestedLevels;      // Tested levels
    
    int                   SupportLevels;     // Support levels
    int                   ResistanceLevels;  // Resistance levels
    int                   SwingHighs;        // Swing highs
    int                   SwingLows;         // Swing lows
    
    double                AvgLevelStrength;  // Average level strength
    double                AvgReliability;    // Average reliability
    double                BreakoutRate;      // Breakout success rate
    double                RetestRate;        // Retest success rate
    
    datetime              LastStructureTime; // Last structure detection
    datetime              LastBreakTime;     // Last structure break
    ENUM_STRUCTURE_TYPE   LastBreakType;     // Last break type
    
    int                   TrendChanges;      // Trend changes count
    int                   StructureBreaks;   // Structure breaks count
    double                TrendConsistency;  // Trend consistency score
};

//+------------------------------------------------------------------+
//| CStructure - Advanced Market Structure Analysis                 |
//+------------------------------------------------------------------+
class CStructure {
private:
    EAContext*            m_pContext;         // Reference to EA context
    bool                  m_bInitialized;    // Initialization status
    
    // Configuration
    SStructureConfig      m_Config;           // Structure configuration
    string                m_Symbol;           // Current symbol
    ENUM_TIMEFRAMES       m_Timeframe;       // Analysis timeframe
    
    // Structure data
    SStructureLevel       m_Levels[];         // Structure levels array
    int                   m_LevelCount;       // Number of levels
    SSwingPoint           m_Swings[];         // Swing points array
    int                   m_SwingCount;       // Number of swings
    
    // Market structure
    SMarketStructure      m_Structure;        // Current market structure
    SStructureStats       m_Stats;            // Structure statistics
    
    // Market data
    double                m_HighData[];       // High prices
    double                m_LowData[];        // Low prices
    double                m_OpenData[];       // Open prices
    double                m_CloseData[];      // Close prices
    long                  m_VolumeData[];     // Volume data
    datetime              m_TimeData[];       // Time data
    int                   m_DataCount;        // Data count
    
    // Analysis state
    datetime              m_LastUpdate;       // Last update time
    datetime              m_LastScan;         // Last structure scan
    bool                  m_StructureChanged; // Structure change flag
    
    // Constants
    static const int      MAX_LEVELS;
    static const int      MAX_SWINGS;
    static const double   STRUCTURE_TOLERANCE;
    
public:
    //--- Constructor/Destructor ---
    CStructure();
    ~CStructure();
    
    //--- Core Methods ---
    bool                  Initialize(EAContext* context);
    bool                  Initialize(const string& symbol, const ENUM_TIMEFRAMES timeframe, const SStructureConfig& config);
    void                  Deinitialize();
    bool                  IsInitialized() const { return m_bInitialized; }
    void                  Update();
    
    //--- Structure Analysis ---
    bool                  AnalyzeStructure();
    bool                  DetectStructureLevels();
    bool                  DetectSwingPoints();
    bool                  DetectStructureBreaks();
    bool                  UpdateTrendDirection();
    
    //--- Level Management ---
    int                   GetLevelCount() const { return m_LevelCount; }
    SStructureLevel       GetLevel(const int index);
    SStructureLevel       GetNearestLevel(const double price, const ENUM_STRUCTURE_TYPE type = STRUCTURE_NONE);
    bool                  GetActiveLevels(SStructureLevel& levels[]);
    bool                  GetLevelsByType(SStructureLevel& levels[], const ENUM_STRUCTURE_TYPE type);
    
    //--- Swing Point Access ---
    int                   GetSwingCount() const { return m_SwingCount; }
    SSwingPoint           GetSwing(const int index);
    SSwingPoint           GetLastSwingHigh();
    SSwingPoint           GetLastSwingLow();
    bool                  GetRecentSwings(SSwingPoint& swings[], const int count = 10);
    
    //--- Market Structure ---
    SMarketStructure      GetMarketStructure() const { return m_Structure; }
    ENUM_TREND_DIRECTION  GetPrimaryTrend() const { return m_Structure.PrimaryTrend; }
    ENUM_TREND_DIRECTION  GetSecondaryTrend() const { return m_Structure.SecondaryTrend; }
    double                GetTrendStrength() const { return m_Structure.TrendStrength; }
    double                GetTrendAngle() const { return m_Structure.TrendAngle; }
    
    //--- Structure Queries ---
    bool                  IsSupport(const double price, const double tolerance = 0);
    bool                  IsResistance(const double price, const double tolerance = 0);
    bool                  IsStructureLevel(const double price, const double tolerance = 0);
    bool                  IsSwingHigh(const double price, const double tolerance = 0);
    bool                  IsSwingLow(const double price, const double tolerance = 0);
    
    //--- Break Analysis ---
    bool                  IsStructureBroken(const double price);
    bool                  IsHighBroken() const { return m_Structure.HighBroken; }
    bool                  IsLowBroken() const { return m_Structure.LowBroken; }
    ENUM_BREAK_TYPE       GetLastBreakType();
    datetime              GetLastBreakTime();
    
    //--- Trend Analysis ---
    bool                  IsBullishStructure();
    bool                  IsBearishStructure();
    bool                  IsSidewaysStructure();
    bool                  IsStructureChanging();
    bool                  IsHigherHigh(const double price);
    bool                  IsHigherLow(const double price);
    bool                  IsLowerHigh(const double price);
    bool                  IsLowerLow(const double price);
    
    //--- Key Levels ---
    double                GetCurrentHigh() const { return m_Structure.CurrentHigh; }
    double                GetCurrentLow() const { return m_Structure.CurrentLow; }
    double                GetPreviousHigh() const { return m_Structure.PreviousHigh; }
    double                GetPreviousLow() const { return m_Structure.PreviousLow; }
    double                GetNearestSupport(const double price);
    double                GetNearestResistance(const double price);
    
    //--- Advanced Features ---
    bool                  DetectOrderBlocks();
    bool                  DetectFairValueGaps();
    bool                  DetectLiquidityPools();
    bool                  DetectInstitutionalLevels();
    
    //--- Level Validation ---
    bool                  ValidateLevel(const SStructureLevel& level);
    double                CalculateLevelStrength(const SStructureLevel& level);
    double                CalculateLevelSignificance(const SStructureLevel& level);
    ENUM_STRUCTURE_STRENGTH DetermineStrength(const int touch_count);
    
    //--- Trading Signals ---
    bool                  IsBreakoutSignal(const double price);
    bool                  IsRetestSignal(const double price);
    bool                  IsRejectionSignal(const double price);
    double                GetBreakoutTarget(const double break_price);
    double                GetRetestLevel(const double break_price);
    
    //--- Statistics ---
    SStructureStats       GetStatistics() const { return m_Stats; }
    void                  UpdateStatistics();
    double                GetBreakoutSuccessRate() const { return m_Stats.BreakoutRate; }
    double                GetRetestSuccessRate() const { return m_Stats.RetestRate; }
    
    //--- Configuration ---
    bool                  SetConfiguration(const SStructureConfig& config);
    SStructureConfig      GetConfiguration() const { return m_Config; }
    bool                  EnableStructureType(const ENUM_STRUCTURE_TYPE type, const bool enable);
    
    //--- Information ---
    string                GetStructureSummary();
    string                GetTrendSummary();
    string                GetLevelsSummary();
    string                GetStatisticsSummary();
    
private:
    //--- Data Loading ---
    bool                  LoadMarketData();
    void                  UpdateMarketData();
    
    //--- Structure Detection Implementation ---
    bool                  FindSupportResistance();
    bool                  FindTrendLines();
    bool                  FindChannels();
    bool                  FindPivotPoints();
    
    //--- Swing Detection Implementation ---
    bool                  FindSwingHighs();
    bool                  FindSwingLows();
    bool                  ValidateSwing(const SSwingPoint& swing);
    SSwingPoint           CreateSwing(const ENUM_STRUCTURE_TYPE type, const double price, const datetime time, const int index);
    
    //--- Break Detection Implementation ---
    bool                  CheckLevelBreaks();
    bool                  CheckSwingBreaks();
    bool                  ValidateBreak(const double level, const double break_price);
    ENUM_BREAK_TYPE       ClassifyBreak(const SStructureLevel& level, const double break_price);
    
    //--- Trend Analysis Implementation ---
    ENUM_TREND_DIRECTION  AnalyzePrimaryTrend();
    ENUM_TREND_DIRECTION  AnalyzeSecondaryTrend();
    double                CalculateTrendStrength();
    double                CalculateTrendAngle();
    double                CalculateTrendVelocity();
    
    //--- Level Creation ---
    SStructureLevel       CreateLevel(const ENUM_STRUCTURE_TYPE type, const double price, const datetime time);
    void                  UpdateLevel(SStructureLevel& level, const double price, const datetime time);
    bool                  AddLevel(const SStructureLevel& level);
    bool                  RemoveLevel(const int index);
    
    //--- Level Management ---
    void                  UpdateLevelStatus();
    void                  CleanupOldLevels();
    void                  SortLevels();
    bool                  IsLevelNearby(const double price, const double tolerance);
    
    //--- Calculation Methods ---
    double                CalculateAverageRange(const int period);
    double                CalculateVolatility(const int period);
    double                CalculateMomentum(const int period);
    bool                  IsPriceAtLevel(const double price, const double level, const double tolerance);
    
    //--- Support Methods ---
    bool                  IsLocalHigh(const int index, const int lookback);
    bool                  IsLocalLow(const int index, const int lookback);
    int                   CountTouches(const double level, const double tolerance, const int lookback);
    double                GetMaxDeviation(const double level, const int start_index, const int end_index);
    
    //--- Utility Methods ---
    bool                  IsValidIndex(const int index);
    bool                  IsValidPrice(const double price);
    int                   GetBarIndex(const datetime time);
    datetime              GetBarTime(const int index);
    void                  LogStructureEvent(const string& event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO);
    
    //--- Array Management ---
    void                  ResizeLevelArray(const int new_size);
    void                  ResizeSwingArray(const int new_size);
    void                  AddLevelToArray(const SStructureLevel& level);
    void                  AddSwingToArray(const SSwingPoint& swing);
};

// Static constants definition
const int CStructure::MAX_LEVELS = 200;
const int CStructure::MAX_SWINGS = 100;
const double CStructure::STRUCTURE_TOLERANCE = 0.0001;

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CStructure::CStructure() {
    m_pContext = NULL;
    m_bInitialized = false;
    m_Symbol = "";
    m_Timeframe = PERIOD_CURRENT;
    m_LevelCount = 0;
    m_SwingCount = 0;
    m_DataCount = 0;
    m_LastUpdate = 0;
    m_LastScan = 0;
    m_StructureChanged = false;
    
    // Initialize structures
    ZeroMemory(m_Config);
    ZeroMemory(m_Structure);
    ZeroMemory(m_Stats);
    
    // Set default configuration
    m_Config.LookbackPeriod = 500;
    m_Config.SwingLookback = 10;
    m_Config.MinSwingSize = 100; // points
    m_Config.LevelTolerance = 20; // points
    m_Config.DetectSupport = true;
    m_Config.DetectResistance = true;
    m_Config.DetectTrendLines = true;
    m_Config.DetectChannels = true;
    m_Config.DetectSwings = true;
    m_Config.DetectBreaks = true;
    m_Config.UseOrderBlocks = false;
    m_Config.UseFairValueGaps = false;
    m_Config.UseLiquidityPools = false;
    m_Config.UseInstitutional = false;
    m_Config.MinTouchCount = 2;
    m_Config.MinSignificance = 50.0;
    m_Config.MinReliability = 60.0;
    m_Config.UseTimeFilter = false;
    m_Config.UseVolumeFilter = false;
    m_Config.ShowLevels = true;
    m_Config.ShowSwings = true;
    m_Config.ShowBreaks = true;
    m_Config.ShowLabels = true;
    m_Config.MaxLevels = 50;
    m_Config.RealTimeUpdate = true;
    m_Config.HistoricalScan = true;
    m_Config.UpdateFrequency = 60; // 1 minute
    m_Config.AutoCleanup = true;
}

bool CStructure::Initialize(EAContext* context) {
    if(context == NULL) {
        printf("Error: CStructure received a null EAContext pointer.");
        return false;
    }
    m_pContext = context;
    return true;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CStructure::~CStructure() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CStructure::Initialize(const string& symbol, const ENUM_TIMEFRAMES timeframe, const SStructureConfig& config) {
    if (m_bInitialized) {
        return true;
    }
    
    if (m_pContext == NULL) {
        Print("[STRUCTURE] Context is NULL. Call Initialize(EAContext*) first.");
        return false;
    }
    
    m_Symbol = symbol;
    m_Timeframe = timeframe;
    m_Config = config;
    
    // Validate configuration
    if (m_Config.LookbackPeriod < 100) {
        m_Config.LookbackPeriod = 500;
    }
    
    if (m_Config.SwingLookback < 5) {
        m_Config.SwingLookback = 10;
    }
    
    if (m_Config.MaxLevels > MAX_LEVELS) {
        m_Config.MaxLevels = MAX_LEVELS;
    }
    
    // Initialize arrays
    ArrayResize(m_Levels, MAX_LEVELS);
    ArrayResize(m_Swings, MAX_SWINGS);
    
    // Load initial market data
    if (!LoadMarketData()) {
        LogStructureEvent("Failed to load market data", LOG_LEVEL_ERROR);
        return false;
    }
    
    // Perform initial structure analysis
    if (m_Config.HistoricalScan) {
        AnalyzeStructure();
        UpdateStatistics();
    }
    
    m_bInitialized = true;
    
    if (m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo("Structure analysis initialized for: " + symbol, __FUNCTION__);
        m_pContext->pLogger->LogInfo(GetStructureSummary(), __FUNCTION__);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CStructure::Deinitialize() {
    if (!m_bInitialized) {
        return;
    }
    
    if (m_pContext != NULL && m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo(GetStatisticsSummary(), __FUNCTION__);
        m_pContext->pLogger->LogInfo("Structure analysis shutting down", __FUNCTION__);
    }
    
    m_bInitialized = false;
}

//+------------------------------------------------------------------+
//| Update                                                           |
//+------------------------------------------------------------------+
void CStructure::Update() {
    if (!m_bInitialized) {
        return;
    }
    
    datetime current_time = TimeCurrent();
    
    // Real-time structure analysis
    if (m_Config.RealTimeUpdate) {
        UpdateMarketData();
        
        // Update level status
        UpdateLevelStatus();
        
        // Check for structure breaks
        if (DetectStructureBreaks()) {
            m_StructureChanged = true;
            UpdateTrendDirection();
        }
        
        // Full structure analysis every few minutes
        if (current_time - m_LastScan >= m_Config.UpdateFrequency) {
            if (AnalyzeStructure()) {
                m_StructureChanged = true;
                UpdateStatistics();
            }
            m_LastScan = current_time;
        }
    }
    
    // Cleanup old levels
    if (m_Config.AutoCleanup && current_time - m_LastUpdate >= 3600) { // Every hour
        CleanupOldLevels();
        UpdateStatistics();
        m_LastUpdate = current_time;
    }
}

//+------------------------------------------------------------------+
//| Analyze Structure                                                |
//+------------------------------------------------------------------+
bool CStructure::AnalyzeStructure() {
    if (m_DataCount < m_Config.SwingLookback * 2) {
        return false;
    }
    
    bool structure_found = false;
    
    // Detect structure levels
    if (DetectStructureLevels()) {
        structure_found = true;
    }
    
    // Detect swing points
    if (DetectSwingPoints()) {
        structure_found = true;
    }
    
    // Update trend direction
    if (UpdateTrendDirection()) {
        structure_found = true;
    }
    
    // Detect structure breaks
    if (DetectStructureBreaks()) {
        structure_found = true;
    }
    
    if (structure_found) {
        SortLevels();
        LogStructureEvent(StringFormat("Structure analysis completed. Found %d levels, %d swings", 
                                      m_LevelCount, m_SwingCount));
    }
    
    return structure_found;
}

//+------------------------------------------------------------------+
//| Detect Structure Levels                                          |
//+------------------------------------------------------------------+
bool CStructure::DetectStructureLevels() {
    bool levels_found = false;
    
    // Find support and resistance levels
    if (m_Config.DetectSupport || m_Config.DetectResistance) {
        if (FindSupportResistance()) {
            levels_found = true;
        }
    }
    
    // Find trend lines
    if (m_Config.DetectTrendLines) {
        if (FindTrendLines()) {
            levels_found = true;
        }
    }
    
    // Find channels
    if (m_Config.DetectChannels) {
        if (FindChannels()) {
            levels_found = true;
        }
    }
    
    // Find pivot points
    if (FindPivotPoints()) {
        levels_found = true;
    }
    
    return levels_found;
}

//+------------------------------------------------------------------+
//| Detect Swing Points                                              |
//+------------------------------------------------------------------+
bool CStructure::DetectSwingPoints() {
    bool swings_found = false;
    
    // Find swing highs
    if (FindSwingHighs()) {
        swings_found = true;
    }
    
    // Find swing lows
    if (FindSwingLows()) {
        swings_found = true;
    }
    
    return swings_found;
}

//+------------------------------------------------------------------+
//| Update Trend Direction                                           |
//+------------------------------------------------------------------+
bool CStructure::UpdateTrendDirection() {
    ENUM_TREND_DIRECTION old_primary = m_Structure.PrimaryTrend;
    ENUM_TREND_DIRECTION old_secondary = m_Structure.SecondaryTrend;
    
    // Analyze primary trend
    m_Structure.PrimaryTrend = AnalyzePrimaryTrend();
    
    // Analyze secondary trend
    m_Structure.SecondaryTrend = AnalyzeSecondaryTrend();
    
    // Calculate trend metrics
    m_Structure.TrendStrength = CalculateTrendStrength();
    m_Structure.TrendAngle = CalculateTrendAngle();
    m_Structure.TrendVelocity = CalculateTrendVelocity();
    
    // Update market character
    m_Structure.IsImpulsive = (m_Structure.TrendStrength > 70.0);
    m_Structure.IsCorrective = (m_Structure.TrendStrength < 30.0);
    m_Structure.IsConsolidating = (m_Structure.PrimaryTrend == TREND_SIDEWAYS);
    m_Structure.IsBreakingOut = (m_Structure.HighBroken || m_Structure.LowBroken);
    
    // Check for trend changes
    bool trend_changed = (old_primary != m_Structure.PrimaryTrend || 
                         old_secondary != m_Structure.SecondaryTrend);
    
    if (trend_changed) {
        m_Stats.TrendChanges++;
        LogStructureEvent(StringFormat("Trend changed: %s -> %s", 
                                      EnumToString(old_primary), 
                                      EnumToString(m_Structure.PrimaryTrend)));
    }
    
    return trend_changed;
}

//+------------------------------------------------------------------+
//| Is Bullish Structure                                             |
//+------------------------------------------------------------------+
bool CStructure::IsBullishStructure() {
    return (m_Structure.PrimaryTrend == TREND_BULLISH || 
            m_Structure.PrimaryTrend == TREND_BREAKOUT_BULL || 
            m_Structure.PrimaryTrend == TREND_REVERSAL_BULL);
}

//+------------------------------------------------------------------+
//| Is Bearish Structure                                             |
//+------------------------------------------------------------------+
bool CStructure::IsBearishStructure() {
    return (m_Structure.PrimaryTrend == TREND_BEARISH || 
            m_Structure.PrimaryTrend == TREND_BREAKOUT_BEAR || 
            m_Structure.PrimaryTrend == TREND_REVERSAL_BEAR);
}

//+------------------------------------------------------------------+
//| Is Sideways Structure                                            |
//+------------------------------------------------------------------+
bool CStructure::IsSidewaysStructure() {
    return (m_Structure.PrimaryTrend == TREND_SIDEWAYS || 
            m_Structure.PrimaryTrend == TREND_CONSOLIDATION);
}

//+------------------------------------------------------------------+
//| Is Higher High                                                   |
//+------------------------------------------------------------------+
bool CStructure::IsHigherHigh(const double price) {
    return (price > m_Structure.CurrentHigh && 
            m_Structure.CurrentHigh > m_Structure.PreviousHigh);
}

//+------------------------------------------------------------------+
//| Is Higher Low                                                    |
//+------------------------------------------------------------------+
bool CStructure::IsHigherLow(const double price) {
    return (price > m_Structure.CurrentLow && 
            m_Structure.CurrentLow > m_Structure.PreviousLow);
}

//+------------------------------------------------------------------+
//| Is Lower High                                                    |
//+------------------------------------------------------------------+
bool CStructure::IsLowerHigh(const double price) {
    return (price < m_Structure.CurrentHigh && 
            m_Structure.CurrentHigh < m_Structure.PreviousHigh);
}

//+------------------------------------------------------------------+
//| Is Lower Low                                                     |
//+------------------------------------------------------------------+
bool CStructure::IsLowerLow(const double price) {
    return (price < m_Structure.CurrentLow && 
            m_Structure.CurrentLow < m_Structure.PreviousLow);
}

//+------------------------------------------------------------------+
//| Get Nearest Support                                              |
//+------------------------------------------------------------------+
double CStructure::GetNearestSupport(const double price) {
    double nearest_support = 0;
    double min_distance = DBL_MAX;
    
    for (int i = 0; i < m_LevelCount; i++) {
        if (m_Levels[i].Type == STRUCTURE_SUPPORT && 
            m_Levels[i].IsActive && 
            m_Levels[i].Price < price) {
            
            double distance = price - m_Levels[i].Price;
            if (distance < min_distance) {
                min_distance = distance;
                nearest_support = m_Levels[i].Price;
            }
        }
    }
    
    return nearest_support;
}

//+------------------------------------------------------------------+
//| Get Nearest Resistance                                           |
//+------------------------------------------------------------------+
double CStructure::GetNearestResistance(const double price) {
    double nearest_resistance = 0;
    double min_distance = DBL_MAX;
    
    for (int i = 0; i < m_LevelCount; i++) {
        if (m_Levels[i].Type == STRUCTURE_RESISTANCE && 
            m_Levels[i].IsActive && 
            m_Levels[i].Price > price) {
            
            double distance = m_Levels[i].Price - price;
            if (distance < min_distance) {
                min_distance = distance;
                nearest_resistance = m_Levels[i].Price;
            }
        }
    }
    
    return nearest_resistance;
}

//+------------------------------------------------------------------+
//| Get Structure Summary                                            |
//+------------------------------------------------------------------+
string CStructure::GetStructureSummary() {
    string summary = "=== MARKET STRUCTURE ===\n";
    summary += StringFormat("Symbol: %s\n", m_Symbol);
    summary += StringFormat("Timeframe: %s\n", EnumToString(m_Timeframe));
    summary += StringFormat("Primary Trend: %s\n", EnumToString(m_Structure.PrimaryTrend));
    summary += StringFormat("Secondary Trend: %s\n", EnumToString(m_Structure.SecondaryTrend));
    summary += StringFormat("Trend Strength: %.1f%%\n", m_Structure.TrendStrength);
    summary += StringFormat("Trend Angle: %.1f°\n", m_Structure.TrendAngle);
    summary += StringFormat("Current High: %.5f\n", m_Structure.CurrentHigh);
    summary += StringFormat("Current Low: %.5f\n", m_Structure.CurrentLow);
    summary += StringFormat("Structure Levels: %d\n", m_Stats.ActiveLevels);
    summary += StringFormat("Swing Points: %d\n", m_SwingCount);
    summary += StringFormat("High Broken: %s\n", m_Structure.HighBroken ? "Yes" : "No");
    summary += StringFormat("Low Broken: %s\n", m_Structure.LowBroken ? "Yes" : "No");
    
    return summary;
}

//+------------------------------------------------------------------+
//| Internal Methods                                                 |
//+------------------------------------------------------------------+
bool CStructure::LoadMarketData() {
    if (m_Symbol == "") {
        return false;
    }
    
    // Load OHLC and volume data
    double high_prices[], low_prices[], open_prices[], close_prices[];
    long volumes[];
    datetime times[];
    
    int copied_high = CopyHigh(m_Symbol, m_Timeframe, 0, m_Config.LookbackPeriod, high_prices);
    int copied_low = CopyLow(m_Symbol, m_Timeframe, 0, m_Config.LookbackPeriod, low_prices);
    int copied_open = CopyOpen(m_Symbol, m_Timeframe, 0, m_Config.LookbackPeriod, open_prices);
    int copied_close = CopyClose(m_Symbol, m_Timeframe, 0, m_Config.LookbackPeriod, close_prices);
    int copied_volumes = CopyTickVolume(m_Symbol, m_Timeframe, 0, m_Config.LookbackPeriod, volumes);
    int copied_times = CopyTime(m_Symbol, m_Timeframe, 0, m_Config.LookbackPeriod, times);
    
    if (copied_high < m_Config.SwingLookback * 2 || 
        copied_low < m_Config.SwingLookback * 2 || 
        copied_open < m_Config.SwingLookback * 2 || 
        copied_close < m_Config.SwingLookback * 2) {
        LogStructureEvent("Insufficient market data loaded", LOG_LEVEL_ERROR);
        return false;
    }
    
    // Store data
    m_DataCount = copied_high;
    ArrayResize(m_HighData, m_DataCount);
    ArrayResize(m_LowData, m_DataCount);
    ArrayResize(m_OpenData, m_DataCount);
    ArrayResize(m_CloseData, m_DataCount);
    ArrayResize(m_VolumeData, m_DataCount);
    ArrayResize(m_TimeData, m_DataCount);
    
    ArrayCopy(m_HighData, high_prices);
    ArrayCopy(m_LowData, low_prices);
    ArrayCopy(m_OpenData, open_prices);
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

bool CStructure::AddLevel(const SStructureLevel& level) {
    if (m_LevelCount >= ArraySize(m_Levels)) {
        // Remove weakest level if array is full
        int weakest_index = 0;
        double weakest_strength = m_Levels[0].Reliability;
        
        for (int i = 1; i < m_LevelCount; i++) {
            if (m_Levels[i].Reliability < weakest_strength) {
                weakest_strength = m_Levels[i].Reliability;
                weakest_index = i;
            }
        }
        
        // Remove weakest level
        for (int i = weakest_index; i < m_LevelCount - 1; i++) {
            m_Levels[i] = m_Levels[i + 1];
        }
        m_LevelCount--;
    }
    
    // Add new level
    m_Levels[m_LevelCount] = level;
    m_LevelCount++;
    
    return true;
}

void CStructure::AddSwingToArray(const SSwingPoint& swing) {
    if (m_SwingCount >= ArraySize(m_Swings)) {
        // Shift array to make room
        for (int i = 0; i < m_SwingCount - 1; i++) {
            m_Swings[i] = m_Swings[i + 1];
        }
        m_SwingCount--;
    }
    
    m_Swings[m_SwingCount] = swing;
    m_SwingCount++;
}

} // namespace ApexPullback::v5

#endif // STRUCTURE_MQH--;
    }
    
    // Add new level
    m_Levels[m_LevelCount] = level;
    m_LevelCount++;
    
    return true;
}

void CStructure::AddSwingToArray(const SSwingPoint& swing) {
    if (m_SwingCount >= ArraySize(m_Swings)) {
        // Shift array to make room
        for (int i = 0; i < m_SwingCount - 1; i++) {
            m_Swings[i] = m_Swings[i + 1];
        }
        m_SwingCount--;
    }
    
    m_Swings[m_SwingCount] = swing;
    m_SwingCount++;
}

void CStructure::UpdateStatistics() {
    // Reset statistics
    ZeroMemory(m_Stats);
    
    // Count levels by type and status
    for (int i = 0; i < m_LevelCount; i++) {
        m_Stats.TotalLevels++;
        
        if (m_Levels[i].IsActive) {
            m_Stats.ActiveLevels++;
        }
        
        if (m_Levels[i].IsBroken) {
            m_Stats.BrokenLevels++;
        }
        
        if (m_Levels[i].TouchCount > 1) {
            m_Stats.TestedLevels++;
        }
        
        if (m_Levels[i].Type == STRUCTURE_SUPPORT) {
            m_Stats.SupportLevels++;
        } else if (m_Levels[i].Type == STRUCTURE_RESISTANCE) {
            m_Stats.ResistanceLevels++;
        }
        
        m_Stats.AvgLevelStrength += m_Levels[i].Reliability;
        m_Stats.AvgReliability += m_Levels[i].Significance;
    }
    
    // Calculate averages
    if (m_Stats.TotalLevels > 0) {
        m_Stats.AvgLevelStrength /= m_Stats.TotalLevels;
        m_Stats.AvgReliability /= m_Stats.TotalLevels;
    }
    
    // Count swing points
    for (int i = 0; i < m_SwingCount; i++) {
        if (m_Swings[i].Type == STRUCTURE_SWING_HIGH) {
            m_Stats.SwingHighs++;
        } else if (m_Swings[i].Type == STRUCTURE_SWING_LOW) {
            m_Stats.SwingLows++;
        }
    }
    
    // Calculate success rates (simplified)
    if (m_Stats.BrokenLevels > 0) {
        m_Stats.BreakoutRate = (double)m_Stats.BrokenLevels / m_Stats.TotalLevels * 100.0;
    }
    
    m_Stats.LastStructureTime = TimeCurrent();
}

void CStructure::UpdateMarketData() {
    // Update only the latest bars
    double high_prices[10], low_prices[10], open_prices[10], close_prices[10];
    long volumes[10];
    datetime times[10];
    
    int copied = CopyHigh(m_Symbol, m_Timeframe, 0, 10, high_prices);
    if (copied > 0) {
        CopyLow(m_Symbol, m_Timeframe, 0, copied, low_prices);
        CopyOpen(m_Symbol, m_Timeframe, 0, copied, open_prices);
        CopyClose(m_Symbol, m_Timeframe, 0, copied, close_prices);
        CopyTickVolume(m_Symbol, m_Timeframe, 0, copied, volumes);
        CopyTime(m_Symbol, m_Timeframe, 0, copied, times);
        
        // Update latest data
        for (int i = 0; i < copied && i < 10; i++) {
            int index = m_DataCount - copied + i;
            if (index >= 0 && index < m_DataCount) {
                m_HighData[index] = high_prices[i];
                m_LowData[index] = low_prices[i];
                m_OpenData[index] = open_prices[i];
                m_CloseData[index] = close_prices[i];
                m_VolumeData[index] = (i < ArraySize(volumes)) ? volumes[i] : 1;
                m_TimeData[index] = times[i];
            }
        }
    }
}

void CStructure::UpdateLevelStatus() {
    double current_price = SymbolInfoDouble(m_Symbol, SYMBOL_BID);
    datetime current_time = TimeCurrent();
    
    for (int i = 0; i < m_LevelCount; i++) {
        // Update bars since touch
        m_Levels[i].BarsSinceTouch = (int)((current_time - m_Levels[i].LastTouch) / PeriodSeconds(m_Timeframe));
        
        // Update bars since break
        if (m_Levels[i].IsBroken) {
            m_Levels[i].BarsSinceBreak = (int)((current_time - m_Levels[i].BreakTime) / PeriodSeconds(m_Timeframe));
        }
        
        // Check for new touches
        double tolerance = m_Config.LevelTolerance * SymbolInfoDouble(m_Symbol, SYMBOL_POINT);
        if (IsPriceAtLevel(current_price, m_Levels[i].Price, tolerance)) {
            m_Levels[i].LastTouch = current_time;
            m_Levels[i].TouchCount++;
            m_Levels[i].BarsSinceTouch = 0;
            
            // Add to touch history
            if (m_Levels[i].TouchHistoryCount < 10) {
                m_Levels[i].TouchTimes[m_Levels[i].TouchHistoryCount] = current_time;
                m_Levels[i].TouchPrices[m_Levels[i].TouchHistoryCount] = current_price;
                m_Levels[i].TouchHistoryCount++;
            }
        }
    }
}

bool CStructure::DetectStructureBreaks() {
    bool breaks_detected = false;
    double current_price = SymbolInfoDouble(m_Symbol, SYMBOL_BID);
    datetime current_time = TimeCurrent();
    
    // Check level breaks
    for (int i = 0; i < m_LevelCount; i++) {
        if (!m_Levels[i].IsBroken && m_Levels[i].IsActive) {
            bool is_broken = false;
            
            if (m_Levels[i].Type == STRUCTURE_SUPPORT && current_price < m_Levels[i].Price) {
                is_broken = true;
            } else if (m_Levels[i].Type == STRUCTURE_RESISTANCE && current_price > m_Levels[i].Price) {
                is_broken = true;
            }
            
            if (is_broken) {
                m_Levels[i].IsBroken = true;
                m_Levels[i].BreakTime = current_time;
                m_Levels[i].Status = STATUS_BROKEN;
                m_Levels[i].BreakType = ClassifyBreak(m_Levels[i], current_price);
                
                m_Stats.StructureBreaks++;
                m_Stats.LastBreakTime = current_time;
                m_Stats.LastBreakType = m_Levels[i].Type;
                
                LogStructureEvent(StringFormat("Structure break: %s at %.5f", 
                                              EnumToString(m_Levels[i].Type), 
                                              m_Levels[i].Price));
                
                breaks_detected = true;
            }
        }
    }
    
    // Check swing breaks
    for (int i = 0; i < m_SwingCount; i++) {
        if (!m_Swings[i].IsBroken) {
            bool is_broken = false;
            
            if (m_Swings[i].Type == STRUCTURE_SWING_HIGH && current_price > m_Swings[i].Price) {
                is_broken = true;
                m_Structure.HighBroken = true;
                m_Structure.HighBreakTime = current_time;
            } else if (m_Swings[i].Type == STRUCTURE_SWING_LOW && current_price < m_Swings[i].Price) {
                is_broken = true;
                m_Structure.LowBroken = true;
                m_Structure.LowBreakTime = current_time;
            }
            
            if (is_broken) {
                m_Swings[i].IsBroken = true;
                m_Swings[i].BreakTime = current_time;
                m_Swings[i].BreakPrice = current_price;
                
                breaks_detected = true;
            }
        }
    }
    
    return breaks_detected;
}

ENUM_BREAK_TYPE CStructure::ClassifyBreak(const SStructureLevel& level, const double break_price) {
    double break_distance = MathAbs(break_price - level.Price);
    double atr = CalculateAverageRange(14);
    
    if (break_distance > atr * 0.5) {
        return BREAK_CLEAN;
    } else {
        return BREAK_FALSE; // Might be false break
    }
}

double CStructure::CalculateAverageRange(const int period) {
    if (m_DataCount < period) {
        return 0;
    }
    
    double total_range = 0;
    int start_index = m_DataCount - period;
    
    for (int i = start_index; i < m_DataCount; i++) {
        total_range += (m_HighData[i] - m_LowData[i]);
    }
    
    return total_range / period;
}

double CStructure::CalculateTrendStrength() {
    if (m_SwingCount < 4) {
        return 50.0;
    }
    
    // Simple trend strength calculation based on swing consistency
    int consistent_moves = 0;
    int total_moves = 0;
    
    for (int i = 1; i < m_SwingCount; i++) {
        if (m_Structure.PrimaryTrend == TREND_BULLISH) {
            if (m_Swings[i].Type == STRUCTURE_SWING_HIGH && 
                m_Swings[i].Price > m_Swings[i-1].Price) {
                consistent_moves++;
            }
        } else if (m_Structure.PrimaryTrend == TREND_BEARISH) {
            if (m_Swings[i].Type == STRUCTURE_SWING_LOW && 
                m_Swings[i].Price < m_Swings[i-1].Price) {
                consistent_moves++;
            }
        }
        total_moves++;
    }
    
    if (total_moves > 0) {
        return (double)consistent_moves / total_moves * 100.0;
    }
    
    return 50.0;
}

void CStructure::CleanupOldLevels() {
    datetime cutoff_time = TimeCurrent() - (PeriodSeconds(m_Timeframe) * m_Config.LookbackPeriod);
    
    for (int i = m_LevelCount - 1; i >= 0; i--) {
        bool should_remove = false;
        
        // Remove very old levels
        if (m_Levels[i].LastTouch < cutoff_time) {
            should_remove = true;
        }
        
        // Remove broken levels that are old
        if (m_Levels[i].IsBroken && m_Levels[i].BarsSinceBreak > 100) {
            should_remove = true;
        }
        
        // Remove weak levels
        if (m_Levels[i].Reliability < 30.0 && m_Levels[i].TouchCount < 3) {
            should_remove = true;
        }
        
        if (should_remove) {
            RemoveLevel(i);
        }
    }
}

bool CStructure::RemoveLevel(const int index) {
    if (index < 0 || index >= m_LevelCount) {
        return false;
    }
    
    // Shift array elements
    for (int i = index; i < m_LevelCount - 1; i++) {
        m_Levels[i] = m_Levels[i + 1];
    }
    
    m_LevelCount--;
    return true;
}

void CStructure::SortLevels() {
    // Simple bubble sort by price
    for (int i = 0; i < m_LevelCount - 1; i++) {
        for (int j = 0; j < m_LevelCount - i - 1; j++) {
            if (m_Levels[j].Price > m_Levels[j + 1].Price) {
                SStructureLevel temp = m_Levels[j];
                m_Levels[j] = m_Levels[j + 1];
                m_Levels[j + 1] = temp;
            }
        }
    }
}

bool CStructure::IsValidIndex(const int index) {
    return (index >= 0 && index < m_DataCount);
}

bool CStructure::IsValidPrice(const double price) {
    return (price > 0 && price != EMPTY_VALUE);
}

void CStructure::LogStructureEvent(const string& event, const ENUM_LOG_LEVEL level) {
    if (m_pContext != NULL && m_pContext->pLogger != NULL) {
        m_pContext->pLogger->Log(level, event, __FUNCTION__);
    }
}

// Additional stub implementations for missing methods
bool CStructure::FindTrendLines() { return false; }
bool CStructure::FindChannels() { return false; }
bool CStructure::FindPivotPoints() { return false; }
bool CStructure::DetectOrderBlocks() { return false; }
bool CStructure::DetectFairValueGaps() { return false; }
bool CStructure::DetectLiquidityPools() { return false; }
bool CStructure::DetectInstitutionalLevels() { return false; }

ENUM_TREND_DIRECTION CStructure::AnalyzeSecondaryTrend() {
    return m_Structure.PrimaryTrend; // Simplified
}

double CStructure::CalculateTrendAngle() { return 0.0; }
double CStructure::CalculateTrendVelocity() { return 0.0; }
double CStructure::CalculateVolatility(const int period) { return 0.0; }
double CStructure::CalculateMomentum(const int period) { return 0.0; }

#endif // STRUCTURE_MQH_;       // Number of levels
    SSwingPoint           m_Swings[];         // Swing points array
    int                   m_SwingCount;       // Number of swings
    
    // Market structure
    SMarketStructure      m_Structure;        // Current market structure
    SStructureStats       m_Stats;            // Structure statistics
    
    // Market data
    double                m_HighData[];       // High prices
    double                m_LowData[];        // Low prices
    double                m_OpenData[];       // Open prices
    double                m_CloseData[];      // Close prices
    long                  m_VolumeData[];     // Volume data
    datetime              m_TimeData[];       // Time data
    int                   m_DataCount;        // Data count
    
    // Analysis state
    datetime              m_LastUpdate;       // Last update time
    datetime              m_LastScan;         // Last structure scan
    bool                  m_StructureChanged; // Structure change flag
    
    // Constants
    static const int      MAX_LEVELS;
    static const int      MAX_SWINGS;
    static const double   STRUCTURE_TOLERANCE;
    
public:
    //--- Constructor/Destructor ---
    CStructure(EAContext* context);
    ~CStructure();
    
    //--- Core Methods ---
    bool                  Initialize(const string& symbol, const ENUM_TIMEFRAMES timeframe, const SStructureConfig& config);
    void                  Deinitialize();
    bool                  IsInitialized() const { return m_bInitialized; }
    void                  Update();
    
    //--- Structure Analysis ---
    bool                  AnalyzeStructure();
    bool                  DetectStructureLevels();
    bool                  DetectSwingPoints();
    bool                  DetectStructureBreaks();
    bool                  UpdateTrendDirection();
    
    //--- Level Management ---
    int                   GetLevelCount() const { return m_LevelCount; }
    SStructureLevel       GetLevel(const int index);
    SStructureLevel       GetNearestLevel(const double price, const ENUM_STRUCTURE_TYPE type = STRUCTURE_NONE);
    bool                  GetActiveLevels(SStructureLevel& levels[]);
    bool                  GetLevelsByType(SStructureLevel& levels[], const ENUM_STRUCTURE_TYPE type);
    
    //--- Swing Point Access ---
    int                   GetSwingCount() const { return m_SwingCount; }
    SSwingPoint           GetSwing(const int index);
    SSwingPoint           GetLastSwingHigh();
    SSwingPoint           GetLastSwingLow();
    bool                  GetRecentSwings(SSwingPoint& swings[], const int count = 10);
    
    //--- Market Structure ---
    SMarketStructure      GetMarketStructure() const { return m_Structure; }
    ENUM_TREND_DIRECTION  GetPrimaryTrend() const { return m_Structure.PrimaryTrend; }
    ENUM_TREND_DIRECTION  GetSecondaryTrend() const { return m_Structure.SecondaryTrend; }
    double                GetTrendStrength() const { return m_Structure.TrendStrength; }
    double                GetTrendAngle() const { return m_Structure.TrendAngle; }
    
    //--- Structure Queries ---
    bool                  IsSupport(const double price, const double tolerance = 0);
    bool                  IsResistance(const double price, const double tolerance = 0);
    bool                  IsStructureLevel(const double price, const double tolerance = 0);
    bool                  IsSwingHigh(const double price, const double tolerance = 0);
    bool                  IsSwingLow(const double price, const double tolerance = 0);
    
    //--- Break Analysis ---
    bool                  IsStructureBroken(const double price);
    bool                  IsHighBroken() const { return m_Structure.HighBroken; }
    bool                  IsLowBroken() const { return m_Structure.LowBroken; }
    ENUM_BREAK_TYPE       GetLastBreakType();
    datetime              GetLastBreakTime();
    
    //--- Trend Analysis ---
    bool                  IsBullishStructure();
    bool                  IsBearishStructure();
    bool                  IsSidewaysStructure();
    bool                  IsStructureChanging();
    bool                  IsHigherHigh(const double price);
    bool                  IsHigherLow(const double price);
    bool                  IsLowerHigh(const double price);
    bool                  IsLowerLow(const double price);
    
    //--- Key Levels ---
    double                GetCurrentHigh() const { return m_Structure.CurrentHigh; }
    double                GetCurrentLow() const { return m_Structure.CurrentLow; }
    double                GetPreviousHigh() const { return m_Structure.PreviousHigh; }
    double                GetPreviousLow() const { return m_Structure.PreviousLow; }
    double                GetNearestSupport(const double price);
    double                GetNearestResistance(const double price);
    
    //--- Advanced Features ---
    bool                  DetectOrderBlocks();
    bool                  DetectFairValueGaps();
    bool                  DetectLiquidityPools();
    bool                  DetectInstitutionalLevels();
    
    //--- Level Validation ---
    bool                  ValidateLevel(const SStructureLevel& level);
    double                CalculateLevelStrength(const SStructureLevel& level);
    double                CalculateLevelSignificance(const SStructureLevel& level);
    ENUM_STRUCTURE_STRENGTH DetermineStrength(const int touch_count);
    
    //--- Trading Signals ---
    bool                  IsBreakoutSignal(const double price);
    bool                  IsRetestSignal(const double price);
    bool                  IsRejectionSignal(const double price);
    double                GetBreakoutTarget(const double break_price);
    double                GetRetestLevel(const double break_price);
    
    //--- Statistics ---
    SStructureStats       GetStatistics() const { return m_Stats; }
    void                  UpdateStatistics();
    double                GetBreakoutSuccessRate() const { return m_Stats.BreakoutRate; }
    double                GetRetestSuccessRate() const { return m_Stats.RetestRate; }
    
    //--- Configuration ---
    bool                  SetConfiguration(const SStructureConfig& config);
    SStructureConfig      GetConfiguration() const { return m_Config; }
    bool                  EnableStructureType(const ENUM_STRUCTURE_TYPE type, const bool enable);
    
    //--- Information ---
    string                GetStructureSummary();
    string                GetTrendSummary();
    string                GetLevelsSummary();
    string                GetStatisticsSummary();
    
private:
    //--- Data Loading ---
    bool                  LoadMarketData();
    void                  UpdateMarketData();
    
    //--- Structure Detection Implementation ---
    bool                  FindSupportResistance();
    bool                  FindTrendLines();
    bool                  FindChannels();
    bool                  FindPivotPoints();
    
    //--- Swing Detection Implementation ---
    bool                  FindSwingHighs();
    bool                  FindSwingLows();
    bool                  ValidateSwing(const SSwingPoint& swing);
    SSwingPoint           CreateSwing(const ENUM_STRUCTURE_TYPE type, const double price, const datetime time, const int index);
    
    //--- Break Detection Implementation ---
    bool                  CheckLevelBreaks();
    bool                  CheckSwingBreaks();
    bool                  ValidateBreak(const double level, const double break_price);
    ENUM_BREAK_TYPE       ClassifyBreak(const SStructureLevel& level, const double break_price);
    
    //--- Trend Analysis Implementation ---
    ENUM_TREND_DIRECTION  AnalyzePrimaryTrend();
    ENUM_TREND_DIRECTION  AnalyzeSecondaryTrend();
    double                CalculateTrendStrength();
    double                CalculateTrendAngle();
    double                CalculateTrendVelocity();
    
    //--- Level Creation ---
    SStructureLevel       CreateLevel(const ENUM_STRUCTURE_TYPE type, const double price, const datetime time);
    void                  UpdateLevel(SStructureLevel& level, const double price, const datetime time);
    bool                  AddLevel(const SStructureLevel& level);
    bool                  RemoveLevel(const int index);
    
    //--- Level Management ---
    void                  UpdateLevelStatus();
    void                  CleanupOldLevels();
    void                  SortLevels();
    bool                  IsLevelNearby(const double price, const double tolerance);
    
    //--- Calculation Methods ---
    double                CalculateAverageRange(const int period);
    double                CalculateVolatility(const int period);
    double                CalculateMomentum(const int period);
    bool                  IsPriceAtLevel(const double price, const double level, const double tolerance);
    
    //--- Support Methods ---
    bool                  IsLocalHigh(const int index, const int lookback);
    bool                  IsLocalLow(const int index, const int lookback);
    int                   CountTouches(const double level, const double tolerance, const int lookback);
    double                GetMaxDeviation(const double level, const int start_index, const int end_index);
    
    //--- Utility Methods ---
    bool                  IsValidIndex(const int index);
    bool                  IsValidPrice(const double price);
    int                   GetBarIndex(const datetime time);
    datetime              GetBarTime(const int index);
    void                  LogStructureEvent(const string& event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO);
    
    //--- Array Management ---
    void                  ResizeLevelArray(const int new_size);
    void                  ResizeSwingArray(const int new_size);
    void                  AddLevelToArray(const SStructureLevel& level);
    void                  AddSwingToArray(const SSwingPoint& swing);
};

// Static constants definition
const int CStructure::MAX_LEVELS = 200;
const int CStructure::MAX_SWINGS = 100;
const double CStructure::STRUCTURE_TOLERANCE = 0.0001;

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CStructure::CStructure(EAContext* context) {
    m_pContext = context;
    m_bInitialized = false;
    m_Symbol = "";
    m_Timeframe = PERIOD_CURRENT;
    m_LevelCount = 0;
    m_SwingCount = 0;
    m_DataCount = 0;
    m_LastUpdate = 0;
    m_LastScan = 0;
    m_StructureChanged = false;
    
    // Initialize structures
    ZeroMemory(m_Config);
    ZeroMemory(m_Structure);
    ZeroMemory(m_Stats);
    
    // Set default configuration
    m_Config.LookbackPeriod = 500;
    m_Config.SwingLookback = 10;
    m_Config.MinSwingSize = 100; // points
    m_Config.LevelTolerance = 20; // points
    m_Config.DetectSupport = true;
    m_Config.DetectResistance = true;
    m_Config.DetectTrendLines = true;
    m_Config.DetectChannels = true;
    m_Config.DetectSwings = true;
    m_Config.DetectBreaks = true;
    m_Config.UseOrderBlocks = false;
    m_Config.UseFairValueGaps = false;
    m_Config.UseLiquidityPools = false;
    m_Config.UseInstitutional = false;
    m_Config.MinTouchCount = 2;
    m_Config.MinSignificance = 50.0;
    m_Config.MinReliability = 60.0;
    m_Config.UseTimeFilter = false;
    m_Config.UseVolumeFilter = false;
    m_Config.ShowLevels = true;
    m_Config.ShowSwings = true;
    m_Config.ShowBreaks = true;
    m_Config.ShowLabels = true;
    m_Config.MaxLevels = 50;
    m_Config.RealTimeUpdate = true;
    m_Config.HistoricalScan = true;
    m_Config.UpdateFrequency = 60; // 1 minute
    m_Config.AutoCleanup = true;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CStructure::~CStructure() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CStructure::Initialize(const string& symbol, const ENUM_TIMEFRAMES timeframe, const SStructureConfig& config) {
    if (m_bInitialized) {
        return true;
    }
    
    if (m_pContext == NULL) {
        Print("[STRUCTURE] Context is NULL");
        return false;
    }
    
    m_Symbol = symbol;
    m_Timeframe = timeframe;
    m_Config = config;
    
    // Validate configuration
    if (m_Config.LookbackPeriod < 100) {
        m_Config.LookbackPeriod = 500;
    }
    
    if (m_Config.SwingLookback < 5) {
        m_Config.SwingLookback = 10;
    }
    
    if (m_Config.MaxLevels > MAX_LEVELS) {
        m_Config.MaxLevels = MAX_LEVELS;
    }
    
    // Initialize arrays
    ArrayResize(m_Levels, MAX_LEVELS);
    ArrayResize(m_Swings, MAX_SWINGS);
    
    // Load initial market data
    if (!LoadMarketData()) {
        LogStructureEvent("Failed to load market data", LOG_LEVEL_ERROR);
        return false;
    }
    
    // Perform initial structure analysis
    if (m_Config.HistoricalScan) {
        AnalyzeStructure();
        UpdateStatistics();
    }
    
    m_bInitialized = true;
    
    if (m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo("Structure analysis initialized for: " + symbol, __FUNCTION__);
        m_pContext->pLogger->LogInfo(GetStructureSummary(), __FUNCTION__);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CStructure::Deinitialize() {
    if (!m_bInitialized) {
        return;
    }
    
    if (m_pContext != NULL && m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo(GetStatisticsSummary(), __FUNCTION__);
        m_pContext->pLogger->LogInfo("Structure analysis shutting down", __FUNCTION__);
    }
    
    m_bInitialized = false;
}

//+------------------------------------------------------------------+
//| Update                                                           |
//+------------------------------------------------------------------+
void CStructure::Update() {
    if (!m_bInitialized) {
        return;
    }
    
    datetime current_time = TimeCurrent();
    
    // Real-time structure analysis
    if (m_Config.RealTimeUpdate) {
        UpdateMarketData();
        
        // Update level status
        UpdateLevelStatus();
        
        // Check for structure breaks
        if (DetectStructureBreaks()) {
            m_StructureChanged = true;
            UpdateTrendDirection();
        }
        
        // Full structure analysis every few minutes
        if (current_time - m_LastScan >= m_Config.UpdateFrequency) {
            if (AnalyzeStructure()) {
                m_StructureChanged = true;
                UpdateStatistics();
            }
            m_LastScan = current_time;
        }
    }
    
    // Cleanup old levels
    if (m_Config.AutoCleanup && current_time - m_LastUpdate >= 3600) { // Every hour
        CleanupOldLevels();
        UpdateStatistics();
        m_LastUpdate = current_time;
    }
}

//+------------------------------------------------------------------+
//| Analyze Structure                                                |
//+------------------------------------------------------------------+
bool CStructure::AnalyzeStructure() {
    if (m_DataCount < m_Config.SwingLookback * 2) {
        return false;
    }
    
    bool structure_found = false;
    
    // Detect structure levels
    if (DetectStructureLevels()) {
        structure_found = true;
    }
    
    // Detect swing points
    if (DetectSwingPoints()) {
        structure_found = true;
    }
    
    // Update trend direction
    if (UpdateTrendDirection()) {
        structure_found = true;
    }
    
    // Detect structure breaks
    if (DetectStructureBreaks()) {
        structure_found = true;
    }
    
    if (structure_found) {
        SortLevels();
        LogStructureEvent(StringFormat("Structure analysis completed. Found %d levels, %d swings", 
                                      m_LevelCount, m_SwingCount));
    }
    
    return structure_found;
}

//+------------------------------------------------------------------+
//| Detect Structure Levels                                          |
//+------------------------------------------------------------------+
bool CStructure::DetectStructureLevels() {
    bool levels_found = false;
    
    // Find support and resistance levels
    if (m_Config.DetectSupport || m_Config.DetectResistance) {
        if (FindSupportResistance()) {
            levels_found = true;
        }
    }
    
    // Find trend lines
    if (m_Config.DetectTrendLines) {
        if (FindTrendLines()) {
            levels_found = true;
        }
    }
    
    // Find channels
    if (m_Config.DetectChannels) {
        if (FindChannels()) {
            levels_found = true;
        }
    }
    
    // Find pivot points
    if (FindPivotPoints()) {
        levels_found = true;
    }
    
    return levels_found;
}

//+------------------------------------------------------------------+
//| Detect Swing Points                                              |
//+------------------------------------------------------------------+
bool CStructure::DetectSwingPoints() {
    bool swings_found = false;
    
    // Find swing highs
    if (FindSwingHighs()) {
        swings_found = true;
    }
    
    // Find swing lows
    if (FindSwingLows()) {
        swings_found = true;
    }
    
    return swings_found;
}

//+------------------------------------------------------------------+
//| Update Trend Direction                                           |
//+------------------------------------------------------------------+
bool CStructure::UpdateTrendDirection() {
    ENUM_TREND_DIRECTION old_primary = m_Structure.PrimaryTrend;
    ENUM_TREND_DIRECTION old_secondary = m_Structure.SecondaryTrend;
    
    // Analyze primary trend
    m_Structure.PrimaryTrend = AnalyzePrimaryTrend();
    
    // Analyze secondary trend
    m_Structure.SecondaryTrend = AnalyzeSecondaryTrend();
    
    // Calculate trend metrics
    m_Structure.TrendStrength = CalculateTrendStrength();
    m_Structure.TrendAngle = CalculateTrendAngle();
    m_Structure.TrendVelocity = CalculateTrendVelocity();
    
    // Update market character
    m_Structure.IsImpulsive = (m_Structure.TrendStrength > 70.0);
    m_Structure.IsCorrective = (m_Structure.TrendStrength < 30.0);
    m_Structure.IsConsolidating = (m_Structure.PrimaryTrend == TREND_SIDEWAYS);
    m_Structure.IsBreakingOut = (m_Structure.HighBroken || m_Structure.LowBroken);
    
    // Check for trend changes
    bool trend_changed = (old_primary != m_Structure.PrimaryTrend || 
                         old_secondary != m_Structure.SecondaryTrend);
    
    if (trend_changed) {
        m_Stats.TrendChanges++;
        LogStructureEvent(StringFormat("Trend changed: %s -> %s", 
                                      EnumToString(old_primary), 
                                      EnumToString(m_Structure.PrimaryTrend)));
    }
    
    return trend_changed;
}

//+------------------------------------------------------------------+
//| Is Bullish Structure                                             |
//+------------------------------------------------------------------+
bool CStructure::IsBullishStructure() {
    return (m_Structure.PrimaryTrend == TREND_BULLISH || 
            m_Structure.PrimaryTrend == TREND_BREAKOUT_BULL || 
            m_Structure.PrimaryTrend == TREND_REVERSAL_BULL);
}

//+------------------------------------------------------------------+
//| Is Bearish Structure                                             |
//+------------------------------------------------------------------+
bool CStructure::IsBearishStructure() {
    return (m_Structure.PrimaryTrend == TREND_BEARISH || 
            m_Structure.PrimaryTrend == TREND_BREAKOUT_BEAR || 
            m_Structure.PrimaryTrend == TREND_REVERSAL_BEAR);
}

//+------------------------------------------------------------------+
//| Is Sideways Structure                                            |
//+------------------------------------------------------------------+
bool CStructure::IsSidewaysStructure() {
    return (m_Structure.PrimaryTrend == TREND_SIDEWAYS || 
            m_Structure.PrimaryTrend == TREND_CONSOLIDATION);
}

//+------------------------------------------------------------------+
//| Is Higher High                                                   |
//+------------------------------------------------------------------+
bool CStructure::IsHigherHigh(const double price) {
    return (price > m_Structure.CurrentHigh && 
            m_Structure.CurrentHigh > m_Structure.PreviousHigh);
}

//+------------------------------------------------------------------+
//| Is Higher Low                                                    |
//+------------------------------------------------------------------+
bool CStructure::IsHigherLow(const double price) {
    return (price > m_Structure.CurrentLow && 
            m_Structure.CurrentLow > m_Structure.PreviousLow);
}

//+------------------------------------------------------------------+
//| Is Lower High                                                    |
//+------------------------------------------------------------------+
bool CStructure::IsLowerHigh(const double price) {
    return (price < m_Structure.CurrentHigh && 
            m_Structure.CurrentHigh < m_Structure.PreviousHigh);
}

//+------------------------------------------------------------------+
//| Is Lower Low                                                     |
//+------------------------------------------------------------------+
bool CStructure::IsLowerLow(const double price) {
    return (price < m_Structure.CurrentLow && 
            m_Structure.CurrentLow < m_Structure.PreviousLow);
}

//+------------------------------------------------------------------+
//| Get Nearest Support                                              |
//+------------------------------------------------------------------+
double CStructure::GetNearestSupport(const double price) {
    double nearest_support = 0;
    double min_distance = DBL_MAX;
    
    for (int i = 0; i < m_LevelCount; i++) {
        if (m_Levels[i].Type == STRUCTURE_SUPPORT && 
            m_Levels[i].IsActive && 
            m_Levels[i].Price < price) {
            
            double distance = price - m_Levels[i].Price;
            if (distance < min_distance) {
                min_distance = distance;
                nearest_support = m_Levels[i].Price;
            }
        }
    }
    
    return nearest_support;
}

//+------------------------------------------------------------------+
//| Get Nearest Resistance                                           |
//+------------------------------------------------------------------+
double CStructure::GetNearestResistance(const double price) {
    double nearest_resistance = 0;
    double min_distance = DBL_MAX;
    
    for (int i = 0; i < m_LevelCount; i++) {
        if (m_Levels[i].Type == STRUCTURE_RESISTANCE && 
            m_Levels[i].IsActive && 
            m_Levels[i].Price > price) {
            
            double distance = m_Levels[i].Price - price;
            if (distance < min_distance) {
                min_distance = distance;
                nearest_resistance = m_Levels[i].Price;
            }
        }
    }
    
    return nearest_resistance;
}

//+------------------------------------------------------------------+
//| Get Structure Summary                                            |
//+------------------------------------------------------------------+
string CStructure::GetStructureSummary() {
    string summary = "=== MARKET STRUCTURE ===\n";
    summary += StringFormat("Symbol: %s\n", m_Symbol);
    summary += StringFormat("Timeframe: %s\n", EnumToString(m_Timeframe));
    summary += StringFormat("Primary Trend: %s\n", EnumToString(m_Structure.PrimaryTrend));
    summary += StringFormat("Secondary Trend: %s\n", EnumToString(m_Structure.SecondaryTrend));
    summary += StringFormat("Trend Strength: %.1f%%\n", m_Structure.TrendStrength);
    summary += StringFormat("Trend Angle: %.1f°\n", m_Structure.TrendAngle);
    summary += StringFormat("Current High: %.5f\n", m_Structure.CurrentHigh);
    summary += StringFormat("Current Low: %.5f\n", m_Structure.CurrentLow);
    summary += StringFormat("Structure Levels: %d\n", m_Stats.ActiveLevels);
    summary += StringFormat("Swing Points: %d\n", m_SwingCount);
    summary += StringFormat("High Broken: %s\n", m_Structure.HighBroken ? "Yes" : "No");
    summary += StringFormat("Low Broken: %s\n", m_Structure.LowBroken ? "Yes" : "No");
    
    return summary;
}

//+------------------------------------------------------------------+
//| Internal Methods                                                 |
//+------------------------------------------------------------------+
bool CStructure::LoadMarketData() {
    if (m_Symbol == "") {
        return false;
    }
    
    // Load OHLC and volume data
    double high_prices[], low_prices[], open_prices[], close_prices[];
    long volumes[];
    datetime times[];
    
    int copied_high = CopyHigh(m_Symbol, m_Timeframe, 0, m_Config.LookbackPeriod, high_prices);
    int copied_low = CopyLow(m_Symbol, m_Timeframe, 0, m_Config.LookbackPeriod, low_prices);
    int copied_open = CopyOpen(m_Symbol, m_Timeframe, 0, m_Config.LookbackPeriod, open_prices);
    int copied_close = CopyClose(m_Symbol, m_Timeframe, 0, m_Config.LookbackPeriod, close_prices);
    int copied_volumes = CopyTickVolume(m_Symbol, m_Timeframe, 0, m_Config.LookbackPeriod, volumes);
    int copied_times = CopyTime(m_Symbol, m_Timeframe, 0, m_Config.LookbackPeriod, times);
    
    if (copied_high < m_Config.SwingLookback * 2 || 
        copied_low < m_Config.SwingLookback * 2 || 
        copied_open < m_Config.SwingLookback * 2 || 
        copied_close < m_Config.SwingLookback * 2) {
        LogStructureEvent("Insufficient market data loaded", LOG_LEVEL_ERROR);
        return false;
    }
    
    // Store data
    m_DataCount = copied_high;
    ArrayResize(m_HighData, m_DataCount);
    ArrayResize(m_LowData, m_DataCount);
    ArrayResize(m_OpenData, m_DataCount);
    ArrayResize(m_CloseData, m_DataCount);
    ArrayResize(m_VolumeData, m_DataCount);
    ArrayResize(m_TimeData, m_DataCount);
    
    ArrayCopy(m_HighData, high_prices);
    ArrayCopy(m_LowData, low_prices);
    ArrayCopy(m_OpenData, open_prices);
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

bool CStructure::FindSupportResistance() {
    if (m_DataCount < 50) {
        return false;
    }
    
    bool levels_found = false;
    double point = SymbolInfoDouble(m_Symbol, SYMBOL_POINT);
    double tolerance = m_Config.LevelTolerance * point;
    
    // Scan for potential support/resistance levels
    for (int i = m_Config.SwingLookback; i < m_DataCount - m_Config.SwingLookback; i++) {
        double high = m_HighData[i];
        double low = m_LowData[i];
        
        // Check for resistance level (local high)
        if (IsLocalHigh(i, m_Config.SwingLookback)) {
            // Count touches of this level
            int touch_count = CountTouches(high, tolerance, m_Config.LookbackPeriod);
            
            if (touch_count >= m_Config.MinTouchCount) {
                // Check if level already exists
                if (!IsLevelNearby(high, tolerance)) {
                    SStructureLevel level = CreateLevel(STRUCTURE_RESISTANCE, high, m_TimeData[i]);
                    level.TouchCount = touch_count;
                    level.Significance = CalculateLevelSignificance(level);
                    level.Reliability = CalculateLevelStrength(level);
                    level.Strength = DetermineStrength(touch_count);
                    
                    if (ValidateLevel(level)) {
                        AddLevel(level);
                        levels_found = true;
                    }
                }
            }
        }
        
        // Check for support level (local low)
        if (IsLocalLow(i, m_Config.SwingLookback)) {
            // Count touches of this level
            int touch_count = CountTouches(low, tolerance, m_Config.LookbackPeriod);
            
            if (touch_count >= m_Config.MinTouchCount) {
                // Check if level already exists
                if (!IsLevelNearby(low, tolerance)) {
                    SStructureLevel level = CreateLevel(STRUCTURE_SUPPORT, low, m_TimeData[i]);
                    level.TouchCount = touch_count;
                    level.Significance = CalculateLevelSignificance(level);
                    level.Reliability = CalculateLevelStrength(level);
                    level.Strength = DetermineStrength(touch_count);
                    
                    if (ValidateLevel(level)) {
                        AddLevel(level);
                        levels_found = true;
                    }
                }
            }
        }
    }
    
    return levels_found;
}

bool CStructure::FindSwingHighs() {
    bool swings_found = false;
    
    for (int i = m_Config.SwingLookback; i < m_DataCount - m_Config.SwingLookback; i++) {
        if (IsLocalHigh(i, m_Config.SwingLookback)) {
            SSwingPoint swing = CreateSwing(STRUCTURE_SWING_HIGH, m_HighData[i], m_TimeData[i], i);
            swing.LookbackLeft = m_Config.SwingLookback;
            swing.LookbackRight = m_Config.SwingLookback;
            swing.Strength = CalculateLevelStrength(CreateLevel(STRUCTURE_SWING_HIGH, swing.Price, swing.Time));
            swing.IsConfirmed = true;
            
            if (ValidateSwing(swing)) {
                AddSwingToArray(swing);
                swings_found = true;
            }
        }
    }
    
    return swings_found;
}

bool CStructure::FindSwingLows() {
    bool swings_found = false;
    
    for (int i = m_Config.SwingLookback; i < m_DataCount - m_Config.SwingLookback; i++) {
        if (IsLocalLow(i, m_Config.SwingLookback)) {
            SSwingPoint swing = CreateSwing(STRUCTURE_SWING_LOW, m_LowData[i], m_TimeData[i], i);
            swing.LookbackLeft = m_Config.SwingLookback;
            swing.LookbackRight = m_Config.SwingLookback;
            swing.Strength = CalculateLevelStrength(CreateLevel(STRUCTURE_SWING_LOW, swing.Price, swing.Time));
            swing.IsConfirmed = true;
            
            if (ValidateSwing(swing)) {
                AddSwingToArray(swing);
                swings_found = true;
            }
        }
    }
    
    return swings_found;
}

ENUM_TREND_DIRECTION CStructure::AnalyzePrimaryTrend() {
    if (m_SwingCount < 4) {
        return TREND_UNDEFINED;
    }
    
    // Get recent swing points
    SSwingPoint recent_swings[10];
    int swing_count = 0;
    
    // Collect recent swings (last 10)
    for (int i = MathMax(0, m_SwingCount - 10); i < m_SwingCount; i++) {
        recent_swings[swing_count] = m_Swings[i];
        swing_count++;
    }
    
    if (swing_count < 4) {
        return TREND_UNDEFINED;
    }
    
    // Analyze swing pattern
    int higher_highs = 0;
    int higher_lows = 0;
    int lower_highs = 0;
    int lower_lows = 0;
    
    for (int i = 1; i < swing_count; i++) {
        if (recent_swings[i].Type == STRUCTURE_SWING_HIGH) {
            // Find previous high
            for (int j = i - 1; j >= 0; j--) {
                if (recent_swings[j].Type == STRUCTURE_SWING_HIGH) {
                    if (recent_swings[i].Price > recent_swings[j].Price) {
                        higher_highs++;
                    } else {
                        lower_highs++;
                    }
                    break;
                }
            }
        } else if (recent_swings[i].Type == STRUCTURE_SWING_LOW) {
            // Find previous low
            for (int j = i - 1; j >= 0; j--) {
                if (recent_swings[j].Type == STRUCTURE_SWING_LOW) {
                    if (recent_swings[i].Price > recent_swings[j].Price) {
                        higher_lows++;
                    } else {
                        lower_lows++;
                    }
                    break;
                }
            }
        }
    }
    
    // Determine trend based on swing analysis
    if (higher_highs > lower_highs && higher_lows > lower_lows) {
        return TREND_BULLISH;
    } else if (lower_highs > higher_highs && lower_lows > higher_lows) {
        return TREND_BEARISH;
    } else {
        return TREND_SIDEWAYS;
    }
}

SStructureLevel CStructure::CreateLevel(const ENUM_STRUCTURE_TYPE type, const double price, const datetime time) {
    SStructureLevel level;
    ZeroMemory(level);
    
    level.Type = type;
    level.Strength = STRENGTH_WEAK;
    level.Status = STATUS_ACTIVE;
    level.BreakType = BREAK_NONE;
    level.Price = price;
    level.FirstTouch = time;
    level.LastTouch = time;
    level.TouchCount = 1;
    level.BarsSinceTouch = 0;
    level.BarsSinceBreak = 0;
    level.MaxDeviation = 0;
    level.AverageDeviation = 0;
    level.Significance = 50.0;
    level.Reliability = 50.0;
    level.IsActive = true;
    level.IsBroken = false;
    level.IsRetested = false;
    level.IsInstitutional = false;
    level.TouchHistoryCount = 0;
    
    return level;
}

SSwingPoint CStructure::CreateSwing(const ENUM_STRUCTURE_TYPE type, const double price, const datetime time, const int index) {
    SSwingPoint swing;
    ZeroMemory(swing);
    
    swing.Type = type;
    swing.Price = price;
    swing.Time = time;
    swing.BarIndex = index;
    swing.Strength = 50.0;
    swing.Significance = 50.0;
    swing.LookbackLeft = m_Config.SwingLookback;
    swing.LookbackRight = m_Config.SwingLookback;
    swing.IsConfirmed = false;
    swing.IsBroken = false;
    swing.IsRetested = false;
    swing.Label = EnumToString(type);
    
    return swing;
}

bool CStructure::ValidateLevel(const SStructureLevel& level) {
    // Basic validation
    if (!IsValidPrice(level.Price)) {
        return false;
    }
    
    if (level.TouchCount < m_Config.MinTouchCount) {
        return false;
    }
    
    if (level.Significance < m_Config.MinSignificance) {
        return false;
    }
    
    if (level.Reliability < m_Config.MinReliability) {
        return false;
    }
    
    return true;
}

bool CStructure::ValidateSwing(const SSwingPoint& swing) {
    // Basic validation
    if (!IsValidPrice(swing.Price)) {
        return false;
    }
    
    double point = SymbolInfoDouble(m_Symbol, SYMBOL_POINT);
    double min_size = m_Config.MinSwingSize * point;
    
    // Check swing size (simplified)
    if (m_SwingCount > 0) {
        SSwingPoint last_swing = m_Swings[m_SwingCount - 1];
        double swing_size = MathAbs(swing.Price - last_swing.Price);
        if (swing_size < min_size) {
            return false;
        }
    }
    
    return true;
}

bool CStructure::IsLocalHigh(const int index, const int lookback) {
    if (!IsValidIndex(index) || index < lookback || index >= m_DataCount - lookback) {
        return false;
    }
    
    double current_high = m_HighData[index];
    
    // Check left side
    for (int i = index - lookback; i < index; i++) {
        if (m_HighData[i] >= current_high) {
            return false;
        }
    }
    
    // Check right side
    for (int i = index + 1; i <= index + lookback; i++) {
        if (m_HighData[i] >= current_high) {
            return false;
        }
    }
    
    return true;
}

bool CStructure::IsLocalLow(const int index, const int lookback) {
    if (!IsValidIndex(index) || index < lookback || index >= m_DataCount - lookback) {
        return false;
    }
    
    double current_low = m_LowData[index];
    
    // Check left side
    for (int i = index - lookback; i < index; i++) {
        if (m_LowData[i] <= current_low) {
            return false;
        }
    }
    
    // Check right side
    for (int i = index + 1; i <= index + lookback; i++) {
        if (m_LowData[i] <= current_low) {
            return false;
        }
    }
    
    return true;
}

int CStructure::CountTouches(const double level, const double tolerance, const int lookback) {
    int touches = 0;
    int start_index = MathMax(0, m_DataCount - lookback);
    
    for (int i = start_index; i < m_DataCount; i++) {
        if (IsPriceAtLevel(m_HighData[i], level, tolerance) || 
            IsPriceAtLevel(m_LowData[i], level, tolerance)) {
            touches++;
        }
    }
    
    return touches;
}

bool CStructure::IsPriceAtLevel(const double price, const double level, const double tolerance) {
    return (MathAbs(price - level) <= tolerance);
}

bool CStructure::IsLevelNearby(const double price, const double tolerance) {
    for (int i = 0; i < m_LevelCount; i++) {
        if (IsPriceAtLevel(price, m_Levels[i].Price, tolerance)) {
            return true;
        }
    }
    return false;
}

double CStructure::CalculateLevelStrength(const SStructureLevel& level) {
    double strength = 0;
    
    // Base strength from touch count
    strength += level.TouchCount * 10.0;
    
    // Bonus for age
    int age_bars = (int)((TimeCurrent() - level.FirstTouch) / PeriodSeconds(m_Timeframe));
    strength += MathMin(age_bars / 100.0, 20.0);
    
    // Penalty for deviation
    if (level.MaxDeviation > 0) {
        double deviation_penalty = (level.MaxDeviation / level.Price) * 100.0;
        strength -= deviation_penalty;
    }
    
    return MathMax(0, MathMin(100, strength));
}

double CStructure::CalculateLevelSignificance(const SStructureLevel& level) {
    double significance = 50.0; // Base significance
    
    // Increase based on touch count
    significance += (level.TouchCount - 1) * 15.0;
    
    // Increase based on time span
    int time_span = (int)((level.LastTouch - level.FirstTouch) / PeriodSeconds(m_Timeframe));
    significance += MathMin(time_span / 50.0, 25.0);
    
    return MathMax(0, MathMin(100, significance));
}

ENUM_STRUCTURE_STRENGTH CStructure::DetermineStrength(const int touch_count) {
    if (touch_count >= 8) {
        return STRENGTH_VERY_STRONG;
    } else if (touch_count >= 5) {
        return STRENGTH_STRONG;
    } else if (touch_count >= 3) {
        return STRENGTH_MODERATE;
    } else {
        return STRENGTH_WEAK;
    }
}

bool CStructure::AddLevel(const SStructureLevel& level) {
    if (m_LevelCount >= ArraySize(m_Levels)) {
        // Remove weakest level if array is full
        int weakest_index = 0;
        double weakest_strength = m_Levels[0].Reliability;
        
        for (int i = 1; i < m_LevelCount; i++) {
            if (m_Levels[i].Reliability < weakest_strength) {
                weakest_strength = m_Levels[i].Reliability;
                weakest_index = i;
            }
        }
        
        // Remove weakest level
        for (int i = weakest_index; i < m_LevelCount - 1; i++) {
            m_Levels[i] = m_Levels[i + 1];
        }
        m_LevelCount