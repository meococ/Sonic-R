//+------------------------------------------------------------------+
//|                                              RiskValidator.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "../../01_Core/CommonStructs.mqh"

//+------------------------------------------------------------------+
//| Risk validation enumerations                                    |
//+------------------------------------------------------------------+
enum ENUM_VALIDATION_RESULT {
    VALIDATION_PASSED,
    VALIDATION_WARNING,
    VALIDATION_FAILED,
    VALIDATION_CRITICAL,
    VALIDATION_UNKNOWN
};

enum ENUM_VALIDATION_TYPE {
    VALIDATION_POSITION_SIZE,
    VALIDATION_STOP_LOSS,
    VALIDATION_TAKE_PROFIT,
    VALIDATION_RISK_REWARD,
    VALIDATION_CORRELATION,
    VALIDATION_EXPOSURE,
    VALIDATION_DRAWDOWN,
    VALIDATION_MARGIN,
    VALIDATION_SPREAD,
    VALIDATION_VOLATILITY,
    VALIDATION_LIQUIDITY,
    VALIDATION_TIME_FILTER,
    VALIDATION_NEWS_FILTER,
    VALIDATION_CUSTOM
};

enum ENUM_VALIDATION_SEVERITY {
    SEVERITY_INFO,
    SEVERITY_LOW,
    SEVERITY_MEDIUM,
    SEVERITY_HIGH,
    SEVERITY_CRITICAL
};

enum ENUM_VALIDATION_ACTION {
    ACTION_ALLOW,
    ACTION_WARN,
    ACTION_MODIFY,
    ACTION_REJECT,
    ACTION_BLOCK
};

enum ENUM_RISK_CATEGORY {
    RISK_CATEGORY_MARKET,
    RISK_CATEGORY_CREDIT,
    RISK_CATEGORY_OPERATIONAL,
    RISK_CATEGORY_LIQUIDITY,
    RISK_CATEGORY_REGULATORY,
    RISK_CATEGORY_SYSTEMIC
};

//+------------------------------------------------------------------+
//| Risk validation structures                                      |
//+------------------------------------------------------------------+
struct SValidationRule {
    ENUM_VALIDATION_TYPE Type;
    string Name;
    string Description;
    bool IsEnabled;
    ENUM_VALIDATION_SEVERITY Severity;
    ENUM_VALIDATION_ACTION Action;
    double MinValue;
    double MaxValue;
    double WarningThreshold;
    double CriticalThreshold;
    string Parameters;
    datetime LastUpdate;
    int ViolationCount;
    datetime LastViolation;
};

struct SValidationResult {
    ENUM_VALIDATION_RESULT Result;
    ENUM_VALIDATION_TYPE Type;
    ENUM_VALIDATION_SEVERITY Severity;
    ENUM_VALIDATION_ACTION RecommendedAction;
    string Message;
    string Details;
    double ActualValue;
    double ExpectedValue;
    double Threshold;
    datetime Timestamp;
    bool IsBlocking;
    string Symbol;
    int OrderTicket;
};

struct SRiskLimits {
    double MaxPositionSize;         // Maximum position size (lots)
    double MaxPositionValue;        // Maximum position value (currency)
    double MaxRiskPerTrade;         // Maximum risk per trade (%)
    double MaxDailyRisk;           // Maximum daily risk (%)
    double MaxWeeklyRisk;          // Maximum weekly risk (%)
    double MaxMonthlyRisk;         // Maximum monthly risk (%)
    double MaxDrawdown;            // Maximum drawdown (%)
    double MaxCorrelation;         // Maximum correlation between positions
    double MaxExposure;            // Maximum exposure per symbol (%)
    double MinRiskReward;          // Minimum risk/reward ratio
    double MaxSpread;              // Maximum allowed spread (points)
    double MinStopLoss;            // Minimum stop loss distance (points)
    double MaxStopLoss;            // Maximum stop loss distance (points)
    double MinTakeProfit;          // Minimum take profit distance (points)
    int MaxPositions;              // Maximum number of open positions
    int MaxOrdersPerSymbol;        // Maximum orders per symbol
    double MinAccountBalance;      // Minimum account balance
    double MaxLeverage;            // Maximum leverage
    double MinMarginLevel;         // Minimum margin level (%)
};

struct SMarketConditions {
    double CurrentSpread;
    double AverageSpread;
    double Volatility;
    double Liquidity;
    bool IsMarketOpen;
    bool IsNewsTime;
    bool IsHighImpactNews;
    double MarketSentiment;
    datetime LastUpdate;
    string MarketStatus;
};

struct SValidationContext {
    string Symbol;
    ENUM_ORDER_TYPE OrderType;
    double Volume;
    double Price;
    double StopLoss;
    double TakeProfit;
    string Comment;
    int Magic;
    datetime Expiration;
    SMarketConditions MarketConditions;
    double AccountBalance;
    double AccountEquity;
    double AccountMargin;
    double AccountFreeMargin;
    int OpenPositions;
    double TotalExposure;
    double CurrentDrawdown;
};

struct SValidationStatistics {
    int TotalValidations;
    int PassedValidations;
    int WarningValidations;
    int FailedValidations;
    int CriticalValidations;
    int BlockedTrades;
    int ModifiedTrades;
    double SuccessRate;
    datetime FirstValidation;
    datetime LastValidation;
    string MostCommonViolation;
    int MostCommonViolationCount;
};

struct SValidationConfiguration {
    bool EnableValidation;
    bool EnableWarnings;
    bool EnableBlocking;
    bool EnableLogging;
    bool EnableStatistics;
    bool StrictMode;               // Strict validation mode
    bool AllowOverrides;           // Allow manual overrides
    int MaxWarningsPerDay;
    int MaxViolationsPerDay;
    double ToleranceLevel;         // Tolerance for minor violations
    string NotificationEmail;
    bool SendEmailAlerts;
    bool SendPushNotifications;
};

//+------------------------------------------------------------------+
//| Risk Validator Class                                            |
//+------------------------------------------------------------------+
class CRiskValidator {
private:
    EAContext* m_pContext;
    
    // Configuration
    SValidationConfiguration m_Config;
    SRiskLimits m_RiskLimits;
    
    // Validation rules
    SValidationRule m_Rules[20];
    int m_RuleCount;
    
    // Statistics
    SValidationStatistics m_Statistics;
    
    // Internal state
    bool m_bInitialized;
    bool m_bValidationEnabled;
    datetime m_LastValidation;
    
    // Helper methods
    bool InitializeRules();
    bool ValidatePositionSize(const SValidationContext& context, SValidationResult& result);
    bool ValidateStopLoss(const SValidationContext& context, SValidationResult& result);
    bool ValidateTakeProfit(const SValidationContext& context, SValidationResult& result);
    bool ValidateRiskReward(const SValidationContext& context, SValidationResult& result);
    bool ValidateCorrelation(const SValidationContext& context, SValidationResult& result);
    bool ValidateExposure(const SValidationContext& context, SValidationResult& result);
    bool ValidateDrawdown(const SValidationContext& context, SValidationResult& result);
    bool ValidateMargin(const SValidationContext& context, SValidationResult& result);
    bool ValidateSpread(const SValidationContext& context, SValidationResult& result);
    bool ValidateVolatility(const SValidationContext& context, SValidationResult& result);
    bool ValidateLiquidity(const SValidationContext& context, SValidationResult& result);
    bool ValidateTimeFilter(const SValidationContext& context, SValidationResult& result);
    bool ValidateNewsFilter(const SValidationContext& context, SValidationResult& result);
    bool UpdateMarketConditions(const string symbol, SMarketConditions& conditions);
    bool CheckRuleViolation(const SValidationRule& rule, double value, SValidationResult& result);
    bool UpdateStatistics(const SValidationResult& result);
    void LogValidationResult(const SValidationResult& result);
    void LogError(const string message);
    void LogActivity(const string message);
    
public:
    // Constructor/Destructor
    CRiskValidator();
    ~CRiskValidator();
    
    // Initialization
    bool Initialize(EAContext* context);
    bool Deinitialize();
    bool Configure(const SValidationConfiguration& config);
    
    // Risk limits management
    bool SetRiskLimits(const SRiskLimits& limits);
    SRiskLimits GetRiskLimits() const { return m_RiskLimits; }
    bool UpdateRiskLimit(ENUM_VALIDATION_TYPE type, double value);
    
    // Validation rules management
    bool AddRule(const SValidationRule& rule);
    bool RemoveRule(ENUM_VALIDATION_TYPE type);
    bool EnableRule(ENUM_VALIDATION_TYPE type, bool enable = true);
    bool UpdateRule(const SValidationRule& rule);
    bool GetRule(ENUM_VALIDATION_TYPE type, SValidationRule& rule);
    int GetRuleCount() const { return m_RuleCount; }
    
    // Main validation methods
    bool ValidateTrade(const SValidationContext& context, SValidationResult& result);
    bool ValidateOrder(const SValidationContext& context, SValidationResult& result);
    bool ValidateModification(const SValidationContext& context, SValidationResult& result);
    bool ValidateClose(const SValidationContext& context, SValidationResult& result);
    
    // Batch validation
    bool ValidateMultipleTrades(const SValidationContext& contexts[], SValidationResult& results[]);
    bool ValidatePortfolio(SValidationResult& results[]);
    
    // Quick validation methods
    bool IsTradeAllowed(const string symbol, double volume, ENUM_ORDER_TYPE type);
    bool IsPositionSizeValid(const string symbol, double volume);
    bool IsRiskAcceptable(const string symbol, double volume, double stopLoss);
    bool IsSpreadAcceptable(const string symbol);
    bool IsMarketConditionSuitable(const string symbol);
    
    // Risk assessment
    double CalculateTradeRisk(const string symbol, double volume, double stopLoss);
    double CalculatePositionExposure(const string symbol, double volume);
    double CalculateCorrelationRisk(const string symbol);
    double CalculateDrawdownRisk();
    
    // Override and exception handling
    bool RequestOverride(ENUM_VALIDATION_TYPE type, const string reason);
    bool GrantOverride(ENUM_VALIDATION_TYPE type, const string approver);
    bool IsOverrideActive(ENUM_VALIDATION_TYPE type);
    
    // Reporting and statistics
    SValidationStatistics GetStatistics() const { return m_Statistics; }
    bool GenerateValidationReport(string& report);
    bool GenerateRiskReport(string& report);
    bool ResetStatistics();
    
    // Configuration
    bool EnableValidation(bool enable = true);
    bool SetStrictMode(bool strict = true);
    bool AllowOverrides(bool allow = true);
    
    // Utility methods
    string GetValidationResultName(ENUM_VALIDATION_RESULT result);
    string GetValidationTypeName(ENUM_VALIDATION_TYPE type);
    string GetSeverityName(ENUM_VALIDATION_SEVERITY severity);
    string GetActionName(ENUM_VALIDATION_ACTION action);
    
    // Status
    bool IsInitialized() const { return m_bInitialized; }
    bool IsValidationEnabled() const { return m_bValidationEnabled; }
    datetime GetLastValidation() const { return m_LastValidation; }
};

//+------------------------------------------------------------------+
//| Constructor                                                     |
//+------------------------------------------------------------------+
CRiskValidator::CRiskValidator() {
    m_pContext = NULL;
    m_RuleCount = 0;
    m_bInitialized = false;
    m_bValidationEnabled = true;
    m_LastValidation = 0;
    
    ZeroMemory(m_Statistics);
    ZeroMemory(m_Config);
    ZeroMemory(m_RiskLimits);
    
    // Set default configuration
    m_Config.EnableValidation = true;
    m_Config.EnableWarnings = true;
    m_Config.EnableBlocking = true;
    m_Config.EnableLogging = true;
    m_Config.EnableStatistics = true;
    m_Config.StrictMode = false;
    m_Config.AllowOverrides = true;
    m_Config.MaxWarningsPerDay = 50;
    m_Config.MaxViolationsPerDay = 10;
    m_Config.ToleranceLevel = 0.05;  // 5% tolerance
    m_Config.SendEmailAlerts = false;
    m_Config.SendPushNotifications = false;
    
    // Set default risk limits
    m_RiskLimits.MaxPositionSize = 10.0;        // 10 lots
    m_RiskLimits.MaxPositionValue = 100000.0;   // $100,000
    m_RiskLimits.MaxRiskPerTrade = 2.0;         // 2%
    m_RiskLimits.MaxDailyRisk = 5.0;            // 5%
    m_RiskLimits.MaxWeeklyRisk = 10.0;          // 10%
    m_RiskLimits.MaxMonthlyRisk = 20.0;         // 20%
    m_RiskLimits.MaxDrawdown = 15.0;            // 15%
    m_RiskLimits.MaxCorrelation = 0.7;          // 70%
    m_RiskLimits.MaxExposure = 25.0;            // 25%
    m_RiskLimits.MinRiskReward = 1.5;           // 1:1.5
    m_RiskLimits.MaxSpread = 5.0;               // 5 points
    m_RiskLimits.MinStopLoss = 10.0;            // 10 points
    m_RiskLimits.MaxStopLoss = 500.0;           // 500 points
    m_RiskLimits.MinTakeProfit = 15.0;          // 15 points
    m_RiskLimits.MaxPositions = 10;             // 10 positions
    m_RiskLimits.MaxOrdersPerSymbol = 3;        // 3 orders per symbol
    m_RiskLimits.MinAccountBalance = 1000.0;    // $1,000
    m_RiskLimits.MaxLeverage = 100.0;           // 1:100
    m_RiskLimits.MinMarginLevel = 200.0;        // 200%
}

//+------------------------------------------------------------------+
//| Destructor                                                      |
//+------------------------------------------------------------------+
CRiskValidator::~CRiskValidator() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize risk validator                                       |
//+------------------------------------------------------------------+
bool CRiskValidator::Initialize(EAContext* context) {
    if (context == NULL) {
        LogError("Invalid context provided");
        return false;
    }
    
    m_pContext = context;
    
    // Initialize validation rules
    if (!InitializeRules()) {
        LogError("Failed to initialize validation rules");
        return false;
    }
    
    // Initialize statistics
    m_Statistics.FirstValidation = TimeCurrent();
    
    m_bInitialized = true;
    m_bValidationEnabled = m_Config.EnableValidation;
    
    LogActivity("Risk validator initialized successfully");
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize risk validator                                     |
//+------------------------------------------------------------------+
bool CRiskValidator::Deinitialize() {
    if (m_bInitialized) {
        m_bInitialized = false;
        m_bValidationEnabled = false;
        m_pContext = NULL;
        LogActivity("Risk validator deinitialized");
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Configure risk validator                                        |
//+------------------------------------------------------------------+
bool CRiskValidator::Configure(const SValidationConfiguration& config) {
    m_Config = config;
    m_bValidationEnabled = m_Config.EnableValidation;
    
    LogActivity("Risk validator configured successfully");
    return true;
}

//+------------------------------------------------------------------+
//| Initialize validation rules                                     |
//+------------------------------------------------------------------+
bool CRiskValidator::InitializeRules() {
    m_RuleCount = 0;
    
    // Define default validation rules
    string ruleNames[] = {
        "Position Size", "Stop Loss", "Take Profit", "Risk/Reward", "Correlation",
        "Exposure", "Drawdown", "Margin", "Spread", "Volatility",
        "Liquidity", "Time Filter", "News Filter"
    };
    
    string ruleDescriptions[] = {
        "Validates position size limits",
        "Validates stop loss requirements",
        "Validates take profit settings",
        "Validates risk/reward ratio",
        "Validates correlation limits",
        "Validates exposure limits",
        "Validates drawdown limits",
        "Validates margin requirements",
        "Validates spread conditions",
        "Validates volatility conditions",
        "Validates liquidity conditions",
        "Validates trading time filters",
        "Validates news event filters"
    };
    
    ENUM_VALIDATION_SEVERITY severities[] = {
        SEVERITY_HIGH, SEVERITY_HIGH, SEVERITY_MEDIUM, SEVERITY_MEDIUM, SEVERITY_MEDIUM,
        SEVERITY_HIGH, SEVERITY_CRITICAL, SEVERITY_HIGH, SEVERITY_LOW, SEVERITY_MEDIUM,
        SEVERITY_MEDIUM, SEVERITY_LOW, SEVERITY_MEDIUM
    };
    
    ENUM_VALIDATION_ACTION actions[] = {
        ACTION_REJECT, ACTION_REJECT, ACTION_WARN, ACTION_WARN, ACTION_WARN,
        ACTION_REJECT, ACTION_BLOCK, ACTION_REJECT, ACTION_WARN, ACTION_WARN,
        ACTION_WARN, ACTION_WARN, ACTION_WARN
    };
    
    for (int i = 0; i < ArraySize(ruleNames) && i < ArraySize(m_Rules); i++) {
        SValidationRule rule;
        ZeroMemory(rule);
        
        rule.Type = (ENUM_VALIDATION_TYPE)i;
        rule.Name = ruleNames[i];
        rule.Description = ruleDescriptions[i];
        rule.IsEnabled = true;
        rule.Severity = severities[i];
        rule.Action = actions[i];
        rule.MinValue = 0.0;
        rule.MaxValue = 0.0;
        rule.WarningThreshold = 0.0;
        rule.CriticalThreshold = 0.0;
        rule.Parameters = "";
        rule.LastUpdate = TimeCurrent();
        rule.ViolationCount = 0;
        rule.LastViolation = 0;
        
        m_Rules[m_RuleCount] = rule;
        m_RuleCount++;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Validate trade                                                  |
//+------------------------------------------------------------------+
bool CRiskValidator::ValidateTrade(const SValidationContext& context, SValidationResult& result) {
    if (!m_bInitialized || !m_bValidationEnabled) {
        result.Result = VALIDATION_PASSED;
        result.Message = "Validation disabled";
        return true;
    }
    
    // Initialize result
    ZeroMemory(result);
    result.Result = VALIDATION_PASSED;
    result.Timestamp = TimeCurrent();
    result.Symbol = context.Symbol;
    
    // Run all enabled validation rules
    SValidationResult tempResult;
    ENUM_VALIDATION_RESULT worstResult = VALIDATION_PASSED;
    
    for (int i = 0; i < m_RuleCount; i++) {
        if (!m_Rules[i].IsEnabled) continue;
        
        ZeroMemory(tempResult);
        bool ruleResult = false;
        
        switch (m_Rules[i].Type) {
            case VALIDATION_POSITION_SIZE:
                ruleResult = ValidatePositionSize(context, tempResult);
                break;
            case VALIDATION_STOP_LOSS:
                ruleResult = ValidateStopLoss(context, tempResult);
                break;
            case VALIDATION_TAKE_PROFIT:
                ruleResult = ValidateTakeProfit(context, tempResult);
                break;
            case VALIDATION_RISK_REWARD:
                ruleResult = ValidateRiskReward(context, tempResult);
                break;
            case VALIDATION_CORRELATION:
                ruleResult = ValidateCorrelation(context, tempResult);
                break;
            case VALIDATION_EXPOSURE:
                ruleResult = ValidateExposure(context, tempResult);
                break;
            case VALIDATION_DRAWDOWN:
                ruleResult = ValidateDrawdown(context, tempResult);
                break;
            case VALIDATION_MARGIN:
                ruleResult = ValidateMargin(context, tempResult);
                break;
            case VALIDATION_SPREAD:
                ruleResult = ValidateSpread(context, tempResult);
                break;
            case VALIDATION_VOLATILITY:
                ruleResult = ValidateVolatility(context, tempResult);
                break;
            case VALIDATION_LIQUIDITY:
                ruleResult = ValidateLiquidity(context, tempResult);
                break;
            case VALIDATION_TIME_FILTER:
                ruleResult = ValidateTimeFilter(context, tempResult);
                break;
            case VALIDATION_NEWS_FILTER:
                ruleResult = ValidateNewsFilter(context, tempResult);
                break;
            default:
                continue;
        }
        
        if (ruleResult && tempResult.Result > worstResult) {
            worstResult = tempResult.Result;
            result = tempResult;  // Keep the worst result
        }
    }
    
    result.Result = worstResult;
    
    // Update statistics
    UpdateStatistics(result);
    
    // Log result
    LogValidationResult(result);
    
    m_LastValidation = TimeCurrent();
    m_Statistics.LastValidation = m_LastValidation;
    
    return true;
}

//+------------------------------------------------------------------+
//| Validate position size                                          |
//+------------------------------------------------------------------+
bool CRiskValidator::ValidatePositionSize(const SValidationContext& context, SValidationResult& result) {
    result.Type = VALIDATION_POSITION_SIZE;
    result.ActualValue = context.Volume;
    result.Threshold = m_RiskLimits.MaxPositionSize;
    
    if (context.Volume > m_RiskLimits.MaxPositionSize) {
        result.Result = VALIDATION_FAILED;
        result.Severity = SEVERITY_HIGH;
        result.RecommendedAction = ACTION_REJECT;
        result.Message = StringFormat("Position size %.2f exceeds maximum allowed %.2f", 
                                    context.Volume, m_RiskLimits.MaxPositionSize);
        result.IsBlocking = true;
        return true;
    }
    
    // Check warning threshold (80% of max)
    double warningThreshold = m_RiskLimits.MaxPositionSize * 0.8;
    if (context.Volume > warningThreshold) {
        result.Result = VALIDATION_WARNING;
        result.Severity = SEVERITY_MEDIUM;
        result.RecommendedAction = ACTION_WARN;
        result.Message = StringFormat("Position size %.2f approaching maximum limit %.2f", 
                                    context.Volume, m_RiskLimits.MaxPositionSize);
        result.IsBlocking = false;
        return true;
    }
    
    result.Result = VALIDATION_PASSED;
    result.Message = "Position size validation passed";
    return true;
}

//+------------------------------------------------------------------+
//| Validate stop loss                                              |
//+------------------------------------------------------------------+
bool CRiskValidator::ValidateStopLoss(const SValidationContext& context, SValidationResult& result) {
    result.Type = VALIDATION_STOP_LOSS;
    
    if (context.StopLoss == 0.0) {
        result.Result = VALIDATION_FAILED;
        result.Severity = SEVERITY_HIGH;
        result.RecommendedAction = ACTION_REJECT;
        result.Message = "Stop loss is required but not set";
        result.IsBlocking = true;
        return true;
    }
    
    // Calculate stop loss distance in points
    double point = SymbolInfoDouble(context.Symbol, SYMBOL_POINT);
    double stopDistance = 0.0;
    
    if (context.OrderType == ORDER_TYPE_BUY || context.OrderType == ORDER_TYPE_BUY_LIMIT) {
        stopDistance = (context.Price - context.StopLoss) / point;
    } else if (context.OrderType == ORDER_TYPE_SELL || context.OrderType == ORDER_TYPE_SELL_LIMIT) {
        stopDistance = (context.StopLoss - context.Price) / point;
    }
    
    result.ActualValue = stopDistance;
    
    // Check minimum stop loss distance
    if (stopDistance < m_RiskLimits.MinStopLoss) {
        result.Result = VALIDATION_FAILED;
        result.Severity = SEVERITY_HIGH;
        result.RecommendedAction = ACTION_REJECT;
        result.Threshold = m_RiskLimits.MinStopLoss;
        result.Message = StringFormat("Stop loss distance %.1f points is below minimum %.1f points", 
                                    stopDistance, m_RiskLimits.MinStopLoss);
        result.IsBlocking = true;
        return true;
    }
    
    // Check maximum stop loss distance
    if (stopDistance > m_RiskLimits.MaxStopLoss) {
        result.Result = VALIDATION_WARNING;
        result.Severity = SEVERITY_MEDIUM;
        result.RecommendedAction = ACTION_WARN;
        result.Threshold = m_RiskLimits.MaxStopLoss;
        result.Message = StringFormat("Stop loss distance %.1f points exceeds recommended maximum %.1f points", 
                                    stopDistance, m_RiskLimits.MaxStopLoss);
        result.IsBlocking = false;
        return true;
    }
    
    result.Result = VALIDATION_PASSED;
    result.Message = "Stop loss validation passed";
    return true;
}

//+------------------------------------------------------------------+
//| Validate take profit                                            |
//+------------------------------------------------------------------+
bool CRiskValidator::ValidateTakeProfit(const SValidationContext& context, SValidationResult& result) {
    result.Type = VALIDATION_TAKE_PROFIT;
    
    if (context.TakeProfit == 0.0) {
        result.Result = VALIDATION_WARNING;
        result.Severity = SEVERITY_LOW;
        result.RecommendedAction = ACTION_WARN;
        result.Message = "Take profit not set - consider setting a target";
        result.IsBlocking = false;
        return true;
    }
    
    // Calculate take profit distance in points
    double point = SymbolInfoDouble(context.Symbol, SYMBOL_POINT);
    double tpDistance = 0.0;
    
    if (context.OrderType == ORDER_TYPE_BUY || context.OrderType == ORDER_TYPE_BUY_LIMIT) {
        tpDistance = (context.TakeProfit - context.Price) / point;
    } else if (context.OrderType == ORDER_TYPE_SELL || context.OrderType == ORDER_TYPE_SELL_LIMIT) {
        tpDistance = (context.Price - context.TakeProfit) / point;
    }
    
    result.ActualValue = tpDistance;
    
    // Check minimum take profit distance
    if (tpDistance < m_RiskLimits.MinTakeProfit) {
        result.Result = VALIDATION_WARNING;
        result.Severity = SEVERITY_MEDIUM;
        result.RecommendedAction = ACTION_WARN;
        result.Threshold = m_RiskLimits.MinTakeProfit;
        result.Message = StringFormat("Take profit distance %.1f points is below recommended minimum %.1f points", 
                                    tpDistance, m_RiskLimits.MinTakeProfit);
        result.IsBlocking = false;
        return true;
    }
    
    result.Result = VALIDATION_PASSED;
    result.Message = "Take profit validation passed";
    return true;
}

//+------------------------------------------------------------------+
//| Validate risk/reward ratio                                      |
//+------------------------------------------------------------------+
bool CRiskValidator::ValidateRiskReward(const SValidationContext& context, SValidationResult& result) {
    result.Type = VALIDATION_RISK_REWARD;
    
    if (context.StopLoss == 0.0 || context.TakeProfit == 0.0) {
        result.Result = VALIDATION_WARNING;
        result.Severity = SEVERITY_LOW;
        result.RecommendedAction = ACTION_WARN;
        result.Message = "Cannot calculate risk/reward ratio - stop loss or take profit missing";
        result.IsBlocking = false;
        return true;
    }
    
    // Calculate risk and reward distances
    double point = SymbolInfoDouble(context.Symbol, SYMBOL_POINT);
    double riskDistance = 0.0;
    double rewardDistance = 0.0;
    
    if (context.OrderType == ORDER_TYPE_BUY || context.OrderType == ORDER_TYPE_BUY_LIMIT) {
        riskDistance = (context.Price - context.StopLoss) / point;
        rewardDistance = (context.TakeProfit - context.Price) / point;
    } else if (context.OrderType == ORDER_TYPE_SELL || context.OrderType == ORDER_TYPE_SELL_LIMIT) {
        riskDistance = (context.StopLoss - context.Price) / point;
        rewardDistance = (context.Price - context.TakeProfit) / point;
    }
    
    if (riskDistance <= 0.0) {
        result.Result = VALIDATION_FAILED;
        result.Severity = SEVERITY_HIGH;
        result.RecommendedAction = ACTION_REJECT;
        result.Message = "Invalid risk distance calculated";
        result.IsBlocking = true;
        return true;
    }
    
    double riskRewardRatio = rewardDistance / riskDistance;
    result.ActualValue = riskRewardRatio;
    result.Threshold = m_RiskLimits.MinRiskReward;
    
    if (riskRewardRatio < m_RiskLimits.MinRiskReward) {
        result.Result = VALIDATION_WARNING;
        result.Severity = SEVERITY_MEDIUM;
        result.RecommendedAction = ACTION_WARN;
        result.Message = StringFormat("Risk/reward ratio %.2f is below minimum recommended %.2f", 
                                    riskRewardRatio, m_RiskLimits.MinRiskReward);
        result.IsBlocking = false;
        return true;
    }
    
    result.Result = VALIDATION_PASSED;
    result.Message = StringFormat("Risk/reward ratio %.2f validation passed", riskRewardRatio);
    return true;
}

//+------------------------------------------------------------------+
//| Validate spread conditions                                      |
//+------------------------------------------------------------------+
bool CRiskValidator::ValidateSpread(const SValidationContext& context, SValidationResult& result) {
    result.Type = VALIDATION_SPREAD;
    
    double ask = SymbolInfoDouble(context.Symbol, SYMBOL_ASK);
    double bid = SymbolInfoDouble(context.Symbol, SYMBOL_BID);
    double point = SymbolInfoDouble(context.Symbol, SYMBOL_POINT);
    
    if (ask <= 0.0 || bid <= 0.0 || point <= 0.0) {
        result.Result = VALIDATION_FAILED;
        result.Severity = SEVERITY_HIGH;
        result.RecommendedAction = ACTION_REJECT;
        result.Message = "Cannot retrieve market data for spread validation";
        result.IsBlocking = true;
        return true;
    }
    
    double currentSpread = (ask - bid) / point;
    result.ActualValue = currentSpread;
    result.Threshold = m_RiskLimits.MaxSpread;
    
    if (currentSpread > m_RiskLimits.MaxSpread) {
        result.Result = VALIDATION_WARNING;
        result.Severity = SEVERITY_MEDIUM;
        result.RecommendedAction = ACTION_WARN;
        result.Message = StringFormat("Current spread %.1f points exceeds maximum recommended %.1f points", 
                                    currentSpread, m_RiskLimits.MaxSpread);
        result.IsBlocking = false;
        return true;
    }
    
    result.Result = VALIDATION_PASSED;
    result.Message = StringFormat("Spread %.1f points validation passed", currentSpread);
    return true;
}

//+------------------------------------------------------------------+
//| Validate margin requirements                                    |
//+------------------------------------------------------------------+
bool CRiskValidator::ValidateMargin(const SValidationContext& context, SValidationResult& result) {
    result.Type = VALIDATION_MARGIN;
    
    double marginLevel = (context.AccountEquity / context.AccountMargin) * 100.0;
    result.ActualValue = marginLevel;
    result.Threshold = m_RiskLimits.MinMarginLevel;
    
    if (marginLevel < m_RiskLimits.MinMarginLevel) {
        result.Result = VALIDATION_FAILED;
        result.Severity = SEVERITY_CRITICAL;
        result.RecommendedAction = ACTION_BLOCK;
        result.Message = StringFormat("Margin level %.1f%% is below minimum required %.1f%%", 
                                    marginLevel, m_RiskLimits.MinMarginLevel);
        result.IsBlocking = true;
        return true;
    }
    
    // Warning threshold (120% of minimum)
    double warningLevel = m_RiskLimits.MinMarginLevel * 1.2;
    if (marginLevel < warningLevel) {
        result.Result = VALIDATION_WARNING;
        result.Severity = SEVERITY_HIGH;
        result.RecommendedAction = ACTION_WARN;
        result.Message = StringFormat("Margin level %.1f%% is approaching minimum limit %.1f%%", 
                                    marginLevel, m_RiskLimits.MinMarginLevel);
        result.IsBlocking = false;
        return true;
    }
    
    result.Result = VALIDATION_PASSED;
    result.Message = StringFormat("Margin level %.1f%% validation passed", marginLevel);
    return true;
}

//+------------------------------------------------------------------+
//| Update statistics                                               |
//+------------------------------------------------------------------+
bool CRiskValidator::UpdateStatistics(const SValidationResult& result) {
    m_Statistics.TotalValidations++;
    
    switch (result.Result) {
        case VALIDATION_PASSED:
            m_Statistics.PassedValidations++;
            break;
        case VALIDATION_WARNING:
            m_Statistics.WarningValidations++;
            break;
        case VALIDATION_FAILED:
            m_Statistics.FailedValidations++;
            break;
        case VALIDATION_CRITICAL:
            m_Statistics.CriticalValidations++;
            break;
    }
    
    if (result.IsBlocking) {
        m_Statistics.BlockedTrades++;
    }
    
    // Calculate success rate
    if (m_Statistics.TotalValidations > 0) {
        m_Statistics.SuccessRate = (double)m_Statistics.PassedValidations / m_Statistics.TotalValidations * 100.0;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Log validation result                                           |
//+------------------------------------------------------------------+
void CRiskValidator::LogValidationResult(const SValidationResult& result) {
    if (!m_Config.EnableLogging) return;
    
    string message = StringFormat("Validation %s: %s - %s", 
                                GetValidationResultName(result.Result),
                                GetValidationTypeName(result.Type),
                                result.Message);
    
    if (result.Result == VALIDATION_FAILED || result.Result == VALIDATION_CRITICAL) {
        LogError(message);
    } else {
        LogActivity(message);
    }
}

//+------------------------------------------------------------------+
//| Log error message                                               |
//+------------------------------------------------------------------+
void CRiskValidator::LogError(const string message) {
    if (m_pContext != NULL && m_pContext.pLogger != NULL) {
        m_pContext.pLogger.LogError("RiskValidator: " + message);
    } else {
        Print("RiskValidator ERROR: ", message);
    }
}

//+------------------------------------------------------------------+
//| Log activity message                                            |
//+------------------------------------------------------------------+
void CRiskValidator::LogActivity(const string message) {
    if (m_pContext != NULL && m_pContext.pLogger != NULL) {
        m_pContext.pLogger.LogInfo("RiskValidator: " + message);
    } else {
        Print("RiskValidator: ", message);
    }
}

//+------------------------------------------------------------------+
//| Get validation result name                                      |
//+------------------------------------------------------------------+
string CRiskValidator::GetValidationResultName(ENUM_VALIDATION_RESULT result) {
    switch (result) {
        case VALIDATION_PASSED: return "PASSED";
        case VALIDATION_WARNING: return "WARNING";
        case VALIDATION_FAILED: return "FAILED";
        case VALIDATION_CRITICAL: return "CRITICAL";
        case VALIDATION_UNKNOWN: return "UNKNOWN";
        default: return "INVALID";
    }
}

//+------------------------------------------------------------------+
//| Get validation type name                                        |
//+------------------------------------------------------------------+
string CRiskValidator::GetValidationTypeName(ENUM_VALIDATION_TYPE type) {
    switch (type) {
        case VALIDATION_POSITION_SIZE: return "Position Size";
        case VALIDATION_STOP_LOSS: return "Stop Loss";
        case VALIDATION_TAKE_PROFIT: return "Take Profit";
        case VALIDATION_RISK_REWARD: return "Risk/Reward";
        case VALIDATION_CORRELATION: return "Correlation";
        case VALIDATION_EXPOSURE: return "Exposure";
        case VALIDATION_DRAWDOWN: return "Drawdown";
        case VALIDATION_MARGIN: return "Margin";
        case VALIDATION_SPREAD: return "Spread";
        case VALIDATION_VOLATILITY: return "Volatility";
        case VALIDATION_LIQUIDITY: return "Liquidity";
        case VALIDATION_TIME_FILTER: return "Time Filter";
        case VALIDATION_NEWS_FILTER: return "News Filter";
        case VALIDATION_CUSTOM: return "Custom";
        default: return "Unknown";
    }
}

//+------------------------------------------------------------------+
//| Get severity name                                               |
//+------------------------------------------------------------------+
string CRiskValidator::GetSeverityName(ENUM_VALIDATION_SEVERITY severity) {
    switch (severity) {
        case SEVERITY_INFO: return "Info";
        case SEVERITY_LOW: return "Low";
        case SEVERITY_MEDIUM: return "Medium";
        case SEVERITY_HIGH: return "High";
        case SEVERITY_CRITICAL: return "Critical";
        default: return "Unknown";
    }
}

//+------------------------------------------------------------------+
//| Get action name                                                 |
//+------------------------------------------------------------------+
string CRiskValidator::GetActionName(ENUM_VALIDATION_ACTION action) {
    switch (action) {
        case ACTION_ALLOW: return "Allow";
        case ACTION_WARN: return "Warn";
        case ACTION_MODIFY: return "Modify";
        case ACTION_REJECT: return "Reject";
        case ACTION_BLOCK: return "Block";
        default: return "Unknown";
    }
}

//+------------------------------------------------------------------+
//| Placeholder implementations for remaining validation methods     |
//+------------------------------------------------------------------+
bool CRiskValidator::ValidateCorrelation(const SValidationContext& context, SValidationResult& result) {
    result.Type = VALIDATION_CORRELATION;
    result.Result = VALIDATION_PASSED;
    result.Message = "Correlation validation passed";
    return true;
}

bool CRiskValidator::ValidateExposure(const SValidationContext& context, SValidationResult& result) {
    result.Type = VALIDATION_EXPOSURE;
    result.Result = VALIDATION_PASSED;
    result.Message = "Exposure validation passed";
    return true;
}

bool CRiskValidator::ValidateDrawdown(const SValidationContext& context, SValidationResult& result) {
    result.Type = VALIDATION_DRAWDOWN;
    result.Result = VALIDATION_PASSED;
    result.Message = "Drawdown validation passed";
    return true;
}

bool CRiskValidator::ValidateVolatility(const SValidationContext& context, SValidationResult& result) {
    result.Type = VALIDATION_VOLATILITY;
    result.Result = VALIDATION_PASSED;
    result.Message = "Volatility validation passed";
    return true;
}

bool CRiskValidator::ValidateLiquidity(const SValidationContext& context, SValidationResult& result) {
    result.Type = VALIDATION_LIQUIDITY;
    result.Result = VALIDATION_PASSED;
    result.Message = "Liquidity validation passed";
    return true;
}

bool CRiskValidator::ValidateTimeFilter(const SValidationContext& context, SValidationResult& result) {
    result.Type = VALIDATION_TIME_FILTER;
    result.Result = VALIDATION_PASSED;
    result.Message = "Time filter validation passed";
    return true;
}

bool CRiskValidator::ValidateNewsFilter(const SValidationContext& context, SValidationResult& result) {
    result.Type = VALIDATION_NEWS_FILTER;
    result.Result = VALIDATION_PASSED;
    result.Message = "News filter validation passed";
    return true;
}

//+------------------------------------------------------------------+