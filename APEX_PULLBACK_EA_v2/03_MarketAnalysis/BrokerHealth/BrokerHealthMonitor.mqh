//+------------------------------------------------------------------+
//|                                           BrokerHealthMonitor.mqh |
//|                     APEX PULLBACK EA v5 FINAL - Broker Health   |
//|      Description: Enhanced broker health monitoring from v14    |
//+------------------------------------------------------------------+

#ifndef BROKER_HEALTH_MONITOR_V5_FINAL_MQH
#define BROKER_HEALTH_MONITOR_V5_FINAL_MQH

#include "..\\..\\00_Core\\Common\\CommonStructs.mqh"
#include "..\\..\\00_Core\\Common\\Enums.mqh"

namespace ApexPullback {

//+------------------------------------------------------------------+
//| Broker Health Metrics Structure                                 |
//+------------------------------------------------------------------+
struct BrokerHealthMetrics {
    double HealthScore;         // Overall health score (0-100)
    ENUM_BROKER_HEALTH HealthStatus;
    double HealthTrend;         // Trend indicator
    
    // Component Scores
    double SlippageScore;       // Slippage performance score
    double LatencyScore;        // Execution speed score
    double RequoteScore;        // Requote frequency score
    double SuccessRateScore;    // Order success rate score
    
    void Reset() {
        HealthScore = 100.0;
        HealthStatus = HEALTH_EXCELLENT;
        HealthTrend = 0.0;
        SlippageScore = 100.0;
        LatencyScore = 100.0;
        RequoteScore = 100.0;
        SuccessRateScore = 100.0;
    }
};

//+------------------------------------------------------------------+
//| Broker Health Thresholds Structure                              |
//+------------------------------------------------------------------+
struct BrokerHealthThresholds {
    double ExcellentThreshold;
    double GoodThreshold;
    double WarningThreshold;
    double CriticalThreshold;
    double SlippageWarningPips;
    double LatencyWarningMs;
    double DeterioratingTrend;
    
    void SetDefaults() {
        ExcellentThreshold = 90.0;
        GoodThreshold = 75.0;
        WarningThreshold = 60.0;
        CriticalThreshold = 40.0;
        SlippageWarningPips = 1.0;
        LatencyWarningMs = 500.0;
        DeterioratingTrend = -5.0;
    }
};

//+------------------------------------------------------------------+
//| Enhanced CBrokerHealthMonitor Class                             |
//+------------------------------------------------------------------+
class CBrokerHealthMonitor {
private:
    EAContext* m_pContext;
    
    // Current Metrics
    BrokerHealthMetrics m_currentMetrics;
    BrokerHealthMetrics m_previousMetrics;
    BrokerHealthThresholds m_thresholds;
    
    // Historical Data
    double m_healthHistory[];
    double m_slippageHistory[];
    double m_latencyHistory[];
    int m_historySize;
    int m_maxHistorySize;
    
    // Alert Management
    datetime m_lastAlertTime;
    ENUM_BROKER_HEALTH m_lastAlertLevel;
    int m_alertCooldownMinutes;
    
    // Tracking Variables
    int m_totalExecutions;
    int m_successfulExecutions;
    double m_totalSlippage;
    double m_totalLatency;
    
public:
    CBrokerHealthMonitor();
    ~CBrokerHealthMonitor();
    
    // Initialization
    bool Initialize(EAContext* context);
    void Deinitialize();
    
    // Configuration
    void SetThresholds(const BrokerHealthThresholds& thresholds);
    void UpdateConfiguration();
    
    // Core Monitoring
    void UpdateMetrics();
    void AnalyzeBrokerHealth();
    void UpdateWithNewDataPoint(double slippagePips, double executionTimeMs);
    void OnTradeTransaction(const MqlTradeTransaction& trans, const MqlTradeRequest& request, const MqlTradeResult& result);
    
    // Getters
    BrokerHealthMetrics GetCurrentMetrics() const { return m_currentMetrics; }
    double GetHealthScore() const { return m_currentMetrics.HealthScore; }
    ENUM_BROKER_HEALTH GetHealthStatus() const { return m_currentMetrics.HealthStatus; }
    
    // Risk Management Integration
    double GetRiskAdjustmentFactor();
    bool ShouldReduceRisk();
    bool ShouldTriggerCircuitBreaker();
    
    // Reporting
    void GenerateHealthReport(string& report);
    string GenerateDetailedReport();
    
    // Utility
    void Reset();
    void RunDiagnostics();
    
private:
    // Internal Calculations
    double CalculateSlippageScore();
    double CalculateLatencyScore();
    double CalculateRequoteScore();
    double CalculateSuccessRateScore();
    double CalculateOverallHealthScore();
    
    // Trend Analysis
    void UpdateHealthHistory(double healthScore);
    void UpdateTrendAnalysis();
    
    // Alert System
    void CheckAndTriggerAlerts();
    bool IsAlertCooldownActive();
    void SendAlert(const string& message);
    
    // Utility Methods
    ENUM_BROKER_HEALTH DetermineHealthStatus(double healthScore);
    string GetHealthStatusString(ENUM_BROKER_HEALTH status);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CBrokerHealthMonitor::CBrokerHealthMonitor() :
    m_pContext(NULL),
    m_historySize(0),
    m_maxHistorySize(100),
    m_lastAlertTime(0),
    m_lastAlertLevel(HEALTH_EXCELLENT),
    m_alertCooldownMinutes(15),
    m_totalExecutions(0),
    m_successfulExecutions(0),
    m_totalSlippage(0.0),
    m_totalLatency(0.0)
{
    m_currentMetrics.Reset();
    m_previousMetrics.Reset();
    m_thresholds.SetDefaults();
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CBrokerHealthMonitor::Initialize(EAContext* context) {
    if(!context || !context->pLogger) return false;
    
    m_pContext = context;
    
    if(!m_pContext->InputParams.EnableBrokerHealthMonitoring) {
        m_pContext->pLogger->LogInfo("BrokerHealthMonitor is disabled by settings", __FUNCTION__);
        return true;
    }
    
    // Initialize history arrays
    ArrayResize(m_healthHistory, m_maxHistorySize);
    ArrayResize(m_slippageHistory, m_maxHistorySize);
    ArrayResize(m_latencyHistory, m_maxHistorySize);
    
    ArrayInitialize(m_healthHistory, 100.0);
    ArrayInitialize(m_slippageHistory, 0.0);
    ArrayInitialize(m_latencyHistory, 0.0);
    
    m_historySize = 0;
    
    m_pContext->pLogger->LogInfo("BrokerHealthMonitor initialized successfully", __FUNCTION__);
    return true;
}

//+------------------------------------------------------------------+
//| Update Metrics                                                   |
//+------------------------------------------------------------------+
void CBrokerHealthMonitor::UpdateMetrics() {
    if(!m_pContext || !m_pContext->InputParams.EnableBrokerHealthMonitoring) return;
    
    // Store previous metrics
    m_previousMetrics = m_currentMetrics;
    
    // Calculate component scores
    m_currentMetrics.SlippageScore = CalculateSlippageScore();
    m_currentMetrics.LatencyScore = CalculateLatencyScore();
    m_currentMetrics.RequoteScore = CalculateRequoteScore();
    m_currentMetrics.SuccessRateScore = CalculateSuccessRateScore();
    
    // Calculate overall health
    m_currentMetrics.HealthScore = CalculateOverallHealthScore();
    m_currentMetrics.HealthStatus = DetermineHealthStatus(m_currentMetrics.HealthScore);
    
    // Update trend analysis
    UpdateHealthHistory(m_currentMetrics.HealthScore);
    UpdateTrendAnalysis();
    
    // Check for alerts
    CheckAndTriggerAlerts();
    
    if(m_pContext->pLogger && m_pContext->InputParams.EnableMethodLogging) {
        m_pContext->pLogger->LogDebug(StringFormat("Health updated: Score=%.2f, Status=%s", 
                                     m_currentMetrics.HealthScore, 
                                     GetHealthStatusString(m_currentMetrics.HealthStatus)), __FUNCTION__);
    }
}

//+------------------------------------------------------------------+
//| Get Risk Adjustment Factor                                       |
//+------------------------------------------------------------------+
double CBrokerHealthMonitor::GetRiskAdjustmentFactor() {
    switch(m_currentMetrics.HealthStatus) {
        case HEALTH_EXCELLENT: return 1.0;
        case HEALTH_GOOD:      return 0.9;
        case HEALTH_WARNING:   return 0.7;
        case HEALTH_CRITICAL:  return 0.5;
        default:               return 1.0;
    }
}

//+------------------------------------------------------------------+
//| Generate Health Report                                           |
//+------------------------------------------------------------------+
void CBrokerHealthMonitor::GenerateHealthReport(string& report) {
    report = "=== BROKER HEALTH REPORT ===\n";
    report += StringFormat("Overall Score: %.2f (%s)\n", 
                          m_currentMetrics.HealthScore, 
                          GetHealthStatusString(m_currentMetrics.HealthStatus));
    report += StringFormat("Health Trend: %.3f\n", m_currentMetrics.HealthTrend);
    report += StringFormat("Slippage Score: %.2f\n", m_currentMetrics.SlippageScore);
    report += StringFormat("Latency Score: %.2f\n", m_currentMetrics.LatencyScore);
    report += StringFormat("Success Rate: %.2f\n", m_currentMetrics.SuccessRateScore);
    report += "============================";
}

} // namespace ApexPullback

#endif // BROKER_HEALTH_MONITOR_V5_FINAL_MQH