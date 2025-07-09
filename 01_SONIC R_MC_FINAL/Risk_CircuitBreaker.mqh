//+------------------------------------------------------------------+
//|                  Risk_CircuitBreaker.mqh - MVP STUB              |
//|                  APEX Pullback EA v4.6 - Flat Architecture       |
//|      "Namespace removed for global scope compatibility"          |
//+------------------------------------------------------------------+

#ifndef RISK_CIRCUITBREAKER_MQH
#define RISK_CIRCUITBREAKER_MQH

#include "Core_Defines.mqh"
#include "Core_Context.mqh"

// Namespace has been removed.

//+------------------------------------------------------------------+
//| CCircuitBreaker - Minimal Working Implementation                 |
//+------------------------------------------------------------------+
class CCircuitBreaker
{
private:
    bool                m_initialized;
    CEaContext*         m_pContext; // Pointer to the global EA context
    bool               m_tradingEnabled;
    double             m_dailyLossLimit;
    double             m_dailyStartBalance;
    
public:
    CCircuitBreaker() : m_initialized(false), m_pContext(NULL), 
                        m_tradingEnabled(true), m_dailyLossLimit(0), 
                        m_dailyStartBalance(0) {}
    
    ~CCircuitBreaker() {}
    
    bool Initialize(CEaContext* pContext)
    {
        m_pContext = pContext;
        if(!m_pContext || !m_pContext->pLogger)
        {
            // Cannot log if context or logger is invalid
            return false;
        }
        m_tradingEnabled = true;
        m_dailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
        m_dailyLossLimit = m_dailyStartBalance * 0.05; // 5% daily loss limit
        m_initialized = true;
        
        if(m_pContext->pLogger) m_pContext->pLogger->LogInfo("Circuit Breaker initialized - Trading enabled");
        return true;
    }
    
    void PostInitialize()
    {
        if(!m_initialized) return;
        
        m_dailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
        if(m_pContext->pLogger) m_pContext->pLogger->LogInfo("Circuit Breaker post-initialization completed");
    }
    
    bool IsTradingAllowed()
    {
        if(!m_initialized) return false;
        
        // Basic daily loss check
        double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
        double dailyLoss = m_dailyStartBalance - currentBalance;
        
        if(dailyLoss > m_dailyLossLimit)
        {
            m_tradingEnabled = false;
            string msg = StringFormat("Circuit Breaker TRIGGERED: Daily loss %.2f exceeds limit %.2f", 
                                    dailyLoss, m_dailyLossLimit);
            if(m_pContext->pLogger) m_pContext->pLogger->LogWarning(msg, __FUNCTION__);
            return false;
        }
        
        return m_tradingEnabled;
    }
    
    bool ValidateTradeRequest(const STradeRequest& request)
    {
        if(!m_initialized) return false;
        if(!IsTradingAllowed()) return false;
        
        // Basic validation
        if(request.Volume <= 0)
        {
            if(m_pContext->pLogger) m_pContext->pLogger->LogWarning("Invalid volume", __FUNCTION__);
            return false;
        }
        
        return true;
    }
    
    void OnNewDay()
    {
        if(!m_initialized) return;
        
        m_dailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
        m_tradingEnabled = true;
        if(m_pContext->pLogger) m_pContext->pLogger->LogInfo("New day reset completed");
    }
    
    void EnableTrading() { m_tradingEnabled = true; }
    void DisableTrading() { m_tradingEnabled = false; }
    bool IsInitialized() const { return m_initialized; }
    bool IsTripped() const { return !m_tradingEnabled; }
    void OnTick() { /* Stub - basic monitoring */ }
};

// End of namespace removal

#endif
