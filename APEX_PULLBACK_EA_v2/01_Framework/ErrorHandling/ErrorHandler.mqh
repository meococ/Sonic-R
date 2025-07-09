//+------------------------------------------------------------------+
//|                                               ErrorHandler.mqh |
//|                   ErrorHandler.mqh - APEX Pullback EA v14.0 |
//|   Description: Centralized error handling and reporting system.  |
//+------------------------------------------------------------------+

#ifndef ERRORHANDLER_MQH_
#define ERRORHANDLER_MQH_

#include "../../00_Core/Common/CommonStructs.mqh"

//+------------------------------------------------------------------+
//| CErrorHandler - Centralized Error Handling System              |
//+------------------------------------------------------------------+
class CErrorHandler {
private:
    EAContext*    m_pContext;           // Reference to EA context
    bool          m_bInitialized;       // Initialization status
    int           m_iLastError;         // Last MQL5 error code
    int           m_iErrorCount;        // Total errors recorded
    datetime      m_dtLastErrorTime;    // Timestamp of the last error

public:
    //--- Constructor/Destructor ---
    CErrorHandler();
    ~CErrorHandler();

    //--- Core Methods ---
    bool          Initialize(EAContext* context);
    void          Deinitialize();
    bool          IsInitialized() const { return m_bInitialized; }

    //--- Error Handling ---
    void          HandleError(const string& function, const string& message, const int error_code = 0);
    void          HandleCriticalError(const string& function, const string& message);
    void          CheckMqlError(const string& function, const string& operation_desc);

    //--- Getters ---
    int           GetLastError() const { return m_iLastError; }
    int           GetErrorCount() const { return m_iErrorCount; }
    string        GetErrorStats() const;

private:
    //--- Internal Methods ---
    void          RecordError(const int error_code, const string& message);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CErrorHandler::CErrorHandler() {
    m_pContext = NULL;
    m_bInitialized = false;
    m_iLastError = 0;
    m_iErrorCount = 0;
    m_dtLastErrorTime = 0;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CErrorHandler::~CErrorHandler() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CErrorHandler::Initialize(EAContext* context) {
    if (m_bInitialized) {
        return true;
    }
    m_pContext = context;
    if (m_pContext == NULL) {
        Print("[ERROR HANDLER] Context is NULL on initialization.");
        return false;
    }
    m_bInitialized = true;
    // Log initialization via the Logger if available
    if (m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo("Error Handler initialized.", __FUNCTION__);
    }
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CErrorHandler::Deinitialize() {
    if (!m_bInitialized) {
        return;
    }
    if (m_pContext != NULL && m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo(StringFormat("Error Handler shutting down. Total errors: %d", m_iErrorCount), __FUNCTION__);
    }
    m_bInitialized = false;
}

//+------------------------------------------------------------------+
//| Handle a generic error                                           |
//+------------------------------------------------------------------+
void CErrorHandler::HandleError(const string& function, const string& message, const int error_code = 0) {
    if (!m_bInitialized) return;

    int code_to_log = (error_code != 0) ? error_code : GetLastError();
    string full_message = StringFormat("%s | MQL5 Error: %d (%s)", message, code_to_log, ErrorDescription(code_to_log));

    RecordError(code_to_log, full_message);

    if (m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogError(full_message, function);
    }
}

//+------------------------------------------------------------------+
//| Handle a critical error that might stop the EA                   |
//+------------------------------------------------------------------+
void CErrorHandler::HandleCriticalError(const string& function, const string& message) {
    if (!m_bInitialized) return;

    int code_to_log = GetLastError();
    string full_message = StringFormat("CRITICAL: %s | MQL5 Error: %d (%s)", message, code_to_log, ErrorDescription(code_to_log));

    RecordError(code_to_log, full_message);

    if (m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogError(full_message, function); // Use LogError for critical issues
    }

    // Potentially trigger a safe shutdown of the EA
    // m_pContext->pSystemManager->InitiateSafeShutdown("Critical Error");
}

//+------------------------------------------------------------------+
//| Check the last MQL5 error code after an operation                |
//+------------------------------------------------------------------+
void CErrorHandler::CheckMqlError(const string& function, const string& operation_desc) {
    if (!m_bInitialized) return;

    int error_code = GetLastError();
    if (error_code != ERR_SUCCESS) {
        string message = StringFormat("Error after operation: %s", operation_desc);
        HandleError(function, message, error_code);
    }
}

//+------------------------------------------------------------------+
//| Get error statistics                                             |
//+------------------------------------------------------------------+
string CErrorHandler::GetErrorStats() const {
    return StringFormat("Total Errors: %d, Last Error Code: %d at %s",
                        m_iErrorCount,
                        m_iLastError,
                        TimeToString(m_dtLastErrorTime, TIME_DATE | TIME_SECONDS));
}

//+------------------------------------------------------------------+
//| Record an error internally                                       |
//+------------------------------------------------------------------+
void CErrorHandler::RecordError(const int error_code, const string& message) {
    m_iLastError = error_code;
    m_iErrorCount++;
    m_dtLastErrorTime = TimeCurrent();
    // Potentially store more detailed error info in a collection if needed
}

#endif // ERRORHANDLER_MQH_