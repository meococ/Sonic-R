//+------------------------------------------------------------------+
//| PatternDetector.mqh                                             |
//| Phát hiện mẫu hình giá thông minh cho EA                        |
//+------------------------------------------------------------------+

#ifndef PATTERNDETECTOR_MQH_
#define PATTERNDETECTOR_MQH_

#include "CommonStructs.mqh"

// BẮT ĐẦU NAMESPACE
namespace ApexPullback {

// Định nghĩa các tỷ lệ Fibonacci phổ biến
#define FIB_0_236 0.236
#define FIB_0_382 0.382
#define FIB_0_5   0.500
#define FIB_0_618 0.618
#define FIB_0_786 0.786
#define FIB_0_886 0.886

// Định nghĩa các tỷ lệ Harmonic
#define GARTLEY_B  0.618    // Điểm B của mẫu Gartley
#define GARTLEY_C  0.382    // Điểm C của mẫu Gartley
#define GARTLEY_D  0.786    // Điểm D của mẫu Gartley

#define BUTTERFLY_B 0.786   // Điểm B của mẫu Butterfly
#define BUTTERFLY_C 0.382   // Điểm C của mẫu Butterfly
#define BUTTERFLY_D 1.618   // Điểm D của mẫu Butterfly

#define BAT_B 0.382        // Điểm B của mẫu Bat
#define BAT_C 0.382        // Điểm C của mẫu Bat
#define BAT_D 0.886        // Điểm D của mẫu Bat

#define CRAB_B 0.382       // Điểm B của mẫu Crab
#define CRAB_C 0.618       // Điểm C của mẫu Crab
#define CRAB_D 1.618       // Điểm D của mẫu Crab

// DetectedPattern struct đã được định nghĩa trong CommonStructs.mqh
// Xóa định nghĩa trùng lặp để tránh xung đột

//+------------------------------------------------------------------+
//| Class CPatternDetector - Phát hiện mẫu hình giá                  |
//+------------------------------------------------------------------+
class CPatternDetector {
private:
    string m_Symbol;
    ENUM_TIMEFRAMES m_Timeframe;
    CLogger* m_Logger;
    CMarketProfile* m_MarketProfile;
    CSwingPointDetector* m_SwingPointDetector; // Thêm con trỏ tới SwingPointDetector
    double m_slBufferMultiplier; // Hệ số nhân ATR cho vùng đệm SL
    double m_minRR; // Tỷ lệ R:R tối thiểu
    double m_defaultRR; // Tỷ lệ R:R mặc định khi không có mục tiêu cấu trúc rõ ràng
    
    // Cấu hình
    double m_MinPullbackPercent;      // % pullback tối thiểu
    double m_MaxPullbackPercent;      // % pullback tối đa
    double m_PriceActionQualityThreshold; // Ngưỡng chất lượng price action
    double m_MomentumThreshold;       // Ngưỡng momentum
    double m_VolumeThreshold;         // Ngưỡng volume
    
    // Bộ lọc nâng cao 
    double m_AdxThreshold;            // Ngưỡng ADX
    double m_VolatilityThreshold;     // Ngưỡng biến động
    bool m_RequirePriceActionConfirmation; // Yêu cầu xác nhận price action
    bool m_RequireMomentumConfirmation;    // Yêu cầu xác nhận momentum
    bool m_RequireVolumeConfirmation;      // Yêu cầu xác nhận volume
    bool m_EnableMarketRegimeFilter;       // Bật lọc market regime
    
    // Bộ lọc pullback chặt chẽ
    bool m_StrictPullbackFilter;      // Bật bộ lọc pullback chặt chẽ
    int m_MinConfirmationBars;        // Số nến xác nhận tối thiểu
    int m_MaxRejectionCount;          // Số lần từ chối tối đa
    
    // Biến hỗ trợ phân tích
    double m_LastPatternQuality;      // Chất lượng mẫu hình cuối cùng
    ENUM_PATTERN_TYPE m_LastPatternType; // Loại mẫu hình cuối cùng
    datetime m_LastDetectionTime;     // Thời gian phát hiện cuối cùng
    
    // Thành viên dữ liệu cơ bản
    bool m_isInitialized;             // Trạng thái khởi tạo
    
    // Tham số cấu hình
    int m_minBarsForPattern;          // Số nến tối thiểu cho mẫu hình
    int m_maxBarsForPattern;          // Số nến tối đa cho mẫu hình
    double m_fibTolerance;            // Dung sai cho tỷ lệ Fibonacci (±%)
    double m_atr;                     // Giá trị ATR hiện tại
    bool m_useVolume;                 // Có xét đến volume hay không
    
    // Buffer lưu trữ
    double m_high[];                  // Buffer giá cao
    double m_low[];                   // Buffer giá thấp
    double m_close[];                 // Buffer giá đóng cửa
    double m_open[];                  // Buffer giá mở cửa
    long m_volume[];                  // Buffer khối lượng
    double m_atrBuffer[];             // Buffer ATR
    datetime m_time[];                // Buffer thời gian
    
    // Bộ nhớ đệm mẫu hình đã phát hiện
    DetectedPattern m_lastDetectedPattern;        // Mẫu hình được phát hiện gần nhất
    DetectedPattern m_detectedPullback;           // Mẫu hình pullback
    DetectedPattern m_detectedReversal;           // Mẫu hình đảo chiều
    DetectedPattern m_detectedHarmonic;           // Mẫu hình harmonic
    DetectedPattern m_detectedBreakout;           // Mẫu hình breakout
    
    // Các tay cầm indicator
    int m_atrHandle;                  // Handle chỉ báo ATR
    
public:
    // Constructor và Destructor
    CPatternDetector();
    ~CPatternDetector();
    
    // Hàm khởi tạo và kết thúc
    bool Initialize(EAContext* context, string symbol, ENUM_TIMEFRAMES timeframe);
    void SetLogger(CLogger* logger); // Sẽ bị loại bỏ nếu Logger được lấy từ context
    void SetSwingPointDetector(CSwingPointDetector* detector) { m_SwingPointDetector = detector; } // Sẽ bị loại bỏ nếu SwingPointDetector được lấy từ context
    void SetSLBufferMultiplier(double val) { m_slBufferMultiplier = val; }
    void SetMinRR(double val) { m_minRR = val; }
    void SetDefaultRR(double val) { m_defaultRR = val; }
    void Release();
    
    // Hàm cập nhật dữ liệu và làm mới
    bool RefreshData(int bars = 100);
    void SetATR(double atr);
    
    // Hàm thiết lập tham số cấu hình
    void SetFibTolerance(double tolerance) { m_fibTolerance = tolerance; }
    void SetMinPullbackPct(double minPct) { m_MinPullbackPercent = minPct; }
    void SetMaxPullbackPct(double maxPct) { m_MaxPullbackPercent = maxPct; }
    void SetBarsRange(int minBars, int maxBars) {
        m_minBarsForPattern = minBars;
        m_maxBarsForPattern = maxBars;
    }
    
    // Hàm chính để phát hiện mẫu hình
    bool DetectPattern(ENUM_PATTERN_TYPE& scenario, double& strength);
    
    // Hàm phát hiện các loại mẫu hình cụ thể
    bool IsPullback(bool isBullish, double& strength);
    bool IsReversal(bool isBullish, double& strength);
    bool IsHarmonic(bool isBullish, double& strength);
    
    // Hàm lấy thông tin chi tiết về mẫu hình đã phát hiện
    bool GetPatternDetails(DetectedPattern& pattern);
    
    // Hàm kiểm tra các mẫu hình cụ thể
    bool CheckFibonacciPullback(bool isBullish, DetectedPattern& pattern);
    bool CheckBullishPullback(DetectedPattern& pattern);
    bool CheckBearishPullback(DetectedPattern& pattern);
    bool CheckStrongPullback(bool isBullish, DetectedPattern& pattern);
    bool CheckEngulfingPattern(bool isBullish, DetectedPattern& pattern);
    bool CheckPinbarPattern(bool isBullish, DetectedPattern& pattern);
    bool CheckDivergencePattern(bool isBullish, DetectedPattern& pattern);
    bool CheckDoubleTopBottomPattern(bool isBullish, DetectedPattern& pattern);
    bool CheckRangeBreakoutPattern(bool isBullish, DetectedPattern& pattern);
    bool CheckGartleyPattern(bool isBullish, DetectedPattern& pattern);
    bool CheckButterflyPattern(bool isBullish, DetectedPattern& pattern);
    bool CheckBatPattern(bool isBullish, DetectedPattern& pattern);
    bool CheckCrabPattern(bool isBullish, DetectedPattern& pattern);
    
    // Bước 2: Hàm phát hiện Mean Reversion cho thị trường đi ngang
    bool DetectMeanReversionPattern(bool& isBullish, DetectedPattern& pattern);

    // Cài đặt bộ lọc pullback chặt chẽ
    void SetStrictPullbackFilter(bool enable, int minConfirmationBars = 2, int maxRejectionCount = 1);

private:
    // Hàm phụ trợ nội bộ
    bool DetectPullbackPatterns();
    bool DetectReversalPatterns();
    bool DetectBreakoutPatterns();
    bool DetectHarmonicPatterns();
    
    bool IsValidPullbackDepth(double highPrice, double lowPrice, double& ratio);
    bool IsValidFibonacciRatio(double ratio, double targetRatio);
    bool IsUptrend(int startBar, int endBar);
    bool IsDowntrend(int startBar, int endBar);
    
    void LogPattern(string patternName, bool isValid, string description = "");
    double CalculatePatternStrength(DetectedPattern& pattern);
    
    // Hàm xử lý các điểm swing
    int FindLastSwingHigh(int startBar, int lookback);
    int FindLastSwingLow(int startBar, int lookback);
    int FindSwingPoint(bool findHigh, int startBar, int lookback, double& price);
    double CalculateFibonacciRetracementLevel(double startPrice, double endPrice, double retracementRatio, bool isBullish);
    
    // Helper functions cho Mean Reversion
    double CalculateSimpleRSI(int period);
    bool IsPinbarPattern(bool checkBullish);
    double CalculateEMA(int period, int shift);

    bool DetectPullbackPattern(bool isBullish, DetectedPattern& pattern);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPatternDetector::CPatternDetector() {
    m_isInitialized = false;
    m_Logger = NULL;
    m_SwingPointDetector = NULL; // Khởi tạo SwingPointDetector là NULL
    m_atrHandle = INVALID_HANDLE;
    m_slBufferMultiplier = 0.2; // Giá trị mặc định, có thể cấu hình
    m_minRR = 1.0; // Giá trị mặc định
    m_defaultRR = 2.0; // Giá trị mặc định
    
    // Thiết lập các giá trị mặc định
    m_minBarsForPattern = 5;
    m_maxBarsForPattern = 20;
    m_fibTolerance = 0.03;  // Dung sai 3%
    m_MinPullbackPercent = 20.0;
    m_MaxPullbackPercent = 70.0;
    m_atr = 0.0;
    m_useVolume = true;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPatternDetector::~CPatternDetector() {
    Release();
}

//+------------------------------------------------------------------+
//| Khởi tạo với EAContext, symbol và timeframe                     |
//+------------------------------------------------------------------+
bool CPatternDetector::Initialize(ApexPullback::EAContext* context, string symbol, ENUM_TIMEFRAMES timeframe) {
    // Giải phóng tài nguyên nếu đã khởi tạo trước đó
    if (m_isInitialized) {
        Release();
    }
    
    m_Logger = context->Logger; // Lấy Logger từ context
    m_SwingPointDetector = context->SwingPointDetector; // Lấy SwingPointDetector từ context

    if (m_Logger == NULL) {
        printf("CPatternDetector::Initialize - Logger is NULL from context");
        // return false; // Quyết định có return false hay không tùy thuộc vào mức độ quan trọng của Logger
    }
    if (m_SwingPointDetector == NULL) {
        if(m_Logger) m_Logger->LogError("CPatternDetector::Initialize - SwingPointDetector is NULL from context");
        return false; 
    }

    m_Symbol = symbol;
    m_Timeframe = timeframe;
    // m_Logger đã được gán từ context
    
    // Tạo handle cho indicator ATR
    m_atrHandle = iATR(m_Symbol, m_Timeframe, 14);
    if (m_atrHandle == INVALID_HANDLE) {
        if (m_Logger != NULL) m_Logger->LogError("Không thể tạo handle ATR trong PatternDetector");
        return false;
    }
    
    // Cấp phát bộ nhớ cho các buffer
    // Nên lấy kích thước buffer từ context nếu có, ví dụ context->MaxBarsForPattern
    int bufferSize = m_maxBarsForPattern * 2; // Giữ nguyên nếu không có trong context
    if (context->InputParameters != NULL && context->InputParameters->GetInt("MaxBarsForPattern") > 0) { // Corrected: context->InputParameters->GetInt
        bufferSize = context->InputParameters->GetInt("MaxBarsForPattern") * 2;
    }

    ArrayResize(m_high, bufferSize);
    ArrayResize(m_low, bufferSize);
    ArrayResize(m_close, bufferSize);
    ArrayResize(m_open, bufferSize);
    ArrayResize(m_volume, bufferSize);
    ArrayResize(m_atrBuffer, bufferSize);
    ArrayResize(m_time, bufferSize);
    
    // Thiết lập các mảng là mảng series (index 0 là nến mới nhất)
    ArraySetAsSeries(m_high, true);
    ArraySetAsSeries(m_low, true);
    ArraySetAsSeries(m_close, true);
    ArraySetAsSeries(m_open, true);
    ArraySetAsSeries(m_volume, true);
    ArraySetAsSeries(m_atrBuffer, true);
    ArraySetAsSeries(m_time, true);
    
    // Làm mới dữ liệu
    bool refreshOk = RefreshData(bufferSize); // Truyền bufferSize vào RefreshData
    
    m_isInitialized = refreshOk;
    if(m_Logger && m_isInitialized) m_Logger->LogInfo("CPatternDetector initialized successfully for " + m_Symbol);
    else if (m_Logger && !m_isInitialized) m_Logger->LogError("CPatternDetector initialization failed for " + m_Symbol);

    return refreshOk;
}

// Hàm SetLogger và SetSwingPointDetector có thể không cần thiết nữa nếu chúng luôn được lấy từ context trong Initialize
// Tuy nhiên, vẫn giữ lại SetLogger để có thể thay đổi logger sau này nếu cần (ít khả năng)
void CPatternDetector::SetLogger(CLogger* logger) {
    m_Logger = logger;
}

//+------------------------------------------------------------------+
//| Giải phóng tài nguyên                                            |
//+------------------------------------------------------------------+
void CPatternDetector::Release() {
    if (m_atrHandle != INVALID_HANDLE) {
        IndicatorRelease(m_atrHandle);
        m_atrHandle = INVALID_HANDLE;
    }
    
    m_isInitialized = false;
}

//+------------------------------------------------------------------+
//| Làm mới dữ liệu từ thị trường                                    |
//+------------------------------------------------------------------+
bool CPatternDetector::RefreshData(int bars = 100) {
    if (bars < m_maxBarsForPattern) {
        bars = m_maxBarsForPattern * 2;  // Đảm bảo lấy đủ dữ liệu
    }
    
    // Đảm bảo kích thước mảng phù hợp
    ArrayResize(m_high, bars);
    ArrayResize(m_low, bars);
    ArrayResize(m_close, bars);
    ArrayResize(m_open, bars);
    ArrayResize(m_volume, bars);
    ArrayResize(m_atrBuffer, bars);
    ArrayResize(m_time, bars);
    
    // Copy dữ liệu giá
    if (CopyHigh(m_Symbol, m_Timeframe, 0, bars, m_high) != bars) {
        if (m_Logger != NULL) m_Logger->LogError("Không thể copy dữ liệu giá high");
        return false;
    }
    
    if (CopyLow(m_Symbol, m_Timeframe, 0, bars, m_low) != bars) {
        if (m_Logger != NULL) m_Logger->LogError("Không thể copy dữ liệu giá low");
        return false;
    }
    
    if (CopyClose(m_Symbol, m_Timeframe, 0, bars, m_close) != bars) {
        if (m_Logger != NULL) m_Logger->LogError("Không thể copy dữ liệu giá close");
        return false;
    }
    
    if (CopyOpen(m_Symbol, m_Timeframe, 0, bars, m_open) != bars) {
        if (m_Logger != NULL) m_Logger->LogError("Không thể copy dữ liệu giá open");
        return false;
    }
    
    // Copy dữ liệu khối lượng nếu cần
    if (m_useVolume) {
        if (CopyTickVolume(m_Symbol, m_Timeframe, 0, bars, m_volume) != bars) {
            if (m_Logger != NULL) {
                m_Logger->LogDebug("Volume không khả dụng cho " + m_Symbol);
                m_useVolume = false;  // Tắt sử dụng volume nếu không có dữ liệu
            }
        }
    }
    
    // Copy dữ liệu ATR
    if (m_atrHandle != INVALID_HANDLE) {
        if (CopyBuffer(m_atrHandle, 0, 0, bars, m_atrBuffer) != bars) {
            if (m_Logger != NULL) m_Logger->LogWarning("Không thể copy dữ liệu ATR");
        }
        else {
            // Cập nhật ATR hiện tại
            m_atr = m_atrBuffer[0];
        }
    }
    
    // Copy dữ liệu thởi gian
    if (CopyTime(m_Symbol, m_Timeframe, 0, bars, m_time) != bars) {
        if (m_Logger != NULL) m_Logger->LogError("Không thể copy dữ liệu thời gian");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Thiết lập giá trị ATR từ bên ngoài                               |
//+------------------------------------------------------------------+
void CPatternDetector::SetATR(double atr) {
    m_atr = atr;
}

//| Phát hiện mẫu hình và trả về thông tin                           |
//+------------------------------------------------------------------+
bool CPatternDetector::DetectPattern(ENUM_PATTERN_TYPE& scenario, double& strength) {
    if (!m_isInitialized || m_atr <= 0) {
        if (m_Logger != NULL) m_Logger->LogError("PatternDetector chưa được khởi tạo đúng cách hoặc ATR không hợp lệ");
        scenario = PATTERN_NONE;
        strength = 0.0;
        return false;
    }
    
    // Phát hiện các loại mẫu hình
    bool foundPattern = false;
    
    // Khởi tạo các giá trị mặc định
    scenario = PATTERN_NONE;
    strength = 0.0;
    
    // Kiểm tra mẫu hình Pullback
    if (DetectPullbackPatterns()) {
        scenario = m_detectedPullback.type;
        strength = m_detectedPullback.strength;
        m_lastDetectedPattern = m_detectedPullback;
        foundPattern = true;
    }
    // Kiểm tra mẫu hình Reversal nếu không tìm thấy Pullback
    else if (DetectReversalPatterns()) {
        scenario = m_detectedReversal.type;
        strength = m_detectedReversal.strength;
        m_lastDetectedPattern = m_detectedReversal;
        foundPattern = true;
    }
    // Kiểm tra mẫu hình Harmonic nếu không tìm thấy cả hai
    else if (DetectHarmonicPatterns()) {
        scenario = m_detectedHarmonic.type;
        strength = m_detectedHarmonic.strength;
        m_lastDetectedPattern = m_detectedHarmonic;
        foundPattern = true;
    }
    
    return foundPattern;
}

//+------------------------------------------------------------------+
//| Ghi Log thông tin mẫu hình                                       |
//+------------------------------------------------------------------+
void CPatternDetector::LogPattern(string patternName, bool isValid, string description = "") {
    if (m_Logger != NULL) {
        if (isValid) {
            m_Logger->LogDebug("Phát hiện mẫu hình: " + patternName + ", " + description);
        } else {
            m_Logger->LogDebug("Kiểm tra mẫu hình không hợp lệ: " + patternName);
        }
    }
}

//+------------------------------------------------------------------+
//| Tính toán độ mạnh của mẫu hình dựa trên nhiều yếu tố             |
//+------------------------------------------------------------------+
double CPatternDetector::CalculatePatternStrength(ApexPullback::DetectedPattern& pattern) {
    // Giá trị cơ sở cho độ mạnh
    double strength = 0.5;
    
    // Điều chỉnh dựa trên loại mẫu hình
    switch (pattern.type) {
        case SCENARIO_STRONG_PULLBACK:
            strength = 0.8;
            break;
        case SCENARIO_FIBONACCI_PULLBACK:
            strength = 0.75;
            break;
        case SCENARIO_BULLISH_PULLBACK:
        case SCENARIO_BEARISH_PULLBACK:
            strength = 0.7;
            break;
        case SCENARIO_HARMONIC_PATTERN:
            strength = 0.75;
            break;
        case SCENARIO_MOMENTUM_SHIFT:
            strength = 0.65;
            break;
        default:
            strength = 0.5;
            break;
    }
    
    // Điều chỉnh dựa trên Risk:Reward
    double riskReward = MathAbs(pattern.takeProfit - pattern.entryLevel) / 
                      MathAbs(pattern.stopLoss - pattern.entryLevel);
    
    if (riskReward > 3.0) strength *= 1.2;
    else if (riskReward > 2.0) strength *= 1.1;
    else if (riskReward < 1.0) strength *= 0.8;
    
    // Điều chỉnh dựa trên số nến trong mẫu hình
    int patternLength = pattern.startBar - pattern.endBar;
    if (patternLength > 15) strength *= 0.9;
    else if (patternLength < 5) strength *= 0.95;
    
    // Giới hạn độ mạnh trong khoảng [0.0, 1.0]
    return MathMin(MathMax(strength, 0.0), 1.0);
}

//+------------------------------------------------------------------+
//| Tìm điểm swing high gần nhất                                     |
//+------------------------------------------------------------------+
int CPatternDetector::FindLastSwingHigh(int startBar, int lookback) {
    double highestHigh = -DBL_MAX;
    int highestBar = -1;
    
    if (startBar + lookback >= ArraySize(m_high) || startBar < 0) {
        lookback = MathMin(lookback, ArraySize(m_high) - startBar - 1);
    }
    
    // Tìm đỉnh cao nhất
    for (int i = startBar; i <= startBar + lookback; i++) {
        if (m_high[i] > highestHigh) {
            highestHigh = m_high[i];
            highestBar = i;
        }
    }
    
    return highestBar;
}

//+------------------------------------------------------------------+
//| Tìm điểm swing low gần nhất                                      |
//+------------------------------------------------------------------+
int CPatternDetector::FindLastSwingLow(int startBar, int lookback) {
    double lowestLow = DBL_MAX;
    int lowestBar = -1;
    
    if (startBar + lookback >= ArraySize(m_low) || startBar < 0) {
        lookback = MathMin(lookback, ArraySize(m_low) - startBar - 1);
    }
    
    // Tìm đáy thấp nhất
    for (int i = startBar; i <= startBar + lookback; i++) {
        if (m_low[i] < lowestLow) {
            lowestLow = m_low[i];
            lowestBar = i;
        }
    }
    
    return lowestBar;
}

//+------------------------------------------------------------------+
//| Tìm điểm swing (high hoặc low) và trả về vị trí nến              |
//+------------------------------------------------------------------+
int CPatternDetector::FindSwingPoint(bool findHigh, int startBar, int lookback, double& price) {
    if (findHigh) {
        int bar = FindLastSwingHigh(startBar, lookback);
        if (bar >= 0) {
            price = m_high[bar];
            return bar;
        }
    } else {
        int bar = FindLastSwingLow(startBar, lookback);
        if (bar >= 0) {
            price = m_low[bar];
            return bar;
        }
    }
    
    return -1;
}

//+------------------------------------------------------------------+
//| Tính toán mức Fibonacci Retracement                              |
//+------------------------------------------------------------------+
double CPatternDetector::CalculateFibonacciRetracementLevel(double startPrice, double endPrice, double retracementRatio, bool isBullish) {
    if (isBullish) {
        // Trong xu hướng tăng: Từ low đến high
        return endPrice - (endPrice - startPrice) * retracementRatio;
    } else {
        // Trong xu hướng giảm: Từ high đến low
        return startPrice - (startPrice - endPrice) * retracementRatio;
    }
}

//+------------------------------------------------------------------+
//| Phát hiện các mẫu hình pullback                                  |
//+------------------------------------------------------------------+
bool CPatternDetector::DetectPullbackPatterns() {
    // Khởi tạo mẫu hình với các giá trị mặc định
    m_detectedPullback.Initialize();
    
    // Kiểm tra các loại mẫu hình pullback
    if (DetectPullbackPattern(true, m_detectedPullback)) {
        return true;
    }
    else if (DetectPullbackPattern(false, m_detectedPullback)) {
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Phát hiện các mẫu hình đảo chiều                                  |
//+------------------------------------------------------------------+
bool CPatternDetector::DetectReversalPatterns() {
    // Khởi tạo mẫu hình với các giá trị mặc định
    m_detectedReversal.Initialize();
    
    // Kiểm tra các mẫu hình đảo chiều nến
    if (CheckEngulfingPattern(true, m_detectedReversal)) {
        return true;
    }
    else if (CheckEngulfingPattern(false, m_detectedReversal)) {
        return true;
    }
    else if (CheckPinbarPattern(true, m_detectedReversal)) {
        return true;
    }
    else if (CheckPinbarPattern(false, m_detectedReversal)) {
        return true;
    }
    else if (CheckDivergencePattern(true, m_detectedReversal)) {
        return true;
    }
    else if (CheckDivergencePattern(false, m_detectedReversal)) {
        return true;
    }
    else if (CheckDoubleTopBottomPattern(true, m_detectedReversal)) {
        return true;
    }
    else if (CheckDoubleTopBottomPattern(false, m_detectedReversal)) {
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Phát hiện các mẫu hình harmonic                                   |
//+------------------------------------------------------------------+
bool CPatternDetector::DetectHarmonicPatterns() {
    // Khởi tạo mẫu hình với các giá trị mặc định
    m_detectedHarmonic.Initialize();
    
    // Kiểm tra các loại mẫu hình harmonic
    if (CheckGartleyPattern(true, m_detectedHarmonic)) {
        return true;
    }
    else if (CheckGartleyPattern(false, m_detectedHarmonic)) {
        return true;
    }
    else if (CheckButterflyPattern(true, m_detectedHarmonic)) {
        return true;
    }
    else if (CheckButterflyPattern(false, m_detectedHarmonic)) {
        return true;
    }
    else if (CheckBatPattern(true, m_detectedHarmonic)) {
        return true;
    }
    else if (CheckBatPattern(false, m_detectedHarmonic)) {
        return true;
    }
    else if (CheckCrabPattern(true, m_detectedHarmonic)) {
        return true;
    }
    else if (CheckCrabPattern(false, m_detectedHarmonic)) {
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Kiểm tra xem tỷ lệ pullback có hợp lệ không                        |
//+------------------------------------------------------------------+
bool CPatternDetector::IsValidPullbackDepth(double highPrice, double lowPrice, double& ratio) {
    double range = MathAbs(highPrice - lowPrice);
    if (range <= 0) {
        return false;
    }
    
    ratio = 100.0 * range / ((highPrice + lowPrice) / 2.0);
    
    return (ratio >= m_minPullbackPct && ratio <= m_maxPullbackPct);
}

//+------------------------------------------------------------------+
//| Kiểm tra tỷ lệ Fibonacci có nằm trong khoảng dung sai              |
//+------------------------------------------------------------------+
bool CPatternDetector::IsValidFibonacciRatio(double ratio, double targetRatio) {
    return (MathAbs(ratio - targetRatio) <= m_fibTolerance);
}

//+------------------------------------------------------------------+
//| Kiểm tra xu hướng tăng                                           |
//+------------------------------------------------------------------+
bool CPatternDetector::IsUptrend(int startBar, int endBar) {
    if (startBar < 0 || endBar < 0 || startBar >= ArraySize(m_close) || endBar >= ArraySize(m_close)) {
        return false;
    }
    
    // Xu hướng tăng đơn giản là giá đóng cửa cuối kỳ > giá đóng cửa đầu kỳ
    // Có thể thêm nhiều điều kiện phức tạp hơn ở đây
    return (m_close[endBar] > m_close[startBar]);
}

//+------------------------------------------------------------------+
//| Kiểm tra xu hướng giảm                                           |
//+------------------------------------------------------------------+
bool CPatternDetector::IsDowntrend(int startBar, int endBar) {
    if (startBar < 0 || endBar < 0 || startBar >= ArraySize(m_close) || endBar >= ArraySize(m_close)) {
        return false;
    }
    
    // Xu hướng giảm đơn giản là giá đóng cửa cuối kỳ < giá đóng cửa đầu kỳ
    // Có thể thêm nhiều điều kiện phức tạp hơn ở đây
    return (m_close[endBar] < m_close[startBar]);
}

//+------------------------------------------------------------------+
//| Kiểm tra mẫu hình pullback mạnh (Strong Pullback)                 |
//+------------------------------------------------------------------+
bool CPatternDetector::CheckStrongPullback(bool isBullish, ApexPullback::DetectedPattern& pattern) {
    // Khởi tạo mẫu hình
    pattern.Initialize();
    pattern.isBullish = isBullish;
    pattern.type = SCENARIO_STRONG_PULLBACK;
    pattern.description = isBullish ? "Strong Bullish Pullback" : "Strong Bearish Pullback";
    
    // Khởi tạo các biến
    int lookbackBars = 20;
    
    // Kích thước tối thiểu phù hợp với tầm nhìn giao dịch
    if (ArraySize(m_high) < lookbackBars + 5) {
        LogPattern(pattern.description, false, "Không đủ dữ liệu");
        return false;
    }
    
    // Định vị swing points
    double swingPrice = 0.0;
    int swingBar = -1;
    
    // Tìm swing high/low quan trọng
    if (isBullish) {
        // Tìm swing low trước khi tăng
        swingBar = FindLastSwingLow(0, lookbackBars);
        if (swingBar < 0) {
            LogPattern(pattern.description, false, "Không tìm thấy swing low phù hợp");
            return false;
        }
        swingPrice = m_low[swingBar];
    } else {
        // Tìm swing high trước khi giảm
        swingBar = FindLastSwingHigh(0, lookbackBars);
        if (swingBar < 0) {
            LogPattern(pattern.description, false, "Không tìm thấy swing high phù hợp");
            return false;
        }
        swingPrice = m_high[swingBar];
    }
    
    // Kiểm tra xu hướng chính
    bool isMainTrend = isBullish ? IsUptrend(swingBar, 0) : IsDowntrend(swingBar, 0);
    if (!isMainTrend) {
        LogPattern(pattern.description, false, "Không có xu hướng chính rõ ràng");
        return false;
    }
    
    // Tìm điểm bắt đầu và kết thúc pullback
    int pullbackStartBar = -1;
    int pullbackEndBar = -1;
    double pullbackStartPrice = 0.0;
    double pullbackEndPrice = 0.0;
    
    if (isBullish) {
        // Sau swing low, tìm mức cao gần đây (điểm bắt đầu pullback)
        pullbackStartBar = FindLastSwingHigh(0, swingBar);
        if (pullbackStartBar < 0 || pullbackStartBar >= swingBar) {
            LogPattern(pattern.description, false, "Không tìm thấy điểm bắt đầu pullback");
            return false;
        }
        pullbackStartPrice = m_high[pullbackStartBar];
        
        // Tìm mức thấp kể từ điểm bắt đầu pullback (điểm kết thúc pullback)
        pullbackEndBar = FindLastSwingLow(0, pullbackStartBar);
        if (pullbackEndBar < 0 || pullbackEndBar >= pullbackStartBar) {
            LogPattern(pattern.description, false, "Không tìm thấy điểm kết thúc pullback");
            return false;
        }
        pullbackEndPrice = m_low[pullbackEndBar];
        
        // Kiểm tra mức pullback hợp lệ (không quá sâu, không quá nông)
        double retracementRatio = (pullbackStartPrice - pullbackEndPrice) / (pullbackStartPrice - swingPrice);
        if (retracementRatio < 0.3 || retracementRatio > 0.7) {
            LogPattern(pattern.description, false, "Mức pullback không hợp lệ: " + DoubleToString(retracementRatio, 2));
            return false;
        }
        
        // Kiểm tra momentum
        bool hasMomentumSupport = false;
        // Lấy dữ liệu RSI để kiểm tra (giả định đã có giá trị RSI)
        double rsiValue = 50.0; // Cần lấy giá trị thực từ indicator
        
        // RSI đang tăng từ vùng oversold
        if (rsiValue > 40 && rsiValue < 60) {
            hasMomentumSupport = true;
        }
        
        if (!hasMomentumSupport) {
            LogPattern(pattern.description, false, "Không có xác nhận momentum");
            return false;
        }
        
        // Kiểm tra khối lượng (nếu có dữ liệu)
        bool hasVolumeConfirmation = true;
        if (m_useVolume) {
            // Khối lượng giảm trong pullback, tăng khi xác nhận xu hướng
            double avgVolume = (m_volume[1] + m_volume[2] + m_volume[3]) / 3.0;
            double pullbackVolume = (m_volume[pullbackEndBar] + m_volume[pullbackEndBar + 1]) / 2.0;
            
            if (pullbackVolume > avgVolume) {
                hasVolumeConfirmation = false;
                LogPattern(pattern.description, false, "Volume không xác nhận (quá cao trong pullback)");
                return false;
            }
        }
        
        // Kiểm tra nến xác nhận
        bool hasConfirmationCandle = false;
        
        // Nến gần nhất phải có thân dài và đóng cửa gần mức cao
        double bodySize = MathAbs(m_close[0] - m_open[0]);
        double candleRange = m_high[0] - m_low[0];
        
        if (bodySize > 0.6 * candleRange && m_close[0] > m_open[0]) {
            hasConfirmationCandle = true;
        }
        
        if (!hasConfirmationCandle) {
            LogPattern(pattern.description, false, "Không có nến xác nhận");
            return false;
        }
        
        // Thiết lập giá trị mẫu hình
        pattern.startBar = swingBar;
        pattern.endBar = 0;
        pattern.entryLevel = m_close[0];
        pattern.stopLoss = pullbackEndPrice - m_atr * 0.5; // SL dưới mức pullback với buffer ATR
        pattern.takeProfit = pullbackStartPrice + (pullbackStartPrice - swingPrice) * 0.5; // TP tối thiểu 1.5R
        pattern.isValid = true;
        
    } else {
        // Sau swing high, tìm mức thấp gần đây (điểm bắt đầu pullback)
        pullbackStartBar = FindLastSwingLow(0, swingBar);
        if (pullbackStartBar < 0 || pullbackStartBar >= swingBar) {
            LogPattern(pattern.description, false, "Không tìm thấy điểm bắt đầu pullback");
            return false;
        }
        pullbackStartPrice = m_low[pullbackStartBar];
        
        // Tìm mức cao kể từ điểm bắt đầu pullback (điểm kết thúc pullback)
        pullbackEndBar = FindLastSwingHigh(0, pullbackStartBar);
        if (pullbackEndBar < 0 || pullbackEndBar >= pullbackStartBar) {
            LogPattern(pattern.description, false, "Không tìm thấy điểm kết thúc pullback");
            return false;
        }
        pullbackEndPrice = m_high[pullbackEndBar];
        
        // Kiểm tra mức pullback hợp lệ (không quá sâu, không quá nông)
        double retracementRatio = (pullbackEndPrice - pullbackStartPrice) / (swingPrice - pullbackStartPrice);
        if (retracementRatio < 0.3 || retracementRatio > 0.7) {
            LogPattern(pattern.description, false, "Mức pullback không hợp lệ: " + DoubleToString(retracementRatio, 2));
            return false;
        }
        
        // Kiểm tra momentum
        bool hasMomentumSupport = false;
        // Lấy dữ liệu RSI để kiểm tra (giả định đã có giá trị RSI)
        double rsiValue = 50.0; // Cần lấy giá trị thực từ indicator
        
        // RSI đang giảm từ vùng overbought
        if (rsiValue > 40 && rsiValue < 60) {
            hasMomentumSupport = true;
        }
        
        if (!hasMomentumSupport) {
            LogPattern(pattern.description, false, "Không có xác nhận momentum");
            return false;
        }
        
        // Kiểm tra khối lượng (nếu có dữ liệu)
        bool hasVolumeConfirmation = true;
        if (m_useVolume) {
            // Khối lượng giảm trong pullback, tăng khi xác nhận xu hướng
            double avgVolume = (m_volume[1] + m_volume[2] + m_volume[3]) / 3.0;
            double pullbackVolume = (m_volume[pullbackEndBar] + m_volume[pullbackEndBar + 1]) / 2.0;
            
            if (pullbackVolume > avgVolume) {
                hasVolumeConfirmation = false;
                LogPattern(pattern.description, false, "Volume không xác nhận (quá cao trong pullback)");
                return false;
            }
        }
        
        // Kiểm tra nến xác nhận
        bool hasConfirmationCandle = false;
        
        // Nến gần nhất phải có thân dài và đóng cửa gần mức thấp
        double bodySize = MathAbs(m_close[0] - m_open[0]);
        double candleRange = m_high[0] - m_low[0];
        
        if (bodySize > 0.6 * candleRange && m_close[0] < m_open[0]) {
            hasConfirmationCandle = true;
        }
        
        if (!hasConfirmationCandle) {
            LogPattern(pattern.description, false, "Không có nến xác nhận");
            return false;
        }
        
        // Thiết lập giá trị mẫu hình
        pattern.startBar = swingBar;
        pattern.endBar = 0;
        pattern.entryLevel = m_close[0];
        pattern.stopLoss = pullbackEndPrice + m_atr * 0.5; // SL trên mức pullback với buffer ATR
        pattern.takeProfit = pullbackStartPrice - (swingPrice - pullbackStartPrice) * 0.5; // TP tối thiểu 1.5R
        pattern.isValid = true;
    }
    
    // Tính độ mạnh mẫu hình
    if (pattern.isValid) {
        // Yếu tố tăng cường độ mạnh
        pattern.strength = 0.7; // Giá trị cơ sở
        
        // Tăng độ mạnh nếu khối lượng xác nhận
        if (m_useVolume) {
            double currentVolume = m_volume[0];
            double avgVolume = (m_volume[1] + m_volume[2] + m_volume[3]) / 3.0;
            
            if (currentVolume > avgVolume * 1.5) {
                pattern.strength += 0.1;
            }
        }
        
        // Tăng độ mạnh nếu ATR hợp lý (không quá biến động)
        if (m_atr > 0 && m_atr < m_atrBuffer[10] * 1.5) {
            pattern.strength += 0.1;
        }
        
        // Giới hạn độ mạnh trong khoảng [0, 1]
        pattern.strength = MathMin(1.0, pattern.strength);
        
        LogPattern(pattern.description, true, "Độ mạnh: " + DoubleToString(pattern.strength, 2));
    }
    
    return pattern.isValid;
}

//+------------------------------------------------------------------+
//| Kiểm tra mẫu hình Engulfing (nuốt chừng) với định nghĩa toán học chính xác |
//+------------------------------------------------------------------+
bool CPatternDetector::CheckEngulfingPattern(bool isBullish, ApexPullback::DetectedPattern& pattern) {
    // Kiểm tra đủ dữ liệu
    if (ArraySize(m_high) < 3 || ArraySize(m_low) < 3 || ArraySize(m_open) < 3 || ArraySize(m_close) < 3) {
        return false;
    }
    
    pattern.Initialize();
    pattern.isBullish = isBullish;
    pattern.type = SCENARIO_CUSTOM;
    pattern.description = isBullish ? "Bullish Engulfing" : "Bearish Engulfing";
    
    // Lấy dữ liệu 2 nến: nến hiện tại [0] và nến trước [1]
    double currentOpen = m_open[0];
    double currentClose = m_close[0];
    double currentHigh = m_high[0];
    double currentLow = m_low[0];
    
    double prevOpen = m_open[1];
    double prevClose = m_close[1];
    double prevHigh = m_high[1];
    double prevLow = m_low[1];
    
    // Tính toán kích thước thân nến
    double currentBodySize = MathAbs(currentClose - currentOpen);
    double prevBodySize = MathAbs(prevClose - prevOpen);
    double currentRange = currentHigh - currentLow;
    double prevRange = prevHigh - prevLow;
    
    // Điều kiện cơ bản: thân nến hiện tại phải đủ lớn
    if (currentBodySize < m_atr * 0.3 || currentRange < m_atr * 0.5) {
        LogPattern(pattern.description, false, "Thân nến hiện tại quá nhỏ");
        return false;
    }
    
    bool validEngulfing = false;
    
    if (isBullish) {
        // Bullish Engulfing - Định nghĩa toán học chính xác:
        // 1. Nến trước phải là nến giảm (prevClose < prevOpen)
        // 2. Nến hiện tại phải là nến tăng (currentClose > currentOpen)
        // 3. Thân nến hiện tại phải "nuốt chửng" hoàn toàn thân nến trước:
        //    - currentOpen <= prevClose (mở cửa thấp hơn hoặc bằng đóng cửa nến trước)
        //    - currentClose >= prevOpen (đóng cửa cao hơn hoặc bằng mở cửa nến trước)
        // 4. Thân nến hiện tại phải lớn hơn thân nến trước ít nhất 50%
        
        bool prevIsBearish = prevClose < prevOpen;
        bool currentIsBullish = currentClose > currentOpen;
        bool bodyEngulfment = (currentOpen <= prevClose) && (currentClose >= prevOpen);
        bool sizeRequirement = currentBodySize >= prevBodySize * 1.5;
        
        // Điều kiện bổ sung: kiểm tra khối lượng (nếu có)
        bool volumeConfirmation = true;
        if (m_useVolume && ArraySize(m_volume) > 1) {
            volumeConfirmation = m_volume[0] > m_volume[1] * 1.2; // Khối lượng tăng 20%
        }
        
        // Điều kiện về vị trí trong xu hướng
        bool trendContext = true;
        if (ArraySize(m_close) > 10) {
            double ema20 = CalculateEMA(20, 0);
            trendContext = currentLow > ema20 * 0.995; // Gần hoặc trên EMA20
        }
        
        validEngulfing = prevIsBearish && currentIsBullish && bodyEngulfment && 
                        sizeRequirement && volumeConfirmation && trendContext;
        
        if (validEngulfing) {
            pattern.entryLevel = currentClose;
            pattern.stopLoss = MathMin(currentLow, prevLow) - m_atr * 0.5;
            pattern.takeProfit = currentClose + (currentClose - pattern.stopLoss) * 2.0;
            pattern.strength = 0.8;
            
            // Tăng độ mạnh nếu có xác nhận bổ sung
            if (volumeConfirmation) pattern.strength += 0.1;
            if (currentBodySize >= prevBodySize * 2.0) pattern.strength += 0.1;
        }
        
    } else {
        // Bearish Engulfing - Định nghĩa toán học chính xác:
        // 1. Nến trước phải là nến tăng (prevClose > prevOpen)
        // 2. Nến hiện tại phải là nến giảm (currentClose < currentOpen)
        // 3. Thân nến hiện tại phải "nuốt chửng" hoàn toàn thân nến trước:
        //    - currentOpen >= prevClose (mở cửa cao hơn hoặc bằng đóng cửa nến trước)
        //    - currentClose <= prevOpen (đóng cửa thấp hơn hoặc bằng mở cửa nến trước)
        // 4. Thân nến hiện tại phải lớn hơn thân nến trước ít nhất 50%
        
        bool prevIsBullish = prevClose > prevOpen;
        bool currentIsBearish = currentClose < currentOpen;
        bool bodyEngulfment = (currentOpen >= prevClose) && (currentClose <= prevOpen);
        bool sizeRequirement = currentBodySize >= prevBodySize * 1.5;
        
        // Điều kiện bổ sung: kiểm tra khối lượng (nếu có)
        bool volumeConfirmation = true;
        if (m_useVolume && ArraySize(m_volume) > 1) {
            volumeConfirmation = m_volume[0] > m_volume[1] * 1.2;
        }
        
        // Điều kiện về vị trí trong xu hướng
        bool trendContext = true;
        if (ArraySize(m_close) > 10) {
            double ema20 = CalculateEMA(20, 0);
            trendContext = currentHigh < ema20 * 1.005; // Gần hoặc dưới EMA20
        }
        
        validEngulfing = prevIsBullish && currentIsBearish && bodyEngulfment && 
                        sizeRequirement && volumeConfirmation && trendContext;
        
        if (validEngulfing) {
            pattern.entryLevel = currentClose;
            pattern.stopLoss = MathMax(currentHigh, prevHigh) + m_atr * 0.5;
            pattern.takeProfit = currentClose - (pattern.stopLoss - currentClose) * 2.0;
            pattern.strength = 0.8;
            
            // Tăng độ mạnh nếu có xác nhận bổ sung
            if (volumeConfirmation) pattern.strength += 0.1;
            if (currentBodySize >= prevBodySize * 2.0) pattern.strength += 0.1;
        }
    }
    
    pattern.isValid = validEngulfing;
    
    if (pattern.isValid) {
        pattern.startBar = 1;
        pattern.endBar = 0;
        LogPattern(pattern.description, true, StringFormat("Độ mạnh: %.2f, Body ratio: %.2f", 
                  pattern.strength, currentBodySize / prevBodySize));
    } else {
        LogPattern(pattern.description, false, "Không đáp ứng điều kiện Engulfing");
    }
    
    return pattern.isValid;
}

//+------------------------------------------------------------------+
//| Kiểm tra mẫu hình Gartley                                         |
//+------------------------------------------------------------------+
bool CPatternDetector::CheckGartleyPattern(bool isBullish, ApexPullback::DetectedPattern& pattern) {
    // Triển khai mã để kiểm tra mẫu hình Gartley
    pattern.Initialize();
    pattern.isBullish = isBullish;
    pattern.type = SCENARIO_HARMONIC_PATTERN;
    pattern.description = isBullish ? "Bullish Gartley" : "Bearish Gartley";
    
    // Cần triển khai logic để kiểm tra mẫu hình Gartley
    // Giả định mẫu hình này chưa được hỗ trợ đầy đủ
    pattern.isValid = false;
    
    if (pattern.isValid) {
        // Tính toán độ mạnh của mẫu hình
        pattern.strength = CalculatePatternStrength(pattern);
        
        // Ghi log
        LogPattern(pattern.description, true);
    }
    
    return pattern.isValid;
}

//+------------------------------------------------------------------+
//| Kiểm tra mẫu hình Butterfly                                      |
//+------------------------------------------------------------------+
bool CPatternDetector::CheckButterflyPattern(bool isBullish, ApexPullback::DetectedPattern& pattern) {
    // Triển khai mã để kiểm tra mẫu hình Butterfly
    pattern.Initialize();
    pattern.isBullish = isBullish;
    pattern.type = SCENARIO_HARMONIC_PATTERN;
    pattern.description = isBullish ? "Bullish Butterfly" : "Bearish Butterfly";
    
    // Cần triển khai logic để kiểm tra mẫu hình Butterfly
    // Giả định mẫu hình này chưa được hỗ trợ đầy đủ
    pattern.isValid = false;
    
    if (pattern.isValid) {
        // Tính toán độ mạnh của mẫu hình
        pattern.strength = CalculatePatternStrength(pattern);
        
        // Ghi log
        LogPattern(pattern.description, true);
    }
    
    return pattern.isValid;
}

//+------------------------------------------------------------------+
//| Kiểm tra mẫu hình Bat                                            |
//+------------------------------------------------------------------+
bool CPatternDetector::CheckBatPattern(bool isBullish, ApexPullback::DetectedPattern& pattern) {
    // Triển khai mã để kiểm tra mẫu hình Bat
    pattern.Initialize();
    pattern.isBullish = isBullish;
    pattern.type = SCENARIO_HARMONIC_PATTERN;
    pattern.description = isBullish ? "Bullish Bat" : "Bearish Bat";
    
    // Cần triển khai logic để kiểm tra mẫu hình Bat
    // Giả định mẫu hình này chưa được hỗ trợ đầy đủ
    pattern.isValid = false;
    
    if (pattern.isValid) {
        // Tính toán độ mạnh của mẫu hình
        pattern.strength = CalculatePatternStrength(pattern);
        
        // Ghi log
        LogPattern(pattern.description, true);
    }
    
    return pattern.isValid;
}

//+------------------------------------------------------------------+
//| Kiểm tra mẫu hình Crab                                           |
//+------------------------------------------------------------------+
bool CPatternDetector::CheckCrabPattern(bool isBullish, ApexPullback::DetectedPattern& pattern) {
    // Triển khai mã để kiểm tra mẫu hình Crab
    pattern.Initialize();
    pattern.isBullish = isBullish;
    pattern.type = SCENARIO_HARMONIC_PATTERN;
    pattern.description = isBullish ? "Bullish Crab" : "Bearish Crab";
    
    // Cần triển khai logic để kiểm tra mẫu hình Crab
    // Giả định mẫu hình này chưa được hỗ trợ đầy đủ
    pattern.isValid = false;
    
    if (pattern.isValid) {
        // Tính toán độ mạnh của mẫu hình
        pattern.strength = CalculatePatternStrength(pattern);
        
        // Ghi log
        LogPattern(pattern.description, true);
    }
    
    return pattern.isValid;
}

//+------------------------------------------------------------------+
//| Cài đặt bộ lọc pullback chặt chẽ                                   |
//+------------------------------------------------------------------+
void CPatternDetector::SetStrictPullbackFilter(bool enable, int minConfirmationBars = 2, int maxRejectionCount = 1) {
    m_StrictPullbackFilter = enable;
    m_MinConfirmationBars = minConfirmationBars;
    m_MaxRejectionCount = maxRejectionCount;
    
    if (m_Logger != NULL) {
        m_Logger.LogInfo("PatternDetector: " + (enable ? "Bật" : "Tắt") + " bộ lọc pullback chặt chẽ");
    }
}

bool CPatternDetector::DetectPullbackPattern(bool isBullish, ApexPullback::DetectedPattern& pattern) {
    pattern.Initialize(); // Khởi tạo pattern
    pattern.isBullish = isBullish;
    pattern.type = isBullish ? SCENARIO_BULLISH_PULLBACK : SCENARIO_BEARISH_PULLBACK;

    // BỘ LỌC CHỐNG SIDEWAY CỨNG - Bước 1: Kích hoạt bộ lọc một cách tường minh
    if (m_MarketProfile != NULL) {
        // Lấy market regime từ context (đã được cập nhật bởi MarketProfile)
        ENUM_MARKET_REGIME currentRegime = m_context->CurrentMarketRegime;
        
        // Từ chối hoàn toàn pullback khi thị trường đi ngang
        if (currentRegime == REGIME_RANGING_STABLE || 
            currentRegime == REGIME_RANGING_VOLATILE || 
            currentRegime == REGIME_VOLATILE_CONTRACTION) {
            LogPattern("Pullback", false, "Bị từ chối do thị trường đang đi ngang/tích lũy.");
            return false;
        }
    }

    // Kiểm tra đủ dữ liệu
    int requiredBars = m_maxBarsForPattern;
    if (m_high.Size() < requiredBars || m_low.Size() < requiredBars || m_close.Size() < requiredBars) {
        LogPattern("Pullback", false, "Không đủ dữ liệu");
        return false;
    }

    // Điều kiện 1: Kiểm tra cấu trúc thị trường từ SwingPointDetector
    if (m_SwingPointDetector == NULL) {
        LogPattern("Pullback", false, "SwingPointDetector chưa được thiết lập");
        return false;
    }

    MarketRegimeInfo regimeInfo = m_SwingPointDetector.GetMarketRegimeInfo(); // Lấy thông tin Market Regime
    int hhCount = 0;
    int hlCount = 0;
    int lhCount = 0;
    int llCount = 0;

    SwingPoint swings[10]; // Mảng để lưu trữ các swing points
    int numSwings = m_SwingPointDetector.GetSwingPoints(swings, 10); // Lấy tối đa 10 swing gần nhất

    if (numSwings < 4) { // Cần ít nhất 2 high và 2 low để xác định xu hướng (2 HH và 2 HL hoặc 2 LH và 2 LL)
        LogPattern("Pullback", false, "Không đủ swing points để xác định xu hướng (< 4)");
        return false;
    }

    // Logic đếm HH, HL, LH, LL
    // Giả định mảng swings được trả về theo thứ tự thời gian giảm dần (mới nhất ở index 0)
    double lastHighPrice = 0, prevHighPrice = 0;
    double lastLowPrice = 0, prevLowPrice = 0;
    int highSwingsFound = 0;
    int lowSwingsFound = 0;

    for (int i = 0; i < numSwings; i++) {
        if (swings[i].type == SWING_HIGH) {
            highSwingsFound++;
            if (highSwingsFound == 1) {
                lastHighPrice = swings[i].price;
            } else if (highSwingsFound == 2) {
                prevHighPrice = lastHighPrice;
                lastHighPrice = swings[i].price;
                if (lastHighPrice > prevHighPrice) hhCount++;
                else if (lastHighPrice < prevHighPrice) lhCount++;
            } else if (highSwingsFound > 2) {
                 prevHighPrice = lastHighPrice;
                 lastHighPrice = swings[i].price;
                 if (lastHighPrice > prevHighPrice) hhCount++;
                 else if (lastHighPrice < prevHighPrice) lhCount++;
            }
        }
        if (swings[i].type == SWING_LOW) {
            lowSwingsFound++;
            if (lowSwingsFound == 1) {
                lastLowPrice = swings[i].price;
            } else if (lowSwingsFound == 2) {
                prevLowPrice = lastLowPrice;
                lastLowPrice = swings[i].price;
                if (lastLowPrice > prevLowPrice) hlCount++;
                else if (lastLowPrice < prevLowPrice) llCount++;
            } else if (lowSwingsFound > 2) {
                prevLowPrice = lastLowPrice;
                lastLowPrice = swings[i].price;
                if (lastLowPrice > prevLowPrice) hlCount++;
                else if (lastLowPrice < prevLowPrice) llCount++;
            }
        }
    }

    bool isConfirmedUptrend = (isBullish && hhCount >= 2 && hlCount >= 2);
    bool isConfirmedDowntrend = (!isBullish && lhCount >= 2 && llCount >= 2);

    if (!isConfirmedUptrend && !isConfirmedDowntrend) {
        LogPattern("Pullback", false, StringFormat("Không có xu hướng được xác nhận. Bullish: %s (HH:%d, HL:%d). Bearish: %s (LH:%d, LL:%d)", 
                                                isBullish ? "true" : "false", hhCount, hlCount, 
                                                !isBullish ? "true" : "false", lhCount, llCount));
        return false;
    }

    // Lấy Swing High/Low gần nhất cho sóng đẩy
    SwingPoint impulseWaveStartSwing, impulseWaveEndSwing;
    bool foundImpulseWaveStart = false;
    bool foundImpulseWaveEnd = false;

    if (isBullish) { // Xu hướng tăng, sóng đẩy từ Swing Low -> Swing High
        // Tìm Swing Low gần nhất làm điểm bắt đầu sóng đẩy (impulseWaveStartSwing)
        for (int i = 0; i < numSwings; i++) {
            if (swings[i].type == SWING_LOW) {
                impulseWaveStartSwing = swings[i];
                foundImpulseWaveStart = true;
                break; 
            }
        }
        // Tìm Swing High gần nhất (sau impulseWaveStartSwing) làm điểm kết thúc sóng đẩy (impulseWaveEndSwing)
        // Hoặc nếu chưa có Swing High rõ ràng sau đó, có thể là giá cao nhất hiện tại
        for (int i = 0; i < numSwings; i++) {
            if (swings[i].type == SWING_HIGH && swings[i].time > impulseWaveStartSwing.time) {
                impulseWaveEndSwing = swings[i];
                foundImpulseWaveEnd = true;
                break;
            }
        }
        if (!foundImpulseWaveEnd) { // Nếu không có swing high nào sau swing low, tìm giá cao nhất kể từ sau impulseWaveStartSwing
            double tempHighestPrice = impulseWaveStartSwing.price;
            datetime tempHighestTime = impulseWaveStartSwing.time;
            int tempHighestBarIndex = impulseWaveStartSwing.barIndex;
            bool potentialEndFound = false;
            // Duyệt ngược từ nến ngay trước nến hiện tại (index 1) đến nến sau impulseWaveStartSwing
            for (int k = 1; k < Bars(m_Symbol,m_Timeframe) - impulseWaveStartSwing.barIndex && k < 200; k++) { 
                int checkBar = impulseWaveStartSwing.barIndex - k; // barIndex giảm dần khi đi về quá khứ
                if (checkBar < 0) break; // Không đi quá xa
                if (m_time[checkBar] <= impulseWaveStartSwing.time) continue; 

                if (m_high[checkBar] > tempHighestPrice) {
                    tempHighestPrice = m_high[checkBar];
                    tempHighestTime = m_time[checkBar];
                    tempHighestBarIndex = checkBar;
                    potentialEndFound = true;
                }
                 // Nếu giá bắt đầu giảm sau khi tạo đỉnh thì có thể đó là SH
                if (potentialEndFound && m_high[checkBar] < tempHighestPrice && (tempHighestPrice - m_high[checkBar] > m_atr * 0.5) ) break; 
            }
            if (potentialEndFound && tempHighestPrice > impulseWaveStartSwing.price) {
                impulseWaveEndSwing.price = tempHighestPrice;
                impulseWaveEndSwing.time = tempHighestTime;
                impulseWaveEndSwing.barIndex = tempHighestBarIndex;
                impulseWaveEndSwing.type = SWING_HIGH; // Gán type
                foundImpulseWaveEnd = true;
            }
        }

    } else { // Xu hướng giảm, sóng đẩy từ Swing High -> Swing Low
        // Tìm Swing High gần nhất làm điểm bắt đầu sóng đẩy (impulseWaveStartSwing)
        for (int i = 0; i < numSwings; i++) {
            if (swings[i].type == SWING_HIGH) {
                impulseWaveStartSwing = swings[i];
                foundImpulseWaveStart = true;
                break; 
            }
        }
        // Tìm Swing Low gần nhất (sau impulseWaveStartSwing) làm điểm kết thúc sóng đẩy (impulseWaveEndSwing)
        for (int i = 0; i < numSwings; i++) {
            if (swings[i].type == SWING_LOW && swings[i].time > impulseWaveStartSwing.time) {
                impulseWaveEndSwing = swings[i];
                foundImpulseWaveEnd = true;
                break;
            }
        }
         if (!foundImpulseWaveEnd) { // Nếu không có swing low nào sau swing high, tìm giá thấp nhất kể từ sau impulseWaveStartSwing
            double tempLowestPrice = impulseWaveStartSwing.price;
            datetime tempLowestTime = impulseWaveStartSwing.time;
            int tempLowestBarIndex = impulseWaveStartSwing.barIndex;
            bool potentialEndFound = false;
            for (int k = 1; k < Bars(m_Symbol,m_Timeframe) - impulseWaveStartSwing.barIndex && k < 200; k++) {
                int checkBar = impulseWaveStartSwing.barIndex - k;
                if (checkBar < 0) break;
                if (m_time[checkBar] <= impulseWaveStartSwing.time) continue;

                if (m_low[checkBar] < tempLowestPrice) {
                    tempLowestPrice = m_low[checkBar];
                    tempLowestTime = m_time[checkBar];
                    tempLowestBarIndex = checkBar;
                    potentialEndFound = true;
                }
                if(potentialEndFound && m_low[checkBar] > tempLowestPrice && (m_low[checkBar] - tempLowestPrice > m_atr * 0.5) ) break;
            }
            if (potentialEndFound && tempLowestPrice < impulseWaveStartSwing.price) {
                impulseWaveEndSwing.price = tempLowestPrice;
                impulseWaveEndSwing.time = tempLowestTime;
                impulseWaveEndSwing.barIndex = tempLowestBarIndex;
                impulseWaveEndSwing.type = SWING_LOW; // Gán type
                foundImpulseWaveEnd = true;
            }
        }
    }

    if (!foundImpulseWaveStart || !foundImpulseWaveEnd) {
        LogPattern("Pullback", false, "Không tìm thấy đủ Swing Points cho sóng đẩy");
        return false;
    }
    // Đảm bảo sóng đẩy hợp lệ (start trước end)
    if (impulseWaveStartSwing.time >= impulseWaveEndSwing.time) {
        LogPattern("Pullback", false, "Sóng đẩy không hợp lệ (start time >= end time)");
        return false;
    }
    // Đảm bảo giá của sóng đẩy hợp lý
    if (isBullish && impulseWaveStartSwing.price >= impulseWaveEndSwing.price) {
        LogPattern("Pullback", false, "Sóng đẩy tăng không hợp lệ (start price >= end price)");
        return false;
    }
    if (!isBullish && impulseWaveStartSwing.price <= impulseWaveEndSwing.price) {
        LogPattern("Pullback", false, "Sóng đẩy giảm không hợp lệ (start price <= end price)");
        return false;
    }

    // Điều kiện 2: Giá hiện tại hồi về vùng giá trị (EMA 34/89 hoặc Fibonacci)
    // Tính EMA 34 và 89
    double ema34 = iMA(m_Symbol, m_Timeframe, 34, 0, MODE_EMA, PRICE_CLOSE, 0);
    double ema89 = iMA(m_Symbol, m_Timeframe, 89, 0, MODE_EMA, PRICE_CLOSE, 0);

    bool inEMAValueZone = false;
    if (isBullish) {
        inEMAValueZone = (m_low[0] <= MathMax(ema34, ema89) && m_high[0] >= MathMin(ema34, ema89));
    } else {
        inEMAValueZone = (m_high[0] >= MathMin(ema34, ema89) && m_low[0] <= MathMax(ema34, ema89));
    }

    // Tính Fibonacci Retracement của sóng đẩy gần nhất (từ impulseWaveStartSwing đến impulseWaveEndSwing)
    double fibLevel50 = 0.0;
    double fibLevel618 = 0.0;
    bool inFibZone = false;

    double impulseWaveRange = MathAbs(impulseWaveEndSwing.price - impulseWaveStartSwing.price);
    if (impulseWaveRange > 0) {
        if (isBullish) { // Sóng đẩy tăng từ impulseWaveStartSwing (Low) -> impulseWaveEndSwing (High)
            fibLevel50 = impulseWaveEndSwing.price - impulseWaveRange * 0.5;
            fibLevel618 = impulseWaveEndSwing.price - impulseWaveRange * 0.618;
            // Giá hiện tại (low của nến) phải chạm hoặc vượt qua fib 0.5 và không vượt quá fib 0.618 (tính từ trên xuống)
            inFibZone = (m_low[0] <= fibLevel50 && m_low[0] >= fibLevel618);
        } else { // Sóng đẩy giảm từ impulseWaveStartSwing (High) -> impulseWaveEndSwing (Low)
            fibLevel50 = impulseWaveEndSwing.price + impulseWaveRange * 0.5;
            fibLevel618 = impulseWaveEndSwing.price + impulseWaveRange * 0.618;
            // Giá hiện tại (high của nến) phải chạm hoặc vượt qua fib 0.5 và không vượt quá fib 0.618 (tính từ dưới lên)
            inFibZone = (m_high[0] >= fibLevel50 && m_high[0] <= fibLevel618);
        }
    }

    if (!inEMAValueZone && !inFibZone) {
        LogPattern("Pullback", false, "Giá không hồi về vùng giá trị (EMA hoặc Fibonacci)");
        return false;
    }

    // Điều kiện 3: Nến xác nhận
    bool confirmationCandle = false;
    if (isBullish) {
        // Bullish Engulfing hoặc Pinbar tăng
        // Bullish Engulfing: m_open[0] < m_close[1] && m_close[0] > m_open[1] && m_close[0] > m_open[0] && (m_close[0]-m_open[0]) > (m_open[1]-m_close[1])*0.8
        bool isBullishEngulfing = m_open[0] < m_close[1] && m_close[0] > m_open[1] && m_close[0] > m_open[0] && (m_close[0]-m_open[0]) > MathAbs(m_open[1]-m_close[1])*0.8;
        // Bullish Pinbar: (m_low[0] < m_open[0] && m_low[0] < m_close[0]) && (MathMin(m_open[0], m_close[0]) - m_low[0]) > 2 * MathAbs(m_open[0]-m_close[0]) && (m_high[0] - MathMax(m_open[0], m_close[0])) < MathAbs(m_open[0]-m_close[0])
        double body = MathAbs(m_open[0] - m_close[0]);
        double lowerWick = (m_open[0] < m_close[0]) ? (m_open[0] - m_low[0]) : (m_close[0] - m_low[0]);
        double upperWick = (m_open[0] < m_close[0]) ? (m_high[0] - m_close[0]) : (m_high[0] - m_open[0]);
        bool isBullishPinbar = lowerWick > 2 * body && upperWick < body && m_close[0] > m_open[0];
        confirmationCandle = isBullishEngulfing || isBullishPinbar;
    } else {
        // Bearish Engulfing hoặc Pinbar giảm
        // Bearish Engulfing: m_open[0] > m_close[1] && m_close[0] < m_open[1] && m_close[0] < m_open[0] && (m_open[0]-m_close[0]) > (m_close[1]-m_open[1])*0.8
        bool isBearishEngulfing = m_open[0] > m_close[1] && m_close[0] < m_open[1] && m_close[0] < m_open[0] && (m_open[0]-m_close[0]) > MathAbs(m_close[1]-m_open[1])*0.8;
        // Bearish Pinbar: (m_high[0] > m_open[0] && m_high[0] > m_close[0]) && (m_high[0] - MathMax(m_open[0], m_close[0])) > 2 * MathAbs(m_open[0]-m_close[0]) && (MathMin(m_open[0], m_close[0]) - m_low[0]) < MathAbs(m_open[0]-m_close[0])
        double body = MathAbs(m_open[0] - m_close[0]);
        double lowerWick = (m_open[0] < m_close[0]) ? (m_open[0] - m_low[0]) : (m_close[0] - m_low[0]);
        double upperWick = (m_open[0] < m_close[0]) ? (m_high[0] - m_close[0]) : (m_high[0] - m_open[0]);
        bool isBearishPinbar = upperWick > 2 * body && lowerWick < body && m_close[0] < m_open[0];
        confirmationCandle = isBearishEngulfing || isBearishPinbar;
    }

    if (!confirmationCandle) {
        LogPattern("Pullback", false, "Không có nến xác nhận");
        return false;
    }

    // Nếu tất cả điều kiện được thỏa mãn
    pattern.isValid = true;
    pattern.strength = 0.75; // Độ mạnh tạm thời, có thể tính toán chi tiết hơn
    pattern.description = StringFormat("Pullback %s (Structural) confirmed. EMA Zone: %s, Fib Zone: %s. Impulse: %.5f (bar %d) to %.5f (bar %d)", 
                                    isBullish ? "Bullish" : "Bearish", 
                                    inEMAValueZone ? "Yes" : "No", 
                                    inFibZone ? "Yes" : "No",
                                    impulseWaveStartSwing.price, impulseWaveStartSwing.barIndex,
                                    impulseWaveEndSwing.price, impulseWaveEndSwing.barIndex);
    pattern.startBar = impulseWaveStartSwing.barIndex; 
    pattern.endBar = 0; // Nến hiện tại là nến xác nhận, kết thúc của pullback phase

    // Tính toán SL/TP dựa trên cấu trúc
    if (isBullish) {
        pattern.entryLevel = m_close[0]; 
        pattern.stopLoss = impulseWaveStartSwing.price - m_atr * m_slBufferMultiplier; 
        
        if (foundImpulseWaveEnd && impulseWaveEndSwing.price > pattern.entryLevel) {
            pattern.takeProfit = impulseWaveEndSwing.price; 
            // Đảm bảo R:R tối thiểu nếu TP quá gần hoặc không hợp lệ
            if ((pattern.takeProfit - pattern.entryLevel) < (pattern.entryLevel - pattern.stopLoss) * m_minRR || pattern.takeProfit <= pattern.entryLevel) {
                 pattern.takeProfit = pattern.entryLevel + (pattern.entryLevel - pattern.stopLoss) * m_defaultRR; 
            }
        } else { 
            pattern.takeProfit = pattern.entryLevel + (pattern.entryLevel - pattern.stopLoss) * m_defaultRR; 
        }
    } else { // Bearish
        pattern.entryLevel = m_close[0];
        pattern.stopLoss = impulseWaveStartSwing.price + m_atr * m_slBufferMultiplier; 
        
        if (foundImpulseWaveEnd && impulseWaveEndSwing.price < pattern.entryLevel) {
            pattern.takeProfit = impulseWaveEndSwing.price;
            if ((pattern.entryLevel - pattern.takeProfit) < (pattern.stopLoss - pattern.entryLevel) * m_minRR || pattern.takeProfit >= pattern.entryLevel) {
                pattern.takeProfit = pattern.entryLevel - (pattern.stopLoss - pattern.entryLevel) * m_defaultRR;
            }
        } else { 
            pattern.takeProfit = pattern.entryLevel - (pattern.stopLoss - pattern.entryLevel) * m_defaultRR;
        }
    }
    // Kiểm tra lại SL và TP để đảm bảo hợp lệ (SL khác Entry, TP khác Entry và SL < Entry < TP cho Buy, SL > Entry > TP cho Sell)
    if (isBullish) {
        if (pattern.stopLoss >= pattern.entryLevel) {
            LogPattern("Pullback", false, StringFormat("SL >= Entry (%.5f >= %.5f). Điều chỉnh SL.", pattern.stopLoss, pattern.entryLevel));
            pattern.stopLoss = pattern.entryLevel - m_atr * MathMax(m_slBufferMultiplier, 0.1); // Đảm bảo SL < Entry
        }
        if (pattern.takeProfit <= pattern.entryLevel) {
            LogPattern("Pullback", false, StringFormat("TP <= Entry (%.5f <= %.5f). Điều chỉnh TP.", pattern.takeProfit, pattern.entryLevel));
            pattern.takeProfit = pattern.entryLevel + (pattern.entryLevel - pattern.stopLoss) * m_defaultRR;
        }
    } else { // Bearish
        if (pattern.stopLoss <= pattern.entryLevel) {
            LogPattern("Pullback", false, StringFormat("SL <= Entry (%.5f <= %.5f). Điều chỉnh SL.", pattern.stopLoss, pattern.entryLevel));
            pattern.stopLoss = pattern.entryLevel + m_atr * MathMax(m_slBufferMultiplier, 0.1); // Đảm bảo SL > Entry
        }
        if (pattern.takeProfit >= pattern.entryLevel) {
            LogPattern("Pullback", false, StringFormat("TP >= Entry (%.5f >= %.5f). Điều chỉnh TP.", pattern.takeProfit, pattern.entryLevel));
            pattern.takeProfit = pattern.entryLevel - (pattern.stopLoss - pattern.entryLevel) * m_defaultRR;
        }
    }
    // Đảm bảo SL và TP không quá gần nhau
    if(MathAbs(pattern.takeProfit - pattern.entryLevel) < m_atr * 0.5) { // Nếu TP quá gần entry
        LogPattern("Pullback", false, "TP quá gần Entry. Điều chỉnh TP theo default RR.");
        if(isBullish) pattern.takeProfit = pattern.entryLevel + (pattern.entryLevel - pattern.stopLoss) * m_defaultRR;
        else pattern.takeProfit = pattern.entryLevel - (pattern.stopLoss - pattern.entryLevel) * m_defaultRR;
    }

    LogPattern(pattern.description, true);
    return true;
} // Added as per instruction to close the preceding function

    // Phần code cũ đã được xóa bỏ để tránh lỗi và nhầm lẫn.
    // Logic phát hiện pullback hiện tại dựa trên cấu trúc thị trường từ SwingPointDetector,
    // vùng giá trị EMA/Fibonacci và nến xác nhận.

    
    // Phần code cũ đã được xóa bỏ để tránh lỗi và nhầm lẫn.
    // Logic phát hiện pullback hiện tại dựa trên cấu trúc thị trường từ SwingPointDetector,
    // vùng giá trị EMA/Fibonacci và nến xác nhận.

//+------------------------------------------------------------------+
//| Phát hiện các mẫu hình breakout                                   |
//+------------------------------------------------------------------+
bool CPatternDetector::DetectBreakoutPatterns() {
    // Khởi tạo mẫu hình với các giá trị mặc định
    m_detectedBreakout.Initialize();
    
    // Kiểm tra các mẫu hình breakout
    if (CheckRangeBreakoutPattern(true, m_detectedBreakout)) {
        return true;
    }
    else if (CheckRangeBreakoutPattern(false, m_detectedBreakout)) {
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Kiểm tra mẫu hình Pinbar với định nghĩa toán học chính xác       |
//+------------------------------------------------------------------+
bool CPatternDetector::CheckPinbarPattern(bool isBullish, ApexPullback::DetectedPattern& pattern) {
    if (ArraySize(m_high) < 3 || ArraySize(m_low) < 3 || ArraySize(m_close) < 3 || ArraySize(m_open) < 3) {
        return false;
    }
    
    pattern.Initialize();
    pattern.isBullish = isBullish;
    pattern.type = SCENARIO_CUSTOM;
    pattern.description = isBullish ? "Bullish Pinbar" : "Bearish Pinbar";
    
    int pinbarIndex = 1; // Kiểm tra nến trước nến hiện tại
    double open = m_open[pinbarIndex];
    double close = m_close[pinbarIndex];
    double high = m_high[pinbarIndex];
    double low = m_low[pinbarIndex];
    
    // Tính toán các thành phần của nến
    double bodySize = MathAbs(close - open);
    double totalRange = high - low;
    double upperWick = high - MathMax(open, close);
    double lowerWick = MathMin(open, close) - low;
    
    // Điều kiện cơ bản: nến phải có kích thước đủ lớn
    if (totalRange < m_atr * 0.5) {
        LogPattern(pattern.description, false, "Kích thước nến quá nhỏ");
        return false;
    }
    
    bool validPinbar = false;
    
    if (isBullish) {
        // Bullish Pinbar - Định nghĩa toán học chính xác:
        // 1. Đuôi dưới (lower wick) phải dài: lowerWick >= 2 * bodySize
        // 2. Đuôi trên (upper wick) phải ngắn: upperWick <= 0.5 * bodySize
        // 3. Thân nến phải nhỏ so với tổng chiều dài: bodySize <= 0.3 * totalRange
        // 4. Nến có thể là tăng hoặc giảm, nhưng đóng cửa phải ở 1/3 trên của range
        // 5. Đuôi dưới phải dài ít nhất 60% tổng range
        
        bool longLowerWick = lowerWick >= bodySize * 2.0;
        bool shortUpperWick = upperWick <= bodySize * 0.5;
        bool smallBody = bodySize <= totalRange * 0.3;
        bool closeInUpperThird = (close - low) >= totalRange * 0.6;
        bool wickDominance = lowerWick >= totalRange * 0.6;
        
        // Điều kiện bối cảnh: phải ở vùng support hoặc trong pullback
        bool contextValid = true;
        if (ArraySize(m_close) > 20) {
            double ema50 = CalculateEMA(50, pinbarIndex);
            double ema200 = CalculateEMA(200, pinbarIndex);
            // Pinbar bullish hợp lệ khi giá gần support (EMA50 hoặc EMA200)
            contextValid = (low <= ema50 * 1.01) || (low <= ema200 * 1.01) || (ema50 > ema200);
        }
        
        // Kiểm tra rejection: giá phải test và reject khỏi mức thấp
        bool rejectionConfirmed = false;
        if (ArraySize(m_close) > pinbarIndex + 1) {
            double nextClose = m_close[pinbarIndex - 1]; // Nến sau pinbar
            rejectionConfirmed = nextClose > (low + totalRange * 0.3);
        }
        
        validPinbar = longLowerWick && shortUpperWick && smallBody && 
                     closeInUpperThird && wickDominance && contextValid;
        
        if (validPinbar) {
            pattern.entryLevel = high + m_atr * 0.1; // Entry trên đỉnh pinbar
            pattern.stopLoss = low - m_atr * 0.3; // SL dưới đuôi pinbar
            pattern.takeProfit = pattern.entryLevel + (pattern.entryLevel - pattern.stopLoss) * 2.0;
            pattern.strength = 0.75;
            
            // Tăng độ mạnh nếu có xác nhận
            if (rejectionConfirmed) pattern.strength += 0.1;
            if (lowerWick >= totalRange * 0.7) pattern.strength += 0.1;
            if (contextValid && ArraySize(m_close) > 50) {
                double ema50 = CalculateEMA(50, pinbarIndex);
                if (MathAbs(low - ema50) < m_atr * 0.5) pattern.strength += 0.05; // Gần EMA50
            }
        }
        
    } else {
        // Bearish Pinbar - Định nghĩa toán học chính xác:
        // 1. Đuôi trên (upper wick) phải dài: upperWick >= 2 * bodySize
        // 2. Đuôi dưới (lower wick) phải ngắn: lowerWick <= 0.5 * bodySize
        // 3. Thân nến phải nhỏ so với tổng chiều dài: bodySize <= 0.3 * totalRange
        // 4. Nến có thể là tăng hoặc giảm, nhưng đóng cửa phải ở 1/3 dưới của range
        // 5. Đuôi trên phải dài ít nhất 60% tổng range
        
        bool longUpperWick = upperWick >= bodySize * 2.0;
        bool shortLowerWick = lowerWick <= bodySize * 0.5;
        bool smallBody = bodySize <= totalRange * 0.3;
        bool closeInLowerThird = (high - close) >= totalRange * 0.6;
        bool wickDominance = upperWick >= totalRange * 0.6;
        
        // Điều kiện bối cảnh: phải ở vùng resistance hoặc trong pullback
        bool contextValid = true;
        if (ArraySize(m_close) > 20) {
            double ema50 = CalculateEMA(50, pinbarIndex);
            double ema200 = CalculateEMA(200, pinbarIndex);
            // Pinbar bearish hợp lệ khi giá gần resistance (EMA50 hoặc EMA200)
            contextValid = (high >= ema50 * 0.99) || (high >= ema200 * 0.99) || (ema50 < ema200);
        }
        
        // Kiểm tra rejection: giá phải test và reject khỏi mức cao
        bool rejectionConfirmed = false;
        if (ArraySize(m_close) > pinbarIndex + 1) {
            double nextClose = m_close[pinbarIndex - 1]; // Nến sau pinbar
            rejectionConfirmed = nextClose < (high - totalRange * 0.3);
        }
        
        validPinbar = longUpperWick && shortLowerWick && smallBody && 
                     closeInLowerThird && wickDominance && contextValid;
        
        if (validPinbar) {
            pattern.entryLevel = low - m_atr * 0.1; // Entry dưới đáy pinbar
            pattern.stopLoss = high + m_atr * 0.3; // SL trên đỉnh pinbar
            pattern.takeProfit = pattern.entryLevel - (pattern.stopLoss - pattern.entryLevel) * 2.0;
            pattern.strength = 0.75;
            
            // Tăng độ mạnh nếu có xác nhận
            if (rejectionConfirmed) pattern.strength += 0.1;
            if (upperWick >= totalRange * 0.7) pattern.strength += 0.1;
            if (contextValid && ArraySize(m_close) > 50) {
                double ema50 = CalculateEMA(50, pinbarIndex);
                if (MathAbs(high - ema50) < m_atr * 0.5) pattern.strength += 0.05; // Gần EMA50
            }
        }
    }
    
    pattern.isValid = validPinbar;
    
    if (pattern.isValid) {
        pattern.startBar = pinbarIndex;
        pattern.endBar = pinbarIndex;
        LogPattern(pattern.description, true, StringFormat("Độ mạnh: %.2f, Wick ratio: %.2f", 
                  pattern.strength, isBullish ? (lowerWick/totalRange) : (upperWick/totalRange)));
    } else {
        LogPattern(pattern.description, false, "Không đáp ứng điều kiện Pinbar");
    }
    
    return pattern.isValid;
}

//+------------------------------------------------------------------+
//| Kiểm tra mẫu hình phân kỳ (Divergence)                           |
//+------------------------------------------------------------------+
bool CPatternDetector::CheckDivergencePattern(bool isBullish, ApexPullback::DetectedPattern& pattern) {
    // Cần ít nhất 20 nến để phân tích phân kỳ
    if (ArraySize(m_close) < 20) {
        return false;
    }
    
    // Tìm 2 đỉnh/đáy gần nhất
    int lookback = 10;
    int peak1 = -1, peak2 = -1;
    
    if (isBullish) {
        // Tìm 2 đáy gần nhất
        for (int i = 2; i < lookback && i < ArraySize(m_low); i++) {
            if (m_low[i] < m_low[i-1] && m_low[i] < m_low[i+1]) {
                if (peak1 == -1) peak1 = i;
                else if (peak2 == -1) {
                    peak2 = i;
                    break;
                }
            }
        }
        
        // Kiểm tra phân kỳ tăng: giá tạo đáy thấp hơn nhưng RSI tạo đáy cao hơn
        if (peak1 != -1 && peak2 != -1 && m_low[peak1] < m_low[peak2]) {
            // Giả định có RSI divergence (cần implement RSI indicator)
            pattern.type = PATTERN_REVERSAL;
            pattern.isValid = true;
            pattern.isBullish = true;
            pattern.strength = 0.8;
            pattern.entryLevel = m_close[0];
            pattern.stopLoss = m_low[peak1] - m_atr * 0.5;
            pattern.takeProfit = pattern.entryLevel + (pattern.entryLevel - pattern.stopLoss) * 2.0;
            pattern.description = "Bullish Divergence";
            return true;
        }
    } else {
        // Tìm 2 đỉnh gần nhất
        for (int i = 2; i < lookback && i < ArraySize(m_high); i++) {
            if (m_high[i] > m_high[i-1] && m_high[i] > m_high[i+1]) {
                if (peak1 == -1) peak1 = i;
                else if (peak2 == -1) {
                    peak2 = i;
                    break;
                }
            }
        }
        
        // Kiểm tra phân kỳ giảm: giá tạo đỉnh cao hơn nhưng RSI tạo đỉnh thấp hơn
        if (peak1 != -1 && peak2 != -1 && m_high[peak1] > m_high[peak2]) {
            pattern.type = PATTERN_REVERSAL;
            pattern.isValid = true;
            pattern.isBullish = false;
            pattern.strength = 0.8;
            pattern.entryLevel = m_close[0];
            pattern.stopLoss = m_high[peak1] + m_atr * 0.5;
            pattern.takeProfit = pattern.entryLevel - (pattern.stopLoss - pattern.entryLevel) * 2.0;
            pattern.description = "Bearish Divergence";
            return true;
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Kiểm tra mẫu hình Double Top/Bottom                              |
//+------------------------------------------------------------------+
bool CPatternDetector::CheckDoubleTopBottomPattern(bool isBullish, ApexPullback::DetectedPattern& pattern) {
    if (ArraySize(m_high) < 30 || ArraySize(m_low) < 30) {
        return false;
    }
    
    int lookback = 20;
    double tolerance = m_atr * 0.5;
    
    if (isBullish) {
        // Tìm Double Bottom
        for (int i = 5; i < lookback; i++) {
            for (int j = i + 5; j < lookback && j < ArraySize(m_low); j++) {
                if (MathAbs(m_low[i] - m_low[j]) <= tolerance) {
                    // Kiểm tra có đỉnh ở giữa không
                    double maxBetween = 0;
                    for (int k = i + 1; k < j; k++) {
                        if (m_high[k] > maxBetween) maxBetween = m_high[k];
                    }
                    
                    if (maxBetween > m_low[i] + m_atr) {
                        pattern.type = PATTERN_REVERSAL;
                        pattern.isValid = true;
                        pattern.isBullish = true;
                        pattern.strength = 0.75;
                        pattern.entryLevel = maxBetween;
                        pattern.stopLoss = MathMin(m_low[i], m_low[j]) - m_atr * 0.5;
                        pattern.takeProfit = pattern.entryLevel + (pattern.entryLevel - pattern.stopLoss) * 1.5;
                        pattern.description = "Double Bottom";
                        return true;
                    }
                }
            }
        }
    } else {
        // Tìm Double Top
        for (int i = 5; i < lookback; i++) {
            for (int j = i + 5; j < lookback && j < ArraySize(m_high); j++) {
                if (MathAbs(m_high[i] - m_high[j]) <= tolerance) {
                    // Kiểm tra có đáy ở giữa không
                    double minBetween = DBL_MAX;
                    for (int k = i + 1; k < j; k++) {
                        if (m_low[k] < minBetween) minBetween = m_low[k];
                    }
                    
                    if (minBetween < m_high[i] - m_atr) {
                        pattern.type = PATTERN_REVERSAL;
                        pattern.isValid = true;
                        pattern.isBullish = false;
                        pattern.strength = 0.75;
                        pattern.entryLevel = minBetween;
                        pattern.stopLoss = MathMax(m_high[i], m_high[j]) + m_atr * 0.5;
                        pattern.takeProfit = pattern.entryLevel - (pattern.stopLoss - pattern.entryLevel) * 1.5;
                        pattern.description = "Double Top";
                        return true;
                    }
                }
            }
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Kiểm tra mẫu hình Range Breakout                                 |
//+------------------------------------------------------------------+
bool CPatternDetector::CheckRangeBreakoutPattern(bool isBullish, ApexPullback::DetectedPattern& pattern) {
    if (ArraySize(m_high) < 20 || ArraySize(m_low) < 20) {
        return false;
    }
    
    int rangePeriod = 15;
    double rangeHigh = 0, rangeLow = DBL_MAX;
    
    // Tìm range trong 15 nến gần nhất
    for (int i = 1; i <= rangePeriod && i < ArraySize(m_high); i++) {
        if (m_high[i] > rangeHigh) rangeHigh = m_high[i];
        if (m_low[i] < rangeLow) rangeLow = m_low[i];
    }
    
    double rangeSize = rangeHigh - rangeLow;
    if (rangeSize < m_atr * 2) return false; // Range quá nhỏ
    
    double currentPrice = m_close[0];
    double breakoutThreshold = m_atr * 0.3;
    
    if (isBullish) {
        // Breakout lên trên
        if (currentPrice > rangeHigh + breakoutThreshold) {
            pattern.type = PATTERN_BREAKOUT;
            pattern.isValid = true;
            pattern.isBullish = true;
            pattern.strength = 0.7;
            pattern.entryLevel = rangeHigh + breakoutThreshold;
            pattern.stopLoss = rangeLow - m_atr * 0.5;
            pattern.takeProfit = pattern.entryLevel + rangeSize * 1.5;
            pattern.description = "Bullish Range Breakout";
            return true;
        }
    } else {
        // Breakout xuống dưới
        if (currentPrice < rangeLow - breakoutThreshold) {
            pattern.type = PATTERN_BREAKOUT;
            pattern.isValid = true;
            pattern.isBullish = false;
            pattern.strength = 0.7;
            pattern.entryLevel = rangeLow - breakoutThreshold;
            pattern.stopLoss = rangeHigh + m_atr * 0.5;
            pattern.takeProfit = pattern.entryLevel - rangeSize * 1.5;
            pattern.description = "Bearish Range Breakout";
            return true;
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Phát hiện mẫu hình Mean Reversion cho thị trường đi ngang        |
//| Bước 2: Xây dựng chiến lược giao dịch trong Range               |
//+------------------------------------------------------------------+
bool CPatternDetector::DetectMeanReversionPattern(bool& isBullish, ApexPullback::DetectedPattern& pattern) {
    pattern.Initialize();
    
    // Điều kiện Setup: Chỉ hoạt động khi thị trường đi ngang ổn định
    if (m_context->IsMarketProfileValid) {
        ENUM_MARKET_REGIME currentRegime = m_context->CurrentMarketRegime;
        if (currentRegime != REGIME_RANGING_STABLE) {
            LogPattern("MeanReversion", false, "Chỉ hoạt động trong REGIME_RANGING_STABLE");
            return false;
        }
    }
    
    // Kiểm tra đủ dữ liệu
    if (ArraySize(m_high) < 20 || ArraySize(m_low) < 20 || ArraySize(m_close) < 20) {
        LogPattern("MeanReversion", false, "Không đủ dữ liệu");
        return false;
    }
    
    // Tính toán Bollinger Bands (20 periods, 2 std dev)
    int bbPeriod = 20;
    double bbDeviation = 2.0;
    double sma = 0;
    
    // Tính SMA
    for (int i = 0; i < bbPeriod && i < ArraySize(m_close); i++) {
        sma += m_close[i];
    }
    sma /= bbPeriod;
    
    // Tính Standard Deviation
    double variance = 0;
    for (int i = 0; i < bbPeriod && i < ArraySize(m_close); i++) {
        variance += MathPow(m_close[i] - sma, 2);
    }
    double stdDev = MathSqrt(variance / bbPeriod);
    
    double upperBand = sma + (bbDeviation * stdDev);
    double lowerBand = sma - (bbDeviation * stdDev);
    double currentPrice = m_close[0];
    
    // Tính RSI đơn giản (14 periods)
    double rsi = CalculateSimpleRSI(14);
    
    // Kiểm tra Pinbar pattern
    bool isPinbarBullish = IsPinbarPattern(true);
    bool isPinbarBearish = IsPinbarPattern(false);
    
    // Điều kiện Mua: Giá chạm Lower Band + RSI < 30 + Pinbar tăng
    if (currentPrice <= lowerBand && rsi < 30 && isPinbarBullish) {
        isBullish = true;
        pattern.type = PATTERN_MEAN_REVERSION;
        pattern.isValid = true;
        pattern.isBullish = true;
        pattern.strength = 0.75;
        pattern.entryLevel = currentPrice;
        pattern.stopLoss = lowerBand - (m_atr * 0.5); // SL ngoài Lower Band một chút
        pattern.takeProfit = sma; // TP tại đường giữa
        pattern.description = "Bullish Mean Reversion (Lower Band + RSI < 30 + Pinbar)";
        
        LogPattern("MeanReversion", true, StringFormat("LONG: Price=%.5f, LowerBand=%.5f, RSI=%.1f", 
                  currentPrice, lowerBand, rsi));
        return true;
    }
    
    // Điều kiện Bán: Giá chạm Upper Band + RSI > 70 + Pinbar giảm
    if (currentPrice >= upperBand && rsi > 70 && isPinbarBearish) {
        isBullish = false;
        pattern.type = PATTERN_MEAN_REVERSION;
        pattern.isValid = true;
        pattern.isBullish = false;
        pattern.strength = 0.75;
        pattern.entryLevel = currentPrice;
        pattern.stopLoss = upperBand + (m_atr * 0.5); // SL ngoài Upper Band một chút
        pattern.takeProfit = sma; // TP tại đường giữa
        pattern.description = "Bearish Mean Reversion (Upper Band + RSI > 70 + Pinbar)";
        
        LogPattern("MeanReversion", true, StringFormat("SHORT: Price=%.5f, UpperBand=%.5f, RSI=%.1f", 
                  currentPrice, upperBand, rsi));
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Tính RSI đơn giản                                               |
//+------------------------------------------------------------------+
double CPatternDetector::CalculateSimpleRSI(int period) {
    if (ArraySize(m_close) < period + 1) return 50.0; // Giá trị trung tính
    
    double gains = 0, losses = 0;
    
    for (int i = 1; i <= period && i < ArraySize(m_close); i++) {
        double change = m_close[i-1] - m_close[i];
        if (change > 0) gains += change;
        else losses += MathAbs(change);
    }
    
    if (losses == 0) return 100.0;
    if (gains == 0) return 0.0;
    
    double avgGain = gains / period;
    double avgLoss = losses / period;
    double rs = avgGain / avgLoss;
    
    return 100.0 - (100.0 / (1.0 + rs));
}

//+------------------------------------------------------------------+
//| Kiểm tra Pinbar pattern                                         |
//+------------------------------------------------------------------+
bool CPatternDetector::IsPinbarPattern(bool checkBullish) {
    if (ArraySize(m_high) < 2 || ArraySize(m_low) < 2 || 
        ArraySize(m_open) < 2 || ArraySize(m_close) < 2) {
        return false;
    }
    
    double open = m_open[0];
    double close = m_close[0];
    double high = m_high[0];
    double low = m_low[0];
    
    double bodySize = MathAbs(close - open);
    double totalRange = high - low;
    
    if (totalRange == 0 || bodySize / totalRange > 0.3) return false; // Body quá lớn
    
    if (checkBullish) {
        // Bullish Pinbar: Long lower shadow, small body near high
        double lowerShadow = MathMin(open, close) - low;
        double upperShadow = high - MathMax(open, close);
        
        return (lowerShadow > bodySize * 2 && upperShadow < bodySize && close > open);
    } else {
        // Bearish Pinbar: Long upper shadow, small body near low
        double upperShadow = high - MathMax(open, close);
        double lowerShadow = MathMin(open, close) - low;
        
        return (upperShadow > bodySize * 2 && lowerShadow < bodySize && close < open);
    }

//+------------------------------------------------------------------+
//| Calculate EMA value at specific shift                           |
//+------------------------------------------------------------------+
double CPatternDetector::CalculateEMA(int period, int shift) {
    if (!m_isInitialized || period <= 0 || shift < 0) {
        return 0.0;
    }
    
    // Kiểm tra đủ dữ liệu
    if (ArraySize(m_close) < period + shift) {
        return 0.0;
    }
    
    double alpha = 2.0 / (period + 1.0);
    double ema = m_close[ArraySize(m_close) - 1 - shift - period + 1]; // Giá trị khởi tạo
    
    // Tính EMA từ period bars trước đến shift
    for (int i = ArraySize(m_close) - shift - period + 2; i <= ArraySize(m_close) - 1 - shift; i++) {
        ema = alpha * m_close[i] + (1.0 - alpha) * ema;
    }
    
    return ema;
}

} // end namespace ApexPullback

#endif // PATTERNDETECTOR_MQH_