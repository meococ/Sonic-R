//+------------------------------------------------------------------+
//|                                                  IRiskEngine.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#ifndef IRISKENGINE_MQH_
#define IRISKENGINE_MQH_

#include "../../00_Core/CommonStructs.mqh"

namespace ApexPullback::v5 {

//+------------------------------------------------------------------+
//| Risk Engine Interface                                            |
//+------------------------------------------------------------------+
interface IRiskEngine
{
    // Core Risk Management
    bool Initialize(EAContext* context);
    void Deinitialize();
    
    // Position Sizing
    double CalculatePositionSize(double stopLossPips, string &details);
    double CalculateOptimalSize(double stopLossPips, double confidenceLevel);
    double CalculateConstrainedSize(double stopLossPips);
    
    // Risk Validation
    bool CanOpenNewPosition();
    bool ValidateRiskLimits(double positionSize, double stopLoss);
    bool CheckPortfolioLimits();
    bool CheckVaRLimits();
    
    // Risk Metrics
    SRiskMetrics GetRiskMetrics();
    SPortfolioRisk GetPortfolioRisk();
    double GetCurrentDrawdown();
    double GetDailyVaR95();
    double GetRemainingRiskBudget();
    
    // Risk Adjustment
    double GetDynamicRiskFactor();
    double GetMarketRegimeRiskFactor();
    double GetSessionRiskFactor();
    double GetNewsRiskFactor();
    double GetVolatilityRiskFactor();
    
    // Advanced Analytics
    double CalculateRiskOfRuin(double initialCapital, double maxDrawdown);
    double CalculateMaxDrawdownProbability();
    double CalculateKellyPercentage();
    double CalculateSharpeRatio();
    double CalculateSortinoRatio();
    
    // Stress Testing
    void RunStressTest();
    void RunMonteCarloSimulation(int iterations);
    void PerformScenarioAnalysis();
    
    // Emergency Controls
    void TriggerEmergencyStop(string reason);
    void CheckEmergencyConditions();
    bool IsEmergencyCondition();
    
    // Event Handling
    void OnDealExecuted(long dealTicket);
    void OnPositionOpened(ulong positionTicket);
    void OnPositionClosed(ulong positionTicket);
    void Update();
};

//+------------------------------------------------------------------+
//| Risk Event Interface                                             |
//+------------------------------------------------------------------+
interface IRiskEventHandler
{
    void OnRiskLimitExceeded(ENUM_RISK_LIMIT_TYPE limitType, double currentValue, double limitValue);
    void OnDrawdownAlert(double currentDrawdown, double maxDrawdown);
    void OnConsecutiveLossAlert(int consecutiveLosses, int maxAllowed);
    void OnVaRExceeded(double currentVaR, double limitVaR);
    void OnEmergencyStop(string reason);
    void OnRiskMetricsUpdated(const SRiskMetrics &metrics);
};

//+------------------------------------------------------------------+
//| Risk Limit Types                                                |
//+------------------------------------------------------------------+
enum ENUM_RISK_LIMIT_TYPE
{
    RISK_LIMIT_DAILY_LOSS,
    RISK_LIMIT_MAX_DRAWDOWN,
    RISK_LIMIT_CONSECUTIVE_LOSSES,
    RISK_LIMIT_DAILY_TRADES,
    RISK_LIMIT_VAR_95,
    RISK_LIMIT_PORTFOLIO_EXPOSURE,
    RISK_LIMIT_SINGLE_ASSET_EXPOSURE,
    RISK_LIMIT_CORRELATION_RISK,
    RISK_LIMIT_LEVERAGE_RATIO,
    RISK_LIMIT_MARGIN_UTILIZATION
};

//+------------------------------------------------------------------+
//| Risk Configuration Interface                                     |
//+------------------------------------------------------------------+
interface IRiskConfiguration
{
    // Basic Risk Settings
    void SetRiskPercent(double riskPercent);
    void SetMaxDailyLoss(double maxDailyLossPercent);
    void SetMaxDrawdown(double maxDrawdownPercent);
    void SetMaxConsecutiveLosses(int maxLosses);
    void SetMaxDailyTrades(int maxTrades);
    
    // Advanced Risk Settings
    void SetVaRSettings(bool enabled, int lookback, double confidence);
    void SetStressTestSettings(bool enabled, double scenarios[]);
    void SetPortfolioLimits(double maxExposure, double maxSingleAsset);
    void SetDynamicRiskSettings(bool enabled, double volThreshold, double ddThreshold);
    
    // Risk Adjustment Settings
    void SetMarketRegimeFactors(double trending, double ranging, double volatile);
    void SetSessionFactors(double asian, double london, double newyork);
    void SetNewsRiskFactors(double high, double medium, double low);
    
    // Emergency Settings
    void SetEmergencyThresholds(double extremeDD, double rapidLoss, int extremeLosses);
    void SetCircuitBreakerSettings(bool enabled, int pauseMinutes);
    
    // Getters
    SAdvancedRiskConfig GetRiskConfig();
    void LoadRiskConfig(const SAdvancedRiskConfig &config);
    void SaveRiskConfig();
    void ResetToDefaults();
};

//+------------------------------------------------------------------+
//| Risk Analytics Interface                                         |
//+------------------------------------------------------------------+
interface IRiskAnalytics
{
    // Performance Metrics
    double CalculateSharpeRatio(const double &returns[], int count);
    double CalculateSortinoRatio(const double &returns[], int count);
    double CalculateCalmarRatio(const double &returns[], int count);
    double CalculateUlcerIndex(const double &returns[], int count);
    double CalculateMaxDrawdown(const double &equity[], int count);
    
    // VaR Calculations
    double CalculateVaR(const double &returns[], int count, double confidence);
    double CalculateExpectedShortfall(const double &returns[], int count, double confidence);
    double CalculateConditionalVaR(const double &returns[], int count, double confidence);
    
    // Risk-Adjusted Returns
    double CalculateRiskAdjustedReturn(const double &returns[], int count);
    double CalculateAnnualizedReturn(const double &returns[], int count);
    double CalculateAnnualizedVolatility(const double &returns[], int count);
    double CalculateInformationRatio(const double &returns[], const double &benchmark[], int count);
    
    // Portfolio Metrics
    double CalculatePortfolioBeta(const double &returns[], const double &market[], int count);
    double CalculatePortfolioAlpha(const double &returns[], const double &market[], int count);
    double CalculateTrackingError(const double &returns[], const double &benchmark[], int count);
    double CalculateCorrelation(const double &series1[], const double &series2[], int count);
    
    // Risk Decomposition
    double CalculateSystematicRisk(const double &returns[], const double &market[], int count);
    double CalculateIdiosyncraticRisk(const double &returns[], const double &market[], int count);
    double CalculateDownsideDeviation(const double &returns[], int count, double threshold);
    
    // Advanced Metrics
    double CalculateOmegaRatio(const double &returns[], int count, double threshold);
    double CalculateKappaRatio(const double &returns[], int count, int order);
    double CalculatePainIndex(const double &equity[], int count);
    double CalculateUlcerPerformanceIndex(const double &equity[], int count);
};

//+------------------------------------------------------------------+
//| Risk Monitoring Interface                                        |
//+------------------------------------------------------------------+
interface IRiskMonitor
{
    // Real-time Monitoring
    void StartMonitoring();
    void StopMonitoring();
    bool IsMonitoring();
    
    // Alert Management
    void SetAlertThresholds(const SRiskAlertThresholds &thresholds);
    void EnableAlert(ENUM_RISK_ALERT_TYPE alertType, bool enabled);
    void CheckAlerts();
    void SendAlert(ENUM_RISK_ALERT_TYPE alertType, string message);
    
    // Risk Dashboard
    void UpdateRiskDashboard();
    string GenerateRiskReport();
    void ExportRiskData(string filename);
    
    // Historical Analysis
    void AnalyzeHistoricalRisk(datetime fromDate, datetime toDate);
    void GenerateRiskStatistics();
    void CompareRiskPeriods(datetime period1Start, datetime period1End, 
                          datetime period2Start, datetime period2End);
};

//+------------------------------------------------------------------+
//| Risk Alert Types                                                |
//+------------------------------------------------------------------+
enum ENUM_RISK_ALERT_TYPE
{
    ALERT_DRAWDOWN_WARNING,
    ALERT_DRAWDOWN_CRITICAL,
    ALERT_DAILY_LOSS_WARNING,
    ALERT_DAILY_LOSS_CRITICAL,
    ALERT_CONSECUTIVE_LOSSES,
    ALERT_VAR_EXCEEDED,
    ALERT_PORTFOLIO_LIMIT,
    ALERT_CORRELATION_HIGH,
    ALERT_VOLATILITY_SPIKE,
    ALERT_NEWS_RISK,
    ALERT_MARGIN_CALL_RISK,
    ALERT_EMERGENCY_STOP
};

//+------------------------------------------------------------------+
//| Risk Alert Thresholds Structure                                 |
//+------------------------------------------------------------------+
struct SRiskAlertThresholds
{
    double DrawdownWarning;      // % of max drawdown for warning
    double DrawdownCritical;     // % of max drawdown for critical alert
    double DailyLossWarning;     // % of daily loss for warning
    double DailyLossCritical;    // % of daily loss for critical alert
    int    ConsecutiveLossLimit; // Number of consecutive losses
    double VaRWarningLevel;      // VaR threshold for warning
    double CorrelationLimit;     // Maximum correlation threshold
    double VolatilityMultiple;   // Volatility spike multiple
    int    NewsRiskMinutes;      // Minutes before news to alert
    double MarginUtilization;    // Margin utilization warning level
    
    SRiskAlertThresholds() {
        DrawdownWarning = 0.75;      // 75% of max drawdown
        DrawdownCritical = 0.9;      // 90% of max drawdown
        DailyLossWarning = 0.75;     // 75% of daily loss limit
        DailyLossCritical = 0.9;     // 90% of daily loss limit
        ConsecutiveLossLimit = 5;    // 5 consecutive losses
        VaRWarningLevel = 0.04;      // 4% VaR warning
        CorrelationLimit = 0.8;      // 80% correlation limit
        VolatilityMultiple = 2.0;    // 2x normal volatility
        NewsRiskMinutes = 30;        // 30 minutes before news
        MarginUtilization = 0.8;     // 80% margin utilization
    }
};

} // namespace ApexPullback::v5

#endif // IRISKENGINE_MQH_ 