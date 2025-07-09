//+------------------------------------------------------------------+
//|                                                 RiskAnalyzer.mqh |
//|                                    APEX Pullback EA v5.0 FINAL   |
//|                                        Advanced Risk Analyzer    |
//+------------------------------------------------------------------+
#property copyright "APEX Trading Systems"
#property version   "5.00"
#property strict

#include "../../01_Core/CommonStructs.mqh"

//+------------------------------------------------------------------+
//| Risk metrics structure                                           |
//+------------------------------------------------------------------+
struct SRiskMetrics {
    // Portfolio risk
    double PortfolioRisk;
    double MaxPortfolioRisk;
    double RiskPerTrade;
    double MaxRiskPerTrade;
    
    // Drawdown analysis
    double CurrentDrawdown;
    double MaxDrawdown;
    double MaxDrawdownPercent;
    double DrawdownDuration;
    double AverageDrawdown;
    
    // Volatility metrics
    double EquityVolatility;
    double ReturnsVolatility;
    double VaR95;
    double VaR99;
    double CVaR95;
    double CVaR99;
    
    // Risk ratios
    double SharpeRatio;
    double SortinoRatio;
    double CalmarRatio;
    double SterlingRatio;
    double BurkeRatio;
    
    // Correlation analysis
    double MarketCorrelation;
    double BetaCoefficient;
    double AlphaCoefficient;
    
    // Risk events
    int RiskEvents;
    int CriticalRiskEvents;
    datetime LastRiskEvent;
    
    // Risk limits
    bool RiskLimitBreached;
    ENUM_RISK_LEVEL CurrentRiskLevel;
    string RiskWarnings[];
    
    datetime LastUpdateTime;
};

//+------------------------------------------------------------------+
//| Risk event structure                                            |
//+------------------------------------------------------------------+
struct SRiskEvent {
    datetime Time;
    ENUM_RISK_LEVEL Level;
    string Description;
    double Value;
    double Threshold;
    string Action;
};

//+------------------------------------------------------------------+
//| Risk Analyzer Class                                             |
//+------------------------------------------------------------------+
class CRiskAnalyzer {
private:
    EAContext* m_pContext;
    SRiskMetrics m_Metrics;
    SRiskEvent m_RiskEvents[];
    int m_iEventCount;
    
    // Historical data
    double m_dEquityHistory[];
    double m_dReturnsHistory[];
    datetime m_EquityTimes[];
    int m_iHistoryCount;
    
    // Risk parameters
    double m_dMaxPortfolioRisk;
    double m_dMaxTradeRisk;
    double m_dVaRConfidence95;
    double m_dVaRConfidence99;
    int m_iLookbackPeriod;
    
    // Configuration
    bool m_bInitialized;
    bool m_bRealTimeMonitoring;
    string m_sReportPath;
    
    // Internal calculations
    double m_dLastEquity;
    double m_dEquityPeak;
    datetime m_DrawdownStartTime;
    bool m_bInDrawdown;
    
public:
    CRiskAnalyzer();
    ~CRiskAnalyzer();
    
    // Core methods
    bool Initialize(EAContext* context);
    void Deinitialize();
    void Reset();
    
    // Risk monitoring
    void UpdateRiskMetrics(const double currentEquity);
    void AnalyzePortfolioRisk();
    void CheckRiskLimits();
    void MonitorDrawdown(const double currentEquity);
    
    // Risk calculations
    double CalculateVaR(const double confidence);
    double CalculateCVaR(const double confidence);
    double CalculateVolatility();
    double CalculateSharpeRatio();
    double CalculateSortinoRatio();
    double CalculateMaxDrawdown();
    
    // Risk events
    void LogRiskEvent(const ENUM_RISK_LEVEL level, const string description, 
                      const double value, const double threshold, const string action = "");
    bool IsRiskLimitBreached() const;
    ENUM_RISK_LEVEL GetCurrentRiskLevel() const;
    
    // Getters
    SRiskMetrics GetRiskMetrics() const { return m_Metrics; }
    double GetPortfolioRisk() const { return m_Metrics.PortfolioRisk; }
    double GetMaxDrawdown() const { return m_Metrics.MaxDrawdown; }
    double GetVaR95() const { return m_Metrics.VaR95; }
    double GetSharpeRatio() const { return m_Metrics.SharpeRatio; }
    ENUM_RISK_LEVEL GetRiskLevel() const { return m_Metrics.CurrentRiskLevel; }
    
    // Reporting
    string GetRiskReport() const;
    string GetDetailedRiskReport() const;
    string GetRiskWarnings() const;
    bool ExportRiskReport(const string filename) const;
    
    // Risk management recommendations
    string GetRiskRecommendations() const;
    double GetRecommendedPositionSize(const double stopLoss) const;
    bool ShouldReduceRisk() const;
    bool ShouldStopTrading() const;
    
private:
    // Internal calculations
    void CalculateBasicRiskMetrics();
    void CalculateAdvancedRiskMetrics();
    void CalculateRiskRatios();
    void UpdateEquityHistory(const double equity);
    void CalculateReturns();
    double CalculateDownsideDeviation() const;
    double CalculateStandardDeviation(const double data[], const int count) const;
    
    // Risk level assessment
    ENUM_RISK_LEVEL AssessRiskLevel() const;
    void UpdateRiskWarnings();
    
    // Utility methods
    string FormatRiskValue(const double value) const;
    string FormatPercentage(const double value) const;
    void LogRiskAnalysisEvent(const string event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CRiskAnalyzer::CRiskAnalyzer() {
    m_pContext = NULL;
    m_bInitialized = false;
    m_bRealTimeMonitoring = true;
    m_iEventCount = 0;
    m_iHistoryCount = 0;
    
    // Default risk parameters
    m_dMaxPortfolioRisk = 20.0; // 20% max portfolio risk
    m_dMaxTradeRisk = 2.0;      // 2% max risk per trade
    m_dVaRConfidence95 = 0.95;
    m_dVaRConfidence99 = 0.99;
    m_iLookbackPeriod = 252;    // 1 year of trading days
    
    // Initialize metrics
    ZeroMemory(m_Metrics);
    m_Metrics.CurrentRiskLevel = RISK_LEVEL_LOW;
    m_Metrics.LastUpdateTime = TimeCurrent();
    
    m_dLastEquity = 0.0;
    m_dEquityPeak = 0.0;
    m_DrawdownStartTime = 0;
    m_bInDrawdown = false;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CRiskAnalyzer::~CRiskAnalyzer() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize risk analyzer                                        |
//+------------------------------------------------------------------+
bool CRiskAnalyzer::Initialize(EAContext* context) {
    if (context == NULL) {
        Print("[RISK ANALYZER ERROR] Context is NULL");
        return false;
    }
    
    m_pContext = context;
    
    // Set report path
    m_sReportPath = "Reports\\Risk\\";
    
    // Initialize arrays
    ArrayResize(m_RiskEvents, 1000);
    ArrayResize(m_dEquityHistory, m_iLookbackPeriod);
    ArrayResize(m_dReturnsHistory, m_iLookbackPeriod);
    ArrayResize(m_EquityTimes, m_iLookbackPeriod);
    ArrayResize(m_Metrics.RiskWarnings, 10);
    
    // Get initial equity
    m_dLastEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    m_dEquityPeak = m_dLastEquity;
    
    // Reset metrics
    Reset();
    
    m_bInitialized = true;
    
    if (m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo("RiskAnalyzer initialized successfully", __FUNCTION__);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize risk analyzer                                      |
//+------------------------------------------------------------------+
void CRiskAnalyzer::Deinitialize() {
    if (m_bInitialized && m_pContext != NULL && m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo(GetRiskReport(), __FUNCTION__);
        m_pContext->pLogger->LogInfo("RiskAnalyzer deinitialized", __FUNCTION__);
    }
    
    m_bInitialized = false;
    m_pContext = NULL;
}

//+------------------------------------------------------------------+
//| Reset all risk metrics                                         |
//+------------------------------------------------------------------+
void CRiskAnalyzer::Reset() {
    ZeroMemory(m_Metrics);
    m_Metrics.CurrentRiskLevel = RISK_LEVEL_LOW;
    m_Metrics.LastUpdateTime = TimeCurrent();
    
    m_iEventCount = 0;
    m_iHistoryCount = 0;
    
    ArrayResize(m_RiskEvents, 0);
    ArrayResize(m_dEquityHistory, 0);
    ArrayResize(m_dReturnsHistory, 0);
    ArrayResize(m_EquityTimes, 0);
    ArrayResize(m_Metrics.RiskWarnings, 0);
    
    m_dLastEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    m_dEquityPeak = m_dLastEquity;
    m_DrawdownStartTime = 0;
    m_bInDrawdown = false;
    
    if (m_bInitialized && m_pContext != NULL && m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo("RiskAnalyzer reset completed", __FUNCTION__);
    }
}

//+------------------------------------------------------------------+
//| Update risk metrics                                            |
//+------------------------------------------------------------------+
void CRiskAnalyzer::UpdateRiskMetrics(const double currentEquity) {
    if (!m_bInitialized) return;
    
    // Update equity history
    UpdateEquityHistory(currentEquity);
    
    // Monitor drawdown
    MonitorDrawdown(currentEquity);
    
    // Calculate risk metrics
    CalculateBasicRiskMetrics();
    CalculateAdvancedRiskMetrics();
    CalculateRiskRatios();
    
    // Assess risk level
    m_Metrics.CurrentRiskLevel = AssessRiskLevel();
    
    // Update warnings
    UpdateRiskWarnings();
    
    // Check risk limits
    CheckRiskLimits();
    
    m_Metrics.LastUpdateTime = TimeCurrent();
    m_dLastEquity = currentEquity;
}

//+------------------------------------------------------------------+
//| Monitor drawdown                                               |
//+------------------------------------------------------------------+
void CRiskAnalyzer::MonitorDrawdown(const double currentEquity) {
    // Update equity peak
    if (currentEquity > m_dEquityPeak) {
        m_dEquityPeak = currentEquity;
        
        // End drawdown period if we were in one
        if (m_bInDrawdown) {
            m_bInDrawdown = false;
            double durationHours = (double)(TimeCurrent() - m_DrawdownStartTime) / 3600.0;
            LogRiskAnalysisEvent(StringFormat("Drawdown recovery completed. Duration: %.1f hours", durationHours));
        }
    }
    
    // Calculate current drawdown
    m_Metrics.CurrentDrawdown = m_dEquityPeak - currentEquity;
    
    // Check if entering drawdown
    if (!m_bInDrawdown && m_Metrics.CurrentDrawdown > 0) {
        m_bInDrawdown = true;
        m_DrawdownStartTime = TimeCurrent();
        LogRiskAnalysisEvent("Drawdown period started", LOG_LEVEL_WARNING);
    }
    
    // Update max drawdown
    if (m_Metrics.CurrentDrawdown > m_Metrics.MaxDrawdown) {
        m_Metrics.MaxDrawdown = m_Metrics.CurrentDrawdown;
        if (m_dEquityPeak > 0) {
            m_Metrics.MaxDrawdownPercent = (m_Metrics.MaxDrawdown / m_dEquityPeak) * 100.0;
        }
        
        // Log significant drawdown
        if (m_Metrics.MaxDrawdownPercent > 10.0) {
            LogRiskEvent(RISK_LEVEL_HIGH, "Significant drawdown detected", 
                        m_Metrics.MaxDrawdownPercent, 10.0, "Monitor closely");
        }
    }
    
    // Update drawdown duration
    if (m_bInDrawdown) {
        m_Metrics.DrawdownDuration = (double)(TimeCurrent() - m_DrawdownStartTime) / 3600.0; // in hours
    }
}

//+------------------------------------------------------------------+
//| Calculate basic risk metrics                                   |
//+------------------------------------------------------------------+
void CRiskAnalyzer::CalculateBasicRiskMetrics() {
    if (m_iHistoryCount < 2) return;
    
    // Calculate returns
    CalculateReturns();
    
    // Portfolio risk (current drawdown as % of peak)
    m_Metrics.PortfolioRisk = (m_dEquityPeak > 0) ? 
                             (m_Metrics.CurrentDrawdown / m_dEquityPeak) * 100.0 : 0.0;
    
    // Update max portfolio risk
    if (m_Metrics.PortfolioRisk > m_Metrics.MaxPortfolioRisk) {
        m_Metrics.MaxPortfolioRisk = m_Metrics.PortfolioRisk;
    }
    
    // Equity volatility
    m_Metrics.EquityVolatility = CalculateStandardDeviation(m_dEquityHistory, m_iHistoryCount);
    
    // Returns volatility
    if (ArraySize(m_dReturnsHistory) > 1) {
        m_Metrics.ReturnsVolatility = CalculateStandardDeviation(m_dReturnsHistory, ArraySize(m_dReturnsHistory));
    }
    
    // VaR calculations
    m_Metrics.VaR95 = CalculateVaR(m_dVaRConfidence95);
    m_Metrics.VaR99 = CalculateVaR(m_dVaRConfidence99);
    
    // CVaR calculations
    m_Metrics.CVaR95 = CalculateCVaR(m_dVaRConfidence95);
    m_Metrics.CVaR99 = CalculateCVaR(m_dVaRConfidence99);
}

//+------------------------------------------------------------------+
//| Calculate Value at Risk                                        |
//+------------------------------------------------------------------+
double CRiskAnalyzer::CalculateVaR(const double confidence) {
    if (ArraySize(m_dReturnsHistory) < 10) return 0.0;
    
    // Sort returns for percentile calculation
    double sortedReturns[];
    ArrayCopy(sortedReturns, m_dReturnsHistory);
    ArraySort(sortedReturns);
    
    int size = ArraySize(sortedReturns);
    int index = (int)((1.0 - confidence) * size);
    
    if (index >= 0 && index < size) {
        return MathAbs(sortedReturns[index]);
    }
    
    return 0.0;
}

//+------------------------------------------------------------------+
//| Calculate Conditional Value at Risk                            |
//+------------------------------------------------------------------+
double CRiskAnalyzer::CalculateCVaR(const double confidence) {
    if (ArraySize(m_dReturnsHistory) < 10) return 0.0;
    
    // Sort returns for percentile calculation
    double sortedReturns[];
    ArrayCopy(sortedReturns, m_dReturnsHistory);
    ArraySort(sortedReturns);
    
    int size = ArraySize(sortedReturns);
    int cutoffIndex = (int)((1.0 - confidence) * size);
    
    if (cutoffIndex <= 0) return 0.0;
    
    // Calculate average of worst returns
    double sum = 0.0;
    for (int i = 0; i < cutoffIndex; i++) {
        sum += sortedReturns[i];
    }
    
    return MathAbs(sum / cutoffIndex);
}

//+------------------------------------------------------------------+
//| Calculate risk ratios                                          |
//+------------------------------------------------------------------+
void CRiskAnalyzer::CalculateRiskRatios() {
    if (m_iHistoryCount < 10) return;
    
    // Sharpe Ratio
    m_Metrics.SharpeRatio = CalculateSharpeRatio();
    
    // Sortino Ratio
    m_Metrics.SortinoRatio = CalculateSortinoRatio();
    
    // Calmar Ratio
    if (m_Metrics.MaxDrawdown > 0) {
        double annualReturn = 0.0; // Calculate from equity history
        if (m_iHistoryCount > 1) {
            double totalReturn = (m_dEquityHistory[m_iHistoryCount-1] / m_dEquityHistory[0]) - 1.0;
            annualReturn = totalReturn * 252.0 / m_iHistoryCount; // Annualized
        }
        m_Metrics.CalmarRatio = annualReturn / (m_Metrics.MaxDrawdown / m_dEquityHistory[0] * 100.0);
    }
}

//+------------------------------------------------------------------+
//| Calculate Sharpe ratio                                         |
//+------------------------------------------------------------------+
double CRiskAnalyzer::CalculateSharpeRatio() {
    if (ArraySize(m_dReturnsHistory) < 2) return 0.0;
    
    // Calculate average return
    double avgReturn = 0.0;
    int count = ArraySize(m_dReturnsHistory);
    for (int i = 0; i < count; i++) {
        avgReturn += m_dReturnsHistory[i];
    }
    avgReturn /= count;
    
    // Calculate standard deviation
    double stdDev = CalculateStandardDeviation(m_dReturnsHistory, count);
    
    // Sharpe ratio (assuming risk-free rate = 0)
    return (stdDev > 0) ? (avgReturn / stdDev) : 0.0;
}

//+------------------------------------------------------------------+
//| Calculate Sortino ratio                                        |
//+------------------------------------------------------------------+
double CRiskAnalyzer::CalculateSortinoRatio() {
    if (ArraySize(m_dReturnsHistory) < 2) return 0.0;
    
    // Calculate average return
    double avgReturn = 0.0;
    int count = ArraySize(m_dReturnsHistory);
    for (int i = 0; i < count; i++) {
        avgReturn += m_dReturnsHistory[i];
    }
    avgReturn /= count;
    
    // Calculate downside deviation
    double downsideDev = CalculateDownsideDeviation();
    
    // Sortino ratio
    return (downsideDev > 0) ? (avgReturn / downsideDev) : 0.0;
}

//+------------------------------------------------------------------+
//| Calculate downside deviation                                   |
//+------------------------------------------------------------------+
double CRiskAnalyzer::CalculateDownsideDeviation() const {
    if (ArraySize(m_dReturnsHistory) < 2) return 0.0;
    
    double sumSquaredDownsideDeviations = 0.0;
    int downsideCount = 0;
    
    for (int i = 0; i < ArraySize(m_dReturnsHistory); i++) {
        if (m_dReturnsHistory[i] < 0) {
            sumSquaredDownsideDeviations += m_dReturnsHistory[i] * m_dReturnsHistory[i];
            downsideCount++;
        }
    }
    
    return (downsideCount > 0) ? MathSqrt(sumSquaredDownsideDeviations / downsideCount) : 0.0;
}

//+------------------------------------------------------------------+
//| Update equity history                                          |
//+------------------------------------------------------------------+
void CRiskAnalyzer::UpdateEquityHistory(const double equity) {
    // Resize arrays if needed
    if (m_iHistoryCount >= ArraySize(m_dEquityHistory)) {
        // Shift array left to make room
        for (int i = 1; i < ArraySize(m_dEquityHistory); i++) {
            m_dEquityHistory[i-1] = m_dEquityHistory[i];
            m_EquityTimes[i-1] = m_EquityTimes[i];
        }
        m_iHistoryCount = ArraySize(m_dEquityHistory) - 1;
    }
    
    // Add new equity point
    m_dEquityHistory[m_iHistoryCount] = equity;
    m_EquityTimes[m_iHistoryCount] = TimeCurrent();
    m_iHistoryCount++;
}

//+------------------------------------------------------------------+
//| Calculate returns from equity history                          |
//+------------------------------------------------------------------+
void CRiskAnalyzer::CalculateReturns() {
    if (m_iHistoryCount < 2) return;
    
    ArrayResize(m_dReturnsHistory, m_iHistoryCount - 1);
    
    for (int i = 1; i < m_iHistoryCount; i++) {
        if (m_dEquityHistory[i-1] > 0) {
            m_dReturnsHistory[i-1] = (m_dEquityHistory[i] / m_dEquityHistory[i-1]) - 1.0;
        } else {
            m_dReturnsHistory[i-1] = 0.0;
        }
    }
}

//+------------------------------------------------------------------+
//| Calculate standard deviation                                    |
//+------------------------------------------------------------------+
double CRiskAnalyzer::CalculateStandardDeviation(const double &data[], const int count) const {
    if (count < 2) return 0.0;
    
    // Calculate mean
    double mean = 0.0;
    for (int i = 0; i < count; i++) {
        mean += data[i];
    }
    mean /= count;
    
    // Calculate variance
    double variance = 0.0;
    for (int i = 0; i < count; i++) {
        double diff = data[i] - mean;
        variance += diff * diff;
    }
    variance /= (count - 1);
    
    return MathSqrt(variance);
}

//+------------------------------------------------------------------+
//| Assess current risk level                                      |
//+------------------------------------------------------------------+
ENUM_RISK_LEVEL CRiskAnalyzer::AssessRiskLevel() const {
    double riskScore = 0.0;
    
    // Drawdown component
    if (m_Metrics.MaxDrawdownPercent > 20.0) riskScore += 40;
    else if (m_Metrics.MaxDrawdownPercent > 10.0) riskScore += 20;
    else if (m_Metrics.MaxDrawdownPercent > 5.0) riskScore += 10;
    
    // VaR component
    if (m_Metrics.VaR95 > 5.0) riskScore += 30;
    else if (m_Metrics.VaR95 > 3.0) riskScore += 15;
    else if (m_Metrics.VaR95 > 1.0) riskScore += 5;
    
    // Volatility component
    if (m_Metrics.ReturnsVolatility > 0.05) riskScore += 20;
    else if (m_Metrics.ReturnsVolatility > 0.03) riskScore += 10;
    else if (m_Metrics.ReturnsVolatility > 0.01) riskScore += 5;
    
    // Sharpe ratio component (inverted)
    if (m_Metrics.SharpeRatio < 0) riskScore += 10;
    else if (m_Metrics.SharpeRatio < 0.5) riskScore += 5;
    
    // Determine risk level
    if (riskScore >= 70) return RISK_LEVEL_CRITICAL;
    if (riskScore >= 50) return RISK_LEVEL_HIGH;
    if (riskScore >= 30) return RISK_LEVEL_MEDIUM;
    if (riskScore >= 10) return RISK_LEVEL_LOW;
    
    return RISK_LEVEL_VERY_LOW;
}

//+------------------------------------------------------------------+
//| Check risk limits                                              |
//+------------------------------------------------------------------+
void CRiskAnalyzer::CheckRiskLimits() {
    m_Metrics.RiskLimitBreached = false;
    
    // Check portfolio risk limit
    if (m_Metrics.PortfolioRisk > m_dMaxPortfolioRisk) {
        m_Metrics.RiskLimitBreached = true;
        LogRiskEvent(RISK_LEVEL_CRITICAL, "Portfolio risk limit breached", 
                    m_Metrics.PortfolioRisk, m_dMaxPortfolioRisk, "Reduce position sizes");
    }
    
    // Check drawdown limit
    if (m_Metrics.MaxDrawdownPercent > 15.0) {
        LogRiskEvent(RISK_LEVEL_HIGH, "Excessive drawdown detected", 
                    m_Metrics.MaxDrawdownPercent, 15.0, "Review strategy");
    }
    
    // Check VaR limit
    if (m_Metrics.VaR95 > 3.0) {
        LogRiskEvent(RISK_LEVEL_MEDIUM, "High VaR detected", 
                    m_Metrics.VaR95, 3.0, "Monitor positions");
    }
}

//+------------------------------------------------------------------+
//| Log risk event                                                 |
//+------------------------------------------------------------------+
void CRiskAnalyzer::LogRiskEvent(const ENUM_RISK_LEVEL level, const string description, 
                                const double value, const double threshold, const string action = "") {
    // Resize array if needed
    if (m_iEventCount >= ArraySize(m_RiskEvents)) {
        ArrayResize(m_RiskEvents, ArraySize(m_RiskEvents) + 100);
    }
    
    // Create risk event
    SRiskEvent event;
    event.Time = TimeCurrent();
    event.Level = level;
    event.Description = description;
    event.Value = value;
    event.Threshold = threshold;
    event.Action = action;
    
    m_RiskEvents[m_iEventCount] = event;
    m_iEventCount++;
    
    // Update counters
    m_Metrics.RiskEvents++;
    if (level >= RISK_LEVEL_HIGH) {
        m_Metrics.CriticalRiskEvents++;
    }
    m_Metrics.LastRiskEvent = TimeCurrent();
    
    // Log to system
    ENUM_LOG_LEVEL logLevel = LOG_LEVEL_INFO;
    if (level >= RISK_LEVEL_HIGH) logLevel = LOG_LEVEL_ERROR;
    else if (level >= RISK_LEVEL_MEDIUM) logLevel = LOG_LEVEL_WARNING;
    
    string logMessage = StringFormat("RISK EVENT [%s]: %s (Value: %.2f, Threshold: %.2f)", 
                                    EnumToString(level), description, value, threshold);
    if (action != "") {
        logMessage += " - Action: " + action;
    }
    
    LogRiskAnalysisEvent(logMessage, logLevel);
}

//+------------------------------------------------------------------+
//| Get risk report                                                |
//+------------------------------------------------------------------+
string CRiskAnalyzer::GetRiskReport() const {
    string report = "\n=== RISK ANALYSIS REPORT ===\n";
    report += StringFormat("Risk Level: %s\n", EnumToString(m_Metrics.CurrentRiskLevel));
    report += StringFormat("Portfolio Risk: %.2f%% (Max: %.2f%%)\n", 
                          m_Metrics.PortfolioRisk, m_Metrics.MaxPortfolioRisk);
    report += StringFormat("Current Drawdown: %s (%.2f%%)\n", 
                          FormatRiskValue(m_Metrics.CurrentDrawdown), 
                          (m_dEquityPeak > 0) ? (m_Metrics.CurrentDrawdown / m_dEquityPeak * 100.0) : 0.0);
    report += StringFormat("Max Drawdown: %s (%.2f%%)\n", 
                          FormatRiskValue(m_Metrics.MaxDrawdown), m_Metrics.MaxDrawdownPercent);
    report += StringFormat("VaR (95%%): %.2f%%\n", m_Metrics.VaR95);
    report += StringFormat("VaR (99%%): %.2f%%\n", m_Metrics.VaR99);
    report += StringFormat("Sharpe Ratio: %.2f\n", m_Metrics.SharpeRatio);
    report += StringFormat("Sortino Ratio: %.2f\n", m_Metrics.SortinoRatio);
    report += StringFormat("Risk Events: %d (Critical: %d)\n", 
                          m_Metrics.RiskEvents, m_Metrics.CriticalRiskEvents);
    
    if (m_Metrics.RiskLimitBreached) {
        report += "\n*** RISK LIMIT BREACHED ***\n";
    }
    
    report += "===========================\n";
    
    return report;
}

//+------------------------------------------------------------------+
//| Get risk recommendations                                       |
//+------------------------------------------------------------------+
string CRiskAnalyzer::GetRiskRecommendations() const {
    string recommendations = "";
    
    switch(m_Metrics.CurrentRiskLevel) {
    case RISK_LEVEL_CRITICAL:
        recommendations = "CRITICAL: Stop trading immediately. Review all positions. Reduce leverage significantly.";
        break;
    case RISK_LEVEL_HIGH:
        recommendations = "HIGH RISK: Reduce position sizes by 50%. Close losing positions. Avoid new trades.";
        break;
    case RISK_LEVEL_MEDIUM:
        recommendations = "MEDIUM RISK: Reduce position sizes by 25%. Monitor closely. Consider tighter stops.";
        break;
    case RISK_LEVEL_LOW:
        recommendations = "LOW RISK: Normal trading. Monitor risk metrics regularly.";
        break;
    default:
        recommendations = "VERY LOW RISK: Normal trading conditions. Consider increasing position sizes if appropriate.";
        break;
    }
    
    return recommendations;
}

//+------------------------------------------------------------------+
//| Should reduce risk                                             |
//+------------------------------------------------------------------+
bool CRiskAnalyzer::ShouldReduceRisk() const {
    return (m_Metrics.CurrentRiskLevel >= RISK_LEVEL_MEDIUM || 
            m_Metrics.RiskLimitBreached ||
            m_Metrics.MaxDrawdownPercent > 10.0);
}

//+------------------------------------------------------------------+
//| Should stop trading                                            |
//+------------------------------------------------------------------+
bool CRiskAnalyzer::ShouldStopTrading() const {
    return (m_Metrics.CurrentRiskLevel >= RISK_LEVEL_CRITICAL || 
            m_Metrics.MaxDrawdownPercent > 20.0 ||
            m_Metrics.PortfolioRisk > m_dMaxPortfolioRisk);
}

//+------------------------------------------------------------------+
//| Format risk value                                              |
//+------------------------------------------------------------------+
string CRiskAnalyzer::FormatRiskValue(const double value) const {
    return StringFormat("%.2f %s", value, AccountInfoString(ACCOUNT_CURRENCY));
}

//+------------------------------------------------------------------+
//| Format percentage value                                        |
//+------------------------------------------------------------------+
string CRiskAnalyzer::FormatPercentage(const double value) const {
    return StringFormat("%.2f%%", value);
}

//+------------------------------------------------------------------+
//| Log risk analysis event                                        |
//+------------------------------------------------------------------+
void CRiskAnalyzer::LogRiskAnalysisEvent(const string event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO) {
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
            break;
        }
    }
}

//+------------------------------------------------------------------+
//| Update risk warnings                                           |
//+------------------------------------------------------------------+
void CRiskAnalyzer::UpdateRiskWarnings() {
    ArrayResize(m_Metrics.RiskWarnings, 0);
    
    if (m_Metrics.MaxDrawdownPercent > 15.0) {
        ArrayResize(m_Metrics.RiskWarnings, ArraySize(m_Metrics.RiskWarnings) + 1);
        m_Metrics.RiskWarnings[ArraySize(m_Metrics.RiskWarnings) - 1] = "Excessive drawdown detected";
    }
    
    if (m_Metrics.VaR95 > 3.0) {
        ArrayResize(m_Metrics.RiskWarnings, ArraySize(m_Metrics.RiskWarnings) + 1);
        m_Metrics.RiskWarnings[ArraySize(m_Metrics.RiskWarnings) - 1] = "High Value at Risk";
    }
    
    if (m_Metrics.SharpeRatio < 0) {
        ArrayResize(m_Metrics.RiskWarnings, ArraySize(m_Metrics.RiskWarnings) + 1);
        m_Metrics.RiskWarnings[ArraySize(m_Metrics.RiskWarnings) - 1] = "Negative risk-adjusted returns";
    }
    
    if (m_Metrics.PortfolioRisk > m_dMaxPortfolioRisk * 0.8) {
        ArrayResize(m_Metrics.RiskWarnings, ArraySize(m_Metrics.RiskWarnings) + 1);
        m_Metrics.RiskWarnings[ArraySize(m_Metrics.RiskWarnings) - 1] = "Approaching portfolio risk limit";
    }
}

//+------------------------------------------------------------------+
//| Get recommended position size                                  |
//+------------------------------------------------------------------+
double CRiskAnalyzer::GetRecommendedPositionSize(const double stopLoss) const {
    if (stopLoss <= 0 || m_dLastEquity <= 0) return 0.0;
    
    // Base risk per trade
    double baseRiskPercent = m_dMaxTradeRisk;
    
    // Adjust based on current risk level
    switch(m_Metrics.CurrentRiskLevel) {
    case RISK_LEVEL_CRITICAL:
        return 0.0; // No new positions
    case RISK_LEVEL_HIGH:
        baseRiskPercent *= 0.25; // 25% of normal
        break;
    case RISK_LEVEL_MEDIUM:
        baseRiskPercent *= 0.5; // 50% of normal
        break;
    case RISK_LEVEL_LOW:
        baseRiskPercent *= 0.75; // 75% of normal
        break;
    default:
        // Normal risk
        break;
    }
    
    // Calculate position size
    double riskAmount = m_dLastEquity * (baseRiskPercent / 100.0);
    double positionSize = riskAmount / stopLoss;
    
    return positionSize;
}