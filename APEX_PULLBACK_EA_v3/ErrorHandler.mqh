#ifndef APEX_ERRORHANDLER_MQH_
#define APEX_ERRORHANDLER_MQH_

#include "CommonStructs.mqh"

namespace ApexPullback {

// Cấu trúc để lưu trữ thông tin lỗi
struct SErrorInfo {
    int         error_code;
    string      function_name;
    string      message;
    datetime    timestamp;
    ENUM_ERROR_TYPE error_type;

    void Clear() {
        error_code = 0;
        function_name = "";
        message = "";
        timestamp = 0;
        error_type = ERROR_TYPE_NONE;
    }
};

class CErrorHandler 
{
private:
    // --- State ---
    bool       m_initialized;      // Initialization flag
private:
    EAContext* m_pContext;      // Pointer to the global context
    
    // Circular buffer for errors when logger is unavailable
    static const int MAX_ERROR_BUFFER = 50;
    SErrorInfo   m_errorBuffer[MAX_ERROR_BUFFER];
    int          m_bufferIndex;     // Next write position
    int          m_errorsInBuff;    // Current number of errors in buffer

    // Phân loại lỗi
    ENUM_ERROR_TYPE ClassifyError(const int error_code) const;
    
    // Xử lý bộ đệm lỗi
    void BufferError(const SErrorInfo& error);
    void ProcessErrorBuffer();

public:
    CErrorHandler(void) : m_initialized(false), m_pContext(NULL), m_bufferIndex(0), m_errorsInBuff(0) {}
    ~CErrorHandler(void) { Deinitialize(); }

    bool Initialize(EAContext* pContext);
    void Deinitialize(void);
    bool IsInitialized(void) const { return m_initialized; }

    // Xử lý lỗi với phân loại tự động
    bool HandleError(const int error_code, const string& function_name, const string& message, bool trip_circuit_breaker = false);
    
    // Lấy thông tin lỗi cuối cùng
    bool GetLastError(SErrorInfo& error) const;
    
    // Xóa bộ đệm lỗi
    void ClearErrorBuffer();
};

//+------------------------------------------------------------------+
//| Initializes the Error Handler                                    |
//+------------------------------------------------------------------+
bool CErrorHandler::Initialize(EAContext* pContext)
{
    if (m_initialized) return true;

    m_pContext = pContext;
    if (m_pContext == NULL)
    {
        Print("FATAL: CErrorHandler received a NULL context during initialization.");
        return false;
    }
    
    ClearErrorBuffer();
    m_initialized = true;
    
    // Immediately process any errors that were buffered before full initialization
    ProcessErrorBuffer();
    
    return true;
}

// Implementation of HandleError
bool CErrorHandler::HandleError(const int error_code, const string& function_name, const string& message, bool trip_circuit_breaker = false) 
{
    // Create error info immediately
    SErrorInfo error;
    error.error_code = error_code;
    error.function_name = function_name;
    error.message = message;
    error.timestamp = TimeCurrent();
    error.error_type = ClassifyError(error_code);

    // Buffer the error first, regardless of initialization state.
    // This ensures no error is ever lost.
    BufferError(error);

    // If not fully initialized, we can't do anything else.
    if (!m_initialized || m_pContext == NULL)
    {
        PrintFormat("CRITICAL FAILURE in ErrorHandler: Handler not initialized. Error buffered. Original Error: Code[%d] in '%s'. Message: %s", error_code, function_name, message);
        return false;
    }

    // Now that we are initialized, try to process the buffer.
    // This will log the error we just added, and any others.
    ProcessErrorBuffer(); 

    // The rest of the logic depends on a valid context
    string full_message = StringFormat("Code[%d] Type[%s]: %s", 
        error_code, 
        EnumToString(error.error_type), 
        message);

    bool logged = true; // Assume success as it's now buffered or logged

    // Xử lý theo loại lỗi
    switch(error.error_type)
    {
        case ERROR_TYPE_BROKER:
            // Notify BrokerHealthMonitor if available
            if(m_pContext->pBrokerHealthMonitor != NULL)
                m_pContext->pBrokerHealthMonitor->OnBrokerError(error_code);
            break;
            
        case ERROR_TYPE_SYSTEM:
            // Lỗi hệ thống nghiêm trọng luôn kích hoạt circuit breaker
            trip_circuit_breaker = true;
            break;
            
        case ERROR_TYPE_NETWORK:
            // Có thể thêm logic retry ở đây
            break;
    }

    // Kích hoạt circuit breaker nếu cần
    if (trip_circuit_breaker && m_pContext->pCircuitBreaker != NULL) 
    {
        m_pContext->pCircuitBreaker->Trip(full_message);
    }

    return logged;
}

//+------------------------------------------------------------------+
//| Classifies an error based on its MQL5 code.                      |
//+------------------------------------------------------------------+
ENUM_ERROR_TYPE CErrorHandler::ClassifyError(const int error_code) const
{
    // Trade Server Return Codes (https://www.mql5.com/en/docs/constants/tradingconstants/enum_trade_return_codes)
    if (error_code >= 10004 && error_code <= 10045)
    {
        switch(error_code)
        {
            // Broker/Connection Issues
            case TRADE_RETCODE_REQUOTE:
            case TRADE_RETCODE_PRICE_OFF:
            case TRADE_RETCODE_PRICE_CHANGED:
            case TRADE_RETCODE_BROKER_BUSY:
            case TRADE_RETCODE_SERVER_BUSY: // Same as TRADE_RETCODE_BROKER_BUSY
            case TRADE_RETCODE_CONNECTION:
            case TRADE_RETCODE_TIMEOUT:
                return ERROR_TYPE_BROKER;

            // Logic/Parameter Errors (should be caught in development)
            case TRADE_RETCODE_INVALID_REQUEST:
            case TRADE_RETCODE_INVALID_STOPS:
            case TRADE_RETCODE_INVALID_TRADE_VOLUME:
            case TRADE_RETCODE_INVALID_PRICE:
            case TRADE_RETCODE_INVALID_EXPIRATION:
            case TRADE_RETCODE_INVALID_FILL:
            case TRADE_RETCODE_UNSUPPORTED_FILL:
                return ERROR_TYPE_LOGIC;

            // Account/State Issues
            case TRADE_RETCODE_NO_MONEY:
            case TRADE_RETCODE_DISABLED:
            case TRADE_RETCODE_ACCOUNT_DISABLED:
            case TRADE_RETCODE_TRADE_DISABLED_BY_FIFO:
                return ERROR_TYPE_ACCOUNT;

            // Other trade-related errors
            default:
                return ERROR_TYPE_TRADE;
        }
    }

    // General MQL5 Errors (https://www.mql5.com/en/docs/constants/errorswarnings/errorcodes)
    switch(error_code)
    {
        // System Errors
        case ERR_INTERNAL_ERROR:
        case ERR_NOT_ENOUGH_MEMORY:
        case ERR_TOO_MANY_OBJECTS:
        case ERR_TOO_MANY_MODULES:
            return ERROR_TYPE_SYSTEM;

        // Network Errors
        case ERR_NO_CONNECTION:
        case ERR_NOT_CONNECTED:
        case ERR_NOTIFICATION_SEND_FAILED:
            return ERROR_TYPE_NETWORK;

        // Broker/Trade Context Errors
        case ERR_BROKER_BUSY:
        case ERR_TRADE_CONTEXT_BUSY:
            return ERROR_TYPE_BROKER;

        // Logic/Parameter Errors
        case ERR_INVALID_PARAMETER:
        case ERR_INVALID_FUNCTION_PARAMETER_VALUE:
        case ERR_INVALID_HANDLE:
        case ERR_INVALID_POINTER:
            return ERROR_TYPE_LOGIC;
    }

    return ERROR_TYPE_UNKNOWN;
}

//+------------------------------------------------------------------+
//| Stores an error in the circular buffer.                          |
//+------------------------------------------------------------------+
void CErrorHandler::BufferError(const SErrorInfo& error)
{
    m_errorBuffer[m_bufferIndex] = error;
    m_bufferIndex = (m_bufferIndex + 1) % MAX_ERROR_BUFFER;
    if (m_errorsInBuff < MAX_ERROR_BUFFER)
    {
        m_errorsInBuff++;
    }
}

//+------------------------------------------------------------------+
//| Deinitializes the Error Handler                                  |
//+------------------------------------------------------------------+
void CErrorHandler::Deinitialize(void)
{
    if(!m_initialized) return;
    
    // Attempt to process any remaining buffered errors before shutting down
    ProcessErrorBuffer();
    
    if(m_pContext && m_pContext->pLogger && m_pContext->pLogger->IsInitialized())
    {
       m_pContext->pLogger->LogInfo("ErrorHandler deinitialized.", __FUNCTION__);
    }
    
    m_pContext = NULL;
    m_initialized = false;
}

//+------------------------------------------------------------------+
//| Gets the last error from the buffer.                             |
//+------------------------------------------------------------------+
bool CErrorHandler::GetLastError(SErrorInfo& error) const
{
    if (m_errorsInBuff > 0)
    {
        // Last error is at the position before the current buffer index
        int last_index = (m_bufferIndex - 1 + MAX_ERROR_BUFFER) % MAX_ERROR_BUFFER;
        error = m_errorBuffer[last_index];
        return true;
    }
    error.Clear();
    return false;
}

//+------------------------------------------------------------------+
//| Clears the error buffer.                                         |
//+------------------------------------------------------------------+
void CErrorHandler::ClearErrorBuffer()
{
    for(int i = 0; i < MAX_ERROR_BUFFER; i++)
    {
        m_errorBuffer[i].Clear();
    }
    m_bufferIndex = 0;
    m_errorsInBuff = 0;
}

//+------------------------------------------------------------------+
//| Processes any errors currently in the buffer.                    |
//+------------------------------------------------------------------+
void CErrorHandler::ProcessErrorBuffer()
{
    // Can't process if logger isn't ready or there's nothing to process.
    if (m_pContext == NULL || m_pContext->pLogger == NULL || !m_pContext->pLogger->IsInitialized() || m_errorsInBuff == 0)
        return;

    // To prevent re-entrancy issues, copy errors to a temp buffer and clear the main one.
    SErrorInfo tempBuffer[];
    ArrayResize(tempBuffer, m_errorsInBuff);
    int tempCount = m_errorsInBuff;

    int readIndex = (m_bufferIndex - m_errorsInBuff + MAX_ERROR_BUFFER) % MAX_ERROR_BUFFER;
    for(int i = 0; i < tempCount; i++)
    {
        tempBuffer[i] = m_errorBuffer[readIndex];
        readIndex = (readIndex + 1) % MAX_ERROR_BUFFER;
    }

    // Now clear the main buffer
    ClearErrorBuffer();

    // Process the temporary buffer
    m_pContext->pLogger->LogInfo(StringFormat("Processing %d buffered error(s)...", tempCount), __FUNCTION__);

    for (int i = 0; i < tempCount; i++)
    {
        SErrorInfo& error = tempBuffer[i];
        string full_message = StringFormat("BUFFERED: Code[%d] Type[%s]: %s",
            error.error_code,
            EnumToString(error.error_type),
            error.message);
        m_pContext->pLogger->LogError(full_message, error.function_name);
    }
}

} // namespace ApexPullback

#endif // ERRORHANDLER_MQH_