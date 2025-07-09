//+------------------------------------------------------------------+
//|                                                     Logger.mqh |
//|              APEX Pullback EA v14.0 - Hệ thống ghi nhật ký      |
//|                  Phiên bản đã được tái cấu trúc                 |
//+------------------------------------------------------------------+

#ifndef APEX_LOGGER_MQH_
#define APEX_LOGGER_MQH_

#include "SonicR_CommonStructs.mqh" // For all types including enums

// BẮT ĐẦU NAMESPACE
namespace ApexSonicR
{

//+------------------------------------------------------------------+
//| Lớp CLogger - Quản lý ghi log chuyên nghiệp cho EA              |
//+------------------------------------------------------------------+
class CLogger
{
private:
    // --- Cấu hình & Trạng thái Nội tại ---
    ENUM_LOG_LEVEL  m_log_level;
    int             m_log_output;  // Use int for now, can be ENUM later
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
    void WriteToFile(const string& formatted_message) const;
    bool SendTelegramMessage(const string& formatted_message, const bool important) const;
    string GetLogLevelString(const ENUM_LOG_LEVEL level) const;

public:
    // --- Constructor & Destructor ---
    CLogger();
    ~CLogger();
    
    // --- Phương thức Khởi tạo & Dọn dẹp ---
    bool Initialize();
    void Deinitialize();
    bool IsInitialized() const { return m_initialized; }
    void OnTick() {}
    
    // --- Phương thức Ghi log Chính ---
    void Log(const ENUM_LOG_LEVEL level, const string message, const string tags = "") const;
    void Info(const string message, const string tags = "") const { Log(LOG_LEVEL_INFO, message, tags); }
    void Debug(const string message, const string tags = "") const { Log(LOG_LEVEL_DEBUG, message, tags); }
    void Warning(const string message, const string tags = "") const { Log(LOG_LEVEL_WARNING, message, tags); }
    void Error(const string message, const string tags = "") const { Log(LOG_LEVEL_ERROR, message, tags); }

    // --- Phương thức Tiện ích ---
    string GetLogFileName() const { return m_log_file_name; }
};

//+------------------------------------------------------------------+
//| Constructor - Khởi tạo trạng thái ban đầu an toàn               |
//+------------------------------------------------------------------+
CLogger::CLogger() : 
    m_log_level(LOG_LEVEL_INFO),
    m_log_output(2), // LOG_OUTPUT_CONSOLE equivalent
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
bool CLogger::Initialize()
{
    if (m_initialized) return true;
    // if (context == NULL) return false; // Removed as per edit hint

    // Use default values for now - can be enhanced later
    m_log_level = LOG_LEVEL_INFO;
    m_log_output = 2; // Console output
    m_enable_telegram = false;
    m_order_comment = "APEX_EA";
    
    m_symbol_name = Symbol();

    // 2. Setup file logging if needed
    if (m_log_output == 1 || m_log_output == 3) // FILE or BOTH
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

    // Log initialization message
    Log(LOG_LEVEL_INFO, "Logger initialized. Log file: '" + (m_log_file_handle != INVALID_HANDLE ? m_log_file_name : "N/A") + "'", "Logger");

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
    if (m_log_output == 2 || m_log_output == 3) // CONSOLE or BOTH
    {
        Print(formatted_message);
    }

    if (m_log_output == 1 || m_log_output == 3) // FILE or BOTH
    {
        WriteToFile(formatted_message);
    }
    
    // 4. Gửi Telegram nếu được kích hoạt
    if(m_enable_telegram)
    {
        bool is_important = (level >= LOG_LEVEL_WARNING);
        if(!m_telegram_important_only || is_important)
        {
            SendTelegramMessage(formatted_message, is_important);
        }
    }
}

//+------------------------------------------------------------------+
//| Ghi vào file log                                                 |
//+------------------------------------------------------------------+
void CLogger::WriteToFile(const string& formatted_message) const
{
    if (m_log_file_handle != INVALID_HANDLE)
    {
        FileWriteString(m_log_file_handle, formatted_message + "\r\n");
        FileFlush(m_log_file_handle);
    }
}

//+------------------------------------------------------------------+
//| Gửi tin nhắn Telegram                                            |
//+------------------------------------------------------------------+
bool CLogger::SendTelegramMessage(const string& formatted_message, const bool important) const
{
    if(m_telegram_bot_token == "" || m_telegram_chat_id == "") return false;

    string url = "https://api.telegram.org/bot" + m_telegram_bot_token + "/sendMessage";
    string headers;
    char post[], result[];
    string message_text = (important ? "\U0001F198 " : "") + "[" + m_order_comment + "] " + formatted_message;
    string post_data = "chat_id=" + m_telegram_chat_id + "&text=" + CharArrayToString(StringToCharArray(message_text, 0, -1, CP_UTF8), 0, -1);

    StringToCharArray(post_data, post, 0, StringLen(post_data), CP_UTF8);

    int res = WebRequest("POST", url, NULL, NULL, 5000, post, ArraySize(post), result, headers);

    if (res == -1)
    {       
        // Không ghi log lỗi ở đây để tránh vòng lặp vô hạn
        PrintFormat("LOGGER ERROR: Failed to send Telegram message. Error code: %d", GetLastError());
        return false;
    }
    
    return true;
}

} // KẾT THÚC NAMESPACE

#endif // APEX_LOGGER_MQH_