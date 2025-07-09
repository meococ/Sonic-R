//+------------------------------------------------------------------+
//|                      Enums.mqh - APEX Pullback EA v14.0          |
//+------------------------------------------------------------------+
#ifndef ENUMS_MQH_
#define ENUMS_MQH_

// === CORE INCLUDES (KHÔNG BẮT BUỘC CHO FILE NÀY VÌ CHỈ CHỨA ENUMS) ===


// BẮT ĐẦU NAMESPACE
namespace ApexPullback {











//===== HƯỚNG GIAO DỊCH =====
/// @brief Cho phép chỉ giao dịch theo một hướng nhất định
enum ENUM_ALLOWED_DIRECTION {
    DIRECTION_BOTH,       // Cả hai hướng Long và Short
    DIRECTION_LONG_ONLY,  // Chỉ Long
    DIRECTION_SHORT_ONLY  // Chỉ Short
};






//+------------------------------------------------------------------+
//| Cấp độ ghi log (Log Level)                                       |
//+------------------------------------------------------------------+
/// @brief Mức độ chi tiết của thông tin log
enum ENUM_LOG_LEVEL {
    LOG_NONE = 0,       // Không ghi log
    LOG_ERROR = 1,      // Chỉ ghi lỗi nghiêm trọng
    LOG_WARNING = 2,    // Ghi lỗi và cảnh báo
    LOG_INFO = 3,       // Ghi lỗi, cảnh báo và thông tin hoạt động (mặc định)
    LOG_DEBUG = 4,      // Ghi tất cả, bao gồm thông tin gỡ lỗi chi tiết
    LOG_VERBOSE = 5     // Ghi tất cả, bao gồm cả thông tin rất chi tiết (thường dùng cho phát triển)
};

//===== TRẠNG THÁI EA =====
/// @brief Trạng thái hoạt động của EA
enum ENUM_EA_STATE {
    STATE_INIT,         // Đang khởi tạo
    STATE_RUNNING,      // Đang chạy bình thường
    STATE_PAUSED,       // Tạm dừng (do volatility, DD, tin tức...)
    STATE_REDUCED_RISK, // Đang chạy với risk thấp hơn (sau DD)
    STATE_STOPPED       // EA đã dừng hoạt động
};



//===== LOẠI SWING POINT =====
/// @brief Định nghĩa các loại swing point
enum ENUM_SWING_POINT_TYPE {
    SWING_UNKNOWN = 0,            // Chưa xác định
    SWING_HIGH = 1,               // Swing High
    SWING_LOW = 2                // Swing Low
};







//===== ĐẦU RA LOG =====
/// @brief Xác định nơi xuất log
enum ENUM_LOG_OUTPUT {
    LOG_OUTPUT_NONE = 0,      // Không xuất log
    LOG_OUTPUT_FILE = 1,      // Chỉ xuất ra file
    LOG_OUTPUT_CONSOLE = 2,   // Chỉ xuất ra console (Experts tab)
    LOG_OUTPUT_BOTH = 3,      // Xuất ra cả hai
    LOG_OUTPUT_ALERT = 4      // Hiển thị qua Alert()
};

//===== CHỦ ĐỀ DASHBOARD =====
/// @brief Định nghĩa các chủ đề màu sắc cho dashboard
enum ENUM_DASHBOARD_THEME {
    THEME_DARK,   // Nền tối, chữ sáng
    THEME_LIGHT   // Nền sáng, chữ tối
};






//===== CHẾ ĐỘ & XU HƯỚNG THỊ TRƯỜNG (HỢP NHẤT) =====
/// @brief Định nghĩa các chế độ và xu hướng thị trường chi tiết, hợp nhất từ ENUM_MARKET_TREND và ENUM_MARKET_REGIME
enum ENUM_MARKET_REGIME {
    REGIME_UNKNOWN = 0,           // Chế độ chưa xác định
    
    // Xu hướng tăng
    REGIME_BULL_TREND_STRONG,     // Xu hướng tăng mạnh
    REGIME_BULL_TREND_NORMAL,     // Xu hướng tăng bình thường
    REGIME_BULL_PULLBACK,         // Pullback trong xu hướng tăng (cơ hội BUY)
    
    // Xu hướng giảm
    REGIME_BEAR_TREND_STRONG,     // Xu hướng giảm mạnh
    REGIME_BEAR_TREND_NORMAL,     // Xu hướng giảm bình thường
    REGIME_BEAR_PULLBACK,         // Pullback trong xu hướng giảm (cơ hội SELL)
    
    // Đi ngang (Ranging)
    REGIME_RANGING_STABLE,        // Sideway ổn định, biên độ hẹp
    REGIME_RANGING_VOLATILE,      // Sideway biến động, biên độ rộng
    
    // Biến động cao (Không rõ xu hướng)
    REGIME_VOLATILE_EXPANSION,    // Biến động mở rộng (phá vỡ tiềm năng)
    REGIME_VOLATILE_CONTRACTION,  // Biến động thu hẹp (tích lũy)
    
    // Chuyển tiếp
    REGIME_TRANSITIONING          // Chế độ chuyển tiếp giữa các trạng thái
};



//===== LOẠI DRAWDOWN =====
/// @brief Định nghĩa các loại drawdown
enum ENUM_DRAWDOWN_TYPE {
    DRAWDOWN_BALANCE_BASED,   // Drawdown dựa trên Balance
    DRAWDOWN_EQUITY_BASED     // Drawdown dựa trên Equity (trailing)
};

//===== TRẠNG THÁI SỨC KHỎE BROKER =====
/// @brief Định nghĩa các mức độ sức khỏe của broker
enum ENUM_HEALTH_STATUS {
    HEALTH_EXCELLENT = 0,     // Sức khỏe xuất sắc (90-100 điểm)
    HEALTH_GOOD = 1,          // Sức khỏe tốt (75-89 điểm)
    HEALTH_WARNING = 2,       // Cảnh báo (60-74 điểm)
    HEALTH_CRITICAL = 3       // Nguy hiểm (dưới 60 điểm)
};


/// @brief Preset cấu hình cho từng loại thị trường
enum ENUM_MARKET_PRESET {
    // === PRESET TỔNG QUÁT ===
    PRESET_AUTO,        // Tự động nhận diện và điều chỉnh
    PRESET_CONSERVATIVE, // Cấu hình bảo thủ (ít tín hiệu, chất lượng cao)
    PRESET_BALANCED,    // Cấu hình cân bằng
    PRESET_AGGRESSIVE,  // Cấu hình tích cực (nhiều tín hiệu hơn)
    
    // === PRESET THEO LOẠI TÀI SẢN ===
    PRESET_FOREX,       // Cấu hình cho Forex chính
    PRESET_EXOTICS,     // Cấu hình cho Forex ngoại lai
    PRESET_INDICES,     // Cấu hình cho chỉ số
    PRESET_METALS,      // Cấu hình cho kim loại (gold, silver)
    PRESET_CRYPTO,      // Cấu hình cho tiền điện tử
    
    // === PRESET CỤ THỂ CHO CÁC CẶP TIỀN CHÍNH ===
    // EURUSD Presets
    PRESET_EURUSD_H1_CONSERVATIVE,    // EURUSD H1 - Bảo thủ
    PRESET_EURUSD_H1_STANDARD,        // EURUSD H1 - Chuẩn
    PRESET_EURUSD_H1_AGGRESSIVE,      // EURUSD H1 - Tích cực
    PRESET_EURUSD_H4_CONSERVATIVE,    // EURUSD H4 - Bảo thủ
    PRESET_EURUSD_H4_STANDARD,        // EURUSD H4 - Chuẩn
    PRESET_EURUSD_H4_AGGRESSIVE,      // EURUSD H4 - Tích cực
    
    // GBPUSD Presets
    PRESET_GBPUSD_H1_CONSERVATIVE,    // GBPUSD H1 - Bảo thủ
    PRESET_GBPUSD_H1_STANDARD,        // GBPUSD H1 - Chuẩn
    PRESET_GBPUSD_H1_AGGRESSIVE,      // GBPUSD H1 - Tích cực
    PRESET_GBPUSD_H4_CONSERVATIVE,    // GBPUSD H4 - Bảo thủ
    PRESET_GBPUSD_H4_STANDARD,        // GBPUSD H4 - Chuẩn
    PRESET_GBPUSD_H4_AGGRESSIVE,      // GBPUSD H4 - Tích cực
    
    // USDJPY Presets
    PRESET_USDJPY_H1_CONSERVATIVE,    // USDJPY H1 - Bảo thủ
    PRESET_USDJPY_H1_STANDARD,        // USDJPY H1 - Chuẩn
    PRESET_USDJPY_H1_AGGRESSIVE,      // USDJPY H1 - Tích cực
    PRESET_USDJPY_H4_CONSERVATIVE,    // USDJPY H4 - Bảo thủ
    PRESET_USDJPY_H4_STANDARD,        // USDJPY H4 - Chuẩn
    PRESET_USDJPY_H4_AGGRESSIVE,      // USDJPY H4 - Tích cực
    
    // XAUUSD (Gold) Presets
    PRESET_XAUUSD_M15_CONSERVATIVE,   // XAUUSD M15 - Bảo thủ
    PRESET_XAUUSD_M15_STANDARD,       // XAUUSD M15 - Chuẩn
    PRESET_XAUUSD_M15_AGGRESSIVE,     // XAUUSD M15 - Tích cực
    PRESET_XAUUSD_H1_CONSERVATIVE,    // XAUUSD H1 - Bảo thủ
    PRESET_XAUUSD_H1_STANDARD,        // XAUUSD H1 - Chuẩn
    PRESET_XAUUSD_H1_AGGRESSIVE,      // XAUUSD H1 - Tích cực
    
    // USDCAD Presets
    PRESET_USDCAD_H1_CONSERVATIVE,    // USDCAD H1 - Bảo thủ
    PRESET_USDCAD_H1_STANDARD,        // USDCAD H1 - Chuẩn
    PRESET_USDCAD_H1_AGGRESSIVE,      // USDCAD H1 - Tích cực
    
    // AUDUSD Presets
    PRESET_AUDUSD_H1_CONSERVATIVE,    // AUDUSD H1 - Bảo thủ
    PRESET_AUDUSD_H1_STANDARD,        // AUDUSD H1 - Chuẩn
    PRESET_AUDUSD_H1_AGGRESSIVE,      // AUDUSD H1 - Tích cực
    
    // NZDUSD Presets
    PRESET_NZDUSD_H1_CONSERVATIVE,    // NZDUSD H1 - Bảo thủ
    PRESET_NZDUSD_H1_STANDARD,        // NZDUSD H1 - Chuẩn
    PRESET_NZDUSD_H1_AGGRESSIVE,      // NZDUSD H1 - Tích cực
    
    // USDCHF Presets
    PRESET_USDCHF_H1_CONSERVATIVE,    // USDCHF H1 - Bảo thủ
    PRESET_USDCHF_H1_STANDARD,        // USDCHF H1 - Chuẩn
    PRESET_USDCHF_H1_AGGRESSIVE,      // USDCHF H1 - Tích cực
    
    // === PRESET CHO CÁC CẶP CROSS ===
    PRESET_EURJPY_H1_STANDARD,        // EURJPY H1 - Chuẩn
    PRESET_GBPJPY_H1_STANDARD,        // GBPJPY H1 - Chuẩn
    PRESET_EURGBP_H1_STANDARD,        // EURGBP H1 - Chuẩn
    
    // === PRESET CHO CHỈ SỐ ===
    PRESET_US30_H1_STANDARD,          // US30 (Dow Jones) H1
    PRESET_SPX500_H1_STANDARD,        // SPX500 (S&P 500) H1
    PRESET_NAS100_H1_STANDARD,        // NAS100 (Nasdaq) H1
    PRESET_GER40_H1_STANDARD,         // GER40 (DAX) H1
    
    // === PRESET CHO KIM LOẠI KHÁC ===
    PRESET_XAGUSD_H1_STANDARD,        // XAGUSD (Silver) H1
    
    PRESET_CUSTOM       // Cấu hình tùy chỉnh
};

//===== PHIÊN GIAO DỊCH =====
/// @brief Các phiên giao dịch chính trong ngày
enum ENUM_SESSION {
    SESSION_UNKNOWN = 0,       // Phiên không xác định
    SESSION_ASIAN = 1,        // Phiên Á (Tokyo)
    SESSION_EUROPEAN = 2,     // Phiên London (Âu)
    SESSION_AMERICAN = 3,     // Phiên New York (Mỹ)
    SESSION_SYDNEY = 4,       // Phiên Sydney
    SESSION_OVERNIGHT = 5,    // Phiên qua đêm
    SESSION_EUROPEAN_AMERICAN, // Phiên giao thoa Âu-Mỹ (thanh khoản cao nhất)
    SESSION_LONDON_NY,         // Phiên giao thoa London-NY (tương tự EUROPEAN_AMERICAN)
    SESSION_CLOSING            // Phiên đóng cửa (ít thanh khoản)
};



/// @brief Bộ lọc phiên giao dịch
enum ENUM_SESSION_FILTER_MODE {
    FILTER_ALL_SESSIONS,         // Giao dịch mọi phiên
    FILTER_ASIAN_ONLY,          // Chỉ giao dịch phiên Á
    FILTER_LONDON_ONLY,         // Chỉ giao dịch phiên London
    FILTER_NEWYORK_ONLY,        // Chỉ giao dịch phiên New York
    FILTER_MAJOR_SESSIONS_ONLY, // Chỉ giao dịch phiên chính (London+NY)
    FILTER_OVERLAP_ONLY,        // Chỉ giao dịch phiên giao thoa
    FILTER_CUSTOM_SESSION       // Tùy chỉnh (sử dụng bitwise mask)
};

//===== TÍN HIỆU =====
/// @brief Loại tín hiệu
enum ENUM_SIGNAL_TYPE {
    SIGNAL_BUY,   // Tín hiệu mua
    SIGNAL_SELL,  // Tín hiệu bán
    SIGNAL_NONE   // Không có tín hiệu
};

/// @brief Hướng tín hiệu
enum ENUM_SIGNAL_DIRECTION {
    SIGNAL_DIRECTION_LONG,   // Tín hiệu xu hướng tăng (BUY)
    SIGNAL_DIRECTION_SHORT,  // Tín hiệu xu hướng giảm (SELL)
    SIGNAL_DIRECTION_BOTH,   // Cả hai chiều (BUY và SELL)
    SIGNAL_DIRECTION_NONE    // Không có chiều nào
};



//+------------------------------------------------------------------+
//| Trạng thái vị thế (Position State) (HỢP NHẤT)                     |
//+------------------------------------------------------------------+
/// @brief Trạng thái của một vị thế đang mở, đã được hợp nhất và chuẩn hóa
enum ENUM_POSITION_STATE {
    POS_STATE_NONE = 0,               // Không có trạng thái (chưa mở)
    POS_STATE_OPEN,                   // Mới mở
    POS_STATE_BREAKEVEN,              // Đã dời SL về hòa vốn
    POS_STATE_PARTIAL_CLOSED,         // Đã đóng một phần
    POS_STATE_TRAILING_ACTIVE,        // Đang trong quá trình trailing stop
    POS_STATE_RISK_REDUCED,           // Đã giảm rủi ro (ví dụ: sau khi đạt TP1)
    POS_STATE_PENDING_CLOSE,          // Đang chờ điều kiện để đóng
    POS_STATE_HEDGED                  // Vị thế đang được bảo hiểm (nếu có)
};









//+------------------------------------------------------------------+
//| Định danh (ID) cho các chiến lược giao dịch (HỢP NHẤT)          |
//+------------------------------------------------------------------+
/// @brief Định danh (ID) cho các chiến lược giao dịch, đã được hợp nhất và chuẩn hóa
enum ENUM_STRATEGY_ID {
    STRATEGY_ID_NONE = 0,             // Không có chiến lược / Không xác định
    STRATEGY_ID_PULLBACK,             // Chiến lược Pullback theo xu hướng (chính)
    STRATEGY_ID_BREAKOUT,             // Chiến lược Breakout (Phá vỡ)
    STRATEGY_ID_MEAN_REVERSION,       // Chiến lược Hồi quy về trung bình
    STRATEGY_ID_RANGE_TRADING,        // Chiến lược Giao dịch trong biên độ
    STRATEGY_ID_COUNTER_TREND,        // Chiến lược Giao dịch ngược xu hướng
    STRATEGY_ID_SCALPING,             // Chiến lược Scalping
    STRATEGY_ID_SWING,                // Chiến lược Swing Trading
    STRATEGY_ID_HARMONIC,             // Chiến lược dựa trên mẫu hình Harmonic
    STRATEGY_ID_DIVERGENCE,           // Chiến lược dựa trên phân kỳ
    STRATEGY_ID_CUSTOM                // Chiến lược tùy chỉnh
};


/// @brief Chế độ vào lệnh
enum ENUM_ENTRY_MODE {
    ENTRY_MODE_MARKET,         // Lệnh thị trường (vào ngay lập tức)
    ENTRY_MODE_LIMIT,          // Lệnh giới hạn (đợi pullback thêm)
    ENTRY_MODE_SMART,          // Thông minh (dựa trên chất lượng tín hiệu, ví dụ: chỉ vào khi có momentum)
    ENTRY_MODE_DEFAULT = ENTRY_MODE_MARKET // Chế độ mặc định là lệnh thị trường
};



//===== QUẢN LÝ RỦI RO =====
/// @brief Trạng thái rủi ro hệ thống
enum ENUM_RISK_STATE {
    RISK_NORMAL,   // Rủi ro bình thường
    RISK_CAUTION,  // Cảnh báo rủi ro (DD 5-10%)
    RISK_WARNING,  // Rủi ro báo động (DD 10-15%)
    RISK_CRITICAL, // Rủi ro nghiêm trọng (DD 15%+)
    RISK_PAUSED    // Tạm dừng giao dịch do rủi ro
};



/// @brief Tầm quan trọng của điểm swing
enum ENUM_SWING_IMPORTANCE {
    SWING_MINOR,   // Đỉnh/đáy nhỏ (ngắn hạn)
    SWING_MAJOR,   // Đỉnh/đáy lớn (trung hạn)
    SWING_CRITICAL // Đỉnh/đáy quan trọng (dài hạn)
};

//===== TRAILING STOP =====
/// @brief Các phương pháp trailing stop
enum ENUM_TRAILING_STOP_MODE {
    TRAILING_MODE_NONE,         // Không sử dụng trailing stop
    TRAILING_MODE_ATR,          // Trailing dựa trên ATR
    TRAILING_MODE_CHANDELIER,   // Trailing kiểu Chandelier Exit
    TRAILING_MODE_SWING_POINTS, // Trailing dựa trên swing points
    TRAILING_MODE_EMA,          // Sử dụng đường EMA
    TRAILING_MODE_PSAR,         // Sử dụng Parabolic SAR
    TRAILING_MODE_ADAPTIVE,     // Thích ứng theo Regime
    TRAILING_MODE_DEFAULT = TRAILING_MODE_ATR // Mặc định là ATR
};



//===== MULTI-TIMEFRAME =====
/// @brief Sự đồng thuận của đa khung thời gian
enum ENUM_MTF_ALIGNMENT {
    MTF_ALIGNMENT_BULLISH,      // Đồng thuận xu hướng tăng (H1+H4+D1)
    MTF_ALIGNMENT_BEARISH,      // Đồng thuận xu hướng giảm (H1+H4+D1)
    MTF_ALIGNMENT_NEUTRAL,      // Trung tính (không rõ xu hướng)
    MTF_ALIGNMENT_CONFLICTING   // Mâu thuẫn giữa các khung thời gian
};

//===== BỘ LỌC TIN TỨC =====

/// @brief Chế độ phản ứng với tin tức
enum ENUM_NEWS_REACTION_MODE {
    NEWS_FILTER_OFF,                    // Tắt bộ lọc tin tức
    NEWS_FILTER_PAUSE_EA,               // Tạm dừng mở lệnh mới trong thời gian tin tức
    NEWS_FILTER_CLOSE_TRADES,      // Đóng tất cả các lệnh đang mở trước khi tin ra
    NEWS_FILTER_REDUCE_RISK        // Giảm rủi ro cho các lệnh mới (nếu có)
};



/// @brief Mức độ quan trọng của tin tức
enum ENUM_NEWS_IMPORTANCE_LEVEL {
    NEWS_FILTER_LOW,           // Tin tức tác động thấp
    NEWS_FILTER_MEDIUM,        // Tin tức tác động trung bình
    NEWS_FILTER_HIGH,          // Tin tức tác động cao
    NEWS_FILTER_LEVEL_CRITICAL // Tin tức tác động nghiêm trọng
};



//===== TIMEFRAMES =====
/// @brief Khung thời gian giao dịch (sử dụng enum chuẩn MQL5)
enum ENUM_TIMEFRAMES {
    PERIOD_M1  = 1,      // 1 phút
    PERIOD_M5  = 5,      // 5 phút
    PERIOD_M15 = 15,     // 15 phút
    PERIOD_M30 = 30,     // 30 phút
    PERIOD_H1  = 60,     // 1 giờ
    PERIOD_H4  = 240,    // 4 giờ
    PERIOD_D1  = 1440,   // 1 ngày
    PERIOD_W1  = 10080,  // 1 tuần
    PERIOD_MN1 = 43200,  // 1 tháng
    PERIOD_CURRENT = 0   // Khung thời gian hiện tại
};





//===== THÔNG BÁO VÀ CẢNH BÁO =====
// Cấp độ cảnh báo
enum ENUM_ALERT_LEVEL {
    ALERT_LEVEL_NORMAL,    
    ALERT_LEVEL_INFO,      
    ALERT_LEVEL_WARNING,   
    ALERT_LEVEL_CRITICAL   
};

//===== HIỆU SUẤT EA =====
/// @brief Trạng thái hiệu suất
//===== HEALTH PORTFOLIO =====
/// @brief Trạng thái sức khỏe danh mục đầu tư
enum ENUM_PORTFOLIO_HEALTH {
    PORTFOLIO_HEALTH_EXCELLENT,  // Danh mục xuất sắc
    PORTFOLIO_HEALTH_GOOD,       // Danh mục tốt
    PORTFOLIO_HEALTH_AVERAGE,    // Danh mục trung bình
    PORTFOLIO_HEALTH_WARNING,    // Danh mục cần cảnh báo
    PORTFOLIO_HEALTH_DANGER,     // Danh mục nguy hiểm
    PORTFOLIO_HEALTH_UNKNOWN     // Trạng thái không xác định
};

// ENUM_TRADING_SESSION đã được hợp nhất vào ENUM_SESSION 
// Chúng ta chỉ sử dụng ENUM_SESSION để tránh xung đột

//===== PERFORMANCE STATUS =====
/// @brief Trạng thái hiệu suất
enum ENUM_PERFORMANCE_STATUS {
    PERFORMANCE_EXCELLENT, // Hiệu suất xuất sắc (profit factor > 2.0)
    PERFORMANCE_GOOD,      // Hiệu suất tốt (profit factor 1.5-2.0)
    PERFORMANCE_AVERAGE,   // Hiệu suất trung bình (profit factor 1.2-1.5)
    PERFORMANCE_POOR,      // Hiệu suất kém (profit factor 1.0-1.2)
    PERFORMANCE_CRITICAL   // Hiệu suất nghiêm trọng (profit factor < 1.0)
};

//===== MẪU HÌNH PATTERN DETECTOR =====
/// @brief Các loại mẫu hình được phát hiện bởi PatternDetector
enum ENUM_PATTERN_TYPE {
    PATTERN_NONE = 0,              // Không có mẫu hình
    SCENARIO_FIBONACCI_PULLBACK,   // Pullback Fibonacci
    SCENARIO_BULLISH_PULLBACK,     // Pullback tăng
    SCENARIO_BEARISH_PULLBACK,     // Pullback giảm
    SCENARIO_STRONG_PULLBACK,      // Pullback mạnh
    SCENARIO_MOMENTUM_SHIFT,       // Chuyển động lượng
    SCENARIO_HARMONIC_PATTERN,     // Mẫu hình harmonic (Gartley, Butterfly, Crab)
    PATTERN_MEAN_REVERSION,        // Mẫu hình Mean Reversion cho thị trường đi ngang
    SCENARIO_CUSTOM                // Mẫu hình tùy chỉnh
};

//===== ASSET PROFILER =====
/// @brief Loại tài sản (dùng cho AssetProfiler)
enum ENUM_ASSET_TYPE {
    ASSET_TYPE_FOREX_MAJOR,    // Cặp tiền chính (EURUSD, GBPUSD...)
    ASSET_TYPE_FOREX_MINOR,    // Cặp tiền phụ (EURGBP, AUDJPY...)
    ASSET_TYPE_FOREX_EXOTIC,   // Cặp tiền ngoại lai (USDTRY, USDZAR...)
    ASSET_TYPE_INDEX,          // Chỉ số (DAX, S&P500...)
    ASSET_TYPE_COMMODITY,      // Hàng hóa (Oil, Natural Gas...)
    ASSET_TYPE_METAL,          // Kim loại (Gold, Silver...)
    ASSET_TYPE_CRYPTO,         // Tiền điện tử (BTCUSD, ETHUSD...)
    ASSET_TYPE_CUSTOM          // Tùy chỉnh hoặc không xác định
};

/// @brief Độ thanh khoản của tài sản

//===== ASSET PROFILER LOG LEVELS =====
/// @brief Định nghĩa log levels để kiểm soát lượng log cho Asset Profiler
enum ENUM_PROFILE_LOG_LEVEL {
    PROFILE_LOG_NONE = 0,      // Không log
    PROFILE_LOG_ERRORS,        // Chỉ log lỗi
    PROFILE_LOG_IMPORTANT,     // Log thông tin quan trọng
    PROFILE_LOG_ALL            // Log tất cả
};

//===== ASSET PROFILER ADJUSTMENT MODE =====
/// @brief Enum cho loại điều chỉnh trong Asset Profiler
enum ENUM_ADJUSTMENT_MODE {
    ADJ_MODE_BASIC = 0,        // Điều chỉnh cơ bản
    ADJ_MODE_ADVANCED,         // Điều chỉnh nâng cao (sigmoid)
    ADJ_MODE_TIME_WEIGHTED     // Điều chỉnh có trọng số thời gian
};

//===== WEEKDAYS ENUM =====
/// @brief Enum cho các ngày trong tuần
enum ENUM_WEEKDAYS {
    WEEKDAY_SUNDAY = 0,   // Chủ nhật
    WEEKDAY_MONDAY,      // Thứ hai
    WEEKDAY_TUESDAY,     // Thứ ba
    WEEKDAY_WEDNESDAY,   // Thứ tư
    WEEKDAY_THURSDAY,    // Thứ năm
    WEEKDAY_FRIDAY,      // Thứ sáu
    WEEKDAY_SATURDAY     // Thứ bảy
};

//===== TREND DIRECTION =====
/// @brief Hướng xu hướng giao dịch
enum ENUM_TREND_DIRECTION {
    TREND_BOTH,        // Cả hai chiều (buy và sell)
    TREND_BUY_ONLY,    // Chỉ giao dịch mua (buy only)
    TREND_SELL_ONLY,   // Chỉ giao dịch bán (sell only)
    TREND_BULLISH,     // Xu hướng tăng
    TREND_BEARISH      // Xu hướng giảm
};

/// @brief Độ thanh khoản của tài sản
enum ENUM_ASSET_LIQUIDITY {
    LIQUIDITY_VERY_LOW,  // Thanh khoản rất thấp (exotic pairs)
    LIQUIDITY_LOW,       // Thanh khoản thấp
    LIQUIDITY_MEDIUM,    // Thanh khoản trung bình
    LIQUIDITY_HIGH,      // Thanh khoản cao (forex majors)
    LIQUIDITY_VERY_HIGH  // Thanh khoản rất cao (EURUSD, S&P500)
};

//===== LOẠI GIÁ TRỊ TỐI ƯU =====
/// @brief Loại giá trị tối ưu (sử dụng cho Walk-Forward)
enum ENUM_OPTIMIZATION_TYPE {
    OPT_BALANCE,           // Số dư cuối kỳ
    OPT_PROFIT_FACTOR,     // Profit Factor
    OPT_EXPECTED_PAYOFF,   // Expected Payoff
    OPT_DRAWDOWN_PERCENT,  // Drawdown tính theo %
    OPT_RECOVERY_FACTOR,   // Recovery Factor
    OPT_SHARPE_RATIO,      // Sharpe Ratio
    OPT_CUSTOM             // Tùy chỉnh (dùng với hàm tối ưu riêng)
};

//===== THIẾT LẬP HỆ THỐNG =====
// ENUM_DASHBOARD_THEME đã được định nghĩa ở trên.

// Compatibility aliases
#define DASHBOARD_DARK THEME_DARK
#define DASHBOARD_LIGHT THEME_LIGHT
#define DASHBOARD_BLUE THEME_BLUE
#define DASHBOARD_GREEN THEME_GREEN
#define DASHBOARD_CUSTOM THEME_CUSTOM

/// @brief Chế độ hiển thị dashboard
enum ENUM_DASHBOARD_MODE {
    DASHBOARD_FULL,       // Hiển thị đầy đủ thông tin
    DASHBOARD_MINIMAL,    // Hiển thị tối thiểu 
    DASHBOARD_PERFORMANCE,// Tập trung vào hiệu suất
    DASHBOARD_TECHNICAL,  // Tập trung vào phân tích kỹ thuật
    DASHBOARD_RISK,       // Tập trung vào quản lý rủi ro
    DASHBOARD_CUSTOM      // Tùy chỉnh
};

//===== THANH KHOẢN THỊ TRƯỜNG =====
/// @brief Trạng thái thanh khoản (từ AssetProfiler)
enum ENUM_LIQUIDITY_STATE {
    LIQUIDITY_NORMAL,      // Thanh khoản bình thường
    LIQUIDITY_DECREASING,  // Thanh khoản đang giảm
    LIQUIDITY_LOW_WARNING, // Cảnh báo thanh khoản thấp
    LIQUIDITY_EXTREME_LOW  // Thanh khoản cực thấp, cẩn thận
};
// Phân loại tài sản
enum ENUM_ASSET_CLASS {
    ASSET_CLASS_FOREX,    // Forex
    ASSET_CLASS_METALS,   // Kim loại
    ASSET_CLASS_INDICES,  // Chỉ số
    ASSET_CLASS_CRYPTO,   // Tiền điện tử
    ASSET_CLASS_OTHER     // Khác
};

// Nhóm cặp tiền
enum ENUM_SYMBOL_GROUP {
   GROUP_MAJOR,         // Cặp chính
   GROUP_MINOR,         // Cặp phụ
   GROUP_EXOTIC,        // Cặp ngoại lai
   GROUP_GOLD,          // Vàng
   GROUP_SILVER,        // Bạc
   GROUP_METALS_OTHER,  // Kim loại khác
   GROUP_US_INDICES,    // Chỉ số Mỹ
   GROUP_EU_INDICES,    // Chỉ số châu Âu
   GROUP_ASIAN_INDICES, // Chỉ số châu Á
   GROUP_INDICES_OTHER, // Chỉ số khác
   GROUP_CRYPTO,        // Tiền điện tử
   GROUP_ENERGY,        // Năng lượng
   GROUP_UNDEFINED      // Chưa xác định
};

// Mức độ biến động
enum ENUM_ASSET_VOLATILITY {
   VOLATILITY_LOW,      // Thấp
   VOLATILITY_MEDIUM,   // Trung bình
   VOLATILITY_HIGH,     // Cao
   VOLATILITY_EXTREME   // Cực cao
};


// Enum cho chế độ Take Profit (Ưu tiên #2)
enum ENUM_TP_MODE {
    TP_MODE_RR,          // Chốt lời theo tỷ lệ R:R cố định
    TP_MODE_RR_FIXED,    // Chốt lời theo tỷ lệ R:R cố định (alias)
    TP_MODE_STRUCTURE,   // Chốt lời theo cấu trúc (đỉnh/đáy cũ)
    TP_MODE_VOLATILITY,  // Chốt lời theo biến động (ADX)
    TP_DEFAULT           // Chế độ mặc định
};

// Compatibility aliases
#define TP_MODE_DEFAULT TP_DEFAULT

//===== CHIẾN LƯỢC GIAO DỊCH =====
/// @brief Các chiến lược giao dịch được hỗ trợ
enum ENUM_TRADING_STRATEGY {
    STRATEGY_UNDEFINED = -1,      // Chưa xác định hoặc không áp dụng
    STRATEGY_PULLBACK_TREND,      // Pullback theo xu hướng (chiến lược cốt lõi)
    STRATEGY_SHALLOW_PULLBACK,    // Pullback nông cho chỉ số
    STRATEGY_MOMENTUM_BREAKOUT,   // Breakout theo momentum cho crypto
    STRATEGY_MEAN_REVERSION,      // Giao dịch đảo chiều theo mean reversion
    STRATEGY_RANGE_TRADING,       // Giao dịch trong biên độ sideway
    STRATEGY_CUSTOM,              // Chiến lược tùy chỉnh
    // --- Helper for array sizing ---
    ENUM_TRADING_STRATEGY_COUNT   // Total number of defined strategies (excluding UNDEFINED)
};

//===== CHẾ ĐỘ ĐIỀU CHỈNH THAM SỐ =====
/// @brief Các chế độ điều chỉnh tham số giao dịch
enum ENUM_PARAMETER_ADJUSTMENT {
    PARAM_STANDARD,        // Tham số tiêu chuẩn (không điều chỉnh)
    PARAM_VOLATILITY,      // Điều chỉnh theo biến động
    PARAM_SESSION,         // Điều chỉnh theo phiên giao dịch
    PARAM_NEWS_IMPACT,     // Điều chỉnh theo tác động tin tức
    PARAM_MARKET_REGIME,   // Điều chỉnh theo trạng thái thị trường
    PARAM_CUSTOM           // Điều chỉnh tùy chỉnh
};

//===== CHẾ ĐỘ THÍCH NGHI (ADAPTIVE MODE) =====
/// @brief Xác định cách EA sử dụng các tham số từ Inputs và AssetProfiler
enum ENUM_ADAPTIVE_MODE {
    ADAPTIVE_MODE_OFF = 0,    // Tắt chế độ thích nghi
    MODE_MANUAL,              // EA 100% tuân theo tham số trong Inputs
    MODE_LOG_ONLY,            // EA chạy theo Inputs, AssetProfiler ghi log đề xuất
    MODE_HYBRID               // EA kết hợp tham số Inputs và đề xuất từ AssetProfiler
};

//===== BỘ LỌC PHIÊN GIAO DỊCH =====
/// @brief Loại phiên giao dịch để lọc
enum ENUM_SESSION_FILTER {
    SESSION_ALL,           // Tất cả phiên
    SESSION_ASIAN,         // Phiên Á
    SESSION_LONDON,        // Phiên London
    SESSION_NEWYORK,       // Phiên New York
    SESSION_OVERLAP        // Phiên giao thoa
};

//===== CHẾ ĐỘ QUẢN LÝ RỦI RO =====
/// @brief Chế độ quản lý rủi ro
enum ENUM_RISK_MODE {
    RISK_FIXED_LOT,        // Lot size cố định
    RISK_PERCENTAGE,       // Theo phần trăm tài khoản
    RISK_VOLATILITY,       // Theo độ biến động
    RISK_ADAPTIVE          // Thích nghi theo điều kiện thị trường
};

//===== MỨC ĐỘ TÁC ĐỘNG TIN TỨC =====
/// @brief Mức độ tác động của tin tức
enum ENUM_NEWS_IMPACT {
    NEWS_LOW,              // Tác động thấp
    NEWS_MEDIUM,           // Tác động trung bình
    NEWS_HIGH,             // Tác động cao
    NEWS_ALL               // Tất cả tin tức
};

//===== CHỦ ĐỀ DASHBOARD =====
// ENUM_DASHBOARD_THEME đã được khai báo ở dòng 573

} // end namespace ApexPullback
#endif // ENUMS_MQH_