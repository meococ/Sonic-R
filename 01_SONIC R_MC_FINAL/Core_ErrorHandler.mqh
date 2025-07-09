//+------------------------------------------------------------------+
//|                                    Core_ErrorHandler.mqh        |
//|                  APEX Pullback EA v4.6 - Error Handler          |
//|                              Đại Bàng - Clean Version           |
//+------------------------------------------------------------------+
#ifndef CORE_ERRORHANDLER_MQH
#define CORE_ERRORHANDLER_MQH

#include "SonicR_CommonStructs.mqh"

namespace ApexSonicR {

class CErrorHandler 
{
private:
    bool                m_initialized;
    int                 m_errorCount;
    int                 m_lastErrorCode;
    datetime            m_lastErrorTime;
    string              m_lastErrorMessage;
    int                 m_consecutiveErrors;
    bool                m_emergencyStop;

public:
    CErrorHandler() : 
        m_initialized(false),
        m_errorCount(0),
        m_lastErrorCode(0),
        m_lastErrorTime(0),
        m_lastErrorMessage(""),
        m_consecutiveErrors(0),
        m_emergencyStop(false)
    {
    }
    
    ~CErrorHandler() {}

    // Khởi tạo và Dọn dẹp
    bool Initialize() {
        m_initialized = true;
        Print("ErrorHandler initialized");
        return true;
    }
    
    void Deinitialize() {
        m_initialized = false;
        Print("ErrorHandler deinitialized");
    }
    
    bool IsInitialized() const { return m_initialized; }
    void OnTick() {}
    
    // Basic error handling
    void HandleError(string function, string message, int severity = 0) {
        if (!m_initialized) return;
        
        m_errorCount++;
        m_consecutiveErrors++;
        m_lastErrorTime = TimeCurrent();
        m_lastErrorCode = GetLastError();
        m_lastErrorMessage = message;
        
        // Log error
        Print("ERROR in ", function, ": ", message);
        
        // Check for emergency stop
        if (m_consecutiveErrors > 10) {
            m_emergencyStop = true;
            Print("EMERGENCY STOP activated due to consecutive errors");
        }
        
        ResetLastError();
    }
    
    // Status methods
    int GetErrorCount() const { return m_errorCount; }
    int GetConsecutiveErrors() const { return m_consecutiveErrors; }
    bool IsEmergencyStop() const { return m_emergencyStop; }
    
    void ResetConsecutiveErrors() { m_consecutiveErrors = 0; }
    void ResetEmergencyStop() { m_emergencyStop = false; }
};

} // END NAMESPACE ApexSonicR

#endif // CORE_ERRORHANDLER_MQH
