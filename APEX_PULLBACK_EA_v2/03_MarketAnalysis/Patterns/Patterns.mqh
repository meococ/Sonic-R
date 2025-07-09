//+------------------------------------------------------------------+
//|                                                     Patterns.mqh |
//|                     Patterns.mqh - APEX Pullback EA v5 FINAL   |
//|      Description: Advanced Pattern Detection & Recognition      |
//|                   Ported from v14 with enhanced capabilities    |
//+------------------------------------------------------------------+

#ifndef PATTERNS_MQH_
#define PATTERNS_MQH_

#include "..\..\00_Core\CommonStructs.mqh"

namespace ApexPullback::v5 {

//+------------------------------------------------------------------+
//| Pattern Detection Enumerations                                  |
//+------------------------------------------------------------------+
enum ENUM_PATTERN_TYPE {
    PATTERN_NONE,                   // No pattern detected
    PATTERN_BULLISH_PULLBACK,       // Bullish pullback pattern
    PATTERN_BEARISH_PULLBACK,       // Bearish pullback pattern
    PATTERN_FIBONACCI_PULLBACK,     // Fibonacci-based pullback
    PATTERN_STRONG_PULLBACK,        // Strong pullback pattern
    PATTERN_BULLISH_REVERSAL,       // Bullish reversal pattern
    PATTERN_BEARISH_REVERSAL,       // Bearish reversal pattern
    PATTERN_DOUBLE_TOP,             // Double top pattern
    PATTERN_DOUBLE_BOTTOM,          // Double bottom pattern
    PATTERN_HEAD_SHOULDERS,         // Head and shoulders
    PATTERN_INVERSE_HEAD_SHOULDERS, // Inverse head and shoulders
    PATTERN_ASCENDING_TRIANGLE,     // Ascending triangle
    PATTERN_DESCENDING_TRIANGLE,    // Descending triangle
    PATTERN_SYMMETRIC_TRIANGLE,     // Symmetric triangle
    PATTERN_FLAG_BULLISH,           // Bullish flag
    PATTERN_FLAG_BEARISH,           // Bearish flag
    PATTERN_PENNANT_BULLISH,        // Bullish pennant
    PATTERN_PENNANT_BEARISH,        // Bearish pennant
    PATTERN_WEDGE_RISING,           // Rising wedge
    PATTERN_WEDGE_FALLING,          // Falling wedge
    PATTERN_CHANNEL_BULLISH,        // Bullish channel
    PATTERN_CHANNEL_BEARISH,        // Bearish channel
    PATTERN_GARTLEY_BULLISH,        // Bullish Gartley
    PATTERN_GARTLEY_BEARISH,        // Bearish Gartley
    PATTERN_BUTTERFLY_BULLISH,      // Bullish Butterfly
    PATTERN_BUTTERFLY_BEARISH,      // Bearish Butterfly
    PATTERN_BAT_BULLISH,            // Bullish Bat
    PATTERN_BAT_BEARISH,            // Bearish Bat
    PATTERN_CRAB_BULLISH,           // Bullish Crab
    PATTERN_CRAB_BEARISH,           // Bearish Crab
    PATTERN_SHARK_BULLISH,          // Bullish Shark
    PATTERN_SHARK_BEARISH,          // Bearish Shark
    PATTERN_CYPHER_BULLISH,         // Bullish Cypher
    PATTERN_CYPHER_BEARISH,         // Bearish Cypher
    PATTERN_ABCD_BULLISH,           // Bullish ABCD
    PATTERN_ABCD_BEARISH,           // Bearish ABCD
    PATTERN_ENGULFING_BULLISH,      // Bullish engulfing
    PATTERN_ENGULFING_BEARISH,      // Bearish engulfing
    PATTERN_HAMMER,                 // Hammer pattern
    PATTERN_HANGING_MAN,            // Hanging man pattern
    PATTERN_DOJI,                   // Doji pattern
    PATTERN_SHOOTING_STAR,          // Shooting star
    PATTERN_MORNING_STAR,           // Morning star
    PATTERN_EVENING_STAR,           // Evening star
    PATTERN_INSIDE_BAR,             // Inside bar
    PATTERN_OUTSIDE_BAR,            // Outside bar (engulfing)
    PATTERN_PIN_BAR_BULLISH,        // Bullish pin bar
    PATTERN_PIN_BAR_BEARISH,        // Bearish pin bar
    PATTERN_MOMENTUM_SHIFT,         // Momentum shift pattern
    PATTERN_VOLUME_CLIMAX,          // Volume climax pattern
    PATTERN_BREAKOUT_BULLISH,       // Bullish breakout
    PATTERN_BREAKOUT_BEARISH,       // Bearish breakout
    PATTERN_FALSE_BREAKOUT,         // False breakout pattern
    PATTERN_RANGE_REVERSAL,         // Range reversal pattern
    PATTERN_TREND_CONTINUATION,     // Trend continuation pattern
    PATTERN_CUSTOM                  // Custom pattern
};

enum ENUM_PATTERN_TIMEFRAME {
    PATTERN_TF_CURRENT,             // Current timeframe
    PATTERN_TF_HIGHER,              // Higher timeframe
    PATTERN_TF_LOWER,               // Lower timeframe
    PATTERN_TF_MULTI,               // Multiple timeframes
    PATTERN_TF_ALL                  // All timeframes
};

enum ENUM_PATTERN_QUALITY {
    PATTERN_QUALITY_POOR,           // Poor quality pattern
    PATTERN_QUALITY_FAIR,           // Fair quality pattern
    PATTERN_QUALITY_GOOD,           // Good quality pattern
    PATTERN_QUALITY_EXCELLENT,      // Excellent quality pattern
    PATTERN_QUALITY_PERFECT         // Perfect quality pattern
};

enum ENUM_PATTERN_STATUS {
    PATTERN_STATUS_FORMING,         // Pattern is forming
    PATTERN_STATUS_COMPLETE,        // Pattern is complete
    PATTERN_STATUS_TRIGGERED,       // Pattern has been triggered
    PATTERN_STATUS_FAILED,          // Pattern has failed
    PATTERN_STATUS_EXPIRED          // Pattern has expired
};

//+------------------------------------------------------------------+
//| Pattern Detection Structures                                    |
//+------------------------------------------------------------------+
struct SPatternPoint {
    datetime              Time;                 // Point time
    double                Price;                // Price level
    int                   BarIndex;             // Bar index
    bool                  IsHigh;               // Is swing high
    bool                  IsLow;                // Is swing low
    double                Volume;               // Volume at point
    string                Label;                // Point label (X, A, B, C, D)
};

struct SDetectedPattern {
    ENUM_PATTERN_TYPE     Type;                 // Pattern type
    ENUM_PATTERN_QUALITY  Quality;              // Pattern quality
    ENUM_PATTERN_STATUS   Status;               // Pattern status
    ENUM_PATTERN_TIMEFRAME Timeframe;           // Detection timeframe
    
    // Pattern identification
    string                Name;                 // Pattern name
    string                Description;          // Pattern description
    datetime              DetectionTime;        // When pattern was detected
    datetime              FormationStart;       // Pattern formation start
    datetime              FormationEnd;         // Pattern formation end
    
    // Pattern geometry
    SPatternPoint         Points[];             // Pattern points (X, A, B, C, D)
    int                   PointCount;           // Number of points
    double                PatternHeight;        // Pattern height
    double                PatternWidth;         // Pattern width (in bars)
    
    // Entry & Exit Levels
    double                EntryLevel;           // Entry price level
    double                StopLoss;             // Stop loss level
    double                TakeProfit1;          // First take profit
    double                TakeProfit2;          // Second take profit
    double                TakeProfit3;          // Third take profit
    
    // Risk & Reward
    double                RiskRewardRatio;      // Risk to reward ratio
    double                RiskAmount;           // Risk amount in points
    double                RewardPotential;      // Reward potential in points
    double                ProbabilityOfSuccess; // Success probability (0-1)
    
    // Pattern metrics
    double                Strength;             // Pattern strength (0-1)
    double                Reliability;          // Pattern reliability (0-1)
    double                Confidence;           // Detection confidence (0-1)
    double                FibonacciLevel;       // Fibonacci retracement level
    double                VolatilityFactor;     // Volatility impact factor
    
    // Validation metrics
    bool                  IsValid;              // Pattern is valid
    bool                  IsConfirmed;          // Pattern is confirmed
    bool                  HasVolumeConfirmation; // Volume confirmation
    bool                  HasMomentumConfirmation; // Momentum confirmation
    bool                  HasStructureConfirmation; // Structure confirmation
    
    // Trading context
    bool                  IsBullish;            // Bullish pattern
    bool                  IsBearish;            // Bearish pattern
    bool                  IsReversalPattern;    // Reversal pattern
    bool                  IsContinuationPattern; // Continuation pattern
    bool                  IsBreakoutPattern;    // Breakout pattern
    
    // Timing
    int                   BarsToComplete;       // Bars to pattern completion
    int                   BarsSinceFormation;   // Bars since formation
    datetime              ExpirationTime;       // Pattern expiration time
    
    // Additional data
    string                Tags[];               // Pattern tags
    double                CustomData[];         // Custom data array
    string                Notes;                // Additional notes
};

struct SPatternFilter {
    // Quality filters
    ENUM_PATTERN_QUALITY  MinQuality;           // Minimum quality required
    double                MinStrength;          // Minimum strength (0-1)
    double                MinReliability;       // Minimum reliability (0-1)
    double                MinConfidence;        // Minimum confidence (0-1)
    
    // Risk filters
    double                MaxRisk;              // Maximum risk in points
    double                MinRiskReward;        // Minimum risk-reward ratio
    double                MaxRiskPercent;       // Maximum risk percentage
    
    // Type filters
    ENUM_PATTERN_TYPE     AllowedTypes[];       // Allowed pattern types
    ENUM_PATTERN_TYPE     ExcludedTypes[];      // Excluded pattern types
    bool                  AllowReversals;       // Allow reversal patterns
    bool                  AllowContinuations;   // Allow continuation patterns
    bool                  AllowBreakouts;       // Allow breakout patterns
    
    // Timeframe filters
    ENUM_PATTERN_TIMEFRAME PreferredTimeframe; // Preferred timeframe
    bool                  RequireMultiTF;       // Require multi-timeframe confirmation
    
    // Confirmation filters
    bool                  RequireVolumeConfirmation; // Require volume confirmation
    bool                  RequireMomentumConfirmation; // Require momentum confirmation
    bool                  RequireStructureConfirmation; // Require structure confirmation
    
    // Market condition filters
    bool                  FilterByTrend;        // Filter by market trend
    bool                  FilterByVolatility;   // Filter by volatility
    bool                  FilterBySession;      // Filter by trading session
    bool                  FilterByNews;         // Filter by news events
    
    // Time filters
    datetime              StartTime;            // Start time filter
    datetime              EndTime;              // End time filter
    bool                  AvoidNewsTime;        // Avoid news time
    
    // Advanced filters
    bool                  EnableMLValidation;   // Enable ML validation
    double                MLConfidenceThreshold; // ML confidence threshold
    bool                  UseCustomLogic;       // Use custom filter logic
};

struct SPatternStatistics {
    // Detection statistics
    int                   TotalPatternsDetected; // Total patterns detected
    int                   ValidPatterns;         // Valid patterns count
    int                   TriggeredPatterns;     // Triggered patterns count
    int                   SuccessfulPatterns;    // Successful patterns count
    int                   FailedPatterns;        // Failed patterns count
    
    // Success rates by type
    double                BullishSuccessRate;   // Bullish pattern success rate
    double                BearishSuccessRate;   // Bearish pattern success rate
    double                ReversalSuccessRate;  // Reversal pattern success rate
    double                ContinuationSuccessRate; // Continuation success rate
    double                BreakoutSuccessRate;  // Breakout pattern success rate
    
    // Performance metrics
    double                AverageRiskReward;    // Average risk-reward ratio
    double                AverageSuccess;       // Average success rate
    double                AverageReliability;   // Average reliability
    double                TotalProfit;          // Total profit from patterns
    double                TotalLoss;            // Total loss from patterns
    
    // Timing statistics
    double                AverageDetectionTime; // Average detection time
    double                AverageFormationTime; // Average formation time
    double                AverageHoldTime;      // Average holding time
    
    // Quality distribution
    int                   PoorQualityCount;     // Poor quality patterns
    int                   FairQualityCount;     // Fair quality patterns
    int                   GoodQualityCount;     // Good quality patterns
    int                   ExcellentQualityCount; // Excellent quality patterns
    int                   PerfectQualityCount;  // Perfect quality patterns
    
    // Last update
    datetime              LastUpdate;           // Last statistics update
    datetime              PeriodStart;          // Statistics period start
    datetime              PeriodEnd;            // Statistics period end
};

//+------------------------------------------------------------------+
//| Fibonacci Constants                                             |
//+------------------------------------------------------------------+
const double FIB_0_000 = 0.000;
const double FIB_0_236 = 0.236;
const double FIB_0_382 = 0.382;
const double FIB_0_500 = 0.500;
const double FIB_0_618 = 0.618;
const double FIB_0_786 = 0.786;
const double FIB_0_886 = 0.886;
const double FIB_1_000 = 1.000;
const double FIB_1_272 = 1.272;
const double FIB_1_414 = 1.414;
const double FIB_1_618 = 1.618;
const double FIB_2_000 = 2.000;
const double FIB_2_618 = 2.618;

//+------------------------------------------------------------------+
//| Harmonic Pattern Constants                                      |
//+------------------------------------------------------------------+
const double GARTLEY_B = 0.618;
const double GARTLEY_C = 0.382;
const double GARTLEY_D = 0.786;

const double BUTTERFLY_B = 0.786;
const double BUTTERFLY_C = 0.382;
const double BUTTERFLY_D = 1.618;

const double BAT_B = 0.382;
const double BAT_C = 0.382;
const double BAT_D = 0.886;

const double CRAB_B = 0.382;
const double CRAB_C = 0.618;
const double CRAB_D = 1.618;

const double SHARK_B = 0.382;
const double SHARK_C = 1.130;
const double SHARK_D = 1.618;

const double CYPHER_B = 0.382;
const double CYPHER_C = 1.272;
const double CYPHER_D = 0.786;

//+------------------------------------------------------------------+
//| CPatterns - Advanced Pattern Detection Engine                   |
//+------------------------------------------------------------------+
class CPatterns {
private:
    EAContext*            m_pContext;           // Reference to EA context
    bool                  m_bInitialized;      // Initialization status
    
    // Configuration
    SPatternFilter        m_Filter;             // Pattern filter configuration
    bool                  m_EnableRealTimeDetection; // Real-time detection
    bool                  m_EnableMultiTimeframe; // Multi-timeframe analysis
    bool                  m_EnableHarmonicPatterns; // Harmonic patterns
    bool                  m_EnableCandlestickPatterns; // Candlestick patterns
    
    // Pattern Storage
    SDetectedPattern      m_Patterns[];         // Detected patterns array
    int                   m_PatternCount;       // Number of patterns
    SDetectedPattern      m_ActivePattern;      // Currently active pattern
    bool                  m_HasActivePattern;   // Has active pattern flag
    
    // Statistics
    SPatternStatistics    m_Statistics;         // Pattern statistics
    datetime              m_LastStatisticsUpdate; // Last statistics update
    
    // Data Buffers
    double                m_High[];             // High prices buffer
    double                m_Low[];              // Low prices buffer
    double                m_Close[];            // Close prices buffer
    double                m_Open[];             // Open prices buffer
    long                  m_Volume[];           // Volume buffer
    datetime              m_Time[];             // Time buffer
    
    // Technical Indicators
    int                   m_ATRHandle;          // ATR indicator handle
    int                   m_RSIHandle;          // RSI indicator handle
    int                   m_MACDHandle;         // MACD indicator handle
    int                   m_BBHandle;           // Bollinger Bands handle
    
    double                m_ATRBuffer[];        // ATR values
    double                m_RSIBuffer[];        // RSI values
    double                m_MACDMainBuffer[];   // MACD main line
    double                m_MACDSignalBuffer[]; // MACD signal line
    double                m_BBUpperBuffer[];    // BB upper band
    double                m_BBLowerBuffer[];    // BB lower band
    double                m_BBMiddleBuffer[];   // BB middle band
    
    // Swing Points
    SPatternPoint         m_SwingHighs[];       // Recent swing highs
    SPatternPoint         m_SwingLows[];        // Recent swing lows
    int                   m_SwingHighCount;     // Number of swing highs
    int                   m_SwingLowCount;      // Number of swing lows
    
    // Detection Parameters
    int                   m_LookbackPeriod;     // Pattern lookback period
    int                   m_MinPatternBars;     // Minimum pattern bars
    int                   m_MaxPatternBars;     // Maximum pattern bars
    double                m_FibTolerance;       // Fibonacci tolerance
    double                m_PriceTolerancePercent; // Price tolerance percentage
    
    // Performance Tracking
    datetime              m_LastDetectionTime;  // Last detection time
    int                   m_DetectionCount;     // Total detections
    int                   m_ValidDetectionCount; // Valid detections
    double                m_AverageDetectionTime; // Average detection time
    
    // Memory Management
    int                   m_MaxPatterns;        // Maximum stored patterns
    bool                  m_MemoryOptimized;    // Memory optimization flag
    
public:
    //--- Constructor/Destructor ---
    CPatterns(EAContext* context);
    ~CPatterns();
    
    //--- Core Methods ---
    bool                  Initialize(const SPatternFilter& filter);
    void                  Deinitialize();
    bool                  IsInitialized() const { return m_bInitialized; }
    
    //--- Configuration ---
    bool                  SetFilter(const SPatternFilter& filter);
    SPatternFilter        GetFilter() const { return m_Filter; }
    void                  SetRealTimeDetection(bool enabled);
    void                  SetMultiTimeframeAnalysis(bool enabled);
    void                  SetHarmonicPatternsEnabled(bool enabled);
    void                  SetCandlestickPatternsEnabled(bool enabled);
    
    //--- Pattern Detection ---
    bool                  DetectPatterns();
    bool                  DetectPattern(ENUM_PATTERN_TYPE type, SDetectedPattern& pattern);
    SDetectedPattern      GetActivePattern();
    bool                  HasActivePattern() const { return m_HasActivePattern; }
    
    //--- Specific Pattern Detection ---
    bool                  DetectPullbackPatterns();
    bool                  DetectReversalPatterns();
    bool                  DetectHarmonicPatterns();
    bool                  DetectCandlestickPatterns();
    bool                  DetectBreakoutPatterns();
    bool                  DetectContinuationPatterns();
    
    //--- Pullback Patterns ---
    bool                  DetectBullishPullback(SDetectedPattern& pattern);
    bool                  DetectBearishPullback(SDetectedPattern& pattern);
    bool                  DetectFibonacciPullback(SDetectedPattern& pattern);
    bool                  DetectStrongPullback(SDetectedPattern& pattern);
    
    //--- Harmonic Patterns ---
    bool                  DetectGartleyPattern(SDetectedPattern& pattern);
    bool                  DetectButterflyPattern(SDetectedPattern& pattern);
    bool                  DetectBatPattern(SDetectedPattern& pattern);
    bool                  DetectCrabPattern(SDetectedPattern& pattern);
    bool                  DetectSharkPattern(SDetectedPattern& pattern);
    bool                  DetectCypherPattern(SDetectedPattern& pattern);
    bool                  DetectABCDPattern(SDetectedPattern& pattern);
    
    //--- Candlestick Patterns ---
    bool                  DetectEngulfingPattern(SDetectedPattern& pattern);
    bool                  DetectPinBarPattern(SDetectedPattern& pattern);
    bool                  DetectDojiPattern(SDetectedPattern& pattern);
    bool                  DetectHammerPattern(SDetectedPattern& pattern);
    bool                  DetectShootingStarPattern(SDetectedPattern& pattern);
    bool                  DetectInsideBarPattern(SDetectedPattern& pattern);
    bool                  DetectOutsideBarPattern(SDetectedPattern& pattern);
    
    //--- Pattern Validation ---
    bool                  ValidatePattern(SDetectedPattern& pattern);
    bool                  ValidateHarmonicRatios(const SDetectedPattern& pattern);
    bool                  ValidateVolumeConfirmation(const SDetectedPattern& pattern);
    bool                  ValidateMomentumConfirmation(const SDetectedPattern& pattern);
    bool                  ValidateStructureConfirmation(const SDetectedPattern& pattern);
    
    //--- Pattern Analysis ---
    double                CalculatePatternStrength(const SDetectedPattern& pattern);
    double                CalculatePatternReliability(const SDetectedPattern& pattern);
    double                CalculateSuccessProbability(const SDetectedPattern& pattern);
    ENUM_PATTERN_QUALITY  AssessPatternQuality(const SDetectedPattern& pattern);
    
    //--- Pattern Management ---
    bool                  AddPattern(const SDetectedPattern& pattern);
    bool                  UpdatePattern(int pattern_id, const SDetectedPattern& pattern);
    bool                  RemovePattern(int pattern_id);
    void                  ClearExpiredPatterns();
    void                  ClearAllPatterns();
    
    //--- Pattern Queries ---
    int                   GetPatternCount() const { return m_PatternCount; }
    SDetectedPattern      GetPattern(int index);
    SDetectedPattern      GetLatestPattern();
    bool                  GetPatternsByType(ENUM_PATTERN_TYPE type, SDetectedPattern& patterns[]);
    bool                  GetPatternsByQuality(ENUM_PATTERN_QUALITY quality, SDetectedPattern& patterns[]);
    
    //--- Statistics ---
    SPatternStatistics    GetStatistics();
    void                  UpdateStatistics();
    void                  ResetStatistics();
    double                GetSuccessRate(ENUM_PATTERN_TYPE type = PATTERN_NONE);
    
    //--- Swing Point Analysis ---
    void                  UpdateSwingPoints();
    bool                  FindSwingHighs(int lookback = 20);
    bool                  FindSwingLows(int lookback = 20);
    SPatternPoint         GetLastSwingHigh();
    SPatternPoint         GetLastSwingLow();
    
    //--- Utility Methods ---
    void                  Update();
    void                  Reset();
    bool                  IsPatternActive(const SDetectedPattern& pattern);
    bool                  IsPatternExpired(const SDetectedPattern& pattern);
    
    //--- Reporting ---
    string                GeneratePatternReport();
    string                GenerateStatisticsReport();
    bool                  ExportPatternsToCSV(const string& filename);
    
private:
    //--- Internal Detection Methods ---
    bool                  InitializeIndicators();
    void                  UpdateIndicatorBuffers();
    void                  UpdatePriceBuffers(int bars = 100);
    
    //--- Fibonacci Analysis ---
    double                CalculateFibonacciLevel(double start_price, double end_price, double fib_level);
    bool                  IsFibonacciLevel(double price, double start_price, double end_price, double tolerance = 0.03);
    double                GetClosestFibonacciLevel(double price, double start_price, double end_price);
    
    //--- Harmonic Pattern Validation ---
    bool                  ValidateHarmonicPattern(const SPatternPoint& X, const SPatternPoint& A,
                                                 const SPatternPoint& B, const SPatternPoint& C,
                                                 const SPatternPoint& D, ENUM_PATTERN_TYPE type);
    
    bool                  CheckHarmonicRatio(double ratio, double target, double tolerance = 0.05);
    double                CalculateRatio(double price1, double price2, double price3, double price4);
    
    //--- Pattern Geometry ---
    double                CalculatePatternHeight(const SDetectedPattern& pattern);
    double                CalculatePatternWidth(const SDetectedPattern& pattern);
    bool                  IsPatternSymmetric(const SDetectedPattern& pattern);
    
    //--- Entry/Exit Calculation ---
    void                  CalculateEntryLevels(SDetectedPattern& pattern);
    void                  CalculateStopLoss(SDetectedPattern& pattern);
    void                  CalculateTakeProfits(SDetectedPattern& pattern);
    double                CalculateRiskRewardRatio(const SDetectedPattern& pattern);
    
    //--- Pattern Confirmation ---
    bool                  ConfirmWithVolume(const SDetectedPattern& pattern);
    bool                  ConfirmWithMomentum(const SDetectedPattern& pattern);
    bool                  ConfirmWithStructure(const SDetectedPattern& pattern);
    bool                  ConfirmWithMultiTimeframe(const SDetectedPattern& pattern);
    
    //--- Utility Functions ---
    void                  LogPatternEvent(const string& event, ENUM_LOG_LEVEL level = LOG_LEVEL_INFO);
    string                PatternTypeToString(ENUM_PATTERN_TYPE type);
    string                PatternQualityToString(ENUM_PATTERN_QUALITY quality);
    string                PatternStatusToString(ENUM_PATTERN_STATUS status);
    
    //--- Memory Management ---
    void                  CleanupResources();
    bool                  OptimizeMemoryUsage();
    void                  ResizePatternArray(int new_size);
    
    //--- Time Utilities ---
    bool                  IsWithinTradingHours();
    bool                  IsNewsTime();
    datetime              GetPatternExpirationTime(ENUM_PATTERN_TYPE type);
    
    //--- Error Handling ---
    bool                  HandleDetectionError(int error_code);
    void                  ValidateInputData();
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPatterns::CPatterns(EAContext* context) {
    m_pContext = context;
    m_bInitialized = false;
    m_PatternCount = 0;
    m_HasActivePattern = false;
    m_SwingHighCount = 0;
    m_SwingLowCount = 0;
    m_DetectionCount = 0;
    m_ValidDetectionCount = 0;
    m_AverageDetectionTime = 0.0;
    m_MemoryOptimized = false;
    m_MaxPatterns = 100;
    
    // Initialize handles
    m_ATRHandle = INVALID_HANDLE;
    m_RSIHandle = INVALID_HANDLE;
    m_MACDHandle = INVALID_HANDLE;
    m_BBHandle = INVALID_HANDLE;
    
    // Initialize configuration
    ZeroMemory(m_Filter);
    ZeroMemory(m_Statistics);
    ZeroMemory(m_ActivePattern);
    
    // Set default configuration
    m_EnableRealTimeDetection = true;
    m_EnableMultiTimeframe = false;
    m_EnableHarmonicPatterns = true;
    m_EnableCandlestickPatterns = true;
    
    // Set default filter
    m_Filter.MinQuality = PATTERN_QUALITY_FAIR;
    m_Filter.MinStrength = 0.6;
    m_Filter.MinReliability = 0.7;
    m_Filter.MinConfidence = 0.8;
    m_Filter.MinRiskReward = 1.5;
    m_Filter.AllowReversals = true;
    m_Filter.AllowContinuations = true;
    m_Filter.AllowBreakouts = true;
    m_Filter.RequireVolumeConfirmation = false;
    m_Filter.RequireMomentumConfirmation = false;
    m_Filter.RequireStructureConfirmation = true;
    
    // Set detection parameters
    m_LookbackPeriod = 100;
    m_MinPatternBars = 5;
    m_MaxPatternBars = 50;
    m_FibTolerance = 0.03; // 3% tolerance
    m_PriceTolerancePercent = 0.5; // 0.5% tolerance
    
    // Initialize times
    m_LastDetectionTime = 0;
    m_LastStatisticsUpdate = 0;
    
    // Resize arrays
    ArrayResize(m_Patterns, m_MaxPatterns);
    ArrayResize(m_SwingHighs, 50);
    ArrayResize(m_SwingLows, 50);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPatterns::~CPatterns() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CPatterns::Initialize(const SPatternFilter& filter) {
    if (m_bInitialized) {
        return true;
    }
    
    if (m_pContext == NULL) {
        Print("[PATTERNS] Context is NULL");
        return false;
    }
    
    // Set filter configuration
    m_Filter = filter;
    
    // Initialize technical indicators
    if (!InitializeIndicators()) {
        LogPatternEvent("Failed to initialize indicators", LOG_LEVEL_ERROR);
        return false;
    }
    
    // Initialize price buffers
    UpdatePriceBuffers(m_LookbackPeriod);
    
    // Update indicator buffers
    UpdateIndicatorBuffers();
    
    // Initial swing point detection
    UpdateSwingPoints();
    
    m_bInitialized = true;
    
    if (m_pContext->pLogger != NULL) {
        string init_msg = StringFormat("Pattern Detection initialized: MinQuality=%d, MinStrength=%.2f",
                                      (int)m_Filter.MinQuality, m_Filter.MinStrength);
        m_pContext->pLogger->LogInfo(init_msg, __FUNCTION__);
    }
    
    LogPatternEvent("Pattern Detection initialized successfully", LOG_LEVEL_INFO);
    
    return true;
}

//+------------------------------------------------------------------+
//| Internal Methods Implementation                                  |
//+------------------------------------------------------------------+

bool CPatterns::InitializeIndicators() {
    // Initialize ATR
    m_ATRHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
    if (m_ATRHandle == INVALID_HANDLE) {
        LogPatternEvent("Failed to create ATR indicator", LOG_LEVEL_ERROR);
        return false;
    }
    
    // Initialize RSI
    m_RSIHandle = iRSI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
    if (m_RSIHandle == INVALID_HANDLE) {
        LogPatternEvent("Failed to create RSI indicator", LOG_LEVEL_ERROR);
        return false;
    }
    
    // Initialize MACD
    m_MACDHandle = iMACD(_Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);
    if (m_MACDHandle == INVALID_HANDLE) {
        LogPatternEvent("Failed to create MACD indicator", LOG_LEVEL_ERROR);
        return false;
    }
    
    // Initialize Bollinger Bands
    m_BBHandle = iBands(_Symbol, PERIOD_CURRENT, 20, 0, 2.0, PRICE_CLOSE);
    if (m_BBHandle == INVALID_HANDLE) {
        LogPatternEvent("Failed to create Bollinger Bands indicator", LOG_LEVEL_ERROR);
        return false;
    }
    
    // Resize indicator buffers
    ArrayResize(m_ATRBuffer, m_LookbackPeriod);
    ArrayResize(m_RSIBuffer, m_LookbackPeriod);
    ArrayResize(m_MACDMainBuffer, m_LookbackPeriod);
    ArrayResize(m_MACDSignalBuffer, m_LookbackPeriod);
    ArrayResize(m_BBUpperBuffer, m_LookbackPeriod);
    ArrayResize(m_BBLowerBuffer, m_LookbackPeriod);
    ArrayResize(m_BBMiddleBuffer, m_LookbackPeriod);
    
    // Set arrays as series
    ArraySetAsSeries(m_ATRBuffer, true);
    ArraySetAsSeries(m_RSIBuffer, true);
    ArraySetAsSeries(m_MACDMainBuffer, true);
    ArraySetAsSeries(m_MACDSignalBuffer, true);
    ArraySetAsSeries(m_BBUpperBuffer, true);
    ArraySetAsSeries(m_BBLowerBuffer, true);
    ArraySetAsSeries(m_BBMiddleBuffer, true);
    
    return true;
}

void CPatterns::LogPatternEvent(const string& event, ENUM_LOG_LEVEL level) {
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

} // namespace ApexPullback::v5

#endif // PATTERNS_MQH_