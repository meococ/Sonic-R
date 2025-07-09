//+------------------------------------------------------------------+
//| RiskOptimizer.mqh                                             |
//| Module for risk and money management optimization              |
//+------------------------------------------------------------------+

#ifndef RISKOPTIMIZER_MQH_
#define RISKOPTIMIZER_MQH_

// --- Standard MQL5 Libraries ---
// #include <Trade/Trade.mqh>       // Uncomment if CTrade or related trade functions are used directly
// #include <Trade/SymbolInfo.mqh>  // Uncomment if symbol properties are directly accessed
// #include <Trade/AccountInfo.mqh> // Uncomment if account information is directly accessed
// #include <Arrays/ArrayObj.mqh>   // Uncomment if CArrayObj or other array classes are used
// #include <Math/Stat/Math.mqh>    // Uncomment if advanced math/stat functions are used

// --- ApexPullback EA Includes ---
#include "CommonStructs.mqh"      // For EAContext and other common structures

// Bắt đầu namespace ApexPullback - chứa tất cả các lớp và cấu trúc của EA
namespace ApexPullback {



//====================================================
//+------------------------------------------------------------------+
//| CRiskOptimizer - Module xử lý tối ưu hóa quản lý rủi ro                |
//+------------------------------------------------------------------+
class CRiskOptimizer {
private:
    // --- Core Dependencies ---
    EAContext* m_context;           // Pointer to the central EA context
    // SRiskOptimizerConfig is now accessed via m_context.RiskOptimizerConfig

    // --- State & Cache Variables ---
    double   m_AverageATR;
    datetime m_LastCalculationTime;
    datetime m_LastBarTime;
    bool     m_IsNewBar;

    // --- Performance & Cycle Tracking ---
    double   m_WeeklyProfit;
    double   m_MonthlyProfit;
    int      m_ConsecutiveProfitDays;
    int      m_ConsecutiveLosses;
    datetime m_LastWeekMonday;
    int      m_CurrentMonth;
    double   m_DayStartBalance;
    double   m_CurrentDailyLossPercent;

    // --- Pause & Trading State ---
    bool     m_IsPaused;
    datetime m_PauseUntil;
    ENUM_PAUSE_REASON m_PauseReason;
    ENUM_SESSION m_LastSession;
    int      m_ScalingCount;

    // --- Risk Adjustment Factors ---
    double   m_CurrentRiskMultiplier;     // The final risk multiplier applied to trades
    double   m_LastEquityPeak;
    double   m_MaxDrawdownPercent;
    double   m_VolatilityBasedMultiplier;
    double   m_MarketConditionMultiplier;
    
    // --- Market Strategy ---
    ENUM_MARKET_STRATEGY m_CurrentStrategy;
    datetime m_LastStrategyUpdateTime;

public:
    // --- Constructor & Destructor ---
    CRiskOptimizer(EAContext* context);
    ~CRiskOptimizer();

    // --- Main Event Handlers ---
    void OnTick();
    void OnNewBar();
    void OnTradeClosed(double profit);

    // --- Core Calculation & Checks ---
    bool CalculateTradeParameters(double entryPrice, double initialStopLoss, ENUM_ORDER_TYPE orderType, double& lotSize, double& slPrice, double& tpPrice);
    PauseState CheckAutoPause();
    TrailingAction CheckTrailingStop(long positionTicket, double currentAsk, double currentBid);
    bool ShouldScaleIn(long originalTicket);

    // --- Getters & State Management ---
    ENUM_MARKET_STRATEGY GetCurrentMarketStrategy();
    void Reset();

private:
    // --- Private Helper Methods ---
    void UpdatePerformanceMetrics();
    void AdjustRiskBasedOnPerformance();
    void UpdateVolatilityAndMarketCondition();
    double GetCurrentRiskMultiplier();
    void UpdateCycleStats();
    void UpdateATR();
    void UpdateMarketStrategy();
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CRiskOptimizer::CRiskOptimizer(EAContext* context) :
    m_context(context)
{
    Reset();
    m_context.Logger.LogInfo("CRiskOptimizer initialized successfully.");
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CRiskOptimizer::~CRiskOptimizer()
{
    // Destructor logic if needed (e.g., freeing resources)
}

//+------------------------------------------------------------------+
//| Reset State                                                      |
//+------------------------------------------------------------------+
void CRiskOptimizer::Reset()
{
    m_AverageATR = 0.0;
    m_LastCalculationTime = 0;
    m_LastBarTime = 0;
    m_IsNewBar = false;

    m_WeeklyProfit = 0.0;
    m_MonthlyProfit = 0.0;
    m_ConsecutiveProfitDays = 0;
    m_ConsecutiveLosses = 0;
    m_LastWeekMonday = 0;
    m_CurrentMonth = 0;
    m_DayStartBalance = m_context.Account.Balance();
    m_CurrentDailyLossPercent = 0.0;

    m_IsPaused = false;
    m_PauseUntil = 0;
    m_PauseReason = PAUSE_NONE;
    m_LastSession = SESSION_UNKNOWN;
    m_ScalingCount = 0;

    m_CurrentRiskMultiplier = 1.0;
    m_LastEquityPeak = m_context.Account.Equity();
    m_MaxDrawdownPercent = 0.0;
    m_VolatilityBasedMultiplier = 1.0;
    m_MarketConditionMultiplier = 1.0;

    m_CurrentStrategy = STRATEGY_DEFAULT;
    m_LastStrategyUpdateTime = 0;

    UpdateATR(); // Initial ATR calculation
    UpdateMarketStrategy(); // Initial strategy determination
    m_context.Logger.LogInfo("CRiskOptimizer state has been reset.");
}


//+------------------------------------------------------------------+
//| OnTick Event Handler                                             |
//+------------------------------------------------------------------+
void CRiskOptimizer::OnTick()
{
    // Check if the EA is currently paused
    if (m_IsPaused && TimeCurrent() < m_PauseUntil) {
        return; // Still in pause period
    }
    if (m_IsPaused && m_context.RiskOptimizerConfig.AutoPause.EnableAutoResume) {
        // Logic to auto-resume if conditions are met
        bool shouldResume = false;
        if (m_context.RiskOptimizerConfig.AutoPause.ResumeOnNewDay && MQL5InfoInteger(MQL5_DAY) != TimeToStruct(m_PauseUntil).day) {
            shouldResume = true;
        }
        if (m_context.RiskOptimizerConfig.AutoPause.ResumeOnSessionChange && m_context.MarketProfile.GetCurrentSession() != m_LastSession) {
            shouldResume = true;
        }

        if (shouldResume) {
            m_IsPaused = false;
            m_PauseUntil = 0;
            m_PauseReason = PAUSE_NONE;
            m_context.Logger.LogInfo("Auto-resumed trading.");
        }
    }

    // Perform periodic updates (not on every single tick to save CPU)
    if (TimeCurrent() - m_LastCalculationTime > m_context.RiskOptimizerConfig.CacheTimeSeconds) {
        UpdatePerformanceMetrics();
        AdjustRiskBasedOnPerformance();
        m_LastCalculationTime = TimeCurrent();
    }
}

//+------------------------------------------------------------------+
//| OnNewBar Event Handler                                           |
//+------------------------------------------------------------------+
void CRiskOptimizer::OnNewBar()
{
    m_IsNewBar = true;
    m_LastBarTime = TimeCurrent();

    // Update daily/weekly/monthly stats
    UpdateCycleStats();

    // Update indicators and market state
    UpdateATR();
    UpdateMarketStrategy();
    UpdateVolatilityAndMarketCondition();

    // Reset scaling count for the new bar
    m_ScalingCount = 0;
}

//+------------------------------------------------------------------+
//| OnTradeClosed Event Handler                                      |
//+------------------------------------------------------------------+
void CRiskOptimizer::OnTradeClosed(double profit)
{
    if (profit > 0) {
        m_ConsecutiveLosses = 0;
        m_ConsecutiveProfitDays++; // This might need more logic to be accurate
    } else if (profit < 0) {
        m_ConsecutiveLosses++;
        m_ConsecutiveProfitDays = 0;
    }

    // Update performance metrics immediately after a trade closes
    UpdatePerformanceMetrics();
    AdjustRiskBasedOnPerformance();
}

//+------------------------------------------------------------------+
//| Calculate Trade Parameters                                       |
//+------------------------------------------------------------------+
bool CRiskOptimizer::CalculateTradeParameters(double entryPrice, double initialStopLoss, ENUM_ORDER_TYPE orderType, double& lotSize, double& slPrice, double& tpPrice)
{
    // 1. Get Final Risk Multiplier
    double finalRiskMultiplier = GetCurrentRiskMultiplier();
    if (finalRiskMultiplier <= 0) {
        m_context.Logger.LogWarning("Risk multiplier is zero or negative. No trade will be placed.");
        return false;
    }

    // 2. Calculate Stop Loss in points and price
    double slPoints = initialStopLoss * m_context.RiskOptimizerConfig.SL_ATR_Multiplier * m_AverageATR;
    if (orderType == ORDER_TYPE_BUY) {
        slPrice = entryPrice - slPoints * m_context.Symbol.Point();
    } else {
        slPrice = entryPrice + slPoints * m_context.Symbol.Point();
    }

    // 3. Calculate Lot Size
    double riskAmount = m_context.Account.Balance() * (m_context.RiskOptimizerConfig.RiskPercent / 100.0) * finalRiskMultiplier;
    if (m_context.RiskOptimizerConfig.UseFixedMaxRiskUSD && riskAmount > m_context.RiskOptimizerConfig.MaxRiskUSD) {
        riskAmount = m_context.RiskOptimizerConfig.MaxRiskUSD;
    }
    if (riskAmount > m_context.Account.Balance() * (m_context.RiskOptimizerConfig.MaxRiskPercent / 100.0)) {
        riskAmount = m_context.Account.Balance() * (m_context.RiskOptimizerConfig.MaxRiskPercent / 100.0);
    }

    double tickValue = m_context.Symbol.TickValue();
    double tickSize = m_context.Symbol.TickSize();
    if (slPoints <= 0 || tickValue <= 0) {
        m_context.Logger.LogError("Invalid SL points or tick value for lot size calculation.");
        return false;
    }
    lotSize = riskAmount / (slPoints * tickValue / tickSize);
    lotSize = m_context.Trade.NormalizeLot(lotSize);

    if (lotSize < m_context.Symbol.LotsMin()) {
        m_context.Logger.LogWarning("Calculated lot size is too small. No trade placed.");
        return false;
    }

    // 4. Calculate Take Profit
    double tpPoints = slPoints * m_context.RiskOptimizerConfig.TP_RR_Ratio;
    if (orderType == ORDER_TYPE_BUY) {
        tpPrice = entryPrice + tpPoints * m_context.Symbol.Point();
    } else {
        tpPrice = entryPrice - tpPoints * m_context.Symbol.Point();
    }

    return true;
}

//+------------------------------------------------------------------+
//| Check Auto Pause Conditions                                      |
//+------------------------------------------------------------------+
PauseState CRiskOptimizer::CheckAutoPause()
{
    PauseState state = {false, PAUSE_NONE, 0, ""};
    if (!m_context.RiskOptimizerConfig.AutoPause.EnableAutoPause || m_IsPaused) {
        return state;
    }

    // Check for consecutive losses
    if (m_ConsecutiveLosses >= m_context.RiskOptimizerConfig.AutoPause.ConsecutiveLossesLimit) {
        state.ShouldPause = true;
        state.Reason = PAUSE_CONSECUTIVE_LOSSES;
        state.PauseMinutes = m_context.RiskOptimizerConfig.AutoPause.PauseMinutes;
        state.Message = "Paused due to consecutive losses.";
        m_IsPaused = true;
        m_PauseUntil = TimeCurrent() + state.PauseMinutes * 60;
        m_PauseReason = state.Reason;
        return state;
    }

    // Check for daily loss limit
    if (m_CurrentDailyLossPercent >= m_context.RiskOptimizerConfig.AutoPause.DailyLossPercentLimit) {
        state.ShouldPause = true;
        state.Reason = PAUSE_DAILY_LOSS_LIMIT;
        state.PauseMinutes = 1440; // Pause for the rest of the day
        state.Message = "Paused due to daily loss limit.";
        m_IsPaused = true;
        m_PauseUntil = TimeCurrent() + state.PauseMinutes * 60;
        m_PauseReason = state.Reason;
        return state;
    }

    // Check for volatility spike
    if (m_context.RiskOptimizerConfig.AutoPause.SkipTradeOnExtremeVolatility) {
        double currentVolatility = m_context.Indicators.iATR(m_context.Symbol.Name(), m_context.Timeframe, 1, 0) / m_AverageATR;
        if (currentVolatility > m_context.RiskOptimizerConfig.AutoPause.VolatilitySpikeFactor) {
             state.ShouldPause = true; // This is a temporary pause for the current signal, not a long-term pause
             state.Reason = PAUSE_VOLATILITY_SPIKE;
             state.Message = "Skipping trade due to extreme volatility spike.";
             return state;
        }
    }

    return state;
}

//+------------------------------------------------------------------+
//| Check Trailing Stop                                              |
//+------------------------------------------------------------------+
TrailingAction CRiskOptimizer::CheckTrailingStop(long positionTicket, double currentAsk, double currentBid)
{
    TrailingAction action = {false, 0.0, 0.0, 0.0, TRAILING_NONE};
    if (!m_context.RiskOptimizerConfig.Trailing.EnableSmartTrailing) {
        return action;
    }

    // Get position info
    if (!m_context.Trade.PositionSelectByTicket(positionTicket)) {
        return action;
    }

    double openPrice = m_context.Trade.PositionGetDouble(POSITION_PRICE_OPEN);
    double currentSL = m_context.Trade.PositionGetDouble(POSITION_SL);
    double initialRiskPoints = MathAbs(openPrice - currentSL) / m_context.Symbol.Point();
    if (initialRiskPoints <= 0) {
        return action;
    }

    double currentProfitPoints = 0;
    ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)m_context.Trade.PositionGetInteger(POSITION_TYPE);
    if (type == POSITION_TYPE_BUY) {
        currentProfitPoints = (currentBid - openPrice) / m_context.Symbol.Point();
    } else {
        currentProfitPoints = (openPrice - currentAsk) / m_context.Symbol.Point();
    }

    double rMultiple = currentProfitPoints / initialRiskPoints;
    action.RMultiple = rMultiple;

    double newSL = currentSL;
    ENUM_TRAILING_PHASE newPhase = TRAILING_NONE;

    // Determine the highest applicable trailing phase
    if (m_context.RiskOptimizerConfig.Trailing.EnableRMultipleTrailing) {
        if (rMultiple >= m_context.RiskOptimizerConfig.Trailing.ThirdLockRMultiple) newPhase = TRAILING_THIRD_LOCK;
        else if (rMultiple >= m_context.RiskOptimizerConfig.Trailing.SecondLockRMultiple) newPhase = TRAILING_SECOND_LOCK;
        else if (rMultiple >= m_context.RiskOptimizerConfig.Trailing.FirstLockRMultiple) newPhase = TRAILING_FIRST_LOCK;
        else if (rMultiple >= m_context.RiskOptimizerConfig.Trailing.BreakEvenRMultiple) newPhase = TRAILING_BREAKEVEN;
    }

    // Calculate new SL based on the determined phase
    switch (newPhase) {
        case TRAILING_THIRD_LOCK:
            action.LockPercentage = m_context.RiskOptimizerConfig.Trailing.LockPercentageThird;
            newSL = openPrice + (type == POSITION_TYPE_BUY ? 1 : -1) * initialRiskPoints * m_context.RiskOptimizerConfig.Trailing.ThirdLockRMultiple * (1.0 - action.LockPercentage / 100.0) * m_context.Symbol.Point();
            break;
        case TRAILING_SECOND_LOCK:
            action.LockPercentage = m_context.RiskOptimizerConfig.Trailing.LockPercentageSecond;
            newSL = openPrice + (type == POSITION_TYPE_BUY ? 1 : -1) * initialRiskPoints * m_context.RiskOptimizerConfig.Trailing.SecondLockRMultiple * (1.0 - action.LockPercentage / 100.0) * m_context.Symbol.Point();
            break;
        case TRAILING_FIRST_LOCK:
            action.LockPercentage = m_context.RiskOptimizerConfig.Trailing.LockPercentageFirst;
            newSL = openPrice + (type == POSITION_TYPE_BUY ? 1 : -1) * initialRiskPoints * m_context.RiskOptimizerConfig.Trailing.FirstLockRMultiple * (1.0 - action.LockPercentage / 100.0) * m_context.Symbol.Point();
            break;
        case TRAILING_BREAKEVEN:
            newSL = openPrice + (type == POSITION_TYPE_BUY ? m_context.RiskOptimizerConfig.PartialClose.BreakEvenBuffer : -m_context.RiskOptimizerConfig.PartialClose.BreakEvenBuffer) * m_context.Symbol.Point();
            break;
    }

    // Check if the new SL is an improvement
    bool isSLImproved = (type == POSITION_TYPE_BUY && newSL > currentSL) || (type == POSITION_TYPE_SELL && newSL < currentSL);

    if (newPhase != TRAILING_NONE && isSLImproved) {
        action.ShouldTrail = true;
        action.NewStopLoss = newSL;
        action.Phase = newPhase;
    }

    return action;
}

//+------------------------------------------------------------------+
//| Check if Scaling In is Allowed                                   |
//+------------------------------------------------------------------+
bool CRiskOptimizer::ShouldScaleIn(long originalTicket)
{
    // 1. Basic checks
    if (!m_context.RiskOptimizerConfig.EnableScaling || m_ScalingCount >= m_context.RiskOptimizerConfig.MaxScalingCount) {
        return false;
    }

    // 2. Get position info
    if (!m_context.Trade.PositionSelectByTicket(originalTicket)) {
        m_context.Logger.LogWarning("Could not select original position for scaling check.");
        return false;
    }

    double openPrice = m_context.Trade.PositionGetDouble(POSITION_PRICE_OPEN);
    double currentSL = m_context.Trade.PositionGetDouble(POSITION_SL);
    double currentPrice = m_context.Trade.PositionGetDouble(POSITION_PRICE_CURRENT);
    ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)m_context.Trade.PositionGetInteger(POSITION_TYPE);

    // 3. Check for breakeven requirement
    if (m_context.RiskOptimizerConfig.RequireBreakEvenForScaling) {
        bool isAtBreakEven = (type == POSITION_TYPE_BUY && currentSL >= openPrice) || (type == POSITION_TYPE_SELL && currentSL <= openPrice);
        if (!isAtBreakEven) {
            return false; // Not yet at breakeven
        }
    }

    // 4. Check for minimum R-multiple requirement
    double initialRiskPoints = MathAbs(openPrice - currentSL) / m_context.Symbol.Point();
    if (initialRiskPoints <= 0) {
        return false;
    }
    double currentProfitPoints = (type == POSITION_TYPE_BUY) ? (currentPrice - openPrice) / m_context.Symbol.Point() : (openPrice - currentPrice) / m_context.Symbol.Point();
    double rMultiple = currentProfitPoints / initialRiskPoints;

    if (rMultiple < m_context.RiskOptimizerConfig.MinRMultipleForScaling) {
        return false; // Not profitable enough
    }

    // 5. Check for clear trend requirement
    if (m_context.RiskOptimizerConfig.ScalingRequiresClearTrend) {
        ENUM_MARKET_STRATEGY strategy = GetCurrentMarketStrategy();
        if (strategy != STRATEGY_SWING && strategy != STRATEGY_AGGRESSIVE) {
            return false; // Market is not in a clear trend
        }
    }

    // If all checks pass, it's okay to scale in.
    // The scaling count will be incremented by the TradeManager after a successful trade.
    return true;
}

//+------------------------------------------------------------------+
//| Get Current Market Strategy                                      |
//+------------------------------------------------------------------+
ENUM_MARKET_STRATEGY CRiskOptimizer::GetCurrentMarketStrategy()
{
    return m_CurrentStrategy;
}




//+------------------------------------------------------------------+
//|                        PRIVATE METHODS                           |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Update Performance Metrics                                       |
//+------------------------------------------------------------------+
void CRiskOptimizer::UpdatePerformanceMetrics()
{
    double currentEquity = m_context.Account.Equity();

    // Update equity peak
    if (currentEquity > m_LastEquityPeak) {
        m_LastEquityPeak = currentEquity;
    }

    // Update drawdown
    m_MaxDrawdownPercent = (m_LastEquityPeak - currentEquity) / m_LastEquityPeak * 100.0;

    // Update daily loss
    m_CurrentDailyLossPercent = (m_DayStartBalance - m_context.Account.Balance()) / m_DayStartBalance * 100.0;
}

//+------------------------------------------------------------------+
//| Adjust Risk Based on Performance                                 |
//+------------------------------------------------------------------+
void CRiskOptimizer::AdjustRiskBasedOnPerformance()
{
    double baseMultiplier = 1.0;

    // Adjust for drawdown
    if (m_Config.EnableDrawdownProtection && m_MaxDrawdownPercent > m_Config.DrawdownReduceThreshold) {
        if (m_Config.EnableTaperedRisk) {
            double excessDD = m_MaxDrawdownPercent - m_Config.DrawdownReduceThreshold;
            double maxDDrange = m_Config.MaxAllowedDrawdown - m_Config.DrawdownReduceThreshold;
            double reductionFactor = (maxDDrange > 0) ? (excessDD / maxDDrange) : 1.0;
            baseMultiplier = 1.0 - (1.0 - m_Config.MinRiskMultiplier) * MathMin(1.0, reductionFactor);
        } else {
            baseMultiplier = m_Config.MinRiskMultiplier;
        }
    }

    // Adjust for profit cycles (weekly/monthly)
    if (m_Config.EnableWeeklyCycle && m_WeeklyProfit < 0) {
        baseMultiplier *= m_Config.WeeklyLossReduceFactor;
    }
    if (m_Config.EnableMonthlyCycle && m_MonthlyProfit > 0) {
        baseMultiplier *= m_Config.MonthlyProfitBoostFactor;
    }

    // Clamp the multiplier to avoid extreme values
    m_CurrentRiskMultiplier = MathMax(m_Config.MinRiskMultiplier, MathMin(m_Config.MaxCycleRiskBoost, baseMultiplier));
}

//+------------------------------------------------------------------+
//| Update Volatility and Market Condition Multipliers               |
//+------------------------------------------------------------------+
void CRiskOptimizer::UpdateVolatilityAndMarketCondition()
{
    // This is a placeholder for more complex logic.
    // e.g., use Market Profile or other indicators to determine market condition.
    m_VolatilityBasedMultiplier = 1.0; // Could be adjusted based on ATR ratio
    m_MarketConditionMultiplier = 1.0; // Could be adjusted based on trend/range detection
}

//+------------------------------------------------------------------+
//| Get Final Current Risk Multiplier                                |
//+------------------------------------------------------------------+
double CRiskOptimizer::GetCurrentRiskMultiplier()
{
    // Combine all factors to get the final multiplier
    return m_CurrentRiskMultiplier * m_VolatilityBasedMultiplier * m_MarketConditionMultiplier;
}

//+------------------------------------------------------------------+
//| Update Cycle Statistics (Daily, Weekly, Monthly)                 |
//+------------------------------------------------------------------+
void CRiskOptimizer::UpdateCycleStats()
{
    datetime now = TimeCurrent();
    MqlDateTime timeStruct;
    TimeToStruct(now, timeStruct);

    // Daily reset
    if (timeStruct.day != TimeToStruct(m_LastBarTime).day) {
        m_DayStartBalance = m_context.Account.Balance();
        m_CurrentDailyLossPercent = 0.0;
        m_ConsecutiveLosses = 0; // Reset daily consecutive losses
    }

    // Weekly reset
    if (m_LastWeekMonday == 0 || (timeStruct.day_of_week == MONDAY && timeStruct.day != TimeToStruct(m_LastBarTime).day)) {
        m_LastWeekMonday = now;
        m_WeeklyProfit = 0.0; // This needs to be calculated from trade history
    }

    // Monthly reset
    if (timeStruct.mon != m_CurrentMonth) {
        m_CurrentMonth = timeStruct.mon;
        m_MonthlyProfit = 0.0; // This needs to be calculated from trade history
    }
}

//+------------------------------------------------------------------+
//| Update ATR Values                                                |
//+------------------------------------------------------------------+
void CRiskOptimizer::UpdateATR()
{
    m_AverageATR = m_context.Indicators.iATR(m_context.Symbol.Name(), m_context.Timeframe, m_Config.ChandelierLookback, 0);
    if (m_AverageATR <= 0) {
        m_context.Logger.LogWarning("Could not calculate average ATR. Using a default value.");
        m_AverageATR = m_context.Indicators.iATR(m_context.Symbol.Name(), m_context.Timeframe, 14, 1); // Fallback
    }
}

//+------------------------------------------------------------------+
//| Update Market Strategy                                           |
//+------------------------------------------------------------------+
void CRiskOptimizer::UpdateMarketStrategy()
{
    // Simple logic: Use Market Profile to determine trend/range
    if (m_context.MarketProfile != NULL) {
        ENUM_MARKET_CONDITION condition = m_context.MarketProfile.GetMarketCondition();
        switch (condition) {
            case MARKET_CONDITION_TREND_UP:
            case MARKET_CONDITION_TREND_DOWN:
                m_CurrentStrategy = STRATEGY_SWING;
                break;
            case MARKET_CONDITION_RANGING:
                m_CurrentStrategy = STRATEGY_SCALPING;
                break;
            default:
                m_CurrentStrategy = STRATEGY_DEFAULT;
                break;
        }
    } else {
        m_CurrentStrategy = STRATEGY_DEFAULT;
    }
    m_LastStrategyUpdateTime = TimeCurrent();
}
    void UpdateATR();

    // Cập nhật chiến lược thị trường
    void UpdateMarketStrategy();

public:
    // Constructor mới, nhận context và config qua tham chiếu
    CRiskOptimizer(EAContext* context, SRiskOptimizerConfig& config) :
        m_context(context),
        m_Config(config)
    {
        // Khởi tạo các biến trạng thái
        m_AverageATR = 0;
        m_LastATR = 0;
        m_LastVolatilityRatio = 0;
        m_LastCalculationTime = 0;
        m_LastBarTime = 0;
        m_WeeklyProfit = 0;
        m_MonthlyProfit = 0;
        m_ConsecutiveProfitDays = 0;
        m_LastWeekMonday = 0;
        m_CurrentMonth = 0;
        m_IsPaused = false;
        m_PauseUntil = 0;
        m_LastSession = SESSION_UNKNOWN;
        m_LastTradeDay = 0;
        m_DayStartBalance = 0;
        m_CurrentDailyLoss = 0;
        m_LastTrailingStop = 0;
        m_CurrentTrailingPhase = TRAILING_NONE;
        m_CurrentStrategy = STRATEGY_DEFAULT;
        m_LastStrategyUpdateTime = 0;
        m_ConsecutiveLosses = 0;
        m_TotalTradesDay = 0;
        m_IsNewBar = false;
        m_ScalingCount = 0;
        ArrayInitialize(m_SpreadHistory, 0.0);

        // Khởi tạo các biến điều chỉnh risk tự động
        m_BaseRiskPercent = m_Config.RiskPercent;
        m_CurrentRiskMultiplier = 1.0;
        m_LastEquityPeak = AccountInfoDouble(ACCOUNT_EQUITY);
        m_MaxDrawdownPercent = 0.0;
        m_ConsecutiveWins = 0;
        m_ConsecutiveLossesForRisk = 0;
        m_WeeklyProfitPercent = 0.0;
        m_MonthlyProfitPercent = 0.0;
        m_LastRiskAdjustmentTime = 0;
        m_RiskAdjustmentEnabled = m_Config.EnableDrawdownProtection; // Ví dụ: bật nếu có bảo vệ DD
        m_VolatilityBasedMultiplier = 1.0;
        m_MarketConditionMultiplier = 1.0;

        m_context.Logger.LogInfo("RiskOptimizer đã được khởi tạo.");
    }

    // Destructor
    ~CRiskOptimizer() {
        // Không cần làm gì ở đây vì không có quản lý bộ nhớ động
    }

    // --- Giao diện Public --- 

    // Hàm cập nhật mỗi tick
    void OnTick();

    // Hàm cập nhật mỗi thanh nến mới
    void OnNewBar();

    // Tính toán các tham số giao dịch (SL, TP, Lot Size)
    TradeParameters CalculateTradeParameters(const EntryParams& params);

    // Kiểm tra xem có nên tạm dừng giao dịch không
    PauseState CheckAutoPause();

    // Kiểm tra và thực hiện trailing stop
    TrailingAction CheckTrailingStop(const PositionInfo& position);

    // Kiểm tra xem có nên scaling không
    bool ShouldScaleIn(const PositionInfo& position);

    // Thông báo cho RiskOptimizer về một giao dịch đã đóng
    void OnTradeClosed(double profit, int consecutive_losses);

    // Lấy chiến lược thị trường hiện tại
    ENUM_MARKET_STRATEGY GetCurrentMarketStrategy();

    // Lấy thông tin cấu hình
    const SRiskOptimizerConfig& GetConfig() const { return m_Config; }

    // Reset trạng thái (ví dụ: khi thay đổi tài khoản hoặc biểu đồ)
    void Reset();

    
    // Biến cache indicator
    double m_AverageATR;
    double m_LastATR;
    double m_LastVolatilityRatio;
    datetime m_LastCalculationTime;
    datetime m_LastBarTime;
    
    // Biến theo dõi lợi nhuận và chu kỳ
    double m_WeeklyProfit;
    double m_MonthlyProfit;
    int m_ConsecutiveProfitDays;
    datetime m_LastWeekMonday;
    int m_CurrentMonth;
    
    // Trạng thái tạm dừng
    bool m_IsPaused;
    datetime m_PauseUntil;
    ENUM_SESSION m_LastSession;
    
    // Trạng thái giao dịch
    int m_LastTradeDay;
    double m_DayStartBalance;
    double m_CurrentDailyLoss;
    double m_LastTrailingStop;
    ENUM_TRAILING_PHASE m_CurrentTrailingPhase;
    ENUM_MARKET_STRATEGY m_CurrentStrategy;
    datetime m_LastStrategyUpdateTime;
    int m_ConsecutiveLosses;
    int m_TotalTradesDay;
    bool m_IsNewBar;
    int m_ScalingCount;
    
    // Lịch sử spread
    double m_SpreadHistory[20];
    
    // Phương thức private hỗ trợ
    // bool ValidateMomentumAlternative(bool isLong); // Đã loại bỏ, logic sẽ được tích hợp vào các hàm check điều kiện
    // double GetSLMultiplierForCluster(ENUM_CLUSTER_TYPE cluster); // Đã loại bỏ, logic sẽ được tích hợp vào CalculateTradeParameters
    // double GetTPMultiplierForCluster(ENUM_CLUSTER_TYPE cluster); // Đã loại bỏ, logic sẽ được tích hợp vào CalculateTradeParameters
    // double GetTrailingFactorForRegime(ENUM_MARKET_REGIME regime); // Đã loại bỏ, logic sẽ được tích hợp vào CheckTrailingStop
    
    // Phương thức tự động điều chỉnh Risk
    void UpdatePerformanceMetrics(); // Cập nhật các chỉ số hiệu suất
    void AdjustRiskBasedOnPerformance(); // Điều chỉnh risk dựa trên hiệu suất
    void UpdateVolatilityAndMarketCondition(); // Cập nhật các hệ số theo thị trường
    double GetCurrentRiskMultiplier(); // Lấy hệ số risk hiện tại
    double CalculateDrawdownBasedRiskAdjustment(); // Điều chỉnh risk dựa trên drawdown
    double CalculateVolatilityBasedRiskAdjustment(); // Điều chỉnh risk dựa trên volatility
    double CalculateMarketConditionRiskAdjustment(); // Điều chỉnh risk dựa trên market conditions
    void UpdatePerformanceMetrics(); // Cập nhật metrics performance
    bool ShouldReduceRisk(); // Kiểm tra có nên giảm risk không
    bool ShouldIncreaseRisk(); // Kiểm tra có nên tăng risk không
    
public:
//| Constructor - Khởi tạo với thông số mặc định nâng cao            |
//+------------------------------------------------------------------+
CRiskOptimizer() : 
    m_Profile(NULL),
    m_SwingDetector(NULL),
    m_Logger(NULL),
    m_SafeData(NULL),
    m_AssetProfiler(NULL),   // Mới v14.0
    m_NewsFilter(NULL),      // Mới v14.0
    m_Symbol(""),
    m_MainTimeframe(PERIOD_H4),
    m_AverageATR(0.0),
    m_LastATR(0.0),
    m_LastVolatilityRatio(1.0),
    m_LastCalculationTime(0),
    m_LastBarTime(0),
    m_WeeklyProfit(0.0),
    m_MonthlyProfit(0.0),
    m_ConsecutiveProfitDays(0),
    m_LastWeekMonday(0),
    m_CurrentMonth(0),
    m_IsPaused(false),
    m_PauseUntil(0),
    m_LastSession(SESSION_CLOSING),
    m_LastTradeDay(0),
    m_DayStartBalance(0.0),
    m_CurrentDailyLoss(0.0),
    m_LastTrailingStop(0.0),
    m_CurrentTrailingPhase(TRAILING_NONE),
    m_CurrentStrategy(STRATEGY_AGGRESSIVE),
    m_LastStrategyUpdateTime(0),
    m_ConsecutiveLosses(0),
    m_TotalTradesDay(0),
    m_IsNewBar(false),
    m_ScalingCount(0),
    // Khởi tạo automatic risk adjustment variables
    m_BaseRiskPercent(1.0),
    m_CurrentRiskMultiplier(1.0),
    m_LastEquityPeak(0.0),
    m_MaxDrawdownPercent(0.0),
    m_ConsecutiveWins(0),
    m_ConsecutiveLossesForRisk(0),
    m_WeeklyProfitPercent(0.0),
    m_MonthlyProfitPercent(0.0),
    m_LastRiskAdjustmentTime(0),
    m_RiskAdjustmentEnabled(true),
    m_VolatilityBasedMultiplier(1.0),
    m_MarketConditionMultiplier(1.0)
{
    // Khởi tạo config với giá trị mặc định
    m_Config = SRiskOptimizerConfig();
    
    // Khởi tạo mảng lưu trữ spread
    for (int i = 0; i < 10; i++) {
        m_SpreadHistory[i] = 0;
    }
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CRiskOptimizer::~CRiskOptimizer()
{
    // Giải phóng các handles trước khi xóa đối tượng
    ReleaseHandles();
    
    // Giải phóng bộ nhớ SafeDataProvider
    if (m_SafeData != NULL) {
        delete m_SafeData;
        m_SafeData = NULL;
    }
}

//+------------------------------------------------------------------+
//| Initialize - Khởi tạo RiskOptimizer                              |
//+------------------------------------------------------------------+
bool CRiskOptimizer::Initialize(string symbol, ENUM_TIMEFRAMES timeframe, double riskPercent, double atrMultSL, double atrMultTP)
{
    m_Symbol = symbol;
    m_MainTimeframe = timeframe;
    m_Config.RiskPercent = riskPercent;
    m_Config.SL_ATR_Multiplier = atrMultSL;
    m_Config.TP_RR_Ratio = atrMultTP;
    
    // Nếu logger chưa được khởi tạo, tạo logger mới
    if (m_Logger == NULL) {
        m_Logger = new CLogger();
        if (m_Logger == NULL) {
            Print("ERROR: Không thể tạo Logger");
            return false;
        }
        m_Logger.Initialize("RiskOptimizer", false, false);
    }
    
    // Khởi tạo SafeDataProvider
    m_SafeData = new CSafeDataProvider();
    if (m_SafeData == NULL) {
        if (m_Logger != NULL)
            m_Logger.LogError("Không thể khởi tạo SafeDataProvider");
        return false;
    }
    
    // Initialize với các tham số cần thiết
    if (!m_SafeData.Initialize(symbol, timeframe, m_Logger)) {
        if (m_Logger != NULL)
            m_Logger.LogError("Không thể initialize SafeDataProvider");
        return false;
    }
    
    // Khởi tạo các biến trạng thái
    m_IsPaused = false;
    m_PauseUntil = 0;
    m_LastSession = SESSION_CLOSING;
    m_LastTradeDay = 0;
    m_DayStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    m_CurrentDailyLoss = 0.0;
    m_ConsecutiveLosses = 0;
    m_TotalTradesDay = 0;
    m_ScalingCount = 0;
    
    // Cập nhật trạng thái ngày
    UpdateDailyState();
    
    if (m_Logger != NULL) {
        m_Logger-.LogInfo(StringFormat(
            "RiskOptimizer v14.0 khởi tạo: %s, Risk=%.2f%%, SL ATR=%.2f, TP RR=%.2f", 
            m_Symbol, m_Config.RiskPercent, m_Config.SL_ATR_Multiplier, m_Config.TP_RR_Ratio
        ));
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| UpdateDailyState - Cập nhật trạng thái hàng ngày                  |
//+------------------------------------------------------------------+
void CRiskOptimizer::UpdateDailyState()
{
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    
    // Cập nhật giá trị ngày
    int currentDay = dt.day;
    
    // Nếu là ngày mới, reset các biến ngày
    if (currentDay != m_LastTradeDay && m_LastTradeDay > 0) {
        // Lưu số dư đầu ngày
        m_DayStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
        m_CurrentDailyLoss = 0;
        m_TotalTradesDay = 0;
        
        // Reset các biến khác nếu cần
        if (m_Logger != NULL) {
            m_Logger.LogInfo("Ngày mới - Reset trạng thái giao dịch hàng ngày");
        }
    }
    
    // Cập nhật ngày hiện tại
    m_LastTradeDay = currentDay;
}

//+------------------------------------------------------------------+
//| SetSwingPointDetector - Thiết lập Swing Point Detector           |
//+------------------------------------------------------------------+
bool CRiskOptimizer::SetSwingPointDetector(CSwingPointDetector* swingDetector)
{
    if (swingDetector == NULL) {
        if (m_Logger != NULL) m_Logger.LogError("Không thể thiết lập SwingPointDetector (NULL)");
        return false;
    }
    
    m_SwingDetector = swingDetector;
    return true;
}

//+------------------------------------------------------------------+
//| SetAssetProfiler - Thiết lập Asset Profiler (mới v14.0)          |
//+------------------------------------------------------------------+
bool CRiskOptimizer::SetAssetProfiler(CAssetProfiler* assetProfiler)
{
    if (assetProfiler == NULL) {
        if (m_Logger != NULL) m_Logger.LogError("Không thể thiết lập AssetProfiler (NULL)");
        return false;
    }
    
    m_AssetProfiler = assetProfiler;
    
    if (m_Logger != NULL) {
        m_Logger.LogInfo("AssetProfiler được thiết lập thành công");
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| SetNewsFilter - Thiết lập News Filter (mới v14.0)                |
//+------------------------------------------------------------------+
bool CRiskOptimizer::SetNewsFilter(CNewsFilter* newsFilter)
{
    if (newsFilter == NULL) {
        if (m_Logger != NULL) m_Logger.LogError("Không thể thiết lập NewsFilter (NULL)");
        return false;
    }
    
    m_NewsFilter = newsFilter;
    
    if (m_Logger != NULL) {
        m_Logger.LogInfo("NewsFilter được thiết lập thành công");
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| UpdateMarketProfile - Cập nhật liên kết tới Market Profile       |
//+------------------------------------------------------------------+
void CRiskOptimizer::UpdateMarketProfile(CMarketProfile* profile)
{
    m_Profile = profile;
    
    // Kiểm tra bar mới khi cập nhật profile
    static datetime lastBarTime = 0;
    datetime currentBarTime = 0;
    
    if (m_SafeData != NULL) {
        currentBarTime = m_SafeData.GetCurrentBarTime(m_MainTimeframe);
        if (currentBarTime > 0 && currentBarTime != lastBarTime) {
            m_IsNewBar = true;
            lastBarTime = currentBarTime;
        } else {
            m_IsNewBar = false;
        }
    }
    
    // Tính toán tỷ lệ biến động (Volatility Ratio) mới
    if (m_IsNewBar || m_LastVolatilityRatio <= 0) {
        m_LastVolatilityRatio = GetVolatilityAdjustmentFactor();
    }
}

//+------------------------------------------------------------------+
//| GetVolatilityRatio - Tính tỷ lệ biến động hiện tại so với trung bình |
//+------------------------------------------------------------------+
double CRiskOptimizer::GetVolatilityRatio()
{
    // Nếu đã có cache thì trả về
    if (!NeedToUpdateCache() && m_LastVolatilityRatio > 0) {
        return m_LastVolatilityRatio;
    }
    
    // Tính toán mới
    m_LastVolatilityRatio = GetVolatilityAdjustmentFactor();
    return m_LastVolatilityRatio;
}

//+------------------------------------------------------------------+
//| GetVolatilityAdjustmentFactor - Tính hệ số điều chỉnh biến động   |
//+------------------------------------------------------------------+
//| GetVolatilityAdjustmentFactor - Tính hệ số điều chỉnh biến động   |
//+------------------------------------------------------------------+
double CRiskOptimizer::GetVolatilityAdjustmentFactor()
{
    // Hàm này được đơn giản hóa để tránh trùng lắp với phiên bản đầy đủ ở sau
    // Phiên bản đầy đủ đã được định nghĩa ở phần sau của file
    return 1.0; // Giá trị mặc định
}


//+------------------------------------------------------------------+
//| CalculateAverageATR - Tính ATR trung bình trong period ngày      |
//+------------------------------------------------------------------+
double CRiskOptimizer::CalculateAverageATR(int period)
{
    if (period <= 0) return 0;
    
    // Lấy giá trị ATR cho nhiều ngày
    double atrArray[];
    ArrayResize(atrArray, period);
    
    // Handle ATR indicator
    int atrHandle = iATR(m_Symbol, m_MainTimeframe, 14);
    if (atrHandle == INVALID_HANDLE) {
        if (m_Logger != NULL) {
            m_Logger.LogError("Không thể tạo ATR handle trong CalculateAverageATR");
        }
        return 0;
    }
    
    // Sao chép giá trị
    int copied = CopyBuffer(atrHandle, 0, 0, period, atrArray);
    IndicatorRelease(atrHandle);
    
    if (copied != period) {
        if (m_Logger != NULL) {
            m_Logger.LogWarning(StringFormat("Chỉ sao chép được %d/%d giá trị ATR", copied, period));
        }
        if (copied <= 0) return 0;
    }
    
    // Tính trung bình
    double sum = 0;
    for (int i = 0; i < copied; i++) {
        sum += atrArray[i];
    }
    
    return sum / copied;
}

//+------------------------------------------------------------------+
//| SetDrawdownParameters - Thiết lập các tham số điều chỉnh risk DD |
//+------------------------------------------------------------------+
void CRiskOptimizer::SetDrawdownParameters(double threshold, bool enableTapered, double minRiskMultiplier)
{
    m_Config.DrawdownReduceThreshold = threshold;
    m_Config.EnableTaperedRisk = enableTapered;
    m_Config.MinRiskMultiplier = minRiskMultiplier;
    
    if (m_Logger != NULL) {
        m_Logger.LogInfo(StringFormat(
            "Thiết lập DrawdownParameters: Threshold=%.2f%%, Tapered=%s, MinMultiplier=%.2f", 
            m_Config.DrawdownReduceThreshold, m_Config.EnableTaperedRisk ? "true" : "false", m_Config.MinRiskMultiplier
        ));
    }
}

//+------------------------------------------------------------------+
//| SetChandelierExit - Thiết lập thông số Chandelier Exit           |
//+------------------------------------------------------------------+
void CRiskOptimizer::SetChandelierExit(bool useChande, int lookback, double atrMult)
{
    m_Config.UseChandelierExit = useChande;
    m_Config.ChandelierLookback = lookback;
    m_Config.ChandelierATRMultiplier = atrMult;
    
    if (m_Logger != NULL) {
        m_Logger.LogInfo(StringFormat(
            "Thiết lập Chandelier Exit: Enabled=%s, Lookback=%d, AtrMultiplier=%.2f", 
            m_Config.UseChandelierExit ? "true" : "false", m_Config.ChandelierLookback, m_Config.ChandelierATRMultiplier
        ));
    }
}

//+------------------------------------------------------------------+
//| SetDetailedLogging - Thiết lập chi tiết logging                  |
//+------------------------------------------------------------------+
void CRiskOptimizer::SetDetailedLogging(bool enable)
{
    m_Config.EnableDetailedLogs = enable;
    
    if (m_Logger != NULL) m_Logger.LogDebug(StringFormat("RiskOptimizer: Detailed logging %s", enable ? "enabled" : "disabled"));
}

//+------------------------------------------------------------------+
//| SetRiskLimits - Thiết lập giới hạn risk                          |
//+------------------------------------------------------------------+
void CRiskOptimizer::SetRiskLimits(bool useFixedUSD, double maxUSD, double maxPercent)
{
    m_Config.UseFixedMaxRiskUSD = useFixedUSD;
    m_Config.MaxRiskUSD = maxUSD;
    m_Config.MaxRiskPercent = maxPercent;
    
    if (m_Logger != NULL) {
        string limitType = useFixedUSD ? "USD cố định" : "% Balance";
        string limitValue = useFixedUSD ? "$" + DoubleToString(maxUSD, 2) : DoubleToString(maxPercent, 2) + "%";
        
        m_Logger.LogInfo(StringFormat(
            "Thiết lập giới hạn risk: Loại=%s, Giá trị=%s", 
            limitType, limitValue
        ));
    }
}

//+------------------------------------------------------------------+
//| SetScalingParameters - Thiết lập tham số nhồi lệnh (v14.0)       |
//+------------------------------------------------------------------+
void CRiskOptimizer::SetScalingParameters(bool enable, int maxCount, double riskPercent, 
                                        bool requireBE, bool requireTrend, double minRMultiple)
{
    // Thiết lập các tham số scaling
    m_Config.EnableScaling = enable;
    m_Config.MaxScalingCount = maxCount;
    m_Config.ScalingRiskPercent = riskPercent;
    m_Config.RequireBreakEvenForScaling = requireBE;
    m_Config.ScalingRequiresClearTrend = requireTrend;
    m_Config.MinRMultipleForScaling = minRMultiple;
    
    if (m_Logger != NULL) {
        m_Logger.LogInfo(StringFormat(
            "Thiết lập Scaling: Enable=%s, MaxCount=%d, Risk=%.2f%%, RequireBE=%s, RequireTrend=%s, MinRMultiple=%.1f",
            enable ? "true" : "false", maxCount, riskPercent, 
            requireBE ? "true" : "false", requireTrend ? "true" : "false", minRMultiple
        ));
    }
}

//+------------------------------------------------------------------+
//| SetPartialCloseParameters - Thiết lập đóng từng phần (v14.0)     |
//+------------------------------------------------------------------+
void CRiskOptimizer::SetPartialCloseParameters(bool enable, double r1, double r2, 
                                             double percent1, double percent2, bool moveToBE)
{
    // Thiết lập tham số đóng từng phần
    m_Config.PartialClose.UsePartialClose = enable;
    m_Config.PartialClose.FirstRMultiple = r1;
    m_Config.PartialClose.SecondRMultiple = r2;
    m_Config.PartialClose.FirstClosePercent = percent1;
    m_Config.PartialClose.SecondClosePercent = percent2;
    m_Config.PartialClose.MoveToBreakEven = moveToBE;
    
    if (m_Logger != NULL) {
        m_Logger.LogInfo(StringFormat(
            "Thiết lập Partial Close: Enable=%s, R1=%.1f, R2=%.1f, %%1=%.1f, %%2=%.1f, MoveBE=%s",
            enable ? "true" : "false", r1, r2, percent1, percent2, moveToBE ? "true" : "false"
        ));
    }
}

//+------------------------------------------------------------------+
//| SetNewsFilterParameters - Thiết lập lọc tin tức (v14.0)          |
//+------------------------------------------------------------------+
void CRiskOptimizer::SetNewsFilterParameters(bool enable, int highBefore, int highAfter, 
                                           int mediumBefore, int mediumAfter, string dataFile)
{
    // Thiết lập tham số lọc tin tức
    m_Config.NewsFilter.EnableNewsFilter = enable;
    m_Config.NewsFilter.HighImpactMinutesBefore = highBefore;
    m_Config.NewsFilter.HighImpactMinutesAfter = highAfter;
    m_Config.NewsFilter.MediumImpactMinutesBefore = mediumBefore;
    m_Config.NewsFilter.MediumImpactMinutesAfter = mediumAfter;
    m_Config.NewsFilter.NewsDataFile = dataFile;
    
    if (m_Logger != NULL) {
        m_Logger.LogInfo(StringFormat(
            "Thiết lập News Filter: Enable=%s, HighBefore=%d, HighAfter=%d, MediumBefore=%d, MediumAfter=%d, File=%s",
            enable ? "true" : "false", highBefore, highAfter, mediumBefore, mediumAfter, dataFile
        ));
    }
    
    // Áp dụng cấu hình vào NewsFilter object nếu có
    if (m_NewsFilter != NULL && enable) {
        m_NewsFilter.Configure(highBefore, highAfter, mediumBefore, mediumAfter);
    }
}

//+------------------------------------------------------------------+
//| EnablePropFirmMode - Bật/tắt chế độ Prop Firm (v14.0)            |
//+------------------------------------------------------------------+
void CRiskOptimizer::EnablePropFirmMode(bool enable)
{
    m_Config.PropFirmMode = enable;
    
    // Điều chỉnh các tham số khác để phù hợp với Prop Firm mode
    if (enable) {
        // Chế độ Prop Firm: Bảo thủ hơn, bảo vệ vốn là ưu tiên hàng đầu
        m_Config.MaxRiskPercent = MathMin(m_Config.MaxRiskPercent, 1.5);  // Giới hạn tối đa 1.5%
        m_Config.DrawdownReduceThreshold = MathMin(m_Config.DrawdownReduceThreshold, 5.0); // Bắt đầu giảm risk sớm hơn
        m_Config.MaxAllowedDrawdown = MathMin(m_Config.MaxAllowedDrawdown, 8.0); // DD tối đa thấp hơn
        m_Config.AutoPause.DailyLossPercentLimit = MathMin(m_Config.AutoPause.DailyLossPercentLimit, 3.0); // Giới hạn lỗ ngày thấp hơn
        m_Config.ScalingRiskPercent = 0.25; // Giảm risk khi scaling nhiều hơn
        m_Config.EnableWeeklyCycle = true;  // Bật chu kỳ weekly
        m_Config.WeeklyLossReduceFactor = 0.7; // Giảm risk mạnh hơn khi tuần lỗ
    }
    
    if (m_Logger != NULL) {
        if (enable) {
            m_Logger.LogInfo("Đã bật chế độ Prop Firm - Tăng cường bảo vệ vốn");
        } else {
            m_Logger.LogInfo("Đã tắt chế độ Prop Firm");
        }
    }
}

//+------------------------------------------------------------------+
//| Giải phóng các handles tài nguyên                                |
//+------------------------------------------------------------------+
void CRiskOptimizer::ReleaseHandles() {
    // Giải phóng tất cả indicator handles nếu có
    if (m_Logger != NULL) {
        m_Logger.LogDebug("Giải phóng indicator handles trong RiskOptimizer");
    }
}

//+------------------------------------------------------------------+
//| Get valid ATR value with fallback                                |
//+------------------------------------------------------------------+
double CRiskOptimizer::GetValidATR()
{
    // Kiểm tra xem có cần cập nhật cache không
    if (!NeedToUpdateCache() && m_LastATR > 0) {
        return m_LastATR; // Sử dụng cache
    }
    
    // Ưu tiên lấy ATR từ AssetProfiler (nếu có)
    if (m_AssetProfiler != NULL) {
        double assetATR = m_AssetProfiler.GetAssetATR(m_Symbol, m_MainTimeframe);
        if (assetATR > 0) {
            // Cập nhật cache và trả về giá trị
            m_LastATR = assetATR;
            m_LastCalculationTime = TimeCurrent();
            return assetATR;
        }
    }
    
    // Dùng SafeDataProvider để lấy ATR an toàn
    double atr = 0;
    if (m_SafeData != NULL) {
        atr = m_SafeData.GetSafeATR(m_Profile, m_MainTimeframe);
    } else {
        // Fallback nếu SafeDataProvider chưa được khởi tạo
        
        // Kết nối với MarketProfile nếu có
        if (m_Profile != NULL) {
            double currentATR = m_Profile.GetATRH4();
            if (currentATR > 0) {
                atr = currentATR;
            }
        }
        
        // Nếu không có giá trị hợp lệ, thử lấy giá trị từ thời gian hiện tại
        if (atr <= 0) {
            int handle = iATR(m_Symbol, m_MainTimeframe, 14);
            if (handle != INVALID_HANDLE) {
                double buffer[];
                ArraySetAsSeries(buffer, true);
                if (CopyBuffer(handle, 0, 0, 1, buffer) > 0) {
                    atr = buffer[0];
                }
                IndicatorRelease(handle);
            }
            
            if (atr <= 0) {
                // Fallback cuối cùng
                atr = SymbolInfoDouble(m_Symbol, SYMBOL_POINT) * 100;
                if (m_Logger != NULL) m_Logger.LogWarning("Sử dụng giá trị ATR dự phòng");
            }
        }
    }
    
    // Cập nhật giá trị cache
    m_LastATR = atr;
    m_LastCalculationTime = TimeCurrent();
    
    return atr;
}

//+------------------------------------------------------------------+
//| Kiểm tra xem có cần cập nhật cache                               |
//+------------------------------------------------------------------+
bool CRiskOptimizer::NeedToUpdateCache()
{
    datetime currentTime = TimeCurrent();
    
    // Đánh dấu các bar mới - phương pháp hiệu quả nhất
    datetime currentBarTime = 0;
    
    if (m_SafeData != NULL) {
        currentBarTime = m_SafeData.GetCurrentBarTime(m_MainTimeframe);
        
        // Nếu bar mới, luôn cập nhật cache
        if (currentBarTime > 0 && currentBarTime != m_LastBarTime) {
            if (m_Logger != NULL && m_Logger.IsDebugEnabled()) {
                m_Logger.LogDebug("Cập nhật cache do bar mới");
            }
            m_LastBarTime = currentBarTime;
            return true;
        }
    }
    
    // Kiểm tra theo thởi gian cache
    if (m_LastCalculationTime == 0 || 
        (currentTime - m_LastCalculationTime) >= m_Config.CacheTimeSeconds) {
        return true;
    }
    
    // Phát hiện biến động mạnh bất thường (cần cập nhật cache gấp)
    if (DetectSuddenVolatilitySpike()) {
        if (m_Logger != NULL) {
            m_Logger.LogInfo("Cập nhật cache do phát hiện biến động đột biến");
        }
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Phát hiện biến động đột biến để cập nhật cache                   |
//+------------------------------------------------------------------+
bool CRiskOptimizer::DetectSuddenVolatilitySpike()
{
    // Tính tỷ lệ biến động mới 
    double currentATR = 0;
    
    int atrHandle = iATR(m_Symbol, m_MainTimeframe, 14);
    if (atrHandle == INVALID_HANDLE) {
        return false;
    }
    
    double buffer[];
    ArraySetAsSeries(buffer, true);
    
    if (CopyBuffer(atrHandle, 0, 0, 1, buffer) <= 0) {
        IndicatorRelease(atrHandle);
        return false;
    }
    
    currentATR = buffer[0];
    IndicatorRelease(atrHandle);
    
    if (currentATR > 0 && m_LastATR > 0) {
        // Nếu ATR tăng hơn 50% trong thởi gian ngắn - dấu hiệu biến động đột biến
        if (currentATR > m_LastATR * 1.5) {
            return true;
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Get volatility adjustment factor with improved handling          |
//+------------------------------------------------------------------+
// Hàm được đổi tên để tránh xung đột với hàm GetVolatilityAdjustmentFactor đã định nghĩa trước đó
double CRiskOptimizer::GetVolatilityAdjustmentFactorDetailed()
{
    // Kiểm tra cache
    if (!NeedToUpdateCache() && m_LastVolatilityRatio > 0) {
        return m_LastVolatilityRatio;
    }
    
    // Ưu tiên lấy volatility ratio từ AssetProfiler
    if (m_AssetProfiler != NULL) {
        double assetVolatilityRatio = m_AssetProfiler.GetVolatilityRatio(m_Symbol);
        if (assetVolatilityRatio > 0) {
            m_LastVolatilityRatio = assetVolatilityRatio;
            return assetVolatilityRatio;
        }
    }
    
    // Lấy volatility ratio từ SafeDataProvider nếu có
    double volatilityRatio = 1.0;
    if (m_SafeData != NULL) {
        volatilityRatio = m_SafeData.GetSafeVolatilityRatio();
    } else if (m_Profile != NULL) {
        // Thử lấy từ profile
        volatilityRatio = m_Profile.GetVolatilityRatio();
        
        // Nếu không lấy được, tính thủ công
        if (volatilityRatio <= 0 && m_AverageATR > 0) {
            double currentATR = GetValidATR();
            if (currentATR > 0) {
                volatilityRatio = currentATR / m_AverageATR;
            }
        }
    }
    
    // Nếu vẫn không có tỷ lệ biến động hợp lệ, trả về 1.0 (không điều chỉnh)
    if (volatilityRatio <= 0) return 1.0;
    
    // Phát hiện và xử lý biến động bất thường
    if (volatilityRatio > 3.0) {
        if (m_Logger != NULL) {
            m_Logger.LogWarning(StringFormat(
                "Phát hiện biến động bất thường: %.2f lần so với bình thường. Áp dụng giới hạn.",
                volatilityRatio
            ));
        }
        
        // Giới hạn lại tỷ lệ biến động
        volatilityRatio = 3.0;
    }
    
    // Tính hệ số điều chỉnh:
    // - Biến động thấp (< 0.8): tăng nhẹ (lên tới 1.2)
    // - Biến động vừa (0.8-1.2): giữ nguyên
    // - Biến động cao (> 1.2): giảm dần (xuống tới 0.7)
    // - Biến động rất cao (> 2.0): giới hạn ở 0.5
    double adjustmentFactor = 1.0;
    
    if (volatilityRatio < 0.8) {
        // Biến động thấp: tăng SL/TP nhưng không quá 1.2
        adjustmentFactor = 1.0 + (0.8 - volatilityRatio) * 0.5;
        adjustmentFactor = MathMin(adjustmentFactor, 1.2);
    }
    else if (volatilityRatio > 1.2) {
        // Biến động cao: giảm SL/TP
        if (volatilityRatio < 2.0) {
            // Áp dụng công thức bậc hai để giảm dần
            adjustmentFactor = 1.0 - (volatilityRatio - 1.2) * 0.25;
        } else {
            // Biến động rất cao (> 2.0): giảm xuống mức tối thiểu
            adjustmentFactor = 0.5;
        }
    }
    
    return adjustmentFactor;
}

//+------------------------------------------------------------------+
//| Tính toán khối lượng giao dịch dựa trên risk percent và SL points |
//+------------------------------------------------------------------+
double CRiskOptimizer::CalculateLotSizeByRisk(string symbol, double stopLossPoints, double riskPercent) {
    if (stopLossPoints <= 0) {
        if (m_Logger != NULL) {
            m_Logger.LogError(StringFormat(
                "Giá trị stopLossPoints (%.1f) không hợp lệ trong CalculateLotSizeByRisk", 
                stopLossPoints));
        }
        return 0.01; // Giá trị mặc định an toàn
    }
    
    // Lấy số dư tài khoản
    double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    
    if (accountBalance <= 0) {
        if (m_Logger != NULL) m_Logger.LogWarning("Số dư tài khoản không hợp lệ");
        return 0.01;
    }
    
    // Tính số tiền được phép risk (theo % hoặc giá trị tối đa cố định)
    double riskAmount = (accountBalance * riskPercent / 100.0);
    
    // Tính tick value (giá trị của 1 tick)
    double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
    double tickSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
    double pointValue = (tickValue * _Point) / tickSize;
    
    // Tính toán lot size tối ưu
    double lotSize = riskAmount / (stopLossPoints * pointValue);
    
    // Chuẩn hóa lot size theo quy định của sàn
    lotSize = NormalizeLotSize(symbol, lotSize);
    
    return lotSize;
}

//+------------------------------------------------------------------+
//| Chuẩn hóa khối lượng giao dịch theo tiêu chuẩn sàn             |
//+------------------------------------------------------------------+
double CRiskOptimizer::NormalizeLotSize(string symbol, double lotSize) {
    if (lotSize <= 0) return 0.01; // Giá trị mặc định an toàn
    
    // Lấy thông tin về khối lượng tối thiểu, tối đa và bước
    double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
    double stepLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
    
    // Đảm bảo khối lượng nằm trong giới hạn
    lotSize = MathMax(lotSize, minLot);
    lotSize = MathMin(lotSize, maxLot);
    
    // Làm tròn theo bước khối lượng
    if (stepLot > 0) {
        lotSize = MathFloor(lotSize / stepLot) * stepLot;
    }
    
    // Trả về giá trị đã chuẩn hóa
    return MathMax(lotSize, minLot);
}

//+------------------------------------------------------------------+
//| AUTOMATIC RISK ADJUSTMENT IMPLEMENTATIONS                        |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Lấy RiskPercent đã được tối ưu hóa                              |
//+------------------------------------------------------------------+
double CRiskOptimizer::GetOptimizedRiskPercent()
{
    if (!m_RiskAdjustmentEnabled) {
        return m_Config.RiskPercent;
    }
    
    // Cập nhật metrics trước khi tính toán
    UpdatePerformanceMetrics();
    
    // Tính toán adaptive risk percent
    double adaptiveRisk = CalculateAdaptiveRiskPercent();
    
    // Áp dụng các giới hạn an toàn
    double maxRisk = m_Config.MaxRiskPercent > 0 ? m_Config.MaxRiskPercent : m_BaseRiskPercent * 2.0;
    double minRisk = m_BaseRiskPercent * 0.25; // Tối thiểu 25% risk gốc
    
    adaptiveRisk = MathMax(minRisk, MathMin(maxRisk, adaptiveRisk));
    
    if (m_Logger != NULL) {
        m_Logger->LogInfo(StringFormat(
            "RiskOptimizer: Optimized Risk = %.2f%% (Base: %.2f%%, Multiplier: %.2f)",
            adaptiveRisk, m_BaseRiskPercent, m_CurrentRiskMultiplier
        ));
    }
    
    return adaptiveRisk;
}

//+------------------------------------------------------------------+
//| Tính toán RiskPercent thích ứng                                 |
//+------------------------------------------------------------------+
double CRiskOptimizer::CalculateAdaptiveRiskPercent()
{
    // Tính toán các hệ số điều chỉnh
    double performanceMultiplier = CalculatePerformanceBasedRiskAdjustment();
    double drawdownMultiplier = CalculateDrawdownBasedRiskAdjustment();
    double volatilityMultiplier = CalculateVolatilityBasedRiskAdjustment();
    double marketMultiplier = CalculateMarketConditionRiskAdjustment();
    
    // V14.0: Tích hợp Broker Health Factor
    double brokerHealthMultiplier = 1.0;
    if(m_Context != NULL && m_Context->BrokerHealthMonitor != NULL)
      {
       brokerHealthMultiplier = m_Context->BrokerHealthMonitor->GetHealthBasedRiskFactor();
       if(m_Logger != NULL)
         {
          m_Logger->LogDebug("RiskOptimizer: Broker Health Multiplier = " + DoubleToString(brokerHealthMultiplier, 3));
         }
      }
    
    // V14.0: Tích hợp Parameter Stability Factor
    double stabilityMultiplier = 1.0;
    if(m_Context != NULL && !m_Context->IsStrategyUnstable)
      {
       stabilityMultiplier = MathMax(0.5, m_Context->ParameterStabilityIndex); // Tối thiểu 50%
       if(m_Logger != NULL)
         {
          m_Logger->LogDebug("RiskOptimizer: Parameter Stability Multiplier = " + DoubleToString(stabilityMultiplier, 3));
         }
      }
    else if(m_Context != NULL && m_Context->IsStrategyUnstable)
      {
       stabilityMultiplier = 0.3; // Giảm mạnh risk khi không ổn định
       if(m_Logger != NULL)
         {
          m_Logger->LogWarning("RiskOptimizer: Strategy unstable, reducing risk to 30%");
         }
      }
    
    // Kết hợp các hệ số (sử dụng trung bình có trọng số với broker health và stability)
    m_CurrentRiskMultiplier = (performanceMultiplier * 0.25 + 
                              drawdownMultiplier * 0.3 + 
                              volatilityMultiplier * 0.15 + 
                              marketMultiplier * 0.1 +
                              brokerHealthMultiplier * 0.1 +
                              stabilityMultiplier * 0.1);
    
    // Làm mượt thay đổi để tránh biến động quá mạnh
    static double lastMultiplier = 1.0;
    double smoothingFactor = 0.7; // 70% giá trị cũ, 30% giá trị mới
    m_CurrentRiskMultiplier = lastMultiplier * smoothingFactor + m_CurrentRiskMultiplier * (1.0 - smoothingFactor);
    lastMultiplier = m_CurrentRiskMultiplier;
    
    return m_BaseRiskPercent * m_CurrentRiskMultiplier;
}

//+------------------------------------------------------------------+
//| Cập nhật risk dựa trên hiệu suất                                |
//+------------------------------------------------------------------+
void CRiskOptimizer::UpdateRiskBasedOnPerformance()
{
    if (!m_RiskAdjustmentEnabled) return;
    
    // Chỉ cập nhật nếu đã đủ thời gian từ lần điều chỉnh cuối
    datetime currentTime = TimeCurrent();
    if (currentTime - m_LastRiskAdjustmentTime < 3600) return; // Tối thiểu 1 giờ
    
    UpdatePerformanceMetrics();
    
    // Cập nhật RiskPercent trong config
    double newRiskPercent = GetOptimizedRiskPercent();
    if (MathAbs(newRiskPercent - m_Config.RiskPercent) > 0.01) { // Thay đổi > 0.01%
        m_Config.RiskPercent = newRiskPercent;
        m_LastRiskAdjustmentTime = currentTime;
        
        if (m_Logger != NULL) {
            m_Logger->LogInfo(StringFormat(
                "RiskOptimizer: Risk điều chỉnh thành %.2f%% (Multiplier: %.2f)",
                newRiskPercent, m_CurrentRiskMultiplier
            ));
        }
    }
}

//+------------------------------------------------------------------+
//| Kiểm tra có cần điều chỉnh risk không                           |
//+------------------------------------------------------------------+
bool CRiskOptimizer::IsRiskAdjustmentNeeded()
{
    if (!m_RiskAdjustmentEnabled) return false;
    
    // Kiểm tra thời gian từ lần điều chỉnh cuối
    datetime currentTime = TimeCurrent();
    if (currentTime - m_LastRiskAdjustmentTime < 1800) return false; // Tối thiểu 30 phút
    
    // Kiểm tra các điều kiện cần điều chỉnh
    return (ShouldReduceRisk() || ShouldIncreaseRisk());
}

//+------------------------------------------------------------------+
//| Lấy hệ số nhân risk hiện tại                                    |
//+------------------------------------------------------------------+
double CRiskOptimizer::GetCurrentRiskMultiplier()
{
    return m_CurrentRiskMultiplier;
}

//+------------------------------------------------------------------+
//| Reset các điều chỉnh risk về mặc định                           |
//+------------------------------------------------------------------+
void CRiskOptimizer::ResetRiskAdjustments()
{
    m_CurrentRiskMultiplier = 1.0;
    m_LastEquityPeak = AccountInfoDouble(ACCOUNT_EQUITY);
    m_MaxDrawdownPercent = 0.0;
    m_ConsecutiveWins = 0;
    m_ConsecutiveLossesForRisk = 0;
    m_WeeklyProfitPercent = 0.0;
    m_MonthlyProfitPercent = 0.0;
    m_LastRiskAdjustmentTime = 0;
    m_VolatilityBasedMultiplier = 1.0;
    m_MarketConditionMultiplier = 1.0;
    
    if (m_Logger != NULL) {
        m_Logger->LogInfo("RiskOptimizer: Đã reset tất cả điều chỉnh risk về mặc định");
    }
}

//+------------------------------------------------------------------+
//| Tính toán điều chỉnh risk dựa trên hiệu suất                    |
//+------------------------------------------------------------------+
double CRiskOptimizer::CalculatePerformanceBasedRiskAdjustment()
{
    double multiplier = 1.0;
    
    // Điều chỉnh dựa trên consecutive wins/losses
    if (m_ConsecutiveWins >= 3) {
        // Tăng risk khi thắng liên tiếp (nhưng có giới hạn)
        multiplier += MathMin(0.2, m_ConsecutiveWins * 0.05);
    } else if (m_ConsecutiveLossesForRisk >= 2) {
        // Giảm risk khi thua liên tiếp
        multiplier -= MathMin(0.4, m_ConsecutiveLossesForRisk * 0.1);
    }
    
    // Điều chỉnh dựa trên lợi nhuận tuần
    if (m_WeeklyProfitPercent > 5.0) {
        multiplier += 0.1; // Tăng 10% khi lợi nhuận tuần > 5%
    } else if (m_WeeklyProfitPercent < -3.0) {
        multiplier -= 0.15; // Giảm 15% khi lỗ tuần > 3%
    }
    
    // Điều chỉnh dựa trên lợi nhuận tháng
    if (m_MonthlyProfitPercent > 15.0) {
        multiplier += 0.05; // Tăng nhẹ khi lợi nhuận tháng tốt
    } else if (m_MonthlyProfitPercent < -10.0) {
        multiplier -= 0.2; // Giảm mạnh khi lỗ tháng > 10%
    }
    
    return MathMax(0.3, MathMin(1.5, multiplier));
}

//+------------------------------------------------------------------+
//| Tính toán điều chỉnh risk dựa trên drawdown                     |
//+------------------------------------------------------------------+
double CRiskOptimizer::CalculateDrawdownBasedRiskAdjustment()
{
    double multiplier = 1.0;
    
    // Điều chỉnh dựa trên drawdown hiện tại
    if (m_MaxDrawdownPercent > 15.0) {
        multiplier = 0.4; // Giảm mạnh khi drawdown > 15%
    } else if (m_MaxDrawdownPercent > 10.0) {
        multiplier = 0.6; // Giảm vừa khi drawdown > 10%
    } else if (m_MaxDrawdownPercent > 5.0) {
        multiplier = 0.8; // Giảm nhẹ khi drawdown > 5%
    } else if (m_MaxDrawdownPercent < 2.0) {
        multiplier = 1.1; // Tăng nhẹ khi drawdown thấp
    }
    
    return MathMax(0.2, MathMin(1.2, multiplier));
}

//+------------------------------------------------------------------+
//| Tính toán điều chỉnh risk dựa trên volatility                   |
//+------------------------------------------------------------------+
double CRiskOptimizer::CalculateVolatilityBasedRiskAdjustment()
{
    // Sử dụng volatility adjustment factor đã có
    double volatilityFactor = GetVolatilityAdjustmentFactor();
    
    // Chuyển đổi thành multiplier cho risk
    // Volatility cao -> giảm risk, Volatility thấp -> tăng risk
    double multiplier = 1.0;
    
    if (volatilityFactor < 0.8) {
        multiplier = 0.7; // Volatility rất cao -> giảm risk mạnh
    } else if (volatilityFactor < 1.0) {
        multiplier = 0.85; // Volatility cao -> giảm risk vừa
    } else if (volatilityFactor > 1.2) {
        multiplier = 1.1; // Volatility thấp -> tăng risk nhẹ
    }
    
    m_VolatilityBasedMultiplier = multiplier;
    return MathMax(0.5, MathMin(1.2, multiplier));
}

//+------------------------------------------------------------------+
//| Tính toán điều chỉnh risk dựa trên điều kiện thị trường         |
//+------------------------------------------------------------------+
double CRiskOptimizer::CalculateMarketConditionRiskAdjustment()
{
    double multiplier = 1.0;
    
    // Kiểm tra spread
    double currentSpread = SymbolInfoInteger(m_Symbol, SYMBOL_SPREAD) * SymbolInfoDouble(m_Symbol, SYMBOL_POINT);
    double normalSpread = SymbolInfoDouble(m_Symbol, SYMBOL_POINT) * 10; // Giả định spread bình thường
    
    if (currentSpread > normalSpread * 2.0) {
        multiplier -= 0.2; // Giảm risk khi spread cao
    }
    
    // Kiểm tra thời gian giao dịch (giảm risk ngoài giờ chính)
    datetime currentTime = TimeCurrent();
    MqlDateTime timeStruct;
    TimeToStruct(currentTime, timeStruct);
    
    // Giảm risk ngoài giờ giao dịch chính (22:00 - 06:00 GMT)
    if (timeStruct.hour >= 22 || timeStruct.hour <= 6) {
        multiplier -= 0.1;
    }
    
    m_MarketConditionMultiplier = multiplier;
    return MathMax(0.6, MathMin(1.1, multiplier));
}

//+------------------------------------------------------------------+
//| Cập nhật các metrics hiệu suất                                  |
//+------------------------------------------------------------------+
void CRiskOptimizer::UpdatePerformanceMetrics()
{
    // Cập nhật equity peak và drawdown
    double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    if (currentEquity > m_LastEquityPeak) {
        m_LastEquityPeak = currentEquity;
        m_MaxDrawdownPercent = 0.0; // Reset drawdown khi đạt đỉnh mới
    } else {
        // Tính drawdown hiện tại
        double currentDrawdown = (m_LastEquityPeak - currentEquity) / m_LastEquityPeak * 100.0;
        if (currentDrawdown > m_MaxDrawdownPercent) {
            m_MaxDrawdownPercent = currentDrawdown;
        }
    }
    
    // Cập nhật lợi nhuận tuần/tháng (cần implement logic tính toán chi tiết)
    // Đây là placeholder - cần tích hợp với hệ thống tracking lợi nhuận
    
    // Lưu base risk percent nếu chưa có
    if (m_BaseRiskPercent <= 0) {
        m_BaseRiskPercent = m_Config.RiskPercent;
    }
}

//+------------------------------------------------------------------+
//| Kiểm tra có nên giảm risk không                                 |
//+------------------------------------------------------------------+
bool CRiskOptimizer::ShouldReduceRisk()
{
    // Giảm risk khi:
    // 1. Drawdown cao
    if (m_MaxDrawdownPercent > 8.0) return true;
    
    // 2. Thua liên tiếp nhiều
    if (m_ConsecutiveLossesForRisk >= 3) return true;
    
    // 3. Lỗ tuần/tháng cao
    if (m_WeeklyProfitPercent < -5.0 || m_MonthlyProfitPercent < -12.0) return true;
    
    // 4. Volatility quá cao
    if (m_VolatilityBasedMultiplier < 0.8) return true;
    
    return false;
}

//+------------------------------------------------------------------+
//| Kiểm tra có nên tăng risk không                                 |
//+------------------------------------------------------------------+
bool CRiskOptimizer::ShouldIncreaseRisk()
{
    // Tăng risk khi:
    // 1. Hiệu suất tốt và drawdown thấp
    if (m_MaxDrawdownPercent < 3.0 && m_ConsecutiveWins >= 3) return true;
    
    // 2. Lợi nhuận ổn định
    if (m_WeeklyProfitPercent > 3.0 && m_MonthlyProfitPercent > 8.0) return true;
    
    // 3. Volatility thấp và điều kiện thị trường tốt
    if (m_VolatilityBasedMultiplier > 1.05 && m_MarketConditionMultiplier > 0.95) return true;
    
    return false;
}

}; // đóng class CRiskOptimizer

// Đóng namespace ApexPullback
} // end namespace ApexPullback

#endif // RISKOPTIMIZER_MQH_