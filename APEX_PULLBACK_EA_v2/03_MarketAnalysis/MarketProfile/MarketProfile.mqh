//+------------------------------------------------------------------+
//|                                                MarketProfile.mqh |
//|                 MarketProfile.mqh - APEX Pullback EA v5 FINAL   |
//|      Description: Advanced Market Profile analysis system that  |
//|                   analyzes volume distribution, value areas,     |
//|                   market structure, and regime analytics.        |
//|                   Enhanced with v14 advanced features.          |
//+------------------------------------------------------------------+

#ifndef MARKET_PROFILE_MQH_
#define MARKET_PROFILE_MQH_

#include "..\..\00_Core\CommonStructs.mqh"

namespace ApexPullback::v5 {

//+------------------------------------------------------------------+
//| Market Regime Types (Enhanced from v14)                         |
//+------------------------------------------------------------------+
enum ENUM_MARKET_REGIME {
    REGIME_TRENDING_BULL,        // Strong bullish trend
    REGIME_TRENDING_BEAR,        // Strong bearish trend
    REGIME_RANGING_STABLE,       // Stable ranging market
    REGIME_RANGING_VOLATILE,     // Volatile ranging market
    REGIME_VOLATILE_EXPANSION,   // Volatility expansion
    REGIME_VOLATILE_CONTRACTION, // Volatility contraction
    REGIME_TRANSITION,           // Market regime transition
    REGIME_UNKNOWN               // Unknown regime
};

enum ENUM_MARKET_TREND {
    TREND_UP_STRONG,            // Strong uptrend
    TREND_UP_NORMAL,            // Normal uptrend
    TREND_UP_WEAK,              // Weak uptrend
    TREND_SIDEWAYS,             // Sideways market
    TREND_DOWN_WEAK,            // Weak downtrend
    TREND_DOWN_NORMAL,          // Normal downtrend
    TREND_DOWN_STRONG,          // Strong downtrend
    TREND_UNDEFINED             // Undefined trend
};

//+------------------------------------------------------------------+
//| Market Profile Types                                             |
//+------------------------------------------------------------------+
enum ENUM_PROFILE_TYPE {
    PROFILE_DAILY,          // Daily profile
    PROFILE_WEEKLY,         // Weekly profile
    PROFILE_MONTHLY,        // Monthly profile
    PROFILE_SESSION,        // Session-based profile
    PROFILE_CUSTOM          // Custom timeframe profile
};

enum ENUM_PROFILE_SHAPE {
    SHAPE_NORMAL,           // Normal distribution
    SHAPE_B_SHAPED,         // B-shaped (double distribution)
    SHAPE_P_SHAPED,         // P-shaped (trending up)
    SHAPE_B_SHAPED_DOWN,    // b-shaped (trending down)
    SHAPE_RECTANGULAR,      // Rectangular (balanced)
    SHAPE_SKEWED_UP,        // Skewed upward
    SHAPE_SKEWED_DOWN,      // Skewed downward
    SHAPE_UNKNOWN           // Unknown/irregular shape
};

enum ENUM_MARKET_STRUCTURE {
    STRUCTURE_BALANCED,     // Balanced market
    STRUCTURE_TRENDING_UP,  // Trending up
    STRUCTURE_TRENDING_DOWN, // Trending down
    STRUCTURE_ROTATIONAL,   // Rotational market
    STRUCTURE_BREAKOUT,     // Breakout market
    STRUCTURE_CONSOLIDATION // Consolidation
};

//+------------------------------------------------------------------+
//| Enhanced Market Profile Data (v14 Features)                     |
//+------------------------------------------------------------------+
struct SMarketProfileData {
    // Basic market data
    double                currentPrice;         // Current market price
    double                currentHigh;          // Current bar high
    double                currentLow;           // Current bar low
    double                currentOpen;          // Current bar open
    double                previousPrice;        // Previous bar close
    datetime              timestamp;            // Data timestamp
    string                symbol;               // Symbol name
    ENUM_TIMEFRAMES       timeframe;            // Analysis timeframe
    
    // Technical indicators
    double                currentSpread;        // Current spread
    double                atrCurrent;           // Current ATR
    double                atrPrevious;          // Previous ATR
    double                atrRatio;             // ATR ratio (current/average)
    double                averageDailyAtr;      // Average daily ATR
    
    // ADX indicators
    double                adxValue;             // ADX value
    double                adxSlope;             // ADX slope
    double                diPlus;               // DI+ value
    double                diMinus;              // DI- value
    double                minAdxValue;          // Minimum ADX threshold
    
    // RSI indicators
    double                rsiValue;             // RSI value
    double                rsiSlope;             // RSI slope
    
    // MACD indicators
    double                macdValue;            // MACD main line
    double                macdSignal;           // MACD signal line
    double                macdHistogram;        // MACD histogram
    double                macdHistogramSlope;   // MACD histogram slope
    
    // Moving averages
    double                emaFast;              // Fast EMA
    double                emaMedium;            // Medium EMA
    double                emaSlow;              // Slow EMA
    double                emaFastH4;            // Fast EMA H4
    double                emaMediumH4;          // Medium EMA H4
    double                emaSlowH4;            // Slow EMA H4
    
    // Bollinger Bands
    double                bbWidth;              // Bollinger Bands width
    double                bbUpper;              // BB upper band
    double                bbLower;              // BB lower band
    double                bbMiddle;             // BB middle line
    
    // Market analysis
    ENUM_MARKET_TREND     trend;                // Current trend
    ENUM_MARKET_REGIME    regime;               // Market regime
    double                trendScore;           // Trend strength score
    double                regimeConfidence;     // Regime confidence level
    
    // Market conditions
    bool                  isTrending;           // Is market trending
    bool                  isSidewaysOrChoppy;   // Is sideways or choppy
    bool                  isLowMomentum;        // Low momentum flag
    bool                  isVolatile;           // High volatility flag
    bool                  isTransitioning;      // Market transitioning
    
    // Multi-timeframe analysis
    bool                  mtfBullishAlignment;  // MTF bullish alignment
    bool                  mtfBearishAlignment;  // MTF bearish alignment
    double                mtfStrength;          // MTF strength score
    
    // Volume analysis
    long                  currentVolume;        // Current volume
    double                volumeRatio;          // Volume ratio
    bool                  isHighVolume;         // High volume flag
    
    // Session analysis
    ENUM_SESSION          currentSession;       // Current trading session
    bool                  isSessionOpen;        // Session open flag
    
    // Constructor
    SMarketProfileData() {
        Clear();
    }
    
    void Clear() {
        currentPrice = 0.0;
        currentHigh = 0.0;
        currentLow = 0.0;
        currentOpen = 0.0;
        previousPrice = 0.0;
        timestamp = 0;
        symbol = "";
        timeframe = PERIOD_CURRENT;
        
        currentSpread = 0.0;
        atrCurrent = 0.0;
        atrPrevious = 0.0;
        atrRatio = 1.0;
        averageDailyAtr = 0.0;
        
        adxValue = 0.0;
        adxSlope = 0.0;
        diPlus = 0.0;
        diMinus = 0.0;
        minAdxValue = 0.0;
        
        rsiValue = 50.0;
        rsiSlope = 0.0;
        
        macdValue = 0.0;
        macdSignal = 0.0;
        macdHistogram = 0.0;
        macdHistogramSlope = 0.0;
        
        emaFast = 0.0;
        emaMedium = 0.0;
        emaSlow = 0.0;
        emaFastH4 = 0.0;
        emaMediumH4 = 0.0;
        emaSlowH4 = 0.0;
        
        bbWidth = 0.0;
        bbUpper = 0.0;
        bbLower = 0.0;
        bbMiddle = 0.0;
        
        trend = TREND_UNDEFINED;
        regime = REGIME_UNKNOWN;
        trendScore = 0.0;
        regimeConfidence = 0.0;
        
        isTrending = false;
        isSidewaysOrChoppy = false;
        isLowMomentum = false;
        isVolatile = false;
        isTransitioning = false;
        
        mtfBullishAlignment = false;
        mtfBearishAlignment = false;
        mtfStrength = 0.0;
        
        currentVolume = 0;
        volumeRatio = 1.0;
        isHighVolume = false;
        
        currentSession = SESSION_NONE;
        isSessionOpen = false;
    }
};

//+------------------------------------------------------------------+
//| Price Level Data                                                 |
//+------------------------------------------------------------------+
struct SPriceLevel {
    double                Price;            // Price level
    long                  Volume;           // Total volume at this level
    int                   TimeSpent;        // Time spent at this level (ticks)
    double                VolumePercent;    // Volume percentage of total
    bool                  IsHighVolume;     // High volume node flag
    bool                  IsLowVolume;      // Low volume node flag
    bool                  IsPOC;            // Point of Control flag
    bool                  IsValueArea;      // Value area flag
};

//+------------------------------------------------------------------+
//| Value Area Data                                                  |
//+------------------------------------------------------------------+
struct SValueArea {
    double                VAH;              // Value Area High
    double                VAL;              // Value Area Low
    double                POC;              // Point of Control
    double                VolumeAtPOC;      // Volume at POC
    double                ValueAreaVolume;  // Total volume in value area
    double                ValueAreaPercent; // Value area percentage (default 70%)
    int                   ValueAreaWidth;   // Value area width in ticks
    bool                  IsValid;          // Value area validity flag
};

//+------------------------------------------------------------------+
//| Market Profile Session                                           |
//+------------------------------------------------------------------+
struct SProfileSession {
    datetime              StartTime;        // Session start time
    datetime              EndTime;          // Session end time
    double                SessionHigh;      // Session high
    double                SessionLow;       // Session low
    double                OpenPrice;        // Session open
    double                ClosePrice;       // Session close
    long                  TotalVolume;      // Total session volume
    SValueArea            ValueArea;        // Session value area
    ENUM_PROFILE_SHAPE    ProfileShape;     // Profile shape
    double                Balance;          // Market balance score
    bool                  IsComplete;       // Session completion flag
};

//+------------------------------------------------------------------+
//| Volume Profile Data                                              |
//+------------------------------------------------------------------+
struct SVolumeProfile {
    SPriceLevel           Levels[];         // Price levels array
    int                   LevelCount;       // Number of levels
    double                TickSize;         // Tick size for levels
    double                MinPrice;         // Minimum price in profile
    double                MaxPrice;         // Maximum price in profile
    long                  TotalVolume;      // Total volume
    SValueArea            ValueArea;        // Value area data
    ENUM_PROFILE_SHAPE    Shape;            // Profile shape
    double                Skewness;         // Distribution skewness
    double                Kurtosis;         // Distribution kurtosis
    datetime              ProfileDate;      // Profile date/time
    ENUM_PROFILE_TYPE     ProfileType;      // Profile type
};

//+------------------------------------------------------------------+
//| Enhanced Market Context (v14 Features)                          |
//+------------------------------------------------------------------+
struct SMarketContext {
    ENUM_MARKET_STRUCTURE Structure;        // Current market structure
    ENUM_MARKET_REGIME    Regime;           // Market regime
    ENUM_MARKET_TREND     Trend;            // Market trend
    
    double                StructureScore;   // Structure confidence score
    double                RegimeConfidence; // Regime confidence
    double                TrendStrength;    // Trend strength (0-100)
    
    bool                  IsBalanced;       // Market balance flag
    bool                  IsRotational;     // Rotational market flag
    bool                  IsTrending;       // Trending market flag
    bool                  IsVolatile;       // Volatile market flag
    bool                  IsTransitioning;  // Transitioning flag
    
    double                VolatilityRatio;  // Volatility ratio
    double                MomentumStrength; // Momentum strength
    double                RotationLevel;    // Rotation level
    double                BreakoutLevel;    // Potential breakout level
    
    // Multi-timeframe context
    bool                  MTFAlignment;     // Multi-timeframe alignment
    double                MTFStrength;      // MTF strength score
    
    datetime              LastStructureChange; // Last structure change
    datetime              LastRegimeChange;    // Last regime change
    string                StructureNotes;   // Structure analysis notes
    
    // Constructor
    SMarketContext() {
        Structure = STRUCTURE_BALANCED;
        Regime = REGIME_UNKNOWN;
        Trend = TREND_UNDEFINED;
        StructureScore = 0.0;
        RegimeConfidence = 0.0;
        TrendStrength = 0.0;
        IsBalanced = false;
        IsRotational = false;
        IsTrending = false;
        IsVolatile = false;
        IsTransitioning = false;
        VolatilityRatio = 1.0;
        MomentumStrength = 0.0;
        RotationLevel = 0.0;
        BreakoutLevel = 0.0;
        MTFAlignment = false;
        MTFStrength = 0.0;
        LastStructureChange = 0;
        LastRegimeChange = 0;
        StructureNotes = "";
    }
};

//+------------------------------------------------------------------+
//| Profile Statistics                                               |
//+------------------------------------------------------------------+
struct SProfileStats {
    double                AverageVolume;    // Average volume per level
    double                VolumeStdDev;     // Volume standard deviation
    double                MaxVolume;        // Maximum volume level
    double                MinVolume;        // Minimum volume level
    int                   HighVolumeNodes;  // Number of high volume nodes
    int                   LowVolumeNodes;   // Number of low volume nodes
    double                VolumeConcentration; // Volume concentration ratio
    double                ProfileWidth;     // Profile width (price range)
    double                ProfileCenter;    // Profile center (median)
    double                VolumeWeightedPrice; // Volume weighted average price
    
    // Enhanced statistics (v14)
    double                VolatilityIndex;  // Volatility index
    double                TrendIntensity;   // Trend intensity measure
    double                MarketEfficiency; // Market efficiency score
    double                LiquidityScore;   // Liquidity assessment
};

//+------------------------------------------------------------------+
//| Enhanced Profile Configuration (v14 Features)                   |
//+------------------------------------------------------------------+
struct SProfileConfig {
    ENUM_PROFILE_TYPE     ProfileType;      // Profile type
    int                   TicksPerLevel;    // Ticks per price level
    double                ValueAreaPercent; // Value area percentage (default 70%)
    int                   MinVolumeThreshold; // Minimum volume threshold
    bool                  UseTickVolume;    // Use tick volume vs real volume
    bool                  CalculateTPO;     // Calculate Time Price Opportunity
    bool                  ShowLowVolumeNodes; // Show low volume nodes
    bool                  ShowHighVolumeNodes; // Show high volume nodes
    int                   SessionStartHour; // Session start hour
    int                   SessionEndHour;   // Session end hour
    bool                  AutoDetectSessions; // Auto-detect trading sessions
    int                   MaxProfileDays;  // Maximum profile days to keep
    
    // Enhanced configuration (v14)
    bool                  UseMultiTimeframe; // Use multi-timeframe analysis
    ENUM_TIMEFRAMES       HigherTimeframe;   // Higher timeframe for MTF
    bool                  EnableRegimeAnalysis; // Enable regime analysis
    bool                  EnableVolatilityAnalysis; // Enable volatility analysis
    double                VolatilityThreshold; // Volatility threshold
    double                TrendThreshold;      // Trend strength threshold
    bool                  EnableSmartFiltering; // Enable smart filtering
    int                   RegimeUpdateInterval; // Regime update interval (minutes)
};

//+------------------------------------------------------------------+
//| CMarketProfile - Enhanced Advanced Market Profile Analysis      |
//+------------------------------------------------------------------+
class CMarketProfile {
private:
    EAContext*            m_pContext;       // Reference to EA context
    bool                  m_bInitialized;  // Initialization status
    
    // Configuration
    SProfileConfig        m_Config;         // Profile configuration
    string                m_Symbol;         // Current symbol
    ENUM_TIMEFRAMES       m_Timeframe;      // Analysis timeframe
    
    // Enhanced profile data (v14)
    SVolumeProfile        m_CurrentProfile; // Current volume profile
    SMarketContext        m_MarketContext;  // Enhanced market context
    SMarketProfileData    m_CurrentData;    // Current market data
    SMarketProfileData    m_PreviousData;   // Previous market data
    SProfileStats         m_Stats;          // Profile statistics
    
    // Historical profiles
    SVolumeProfile        m_HistoricalProfiles[]; // Historical profiles array
    int                   m_ProfileCount;   // Number of stored profiles
    
    // Session data
    SProfileSession       m_CurrentSession; // Current session
    SProfileSession       m_PreviousSession; // Previous session
    
    // Working data
    double                m_PriceData[];    // Price data buffer
    long                  m_VolumeData[];   // Volume data buffer
    datetime              m_TimeData[];     // Time data buffer
    int                   m_DataCount;      // Data count
    
    // Analysis results
    double                m_SupportLevels[]; // Support levels from profile
    double                m_ResistanceLevels[]; // Resistance levels from profile
    int                   m_SupportCount;   // Support levels count
    int                   m_ResistanceCount; // Resistance levels count
    
    // Enhanced analysis (v14)
    double                m_ATRHistory[];   // ATR history for calculations
    double                m_SpreadHistory[]; // Spread history
    int                   m_SpreadCount;    // Spread count
    datetime              m_LastUpdateTime; // Last update time
    datetime              m_LastRegimeUpdate; // Last regime update
    
    // Update tracking
    datetime              m_LastUpdate;     // Last update time
    datetime              m_LastProfileBuild; // Last profile build time
    
    // Constants
    static const double   DEFAULT_VALUE_AREA_PERCENT;
    static const int      DEFAULT_TICKS_PER_LEVEL;
    static const int      MAX_PRICE_LEVELS;
    
public:
    //--- Constructor/Destructor ---
    CMarketProfile(EAContext* context);
    ~CMarketProfile();
    
    //--- Core Methods ---
    bool                  Initialize(const string& symbol, const ENUM_TIMEFRAMES timeframe, const SProfileConfig& config);
    void                  Deinitialize();
    bool                  IsInitialized() const { return m_bInitialized; }
    void                  Update();
    
    //--- Enhanced Data Access (v14) ---
    SMarketProfileData    GetCurrentData() const { return m_CurrentData; }
    SMarketProfileData    GetPreviousData() const { return m_PreviousData; }
    bool                  IsNewBar();
    
    //--- Market Regime Analysis (v14) ---
    ENUM_MARKET_REGIME    GetMarketRegime() const { return m_MarketContext.Regime; }
    double                GetRegimeConfidence() const { return m_MarketContext.RegimeConfidence; }
    bool                  IsRegimeTransitioning() const { return m_MarketContext.IsTransitioning; }
    ENUM_MARKET_TREND     GetMarketTrend() const { return m_MarketContext.Trend; }
    double                GetTrendStrength() const { return m_MarketContext.TrendStrength; }
    
    //--- Market Condition Analysis (v14) ---
    bool                  IsTrendStrongEnough() const;
    bool                  IsSidewaysOrChoppy() const { return m_CurrentData.isSidewaysOrChoppy; }
    bool                  IsLowMomentum() const { return m_CurrentData.isLowMomentum; }
    bool                  IsVolatile() const { return m_CurrentData.isVolatile; }
    bool                  IsMarketTransitioning() const { return m_CurrentData.isTransitioning; }
    double                GetVolatilityRatio() const { return m_MarketContext.VolatilityRatio; }
    double                GetMomentumStrength() const { return m_MarketContext.MomentumStrength; }
    
    //--- Multi-timeframe Analysis (v14) ---
    bool                  IsMultiTimeframeAligned() const;
    double                GetMTFStrength() const { return m_MarketContext.MTFStrength; }
    bool                  ValidateMultiTimeframeTrend(bool isLong);
    
    //--- Pullback Analysis (v14) ---
    double                CalculatePullbackPercent(bool isLong) const;
    bool                  IsPriceInPullbackZone(bool isLong);
    bool                  IsValidPullbackEntry(bool isLong, double entryPrice);
    
    //--- Profile Building ---
    bool                  BuildCurrentProfile();
    bool                  BuildHistoricalProfile(const datetime start_time, const datetime end_time);
    bool                  BuildSessionProfile(const SProfileSession& session);
    void                  ClearProfiles();
    
    //--- Profile Access ---
    SVolumeProfile        GetCurrentProfile() const { return m_CurrentProfile; }
    SVolumeProfile        GetHistoricalProfile(const int index);
    SProfileSession       GetCurrentSession() const { return m_CurrentSession; }
    SProfileSession       GetPreviousSession() const { return m_PreviousSession; }
    
    //--- Value Area Analysis ---
    SValueArea            GetCurrentValueArea() const { return m_CurrentProfile.ValueArea; }
    double                GetPOC() const { return m_CurrentProfile.ValueArea.POC; }
    double                GetVAH() const { return m_CurrentProfile.ValueArea.VAH; }
    double                GetVAL() const { return m_CurrentProfile.ValueArea.VAL; }
    bool                  IsPriceInValueArea(const double price);
    bool                  IsPriceAboveValueArea(const double price);
    bool                  IsPriceBelowValueArea(const double price);
    
    //--- Market Structure ---
    SMarketContext        GetMarketContext() const { return m_MarketContext; }
    ENUM_MARKET_STRUCTURE GetMarketStructure() const { return m_MarketContext.Structure; }
    bool                  IsMarketBalanced() const { return m_MarketContext.IsBalanced; }
    bool                  IsMarketTrending() const { return m_MarketContext.IsTrending; }
    bool                  IsMarketRotational() const { return m_MarketContext.IsRotational; }
    
    //--- Profile Shape Analysis ---
    ENUM_PROFILE_SHAPE    GetProfileShape() const { return m_CurrentProfile.Shape; }
    bool                  IsNormalDistribution();
    bool                  IsBShapedProfile();
    bool                  IsPShapedProfile();
    bool                  IsRectangularProfile();
    double                GetProfileSkewness() const { return m_CurrentProfile.Skewness; }
    
    //--- Volume Analysis ---
    long                  GetVolumeAtPrice(const double price);
    double                GetVolumePercent(const double price);
    bool                  IsHighVolumeNode(const double price);
    bool                  IsLowVolumeNode(const double price);
    double                GetVolumeWeightedPrice();
    
    //--- Support/Resistance ---
    int                   GetSupportLevels(double& levels[]);
    int                   GetResistanceLevels(double& levels[]);
    double                GetNearestSupport(const double price);
    double                GetNearestResistance(const double price);
    bool                  IsSignificantLevel(const double price);
    
    //--- Trading Signals ---
    bool                  IsValueAreaRejection(const double price);
    bool                  IsValueAreaAcceptance(const double price);
    bool                  IsPOCTest(const double price);
    bool                  IsBreakoutSignal(const double price);
    bool                  IsRotationSignal(const double price);
    
    //--- Session Analysis ---
    bool                  IsSessionOpen();
    bool                  IsSessionClose();
    double                GetSessionBalance();
    bool                  IsSessionBreakout();
    bool                  IsSessionRotation();
    
    //--- Statistics ---
    SProfileStats         GetProfileStatistics() const { return m_Stats; }
    double                GetAverageVolume() const { return m_Stats.AverageVolume; }
    double                GetVolumeConcentration() const { return m_Stats.VolumeConcentration; }
    int                   GetHighVolumeNodeCount() const { return m_Stats.HighVolumeNodes; }
    int                   GetLowVolumeNodeCount() const { return m_Stats.LowVolumeNodes; }
    
    //--- Enhanced Statistics (v14) ---
    double                GetVolatilityIndex() const { return m_Stats.VolatilityIndex; }
    double                GetTrendIntensity() const { return m_Stats.TrendIntensity; }
    double                GetMarketEfficiency() const { return m_Stats.MarketEfficiency; }
    double                GetLiquidityScore() const { return m_Stats.LiquidityScore; }
    
    //--- Configuration ---
    bool                  SetConfiguration(const SProfileConfig& config);
    SProfileConfig        GetConfiguration() const { return m_Config; }
    bool                  SetValueAreaPercent(const double percent);
    bool                  SetTicksPerLevel(const int ticks);
    
    //--- Information ---
    string                GetProfileSummary();
    string                GetMarketStructureDescription();
    string                GetValueAreaDescription();
    string                GetTradingRecommendations();
    string                GetRegimeAnalysis();
    
private:
    //--- Enhanced Analysis Implementation (v14) ---
    bool                  UpdateMarketData();
    void                  UpdateATRHistory();
    void                  UpdateSpreadHistory();
    bool                  ValidateMarketData();
    
    //--- Market Regime Analysis (v14) ---
    void                  AnalyzeMarketRegime();
    ENUM_MARKET_REGIME    DetermineMarketRegime();
    ENUM_MARKET_TREND     DetermineTrend();
    double                CalculateTrendStrength();
    double                CalculateRegimeConfidence();
    bool                  DetectRegimeTransition();
    
    //--- Market Condition Detection (v14) ---
    bool                  CheckLowMomentum();
    bool                  CheckHighVolatility();
    bool                  CheckSidewaysMarket();
    bool                  CheckChoppyMarket();
    double                CalculateChoppyScore();
    double                CalculateSidewaysScore();
    double                CalculateMomentumScore();
    
    //--- Multi-timeframe Analysis (v14) ---
    bool                  AnalyzeMultiTimeframe();
    bool                  CheckMTFAlignment();
    double                CalculateMTFStrength();
    
    //--- Profile Building Implementation ---
    bool                  LoadMarketData(const datetime start_time, const datetime end_time);
    void                  CalculatePriceLevels();
    void                  DistributeVolume();
    void                  CalculateValueArea();
    void                  AnalyzeProfileShape();
    void                  CalculateStatistics();
    void                  CalculateEnhancedStatistics();
    
    //--- Market Structure Analysis ---
    void                  AnalyzeMarketStructure();
    ENUM_MARKET_STRUCTURE DetermineMarketStructure();
    double                CalculateStructureScore();
    bool                  DetectBalance();
    bool                  DetectTrend();
    bool                  DetectRotation();
    
    //--- Volume Analysis Implementation ---
    void                  IdentifyVolumeNodes();
    void                  CalculateVolumeStatistics();
    double                CalculateVolumeConcentration();
    
    //--- Support/Resistance Detection ---
    void                  IdentifySupportResistance();
    bool                  IsSignificantVolumeLevel(const double price, const long volume);
    double                CalculateLevelStrength(const double price);
    
    //--- Shape Analysis Implementation ---
    ENUM_PROFILE_SHAPE    AnalyzeDistributionShape();
    double                CalculateSkewness();
    double                CalculateKurtosis();
    bool                  DetectBimodalDistribution();
    
    //--- Session Management ---
    void                  UpdateCurrentSession();
    bool                  IsNewSession();
    void                  FinalizeSession();
    
    //--- Utility Methods ---
    int                   PriceToLevel(const double price);
    double                LevelToPrice(const int level);
    bool                  ValidateProfileData();
    void                  SortLevelsByVolume();
    void                  LogProfileEvent(const string& event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO);
    double                CalculateSlope(const double& buffer[], int periods = 5);
    
    //--- Mathematical Functions ---
    double                CalculatePercentile(const double data[], const int count, const double percentile);
    double                CalculateMedian(const double data[], const int count);
    double                CalculateMode(const double data[], const int count);
    double                CalculateStandardDeviation(const double data[], const int count);
    double                CalculateCorrelation(const double x[], const double y[], const int count);
    
    //--- Memory Management ---
    void                  ResizeArrays(const int new_size);
    void                  CleanupOldProfiles();
    bool                  InitializeDataArrays();
};

// Static constants definition
const double CMarketProfile::DEFAULT_VALUE_AREA_PERCENT = 70.0;
const int CMarketProfile::DEFAULT_TICKS_PER_LEVEL = 1;
const int CMarketProfile::MAX_PRICE_LEVELS = 1000;

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CMarketProfile::CMarketProfile(EAContext* context) {
    m_pContext = context;
    m_bInitialized = false;
    m_Symbol = "";
    m_Timeframe = PERIOD_CURRENT;
    m_DataCount = 0;
    m_ProfileCount = 0;
    m_SupportCount = 0;
    m_ResistanceCount = 0;
    m_SpreadCount = 0;
    m_LastUpdate = 0;
    m_LastProfileBuild = 0;
    m_LastUpdateTime = 0;
    m_LastRegimeUpdate = 0;
    
    // Initialize structures
    ZeroMemory(m_Config);
    ZeroMemory(m_CurrentProfile);
    ZeroMemory(m_MarketContext);
    ZeroMemory(m_CurrentData);
    ZeroMemory(m_PreviousData);
    ZeroMemory(m_Stats);
    ZeroMemory(m_CurrentSession);
    ZeroMemory(m_PreviousSession);
    
    // Set enhanced default configuration (v14)
    m_Config.ProfileType = PROFILE_DAILY;
    m_Config.TicksPerLevel = DEFAULT_TICKS_PER_LEVEL;
    m_Config.ValueAreaPercent = DEFAULT_VALUE_AREA_PERCENT;
    m_Config.MinVolumeThreshold = 10;
    m_Config.UseTickVolume = true;
    m_Config.CalculateTPO = true;
    m_Config.ShowLowVolumeNodes = true;
    m_Config.ShowHighVolumeNodes = true;
    m_Config.SessionStartHour = 0;
    m_Config.SessionEndHour = 24;
    m_Config.AutoDetectSessions = true;
    m_Config.MaxProfileDays = 30;
    
    // Enhanced configuration (v14)
    m_Config.UseMultiTimeframe = true;
    m_Config.HigherTimeframe = PERIOD_H4;
    m_Config.EnableRegimeAnalysis = true;
    m_Config.EnableVolatilityAnalysis = true;
    m_Config.VolatilityThreshold = 1.5;
    m_Config.TrendThreshold = 25.0;
    m_Config.EnableSmartFiltering = true;
    m_Config.RegimeUpdateInterval = 5;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CMarketProfile::~CMarketProfile() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CMarketProfile::Initialize(const string& symbol, const ENUM_TIMEFRAMES timeframe, const SProfileConfig& config) {
    if (m_bInitialized) {
        return true;
    }
    
    if (m_pContext == NULL) {
        Print("[MARKET_PROFILE] Context is NULL");
        return false;
    }
    
    m_Symbol = symbol;
    m_Timeframe = timeframe;
    m_Config = config;
    
    // Validate configuration
    if (m_Config.ValueAreaPercent <= 0 || m_Config.ValueAreaPercent > 100) {
        m_Config.ValueAreaPercent = DEFAULT_VALUE_AREA_PERCENT;
    }
    
    if (m_Config.TicksPerLevel <= 0) {
        m_Config.TicksPerLevel = DEFAULT_TICKS_PER_LEVEL;
    }
    
    // Initialize enhanced arrays (v14)
    if (!InitializeDataArrays()) {
        if (m_pContext.pLogger != NULL) {
            m_pContext.pLogger.LogError("Failed to initialize data arrays", __FUNCTION__);
        }
        return false;
    }
    
    // Initialize arrays
    ArrayResize(m_HistoricalProfiles, m_Config.MaxProfileDays);
    ArrayResize(m_SupportLevels, 20);
    ArrayResize(m_ResistanceLevels, 20);
    
    // Initialize market data
    if (!UpdateMarketData()) {
        if (m_pContext.pLogger != NULL) {
            m_pContext.pLogger.LogWarning("Failed to update initial market data", __FUNCTION__);
        }
    }
    
    // Build initial profile
    if (!BuildCurrentProfile()) {
        LogProfileEvent("Failed to build initial profile", LOG_LEVEL_WARNING);
    }
    
    m_bInitialized = true;
    
    if (m_pContext.pLogger != NULL) {
        m_pContext.pLogger.LogInfo("Enhanced MarketProfile initialized for: " + symbol, __FUNCTION__);
        m_pContext.pLogger.LogInfo(GetProfileSummary(), __FUNCTION__);
        m_pContext.pLogger.LogInfo(GetRegimeAnalysis(), __FUNCTION__);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CMarketProfile::Deinitialize() {
    if (!m_bInitialized) {
        return;
    }
    
    if (m_pContext != NULL && m_pContext.pLogger != NULL) {
        m_pContext.pLogger.LogInfo(GetTradingRecommendations(), __FUNCTION__);
        m_pContext.pLogger.LogInfo(GetRegimeAnalysis(), __FUNCTION__);
        m_pContext.pLogger.LogInfo("Enhanced MarketProfile shutting down", __FUNCTION__);
    }
    
    m_bInitialized = false;
}

//+------------------------------------------------------------------+
//| Enhanced Update Method (v14)                                    |
//+------------------------------------------------------------------+
void CMarketProfile::Update() {
    if (!m_bInitialized) {
        return;
    }
    
    datetime current_time = TimeCurrent();
    
    // Check for new bar
    if (!IsNewBar()) {
        return; // No new data to process
    }
    
    // Update market data
    if (!UpdateMarketData()) {
        LogProfileEvent("Failed to update market data", LOG_LEVEL_WARNING);
        return;
    }
    
    // Update market regime (at configured intervals)
    if (m_Config.EnableRegimeAnalysis && 
        (current_time - m_LastRegimeUpdate >= m_Config.RegimeUpdateInterval * 60)) {
        AnalyzeMarketRegime();
        m_LastRegimeUpdate = current_time;
    }
    
    // Update session
    UpdateCurrentSession();
    
    // Rebuild profile periodically
    if (current_time - m_LastProfileBuild >= 3600) { // Every hour
        BuildCurrentProfile();
        m_LastProfileBuild = current_time;
    }
    
    // Update market structure
    AnalyzeMarketStructure();
    
    // Multi-timeframe analysis
    if (m_Config.UseMultiTimeframe) {
        AnalyzeMultiTimeframe();
    }
    
    // Calculate enhanced statistics
    CalculateEnhancedStatistics();
    
    m_LastUpdate = current_time;
    
    // Log significant changes
    if (m_pContext.pLogger != NULL && m_pContext.pLogger.IsDebugEnabled()) {
        string log_msg = StringFormat("MarketProfile Update - Regime: %s, Trend: %s, Volatility: %.2f, Strength: %.1f",
            EnumToString(m_MarketContext.Regime),
            EnumToString(m_MarketContext.Trend),
            m_MarketContext.VolatilityRatio,
            m_MarketContext.TrendStrength);
        m_pContext.pLogger.LogDebug(log_msg, __FUNCTION__);
    }
}

//+------------------------------------------------------------------+
//| Build Current Profile                                            |
//+------------------------------------------------------------------+
bool CMarketProfile::BuildCurrentProfile() {
    if (!m_bInitialized) {
        return false;
    }
    
    LogProfileEvent("Building current market profile", LOG_LEVEL_INFO);
    
    // Determine time range based on profile type
    datetime start_time, end_time;
    end_time = TimeCurrent();
    
    switch(m_Config.ProfileType) {
        case PROFILE_DAILY:
            start_time = end_time - 86400; // 24 hours
            break;
        case PROFILE_WEEKLY:
            start_time = end_time - 604800; // 7 days
            break;
        case PROFILE_MONTHLY:
            start_time = end_time - 2592000; // 30 days
            break;
        case PROFILE_SESSION:
            // Use session times
            start_time = end_time - (m_Config.SessionEndHour - m_Config.SessionStartHour) * 3600;
            break;
        default:
            start_time = end_time - 86400;
    }
    
    // Load market data
    if (!LoadMarketData(start_time, end_time)) {
        LogProfileEvent("Failed to load market data", LOG_LEVEL_ERROR);
        return false;
    }
    
    // Build profile
    CalculatePriceLevels();
    DistributeVolume();
    CalculateValueArea();
    AnalyzeProfileShape();
    CalculateStatistics();
    IdentifyVolumeNodes();
    IdentifySupportResistance();
    
    // Update metadata
    m_CurrentProfile.ProfileDate = TimeCurrent();
    m_CurrentProfile.ProfileType = m_Config.ProfileType;
    
    LogProfileEvent("Market profile built successfully", LOG_LEVEL_INFO);
    
    return true;
}

//+------------------------------------------------------------------+
//| Get POC                                                          |
//+------------------------------------------------------------------+
double CMarketProfile::GetPOC() const {
    return m_CurrentProfile.ValueArea.POC;
}

//+------------------------------------------------------------------+
//| Is Price In Value Area                                           |
//+------------------------------------------------------------------+
bool CMarketProfile::IsPriceInValueArea(const double price) {
    return (price >= m_CurrentProfile.ValueArea.VAL && 
            price <= m_CurrentProfile.ValueArea.VAH);
}

//+------------------------------------------------------------------+
//| Is Price Above Value Area                                        |
//+------------------------------------------------------------------+
bool CMarketProfile::IsPriceAboveValueArea(const double price) {
    return (price > m_CurrentProfile.ValueArea.VAH);
}

//+------------------------------------------------------------------+
//| Is Price Below Value Area                                        |
//+------------------------------------------------------------------+
bool CMarketProfile::IsPriceBelowValueArea(const double price) {
    return (price < m_CurrentProfile.ValueArea.VAL);
}

//+------------------------------------------------------------------+
//| Get Volume At Price                                              |
//+------------------------------------------------------------------+
long CMarketProfile::GetVolumeAtPrice(const double price) {
    int level = PriceToLevel(price);
    
    for (int i = 0; i < m_CurrentProfile.LevelCount; i++) {
        if (PriceToLevel(m_CurrentProfile.Levels[i].Price) == level) {
            return m_CurrentProfile.Levels[i].Volume;
        }
    }
    
    return 0;
}

//+------------------------------------------------------------------+
//| Is High Volume Node                                              |
//+------------------------------------------------------------------+
bool CMarketProfile::IsHighVolumeNode(const double price) {
    for (int i = 0; i < m_CurrentProfile.LevelCount; i++) {
        if (MathAbs(m_CurrentProfile.Levels[i].Price - price) < m_CurrentProfile.TickSize) {
            return m_CurrentProfile.Levels[i].IsHighVolume;
        }
    }
    return false;
}

//+------------------------------------------------------------------+
//| Is Value Area Rejection                                          |
//+------------------------------------------------------------------+
bool CMarketProfile::IsValueAreaRejection(const double price) {
    // Check if price tested value area boundaries and was rejected
    double vah = m_CurrentProfile.ValueArea.VAH;
    double val = m_CurrentProfile.ValueArea.VAL;
    
    // Price near VAH and moving down = rejection
    if (MathAbs(price - vah) < m_CurrentProfile.TickSize * 3) {
        return true;
    }
    
    // Price near VAL and moving up = rejection
    if (MathAbs(price - val) < m_CurrentProfile.TickSize * 3) {
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Get Profile Summary                                              |
//+------------------------------------------------------------------+
string CMarketProfile::GetProfileSummary() {
    string summary = "=== MARKET PROFILE ANALYSIS ===\n";
    summary += StringFormat("Symbol: %s\n", m_Symbol);
    summary += StringFormat("Profile Type: %s\n", EnumToString(m_Config.ProfileType));
    summary += StringFormat("POC: %.5f\n", m_CurrentProfile.ValueArea.POC);
    summary += StringFormat("VAH: %.5f\n", m_CurrentProfile.ValueArea.VAH);
    summary += StringFormat("VAL: %.5f\n", m_CurrentProfile.ValueArea.VAL);
    summary += StringFormat("Value Area Volume: %.1f%%\n", m_CurrentProfile.ValueArea.ValueAreaPercent);
    summary += StringFormat("Profile Shape: %s\n", EnumToString(m_CurrentProfile.Shape));
    summary += StringFormat("Market Structure: %s\n", EnumToString(m_MarketContext.Structure));
    summary += StringFormat("High Volume Nodes: %d\n", m_Stats.HighVolumeNodes);
    summary += StringFormat("Low Volume Nodes: %d\n", m_Stats.LowVolumeNodes);
    
    return summary;
}

//+------------------------------------------------------------------+
//| Internal Methods                                                 |
//+------------------------------------------------------------------+
bool CMarketProfile::LoadMarketData(const datetime start_time, const datetime end_time) {
    if (m_Symbol == "") {
        return false;
    }
    
    // Calculate required bars
    int bars_needed = (int)((end_time - start_time) / PeriodSeconds(m_Timeframe));
    if (bars_needed <= 0) {
        return false;
    }
    
    // Load price data
    double high_prices[], low_prices[], close_prices[];
    long volumes[];
    datetime times[];
    
    int copied_high = CopyHigh(m_Symbol, m_Timeframe, start_time, bars_needed, high_prices);
    int copied_low = CopyLow(m_Symbol, m_Timeframe, start_time, bars_needed, low_prices);
    int copied_close = CopyClose(m_Symbol, m_Timeframe, start_time, bars_needed, close_prices);
    int copied_volumes = CopyTickVolume(m_Symbol, m_Timeframe, start_time, bars_needed, volumes);
    int copied_times = CopyTime(m_Symbol, m_Timeframe, start_time, bars_needed, times);
    
    if (copied_high < 10 || copied_low < 10 || copied_close < 10) {
        LogProfileEvent("Insufficient market data loaded", LOG_LEVEL_ERROR);
        return false;
    }
    
    // Store data for profile building
    m_DataCount = copied_high;
    ArrayResize(m_PriceData, m_DataCount * 3); // High, Low, Close
    ArrayResize(m_VolumeData, m_DataCount);
    ArrayResize(m_TimeData, m_DataCount);
    
    // Combine price data (High, Low, Close for each bar)
    for (int i = 0; i < m_DataCount; i++) {
        m_PriceData[i * 3] = high_prices[i];
        m_PriceData[i * 3 + 1] = low_prices[i];
        m_PriceData[i * 3 + 2] = close_prices[i];
        
        if (copied_volumes > i) {
            m_VolumeData[i] = volumes[i];
        } else {
            m_VolumeData[i] = 1; // Default volume
        }
        
        if (copied_times > i) {
            m_TimeData[i] = times[i];
        }
    }
    
    return true;
}

void CMarketProfile::CalculatePriceLevels() {
    if (m_DataCount == 0) {
        return;
    }
    
    // Find price range
    double min_price = m_PriceData[0];
    double max_price = m_PriceData[0];
    
    for (int i = 0; i < m_DataCount * 3; i++) {
        if (m_PriceData[i] < min_price) min_price = m_PriceData[i];
        if (m_PriceData[i] > max_price) max_price = m_PriceData[i];
    }
    
    // Get symbol tick size
    double tick_size = SymbolInfoDouble(m_Symbol, SYMBOL_TRADE_TICK_SIZE);
    if (tick_size <= 0) tick_size = 0.00001; // Default for forex
    
    m_CurrentProfile.TickSize = tick_size * m_Config.TicksPerLevel;
    m_CurrentProfile.MinPrice = min_price;
    m_CurrentProfile.MaxPrice = max_price;
    
    // Calculate number of levels
    int level_count = (int)((max_price - min_price) / m_CurrentProfile.TickSize) + 1;
    level_count = MathMin(level_count, MAX_PRICE_LEVELS);
    
    // Initialize price levels
    ArrayResize(m_CurrentProfile.Levels, level_count);
    m_CurrentProfile.LevelCount = level_count;
    
    for (int i = 0; i < level_count; i++) {
        m_CurrentProfile.Levels[i].Price = min_price + i * m_CurrentProfile.TickSize;
        m_CurrentProfile.Levels[i].Volume = 0;
        m_CurrentProfile.Levels[i].TimeSpent = 0;
        m_CurrentProfile.Levels[i].VolumePercent = 0.0;
        m_CurrentProfile.Levels[i].IsHighVolume = false;
        m_CurrentProfile.Levels[i].IsLowVolume = false;
        m_CurrentProfile.Levels[i].IsPOC = false;
        m_CurrentProfile.Levels[i].IsValueArea = false;
    }
}

void CMarketProfile::DistributeVolume() {
    if (m_DataCount == 0 || m_CurrentProfile.LevelCount == 0) {
        return;
    }
    
    m_CurrentProfile.TotalVolume = 0;
    
    // Distribute volume across price levels
    for (int bar = 0; bar < m_DataCount; bar++) {
        double high = m_PriceData[bar * 3];
        double low = m_PriceData[bar * 3 + 1];
        double close = m_PriceData[bar * 3 + 2];
        long volume = m_VolumeData[bar];
        
        // Find levels within this bar's range
        int start_level = PriceToLevel(low);
        int end_level = PriceToLevel(high);
        
        if (start_level == end_level) {
            // All volume goes to one level
            if (start_level >= 0 && start_level < m_CurrentProfile.LevelCount) {
                m_CurrentProfile.Levels[start_level].Volume += volume;
                m_CurrentProfile.Levels[start_level].TimeSpent++;
            }
        } else {
            // Distribute volume across multiple levels
            int level_count = end_level - start_level + 1;
            long volume_per_level = volume / level_count;
            
            for (int level = start_level; level <= end_level; level++) {
                if (level >= 0 && level < m_CurrentProfile.LevelCount) {
                    m_CurrentProfile.Levels[level].Volume += volume_per_level;
                    m_CurrentProfile.Levels[level].TimeSpent++;
                }
            }
        }
        
        m_CurrentProfile.TotalVolume += volume;
    }
    
    // Calculate volume percentages
    for (int i = 0; i < m_CurrentProfile.LevelCount; i++) {
        if (m_CurrentProfile.TotalVolume > 0) {
            m_CurrentProfile.Levels[i].VolumePercent = 
                (double)m_CurrentProfile.Levels[i].Volume / m_CurrentProfile.TotalVolume * 100.0;
        }
    }
}

void CMarketProfile::CalculateValueArea() {
    if (m_CurrentProfile.LevelCount == 0 || m_CurrentProfile.TotalVolume == 0) {
        return;
    }
    
    // Find POC (Point of Control) - level with highest volume
    int poc_index = 0;
    long max_volume = 0;
    
    for (int i = 0; i < m_CurrentProfile.LevelCount; i++) {
        if (m_CurrentProfile.Levels[i].Volume > max_volume) {
            max_volume = m_CurrentProfile.Levels[i].Volume;
            poc_index = i;
        }
    }
    
    m_CurrentProfile.ValueArea.POC = m_CurrentProfile.Levels[poc_index].Price;
    m_CurrentProfile.ValueArea.VolumeAtPOC = (double)max_volume;
    m_CurrentProfile.Levels[poc_index].IsPOC = true;
    
    // Calculate value area (default 70% of volume)
    long target_volume = (long)(m_CurrentProfile.TotalVolume * m_Config.ValueAreaPercent / 100.0);
    long accumulated_volume = max_volume;
    
    int va_high_index = poc_index;
    int va_low_index = poc_index;
    
    // Expand value area up and down from POC
    while (accumulated_volume < target_volume && 
           (va_high_index < m_CurrentProfile.LevelCount - 1 || va_low_index > 0)) {
        
        long volume_above = 0, volume_below = 0;
        
        if (va_high_index < m_CurrentProfile.LevelCount - 1) {
            volume_above = m_CurrentProfile.Levels[va_high_index + 1].Volume;
        }
        
        if (va_low_index > 0) {
            volume_below = m_CurrentProfile.Levels[va_low_index - 1].Volume;
        }
        
        // Add the side with more volume
        if (volume_above >= volume_below && va_high_index < m_CurrentProfile.LevelCount - 1) {
            va_high_index++;
            accumulated_volume += volume_above;
            m_CurrentProfile.Levels[va_high_index].IsValueArea = true;
        } else if (va_low_index > 0) {
            va_low_index--;
            accumulated_volume += volume_below;
            m_CurrentProfile.Levels[va_low_index].IsValueArea = true;
        } else {
            break;
        }
    }
    
    // Set value area boundaries
    m_CurrentProfile.ValueArea.VAH = m_CurrentProfile.Levels[va_high_index].Price;
    m_CurrentProfile.ValueArea.VAL = m_CurrentProfile.Levels[va_low_index].Price;
    m_CurrentProfile.ValueArea.ValueAreaVolume = (double)accumulated_volume;
    m_CurrentProfile.ValueArea.ValueAreaPercent = 
        (double)accumulated_volume / m_CurrentProfile.TotalVolume * 100.0;
    m_CurrentProfile.ValueArea.ValueAreaWidth = va_high_index - va_low_index + 1;
    m_CurrentProfile.ValueArea.IsValid = true;
}

int CMarketProfile::PriceToLevel(const double price) {
    if (m_CurrentProfile.TickSize <= 0) {
        return 0;
    }
    
    int level = (int)((price - m_CurrentProfile.MinPrice) / m_CurrentProfile.TickSize);
    return MathMax(0, MathMin(level, m_CurrentProfile.LevelCount - 1));
}

double CMarketProfile::LevelToPrice(const int level) {
    if (level < 0 || level >= m_CurrentProfile.LevelCount) {
        return 0.0;
    }
    
    return m_CurrentProfile.MinPrice + level * m_CurrentProfile.TickSize;
}

void CMarketProfile::AnalyzeMarketStructure() {
    // Determine market structure based on profile characteristics
    m_MarketContext.Structure = DetermineMarketStructure();
    m_MarketContext.StructureScore = CalculateStructureScore();
    m_MarketContext.IsBalanced = DetectBalance();
    m_MarketContext.IsTrending = DetectTrend();
    m_MarketContext.IsRotational = DetectRotation();
    
    // Calculate trend strength
    if (m_MarketContext.IsTrending) {
        double price_range = m_CurrentProfile.MaxPrice - m_CurrentProfile.MinPrice;
        double va_range = m_CurrentProfile.ValueArea.VAH - m_CurrentProfile.ValueArea.VAL;
        m_MarketContext.TrendStrength = (1.0 - va_range / price_range) * 100.0;
    } else {
        m_MarketContext.TrendStrength = 0.0;
    }
}

ENUM_MARKET_STRUCTURE CMarketProfile::DetermineMarketStructure() {
    if (m_CurrentProfile.LevelCount == 0) {
        return STRUCTURE_CONSOLIDATION;
    }
    
    // Analyze profile shape and distribution
    ENUM_PROFILE_SHAPE shape = m_CurrentProfile.Shape;
    double skewness = m_CurrentProfile.Skewness;
    
    // Determine structure based on shape and skewness
    if (shape == SHAPE_P_SHAPED || skewness > 0.5) {
        return STRUCTURE_TRENDING_UP;
    } else if (shape == SHAPE_B_SHAPED_DOWN || skewness < -0.5) {
        return STRUCTURE_TRENDING_DOWN;
    } else if (shape == SHAPE_B_SHAPED) {
        return STRUCTURE_ROTATIONAL;
    } else if (shape == SHAPE_RECTANGULAR) {
        return STRUCTURE_BALANCED;
    } else {
        return STRUCTURE_CONSOLIDATION;
    }
}

bool CMarketProfile::DetectBalance() {
    // Market is balanced if value area contains significant portion of price action
    double va_range = m_CurrentProfile.ValueArea.VAH - m_CurrentProfile.ValueArea.VAL;
    double total_range = m_CurrentProfile.MaxPrice - m_CurrentProfile.MinPrice;
    
    if (total_range <= 0) {
        return false;
    }
    
    double balance_ratio = va_range / total_range;
    return (balance_ratio > 0.6 && m_CurrentProfile.ValueArea.ValueAreaPercent > 65.0);
}

void CMarketProfile::LogProfileEvent(const string& event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO) {
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

//+------------------------------------------------------------------+
//| Initialize Data Arrays                                           |
//+------------------------------------------------------------------+
bool CMarketProfile::InitializeDataArrays() {
    if (m_pContext == NULL) {
        return false;
    }
    
    // Initialize ATR history for calculations
    int atr_buffer_size = 100; // Sufficient for volatility analysis
    if (ArrayResize(m_ATRHistory, atr_buffer_size) != atr_buffer_size) {
        LogProfileEvent("Failed to resize ATR history array", LOG_LEVEL_ERROR);
        return false;
    }
    ArraySetAsSeries(m_ATRHistory, true);
    
    // Initialize spread history for monitoring
    int spread_buffer_size = 50;
    if (ArrayResize(m_SpreadHistory, spread_buffer_size) != spread_buffer_size) {
        LogProfileEvent("Failed to resize spread history array", LOG_LEVEL_ERROR);
        return false;
    }
    ArraySetAsSeries(m_SpreadHistory, true);
    
    return true;
}

//+------------------------------------------------------------------+
//| Is New Bar                                                       |
//+------------------------------------------------------------------+
bool CMarketProfile::IsNewBar() {
    MqlRates rates[1];
    if (CopyRates(m_Symbol, m_Timeframe, 0, 1, rates) < 1) {
        return false;
    }
    
    if (rates[0].time > m_LastUpdateTime) {
        m_LastUpdateTime = rates[0].time;
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Update Market Data                                               |
//+------------------------------------------------------------------+
bool CMarketProfile::UpdateMarketData() {
    if (m_pContext == NULL || m_pContext.pIndicatorUtils == NULL) {
        return false;
    }
    
    // Save previous data
    m_PreviousData = m_CurrentData;
    
    // Get current price data
    MqlRates rates[1];
    if (CopyRates(m_Symbol, m_Timeframe, 0, 1, rates) < 1) {
        LogProfileEvent("Failed to get current price data", LOG_LEVEL_WARNING);
        return false;
    }
    
    // Update basic market data
    m_CurrentData.currentPrice = rates[0].close;
    m_CurrentData.currentHigh = rates[0].high;
    m_CurrentData.currentLow = rates[0].low;
    m_CurrentData.currentOpen = rates[0].open;
    m_CurrentData.previousPrice = m_PreviousData.currentPrice;
    m_CurrentData.timestamp = rates[0].time;
    m_CurrentData.symbol = m_Symbol;
    m_CurrentData.timeframe = m_Timeframe;
    
    // Update technical indicators
    m_CurrentData.currentSpread = (double)SymbolInfoInteger(m_Symbol, SYMBOL_SPREAD);
    m_CurrentData.atrCurrent = m_pContext.pIndicatorUtils.GetATR(0);
    m_CurrentData.atrPrevious = m_pContext.pIndicatorUtils.GetATR(1);
    
    // Calculate ATR ratio
    UpdateATRHistory();
    UpdateSpreadHistory();
    
    // Update other indicators
    m_CurrentData.adxValue = m_pContext.pIndicatorUtils.GetADX(0);
    m_CurrentData.adxSlope = m_CurrentData.adxValue - m_pContext.pIndicatorUtils.GetADX(1);
    m_CurrentData.diPlus = m_pContext.pIndicatorUtils.GetADXPlus(0);
    m_CurrentData.diMinus = m_pContext.pIndicatorUtils.GetADXMinus(0);
    
    m_CurrentData.rsiValue = m_pContext.pIndicatorUtils.GetRSI(0);
    m_CurrentData.rsiSlope = m_CurrentData.rsiValue - m_pContext.pIndicatorUtils.GetRSI(1);
    
    m_CurrentData.macdValue = m_pContext.pIndicatorUtils.GetMACDMain(0);
    m_CurrentData.macdSignal = m_pContext.pIndicatorUtils.GetMACDSignal(0);
    m_CurrentData.macdHistogram = m_CurrentData.macdValue - m_CurrentData.macdSignal;
    m_CurrentData.macdHistogramSlope = m_CurrentData.macdHistogram - 
        (m_pContext.pIndicatorUtils.GetMACDMain(1) - m_pContext.pIndicatorUtils.GetMACDSignal(1));
    
    // Update moving averages
    m_CurrentData.emaFast = m_pContext.pIndicatorUtils.GetEMA(m_pContext.Inputs.CoreStrategy.EmaFastPeriod, 0);
    m_CurrentData.emaMedium = m_pContext.pIndicatorUtils.GetEMA(m_pContext.Inputs.CoreStrategy.EmaMediumPeriod, 0);
    m_CurrentData.emaSlow = m_pContext.pIndicatorUtils.GetEMA(m_pContext.Inputs.CoreStrategy.EmaSlowPeriod, 0);
    
    // Multi-timeframe EMAs
    if (m_Config.UseMultiTimeframe) {
        m_CurrentData.emaFastH4 = m_pContext.pIndicatorUtils.GetEMA(m_pContext.Inputs.CoreStrategy.EmaFastPeriod, 0, m_Config.HigherTimeframe);
        m_CurrentData.emaMediumH4 = m_pContext.pIndicatorUtils.GetEMA(m_pContext.Inputs.CoreStrategy.EmaMediumPeriod, 0, m_Config.HigherTimeframe);
        m_CurrentData.emaSlowH4 = m_pContext.pIndicatorUtils.GetEMA(m_pContext.Inputs.CoreStrategy.EmaSlowPeriod, 0, m_Config.HigherTimeframe);
    }
    
    // Update Bollinger Bands
    m_CurrentData.bbWidth = m_pContext.pIndicatorUtils.GetBBWidth(0);
    m_CurrentData.bbUpper = m_pContext.pIndicatorUtils.GetBBUpper(0);
    m_CurrentData.bbLower = m_pContext.pIndicatorUtils.GetBBLower(0);
    m_CurrentData.bbMiddle = m_pContext.pIndicatorUtils.GetBBMiddle(0);
    
    // Update volume data
    long volumes[1];
    if (CopyTickVolume(m_Symbol, m_Timeframe, 0, 1, volumes) > 0) {
        m_CurrentData.currentVolume = volumes[0];
        // Calculate volume ratio if we have previous volume
        if (m_PreviousData.currentVolume > 0) {
            m_CurrentData.volumeRatio = (double)m_CurrentData.currentVolume / m_PreviousData.currentVolume;
        }
    }
    
    return ValidateMarketData();
}

//+------------------------------------------------------------------+
//| Update ATR History                                               |
//+------------------------------------------------------------------+
void CMarketProfile::UpdateATRHistory() {
    if (m_CurrentData.atrCurrent > 0) {
        // Shift array and add new value
        for (int i = ArraySize(m_ATRHistory) - 1; i > 0; i--) {
            m_ATRHistory[i] = m_ATRHistory[i - 1];
        }
        m_ATRHistory[0] = m_CurrentData.atrCurrent;
        
        // Calculate ATR ratio
        double sum = 0;
        int count = 0;
        for (int i = 1; i < MathMin(20, ArraySize(m_ATRHistory)); i++) {
            if (m_ATRHistory[i] > 0) {
                sum += m_ATRHistory[i];
                count++;
            }
        }
        
        if (count > 0) {
            m_CurrentData.averageDailyAtr = sum / count;
            m_CurrentData.atrRatio = m_CurrentData.atrCurrent / m_CurrentData.averageDailyAtr;
        } else {
            m_CurrentData.atrRatio = 1.0;
        }
    }
}

//+------------------------------------------------------------------+
//| Update Spread History                                            |
//+------------------------------------------------------------------+
void CMarketProfile::UpdateSpreadHistory() {
    if (m_CurrentData.currentSpread > 0) {
        // Shift array and add new value
        for (int i = ArraySize(m_SpreadHistory) - 1; i > 0; i--) {
            m_SpreadHistory[i] = m_SpreadHistory[i - 1];
        }
        m_SpreadHistory[0] = m_CurrentData.currentSpread;
        m_SpreadCount = MathMin(m_SpreadCount + 1, ArraySize(m_SpreadHistory));
    }
}

//+------------------------------------------------------------------+
//| Validate Market Data                                             |
//+------------------------------------------------------------------+
bool CMarketProfile::ValidateMarketData() {
    // Basic validation checks
    if (m_CurrentData.currentPrice <= 0) {
        LogProfileEvent("Invalid current price", LOG_LEVEL_WARNING);
        return false;
    }
    
    if (m_CurrentData.atrCurrent <= 0) {
        LogProfileEvent("Invalid ATR value", LOG_LEVEL_WARNING);
        return false;
    }
    
    if (m_CurrentData.adxValue < 0 || m_CurrentData.adxValue > 100) {
        LogProfileEvent("ADX value out of range", LOG_LEVEL_WARNING);
        return false;
    }
    
    if (m_CurrentData.rsiValue < 0 || m_CurrentData.rsiValue > 100) {
        LogProfileEvent("RSI value out of range", LOG_LEVEL_WARNING);
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Analyze Market Regime                                            |
//+------------------------------------------------------------------+
void CMarketProfile::AnalyzeMarketRegime() {
    if (!m_bInitialized) {
        return;
    }
    
    // Determine trend and regime
    m_MarketContext.Trend = DetermineTrend();
    m_MarketContext.Regime = DetermineMarketRegime();
    m_MarketContext.TrendStrength = CalculateTrendStrength();
    m_MarketContext.RegimeConfidence = CalculateRegimeConfidence();
    
    // Detect market conditions
    m_CurrentData.isTrending = (m_CurrentData.adxValue > 25.0 && m_MarketContext.TrendStrength > m_Config.TrendThreshold);
    m_CurrentData.isSidewaysOrChoppy = CheckSidewaysMarket() || CheckChoppyMarket();
    m_CurrentData.isLowMomentum = CheckLowMomentum();
    m_CurrentData.isVolatile = CheckHighVolatility();
    m_CurrentData.isTransitioning = DetectRegimeTransition();
    
    // Update market context
    m_MarketContext.IsTrending = m_CurrentData.isTrending;
    m_MarketContext.IsVolatile = m_CurrentData.isVolatile;
    m_MarketContext.IsTransitioning = m_CurrentData.isTransitioning;
    m_MarketContext.VolatilityRatio = m_CurrentData.atrRatio;
    m_MarketContext.MomentumStrength = CalculateMomentumScore();
    
    // Log regime changes
    if (m_MarketContext.Regime != m_PreviousData.regime) {
        m_MarketContext.LastRegimeChange = TimeCurrent();
        LogProfileEvent(StringFormat("Market regime changed to: %s", EnumToString(m_MarketContext.Regime)), LOG_LEVEL_INFO);
    }
}

//+------------------------------------------------------------------+
//| Determine Market Regime                                          |
//+------------------------------------------------------------------+
ENUM_MARKET_REGIME CMarketProfile::DetermineMarketRegime() {
    double adx = m_CurrentData.adxValue;
    double atrRatio = m_CurrentData.atrRatio;
    ENUM_MARKET_TREND trend = m_MarketContext.Trend;
    
    // High volatility conditions
    if (atrRatio > m_Config.VolatilityThreshold * 1.5) {
        return REGIME_VOLATILE_EXPANSION;
    }
    
    // Low volatility conditions
    if (atrRatio < 0.7) {
        return REGIME_VOLATILE_CONTRACTION;
    }
    
    // Trending conditions
    if (adx > 30 && m_MarketContext.TrendStrength > 50) {
        if (trend == TREND_UP_STRONG || trend == TREND_UP_NORMAL) {
            return REGIME_TRENDING_BULL;
        } else if (trend == TREND_DOWN_STRONG || trend == TREND_DOWN_NORMAL) {
            return REGIME_TRENDING_BEAR;
        }
    }
    
    // Ranging conditions
    if (adx < 25 && m_MarketContext.TrendStrength < 30) {
        if (atrRatio > 1.2) {
            return REGIME_RANGING_VOLATILE;
        } else {
            return REGIME_RANGING_STABLE;
        }
    }
    
    // Transition detection
    if (m_CurrentData.isTransitioning) {
        return REGIME_TRANSITION;
    }
    
    return REGIME_UNKNOWN;
}

//+------------------------------------------------------------------+
//| Determine Trend                                                  |
//+------------------------------------------------------------------+
ENUM_MARKET_TREND CMarketProfile::DetermineTrend() {
    double emaFast = m_CurrentData.emaFast;
    double emaMedium = m_CurrentData.emaMedium;
    double emaSlow = m_CurrentData.emaSlow;
    double currentPrice = m_CurrentData.currentPrice;
    double adx = m_CurrentData.adxValue;
    
    // Check EMA alignment
    bool bullishAlignment = (emaFast > emaMedium && emaMedium > emaSlow);
    bool bearishAlignment = (emaFast < emaMedium && emaMedium < emaSlow);
    
    // Price position relative to EMAs
    bool priceAboveEMAs = (currentPrice > emaFast && currentPrice > emaMedium);
    bool priceBelowEMAs = (currentPrice < emaFast && currentPrice < emaMedium);
    
    // Strong trend conditions
    if (bullishAlignment && priceAboveEMAs && adx > 30) {
        return TREND_UP_STRONG;
    }
    if (bearishAlignment && priceBelowEMAs && adx > 30) {
        return TREND_DOWN_STRONG;
    }
    
    // Normal trend conditions
    if (bullishAlignment && adx > 20) {
        return TREND_UP_NORMAL;
    }
    if (bearishAlignment && adx > 20) {
        return TREND_DOWN_NORMAL;
    }
    
    // Weak trend conditions
    if (bullishAlignment || (currentPrice > emaMedium && adx > 15)) {
        return TREND_UP_WEAK;
    }
    if (bearishAlignment || (currentPrice < emaMedium && adx > 15)) {
        return TREND_DOWN_WEAK;
    }
    
    // Sideways
    if (adx < 20) {
        return TREND_SIDEWAYS;
    }
    
    return TREND_UNDEFINED;
}

//+------------------------------------------------------------------+
//| Calculate Trend Strength                                         |
//+------------------------------------------------------------------+
double CMarketProfile::CalculateTrendStrength() {
    double strength = 0.0;
    
    // ADX component (40% weight)
    strength += (m_CurrentData.adxValue / 100.0) * 40.0;
    
    // EMA alignment component (30% weight)
    double emaFast = m_CurrentData.emaFast;
    double emaMedium = m_CurrentData.emaMedium;
    double emaSlow = m_CurrentData.emaSlow;
    
    double emaSpread = MathAbs(emaFast - emaSlow);
    double priceLevel = (emaFast + emaSlow) / 2.0;
    double emaStrength = 0.0;
    
    if (priceLevel > 0) {
        emaStrength = (emaSpread / priceLevel) * 100.0;
        emaStrength = MathMin(emaStrength, 30.0); // Cap at 30%
    }
    strength += emaStrength;
    
    // Price momentum component (20% weight)
    double priceChange = 0.0;
    if (m_PreviousData.currentPrice > 0) {
        priceChange = MathAbs(m_CurrentData.currentPrice - m_PreviousData.currentPrice);
        double momentumStrength = (priceChange / m_CurrentData.atrCurrent) * 10.0;
        momentumStrength = MathMin(momentumStrength, 20.0); // Cap at 20%
        strength += momentumStrength;
    }
    
    // Volume component (10% weight)
    if (m_CurrentData.volumeRatio > 1.0) {
        double volumeStrength = MathMin((m_CurrentData.volumeRatio - 1.0) * 10.0, 10.0);
        strength += volumeStrength;
    }
    
    return MathMin(strength, 100.0);
}

//+------------------------------------------------------------------+
//| Calculate Regime Confidence                                      |
//+------------------------------------------------------------------+
double CMarketProfile::CalculateRegimeConfidence() {
    double confidence = 0.0;
    
    // ADX confidence
    if (m_CurrentData.adxValue > 30) {
        confidence += 0.4;
    } else if (m_CurrentData.adxValue > 20) {
        confidence += 0.3;
    } else {
        confidence += 0.1;
    }
    
    // Trend consistency
    if (m_MarketContext.TrendStrength > 50) {
        confidence += 0.3;
    } else if (m_MarketContext.TrendStrength > 25) {
        confidence += 0.2;
    } else {
        confidence += 0.1;
    }
    
    // Multi-timeframe alignment
    if (m_Config.UseMultiTimeframe && IsMultiTimeframeAligned()) {
        confidence += 0.2;
    } else {
        confidence += 0.1;
    }
    
    // Volatility consistency
    if (m_CurrentData.atrRatio > 0.8 && m_CurrentData.atrRatio < 1.5) {
        confidence += 0.1;
    }
    
    return MathMin(confidence, 1.0);
}

//+------------------------------------------------------------------+
//| Detect Regime Transition                                         |
//+------------------------------------------------------------------+
bool CMarketProfile::DetectRegimeTransition() {
    // Check for regime transition signals
    
    // ADX direction change
    bool adxDirectionChange = (m_CurrentData.adxSlope > 0 && m_PreviousData.adxSlope < 0) ||
                             (m_CurrentData.adxSlope < 0 && m_PreviousData.adxSlope > 0);
    
    // Significant volatility change
    bool volatilityChange = MathAbs(m_CurrentData.atrRatio - 1.0) > 0.3;
    
    // MACD histogram change
    bool macdChange = (m_CurrentData.macdHistogramSlope > 0 && m_PreviousData.macdHistogramSlope < 0) ||
                     (m_CurrentData.macdHistogramSlope < 0 && m_PreviousData.macdHistogramSlope > 0);
    
    return adxDirectionChange || volatilityChange || macdChange;
}

//+------------------------------------------------------------------+
//| Check Low Momentum                                               |
//+------------------------------------------------------------------+
bool CMarketProfile::CheckLowMomentum() {
    // Low ADX indicates low momentum
    if (m_CurrentData.adxValue < 20) {
        return true;
    }
    
    // Small price movements relative to ATR
    if (m_PreviousData.currentPrice > 0) {
        double priceChange = MathAbs(m_CurrentData.currentPrice - m_PreviousData.currentPrice);
        if (priceChange < m_CurrentData.atrCurrent * 0.3) {
            return true;
        }
    }
    
    // Low volume
    if (m_CurrentData.volumeRatio < 0.7) {
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Check High Volatility                                            |
//+------------------------------------------------------------------+
bool CMarketProfile::CheckHighVolatility() {
    // High ATR ratio
    if (m_CurrentData.atrRatio > m_Config.VolatilityThreshold) {
        return true;
    }
    
    // Wide Bollinger Bands
    if (m_CurrentData.bbWidth > m_CurrentData.atrCurrent * 2.0) {
        return true;
    }
    
    // Large recent price movements
    double priceRange = m_CurrentData.currentHigh - m_CurrentData.currentLow;
    if (priceRange > m_CurrentData.atrCurrent * 1.5) {
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Check Sideways Market                                            |
//+------------------------------------------------------------------+
bool CMarketProfile::CheckSidewaysMarket() {
    double score = CalculateSidewaysScore();
    return (score >= 70.0);
}

//+------------------------------------------------------------------+
//| Check Choppy Market                                              |
//+------------------------------------------------------------------+
bool CMarketProfile::CheckChoppyMarket() {
    double score = CalculateChoppyScore();
    return (score >= 70.0);
}

//+------------------------------------------------------------------+
//| Calculate Choppy Score                                           |
//+------------------------------------------------------------------+
double CMarketProfile::CalculateChoppyScore() {
    double choppyScore = 0.0;
    
    // ADX component (low ADX = choppy)
    if (m_CurrentData.adxValue < 20) {
        choppyScore += 30.0;
    } else if (m_CurrentData.adxValue < 25) {
        choppyScore += 20.0;
    }
    
    // RSI whipsaws
    if (m_CurrentData.rsiValue > 30 && m_CurrentData.rsiValue < 70) {
        choppyScore += 25.0;
    }
    
    // MACD histogram oscillations
    if (MathAbs(m_CurrentData.macdHistogramSlope) > MathAbs(m_CurrentData.macdHistogram) * 0.5) {
        choppyScore += 25.0;
    }
    
    // Narrow Bollinger Bands
    if (m_CurrentData.bbWidth < m_CurrentData.atrCurrent * 0.8) {
        choppyScore += 20.0;
    }
    
    return MathMin(choppyScore, 100.0);
}

//+------------------------------------------------------------------+
//| Calculate Sideways Score                                         |
//+------------------------------------------------------------------+
double CMarketProfile::CalculateSidewaysScore() {
    double sidewaysScore = 0.0;
    
    // ADX component (low ADX = sideways)
    if (m_CurrentData.adxValue < 20) {
        sidewaysScore += 40.0;
    } else if (m_CurrentData.adxValue < 25) {
        sidewaysScore += 25.0;
    }
    
    // EMA convergence
    double emaSpread = MathAbs(m_CurrentData.emaFast - m_CurrentData.emaSlow);
    if (emaSpread < m_CurrentData.atrCurrent) {
        sidewaysScore += 30.0;
    }
    
    // Price within Bollinger Bands middle
    double bbMiddle = m_CurrentData.bbMiddle;
    double bbRange = m_CurrentData.bbUpper - m_CurrentData.bbLower;
    if (bbRange > 0) {
        double pricePosition = MathAbs(m_CurrentData.currentPrice - bbMiddle) / (bbRange / 2.0);
        if (pricePosition < 0.5) {
            sidewaysScore += 30.0;
        }
    }
    
    return MathMin(sidewaysScore, 100.0);
}

//+------------------------------------------------------------------+
//| Calculate Momentum Score                                         |
//+------------------------------------------------------------------+
double CMarketProfile::CalculateMomentumScore() {
    double momentumScore = 0.0;
    
    // RSI momentum
    if (m_CurrentData.rsiValue > 70 || m_CurrentData.rsiValue < 30) {
        momentumScore += 25.0;
    }
    
    // MACD momentum
    if (m_CurrentData.macdHistogram > 0 && m_CurrentData.macdHistogramSlope > 0) {
        momentumScore += 25.0;
    } else if (m_CurrentData.macdHistogram < 0 && m_CurrentData.macdHistogramSlope < 0) {
        momentumScore += 25.0;
    }
    
    // ADX strength
    momentumScore += (m_CurrentData.adxValue / 100.0) * 25.0;
    
    // Price momentum
    if (m_PreviousData.currentPrice > 0) {
        double priceChange = MathAbs(m_CurrentData.currentPrice - m_PreviousData.currentPrice);
        double priceMomentum = (priceChange / m_CurrentData.atrCurrent) * 25.0;
        momentumScore += MathMin(priceMomentum, 25.0);
    }
    
    return MathMin(momentumScore, 100.0);
}

//+------------------------------------------------------------------+
//| Multi-timeframe Analysis                                         |
//+------------------------------------------------------------------+
bool CMarketProfile::AnalyzeMultiTimeframe() {
    if (!m_Config.UseMultiTimeframe) {
        return true;
    }
    
    m_MarketContext.MTFAlignment = CheckMTFAlignment();
    m_MarketContext.MTFStrength = CalculateMTFStrength();
    
    m_CurrentData.mtfBullishAlignment = m_MarketContext.MTFAlignment && 
        (m_MarketContext.Trend == TREND_UP_STRONG || m_MarketContext.Trend == TREND_UP_NORMAL);
    m_CurrentData.mtfBearishAlignment = m_MarketContext.MTFAlignment && 
        (m_MarketContext.Trend == TREND_DOWN_STRONG || m_MarketContext.Trend == TREND_DOWN_NORMAL);
    m_CurrentData.mtfStrength = m_MarketContext.MTFStrength;
    
    return true;
}

//+------------------------------------------------------------------+
//| Check Multi-timeframe Alignment                                  |
//+------------------------------------------------------------------+
bool CMarketProfile::CheckMTFAlignment() {
    if (!m_Config.UseMultiTimeframe) {
        return false;
    }
    
    // Compare current timeframe EMAs with higher timeframe EMAs
    bool h1Bullish = (m_CurrentData.emaFast > m_CurrentData.emaMedium && m_CurrentData.emaMedium > m_CurrentData.emaSlow);
    bool h1Bearish = (m_CurrentData.emaFast < m_CurrentData.emaMedium && m_CurrentData.emaMedium < m_CurrentData.emaSlow);
    
    bool h4Bullish = (m_CurrentData.emaFastH4 > m_CurrentData.emaMediumH4 && m_CurrentData.emaMediumH4 > m_CurrentData.emaSlowH4);
    bool h4Bearish = (m_CurrentData.emaFastH4 < m_CurrentData.emaMediumH4 && m_CurrentData.emaMediumH4 < m_CurrentData.emaSlowH4);
    
    // Check for alignment
    return (h1Bullish && h4Bullish) || (h1Bearish && h4Bearish);
}

//+------------------------------------------------------------------+
//| Calculate Multi-timeframe Strength                               |
//+------------------------------------------------------------------+
double CMarketProfile::CalculateMTFStrength() {
    if (!m_Config.UseMultiTimeframe) {
        return 0.0;
    }
    
    double strength = 0.0;
    
    // EMA separation on H1
    double h1Separation = MathAbs(m_CurrentData.emaFast - m_CurrentData.emaSlow);
    double h1Price = (m_CurrentData.emaFast + m_CurrentData.emaSlow) / 2.0;
    if (h1Price > 0) {
        strength += (h1Separation / h1Price) * 50.0;
    }
    
    // EMA separation on H4
    double h4Separation = MathAbs(m_CurrentData.emaFastH4 - m_CurrentData.emaSlowH4);
    double h4Price = (m_CurrentData.emaFastH4 + m_CurrentData.emaSlowH4) / 2.0;
    if (h4Price > 0) {
        strength += (h4Separation / h4Price) * 50.0;
    }
    
    return MathMin(strength, 100.0);
}

//+------------------------------------------------------------------+
//| Enhanced Public Methods                                          |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Is Trend Strong Enough                                           |
//+------------------------------------------------------------------+
bool CMarketProfile::IsTrendStrongEnough() const {
    return (m_MarketContext.TrendStrength > m_Config.TrendThreshold && 
            m_CurrentData.adxValue > 25.0);
}

//+------------------------------------------------------------------+
//| Is Multi-timeframe Aligned                                       |
//+------------------------------------------------------------------+
bool CMarketProfile::IsMultiTimeframeAligned() const {
    return m_MarketContext.MTFAlignment;
}

//+------------------------------------------------------------------+
//| Validate Multi-timeframe Trend                                   |
//+------------------------------------------------------------------+
bool CMarketProfile::ValidateMultiTimeframeTrend(bool isLong) {
    if (!m_Config.UseMultiTimeframe) {
        return true; // No MTF validation required
    }
    
    if (isLong) {
        return m_CurrentData.mtfBullishAlignment;
    } else {
        return m_CurrentData.mtfBearishAlignment;
    }
}

//+------------------------------------------------------------------+
//| Calculate Pullback Percent                                       |
//+------------------------------------------------------------------+
double CMarketProfile::CalculatePullbackPercent(bool isLong) const {
    if (m_CurrentData.emaFast == 0 || m_CurrentData.emaSlow == 0) {
        return 0.0;
    }
    
    double currentPrice = m_CurrentData.currentPrice;
    double fastEMA = m_CurrentData.emaFast;
    double slowEMA = m_CurrentData.emaSlow;
    
    if (isLong) {
        // For long trades, calculate pullback from swing high
        double trendDirection = fastEMA - slowEMA;
        if (trendDirection > 0) {
            double pullbackDistance = fastEMA - currentPrice;
            return (pullbackDistance / m_CurrentData.atrCurrent) * 100.0;
        }
    } else {
        // For short trades, calculate pullback from swing low
        double trendDirection = slowEMA - fastEMA;
        if (trendDirection > 0) {
            double pullbackDistance = currentPrice - fastEMA;
            return (pullbackDistance / m_CurrentData.atrCurrent) * 100.0;
        }
    }
    
    return 0.0;
}

//+------------------------------------------------------------------+
//| Is Price In Pullback Zone                                        |
//+------------------------------------------------------------------+
bool CMarketProfile::IsPriceInPullbackZone(bool isLong) {
    double pullbackPercent = CalculatePullbackPercent(isLong);
    return (pullbackPercent >= 38.2 && pullbackPercent <= 61.8); // Fibonacci retracement zone
}

//+------------------------------------------------------------------+
//| Is Valid Pullback Entry                                          |
//+------------------------------------------------------------------+
bool CMarketProfile::IsValidPullbackEntry(bool isLong, double entryPrice) {
    // Check if entry price is in pullback zone
    if (!IsPriceInPullbackZone(isLong)) {
        return false;
    }
    
    // Check trend strength
    if (!IsTrendStrongEnough()) {
        return false;
    }
    
    // Check multi-timeframe alignment
    if (!ValidateMultiTimeframeTrend(isLong)) {
        return false;
    }
    
    // Check market conditions
    if (m_CurrentData.isSidewaysOrChoppy || m_CurrentData.isLowMomentum) {
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Calculate Enhanced Statistics                                    |
//+------------------------------------------------------------------+
void CMarketProfile::CalculateEnhancedStatistics() {
    // Calculate volatility index
    m_Stats.VolatilityIndex = m_CurrentData.atrRatio * 100.0;
    
    // Calculate trend intensity
    m_Stats.TrendIntensity = m_MarketContext.TrendStrength;
    
    // Calculate market efficiency (price movement vs volatility)
    if (m_CurrentData.atrCurrent > 0 && m_PreviousData.currentPrice > 0) {
        double priceMove = MathAbs(m_CurrentData.currentPrice - m_PreviousData.currentPrice);
        m_Stats.MarketEfficiency = (priceMove / m_CurrentData.atrCurrent) * 100.0;
    }
    
    // Calculate liquidity score (based on volume and spread)
    double baseScore = 50.0;
    if (m_CurrentData.volumeRatio > 1.0) {
        baseScore += (m_CurrentData.volumeRatio - 1.0) * 25.0;
    }
    if (m_SpreadCount > 5) {
        double avgSpread = 0;
        for (int i = 0; i < MathMin(5, m_SpreadCount); i++) {
            avgSpread += m_SpreadHistory[i];
        }
        avgSpread /= 5.0;
        if (m_CurrentData.currentSpread < avgSpread) {
            baseScore += 25.0;
        }
    }
    m_Stats.LiquidityScore = MathMin(baseScore, 100.0);
}

//+------------------------------------------------------------------+
//| Get Regime Analysis                                              |
//+------------------------------------------------------------------+
string CMarketProfile::GetRegimeAnalysis() {
    string analysis = "=== MARKET REGIME ANALYSIS ===\n";
    analysis += StringFormat("Current Regime: %s (Confidence: %.1f%%)\n", 
        EnumToString(m_MarketContext.Regime), m_MarketContext.RegimeConfidence * 100);
    analysis += StringFormat("Market Trend: %s (Strength: %.1f%%)\n", 
        EnumToString(m_MarketContext.Trend), m_MarketContext.TrendStrength);
    analysis += StringFormat("Volatility Ratio: %.2f\n", m_MarketContext.VolatilityRatio);
    analysis += StringFormat("Momentum Strength: %.1f%%\n", m_MarketContext.MomentumStrength);
    analysis += StringFormat("Market Conditions:\n");
    analysis += StringFormat("  - Trending: %s\n", m_CurrentData.isTrending ? "Yes" : "No");
    analysis += StringFormat("  - Sideways/Choppy: %s\n", m_CurrentData.isSidewaysOrChoppy ? "Yes" : "No");
    analysis += StringFormat("  - Low Momentum: %s\n", m_CurrentData.isLowMomentum ? "Yes" : "No");
    analysis += StringFormat("  - High Volatility: %s\n", m_CurrentData.isVolatile ? "Yes" : "No");
    analysis += StringFormat("  - Transitioning: %s\n", m_CurrentData.isTransitioning ? "Yes" : "No");
    
    if (m_Config.UseMultiTimeframe) {
        analysis += StringFormat("Multi-timeframe Alignment: %s (Strength: %.1f%%)\n", 
            m_MarketContext.MTFAlignment ? "Yes" : "No", m_MarketContext.MTFStrength);
    }
    
    return analysis;
}

//+------------------------------------------------------------------+
//| Calculate Slope                                                  |
//+------------------------------------------------------------------+
double CMarketProfile::CalculateSlope(const double& buffer[], int periods = 5) {
    if (ArraySize(buffer) < periods || periods < 2) {
        return 0.0;
    }
    
    double sum_x = 0, sum_y = 0, sum_xy = 0, sum_x2 = 0;
    
    for (int i = 0; i < periods; i++) {
        sum_x += i;
        sum_y += buffer[i];
        sum_xy += i * buffer[i];
        sum_x2 += i * i;
    }
    
    double denominator = periods * sum_x2 - sum_x * sum_x;
    if (denominator == 0) {
        return 0.0;
    }
    
    return (periods * sum_xy - sum_x * sum_y) / denominator;
}

} // namespace ApexPullback::v5

#endif // MARKET_PROFILE_MQH_