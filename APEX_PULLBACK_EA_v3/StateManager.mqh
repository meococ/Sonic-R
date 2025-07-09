#ifndef STATEMANAGER_MQH_
#define STATEMANAGER_MQH_

#include "CommonStructs.mqh"

namespace ApexPullback {

class CStateManager 
{
private:
    EAContext* m_pContext;
    bool       m_IsInitialized;

public:
    CStateManager() : m_pContext(NULL), m_IsInitialized(false) {}
    ~CStateManager() {}

    bool Initialize(EAContext* pContext);
    bool IsInitialized() const { return m_IsInitialized; }

    void SetState(ENUM_EA_STATE newState, const string reason = "") 
    {
        if (!m_IsInitialized || !m_pContext) return;

        if (m_pContext->State != newState) 
        {
            if (m_pContext->pLogger) 
            {
                string message = "State changed from " + EnumToString(m_pContext->State) + 
                                 " to " + EnumToString(newState) + 
                                 (reason != "" ? ". Reason: " + reason : "");
                m_pContext->pLogger->Log(LOG_INFO, message);
            }
            m_pContext->State = newState;
            
            // TODO: Potentially update dashboard or other UI elements here
            // if(m_pContext->pDashboard) m_pContext->pDashboard->UpdateState(newState);
        }
    }

    ENUM_EA_STATE GetState() const 
    {
        if (!m_IsInitialized || !m_pContext) return EA_STATE_UNINITIALIZED;
        return m_pContext->State;
    }
};

//+------------------------------------------------------------------+
//| Initializes the State Manager                                    |
//+------------------------------------------------------------------+
bool CStateManager::Initialize(EAContext* pContext)
{
    m_pContext = pContext;
    if (m_pContext == NULL)
    {
        Print("FATAL: CStateManager received a NULL context during initialization.");
        return false;
    }

    // Set the initial state directly in the context
    m_pContext->State = EA_STATE_INITIALIZING;
    if (m_pContext->pLogger) m_pContext->pLogger->Log(LOG_INFO, "StateManager initialized. EA state is INITIALIZING.");

    m_IsInitialized = true;
    return true;
};

} // namespace ApexPullback

#endif // STATEMANAGER_MQH_