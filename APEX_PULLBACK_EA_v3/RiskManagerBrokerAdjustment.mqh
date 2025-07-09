//+------------------------------------------------------------------+
//|                                   RiskManagerBrokerAdjustment.mqh |
//|                         Copyright 2023-2024, ApexPullback EA |
//|                                     https://www.apexpullback.com |
//+------------------------------------------------------------------+

#ifndef RISKMANAGER_BROKER_ADJUSTMENT_MQH_
#define RISKMANAGER_BROKER_ADJUSTMENT_MQH_

// Đây là file implementation cho các hàm broker performance adjustment
// Được tách riêng để dễ quản lý và maintain

namespace ApexPullback {

//+------------------------------------------------------------------+
//| Điều chỉnh rủi ro dựa trên chất lượng broker                     |
//+------------------------------------------------------------------+
void CRiskManager::AdjustForBrokerPerformance()
{
    if (CheckPointer(m_context) == POINTER_INVALID || CheckPointer(m_context->BrokerHealthMonitor) == POINTER_INVALID) return;

    // Lấy trạng thái sức khỏe từ BrokerHealthMonitor
    ENUM_HEALTH_STATUS status = m_context->BrokerHealthMonitor->GetHealthStatus();
    double healthScore = m_context->BrokerHealthMonitor->GetHealthScore();
    double riskAdjustmentFactor = m_context->BrokerHealthMonitor->GetRiskAdjustmentFactor();

    // Lưu trạng thái trước đó để phát hiện thay đổi
    double previousMultiplier = m_context->CurrentRiskMultiplier;

    // Điều chỉnh hệ số rủi ro dựa trên trạng thái sức khỏe
    m_context->CurrentRiskMultiplier = riskAdjustmentFactor;

    // Cập nhật trạng thái suy giảm hiệu suất
    m_context->IsBrokerPerformanceDegraded = (status == HEALTH_CRITICAL || status == HEALTH_WARNING);

    // Ghi log nếu có sự thay đổi đáng kể hoặc trạng thái không tốt
    if (m_context->Logger && previousMultiplier != m_context->CurrentRiskMultiplier) {
        string statusString = m_context->BrokerHealthMonitor->GetHealthStatusString(status);
        string logMessage;

        if (m_context->CurrentRiskMultiplier < 1.0) {
            logMessage = StringFormat(
                "[BROKER HEALTH ALERT] Status: %s (Score: %.1f). Risk multiplier adjusted to %.2f.",
                statusString,
                healthScore,
                m_context->CurrentRiskMultiplier
            );
            m_context->Logger->LogWarning(logMessage);
        } else {
            logMessage = StringFormat(
                "[BROKER HEALTH RECOVERY] Status: %s (Score: %.1f). Risk multiplier restored to %.2f.",
                statusString,
                healthScore,
                m_context->CurrentRiskMultiplier
            );
            m_context->Logger->LogInfo(logMessage);
        }
    }

    m_context->LastBrokerHealthCheck = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Tính toán hệ số chất lượng broker (0.0 - 1.0)                   |
//+------------------------------------------------------------------+
double CRiskManager::CalculateBrokerQualityFactor()
{
    if (CheckPointer(m_context) == POINTER_INVALID || CheckPointer(m_context->BrokerHealthMonitor) == POINTER_INVALID) {
        return 1.0; // Trả về giá trị mặc định nếu con trỏ không hợp lệ
    }

    // Lấy điểm sức khỏe tổng thể từ BrokerHealthMonitor
    double healthScore = m_context->BrokerHealthMonitor->GetHealthScore();

    // Chuyển đổi điểm sức khỏe (0-100) thành hệ số chất lượng (0.0-1.0)
    // Giả sử điểm dưới 40 là không thể chấp nhận (hệ số ~0.1), và trên 90 là xuất sắc (hệ số 1.0)
    double qualityFactor = (healthScore / 100.0);

    // Áp dụng một đường cong phi tuyến tính để làm cho sự sụt giảm trở nên rõ rệt hơn
    // Ví dụ: sử dụng hàm power để các giá trị thấp bị phạt nặng hơn
    qualityFactor = pow(qualityFactor, 1.5);

    // Giới hạn hệ số trong một phạm vi an toàn (ví dụ: từ 0.2 đến 1.0)
    return MathMax(0.2, MathMin(1.0, qualityFactor));
}

//+------------------------------------------------------------------+
//| Cập nhật metrics broker performance                              |
//+------------------------------------------------------------------+
void CRiskManager::UpdateBrokerPerformanceMetrics(double slippagePips, double executionTimeMs)
{
    if (CheckPointer(m_context) == POINTER_INVALID || CheckPointer(m_context->BrokerHealthMonitor) == POINTER_INVALID) {
        return; // Bỏ qua nếu con trỏ không hợp lệ
    }

    // Chuyển tiếp dữ liệu đến BrokerHealthMonitor để xử lý tập trung
    // Giả sử BrokerHealthMonitor có một phương thức để nhận các điểm dữ liệu thô này.
    // Ví dụ: UpdateMetrics(avgSlippage, maxSlippage, avgLatency, maxLatency, requoteRate, successRate)
    // Ở đây, chúng ta sẽ gọi một phiên bản đơn giản hơn hoặc cần phải điều chỉnh BrokerHealthMonitor.
    // Giả sử có một hàm `RecordExecutionEvent` trong BrokerHealthMonitor.

    // NOTE: Cần phải có một phương thức trong CBrokerHealthMonitor để nhận dữ liệu này.
    // Giả sử chúng ta thêm một phương thức `RecordTradeExecution` vào CBrokerHealthMonitor
    // CBrokerHealthMonitor::RecordTradeExecution(double slippage, double latency, bool success, bool isRequote)
    // Hiện tại, chúng ta chỉ có slippage và latency.
    
    // *** Giả định rằng CBrokerHealthMonitor sẽ được cập nhật để có một phương thức như sau: ***
    // m_context->BrokerHealthMonitor->UpdateWithNewDataPoint(slippagePips, executionTimeMs);

    // Vì chưa có phương thức đó, chúng ta sẽ tạm thời để trống hàm này
    // và giả định rằng logic cập nhật sẽ được gọi từ một nơi khác (ví dụ: TradeManager)
    // hoặc chúng ta sẽ thêm phương thức đó vào BrokerHealthMonitor ở bước tiếp theo.

    if (m_context->EnableDetailedLogs && m_context->Logger) {
        string logMsg = StringFormat(
            "[BROKER METRICS] Forwarding to Health Monitor -> Slippage: %.2f pips, Latency: %.1f ms",
            slippagePips,
            executionTimeMs
        );
        m_context->Logger->LogDebug(logMsg);
    }
}

//+------------------------------------------------------------------+
//| Kiểm tra xem có nên giảm rủi ro do broker performance không      |
//+------------------------------------------------------------------+
bool CRiskManager::ShouldReduceRiskDueToBroker()
{
    if (CheckPointer(m_context) == POINTER_INVALID || CheckPointer(m_context->BrokerHealthMonitor) == POINTER_INVALID) {
        return false; // Mặc định là không giảm rủi ro nếu con trỏ không hợp lệ
    }

    // Ủy quyền hoàn toàn quyết định cho BrokerHealthMonitor
    return m_context->BrokerHealthMonitor->ShouldReduceRisk();
}

} // End namespace ApexPullback

#endif // RISKMANAGER_BROKER_ADJUSTMENT_MQH_