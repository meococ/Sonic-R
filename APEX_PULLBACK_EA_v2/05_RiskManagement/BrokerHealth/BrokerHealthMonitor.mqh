//+------------------------------------------------------------------+
//|                                          BrokerHealthMonitor.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "../../01_Core/CommonStructs.mqh"

//+------------------------------------------------------------------+
//| Broker health monitoring enumerations                           |
//+------------------------------------------------------------------+
enum ENUM_BROKER_HEALTH_STATUS {
    BROKER_HEALTH_EXCELLENT,
    BROKER_HEALTH_GOOD,
    BROKER_HEALTH_FAIR,
    BROKER_HEALTH_POOR,
    BROKER_HEALTH_CRITICAL,
    BROKER_HEALTH_UNKNOWN
};

enum ENUM_BROKER_METRIC_TYPE {
    BROKER_METRIC_SPREAD,
    BROKER_METRIC_EXECUTION_SPEED,
    BROKER_METRIC_SLIPPAGE,
    BROKER_METRIC_REQUOTES,
    BROKER_METRIC_DISCONNECTIONS,
    BROKER_METRIC_LATENCY,
    BROKER_METRIC_LIQUIDITY,
    BROKER_METRIC_SWAP_RATES,
    BROKER_METRIC_MARGIN_CALL,
    BROKER_METRIC_STOP_OUT,
    BROKER_METRIC_TRADING_HOURS,
    BROKER_METRIC_SERVER_LOAD
};

enum ENUM_EXECUTION_QUALITY {
    EXECUTION_EXCELLENT,    // < 50ms, no slippage
    EXECUTION_GOOD,         // < 100ms, minimal slippage
    EXECUTION_FAIR,         // < 200ms, acceptable slippage
    EXECUTION_POOR,         // < 500ms, high slippage
    EXECUTION_CRITICAL      // > 500ms, excessive slippage
};

enum ENUM_ALERT_LEVEL {
    ALERT_LEVEL_INFO,
    ALERT_LEVEL_WARNING,
    ALERT_LEVEL_CRITICAL,
    ALERT_LEVEL_EMERGENCY
};

//+------------------------------------------------------------------+
//| Broker health monitoring structures                             |
//+------------------------------------------------------------------+
struct SBrokerMetric {
    ENUM_BROKER_METRIC_TYPE Type;
    string Name;
    double CurrentValue;
    double AverageValue;
    double MinValue;
    double MaxValue;
    double Threshold;
    double CriticalThreshold;
    datetime LastUpdate;
    bool IsHealthy;
    string Unit;
    string Description;
};

struct SExecutionStats {
    int TotalOrders;
    int SuccessfulOrders;
    int FailedOrders;
    int RequoteCount;
    double AverageExecutionTime;    // milliseconds
    double AverageSlippage;         // points
    double MaxSlippage;
    double TotalSlippage;
    ENUM_EXECUTION_QUALITY Quality;
    datetime LastExecution;
    datetime FirstExecution;
};

struct SConnectionStats {
    int TotalConnections;
    int Disconnections;
    int Reconnections;
    double AverageLatency;          // milliseconds
    double MaxLatency;
    datetime LastDisconnection;
    datetime LastReconnection;
    double UptimePercentage;
    bool IsConnected;
};

struct SSpreadAnalysis {
    string Symbol;
    double CurrentSpread;
    double AverageSpread;
    double MinSpread;
    double MaxSpread;
    double SpreadVolatility;
    datetime LastUpdate;
    bool IsAcceptable;
    double AcceptableThreshold;
};

struct SBrokerAlert {
    ENUM_ALERT_LEVEL Level;
    ENUM_BROKER_METRIC_TYPE MetricType;
    string Message;
    double Value;
    double Threshold;
    datetime Timestamp;
    bool IsActive;
    bool IsAcknowledged;
};

struct SBrokerHealthReport {
    ENUM_BROKER_HEALTH_STATUS OverallHealth;
    double HealthScore;             // 0-100
    SExecutionStats ExecutionStats;
    SConnectionStats ConnectionStats;
    SSpreadAnalysis SpreadAnalysis[10];  // Top 10 symbols
    int SpreadAnalysisCount;
    SBrokerAlert ActiveAlerts[20];
    int ActiveAlertCount;
    datetime ReportTime;
    string BrokerName;
    string ServerName;
    int AccountNumber;
};

struct SBrokerConfiguration {
    double SpreadThreshold;         // points
    double ExecutionTimeThreshold;  // milliseconds
    double SlippageThreshold;       // points
    double LatencyThreshold;        // milliseconds
    int RequoteThreshold;           // count per hour
    double UptimeThreshold;         // percentage
    bool EnableAlerts;
    bool EnableLogging;
    int MonitoringInterval;         // seconds
    int HistoryDepth;              // number of records to keep
    string MonitoredSymbols[20];
    int MonitoredSymbolCount;
};

struct SBrokerStatistics {
    int TotalMonitoringCycles;
    int HealthyPeriods;
    int UnhealthyPeriods;
    double AverageHealthScore;
    double BestHealthScore;
    double WorstHealthScore;
    datetime FirstMonitoring;
    datetime LastMonitoring;
    int AlertsGenerated;
    int CriticalAlertsGenerated;
    datetime LastAlert;
    string LastAlertMessage;
};

//+------------------------------------------------------------------+
//| Broker Health Monitor Class                                     |
//+------------------------------------------------------------------+
class CBrokerHealthMonitor {
private:
    EAContext* m_pContext;
    
    // Configuration
    SBrokerConfiguration m_Config;
    
    // Metrics
    SBrokerMetric m_Metrics[12];  // All broker metrics
    int m_MetricCount;
    
    // Statistics
    SExecutionStats m_ExecutionStats;
    SConnectionStats m_ConnectionStats;
    SSpreadAnalysis m_SpreadAnalysis[20];
    int m_SpreadAnalysisCount;
    
    // Alerts
    SBrokerAlert m_Alerts[50];
    int m_AlertCount;
    
    // Overall statistics
    SBrokerStatistics m_Statistics;
    
    // Internal state
    bool m_bInitialized;
    bool m_bMonitoring;
    datetime m_LastMonitoring;
    datetime m_LastHealthCheck;
    ENUM_BROKER_HEALTH_STATUS m_CurrentHealth;
    double m_CurrentHealthScore;
    
    // Helper methods
    bool InitializeMetrics();
    bool UpdateMetrics();
    bool AnalyzeSpreads();
    bool MonitorExecution();
    bool CheckConnection();
    bool EvaluateHealth();
    bool GenerateAlerts();
    bool UpdateStatistics();
    double CalculateHealthScore();
    ENUM_BROKER_HEALTH_STATUS DetermineHealthStatus(double score);
    ENUM_EXECUTION_QUALITY DetermineExecutionQuality();
    bool IsSpreadAcceptable(const string symbol, double spread);
    void LogError(const string message);
    void LogActivity(const string message);
    void LogAlert(const SBrokerAlert& alert);
    
public:
    // Constructor/Destructor
    CBrokerHealthMonitor();
    ~CBrokerHealthMonitor();
    
    // Initialization
    bool Initialize(EAContext* context);
    bool Deinitialize();
    bool Configure(const SBrokerConfiguration& config);
    
    // Main operations
    bool StartMonitoring();
    bool StopMonitoring();
    bool UpdateHealth();
    bool PerformHealthCheck();
    
    // Metrics
    bool GetMetric(ENUM_BROKER_METRIC_TYPE type, SBrokerMetric& metric);
    bool GetAllMetrics(SBrokerMetric& metrics[]);
    double GetMetricValue(ENUM_BROKER_METRIC_TYPE type);
    bool IsMetricHealthy(ENUM_BROKER_METRIC_TYPE type);
    
    // Execution monitoring
    bool RecordExecution(double executionTime, double slippage, bool success);
    bool RecordRequote();
    SExecutionStats GetExecutionStats() const { return m_ExecutionStats; }
    ENUM_EXECUTION_QUALITY GetExecutionQuality() const;
    
    // Connection monitoring
    bool RecordDisconnection();
    bool RecordReconnection();
    SConnectionStats GetConnectionStats() const { return m_ConnectionStats; }
    bool IsConnectionHealthy() const;
    
    // Spread analysis
    bool UpdateSpreadAnalysis(const string symbol);
    bool GetSpreadAnalysis(const string symbol, SSpreadAnalysis& analysis);
    bool IsSpreadHealthy(const string symbol);
    double GetAverageSpread(const string symbol);
    
    // Health assessment
    ENUM_BROKER_HEALTH_STATUS GetCurrentHealth() const { return m_CurrentHealth; }
    double GetCurrentHealthScore() const { return m_CurrentHealthScore; }
    bool IsHealthy() const;
    bool GenerateHealthReport(SBrokerHealthReport& report);
    
    // Alerts
    bool GetActiveAlerts(SBrokerAlert& alerts[]);
    int GetActiveAlertCount() const { return m_AlertCount; }
    bool AcknowledgeAlert(int alertIndex);
    bool ClearAlert(int alertIndex);
    bool ClearAllAlerts();
    
    // Configuration
    bool SetConfiguration(const SBrokerConfiguration& config);
    SBrokerConfiguration GetConfiguration() const { return m_Config; }
    bool AddMonitoredSymbol(const string symbol);
    bool RemoveMonitoredSymbol(const string symbol);
    
    // Statistics
    SBrokerStatistics GetStatistics() const { return m_Statistics; }
    bool ResetStatistics();
    
    // Utility
    string GetHealthStatusName(ENUM_BROKER_HEALTH_STATUS status);
    string GetExecutionQualityName(ENUM_EXECUTION_QUALITY quality);
    string GetMetricName(ENUM_BROKER_METRIC_TYPE type);
    string GetAlertLevelName(ENUM_ALERT_LEVEL level);
    
    // Status
    bool IsInitialized() const { return m_bInitialized; }
    bool IsMonitoring() const { return m_bMonitoring; }
    datetime GetLastMonitoring() const { return m_LastMonitoring; }
};

//+------------------------------------------------------------------+
//| Constructor                                                     |
//+------------------------------------------------------------------+
CBrokerHealthMonitor::CBrokerHealthMonitor() {
    m_pContext = NULL;
    m_MetricCount = 0;
    m_SpreadAnalysisCount = 0;
    m_AlertCount = 0;
    m_bInitialized = false;
    m_bMonitoring = false;
    m_LastMonitoring = 0;
    m_LastHealthCheck = 0;
    m_CurrentHealth = BROKER_HEALTH_UNKNOWN;
    m_CurrentHealthScore = 0.0;
    
    // Set default configuration
    m_Config.SpreadThreshold = 3.0;           // 3 points
    m_Config.ExecutionTimeThreshold = 200.0;  // 200ms
    m_Config.SlippageThreshold = 2.0;         // 2 points
    m_Config.LatencyThreshold = 100.0;        // 100ms
    m_Config.RequoteThreshold = 5;            // 5 per hour
    m_Config.UptimeThreshold = 99.0;          // 99%
    m_Config.EnableAlerts = true;
    m_Config.EnableLogging = true;
    m_Config.MonitoringInterval = 60;         // 1 minute
    m_Config.HistoryDepth = 1000;
    m_Config.MonitoredSymbolCount = 0;
    
    ZeroMemory(m_ExecutionStats);
    ZeroMemory(m_ConnectionStats);
    ZeroMemory(m_Statistics);
}

//+------------------------------------------------------------------+
//| Destructor                                                      |
//+------------------------------------------------------------------+
CBrokerHealthMonitor::~CBrokerHealthMonitor() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize broker health monitor                                |
//+------------------------------------------------------------------+
bool CBrokerHealthMonitor::Initialize(EAContext* context) {
    if (context == NULL) {
        LogError("Invalid context provided");
        return false;
    }
    
    m_pContext = context;
    
    // Initialize metrics
    if (!InitializeMetrics()) {
        LogError("Failed to initialize metrics");
        return false;
    }
    
    // Initialize connection stats
    m_ConnectionStats.IsConnected = TerminalInfoInteger(TERMINAL_CONNECTED);
    m_ConnectionStats.TotalConnections = 1;
    m_ConnectionStats.UptimePercentage = 100.0;
    
    // Add default monitored symbols
    if (m_Config.MonitoredSymbolCount == 0) {
        AddMonitoredSymbol(Symbol());
    }
    
    m_bInitialized = true;
    m_Statistics.FirstMonitoring = TimeCurrent();
    
    LogActivity("Broker health monitor initialized successfully");
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize broker health monitor                              |
//+------------------------------------------------------------------+
bool CBrokerHealthMonitor::Deinitialize() {
    if (m_bInitialized) {
        StopMonitoring();
        m_bInitialized = false;
        m_pContext = NULL;
        LogActivity("Broker health monitor deinitialized");
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Configure broker health monitor                                 |
//+------------------------------------------------------------------+
bool CBrokerHealthMonitor::Configure(const SBrokerConfiguration& config) {
    m_Config = config;
    
    // Validate configuration
    if (m_Config.SpreadThreshold < 0.1) m_Config.SpreadThreshold = 0.1;
    if (m_Config.ExecutionTimeThreshold < 10.0) m_Config.ExecutionTimeThreshold = 10.0;
    if (m_Config.SlippageThreshold < 0.1) m_Config.SlippageThreshold = 0.1;
    if (m_Config.LatencyThreshold < 10.0) m_Config.LatencyThreshold = 10.0;
    if (m_Config.RequoteThreshold < 1) m_Config.RequoteThreshold = 1;
    if (m_Config.UptimeThreshold < 50.0) m_Config.UptimeThreshold = 50.0;
    if (m_Config.UptimeThreshold > 100.0) m_Config.UptimeThreshold = 100.0;
    if (m_Config.MonitoringInterval < 10) m_Config.MonitoringInterval = 10;
    if (m_Config.HistoryDepth < 100) m_Config.HistoryDepth = 100;
    
    LogActivity("Broker health monitor configured successfully");
    return true;
}

//+------------------------------------------------------------------+
//| Start monitoring                                                |
//+------------------------------------------------------------------+
bool CBrokerHealthMonitor::StartMonitoring() {
    if (!m_bInitialized) {
        LogError("Broker health monitor not initialized");
        return false;
    }
    
    m_bMonitoring = true;
    m_LastMonitoring = TimeCurrent();
    
    LogActivity("Broker health monitoring started");
    return true;
}

//+------------------------------------------------------------------+
//| Stop monitoring                                                 |
//+------------------------------------------------------------------+
bool CBrokerHealthMonitor::StopMonitoring() {
    if (m_bMonitoring) {
        m_bMonitoring = false;
        LogActivity("Broker health monitoring stopped");
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Update health status                                            |
//+------------------------------------------------------------------+
bool CBrokerHealthMonitor::UpdateHealth() {
    if (!m_bInitialized || !m_bMonitoring) {
        return false;
    }
    
    datetime currentTime = TimeCurrent();
    
    // Check if it's time for monitoring
    if ((currentTime - m_LastMonitoring) < m_Config.MonitoringInterval) {
        return true;
    }
    
    // Update all metrics
    UpdateMetrics();
    
    // Analyze spreads
    AnalyzeSpreads();
    
    // Check connection
    CheckConnection();
    
    // Evaluate overall health
    EvaluateHealth();
    
    // Generate alerts if needed
    if (m_Config.EnableAlerts) {
        GenerateAlerts();
    }
    
    // Update statistics
    UpdateStatistics();
    
    m_LastMonitoring = currentTime;
    m_Statistics.TotalMonitoringCycles++;
    m_Statistics.LastMonitoring = currentTime;
    
    return true;
}

//+------------------------------------------------------------------+
//| Perform comprehensive health check                              |
//+------------------------------------------------------------------+
bool CBrokerHealthMonitor::PerformHealthCheck() {
    if (!m_bInitialized) {
        return false;
    }
    
    // Force update regardless of timing
    UpdateMetrics();
    AnalyzeSpreads();
    CheckConnection();
    EvaluateHealth();
    
    if (m_Config.EnableAlerts) {
        GenerateAlerts();
    }
    
    UpdateStatistics();
    
    m_LastHealthCheck = TimeCurrent();
    
    LogActivity(StringFormat("Health check completed - Status: %s, Score: %.1f", 
                GetHealthStatusName(m_CurrentHealth), m_CurrentHealthScore));
    
    return true;
}

//+------------------------------------------------------------------+
//| Initialize metrics                                              |
//+------------------------------------------------------------------+
bool CBrokerHealthMonitor::InitializeMetrics() {
    m_MetricCount = 0;
    
    // Define all metrics
    string metricNames[] = {
        "Spread", "Execution Speed", "Slippage", "Requotes", "Disconnections",
        "Latency", "Liquidity", "Swap Rates", "Margin Call", "Stop Out",
        "Trading Hours", "Server Load"
    };
    
    string metricUnits[] = {
        "points", "ms", "points", "count", "count",
        "ms", "score", "rate", "level", "level",
        "hours", "percent"
    };
    
    double thresholds[] = {
        3.0, 200.0, 2.0, 5.0, 1.0,
        100.0, 0.8, 0.05, 50.0, 20.0,
        24.0, 80.0
    };
    
    for (int i = 0; i < ArraySize(metricNames) && i < ArraySize(m_Metrics); i++) {
        m_Metrics[i].Type = (ENUM_BROKER_METRIC_TYPE)i;
        m_Metrics[i].Name = metricNames[i];
        m_Metrics[i].CurrentValue = 0.0;
        m_Metrics[i].AverageValue = 0.0;
        m_Metrics[i].MinValue = DBL_MAX;
        m_Metrics[i].MaxValue = -DBL_MAX;
        m_Metrics[i].Threshold = thresholds[i];
        m_Metrics[i].CriticalThreshold = thresholds[i] * 2.0;
        m_Metrics[i].LastUpdate = 0;
        m_Metrics[i].IsHealthy = true;
        m_Metrics[i].Unit = metricUnits[i];
        m_Metrics[i].Description = "";
        
        m_MetricCount++;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Update all metrics                                              |
//+------------------------------------------------------------------+
bool CBrokerHealthMonitor::UpdateMetrics() {
    datetime currentTime = TimeCurrent();
    
    for (int i = 0; i < m_MetricCount; i++) {
        double newValue = 0.0;
        
        switch (m_Metrics[i].Type) {
            case BROKER_METRIC_SPREAD:
                // Average spread across monitored symbols
                {
                    double totalSpread = 0.0;
                    int validSymbols = 0;
                    for (int j = 0; j < m_Config.MonitoredSymbolCount; j++) {
                        double ask = SymbolInfoDouble(m_Config.MonitoredSymbols[j], SYMBOL_ASK);
                        double bid = SymbolInfoDouble(m_Config.MonitoredSymbols[j], SYMBOL_BID);
                        if (ask > 0 && bid > 0) {
                            totalSpread += (ask - bid) / SymbolInfoDouble(m_Config.MonitoredSymbols[j], SYMBOL_POINT);
                            validSymbols++;
                        }
                    }
                    if (validSymbols > 0) {
                        newValue = totalSpread / validSymbols;
                    }
                }
                break;
                
            case BROKER_METRIC_EXECUTION_SPEED:
                newValue = m_ExecutionStats.AverageExecutionTime;
                break;
                
            case BROKER_METRIC_SLIPPAGE:
                newValue = m_ExecutionStats.AverageSlippage;
                break;
                
            case BROKER_METRIC_REQUOTES:
                newValue = m_ExecutionStats.RequoteCount;
                break;
                
            case BROKER_METRIC_DISCONNECTIONS:
                newValue = m_ConnectionStats.Disconnections;
                break;
                
            case BROKER_METRIC_LATENCY:
                newValue = m_ConnectionStats.AverageLatency;
                break;
                
            case BROKER_METRIC_LIQUIDITY:
                // Simple liquidity score based on spread and volume
                newValue = 0.8;  // Placeholder
                break;
                
            case BROKER_METRIC_TRADING_HOURS:
                // Check if market is open
                newValue = SymbolInfoInteger(Symbol(), SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_FULL ? 1.0 : 0.0;
                break;
                
            default:
                newValue = 0.0;
                break;
        }
        
        // Update metric values
        m_Metrics[i].CurrentValue = newValue;
        m_Metrics[i].LastUpdate = currentTime;
        
        // Update min/max
        if (newValue < m_Metrics[i].MinValue) {
            m_Metrics[i].MinValue = newValue;
        }
        if (newValue > m_Metrics[i].MaxValue) {
            m_Metrics[i].MaxValue = newValue;
        }
        
        // Update average (simple moving average)
        if (m_Metrics[i].AverageValue == 0.0) {
            m_Metrics[i].AverageValue = newValue;
        } else {
            m_Metrics[i].AverageValue = (m_Metrics[i].AverageValue * 0.9) + (newValue * 0.1);
        }
        
        // Check if healthy
        m_Metrics[i].IsHealthy = (newValue <= m_Metrics[i].Threshold);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Analyze spreads                                                 |
//+------------------------------------------------------------------+
bool CBrokerHealthMonitor::AnalyzeSpreads() {
    m_SpreadAnalysisCount = 0;
    
    for (int i = 0; i < m_Config.MonitoredSymbolCount && i < ArraySize(m_SpreadAnalysis); i++) {
        string symbol = m_Config.MonitoredSymbols[i];
        
        double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
        double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
        
        if (ask > 0 && bid > 0) {
            SSpreadAnalysis analysis;
            ZeroMemory(analysis);
            
            analysis.Symbol = symbol;
            analysis.CurrentSpread = (ask - bid) / SymbolInfoDouble(symbol, SYMBOL_POINT);
            analysis.LastUpdate = TimeCurrent();
            analysis.AcceptableThreshold = m_Config.SpreadThreshold;
            analysis.IsAcceptable = (analysis.CurrentSpread <= analysis.AcceptableThreshold);
            
            // Update average (simple implementation)
            if (m_SpreadAnalysisCount < ArraySize(m_SpreadAnalysis)) {
                // Find existing analysis for this symbol
                bool found = false;
                for (int j = 0; j < m_SpreadAnalysisCount; j++) {
                    if (m_SpreadAnalysis[j].Symbol == symbol) {
                        // Update existing
                        if (m_SpreadAnalysis[j].AverageSpread == 0.0) {
                            m_SpreadAnalysis[j].AverageSpread = analysis.CurrentSpread;
                        } else {
                            m_SpreadAnalysis[j].AverageSpread = (m_SpreadAnalysis[j].AverageSpread * 0.9) + (analysis.CurrentSpread * 0.1);
                        }
                        
                        m_SpreadAnalysis[j].CurrentSpread = analysis.CurrentSpread;
                        m_SpreadAnalysis[j].LastUpdate = analysis.LastUpdate;
                        m_SpreadAnalysis[j].IsAcceptable = analysis.IsAcceptable;
                        
                        if (analysis.CurrentSpread < m_SpreadAnalysis[j].MinSpread || m_SpreadAnalysis[j].MinSpread == 0.0) {
                            m_SpreadAnalysis[j].MinSpread = analysis.CurrentSpread;
                        }
                        if (analysis.CurrentSpread > m_SpreadAnalysis[j].MaxSpread) {
                            m_SpreadAnalysis[j].MaxSpread = analysis.CurrentSpread;
                        }
                        
                        found = true;
                        break;
                    }
                }
                
                if (!found) {
                    // Add new analysis
                    analysis.AverageSpread = analysis.CurrentSpread;
                    analysis.MinSpread = analysis.CurrentSpread;
                    analysis.MaxSpread = analysis.CurrentSpread;
                    m_SpreadAnalysis[m_SpreadAnalysisCount] = analysis;
                    m_SpreadAnalysisCount++;
                }
            }
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Check connection status                                          |
//+------------------------------------------------------------------+
bool CBrokerHealthMonitor::CheckConnection() {
    bool currentlyConnected = TerminalInfoInteger(TERMINAL_CONNECTED);
    
    if (currentlyConnected != m_ConnectionStats.IsConnected) {
        if (currentlyConnected) {
            // Reconnected
            RecordReconnection();
        } else {
            // Disconnected
            RecordDisconnection();
        }
        
        m_ConnectionStats.IsConnected = currentlyConnected;
    }
    
    // Update uptime percentage
    if (m_ConnectionStats.TotalConnections > 0) {
        double uptime = (double)(m_ConnectionStats.TotalConnections - m_ConnectionStats.Disconnections) / m_ConnectionStats.TotalConnections;
        m_ConnectionStats.UptimePercentage = uptime * 100.0;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Evaluate overall health                                         |
//+------------------------------------------------------------------+
bool CBrokerHealthMonitor::EvaluateHealth() {
    m_CurrentHealthScore = CalculateHealthScore();
    m_CurrentHealth = DetermineHealthStatus(m_CurrentHealthScore);
    
    // Update statistics
    if (m_CurrentHealth == BROKER_HEALTH_EXCELLENT || m_CurrentHealth == BROKER_HEALTH_GOOD) {
        m_Statistics.HealthyPeriods++;
    } else {
        m_Statistics.UnhealthyPeriods++;
    }
    
    // Update average health score
    if (m_Statistics.AverageHealthScore == 0.0) {
        m_Statistics.AverageHealthScore = m_CurrentHealthScore;
    } else {
        m_Statistics.AverageHealthScore = (m_Statistics.AverageHealthScore * 0.95) + (m_CurrentHealthScore * 0.05);
    }
    
    // Update best/worst scores
    if (m_CurrentHealthScore > m_Statistics.BestHealthScore) {
        m_Statistics.BestHealthScore = m_CurrentHealthScore;
    }
    if (m_CurrentHealthScore < m_Statistics.WorstHealthScore || m_Statistics.WorstHealthScore == 0.0) {
        m_Statistics.WorstHealthScore = m_CurrentHealthScore;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Calculate health score                                          |
//+------------------------------------------------------------------+
double CBrokerHealthMonitor::CalculateHealthScore() {
    double totalScore = 0.0;
    double totalWeight = 0.0;
    
    // Weight factors for different metrics
    double weights[] = {
        0.20,  // Spread
        0.25,  // Execution Speed
        0.15,  // Slippage
        0.10,  // Requotes
        0.15,  // Disconnections
        0.10,  // Latency
        0.05   // Others
    };
    
    for (int i = 0; i < m_MetricCount && i < ArraySize(weights); i++) {
        double score = 0.0;
        
        // Calculate score based on threshold
        if (m_Metrics[i].Threshold > 0) {
            if (m_Metrics[i].CurrentValue <= m_Metrics[i].Threshold) {
                score = 100.0;  // Perfect score
            } else if (m_Metrics[i].CurrentValue <= m_Metrics[i].CriticalThreshold) {
                // Linear degradation between threshold and critical
                double ratio = (m_Metrics[i].CurrentValue - m_Metrics[i].Threshold) / 
                              (m_Metrics[i].CriticalThreshold - m_Metrics[i].Threshold);
                score = 100.0 * (1.0 - ratio);
            } else {
                score = 0.0;  // Critical failure
            }
        }
        
        totalScore += score * weights[i];
        totalWeight += weights[i];
    }
    
    // Add connection uptime score
    totalScore += m_ConnectionStats.UptimePercentage * 0.1;
    totalWeight += 0.1;
    
    if (totalWeight > 0) {
        return totalScore / totalWeight;
    }
    
    return 0.0;
}

//+------------------------------------------------------------------+
//| Determine health status from score                              |
//+------------------------------------------------------------------+
ENUM_BROKER_HEALTH_STATUS CBrokerHealthMonitor::DetermineHealthStatus(double score) {
    if (score >= 90.0) return BROKER_HEALTH_EXCELLENT;
    if (score >= 75.0) return BROKER_HEALTH_GOOD;
    if (score >= 60.0) return BROKER_HEALTH_FAIR;
    if (score >= 40.0) return BROKER_HEALTH_POOR;
    if (score >= 0.0)  return BROKER_HEALTH_CRITICAL;
    
    return BROKER_HEALTH_UNKNOWN;
}

//+------------------------------------------------------------------+
//| Record execution statistics                                     |
//+------------------------------------------------------------------+
bool CBrokerHealthMonitor::RecordExecution(double executionTime, double slippage, bool success) {
    m_ExecutionStats.TotalOrders++;
    
    if (success) {
        m_ExecutionStats.SuccessfulOrders++;
    } else {
        m_ExecutionStats.FailedOrders++;
    }
    
    // Update execution time average
    if (m_ExecutionStats.AverageExecutionTime == 0.0) {
        m_ExecutionStats.AverageExecutionTime = executionTime;
    } else {
        m_ExecutionStats.AverageExecutionTime = (m_ExecutionStats.AverageExecutionTime * 0.9) + (executionTime * 0.1);
    }
    
    // Update slippage statistics
    if (m_ExecutionStats.AverageSlippage == 0.0) {
        m_ExecutionStats.AverageSlippage = slippage;
    } else {
        m_ExecutionStats.AverageSlippage = (m_ExecutionStats.AverageSlippage * 0.9) + (slippage * 0.1);
    }
    
    if (slippage > m_ExecutionStats.MaxSlippage) {
        m_ExecutionStats.MaxSlippage = slippage;
    }
    
    m_ExecutionStats.TotalSlippage += slippage;
    m_ExecutionStats.LastExecution = TimeCurrent();
    
    if (m_ExecutionStats.FirstExecution == 0) {
        m_ExecutionStats.FirstExecution = TimeCurrent();
    }
    
    // Update execution quality
    m_ExecutionStats.Quality = DetermineExecutionQuality();
    
    return true;
}

//+------------------------------------------------------------------+
//| Record requote                                                  |
//+------------------------------------------------------------------+
bool CBrokerHealthMonitor::RecordRequote() {
    m_ExecutionStats.RequoteCount++;
    return true;
}

//+------------------------------------------------------------------+
//| Record disconnection                                            |
//+------------------------------------------------------------------+
bool CBrokerHealthMonitor::RecordDisconnection() {
    m_ConnectionStats.Disconnections++;
    m_ConnectionStats.LastDisconnection = TimeCurrent();
    
    LogActivity("Broker disconnection recorded");
    return true;
}

//+------------------------------------------------------------------+
//| Record reconnection                                             |
//+------------------------------------------------------------------+
bool CBrokerHealthMonitor::RecordReconnection() {
    m_ConnectionStats.Reconnections++;
    m_ConnectionStats.LastReconnection = TimeCurrent();
    
    LogActivity("Broker reconnection recorded");
    return true;
}

//+------------------------------------------------------------------+
//| Determine execution quality                                     |
//+------------------------------------------------------------------+
ENUM_EXECUTION_QUALITY CBrokerHealthMonitor::DetermineExecutionQuality() {
    double avgTime = m_ExecutionStats.AverageExecutionTime;
    double avgSlippage = m_ExecutionStats.AverageSlippage;
    
    if (avgTime < 50.0 && avgSlippage < 0.5) return EXECUTION_EXCELLENT;
    if (avgTime < 100.0 && avgSlippage < 1.0) return EXECUTION_GOOD;
    if (avgTime < 200.0 && avgSlippage < 2.0) return EXECUTION_FAIR;
    if (avgTime < 500.0 && avgSlippage < 5.0) return EXECUTION_POOR;
    
    return EXECUTION_CRITICAL;
}

//+------------------------------------------------------------------+
//| Generate alerts                                                 |
//+------------------------------------------------------------------+
bool CBrokerHealthMonitor::GenerateAlerts() {
    // Clear old alerts
    for (int i = 0; i < m_AlertCount; i++) {
        if (!m_Alerts[i].IsActive) {
            // Remove inactive alert
            for (int j = i; j < m_AlertCount - 1; j++) {
                m_Alerts[j] = m_Alerts[j + 1];
            }
            m_AlertCount--;
            i--;
        }
    }
    
    // Check for new alerts
    for (int i = 0; i < m_MetricCount; i++) {
        if (!m_Metrics[i].IsHealthy && m_AlertCount < ArraySize(m_Alerts)) {
            // Check if alert already exists
            bool alertExists = false;
            for (int j = 0; j < m_AlertCount; j++) {
                if (m_Alerts[j].MetricType == m_Metrics[i].Type && m_Alerts[j].IsActive) {
                    alertExists = true;
                    break;
                }
            }
            
            if (!alertExists) {
                // Create new alert
                SBrokerAlert alert;
                ZeroMemory(alert);
                
                alert.MetricType = m_Metrics[i].Type;
                alert.Value = m_Metrics[i].CurrentValue;
                alert.Threshold = m_Metrics[i].Threshold;
                alert.Timestamp = TimeCurrent();
                alert.IsActive = true;
                alert.IsAcknowledged = false;
                
                if (m_Metrics[i].CurrentValue >= m_Metrics[i].CriticalThreshold) {
                    alert.Level = ALERT_LEVEL_CRITICAL;
                    alert.Message = StringFormat("CRITICAL: %s exceeded critical threshold (%.2f >= %.2f)", 
                                               m_Metrics[i].Name, m_Metrics[i].CurrentValue, m_Metrics[i].CriticalThreshold);
                } else {
                    alert.Level = ALERT_LEVEL_WARNING;
                    alert.Message = StringFormat("WARNING: %s exceeded threshold (%.2f >= %.2f)", 
                                               m_Metrics[i].Name, m_Metrics[i].CurrentValue, m_Metrics[i].Threshold);
                }
                
                m_Alerts[m_AlertCount] = alert;
                m_AlertCount++;
                
                m_Statistics.AlertsGenerated++;
                if (alert.Level == ALERT_LEVEL_CRITICAL) {
                    m_Statistics.CriticalAlertsGenerated++;
                }
                
                m_Statistics.LastAlert = alert.Timestamp;
                m_Statistics.LastAlertMessage = alert.Message;
                
                LogAlert(alert);
            }
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Update statistics                                               |
//+------------------------------------------------------------------+
bool CBrokerHealthMonitor::UpdateStatistics() {
    m_Statistics.LastMonitoring = TimeCurrent();
    return true;
}

//+------------------------------------------------------------------+
//| Log error message                                               |
//+------------------------------------------------------------------+
void CBrokerHealthMonitor::LogError(const string message) {
    if (m_pContext != NULL && m_pContext.pLogger != NULL) {
        m_pContext.pLogger.LogError("BrokerHealthMonitor: " + message);
    } else {
        Print("BrokerHealthMonitor ERROR: ", message);
    }
}

//+------------------------------------------------------------------+
//| Log activity message                                            |
//+------------------------------------------------------------------+
void CBrokerHealthMonitor::LogActivity(const string message) {
    if (m_Config.EnableLogging) {
        if (m_pContext != NULL && m_pContext.pLogger != NULL) {
            m_pContext.pLogger.LogInfo("BrokerHealthMonitor: " + message);
        } else {
            Print("BrokerHealthMonitor: ", message);
        }
    }
}

//+------------------------------------------------------------------+
//| Log alert                                                       |
//+------------------------------------------------------------------+
void CBrokerHealthMonitor::LogAlert(const SBrokerAlert& alert) {
    string levelName = GetAlertLevelName(alert.Level);
    string message = StringFormat("[%s] %s", levelName, alert.Message);
    
    if (m_pContext != NULL && m_pContext.pLogger != NULL) {
        if (alert.Level == ALERT_LEVEL_CRITICAL || alert.Level == ALERT_LEVEL_EMERGENCY) {
            m_pContext.pLogger.LogError("BrokerHealthMonitor: " + message);
        } else {
            m_pContext.pLogger.LogWarning("BrokerHealthMonitor: " + message);
        }
    } else {
        Print("BrokerHealthMonitor ALERT: ", message);
    }
}

//+------------------------------------------------------------------+
//| Get health status name                                          |
//+------------------------------------------------------------------+
string CBrokerHealthMonitor::GetHealthStatusName(ENUM_BROKER_HEALTH_STATUS status) {
    switch (status) {
        case BROKER_HEALTH_EXCELLENT: return "Excellent";
        case BROKER_HEALTH_GOOD: return "Good";
        case BROKER_HEALTH_FAIR: return "Fair";
        case BROKER_HEALTH_POOR: return "Poor";
        case BROKER_HEALTH_CRITICAL: return "Critical";
        case BROKER_HEALTH_UNKNOWN: return "Unknown";
        default: return "Invalid";
    }
}

//+------------------------------------------------------------------+
//| Get execution quality name                                      |
//+------------------------------------------------------------------+
string CBrokerHealthMonitor::GetExecutionQualityName(ENUM_EXECUTION_QUALITY quality) {
    switch (quality) {
        case EXECUTION_EXCELLENT: return "Excellent";
        case EXECUTION_GOOD: return "Good";
        case EXECUTION_FAIR: return "Fair";
        case EXECUTION_POOR: return "Poor";
        case EXECUTION_CRITICAL: return "Critical";
        default: return "Unknown";
    }
}

//+------------------------------------------------------------------+
//| Get metric name                                                 |
//+------------------------------------------------------------------+
string CBrokerHealthMonitor::GetMetricName(ENUM_BROKER_METRIC_TYPE type) {
    switch (type) {
        case BROKER_METRIC_SPREAD: return "Spread";
        case BROKER_METRIC_EXECUTION_SPEED: return "Execution Speed";
        case BROKER_METRIC_SLIPPAGE: return "Slippage";
        case BROKER_METRIC_REQUOTES: return "Requotes";
        case BROKER_METRIC_DISCONNECTIONS: return "Disconnections";
        case BROKER_METRIC_LATENCY: return "Latency";
        case BROKER_METRIC_LIQUIDITY: return "Liquidity";
        case BROKER_METRIC_SWAP_RATES: return "Swap Rates";
        case BROKER_METRIC_MARGIN_CALL: return "Margin Call";
        case BROKER_METRIC_STOP_OUT: return "Stop Out";
        case BROKER_METRIC_TRADING_HOURS: return "Trading Hours";
        case BROKER_METRIC_SERVER_LOAD: return "Server Load";
        default: return "Unknown";
    }
}

//+------------------------------------------------------------------+
//| Get alert level name                                            |
//+------------------------------------------------------------------+
string CBrokerHealthMonitor::GetAlertLevelName(ENUM_ALERT_LEVEL level) {
    switch (level) {
        case ALERT_LEVEL_INFO: return "INFO";
        case ALERT_LEVEL_WARNING: return "WARNING";
        case ALERT_LEVEL_CRITICAL: return "CRITICAL";
        case ALERT_LEVEL_EMERGENCY: return "EMERGENCY";
        default: return "UNKNOWN";
    }
}

//+------------------------------------------------------------------+