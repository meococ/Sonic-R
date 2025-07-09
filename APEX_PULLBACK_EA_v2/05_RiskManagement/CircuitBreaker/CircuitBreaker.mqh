//+------------------------------------------------------------------+
//|                                            CircuitBreaker.mqh   |
//|                        APEX Pullback EA v5 FINAL                |
//|      Description: Circuit Breaker for Emergency Risk Control    |
//+------------------------------------------------------------------+

#ifndef CIRCUIT_BREAKER_MQH_
#define CIRCUIT_BREAKER_MQH_

#include "../../00_Core/CommonStructs.mqh"

// MQL5 does not support nested namespaces with :: syntax
// namespace ApexPullback::v5 {

//+------------------------------------------------------------------+
//| Circuit Breaker Class                                            |
//+------------------------------------------------------------------+
class CCircuitBreaker {
private:
    EAContext* m_pContext;
    bool m_bInitialized;
    bool m_bTriggered;
    datetime m_LastTriggerTime;
    string m_sTriggerReason;
    
public:
    // Constructor & Destructor
    CCircuitBreaker();
    ~CCircuitBreaker();
    
    // Initialization
    bool Initialize(EAContext* context);
    void Deinitialize();
    
    // Core Methods
    bool IsTriggered() const { return m_bTriggered; }
    bool ShouldTrigger();
    void Trigger(const string& reason);
    void Reset();
    
    // Market Monitoring
    void MonitorMarketConditions();
    bool IsTradingAllowed();
    
    // Status
    string GetTriggerReason() const { return m_sTriggerReason; }
    datetime GetLastTriggerTime() const { return m_LastTriggerTime; }
    bool IsInitialized() const { return m_bInitialized; }
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CCircuitBreaker::CCircuitBreaker() {
    m_pContext = NULL;
    m_bInitialized = false;
    m_bTriggered = false;
    m_LastTriggerTime = 0;
    m_sTriggerReason = "";
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CCircuitBreaker::~CCircuitBreaker() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CCircuitBreaker::Initialize(EAContext* context) {
    if (context == NULL) {
        return false;
    }
    
    m_pContext = context;
    m_bInitialized = true;
    m_bTriggered = false;
    m_LastTriggerTime = 0;
    m_sTriggerReason = "";
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CCircuitBreaker::Deinitialize() {
    m_pContext = NULL;
    m_bInitialized = false;
}

//+------------------------------------------------------------------+
//| Should Trigger - Check if circuit breaker should activate       |
//+------------------------------------------------------------------+
bool CCircuitBreaker::ShouldTrigger() {
    if (!m_bInitialized || m_pContext == NULL) {
        return false;
    }
    
    // Basic safety checks
    // TODO: Implement comprehensive trigger conditions
    
    return false;
}

//+------------------------------------------------------------------+
//| Trigger - Activate circuit breaker                              |
//+------------------------------------------------------------------+
void CCircuitBreaker::Trigger(const string& reason) {
    m_bTriggered = true;
    m_LastTriggerTime = TimeCurrent();
    m_sTriggerReason = reason;
    
    Print("[CIRCUIT BREAKER] TRIGGERED: ", reason);
}

//+------------------------------------------------------------------+
//| Reset - Reset circuit breaker                                   |
//+------------------------------------------------------------------+
void CCircuitBreaker::Reset() {
    m_bTriggered = false;
    m_sTriggerReason = "";
    
    Print("[CIRCUIT BREAKER] Reset");
}

//+------------------------------------------------------------------+
//| Monitor Market Conditions                                       |
//+------------------------------------------------------------------+
void CCircuitBreaker::MonitorMarketConditions() {
    if (!m_bInitialized || m_pContext == NULL) {
        return;
    }
    
    // Check if circuit breaker should trigger
    if (ShouldTrigger()) {
        Trigger("Market conditions unsafe");
    }
}

//+------------------------------------------------------------------+
//| Is Trading Allowed                                              |
//+------------------------------------------------------------------+
bool CCircuitBreaker::IsTradingAllowed() {
    if (!m_bInitialized) {
        return false;
    }
    
    // If circuit breaker is triggered, trading is not allowed
    return !m_bTriggered;
}

// } // namespace ApexPullback::v5

#endif // CIRCUIT_BREAKER_MQH_