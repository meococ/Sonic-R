//+------------------------------------------------------------------+
//|                     Analysis_BrokerHealth.mqh                    |
//|                  APEX Pullback EA v4.0 - Analysis Module         |
//|                  T�c gi?: C�o Gi� & �?i B�ng                     |
//|                        Ng�y: 2024-12-31                          |
//|   Ch?a: CBrokerHealthMonitor - Gi�m s�t s?c kh?e broker          |
//|   Phase 4.1: Real-time Broker Performance Analysis              |
//+------------------------------------------------------------------+

#ifndef ANALYSIS_BROKERHEALTH_MQH
#define ANALYSIS_BROKERHEALTH_MQH

// Include management handled by Includes.mqh - no direct includes needed

//+------------------------------------------------------------------+
//| Broker Health Status Levels                                     |
//+------------------------------------------------------------------+
enum ENUM_BROKER_HEALTH {
    HEALTH_EXCELLENT = 0,       // 90-100 score - Optimal conditions
    HEALTH_GOOD = 1,           // 75-89 score - Good conditions
    HEALTH_WARNING = 2,        // 60-74 score - Caution advised
    HEALTH_POOR = 3,           // 40-59 score - High risk
    HEALTH_CRITICAL = 4        // 0-39 score - Trading not recommended
};

//+------------------------------------------------------------------+
//| Broker Health Metrics                                           |
//+------------------------------------------------------------------+
struct BrokerHealthMetrics {
    // Overall Health
    double              healthScore;            // Overall health score (0-100)
    ENUM_BROKER_HEALTH  healthStatus;         // Health status level
    double              healthTrend;           // Trend direction (+/-)
    
    // Component Scores (0-100)
    double              executionScore;        // Order execution performance
    double              latencyScore;          // Connection speed performance
    double              slippageScore;         // Price slippage performance
    double              requoteScore;          // Requote frequency performance
    double              uptimeScore;           // Connection uptime performance
    
    // Raw Metrics
    double              averageLatencyMs;      // Average execution time (ms)
    double              averageSlippagePips;   // Average slippage (pips)
    double              requoteRate;           // Requote rate (%)
    double              successRate;           // Order success rate (%)
    double              uptimeRate;           // Connection uptime (%)
    
    // Sample Counts
    int                 totalExecutions;       // Total order attempts
    int                 successfulExecutions;  // Successful orders
    int                 totalRequotes;         // Total requotes
    int                 connectionDrops;       // Connection failures
    
    void Initialize() {
        healthScore = 100.0;
        healthStatus = HEALTH_EXCELLENT;
        healthTrend = 0.0;
        executionScore = 100.0;
        latencyScore = 100.0;
        slippageScore = 100.0;
        requoteScore = 100.0;
        uptimeScore = 100.0;
        averageLatencyMs = 0.0;
        averageSlippagePips = 0.0;
        requoteRate = 0.0;
        successRate = 100.0;
        uptimeRate = 100.0;
        totalExecutions = 0;
        successfulExecutions = 0;
        totalRequotes = 0;
        connectionDrops = 0;
    }
};

//+------------------------------------------------------------------+
//| Enhanced Broker Health Monitor Class                            |
//+------------------------------------------------------------------+
class CBrokerHealthMonitor
{
private:
    bool                        m_initialized;
    BrokerHealthMetrics         m_currentMetrics;
    
    // Monitoring State  
    datetime                    m_lastUpdateTime;
    datetime                    m_connectionStartTime;
    bool                        m_isConnected;
    
    // Performance Tracking
    double                      m_totalLatency;
    double                      m_totalSlippage;
    
public:
    //--- Constructor & Destructor (RAII Pattern) - inline implementations
    CBrokerHealthMonitor()
    {
        m_initialized = false;
        m_lastUpdateTime = 0;
        m_connectionStartTime = TimeCurrent();
        m_isConnected = true;
        m_totalLatency = 0.0;
        m_totalSlippage = 0.0;
        
        // Initialize structures
        m_currentMetrics.Initialize();
        
        Print("[APEX_v4] Broker Health Monitor created - awaiting initialization");
    }
    
    ~CBrokerHealthMonitor()
    {
        if(m_initialized)
        {
            string healthReport = GenerateQuickReport();
            Print("[APEX_v4] Broker Health Monitor destroyed.\n" + healthReport);
        }
    }
    
    //--- Initialization Methods - inline implementations
    bool Initialize()
    {
        // Basic initialization without context dependencies
        if(m_initialized) return true;
        
        // Initialize baseline metrics
        UpdateBaseline();
        
        m_initialized = true;
        Print("[APEX_v4] Broker Health Monitor initialized successfully");
        return true;
    }
    
    bool SetContext(EAContext& ctx)
    {
        if(m_initialized) return true;
        
        // Initialize state
        m_currentMetrics.Initialize();
        m_connectionStartTime = TimeCurrent();
        m_isConnected = TerminalInfoInteger(TERMINAL_CONNECTED);
        
        m_initialized = true;
        Print("[APEX_v4] Broker Health Monitor initialized successfully");
        return true;
    }
    
    void Deinitialize()
    {
        if(!m_initialized) return;
        
        string finalReport = GenerateDetailedReport();
        Print("[APEX_v4] Broker Health Monitor deinitialized.\nFinal Report:\n" + finalReport);
        m_initialized = false;
    }
    
    //--- Core Monitoring Methods - inline implementations
    void OnTick()
    {
        if(!m_initialized) return;
        
        // Update connection status
        bool currentlyConnected = TerminalInfoInteger(TERMINAL_CONNECTED);
        if(currentlyConnected != m_isConnected)
        {
            OnConnectionStatusChanged(currentlyConnected);
        }
        
        // Update metrics periodically (every 10 seconds)
        if(TimeCurrent() - m_lastUpdateTime >= 10)
        {
            UpdateMetrics();
            m_lastUpdateTime = TimeCurrent();
        }
    }
    
    void OnTradeExecution(double requestedPrice, double executedPrice, 
                         bool wasSuccessful, bool wasRequoted)
    {
        if(!m_initialized) return;
        
        // Calculate slippage
        double slippagePips = CalculateSlippagePips(requestedPrice, executedPrice);
        
        // Update metrics
        m_currentMetrics.totalExecutions++;
        if(wasSuccessful)
        {
            m_currentMetrics.successfulExecutions++;
        }
        if(wasRequoted)
        {
            m_currentMetrics.totalRequotes++;
        }
        
        // Update cumulative metrics
        m_totalSlippage += MathAbs(slippagePips);
        
        // Calculate averages
        if(m_currentMetrics.totalExecutions > 0)
        {
            m_currentMetrics.averageSlippagePips = m_totalSlippage / m_currentMetrics.totalExecutions;
            m_currentMetrics.successRate = (double)m_currentMetrics.successfulExecutions / 
                                          m_currentMetrics.totalExecutions * 100.0;
            m_currentMetrics.requoteRate = (double)m_currentMetrics.totalRequotes / 
                                         m_currentMetrics.totalExecutions * 100.0;
        }
        
        // Recalculate health scores
        CalculateHealthScores();
        
        Print(StringFormat("[APEX_v4] Trade recorded: Slippage=%.1f pips, Success=%s",
                          slippagePips, wasSuccessful ? "Yes" : "No"));
    }
    
    //--- Query Methods - inline implementations
    BrokerHealthMetrics GetCurrentMetrics() const { return m_currentMetrics; }
    
    double GetHealthScore() const { return m_currentMetrics.healthScore; }
    
    ENUM_BROKER_HEALTH GetHealthStatus() const { return m_currentMetrics.healthStatus; }
    
    //--- Risk Management Integration - inline implementations
    double GetRiskAdjustmentFactor() const
    {
        // Return risk adjustment factor based on health status
        switch(m_currentMetrics.healthStatus)
        {
            case HEALTH_EXCELLENT:  return 1.0;    // No adjustment
            case HEALTH_GOOD:       return 0.9;    // Slight reduction
            case HEALTH_WARNING:    return 0.7;    // Moderate reduction
            case HEALTH_POOR:       return 0.5;    // Significant reduction
            case HEALTH_CRITICAL:   return 0.2;    // Minimal risk only
            default:                return 1.0;
        }
    }
    
    bool ShouldReduceRisk() const
    {
        return m_currentMetrics.healthStatus >= HEALTH_WARNING;
    }
    
    bool ShouldTriggerCircuitBreaker() const
    {
        return m_currentMetrics.healthStatus == HEALTH_CRITICAL;
    }
    
    //--- Reporting Methods - inline implementations
    string GenerateQuickReport() const
    {
        return StringFormat("Health: %.1f%% (%s), Success: %.1f%%, Slippage: %.1f pips",
                           m_currentMetrics.healthScore,
                           GetHealthStatusString(m_currentMetrics.healthStatus),
                           m_currentMetrics.successRate,
                           m_currentMetrics.averageSlippagePips);
    }
    
    string GenerateDetailedReport() const
    {
        string report = "=== BROKER HEALTH DETAILED REPORT ===\n";
        report += StringFormat("Overall Health Score: %.2f%% (%s)\n", 
                              m_currentMetrics.healthScore,
                              GetHealthStatusString(m_currentMetrics.healthStatus));
        
        report += "\n--- Performance Metrics ---\n";
        report += StringFormat("Average Slippage: %.2f pips\n", m_currentMetrics.averageSlippagePips);
        report += StringFormat("Success Rate: %.1f%%\n", m_currentMetrics.successRate);
        report += StringFormat("Requote Rate: %.1f%%\n", m_currentMetrics.requoteRate);
        report += StringFormat("Uptime Rate: %.1f%%\n", m_currentMetrics.uptimeRate);
        
        report += "\n--- Statistics ---\n";
        report += StringFormat("Total Executions: %d\n", m_currentMetrics.totalExecutions);
        report += StringFormat("Successful Executions: %d\n", m_currentMetrics.successfulExecutions);
        report += StringFormat("Total Requotes: %d\n", m_currentMetrics.totalRequotes);
        report += StringFormat("Connection Drops: %d\n", m_currentMetrics.connectionDrops);
        
        report += "\n--- Risk Assessment ---\n";
        report += StringFormat("Risk Adjustment Factor: %.2f\n", GetRiskAdjustmentFactor());
        report += StringFormat("Reduce Risk Recommended: %s\n", ShouldReduceRisk() ? "YES" : "NO");
        report += StringFormat("Circuit Breaker Trigger: %s\n", ShouldTriggerCircuitBreaker() ? "YES" : "NO");
        
        report += "====================================";
        return report;
    }
    
private:
    //--- Internal Update Methods - inline implementations
    void UpdateMetrics()
    {
        // Update connection metrics
        UpdateConnectionMetrics();
        
        // Calculate component scores
        CalculateHealthScores();
    }
    
    void UpdateConnectionMetrics()
    {
        // Calculate uptime percentage
        double totalTime = (double)(TimeCurrent() - m_connectionStartTime);
        if(totalTime > 0)
        {
            double uptimeTime = totalTime - (m_currentMetrics.connectionDrops * 60.0); // Assume 1 min per drop
            m_currentMetrics.uptimeRate = MathMax(0.0, (uptimeTime / totalTime) * 100.0);
        }
    }
    
    void CalculateHealthScores()
    {
        // Calculate individual component scores
        m_currentMetrics.executionScore = CalculateExecutionScore();
        m_currentMetrics.slippageScore = CalculateSlippageScore();
        m_currentMetrics.requoteScore = CalculateRequoteScore();
        m_currentMetrics.uptimeScore = CalculateUptimeScore();
        
        // Calculate weighted overall score (simplified)
        m_currentMetrics.healthScore = (m_currentMetrics.executionScore * 0.4 +
                                       m_currentMetrics.slippageScore * 0.3 +
                                       m_currentMetrics.requoteScore * 0.2 +
                                       m_currentMetrics.uptimeScore * 0.1);
        
        m_currentMetrics.healthScore = MathMax(0.0, MathMin(100.0, m_currentMetrics.healthScore));
        m_currentMetrics.healthStatus = DetermineHealthStatus(m_currentMetrics.healthScore);
    }
    
    double CalculateExecutionScore()
    {
        if(m_currentMetrics.totalExecutions == 0) return 100.0;
        return m_currentMetrics.successRate;
    }
    
    double CalculateSlippageScore()
    {
        if(m_currentMetrics.averageSlippagePips <= 0) return 100.0;
        if(m_currentMetrics.averageSlippagePips <= 1.0) return 100.0;
        if(m_currentMetrics.averageSlippagePips <= 2.0) return 80.0;
        if(m_currentMetrics.averageSlippagePips <= 3.0) return 60.0;
        return MathMax(0.0, 60.0 - (m_currentMetrics.averageSlippagePips - 3.0) * 10.0);
    }
    
    double CalculateRequoteScore()
    {
        if(m_currentMetrics.requoteRate <= 0) return 100.0;
        if(m_currentMetrics.requoteRate <= 2.0) return 100.0;
        if(m_currentMetrics.requoteRate <= 5.0) return 80.0;
        return MathMax(0.0, 80.0 - (m_currentMetrics.requoteRate - 5.0) * 5.0);
    }
    
    double CalculateUptimeScore()
    {
        return MathMax(0.0, MathMin(100.0, m_currentMetrics.uptimeRate));
    }
    
    void OnConnectionStatusChanged(bool isConnected)
    {
        if(isConnected && !m_isConnected)
        {
            Print("[APEX_v4] Broker connection restored");
        }
        else if(!isConnected && m_isConnected)
        {
            m_currentMetrics.connectionDrops++;
            Print("[APEX_v4] Broker connection lost (total drops: " + 
                  IntegerToString(m_currentMetrics.connectionDrops) + ")");
        }
        
        m_isConnected = isConnected;
    }
    
    //--- Utility Methods - inline implementations
    double CalculateSlippagePips(double requested, double executed)
    {
        if(requested == 0.0 || executed == 0.0) return 0.0;
        
        double pipValue = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
        if(SymbolInfoInteger(Symbol(), SYMBOL_DIGITS) == 5 || 
           SymbolInfoInteger(Symbol(), SYMBOL_DIGITS) == 3)
        {
            pipValue *= 10; // Account for 5-digit brokers
        }
        
        return MathAbs(executed - requested) / pipValue;
    }
    
    ENUM_BROKER_HEALTH DetermineHealthStatus(double healthScore)
    {
        if(healthScore >= 90.0) return HEALTH_EXCELLENT;
        if(healthScore >= 75.0) return HEALTH_GOOD;
        if(healthScore >= 60.0) return HEALTH_WARNING;
        if(healthScore >= 40.0) return HEALTH_POOR;
        return HEALTH_CRITICAL;
    }
    
    string GetHealthStatusString(ENUM_BROKER_HEALTH status) const
    {
        switch(status)
        {
            case HEALTH_EXCELLENT:  return "EXCELLENT";
            case HEALTH_GOOD:       return "GOOD";
            case HEALTH_WARNING:    return "WARNING";
            case HEALTH_POOR:       return "POOR";
            case HEALTH_CRITICAL:   return "CRITICAL";
            default:                return "UNKNOWN";
        }
    }
};

#endif // ANALYSIS_BROKERHEALTH_MQH
