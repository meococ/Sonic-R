//+------------------------------------------------------------------+
//| SonicR_PropFirm_EA.mq5                                           |
//+------------------------------------------------------------------+
#property copyright "SonicR Trading Systems"
#property link      "https://www.sonicrsystems.com"
#property version   "3.0"
#property description "SonicR PropFirm EA: H1 Precision Intraday Strategy"
#property strict

//--- Include all necessary modules
#include "Include/SonicR/CSonicREAManager.mqh"

//--- Enum definitions
enum ENUM_PROP_FIRM_TYPE {
    PROP_FIRM_FTMO,       // FTMO
    PROP_FIRM_THE5ERS,    // The5ers
    PROP_FIRM_MFF,        // MyForexFunds
    PROP_FIRM_TFT,        // TheFundedTrader
    PROP_FIRM_CUSTOM      // Custom (User defined)
};

enum ENUM_CHALLENGE_PHASE {
    PHASE_CHALLENGE,      // Challenge Phase
    PHASE_VERIFICATION,   // Verification Phase
    PHASE_FUNDED          // Funded Account
};

//--- Input parameters
// PropFirm Settings
input group "PropFirm Settings"
input ENUM_PROP_FIRM_TYPE PropFirmType = PROP_FIRM_FTMO;        // PropFirm Type
input ENUM_CHALLENGE_PHASE ChallengePhase = PHASE_CHALLENGE;    // Challenge Phase

// Risk Management
input group "Risk Management"
input double RiskPercent = 1.0;                // Risk per trade (%)
input double MaxDailyDrawdown = 5.0;           // Max daily drawdown (%)
input double MaxTotalDrawdown = 10.0;          // Max total drawdown (%)
input int MaxDailyTrades = 3;                  // Max trades per day
input int MaxConcurrentTrades = 2;             // Max concurrent open trades
input double PortfolioMaxRisk = 5.0;           // Maximum portfolio risk (%)
input double MaxCorrelationThreshold = 0.7;    // Maximum correlation for pairs

// Order Management
input group "Order Management"
input double PartialClosePercent = 0.6;        // Partial close percentage at TP1
input double BreakEvenLevel = 0.8;             // Move to breakeven at X× risk
input double TrailingActivationR = 1.2;        // Activate trailing at X× risk
input double TakeProfitMultiplier1 = 1.2;      // TP1 at X× risk
input int MaxRetryAttempts = 3;                // Max order retry attempts
input int RetryDelayMs = 500;                  // Delay between retries (ms)

// SuperTrend Settings
input group "SuperTrend Settings"
input int SuperTrendPeriod = 10;               // SuperTrend ATR Period
input double SuperTrendMultiplier = 3.0;       // SuperTrend Multiplier

// Strategy Parameters
input group "Strategy Parameters"
input int EMA34Period = 34;                    // EMA 34 Period (Dragon)
input int EMA89Period = 89;                    // EMA 89 Period (Trend)
input int EMA200Period = 200;                  // EMA 200 Period (Structure)
input int ADXPeriod = 14;                      // ADX Period
input int MACDFastPeriod = 12;                 // MACD Fast Period
input int MACDSlowPeriod = 26;                 // MACD Slow Period
input int MACDSignalPeriod = 9;                // MACD Signal Period
input int ATRPeriod = 14;                      // ATR Period
input int RequiredConfluenceScore = 2;         // Required Confluence Score (1-3)

// Market Filters
input group "Market Filters"
input bool UseNewsFilter = true;               // Filter out high-impact news
input int NewsBefore = 60;                     // Minutes before news
input int NewsAfter = 30;                      // Minutes after news
input bool UseSessionFilter = true;            // Filter trading sessions
input int GMTOffset = 2;                       // GMT offset for session filter
input bool UseADXFilter = true;                // Use ADX trend filter
input double ADXThreshold = 22.0;              // ADX threshold
input bool UsePropFirmHoursFilter = true;      // Limit trading to PropFirm active hours

// UI Settings
input group "UI Settings"
input bool EnableDashboard = true;             // Enable visual dashboard
input int DashboardX = 20;                     // Dashboard X position
input int DashboardY = 20;                     // Dashboard Y position
input color BullishColor = clrGreen;           // Bullish Color
input color BearishColor = clrRed;             // Bearish Color
input color NeutralColor = clrGray;            // Neutral Color

// Logging and Reports
input group "Logging and Reports"
input bool EnableDetailedLogging = true;       // Enable detailed logging
input bool SaveDailyReports = true;            // Save daily reports
input bool EnableEmailAlerts = false;          // Enable email alerts
input bool EnablePushNotifications = false;    // Enable push notifications
input int LogLevel = 2;                        // Log Level (0=Error, 1=Warning, 2=Info, 3=Debug)

// Global variables
CSonicREAManager* g_manager = NULL;            // Main EA Manager
int g_magicNumber = 7754321;                  // EA Magic Number

//+------------------------------------------------------------------+
//| Expert initialization function                                    |
//+------------------------------------------------------------------+
int OnInit() {
    // Display initialization message
    Print("Initializing SonicR PropFirm EA v3.0...");
    
    // Create EA Manager
    g_manager = new CSonicREAManager(Symbol(), PERIOD_H1);
    if(g_manager == NULL) {
        Print("ERROR: Failed to create EA Manager instance");
        return INIT_FAILED;
    }
    
    // Configure manager with input parameters
    if(!ConfigureManager()) {
        Print("ERROR: Failed to configure EA Manager");
        delete g_manager;
        g_manager = NULL;
        return INIT_FAILED;
    }
    
    // Initialize manager
    if(!g_manager.Initialize()) {
        Print("ERROR: Failed to initialize EA Manager");
        delete g_manager;
        g_manager = NULL;
        return INIT_FAILED;
    }
    
    // Set up timer for periodic events (every second)
    EventSetTimer(1);
    
    Print("SonicR PropFirm EA v3.0 successfully initialized");
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    // Clean up timer
    EventKillTimer();
    
    // Clean up manager
    if(g_manager != NULL) {
        Print("Deinitializing SonicR PropFirm EA...");
        g_manager.Deinitialize();
        delete g_manager;
        g_manager = NULL;
    }
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick() {
    // Skip if manager not initialized
    if(g_manager == NULL) return;
    
    // Process tick
    g_manager.ProcessTick();
    
    // Process new bar if applicable
    if(IsNewBar()) {
        g_manager.ProcessNewBar();
    }
}

//+------------------------------------------------------------------+
//| Timer event function                                              |
//+------------------------------------------------------------------+
void OnTimer() {
    // Skip if manager not initialized
    if(g_manager == NULL) return;
    
    // Process timer event
    g_manager.ProcessTimer();
}

//+------------------------------------------------------------------+
//| ChartEvent function                                               |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam) {
    // Skip if manager not initialized
    if(g_manager == NULL) return;
    
    // Process chart event
    g_manager.ProcessChartEvent(id, lparam, dparam, sparam);
}

//+------------------------------------------------------------------+
//| Check for new bar                                                 |
//+------------------------------------------------------------------+
bool IsNewBar() {
    static datetime last_time = 0;
    datetime current_time = iTime(Symbol(), PERIOD_H1, 0);
    
    if(current_time != last_time) {
        last_time = current_time;
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Configure Manager with Input Parameters                           |
//+------------------------------------------------------------------+
bool ConfigureManager() {
    if(g_manager == NULL) return false;
    
    // Set magic number
    g_manager.SetMagicNumber(g_magicNumber);
    
    // Configure PropFirm Settings
    g_manager.SetPropFirmSettings(PropFirmType, ChallengePhase);
    
    // Configure Risk Management
    g_manager.SetRiskParameters(
        RiskPercent,
        MaxDailyDrawdown,
        MaxTotalDrawdown,
        MaxDailyTrades,
        MaxConcurrentTrades,
        PortfolioMaxRisk,
        MaxCorrelationThreshold
    );
    
    // Configure Order Management
    g_manager.SetOrderParameters(
        PartialClosePercent,
        BreakEvenLevel,
        TrailingActivationR,
        TakeProfitMultiplier1,
        MaxRetryAttempts,
        RetryDelayMs
    );
    
    // Configure SuperTrend
    g_manager.SetSuperTrendParameters(
        SuperTrendPeriod,
        SuperTrendMultiplier
    );
    
    // Configure Strategy
    g_manager.SetStrategyParameters(
        EMA34Period,
        EMA89Period,
        EMA200Period,
        ADXPeriod,
        MACDFastPeriod,
        MACDSlowPeriod,
        MACDSignalPeriod,
        ATRPeriod,
        RequiredConfluenceScore
    );
    
    // Configure Market Filters
    g_manager.SetMarketFilters(
        UseNewsFilter,
        NewsBefore,
        NewsAfter,
        UseSessionFilter,
        GMTOffset,
        UseADXFilter,
        ADXThreshold,
        UsePropFirmHoursFilter
    );
    
    // Configure UI
    g_manager.SetUIParameters(
        EnableDashboard,
        DashboardX,
        DashboardY,
        BullishColor,
        BearishColor,
        NeutralColor
    );
    
    // Configure Logging
    g_manager.SetLoggingParameters(
        EnableDetailedLogging,
        SaveDailyReports,
        EnableEmailAlerts,
        EnablePushNotifications,
        LogLevel
    );
    
    return true;
}