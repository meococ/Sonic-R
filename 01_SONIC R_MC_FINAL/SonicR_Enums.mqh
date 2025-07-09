//+------------------------------------------------------------------+
//|                                           SonicR_Enums.mqh     |
//|                  Sonic R System - Centralized Enumerations      |
//|                              Đại Bàng Architecture              |
//+------------------------------------------------------------------+
#ifndef SONICR_ENUMS_MQH
#define SONICR_ENUMS_MQH

// BẮT ĐẦU NAMESPACE
namespace ApexSonicR {

//+------------------------------------------------------------------+
//| LOG SYSTEM ENUMS                                                 |
//+------------------------------------------------------------------+
enum ENUM_LOG_LEVEL {
    LOG_LEVEL_ERROR = 0,        // Error messages only
    LOG_LEVEL_WARNING = 1,      // Warning and error messages
    LOG_LEVEL_INFO = 2,         // Info, warning, and error messages
    LOG_LEVEL_DEBUG = 3         // All messages including debug
};

//+------------------------------------------------------------------+
//| SIGNAL SYSTEM ENUMS                                              |
//+------------------------------------------------------------------+
enum ENUM_SIGNAL_TYPE {
    SIGNAL_TYPE_NONE = 0,            // No signal
    SIGNAL_TYPE_BUY = 1,             // Buy signal
    SIGNAL_TYPE_SELL = 2             // Sell signal
};

enum ENUM_SIGNAL_DIRECTION {
    SIGNAL_DIRECTION_NONE = 0,       // No direction
    SIGNAL_DIRECTION_BUY = 1,        // Buy direction
    SIGNAL_DIRECTION_SELL = 2,       // Sell direction
    SIGNAL_DIRECTION_LONG = 1,       // Alias for buy
    SIGNAL_DIRECTION_SHORT = 2       // Alias for sell
};

//+------------------------------------------------------------------+
//| NEWS FILTER ENUMS                                                |
//+------------------------------------------------------------------+
enum ENUM_NEWS_FILTER {
    NEWS_FILTER_OFF = 0,        // No news filtering
    NEWS_FILTER_LOW = 1,        // Low impact news
    NEWS_FILTER_MEDIUM = 2,     // Medium impact news
    NEWS_FILTER_HIGH = 3,       // High impact news
    NEWS_FILTER_CRITICAL = 4    // Critical impact news
};

//+------------------------------------------------------------------+
//| MARKET ANALYSIS ENUMS                                            |
//+------------------------------------------------------------------+
enum ENUM_MARKET_TREND {
    TREND_NONE = 0,             // No clear trend
    TREND_UP = 1,               // Uptrend
    TREND_DOWN = 2,             // Downtrend
    TREND_SIDEWAYS = 3          // Sideways/ranging
};

enum ENUM_MARKET_REGIME {
    REGIME_UNDEFINED = 0,       // Undefined regime
    REGIME_TRENDING = 1,        // Trending market
    REGIME_RANGING = 2,         // Ranging market
    REGIME_VOLATILE = 3,        // High volatility
    REGIME_LOW_VOLUME = 4       // Low volume
};

//+------------------------------------------------------------------+
//| WAVE PATTERN ENUMS                                               |
//+------------------------------------------------------------------+
enum ENUM_WAVE_TYPE {
    WAVE_IMPULSE_1,         // Wave 1 (Impulse)
    WAVE_IMPULSE_2,         // Wave 2 (Correction)
    WAVE_IMPULSE_3,         // Wave 3 (Impulse - strongest)
    WAVE_IMPULSE_4,         // Wave 4 (Correction)
    WAVE_IMPULSE_5,         // Wave 5 (Impulse - final)
    WAVE_CORRECTION_A,      // Wave A (Correction)
    WAVE_CORRECTION_B,      // Wave B (Correction)
    WAVE_CORRECTION_C,      // Wave C (Correction)
    WAVE_TRIANGLE,          // Triangle pattern
    WAVE_FLAT,              // Flat correction
    WAVE_COMPLEX,           // Complex correction
    WAVE_UNKNOWN            // Unidentified pattern
};

enum ENUM_WAVE_DEGREE {
    DEGREE_GRAND_SUPERCYCLE,    // Grand Supercycle
    DEGREE_SUPERCYCLE,          // Supercycle
    DEGREE_CYCLE,               // Cycle
    DEGREE_PRIMARY,             // Primary
    DEGREE_INTERMEDIATE,        // Intermediate
    DEGREE_MINOR,               // Minor
    DEGREE_MINUTE,              // Minute
    DEGREE_MINUETTE,            // Minuette
    DEGREE_SUBMINUETTE          // Subminuette
};

//+------------------------------------------------------------------+
//| STRATEGY ENUMS                                                   |
//+------------------------------------------------------------------+
enum ENUM_STRATEGY_ID {
    STRATEGY_ID_UNDEFINED = 0,  // Undefined strategy
    STRATEGY_ID_PULLBACK,       // Pullback strategy
    STRATEGY_ID_BREAKOUT,       // Breakout strategy
    STRATEGY_ID_MEAN_REVERSION, // Mean reversion strategy
    STRATEGY_ID_SHALLOW_PULLBACK, // Shallow pullback
    STRATEGY_ID_RANGE_TRADING   // Range trading
};

//+------------------------------------------------------------------+
//| TIMEFRAME ENUMS                                                  |
//+------------------------------------------------------------------+
enum ENUM_TIMEFRAMES {
    PERIOD_M1  = 1,      // 1 minute
    PERIOD_M5  = 5,      // 5 minutes
    PERIOD_M15 = 15,     // 15 minutes
    PERIOD_M30 = 30,     // 30 minutes
    PERIOD_H1  = 60,     // 1 hour
    PERIOD_H4  = 240,    // 4 hours
    PERIOD_D1  = 1440,   // 1 day
    PERIOD_W1  = 10080,  // 1 week
    PERIOD_MN1 = 43200,  // 1 month
    PERIOD_CURRENT = 0   // Current timeframe
};

//+------------------------------------------------------------------+
//| EA STATE ENUMS                                                   |
//+------------------------------------------------------------------+
enum ENUM_EA_STATE {
    EA_STATE_INIT = 0,          // Initializing
    EA_STATE_IDLE,              // Idle, waiting for signals
    EA_STATE_ANALYZING,         // Analyzing market
    EA_STATE_TRADING,           // Active trading
    EA_STATE_PAUSED,            // Paused
    EA_STATE_ERROR,             // Error state
    EA_STATE_SHUTDOWN           // Shutting down
};

} // END NAMESPACE ApexSonicR

#endif // SONICR_ENUMS_MQH 