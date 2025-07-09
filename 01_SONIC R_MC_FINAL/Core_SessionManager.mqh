//+------------------------------------------------------------------+
//|                                Core_SessionManager.mqh          |
//|                  APEX Pullback EA v4.6 - Session Manager        |
//|                              Đại Bàng - Clean Version           |
//+------------------------------------------------------------------+
#ifndef CORE_SESSIONMANAGER_MQH
#define CORE_SESSIONMANAGER_MQH

#include "SonicR_CommonStructs.mqh"
#include "Core_Context.mqh"

namespace ApexSonicR {

class CSessionManager 
{
private:
    bool                m_initialized;
    MqlDateTime         m_currentTime;
    bool                m_isLondonSession;
    bool                m_isNewYorkSession;
    bool                m_isTokyoSession;
    bool                m_isAsianSession;

public:
    CSessionManager() : 
        m_initialized(false),
        m_isLondonSession(false),
        m_isNewYorkSession(false),
        m_isTokyoSession(false),
        m_isAsianSession(false)
    {
        ZeroMemory(m_currentTime);
    }
    
    ~CSessionManager() {}

    bool Initialize() {
        m_initialized = true;
        UpdateSessions();
        return true;
    }
    
    void Deinitialize() {
        m_initialized = false;
    }
    
    bool IsInitialized() const { return m_initialized; }
    
    void OnTick() {
        if (!m_initialized) return;
        UpdateSessions();
    }
    
    // Session getters
    bool IsLondonSession() const { return m_isLondonSession; }
    bool IsNewYorkSession() const { return m_isNewYorkSession; }
    bool IsTokyoSession() const { return m_isTokyoSession; }
    bool IsAsianSession() const { return m_isAsianSession; }
    
    // Trading session checks
    bool IsTradeAllowed() const {
        return m_isLondonSession || m_isNewYorkSession || m_isTokyoSession;
    }
    
    bool IsHighVolatilitySession() const {
        return m_isLondonSession || m_isNewYorkSession;
    }

private:
    void UpdateSessions() {
        TimeToStruct(TimeCurrent(), m_currentTime);
        int hour = m_currentTime.hour;
        
        // London Session: 08:00 - 17:00 GMT
        m_isLondonSession = (hour >= 8 && hour <= 17);
        
        // New York Session: 13:00 - 22:00 GMT  
        m_isNewYorkSession = (hour >= 13 && hour <= 22);
        
        // Tokyo Session: 23:00 - 08:00 GMT
        m_isTokyoSession = (hour >= 23 || hour <= 8);
        
        // Asian Session: 00:00 - 09:00 GMT
        m_isAsianSession = (hour >= 0 && hour <= 9);
    }
};

} // namespace ApexSonicR

#endif // CORE_SESSIONMANAGER_MQH

