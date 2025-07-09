//+------------------------------------------------------------------+
//|                                                      Logger.mqh |
//|                        Logger.mqh - APEX Pullback EA v5 FINAL   |
//|      Description: Advanced logging system with multiple outputs, |
//|                   log levels, and performance optimization.     |
//+------------------------------------------------------------------+

#ifndef LOGGER_MQH_
#define LOGGER_MQH_

#include "../../00_Core/Common/CommonStructs.mqh"

//+------------------------------------------------------------------+
//| CLogger - Advanced Logging System                               |
//+------------------------------------------------------------------+
class CLogger {
private:
    EAContext*            m_pContext;           // Reference to EA context
    bool                  m_bInitialized;      // Initialization status
    int                   m_iLogFileHandle;    // CSV log file handle
    string                m_sLogFileName;      // Current log file name
    datetime              m_dtLastLogTime;     // Last log timestamp
    int                   m_iLogCount;         // Number of logs written
    
    // Performance optimization
    string                m_sLogBuffer;        // Buffer for batch writing
    int                   m_iBufferSize;       // Current buffer size
    static const int      MAX_BUFFER_SIZE = 1024; // Max buffer size
    
public:
    //--- Constructor/Destructor ---
    CLogger();
    ~CLogger();
    
    //--- Core Methods ---
    bool                  Initialize(EAContext* context);
    void                  Deinitialize();
    bool                  IsInitialized() const { return m_bInitialized; }
    
    //--- Logging Methods ---
    void                  LogInfo(const string& message, const string& function = "");
    void                  LogWarning(const string& message, const string& function = "");
    void                  LogError(const string& message, const string& function = "");
    void                  LogDebug(const string& message, const string& function = "");
    void                  LogTrade(const string& message, const string& function = "");
    
    //--- Specialized Logging ---
    void                  LogTradeOpen(const string& symbol, const int ticket, const double volume, const double price, const string& comment = "");
    void                  LogTradeClose(const string& symbol, const int ticket, const double volume, const double price, const double profit, const string& comment = "");
    void                  LogSignal(const string& signal_type, const string& symbol, const double confidence, const string& details = "");
    void                  LogRiskEvent(const string& event_type, const string& details, const double risk_level = 0.0);
    void                  LogPerformance(const string& metric, const double value, const string& details = "");
    void                  OnTradeTransaction(const MqlTradeTransaction& trans, const MqlTradeRequest& request, const MqlTradeResult& result);

    //--- Utility Methods ---
    void                  FlushBuffer();       // Force write buffer to file
    void                  RotateLogFile();     // Create new log file
    string                GetLogStats();       // Get logging statistics
    
private:
    //--- Internal Methods ---
    void                  WriteLog(const ENUM_LOG_LEVEL level, const string& message, const string& function);
    string                FormatLogEntry(const ENUM_LOG_LEVEL level, const string& message, const string& function);
    string                GetLogLevelString(const ENUM_LOG_LEVEL level);
    bool                  ShouldLog(const ENUM_LOG_LEVEL level);
    void                  WriteToTerminal(const string& formatted_message, const ENUM_LOG_LEVEL level);
    void                  WriteToFile(const string& formatted_message);
    void                  WriteToBuffer(const string& formatted_message);
    string                GenerateLogFileName();
    bool                  OpenLogFile();
    void                  CloseLogFile();
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CLogger::CLogger() {
    m_pContext = NULL;
    m_bInitialized = false;
    m_iLogFileHandle = INVALID_HANDLE;
    m_sLogFileName = "";
    m_dtLastLogTime = 0;
    m_iLogCount = 0;
    m_sLogBuffer = "";
    m_iBufferSize = 0;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CLogger::~CLogger() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CLogger::Initialize(EAContext* context) {
    if (m_bInitialized) {
        return true;
    }
    
    m_pContext = context;
    if (m_pContext == NULL) {
        Print("[LOGGER ERROR] Context is NULL");
        return false;
    }
    
    // Generate log file name
    m_sLogFileName = GenerateLogFileName();
    
    // Open log file if CSV output is enabled
    if (m_pContext->Inputs.LogOutput == LOG_OUTPUT_CSV || m_pContext->Inputs.LogOutput == LOG_OUTPUT_BOTH) {
        if (!OpenLogFile()) {
            Print("[LOGGER ERROR] Failed to open log file: ", m_sLogFileName);
            return false;
        }
    }
    
    m_bInitialized = true;
    
    // Log initialization
    LogInfo("Logger initialized successfully", __FUNCTION__);
    LogInfo(StringFormat("Log Level: %s", GetLogLevelString(m_pContext->Inputs.LogLevel)), __FUNCTION__);
        LogInfo(StringFormat("Log Output: %d", (int)m_pContext->Inputs.LogOutput), __FUNCTION__);
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CLogger::Deinitialize() {
    if (!m_bInitialized) {
        return;
    }
    
    LogInfo(StringFormat("Logger shutting down. Total logs written: %d", m_iLogCount), __FUNCTION__);
    
    // Flush any remaining buffer
    FlushBuffer();
    
    // Close log file
    CloseLogFile();
    
    m_bInitialized = false;
}

//+------------------------------------------------------------------+
//| Log Methods                                                      |
//+------------------------------------------------------------------+
void CLogger::LogInfo(const string& message, const string& function = "") {
    WriteLog(LOG_LEVEL_INFO, message, function);
}

void CLogger::LogWarning(const string& message, const string& function = "") {
    WriteLog(LOG_LEVEL_WARNING, message, function);
}

void CLogger::LogError(const string& message, const string& function = "") {
    WriteLog(LOG_LEVEL_ERROR, message, function);
}

void CLogger::LogDebug(const string& message, const string& function = "") {
    WriteLog(LOG_LEVEL_DEBUG, message, function);
}

void CLogger::LogTrade(const string& message, const string& function = "") {
    WriteLog(LOG_LEVEL_TRADE, message, function);
}

//+------------------------------------------------------------------+
//| Specialized Logging Methods                                      |
//+------------------------------------------------------------------+
void CLogger::LogTradeOpen(const string& symbol, const int ticket, const double volume, const double price, const string& comment = "") {
    string message = StringFormat("TRADE OPEN: %s | Ticket: %d | Volume: %.2f | Price: %.5f | Comment: %s", 
                                  symbol, ticket, volume, price, comment);
    LogTrade(message, __FUNCTION__);
}

void CLogger::LogTradeClose(const string& symbol, const int ticket, const double volume, const double price, const double profit, const string& comment = "") {
    string message = StringFormat("TRADE CLOSE: %s | Ticket: %d | Volume: %.2f | Price: %.5f | Profit: %.2f | Comment: %s", 
                                  symbol, ticket, volume, price, profit, comment);
    LogTrade(message, __FUNCTION__);
}

void CLogger::LogSignal(const string& signal_type, const string& symbol, const double confidence, const string& details = "") {
    string message = StringFormat("SIGNAL: %s | %s | Confidence: %.2f%% | %s", 
                                  signal_type, symbol, confidence * 100, details);
    LogInfo(message, __FUNCTION__);
}

void CLogger::LogRiskEvent(const string& event_type, const string& details, const double risk_level = 0.0) {
    string message = StringFormat("RISK EVENT: %s | Risk Level: %.2f%% | %s", 
                                  event_type, risk_level * 100, details);
    LogWarning(message, __FUNCTION__);
}

void CLogger::LogPerformance(const string& metric, const double value, const string& details = "") {
    string message = StringFormat("PERFORMANCE: %s = %.4f | %s", metric, value, details);
    LogInfo(message, __FUNCTION__);
}

//+------------------------------------------------------------------+
//| Core Logging Method                                              |
//+------------------------------------------------------------------+
void CLogger::WriteLog(const ENUM_LOG_LEVEL level, const string& message, const string& function) {
    if (!m_bInitialized || !ShouldLog(level)) {
        return;
    }
    
    string formatted_message = FormatLogEntry(level, message, function);
    
    // Write to terminal if enabled
    if (m_pContext->Inputs.LogOutput == LOG_OUTPUT_TERMINAL || m_pContext->Inputs.LogOutput == LOG_OUTPUT_BOTH) {
        WriteToTerminal(formatted_message, level);
    }
    
    // Write to file if enabled
    if (m_pContext->Inputs.LogOutput == LOG_OUTPUT_CSV || m_pContext->Inputs.LogOutput == LOG_OUTPUT_BOTH) {
        WriteToFile(formatted_message);
    }
    
    m_iLogCount++;
    m_dtLastLogTime = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Format Log Entry                                                 |
//+------------------------------------------------------------------+
string CLogger::FormatLogEntry(const ENUM_LOG_LEVEL level, const string& message, const string& function) {
    datetime current_time = TimeCurrent();
    string time_str = TimeToString(current_time, TIME_DATE | TIME_SECONDS);
    string level_str = GetLogLevelString(level);
    string func_str = (function != "") ? StringFormat(" [%s]", function) : "";
    
    return StringFormat("%s | %s%s | %s", time_str, level_str, func_str, message);
}

//+------------------------------------------------------------------+
//| Get Log Level String                                             |
//+------------------------------------------------------------------+
string CLogger::GetLogLevelString(const ENUM_LOG_LEVEL level) {
    switch(level) {
        case LOG_LEVEL_ERROR:   return "ERROR";
        case LOG_LEVEL_WARNING: return "WARN ";
        case LOG_LEVEL_INFO:    return "INFO ";
        case LOG_LEVEL_DEBUG:   return "DEBUG";
        case LOG_LEVEL_TRADE:   return "TRADE";
        default:                return "UNKN ";
    }
}

//+------------------------------------------------------------------+
//| Should Log                                                       |
//+------------------------------------------------------------------+
bool CLogger::ShouldLog(const ENUM_LOG_LEVEL level) {
    return (level <= m_pContext->Inputs.LogLevel);
}

//+------------------------------------------------------------------+
//| Write to Terminal                                                |
//+------------------------------------------------------------------+
void CLogger::WriteToTerminal(const string& formatted_message, const ENUM_LOG_LEVEL level) {
    // Use different Print functions based on log level
    switch(level) {
        case LOG_LEVEL_ERROR:
            Print("❌ ", formatted_message);
            break;
        case LOG_LEVEL_WARNING:
            Print("⚠️ ", formatted_message);
            break;
        case LOG_LEVEL_TRADE:
            Print("💰 ", formatted_message);
            break;
        default:
            Print(formatted_message);
            break;
    }
}

//+------------------------------------------------------------------+
//| Write to File                                                    |
//+------------------------------------------------------------------+
void CLogger::WriteToFile(const string& formatted_message) {
    if (m_iLogFileHandle == INVALID_HANDLE) {
        return;
    }
    
    // Use buffering for better performance
    WriteToBuffer(formatted_message + "\n");
    
    // Flush buffer if it's getting full or on important messages
    if (m_iBufferSize >= MAX_BUFFER_SIZE) {
        FlushBuffer();
    }
}

//+------------------------------------------------------------------+
//| Write to Buffer                                                  |
//+------------------------------------------------------------------+
void CLogger::WriteToBuffer(const string& message) {
    m_sLogBuffer += message;
    m_iBufferSize += StringLen(message);
}

//+------------------------------------------------------------------+
//| Flush Buffer                                                     |
//+------------------------------------------------------------------+
void CLogger::FlushBuffer() {
    if (m_iLogFileHandle == INVALID_HANDLE || m_sLogBuffer == "") {
        return;
    }
    
    FileWriteString(m_iLogFileHandle, m_sLogBuffer);
    FileFlush(m_iLogFileHandle);
    
    m_sLogBuffer = "";
    m_iBufferSize = 0;
}

//+------------------------------------------------------------------+
//| Generate Log File Name                                           |
//+------------------------------------------------------------------+
string CLogger::GenerateLogFileName() {
    datetime current_time = TimeCurrent();
    string date_str = TimeToString(current_time, TIME_DATE);
    StringReplace(date_str, ".", "-");
    
    string filename = m_pContext->Inputs.CsvLogFilename;
    if (filename == "") {
        filename = StringFormat("APEX_Pullback_EA_v5_%s.csv", date_str);
    }
    
    return filename;
}

//+------------------------------------------------------------------+
//| Open Log File                                                    |
//+------------------------------------------------------------------+
bool CLogger::OpenLogFile() {
    m_iLogFileHandle = FileOpen(m_sLogFileName, FILE_WRITE | FILE_CSV | FILE_ANSI);
    
    if (m_iLogFileHandle == INVALID_HANDLE) {
        return false;
    }
    
    // Write CSV header
    string header = "Timestamp,Level,Function,Message";
    FileWriteString(m_iLogFileHandle, header + "\n");
    FileFlush(m_iLogFileHandle);
    
    return true;
}

//+------------------------------------------------------------------+
//| Close Log File                                                   |
//+------------------------------------------------------------------+
void CLogger::CloseLogFile() {
    if (m_iLogFileHandle != INVALID_HANDLE) {
        FileClose(m_iLogFileHandle);
        m_iLogFileHandle = INVALID_HANDLE;
    }
}

//+------------------------------------------------------------------+
//| Get Log Stats                                                    |
//+------------------------------------------------------------------+
string CLogger::GetLogStats() {
    return StringFormat("Logs: %d | Last: %s | File: %s", 
                        m_iLogCount, 
                        TimeToString(m_dtLastLogTime, TIME_SECONDS),
                        m_sLogFileName);
}

//+------------------------------------------------------------------+
//| OnTradeTransaction                                               |
//+------------------------------------------------------------------+
void CLogger::OnTradeTransaction(const MqlTradeTransaction& trans, const MqlTradeRequest& request, const MqlTradeResult& result) {
    if (!m_bInitialized || !ShouldLog(LOG_LEVEL_TRADE)) {
        return;
    }

    string msg = StringFormat("TRADE_TRANSACTION: Type=%s, Order=%d, Position=%d, Symbol=%s, Price=%.5f, Volume=%.2f, Result=%d (%s)",
                              EnumToString(trans.type),
                              trans.order,
                              trans.position,
                              trans.symbol,
                              trans.price,
                              trans.volume,
                              result.retcode,
                              result.comment);
    LogTrade(msg, __FUNCTION__);
}

#endif // LOGGER_MQH_