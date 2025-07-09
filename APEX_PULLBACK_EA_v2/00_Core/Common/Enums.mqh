//+------------------------------------------------------------------+
//|                                                        Enums.mqh |
//|                                       APEX PULLBACK EA v14.0     |
//|                                          Global Enumerations     |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Apex Trading Systems"
#property link      "https://www.apextradingsystems.com"
#property version   "14.0"
#property strict

#ifndef APEX_ENUMS_MQH
#define APEX_ENUMS_MQH

// --- System & Core Enums ---
enum ESystemStatus
{
    STATUS_OK,                  // System is running normally
    STATUS_WARNING,             // System has warnings
    STATUS_ERROR,               // System has critical errors
    STATUS_DISABLED,            // System is manually disabled
    STATUS_PAUSED,              // System is temporarily paused
    STATUS_INITIALIZING         // System is starting up
};

enum ELogLevel
{
    LOG_LEVEL_DEBUG,            // Detailed debug information
    LOG_LEVEL_INFO,             // Informational messages
    LOG_LEVEL_WARNING,          // Warnings that don't stop execution
    LOG_LEVEL_ERROR,            // Errors that may halt some functionality
    LOG_LEVEL_CRITICAL          // Critical errors, system halt likely
};

enum EHealthCheckModule
{
    HEALTH_MODULE_CORE,
    HEALTH_MODULE_DATA,
    HEALTH_MODULE_RISK,
    HEALTH_MODULE_TRADE,
    HEALTH_MODULE_ANALYTICS
};

// --- Trading Strategy & Logic Enums ---
enum ETradingStrategy
{
    STRATEGY_PULLBACK_TREND,
    STRATEGY_BREAKOUT,
    STRATEGY_MEAN_REVERSION
};

enum ESignalDirection
{
    DIRECTION_LONG,             // Buy signal
    DIRECTION_SHORT,            // Sell signal
    DIRECTION_BOTH,             // Both long and short signals are active
    DIRECTION_NONE              // No signals are active
};

enum ETradeDirectionFilter
{
    FILTER_DIRECTION_ANY,
    FILTER_DIRECTION_LONG_ONLY,
    FILTER_DIRECTION_SHORT_ONLY
};

// --- Risk Management Enums ---
enum ERiskLevel
{
    RISK_LOW,
    RISK_MODERATE,
    RISK_HIGH,
    RISK_CUSTOM
};

enum EStopLossMode
{
    SL_MODE_STATIC_PIPS,
    SL_MODE_ATR,
    SL_MODE_SWING_HIGH_LOW,
    SL_MODE_PARABOLIC_SAR
};

enum ETakeProfitMode
{
    TP_MODE_STATIC_PIPS,
    TP_MODE_RISK_REWARD_RATIO,
    TP_MODE_SWING_HIGH_LOW,
    TP_MODE_DYNAMIC_TRAILING
};

// --- Time & Session Management Enums ---
enum ETimeframe
{
    TIMEFRAME_CURRENT = 0,
    TIMEFRAME_M1 = 1,
    TIMEFRAME_M5 = 5,
    TIMEFRAME_M15 = 15,
    TIMEFRAME_M30 = 30,
    TIMEFRAME_H1 = 60,
    TIMEFRAME_H4 = 240,
    TIMEFRAME_D1 = 1440,
    TIMEFRAME_W1 = 10080,
    TIMEFRAME_MN1 = 43200
};

enum ETradingSession
{
    SESSION_ASIAN,
    SESSION_LONDON,
    SESSION_NEW_YORK,
    SESSION_OVERLAP_LDN_NY
};

// --- News Filter Enums ---
enum ENewsFilterLevel
{
    NEWS_FILTER_DISABLED,
    NEWS_FILTER_LOW_IMPACT,
    NEWS_FILTER_MEDIUM_IMPACT,
    NEWS_FILTER_HIGH_IMPACT
};

// --- UI & Dashboard Enums ---
enum EChartTheme
{
    THEME_DARK,
    THEME_LIGHT
};

enum EDashboardTab
{
    TAB_MAIN,
    TAB_PERFORMANCE,
    TAB_RISK,
    TAB_LOGS,
    TAB_SETTINGS
};

// --- Optimization & Analytics Enums ---
enum ENUM_OPTIMIZATION_TYPE
{
    OPTIMIZATION_GENETIC = 0,
    OPTIMIZATION_GRID = 1,
    OPTIMIZATION_SWEEP = 2,
    OPTIMIZATION_RANDOM = 3,
    OPTIMIZATION_SIMULATED_ANNEALING = 4,
    OPTIMIZATION_PARTICLE_SWARM = 5
};

enum ENUM_ADAPTATION_METHOD
{
    ADAPTATION_GRADUAL = 0,
    ADAPTATION_IMMEDIATE = 1,
    ADAPTATION_WEIGHTED = 2,
    ADAPTATION_THRESHOLD = 3
};

// Chart pattern types
enum ENUM_CHART_PATTERN {
    PATTERN_NONE = 0,
    PATTERN_HEAD_SHOULDERS = 1,
    PATTERN_TRIANGLE = 2,
    PATTERN_FLAG = 3,
    PATTERN_PENNANT = 4,
    PATTERN_WEDGE = 5,
    PATTERN_DOUBLE_TOP = 6,
    PATTERN_DOUBLE_BOTTOM = 7,
    PATTERN_TRIPLE_TOP = 8,
    PATTERN_TRIPLE_BOTTOM = 9
};

#endif // APEX_ENUMS_MQH