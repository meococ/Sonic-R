//+------------------------------------------------------------------+
//|                                    APEX_PullbackEA_v5_FINAL.mq5 |
//|                   APEX Pullback EA v5 FINAL - Enhanced System   |
//|      Description: Advanced pullback trading EA with v14         |
//|                   enhanced architecture and sophisticated       |
//|                   trading capabilities                          |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, APEX Trading Systems"
#property link      "https://apex-trading.com"
#property version   "5.00"
#property description "APEX Pullback EA v5 FINAL - Enhanced with v14 Architecture"
#property description "- Advanced pullback detection with AssetDNA"
#property description "- Multi-strategy signal generation with v14 enhancements"
#property description "- Comprehensive risk management and broker health monitoring"
#property description "- Real-time performance analytics with sophisticated metrics"
#property description "- Enhanced dashboard and monitoring capabilities"

// === CORE SYSTEM INCLUDE ===
#include "00_Core/ApexCore.mqh"

// Use the enhanced namespace
using namespace ApexPullback;

//+------------------------------------------------------------------+
//| EA INPUT PARAMETERS - ENHANCED WITH V14 FEATURES                |
//+------------------------------------------------------------------+
input group "=== TRADING STRATEGY ==="
input ENUM_TRADING_STRATEGY      Strategy = STRATEGY_PULLBACK_TREND;     // Primary trading strategy
input ENUM_DIRECTION_FILTER      AllowedDirection = DIRECTION_BOTH;       // Allowed trade direction
input bool                       UseAssetDNA = true;                      // Enable AssetDNA optimization
input bool                       UseMultiTimeframe = true;                // Enable multi-timeframe analysis
input bool                       AdaptiveStrategy = true;                 // Enable adaptive strategy selection

input group "=== TECHNICAL INDICATORS ==="
input int                        EMA_Fast = 21;                           // Fast EMA period
input int                        EMA_Slow = 200;                          // Slow EMA period
input ENUM_TIMEFRAMES            MainTimeframe = PERIOD_M15;              // Main trading timeframe
input int                        RSI_Period = 14;                         // RSI period
input int                        ATR_Period = 14;                         // ATR period

input group "=== RISK MANAGEMENT ==="
input double                     MaxRiskPercent = 2.0;                    // Maximum risk per trade (%)
input double                     MaxDailyRisk = 6.0;                      // Maximum daily risk (%)
input double                     MaxDrawdownPercent = 15.0;               // Maximum allowed drawdown (%)
input bool                       UsePositionSizing = true;                // Enable dynamic position sizing
input bool                       UseCorrelationFilter = true;             // Enable correlation filtering
input double                     MaxSpreadPoints = 3.0;                   // Maximum spread (points)

input group "=== TRADE MANAGEMENT ==="
input double                     MinRiskReward = 2.0;                     // Minimum risk/reward ratio
input bool                       UseTrailingStop = true;                  // Enable trailing stop
input double                     TrailingStopPips = 20.0;                 // Trailing stop distance (pips)
input bool                       UseBreakeven = true;                     // Enable breakeven stop
input double                     BreakevenPips = 10.0;                    // Breakeven trigger (pips)
input int                        MaxConcurrentTrades = 3;                 // Maximum concurrent trades

input group "=== NEWS AND TIME FILTERS ==="
input bool                       UseNewsFilter = true;                    // Enable news filtering
input ENUM_NEWS_FILTER_LEVEL     NewsFilterLevel = NEWS_FILTER_HIGH;      // News filter sensitivity
input bool                       UseTradingHours = true;                  // Enable trading hours filter
input string                     TradingStartTime = "08:00";              // Trading start time
input string                     TradingEndTime = "18:00";                // Trading end time

input group "=== SYSTEM SETTINGS ==="
input int                        MagicNumber = 20241201;                  // Magic number for trades
input bool                       ShowDashboard = true;                    // Show trading dashboard
input ENUM_LOG_LEVEL             LogLevel = LOG_LEVEL_INFO;              // Logging level
input bool                       LogToFile = true;                       // Save logs to file
input bool                       AutoRecovery = true;                     // Enable automatic error recovery
input bool                       EnableAlerts = true;                     // Enable trading alerts

input group "=== ADVANCED SETTINGS ==="
input double                     ConfidenceThreshold = 0.6;               // Minimum signal confidence
input bool                       UseMarketProfile = true;                 // Enable market profile analysis
input bool                       UseVolumeAnalysis = false;               // Enable volume analysis
input int                        MaxRetries = 3;                          // Maximum operation retries
input int                        SlippagePoints = 3;                      // Maximum slippage (points)

input group "=== V14 ENHANCED FEATURES ==="
input bool                       EnableRiskOptimizer = true;              // Enable advanced risk optimization
input bool                       EnableAssetDNALearning = true;           // Enable AssetDNA learning capabilities
input bool                       EnableBrokerHealthMonitoring = true;     // Enable broker health monitoring
input int                        HistoryAnalysisMonths = 12;              // Months of history to analyze
input double                     DecayHalfLifeDays = 30.0;                // Trade importance decay half-life
input bool                       EnableMethodLogging = false;             // Enable detailed method logging
input bool                       EnableStrategyPerformanceLogging = true; // Enable strategy performance logging
input bool                       EnableDetailedScoreLogging = false;      // Enable detailed score logging
input bool                       EnableColdStartLogging = true;           // Enable cold start logging
input bool                       EnableDNAPrinting = true;                // Enable DNA analysis printing
input int                        MinTradesForPerformance = 10;            // Minimum trades for performance analysis
input double                     DefaultPerformanceScore = 0.5;           // Default performance score for new strategies
input double                     MarketSuitabilityWeight = 0.6;           // Weight for market suitability in strategy selection
input double                     PastPerformanceWeight = 0.4;             // Weight for past performance in strategy selection

//+------------------------------------------------------------------+
//| GLOBAL VARIABLES - ENHANCED ARCHITECTURE                        |
//+------------------------------------------------------------------+
CCore*                           g_pCore = NULL;                         // Enhanced Central Core System
bool                             g_bSystemReady = false;                  // System ready flag
datetime                         g_startTime = 0;                        // EA start time

//+------------------------------------------------------------------+
//| Expert initialization function - Enhanced with v14 patterns     |
//+------------------------------------------------------------------+
int OnInit() {
    Print("================================================================");
    Print("    APEX Pullback EA v5 FINAL (Enhanced) - Initializing...");
    Print("    Version: " + GetEAVersion());
    Print("    Build: " + GetEABuildDate());
    Print("    Architecture: Enhanced v14 + v5 Hybrid");
    Print("================================================================");

    g_startTime = TimeCurrent();
    
    // === ENHANCED INITIALIZATION PROCESS ===
    
    // 1. Create enhanced core system
    g_pCore = new CCore();
    if(!g_pCore) {
        Print("CRITICAL FAILURE: Unable to create Core system - EA cannot start");
        return INIT_FAILED;
    }
    
    // 2. Prepare enhanced input parameters
    EAInputParams inputParams;
    SetupEnhancedInputParameters(inputParams);
    
    // 3. Initialize core with sophisticated error handling
    if(!g_pCore->Initialize(inputParams)) {
        Print("CRITICAL FAILURE: Core system initialization failed");
        delete g_pCore;
        g_pCore = NULL;
        return INIT_FAILED;
    }
    
    // 4. Verify system health
    if(!g_pCore->IsHealthy()) {
        Print("WARNING: System health check indicates potential issues");
        Print("Health Score: " + DoubleToString(g_pCore->GetSystemHealthScore(), 2));
        // Continue but with warning
    }
    
    // 5. Start system monitoring
    EventSetTimer(30); // 30-second intervals for system monitoring
    
    g_bSystemReady = true;
    
    // 6. Log successful initialization
    EAContext* pContext = g_pCore->GetContext();
    if(pContext && pContext->pLogger) {
        pContext->pLogger->LogInfo("=== APEX Pullback EA v5 FINAL Successfully Started ===", __FUNCTION__);
        pContext->pLogger->LogInfo("Magic Number: " + IntegerToString(inputParams.MagicNumber), __FUNCTION__);
        pContext->pLogger->LogInfo("Trading Symbol: " + _Symbol, __FUNCTION__);
        pContext->pLogger->LogInfo("Account Type: " + (AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_DEMO ? "DEMO" : "LIVE"), __FUNCTION__);
        pContext->pLogger->LogInfo("AssetDNA Enabled: " + (inputParams.UseAssetDNA ? "YES" : "NO"), __FUNCTION__);
        pContext->pLogger->LogInfo("Broker Health Monitoring: " + (inputParams.EnableBrokerHealthMonitoring ? "YES" : "NO"), __FUNCTION__);
    }
    
    Print("=== APEX Pullback EA v5 FINAL Ready for Trading ===");
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function - Enhanced cleanup             |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    Print("================================================================");
    Print("    APEX Pullback EA v5 FINAL (Enhanced) - Shutting Down...");
    Print("================================================================");
    
    // Stop timer
    EventKillTimer();
    
    // Calculate runtime
    if(g_startTime > 0) {
        long runtimeSeconds = TimeCurrent() - g_startTime;
        Print("Total Runtime: " + TimeToString(runtimeSeconds, TIME_MINUTES | TIME_SECONDS));
    }
    
    // Log shutdown reason
    string reasonStr = "";
    switch(reason) {
        case REASON_PROGRAM:    reasonStr = "Program terminated"; break;
        case REASON_REMOVE:     reasonStr = "Expert removed"; break;
        case REASON_RECOMPILE:  reasonStr = "Expert recompiled"; break;
        case REASON_CHARTCHANGE:reasonStr = "Chart changed"; break;
        case REASON_CHARTCLOSE: reasonStr = "Chart closed"; break;
        case REASON_PARAMETERS: reasonStr = "Parameters changed"; break;
        case REASON_ACCOUNT:    reasonStr = "Account changed"; break;
        case REASON_TEMPLATE:   reasonStr = "Template changed"; break;
        case REASON_INITFAILED: reasonStr = "Initialization failed"; break;
        case REASON_CLOSE:      reasonStr = "Terminal closed"; break;
        default:                reasonStr = "Unknown reason (" + IntegerToString(reason) + ")"; break;
    }
    
    // Log final statistics if available
    if(g_pCore && g_bSystemReady) {
        EAContext* pContext = g_pCore->GetContext();
        if(pContext && pContext->pLogger) {
            pContext->pLogger->LogInfo("EA Shutdown Initiated: " + reasonStr, __FUNCTION__);
            pContext->pLogger->LogInfo("Final System Health: " + DoubleToString(g_pCore->GetSystemHealthScore(), 2), __FUNCTION__);
            
            // Log performance summary
            if(pContext->Performance.TotalTrades > 0) {
                pContext->pLogger->LogInfo(StringFormat("Performance Summary - Trades: %d, Win Rate: %.2f%%, Profit Factor: %.2f", 
                                          pContext->Performance.TotalTrades,
                                          pContext->Performance.WinRate,
                                          pContext->Performance.ProfitFactor), __FUNCTION__);
            }
        }
    }
    
    // Enhanced cleanup
    g_bSystemReady = false;
    
    if(g_pCore) {
        g_pCore->Deinitialize();
        delete g_pCore;
        g_pCore = NULL;
    }
    
    Print("[EA] APEX Pullback EA v5 FINAL shutdown completed. Reason: " + reasonStr);
    Print("================================================================");
}

//+------------------------------------------------------------------+
//| Expert tick function - Enhanced event processing                |
//+------------------------------------------------------------------+
void OnTick() {
    // Enhanced safety checks
    if(!g_bSystemReady || !g_pCore || !g_pCore->IsInitialized()) {
        return;
    }
    
    // System health monitoring
    if(!g_pCore->IsHealthy()) {
        static datetime lastHealthWarning = 0;
        if(TimeCurrent() - lastHealthWarning > 300) { // Every 5 minutes
            Print("WARNING: System health degraded - Score: " + DoubleToString(g_pCore->GetSystemHealthScore(), 2));
            lastHealthWarning = TimeCurrent();
        }
    }
    
    // Delegate to enhanced core system
    g_pCore->OnTick();
}

//+------------------------------------------------------------------+
//| Timer function - Enhanced system monitoring                     |
//+------------------------------------------------------------------+
void OnTimer() {
    if(!g_bSystemReady || !g_pCore) return;
    
    // Enhanced system monitoring and maintenance
    static int timerCount = 0;
    timerCount++;
    
    // Delegate to core
    g_pCore->OnTimer();
    
    // Periodic system health reporting (every 10 minutes)
    if(timerCount % 20 == 0) { // 20 * 30 seconds = 10 minutes
        EAContext* pContext = g_pCore->GetContext();
        if(pContext && pContext->pLogger && pContext->InputParams.EnableMethodLogging) {
            double healthScore = g_pCore->GetSystemHealthScore();
            pContext->pLogger->LogInfo(StringFormat("System Health Check - Score: %.2f, Status: %s", 
                                      healthScore, g_pCore->GetSystemStatus()), __FUNCTION__);
        }
    }
}

//+------------------------------------------------------------------+
//| Trade transaction function - Enhanced trade monitoring          |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans, const MqlTradeRequest& request, const MqlTradeResult& result) {
    if(!g_bSystemReady || !g_pCore) return;
    
    // Delegate to enhanced core system
    g_pCore->OnTradeTransaction(trans, request, result);
}

//+------------------------------------------------------------------+
//| Chart event function - Enhanced UI interaction                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam) {
    if(!g_bSystemReady || !g_pCore) return;
    
    // Delegate to enhanced core system
    g_pCore->OnChartEvent(id, lparam, dparam, sparam);
}

//+------------------------------------------------------------------+
//| Setup Enhanced Input Parameters                                 |
//+------------------------------------------------------------------+
void SetupEnhancedInputParameters(EAInputParams& params) {
    // === BASIC TRADING STRATEGY ===
    params.Strategy = Strategy;
    params.AllowedDirection = AllowedDirection;
    params.UseAssetDNA = UseAssetDNA;
    params.UseMultiTimeframe = UseMultiTimeframe;
    params.AdaptiveStrategy = AdaptiveStrategy;
    
    // === TECHNICAL INDICATORS ===
    params.EMA_Fast = EMA_Fast;
    params.EMA_Slow = EMA_Slow;
    params.MainTimeframe = MainTimeframe;
    params.RSI_Period = RSI_Period;
    params.ATR_Period = ATR_Period;
    
    // === RISK MANAGEMENT ===
    params.MaxRiskPercent = MaxRiskPercent;
    params.MaxDailyRisk = MaxDailyRisk;
    params.MaxDrawdownPercent = MaxDrawdownPercent;
    params.UsePositionSizing = UsePositionSizing;
    params.UseCorrelationFilter = UseCorrelationFilter;
    params.MaxSpreadPoints = MaxSpreadPoints;
    
    // === TRADE MANAGEMENT ===
    params.MinRiskReward = MinRiskReward;
    params.UseTrailingStop = UseTrailingStop;
    params.TrailingStopPips = TrailingStopPips;
    params.UseBreakeven = UseBreakeven;
    params.BreakevenPips = BreakevenPips;
    params.MaxConcurrentTrades = MaxConcurrentTrades;
    
    // === NEWS AND TIME FILTERS ===
    params.UseNewsFilter = UseNewsFilter;
    params.NewsFilterLevel = NewsFilterLevel;
    params.UseTradingHours = UseTradingHours;
    params.TradingStartTime = TradingStartTime;
    params.TradingEndTime = TradingEndTime;
    
    // === SYSTEM SETTINGS ===
    params.MagicNumber = MagicNumber;
    params.ShowDashboard = ShowDashboard;
    params.LogLevel = LogLevel;
    params.LogToFile = LogToFile;
    params.AutoRecovery = AutoRecovery;
    params.EnableAlerts = EnableAlerts;
    
    // === ADVANCED SETTINGS ===
    params.ConfidenceThreshold = ConfidenceThreshold;
    params.UseMarketProfile = UseMarketProfile;
    params.UseVolumeAnalysis = UseVolumeAnalysis;
    params.MaxRetries = MaxRetries;
    params.SlippagePoints = SlippagePoints;
    
    // === V14 ENHANCED FEATURES ===
    params.EnableRiskOptimizer = EnableRiskOptimizer;
    params.EnableAssetDNALearning = EnableAssetDNALearning;
    params.EnableBrokerHealthMonitoring = EnableBrokerHealthMonitoring;
    params.HistoryAnalysisMonths = HistoryAnalysisMonths;
    params.DecayHalfLifeDays = DecayHalfLifeDays;
    params.EnableMethodLogging = EnableMethodLogging;
    params.EnableStrategyPerformanceLogging = EnableStrategyPerformanceLogging;
    params.EnableDetailedScoreLogging = EnableDetailedScoreLogging;
    params.EnableColdStartLogging = EnableColdStartLogging;
    params.EnableDNAPrinting = EnableDNAPrinting;
    params.MinTradesForPerformance = MinTradesForPerformance;
    params.DefaultPerformanceScore = DefaultPerformanceScore;
    params.MarketSuitabilityWeight = MarketSuitabilityWeight;
    params.PastPerformanceWeight = PastPerformanceWeight;
    
    Print("[EA] Enhanced input parameters configured with v14 features");
}

//+------------------------------------------------------------------+
//| ENHANCED UTILITY FUNCTIONS                                      |
//+------------------------------------------------------------------+

// Get current EA status with enhanced information
string GetEnhancedEAStatus() {
    if(!g_bSystemReady || !g_pCore) return "SYSTEM_NOT_READY";
    if(!g_pCore->IsInitialized()) return "NOT_INITIALIZED";
    if(!g_pCore->IsHealthy()) return "UNHEALTHY";
    return g_pCore->GetSystemStatus();
}

// Get comprehensive system report
string GetEnhancedSystemReport() {
    if(!g_bSystemReady || !g_pCore) return "System not ready";
    
    string report = "=== APEX PULLBACK EA v5 FINAL SYSTEM REPORT ===\n";
    report += "Version: " + GetEAVersion() + "\n";
    report += "Status: " + GetEnhancedEAStatus() + "\n";
    report += "Health Score: " + DoubleToString(g_pCore->GetSystemHealthScore(), 2) + "\n";
    
    EAContext* pContext = g_pCore->GetContext();
    if(pContext) {
        report += "Trades: " + IntegerToString(pContext->Performance.TotalTrades) + "\n";
        report += "Win Rate: " + DoubleToString(pContext->Performance.WinRate, 2) + "%\n";
        report += "Profit Factor: " + DoubleToString(pContext->Performance.ProfitFactor, 2) + "\n";
    }
    
    report += "===============================================";
    return report;
}

// Emergency system restart (for manual intervention)
bool RestartEnhancedSystem() {
    Print("=== EMERGENCY SYSTEM RESTART INITIATED ===");
    
    if(g_pCore) {
        EAInputParams currentParams;
        if(g_pCore->GetContext()) {
            currentParams = g_pCore->GetContext()->InputParams;
        }
        
        g_pCore->Deinitialize();
        delete g_pCore;
        g_pCore = NULL;
        
        g_pCore = new CCore();
        if(!g_pCore || !g_pCore->Initialize(currentParams)) {
            Print("CRITICAL: Emergency restart failed");
            return false;
        }
    }
    
    Print("=== EMERGENCY SYSTEM RESTART COMPLETED ===");
    return true;
}

//+------------------------------------------------------------------+
//| ENHANCED VERSION INFORMATION                                    |
//+------------------------------------------------------------------+
string GetEnhancedVersionInfo() {
    string info = "";
    info += "APEX Pullback EA v5 FINAL (Enhanced)\n";
    info += "Version: " + GetEAVersion() + "\n";
    info += "Build Date: " + GetEABuildDate() + "\n";
    info += "Copyright: " + GetEACopyright() + "\n";
    info += "Architecture: Enhanced v14 + v5 Hybrid\n";
    info += "Features: AssetDNA, BrokerHealth, Advanced Risk Management\n";
    info += "Capabilities: Multi-Strategy, Cross-Validation, Adaptive Learning\n";
    return info;
}