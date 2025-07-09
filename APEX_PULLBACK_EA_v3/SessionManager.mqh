//+------------------------------------------------------------------+
//|                                                SessionManager.mqh |
//|                                             APEX Pullback EA v14.0|
//|                                       Copyright 2023-2024, APEX   |
//+------------------------------------------------------------------+

#ifndef SESSIONMANAGER_MQH_
#define SESSIONMANAGER_MQH_

#include "CommonStructs.mqh" // Include for EAContext and enums

namespace ApexPullback {

// Định nghĩa các phiên giao dịch cho Filter đã được đưa vào Enums.mqh
// Sử dụng các giá trị: FILTER_ALL_SESSIONS, FILTER_ASIAN_ONLY, v.v.

//+------------------------------------------------------------------+
//| Class CSessionManager - Quản lý các phiên giao dịch              |
//+------------------------------------------------------------------+
class CSessionManager {
private:
    EAContext*        m_context;           // Pointer đến EAContext

    // Cờ bật/tắt lọc phiên
    bool              m_FilterBySession;
    
    // Điều chỉnh múi giờ GMT
    int               m_GmtOffset;
    
    // Lựa chọn phiên giao dịch
    ENUM_SESSION_FILTER m_SessionFilter;
    
    // Cờ bật/tắt giao dịch tại các thời điểm mở cửa
    bool              m_TradeLondonOpen;
    bool              m_TradeNewYorkOpen;
    
    // Thời gian bắt đầu và kết thúc của các phiên (giờ GMT chuẩn)
    int               m_AsianStart;        // Giờ bắt đầu phiên Á (thường là 0)
    int               m_AsianEnd;          // Giờ kết thúc phiên Á (thường là 8)
    int               m_LondonStart;       // Giờ bắt đầu phiên London (thường là 8)
    int               m_LondonEnd;         // Giờ kết thúc phiên London (thường là 16)
    int               m_NewYorkStart;      // Giờ bắt đầu phiên New York (thường là 13)
    int               m_NewYorkEnd;        // Giờ kết thúc phiên New York (thường là 21)
    int               m_OverlapStart;      // Giờ bắt đầu phiên giao nhau (thường là 13)
    int               m_OverlapEnd;        // Giờ kết thúc phiên giao nhau (thường là 16)
    
    // Biến theo dõi phiên giao dịch hiện tại
    ENUM_SESSION      m_CurrentSession;
    
    // Biến theo dõi thời gian mở cửa London/New York
    datetime          m_LondonOpenTime;
    datetime          m_NewYorkOpenTime;
    
    // Buffer để xác định London Open và New York Open (phút)
    int               m_OpenWindowMinutes;
    
    // Bộ nhớ đệm ngày hiện tại để tối ưu tính toán
    int               m_CurrentDay;
    int               m_CurrentMonth;
    int               m_CurrentYear;
    
    // Theo dõi nếu hôm nay là ngày cuối tuần
    bool              m_IsWeekend;
    
    // Theo dõi DST (Daylight Saving Time - Giờ mùa hè)
    bool              m_IsDST;
    bool              m_AutoAdjustDST;
    
    // Flag logging chi tiết
    bool              m_VerboseLogging;

public:
    // Constructor
    CSessionManager(EAContext* context);
    
    // Destructor
    ~CSessionManager();
    
    // Phương thức khởi tạo
    bool Initialize();
   
   // Cấu hình thời gian phiên
   void ConfigureSessionTimes(int asianStart, int asianEnd, int londonStart, int londonEnd, 
                            int nyStart, int nyEnd);
   
   // Cấu hình DST
   void ConfigureDST(bool autoAdjustDST);
   
   // Cập nhật phiên hiện tại
   void Update();
   
   // Kiểm tra xem phiên có hoạt động không
   bool IsSessionActive();
   
   // Lấy phiên hiện tại
   ENUM_SESSION GetCurrentSession() const { return m_CurrentSession; }
   
   // Kiểm tra xem hiện tại có phải là thời điểm mở cửa London không
   bool IsLondonOpening();
   
   // Kiểm tra xem hiện tại có phải là thời điểm mở cửa New York không
   bool IsNewYorkOpening();
   
   // Kiểm tra hôm nay có phải là cuối tuần không
   bool IsWeekend() const { return m_IsWeekend; }
   
   // Lấy thời gian GMT đã điều chỉnh
   datetime GetAdjustedGMT();
   
   // Lấy tên phiên hiện tại dưới dạng chuỗi
   string GetCurrentSessionName();
   
   // Kiểm tra phiên giao dịch cụ thể có hoạt động không
   bool IsSessionActiveNow(ENUM_SESSION_FILTER session);
   
   // Kiểm tra thị trường có mở cửa không
   bool IsMarketOpen();
   
   // Lấy giờ GMT điều chỉnh
   int GetGmtOffset() const { return m_GmtOffset; }
   
   // --- Public Getter Functions ---
   bool IsFilterEnabled() const { return m_FilterBySession; }
   ENUM_SESSION_FILTER GetSessionFilter() const { return m_SessionFilter; }
   bool IsTradingLondonOpen() const { return m_TradeLondonOpen; }
   bool IsTradingNewYorkOpen() const { return m_TradeNewYorkOpen; }
   
   // Kiểm tra DST
   bool IsDST();
   
   // Tính thời gian phiên tiếp theo
   datetime GetNextSessionStart(ENUM_SESSION session);
   
   // Tính thời gian còn lại đến phiên tiếp theo (giây)
   int GetSecondsToNextSession(ENUM_SESSION session);

private:
   // Lấy ngày hiện tại
   void UpdateCurrentDate();
   
   // Xác định DST tự động
   bool DetectDST();
   
   // Điều chỉnh thời gian phiên do DST
   void AdjustSessionTimesForDST();
   
   // Kiểm tra xem thời gian hiện tại có thuộc phiên không
   bool IsInSession(int hourStart, int hourEnd);
   
   // Kiểm tra xem time có phải là mở cửa giao dịch không
   bool IsMarketOpeningTime(datetime time, int hour, int window);
   
   // Ghi log
   void LogMessage(string message, bool important = false);
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CSessionManager::CSessionManager(EAContext* context) : m_context(context) {
   // Khởi tạo giá trị mặc định
   m_FilterBySession = false;
   m_GmtOffset = 0;
   m_SessionFilter = FILTER_ALL_SESSIONS;
   m_TradeLondonOpen = true;
   m_TradeNewYorkOpen = true;
   
   // Giờ GMT mặc định cho các phiên
   m_AsianStart = 0;
   m_AsianEnd = 8;
   m_LondonStart = 8;
   m_LondonEnd = 16;
   m_NewYorkStart = 13;
   m_NewYorkEnd = 21;
   m_OverlapStart = 13;
   m_OverlapEnd = 16;
   
   // Phiên hiện tại mặc định
   m_CurrentSession = SESSION_CLOSING;
   
   // Thời gian buffer để xác định mở cửa (trong phút)
   m_OpenWindowMinutes = 30;
   
   // Khởi tạo thời gian
   m_LondonOpenTime = 0;
   m_NewYorkOpenTime = 0;
   
   // Ngày hiện tại
   m_CurrentDay = 0;
   m_CurrentMonth = 0;
   m_CurrentYear = 0;
   
   // Cuối tuần
   m_IsWeekend = false;
   
   // DST
   m_IsDST = false;
   m_AutoAdjustDST = true;
   
   // Verbose logging
   m_VerboseLogging = false;
}

//+------------------------------------------------------------------+
//| Destructor                                                        |
//+------------------------------------------------------------------+
CSessionManager::~CSessionManager() {
   // Không cần dọn dẹp gì đặc biệt
}

//+------------------------------------------------------------------+
//| Khởi tạo SessionManager                                          |
//+------------------------------------------------------------------+
bool CSessionManager::Initialize() {
    // Lấy các cài đặt từ context
    m_FilterBySession = m_context->FilterBySession;
    m_SessionFilter = m_context->SessionFilter;
    m_TradeLondonOpen = m_context->TradeLondonOpen;
    m_TradeNewYorkOpen = m_context->TradeNewYorkOpen;
    m_GmtOffset = m_context->GmtOffset;
    m_AutoAdjustDST = m_context->AutoAdjustDST;
    m_OpenWindowMinutes = m_context->OpenWindowMinutes;
    m_VerboseLogging = m_context->EnableSessionLogging;

   // Cập nhật thông tin ngày hiện tại
   UpdateCurrentDate();
   
   // Phát hiện DST nếu cần
   if (m_AutoAdjustDST) {
      m_IsDST = DetectDST();
      if (m_IsDST) {
         AdjustSessionTimesForDST();
      }
   }
   
   // Cập nhật phiên hiện tại
   Update();
   
   // Log thông tin khởi tạo
   LogMessage("SessionManager khởi tạo: GMT Offset = " + IntegerToString(m_GmtOffset) + 
            ", Session Filter = " + EnumToString(m_SessionFilter) + 
            ", DST = " + (m_IsDST ? "Có" : "Không"));
   
   return true;
}

//+------------------------------------------------------------------+
//| Cấu hình thời gian phiên                                         |
//+------------------------------------------------------------------+
void CSessionManager::ConfigureSessionTimes(int asianStart, int asianEnd, 
                                          int londonStart, int londonEnd, 
                                          int nyStart, int nyEnd) {
   // Lưu giờ phiên
   m_AsianStart = asianStart;
   m_AsianEnd = asianEnd;
   m_LondonStart = londonStart;
   m_LondonEnd = londonEnd;
   m_NewYorkStart = nyStart;
   m_NewYorkEnd = nyEnd;
   
   // Tính thời gian overlap
   m_OverlapStart = MathMax(m_LondonStart, m_NewYorkStart);
   m_OverlapEnd = MathMin(m_LondonEnd, m_NewYorkEnd);
   
   // Điều chỉnh nếu cần thiết cho DST
   if (m_IsDST) {
      AdjustSessionTimesForDST();
   }
   
   LogMessage("Đã cấu hình thời gian phiên: Á(" + IntegerToString(m_AsianStart) + 
            "-" + IntegerToString(m_AsianEnd) + "), London(" + 
            IntegerToString(m_LondonStart) + "-" + IntegerToString(m_LondonEnd) + 
            "), NY(" + IntegerToString(m_NewYorkStart) + "-" + 
            IntegerToString(m_NewYorkEnd) + ")");
}

//+------------------------------------------------------------------+
//| Cấu hình DST tự động                                            |
//+------------------------------------------------------------------+
void CSessionManager::ConfigureDST(bool autoAdjustDST) {
   m_AutoAdjustDST = autoAdjustDST;
   
   if (m_AutoAdjustDST) {
      m_IsDST = DetectDST();
      if (m_IsDST) {
         AdjustSessionTimesForDST();
      }
   }
}

//+------------------------------------------------------------------+
//| Cập nhật phiên hiện tại                                          |
//+------------------------------------------------------------------+
void CSessionManager::Update() {
   // Cập nhật ngày nếu cần
   UpdateCurrentDate();
   
   // Lấy giờ hiện tại (GMT đã điều chỉnh)
   datetime currentTime = GetAdjustedGMT();
   MqlDateTime dt;
   TimeToStruct(currentTime, dt);
   
   // Cập nhật trạng thái cuối tuần
   m_IsWeekend = (dt.day_of_week == 0 || dt.day_of_week == 6);
   
   // Nếu cuối tuần, phiên là WEEKEND
   if (m_IsWeekend) {
      m_CurrentSession = SESSION_OVERNIGHT;
      return;
   }
   
   int currentHour = dt.hour;
   
   // Xác định phiên hiện tại
   if (IsInSession(m_OverlapStart, m_OverlapEnd)) {
      m_CurrentSession = SESSION_EUROPEAN_AMERICAN;
   }
   else if (IsInSession(m_AsianStart, m_AsianEnd)) {
      m_CurrentSession = SESSION_ASIAN;
   }
   else if (IsInSession(m_LondonStart, m_LondonEnd)) {
      m_CurrentSession = SESSION_EUROPEAN;
   }
   else if (IsInSession(m_NewYorkStart, m_NewYorkEnd)) {
      m_CurrentSession = SESSION_AMERICAN;
   }
   else {
      m_CurrentSession = SESSION_CLOSING;
   }
   
   // Cập nhật thời gian mở cửa London/New York nếu cần
   if (dt.hour == m_LondonStart && m_LondonOpenTime == 0) {
      m_LondonOpenTime = currentTime;
   }
   else if (dt.hour > m_LondonStart + 1) {
      // Reset khi quá giờ mở cửa
      m_LondonOpenTime = 0;
   }
   
   if (dt.hour == m_NewYorkStart && m_NewYorkOpenTime == 0) {
      m_NewYorkOpenTime = currentTime;
   }
   else if (dt.hour > m_NewYorkStart + 1) {
      // Reset khi quá giờ mở cửa
      m_NewYorkOpenTime = 0;
   }
   
   // Log nếu có thay đổi phiên
   static ENUM_SESSION lastSession = SESSION_CLOSING;
   if (lastSession != m_CurrentSession) {
      LogMessage("Phiên giao dịch thay đổi: " + EnumToString(lastSession) + " -> " + 
               EnumToString(m_CurrentSession));
      lastSession = m_CurrentSession;
   }
}

//+------------------------------------------------------------------+
//| Kiểm tra phiên có hoạt động không                                |
//+------------------------------------------------------------------+
bool CSessionManager::IsSessionActive() {
   // Nếu không lọc theo phiên, luôn trả về true
   if (!m_FilterBySession) return true;
   
   // Nếu cuối tuần, trả về false
   if (m_IsWeekend) return false;
   
   // Kiểm tra phiên hiện tại có phù hợp với lọc không
   return IsSessionActiveNow(m_SessionFilter);
}

//+------------------------------------------------------------------+
//| Kiểm tra xem hiện tại có phải là thời điểm mở cửa London         |
//+------------------------------------------------------------------+
bool CSessionManager::IsLondonOpening() {
   if (!m_TradeLondonOpen) return false;
   
   datetime currentTime = GetAdjustedGMT();
   MqlDateTime dt;
   TimeToStruct(currentTime, dt);
   
   // Kiểm tra xem có trong phạm vi mở cửa London không
   if (dt.hour == m_LondonStart) {
      // Chỉ 30 phút đầu sau khi mở cửa
      if (dt.min < m_OpenWindowMinutes) {
         return true;
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Kiểm tra xem hiện tại có phải là thời điểm mở cửa New York       |
//+------------------------------------------------------------------+
bool CSessionManager::IsNewYorkOpening() {
   if (!m_TradeNewYorkOpen) return false;
   
   datetime currentTime = GetAdjustedGMT();
   MqlDateTime dt;
   TimeToStruct(currentTime, dt);
   
   // Kiểm tra xem có trong phạm vi mở cửa New York không
   if (dt.hour == m_NewYorkStart) {
      // Chỉ 30 phút đầu sau khi mở cửa
      if (dt.min < m_OpenWindowMinutes) {
         return true;
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Lấy thời gian GMT đã điều chỉnh                                  |
//+------------------------------------------------------------------+
datetime CSessionManager::GetAdjustedGMT() {
   // Lấy thời gian GMT
   datetime gmtTime = TimeCurrent(); // TimeGMT() trong MT5 tự xử lý đúng
   
   // Điều chỉnh theo GMT offset
   if (m_GmtOffset != 0) {
      gmtTime += m_GmtOffset * 3600; // Cộng/trừ giờ (3600 giây = 1 giờ)
   }
   
   return gmtTime;
}

//+------------------------------------------------------------------+
//| Lấy tên phiên hiện tại dưới dạng chuỗi                           |
//+------------------------------------------------------------------+
string CSessionManager::GetCurrentSessionName() {
   switch (m_CurrentSession) {
      case SESSION_ASIAN:         return "Phiên Á";
      case SESSION_EUROPEAN:        return "Phiên London";
      case SESSION_AMERICAN:       return "Phiên New York";
      case SESSION_EUROPEAN_AMERICAN: return "Phiên Giao nhau London-NY";
      case SESSION_CLOSING:       return "Phiên Đóng cửa";
      case SESSION_OVERNIGHT:       return "Cuối tuần";
      default:                         return "Không xác định";
   }
}

//+------------------------------------------------------------------+
//| Kiểm tra phiên cụ thể có hoạt động không                         |
//+------------------------------------------------------------------+
bool CSessionManager::IsSessionActiveNow(ENUM_SESSION_FILTER session) {
   // Nếu chọn tất cả các phiên, luôn trả về true
   if (session == FILTER_ALL_SESSIONS) return true;
   
   // Tương ứng giữa SESSION_FILTER và phiên hiện tại
   switch (session) {
      case FILTER_ASIAN_ONLY:
         return (m_CurrentSession == SESSION_ASIAN);
         
      case FILTER_LONDON_ONLY:
         return (m_CurrentSession == SESSION_EUROPEAN || 
               m_CurrentSession == SESSION_EUROPEAN_AMERICAN);
               
      case FILTER_NEWYORK_ONLY:
         return (m_CurrentSession == SESSION_AMERICAN || 
               m_CurrentSession == SESSION_EUROPEAN_AMERICAN);
               
      case FILTER_OVERLAP_ONLY:
         return (m_CurrentSession == SESSION_EUROPEAN_AMERICAN);
         
      case FILTER_CUSTOM_SESSION:
         // Custom - có thể cấu hình theo logic phức tạp hơn
         return true;
         
      default:
         return false;
   }
}

//+------------------------------------------------------------------+
//| Kiểm tra thị trường có mở cửa không                              |
//+------------------------------------------------------------------+
bool CSessionManager::IsMarketOpen() {
   // Kiểm tra cuối tuần
   if (m_IsWeekend) return false;
   
   // Kiểm tra MqlTick để xác định thị trường có mở không
   MqlTick tick;
   if (!SymbolInfoTick(_Symbol, tick)) {
      // Không lấy được thông tin tick
      return false;
   }
   
   // Nếu bid và ask đều 0, thị trường đóng
   if (tick.bid == 0 && tick.ask == 0) {
      return false;
   }
   
   // Kiểm tra giờ đóng cửa
   if (m_CurrentSession == SESSION_CLOSING) {
      return false;
   }
   return true;
}

} // end namespace ApexPullback
   
   return true;
}

//+------------------------------------------------------------------+
//| Kiểm tra DST hiện tại                                            |
//+------------------------------------------------------------------+
bool CSessionManager::IsDST() {
   return m_IsDST;
}

//+------------------------------------------------------------------+
//| Tính thời gian phiên tiếp theo                                   |
//+------------------------------------------------------------------+
datetime CSessionManager::GetNextSessionStart(ENUM_SESSION session) {
   datetime currentTime = GetAdjustedGMT();
   MqlDateTime dt;
   TimeToStruct(currentTime, dt);
   
   // Giờ bắt đầu phiên tiếp theo
   int nextHour = 0;
   
   switch (session) {
      case SESSION_ASIAN:
         nextHour = m_AsianStart;
         break;
      case SESSION_EUROPEAN:
         nextHour = m_LondonStart;
         break;
      case SESSION_AMERICAN:
         nextHour = m_NewYorkStart;
         break;
      case SESSION_EUROPEAN_AMERICAN:
         nextHour = m_OverlapStart;
         break;
      default:
         return 0; // Không hợp lệ
   }
   
   // Tính ngày bắt đầu
   int addDays = 0;
   if (dt.hour >= nextHour) {
      // Nếu đã qua giờ bắt đầu phiên hôm nay, tính cho ngày mai
      addDays = 1;
   }
   
   // Tạo thời gian phiên tiếp theo
   MqlDateTime nextDt;
   nextDt.year = dt.year;
   nextDt.mon = dt.mon;
   nextDt.day = dt.day + addDays;
   nextDt.hour = nextHour;
   nextDt.min = 0;
   nextDt.sec = 0;
   
   // Chuyển đổi thành datetime
   return StructToTime(nextDt);
}

//+------------------------------------------------------------------+
//| Tính thời gian còn lại đến phiên tiếp theo (giây)                |
//+------------------------------------------------------------------+
int CSessionManager::GetSecondsToNextSession(ENUM_SESSION session) {
   datetime nextStart = GetNextSessionStart(session);
   datetime currentTime = GetAdjustedGMT();
   
   if (nextStart == 0 || nextStart <= currentTime) {
      return 0;
   }
   
   return (int)(nextStart - currentTime);
}

//+------------------------------------------------------------------+
//| Cập nhật ngày hiện tại                                           |
//+------------------------------------------------------------------+
void CSessionManager::UpdateCurrentDate() {
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   
   // Kiểm tra xem ngày có thay đổi không
   if (dt.day != m_CurrentDay || dt.mon != m_CurrentMonth || dt.year != m_CurrentYear) {
      m_CurrentDay = dt.day;
      m_CurrentMonth = dt.mon;
      m_CurrentYear = dt.year;
      
      // Reset thời gian mở cửa
      m_LondonOpenTime = 0;
      m_NewYorkOpenTime = 0;
      
      // Cập nhật cuối tuần
      m_IsWeekend = (dt.day_of_week == 0 || dt.day_of_week == 6);
      
      // Phát hiện lại DST
      if (m_AutoAdjustDST) {
         bool wasDST = m_IsDST;
         m_IsDST = DetectDST();
         
         if (wasDST != m_IsDST) {
            LogMessage("Trạng thái DST thay đổi: " + (wasDST ? "Có" : "Không") + 
                     " -> " + (m_IsDST ? "Có" : "Không"), true);
            
            if (m_IsDST) {
               AdjustSessionTimesForDST();
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Phát hiện DST tự động                                            |
//+------------------------------------------------------------------+
bool CSessionManager::DetectDST() {
   // Phát hiện DST dựa vào thời gian hiện tại
   // Quy tắc: DST thường áp dụng ở Mỹ và châu Âu từ tháng 3 đến tháng 11
   
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   
   // Quy tắc đơn giản: DST áp dụng từ tháng 3 (tuần 2) đến tháng 11 (tuần 1)
   if (dt.mon > 3 && dt.mon < 11) {
      return true;
   }
   else if (dt.mon == 3) {
      // Tháng 3: DST bắt đầu từ Chủ nhật thứ hai
      return (dt.day >= 8 && dt.day_of_week == 0) || (dt.day > 14);
   }
   else if (dt.mon == 11) {
      // Tháng 11: DST kết thúc vào Chủ nhật đầu tiên
      return (dt.day < 8 && dt.day_of_week != 0) || (dt.day < 1);
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Điều chỉnh thời gian phiên do DST                                |
//+------------------------------------------------------------------+
void CSessionManager::AdjustSessionTimesForDST() {
   // Khi DST hoạt động, các phiên thường bắt đầu sớm hơn 1 giờ
   // Nhưng chúng ta sẽ giữ nguyên thời gian GMT và điều chỉnh offset
   
   LogMessage("Áp dụng điều chỉnh DST cho thời gian phiên", true);
}

//+------------------------------------------------------------------+
//| Kiểm tra xem thời gian hiện tại có thuộc phiên không             |
//+------------------------------------------------------------------+
bool CSessionManager::IsInSession(int hourStart, int hourEnd) {
   datetime currentTime = GetAdjustedGMT();
   MqlDateTime dt;
   TimeToStruct(currentTime, dt);
   
   int currentHour = dt.hour;
   
   // Xử lý trường hợp phiên qua đêm (ví dụ: 22:00 - 06:00)
   if (hourStart > hourEnd) {
      return (currentHour >= hourStart || currentHour < hourEnd);
   }
   
   // Phiên trong ngày (ví dụ: 08:00 - 16:00)
   return (currentHour >= hourStart && currentHour < hourEnd);
}

//+------------------------------------------------------------------+
//| Kiểm tra xem time có phải là mở cửa giao dịch không              |
//+------------------------------------------------------------------+
bool CSessionManager::IsMarketOpeningTime(datetime time, int hour, int window) {
   MqlDateTime dt;
   TimeToStruct(time, dt);
   
   // Kiểm tra xem có trong phạm vi mở cửa không
   if (dt.hour == hour && dt.min < window) {
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Ghi log                                                           |
//+------------------------------------------------------------------+
void CSessionManager::LogMessage(string message, bool important = false) {
    if (m_context.Logger != NULL) {
        if (important) {
            m_context.Logger->LogInfo(message);
        } else if (m_VerboseLogging) {
            m_context.Logger->LogDebug(message);
        }
    }
}

} // đóng namespace ApexPullback

#endif // SESSIONMANAGER_MQH_