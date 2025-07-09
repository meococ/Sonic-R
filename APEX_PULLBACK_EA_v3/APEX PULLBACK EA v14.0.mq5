//+------------------------------------------------------------------+
//|   APEX PULLBACK EA v14.0 - Professional Edition                  |
//|   Module hóa xuất sắc - Quản lý rủi ro - EA chuẩn Prop           |
//|   Copyright 2025, APEX Forex - Mèo Cọc                           |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, APEX Forex - Mèo Cọc"
#property link      "https://www.apexforex.com"
#property version   "14.0"
#property description "APEX Pullback EA - A professional, modular trading algorithm."
#property icon      "..\\Images\\apex_icon.ico"
#property strict

// --- ARCHITECTURE INCLUDES --- 
// The order of includes is CRITICAL for the compiler to resolve dependencies.
// We include modules from the ground up: foundational -> analysis -> execution -> UI.

// Level 0: Foundational & Core Data Structures
// Enums.mqh has no dependencies.
// CommonStructs.mqh includes Enums.mqh and provides forward declarations for all classes.
#include "Enums.mqh"
#include "CommonStructs.mqh"

// Level 1: Core Infrastructure Modules (depend only on CommonStructs)
#include "Logger.mqh"
#include "ErrorHandler.mqh"
#include "ParameterStore.mqh"
#include "StateManager.mqh"
#include "FunctionStack.mqh"

// Level 2: Market & Session Analysis Modules (may depend on Level 1)
#include "SymbolInfo.mqh"
#include "TimeManager.mqh"
#include "BrokerHealthMonitor.mqh"
#include "SlippageMonitor.mqh"
#include "AssetDNA.mqh"
#include "NewsFilter.mqh"
#include "SessionManager.mqh"

// Level 3: Technical Analysis & Signal Generation (may depend on Level 1, 2)
#include "MathHelper.mqh"
#include "IndicatorUtils.mqh"
#include "SwingPointDetector.mqh"
#include "PatternDetector.mqh"
#include "MarketProfile.mqh"
#include "SignalEngine.mqh"

// Level 4: Risk & Trade Management (may depend on all above)
#include "RiskManager.mqh"
#include "PositionManager.mqh"
#include "TradeManager.mqh"
#include "CircuitBreaker.mqh"
#include "RecoveryManager.mqh"

// Level 5: UI & Performance Analytics (may depend on all above)
#include "PerformanceAnalytics.mqh"
#include "DrawingUtils.mqh"
#include "Dashboard.mqh"

// Level 6: The Core Engine
#include "Core.mqh"

// --- EA INPUT PARAMETERS ---
// MQL5 requires individual input declarations, not struct-based inputs

//--- General Settings ---
input long                  MagicNumber = 12345;          // Magic Number
input string                OrderComment = "APEX_v14";     // Comment cho lệnh

//--- Logging & Display ---
input ENUM_LOG_LEVEL        LogLevel = LOG_INFO;             // Cấp độ log
input ENUM_LOG_OUTPUT       LogOutput = LOG_OUTPUT_CONSOLE;        // Nơi xuất log
input bool                  EnableDetailedLogs = true;   // Bật/tắt log chi tiết
input string                CsvLogFilename = "apex_log.csv";       // Tên file CSV log
input bool                  DisplayDashboard = true;       // Hiển thị dashboard
input ENUM_DASHBOARD_THEME  DashboardTheme = THEME_DARK;       // Chủ đề Dashboard
input int                   UpdateFrequencySeconds = 5; // Tần suất cập nhật (giây)
input bool                  DisableDashboardInBacktest = true; // Tắt dashboard trong backtest

//--- Core Strategy ---
input ENUM_TIMEFRAMES       MainTimeframe = PERIOD_H1;        // Khung thời gian chính
input int                   EMA_Fast = 21;             // EMA nhanh
input int                   EMA_Medium = 50;           // EMA trung bình
input int                   EMA_Slow = 200;             // EMA chậm
input bool                  UseMultiTimeframe = true;    // Sử dụng đa khung thời gian
input ENUM_TIMEFRAMES       HigherTimeframe = PERIOD_H4;      // Khung thời gian cao hơn

//--- Risk Management ---
input double                RiskPercent = 1.0;          // Risk % mỗi lệnh
input double                StopLoss_ATR = 2.0;         // Hệ số ATR cho Stop Loss
input double                TakeProfit_RR = 2.0;        // Tỷ lệ R:R cho Take Profit
input int                   MaxPositions = 1;         // Số vị thế tối đa

// === GLOBAL INSTANCES ===
// g_Core is the single, global instance of our EA's central nervous system.
ApexPullback::CCore *g_Core = NULL;

// Global input parameters struct - populated from individual input variables
ApexPullback::SInputParameters g_Inputs;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // 1. Populate the global input parameters struct from individual input variables
    PopulateInputParameters();
    
    // 2. Create the core instance
    g_Core = new ApexPullback::CCore();
    if(g_Core == NULL)
    {
        Print("CRITICAL: Failed to allocate memory for the Core object. EA cannot start.");
        return(INIT_FAILED);
    }

    // 3. Initialize the core. This sets up the context and all modules.
    if (!g_Core->Initialize(g_Inputs))
    {
        Print("FATAL ERROR: Core initialization failed. Check logs for details.");
        // Clean up the partially initialized object
        delete g_Core;
        g_Core = NULL;
        return INIT_FAILED;
    }
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    //--- Deinitialize and clean up the core object
    if (g_Core != NULL)
    {
        g_Core->Deinitialize();
        delete g_Core;
        g_Core = NULL;
        Print("Core object deinitialized and deleted.");
    }
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    if (g_Core != NULL)
    {
        g_Core->OnTick();
    }
}

//+------------------------------------------------------------------+
//| Expert timer function                                            |
//+------------------------------------------------------------------+
void OnTimer()
{
    if (g_Core != NULL)
    {
        g_Core->OnTimer();
    }
}

//+------------------------------------------------------------------+
//| Chart event function                                             |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
    // Check if the core object is valid before using it
    if(g_Core != NULL)
    {
        // Delegate chart events to the core object.
        g_Core->OnChartEvent(id, lparam, dparam, sparam);
    }
}

//+------------------------------------------------------------------+
//| Trade transaction function                                       |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans, const MqlTradeRequest &request, const MqlTradeResult &result)
{
    if (g_Core != NULL)
    {
        g_Core->OnTradeTransaction(trans, request, result);
    }
}

//+------------------------------------------------------------------+
//| Populate Input Parameters Function                               |
//| Maps individual input variables to the global struct            |
//+------------------------------------------------------------------+
void PopulateInputParameters()
{
    // General Settings
    g_Inputs.MagicNumber = MagicNumber;
    g_Inputs.OrderComment = OrderComment;
    
    // Logging & Display
    g_Inputs.LogLevel = LogLevel;
    g_Inputs.LogOutput = LogOutput;
    g_Inputs.EnableDetailedLogs = EnableDetailedLogs;
    g_Inputs.CsvLogFilename = CsvLogFilename;
    g_Inputs.DisplayDashboard = DisplayDashboard;
    g_Inputs.DashboardTheme = DashboardTheme;
    g_Inputs.UpdateFrequencySeconds = UpdateFrequencySeconds;
    g_Inputs.DisableDashboardInBacktest = DisableDashboardInBacktest;
    
    // Core Strategy
    g_Inputs.MainTimeframe = MainTimeframe;
    g_Inputs.EMA_Fast = EMA_Fast;
    g_Inputs.EMA_Medium = EMA_Medium;
    g_Inputs.EMA_Slow = EMA_Slow;
    g_Inputs.UseMultiTimeframe = UseMultiTimeframe;
    g_Inputs.HigherTimeframe = HigherTimeframe;
    
    // Risk Management
    g_Inputs.RiskPercent = RiskPercent;
    g_Inputs.StopLoss_ATR = StopLoss_ATR;
    g_Inputs.TakeProfit_RR = TakeProfit_RR;
    g_Inputs.MaxPositions = MaxPositions;
    
    // Set default values for parameters not exposed as inputs
    // These can be added as inputs later if needed
    g_Inputs.AlertsEnabled = false;
    g_Inputs.SendNotifications = false;
    g_Inputs.SendEmailAlerts = false;
    g_Inputs.EnableTelegramNotify = false;
    g_Inputs.TelegramBotToken = "";
    g_Inputs.TelegramChatID = "";
    g_Inputs.TelegramImportantOnly = true;
    
    g_Inputs.AllowedDirection = DIRECTION_BOTH;
    g_Inputs.EnablePriceAction = true;
    g_Inputs.EnableSwingLevels = true;
    g_Inputs.MinPullbackPercent = 30.0;
    g_Inputs.MaxPullbackPercent = 70.0;
    g_Inputs.RequirePriceActionConfirmation = true;
    g_Inputs.RequireMomentumConfirmation = true;
    g_Inputs.RequireVolumeConfirmation = false;
    
    g_Inputs.ATR_Period = 14;
    g_Inputs.InpADX_Period = 14;
    g_Inputs.EnableMarketRegimeFilter = true;
    g_Inputs.EnableVolatilityFilter = true;
    g_Inputs.EnableAdxFilter = false;
    g_Inputs.MinAdxValue = 20.0;
    g_Inputs.MaxAdxValue = 80.0;
    g_Inputs.VolatilityThreshold = 2.0;
    g_Inputs.MarketPreset = PRESET_FOREX;
    g_Inputs.MaxSpreadPoints = 30.0;
    
    g_Inputs.EntryMode = ENTRY_MODE_MARKET;
    g_Inputs.UsePartialClose = false;
    g_Inputs.PartialCloseR1 = 1.0;
    g_Inputs.PartialCloseR2 = 2.0;
    g_Inputs.PartialClosePercent1 = 50.0;
    g_Inputs.PartialClosePercent2 = 50.0;
    
    g_Inputs.UseAdaptiveTrailing = false;
    g_Inputs.TrailingMode = TRAILING_MODE_ATR;
    g_Inputs.TrailingAtrMultiplier = 2.0;
    g_Inputs.BreakEvenAfterR = 1.0;
    g_Inputs.BreakEvenBuffer = 5.0;
    
    g_Inputs.UseChandelierExit = false;
    g_Inputs.ChandelierPeriod = 22;
    g_Inputs.ChandelierMultiplier = 3.0;
    
    g_Inputs.FilterBySession = false;
    g_Inputs.SessionFilter = FILTER_MAJOR_SESSIONS_ONLY;
    g_Inputs.UseGmtOffset = false;
    g_Inputs.GmtOffset = 0;
    g_Inputs.TradeLondonOpen = true;
    g_Inputs.TradeNewYorkOpen = true;
    
    g_Inputs.NewsFilterMode = NEWS_FILTER_OFF;
    g_Inputs.NewsDataFile = "news_data.csv";
    g_Inputs.NewsImportance = NEWS_FILTER_HIGH;
    g_Inputs.MinutesBeforeNews = 30;
    g_Inputs.MinutesAfterNews = 30;
    
    g_Inputs.EnableAutoPause = false;
    g_Inputs.VolatilityPauseThreshold = 3.0;
    g_Inputs.DrawdownPauseThreshold = 5.0;
    g_Inputs.EnableAutoResume = false;
    g_Inputs.PauseDurationMinutes = 60;
    g_Inputs.ResumeOnLondonOpen = false;
    
    g_Inputs.PropFirmMode = false;
    g_Inputs.DailyLossLimit = 5.0;
    g_Inputs.MaxDrawdown = 10.0;
    g_Inputs.MaxTradesPerDay = 10;
    g_Inputs.MaxConsecutiveLosses = 5;
}
