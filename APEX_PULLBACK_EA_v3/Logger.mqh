//+------------------------------------------------------------------+
//|                                                     Logger.mqh |
//|              APEX Pullback EA v14.0 - Hệ thống ghi nhật ký      |
//|                  Phiên bản đã được tái cấu trúc                 |
//+------------------------------------------------------------------+

#ifndef APEX_LOGGER_MQH_
#define APEX_LOGGER_MQH_

#include "CommonStructs.mqh" // Phụ thuộc duy nhất

// BẮT ĐẦU NAMESPACE
namespace ApexPullback
{

//+------------------------------------------------------------------+
//| Lớp CLogger - Quản lý ghi log chuyên nghiệp cho EA              |
//+------------------------------------------------------------------+
class CLogger
{
private:
    // --- Cấu hình & Trạng thái Nội tại ---
    ENUM_LOG_LEVEL  m_log_level;
    ENUM_LOG_OUTPUT m_log_output;
    bool            m_enable_telegram;
    bool            m_telegram_important_only;
    string          m_telegram_bot_token;
    string          m_telegram_chat_id;
    string          m_order_comment;

    string          m_symbol_name;      // Tên biểu tượng được lưu trữ
    string          m_log_file_name;    // Tên file log đầy đủ
    int             m_log_file_handle;  // Handle quản lý file log
    bool            m_initialized;      // Cờ trạng thái khởi tạo

    // --- Phương thức Nội bộ Hợp nhất ---
    void Log(const ENUM_LOG_LEVEL level, const string message, const string tags) const;
    void WriteToFile(const string& formatted_message) const;
    bool SendTelegramMessage(const string& formatted_message, const bool important) const;
    string GetLogLevelString(const ENUM_LOG_LEVEL level) const;

public:
    // --- Constructor & Destructor ---
    CLogger();
    ~CLogger();
    
    // --- Khởi tạo và Dọn dẹp ---
    bool Initialize(const SInputParameters &inputs);
    void Deinitialize();

    // --- Phương thức Ghi log Chính (Wrappers) ---
    void LogDebug(const string message, const string tags = "") const   { Log(LOG_LEVEL_DEBUG,   message, tags); }
    void LogInfo(const string message, const string tags = "") const    { Log(LOG_LEVEL_INFO,    message, tags); }
    void LogWarning(const string message, const string tags = "") const { Log(LOG_LEVEL_WARNING, message, tags); }
    void LogError(const string message, const string tags = "") const   { Log(LOG_LEVEL_ERROR,   message, tags); }

    // --- Phương thức Tiện ích ---
    bool   IsInitialized() const { return m_initialized; }
    string GetLogFileName() const { return m_log_file_name; }
    // TODO: Implement GenerateDailySummary in a robust way later.
    // void   GenerateDailySummary();
};

//+------------------------------------------------------------------+
//| Constructor - Khởi tạo trạng thái ban đầu an toàn               |
//+------------------------------------------------------------------+
CLogger::CLogger() : 
    m_log_level(LOG_INFO),
    m_log_output(LOG_OUTPUT_CONSOLE),
    m_enable_telegram(false),
    m_telegram_important_only(true),
    m_telegram_bot_token(""),
    m_telegram_chat_id(""),
    m_order_comment("APEX_EA"),
    m_symbol_name(""),
    m_log_file_name(""),
    m_log_file_handle(INVALID_HANDLE),
    m_initialized(false)
{
}

//+------------------------------------------------------------------+
//| Destructor - Dọn dẹp trước khi hủy đối tượng                     |
//+------------------------------------------------------------------+
CLogger::~CLogger() 
{
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize - Thiết lập Logger từ EAContext                      |
//+------------------------------------------------------------------+
bool CLogger::Initialize(const SInputParameters &inputs)
{
    if (m_initialized) return true;

    // 1. Sao chép các cấu hình cần thiết từ struct inputs
    m_log_level = inputs.LogLevel;
    m_log_output = inputs.LogOutput;
    m_enable_telegram = inputs.EnableTelegramNotify;
    m_telegram_important_only = inputs.TelegramImportantOnly;
    m_telegram_bot_token = inputs.TelegramBotToken;
    m_telegram_chat_id = inputs.TelegramChatID;
    m_order_comment = inputs.OrderComment;
    
    m_symbol_name = Symbol();

    // 2. Cấu hình File Log dựa trên các giá trị đã lưu
    if (m_log_output == LOG_OUTPUT_FILE || m_log_output == LOG_OUTPUT_BOTH)
    {
        string date_str = TimeToString(TimeCurrent(), TIME_DATE);
        StringReplace(date_str, ".", "");
        m_log_file_name = "Logs\\" + m_order_comment + "_" + m_symbol_name + "_" + date_str + ".log";

        m_log_file_handle = FileOpen(m_log_file_name, FILE_WRITE | FILE_TXT | FILE_ANSI | FILE_SHARE_READ);

        if (m_log_file_handle == INVALID_HANDLE)
        {
            PrintFormat("LOGGER WARNING: Cannot open log file '%s', error: %d. File logging will be disabled.", m_log_file_name, GetLastError());
        }
        else
        {
            FileSeek(m_log_file_handle, 0, SEEK_END);
        }
    }

    m_initialized = true;

    // 3. Ghi log thông điệp khởi tạo
    Log(LOG_LEVEL_INFO, "Logger initialized. Log file: '" + (m_log_file_handle != INVALID_HANDLE ? m_log_file_name : "N/A") + "'", "Logger");

    if(m_enable_telegram)
    {
         Log(LOG_LEVEL_INFO, "Telegram notifications enabled." + (m_telegram_important_only ? " (Important Only)" : ""), "Logger,Telegram");
    }

    return true;
}

//+------------------------------------------------------------------+
//| Giải phóng tài nguyên khi kết thúc EA hoặc Logger               |
//+------------------------------------------------------------------+
void CLogger::Deinitialize() 
{
   if(!m_initialized) return;

   Log(LOG_LEVEL_INFO, "Logger is shutting down...", "Logger");
   
   if(m_log_file_handle != INVALID_HANDLE) 
   {
      FileClose(m_log_file_handle);
      m_log_file_handle = INVALID_HANDLE;
   }
   
   m_initialized = false;
   // Không còn m_pContext để reset
}

//+------------------------------------------------------------------+
//| GetLogLevelString - Chuyển enum thành chuỗi để hiển thị        |
//+------------------------------------------------------------------+
string CLogger::GetLogLevelString(const ENUM_LOG_LEVEL level) const
{
    switch(level)
    {
        case LOG_LEVEL_DEBUG:   return "DEBUG";
        case LOG_LEVEL_INFO:    return "INFO";
        case LOG_LEVEL_WARNING: return "WARNING";
        case LOG_LEVEL_ERROR:   return "ERROR";
        default:                return "UNKNOWN";
    }
}

//+------------------------------------------------------------------+
//| Log - Hàm ghi log cốt lõi, hợp nhất                          |
//+------------------------------------------------------------------+
void CLogger::Log(const ENUM_LOG_LEVEL level, const string message, const string tags) const
{
    // 1. Kiểm tra an toàn và cấp độ log
    if (!m_initialized || level < m_log_level) return;

    // 2. Định dạng thông điệp
    string level_str = GetLogLevelString(level);
    string final_tags = tags != "" ? "[" + tags + "] " : "";
    string formatted_message = StringFormat("%s | %-7s | %s%s",
                                     TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS),
                                     level_str,
                                     final_tags,
                                     message);

    // 3. Xử lý đầu ra
    if (m_log_output == LOG_OUTPUT_PRINT || m_log_output == LOG_OUTPUT_BOTH)
    {
        Print(formatted_message);
    }

    if (m_log_output == LOG_OUTPUT_FILE || m_log_output == LOG_OUTPUT_BOTH)
    {
        WriteToFile(formatted_message);
    }

    // 4. Xử lý Telegram
    if (m_enable_telegram)
    {
        // Cảnh báo và Lỗi luôn được coi là quan trọng
        bool is_important = (level == LOG_LEVEL_WARNING || level == LOG_LEVEL_ERROR);
        SendTelegramMessage(formatted_message, is_important);
    }
}

//+------------------------------------------------------------------+
//| Ghi thông điệp vào file log                                      |
//+------------------------------------------------------------------+
void CLogger::WriteToFile(const string& formatted_message) const
{
    if (m_log_file_handle == INVALID_HANDLE) return;
    
    FileWriteString(m_log_file_handle, formatted_message + "\r\n");
    FileFlush(m_log_file_handle); // Đảm bảo nó được ghi ngay lập tức
}

//+------------------------------------------------------------------+
//| Gửi thông báo qua Telegram bằng WebRequest                      |
//+------------------------------------------------------------------+
bool CLogger::SendTelegramMessage(const string& formatted_message, const bool important) const
{
    // Kiểm tra an toàn và cấu hình
    if (!m_enable_telegram || m_telegram_bot_token == "" || m_telegram_chat_id == "")
        return false;

    // Chỉ gửi nếu là tin quan trọng hoặc chế độ "chỉ quan trọng" bị tắt
    if (m_telegram_important_only && !important)
        return false;

    // Xây dựng URL và tham số
    string url = "https://api.telegram.org/bot" + m_telegram_bot_token + "/sendMessage";
    string params = "chat_id=" + m_telegram_chat_id + "&text=" + formatted_message;

    char post_data[];
    char response_data[];
    string response_headers;
    StringToCharArray(params, post_data);
    string headers = "Content-Type: application/x-www-form-urlencoded\r\n";
    int timeout = 5000; // 5 giây

    ResetLastError();
    int res = WebRequest("POST", url, headers, timeout, post_data, response_data, response_headers);

    if (res == -1)
    {
        // Ghi log lỗi vào console để tránh vòng lặp vô hạn
        PrintFormat("CRITICAL LOGGER ERROR: Failed to send Telegram message. Error: %d", GetLastError());
        return false;
    }

    return true;
}

} // KẾT THÚC NAMESPACE

#endif // APEX_LOGGER_MQH_
