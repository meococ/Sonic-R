//+------------------------------------------------------------------+
//|                       Core_Inputs.mqh                            |
//|                  APEX Pullback EA v4.5 - Sonic R Integration     |
//|   Centralized Input Management for the GP-DSI Architecture       |
//+------------------------------------------------------------------+
#ifndef APEX_CORE_INPUTS_MQH_
#define APEX_CORE_INPUTS_MQH_

#include "Core_Defines.mqh"

// This file contains input parameters and requires Core_Defines.mqh for ENUM definitions

//+------------------------------------------------------------------+
//| EXTERNAL INPUT PARAMETERS                                        |
//+------------------------------------------------------------------+

//--- General Settings ---
input group "===== GENERAL SETTINGS =====";
input long      InpMagicNumber              = 12345;                // Magic Number
input ENUM_STRATEGY_TYPE InpStrategyType = STRATEGY_SONIC_R; // Strategy To Use
input ENUM_LOG_LEVEL InpLogLevel = LOG_INFO_LEVEL; // Log Level
input bool      InpLogToFile                = false;                // Log to File
input string    InpEAComment                = "APEX_v4.5_SonicR";   // EA Comment

//--- Enhanced Sonic R Signal Settings ---
input group "===== ENHANCED SONIC R SIGNAL SETTINGS =====";
input bool      InpUseSonicRSystem          = true;                 // MASTER SWITCH: Enable/Disable Sonic R System
input int       InpDragonPeriod             = 34;                   // Sonic R Dragon Period
input int       InpTrendEmaPeriod           = 89;                   // Sonic R Trend EMA Period
input double    InpMinDragonAngle           = 2.0;                  // Minimum angle for Dragon to confirm trend
input ENUM_ALLOWED_DIRECTION InpTradingDirection = DIRECTION_BOTH; // Trading Direction
input double    InpMinWaveStrength          = 0.6;                  // Minimum Wave Pattern Strength (0.0-1.0)
input double    InpMinDragonStrength        = 0.5;                  // Minimum Dragon Strength (0.0-1.0)
input double    InpMinWaveQuality           = 0.7;                  // Minimum Wave Quality Score (0.0-1.0)
input bool      InpUseMultiTimeframeFilter  = true;                 // Enable Multi-Timeframe Confirmation
input bool      InpUseDragonSqueezeFilter   = true;                 // Enable Dragon Squeeze Filter
input bool      InpUseVolumeConfirmation    = true;                 // Enable Enhanced Volume Confirmation

//--- Dragon Band Settings ---
input group "===== DRAGON BAND SETTINGS =====";
input int       InpDragonBandEmaPeriod      = 34;                   // Dragon Band EMA Period
input int       InpDragonBandAtrPeriod      = 14;                   // Dragon Band ATR Period
input double    InpDragonBandVolMultiplier  = 2.0;                  // Dragon Band Volatility Multiplier
input int       InpDragonBandAnglePeriod    = 5;                    // Dragon Band Angle Calculation Period
input double    InpDragonBandMinAngle       = 1.5;                  // Dragon Band Minimum Angle Threshold
input bool      InpDragonBandAdaptive       = true;                 // Use Adaptive Dragon Bands
input double    InpDragonBandAdaptiveMult   = 1.5;                  // Dragon Band Adaptive Multiplier

//--- Scout Entry Settings ---
input group "===== SCOUT ENTRY SETTINGS =====";
input int       InpScoutLookbackPeriod      = 20;                   // Scout Entry Lookback Period
input double    InpScoutMinPullbackRatio    = 0.3;                  // Scout Minimum Pullback Ratio
input double    InpScoutMaxPullbackRatio    = 0.7;                  // Scout Maximum Pullback Ratio
input bool      InpScoutUseDragonFilter     = true;                 // Scout Use Dragon Band Filter
input double    InpScoutDragonTolerance     = 0.5;                  // Scout Dragon Band Tolerance
input bool      InpScoutUseWaveValidation   = true;                 // Scout Use Wave Validation
input int       InpScoutMinWavePoints       = 3;                    // Scout Minimum Wave Points
input bool      InpScoutUsePVSRAConfirm     = true;                 // Scout Use PVSRA Confirmation
input double    InpScoutMinVolumeThreshold  = 1.5;                  // Scout Minimum Volume Threshold
input double    InpScoutMaxRiskPerEntry     = 0.5;                  // Scout Maximum Risk Per Entry (%)
input int       InpScoutMaxConcurrent       = 3;                    // Scout Maximum Concurrent Entries
input int       InpScoutEntryTimeoutMin     = 60;                   // Scout Entry Timeout (minutes)
input int       InpScoutConfirmationCandles = 2;                    // Scout Confirmation Candles

//--- Advanced Strategy Settings ---
input group "===== ADVANCED STRATEGY SETTINGS =====";
input double    InpAdvancedMinSignalStrength = 0.6;                 // Advanced Minimum Signal Strength
input double    InpAdvancedMinConfidence    = 0.7;                  // Advanced Minimum Confidence
input bool      InpAdvancedUseMLPrediction  = false;                // Advanced Use ML Prediction
input double    InpAdvancedMLWeight         = 0.3;                  // Advanced ML Weight
input bool      InpAdvancedUseCorrelation   = true;                 // Advanced Use Correlation Analysis
input double    InpAdvancedCorrelationThreshold = 0.8;              // Advanced Correlation Threshold
input bool      InpAdvancedUseDynamicSizing = true;                 // Advanced Use Dynamic Position Sizing
input double    InpAdvancedMaxPositionSize  = 2.0;                  // Advanced Maximum Position Size (lots)
input int       InpAdvancedSignalTimeout    = 300;                  // Advanced Signal Timeout (seconds)

//--- Risk Management ---
input group "===== RISK MANAGEMENT =====";
input double    InpRiskPercent              = 1.0;                  // Risk Percent per Trade
input ENUM_LOT_SIZE_MODE InpLotSizeMode = LOT_MODE_RISK_PERCENT; // Lot Size Mode
input double    InpFixedLotSize             = 0.1;                  // Fixed Lot Size
input int       InpMaxDailyTrades           = 5;                    // Max Daily Trades
input double    InpMaxDailyLossPercent      = 3.0;                  // Max Daily Loss %
input double    InpRiskRewardRatio          = 2.0;                  // Risk:Reward Ratio
input int       InpSLBufferPips             = 10;                   // SL Buffer Pips
input int       InpStopLossPips             = 50;                   // Stop Loss Pips
input int       InpTakeProfitPips           = 100;                  // Take Profit Pips
input bool      InpUseTrailingStop          = true;                 // Use Trailing Stop
input int       InpMaxConsecutiveLosses    = 5;                    // Max Consecutive Losses
input double    InpMaxDrawdownPercent      = 15.0;                 // Max Drawdown %

//--- Trade Management ---
input group "===== TRADE MANAGEMENT =====";
input bool      InpAsyncModeEnabled         = true;                 // Enable Asynchronous Trading
input int       InpSlippagePoints           = 30;                   // Max Slippage (Points)

//--- Circuit Breaker ---
input group "===== CIRCUIT BREAKER =====";
input bool      InpEnableCircuitBreaker     = true;                // Enable Circuit Breaker
input double    InpCircuitBreakerLoss       = 5.0;                 // Circuit Breaker Loss %
input int       InpCircuitBreakerTrades     = 3;                   // Max Consecutive Losses

//--- Session Management ---
input group "===== SESSION MANAGEMENT =====";
input bool      InpEnableSessionFilter      = false;                // Enable Session Filter
input ENUM_SESSION_FILTER InpSessionFilter  = FILTER_ALL_SESSIONS;  // Session Filter
input int       InpGMTOffset                = 0;                    // GMT Offset (hours)
input bool      InpAutoAdjustDST            = true;                 // Auto Adjust for DST
input bool      InpTradeLondonOpen          = true;                 // Trade London Opening
input bool      InpTradeNewYorkOpen         = true;                 // Trade New York Opening
input int       InpOpenWindowMinutes        = 30;                   // Opening Window (minutes)

//--- UI Dashboard ---
input group "===== UI DASHBOARD =====";
input bool      InpEnableDashboard          = true;                 // Enable on-chart Dashboard
input int       InpDashboardX               = 20;                   // Dashboard X position
input int       InpDashboardY               = 20;                   // Dashboard Y position
input ENUM_DASHBOARD_THEME InpDashboardTheme = THEME_DARK; // Dashboard Theme (Dark/Light)

#endif // APEX_CORE_INPUTS_MQH_