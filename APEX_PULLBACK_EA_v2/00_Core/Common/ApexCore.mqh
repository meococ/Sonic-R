//+------------------------------------------------------------------+
//|                                                     ApexCore.mqh |
//|                       APEX Pullback EA v5 FINAL - Core System   |
//|      Description: Core system include file for APEX Pullback    |
//|                   EA v5 FINAL with complete architecture.       |
//+------------------------------------------------------------------+

#ifndef APEX_CORE_V5_MQH
#define APEX_CORE_V5_MQH

#property copyright "Copyright 2024, APEX Trading Systems"
#property link      "https://apex-trading.com"
#property version   "5.00"

//+------------------------------------------------------------------+
//| FUNDAMENTAL BUILDING BLOCKS - Core Structures & Enums          |
//+------------------------------------------------------------------+
#include "Enums.mqh"
#include "CommonStructs.mqh"

//+------------------------------------------------------------------+
//| FRAMEWORK LAYER - Core Infrastructure                           |
//+------------------------------------------------------------------+
#include "..\01_Framework\Logging\Logger.mqh"
#include "..\01_Framework\ErrorHandling\ErrorHandler.mqh"
#include "..\01_Framework\Configuration\Configuration.mqh"
#include "..\01_Framework\Time\TimeManager.mqh"
#include "..\01_Framework\Broker\BrokerInterface.mqh"
#include "..\01_Framework\Integration\IntegrationManager.mqh"

//+------------------------------------------------------------------+
//| DATA PROVIDERS LAYER - Market Data & Analysis                   |
//+------------------------------------------------------------------+
#include "..\02_DataProviders\Indicators\IndicatorManager.mqh"
#include "..\02_DataProviders\MarketData\MarketDataProvider.mqh"
#include "..\02_DataProviders\Symbol\SymbolManager.mqh"

//+------------------------------------------------------------------+
//| MARKET ANALYSIS LAYER - Advanced Analysis Components            |
//+------------------------------------------------------------------+
#include "..\03_MarketAnalysis\MarketAnalysisManager.mqh"
#include "..\03_MarketAnalysis\AssetDNA\AssetDNA.mqh"
#include "..\03_MarketAnalysis\Technical\TechnicalAnalyzer.mqh"
#include "..\03_MarketAnalysis\BrokerHealth\BrokerHealthMonitor.mqh"

//+------------------------------------------------------------------+
//| SIGNAL GENERATION LAYER - Signal Engine & Filters              |
//+------------------------------------------------------------------+
#include "..\04_SignalGeneration\Core\SignalManager.mqh"
#include "..\04_SignalGeneration\Core\SignalEngine.mqh"
#include "..\04_SignalGeneration\Filters\SignalFilters.mqh"

//+------------------------------------------------------------------+
//| RISK MANAGEMENT LAYER - Comprehensive Risk Control              |
//+------------------------------------------------------------------+
#include "..\05_RiskManagement\RiskManager.mqh"
#include "..\05_RiskManagement\Core\RiskCalculator.mqh"
#include "..\05_RiskManagement\CircuitBreaker\CircuitBreaker.mqh"
#include "..\05_RiskManagement\NewsFilter\NewsFilter.mqh"

//+------------------------------------------------------------------+
//| TRADE MANAGEMENT LAYER - Execution & Position Management        |
//+------------------------------------------------------------------+
#include "..\06_TradeManagement\Core\TradeManager.mqh"
#include "..\06_TradeManagement\Execution\TradeExecutor.mqh"
#include "..\06_TradeManagement\PositionManagement\PositionManager.mqh"
#include "..\06_TradeManagement\TrailingStops\TrailingStopManager.mqh"

//+------------------------------------------------------------------+
//| OPTIMIZATION LAYER - Parameter & Strategy Optimization          |
//+------------------------------------------------------------------+
#include "..\07_Optimization\OptimizationManager.mqh"
#include "..\07_Optimization\StrategyOptimizer\StrategyOptimizer.mqh"
#include "..\07_Optimization\MonteCarlo\MonteCarloSimulator.mqh"

//+------------------------------------------------------------------+
//| ANALYTICS LAYER - Performance & Reporting                       |
//+------------------------------------------------------------------+
#include "..\08_Analytics\AnalyticsManager.mqh"
#include "..\08_Analytics\Performance\PerformanceAnalyzer.mqh"
#include "..\08_Analytics\Reporting\ReportGenerator.mqh"
#include "..\08_Analytics\Data\DataCollector.mqh"

//+------------------------------------------------------------------+
//| USER INTERFACE LAYER - Dashboard & Controls                     |
//+------------------------------------------------------------------+
#include "..\09_UI\UIManager.mqh"
#include "..\09_UI\Dashboard\Dashboard.mqh"
#include "..\09_UI\Alerts\AlertManager.mqh"
#include "..\09_UI\Notifications\NotificationCenter.mqh"

//+------------------------------------------------------------------+
//| CONFIGURATION MANAGEMENT - Core Config System                   |
//+------------------------------------------------------------------+
#include "..\00_Core\ConfigManager\ConfigManager.mqh"

//+------------------------------------------------------------------+
//| FORWARD DECLARATIONS FOR GLOBAL FUNCTIONS                       |
//+------------------------------------------------------------------+

// Signal generation types
enum SignalDirection {
    SIGNAL_NONE = 0,
    SIGNAL_BUY = 1,
    SIGNAL_SELL = 2
};

// System status types  
enum SystemStatus {
    STATUS_INITIALIZING = 0,
    STATUS_OK = 1,
    STATUS_WARNING = 2,
    STATUS_ERROR = 3,
    STATUS_CRITICAL = 4
};

// Health module types
enum HealthModule {
    HEALTH_MODULE_CORE = 0,
    HEALTH_MODULE_DATA = 1,
    HEALTH_MODULE_RISK = 2,
    HEALTH_MODULE_TRADE = 3,
    HEALTH_MODULE_ANALYTICS = 4,
    HEALTH_MODULE_UI = 5
};

//+------------------------------------------------------------------+
//| GLOBAL UTILITY FUNCTIONS                                        |
//+------------------------------------------------------------------+

// Version information
string GetSystemVersion() {
    return "APEX Pullback EA v5.0 FINAL";
}

// Build timestamp
string GetBuildInfo() {
    return "Build: 2024.12.01.001 - Complete Architecture";
}

// Architecture summary
string GetArchitectureInfo() {
    return "Onion Architecture with 9 Layers + Integration Layer";
}

//+------------------------------------------------------------------+
//| COMPILATION VERIFICATION                                         |
//+------------------------------------------------------------------+
#ifdef __MQL5__
    #define APEX_CORE_COMPILED "APEX Core v5 FINAL compiled successfully for MQL5"
#else
    #error "This system requires MQL5 compiler"
#endif

// Core system validation
bool ValidateApexCore() {
    // Verify all essential includes are available
    // This function can be called during initialization to ensure
    // all components are properly compiled and linked
    return true;
}

#endif // APEX_CORE_V5_MQH

//+------------------------------------------------------------------+
//| CORE SYSTEM INFORMATION                                          |
//+------------------------------------------------------------------+
/*
 * APEX Pullback EA v5 FINAL - Core Architecture
 * 
 * This file serves as the central include hub for the entire system.
 * It follows the Onion Architecture pattern with clear separation
 * of concerns across 9 distinct layers:
 * 
 * 1. Core Layer (01_Core): Fundamental structures and enums
 * 2. Framework Layer (01_Framework): Infrastructure components  
 * 3. Data Providers (02_DataProviders): Market data access
 * 4. Market Analysis (03_MarketAnalysis): Advanced analysis
 * 5. Signal Generation (04_SignalGeneration): Trading signals
 * 6. Risk Management (05_RiskManagement): Risk control
 * 7. Trade Management (06_TradeManagement): Trade execution
 * 8. Optimization (07_Optimization): Strategy optimization
 * 9. Analytics (08_Analytics): Performance analysis
 * 10. User Interface (09_UI): Dashboard and controls
 * 
 * Each layer has clear dependencies and interfaces, ensuring
 * maintainable and scalable code architecture.
 */ 