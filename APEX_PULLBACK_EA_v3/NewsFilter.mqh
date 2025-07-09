//+------------------------------------------------------------------+
//| NewsFilter.mqh                                                  |
//| Module quản lý và lọc tin tức kinh tế                            |
//+------------------------------------------------------------------+

#ifndef NEWSFILTER_MQH_
#define NEWSFILTER_MQH_

#include "CommonStructs.mqh"

// BẮT ĐẦU NAMESPACE
namespace ApexPullback {

// Forward declarations
// class CLogger; // Khai báo chuyển tiếp vì chỉ dùng con trỏ
//+------------------------------------------------------------------+
//| Lớp CNewsFilter - Quản lý lọc tin tức                           |
//+------------------------------------------------------------------+
class CNewsFilter {
private:
    EAContext* m_context;                  // Con trỏ đến context chính của EA
    datetime m_lastUpdate;                 // Thời gian cập nhật cuối
    int m_updateIntervalHours;             // Số giờ giữa các lần cập nhật
    
    // Mảng lưu trữ sự kiện tin tức
    NewsEvent m_newsEvents[100];           // Lưu trữ tối đa 100 tin tức
    int m_newsCount;                       // Số tin tức hiện có
    
    // Tham số lọc
    ENUM_NEWS_FILTER m_filterLevel;        // Mức độ lọc tin
    int m_newsImportance;                  // Độ quan trọng tin tối thiểu (1-3)
    int m_minutesBeforeNews;               // Phút trước tin tức
    int m_minutesAfterNews;                // Phút sau tin tức
    
    // Loại tiền tệ cần theo dõi (dựa trên cặp giao dịch)
    string m_currenciesToMonitor[2];       // Tối đa 2 đồng tiền
    
    // File dữ liệu tin tức
    string m_dataFileName;                 // Tên file CSV tin tức
        
    // Hàm hỗ trợ tách chuỗi
    int SplitString(string str, string separator, string& result[]);
    
public:
    // Khởi tạo
    CNewsFilter();
    ~CNewsFilter();
    
    // Khởi tạo và cấu hình
    bool Initialize(EAContext* context);
    
    // Cấu hình tham số
    void Configure(int minutes_before, int minutes_after, int importance);
    
    // Cập nhật dữ liệu tin tức từ tệp CSV
    bool UpdateNews();
    
    // Kiểm tra xem có trong cửa sổ thời gian tin tức không
    bool IsInNewsWindow();
    
    // Hàm gần với tin tức trong khoảng thời gian cụ thể
    bool HasNewsEvent(int minutesBefore, int minutesAfter, int minimumImpact = 2);
    
    // Lấy tin tức sắp tới (để hiển thị trên Dashboard)
    string GetUpcomingNewsInfo(int hoursAhead = 24);
    
    // Lấy thông tin tác động
    int GetCurrentNewsImpact();
    
    // Lấy thời gian tin tức tác động cao tiếp theo
    datetime GetNextHighImpactNewsTime();
    
    // Kiểm tra có tin tức tác động cao
    bool HasHighImpactNews();
    
    // Kiểm tra có tin tức sắp diễn ra
    bool HasUpcomingNews(int minutesAhead = 120, int minimumImpact = 2);
    
    // Kiểm tra có tin tức tác động cao trong khoảng thời gian
    bool IsHighImpactNewsTime(int minutesBefore = 30);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CNewsFilter::CNewsFilter() {
    m_lastUpdate = 0;
    m_updateIntervalHours = 12;      // Cập nhật tin 12 giờ một lần
    m_newsCount = 0;
    
    // Giá trị mặc định
    m_filterLevel = NEWS_MEDIUM;     // Mặc định lọc tin tức trung bình và cao
    m_newsImportance = 2;            // Mặc định từ tác động trung bình trở lên
    m_minutesBeforeNews = 30;        // 30 phút trước tin tức
    m_minutesAfterNews = 15;         // 15 phút sau tin tức
    m_dataFileName = "news_calendar.csv"; // Tên file mặc định
    
    // Khởi tạo mảng
    for(int i = 0; i < 100; i++) {
        m_newsEvents[i].time = 0;
        m_newsEvents[i].currency = "";
        m_newsEvents[i].name = "";
        m_newsEvents[i].impact = 0;
        m_newsEvents[i].isProcessed = false;
    }
    
    m_context = NULL;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CNewsFilter::~CNewsFilter() {
    // Dọn dẹp khi kết thúc
}

//+------------------------------------------------------------------+
//| Khởi tạo và cấu hình                                            |
//+------------------------------------------------------------------+
bool CNewsFilter::Initialize(EAContext* context) {
    if(context == NULL) return false;
    m_context = context;

    // Lưu tham số từ context
    m_filterLevel = m_context->inp_NewsFilter_FilterLevel;
    m_newsImportance = m_context->inp_NewsFilter_MinImportance;
    m_minutesBeforeNews = m_context->inp_NewsFilter_MinutesBefore;
    m_minutesAfterNews = m_context->inp_NewsFilter_MinutesAfter;
    m_dataFileName = m_context->inp_NewsFilter_DataFileName;
    
    string symbol = m_context->inp_Symbol;

    // Khởi tạo các tiền tệ cần giám sát từ cặp tiền tệ
    if (StringLen(symbol) >= 6) {
        m_currenciesToMonitor[0] = StringSubstr(symbol, 0, 3);
        m_currenciesToMonitor[1] = StringSubstr(symbol, 3, 3);
        
        if (m_context->Logger != NULL) {
            m_context->Logger->LogDebug(StringFormat("NewsFilter: Theo dõi các đồng tiền %s và %s", 
                           m_currenciesToMonitor[0], m_currenciesToMonitor[1]));
        }
    } else {
        // Xử lý trường hợp đặc biệt với các cặp phi truyền thống như GOLD, OIL
        if (symbol == "XAUUSD" || symbol == "GOLD") {
            m_currenciesToMonitor[0] = "XAU";
            m_currenciesToMonitor[1] = "USD";
        } else if (symbol == "XAGUSD" || symbol == "SILVER") {
            m_currenciesToMonitor[0] = "XAG";
            m_currenciesToMonitor[1] = "USD";
        } else {
            // Cặp không xác định, chỉ lọc tin tác động cao
            if (m_context->Logger != NULL) {
                m_context->Logger->LogWarning(StringFormat("NewsFilter: Không thể xác định đồng tiền từ symbol (%s), sẽ chỉ lọc tin tác động cao", symbol));
            }
            m_newsImportance = 3;  // Chỉ lọc tin tác động cao
        }
    }
    
    // Đầu tiên, cập nhật tin tức
    bool success = UpdateNews();
    
    if (!success && m_context->Logger != NULL) {
        m_context->Logger->LogWarning(StringFormat("NewsFilter: Không thể cập nhật tin tức từ file %s, bộ lọc tin tức có thể không hoạt động chính xác", m_dataFileName));
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Cấu hình lại tham số                                             |
//+------------------------------------------------------------------+
void CNewsFilter::Configure(int minutes_before, int minutes_after, int importance) {
    m_minutesBeforeNews = minutes_before;
    m_minutesAfterNews = minutes_after;
    m_newsImportance = importance;
    
    if (m_context != NULL && m_context->Logger != NULL) {
        m_context->Logger->LogInfo(StringFormat("NewsFilter: Cấu hình lại - %d phút trước, %d phút sau, tác động >= %d", 
                       minutes_before, minutes_after, importance));
    }
}

//+------------------------------------------------------------------+
//| Cập nhật dữ liệu tin tức từ tệp CSV                              |
//+------------------------------------------------------------------+
bool CNewsFilter::UpdateNews() {
    datetime currentTime = TimeCurrent();
    
    // Kiểm tra thời gian cập nhật, chỉ cập nhật theo định kỳ
    if (m_lastUpdate != 0 && (currentTime - m_lastUpdate < m_updateIntervalHours * 3600)) {
        return true; // Chưa đến thời gian cập nhật
    }
    
    // Reset danh sách tin tức
    m_newsCount = 0;
    
    // Kiểm tra file tồn tại
    if (!FileIsExist(m_dataFileName, FILE_COMMON)) {
        if (m_context != NULL && m_context->Logger != NULL) {
            m_context->Logger->LogWarning(StringFormat("NewsFilter: Không tìm thấy file tin tức %s", m_dataFileName));
        }
        return false;
    }
    
    // Mở file tin tức
    int fileHandle = FileOpen(m_dataFileName, FILE_READ | FILE_CSV | FILE_COMMON, ',');
    if (fileHandle == INVALID_HANDLE) {
        if (m_context != NULL && m_context->Logger != NULL) {
            m_context->Logger->LogError(StringFormat("NewsFilter: Không thể mở file tin tức: %d", GetLastError()));
        }
        return false;
    }
    
    // Đọc tiêu đề file (có thể bỏ qua)
    if (!FileIsEnding(fileHandle)) {
        string header = FileReadString(fileHandle);
    }
    
    // Đọc từng dòng dữ liệu
    while (!FileIsEnding(fileHandle) && m_newsCount < 100) {
        // Đọc từng cột
        string dateStr = FileReadString(fileHandle);
        string timeStr = FileReadString(fileHandle);
        string currency = FileReadString(fileHandle);
        string name = FileReadString(fileHandle);
        string impactStr = FileReadString(fileHandle);
        
        // Nếu hết dòng hoặc dòng không đủ dữ liệu
        if (FileIsLineEnding(fileHandle) && (dateStr == "" || timeStr == "")) {
            continue;
        }
        
        // Xử lý định dạng ngày giờ
        datetime newsTime = 0;
        
        // Cố gắng phân tích nhiều định dạng ngày giờ khác nhau
        if (StringLen(dateStr) >= 8 && StringLen(timeStr) >= 5) {
            // Định dạng: YYYY.MM.DD, HH:MM
            newsTime = StringToTime(dateStr + " " + timeStr);
            
            // Nếu không thành công, thử định dạng khác: DD.MM.YYYY, HH:MM
            if (newsTime == 0) {
                // Định dạng D/M/YYYY
                string dateParts[];
                if (StringSplit(dateStr, '.', dateParts) == 3) {
                    string reformattedDate = dateParts[2] + "." + dateParts[1] + "." + dateParts[0];
                    newsTime = StringToTime(reformattedDate + " " + timeStr);
                }
                else if (StringSplit(dateStr, '/', dateParts) == 3) {
                    string reformattedDate = dateParts[2] + "." + dateParts[1] + "." + dateParts[0];
                    newsTime = StringToTime(reformattedDate + " " + timeStr);
                }
            }
        }
        
        // Nếu vẫn không phân tích được, bỏ qua tin này
        if (newsTime == 0) {
            if (m_context != NULL && m_context->Logger != NULL) {
                m_context->Logger->LogWarning(StringFormat("NewsFilter: Không thể phân tích thời gian tin tức: %s %s", dateStr, timeStr));
            }
            continue;
        }
        
        // Chỉ lấy tin trong tương lai và hiện tại gần (trong 1 giờ qua)
        if (newsTime >= currentTime - 3600) {
            // Xác định mức độ tác động
            int impact = 1; // Mặc định tác động thấp
            
            // Phân tích mức độ tác động từ chuỗi
            if (StringFind(impactStr, "High") >= 0 || StringFind(impactStr, "3") >= 0 || 
                StringFind(impactStr, "!!!") >= 0 || StringFind(impactStr, "***") >= 0) {
                impact = 3; // Tác động cao
            }
            else if (StringFind(impactStr, "Medium") >= 0 || StringFind(impactStr, "2") >= 0 || 
                    StringFind(impactStr, "!!") >= 0 || StringFind(impactStr, "**") >= 0) {
                impact = 2; // Tác động trung bình
            }
            
            // Kiểm tra nếu tin liên quan đến cặp tiền đang giao dịch
            bool relevantNews = false;
            
            // Các tin tác động cao luôn được xem xét
            if (impact == 3 && m_filterLevel != NEWS_CUSTOM) {
                relevantNews = true;
            } else {
                // Tin thường - kiểm tra liên quan đến đồng tiền đang giao dịch
                for (int i = 0; i < 2; i++) {
                    if (StringFind(currency, m_currenciesToMonitor[i]) >= 0) {
                        relevantNews = true;
                        break;
                    }
                }
            }
            
            // Nếu tin liên quan và có mức độ tác động >= mức cấu hình
            if (relevantNews && impact >= m_newsImportance) {
                // Thêm vào danh sách nếu còn chỗ
                if (m_newsCount < 100) {
                    m_newsEvents[m_newsCount].time = newsTime;
                    m_newsEvents[m_newsCount].currency = currency;
                    m_newsEvents[m_newsCount].name = name;
                    m_newsEvents[m_newsCount].impact = impact;
                    m_newsEvents[m_newsCount].isProcessed = false;
                    m_newsCount++;
                }
            }
        }
    }
    
    // Đóng file
    FileClose(fileHandle);
    
    // Cập nhật thời gian
    m_lastUpdate = currentTime;
    
    if (m_context != NULL && m_context->Logger != NULL) {
        m_context->Logger->LogInfo(StringFormat("NewsFilter: Đã cập nhật tin tức, tìm thấy %d tin liên quan", m_newsCount));
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Kiểm tra có tin tức trong khoảng thời gian cụ thể                |
//+------------------------------------------------------------------+
bool CNewsFilter::HasNewsEvent(int minutesBefore, int minutesAfter, int minimumImpact = 2) {
    if (m_filterLevel == NEWS_NONE) {
        return false; // Không lọc tin tức
    }
    
    // Cập nhật tin tức nếu chưa có
    if (m_newsCount == 0) {
        UpdateNews();
    }
    
    datetime currentTime = TimeCurrent();
    bool foundNews = false;
    string newsInfo = "";
    
    // Kiểm tra tất cả các tin tức
    for (int i = 0; i < m_newsCount; i++) {
        // Tin tức có tác động đủ lớn
        if (m_newsEvents[i].impact >= minimumImpact) {
            // Tính thời gian trước và sau tin tức
            datetime beforeTime = m_newsEvents[i].time - minutesBefore * 60;
            datetime afterTime = m_newsEvents[i].time + minutesAfter * 60;
            
            // Nếu thời gian hiện tại nằm trong khoảng trước/sau tin tức
            if (currentTime >= beforeTime && currentTime <= afterTime) {
                foundNews = true;
                
                // Chuẩn bị thông tin để log
                if (m_context != NULL && m_context->Logger != NULL) {
                    string impactStars = "";
                    for (int j = 0; j < m_newsEvents[i].impact; j++) {
                        impactStars += "*";
                    }
                    
                    // Tính toán thời gian còn lại đến tin tức
                    int minutesRemaining = (int)((m_newsEvents[i].time - currentTime) / 60);
                    string timeInfo = "";
                    
                    if (minutesRemaining > 0) {
                        timeInfo = "còn " + IntegerToString(minutesRemaining) + " phút";
                    } else {
                        timeInfo = "đang diễn ra";
                    }
                    
                    newsInfo = "Tin " + impactStars + " " + m_newsEvents[i].currency + ": " + 
                              m_newsEvents[i].name + " (" + timeInfo + ")";
                }
                break;
            }
        }
    }
    
    // Log thông tin nếu tìm thấy tin tức
    if (foundNews && m_context != NULL && m_context->Logger != NULL && newsInfo != "") {
        m_context->Logger->LogInfo(StringFormat("NewsFilter: %s", newsInfo));
    }
    
    return foundNews;
}

//+------------------------------------------------------------------+
//| Kiểm tra xem có đang trong cửa sổ thời gian tin tức không       |
//+------------------------------------------------------------------+
bool CNewsFilter::IsInNewsWindow() {
    // Nếu bộ lọc tin tức bị tắt, luôn trả về false
    if (m_filterLevel == NEWS_NONE) {
        return false;
    }
    
    // Xác định mức độ tác động tối thiểu dựa trên level lọc
    int minimumImpact = m_newsImportance;
    
    switch(m_filterLevel) {
        case NEWS_LOW:    minimumImpact = 1; break;
        case NEWS_MEDIUM: minimumImpact = 2; break;
        case NEWS_HIGH:   minimumImpact = 3; break;
        case NEWS_CUSTOM: minimumImpact = m_newsImportance; break;
        default:          minimumImpact = 2; break;
    }
    
    // Kiểm tra tin tức với tham số cấu hình
    return HasNewsEvent(m_minutesBeforeNews, m_minutesAfterNews, minimumImpact);
}

//+------------------------------------------------------------------+
//| Lấy mức độ tác động tin tức hiện tại                            |
//+------------------------------------------------------------------+
int CNewsFilter::GetCurrentNewsImpact() {
    if (m_filterLevel == NEWS_NONE) {
        return 0; // Không lọc tin tức
    }
    
    // Cập nhật tin tức nếu chưa có
    if (m_newsCount == 0) {
        UpdateNews();
    }
    
    datetime currentTime = TimeCurrent();
    int maxImpact = 0;
    
    // Kiểm tra tất cả các tin tức
    for (int i = 0; i < m_newsCount; i++) {
        // Tính thời gian trước và sau tin tức
        datetime beforeTime = m_newsEvents[i].time - m_minutesBeforeNews * 60;
        datetime afterTime = m_newsEvents[i].time + m_minutesAfterNews * 60;
        
        // Nếu thời gian hiện tại nằm trong khoảng trước/sau tin tức
        if (currentTime >= beforeTime && currentTime <= afterTime) {
            // Lưu mức độ tác động cao nhất
            if (m_newsEvents[i].impact > maxImpact) {
                maxImpact = m_newsEvents[i].impact;
            }
        }
    }
    
    return maxImpact;
}

//+------------------------------------------------------------------+
//| Lấy thời gian tin tức tác động cao tiếp theo                    |
//+------------------------------------------------------------------+
datetime CNewsFilter::GetNextHighImpactNewsTime() {
    if (m_filterLevel == NEWS_NONE) {
        return 0; // Không lọc tin tức
    }
    
    // Cập nhật tin tức nếu chưa có
    if (m_newsCount == 0) {
        UpdateNews();
    }
    
    datetime currentTime = TimeCurrent();
    datetime nextNewsTime = 0;
    
    // Tìm tin tức tác động cao gần nhất trong tương lai
    for (int i = 0; i < m_newsCount; i++) {
        if (m_newsEvents[i].impact >= 3 && m_newsEvents[i].time > currentTime) {
            if (nextNewsTime == 0 || m_newsEvents[i].time < nextNewsTime) {
                nextNewsTime = m_newsEvents[i].time;
            }
        }
    }
    
    return nextNewsTime;
}

//+------------------------------------------------------------------+
//| Lấy thông tin tin tức sắp tới                                    |
//+------------------------------------------------------------------+
string CNewsFilter::GetUpcomingNewsInfo(int hoursAhead = 24) {
    if (m_filterLevel == NEWS_NONE) {
        return "Bộ lọc tin tức đã bị tắt";
    }
    
    // Cập nhật tin tức nếu chưa có
}

} // END NAMESPACE ApexPullback
    if (m_newsCount == 0) {
        UpdateNews();
    }
    
    string newsInfo = "";
    datetime currentTime = TimeCurrent();
    datetime maxTime = currentTime + hoursAhead * 3600; // Giới hạn tối đa là 24 giờ sắp tới
    
    // Mảng tạm để sắp xếp tin tức theo thời gian
    int sortedIndices[100];
    
    // Khởi tạo mảng
    int count = 0;
    for (int i = 0; i < m_newsCount; i++) {
        if (m_newsEvents[i].time > currentTime && m_newsEvents[i].time <= maxTime && 
            m_newsEvents[i].impact >= m_newsImportance) {
            sortedIndices[count] = i;
            count++;
        }
    }
    
    // Sắp xếp tin tức theo thời gian
    for (int i = 0; i < count - 1; i++) {
        for (int j = i + 1; j < count; j++) {
            if (m_newsEvents[sortedIndices[i]].time > m_newsEvents[sortedIndices[j]].time) {
                int temp = sortedIndices[i];
                sortedIndices[i] = sortedIndices[j];
                sortedIndices[j] = temp;
            }
        }
    }
    
    // Tạo chuỗi kết quả
    for (int i = 0; i < count; i++) {
        int idx = sortedIndices[i];
        
        // Tạo chuỗi sao hiển thị mức độ tác động
        string impactStars = "";
        for (int j = 0; j < m_newsEvents[idx].impact; j++) {
            impactStars += "*";
        }
        
        // Định dạng thời gian
        string timeStr = TimeToString(m_newsEvents[idx].time, TIME_DATE|TIME_MINUTES);
        
        // Thêm thông tin tin tức vào kết quả
        newsInfo += timeStr + " | " + impactStars + " | " + 
                  m_newsEvents[idx].currency + " | " + 
                  m_newsEvents[idx].name + "\n";
    }
    
    // Nếu không có tin tức nào
    if (count == 0) {
        newsInfo = "Không có tin tức quan trọng trong " + IntegerToString(hoursAhead) + " giờ tới";
    }
    
    return newsInfo;
}

//+------------------------------------------------------------------+
//| Hàm hỗ trợ tách chuỗi                                          |
//+------------------------------------------------------------------+
int CNewsFilter::SplitString(string str, string separator, string& result[]) {
    int count = 0;
    int pos = 0;
    int sepLen = StringLen(separator);
    
    if (sepLen == 0) {
        ArrayResize(result, 1);
        result[0] = str;
        return 1;
    }
    
    // Đếm số phần tách được
    int posPrev = 0;
    while ((pos = StringFind(str, separator, posPrev)) != -1) {
        count++;
        posPrev = pos + sepLen;
    }
    if (posPrev < StringLen(str)) {
        count++;
    }
    
    // Tách chuỗi
    ArrayResize(result, count);
    posPrev = 0;
    int resultIdx = 0;
    
    while ((pos = StringFind(str, separator, posPrev)) != -1) {
        result[resultIdx++] = StringSubstr(str, posPrev, pos - posPrev);
        posPrev = pos + sepLen;
    }
    
    if (posPrev < StringLen(str)) {
        result[resultIdx] = StringSubstr(str, posPrev);
    }
    
    return count;
}

//+------------------------------------------------------------------+
//| Kiểm tra có tin tức tác động cao                                |
//+------------------------------------------------------------------+
bool CNewsFilter::HasHighImpactNews() {
    // Mặc định kiểm tra tin tức tác động cao (impact level 3) trong khoảng 60 phút trước và 30 phút sau
    return HasNewsEvent(60, 30, 3);
}

//+------------------------------------------------------------------+
//| Kiểm tra có tin tức sắp diễn ra                                  |
//+------------------------------------------------------------------+
bool CNewsFilter::HasUpcomingNews(int minutesAhead, int minimumImpact) {
    // Nếu không lọc tin tức
    if (m_filterLevel == NEWS_NONE) {
        return false;
    }
    
    // Cập nhật tin tức nếu chưa có
    if (m_newsCount == 0) {
        UpdateNews();
    }
    
    datetime currentTime = TimeCurrent();
    datetime futureTime = currentTime + minutesAhead * 60;
    
    // Kiểm tra tất cả các tin tức
    for (int i = 0; i < m_newsCount; i++) {
        // Tin tức có tác động đủ lớn
        if (m_newsEvents[i].impact >= minimumImpact) {
            // Nếu tin tức nằm trong khoảng thời gian sắp tới
            if (m_newsEvents[i].time > currentTime && m_newsEvents[i].time <= futureTime) {
                // Tính toán thời gian còn lại đến tin tức
                int minutesRemaining = (int)((m_newsEvents[i].time - currentTime) / 60);
                
                if (m_logger != NULL && m_logger.IsDebugEnabled()) {
                    string impactStars = "";
                    for (int j = 0; j < m_newsEvents[i].impact; j++) {
                        impactStars += "*";
                    }
                    
                    string infoMsg = StringFormat("NewsFilter: Tin tức sắp diễn ra %s %s: %s (còn %d phút)",
                               impactStars,
                               m_newsEvents[i].currency,
                               m_newsEvents[i].name,
                               minutesRemaining);
                    m_logger->LogInfo(infoMsg);
                }
                
                return true;
            }
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Kiểm tra có tin tức tác động cao trong khoảng thời gian          |
//+------------------------------------------------------------------+
bool CNewsFilter::IsHighImpactNewsTime(int minutesBefore = 30)
{
    if (m_newsCount == 0) {
        return false; // Không có tin tức nào được tải
    }
    
    datetime currentTime = TimeCurrent();
    
    // Duyệt qua tất cả tin tức
    for (int i = 0; i < m_newsCount; i++) {
        // Chỉ kiểm tra tin tức tác động cao (impact >= 3)
        if (m_newsEvents[i].impact >= 3) {
            // Tính khoảng cách thời gian
            int minutesToNews = (int)((m_newsEvents[i].time - currentTime) / 60);
            
            // Kiểm tra nếu tin tức sắp diễn ra trong khoảng thời gian chỉ định
            if (minutesToNews >= 0 && minutesToNews <= minutesBefore) {
                if (m_logger != NULL) {
                    string impactStars = "";
                    if (m_newsEvents[i].impact >= 3) impactStars = "***";
                    else if (m_newsEvents[i].impact >= 2) impactStars = "**";
                    else impactStars = "*";
                    
                    string warningMsg = StringFormat(
                        "IsHighImpactNewsTime: Tin tức tác động cao %s %s: %s (còn %d phút)",
                        impactStars,
                        m_newsEvents[i].currency,
                        m_newsEvents[i].name,
                        minutesToNews
                    );
                    m_logger->LogWarning(warningMsg);
                }
                return true;
            }
        }
    }
    
    return false; // Không có tin tức tác động cao sắp diễn ra
}

} // end namespace ApexPullback

#endif // NEWSFILTER_MQH_