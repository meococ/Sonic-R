#ifndef CORE_TIMEMANAGER_MQH
#define CORE_TIMEMANAGER_MQH

#include "Core_Defines.mqh"

namespace ApexSonicR {

class CTimeManager 
{
private:
    bool                m_initialized;
    bool                m_isNewBar;
    datetime            m_lastBarTime;
    MqlDateTime         m_currentTime;

public:
    CTimeManager() : 
        m_initialized(false),
        m_isNewBar(false),
        m_lastBarTime(0)
    {
        ZeroMemory(m_currentTime);
    }
    
    ~CTimeManager() {}

    bool Initialize() {
        m_initialized = true;
        m_lastBarTime = iTime(Symbol(), PERIOD_CURRENT, 0);
        TimeToStruct(TimeCurrent(), m_currentTime);
        return true;
    }
    
    void Deinitialize() {
        m_initialized = false;
    }
    
    bool IsInitialized() const { return m_initialized; }
    
    void OnTick() {
        if (!m_initialized) return;
        
        // Update current time
        TimeToStruct(TimeCurrent(), m_currentTime);
        
        // Check for new bar
        datetime currentBarTime = iTime(Symbol(), PERIOD_CURRENT, 0);
        m_isNewBar = (currentBarTime > m_lastBarTime);
        if (m_isNewBar) {
            m_lastBarTime = currentBarTime;
        }
    }
    
    // Getters
    bool IsNewBar() const { return m_isNewBar; }
    datetime GetCurrentTime() const { return TimeCurrent(); }
    int GetCurrentHour() const { return m_currentTime.hour; }
    int GetCurrentMinute() const { return m_currentTime.min; }
    int GetCurrentDay() const { return m_currentTime.day; }
    int GetCurrentMonth() const { return m_currentTime.mon; }
    int GetCurrentYear() const { return m_currentTime.year; }
    
    // Session checks
    bool IsTradeAllowed() const { return true; } // Placeholder
    bool IsWithinTradingHours() const { return true; } // Placeholder
};

} // namespace ApexSonicR

#endif // CORE_TIMEMANAGER_MQH