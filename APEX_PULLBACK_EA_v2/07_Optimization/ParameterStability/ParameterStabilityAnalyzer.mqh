//+------------------------------------------------------------------+
//|                                    ParameterStabilityAnalyzer.mqh |
//|                                    APEX PULLBACK EA v5.0 FINAL   |
//|                                    Parameter Instability Detection|
//+------------------------------------------------------------------+

#property copyright "APEX PULLBACK EA v5.0 FINAL"
#property version   "1.00"
#property strict

#ifndef APEX_PARAMETER_STABILITY_ANALYZER_MQH_
#define APEX_PARAMETER_STABILITY_ANALYZER_MQH_

#include "../../00_Core/CommonStructs.mqh"



//+------------------------------------------------------------------+
//| Parameter Tracking Structure                                     |
//+------------------------------------------------------------------+
struct ParameterSnapshot {
    datetime Timestamp;          // Thời gian snapshot
    double RiskPercent;          // Risk percentage
    int ATRPeriod;              // ATR period
    double ATRMultiplier;        // ATR multiplier
    int EMAPeriod1;             // EMA period 1
    int EMAPeriod2;             // EMA period 2
    int EMAPeriod3;             // EMA period 3
    double PullbackThreshold;    // Pullback threshold
    double TrendStrength;        // Trend strength threshold
    double VolatilityFilter;     // Volatility filter
    double CorrelationThreshold; // Correlation threshold
    
    // Performance metrics at time of snapshot
    double WinRate;             // Win rate at snapshot time
    double ProfitFactor;        // Profit factor at snapshot time
    double Expectancy;          // Expectancy at snapshot time
    double MaxDrawdown;         // Max drawdown at snapshot time
    
    // Constructor
    ParameterSnapshot() {
        Timestamp = 0;
        RiskPercent = 0.0;
        ATRPeriod = 0;
        ATRMultiplier = 0.0;
        EMAPeriod1 = 0;
        EMAPeriod2 = 0;
        EMAPeriod3 = 0;
        PullbackThreshold = 0.0;
        TrendStrength = 0.0;
        VolatilityFilter = 0.0;
        CorrelationThreshold = 0.0;
        WinRate = 0.0;
        ProfitFactor = 0.0;
        Expectancy = 0.0;
        MaxDrawdown = 0.0;
    ;

//+------------------------------------------------------------------+
//| Parameter Stability Metrics                                      |
//+------------------------------------------------------------------+
struct StabilityMetrics {
    double InstabilityIndex;     // Overall instability index (0-1)
    double ParameterVariance;    // Normalized parameter variance
    double PerformanceCorrelation; // Correlation between param changes and performance
    double TrendStability;       // Stability of parameter trends
    
    // Individual parameter instabilities
    double RiskInstability;
    double ATRInstability;
    double EMAInstability;
    double ThresholdInstability;
    
    // Alert levels
    bool IsUnstable;            // Overall instability flag
    bool RequiresAttention;     // Moderate instability flag
    bool ShouldTriggerCircuitBreaker; // Critical instability flag
    
    datetime LastUpdate;
    
    // Constructor
    StabilityMetrics() {
        InstabilityIndex = 0.0;
        ParameterVariance = 0.0;
        PerformanceCorrelation = 0.0;
        TrendStability = 0.0;
        RiskInstability = 0.0;
        ATRInstability = 0.0;
        EMAInstability = 0.0;
        ThresholdInstability = 0.0;
        IsUnstable = false;
        RequiresAttention = false;
        ShouldTriggerCircuitBreaker = false;
        LastUpdate = 0;
    }
};

//+------------------------------------------------------------------+
//| Parameter Stability Analyzer Class                               |
//+------------------------------------------------------------------+
class CParameterStabilityAnalyzer {
private:
    // Core Components
    EAContext* m_pContext;
    bool m_bInitialized;
    
    // Parameter History
    ParameterSnapshot m_ParameterHistory[];
    int m_iHistorySize;
    int m_iMaxHistorySize;
    
    // Stability Metrics
    StabilityMetrics m_CurrentMetrics;
    
    // Thresholds
    double m_dUnstableThreshold;      // Above this = unstable (0.6)
    double m_dCriticalThreshold;      // Above this = critical (0.8)
    double m_dAttentionThreshold;     // Above this = needs attention (0.4)
    
    // Analysis Parameters
    int m_iMinSamplesForAnalysis;     // Minimum samples needed for analysis
    int m_iAnalysisLookbackPeriod;    // Lookback period for analysis
    
    // Alert Management
    datetime m_LastAlertTime;
    int m_iAlertCooldownMinutes;
    
    // Internal Methods
    void CaptureCurrentParameters(ParameterSnapshot& snapshot);
    double CalculateParameterVariance();
    double CalculatePerformanceCorrelation();
    double CalculateTrendStability();
    double CalculateIndividualInstability(const double values[], int count, double normalizeRange);
    void UpdateStabilityFlags();
    void CheckAndTriggerAlerts();
    
public:
    // Constructor & Destructor
    CParameterStabilityAnalyzer();
    ~CParameterStabilityAnalyzer();
    
    // Initialization
    bool Initialize(EAContext* pContext);
    void Deinitialize();
    void SetThresholds(double unstable, double critical, double attention);
    void SetAnalysisParameters(int minSamples, int lookbackPeriod);
    
    // Core Functionality
    void RecordParameterSnapshot();
    void AnalyzeStability();
    void GenerateStabilityReport(string& report);
    
    // Getters
    StabilityMetrics GetCurrentMetrics() const { return m_CurrentMetrics; }
    double GetInstabilityIndex() const { return m_CurrentMetrics.InstabilityIndex; }
    bool IsSystemUnstable() const { return m_CurrentMetrics.IsUnstable; }
    bool ShouldTriggerCircuitBreaker() const { return m_CurrentMetrics.ShouldTriggerCircuitBreaker; }
    bool RequiresAttention() const { return m_CurrentMetrics.RequiresAttention; }
    
    // Enhanced Stability Analysis
    double CalculateStabilityIndex();
    double CalculateNormalizedChange(double oldValue, double newValue, double maxRange, double minRange);
    void UpdateParameterInstabilityIndex();
    bool IsStrategyStable(double threshold = 0.6);
    
    // Risk Management Integration
    double GetRiskReductionFactor();
    bool ShouldReduceTrading();
    bool ShouldPauseOptimization();
    
    // Utility
    void Reset();
    void GetParameterTrends(double& riskTrend, double& atrTrend, double& emaTrend);
    void GetRecentChanges(int lookbackBars, double& avgChange, double& maxChange);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CParameterStabilityAnalyzer::CParameterStabilityAnalyzer() : 
    m_pContext(NULL),
    m_bInitialized(false),
    m_iHistorySize(0),
    m_iMaxHistorySize(200),
    m_dUnstableThreshold(0.6),
    m_dCriticalThreshold(0.8),
    m_dAttentionThreshold(0.4),
    m_iMinSamplesForAnalysis(10),
    m_iAnalysisLookbackPeriod(50),
    m_LastAlertTime(0),
    m_iAlertCooldownMinutes(30)
{
    // Constructor body is now empty, initialization is done in the initializer list
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CParameterStabilityAnalyzer::~CParameterStabilityAnalyzer() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CParameterStabilityAnalyzer::Initialize(EAContext* pContext) {
    if (pContext == NULL) {
        Print("[ParameterStabilityAnalyzer] ERROR: Context is NULL");
        return false;
    }
    
    m_pContext = pContext;
    
    // Resize array here, after context is confirmed valid
    ArrayResize(m_ParameterHistory, m_iMaxHistorySize);

    m_bInitialized = true;
    
    if (m_pContext.pLogger != NULL) {
        m_pContext.pLogger.LogInfo("ParameterStabilityAnalyzer initialized successfully", __FUNCTION__);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CParameterStabilityAnalyzer::Deinitialize() {
    if (m_bInitialized && m_pContext.pLogger != NULL) {
        m_pContext.pLogger.LogInfo("ParameterStabilityAnalyzer deinitialized", __FUNCTION__);
    }
    
    m_bInitialized = false;
    m_pContext = NULL;
}

//+------------------------------------------------------------------+
//| Set Custom Thresholds                                           |
//+------------------------------------------------------------------+
void CParameterStabilityAnalyzer::SetThresholds(double unstable, double critical, double attention) {
    m_dUnstableThreshold = MathMax(0.1, MathMin(1.0, unstable));
    m_dCriticalThreshold = MathMax(0.1, MathMin(1.0, critical));
    m_dAttentionThreshold = MathMax(0.1, MathMin(1.0, attention));
    
    if (m_bInitialized && m_pContext.pLogger != NULL) {
        string msg = StringFormat("Stability thresholds updated: Attention=%.2f, Unstable=%.2f, Critical=%.2f",
                                m_dAttentionThreshold, m_dUnstableThreshold, m_dCriticalThreshold);
        m_pContext.pLogger.LogInfo(msg, __FUNCTION__);
    }
}

//+------------------------------------------------------------------+
//| Set Analysis Parameters                                          |
//+------------------------------------------------------------------+
void CParameterStabilityAnalyzer::SetAnalysisParameters(int minSamples, int lookbackPeriod) {
    m_iMinSamplesForAnalysis = MathMax(5, minSamples);
    m_iAnalysisLookbackPeriod = MathMax(10, lookbackPeriod);
    
    if (m_bInitialized && m_pContext.pLogger != NULL) {
        string msg = StringFormat("Analysis parameters updated: MinSamples=%d, Lookback=%d",
                                m_iMinSamplesForAnalysis, m_iAnalysisLookbackPeriod);
        m_pContext.pLogger.LogInfo(msg, __FUNCTION__);
    }
}

//+------------------------------------------------------------------+
//| Record Parameter Snapshot                                        |
//+------------------------------------------------------------------+
void CParameterStabilityAnalyzer::RecordParameterSnapshot() {
    if (!m_bInitialized || m_pContext == NULL) return;
    
    ParameterSnapshot snapshot;
    CaptureCurrentParameters(snapshot);
    
    // Add to history
    int index = m_iHistorySize % m_iMaxHistorySize;
    m_ParameterHistory[index] = snapshot;
    
    if (m_iHistorySize < m_iMaxHistorySize) {
        m_iHistorySize++;
    }
    
    if (m_pContext.pLogger != NULL) {
        string msg = StringFormat("Parameter snapshot recorded: Risk=%.2f%%, ATR=%d, EMA=%d/%d/%d",
                                snapshot.RiskPercent, snapshot.ATRPeriod,
                                snapshot.EMAPeriod1, snapshot.EMAPeriod2, snapshot.EMAPeriod3);
        m_pContext.pLogger.LogDebug(msg, __FUNCTION__);
    }
}

//+------------------------------------------------------------------+
//| Capture Current Parameters                                       |
//+------------------------------------------------------------------+
void CParameterStabilityAnalyzer::CaptureCurrentParameters(ParameterSnapshot& snapshot) {
    snapshot.Timestamp = TimeCurrent();
    
    // Capture current parameters from context
    if (m_pContext != NULL) {
        snapshot.RiskPercent = m_pContext.RiskPercent;
        snapshot.ATRPeriod = m_pContext.ATRPeriod;
        snapshot.ATRMultiplier = m_pContext.ATRMultiplier;
        snapshot.EMAPeriod1 = m_pContext.EMAPeriod1;
        snapshot.EMAPeriod2 = m_pContext.EMAPeriod2;
        snapshot.EMAPeriod3 = m_pContext.EMAPeriod3;
        snapshot.PullbackThreshold = m_pContext.PullbackThreshold;
        snapshot.TrendStrength = m_pContext.TrendStrength;
        snapshot.VolatilityFilter = m_pContext.VolatilityFilter;
        snapshot.CorrelationThreshold = m_pContext.CorrelationThreshold;
        
        // Capture performance metrics if PerformanceTracker is available
        if (m_pContext.pPerformanceTracker != NULL) {
            snapshot.WinRate = m_pContext.pPerformanceTracker.GetWinRate();
            snapshot.ProfitFactor = m_pContext.pPerformanceTracker.GetProfitFactor();
            snapshot.Expectancy = m_pContext.pPerformanceTracker.GetExpectancy();
            snapshot.MaxDrawdown = m_pContext.pPerformanceTracker.GetMaxDrawdown();
        }
    }
}

//+------------------------------------------------------------------+
//| Analyze Stability                                                |
//+------------------------------------------------------------------+
void CParameterStabilityAnalyzer::AnalyzeStability() {
    if (!m_bInitialized || m_iHistorySize < m_iMinSamplesForAnalysis) {
        m_CurrentMetrics.InstabilityIndex = 0.0;
        return;
    }
    
    // Calculate individual components
    m_CurrentMetrics.ParameterVariance = CalculateParameterVariance();
    m_CurrentMetrics.PerformanceCorrelation = CalculatePerformanceCorrelation();
    m_CurrentMetrics.TrendStability = CalculateTrendStability();
    
    // Calculate overall instability index (weighted average)
    double weights[] = {0.4, 0.3, 0.3}; // Variance, Correlation, Trend
    double components[] = {
        m_CurrentMetrics.ParameterVariance,
        MathAbs(m_CurrentMetrics.PerformanceCorrelation), // Use absolute value
        1.0 - m_CurrentMetrics.TrendStability // Invert trend stability
    };
    
    double weightedSum = 0.0;
    for (int i = 0; i < 3; i++) {
        weightedSum += components[i] * weights[i];
    }
    
    m_CurrentMetrics.InstabilityIndex = MathMax(0.0, MathMin(1.0, weightedSum));
    
    // Update flags
    UpdateStabilityFlags();
    
    // Update timestamp
    m_CurrentMetrics.LastUpdate = TimeCurrent();
    
    // Check for alerts
    CheckAndTriggerAlerts();
    
    if (m_pContext.pLogger != NULL) {
        string msg = StringFormat("Stability Analysis: Index=%.3f, Variance=%.3f, Correlation=%.3f, Trend=%.3f",
                                m_CurrentMetrics.InstabilityIndex,
                                m_CurrentMetrics.ParameterVariance,
                                m_CurrentMetrics.PerformanceCorrelation,
                                m_CurrentMetrics.TrendStability);
        m_pContext.pLogger.LogInfo(msg, __FUNCTION__);
    }
}

//+------------------------------------------------------------------+
//| Calculate Parameter Variance                                     |
//+------------------------------------------------------------------+
double CParameterStabilityAnalyzer::CalculateParameterVariance() {
    int lookback = MathMin(m_iAnalysisLookbackPeriod, m_iHistorySize);
    if (lookback < 2) return 0.0;
    
    // Extract parameter arrays for analysis
    double riskValues[];
    double atrValues[];
    double emaValues[];
    double thresholdValues[];
    
    ArrayResize(riskValues, lookback);
    ArrayResize(atrValues, lookback);
    ArrayResize(emaValues, lookback);
    ArrayResize(thresholdValues, lookback);
    
    for (int i = 0; i < lookback; i++) {
        int index = (m_iHistorySize - lookback + i) % m_iMaxHistorySize;
        riskValues[i] = m_ParameterHistory[index].RiskPercent;
        atrValues[i] = m_ParameterHistory[index].ATRPeriod;
        emaValues[i] = (m_ParameterHistory[index].EMAPeriod1 + 
                       m_ParameterHistory[index].EMAPeriod2 + 
                       m_ParameterHistory[index].EMAPeriod3) / 3.0;
        thresholdValues[i] = m_ParameterHistory[index].PullbackThreshold;
    }
    
    // Calculate individual instabilities
    m_CurrentMetrics.RiskInstability = CalculateIndividualInstability(riskValues, lookback, 5.0); // 5% range
    m_CurrentMetrics.ATRInstability = CalculateIndividualInstability(atrValues, lookback, 50.0); // 50 period range
    m_CurrentMetrics.EMAInstability = CalculateIndividualInstability(emaValues, lookback, 100.0); // 100 period range
    m_CurrentMetrics.ThresholdInstability = CalculateIndividualInstability(thresholdValues, lookback, 1.0); // 1.0 range
    
    // Return weighted average
    double weights[] = {0.3, 0.25, 0.25, 0.2};
    double instabilities[] = {
        m_CurrentMetrics.RiskInstability,
        m_CurrentMetrics.ATRInstability,
        m_CurrentMetrics.EMAInstability,
        m_CurrentMetrics.ThresholdInstability
    };
    
    double weightedVariance = 0.0;
    for (int i = 0; i < 4; i++) {
        weightedVariance += instabilities[i] * weights[i];
    }
    
    return weightedVariance;
}

//+------------------------------------------------------------------+
//| Calculate Individual Parameter Instability                       |
//+------------------------------------------------------------------+
double CParameterStabilityAnalyzer::CalculateIndividualInstability(const double values[], int count, double normalizeRange) {
    if (count < 2) return 0.0;
    
    // Calculate mean
    double sum = 0.0;
    for (int i = 0; i < count; i++) {
        sum += values[i];
    }
    double mean = sum / count;
    
    // Calculate variance
    double variance = 0.0;
    for (int i = 0; i < count; i++) {
        double diff = values[i] - mean;
        variance += diff * diff;
    }
    variance /= count;
    
    // Normalize by range and return as instability score (0-1)
    double normalizedVariance = MathSqrt(variance) / normalizeRange;
    return MathMin(1.0, normalizedVariance);
}

//+------------------------------------------------------------------+
//| Calculate Performance Correlation                                |
//+------------------------------------------------------------------+
double CParameterStabilityAnalyzer::CalculatePerformanceCorrelation() {
    int lookback = MathMin(m_iAnalysisLookbackPeriod, m_iHistorySize);
    if (lookback < 5) return 0.0;
    
    // Calculate correlation between parameter changes and performance changes
    double paramChanges[];
    double perfChanges[];
    
    ArrayResize(paramChanges, lookback - 1);
    ArrayResize(perfChanges, lookback - 1);
    
    for (int i = 1; i < lookback; i++) {
        int currentIndex = (m_iHistorySize - lookback + i) % m_iMaxHistorySize;
        int previousIndex = (m_iHistorySize - lookback + i - 1) % m_iMaxHistorySize;
        
        // Calculate parameter change magnitude
        double riskChange = MathAbs(m_ParameterHistory[currentIndex].RiskPercent - 
                                  m_ParameterHistory[previousIndex].RiskPercent);
        double atrChange = MathAbs(m_ParameterHistory[currentIndex].ATRPeriod - 
                                 m_ParameterHistory[previousIndex].ATRPeriod);
        
        paramChanges[i-1] = riskChange + atrChange / 10.0; // Normalize ATR change
        
        // Calculate performance change
        double perfChange = m_ParameterHistory[currentIndex].WinRate - 
                          m_ParameterHistory[previousIndex].WinRate;
        perfChanges[i-1] = perfChange;
    }
    
    // Calculate correlation coefficient
    double correlation = 0.0;
    if (lookback > 5) {
        // Simple correlation calculation
        double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0, sumY2 = 0;
        int n = lookback - 1;
        
        for (int i = 0; i < n; i++) {
            sumX += paramChanges[i];
            sumY += perfChanges[i];
            sumXY += paramChanges[i] * perfChanges[i];
            sumX2 += paramChanges[i] * paramChanges[i];
            sumY2 += perfChanges[i] * perfChanges[i];
        }
        
        double denominator = MathSqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY));
        if (denominator > 0) {
            correlation = (n * sumXY - sumX * sumY) / denominator;
        }
    }
    
    return correlation;
}

//+------------------------------------------------------------------+
//| Calculate Trend Stability                                        |
//+------------------------------------------------------------------+
double CParameterStabilityAnalyzer::CalculateTrendStability() {
    int lookback = MathMin(m_iAnalysisLookbackPeriod, m_iHistorySize);
    if (lookback < 5) return 1.0; // Assume stable if not enough data
    
    // Calculate trend consistency for key parameters
    double riskTrend = 0.0;
    double atrTrend = 0.0;
    
    // Simple trend calculation using first and last values
    int firstIndex = (m_iHistorySize - lookback) % m_iMaxHistorySize;
    int lastIndex = (m_iHistorySize - 1) % m_iMaxHistorySize;
    
    double riskChange = m_ParameterHistory[lastIndex].RiskPercent - 
                       m_ParameterHistory[firstIndex].RiskPercent;
    double atrChange = m_ParameterHistory[lastIndex].ATRPeriod - 
                      m_ParameterHistory[firstIndex].ATRPeriod;
    
    // Calculate trend consistency (how much parameters oscillate around trend)
    double riskOscillation = 0.0;
    double atrOscillation = 0.0;
    
    for (int i = 1; i < lookback - 1; i++) {
        int index = (m_iHistorySize - lookback + i) % m_iMaxHistorySize;
        
        // Expected value based on linear trend
        double progress = (double)i / (lookback - 1);
        double expectedRisk = m_ParameterHistory[firstIndex].RiskPercent + riskChange * progress;
        double expectedATR = m_ParameterHistory[firstIndex].ATRPeriod + atrChange * progress;
        
        // Actual oscillation from trend
        riskOscillation += MathAbs(m_ParameterHistory[index].RiskPercent - expectedRisk);
        atrOscillation += MathAbs(m_ParameterHistory[index].ATRPeriod - expectedATR);
    }
    
    // Normalize oscillations
    riskOscillation /= (lookback - 2);
    atrOscillation /= (lookback - 2);
    
    // Convert to stability score (lower oscillation = higher stability)
    double riskStability = MathMax(0.0, 1.0 - riskOscillation / 2.0); // Normalize by 2%
    double atrStability = MathMax(0.0, 1.0 - atrOscillation / 10.0); // Normalize by 10 periods
    
    return (riskStability + atrStability) / 2.0;
}

//+------------------------------------------------------------------+
//| Update Stability Flags                                          |
//+------------------------------------------------------------------+
void CParameterStabilityAnalyzer::UpdateStabilityFlags() {
    m_CurrentMetrics.RequiresAttention = (m_CurrentMetrics.InstabilityIndex >= m_dAttentionThreshold);
    m_CurrentMetrics.IsUnstable = (m_CurrentMetrics.InstabilityIndex >= m_dUnstableThreshold);
    m_CurrentMetrics.ShouldTriggerCircuitBreaker = (m_CurrentMetrics.InstabilityIndex >= m_dCriticalThreshold);
}

//+------------------------------------------------------------------+
//| Check and Trigger Alerts                                        |
//+------------------------------------------------------------------+
void CParameterStabilityAnalyzer::CheckAndTriggerAlerts() {
    bool shouldAlert = false;
    string alertLevel = "";
    
    if (m_CurrentMetrics.ShouldTriggerCircuitBreaker) {
        shouldAlert = true;
        alertLevel = "CRITICAL";
    } else if (m_CurrentMetrics.IsUnstable) {
        shouldAlert = true;
        alertLevel = "WARNING";
    } else if (m_CurrentMetrics.RequiresAttention) {
        shouldAlert = true;
        alertLevel = "INFO";
    }
    
    // Check cooldown
    if (shouldAlert && (TimeCurrent() - m_LastAlertTime) >= (m_iAlertCooldownMinutes * 60)) {
        string alertMsg = StringFormat("PARAMETER STABILITY ALERT [%s]: Instability Index=%.3f",
                                     alertLevel, m_CurrentMetrics.InstabilityIndex);
        
        if (m_pContext.pLogger != NULL) {
            if (alertLevel == "CRITICAL") {
                m_pContext.pLogger.LogError(alertMsg, __FUNCTION__);
            } else if (alertLevel == "WARNING") {
                m_pContext.pLogger.LogWarning(alertMsg, __FUNCTION__);
            } else {
                m_pContext.pLogger.LogInfo(alertMsg, __FUNCTION__);
            }
        }
        
        // Trigger circuit breaker for critical alerts
        if (alertLevel == "CRITICAL" && m_pContext.pCircuitBreaker != NULL) {
            m_pContext.pCircuitBreaker.TriggerBreaker(TRIP_STABILITY_DEGRADATION, alertMsg);
        }
        
        m_LastAlertTime = TimeCurrent();
    }
}

//+------------------------------------------------------------------+
//| Calculate Stability Index (Enhanced v14 method)                 |
//+------------------------------------------------------------------+
double CParameterStabilityAnalyzer::CalculateStabilityIndex() {
    if (!m_bInitialized || m_iHistorySize < 2) return 1.0;
    
    AnalyzeStability();
    return 1.0 - m_CurrentMetrics.InstabilityIndex; // Convert instability to stability
}

//+------------------------------------------------------------------+
//| Calculate Normalized Change                                      |
//+------------------------------------------------------------------+
double CParameterStabilityAnalyzer::CalculateNormalizedChange(double oldValue, double newValue, double maxRange, double minRange) {
    if (maxRange <= minRange || oldValue == 0) return 0.0;
    
    double change = MathAbs(newValue - oldValue);
    double range = maxRange - minRange;
    
    return MathMin(1.0, change / range);
}

//+------------------------------------------------------------------+
//| Update Parameter Instability Index                              |
//+------------------------------------------------------------------+
void CParameterStabilityAnalyzer::UpdateParameterInstabilityIndex() {
    if (!m_bInitialized) return;
    
    AnalyzeStability();
    
    // Update context with current stability status
    if (m_pContext != NULL) {
        m_pContext.ParameterStabilityIndex = 1.0 - m_CurrentMetrics.InstabilityIndex;
        m_pContext.IsParameterStabilityDegraded = m_CurrentMetrics.IsUnstable;
    }
}

//+------------------------------------------------------------------+
//| Check if Strategy is Stable                                     |
//+------------------------------------------------------------------+
bool CParameterStabilityAnalyzer::IsStrategyStable(double threshold = 0.6) {
    if (!m_bInitialized) return true;
    
    double currentStability = CalculateStabilityIndex();
    return currentStability >= threshold;
}

//+------------------------------------------------------------------+
//| Get Risk Reduction Factor                                        |
//+------------------------------------------------------------------+
double CParameterStabilityAnalyzer::GetRiskReductionFactor() {
    if (!m_bInitialized) return 1.0;
    
    if (m_CurrentMetrics.ShouldTriggerCircuitBreaker) {
        return 0.1; // Reduce to 10% of normal risk
    } else if (m_CurrentMetrics.IsUnstable) {
        return 0.5; // Reduce to 50% of normal risk
    } else if (m_CurrentMetrics.RequiresAttention) {
        return 0.8; // Reduce to 80% of normal risk
    }
    
    return 1.0; // No reduction
}

//+------------------------------------------------------------------+
//| Should Reduce Trading                                            |
//+------------------------------------------------------------------+
bool CParameterStabilityAnalyzer::ShouldReduceTrading() {
    return m_bInitialized && m_CurrentMetrics.IsUnstable;
}

//+------------------------------------------------------------------+
//| Should Pause Optimization                                        |
//+------------------------------------------------------------------+
bool CParameterStabilityAnalyzer::ShouldPauseOptimization() {
    return m_bInitialized && m_CurrentMetrics.ShouldTriggerCircuitBreaker;
}

//+------------------------------------------------------------------+
//| Generate Stability Report                                        |
//+------------------------------------------------------------------+
void CParameterStabilityAnalyzer::GenerateStabilityReport(string& report) {
    report = "\n=== PARAMETER STABILITY REPORT ===\n";
    report += StringFormat("Instability Index: %.3f\n", m_CurrentMetrics.InstabilityIndex);
    report += StringFormat("Parameter Variance: %.3f\n", m_CurrentMetrics.ParameterVariance);
    report += StringFormat("Performance Correlation: %.3f\n", m_CurrentMetrics.PerformanceCorrelation);
    report += StringFormat("Trend Stability: %.3f\n", m_CurrentMetrics.TrendStability);
    
    report += "\n--- Individual Parameter Instabilities ---\n";
    report += StringFormat("Risk Instability: %.3f\n", m_CurrentMetrics.RiskInstability);
    report += StringFormat("ATR Instability: %.3f\n", m_CurrentMetrics.ATRInstability);
    report += StringFormat("EMA Instability: %.3f\n", m_CurrentMetrics.EMAInstability);
    report += StringFormat("Threshold Instability: %.3f\n", m_CurrentMetrics.ThresholdInstability);
    
    report += "\n--- Status Flags ---\n";
    report += StringFormat("Requires Attention: %s\n", m_CurrentMetrics.RequiresAttention ? "YES" : "NO");
    report += StringFormat("Is Unstable: %s\n", m_CurrentMetrics.IsUnstable ? "YES" : "NO");
    report += StringFormat("Circuit Breaker: %s\n", m_CurrentMetrics.ShouldTriggerCircuitBreaker ? "YES" : "NO");
    
    report += "\n--- Risk Management ---\n";
    report += StringFormat("Risk Reduction Factor: %.2f\n", GetRiskReductionFactor());
    report += StringFormat("Should Reduce Trading: %s\n", ShouldReduceTrading() ? "YES" : "NO");
    report += StringFormat("Should Pause Optimization: %s\n", ShouldPauseOptimization() ? "YES" : "NO");
    
    report += StringFormat("\nSamples in History: %d/%d\n", m_iHistorySize, m_iMaxHistorySize);
    report += StringFormat("Last Update: %s\n", TimeToString(m_CurrentMetrics.LastUpdate));
}

//+------------------------------------------------------------------+
//| Reset                                                            |
//+------------------------------------------------------------------+
void CParameterStabilityAnalyzer::Reset() {
    m_CurrentMetrics = StabilityMetrics();
    m_iHistorySize = 0;
    m_LastAlertTime = 0;
    
    // Clear history array
    for (int i = 0; i < m_iMaxHistorySize; i++) {
        m_ParameterHistory[i] = ParameterSnapshot();
    }
    
    if (m_bInitialized && m_pContext.pLogger != NULL) {
        m_pContext.pLogger.LogInfo("ParameterStabilityAnalyzer reset completed", __FUNCTION__);
    }
}

//+------------------------------------------------------------------+
//| Get Parameter Trends                                             |
//+------------------------------------------------------------------+
void CParameterStabilityAnalyzer::GetParameterTrends(double& riskTrend, double& atrTrend, double& emaTrend) {
    riskTrend = 0.0;
    atrTrend = 0.0;
    emaTrend = 0.0;
    
    if (!m_bInitialized || m_iHistorySize < 5) return;
    
    int lookback = MathMin(20, m_iHistorySize);
    int firstIndex = (m_iHistorySize - lookback) % m_iMaxHistorySize;
    int lastIndex = (m_iHistorySize - 1) % m_iMaxHistorySize;
    
    // Calculate trends as percentage change
    if (m_ParameterHistory[firstIndex].RiskPercent > 0) {
        riskTrend = (m_ParameterHistory[lastIndex].RiskPercent - 
                    m_ParameterHistory[firstIndex].RiskPercent) / 
                    m_ParameterHistory[firstIndex].RiskPercent * 100.0;
    }
    
    if (m_ParameterHistory[firstIndex].ATRPeriod > 0) {
        atrTrend = (m_ParameterHistory[lastIndex].ATRPeriod - 
                   m_ParameterHistory[firstIndex].ATRPeriod) / 
                   (double)m_ParameterHistory[firstIndex].ATRPeriod * 100.0;
    }
    
    double firstEMA = (m_ParameterHistory[firstIndex].EMAPeriod1 + 
                      m_ParameterHistory[firstIndex].EMAPeriod2 + 
                      m_ParameterHistory[firstIndex].EMAPeriod3) / 3.0;
    double lastEMA = (m_ParameterHistory[lastIndex].EMAPeriod1 + 
                     m_ParameterHistory[lastIndex].EMAPeriod2 + 
                     m_ParameterHistory[lastIndex].EMAPeriod3) / 3.0;
    
    if (firstEMA > 0) {
        emaTrend = (lastEMA - firstEMA) / firstEMA * 100.0;
    }
}

//+------------------------------------------------------------------+
//| Get Recent Changes                                               |
//+------------------------------------------------------------------+
void CParameterStabilityAnalyzer::GetRecentChanges(int lookbackBars, double& avgChange, double& maxChange) {
    avgChange = 0.0;
    maxChange = 0.0;
    
    if (!m_bInitialized || m_iHistorySize < 2) return;
    
    int lookback = MathMin(lookbackBars, m_iHistorySize - 1);
    double totalChange = 0.0;
    
    for (int i = 1; i <= lookback; i++) {
        int currentIndex = (m_iHistorySize - i) % m_iMaxHistorySize;
        int previousIndex = (m_iHistorySize - i - 1) % m_iMaxHistorySize;
        
        // Calculate total parameter change magnitude
        double riskChange = MathAbs(m_ParameterHistory[currentIndex].RiskPercent - 
                                  m_ParameterHistory[previousIndex].RiskPercent);
        double atrChange = MathAbs(m_ParameterHistory[currentIndex].ATRPeriod - 
                                 m_ParameterHistory[previousIndex].ATRPeriod) / 10.0; // Normalize
        
        double totalParamChange = riskChange + atrChange;
        totalChange += totalParamChange;
        maxChange = MathMax(maxChange, totalParamChange);
    }
    
    avgChange = totalChange / lookback;
}

} // namespace v5
} // namespace ApexPullback

#endif // APEX_PARAMETER_STABILITY_ANALYZER_MQH_