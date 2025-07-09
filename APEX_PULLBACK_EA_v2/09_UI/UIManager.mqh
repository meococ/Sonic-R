//+------------------------------------------------------------------+
//|                                                   UIManager.mqh |
//|                     APEX Pullback EA v5 FINAL - UI Manager      |
//|      Description: User interface management system with         |
//|                   dashboard, alerts, and notifications.         |
//+------------------------------------------------------------------+

#ifndef UI_MANAGER_MQH
#define UI_MANAGER_MQH

#include "..\00_Core\Common\CommonStructs.mqh"
#include "..\00_Core\Common\Enums.mqh"

//+------------------------------------------------------------------+
//| UI Manager Class                                                 |
//+------------------------------------------------------------------+
class CUIManager {
private:
    // Core references
    EAContext*                    m_pContext;
    bool                         m_bInitialized;
    
    // UI state
    bool                         m_ShowDashboard;
    bool                         m_ShowAlerts;
    bool                         m_ShowNotifications;
    
public:
    // Constructor and destructor
                                 CUIManager();
                                ~CUIManager();
    
    // Initialization and cleanup
    bool                         Initialize(EAContext* context);
    void                         Cleanup();
    
    // Core UI methods
    void                         Update();
    void                         OnChartEvent(const int id, const long& lparam, 
                                            const double& dparam, const string& sparam);
    
    // UI control
    void                         ShowDashboard(bool show) { m_ShowDashboard = show; }
    void                         ShowAlerts(bool show) { m_ShowAlerts = show; }
    void                         ShowNotifications(bool show) { m_ShowNotifications = show; }
    
    // Configuration
    bool                         UpdateConfiguration(EAContext* context);
    void                         RunDiagnostics();
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CUIManager::CUIManager() {
    m_pContext = NULL;
    m_bInitialized = false;
    m_ShowDashboard = true;
    m_ShowAlerts = true;
    m_ShowNotifications = true;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CUIManager::~CUIManager() {
    Cleanup();
}

//+------------------------------------------------------------------+
//| Initialize UI Manager                                            |
//+------------------------------------------------------------------+
bool CUIManager::Initialize(EAContext* context) {
    if (context == NULL) {
        Print("[UI] ERROR: Invalid context provided");
        return false;
    }
    
    m_pContext = context;
    m_ShowDashboard = context.InputParams.ShowDashboard;
    
    m_bInitialized = true;
    Print("[UI] UI Manager initialized successfully");
    return true;
}

//+------------------------------------------------------------------+
//| Cleanup                                                          |
//+------------------------------------------------------------------+
void CUIManager::Cleanup() {
    if (m_bInitialized) {
        Print("[UI] UI Manager cleaned up");
        m_bInitialized = false;
    }
}

//+------------------------------------------------------------------+
//| Update UI                                                        |
//+------------------------------------------------------------------+
void CUIManager::Update() {
    if (!m_bInitialized) return;
    
    // Update UI components
    // Implementation would update dashboard, alerts, etc.
}

//+------------------------------------------------------------------+
//| Handle Chart Events                                              |
//+------------------------------------------------------------------+
void CUIManager::OnChartEvent(const int id, const long& lparam, 
                             const double& dparam, const string& sparam) {
    if (!m_bInitialized) return;
    
    // Handle UI interactions
    // Implementation would process button clicks, etc.
}

//+------------------------------------------------------------------+
//| Update Configuration                                             |
//+------------------------------------------------------------------+
bool CUIManager::UpdateConfiguration(EAContext* context) {
    if (context == NULL) return false;
    
    m_ShowDashboard = context.InputParams.ShowDashboard;
    
    return true;
}

//+------------------------------------------------------------------+
//| Run Diagnostics                                                  |
//+------------------------------------------------------------------+
void CUIManager::RunDiagnostics() {
    Print("=== UI MANAGER DIAGNOSTICS ===");
    Print("Initialized: ", m_bInitialized ? "YES" : "NO");
    Print("Show Dashboard: ", m_ShowDashboard ? "YES" : "NO");
    Print("Show Alerts: ", m_ShowAlerts ? "YES" : "NO");
    Print("Show Notifications: ", m_ShowNotifications ? "YES" : "NO");
    Print("==============================");
}

#endif // UI_MANAGER_MQH 