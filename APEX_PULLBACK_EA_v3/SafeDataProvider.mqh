//+------------------------------------------------------------------+
//|                SafeDataProvider Module v14.0                      |
//|                (for ApexPullback EA v14.0)                        |
//+------------------------------------------------------------------+

#ifndef SAFEDATAPROVIDER_MQH
#define SAFEDATAPROVIDER_MQH

// Include các module cần thiết
#include "CommonStructs.mqh"  // For EAContext, Enums, etc.

// MQL5 Strict mode
#property strict

// Sử dụng namespace ApexPullback để tránh xung đột
namespace ApexPullback {

// Forward declaration for CLogger is not strictly needed if Logger.mqh is included,
// but kept here as it was explicitly mentioned in comments. Same for CMarketProfile.
class CLogger; 
class CMarketProfile;

//+------------------------------------------------------------------+
//| Class CSafeDataProvider - Cung cấp dữ liệu an toàn               |
//+------------------------------------------------------------------+
class CSafeDataProvider {
private:
    string   m_Symbol;               // Biểu tượng giao dịch
    ENUM_TIMEFRAMES m_Timeframe;     // Khung thời gian

    // Cache cho dữ liệu quan trọng
    datetime m_LastCacheTime;        // Thời điểm cache gần nhất
    int      m_CacheTimeSeconds;     // Thời gian cache tính bằng giây
    
    // Session tracking
    ENUM_SESSION m_CurrentSession;   // Phiên giao dịch hiện tại
    datetime     m_LastSessionCheck; // Lần kiểm tra phiên gần nhất
    
    // Context
    EAContext* m_context;             // Con trỏ đến context của EA
    
    // Private methods
    void UpdateSessionType();        // Cập nhật loại phiên giao dịch
    
public:
    // Constructor & Destructor
    CSafeDataProvider();
    ~CSafeDataProvider();
    
    // Initialization
    bool Initialize(EAContext* context);
    
    // Basic data getters
    double GetBid() const;
    double GetAsk() const;
    double GetSpread() const;
    double GetAverageSpread(int lookback = 20) const;
    double GetPoint() const;
    double GetPipSize() const;
    double GetTickValue() const;
    double GetTickSize() const;
    
    // Session management
    ENUM_SESSION GetCurrentSession() const;
    bool IsSessionChange() const;
    
    // Time management
    bool IsNewBar(); // Removed const as it modifies a static variable
    datetime GetBarTime(int shift = 0) const;
    bool IsFridayEvening() const;
    bool IsMondayMorning() const;
    
    // Data validation
    bool IsValidData() const;
    bool HasSufficientHistory(int requiredBars) const;
    
    // Additional methods for missing functions
    datetime GetCurrentBarTime(ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT) const;
    double GetSafeATR(ApexPullback::CMarketProfile &profile, ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT) const;
    double GetSafeVolatilityRatio() const;
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSafeDataProvider::CSafeDataProvider() {
    m_Symbol = "";
    m_Timeframe = PERIOD_CURRENT;
    m_LastCacheTime = 0;
    m_CacheTimeSeconds = 10;
    m_CurrentSession = SESSION_UNKNOWN;
    m_LastSessionCheck = 0;
    // m_Logger đã được tự động khởi tạo bởi constructor mặc định
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSafeDataProvider::~CSafeDataProvider() {
    // Clean up if needed
}

//+------------------------------------------------------------------+
//| Initialize with required parameters                              |
//+------------------------------------------------------------------+
bool CSafeDataProvider::Initialize(EAContext* context) {
    m_context = context;
    if (!m_context) return false;

    m_Symbol = m_context->Symbol;
    m_Timeframe = m_context->Timeframe;
    
    if (m_context->Logger) {
        m_context->Logger->LogInfo("Khởi tạo SafeDataProvider cho " + m_Symbol + " trên khung " + EnumToString(m_Timeframe));
    }
    
    // Kiểm tra symbol hợp lệ
    if (!SymbolSelect(m_Symbol, true)) {
        if (m_context->Logger) {
            m_context->Logger->LogError("Không thể chọn symbol " + m_Symbol + " trong Market Watch");
        }

        return false;
    }
    
    // Cập nhật phiên hiện tại
    UpdateSessionType();
    
    return true;
}

//+------------------------------------------------------------------+
//| Get current market session                                       |
//+------------------------------------------------------------------+
ENUM_SESSION CSafeDataProvider::GetCurrentSession() const {
    // Kiểm tra cache
    if (TimeCurrent() - m_LastSessionCheck > 300) { // Cập nhật 5 phút một lần
        UpdateSessionType();
    }
    
    return m_CurrentSession;
}

//+------------------------------------------------------------------+
//| Update current session type                                      |
//+------------------------------------------------------------------+
void CSafeDataProvider::UpdateSessionType() {
    datetime currentTime = TimeCurrent();
    MqlDateTime dt;
    TimeToStruct(currentTime, dt);
    
    // Chỉ xét các ngày trong tuần (1-5: Monday to Friday)
    if (dt.day_of_week >= 1 && dt.day_of_week <= 5) {
        int hour = dt.hour;
        
        // Điều chỉnh theo GMT+2 (Giờ sàn)
        int serverHour = hour; // Giả định MT5 đã điều chỉnh giờ server
        
        // Xác định phiên giao dịch dựa trên giờ
        if (serverHour >= 0 && serverHour < 7) {
            m_CurrentSession = SESSION_ASIAN;
        }
        else if (serverHour >= 7 && serverHour < 10) {
            m_CurrentSession = SESSION_EUROPEAN;
        }
        else if (serverHour >= 10 && serverHour < 17) {
            m_CurrentSession = SESSION_EUROPEAN_AMERICAN;
        }
        else if (serverHour >= 17 && serverHour < 21) {
            m_CurrentSession = SESSION_AMERICAN;
        }
        else if (serverHour >= 21 && serverHour < 24) {
            m_CurrentSession = SESSION_CLOSING;
        }
    } else {
        // Weekend
        m_CurrentSession = SESSION_UNKNOWN;
    }
    
    m_LastSessionCheck = currentTime;
}

//+------------------------------------------------------------------+
//| Check if session has changed                                     |
//+------------------------------------------------------------------+
bool CSafeDataProvider::IsSessionChange() const {
    ENUM_SESSION previousSession = m_CurrentSession;
    ENUM_SESSION currentSession = GetCurrentSession();
    
    return (previousSession != currentSession);
}

//+------------------------------------------------------------------+
//| Get current bid price                                            |
//+------------------------------------------------------------------+
double CSafeDataProvider::GetBid() const {
    return SymbolInfoDouble(m_Symbol, SYMBOL_BID);
}

//+------------------------------------------------------------------+
//| Get current ask price                                            |
//+------------------------------------------------------------------+
double CSafeDataProvider::GetAsk() const {
    return SymbolInfoDouble(m_Symbol, SYMBOL_ASK);
}

//+------------------------------------------------------------------+
//| Get current spread in points                                     |
//+------------------------------------------------------------------+
double CSafeDataProvider::GetSpread() const {
    return (double)SymbolInfoInteger(m_Symbol, SYMBOL_SPREAD);
}

//+------------------------------------------------------------------+
//| Get average spread over lookback period                          |
//+------------------------------------------------------------------+
double CSafeDataProvider::GetAverageSpread(int lookback = 20) const {
    // Implementation would require tracking spread over time
    // Simplified version returns current spread
    return GetSpread();
}

//+------------------------------------------------------------------+
//| Get point value                                                  |
//+------------------------------------------------------------------+
double CSafeDataProvider::GetPoint() {
    return SymbolInfoDouble(m_Symbol, SYMBOL_POINT);
}

//+------------------------------------------------------------------+
//| Get pip size (usually point * 10)                                |
//+------------------------------------------------------------------+
double CSafeDataProvider::GetPipSize() {
    return SymbolInfoDouble(m_Symbol, SYMBOL_POINT) * 10;
}

//+------------------------------------------------------------------+
//| Get tick value                                                   |
//+------------------------------------------------------------------+
double CSafeDataProvider::GetTickValue() {
    return SymbolInfoDouble(m_Symbol, SYMBOL_TRADE_TICK_VALUE);
}

//+------------------------------------------------------------------+
//| Get tick size                                                    |
//+------------------------------------------------------------------+
double CSafeDataProvider::GetTickSize() {
    return SymbolInfoDouble(m_Symbol, SYMBOL_TRADE_TICK_SIZE);
}

//+------------------------------------------------------------------+
//| Check if a new bar has formed                                    |
//+------------------------------------------------------------------+
bool CSafeDataProvider::IsNewBar() {
    static datetime last_time = 0;
    datetime current_time = iTime(m_Symbol, m_Timeframe, 0);
    
    if (last_time == 0) {
        last_time = current_time;
        return false;
    }
    
    if (current_time != last_time) {
        last_time = current_time;
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Get bar time for specified shift                                 |
//+------------------------------------------------------------------+
datetime CSafeDataProvider::GetBarTime(int shift = 0) const {
    return iTime(m_Symbol, m_Timeframe, shift);
}

//+------------------------------------------------------------------+
//| Check if current time is Friday evening                          |
//+------------------------------------------------------------------+
bool CSafeDataProvider::IsFridayEvening() const {
    datetime time = TimeCurrent();
    MqlDateTime dt;
    TimeToStruct(time, dt);
    
    return (dt.day_of_week == 5 && dt.hour >= 20); // Friday after 20:00
}

//+------------------------------------------------------------------+
//| Check if current time is Monday morning                          |
//+------------------------------------------------------------------+
bool CSafeDataProvider::IsMondayMorning() const {
    datetime time = TimeCurrent();
    MqlDateTime dt;
    TimeToStruct(time, dt);
    
    return (dt.day_of_week == 1 && dt.hour <= 8); // Monday before 8:00
}

//+------------------------------------------------------------------+
//| Check if data is valid (no errors in price data)                 |
//+------------------------------------------------------------------+
bool CSafeDataProvider::IsValidData() const {
    // Check for zero prices or other invalid data
    double bid = GetBid();
    double ask = GetAsk();
    
    return (bid > 0 && ask > 0 && ask >= bid);
}

//+------------------------------------------------------------------+
//| Check if there's sufficient price history                        |
//+------------------------------------------------------------------+
bool CSafeDataProvider::HasSufficientHistory(int requiredBars) const {
    int available = Bars(m_Symbol, m_Timeframe);
    return (available >= requiredBars);
}

//+------------------------------------------------------------------+
//| Lấy thời gian nến hiện tại cho timeframe được chỉ định        |
//+------------------------------------------------------------------+
datetime CSafeDataProvider::GetCurrentBarTime(ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT) const {
    return iTime(m_Symbol, timeframe, 0);
}

//+------------------------------------------------------------------+
//| Lấy giá trị ATR một cách an toàn                              |
//+------------------------------------------------------------------+
double CSafeDataProvider::GetSafeATR(ApexPullback::CMarketProfile &profile, ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT) const {
    // Tính toán giá trị ATR từ thị trường trực tiếp
    double atr = 0.0;
    int handle = iATR(m_Symbol, timeframe, 14);
    
    if(handle != INVALID_HANDLE) {
        double buffer[];
        if(CopyBuffer(handle, 0, 0, 1, buffer) > 0) {
            atr = buffer[0];
        }
        IndicatorRelease(handle);
    }
    
    // Phòng trường hợp không lấy được giá trị hoặc giá trị không hợp lệ
    if(atr <= 0.0) {
        // Sử dụng cách tính ATR thủ công
        double highLow = 0.0;
        for(int i = 1; i <= 14; i++) {
            double high = iHigh(m_Symbol, timeframe, i);
            double low = iLow(m_Symbol, timeframe, i);
            if(high > 0 && low > 0) {
                highLow += (high - low);
            }
        }
        atr = highLow / 14.0;
    }
    
    return atr;
}

//+------------------------------------------------------------------+
//| Lấy tỷ lệ biến động                                       |
//+------------------------------------------------------------------+
double CSafeDataProvider::GetSafeVolatilityRatio() const {
    // Mặc định trả về tỷ lệ volatility trung bình = 1.0
    return 1.0;
}

} // namespace ApexPullback

#endif // SAFEDATAPROVIDER_MQH__
