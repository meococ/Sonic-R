//+------------------------------------------------------------------+
//|                                   ParameterStabilityEnhanced.mqh |
//|                         Copyright 2023-2024, ApexPullback EA |
//|                                     https://www.apexpullback.com |
//+------------------------------------------------------------------+

#ifndef PARAMETER_STABILITY_ENHANCED_MQH_
#define PARAMETER_STABILITY_ENHANCED_MQH_

// Implementation cho các phương thức enhanced stability analysis
// Sử dụng công thức Normalized Change theo đề xuất kỹ thuật

namespace ApexPullback {

//+------------------------------------------------------------------+
//| Tính toán Stability Index theo công thức Normalized Change       |
//+------------------------------------------------------------------+
double CParameterStabilityAnalyzer::CalculateStabilityIndex()
{
    if (m_HistorySize < 2) {
        return 1.0; // Hoàn toàn ổn định nếu chưa có đủ dữ liệu
    }
    
    double totalNormalizedChange = 0.0;
    int validChanges = 0;
    
    // Định nghĩa ranges cho từng tham số (để normalize)
    struct ParameterRanges {
        double riskMin, riskMax;
        double atrMin, atrMax;
        double emaMin, emaMax;
        double pullbackMin, pullbackMax;
        double trendMin, trendMax;
        double volatilityMin, volatilityMax;
    } ranges;
    
    // Thiết lập ranges dựa trên kinh nghiệm thực tế
    ranges.riskMin = 0.1; ranges.riskMax = 5.0;           // Risk: 0.1% - 5%
    ranges.atrMin = 5; ranges.atrMax = 50;                // ATR Period: 5 - 50
    ranges.emaMin = 5; ranges.emaMax = 200;               // EMA Period: 5 - 200
    ranges.pullbackMin = 0.1; ranges.pullbackMax = 1.0;  // Pullback: 10% - 100%
    ranges.trendMin = 0.1; ranges.trendMax = 2.0;         // Trend Strength: 0.1 - 2.0
    ranges.volatilityMin = 0.5; ranges.volatilityMax = 3.0; // Volatility: 0.5 - 3.0
    
    // Tính toán normalized changes cho các chu kỳ gần nhất
    int lookback = MathMin(m_HistorySize - 1, 10); // Xem xét 10 chu kỳ gần nhất
    
    for (int i = 1; i <= lookback; i++) {
        int currentIndex = (m_HistorySize - i) % m_MaxHistorySize;
        int previousIndex = (m_HistorySize - i - 1) % m_MaxHistorySize;
        
        ParameterSnapshot current = m_ParameterHistory[currentIndex];
        ParameterSnapshot previous = m_ParameterHistory[previousIndex];
        
        // Tính normalized change cho từng tham số
        double riskChange = CalculateNormalizedChange(
            previous.RiskPercent, current.RiskPercent, 
            ranges.riskMax, ranges.riskMin
        );
        
        double atrChange = CalculateNormalizedChange(
            previous.ATRPeriod, current.ATRPeriod,
            ranges.atrMax, ranges.atrMin
        );
        
        double ema1Change = CalculateNormalizedChange(
            previous.EMAPeriod1, current.EMAPeriod1,
            ranges.emaMax, ranges.emaMin
        );
        
        double ema2Change = CalculateNormalizedChange(
            previous.EMAPeriod2, current.EMAPeriod2,
            ranges.emaMax, ranges.emaMin
        );
        
        double ema3Change = CalculateNormalizedChange(
            previous.EMAPeriod3, current.EMAPeriod3,
            ranges.emaMax, ranges.emaMin
        );
        
        double pullbackChange = CalculateNormalizedChange(
            previous.PullbackThreshold, current.PullbackThreshold,
            ranges.pullbackMax, ranges.pullbackMin
        );
        
        double trendChange = CalculateNormalizedChange(
            previous.TrendStrength, current.TrendStrength,
            ranges.trendMax, ranges.trendMin
        );
        
        double volatilityChange = CalculateNormalizedChange(
            previous.VolatilityFilter, current.VolatilityFilter,
            ranges.volatilityMax, ranges.volatilityMin
        );
        
        // Tính trung bình weighted của tất cả changes
        // Trọng số dựa trên tầm quan trọng của tham số
        double weightedChange = 
            (riskChange * 0.25) +        // Risk quan trọng nhất
            (atrChange * 0.15) +         // ATR quan trọng
            (ema1Change * 0.12) +        // EMA periods
            (ema2Change * 0.12) +
            (ema3Change * 0.12) +
            (pullbackChange * 0.12) +    // Pullback threshold
            (trendChange * 0.07) +       // Trend strength
            (volatilityChange * 0.05);   // Volatility filter
        
        totalNormalizedChange += weightedChange;
        validChanges++;
    }
    
    if (validChanges == 0) {
        return 1.0; // Hoàn toàn ổn định
    }
    
    // Tính InstabilityIndex = Average(NormalizedChange)
    double instabilityIndex = totalNormalizedChange / validChanges;
    
    // Tính phương sai của các normalized changes để đánh giá độ biến động
    double variance = 0.0;
    if (validChanges > 1) {
        double mean = totalNormalizedChange / validChanges;
        double sumSquaredDiff = 0.0;
        
        // Tính lại để có variance
        for (int i = 1; i <= lookback; i++) {
            int currentIndex = (m_HistorySize - i) % m_MaxHistorySize;
            int previousIndex = (m_HistorySize - i - 1) % m_MaxHistorySize;
            
            ParameterSnapshot current = m_ParameterHistory[currentIndex];
            ParameterSnapshot previous = m_ParameterHistory[previousIndex];
            
            // Tính lại weighted change cho variance
            double riskChange = CalculateNormalizedChange(
                previous.RiskPercent, current.RiskPercent, 
                ranges.riskMax, ranges.riskMin
            );
            double weightedChange = riskChange * 0.25; // Simplified for variance calc
            
            double diff = weightedChange - mean;
            sumSquaredDiff += diff * diff;
        }
        
        variance = sumSquaredDiff / validChanges;
    }
    
    // StabilityIndex = 1.0 - AverageVariance (theo đề xuất kỹ thuật)
    double stabilityIndex = 1.0 - MathMin(1.0, variance);
    
    // Cập nhật vào EAContext
    if (m_Context != NULL) {
        m_Context->ParameterStabilityIndex = stabilityIndex;
    }
    
    // Log chi tiết nếu cần
    if (m_Logger && m_Context && m_Context->EnableDetailedLogs) {
        string logMsg = StringFormat(
            "[STABILITY] Index: %.3f (Variance: %.3f), Valid changes: %d, Lookback: %d",
            stabilityIndex, variance, validChanges, lookback
        );
        m_Logger->LogDebug(logMsg);
    }
    
    return stabilityIndex;
}

//+------------------------------------------------------------------+
//| Tính toán Normalized Change cho một tham số                      |
//+------------------------------------------------------------------+
double CParameterStabilityAnalyzer::CalculateNormalizedChange(double oldValue, double newValue, double maxRange, double minRange)
{
    if (maxRange <= minRange) {
        return 0.0; // Tránh chia cho 0
    }
    
    double absoluteChange = MathAbs(newValue - oldValue);
    double normalizedChange = absoluteChange / (maxRange - minRange);
    
    return MathMin(1.0, normalizedChange); // Giới hạn tối đa là 1.0
}

//+------------------------------------------------------------------+
//| Cập nhật Parameter Instability Index vào EAContext              |
//+------------------------------------------------------------------+
void CParameterStabilityAnalyzer::UpdateParameterInstabilityIndex()
{
    if (!m_Context) return;
    
    double stabilityIndex = CalculateStabilityIndex();
    double instabilityIndex = 1.0 - stabilityIndex;
    
    // Cập nhật vào context
    m_Context->CurrentParameterInstabilityIndex = instabilityIndex;
    
    // Đánh giá trạng thái
    if (instabilityIndex > 0.7) {
        m_Context->IsParameterStabilityDegraded = true;
        
        if (m_Logger) {
            string alertMsg = StringFormat(
                "[PARAMETER ALERT] High instability detected: %.1f%% (Threshold: %.1f%%)",
                instabilityIndex * 100, 70.0
            );
            m_Logger->LogWarning(alertMsg);
        }
    } else if (instabilityIndex < 0.4) {
        m_Context->IsParameterStabilityDegraded = false;
        
        // Log recovery nếu trước đó có cảnh báo
        static bool wasUnstable = false;
        if (wasUnstable) {
            if (m_Logger) {
                m_Logger->LogInfo("[PARAMETER RECOVERY] Stability restored");
            }
            wasUnstable = false;
        }
        if (m_Context->IsParameterStabilityDegraded) wasUnstable = true;
    }
    
    m_Context->LastStabilityCheck = TimeCurrent();
    
    // Cập nhật metrics trong class
    m_CurrentMetrics.InstabilityIndex = instabilityIndex;
    m_CurrentMetrics.IsUnstable = (instabilityIndex > m_UnstableThreshold);
    m_CurrentMetrics.RequiresAttention = (instabilityIndex > m_AttentionThreshold);
    m_CurrentMetrics.ShouldTriggerCircuitBreaker = (instabilityIndex > m_CriticalThreshold);
    m_CurrentMetrics.LastUpdate = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Kiểm tra xem chiến lược có ổn định không - V14.0 Enhancement     |
//+------------------------------------------------------------------+
bool CParameterStabilityAnalyzer::IsStrategyStable(double threshold = 0.6)
{
    if (m_Context == NULL) return true; // Mặc định ổn định nếu không có context
    
    double currentStability = m_Context->ParameterStabilityIndex;
    bool isStable = (currentStability >= threshold);
    
    // Cập nhật trạng thái vào EAContext
    m_Context->IsStrategyUnstable = !isStable;
    
    // Log cảnh báo nếu không ổn định
    if (!isStable && m_Logger != NULL) {
        string alertMsg = StringFormat(
            "[STRATEGY INSTABILITY] Current stability: %.1f%%, Threshold: %.1f%% - Strategy marked as UNSTABLE",
            currentStability * 100, threshold * 100
        );
        m_Logger->LogWarning(alertMsg);
    }
    
    return isStable;
}

} // End namespace ApexPullback

#endif // PARAMETER_STABILITY_ENHANCED_MQH_