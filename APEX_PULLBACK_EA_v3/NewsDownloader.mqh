//+------------------------------------------------------------------+
//|                NewsDownloader.mqh - APEX Pullback EA v14.0      |
//|                           Copyright 2023-2024, APEX Forex        |
//|                             https://www.apexpullback.com         |
//+------------------------------------------------------------------+
#ifndef NEWS_DOWNLOADER_MQH
#define NEWS_DOWNLOADER_MQH

#include "CommonStructs.mqh"
#include "Enums.mqh"
#include "Logger.mqh"

namespace ApexPullback {

//+------------------------------------------------------------------+
//| Cấu trúc thông tin nguồn tin tức                                |
//+------------------------------------------------------------------+
struct NewsSource {
    string name;              // Tên nguồn
    string url;               // URL để tải
    string format;            // Định dạng: "CSV", "XML", "JSON"
    bool isActive;            // Có đang sử dụng không
    datetime lastUpdate;      // Lần cập nhật cuối
    int updateIntervalHours;  // Khoảng thời gian cập nhật (giờ)
    
    NewsSource() {
        name = "";
        url = "";
        format = "CSV";
        isActive = true;
        lastUpdate = 0;
        updateIntervalHours = 24;
    }
};

//+------------------------------------------------------------------+
//| Lớp tải tin tức tự động                                         |
//+------------------------------------------------------------------+
class CNewsDownloader {
private:
    CLogger* m_Logger;
    string m_NewsFolder;
    string m_DefaultNewsFile;
    NewsSource m_Sources[];
    bool m_AutoDownloadEnabled;
    int m_MaxRetries;
    int m_TimeoutSeconds;
    
public:
    CNewsDownloader();
    ~CNewsDownloader();
    
    bool Initialize(CLogger* logger, string newsFolder = "NewsData", bool autoDownload = true);
    void Cleanup();
    
    // Main functions
    bool DownloadNewsData(bool forceUpdate = false);
    bool IsNewsFileValid(string filename = "");
    bool IsNewsFileUpToDate(string filename = "", int maxAgeHours = 24);
    string GetNewsFilePath();
    
    // Source management
    void AddNewsSource(string name, string url, string format = "CSV", int updateInterval = 24);
    void RemoveNewsSource(string name);
    void EnableSource(string name, bool enable = true);
    
    // Utility functions
    bool CheckInternetConnection();
    bool ValidateNewsFile(string filename);
    void ShowNewsFileStatus();
    bool CreateBackupNewsFile();
    bool RestoreFromBackup();
    
private:
    bool DownloadFromSource(const NewsSource& source, string& outputFile);
    bool DownloadFromURL(string url, string outputFile);
    bool ParseCSVNews(string filename);
    bool ParseXMLNews(string filename);
    bool ConvertToStandardFormat(string inputFile, string outputFile, string inputFormat);
    string GetFileExtension(string filename);
    bool IsFileOlderThan(string filename, int hours);
    void LogDownloadStatus(string source, bool success, string details = "");
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CNewsDownloader::CNewsDownloader() {
    m_Logger = NULL;
    m_NewsFolder = "NewsData";
    m_DefaultNewsFile = "news_calendar.csv";
    m_AutoDownloadEnabled = true;
    m_MaxRetries = 3;
    m_TimeoutSeconds = 30;
    
    // Initialize default news sources
    ArrayResize(m_Sources, 0);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CNewsDownloader::~CNewsDownloader() {
    Cleanup();
}

//+------------------------------------------------------------------+
//| Khởi tạo NewsDownloader                                         |
//+------------------------------------------------------------------+
bool CNewsDownloader::Initialize(CLogger* logger, string newsFolder = "NewsData", bool autoDownload = true) {
    m_Logger = logger;
    m_NewsFolder = newsFolder;
    m_AutoDownloadEnabled = autoDownload;
    
    // Tạo thư mục news nếu chưa có
    if (!FolderCreate(m_NewsFolder, FILE_COMMON)) {
        if (GetLastError() != ERR_FILE_CANNOT_OPEN) { // Folder might already exist
            if (m_Logger) {
                m_Logger->LogError(StringFormat("Failed to create news folder: %s, Error: %d", 
                    m_NewsFolder, GetLastError()));
            }
            return false;
        }
    }
    
    // Thêm các nguồn tin tức mặc định
    AddNewsSource("ForexFactory", "https://nfs.faireconomy.media/ff_calendar_thisweek.csv", "CSV", 24);
    AddNewsSource("DailyFX", "https://www.dailyfx.com/files/Calendar-01-01-2024-01-07-2024.csv", "CSV", 24);
    AddNewsSource("Investing", "https://www.investing.com/economic-calendar/Service/getCalendarFilteredData", "JSON", 24);
    
    if (m_Logger) {
        m_Logger->LogInfo(StringFormat("NewsDownloader initialized - Folder: %s, AutoDownload: %s", 
            m_NewsFolder, m_AutoDownloadEnabled ? "Yes" : "No"));
    }
    
    // Kiểm tra và tải tin tức nếu cần
    if (m_AutoDownloadEnabled) {
        if (!IsNewsFileValid() || !IsNewsFileUpToDate()) {
            DownloadNewsData();
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Dọn dẹp tài nguyên                                              |
//+------------------------------------------------------------------+
void CNewsDownloader::Cleanup() {
    if (m_Logger) {
        m_Logger->LogInfo("NewsDownloader cleanup completed");
    }
}

//+------------------------------------------------------------------+
//| Tải dữ liệu tin tức                                             |
//+------------------------------------------------------------------+
bool CNewsDownloader::DownloadNewsData(bool forceUpdate = false) {
    if (!m_AutoDownloadEnabled && !forceUpdate) {
        if (m_Logger) {
            m_Logger->LogInfo("Auto download disabled and not forced");
        }
        return false;
    }
    
    // Kiểm tra kết nối internet
    if (!CheckInternetConnection()) {
        if (m_Logger) {
            m_Logger->LogWarning("No internet connection available for news download");
        }
        return false;
    }
    
    bool anySuccess = false;
    
    // Thử tải từ các nguồn
    for (int i = 0; i < ArraySize(m_Sources); i++) {
        if (!m_Sources[i].isActive) continue;
        
        // Kiểm tra xem có cần cập nhật không
        if (!forceUpdate && m_Sources[i].lastUpdate > 0) {
            datetime nextUpdate = m_Sources[i].lastUpdate + m_Sources[i].updateIntervalHours * 3600;
            if (TimeCurrent() < nextUpdate) {
                continue; // Chưa đến thời gian cập nhật
            }
        }
        
        string outputFile;
        if (DownloadFromSource(m_Sources[i], outputFile)) {
            m_Sources[i].lastUpdate = TimeCurrent();
            anySuccess = true;
            
            if (m_Logger) {
                m_Logger->LogInfo(StringFormat("Successfully downloaded news from %s", m_Sources[i].name));
            }
            
            // Nếu tải thành công từ nguồn đầu tiên, có thể dừng lại
            break;
        } else {
            if (m_Logger) {
                m_Logger->LogWarning(StringFormat("Failed to download news from %s", m_Sources[i].name));
            }
        }
    }
    
    if (anySuccess) {
        ShowNewsFileStatus();
    } else {
        if (m_Logger) {
            m_Logger->LogError("Failed to download news from all sources");
        }
        
        // Thử restore từ backup nếu có
        if (FileIsExist(m_NewsFolder + "\\" + m_DefaultNewsFile + ".backup", FILE_COMMON)) {
            RestoreFromBackup();
        }
    }
    
    return anySuccess;
}

//+------------------------------------------------------------------+
//| Kiểm tra file tin tức có hợp lệ không                           |
//+------------------------------------------------------------------+
bool CNewsDownloader::IsNewsFileValid(string filename = "") {
    if (filename == "") {
        filename = GetNewsFilePath();
    }
    
    if (!FileIsExist(filename, FILE_COMMON)) {
        if (m_Logger) {
            m_Logger->LogWarning(StringFormat("News file does not exist: %s", filename));
        }
        return false;
    }
    
    return ValidateNewsFile(filename);
}

//+------------------------------------------------------------------+
//| Kiểm tra file tin tức có cập nhật không                         |
//+------------------------------------------------------------------+
bool CNewsDownloader::IsNewsFileUpToDate(string filename = "", int maxAgeHours = 24) {
    if (filename == "") {
        filename = GetNewsFilePath();
    }
    
    return !IsFileOlderThan(filename, maxAgeHours);
}

//+------------------------------------------------------------------+
//| Lấy đường dẫn file tin tức                                      |
//+------------------------------------------------------------------+
string CNewsDownloader::GetNewsFilePath() {
    return m_NewsFolder + "\\" + m_DefaultNewsFile;
}

//+------------------------------------------------------------------+
//| Thêm nguồn tin tức                                              |
//+------------------------------------------------------------------+
void CNewsDownloader::AddNewsSource(string name, string url, string format = "CSV", int updateInterval = 24) {
    // Kiểm tra xem nguồn đã tồn tại chưa
    for (int i = 0; i < ArraySize(m_Sources); i++) {
        if (m_Sources[i].name == name) {
            // Cập nhật nguồn hiện có
            m_Sources[i].url = url;
            m_Sources[i].format = format;
            m_Sources[i].updateIntervalHours = updateInterval;
            return;
        }
    }
    
    // Thêm nguồn mới
    int newSize = ArraySize(m_Sources) + 1;
    ArrayResize(m_Sources, newSize);
    
    m_Sources[newSize - 1].name = name;
    m_Sources[newSize - 1].url = url;
    m_Sources[newSize - 1].format = format;
    m_Sources[newSize - 1].updateIntervalHours = updateInterval;
    m_Sources[newSize - 1].isActive = true;
    m_Sources[newSize - 1].lastUpdate = 0;
    
    if (m_Logger) {
        m_Logger->LogInfo(StringFormat("Added news source: %s (%s)", name, format));
    }
}

//+------------------------------------------------------------------+
//| Xóa nguồn tin tức                                               |
//+------------------------------------------------------------------+
void CNewsDownloader::RemoveNewsSource(string name) {
    for (int i = 0; i < ArraySize(m_Sources); i++) {
        if (m_Sources[i].name == name) {
            // Dịch chuyển các phần tử
            for (int j = i; j < ArraySize(m_Sources) - 1; j++) {
                m_Sources[j] = m_Sources[j + 1];
            }
            ArrayResize(m_Sources, ArraySize(m_Sources) - 1);
            
            if (m_Logger) {
                m_Logger->LogInfo(StringFormat("Removed news source: %s", name));
            }
            break;
        }
    }
}

//+------------------------------------------------------------------+
//| Bật/tắt nguồn tin tức                                           |
//+------------------------------------------------------------------+
void CNewsDownloader::EnableSource(string name, bool enable = true) {
    for (int i = 0; i < ArraySize(m_Sources); i++) {
        if (m_Sources[i].name == name) {
            m_Sources[i].isActive = enable;
            
            if (m_Logger) {
                m_Logger->LogInfo(StringFormat("%s news source: %s", 
                    enable ? "Enabled" : "Disabled", name));
            }
            break;
        }
    }
}

//+------------------------------------------------------------------+
//| Kiểm tra kết nối internet                                       |
//+------------------------------------------------------------------+
bool CNewsDownloader::CheckInternetConnection() {
    // Thử tải một trang web đơn giản để kiểm tra kết nối
    string testUrl = "http://www.google.com";
    string tempFile = "temp_connection_test.html";
    
    bool connected = DownloadFromURL(testUrl, tempFile);
    
    // Xóa file test
    if (FileIsExist(tempFile, FILE_COMMON)) {
        FileDelete(tempFile, FILE_COMMON);
    }
    
    return connected;
}

//+------------------------------------------------------------------+
//| Validate file tin tức                                           |
//+------------------------------------------------------------------+
bool CNewsDownloader::ValidateNewsFile(string filename) {
    int handle = FileOpen(filename, FILE_READ | FILE_TXT | FILE_COMMON);
    if (handle == INVALID_HANDLE) {
        return false;
    }
    
    // Đọc vài dòng đầu để kiểm tra format
    string firstLine = FileReadString(handle);
    string secondLine = FileReadString(handle);
    
    FileClose(handle);
    
    // Kiểm tra cơ bản: file không rỗng và có header hợp lệ
    if (StringLen(firstLine) < 10 || StringLen(secondLine) < 10) {
        if (m_Logger) {
            m_Logger->LogWarning(StringFormat("News file appears to be invalid or too short: %s", filename));
        }
        return false;
    }
    
    // Kiểm tra có chứa các từ khóa cần thiết
    string lowerFirst = firstLine;
    StringToLower(lowerFirst);
    
    if (StringFind(lowerFirst, "date") < 0 && StringFind(lowerFirst, "time") < 0) {
        if (m_Logger) {
            m_Logger->LogWarning(StringFormat("News file header doesn't contain expected fields: %s", filename));
        }
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Hiển thị trạng thái file tin tức                                |
//+------------------------------------------------------------------+
void CNewsDownloader::ShowNewsFileStatus() {
    if (!m_Logger) return;
    
    string filename = GetNewsFilePath();
    
    if (!FileIsExist(filename, FILE_COMMON)) {
        m_Logger->LogWarning("News file not found: " + filename);
        m_Logger->LogInfo("Recommendation: Enable auto-download or manually place news file");
        return;
    }
    
    // Lấy thông tin file
    datetime fileTime;
    long fileSize;
    
    if (FileGetInteger(filename, FILE_MODIFY_DATE, fileTime, FILE_COMMON) &&
        FileGetInteger(filename, FILE_SIZE, fileSize, FILE_COMMON)) {
        
        int ageHours = (int)((TimeCurrent() - fileTime) / 3600);
        
        m_Logger->LogInfo(StringFormat("News file status: %s", filename));
        m_Logger->LogInfo(StringFormat("  Size: %d bytes", fileSize));
        m_Logger->LogInfo(StringFormat("  Last modified: %s (%d hours ago)", 
            TimeToString(fileTime), ageHours));
        
        if (ageHours > 48) {
            m_Logger->LogWarning("News file is quite old, consider updating");
        } else if (ageHours > 24) {
            m_Logger->LogInfo("News file is 1+ day old, may need update");
        } else {
            m_Logger->LogInfo("News file is up to date");
        }
    }
}

//+------------------------------------------------------------------+
//| Tạo backup file tin tức                                         |
//+------------------------------------------------------------------+
bool CNewsDownloader::CreateBackupNewsFile() {
    string sourceFile = GetNewsFilePath();
    string backupFile = sourceFile + ".backup";
    
    if (!FileIsExist(sourceFile, FILE_COMMON)) {
        return false;
    }
    
    // Copy file
    return FileCopy(sourceFile, FILE_COMMON, backupFile, FILE_COMMON);
}

//+------------------------------------------------------------------+
//| Restore từ backup                                               |
//+------------------------------------------------------------------+
bool CNewsDownloader::RestoreFromBackup() {
    string sourceFile = GetNewsFilePath();
    string backupFile = sourceFile + ".backup";
    
    if (!FileIsExist(backupFile, FILE_COMMON)) {
        return false;
    }
    
    bool success = FileCopy(backupFile, FILE_COMMON, sourceFile, FILE_COMMON);
    
    if (success && m_Logger) {
        m_Logger->LogInfo("Restored news file from backup");
    }
    
    return success;
}

//+------------------------------------------------------------------+
//| Tải từ nguồn cụ thể                                             |
//+------------------------------------------------------------------+
bool CNewsDownloader::DownloadFromSource(const NewsSource& source, string& outputFile) {
    outputFile = m_NewsFolder + "\\" + m_DefaultNewsFile;
    
    // Tạo backup trước khi tải mới
    if (FileIsExist(outputFile, FILE_COMMON)) {
        CreateBackupNewsFile();
    }
    
    bool success = false;
    
    for (int retry = 0; retry < m_MaxRetries; retry++) {
        if (DownloadFromURL(source.url, outputFile)) {
            // Kiểm tra file đã tải
            if (ValidateNewsFile(outputFile)) {
                success = true;
                break;
            } else {
                if (m_Logger) {
                    m_Logger->LogWarning(StringFormat("Downloaded file from %s failed validation, retry %d", 
                        source.name, retry + 1));
                }
            }
        }
        
        if (retry < m_MaxRetries - 1) {
            Sleep(2000); // Wait 2 seconds before retry
        }
    }
    
    LogDownloadStatus(source.name, success, success ? "" : "Failed after " + IntegerToString(m_MaxRetries) + " retries");
    
    return success;
}

//+------------------------------------------------------------------+
//| Tải từ URL                                                      |
//+------------------------------------------------------------------+
bool CNewsDownloader::DownloadFromURL(string url, string outputFile) {
    // Sử dụng WebRequest để tải file
    // Lưu ý: Cần thêm URL vào danh sách allowed URLs trong MT5
    
    char data[];
    string headers;
    int timeout = m_TimeoutSeconds * 1000; // Convert to milliseconds
    
    int result = WebRequest("GET", url, "", timeout, data, headers);
    
    if (result == 200) { // HTTP OK
        // Ghi dữ liệu vào file
        int handle = FileOpen(outputFile, FILE_WRITE | FILE_BIN | FILE_COMMON);
        if (handle != INVALID_HANDLE) {
            FileWriteArray(handle, data);
            FileClose(handle);
            return true;
        }
    } else {
        if (m_Logger) {
            m_Logger->LogError(StringFormat("WebRequest failed for %s, HTTP code: %d", url, result));
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Parse CSV news file                                             |
//+------------------------------------------------------------------+
bool CNewsDownloader::ParseCSVNews(string filename) {
    // Implementation for parsing CSV format
    // This would depend on the specific CSV format from the source
    return true; // Placeholder
}

//+------------------------------------------------------------------+
//| Parse XML news file                                             |
//+------------------------------------------------------------------+
bool CNewsDownloader::ParseXMLNews(string filename) {
    // Implementation for parsing XML format
    return true; // Placeholder
}

//+------------------------------------------------------------------+
//| Convert to standard format                                      |
//+------------------------------------------------------------------+
bool CNewsDownloader::ConvertToStandardFormat(string inputFile, string outputFile, string inputFormat) {
    if (inputFormat == "CSV") {
        return ParseCSVNews(inputFile);
    } else if (inputFormat == "XML") {
        return ParseXMLNews(inputFile);
    }
    
    // If already in standard format, just copy
    return FileCopy(inputFile, FILE_COMMON, outputFile, FILE_COMMON);
}

//+------------------------------------------------------------------+
//| Lấy extension của file                                          |
//+------------------------------------------------------------------+
string CNewsDownloader::GetFileExtension(string filename) {
    int lastDot = StringFindRev(filename, ".");
    if (lastDot >= 0) {
        return StringSubstr(filename, lastDot + 1);
    }
    return "";
}

//+------------------------------------------------------------------+
//| Kiểm tra file có cũ hơn số giờ chỉ định không                   |
//+------------------------------------------------------------------+
bool CNewsDownloader::IsFileOlderThan(string filename, int hours) {
    if (!FileIsExist(filename, FILE_COMMON)) {
        return true; // File không tồn tại = cũ
    }
    
    datetime fileTime;
    if (FileGetInteger(filename, FILE_MODIFY_DATE, fileTime, FILE_COMMON)) {
        return (TimeCurrent() - fileTime) > (hours * 3600);
    }
    
    return true; // Không lấy được thời gian = coi như cũ
}

//+------------------------------------------------------------------+
//| Log trạng thái download                                         |
//+------------------------------------------------------------------+
void CNewsDownloader::LogDownloadStatus(string source, bool success, string details = "") {
    if (!m_Logger) return;
    
    if (success) {
        m_Logger->LogInfo(StringFormat("News download successful from %s%s", 
            source, details != "" ? " - " + details : ""));
    } else {
        m_Logger->LogError(StringFormat("News download failed from %s%s", 
            source, details != "" ? " - " + details : ""));
    }
}

} // namespace ApexPullback

#endif // NEWS_DOWNLOADER_MQH