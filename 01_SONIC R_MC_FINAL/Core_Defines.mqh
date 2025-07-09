//+------------------------------------------------------------------+
//|                                                 Core_Defines.mqh |
//|                                                 Core_Defines.mqh |
//|                           Sonic R EA - Core Definitions        |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Cáo Già & Đại Bàng"
#property link      ""
#property version   "1.00"

//+------------------------------------------------------------------+
//| CORE INCLUDES                                                    |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Indicators\Indicators.mqh>
#include <Math\Stat\Math.mqh>

//+------------------------------------------------------------------+
//| STRATEGY ENUMERATIONS                                            |
//+------------------------------------------------------------------+
enum ENUM_STRATEGY_TYPE
  {
   STRATEGY_NONE = -1,              // No strategy
   STRATEGY_SONIC_R = 0,            // Sonic R strategy
   STRATEGY_SONIC_R_INTEGRATION = 1 // Sonic R Integration strategy
  };

enum ENUM_ALLOWED_DIRECTION {
    DIRECTION_LONG = 0,         // Long only
    DIRECTION_SHORT = 1,        // Short only
    DIRECTION_BOTH = 2,         // Both directions
    DIRECTION_BUY_ONLY = 0,     // Alias for long only
    DIRECTION_SELL_ONLY = 1     // Alias for short only
};

//+------------------------------------------------------------------+
//| LOG LEVEL ENUMERATION                                            |
//+------------------------------------------------------------------+
enum ENUM_LOG_LEVEL {
    LOG_LEVEL_ERROR = 0,        // Error messages only
    LOG_LEVEL_WARNING = 1,      // Warning and error messages
    LOG_LEVEL_INFO = 2,         // Info, warning, and error messages
    LOG_LEVEL_DEBUG = 3         // All messages including debug
};

// LOG LEVEL CONSTANTS (for input compatibility)
#define LOG_ERROR_LEVEL   0
#define LOG_WARNING_LEVEL 1  
#define LOG_INFO_LEVEL    2
#define LOG_DEBUG_LEVEL   3

enum ENUM_SIGNAL_TYPE {
    SIGNAL_TYPE_NONE = 0,            // No signal
    SIGNAL_TYPE_BUY = 1,             // Buy signal
    SIGNAL_TYPE_SELL = 2             // Sell signal
};

// Add missing ENUM_SIGNAL_DIRECTION
enum ENUM_SIGNAL_DIRECTION {
    SIGNAL_DIRECTION_NONE = 0,       // No direction
    SIGNAL_DIRECTION_BUY = 1,        // Buy direction
    SIGNAL_DIRECTION_SELL = 2,       // Sell direction
    SIGNAL_DIRECTION_LONG = 1,       // Alias for buy
    SIGNAL_DIRECTION_SHORT = 2       // Alias for sell
};

enum ENUM_NEWS_FILTER {
    NEWS_FILTER_OFF = 0,        // No news filtering
    NEWS_FILTER_LOW = 1,        // Low impact news
    NEWS_FILTER_MEDIUM = 2,     // Medium impact news
    NEWS_FILTER_HIGH = 3,       // High impact news
    NEWS_FILTER_NONE = 0,       // Alias for no filtering
    NEWS_FILTER_HIGH_IMPACT = 3, // Alias for high impact
    NEWS_FILTER_ALL = 3         // Alias for all news
};

enum ENUM_TRADE_STATE {
    TRADE_STATE_NONE = 0,       // No trade state
    TRADE_STATE_PENDING = 1,    // Trade pending
    TRADE_STATE_OPEN = 2,       // Trade open
    TRADE_STATE_CLOSED = 3,     // Trade closed
    TRADE_STATE_CANCELLED = 4,  // Trade cancelled
    TRADE_STATE_ACTIVE = 2      // Alias for open trade
};

enum ENUM_LOT_SIZE_MODE {
    LOT_MODE_FIXED = 0,         // Fixed lot size
    LOT_MODE_RISK_PERCENT = 1,  // Risk percentage based
    LOT_MODE_BALANCE_PERCENT = 2 // Balance percentage based
};

enum ENUM_SESSION_FILTER {
    FILTER_ALL_SESSIONS = 0,    // All trading sessions
    FILTER_LONDON_ONLY = 1,     // London session only
    FILTER_NEW_YORK_ONLY = 2,   // New York session only
    FILTER_ASIAN_ONLY = 3       // Asian session only
};

enum ENUM_DASHBOARD_THEME {
    THEME_DARK = 0,             // Dark theme
    THEME_LIGHT = 1             // Light theme
};

enum ENUM_MARKET_REGIME
{
    REGIME_UNDEFINED,
    REGIME_TRENDING_BULL,       // Xu hướng tăng rõ rệt
    REGIME_TRENDING_BEAR,       // Xu hướng giảm rõ rệt
    REGIME_BULL_PULLBACK,       // Điều chỉnh trong xu hướng tăng
    REGIME_BEAR_PULLBACK,       // Điều chỉnh trong xu hướng giảm
    REGIME_RANGING_STABLE,      // Đi ngang ổn định
    REGIME_VOLATILE_EXPANSION   // Biến động mạnh, mở rộng
};



//+------------------------------------------------------------------+
//| SONIC R ENUMERATIONS & STRUCTURES                                |
//+------------------------------------------------------------------+

// --- From Analysis_SonicR_PVSRA.mqh ---
enum ENUM_VPSRA_RHYTHM_STATE
{
    RHYTHM_UNKNOWN,                 // Not enough data or undefined state
    RHYTHM_CONVERGENCE_BULLISH,     // Strong up-move confirmed by high volume
    RHYTHM_CONVERGENCE_BEARISH,     // Strong down-move confirmed by high volume
    RHYTHM_DIVERGENCE_BULLISH,      // Down-move on low volume (potential reversal)
    RHYTHM_DIVERGENCE_BEARISH,      // Up-move on low volume (potential reversal)
    RHYTHM_EXHAUSTION_TOP,          // Climax volume on up-move (potential top)
    RHYTHM_EXHAUSTION_BOTTOM        // Climax volume on down-move (potential bottom)
};

struct SVPSRAInfo
{
    ENUM_VPSRA_RHYTHM_STATE rhythmState;    // The determined market rhythm
    double                  rhythmScore;    // A numerical score of the rhythm's strength/confidence
    bool                    isHighVolume;   // Is current volume significantly high?
    bool                    isLowVolume;    // Is current volume significantly low?
    double                  swingStrength;  // Strength of the last price swing
    double                  volumeStrength; // Strength of the volume during the last swing
};

// --- From Signal_SonicR_ScoutEntry.mqh ---
struct SScoutEntryConfig
{
    int lookbackPeriod;
    double minPullbackRatio;
    double maxPullbackRatio;
    bool useDragonBandFilter;
    double dragonBandTolerance;
    bool useWaveValidation;
    int minWavePoints;
    bool usePVSRAConfirmation;
    double minVolumeThreshold;
    double maxRiskPerEntry;
    int maxConcurrentScouts;
    int entryTimeoutMinutes;
    int confirmationCandles;
};

enum ENUM_SCOUT_ENTRY_TYPE
{
    SCOUT_ENTRY_NONE,
    SCOUT_ENTRY_PULLBACK_BUY,
    SCOUT_ENTRY_PULLBACK_SELL,
    SCOUT_ENTRY_BREAKOUT_BUY,
    SCOUT_ENTRY_BREAKOUT_SELL,
    SCOUT_ENTRY_REVERSAL_BUY,
    SCOUT_ENTRY_REVERSAL_SELL
};

enum ENUM_SCOUT_STATE
{
    SCOUT_STATE_INACTIVE,
    SCOUT_STATE_DETECTING,
    SCOUT_STATE_VALIDATING,
    SCOUT_STATE_CONFIRMED,
    SCOUT_STATE_EXECUTED,
    SCOUT_STATE_CANCELLED,
    SCOUT_STATE_EXPIRED
};

struct SScoutEntryInfo
{
    ENUM_SCOUT_ENTRY_TYPE entryType;
    ENUM_SCOUT_STATE state;
    ENUM_SIGNAL_DIRECTION direction;
    double entryPrice;
    double stopLoss;
    double takeProfit;
    double currentPrice;
    double pullbackLevel;
    double pullbackRatio;
    double supportResistanceLevel;
    bool dragonBandConfirmed;
    bool wavePatternConfirmed;
    bool pvsraConfirmed;
    bool volumeConfirmed;
    double entryQuality;
    double riskRewardRatio;
    double probabilitySuccess;
    datetime detectionTime;
    datetime confirmationTime;
    datetime expirationTime;
    int confirmationCandles;
    double riskAmount;
    double positionSize;
    string patternDescription;
    int patternId;
};

//+------------------------------------------------------------------+
//| CORE STRUCTURES                                                  |
//+------------------------------------------------------------------+

// Structure to hold indicator definition for iCustom
struct MqlIndicator
{
    string          name;               // Indicator name (e.g., "Moving Average")
    uint            num_parameters;     // Number of parameters
    MqlParam        parameters[];       // Array of parameters
};

// SSignalInfo moved to Shared_DataStructures.mqh to avoid duplicates

struct STradeRequest {
    string              Symbol;             // Trading symbol
    ENUM_ORDER_TYPE     Type;               // Order type
    double              Volume;             // Trade volume
    double              Price;              // Entry price
    double              StopLoss;           // Stop loss
    double              TakeProfit;         // Take profit
    string              Comment;            // Trade comment
    ulong               Magic;              // Magic number
    datetime            Expiration;         // Order expiration
    
    // Constructor
    STradeRequest() {
        Symbol = "";
        Type = ORDER_TYPE_BUY;
        Volume = 0.0;
        Price = 0.0;
        StopLoss = 0.0;
        TakeProfit = 0.0;
        Comment = "";
        Magic = 0;
        Expiration = 0;
    }
};

struct SPerformanceData {
    int                 TotalTrades;        // Total number of trades
    int                 WinningTrades;      // Number of winning trades
    int                 LosingTrades;       // Number of losing trades
    double              TotalProfit;        // Total profit
    double              TotalLoss;          // Total loss
    double              WinRate;            // Win rate percentage
    double              ProfitFactor;       // Profit factor
    double              MaxDrawdown;        // Maximum drawdown
    double              CurrentDrawdown;    // Current drawdown
    double              Sharpe;             // Sharpe ratio
    datetime            LastUpdate;         // Last update time
    
    // Constructor
    SPerformanceData() {
        TotalTrades = 0;
        WinningTrades = 0;
        LosingTrades = 0;
        TotalProfit = 0.0;
        TotalLoss = 0.0;
        WinRate = 0.0;
        ProfitFactor = 0.0;
        MaxDrawdown = 0.0;
        CurrentDrawdown = 0.0;
        Sharpe = 0.0;
        LastUpdate = 0;
    }
};

struct SRiskData {
    double              MaxRiskPercent;     // Maximum risk per trade
    double              MaxDailyRisk;       // Maximum daily risk
    double              CurrentRisk;        // Current risk exposure
    double              DailyRisk;          // Current daily risk
    bool                CanTrade;           // Can trade flag
    double              AccountBalance;     // Account balance
    double              AccountEquity;      // Account equity
    double              FreeMargin;         // Free margin
    datetime            LastUpdate;         // Last update time
    
    // Constructor
    SRiskData() {
        MaxRiskPercent = 2.0;
        MaxDailyRisk = 6.0;
        CurrentRisk = 0.0;
        DailyRisk = 0.0;
        CanTrade = true;
        AccountBalance = 0.0;
        AccountEquity = 0.0;
        FreeMargin = 0.0;
        LastUpdate = 0;
    }
};

//+------------------------------------------------------------------+
//| GLOBAL CONSTANTS                                                 |
//+------------------------------------------------------------------+
#define APEX_VERSION            "5.00"
#define APEX_BUILD_DATE         "2024.12.01"
#define APEX_COPYRIGHT          "APEX Trading Systems"

// Trading constants
#define MIN_LOT_SIZE            0.01
#define MAX_LOT_SIZE            100.0
#define MIN_STOP_LEVEL          10
#define MAX_SPREAD_POINTS       50
#define DEFAULT_SLIPPAGE        3
#define MAX_RETRIES             3

// Time constants
#define SECONDS_IN_MINUTE       60
#define SECONDS_IN_HOUR         3600
#define SECONDS_IN_DAY          86400
#define MILLISECONDS_IN_SECOND  1000

// Performance constants
#define MIN_TRADES_FOR_STATS    10
#define MAX_DRAWDOWN_PERCENT    30.0
#define MIN_PROFIT_FACTOR       1.2
#define MIN_WIN_RATE            40.0

// File paths
#define LOG_FILE_PATH           "APEX_Logs\\"
#define DATA_FILE_PATH          "APEX_Data\\"
#define CONFIG_FILE_PATH        "APEX_Config\\"

//+------------------------------------------------------------------+
//| UTILITY MACROS                                                   |
//+------------------------------------------------------------------+
#define SAFE_DELETE(ptr)        if(ptr != NULL) { delete ptr; ptr = NULL; }
#define SAFE_ARRAY_DELETE(ptr)  if(ptr != NULL) { delete[] ptr; ptr = NULL; }
#define SAFE_RELEASE(handle)    if(handle != INVALID_HANDLE) { IndicatorRelease(handle); handle = INVALID_HANDLE; }
#define IS_VALID_POINTER(ptr)   (ptr != NULL)
#define NORMALIZE_PRICE(price)  NormalizeDouble(price, _Digits)
#define NORMALIZE_LOT(lot)      NormalizeDouble(lot, 2)
#define NORMALIZE_VOLUME(volume) NormalizeDouble(volume, 2)
#define POINTS_TO_PRICE(points) (points * _Point)
#define PRICE_TO_POINTS(price)  (int)(price / _Point)

//+------------------------------------------------------------------+
//| LOGGING MACROS (RENAMED TO AVOID CONFLICTS)                     |
//+------------------------------------------------------------------+
#define APEX_LOG_ERROR(msg) \
    Print("ERROR [" + __FUNCTION__ + "]: " + msg);

#define APEX_LOG_WARNING(msg) \
    Print("WARNING [" + __FUNCTION__ + "]: " + msg);

#define APEX_LOG_INFO(msg) \
    Print("INFO [" + __FUNCTION__ + "]: " + msg);

#define APEX_LOG_DEBUG(msg) \
    Print("DEBUG [" + __FUNCTION__ + "]: " + msg);

// Legacy compatibility (keep old names but redirect)
#define LOG_ERROR(msg)   APEX_LOG_ERROR(msg)
#define LOG_WARNING(msg) APEX_LOG_WARNING(msg) 
#define LOG_INFO(msg)    APEX_LOG_INFO(msg)
#define LOG_DEBUG(msg)   APEX_LOG_DEBUG(msg)

//+------------------------------------------------------------------+
//| ERROR HANDLING                                                   |
//+------------------------------------------------------------------+
#define CHECK_POINTER(ptr, msg) \
    if(ptr == NULL) { \
        Print("ERROR: " + msg + " - Null pointer"); \
        return false; \
    }

#define CHECK_INIT(result, msg) \
    if(!result) { \
        Print("ERROR: " + msg + " - Initialization failed"); \
        return false; \
    }

//+------------------------------------------------------------------+
//| VALIDATION FUNCTIONS                                             |
//+------------------------------------------------------------------+
bool IsValidPrice(double price) {
    return (price > 0.0 && price != EMPTY_VALUE);
}

bool IsValidVolume(double volume) {
    return (volume >= MIN_LOT_SIZE && volume <= MAX_LOT_SIZE);
}

bool IsValidStopLevel(double entry, double stop) {
    if(!IsValidPrice(entry) || !IsValidPrice(stop)) return false;
    double stopLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
    return (MathAbs(entry - stop) >= stopLevel);
}

bool IsMarketOpen() {
    return (SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_FULL);
}

bool IsNewBar(ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT) {
    static datetime lastBarTime = 0;
    datetime currentBarTime = iTime(_Symbol, timeframe, 0);
    if(currentBarTime != lastBarTime) {
        lastBarTime = currentBarTime;
        return true;
    }
    return false;
}

//+------------------------------------------------------------------+
//| UTILITY FUNCTIONS                                                |
//+------------------------------------------------------------------+
double GetSpreadInPoints() {
    return (SymbolInfoDouble(_Symbol, SYMBOL_ASK) - SymbolInfoDouble(_Symbol, SYMBOL_BID)) / _Point;
}

double GetPipValue() {
    return SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
}

// Removed TimeToString and DoubleToString overrides - use built-in functions

string IntegerToString(long value) {
    return ::IntegerToString(value);
}

//+------------------------------------------------------------------+
