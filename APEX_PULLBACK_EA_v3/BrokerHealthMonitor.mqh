#ifndef BROKERHEALTHMONITOR_MQH_
#define BROKERHEALTHMONITOR_MQH_

#include "CommonStructs.mqh"

namespace ApexPullback {

//+------------------------------------------------------------------+
//| Broker Health Monitor Class                                      |
//+------------------------------------------------------------------+
class CBrokerHealthMonitor {
private:
    EAContext* m_context;
    
    BrokerHealthMetrics m_CurrentMetrics;
    BrokerHealthMetrics m_PreviousMetrics;
    
    // Historical data for trend analysis
    double m_HealthHistory[];
    double m_SlippageHistory[];
    double m_LatencyHistory[];
    int m_HistorySize;
    int m_MaxHistorySize;
    
    // Alert management
    datetime m_LastAlertTime;
    ENUM_HEALTH_STATUS m_LastAlertLevel;
    int m_AlertCooldownMinutes;
    
public:
    CBrokerHealthMonitor();
    ~CBrokerHealthMonitor();
    
    bool Initialize(EAContext* context);
    void SetThresholds(const BrokerHealthThresholds& thresholds);
    
    // Core monitoring functions
    void UpdateMetrics();
    void AnalyzeBrokerHealth();
    void UpdateWithNewDataPoint(double slippagePips, double executionTimeMs);
    
    // Getters
    BrokerHealthMetrics GetCurrentMetrics() const { return m_CurrentMetrics; }
    double GetHealthScore() const { return m_CurrentMetrics.HealthScore; }
    ENUM_HEALTH_STATUS GetHealthStatus() const { return m_CurrentMetrics.HealthStatus; }
    
    // Risk management integration
    double GetRiskAdjustmentFactor();
    double GetHealthBasedRiskFactor();
    bool ShouldReduceRisk();
    bool ShouldIncreaseSpread();
    bool ShouldTriggerCircuitBreaker();
    
    // Reporting
    void GenerateHealthReport(string& report);
    string GenerateDetailedReport();
    
    // Utility
    void Reset();
    void SaveMetricsToFile(const string& filename);
    bool LoadMetricsFromFile(const string& filename);
    
private:
    // Internal calculation methods
    double CalculateSlippageScore();
    double CalculateLatencyScore();
    double CalculateRequoteScore();
    double CalculateSuccessRateScore();
    double CalculateOverallHealthScore();
    
    // Trend analysis
    void UpdateHealthHistory(double healthScore);
    void UpdateTrendAnalysis();
    
    // Alert system
    void CheckAndTriggerAlerts();
    bool IsAlertCooldownActive();
    
    // Utility methods
    ENUM_HEALTH_STATUS DetermineHealthStatus(double healthScore);
    string GetHealthStatusString(ENUM_HEALTH_STATUS status);
    
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CBrokerHealthMonitor::CBrokerHealthMonitor() : 
    m_context(NULL),
    m_HistorySize(0),
    m_MaxHistorySize(0), // Will be set from Inputs
    m_LastAlertTime(0),
    m_LastAlertLevel(HEALTH_EXCELLENT),
    m_AlertCooldownMinutes(0) // Will be set from Inputs
{
    // Để trống, logic sẽ ở trong Initialize
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CBrokerHealthMonitor::~CBrokerHealthMonitor() {
    // Dọn dẹp nếu cần
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CBrokerHealthMonitor::Initialize(EAContext* context) {
    m_context = context;
    m_context = context;
    if(CheckPointer(m_context) == POINTER_INVALID || CheckPointer(m_context->pLogger) == POINTER_INVALID || CheckPointer(m_context->pSymbolInfo) == POINTER_INVALID) {
        printf("BrokerHealthMonitor::Initialize - Context, Logger hoặc SymbolInfo không hợp lệ.");
        return false;
    }

    if (!m_context->Inputs.BHM_Enabled) {
        m_context->pLogger->LogInfo("BrokerHealthMonitor is disabled by input parameters.", __FUNCTION__);
        return true; // Initialize successfully, but will be inactive
    }

    // Load settings from context
    m_MaxHistorySize = m_context->Inputs.BHM_HistorySize;
    m_AlertCooldownMinutes = m_context->Inputs.BHM_AlertCooldownMinutes;

    // Initialize metrics
    Reset();

    // Resize and initialize history arrays
    ArrayResize(m_HealthHistory, m_MaxHistorySize);
    ArrayInitialize(m_HealthHistory, 100.0);
    ArrayResize(m_SlippageHistory, m_MaxHistorySize);
    ArrayInitialize(m_SlippageHistory, 0.0);
    ArrayResize(m_LatencyHistory, m_MaxHistorySize);
    ArrayInitialize(m_LatencyHistory, 0.0);
    m_HistorySize = 0;


    m_context->pLogger->LogInfo("BrokerHealthMonitor đã được khởi tạo thành công", __FUNCTION__);
    return true;
}
    
//+------------------------------------------------------------------+
//| Set Custom Thresholds                                           |
//+------------------------------------------------------------------+
void CBrokerHealthMonitor::OnTradeTransaction(const MqlTradeTransaction& trans, const MqlTradeRequest& request, const MqlTradeResult& result)
{
    if (!m_context || !m_context->Inputs.BHM_Enabled) return;

    // Chỉ xử lý các giao dịch đã hoàn thành
    if (trans.type != TRADE_TRANSACTION_DEAL_ADD) return;

    // Bỏ qua các giao dịch không phải của EA này
    if (trans.comment != m_context->Inputs.OrderComment) return;

    // Tính toán độ trễ thực thi
    double executionTimeMs = (trans.time_msc - request.time_msc);

    // Tính toán trượt giá
    double slippagePips = 0;
    if (request.price != 0 && result.price != 0) {
        if (request.action == TRADE_ACTION_DEAL) { // Market orders
            if (request.type == ORDER_TYPE_BUY) { // Buy
                slippagePips = (result.price - request.price) / m_context->pSymbolInfo->GetPipSize();
            } else if (request.type == ORDER_TYPE_SELL) { // Sell
                slippagePips = (request.price - result.price) / m_context->pSymbolInfo->GetPipSize();
            }
        }
    }

    UpdateWithNewDataPoint(slippagePips, executionTimeMs);
}
    
//+------------------------------------------------------------------+
//| Calculate Slippage Score                                         |
//+------------------------------------------------------------------+
double CBrokerHealthMonitor::CalculateSlippageScore() {
    if (m_HistorySize == 0 || !m_context) return 100.0; // Perfect score if no data

    double totalSlippage = 0;
    int count = 0;
    for (int i = 0; i < m_HistorySize; i++) {
        totalSlippage += m_SlippageHistory[i];
        count++;
    }
    double averageSlippage = (count > 0) ? totalSlippage / count : 0.0;

    // Score calculation: 100 is perfect (0 slippage). 
    // Score decreases as slippage increases. Drops sharply after warning threshold.
    double warningPips = m_context->Inputs.BHM_SlippageWarningPips;
    if (averageSlippage <= 0) return 100.0; // Positive slippage is good
    if (averageSlippage > warningPips * 2) return 0.0; // Very high slippage

    double score = 100.0 * (1.0 - (averageSlippage / (warningPips * 2.0)));
    return MathMax(0.0, MathMin(100.0, score));
}
    
//+------------------------------------------------------------------+
//| Calculate Latency Score                                          |
//+------------------------------------------------------------------+
double CBrokerHealthMonitor::CalculateLatencyScore() {
    if (m_HistorySize == 0 || !m_context) return 100.0;

    double totalLatency = 0;
    int count = 0;
    for (int i = 0; i < m_HistorySize; i++) {
        totalLatency += m_LatencyHistory[i];
        count++;
    }
    double averageLatency = (count > 0) ? totalLatency / count : 0.0;

    double warningMs = m_context->Inputs.BHM_LatencyWarningMs;
    if (averageLatency <= 50) return 100.0; // Excellent latency
    if (averageLatency > warningMs * 2) return 0.0; // Very high latency

    double score = 100.0 * (1.0 - ((averageLatency - 50) / (warningMs * 2.0 - 50)));
    return MathMax(0.0, MathMin(100.0, score));
}
    
//+------------------------------------------------------------------+
//| Calculate Requote Score                                          |
//+------------------------------------------------------------------+
double CBrokerHealthMonitor::CalculateRequoteScore() {
    // V14.0 - Placeholder. Requires tracking requote events from TradeManager.
    // For now, assume no requotes.
    return 100.0;
}
    
//+------------------------------------------------------------------+
//| Calculate Success Rate Score                                     |
//+------------------------------------------------------------------+
double CBrokerHealthMonitor::CalculateSuccessRateScore() {
    // V14.0 - Placeholder. Requires tracking failed order events from TradeManager.
    // For now, assume all trades are successful.
    return 100.0;
}
    
    //+------------------------------------------------------------------+
    //| Update Metrics                                                   |
    //+------------------------------------------------------------------+
    void CBrokerHealthMonitor::UpdateMetrics() {
        // Store previous metrics for comparison
        m_PreviousMetrics = m_CurrentMetrics;
        
        // Calculate individual component scores
        m_CurrentMetrics.SlippageScore = CalculateSlippageScore();
        m_CurrentMetrics.LatencyScore = CalculateLatencyScore();
        m_CurrentMetrics.RequoteScore = CalculateRequoteScore();
        m_CurrentMetrics.SuccessRateScore = CalculateSuccessRateScore();
        
        // Calculate overall health score
        m_CurrentMetrics.HealthScore = CalculateOverallHealthScore();
        
        // Determine health status
        m_CurrentMetrics.HealthStatus = DetermineHealthStatus(m_CurrentMetrics.HealthScore);
        
        // Update historical data and trends
        UpdateHealthHistory(m_CurrentMetrics.HealthScore);
        UpdateTrendAnalysis();
        
        if (m_context != NULL && m_context->pLogger != NULL && m_context->Inputs.LogLevel >= LOG_LEVEL_DEBUG) {
            m_context->pLogger->LogDebug(StringFormat("Health metrics updated: Score=%.2f, Status=%s", 
                                            m_CurrentMetrics.HealthScore, 
                                            GetHealthStatusString(m_CurrentMetrics.HealthStatus)), __FUNCTION__);
        }
    }
    
    //+------------------------------------------------------------------+
    //| Calculate Overall Health Score                                   |
    //+------------------------------------------------------------------+
    double CBrokerHealthMonitor::CalculateOverallHealthScore() {
        // Weighted average of component scores
        double slippageWeight = 0.3;
        double latencyWeight = 0.25;
        double requoteWeight = 0.25;
        double successRateWeight = 0.2;
        
        double totalScore = (m_CurrentMetrics.SlippageScore * slippageWeight) +
                            (m_CurrentMetrics.LatencyScore * latencyWeight) +
                            (m_CurrentMetrics.RequoteScore * requoteWeight) +
                            (m_CurrentMetrics.SuccessRateScore * successRateWeight);
        
        return totalScore;
    }
    
    //+------------------------------------------------------------------+
    //| Update Health History                                            |
    //+------------------------------------------------------------------+
    void CBrokerHealthMonitor::UpdateHealthHistory(double healthScore) {
        if (m_HistorySize < m_MaxHistorySize) {
            m_HealthHistory[m_HistorySize] = healthScore;
            m_HistorySize++;
        } else {
            // Shift history to the left
            for (int i = 0; i < m_MaxHistorySize - 1; i++) {
                m_HealthHistory[i] = m_HealthHistory[i+1];
            }
            m_HealthHistory[m_MaxHistorySize - 1] = healthScore;
        }
    }
    
    //+------------------------------------------------------------------+
    //| Update Trend Analysis                                            |
    //+------------------------------------------------------------------+
    void CBrokerHealthMonitor::UpdateTrendAnalysis() {
        if (m_HistorySize < 2) {
            m_CurrentMetrics.HealthTrend = 0.0;
            return;
        }
        
        // Simple linear trend: (last value - first value) / number of periods
        // A more sophisticated method like linear regression could be used here.
        double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
        int n = MathMin(m_HistorySize, 20); // Use last 20 data points for trend
        
        for (int i = 0; i < n; i++) {
            int index = m_HistorySize - n + i;
            sumX += i;
            sumY += m_HealthHistory[index];
            sumXY += i * m_HealthHistory[index];
            sumX2 += i * i;
        }
        
        double denominator = n * sumX2 - sumX * sumX;
        if (denominator != 0) {
            m_CurrentMetrics.HealthTrend = (n * sumXY - sumX * sumY) / denominator;
        } else {
            m_CurrentMetrics.HealthTrend = 0.0;
        }
    }
    
    //+------------------------------------------------------------------+
    //| Update With New Data Point (Called by TradeManager)              |
    //+------------------------------------------------------------------+
    void CBrokerHealthMonitor::UpdateWithNewDataPoint(double slippagePips, double executionTimeMs) {
    if (!m_context || !m_context->Inputs.BHM_Enabled) return;

    if (m_HistorySize < m_MaxHistorySize) {
        m_SlippageHistory[m_HistorySize] = slippagePips;
        m_LatencyHistory[m_HistorySize] = executionTimeMs;
        m_HistorySize++;
    } else {
        // Shift history to the left
        for (int i = 0; i < m_MaxHistorySize - 1; i++) {
            m_SlippageHistory[i] = m_SlippageHistory[i+1];
            m_LatencyHistory[i] = m_LatencyHistory[i+1];
        }
        m_SlippageHistory[m_MaxHistorySize - 1] = slippagePips;
        m_LatencyHistory[m_MaxHistorySize - 1] = executionTimeMs;
    }

    if(m_context->pLogger != NULL) {
        m_context->pLogger->LogDebug(StringFormat("New broker data point: Slippage=%.2f pips, Latency=%.1f ms. History size: %d", slippagePips, executionTimeMs, m_HistorySize), __FUNCTION__);
    }

    // Recalculate all metrics with the new data point
    UpdateMetrics();
}
    
    //+------------------------------------------------------------------+
    //| Analyze Broker Health (Called periodically, e.g., OnTick)        |
    //+------------------------------------------------------------------+
    void CBrokerHealthMonitor::AnalyzeBrokerHealth() {
        // This function is now responsible for periodic analysis and reporting,
        // not for generating fake data.
        // The actual data crunching and score updates should happen when new data arrives
        // or on a less frequent timer basis.
        
        // For v14.0, we will assume metrics are updated elsewhere and just focus on alerts.
        CheckAndTriggerAlerts();
        
        // Optional: Log a summary report periodically if debugging is enabled
        static datetime lastReportTime = 0;
        if(m_context != NULL && m_context->pLogger != NULL && m_context->Inputs.LogLevel >= LOG_LEVEL_DEBUG && TimeCurrent() - lastReportTime > 300) { // Report every 5 mins
            string report;
            GenerateHealthReport(report);
            m_context->pLogger->LogDebug(report, __FUNCTION__);
            lastReportTime = TimeCurrent();
        }
    }
    
    //+------------------------------------------------------------------+
    //| Generate Health Report                                           |
    //+------------------------------------------------------------------+
    void CBrokerHealthMonitor::GenerateHealthReport(string& report) {
        report = "--- Broker Health Report ---\n";
        report += StringFormat("Overall Score: %.2f (%s)\n", m_CurrentMetrics.HealthScore, GetHealthStatusString(m_CurrentMetrics.HealthStatus));
        report += StringFormat("Score Trend: %.3f\n", m_CurrentMetrics.HealthTrend);
        report += StringFormat("Slippage Score: %.2f | Latency Score: %.2f\n", m_CurrentMetrics.SlippageScore, m_CurrentMetrics.LatencyScore);
        report += StringFormat("Requote Score: %.2f | Success Rate: %.2f\n", m_CurrentMetrics.RequoteScore, m_CurrentMetrics.SuccessRateScore);
        report += "----------------------------";
    }
    
    //+------------------------------------------------------------------+
    //| Determine Health Status from Score                               |
    //+------------------------------------------------------------------+
    ENUM_HEALTH_STATUS CBrokerHealthMonitor::DetermineHealthStatus(double healthScore) {
        if (!m_context) return HEALTH_UNKNOWN;
        if (healthScore >= m_context->Inputs.BHM_ExcellentThreshold) return HEALTH_EXCELLENT;
        if (healthScore >= m_context->Inputs.BHM_GoodThreshold) return HEALTH_GOOD;
        if (healthScore >= m_context->Inputs.BHM_WarningThreshold) return HEALTH_WARNING;
        return HEALTH_CRITICAL;
    }
    
    //+------------------------------------------------------------------+
    //| Get Health Status as a String                                    |
    //+------------------------------------------------------------------+
    string CBrokerHealthMonitor::GetHealthStatusString(ENUM_HEALTH_STATUS status) {
        switch(status) {
            case HEALTH_EXCELLENT: return "Excellent";
            case HEALTH_GOOD:      return "Good";
            case HEALTH_WARNING:   return "Warning";
            case HEALTH_CRITICAL:  return "Critical";
            default:               return "Unknown";
        }
    }
    
    //+------------------------------------------------------------------+
    //| Check and Trigger Alerts                                         |
    //+------------------------------------------------------------------+
    void CBrokerHealthMonitor::CheckAndTriggerAlerts() {
        ENUM_HEALTH_STATUS currentStatus = m_CurrentMetrics.HealthStatus;
        
        if (currentStatus <= HEALTH_WARNING && !IsAlertCooldownActive()) {
            string alertMessage = StringFormat("Broker Health Alert: Status is now %s (Score: %.2f)", 
                                               GetHealthStatusString(currentStatus), 
                                               m_CurrentMetrics.HealthScore);
            
            if (m_context != NULL && m_context->pLogger != NULL) {
                if(currentStatus == HEALTH_WARNING)
                    m_context->pLogger->LogWarning(alertMessage, __FUNCTION__);
                else // CRITICAL
                    m_context->pLogger->LogError(alertMessage, __FUNCTION__);
            }
            
            // Send alert to user (e.g., via mobile notification or email)
            SendNotification(alertMessage);
            
            m_LastAlertTime = TimeCurrent();
            m_LastAlertLevel = currentStatus;
        }
    }
    
    //+------------------------------------------------------------------+
    //| Is Alert Cooldown Active                                         |
    //+------------------------------------------------------------------+
    bool CBrokerHealthMonitor::IsAlertCooldownActive() {
        if (m_LastAlertTime == 0) return false;
        return (TimeCurrent() - m_LastAlertTime) < (m_AlertCooldownMinutes * 60);
    }
    
    //+------------------------------------------------------------------+
    //| Get Risk Adjustment Factor                                       |
    //+------------------------------------------------------------------+
    double CBrokerHealthMonitor::GetRiskAdjustmentFactor() {
        // This is a simple implementation. A more advanced version could use a curve.
        switch(m_CurrentMetrics.HealthStatus) {
            case HEALTH_EXCELLENT:
                return 1.0; // No adjustment
            case HEALTH_GOOD:
                return 0.9; // Slight reduction
            case HEALTH_WARNING:
                return 0.7; // Moderate reduction
            case HEALTH_CRITICAL:
                return 0.5; // Significant reduction
            default:
                return 1.0;
        }
    }
    
    //+------------------------------------------------------------------+
    //| Should Reduce Risk                                               |
    //+------------------------------------------------------------------+
    bool CBrokerHealthMonitor::ShouldReduceRisk() {
        return (m_CurrentMetrics.HealthStatus <= HEALTH_WARNING);
    }
    
    //+------------------------------------------------------------------+
    //| Should Increase Spread                                           |
    //+------------------------------------------------------------------+
    bool CBrokerHealthMonitor::ShouldIncreaseSpread() {
        // Example logic: if slippage score is poor, assume wider spreads are needed
        if (!m_context) return false;
        return (m_CurrentMetrics.SlippageScore < m_context->Inputs.BHM_WarningThreshold);
    }
    
    //+------------------------------------------------------------------+
    //| Should Trigger Circuit Breaker                                   |
    //+------------------------------------------------------------------+
    bool CBrokerHealthMonitor::ShouldTriggerCircuitBreaker() {
        // Trigger if health is critical or has a strong negative trend
        bool isCritical = (m_CurrentMetrics.HealthStatus == HEALTH_CRITICAL);
        if (!m_context) return false;
        bool isDeterioratingFast = (m_CurrentMetrics.HealthTrend < m_context->Inputs.BHM_DeterioratingTrend);
        
        if(isCritical) {
            if(m_context != NULL && m_context->pLogger != NULL) m_context->pLogger->LogError("Circuit Breaker Condition: Broker health is CRITICAL.", __FUNCTION__);
            return true;
        }
        if(isDeterioratingFast) {
            if(m_context != NULL && m_context->pLogger != NULL) m_context->pLogger->LogWarning("Circuit Breaker Condition: Broker health is deteriorating rapidly.", __FUNCTION__);
            return true;
        }
        
        return false;
    }
    
    //+------------------------------------------------------------------+
    //| Reset                                                            |
    //+------------------------------------------------------------------+
    void CBrokerHealthMonitor::Reset() {
    if (!m_context) return;

    m_CurrentMetrics.HealthScore = 100.0;
    m_CurrentMetrics.HealthStatus = HEALTH_EXCELLENT;
    m_CurrentMetrics.HealthTrend = 0.0;
    m_CurrentMetrics.SlippageScore = 100.0;
    m_CurrentMetrics.LatencyScore = 100.0;
    m_CurrentMetrics.RequoteScore = 100.0;
    m_CurrentMetrics.SuccessRateScore = 100.0;
    m_PreviousMetrics = m_CurrentMetrics;

    ArrayInitialize(m_HealthHistory, 100.0);
    ArrayInitialize(m_SlippageHistory, 0.0);
    ArrayInitialize(m_LatencyHistory, 0.0);
    m_HistorySize = 0;

    m_LastAlertTime = 0;
    m_LastAlertLevel = HEALTH_EXCELLENT;

    if (m_context->pLogger) {
        m_context->pLogger->LogInfo("BrokerHealthMonitor has been reset.", __FUNCTION__);
    }
}
    
    //+------------------------------------------------------------------+
    //| Save Metrics to File                                             |
    //+------------------------------------------------------------------+
    void SaveMetricsToFile(const string& filename) {
        // Implementation for persistence
    }
    
    //+------------------------------------------------------------------+
    //| Load Metrics from File                                           |
    //+------------------------------------------------------------------+
    bool LoadMetricsFromFile(const string& filename) {
        // Implementation for persistence
        return true;
    }
    
    //+------------------------------------------------------------------+
    //| Generate Detailed Report                                         |
    //+------------------------------------------------------------------+
    string GenerateDetailedReport() {
        string report = "=== DETAILED BROKER HEALTH REPORT ===\n";
        report += StringFormat("Timestamp: %s\n", TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES));
        report += StringFormat("Overall Health Score: %.2f/100\n", m_CurrentMetrics.HealthScore);
        report += StringFormat("Health Status: %s\n", GetHealthStatusString(m_CurrentMetrics.HealthStatus));
        report += StringFormat("Health Trend: %.3f\n", m_CurrentMetrics.HealthTrend);
        report += "\n--- Component Scores ---\n";
        report += StringFormat("Slippage Score: %.2f/100\n", m_CurrentMetrics.SlippageScore);
        report += StringFormat("Latency Score: %.2f/100\n", m_CurrentMetrics.LatencyScore);
        report += StringFormat("Requote Score: %.2f/100\n", m_CurrentMetrics.RequoteScore);
        report += StringFormat("Success Rate Score: %.2f/100\n", m_CurrentMetrics.SuccessRateScore);
        report += "\n--- Risk Recommendations ---\n";
        report += StringFormat("Risk Adjustment Factor: %.2f\n", GetRiskAdjustmentFactor());
        report += StringFormat("Should Reduce Risk: %s\n", ShouldReduceRisk() ? "YES" : "NO");
        report += StringFormat("Should Increase Spread: %s\n", ShouldIncreaseSpread() ? "YES" : "NO");
        report += StringFormat("Circuit Breaker Trigger: %s\n", ShouldTriggerCircuitBreaker() ? "YES" : "NO");
        report += "=====================================\n";
        return report;
    }
    
    //+------------------------------------------------------------------+
    //| Send Notification (placeholder implementation)                   |
    //+------------------------------------------------------------------+
    void SendNotification(const string& message) {
        // Placeholder for notification system
        // Could integrate with mobile alerts, email, etc.
        if(m_Logger != NULL) {
            m_Logger->LogInfo("NOTIFICATION: " + message);
        }
    }
}; // End of CBrokerHealthMonitor class

} // namespace ApexPullback

#endif // BROKERHEALTHMONITOR_MQH_