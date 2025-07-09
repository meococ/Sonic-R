//+------------------------------------------------------------------+
//|                                         MarketProfile.mqh         |
//|                      APEX PULLBACK EA v14.0 - Professional Edition|
//|               Copyright 2023-2024, APEX Trading Systems           |
//+------------------------------------------------------------------+

#ifndef MARKETPROFILE_MQH_
#define MARKETPROFILE_MQH_

#include "CommonStructs.mqh"

// BẮT ĐẦU NAMESPACE
namespace ApexPullback {

//+------------------------------------------------------------------+
//| Class MarketProfile - Quản lý profile thị trường                  |
//+------------------------------------------------------------------+
class CMarketProfile
{
private:
    // --- Phụ thuộc Cốt lõi ---
    EAContext* m_context; // Pointer tới Single Source of Truth

    // --- Trạng thái Nội tại ---
    bool       m_initialized;      // Trạng thái khởi tạo
    datetime   m_last_update_time; // Thời gian cập nhật cuối cùng của thanh nến

    // --- Dữ liệu Profile ---
    MarketProfileData m_current_profile; // Profile của thanh nến hiện tại
    MarketProfileData m_previous_profile; // Profile của thanh nến trước đó

    // --- Dữ liệu Lịch sử cho Tính toán ---
    double     m_atr_history[];      // Lịch sử ATR để tính toán tỷ lệ
    double     m_spread_history[];   // Lịch sử spread để phát hiện spread bất thường
    int        m_spread_count;       // Số lượng spread đã lưu
    
    // ----- Các hàm private -----
    

    
    // Hàm tính toán độ dốc
    double CalculateSlope(const double &buffer[], int periods = 5);
    
    // Hàm phân tích chế độ thị trường
    ApexPullback::ENUM_MARKET_REGIME DetermineRegime();
    
    // Hàm xác định phiên giao dịch
    ApexPullback::ENUM_SESSION DetermineCurrentSession();
    
    // Hàm kiểm tra sự phân kỳ
    bool IsMultiTimeframeAligned();
    
    // Hàm tính điểm động lượng
    double CalculateMomentumScore();
    
    // Hàm tính khoảng cách giữa các EMA
    double CalculateEmaSpread(bool useHigherTimeframe = false);
    
    // Hàm cập nhật lịch sử ATR
    void UpdateAtrHistory();
    
    // Hàm cập nhật lịch sử spread
    void UpdateSpreadHistory();
    
    // Hàm kiểm tra thị trường choppy
    bool IsChoppyMarket() const;
    
    // Hàm kiểm tra giá trong vùng pullback
    bool IsPriceInPullbackZone(bool isLong);
    double CalculateChoppyScore() const; // Private method to calculate the choppy score
    double CalculateSidewaysScore(); // Private method to calculate the score
    
    // Hàm tính % pullback dựa trên swing và EMA
    double CalculatePullbackPercent(bool isLong);
    
    // Hàm kiểm tra nến mới
    bool IsNewBar();

private: // Private helpers for initialization
    bool InitializeIndicators();
    bool InitializeDataArrays();

public:
    // --- Constructor & Destructor ---
    CMarketProfile(EAContext* context);
    ~CMarketProfile();

    // --- Khởi tạo và Cập nhật ---
    bool Initialize();
    bool Update(); // Gọi mỗi khi có thanh nến mới

    // --- Truy cập Dữ liệu ---
    const MarketProfileData& GetCurrentProfile() const { return m_current_profile; }
    const MarketProfileData& GetPreviousProfile() const { return m_previous_profile; }

    // --- Các hàm Phân tích & Đánh giá ---
    bool IsTrendStrongEnough() const;
    double CalculatePullbackPercent(bool is_long) const;

    // --- Các hàm Getter cho dữ liệu cụ thể (nếu cần truy cập thường xuyên) ---
    ENUM_MARKET_TREND GetTrend() const { return m_current_profile.trend; }
    ENUM_MARKET_REGIME GetRegime() const { return m_current_profile.regime; }
    double GetATR() const { return m_current_profile.atrCurrent; }
    double GetADX() const { return m_current_profile.adxValue; }

    // ----- Các hàm kiểm tra trạng thái thị trường -----
    bool IsSidewaysOrChoppy() const { return m_current_profile.isSidewaysOrChoppy; }
    bool IsLowMomentum() const { return m_current_profile.isLowMomentum; }
    bool IsVolatile() const { return m_current_profile.isVolatile; }
    bool IsMarketTrending() const { return m_current_profile.isTrending; }
    bool IsMarketTransitioning() const { return m_current_profile.isTransitioning; }
    bool IsMarketChoppy() const { return IsChoppyMarket(); }
    bool IsVolatilityExtreme() const { return m_current_profile.atrRatio > m_context.Params.CoreStrategy.VolatilityThreshold * 1.5; }
    double GetRegimeConfidence() const { return m_current_profile.regimeConfidence; }

    // Lấy điểm sức mạnh động lượng
    double GetMomentumStrength() const;
};

//+------------------------------------------------------------------+
//| Implementation                                                   |
//+------------------------------------------------------------------+

// --- Constructor, Destructor, Initializer ---

// Constructor: Khởi tạo các giá trị mặc định an toàn.
CMarketProfile::CMarketProfile(EAContext* context) :
    m_context(context),
    m_initialized(false),
    m_last_update_time(0),
    m_spread_count(0)
{
    m_current_profile.Clear();
    m_previous_profile.Clear();
    // Không khởi tạo mảng ở đây, sẽ thực hiện trong Initialize
}

// Destructor: Hiện tại không cần dọn dẹp gì đặc biệt.
CMarketProfile::~CMarketProfile()
{
}

// Initialize: Thiết lập module với context và chuẩn bị tài nguyên.
bool CMarketProfile::Initialize()
{
    if(!InitializeDataArrays()) // Khởi tạo các mảng dữ liệu trước
    {
        if(m_context->pLogger) m_context->pLogger->Log(ALERT_LEVEL_ERROR, "Failed to initialize data arrays in CMarketProfile.");
        return false;
    }

    // Việc khởi tạo chỉ báo đã được chuyển vào CIndicatorUtils
    // Ở đây chúng ta chỉ cần xác thực chúng đã sẵn sàng
    if (!m_context.pIndicatorUtils || !m_context.pIndicatorUtils->IsInitialized())
    {
        if(m_context.pLogger) m_context.pLogger->Log(ALERT_LEVEL_ERROR, "IndicatorUtils is not initialized before CMarketProfile.");
        return false;
    }

    m_initialized = true;
    if(m_context.pLogger) m_context.pLogger->Log(ALERT_LEVEL_INFO, "CMarketProfile initialized successfully for " + m_context.pSymbolInfo->Symbol() + ".");

    // Cập nhật lần đầu để có dữ liệu ngay
    Update();

    return true;
}

bool CMarketProfile::InitializeDataArrays()
{
    int history_size = m_context.Params.CoreStrategy.ATR_Period * 3; // Lấy đủ dữ liệu

    ArrayResize(m_atr_history, history_size);
    ArraySetAsSeries(m_atr_history, true);

    ArrayResize(m_spread_history, 100); // Lưu 100 spread gần nhất
    ArraySetAsSeries(m_spread_history, true);

    return true;
}

//+------------------------------------------------------------------+
//| Lấy điểm sức mạnh động lượng                                     |
//+------------------------------------------------------------------+
double CMarketProfile::GetMomentumStrength() const
{
    return m_current_profile.momentumScore;
}

//+------------------------------------------------------------------+
//| Tính toán điểm động lượng tổng hợp                               |
//+------------------------------------------------------------------+
double CMarketProfile::CalculateMomentumScore()
{
    // --- Trọng số cho các thành phần ---
    const double w_rsi = 0.30;      // Trọng số cho RSI (vị trí & độ dốc)
    const double w_macd = 0.40;     // Trọng số cho MACD Histogram (giá trị & độ dốc)
    const double w_adx = 0.15;      // Trọng số cho ADX (sức mạnh xu hướng)
    const double w_price_ema = 0.15; // Trọng số cho vị trí giá so với EMA nhanh

    // --- 1. Đánh giá RSI ---
    double rsi_score = 0;
    double rsi_value = m_current_profile.rsiValue;
    double rsi_slope = m_current_profile.rsiSlope;
    if (rsi_value > 55) rsi_score += 0.5; // Vùng tăng giá
    if (rsi_value < 45) rsi_score -= 0.5; // Vùng giảm giá
    if (rsi_slope > 0) rsi_score += 0.5;  // Đang dốc lên
    if (rsi_slope < 0) rsi_score -= 0.5;  // Đang dốc xuống
    rsi_score = fmax(-1.0, fmin(1.0, rsi_score)); // Chuẩn hóa trong [-1, 1]

    // --- 2. Đánh giá MACD Histogram ---
    double macd_score = 0;
    double macd_hist = m_current_profile.macdHistogram;
    double macd_hist_slope = m_current_profile.macdHistogramSlope;
    // Sử dụng giá trị ATR để chuẩn hóa histogram
    double normalized_hist = (m_current_profile.atrCurrent > 0) ? macd_hist / m_current_profile.atrCurrent : 0;
    if (normalized_hist > 0.05) macd_score += 0.5; // Tăng giá rõ rệt
    if (normalized_hist < -0.05) macd_score -= 0.5; // Giảm giá rõ rệt
    if (macd_hist_slope > 0) macd_score += 0.5; // Động lượng tăng
    if (macd_hist_slope < 0) macd_score -= 0.5; // Động lượng giảm
    macd_score = fmax(-1.0, fmin(1.0, macd_score)); // Chuẩn hóa

    // --- 3. Đánh giá ADX ---
    double adx_score = 0;
    if (m_current_profile.adxValue > 25) {
        if (m_current_profile.diPlus > m_current_profile.diMinus) adx_score = 1.0; // Xu hướng tăng mạnh
        else adx_score = -1.0; // Xu hướng giảm mạnh
    }

    // --- 4. Đánh giá vị trí giá so với EMA nhanh ---
    double price_ema_score = 0;
    if (m_current_profile.currentPrice > m_current_profile.emaFast) price_ema_score = 1.0;
    else if (m_current_profile.currentPrice < m_current_profile.emaFast) price_ema_score = -1.0;

    // --- 5. Tính điểm tổng hợp ---
    double total_score = (rsi_score * w_rsi) +
                         (macd_score * w_macd) +
                         (adx_score * w_adx) +
                         (price_ema_score * w_price_ema);

    // Chuẩn hóa điểm cuối cùng về thang điểm từ -1.0 (rất yếu) đến +1.0 (rất mạnh)
    return fmax(-1.0, fmin(1.0, total_score));
}




// --- Private Helper Methods ---

bool CMarketProfile::InitializeDataArrays()
{
    if(!m_context) return false;
    // Kích thước buffer cho spread, đủ lớn để phát hiện bất thường
    int spread_buffer_size = 50;
    if(ArrayResize(m_spread_history, spread_buffer_size) != spread_buffer_size)
    {
        m_context->Logger->LogError("Failed to resize spread_history array.");
        return false;
    }
    ArraySetAsSeries(m_spread_history, true);

    // Kích thước buffer cho ATR, đủ cho các tính toán tỷ lệ và độ dốc
    const int atr_period = m_context->Inputs.CoreStrategy.AtrPeriod;
    int atr_buffer_size = atr_period + 20; // Thêm buffer cho tính toán độ dốc
    if(ArrayResize(m_atr_history, atr_buffer_size) != atr_buffer_size)
    {
        m_context->Logger->LogError("Failed to resize atr_history array.");
        return false;
    }
    ArraySetAsSeries(m_atr_history, true);

    return true;
}



//+------------------------------------------------------------------+
//| InitializeIndicators - Private Helper                          |
//+------------------------------------------------------------------+
bool CMarketProfile::InitializeIndicators()
{
    CIndicatorUtils* utils = m_context->IndicatorUtils;
    if (!utils) return false;

    // The handles are already created by IndicatorUtils during its own initialization.
    // This function now serves as a validation step to ensure all required
    // indicators for MarketProfile are available.
    if (utils->GetAtrHandle() == INVALID_HANDLE ||
        utils->GetAdxHandle() == INVALID_HANDLE ||
        utils->GetRsiHandle() == INVALID_HANDLE ||
        utils->GetMacdHandle() == INVALID_HANDLE ||
        utils->GetBbHandle() == INVALID_HANDLE ||
        utils->GetEmaHandle(m_context->Inputs.CoreStrategy.EmaFastPeriod) == INVALID_HANDLE ||
        utils->GetEmaHandle(m_context->Inputs.CoreStrategy.EmaMediumPeriod) == INVALID_HANDLE ||
        utils->GetEmaHandle(m_context->Inputs.CoreStrategy.EmaSlowPeriod) == INVALID_HANDLE)
    {
        m_context->Logger->LogError("MarketProfile: One or more required indicator handles are invalid.");
        return false;
    }
    
    if (m_context->Inputs.CoreStrategy.UseMultiTimeframe) {
         if (utils->GetEmaHandle(m_context->Inputs.CoreStrategy.EmaFastPeriod, m_context->Inputs.CoreStrategy.HigherTimeframe) == INVALID_HANDLE ||
             utils->GetEmaHandle(m_context->Inputs.CoreStrategy.EmaSlowPeriod, m_context->Inputs.CoreStrategy.HigherTimeframe) == INVALID_HANDLE)
         {
            m_context->Logger->LogError("MarketProfile: One or more required H4 indicator handles are invalid.");
            return false;
         }
    }

    m_context->Logger->LogInfo("MarketProfile: All required indicator handles validated.");
    return true;
}


//+------------------------------------------------------------------+
//| IsNewBar - Kiểm tra nếu có một thanh nến mới đã hình thành.      |
//+------------------------------------------------------------------+
bool CMarketProfile::IsNewBar()
{
    MqlRates rates[1];
    if(CopyRates(m_context->Symbol, m_context->Inputs.CoreStrategy.MainTimeframe, 0, 1, rates) < 1)
    {
        return false; // Không thể lấy dữ liệu nến
    }

    if(rates[0].time > m_last_update_time)
    {
        m_last_update_time = rates[0].time; // Cập nhật thời gian của nến mới nhất
        return true;
    }

    return false;
}

//+------------------------------------------------------------------+
//| Update - Cập nhật toàn bộ profile thị trường.                    |
//| Được gọi tối ưu nhất khi có một thanh nến mới.                   |
//+------------------------------------------------------------------+
bool CMarketProfile::Update()
{
    // --- Điều kiện tiên quyết --- 
    if (!m_initialized || !m_context || !m_context->IndicatorUtils)
        return false;

    // --- Tối ưu hóa: Chỉ chạy khi có nến mới --- 
    if (!IsNewBar())
        return true; // Không phải lỗi, chỉ là chưa có gì mới để xử lý

    // --- Chuẩn bị cho việc cập nhật --- 
    m_previous_profile = m_current_profile; // Lưu trạng thái cũ
    m_current_profile.Clear();              // Reset profile hiện tại
    CIndicatorUtils* utils = m_context->IndicatorUtils;

    // --- 1. Lấy Dữ liệu Giá Cơ bản (Tối ưu hóa) --- 
    MqlRates rates[1];
    if(CopyRates(m_context->Symbol, m_context->Inputs.CoreStrategy.MainTimeframe, 0, 1, rates) < 1)
    {
        m_context->Logger->LogWarning("MarketProfile: Không thể lấy nến hiện tại để cập nhật.");
        return false;
    }
    m_current_profile.currentPrice = rates[0].close;
    m_current_profile.currentHigh  = rates[0].high;
    m_current_profile.currentLow   = rates[0].low;
    m_current_profile.currentOpen  = rates[0].open;
    m_current_profile.previousPrice = m_previous_profile.currentPrice; // Lấy từ profile trước đó
    m_current_profile.timestamp    = rates[0].time;
    m_current_profile.symbol       = m_context->Symbol;
    m_current_profile.timeframe    = m_context->Inputs.CoreStrategy.MainTimeframe;

    // --- 2. Lấy Dữ liệu Chỉ báo Cốt lõi --- 
    m_current_profile.currentSpread = SymbolInfoInteger(m_context->Symbol, SYMBOL_SPREAD);
    m_current_profile.atrCurrent   = utils->GetATR(0);
    m_current_profile.adxValue     = utils->GetADX(0);
    m_current_profile.diPlus       = utils->GetADXPlus(0);
    m_current_profile.diMinus      = utils->GetADXMinus(0);
    m_current_profile.rsiValue     = utils->GetRSI(0);
    m_current_profile.macdValue    = utils->GetMACDMain(0);
    m_current_profile.macdSignal   = utils->GetMACDSignal(0);
    m_current_profile.macdHistogram = m_current_profile.macdValue - m_current_profile.macdSignal;
    m_current_profile.bbWidth      = utils->GetBBWidth(0);
    m_current_profile.emaFast      = utils->GetMA(m_context->Inputs.CoreStrategy.EmaFastPeriod, 0);
    m_current_profile.emaMedium    = utils->GetMA(m_context->Inputs.CoreStrategy.EmaMediumPeriod, 0);
    m_current_profile.emaSlow      = utils->GetMA(m_context->Inputs.CoreStrategy.EmaSlowPeriod, 0);

    // --- 3. Tính toán các Số liệu Phái sinh & Tổng hợp --- 
    UpdateAtrHistory();
    UpdateSpreadHistory();
    // m_current_profile.averageDailyAtr = // Logic này cần xem xét lại, có thể cần timeframe D1
    m_current_profile.atrRatio = (m_current_profile.atrCurrent > 0 && m_atr_history[1] > 0) ? m_current_profile.atrCurrent / m_atr_history[1] : 1.0;
    m_current_profile.adxSlope     = m_current_profile.adxValue - utils->GetADX(1);
    m_current_profile.rsiSlope     = m_current_profile.rsiValue - utils->GetRSI(1);
    m_current_profile.macdHistogramSlope = (m_current_profile.macdHistogram - (utils->GetMACDMain(1) - utils->GetMACDSignal(1)));

    // --- 4. Phân tích & Phân loại Trạng thái Thị trường --- 
    m_current_profile.regime           = DetermineRegime();
    m_current_profile.currentSession   = DetermineCurrentSession();
    m_current_profile.isTrending       = (m_current_profile.regime == ApexPullback::REGIME_TRENDING_UP || m_current_profile.regime == ApexPullback::REGIME_TRENDING_DOWN);
    m_current_profile.choppyScore = CalculateChoppyScore(); // Tính điểm choppy
    m_current_profile.isSidewaysOrChoppy = m_current_profile.choppyScore >= m_context->Inputs.CoreStrategy.ChoppyScoreThreshold;
    m_current_profile.isMultiTimeframeAligned = IsMultiTimeframeAligned();
    m_current_profile.momentumScore    = CalculateMomentumScore();
    m_current_profile.emaSpread        = CalculateEmaSpread(false);
    if (m_context->Inputs.CoreStrategy.UseMultiTimeframe)
    {
        m_current_profile.emaSpreadH4 = CalculateEmaSpread(true);
    }
    m_current_profile.regimeConfidence = 100.0 - m_current_profile.choppyScore; // Độ tin cậy là nghịch đảo của choppy

    m_context->Logger->LogDebug(StringFormat("MarketProfile Updated: %s, Price: %.5f, Regime: %s, Momentum: %.2f", 
                                        m_context->Symbol, m_current_profile.currentPrice, 
                                        EnumToString(m_current_profile.regime), m_current_profile.momentumScore));

    return true;
}

//+------------------------------------------------------------------+
//| Tính toán điểm Choppy của thị trường (0-100)                     |
//+------------------------------------------------------------------+
double CMarketProfile::CalculateChoppyScore() const
{
    if (!m_context || m_current_profile.atrCurrent <= 0) return 50.0; // Giá trị trung bình nếu không tính được

    const CoreStrategyInputs& params = m_context->Inputs.CoreStrategy;
    double score = 0;
    double total_weight = 0;

    // --- 1. ADX Score (Weight: 40) ---
    const double adx_weight = 40.0;
    double adx_score = 0;
    if (m_current_profile.adxValue < params.ChoppyAdxThreshold) {
        // Tuyến tính: ADX càng thấp, điểm càng cao. Dưới 15 là max, trên ngưỡng là 0.
        adx_score = 100.0 * (1.0 - fmax(0, m_current_profile.adxValue - 15.0) / (params.ChoppyAdxThreshold - 15.0));
    }
    score += adx_score * adx_weight;
    total_weight += adx_weight;

    // --- 2. EMA Spread Score (Weight: 30) ---
    const double ema_weight = 30.0;
    double ema_spread = MathAbs(m_current_profile.emaFast - m_current_profile.emaSlow);
    double ema_spread_ratio = ema_spread / m_current_profile.atrCurrent;
    double ema_score = 0;
    if (ema_spread_ratio < params.ChoppyEmaSpreadRatio) {
        // Tuyến tính: Ratio càng nhỏ, điểm càng cao.
        ema_score = 100.0 * (1.0 - ema_spread_ratio / params.ChoppyEmaSpreadRatio);
    }
    score += ema_score * ema_weight;
    total_weight += ema_weight;

    // --- 3. RSI Neutrality Score (Weight: 20) ---
    const double rsi_weight = 20.0;
    double rsi_dist_from_50 = MathAbs(m_current_profile.rsiValue - 50.0);
    double rsi_score = 0;
    // Điểm cao nhất khi RSI = 50, giảm dần khi tiến ra xa
    double rsi_range = 50.0 - params.ChoppyRsiLowerBound; // e.g., 50 - 40 = 10
    if (rsi_dist_from_50 < rsi_range) {
        rsi_score = 100.0 * (1.0 - rsi_dist_from_50 / rsi_range);
    }
    score += rsi_score * rsi_weight;
    total_weight += rsi_weight;

    // --- 4. Bollinger Bands Width Score (Weight: 10) ---
    const double bb_weight = 10.0;
    // Giả sử bbWidth là tỷ lệ so với ATR, nếu không cần phải chuẩn hóa
    // Ví dụ: bbWidth < 1.5 * ATR là rất hẹp
    double bb_score = 0;
    if (m_current_profile.bbWidth < (m_current_profile.atrCurrent * 1.5)) {
        bb_score = 100.0;
    } else if (m_current_profile.bbWidth < (m_current_profile.atrCurrent * 2.5)) {
        bb_score = 50.0;
    }
    score += bb_score * bb_weight;
    total_weight += bb_weight;

    if (total_weight <= 0) return 50.0;

    return fmax(0.0, fmin(100.0, score / total_weight)); // Chuẩn hóa điểm cuối cùng
}

//+------------------------------------------------------------------+
//| Hàm kiểm tra thị trường choppy (dựa trên điểm số)                |
//+------------------------------------------------------------------+
bool CMarketProfile::IsChoppyMarket() const
{
    return m_current_profile.choppyScore >= m_context->Inputs.CoreStrategy.ChoppyScoreThreshold;
}
        CopyLow(m_Symbol, m_MainTimeframe, 0, 100, m_LowBuffer) <= 0 ||
        CopyTime(m_Symbol, m_MainTimeframe, 0, 100, m_TimeBuffer) <= 0)
    {
        if (m_Context != NULL && m_Context->Logger != NULL) {
            m_Context->Logger->LogError(StringFormat("MarketProfile: Failed to copy price data - Error %d", GetLastError()));
        }
        
        return false;
    }
    
    // ----- Lấy dữ liệu chỉ báo - Khung H1 -----
    
    // Chuẩn bị các array
    ArraySetAsSeries(m_EmaFastBuffer, true);
    ArraySetAsSeries(m_EmaMediumBuffer, true);
    ArraySetAsSeries(m_EmaSlowBuffer, true);
    ArraySetAsSeries(m_AtrBuffer, true);
    ArraySetAsSeries(m_AdxBuffer, true);
    ArraySetAsSeries(m_AdxPlusBuffer, true);
    ArraySetAsSeries(m_AdxMinusBuffer, true);
    ArraySetAsSeries(m_RsiBuffer, true);
    ArraySetAsSeries(m_MacdBuffer, true);
    ArraySetAsSeries(m_MacdSignalBuffer, true);
    ArraySetAsSeries(m_MacdHistBuffer, true);
    
    // Copy dữ liệu EMA
    if (CopyBuffer(m_HandleEmaFast, 0, 0, 100, m_EmaFastBuffer) <= 0 ||
        CopyBuffer(m_HandleEmaMedium, 0, 0, 100, m_EmaMediumBuffer) <= 0 ||
        CopyBuffer(m_HandleEmaSlow, 0, 0, 100, m_EmaSlowBuffer) <= 0)
    {
        if (m_Context != NULL && m_Context->Logger != NULL) {
            m_Context->Logger->LogError(StringFormat("MarketProfile: Failed to copy EMA data - Error %d", GetLastError()));
        }
        
        return false;
    }
    
    // Copy dữ liệu ATR
    if (CopyBuffer(m_HandleAtr, 0, 0, 100, m_AtrBuffer) <= 0)
    {
        if (m_Context != NULL && m_Context->Logger != NULL) {
            m_Context->Logger->LogError(StringFormat("MarketProfile: Failed to copy ATR data - Error %d", GetLastError()));
        }
        
        return false;
    }
    
    // Copy dữ liệu ADX
    if (CopyBuffer(m_HandleAdx, 0, 0, 100, m_AdxBuffer) <= 0 ||
        CopyBuffer(m_HandleAdx, 1, 0, 100, m_AdxPlusBuffer) <= 0 ||
        CopyBuffer(m_HandleAdx, 2, 0, 100, m_AdxMinusBuffer) <= 0)
    {
        if (m_Context != NULL && m_Context->Logger != NULL) {
            m_Context->Logger->LogError(StringFormat("MarketProfile: Failed to copy ADX data - Error %d", GetLastError()));
        }
        
        return false;
    }
    
    // Copy dữ liệu RSI
    if (CopyBuffer(m_HandleRsi, 0, 0, 100, m_RsiBuffer) <= 0)
    {
        if (m_Context != NULL && m_Context->Logger != NULL) {
            string logMessage = StringFormat("MarketProfile: Failed to copy RSI data - Error %d", GetLastError());
            m_Context->Logger->LogError(logMessage);
        }
        
        return false;
    }
    
    // Copy dữ liệu MACD
    if (CopyBuffer(m_HandleMacd, 0, 0, 100, m_MacdBuffer) <= 0 ||
        CopyBuffer(m_HandleMacd, 1, 0, 100, m_MacdSignalBuffer) <= 0)
    {
        if (m_Context != NULL && m_Context->Logger != NULL) {
            string logMessage = StringFormat("MarketProfile: Failed to copy MACD data - Error %d", GetLastError());
            m_Context->Logger->LogError(logMessage);
        }
        
        return false;
    }

    // Copy Bollinger Bands data and calculate BBW
    // iBands: buffer 0 = Middle, 1 = Upper, 2 = Lower
    // Chuyển từ mảng cấp phát tĩnh sang mảng cấp phát động để có thể dùng ArraySetAsSeries
    double upperBand[];
    double lowerBand[];
    double middleBand[];
    
    // Cấp phát động cho các mảng
    ArrayResize(upperBand, 100);
    ArrayResize(lowerBand, 100);
    ArrayResize(middleBand, 100);
    
    // Đảm bảo m_BBWBuffer cũng được cấp phát đủ kích thước
    ArrayResize(m_BBWBuffer, MathMax(ArraySize(m_BBWBuffer), 100));
    
    // Cấu hình mảng
    ArraySetAsSeries(upperBand, true);
    ArraySetAsSeries(lowerBand, true);
    ArraySetAsSeries(middleBand, true);
    ArraySetAsSeries(m_BBWBuffer, true);

    if (m_HandleBBW != INVALID_HANDLE && 
        (CopyBuffer(m_HandleBBW, 0, 0, 100, middleBand) <= 0 ||
         CopyBuffer(m_HandleBBW, 1, 0, 100, upperBand) <= 0 ||
         CopyBuffer(m_HandleBBW, 2, 0, 100, lowerBand) <= 0))
    {
        if (m_Context->Logger != NULL) {
            m_Context->Logger->LogError(StringFormat("MarketProfile: Failed to copy Bollinger Bands data - Error %d", GetLastError()));
        }
        // Decide if this is a fatal error or if we can proceed without BBW
        // For now, let's log and continue, BBW score will be 0 if data is missing.
        // return false; 
    }
    else if (m_HandleBBW != INVALID_HANDLE)
    {
        for(int i = 0; i < 100; i++)
        {
            // Sử dụng 0 hoặc EMPTY_VALUE thay thế INVALID_VALUE để tránh lỗi
            // EMPTY_VALUE là hằng số có sẵn trong MQL5
            if(middleBand[i] != 0 && MathIsValidNumber(middleBand[i]) && MathIsValidNumber(upperBand[i]) && MathIsValidNumber(lowerBand[i])) 
                m_BBWBuffer[i] = (upperBand[i] - lowerBand[i]) / middleBand[i]; 
            else if (MathIsValidNumber(upperBand[i]) && MathIsValidNumber(lowerBand[i])) // Fallback if middle is zero or invalid
                 m_BBWBuffer[i] = upperBand[i] - lowerBand[i]; // Simplified: Upper - Lower
            else
                m_BBWBuffer[i] = 0;
        }
    }
    else
    {
        // HandleBBW is invalid, fill BBWBuffer with 0s
        for(int i = 0; i < 100; i++) m_BBWBuffer[i] = 0;
        if (m_Context != NULL && m_Context->Logger != NULL && m_Context->Logger->IsDebugEnabled()) {
             m_Context->Logger->LogDebug("MarketProfile: m_HandleBBW is INVALID_HANDLE. BBW data will be zero.");
        }
    }
    
    // Tính MACD Histogram
    for (int i = 0; i < 100 && i < ArraySize(m_MacdBuffer) && i < ArraySize(m_MacdSignalBuffer); i++)
    {
        m_MacdHistBuffer[i] = m_MacdBuffer[i] - m_MacdSignalBuffer[i];
    }
    
    // ----- Lấy dữ liệu chỉ báo - Khung H4 (nếu sử dụng) -----
    if (m_UseMultiTimeframe)
    {
        // Chuẩn bị các array
        ArraySetAsSeries(m_EmaFastBufferH4, true);
        ArraySetAsSeries(m_EmaMediumBufferH4, true);
        ArraySetAsSeries(m_EmaSlowBufferH4, true);
        ArraySetAsSeries(m_AtrBufferH4, true);
        ArraySetAsSeries(m_AdxBufferH4, true);
        
        // Copy dữ liệu EMA H4
        if (CopyBuffer(m_HandleEmaFastH4, 0, 0, 50, m_EmaFastBufferH4) <= 0 ||
            CopyBuffer(m_HandleEmaMediumH4, 0, 0, 50, m_EmaMediumBufferH4) <= 0 ||
            CopyBuffer(m_HandleEmaSlowH4, 0, 0, 50, m_EmaSlowBufferH4) <= 0)
        {
            if (m_Context != NULL && m_Context->Logger != NULL) {
                m_Context->Logger->LogError(StringFormat("MarketProfile: Failed to copy H4 EMA data - Error %d", GetLastError()));
            }
            
            return false;
        }
        
        // Copy dữ liệu ATR H4
        if (CopyBuffer(m_HandleAtrH4, 0, 0, 50, m_AtrBufferH4) <= 0)
        {
            if (m_Context != NULL && m_Context->Logger != NULL) {
                string logMessage = StringFormat("MarketProfile: Failed to copy H4 ATR data - Error %d", GetLastError());
                m_Context->Logger->LogError(logMessage);
            }
            
            return false;
        }
        
        // Copy dữ liệu ADX H4
        if (CopyBuffer(m_HandleAdxH4, 0, 0, 50, m_AdxBufferH4) <= 0)
        {
            if (m_Context != NULL && m_Context->Logger != NULL) {
                string logMessage = StringFormat("MarketProfile: Failed to copy H4 ADX data - Error %d", GetLastError());
                m_Context->Logger->LogError(logMessage);
            }
            
            return false;
        }
    }
    
    // ----- Cập nhật thông tin thị trường -----
    
    // Cập nhật giá trị EMA
    m_CurrentProfile.ema34 = m_EmaFastBuffer[0];
    m_CurrentProfile.ema89 = m_EmaMediumBuffer[0];
    m_CurrentProfile.ema200 = m_EmaSlowBuffer[0];
    
    // Cập nhật giá trị EMA H4 nếu sử dụng
    if (m_UseMultiTimeframe)
    {
        m_CurrentProfile.ema34H4 = m_EmaFastBufferH4[0];
        m_CurrentProfile.ema89H4 = m_EmaMediumBufferH4[0];
        m_CurrentProfile.ema200H4 = m_EmaSlowBufferH4[0];
    }
    
    // Cập nhật giá trị ATR và tỉ lệ ATR
    m_CurrentProfile.atrCurrent = m_AtrBuffer[0];
    
    // Cập nhật giá trị ATR ratio nếu có ATR trung bình
    if (m_AverageDailyAtr > 0)
        m_CurrentProfile.atrRatio = m_CurrentProfile.atrCurrent / m_AverageDailyAtr;
    else
        m_CurrentProfile.atrRatio = 1.0; // Mặc định nếu chưa có ATR trung bình
    
    // Cập nhật giá trị ADX và Slope
    m_CurrentProfile.adxValue = m_AdxBuffer[0];
    m_CurrentProfile.adxSlope = this->CalculateSlope(m_AdxBuffer, 5);
    m_CurrentProfile.minAdxValue = m_Context->MinAdxValue; // Store Min ADX from context
    
    // Cập nhật giá trị RSI và Slope
    m_CurrentProfile.rsiValue = m_RsiBuffer[0];
    m_CurrentProfile.rsiSlope = this->CalculateSlope(m_RsiBuffer, 5);
    
    // Cập nhật giá trị MACD
    m_CurrentProfile.macdHistogram = m_MacdHistBuffer[0];
    m_CurrentProfile.macdHistogramSlope = this->CalculateSlope(m_MacdHistBuffer, 5);
    
    // ----- Phân tích thị trường -----
    
    // Xác định xu hướng
    m_CurrentProfile.trend = this->DetermineTrend();
    
    // Xác định chế độ thị trường
    m_CurrentProfile.regime = this->DetermineRegime();
    
    // Xác định phiên giao dịch
    m_CurrentProfile.currentSession = this->DetermineCurrentSession();
    
    // Kiểm tra sự phân kỳ giữa các timeframe
    m_CurrentProfile.mtfAlignment = this->IsMultiTimeframeAligned() ? 
        (m_CurrentProfile.trend == ApexPullback::TREND_UP_NORMAL || m_CurrentProfile.trend == ApexPullback::TREND_UP_STRONG ? 
         ApexPullback::MTF_ALIGNMENT_BULLISH : (m_CurrentProfile.trend == ApexPullback::TREND_DOWN_NORMAL || m_CurrentProfile.trend == ApexPullback::TREND_DOWN_STRONG ? ApexPullback::MTF_ALIGNMENT_BEARISH : ApexPullback::MTF_ALIGNMENT_NEUTRAL)) : 
        ApexPullback::MTF_ALIGNMENT_CONFLICTING;
    
    // Tính điểm mạnh của xu hướng
    m_CurrentProfile.trendScore = this->CalculateTrendStrength();
    
    // Kiểm tra thị trường đang trending
    m_CurrentProfile.isTrending = (m_CurrentProfile.adxValue > m_Context->MinAdxValue);
    
    // Kiểm tra các cờ đặc biệt
    m_CurrentProfile.isSidewaysOrChoppy = this->IsSidewayMarket() || this->IsChoppyMarket();
    m_CurrentProfile.isLowMomentum = this->CheckLowMomentum();
    m_CurrentProfile.isVolatile = this->CheckHighVolatility();
    
    // Kiểm tra thị trường đang chuyển đổi chế độ
    double regimeConfidence = 0.0;
    
    // Tính độ tin cậy của regime dựa trên ADX, EMA alignment, và trendScore
    if (m_CurrentProfile.adxValue > 30)
        regimeConfidence += 0.4;  // ADX cao -> độ tin cậy cao
    else if (m_CurrentProfile.adxValue > 20)
        regimeConfidence += 0.3;
    else if (m_CurrentProfile.adxValue > m_Context->MinAdxValue)
        regimeConfidence += 0.2;
    else
        regimeConfidence += 0.1;
    
    // EMA alignment
    double emaSpreadH1 = this->CalculateEmaSpread(false);
    double emaSpreadH4 = this->CalculateEmaSpread(true);
    
    if (emaSpreadH1 > 0.5 && emaSpreadH4 > 0.5)
        regimeConfidence += 0.3;  // EMA xa nhau -> độ tin cậy cao cho trending
    else if (emaSpreadH1 > 0.3 || emaSpreadH4 > 0.3)
        regimeConfidence += 0.2;
    else
        regimeConfidence += 0.1;
    
    // Trend Score
    if (m_CurrentProfile.trendScore > 0.7)
        regimeConfidence += 0.3;
    else if (m_CurrentProfile.trendScore > 0.5)
        regimeConfidence += 0.2;
    else
        regimeConfidence += 0.1;
    
    // Chuẩn hóa
    regimeConfidence = MathMin(regimeConfidence, 1.0);
    m_CurrentProfile.regimeConfidence = regimeConfidence;
    
    // Xác định thị trường đang chuyển đổi chế độ
    m_CurrentProfile.isTransitioning = (regimeConfidence < 0.6);
    
    // Cập nhật lịch sử spread
    this->UpdateSpreadHistory();
    
    // Cập nhật thời gian
    m_LastUpdateTime = currentTime;
    
    // Ghi log chi tiết nếu cần
    if (m_Context != NULL && m_Context->Logger != NULL && m_Context->Logger->IsDebugEnabled())
    {
        string profileInfo = StringFormat(
            "Market Profile [%s]: Trend=%s, Regime=%s, Session=%s, ADX=%.1f (Min: %.1f), ATR=%.5f (%.1fx), RSI=%.1f",
            m_Symbol,
            EnumToString(m_CurrentProfile.trend),
            EnumToString(m_CurrentProfile.regime),
            EnumToString(m_CurrentProfile.currentSession),
            m_CurrentProfile.adxValue,
            m_CurrentProfile.minAdxValue, // Log Min ADX
            m_CurrentProfile.atrCurrent,
            m_CurrentProfile.atrRatio,
            m_CurrentProfile.rsiValue
        );
        
        m_Context->Logger->LogDebug(profileInfo);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Hàm xác định xu hướng thị trường                                |
//+------------------------------------------------------------------+
ApexPullback::ENUM_MARKET_TREND CMarketProfile::DetermineTrend()
{
    // Lấy các giá trị chỉ báo hiện tại
    double ema34 = m_EmaFastBuffer[0];
    double ema89 = m_EmaMediumBuffer[0];
    double ema200 = m_EmaSlowBuffer[0];
    double adx = m_AdxBuffer[0];
    double diPlus = m_AdxPlusBuffer[0];
    double diMinus = m_AdxMinusBuffer[0];
    
    // Lấy các giá trị từ khung H4 nếu sử dụng
    double ema34H4 = 0, ema89H4 = 0, ema200H4 = 0, adxH4 = 0;
    
    if (m_UseMultiTimeframe)
    {
        ema34H4 = m_EmaFastBufferH4[0];
        ema89H4 = m_EmaMediumBufferH4[0];
        ema200H4 = m_EmaSlowBufferH4[0];
        adxH4 = m_AdxBufferH4[0];
    }
    
    // ----- Phân tích xu hướng -----
    
    // Xác định trạng thái EMA H1
    bool emaUpAligned = (ema34 > ema89) && (ema89 > ema200);
    bool emaDownAligned = (ema34 < ema89) && (ema89 < ema200);
    
    // Xác định trạng thái EMA H4 (nếu sử dụng)
    bool emaUpAlignedH4 = false;
    bool emaDownAlignedH4 = false;
    
    if (m_UseMultiTimeframe)
    {
        emaUpAlignedH4 = (ema34H4 > ema89H4) && (ema89H4 > ema200H4);
        emaDownAlignedH4 = (ema34H4 < ema89H4) && (ema89H4 < ema200H4);
    }
    
    // Xác định trạng thái ADX và DI
    bool strongADX = (adx > 25);
    // Truy cập MinAdxValue qua con trỏ m_Context
    bool moderateADX = (adx > m_Context->MinAdxValue && adx <= 25); 
    bool diPlusStronger = (diPlus > diMinus);
    bool diMinusStronger = (diMinus > diPlus);
    
    // ----- Xác định xu hướng -----
    
    // Xu hướng tăng mạnh
    if (emaUpAligned && strongADX && diPlusStronger)
    {
        if (!m_UseMultiTimeframe || emaUpAlignedH4)
            return TREND_UP_STRONG;
    }
    
    // Xu hướng giảm mạnh
    if (emaDownAligned && strongADX && diMinusStronger)
    {
        if (!m_UseMultiTimeframe || emaDownAlignedH4)
            return TREND_DOWN_STRONG;
    }
    
    // Xu hướng tăng
    if (emaUpAligned && (moderateADX || diPlusStronger))
    {
        // Kiểm tra pullback
        double close = m_CloseBuffer[0];
        if (close < ema34)
            return ApexPullback::TREND_UP_PULLBACK;
        else
            return ApexPullback::TREND_UP_NORMAL;
    }
    
    // Xu hướng giảm
    if (emaDownAligned && (moderateADX || diMinusStronger))
    {
        // Kiểm tra pullback
        double close = m_CloseBuffer[0];
        if (close > ema34)
            return ApexPullback::TREND_DOWN_PULLBACK;
        else
            return ApexPullback::TREND_DOWN_NORMAL;
    }
    
    // Không có xu hướng rõ ràng
    return ApexPullback::TREND_SIDEWAY;
}

//+------------------------------------------------------------------+
//| Hàm xác định chế độ thị trường                                  |
//+------------------------------------------------------------------+
ApexPullback::ENUM_MARKET_REGIME CMarketProfile::DetermineRegime()
{
    // Lấy các giá trị hiện tại
    double adx = m_AdxBuffer[0];
    double currentAtrRatio = m_CurrentProfile.atrRatio; // Đổi tên biến để tránh xung đột nếu có
    ApexPullback::ENUM_MARKET_TREND currentTrend = m_CurrentProfile.trend;

    // ----- Xác định chế độ thị trường -----
    
    // Thị trường đang trending
    if (adx > 25)
    {
        if (currentTrend == ApexPullback::TREND_UP_NORMAL || currentTrend == ApexPullback::TREND_UP_STRONG)
            return ApexPullback::REGIME_TRENDING_BULL;
        else if (currentTrend == ApexPullback::TREND_DOWN_NORMAL || currentTrend == ApexPullback::TREND_DOWN_STRONG)
            return ApexPullback::REGIME_TRENDING_BEAR;
    }
    
    // Thị trường biến động cao
    // Truy cập VolatilityThreshold qua con trỏ m_Context
    if (currentAtrRatio > m_Context->VolatilityThreshold) 
    {
        // Truy cập MinAdxValue qua con trỏ m_Context
        if (adx > m_Context->MinAdxValue) 
            return ApexPullback::REGIME_VOLATILE_EXPANSION;  // Biến động cao + có xu hướng
        else
            return ApexPullback::REGIME_RANGING_VOLATILE;   // Biến động cao không xu hướng
    }
    
    // Thị trường sideway có tổ chức
    if (IsSidewayMarket()) // Gọi hàm thành viên trực tiếp
    {
        if (currentAtrRatio < 0.8)
            return ApexPullback::REGIME_RANGING_STABLE;      // Sideway ổn định
        else
            return ApexPullback::REGIME_RANGING_VOLATILE;    // Sideway biến động
    }
    
    // Thị trường có xu hướng yếu
    // Truy cập MinAdxValue qua con trỏ m_Context
    if (adx > m_Context->MinAdxValue && adx <= 25) 
    {
        if (currentTrend == ApexPullback::TREND_UP_NORMAL || currentTrend == ApexPullback::TREND_UP_PULLBACK)
            return ApexPullback::REGIME_TRENDING_BULL;
        else if (currentTrend == ApexPullback::TREND_DOWN_NORMAL || currentTrend == ApexPullback::TREND_DOWN_PULLBACK)
            return ApexPullback::REGIME_TRENDING_BEAR;
        else
            return ApexPullback::REGIME_RANGING_VOLATILE;
    }
    
    // Thị trường đang co hẹp biến động
    if (currentAtrRatio < 0.7)
        return ApexPullback::REGIME_VOLATILE_CONTRACTION;
    
    // Mặc định: ranging stable
    return ApexPullback::REGIME_RANGING_STABLE;
}

//+------------------------------------------------------------------+
//| Hàm xác định phiên giao dịch hiện tại                           |
//+------------------------------------------------------------------+
ApexPullback::ENUM_SESSION CMarketProfile::DetermineCurrentSession()
{
    // Lấy thời gian hiện tại (GMT)
    MqlDateTime dt;
    TimeToStruct(TimeGMT(), dt);
    
    int hour = dt.hour;
    
    // Xác định phiên giao dịch dựa trên giờ GMT
    if (hour >= 0 && hour < 7)
        return ApexPullback::SESSION_ASIAN;         // Phiên Á
    else if (hour >= 7 && hour < 12)
        return ApexPullback::SESSION_EUROPEAN;        // Phiên Âu (London)
    else if (hour >= 12 && hour < 16)
        return ApexPullback::SESSION_EUROPEAN_AMERICAN; // Phiên giao thoa Âu-Mỹ
    else if (hour >= 16 && hour < 20)
        return ApexPullback::SESSION_AMERICAN;       // Phiên Mỹ (New York)
    else
        return ApexPullback::SESSION_CLOSING;       // Phiên đóng cửa
}

//+------------------------------------------------------------------+
//| Hàm kiểm tra sự phân kỳ giữa các timeframe                      |
//+------------------------------------------------------------------+
bool CMarketProfile::IsMultiTimeframeAligned()
{
    if (!m_UseMultiTimeframe)
        return true;  // Nếu không sử dụng đa timeframe, luôn coi là đồng thuận
    
    ApexPullback::ENUM_MARKET_TREND currentTrend = m_CurrentProfile.trend;
    // Kiểm tra khi trend tăng
    if (currentTrend == ApexPullback::TREND_UP_NORMAL || currentTrend == ApexPullback::TREND_UP_STRONG || 
        currentTrend == ApexPullback::TREND_UP_PULLBACK)
    {
        // H4 phải cùng xu hướng tăng
        return (m_CurrentProfile.ema34H4 > m_CurrentProfile.ema89H4);
    }
    
    // Kiểm tra khi trend giảm
    if (currentTrend == ApexPullback::TREND_DOWN_NORMAL || currentTrend == ApexPullback::TREND_DOWN_STRONG || 
        currentTrend == ApexPullback::TREND_DOWN_PULLBACK)
    {
        // H4 phải cùng xu hướng giảm
        return (m_CurrentProfile.ema34H4 < m_CurrentProfile.ema89H4);
    }
    
    // Mặc định: không có trend rõ ràng
    return false;
}

//+------------------------------------------------------------------+
//| Hàm tính toán độ dốc                                            |
//+------------------------------------------------------------------+
double CMarketProfile::CalculateSlope(const double &buffer[], int periods)
{
    if (periods <= 1 || ArraySize(buffer) < periods)
        return 0;
    
    // Sử dụng Linear Regression
    double sum_x = 0, sum_y = 0, sum_xy = 0, sum_xx = 0;
    
    for (int i = 0; i < periods; i++)
    {
        sum_x += i;
        sum_y += buffer[i];
        sum_xy += i * buffer[i];
        sum_xx += i * i;
    }
    
    double n = (double)periods;
    double slope = (n * sum_xy - sum_x * sum_y) / (n * sum_xx - sum_x * sum_x);
    
    // Đảo dấu vì buffer là sắp xếp ngược (index 0 là mới nhất)
    return -slope;
}

//+------------------------------------------------------------------+
//| Hàm tính điểm mạnh của xu hướng                                 |
//+------------------------------------------------------------------+
double CMarketProfile::CalculateTrendStrength()
{
    double score = 0.0;
    
    double adxValue = m_CurrentProfile.adxValue;
    // 1. ADX - đóng góp 40%
    if (adxValue > 40)
        score += 0.4;
    else if (adxValue > 30)
        score += 0.3;
    else if (adxValue > 25)
        score += 0.25;
    else if (adxValue > 20)
        score += 0.2;
    // Truy cập MinAdxValue qua con trỏ m_Context
    else if (adxValue > m_Context->MinAdxValue) 
        score += 0.1;
    
    // 2. EMA Alignment - đóng góp 30%
    double emaSpread = CalculateEmaSpread(false);  // H1 // Gọi hàm thành viên trực tiếp
    if (emaSpread > 1.0)
        score += 0.3;
    else if (emaSpread > 0.7)
        score += 0.25;
    else if (emaSpread > 0.5)
        score += 0.2;
    else if (emaSpread > 0.3)
        score += 0.1;
    else
        score += 0.05;
    
    // 3. Cũng xu hướng H4 - đóng góp 30%
    if (m_UseMultiTimeframe)
    {
        ApexPullback::ENUM_MTF_ALIGNMENT mtfAlignment = m_CurrentProfile.mtfAlignment;
        if (mtfAlignment != ApexPullback::MTF_ALIGNMENT_CONFLICTING)
        {
            double emaSpreadH4 = CalculateEmaSpread(true);  // H4 // Gọi hàm thành viên trực tiếp
            if (emaSpreadH4 > 1.0)
                score += 0.3;
            else if (emaSpreadH4 > 0.7)
                score += 0.25;
            else if (emaSpreadH4 > 0.5)
                score += 0.2;
            else if (emaSpreadH4 > 0.3)
                score += 0.1;
            else
                score += 0.05;
        }
    }
    else
    {
        // Nếu không sử dụng đa timeframe, cho điểm tối đa
        score += 0.3;
    }
    
    // Giới hạn trong khoảng 0.0 - 1.0
    return MathMin(score, 1.0);
}

//+------------------------------------------------------------------+
//| Hàm tính khoảng cách giữa các EMA                              |
//+------------------------------------------------------------------+
double CMarketProfile::CalculateEmaSpread(bool useHigherTimeframe)
{
    double ema34, ema89, ema200, atr;
    
    if (useHigherTimeframe)
    {
        if (!m_UseMultiTimeframe)
            return 0.0;
        
        ema34 = m_CurrentProfile.ema34H4;
        ema89 = m_CurrentProfile.ema89H4;
        ema200 = m_CurrentProfile.ema200H4;
        atr = (ArraySize(m_AtrBufferH4) > 0) ? m_AtrBufferH4[0] : 0.0; // Kiểm tra kích thước mảng trước khi truy cập
    }
    else
    {
        ema34 = m_CurrentProfile.ema34;
        ema89 = m_CurrentProfile.ema89;
        ema200 = m_CurrentProfile.ema200;
        atr = m_CurrentProfile.atrCurrent;
    }
    
    // Nếu ATR = 0, trả về 0 để tránh lỗi chia cho 0
    if (atr == 0)
        return 0.0;
    
    // Tính khoảng cách giữa các EMA, chuẩn hóa theo ATR
    double distance1 = MathAbs(ema34 - ema89) / atr;
    double distance2 = MathAbs(ema89 - ema200) / atr;
    
    // Lấy trung bình của hai khoảng cách
    return (distance1 + distance2) / 2.0;
}

//+------------------------------------------------------------------+
//| Hàm cập nhật lịch sử ATR                                        |
//+------------------------------------------------------------------+
void CMarketProfile::UpdateAtrHistory()
{
    // Copy dữ liệu ATR từ D1
    double atrDailyBuffer[];
    ArraySetAsSeries(atrDailyBuffer, true);
    
    int handleAtrDaily = iATR(m_Symbol, PERIOD_D1, 14); // Using standard ATR period
    if (handleAtrDaily == INVALID_HANDLE)
    {
        // Truy cập Logger qua con trỏ m_Context
    if (m_Context != NULL && m_Context->Logger != NULL) { 
        m_Context->Logger->LogError("MarketProfile: Failed to create daily ATR handle");
    }
        
        return;
    }
    
    if (CopyBuffer(handleAtrDaily, 0, 0, 20, atrDailyBuffer) <= 0)
    {
        // Truy cập Logger qua con trỏ m_Context
    if (m_Context != NULL && m_Context->Logger != NULL) { 
        m_Context->Logger->LogError("MarketProfile: Failed to copy daily ATR data");
    }
        
        IndicatorRelease(handleAtrDaily);
        return;
    }
    
    // Tính trung bình ATR 20 ngày
    double sumAtr = 0;
    int validCount = 0;
    
    for (int i = 0; i < ArraySize(atrDailyBuffer); i++)
    {
        if (atrDailyBuffer[i] > 0)
        {
            sumAtr += atrDailyBuffer[i];
            validCount++;
        }
    }
    
    if (validCount > 0)
        m_AverageDailyAtr = sumAtr / validCount;
    else
        m_AverageDailyAtr = 0;
    
    // Lưu lại lịch sử ATR
    if (validCount > 0)
        ArrayCopy(m_AtrHistory, atrDailyBuffer, 0, 0, MathMin(20, validCount));
    
    IndicatorRelease(handleAtrDaily);
    
    // Truy cập Logger qua con trỏ m_Context
    if (m_Context != NULL && m_Context->Logger != NULL && m_Context->Logger->IsDebugEnabled()) 
    {
        m_Context->Logger->LogDebug("MarketProfile: Updated ATR history - Average Daily ATR: " + 
                       DoubleToString(m_AverageDailyAtr, _Digits));
    }
}

//+------------------------------------------------------------------+
//| Hàm cập nhật lịch sử spread                                     |
//+------------------------------------------------------------------+
void CMarketProfile::UpdateSpreadHistory()
{
    // Lấy spread hiện tại
    double currentSpread = (double)SymbolInfoInteger(m_Symbol, SYMBOL_SPREAD) * SymbolInfoDouble(m_Symbol, SYMBOL_POINT);
    
    // Shift mảng
    for (int i = ArraySize(m_SpreadBuffer) - 1; i > 0; i--)
    {
        m_SpreadBuffer[i] = m_SpreadBuffer[i-1];
    }
    
    // Thêm spread mới vào đầu mảng
    m_SpreadBuffer[0] = currentSpread;
    
    // Tăng count nếu chưa đầy
    if (m_SpreadCount < ArraySize(m_SpreadBuffer))
        m_SpreadCount++;
}

//+------------------------------------------------------------------+
//| Hàm kiểm tra thị trường sideway                                 |
//+------------------------------------------------------------------+
// [IsSidewayMarket đã được định nghĩa ở dòng 250]

// [IsSidewayMarket đã được di chuyển vào trong lớp CMarketProfile]

//+------------------------------------------------------------------+
//| Hàm kiểm tra thị trường choppy                                  |
//+------------------------------------------------------------------+
bool CMarketProfile::IsChoppyMarket() const
{
    double adxValue = m_CurrentProfile.adxValue;
    double atrRatio = m_CurrentProfile.atrRatio;
    // Kiểm tra ADX thấp
    // Truy cập MinAdxValue qua con trỏ m_Context
    if (adxValue < m_Context->MinAdxValue) 
    {
        // Kiểm tra thêm độ biến động
        if (atrRatio < 0.8 || atrRatio > 1.5)
            return true;
        
        // Kiểm tra sự mâu thuẫn giữa các chỉ báo
        double diPlus = m_AdxPlusBuffer[0];
        double diMinus = m_AdxMinusBuffer[0];
        
        // DI+/DI- gần nhau -> không có ưu thế rõ ràng
        if (MathAbs(diPlus - diMinus) < 5)
            return true;
    }
    
    // Kiểm tra EMA cross thường xuyên
    int crossCount = 0;
    for (int i = 1; i < 10; i++)
    {
        if ((m_EmaFastBuffer[i] > m_EmaMediumBuffer[i] && m_EmaFastBuffer[i+1] <= m_EmaMediumBuffer[i+1]) ||
            (m_EmaFastBuffer[i] < m_EmaMediumBuffer[i] && m_EmaFastBuffer[i+1] >= m_EmaMediumBuffer[i+1]))
        {
            crossCount++;
        }
    }
    
    if (crossCount >= 2)  // 2 cross trong 10 nến -> choppy
        return true;
    
    return false;
}

//+------------------------------------------------------------------+
//| Hàm kiểm tra động lượng thấp                                    |
//+------------------------------------------------------------------+
bool CMarketProfile::CheckLowMomentum()
{
    // Kiểm tra RSI ở vùng trung tính
    if (m_CurrentProfile.rsiValue > 45 && m_CurrentProfile.rsiValue < 55)
    {
        // Độ dốc RSI thấp
        if (MathAbs(m_CurrentProfile.rsiSlope) < 0.2)
            return true;
    }
    
    // Kiểm tra MACD Histogram gần 0
    if (MathAbs(m_CurrentProfile.macdHistogram) < 0.0001)
        return true;
    
    // Kiểm tra ADX và độ dốc
    if (m_CurrentProfile.adxValue < 20 && MathAbs(m_CurrentProfile.adxSlope) < 0.1)
        return true;
    
    return false;
}

//+------------------------------------------------------------------+
//| Hàm kiểm tra thị trường biến động cao                          |
//+------------------------------------------------------------------+
bool CMarketProfile::CheckHighVolatility()
{
    double atrRatio = m_CurrentProfile.atrRatio;
    // Kiểm tra tỷ lệ ATR
    // Truy cập VolatilityThreshold qua con trỏ m_Context
    if (atrRatio > m_Context->VolatilityThreshold) 
        return true;
    
    // Kiểm tra sự thay đổi lớn gần đây
    double maxMove = 0;
    for (int i = 1; i < 5; i++)
    {
        double moveSize = MathAbs(m_HighBuffer[i] - m_LowBuffer[i]) / m_CurrentProfile.atrCurrent;
        if (moveSize > maxMove)
            maxMove = moveSize;
    }
    
    if (maxMove > 1.5)  // Di chuyển > 1.5 ATR trong 1 nến
        return true;
    
    return false;
}

//+------------------------------------------------------------------+
//| Hàm kiểm tra giá trong vùng pullback                            |
//+------------------------------------------------------------------+
bool CMarketProfile::IsPriceInPullbackZone(bool isLong)
{
    double currentPrice = m_CloseBuffer[0];
    bool isPullbackZone = false;

    // Lấy giá trị EMA từ m_CurrentProfile
    double ema34 = m_CurrentProfile.ema34;
    double ema89 = m_CurrentProfile.ema89;
    double ema200 = m_CurrentProfile.ema200;
    double atrCurrent = m_CurrentProfile.atrCurrent;
    double recentSwingHigh = m_CurrentProfile.recentSwingHigh;
    // Giả sử recentSwingLow cũng cần thiết cho trường hợp short, nếu không có thì cần thêm vào MarketProfileData
    // double recentSwingLow = m_CurrentProfile.recentSwingLow; 
    
    // Các hằng số quan trọng
    double MAX_PULLBACK_DEPTH = 1.5; // Khoảng cách tối đa tính theo ATR
    
    if (isLong)
    {
        // Vùng pullback trong xu hướng tăng:
        // 1. Giá đã pullback xuống gần/chạm EMA34
        // 2. Không vượt quá EMA89 quá nhiều
        // 3. KHÔNG BAO GIỜ phá EMA200
        
        isPullbackZone = (currentPrice <= ema34 * 1.001) && // Gần hoặc dưới EMA34 một chút
                        (currentPrice >= ema89 * 0.995) &&  // Không quá sâu dưới EMA89
                        (currentPrice > ema200);            // Luôn trên EMA200
        
        // Kiểm tra thêm khoảng cách hợp lý (không pullback quá sâu)
        if (atrCurrent > 0) { // Tránh chia cho 0
            double pullbackDepth = (recentSwingHigh - currentPrice) / atrCurrent;
            if (pullbackDepth > MAX_PULLBACK_DEPTH) {
                isPullbackZone = false; // Pullback quá sâu -> không vào lệnh
            }
        } else {
            isPullbackZone = false; // Nếu ATR không hợp lệ, không coi là pullback zone
        }
    }
    else // Short
    {
        // Vùng pullback trong xu hướng giảm - logic tương tự nhưng ngược lại
        isPullbackZone = (currentPrice >= ema34 * 0.999) && // Gần hoặc trên EMA34 một chút
                        (currentPrice <= ema89 * 1.005) &&  // Không quá cao trên EMA89
                        (currentPrice < ema200);            // Luôn dưới EMA200
        
        // Kiểm tra thêm khoảng cách hợp lý (không pullback quá sâu)
        // Cần m_CurrentProfile.recentSwingLow cho trường hợp này
        // Ví dụ: double pullbackDepth = (currentPrice - recentSwingLow) / atrCurrent;
        // if (pullbackDepth > MAX_PULLBACK_DEPTH) {
        //     isPullbackZone = false; 
        // }
    }
    
    // Kiểm tra thêm nếu price action đang dao động trong khoảng hẹp
    double range = (m_HighBuffer[0] - m_LowBuffer[0]) / m_AtrBuffer[0];
    if (range < 0.5) { // Biên độ thấp hơn 50% ATR
        double rangeAvg = 0;
        for (int i = 0; i < 5; i++) {
            rangeAvg += (m_HighBuffer[i] - m_LowBuffer[i]);
        }
        rangeAvg /= (5 * m_AtrBuffer[0]);
        
        if (rangeAvg < 0.7) { // Biên độ trung bình thấp
            // Truy cập Logger qua con trỏ m_Context
        if (m_Context != NULL && m_Context->Logger != NULL && m_Context->Logger->IsDebugEnabled()) { 
            m_Context->Logger->LogDebug("Thị trường đang sideway dựa trên price action. Range/ATR: " + 
                     DoubleToString(range, 2));
        }
            // Không nên return true ở đây nếu chỉ vì price action hẹp, 
            // isPullbackZone nên tập trung vào việc giá có nằm trong vùng pullback hợp lệ hay không.
            // Việc xác định sideway nên để cho IsSidewayMarket() hoặc các logic khác.
            // return true; 
        }
    }
    
    return isPullbackZone; // Trả về trạng thái pullback đã xác định ở trên
}

//+------------------------------------------------------------------+
//| Tính toán điểm số Sideways                                       |
//+------------------------------------------------------------------+
double CMarketProfile::CalculateSidewaysScore()
{
    // Đảm bảo dữ liệu đã được cập nhật và đủ nến
    if (ArraySize(m_AtrBuffer) < 1 || ArraySize(m_AdxBuffer) < 1 || 
        ArraySize(m_EmaFastBuffer) < 1 || ArraySize(m_EmaMediumBuffer) < 1 ||
        ArraySize(m_BBWBuffer) < 20) // Chỉ cần kiểm tra 20 nến thay vì 100 để tránh lỗi
    {
        if(m_Context != NULL && m_Context->Logger != NULL && m_Context->Logger->IsDebugEnabled())
        m_Context->Logger->LogDebug("CalculateSidewaysScore: Not enough data in buffers for calculation.");
    return -1.0; // Return -1.0 to indicate insufficient data
    }

    double adx_score = 0.0;
    double ema_score = 0.0;
    double bbw_score = 0.0;

    // 1. ADX Score
    // ADX(14) < 22 -> adx_score = 40
    if (m_AdxBuffer[0] < 22.0)
    {
        adx_score = 40.0;
    }

    // 2. EMA Score
    // EMA(34), EMA(89). ema_distance_atr = MathAbs(ema34 - ema89) / ATR(14).
    // ema_distance_atr < 0.5 -> ema_score = 30
    double ema34 = m_EmaFastBuffer[0]; // Assuming m_EmaFast is 34
    double ema89 = m_EmaMediumBuffer[0]; // Assuming m_EmaMedium is 89
    double atr_current = m_AtrBuffer[0]; // ATR(14)
    if (atr_current > Point() * 10) // Avoid division by zero or very small ATR (e.g. 1 pip for 5-digit broker)
    {
        double ema_distance_atr = MathAbs(ema34 - ema89) / atr_current;
        if (ema_distance_atr < 0.5)
        {
            ema_score = 30.0;
        }
    }

    // 3. BBW Score
    // BBW(20). If current BBW is in the lowest 20% of the last 100 candles -> bbw_score = 30
    // m_BBWBuffer contains (Upper - Lower) / Middle
    double current_bbw = GetBBW(0);
    
    // Đánh giá BBW
    if (MathIsValidNumber(current_bbw) && current_bbw > 0.0001)
    {
        // Tạo biến để lưu BBW thấp nhất trong 100 thanh gần đây
        double lowest_bbw_100_bars = 999999;
        double lowestBBW = 999999;  // Khai báo biến lowestBBW ở đây
        int valid_bbw_values_count = 0;
        
        // Tìm BBW thấp nhất
        for (int i = 0; i < MathMin(ArraySize(m_BBWBuffer), 20); i++)
        {
            if (m_BBWBuffer[i] > Point() * 0.1) // Consider only valid, positive BBW values
            {
                lowest_bbw_100_bars = MathMin(lowest_bbw_100_bars, m_BBWBuffer[i]);
                lowestBBW = lowest_bbw_100_bars; // Cập nhật biến lowestBBW cùng lúc
                valid_bbw_values_count++;
            }
        }
        
        // Only proceed if we have a reasonable number of valid BBW values to compare against
        if (valid_bbw_values_count >= 20) // Heuristic: need at least 20 valid past BBW values for a stable low
        {
            // Check if current BBW is in the lowest 20% range relative to its recent low.
            // This means current_bbw <= lowest_bbw_100_bars * 1.20 (20% above the absolute minimum of recent 100 bars)
            if (current_bbw <= lowest_bbw_100_bars * 1.20) 
            {
                bbw_score = 30.0;
            }
        }
    }

    double final_score = adx_score + ema_score + bbw_score;
    double calculated_lowest_bbw = (ArraySize(m_BBWBuffer) > 0 && valid_bbw_values_count >=20 && lowest_bbw_100_bars != 999999) ? lowest_bbw_100_bars : 0.0;
    if(m_Context != NULL && m_Context->Logger != NULL && m_Context->Logger->IsDebugEnabled()) 
        m_Context->Logger->LogDebug(StringFormat("Sideways Score: %.0f (ADX:%.0f, EMA:%.0f, BBW:%.0f). ADX:%.2f, EMA_Dist/ATR:%.2f, Curr BBW:%.5f, Low BBW_Recent:%.5f", 
                                                    final_score, adx_score, ema_score, bbw_score, 
                                                    m_AdxBuffer[0], 
                                                    (atr_current > Point()*10 ? MathAbs(ema34 - ema89) / atr_current : 0.0),
                                                    current_bbw,
                                                    calculated_lowest_bbw ));
    
    return final_score;
}

//+------------------------------------------------------------------+
//| Kiểm tra thị trường có đang Sideways không                       |
//+------------------------------------------------------------------+
bool CMarketProfile::IsSidewaysMarket()
{
    double score = CalculateSidewaysScore();
    // If score is -1 (not enough data), conservatively assume not sideways.
    if (score < 0.0) return false; 
    return score >= 70.0;
}

//+------------------------------------------------------------------+
//| Lấy giá trị ATR trên khung H4                                |
//+------------------------------------------------------------------+
double CMarketProfile::GetATRH4() const {
    // Đảm bảo đã cập nhật dữ liệu mới nhất
    if (ArraySize(m_AtrBufferH4) > 0) {
        return m_AtrBufferH4[0];
    }
    return 0.0;
}

//+------------------------------------------------------------------+
//| Lấy tỷ lệ biến động hiện tại so với trung bình          |
//+------------------------------------------------------------------+
double CMarketProfile::GetVolatilityRatio() const {
    return m_CurrentProfile.atrRatio;
}

//+------------------------------------------------------------------+
//| Kiểm tra xu hướng đủ mạnh                                       |
//+------------------------------------------------------------------+
bool CMarketProfile::IsTrendStrongEnough() const {
    double adxValue = m_CurrentProfile.adxValue;
    // Kiểm tra ADX đủ mạnh
    // Truy cập MinAdxValue qua con trỏ m_Context
    if (adxValue < m_Context->MinAdxValue) { 
        return false;
    }
    
    // Kiểm tra trend score
    if (m_CurrentProfile.trendScore < 0.6) {
        return false;
    }
    
    // Kiểm tra EMA alignment
    bool emaAligned = false;
    ApexPullback::ENUM_MARKET_TREND currentTrend = m_CurrentProfile.trend;
    double ema34 = m_CurrentProfile.ema34;
    double ema89 = m_CurrentProfile.ema89;
    double ema200 = m_CurrentProfile.ema200;

    switch(currentTrend) {
        case ApexPullback::TREND_UP_NORMAL:
        case ApexPullback::TREND_UP_STRONG:
        case ApexPullback::TREND_UP_PULLBACK:
            emaAligned = (ema34 > ema89) && 
                        (ema89 > ema200);
            break;
            
        case ApexPullback::TREND_DOWN_NORMAL:
        case ApexPullback::TREND_DOWN_STRONG:
        case ApexPullback::TREND_DOWN_PULLBACK:
            emaAligned = (ema34 < ema89) && 
                        (ema89 < ema200);
            break;
            
        default:
            return false; // Sideway
    }
    
    return emaAligned;
}

// [CheckLowMomentum đã được định nghĩa ở dòng 1312]

// [IsChoppyMarket đã được định nghĩa ở dòng 1274]

//+------------------------------------------------------------------+
//| Khởi tạo các chỉ báo                                      |
//+------------------------------------------------------------------+
bool CMarketProfile::InitializeAllIndicators(bool isHigherTimeframe)
{
    // Xác định khung thời gian cần khởi tạo
    ENUM_TIMEFRAMES timeframe = isHigherTimeframe ? m_HigherTimeframe : m_MainTimeframe;
    
    if (m_Context != NULL && m_Context->Logger != NULL) {
        string logMessage = StringFormat("MarketProfile: Initializing indicators for %s timeframe %s", 
                               m_Symbol, 
                               EnumToString(timeframe));
        m_Context->Logger->LogInfo(logMessage);
    }
    
    // Khởi tạo các handle chỉ báo khác nhau dựa vào isHigherTimeframe
    if (isHigherTimeframe) {
        // Khởi tạo các chỉ báo cho khung thời gian cao hơn (H4)
        m_HandleEmaFastH4 = iMA(m_Symbol, timeframe, m_Context->EMA_Fast, 0, MODE_EMA, PRICE_CLOSE);
        m_HandleEmaMediumH4 = iMA(m_Symbol, timeframe, m_Context->EMA_Medium, 0, MODE_EMA, PRICE_CLOSE);
        m_HandleEmaSlowH4 = iMA(m_Symbol, timeframe, m_Context->EMA_Slow, 0, MODE_EMA, PRICE_CLOSE);
        m_HandleAtrH4 = iATR(m_Symbol, timeframe, 14); // Using standard ATR period
        m_HandleAdxH4 = iADX(m_Symbol, timeframe, 14); // Using standard ADX period
        
        // Kiểm tra nếu có lỗi khởi tạo
        if (m_HandleEmaFastH4 == INVALID_HANDLE ||
            m_HandleEmaMediumH4 == INVALID_HANDLE ||
            m_HandleEmaSlowH4 == INVALID_HANDLE ||
            m_HandleAtrH4 == INVALID_HANDLE ||
            m_HandleAdxH4 == INVALID_HANDLE) {
                
            if (m_Context != NULL && m_Context->Logger != NULL) {
                m_Context->Logger->LogError("MarketProfile: Failed to initialize higher timeframe indicators");
            }
            
            return false;
        }
    } else {
        // Khởi tạo các chỉ báo cho khung thời gian chính (H1)
        m_HandleEmaFast = iMA(m_Symbol, timeframe, m_Context->EMA_Fast, 0, MODE_EMA, PRICE_CLOSE);
        m_HandleEmaMedium = iMA(m_Symbol, timeframe, m_Context->EMA_Medium, 0, MODE_EMA, PRICE_CLOSE);
        m_HandleEmaSlow = iMA(m_Symbol, timeframe, m_Context->EMA_Slow, 0, MODE_EMA, PRICE_CLOSE);
        m_HandleAtr = iATR(m_Symbol, timeframe, 14); // Using standard ATR period
        m_HandleAdx = iADX(m_Symbol, timeframe, 14); // Using standard ADX period
        m_HandleRsi = iRSI(m_Symbol, timeframe, 14, PRICE_CLOSE); // Using standard RSI period
        m_HandleMacd = iMACD(m_Symbol, timeframe, 12, 26, 9, PRICE_CLOSE); // Using standard MACD settings
        m_HandleBBW = iBands(m_Symbol, timeframe, 20, 0, 2, PRICE_CLOSE); // Using standard Bollinger Bands settings
        
        // Kiểm tra nếu có lỗi khởi tạo
        if (m_HandleEmaFast == INVALID_HANDLE ||
            m_HandleEmaMedium == INVALID_HANDLE ||
            m_HandleEmaSlow == INVALID_HANDLE ||
            m_HandleAtr == INVALID_HANDLE ||
            m_HandleAdx == INVALID_HANDLE ||
            m_HandleRsi == INVALID_HANDLE ||
            m_HandleMacd == INVALID_HANDLE ||
            m_HandleBBW == INVALID_HANDLE) {
                
            if (m_Context != NULL && m_Context->Logger != NULL) {
                m_Context->Logger->LogError("MarketProfile: Failed to initialize indicators");
            }
            
            return false;
        }
    }
    
    if (m_Context != NULL && m_Context->Logger != NULL) {
        m_Context->Logger->LogInfo(StringFormat("MarketProfile: Successfully initialized %s timeframe indicators", 
                                EnumToString(timeframe)));
    }
    
    return true;
}

} // end of namespace ApexPullback

#endif // MARKETPROFILE_MQH_