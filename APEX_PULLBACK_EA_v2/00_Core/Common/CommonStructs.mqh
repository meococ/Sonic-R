//+------------------------------------------------------------------+
//|                                                CommonStructs.mqh |
//|                       APEX PULLBACK EA v5 FINAL - Enhanced Core |
//|      Description: Core Data Structures & Context (v14 Enhanced) |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, APEX Trading Systems"
#property link      "https://apex-trading.com"
#property version   "5.00"
#property description "APEX Pullback EA v5 FINAL - Enhanced Core Architecture"

#ifndef APEX_COMMON_STRUCTS_V5_FINAL_MQH
#define APEX_COMMON_STRUCTS_V5_FINAL_MQH

#include "Enums.mqh"

//+------------------------------------------------------------------+
//| APEX PULLBACK NAMESPACE - v5 FINAL ENHANCED                     |
//+------------------------------------------------------------------+
namespace ApexPullback {

// Forward declarations for central EAContext
struct EAContext;

//+------------------------------------------------------------------+
//| FORWARD DECLARATIONS - CRITICAL DEPENDENCY MANAGEMENT           |
//| This prevents circular dependencies and ensures clean compilation|
//+------------------------------------------------------------------+

// Core Infrastructure
class CLogger;
class CErrorHandler;
class CFunctionStack;
class CParameterStore;
class CStateManager;
class CConfigManager;

// Framework Layer
class CTimeManager;
class CBrokerInterface;
class CIntegrationManager;

// Data Providers
class CIndicatorManager;
class CMarketDataProvider;
class CSymbolManager;

// Market Analysis
class CMarketAnalysisManager;
class CAssetDNA;
class CTechnicalAnalyzer;
class CBrokerHealthMonitor;
class CSlippageMonitor;
class CMarketProfile;

// Signal Generation
class CSignalManager;
class CSignalEngine;
class CSignalFilters;

// Risk Management
class CRiskManager;
class CRiskCalculator;
class CCircuitBreaker;
class CNewsFilter;
class CRiskOptimizer; // Enhanced from v14

// Trade Management
class CTradeManager;
class CTradeExecutor;
class CPositionManager;
class CTrailingStopManager;

// Optimization
class COptimizationManager;
class CStrategyOptimizer;
class CMonteCarloSimulator;
class CWalkForwardAnalyzer;

// Analytics
class CAnalyticsManager;
class CPerformanceAnalyzer;
class CReportGenerator;
class CDataCollector;

// User Interface
class CUIManager;
class CDashboard;
class CAlertManager;
class CNotificationCenter;

// Utilities
class CIndicatorUtils;
class CMathHelper;
class CDrawingUtils;

//+------------------------------------------------------------------+
//| ENHANCED INPUT PARAMETERS STRUCTURE                             |
//+------------------------------------------------------------------+
struct EAInputParams {
    // === TRADING STRATEGY ===
    ENUM_TRADING_STRATEGY Strategy;
    ENUM_DIRECTION_FILTER AllowedDirection;
    bool UseAssetDNA;
    bool UseMultiTimeframe;
    bool AdaptiveStrategy;
    
    // === TECHNICAL INDICATORS ===
    int EMA_Fast;
    int EMA_Slow;
    ENUM_TIMEFRAMES MainTimeframe;
    int RSI_Period;
    int ATR_Period;
    
    // === RISK MANAGEMENT ===
    double MaxRiskPercent;
    double MaxDailyRisk;
    double MaxDrawdownPercent;
    bool UsePositionSizing;
    bool UseCorrelationFilter;
    double MaxSpreadPoints;
    
    // === TRADE MANAGEMENT ===
    double MinRiskReward;
    bool UseTrailingStop;
    double TrailingStopPips;
    bool UseBreakeven;
    double BreakevenPips;
    int MaxConcurrentTrades;
    
    // === NEWS AND TIME FILTERS ===
    bool UseNewsFilter;
    ENUM_NEWS_FILTER_LEVEL NewsFilterLevel;
    bool UseTradingHours;
    string TradingStartTime;
    string TradingEndTime;
    
    // === SYSTEM SETTINGS ===
    int MagicNumber;
    bool ShowDashboard;
    ENUM_LOG_LEVEL LogLevel;
    bool LogToFile;
    bool AutoRecovery;
    bool EnableAlerts;
    
    // === ADVANCED SETTINGS ===
    double ConfidenceThreshold;
    bool UseMarketProfile;
    bool UseVolumeAnalysis;
    int MaxRetries;
    int SlippagePoints;
    
    // === V14 ENHANCED FEATURES ===
    bool EnableRiskOptimizer;
    bool EnableAssetDNALearning;
    bool EnableBrokerHealthMonitoring;
    int HistoryAnalysisMonths;
    double DecayHalfLifeDays;
    bool EnableMethodLogging;
    bool EnableStrategyPerformanceLogging;
    bool EnableDetailedScoreLogging;
    bool EnableColdStartLogging;
    bool EnableDNAPrinting;
    int MinTradesForPerformance;
    double DefaultPerformanceScore;
    double MarketSuitabilityWeight;
    double PastPerformanceWeight;
    
    void SetDefaults() {
        Strategy = STRATEGY_PULLBACK_TREND;
        AllowedDirection = DIRECTION_BOTH;
        UseAssetDNA = true;
        UseMultiTimeframe = true;
        AdaptiveStrategy = true;
        EMA_Fast = 21;
        EMA_Slow = 200;
        MainTimeframe = PERIOD_M15;
        RSI_Period = 14;
        ATR_Period = 14;
        MaxRiskPercent = 2.0;
        MaxDailyRisk = 6.0;
        MaxDrawdownPercent = 15.0;
        UsePositionSizing = true;
        UseCorrelationFilter = true;
        MaxSpreadPoints = 3.0;
        MinRiskReward = 2.0;
        UseTrailingStop = true;
        TrailingStopPips = 20.0;
        UseBreakeven = true;
        BreakevenPips = 10.0;
        MaxConcurrentTrades = 3;
        UseNewsFilter = true;
        NewsFilterLevel = NEWS_FILTER_HIGH;
        UseTradingHours = true;
        TradingStartTime = "08:00";
        TradingEndTime = "18:00";
        MagicNumber = 20241201;
        ShowDashboard = true;
        LogLevel = LOG_LEVEL_INFO;
        LogToFile = true;
        AutoRecovery = true;
        EnableAlerts = true;
        ConfidenceThreshold = 0.6;
        UseMarketProfile = true;
        UseVolumeAnalysis = false;
        MaxRetries = 3;
        SlippagePoints = 3;
        
        // V14 Enhanced Features
        EnableRiskOptimizer = true;
        EnableAssetDNALearning = true;
        EnableBrokerHealthMonitoring = true;
        HistoryAnalysisMonths = 12;
        DecayHalfLifeDays = 30.0;
        EnableMethodLogging = true;
        EnableStrategyPerformanceLogging = true;
        EnableDetailedScoreLogging = false;
        EnableColdStartLogging = true;
        EnableDNAPrinting = true;
        MinTradesForPerformance = 10;
        DefaultPerformanceScore = 0.5;
        MarketSuitabilityWeight = 0.6;
        PastPerformanceWeight = 0.4;
    }
};

//+------------------------------------------------------------------+
//| ENHANCED MARKET STATE STRUCTURE                                 |
//+------------------------------------------------------------------+
struct MarketState {
    // Real-time Market Data
    double CurrentBid;
    double CurrentAsk;
    double CurrentSpread;
    datetime LastTickTime;
    
    // Market Condition Analysis
    ENUM_MARKET_REGIME CurrentRegime;
    ENUM_MARKET_TREND PrimaryTrend;
    ENUM_TRADING_SESSION CurrentSession;
    double VolatilityIndex;
    double TrendStrength;
    double MomentumScore;
    
    // Symbol Properties
    double SymbolPoint;
    int SymbolDigits;
    double MinLot;
    double MaxLot;
    double LotStep;
    double TickValue;
    double TickSize;
    
    // Technical Indicators Cache
    double ATR_Current;
    double RSI_Current;
    double MACD_Main;
    double MACD_Signal;
    double EMA_Fast;
    double EMA_Slow;
    
    // Market Profile Data
    double ValueAreaHigh;
    double ValueAreaLow;
    double PointOfControl;
    double VolumeProfile;
    
    void Reset() {
        CurrentBid = 0.0;
        CurrentAsk = 0.0;
        CurrentSpread = 0.0;
        LastTickTime = 0;
        CurrentRegime = REGIME_UNKNOWN;
        PrimaryTrend = TREND_UNKNOWN;
        CurrentSession = SESSION_UNKNOWN;
        VolatilityIndex = 0.0;
        TrendStrength = 0.0;
        MomentumScore = 0.0;
        SymbolPoint = 0.0;
        SymbolDigits = 0;
        MinLot = 0.0;
        MaxLot = 0.0;
        LotStep = 0.0;
        TickValue = 0.0;
        TickSize = 0.0;
        ATR_Current = 0.0;
        RSI_Current = 0.0;
        MACD_Main = 0.0;
        MACD_Signal = 0.0;
        EMA_Fast = 0.0;
        EMA_Slow = 0.0;
        ValueAreaHigh = 0.0;
        ValueAreaLow = 0.0;
        PointOfControl = 0.0;
        VolumeProfile = 0.0;
    }
};

//+------------------------------------------------------------------+
//| ENHANCED EA PARAMETERS STRUCTURE                                 |
//+------------------------------------------------------------------+
struct EAParams {
    // EA Information
    string EAName;
    string EAVersion;
    string BuildDate;
    int MagicNumber;
    
    // Operational State
    ENUM_EA_STATE CurrentState;
    bool IsInitialized;
    bool IsTradingEnabled;
    bool IsBacktest;
    bool IsOptimization;
    bool IsDemo;
    
    // Performance Tracking
    datetime StartTime;
    datetime LastActivityTime;
    int TotalTrades;
    double TotalProfit;
    double MaxDrawdown;
    double CurrentDrawdown;
    
    // System Health
    double HealthScore;
    ENUM_BROKER_HEALTH BrokerHealth;
    double SystemLoad;
    bool EmergencyStop;
    
    void SetDefaults() {
        EAName = "APEX Pullback EA v5 FINAL";
        EAVersion = "5.0.0";
        BuildDate = "2024.12.01";
        MagicNumber = 20241201;
        CurrentState = STATE_INIT;
        IsInitialized = false;
        IsTradingEnabled = true;
        IsBacktest = false;
        IsOptimization = false;
        IsDemo = true;
        StartTime = TimeCurrent();
        LastActivityTime = 0;
        TotalTrades = 0;
        TotalProfit = 0.0;
        MaxDrawdown = 0.0;
        CurrentDrawdown = 0.0;
        HealthScore = 100.0;
        BrokerHealth = HEALTH_EXCELLENT;
        SystemLoad = 0.0;
        EmergencyStop = false;
    }
};

//+------------------------------------------------------------------+
//| ENHANCED SIGNAL CONTEXT STRUCTURE                               |
//+------------------------------------------------------------------+
struct SSignalContext {
    // Signal Identification
    long SignalID;
    ENUM_TRADING_STRATEGY Strategy;
    ENUM_SIGNAL_TYPE SignalType;
    datetime SignalTime;
    
    // Market Context
    string Symbol;
    ENUM_TIMEFRAMES Timeframe;
    double Price;
    double ATR;
    
    // Signal Quality
    double Confidence;
    double Strength;
    double Reliability;
    bool IsValid;
    
    // Risk Parameters
    double StopLoss;
    double TakeProfit;
    double RiskReward;
    double PositionSize;
    
    // Additional Context
    string Description;
    string Reason;
    int FiltersPassed;
    int FiltersTotal;
    
    void Reset() {
        SignalID = 0;
        Strategy = STRATEGY_UNDEFINED;
        SignalType = SIGNAL_NONE;
        SignalTime = 0;
        Symbol = "";
        Timeframe = PERIOD_CURRENT;
        Price = 0.0;
        ATR = 0.0;
        Confidence = 0.0;
        Strength = 0.0;
        Reliability = 0.0;
        IsValid = false;
        StopLoss = 0.0;
        TakeProfit = 0.0;
        RiskReward = 0.0;
        PositionSize = 0.0;
        Description = "";
        Reason = "";
        FiltersPassed = 0;
        FiltersTotal = 0;
    }
};

//+------------------------------------------------------------------+
//| ENHANCED SIGNAL QUALITY STRUCTURE                               |
//+------------------------------------------------------------------+
struct SSignalQuality {
    // Quality Metrics
    double OverallScore;        // 0-100
    double TechnicalScore;      // Technical analysis confidence
    double MarketScore;         // Market condition suitability
    double TimingScore;         // Entry timing quality
    double RiskScore;           // Risk/reward attractiveness
    
    // Validation Flags
    bool PassedTechnical;
    bool PassedFundamental;
    bool PassedTime;
    bool PassedRisk;
    bool PassedCorrelation;
    bool PassedNews;
    
    // Detailed Analysis
    string QualityReason;
    string RiskAssessment;
    string MarketCondition;
    datetime AnalysisTime;
    
    void Reset() {
        OverallScore = 0.0;
        TechnicalScore = 0.0;
        MarketScore = 0.0;
        TimingScore = 0.0;
        RiskScore = 0.0;
        PassedTechnical = false;
        PassedFundamental = false;
        PassedTime = false;
        PassedRisk = false;
        PassedCorrelation = false;
        PassedNews = false;
        QualityReason = "";
        RiskAssessment = "";
        MarketCondition = "";
        AnalysisTime = 0;
    }
};

//+------------------------------------------------------------------+
//| ENHANCED TRADE INFORMATION STRUCTURE                            |
//+------------------------------------------------------------------+
struct STradeInfo {
    // Trade Identification
    ulong Ticket;
    int MagicNumber;
    string Symbol;
    ENUM_POSITION_TYPE Type;
    
    // Trade Parameters
    double Volume;
    double OpenPrice;
    double ClosePrice;
    double StopLoss;
    double TakeProfit;
    
    // Timing
    datetime OpenTime;
    datetime CloseTime;
    double Duration;
    
    // Performance
    double Profit;
    double Commission;
    double Swap;
    double NetProfit;
    
    // Risk Metrics
    double MaxAdverseExcursion;     // MAE
    double MaxFavorableExcursion;   // MFE
    double RiskReward;
    double ActualRisk;
    
    // Signal Context
    ENUM_TRADING_STRATEGY Strategy;
    long SignalID;
    double SignalConfidence;
    string EntryReason;
    string ExitReason;
    
    // Market Context
    double ATR_AtEntry;
    double Spread_AtEntry;
    double Volatility_AtEntry;
    ENUM_MARKET_REGIME Regime_AtEntry;
    
    void Reset() {
        Ticket = 0;
        MagicNumber = 0;
        Symbol = "";
        Type = POSITION_TYPE_BUY;
        Volume = 0.0;
        OpenPrice = 0.0;
        ClosePrice = 0.0;
        StopLoss = 0.0;
        TakeProfit = 0.0;
        OpenTime = 0;
        CloseTime = 0;
        Duration = 0.0;
        Profit = 0.0;
        Commission = 0.0;
        Swap = 0.0;
        NetProfit = 0.0;
        MaxAdverseExcursion = 0.0;
        MaxFavorableExcursion = 0.0;
        RiskReward = 0.0;
        ActualRisk = 0.0;
        Strategy = STRATEGY_UNDEFINED;
        SignalID = 0;
        SignalConfidence = 0.0;
        EntryReason = "";
        ExitReason = "";
        ATR_AtEntry = 0.0;
        Spread_AtEntry = 0.0;
        Volatility_AtEntry = 0.0;
        Regime_AtEntry = REGIME_UNKNOWN;
    }
};

//+------------------------------------------------------------------+
//| ENHANCED PERFORMANCE METRICS STRUCTURE                          |
//+------------------------------------------------------------------+
struct SPerformanceMetrics {
    // Basic Performance
    double TotalNetProfit;
    double TotalGrossProfit;
    double TotalGrossLoss;
    double ProfitFactor;
    double ExpectedPayoff;
    
    // Trade Statistics
    int TotalTrades;
    int WinningTrades;
    int LosingTrades;
    double WinRate;
    double LossRate;
    
    // Risk Metrics
    double MaxDrawdown;
    double MaxDrawdownPercent;
    double CurrentDrawdown;
    double CurrentDrawdownPercent;
    double AverageDrawdown;
    
    // Advanced Risk Metrics
    double SharpeRatio;
    double SortinoRatio;
    double CalmarRatio;
    double VaR_95;                  // Value at Risk 95%
    double ExpectedShortfall;       // Expected Shortfall
    
    // Consistency Metrics
    int ConsecutiveWins;
    int ConsecutiveLosses;
    int MaxConsecutiveWins;
    int MaxConsecutiveLosses;
    double LargestWin;
    double LargestLoss;
    double AverageWin;
    double AverageLoss;
    
    // Time-based Metrics
    double DailyReturn;
    double WeeklyReturn;
    double MonthlyReturn;
    double AnnualizedReturn;
    double Volatility;
    double Information_Ratio;
    
    // Efficiency Metrics
    double RecoveryFactor;
    double ProfitToMaxDD_Ratio;
    double WinLossRatio;
    double AverageTradeLength;
    double TradingFrequency;
    
    void Reset() {
        TotalNetProfit = 0.0;
        TotalGrossProfit = 0.0;
        TotalGrossLoss = 0.0;
        ProfitFactor = 0.0;
        ExpectedPayoff = 0.0;
        TotalTrades = 0;
        WinningTrades = 0;
        LosingTrades = 0;
        WinRate = 0.0;
        LossRate = 0.0;
        MaxDrawdown = 0.0;
        MaxDrawdownPercent = 0.0;
        CurrentDrawdown = 0.0;
        CurrentDrawdownPercent = 0.0;
        AverageDrawdown = 0.0;
        SharpeRatio = 0.0;
        SortinoRatio = 0.0;
        CalmarRatio = 0.0;
        VaR_95 = 0.0;
        ExpectedShortfall = 0.0;
        ConsecutiveWins = 0;
        ConsecutiveLosses = 0;
        MaxConsecutiveWins = 0;
        MaxConsecutiveLosses = 0;
        LargestWin = 0.0;
        LargestLoss = 0.0;
        AverageWin = 0.0;
        AverageLoss = 0.0;
        DailyReturn = 0.0;
        WeeklyReturn = 0.0;
        MonthlyReturn = 0.0;
        AnnualizedReturn = 0.0;
        Volatility = 0.0;
        Information_Ratio = 0.0;
        RecoveryFactor = 0.0;
        ProfitToMaxDD_Ratio = 0.0;
        WinLossRatio = 0.0;
        AverageTradeLength = 0.0;
        TradingFrequency = 0.0;
    }
};

//+------------------------------------------------------------------+
//| ENHANCED ASSET PROFILE STRUCTURE (FROM V14)                     |
//+------------------------------------------------------------------+
struct SAssetProfile {
    // Basic Properties
    string Symbol;
    ENUM_TIMEFRAMES PrimaryTimeframe;
    double AverageSpread;
    double TypicalVolatility;
    
    // Statistical Properties
    double AverageATR;
    double YearlyVolatility;
    double AverageDailyRange;
    double SeasonalityFactor;
    
    // Behavioral Characteristics
    bool IsStrongTrending;
    bool IsMeanReverting;
    bool IsNewsReactive;
    bool IsSessionSensitive;
    
    // Trading Suitability
    double PullbackSuitability;
    double BreakoutSuitability;
    double ScalpingSuitability;
    double SwingSuitability;
    
    // Risk Characteristics
    double MaxHistoricalDrawdown;
    double AverageWinRate;
    double TypicalRiskReward;
    int OptimalPositionSize;
    
    void Reset() {
        Symbol = "";
        PrimaryTimeframe = PERIOD_CURRENT;
        AverageSpread = 0.0;
        TypicalVolatility = 0.0;
        AverageATR = 0.0;
        YearlyVolatility = 0.0;
        AverageDailyRange = 0.0;
        SeasonalityFactor = 0.0;
        IsStrongTrending = false;
        IsMeanReverting = false;
        IsNewsReactive = false;
        IsSessionSensitive = false;
        PullbackSuitability = 0.0;
        BreakoutSuitability = 0.0;
        ScalpingSuitability = 0.0;
        SwingSuitability = 0.0;
        MaxHistoricalDrawdown = 0.0;
        AverageWinRate = 0.0;
        TypicalRiskReward = 0.0;
        OptimalPositionSize = 0;
    }
};

//+------------------------------------------------------------------+
//| ENHANCED RISK METRICS STRUCTURE (FROM V14)                      |
//+------------------------------------------------------------------+
struct SRiskMetrics {
    // Account Risk Metrics
    double AccountBalance;
    double AccountEquity;
    double AccountMargin;
    double AccountFreeMargin;
    double AccountMarginLevel;
    
    // Drawdown Analysis
    double CurrentDrawdown;
    double MaxDrawdown;
    double DailyDrawdown;
    double WeeklyDrawdown;
    double MonthlyDrawdown;
    
    // Value at Risk (VaR)
    double VaR_1Day_95;
    double VaR_1Day_99;
    double VaR_1Week_95;
    double VaR_1Month_95;
    
    // Portfolio Risk
    double PortfolioRisk;
    double ConcentrationRisk;
    double CorrelationRisk;
    double LiquidityRisk;
    
    // Position Risk
    double MaxPositionRisk;
    double CurrentPositionRisk;
    double AveragePositionRisk;
    int MaxPositions;
    int CurrentPositions;
    
    void Reset() {
        AccountBalance = 0.0;
        AccountEquity = 0.0;
        AccountMargin = 0.0;
        AccountFreeMargin = 0.0;
        AccountMarginLevel = 0.0;
        CurrentDrawdown = 0.0;
        MaxDrawdown = 0.0;
        DailyDrawdown = 0.0;
        WeeklyDrawdown = 0.0;
        MonthlyDrawdown = 0.0;
        VaR_1Day_95 = 0.0;
        VaR_1Day_99 = 0.0;
        VaR_1Week_95 = 0.0;
        VaR_1Month_95 = 0.0;
        PortfolioRisk = 0.0;
        ConcentrationRisk = 0.0;
        CorrelationRisk = 0.0;
        LiquidityRisk = 0.0;
        MaxPositionRisk = 0.0;
        CurrentPositionRisk = 0.0;
        AveragePositionRisk = 0.0;
        MaxPositions = 0;
        CurrentPositions = 0;
    }
};

//+------------------------------------------------------------------+
//| CENTRAL EA CONTEXT - THE HEART OF THE SYSTEM                    |
//| Enhanced with v14's sophisticated architecture                   |
//+------------------------------------------------------------------+
struct EAContext {
    // === ENHANCED CORE STATE ===
    EAInputParams InputParams;              // All input parameters
    EAParams Params;                        // EA operational parameters
    MarketState MarketState;                // Current market state
    SSignalContext LastSignal;              // Last signal context
    SPerformanceMetrics Performance;        // Performance metrics
    SAssetProfile AssetProfile;             // Asset characteristics
    SRiskMetrics RiskMetrics;               // Risk metrics
    
    // === SYSTEM STATE ===
    bool IsNewBarEvent;                     // New bar flag
    datetime LastTickTime;                  // Last tick timestamp
    MqlTick LastTick;                       // Last tick data
    bool IsEmergencyStop;                   // Emergency stop flag
    string StatusMessage;                   // Current status message
    
    // === CORE INFRASTRUCTURE POINTERS ===
    CLogger* pLogger;
    CErrorHandler* pErrorHandler;
    CFunctionStack* pFuncStack;
    CParameterStore* pParamStore;
    CStateManager* pStateManager;
    CConfigManager* pConfigManager;
    
    // === FRAMEWORK LAYER POINTERS ===
    CTimeManager* pTimeManager;
    CBrokerInterface* pBrokerInterface;
    CIntegrationManager* pIntegrationManager;
    
    // === DATA PROVIDERS POINTERS ===
    CIndicatorManager* pIndicatorManager;
    CMarketDataProvider* pMarketDataProvider;
    CSymbolManager* pSymbolManager;
    
    // === MARKET ANALYSIS POINTERS ===
    CMarketAnalysisManager* pMarketAnalysisManager;
    CAssetDNA* pAssetDNA;
    CTechnicalAnalyzer* pTechnicalAnalyzer;
    CBrokerHealthMonitor* pBrokerHealthMonitor;
    CSlippageMonitor* pSlippageMonitor;
    CMarketProfile* pMarketProfile;
    
    // === SIGNAL GENERATION POINTERS ===
    CSignalManager* pSignalManager;
    CSignalEngine* pSignalEngine;
    CSignalFilters* pSignalFilters;
    
    // === RISK MANAGEMENT POINTERS ===
    CRiskManager* pRiskManager;
    CRiskCalculator* pRiskCalculator;
    CCircuitBreaker* pCircuitBreaker;
    CNewsFilter* pNewsFilter;
    CRiskOptimizer* pRiskOptimizer;
    
    // === TRADE MANAGEMENT POINTERS ===
    CTradeManager* pTradeManager;
    CTradeExecutor* pTradeExecutor;
    CPositionManager* pPositionManager;
    CTrailingStopManager* pTrailingStopManager;
    
    // === OPTIMIZATION POINTERS ===
    COptimizationManager* pOptimizationManager;
    CStrategyOptimizer* pStrategyOptimizer;
    CMonteCarloSimulator* pMonteCarloSimulator;
    CWalkForwardAnalyzer* pWalkForwardAnalyzer;
    
    // === ANALYTICS POINTERS ===
    CAnalyticsManager* pAnalyticsManager;
    CPerformanceAnalyzer* pPerformanceAnalyzer;
    CReportGenerator* pReportGenerator;
    CDataCollector* pDataCollector;
    
    // === USER INTERFACE POINTERS ===
    CUIManager* pUIManager;
    CDashboard* pDashboard;
    CAlertManager* pAlertManager;
    CNotificationCenter* pNotificationCenter;
    
    // === UTILITIES POINTERS ===
    CIndicatorUtils* pIndicatorUtils;
    CMathHelper* pMathHelper;
    CDrawingUtils* pDrawingUtils;
    
    // === CONSTRUCTOR - INITIALIZE ALL TO NULL ===
    EAContext() {
        // Initialize structures
        InputParams.SetDefaults();
        Params.SetDefaults();
        MarketState.Reset();
        LastSignal.Reset();
        Performance.Reset();
        AssetProfile.Reset();
        RiskMetrics.Reset();
        
        // Initialize system state
        IsNewBarEvent = false;
        LastTickTime = 0;
        ZeroMemory(LastTick);
        IsEmergencyStop = false;
        StatusMessage = "Initializing...";
        
        // Initialize all pointers to NULL
        pLogger = NULL;
        pErrorHandler = NULL;
        pFuncStack = NULL;
        pParamStore = NULL;
        pStateManager = NULL;
        pConfigManager = NULL;
        pTimeManager = NULL;
        pBrokerInterface = NULL;
        pIntegrationManager = NULL;
        pIndicatorManager = NULL;
        pMarketDataProvider = NULL;
        pSymbolManager = NULL;
        pMarketAnalysisManager = NULL;
        pAssetDNA = NULL;
        pTechnicalAnalyzer = NULL;
        pBrokerHealthMonitor = NULL;
        pSlippageMonitor = NULL;
        pMarketProfile = NULL;
        pSignalManager = NULL;
        pSignalEngine = NULL;
        pSignalFilters = NULL;
        pRiskManager = NULL;
        pRiskCalculator = NULL;
        pCircuitBreaker = NULL;
        pNewsFilter = NULL;
        pRiskOptimizer = NULL;
        pTradeManager = NULL;
        pTradeExecutor = NULL;
        pPositionManager = NULL;
        pTrailingStopManager = NULL;
        pOptimizationManager = NULL;
        pStrategyOptimizer = NULL;
        pMonteCarloSimulator = NULL;
        pWalkForwardAnalyzer = NULL;
        pAnalyticsManager = NULL;
        pPerformanceAnalyzer = NULL;
        pReportGenerator = NULL;
        pDataCollector = NULL;
        pUIManager = NULL;
        pDashboard = NULL;
        pAlertManager = NULL;
        pNotificationCenter = NULL;
        pIndicatorUtils = NULL;
        pMathHelper = NULL;
        pDrawingUtils = NULL;
    }
};

//+------------------------------------------------------------------+
//| ENHANCED CONSTANTS AND MAGIC NUMBERS                            |
//+------------------------------------------------------------------+
const int EA_MAGIC_NUMBER_BASE = 20241201;
const string EA_VERSION = "5.0.0 FINAL";
const string EA_BUILD_DATE = "2024.12.01";
const string EA_COPYRIGHT = "Copyright 2024, APEX Trading Systems";

//+------------------------------------------------------------------+
//| UTILITY FUNCTIONS                                               |
//+------------------------------------------------------------------+
string GetEAVersion() { return EA_VERSION; }
string GetEABuildDate() { return EA_BUILD_DATE; }
string GetEACopyright() { return EA_COPYRIGHT; }
int GetEAMagicBase() { return EA_MAGIC_NUMBER_BASE; }

} // END NAMESPACE ApexPullback

#endif // APEX_COMMON_STRUCTS_V5_FINAL_MQH

//+------------------------------------------------------------------+
//| ARCHITECTURE DOCUMENTATION                                      |
//+------------------------------------------------------------------+
/*
 * APEX Pullback EA v5 FINAL - Enhanced Architecture Documentation
 * 
 * This CommonStructs.mqh represents the enhanced core of the EA system,
 * incorporating the best practices and sophisticated patterns from v14:
 * 
 * KEY ENHANCEMENTS FROM V14:
 * 
 * 1. NAMESPACE MANAGEMENT
 *    - Clean ApexPullback namespace encapsulation
 *    - Proper scope isolation and naming conventions
 * 
 * 2. FORWARD DECLARATIONS
 *    - Complete forward declaration pattern to prevent circular dependencies
 *    - Organized by functional layers for clear architecture
 * 
 * 3. ENHANCED STRUCTURES
 *    - More sophisticated EAInputParams with v14 advanced features
 *    - Comprehensive MarketState with real-time analysis
 *    - Professional-grade performance metrics
 *    - Asset profiling capabilities from v14's AssetDNA
 * 
 * 4. CENTRAL EACONTEXT
 *    - Single source of truth for all EA state
 *    - Organized pointer management for all system components
 *    - Proper initialization and cleanup patterns
 * 
 * 5. PROFESSIONAL STANDARDS
 *    - Enterprise-level documentation
 *    - Consistent coding standards and naming conventions
 *    - Robust error handling preparation
 * 
 * This enhanced architecture provides the foundation for a world-class
 * trading system that combines the modularity of v5 with the sophistication
 * and battle-tested patterns of v14.
 */