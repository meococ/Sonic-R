//+------------------------------------------------------------------+
//|                                                RiskOptimizer.mqh |
//|                RiskOptimizer.mqh - APEX Pullback EA v5 FINAL    |
//|      Description: Advanced Risk Optimization & Money Management |
//|                   Ported from v14 with improved architecture    |
//+------------------------------------------------------------------+

#ifndef RISK_OPTIMIZER_MQH_
#define RISK_OPTIMIZER_MQH_

#include "..\..\00_Core\CommonStructs.mqh"

namespace ApexPullback::v5 {

//+------------------------------------------------------------------+
//| Risk Optimization Enumerations                                  |
//+------------------------------------------------------------------+
enum ENUM_PAUSE_REASON {
    PAUSE_NONE,
    PAUSE_CONSECUTIVE_LOSSES,
    PAUSE_DAILY_LOSS_LIMIT,
    PAUSE_VOLATILITY_SPIKE,
    PAUSE_DRAWDOWN_LIMIT,
    PAUSE_NEWS_EVENT,
    PAUSE_MANUAL,
    PAUSE_EMERGENCY
};

enum ENUM_MARKET_STRATEGY {
    STRATEGY_DEFAULT,
    STRATEGY_CONSERVATIVE,
    STRATEGY_BALANCED,
    STRATEGY_AGGRESSIVE,
    STRATEGY_SWING,
    STRATEGY_SCALPING,
    STRATEGY_TREND_FOLLOWING,
    STRATEGY_MEAN_REVERSION
};

enum ENUM_TRAILING_PHASE {
    TRAILING_NONE,
    TRAILING_BREAKEVEN,
    TRAILING_FIRST_LOCK,
    TRAILING_SECOND_LOCK,
    TRAILING_THIRD_LOCK,
    TRAILING_DYNAMIC
};

//+------------------------------------------------------------------+
//| Risk Optimization Structures                                    |
//+------------------------------------------------------------------+
struct SPauseState {
    bool                  ShouldPause;         // Should pause trading
    ENUM_PAUSE_REASON     Reason;              // Pause reason
    int                   PauseMinutes;        // Duration in minutes
    string                Message;             // Descriptive message
    datetime              PauseUntil;          // Resume time
    bool                  AllowManualResume;   // Allow manual resume
};

struct STrailingAction {
    bool                  ShouldTrail;         // Should update trailing stop
    double                NewStopLoss;         // New stop loss price
    double                RMultiple;           // Current R multiple
    double                LockPercentage;      // Percentage of profit to lock
    ENUM_TRAILING_PHASE   Phase;              // Current trailing phase
    string                Description;         // Action description
};

struct SRiskMetrics {
    double                CurrentRiskPercent;  // Current risk percentage
    double                DailyLossPercent;    // Daily loss percentage
    double                WeeklyPnL;           // Weekly P&L
    double                MonthlyPnL;          // Monthly P&L
    double                MaxDrawdownPercent;  // Maximum drawdown
    double                EquityPeak;          // Equity peak
    int                   ConsecutiveLosses;   // Consecutive losses count
    int                   ConsecutiveWins;     // Consecutive wins count
    datetime              LastUpdateTime;      // Last update time
};

struct SVolatilityMetrics {
    double                CurrentATR;          // Current ATR value
    double                AverageATR;          // Average ATR
    double                VolatilityRatio;     // Current/Average ratio
    double                VolatilityMultiplier; // Risk adjustment multiplier
    bool                  IsHighVolatility;   // High volatility flag
    datetime              LastCalculation;    // Last calculation time
};

struct STradeParameters {
    double                LotSize;             // Calculated lot size
    double                StopLoss;            // Stop loss price
    double                TakeProfit;          // Take profit price
    double                RiskAmount;          // Risk amount in currency
    double                RiskMultiplier;      // Applied risk multiplier
    bool                  IsValid;             // Parameters validity
    string                ValidationMessage;   // Validation details
};

//+------------------------------------------------------------------+
//| Risk Optimizer Configuration                                    |
//+------------------------------------------------------------------+
struct SRiskOptimizerConfig {
    // Basic Risk Settings
    double                BaseRiskPercent;     // Base risk percentage (2.0)
    double                MaxRiskPercent;      // Maximum risk percentage (5.0)
    double                MinRiskPercent;      // Minimum risk percentage (0.5)
    double                MaxRiskUSD;          // Maximum risk in USD
    bool                  UseFixedMaxRiskUSD;  // Use fixed USD limit
    
    // Stop Loss & Take Profit
    double                SL_ATR_Multiplier;   // SL ATR multiplier (2.0)
    double                TP_RR_Ratio;         // Take Profit R:R ratio (2.0)
    double                MinSL_Points;        // Minimum SL in points
    double                MaxSL_Points;        // Maximum SL in points
    
    // Performance-based Adjustment
    bool                  EnablePerformanceAdjustment; // Enable adjustment
    double                WinRateThreshold;    // Win rate threshold (60%)
    double                LossRateThreshold;   // Loss rate threshold (30%)
    double                PerformanceBonus;    // Performance bonus multiplier
    double                PerformancePenalty;  // Performance penalty multiplier
    
    // Volatility Adjustment
    bool                  EnableVolatilityAdjustment; // Enable volatility adj
    double                VolatilityThreshold; // Volatility spike threshold
    double                VolatilityMultiplier; // Volatility adjustment factor
    int                   ATR_Period;          // ATR calculation period
    
    // Auto Pause Settings
    bool                  EnableAutoPause;     // Enable auto pause
    int                   ConsecutiveLossLimit; // Consecutive loss limit
    double                DailyLossLimit;      // Daily loss limit (%)
    double                DrawdownLimit;       // Drawdown limit (%)
    int                   PauseMinutes;        // Default pause duration
    bool                  EnableAutoResume;    // Enable auto resume
    
    // Trailing Stop Settings
    bool                  EnableSmartTrailing; // Enable smart trailing
    double                BreakevenRMultiple;  // Breakeven R multiple
    double                FirstLockRMultiple;  // First lock R multiple
    double                SecondLockRMultiple; // Second lock R multiple
    double                ThirdLockRMultiple;  // Third lock R multiple
    double                LockPercentageFirst; // First lock percentage
    double                LockPercentageSecond; // Second lock percentage
    double                LockPercentageThird; // Third lock percentage
    
    // Scaling Settings
    bool                  EnableScaling;       // Enable position scaling
    int                   MaxScalingCount;     // Maximum scaling count
    double                MinRMultipleForScaling; // Min R for scaling
    bool                  RequireBreakevenForScaling; // Require BE for scaling
    bool                  ScalingRequiresTrend; // Scaling requires trend
    
    // Market Strategy
    bool                  EnableStrategyAdaptation; // Enable strategy adaptation
    int                   StrategyUpdateInterval; // Update interval (minutes)
    bool                  UseMarketRegimeFilter; // Use market regime filter
    
    // Cache & Performance
    int                   CacheTimeSeconds;    // Cache time in seconds
    bool                  EnableDetailedLogging; // Enable detailed logs
    bool                  EnablePerformanceStats; // Enable performance stats
};

//+------------------------------------------------------------------+
//| CRiskOptimizer - Advanced Risk Management                       |
//+------------------------------------------------------------------+
class CRiskOptimizer {
private:
    EAContext*            m_pContext;           // Reference to EA context
    bool                  m_bInitialized;      // Initialization status
    
    // Configuration
    SRiskOptimizerConfig  m_Config;             // Risk optimizer configuration
    
    // Current State
    SRiskMetrics          m_Metrics;            // Current risk metrics
    SVolatilityMetrics    m_Volatility;         // Volatility metrics
    SPauseState           m_PauseState;         // Current pause state
    ENUM_MARKET_STRATEGY  m_CurrentStrategy;    // Current market strategy
    
    // Performance Tracking
    double                m_DayStartBalance;    // Day start balance
    double                m_WeekStartBalance;   // Week start balance
    double                m_MonthStartBalance;  // Month start balance
    datetime              m_LastDayStart;       // Last day start time
    datetime              m_LastWeekStart;      // Last week start time
    datetime              m_LastMonthStart;     // Last month start time
    
    // Volatility Calculation
    double                m_ATR_Buffer[];       // ATR calculation buffer
    int                   m_ATR_Handle;         // ATR indicator handle
    datetime              m_LastATRUpdate;      // Last ATR update time
    
    // Risk Adjustment Factors
    double                m_PerformanceMultiplier; // Performance-based multiplier
    double                m_VolatilityMultiplier;  // Volatility-based multiplier
    double                m_MarketMultiplier;      // Market condition multiplier
    double                m_FinalRiskMultiplier;   // Final combined multiplier
    
    // Scaling & Position Management
    int                   m_ScalingCount;       // Current scaling count
    datetime              m_LastTradeTime;      // Last trade time
    bool                  m_TradingAllowed;     // Trading allowed flag
    
    // Update Tracking
    datetime              m_LastUpdate;         // Last update time
    datetime              m_LastMetricsUpdate;  // Last metrics update
    datetime              m_LastStrategyUpdate; // Last strategy update
    
    // Constants
    static const int      DEFAULT_ATR_PERIOD;
    static const double   DEFAULT_RISK_PERCENT;
    static const int      MAX_CONSECUTIVE_LOSSES;
    
public:
    //--- Constructor/Destructor ---
    CRiskOptimizer(EAContext* context);
    ~CRiskOptimizer();
    
    //--- Core Methods ---
    bool                  Initialize(const SRiskOptimizerConfig& config);
    void                  Deinitialize();
    bool                  IsInitialized() const { return m_bInitialized; }
    void                  Update();
    
    //--- Event Handlers ---
    void                  OnTick();
    void                  OnNewBar();
    void                  OnTradeOpened(const long ticket, const double profit = 0.0);
    void                  OnTradeClosed(const long ticket, const double profit);
    void                  OnNewsEvent(const ENUM_NEWS_IMPACT impact);
    
    //--- Trade Parameter Calculation ---
    bool                  CalculateTradeParameters(const double entry_price, 
                                                   const double initial_sl,
                                                   const ENUM_ORDER_TYPE order_type,
                                                   STradeParameters& params);
    
    bool                  ValidateTradeParameters(const STradeParameters& params);
    double                CalculateOptimalLotSize(const double risk_amount, const double sl_points);
    
    //--- Risk Assessment ---
    SPauseState           CheckAutoPause();
    bool                  ShouldPauseTrading();
    bool                  ShouldResumeTrading();
    bool                  IsTradingAllowed() const { return m_TradingAllowed && !m_PauseState.ShouldPause; }
    
    //--- Position Management ---
    STrailingAction       CheckTrailingStop(const long position_ticket);
    bool                  ShouldScaleIn(const long original_ticket);
    bool                  ShouldPartialClose(const long position_ticket, double& close_percentage);
    
    //--- Market Strategy ---
    ENUM_MARKET_STRATEGY  GetCurrentStrategy() const { return m_CurrentStrategy; }
    bool                  UpdateMarketStrategy();
    double                GetStrategyRiskMultiplier() const;
    
    //--- Risk Metrics ---
    SRiskMetrics          GetRiskMetrics() const { return m_Metrics; }
    SVolatilityMetrics    GetVolatilityMetrics() const { return m_Volatility; }
    double                GetCurrentRiskMultiplier() const { return m_FinalRiskMultiplier; }
    double                GetDailyPnL() const;
    double                GetWeeklyPnL() const;
    double                GetMonthlyPnL() const;
    
    //--- Pause Management ---
    void                  PauseTrading(const ENUM_PAUSE_REASON reason, const int minutes = 0);
    void                  ResumeTrading();
    bool                  IsPaused() const { return m_PauseState.ShouldPause; }
    SPauseState           GetPauseState() const { return m_PauseState; }
    
    //--- Configuration ---
    bool                  SetConfiguration(const SRiskOptimizerConfig& config);
    SRiskOptimizerConfig  GetConfiguration() const { return m_Config; }
    void                  ResetToDefaults();
    
    //--- Statistics ---
    string                GetPerformanceReport();
    string                GetRiskReport();
    string                GetStrategyReport();
    
    //--- Utility ---
    void                  Reset();
    bool                  IsConfigValid() const;
    
private:
    //--- Internal Updates ---
    void                  UpdateRiskMetrics();
    void                  UpdateVolatilityMetrics();
    void                  UpdatePerformanceMultipliers();
    void                  UpdateDailyWeeklyMonthly();
    
    //--- Risk Calculations ---
    double                CalculatePerformanceMultiplier();
    double                CalculateVolatilityMultiplier();
    double                CalculateMarketMultiplier();
    void                  UpdateFinalRiskMultiplier();
    
    //--- ATR & Volatility ---
    bool                  InitializeATR();
    void                  UpdateATR();
    double                GetCurrentATR();
    double                GetAverageATR(const int periods = 20);
    
    //--- Strategy Detection ---
    ENUM_MARKET_STRATEGY  DetectMarketStrategy();
    bool                  IsHighVolatilityPeriod();
    bool                  IsTrendingMarket();
    bool                  IsRangingMarket();
    
    //--- Pause Logic ---
    bool                  CheckConsecutiveLosses();
    bool                  CheckDailyLossLimit();
    bool                  CheckDrawdownLimit();
    bool                  CheckVolatilitySpike();
    
    //--- Utility Methods ---
    void                  LogRiskEvent(const string& event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO);
    void                  ValidateConfiguration();
    datetime              GetStartOfDay(const datetime time);
    datetime              GetStartOfWeek(const datetime time);
    datetime              GetStartOfMonth(const datetime time);
    
    //--- Memory Management ---
    void                  CleanupResources();
};

// Static constants definition
const int CRiskOptimizer::DEFAULT_ATR_PERIOD = 14;
const double CRiskOptimizer::DEFAULT_RISK_PERCENT = 2.0;
const int CRiskOptimizer::MAX_CONSECUTIVE_LOSSES = 5;

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CRiskOptimizer::CRiskOptimizer(EAContext* context) {
    m_pContext = context;
    m_bInitialized = false;
    m_ATR_Handle = INVALID_HANDLE;
    m_ScalingCount = 0;
    m_TradingAllowed = true;
    
    // Initialize structures
    ZeroMemory(m_Config);
    ZeroMemory(m_Metrics);
    ZeroMemory(m_Volatility);
    ZeroMemory(m_PauseState);
    
    // Set default configuration
    ResetToDefaults();
    
    // Initialize times
    m_LastUpdate = 0;
    m_LastMetricsUpdate = 0;
    m_LastStrategyUpdate = 0;
    m_LastATRUpdate = 0;
    m_LastTradeTime = 0;
    
    // Initialize multipliers
    m_PerformanceMultiplier = 1.0;
    m_VolatilityMultiplier = 1.0;
    m_MarketMultiplier = 1.0;
    m_FinalRiskMultiplier = 1.0;
    
    // Initialize balance tracking
    m_DayStartBalance = 0.0;
    m_WeekStartBalance = 0.0;
    m_MonthStartBalance = 0.0;
    m_LastDayStart = 0;
    m_LastWeekStart = 0;
    m_LastMonthStart = 0;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CRiskOptimizer::~CRiskOptimizer() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CRiskOptimizer::Initialize(const SRiskOptimizerConfig& config) {
    if (m_bInitialized) {
        return true;
    }
    
    if (m_pContext == NULL) {
        Print("[RISK_OPTIMIZER] Context is NULL");
        return false;
    }
    
    // Set configuration
    m_Config = config;
    ValidateConfiguration();
    
    // Initialize ATR indicator
    if (!InitializeATR()) {
        LogRiskEvent("Failed to initialize ATR indicator", LOG_LEVEL_ERROR);
        return false;
    }
    
    // Initialize balance tracking
    double current_balance = AccountInfoDouble(ACCOUNT_BALANCE);
    m_DayStartBalance = current_balance;
    m_WeekStartBalance = current_balance;
    m_MonthStartBalance = current_balance;
    
    datetime current_time = TimeCurrent();
    m_LastDayStart = GetStartOfDay(current_time);
    m_LastWeekStart = GetStartOfWeek(current_time);
    m_LastMonthStart = GetStartOfMonth(current_time);
    
    // Initialize metrics
    m_Metrics.EquityPeak = AccountInfoDouble(ACCOUNT_EQUITY);
    m_Metrics.LastUpdateTime = current_time;
    
    // Set initial strategy
    m_CurrentStrategy = STRATEGY_BALANCED;
    
    m_bInitialized = true;
    
    if (m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo("RiskOptimizer initialized successfully", __FUNCTION__);
        LogRiskEvent(GetRiskReport(), LOG_LEVEL_INFO);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CRiskOptimizer::Deinitialize() {
    if (!m_bInitialized) {
        return;
    }
    
    // Log final performance report
    if (m_pContext != NULL && m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo(GetPerformanceReport(), __FUNCTION__);
        m_pContext->pLogger->LogInfo("RiskOptimizer shutting down", __FUNCTION__);
    }
    
    // Cleanup resources
    CleanupResources();
    
    m_bInitialized = false;
}

//+------------------------------------------------------------------+
//| Update                                                           |
//+------------------------------------------------------------------+
void CRiskOptimizer::Update() {
    if (!m_bInitialized) {
        return;
    }
    
    datetime current_time = TimeCurrent();
    
    // Update metrics periodically
    if (current_time - m_LastMetricsUpdate >= m_Config.CacheTimeSeconds) {
        UpdateRiskMetrics();
        UpdateVolatilityMetrics();
        UpdatePerformanceMultipliers();
        m_LastMetricsUpdate = current_time;
    }
    
    // Update daily/weekly/monthly tracking
    UpdateDailyWeeklyMonthly();
    
    // Update market strategy
    if (m_Config.EnableStrategyAdaptation && 
        current_time - m_LastStrategyUpdate >= m_Config.StrategyUpdateInterval * 60) {
        UpdateMarketStrategy();
        m_LastStrategyUpdate = current_time;
    }
    
    // Check pause conditions
    if (m_Config.EnableAutoPause && !m_PauseState.ShouldPause) {
        SPauseState pause_check = CheckAutoPause();
        if (pause_check.ShouldPause) {
            m_PauseState = pause_check;
            LogRiskEvent("Auto-pause triggered: " + pause_check.Message, LOG_LEVEL_WARNING);
        }
    }
    
    // Check resume conditions
    if (m_PauseState.ShouldPause && m_Config.EnableAutoResume) {
        if (ShouldResumeTrading()) {
            ResumeTrading();
        }
    }
    
    m_LastUpdate = current_time;
}

//+------------------------------------------------------------------+
//| Calculate Trade Parameters                                       |
//+------------------------------------------------------------------+
bool CRiskOptimizer::CalculateTradeParameters(const double entry_price,
                                              const double initial_sl,
                                              const ENUM_ORDER_TYPE order_type,
                                              STradeParameters& params) {
    if (!m_bInitialized) {
        params.IsValid = false;
        params.ValidationMessage = "RiskOptimizer not initialized";
        return false;
    }
    
    // Check if trading is allowed
    if (!IsTradingAllowed()) {
        params.IsValid = false;
        params.ValidationMessage = "Trading is paused: " + m_PauseState.Message;
        return false;
    }
    
    // Get current risk multiplier
    double risk_multiplier = GetCurrentRiskMultiplier();
    if (risk_multiplier <= 0) {
        params.IsValid = false;
        params.ValidationMessage = "Risk multiplier is zero or negative";
        return false;
    }
    
    // Calculate stop loss distance
    double current_atr = GetCurrentATR();
    if (current_atr <= 0) {
        params.IsValid = false;
        params.ValidationMessage = "Invalid ATR value";
        return false;
    }
    
    double sl_distance = initial_sl * m_Config.SL_ATR_Multiplier * current_atr;
    
    // Calculate stop loss price
    double sl_price;
    if (order_type == ORDER_TYPE_BUY) {
        sl_price = entry_price - sl_distance;
    } else {
        sl_price = entry_price + sl_distance;
    }
    
    // Calculate take profit price
    double tp_distance = sl_distance * m_Config.TP_RR_Ratio;
    double tp_price;
    if (order_type == ORDER_TYPE_BUY) {
        tp_price = entry_price + tp_distance;
    } else {
        tp_price = entry_price - tp_distance;
    }
    
    // Calculate risk amount
    double account_balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double base_risk_amount = account_balance * (m_Config.BaseRiskPercent / 100.0);
    double adjusted_risk_amount = base_risk_amount * risk_multiplier;
    
    // Apply risk limits
    double max_risk_amount = account_balance * (m_Config.MaxRiskPercent / 100.0);
    if (adjusted_risk_amount > max_risk_amount) {
        adjusted_risk_amount = max_risk_amount;
    }
    
    if (m_Config.UseFixedMaxRiskUSD && adjusted_risk_amount > m_Config.MaxRiskUSD) {
        adjusted_risk_amount = m_Config.MaxRiskUSD;
    }
    
    // Calculate lot size
    double lot_size = CalculateOptimalLotSize(adjusted_risk_amount, sl_distance / SymbolInfoDouble(_Symbol, SYMBOL_POINT));
    
    // Fill parameters structure
    params.LotSize = lot_size;
    params.StopLoss = sl_price;
    params.TakeProfit = tp_price;
    params.RiskAmount = adjusted_risk_amount;
    params.RiskMultiplier = risk_multiplier;
    params.IsValid = true;
    params.ValidationMessage = "Parameters calculated successfully";
    
    // Validate parameters
    if (!ValidateTradeParameters(params)) {
        return false;
    }
    
    if (m_Config.EnableDetailedLogging && m_pContext->pLogger != NULL) {
        string log_msg = StringFormat("Trade parameters: Lot=%.2f, SL=%.5f, TP=%.5f, Risk=%.2f, Multiplier=%.2f",
                                     params.LotSize, params.StopLoss, params.TakeProfit, 
                                     params.RiskAmount, params.RiskMultiplier);
        m_pContext->pLogger->LogDebug(log_msg, __FUNCTION__);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Reset To Defaults                                                |
//+------------------------------------------------------------------+
void CRiskOptimizer::ResetToDefaults() {
    // Basic Risk Settings
    m_Config.BaseRiskPercent = DEFAULT_RISK_PERCENT;
    m_Config.MaxRiskPercent = 5.0;
    m_Config.MinRiskPercent = 0.5;
    m_Config.MaxRiskUSD = 1000.0;
    m_Config.UseFixedMaxRiskUSD = false;
    
    // Stop Loss & Take Profit
    m_Config.SL_ATR_Multiplier = 2.0;
    m_Config.TP_RR_Ratio = 2.0;
    m_Config.MinSL_Points = 10.0;
    m_Config.MaxSL_Points = 200.0;
    
    // Performance-based Adjustment
    m_Config.EnablePerformanceAdjustment = true;
    m_Config.WinRateThreshold = 60.0;
    m_Config.LossRateThreshold = 30.0;
    m_Config.PerformanceBonus = 1.2;
    m_Config.PerformancePenalty = 0.8;
    
    // Volatility Adjustment
    m_Config.EnableVolatilityAdjustment = true;
    m_Config.VolatilityThreshold = 1.5;
    m_Config.VolatilityMultiplier = 0.7;
    m_Config.ATR_Period = DEFAULT_ATR_PERIOD;
    
    // Auto Pause Settings
    m_Config.EnableAutoPause = true;
    m_Config.ConsecutiveLossLimit = MAX_CONSECUTIVE_LOSSES;
    m_Config.DailyLossLimit = 5.0;
    m_Config.DrawdownLimit = 10.0;
    m_Config.PauseMinutes = 60;
    m_Config.EnableAutoResume = true;
    
    // Trailing Stop Settings
    m_Config.EnableSmartTrailing = true;
    m_Config.BreakevenRMultiple = 0.5;
    m_Config.FirstLockRMultiple = 1.0;
    m_Config.SecondLockRMultiple = 2.0;
    m_Config.ThirdLockRMultiple = 3.0;
    m_Config.LockPercentageFirst = 50.0;
    m_Config.LockPercentageSecond = 70.0;
    m_Config.LockPercentageThird = 80.0;
    
    // Scaling Settings
    m_Config.EnableScaling = false;
    m_Config.MaxScalingCount = 2;
    m_Config.MinRMultipleForScaling = 0.5;
    m_Config.RequireBreakevenForScaling = true;
    m_Config.ScalingRequiresTrend = true;
    
    // Market Strategy
    m_Config.EnableStrategyAdaptation = true;
    m_Config.StrategyUpdateInterval = 15;
    m_Config.UseMarketRegimeFilter = true;
    
    // Cache & Performance
    m_Config.CacheTimeSeconds = 10;
    m_Config.EnableDetailedLogging = false;
    m_Config.EnablePerformanceStats = true;
}

//+------------------------------------------------------------------+
//| Internal Methods - Portfolio of advanced risk management logic  |
//+------------------------------------------------------------------+

void CRiskOptimizer::UpdateRiskMetrics() {
    double current_equity = AccountInfoDouble(ACCOUNT_EQUITY);
    double current_balance = AccountInfoDouble(ACCOUNT_BALANCE);
    
    // Update equity peak
    if (current_equity > m_Metrics.EquityPeak) {
        m_Metrics.EquityPeak = current_equity;
    }
    
    // Calculate current drawdown
    if (m_Metrics.EquityPeak > 0) {
        m_Metrics.MaxDrawdownPercent = (m_Metrics.EquityPeak - current_equity) / m_Metrics.EquityPeak * 100.0;
    }
    
    // Calculate daily loss percentage
    if (m_DayStartBalance > 0) {
        m_Metrics.DailyLossPercent = (m_DayStartBalance - current_balance) / m_DayStartBalance * 100.0;
    }
    
    // Update PnL calculations
    m_Metrics.WeeklyPnL = current_balance - m_WeekStartBalance;
    m_Metrics.MonthlyPnL = current_balance - m_MonthStartBalance;
    
    m_Metrics.LastUpdateTime = TimeCurrent();
}

double CRiskOptimizer::CalculateOptimalLotSize(const double risk_amount, const double sl_points) {
    if (sl_points <= 0 || risk_amount <= 0) {
        return 0.0;
    }
    
    double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    double tick_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
    double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    
    if (tick_value <= 0 || tick_size <= 0 || point <= 0) {
        return 0.0;
    }
    
    // Calculate lot size
    double pip_value = tick_value * point / tick_size;
    double lot_size = risk_amount / (sl_points * pip_value);
    
    // Normalize lot size
    double min_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double max_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
    double lot_step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
    
    if (lot_step > 0) {
        lot_size = MathRound(lot_size / lot_step) * lot_step;
    }
    
    lot_size = MathMax(lot_size, min_lot);
    lot_size = MathMin(lot_size, max_lot);
    
    return lot_size;
}

SPauseState CRiskOptimizer::CheckAutoPause() {
    SPauseState pause_state;
    ZeroMemory(pause_state);
    
    if (!m_Config.EnableAutoPause) {
        return pause_state;
    }
    
    // Check consecutive losses
    if (CheckConsecutiveLosses()) {
        pause_state.ShouldPause = true;
        pause_state.Reason = PAUSE_CONSECUTIVE_LOSSES;
        pause_state.PauseMinutes = m_Config.PauseMinutes;
        pause_state.Message = StringFormat("Consecutive losses limit reached: %d", m_Metrics.ConsecutiveLosses);
        pause_state.PauseUntil = TimeCurrent() + pause_state.PauseMinutes * 60;
        return pause_state;
    }
    
    // Check daily loss limit
    if (CheckDailyLossLimit()) {
        pause_state.ShouldPause = true;
        pause_state.Reason = PAUSE_DAILY_LOSS_LIMIT;
        pause_state.PauseMinutes = 1440; // Rest of the day
        pause_state.Message = StringFormat("Daily loss limit reached: %.2f%%", m_Metrics.DailyLossPercent);
        pause_state.PauseUntil = GetStartOfDay(TimeCurrent() + 86400); // Next day start
        return pause_state;
    }
    
    // Check drawdown limit
    if (CheckDrawdownLimit()) {
        pause_state.ShouldPause = true;
        pause_state.Reason = PAUSE_DRAWDOWN_LIMIT;
        pause_state.PauseMinutes = m_Config.PauseMinutes * 2; // Longer pause for drawdown
        pause_state.Message = StringFormat("Drawdown limit reached: %.2f%%", m_Metrics.MaxDrawdownPercent);
        pause_state.PauseUntil = TimeCurrent() + pause_state.PauseMinutes * 60;
        return pause_state;
    }
    
    // Check volatility spike
    if (CheckVolatilitySpike()) {
        pause_state.ShouldPause = true;
        pause_state.Reason = PAUSE_VOLATILITY_SPIKE;
        pause_state.PauseMinutes = 15; // Short pause for volatility
        pause_state.Message = StringFormat("Volatility spike detected: %.2f", m_Volatility.VolatilityRatio);
        pause_state.PauseUntil = TimeCurrent() + pause_state.PauseMinutes * 60;
        return pause_state;
    }
    
    return pause_state;
}

void CRiskOptimizer::LogRiskEvent(const string& event, const ENUM_LOG_LEVEL level) {
    if (m_pContext != NULL && m_pContext->pLogger != NULL) {
        switch(level) {
            case LOG_LEVEL_ERROR:
                m_pContext->pLogger->LogError(event, __FUNCTION__);
                break;
            case LOG_LEVEL_WARNING:
                m_pContext->pLogger->LogWarning(event, __FUNCTION__);
                break;
            default:
                m_pContext->pLogger->LogInfo(event, __FUNCTION__);
        }
    }
}

} // namespace ApexPullback::v5

#endif // RISK_OPTIMIZER_MQH_