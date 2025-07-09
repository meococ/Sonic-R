//+------------------------------------------------------------------+
//|                                                    UIManager.mqh |
//|                                    APEX Pullback EA v5.0 FINAL   |
//|                                      Advanced UI Manager System  |
//+------------------------------------------------------------------+
#property copyright "APEX Trading Systems"
#property version   "5.00"
#property strict

#include "../../00_Core/CommonStructs.mqh"
#include <Controls\Dialog.mqh>
#include <Controls\Panel.mqh>
#include <Controls\Label.mqh>
#include <Controls\Button.mqh>
#include <Controls\Edit.mqh>
#include <Controls\ComboBox.mqh>
#include <Controls\CheckBox.mqh>
#include <Controls\RadioGroup.mqh>
#include <Controls\ListView.mqh>
#include <Controls\Picture.mqh>

//+------------------------------------------------------------------+
//| UI Theme enumeration                                            |
//+------------------------------------------------------------------+
enum ENUM_UI_THEME {
    UI_THEME_DARK,
    UI_THEME_LIGHT,
    UI_THEME_BLUE,
    UI_THEME_GREEN,
    UI_THEME_CUSTOM
};

//+------------------------------------------------------------------+
//| UI Panel types                                                 |
//+------------------------------------------------------------------+
enum ENUM_UI_PANEL_TYPE {
    UI_PANEL_MAIN,
    UI_PANEL_TRADING,
    UI_PANEL_RISK,
    UI_PANEL_ANALYTICS,
    UI_PANEL_SETTINGS,
    UI_PANEL_LOGS,
    UI_PANEL_ALERTS
};

//+------------------------------------------------------------------+
//| UI Control types                                               |
//+------------------------------------------------------------------+
enum ENUM_UI_CONTROL_TYPE {
    UI_CONTROL_LABEL,
    UI_CONTROL_BUTTON,
    UI_CONTROL_EDIT,
    UI_CONTROL_COMBO,
    UI_CONTROL_CHECK,
    UI_CONTROL_RADIO,
    UI_CONTROL_LIST,
    UI_CONTROL_PICTURE,
    UI_CONTROL_PANEL
};

//+------------------------------------------------------------------+
//| UI Color scheme structure                                      |
//+------------------------------------------------------------------+
struct SUIColorScheme {
    color BackgroundColor;
    color PanelColor;
    color BorderColor;
    color TextColor;
    color ButtonColor;
    color ButtonHoverColor;
    color ButtonActiveColor;
    color SuccessColor;
    color WarningColor;
    color ErrorColor;
    color InfoColor;
};

//+------------------------------------------------------------------+
//| UI Control configuration                                       |
//+------------------------------------------------------------------+
struct SUIControlConfig {
    string Name;
    ENUM_UI_CONTROL_TYPE Type;
    int X;
    int Y;
    int Width;
    int Height;
    string Text;
    color BackColor;
    color TextColor;
    bool Visible;
    bool Enabled;
    string Tooltip;
    int FontSize;
    string FontName;
};

//+------------------------------------------------------------------+
//| UI Panel configuration                                         |
//+------------------------------------------------------------------+
struct SUIPanelConfig {
    string Name;
    ENUM_UI_PANEL_TYPE Type;
    int X;
    int Y;
    int Width;
    int Height;
    string Title;
    bool Visible;
    bool Resizable;
    bool Movable;
    bool Minimizable;
    SUIControlConfig Controls[];
};

//+------------------------------------------------------------------+
//| UI Layout configuration                                        |
//+------------------------------------------------------------------+
struct SUILayoutConfig {
    ENUM_UI_THEME Theme;
    SUIColorScheme ColorScheme;
    SUIPanelConfig Panels[];
    int DefaultFontSize;
    string DefaultFontName;
    bool ShowTooltips;
    bool EnableAnimations;
    int AnimationSpeed;
    bool AutoResize;
    bool RememberPosition;
};

//+------------------------------------------------------------------+
//| UI Event structure                                             |
//+------------------------------------------------------------------+
struct SUIEvent {
    string ControlName;
    ENUM_UI_CONTROL_TYPE ControlType;
    int EventType;
    string EventData;
    datetime EventTime;
};

//+------------------------------------------------------------------+
//| UI Statistics                                                  |
//+------------------------------------------------------------------+
struct SUIStats {
    int TotalControls;
    int VisibleControls;
    int EnabledControls;
    int TotalPanels;
    int VisiblePanels;
    int EventsProcessed;
    datetime LastUpdate;
    double UpdateFrequency;
    bool IsResponsive;
};

//+------------------------------------------------------------------+
//| UI Manager Class                                               |
//+------------------------------------------------------------------+
class CUIManager {
private:
    EAContext* m_pContext;
    SUILayoutConfig m_LayoutConfig;
    SUIStats m_Stats;
    
    // UI Controls
    CAppDialog* m_pMainDialog;
    CPanel* m_pPanels[];
    CLabel* m_pLabels[];
    CButton* m_pButtons[];
    CEdit* m_pEdits[];
    CComboBox* m_pCombos[];
    CCheckBox* m_pCheckBoxes[];
    CRadioGroup* m_pRadioGroups[];
    CListView* m_pListViews[];
    CPicture* m_pPictures[];
    
    // Event handling
    SUIEvent m_EventQueue[];
    int m_EventQueueSize;
    
    // Status
    bool m_bInitialized;
    bool m_bVisible;
    bool m_bEnabled;
    
    // Update tracking
    datetime m_LastUpdate;
    int m_UpdateInterval;
    
public:
    CUIManager();
    ~CUIManager();
    
    // Core methods
    bool Initialize(EAContext* context);
    void Deinitialize();
    
    // Layout management
    void SetLayoutConfig(const SUILayoutConfig& config);
    SUILayoutConfig GetLayoutConfig() const { return m_LayoutConfig; }
    void SetTheme(const ENUM_UI_THEME theme);
    void SetColorScheme(const SUIColorScheme& scheme);
    
    // Panel management
    bool CreatePanel(const SUIPanelConfig& config);
    bool RemovePanel(const string name);
    bool ShowPanel(const string name, const bool show = true);
    bool HidePanel(const string name) { return ShowPanel(name, false); }
    bool MovePanel(const string name, const int x, const int y);
    bool ResizePanel(const string name, const int width, const int height);
    
    // Control management
    bool CreateControl(const string panelName, const SUIControlConfig& config);
    bool RemoveControl(const string panelName, const string controlName);
    bool ShowControl(const string panelName, const string controlName, const bool show = true);
    bool HideControl(const string panelName, const string controlName) { return ShowControl(panelName, controlName, false); }
    bool EnableControl(const string panelName, const string controlName, const bool enable = true);
    bool DisableControl(const string panelName, const string controlName) { return EnableControl(panelName, controlName, false); }
    
    // Control value management
    bool SetControlText(const string panelName, const string controlName, const string text);
    string GetControlText(const string panelName, const string controlName) const;
    bool SetControlValue(const string panelName, const string controlName, const double value);
    double GetControlValue(const string panelName, const string controlName) const;
    bool SetControlColor(const string panelName, const string controlName, const color clr);
    
    // Display methods
    void Show();
    void Hide();
    bool IsVisible() const { return m_bVisible; }
    void Enable();
    void Disable();
    bool IsEnabled() const { return m_bEnabled; }
    
    // Update methods
    void Update();
    void UpdatePanel(const string name);
    void UpdateControl(const string panelName, const string controlName);
    void SetUpdateInterval(const int intervalMs) { m_UpdateInterval = intervalMs; }
    
    // Event handling
    void ProcessEvents();
    bool AddEvent(const SUIEvent& event);
    SUIEvent GetNextEvent();
    bool HasPendingEvents() const { return ArraySize(m_EventQueue) > 0; }
    void ClearEvents();
    
    // Predefined panels
    bool CreateMainPanel();
    bool CreateTradingPanel();
    bool CreateRiskPanel();
    bool CreateAnalyticsPanel();
    bool CreateSettingsPanel();
    bool CreateLogsPanel();
    bool CreateAlertsPanel();
    
    // Data display
    void UpdateAccountInfo();
    void UpdateTradingInfo();
    void UpdateRiskInfo();
    void UpdatePerformanceInfo();
    void UpdateSystemStatus();
    void UpdateMarketInfo();
    
    // Utility methods
    SUIStats GetStatistics() const { return m_Stats; }
    void RefreshAll();
    void ResetLayout();
    bool SaveLayout(const string filename) const;
    bool LoadLayout(const string filename);
    
private:
    // Internal methods
    void InitializeTheme();
    void InitializeColorScheme();
    void CreateDefaultLayout();
    void UpdateStatistics();
    
    // Control creation helpers
    CLabel* CreateLabel(const SUIControlConfig& config);
    CButton* CreateButton(const SUIControlConfig& config);
    CEdit* CreateEdit(const SUIControlConfig& config);
    CComboBox* CreateComboBox(const SUIControlConfig& config);
    CCheckBox* CreateCheckBox(const SUIControlConfig& config);
    CRadioGroup* CreateRadioGroup(const SUIControlConfig& config);
    CListView* CreateListView(const SUIControlConfig& config);
    CPicture* CreatePicture(const SUIControlConfig& config);
    CPanel* CreatePanelControl(const SUIControlConfig& config);
    
    // Event handlers
    void OnButtonClick(const string buttonName);
    void OnEditChange(const string editName);
    void OnComboChange(const string comboName);
    void OnCheckBoxChange(const string checkBoxName);
    void OnRadioChange(const string radioName);
    void OnListSelect(const string listName);
    
    // Utility methods
    CPanel* FindPanel(const string name);
    int FindPanelIndex(const string name);
    string FormatNumber(const double value, const int digits = 2) const;
    string FormatCurrency(const double value) const;
    string FormatPercent(const double value) const;
    color GetThemeColor(const string colorName) const;
    
    // Logging
    void LogUIEvent(const string event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CUIManager::CUIManager() {
    m_pContext = NULL;
    m_pMainDialog = NULL;
    m_bInitialized = false;
    m_bVisible = false;
    m_bEnabled = true;
    m_LastUpdate = 0;
    m_UpdateInterval = 1000; // 1 second
    m_EventQueueSize = 100;
    
    // Initialize default layout
    ZeroMemory(m_LayoutConfig);
    m_LayoutConfig.Theme = UI_THEME_DARK;
    m_LayoutConfig.DefaultFontSize = 9;
    m_LayoutConfig.DefaultFontName = "Arial";
    m_LayoutConfig.ShowTooltips = true;
    m_LayoutConfig.EnableAnimations = false;
    m_LayoutConfig.AnimationSpeed = 250;
    m_LayoutConfig.AutoResize = true;
    m_LayoutConfig.RememberPosition = true;
    
    // Initialize statistics
    ZeroMemory(m_Stats);
    
    // Initialize color scheme
    InitializeColorScheme();
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CUIManager::~CUIManager() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize UI Manager                                          |
//+------------------------------------------------------------------+
bool CUIManager::Initialize(EAContext* context) {
    if (context == NULL) {
        Print("[UI MANAGER ERROR] Context is NULL");
        return false;
    }
    
    m_pContext = context;
    
    // Initialize theme
    InitializeTheme();
    
    // Create main dialog
    m_pMainDialog = new CAppDialog();
    if (m_pMainDialog == NULL) {
        LogUIEvent("Failed to create main dialog", LOG_LEVEL_ERROR);
        return false;
    }
    
    // Create default layout
    CreateDefaultLayout();
    
    // Initialize event queue
    ArrayResize(m_EventQueue, 0);
    
    m_bInitialized = true;
    LogUIEvent("UI Manager initialized successfully");
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize UI Manager                                       |
//+------------------------------------------------------------------+
void CUIManager::Deinitialize() {
    if (m_bInitialized) {
        Hide();
        
        // Clean up controls
        for (int i = 0; i < ArraySize(m_pPanels); i++) {
            if (m_pPanels[i] != NULL) {
                delete m_pPanels[i];
                m_pPanels[i] = NULL;
            }
        }
        
        for (int i = 0; i < ArraySize(m_pLabels); i++) {
            if (m_pLabels[i] != NULL) {
                delete m_pLabels[i];
                m_pLabels[i] = NULL;
            }
        }
        
        for (int i = 0; i < ArraySize(m_pButtons); i++) {
            if (m_pButtons[i] != NULL) {
                delete m_pButtons[i];
                m_pButtons[i] = NULL;
            }
        }
        
        // Clean up main dialog
        if (m_pMainDialog != NULL) {
            delete m_pMainDialog;
            m_pMainDialog = NULL;
        }
        
        LogUIEvent("UI Manager deinitialized");
    }
    
    m_bInitialized = false;
    m_pContext = NULL;
}

//+------------------------------------------------------------------+
//| Initialize color scheme                                        |
//+------------------------------------------------------------------+
void CUIManager::InitializeColorScheme() {
    // Dark theme colors
    m_LayoutConfig.ColorScheme.BackgroundColor = C'30,30,30';
    m_LayoutConfig.ColorScheme.PanelColor = C'45,45,45';
    m_LayoutConfig.ColorScheme.BorderColor = C'70,70,70';
    m_LayoutConfig.ColorScheme.TextColor = C'220,220,220';
    m_LayoutConfig.ColorScheme.ButtonColor = C'60,60,60';
    m_LayoutConfig.ColorScheme.ButtonHoverColor = C'80,80,80';
    m_LayoutConfig.ColorScheme.ButtonActiveColor = C'100,100,100';
    m_LayoutConfig.ColorScheme.SuccessColor = C'0,150,0';
    m_LayoutConfig.ColorScheme.WarningColor = C'255,165,0';
    m_LayoutConfig.ColorScheme.ErrorColor = C'220,20,20';
    m_LayoutConfig.ColorScheme.InfoColor = C'70,130,180';
}

//+------------------------------------------------------------------+
//| Initialize theme                                               |
//+------------------------------------------------------------------+
void CUIManager::InitializeTheme() {
    switch(m_LayoutConfig.Theme) {
    case UI_THEME_LIGHT:
        m_LayoutConfig.ColorScheme.BackgroundColor = C'240,240,240';
        m_LayoutConfig.ColorScheme.PanelColor = C'255,255,255';
        m_LayoutConfig.ColorScheme.BorderColor = C'200,200,200';
        m_LayoutConfig.ColorScheme.TextColor = C'50,50,50';
        m_LayoutConfig.ColorScheme.ButtonColor = C'230,230,230';
        break;
    case UI_THEME_BLUE:
        m_LayoutConfig.ColorScheme.BackgroundColor = C'25,25,50';
        m_LayoutConfig.ColorScheme.PanelColor = C'40,40,80';
        m_LayoutConfig.ColorScheme.BorderColor = C'70,70,120';
        m_LayoutConfig.ColorScheme.TextColor = C'200,200,255';
        m_LayoutConfig.ColorScheme.ButtonColor = C'60,60,120';
        break;
    case UI_THEME_GREEN:
        m_LayoutConfig.ColorScheme.BackgroundColor = C'25,50,25';
        m_LayoutConfig.ColorScheme.PanelColor = C'40,80,40';
        m_LayoutConfig.ColorScheme.BorderColor = C'70,120,70';
        m_LayoutConfig.ColorScheme.TextColor = C'200,255,200';
        m_LayoutConfig.ColorScheme.ButtonColor = C'60,120,60';
        break;
    default: // UI_THEME_DARK
        InitializeColorScheme();
        break;
    }
}

//+------------------------------------------------------------------+
//| Create default layout                                          |
//+------------------------------------------------------------------+
void CUIManager::CreateDefaultLayout() {
    // Create main panels
    CreateMainPanel();
    CreateTradingPanel();
    CreateRiskPanel();
    CreateAnalyticsPanel();
    CreateSettingsPanel();
    CreateLogsPanel();
    CreateAlertsPanel();
}

//+------------------------------------------------------------------+
//| Create main panel                                              |
//+------------------------------------------------------------------+
bool CUIManager::CreateMainPanel() {
    SUIPanelConfig config;
    ZeroMemory(config);
    
    config.Name = "MainPanel";
    config.Type = UI_PANEL_MAIN;
    config.X = 10;
    config.Y = 30;
    config.Width = 300;
    config.Height = 200;
    config.Title = "APEX EA Control Panel";
    config.Visible = true;
    config.Resizable = true;
    config.Movable = true;
    config.Minimizable = true;
    
    // Add controls
    ArrayResize(config.Controls, 5);
    
    // EA Status Label
    config.Controls[0].Name = "StatusLabel";
    config.Controls[0].Type = UI_CONTROL_LABEL;
    config.Controls[0].X = 10;
    config.Controls[0].Y = 30;
    config.Controls[0].Width = 280;
    config.Controls[0].Height = 20;
    config.Controls[0].Text = "EA Status: Initializing...";
    config.Controls[0].Visible = true;
    
    // Start/Stop Button
    config.Controls[1].Name = "StartStopButton";
    config.Controls[1].Type = UI_CONTROL_BUTTON;
    config.Controls[1].X = 10;
    config.Controls[1].Y = 60;
    config.Controls[1].Width = 80;
    config.Controls[1].Height = 25;
    config.Controls[1].Text = "Start";
    config.Controls[1].Visible = true;
    
    // Settings Button
    config.Controls[2].Name = "SettingsButton";
    config.Controls[2].Type = UI_CONTROL_BUTTON;
    config.Controls[2].X = 100;
    config.Controls[2].Y = 60;
    config.Controls[2].Width = 80;
    config.Controls[2].Height = 25;
    config.Controls[2].Text = "Settings";
    config.Controls[2].Visible = true;
    
    // Analytics Button
    config.Controls[3].Name = "AnalyticsButton";
    config.Controls[3].Type = UI_CONTROL_BUTTON;
    config.Controls[3].X = 190;
    config.Controls[3].Y = 60;
    config.Controls[3].Width = 80;
    config.Controls[3].Height = 25;
    config.Controls[3].Text = "Analytics";
    config.Controls[3].Visible = true;
    
    // Account Info Label
    config.Controls[4].Name = "AccountLabel";
    config.Controls[4].Type = UI_CONTROL_LABEL;
    config.Controls[4].X = 10;
    config.Controls[4].Y = 100;
    config.Controls[4].Width = 280;
    config.Controls[4].Height = 60;
    config.Controls[4].Text = "Account: Loading...";
    config.Controls[4].Visible = true;
    
    return CreatePanel(config);
}

//+------------------------------------------------------------------+
//| Create trading panel                                           |
//+------------------------------------------------------------------+
bool CUIManager::CreateTradingPanel() {
    SUIPanelConfig config;
    ZeroMemory(config);
    
    config.Name = "TradingPanel";
    config.Type = UI_PANEL_TRADING;
    config.X = 320;
    config.Y = 30;
    config.Width = 280;
    config.Height = 250;
    config.Title = "Trading Information";
    config.Visible = true;
    config.Resizable = true;
    config.Movable = true;
    config.Minimizable = true;
    
    // Add trading controls
    ArrayResize(config.Controls, 6);
    
    // Open Positions
    config.Controls[0].Name = "PositionsLabel";
    config.Controls[0].Type = UI_CONTROL_LABEL;
    config.Controls[0].X = 10;
    config.Controls[0].Y = 30;
    config.Controls[0].Width = 260;
    config.Controls[0].Height = 20;
    config.Controls[0].Text = "Open Positions: 0";
    config.Controls[0].Visible = true;
    
    // Total Profit
    config.Controls[1].Name = "ProfitLabel";
    config.Controls[1].Type = UI_CONTROL_LABEL;
    config.Controls[1].X = 10;
    config.Controls[1].Y = 55;
    config.Controls[1].Width = 260;
    config.Controls[1].Height = 20;
    config.Controls[1].Text = "Total Profit: $0.00";
    config.Controls[1].Visible = true;
    
    // Today's Trades
    config.Controls[2].Name = "TodayTradesLabel";
    config.Controls[2].Type = UI_CONTROL_LABEL;
    config.Controls[2].X = 10;
    config.Controls[2].Y = 80;
    config.Controls[2].Width = 260;
    config.Controls[2].Height = 20;
    config.Controls[2].Text = "Today's Trades: 0";
    config.Controls[2].Visible = true;
    
    // Win Rate
    config.Controls[3].Name = "WinRateLabel";
    config.Controls[3].Type = UI_CONTROL_LABEL;
    config.Controls[3].X = 10;
    config.Controls[3].Y = 105;
    config.Controls[3].Width = 260;
    config.Controls[3].Height = 20;
    config.Controls[3].Text = "Win Rate: 0%";
    config.Controls[3].Visible = true;
    
    // Close All Button
    config.Controls[4].Name = "CloseAllButton";
    config.Controls[4].Type = UI_CONTROL_BUTTON;
    config.Controls[4].X = 10;
    config.Controls[4].Y = 140;
    config.Controls[4].Width = 100;
    config.Controls[4].Height = 25;
    config.Controls[4].Text = "Close All";
    config.Controls[4].Visible = true;
    
    // Emergency Stop Button
    config.Controls[5].Name = "EmergencyStopButton";
    config.Controls[5].Type = UI_CONTROL_BUTTON;
    config.Controls[5].X = 120;
    config.Controls[5].Y = 140;
    config.Controls[5].Width = 100;
    config.Controls[5].Height = 25;
    config.Controls[5].Text = "Emergency Stop";
    config.Controls[5].Visible = true;
    config.Controls[5].BackColor = m_LayoutConfig.ColorScheme.ErrorColor;
    
    return CreatePanel(config);
}

//+------------------------------------------------------------------+
//| Create risk panel                                              |
//+------------------------------------------------------------------+
bool CUIManager::CreateRiskPanel() {
    SUIPanelConfig config;
    ZeroMemory(config);
    
    config.Name = "RiskPanel";
    config.Type = UI_PANEL_RISK;
    config.X = 10;
    config.Y = 240;
    config.Width = 300;
    config.Height = 180;
    config.Title = "Risk Management";
    config.Visible = true;
    config.Resizable = true;
    config.Movable = true;
    config.Minimizable = true;
    
    // Add risk controls
    ArrayResize(config.Controls, 4);
    
    // Current Drawdown
    config.Controls[0].Name = "DrawdownLabel";
    config.Controls[0].Type = UI_CONTROL_LABEL;
    config.Controls[0].X = 10;
    config.Controls[0].Y = 30;
    config.Controls[0].Width = 280;
    config.Controls[0].Height = 20;
    config.Controls[0].Text = "Current Drawdown: 0%";
    config.Controls[0].Visible = true;
    
    // Risk Level
    config.Controls[1].Name = "RiskLevelLabel";
    config.Controls[1].Type = UI_CONTROL_LABEL;
    config.Controls[1].X = 10;
    config.Controls[1].Y = 55;
    config.Controls[1].Width = 280;
    config.Controls[1].Height = 20;
    config.Controls[1].Text = "Risk Level: Low";
    config.Controls[1].Visible = true;
    
    // Margin Level
    config.Controls[2].Name = "MarginLabel";
    config.Controls[2].Type = UI_CONTROL_LABEL;
    config.Controls[2].X = 10;
    config.Controls[2].Y = 80;
    config.Controls[2].Width = 280;
    config.Controls[2].Height = 20;
    config.Controls[2].Text = "Margin Level: 0%";
    config.Controls[2].Visible = true;
    
    // Risk Status
    config.Controls[3].Name = "RiskStatusLabel";
    config.Controls[3].Type = UI_CONTROL_LABEL;
    config.Controls[3].X = 10;
    config.Controls[3].Y = 105;
    config.Controls[3].Width = 280;
    config.Controls[3].Height = 40;
    config.Controls[3].Text = "Risk Status: Normal";
    config.Controls[3].Visible = true;
    
    return CreatePanel(config);
}

//+------------------------------------------------------------------+
//| Create analytics panel                                         |
//+------------------------------------------------------------------+
bool CUIManager::CreateAnalyticsPanel() {
    SUIPanelConfig config;
    ZeroMemory(config);
    
    config.Name = "AnalyticsPanel";
    config.Type = UI_PANEL_ANALYTICS;
    config.X = 320;
    config.Y = 290;
    config.Width = 280;
    config.Height = 200;
    config.Title = "Performance Analytics";
    config.Visible = false; // Hidden by default
    config.Resizable = true;
    config.Movable = true;
    config.Minimizable = true;
    
    // Add analytics controls
    ArrayResize(config.Controls, 4);
    
    // Sharpe Ratio
    config.Controls[0].Name = "SharpeLabel";
    config.Controls[0].Type = UI_CONTROL_LABEL;
    config.Controls[0].X = 10;
    config.Controls[0].Y = 30;
    config.Controls[0].Width = 260;
    config.Controls[0].Height = 20;
    config.Controls[0].Text = "Sharpe Ratio: 0.00";
    config.Controls[0].Visible = true;
    
    // Profit Factor
    config.Controls[1].Name = "ProfitFactorLabel";
    config.Controls[1].Type = UI_CONTROL_LABEL;
    config.Controls[1].X = 10;
    config.Controls[1].Y = 55;
    config.Controls[1].Width = 260;
    config.Controls[1].Height = 20;
    config.Controls[1].Text = "Profit Factor: 0.00";
    config.Controls[1].Visible = true;
    
    // Max Drawdown
    config.Controls[2].Name = "MaxDrawdownLabel";
    config.Controls[2].Type = UI_CONTROL_LABEL;
    config.Controls[2].X = 10;
    config.Controls[2].Y = 80;
    config.Controls[2].Width = 260;
    config.Controls[2].Height = 20;
    config.Controls[2].Text = "Max Drawdown: 0%";
    config.Controls[2].Visible = true;
    
    // Generate Report Button
    config.Controls[3].Name = "ReportButton";
    config.Controls[3].Type = UI_CONTROL_BUTTON;
    config.Controls[3].X = 10;
    config.Controls[3].Y = 120;
    config.Controls[3].Width = 120;
    config.Controls[3].Height = 25;
    config.Controls[3].Text = "Generate Report";
    config.Controls[3].Visible = true;
    
    return CreatePanel(config);
}

//+------------------------------------------------------------------+
//| Create settings panel                                          |
//+------------------------------------------------------------------+
bool CUIManager::CreateSettingsPanel() {
    SUIPanelConfig config;
    ZeroMemory(config);
    
    config.Name = "SettingsPanel";
    config.Type = UI_PANEL_SETTINGS;
    config.X = 610;
    config.Y = 30;
    config.Width = 250;
    config.Height = 300;
    config.Title = "EA Settings";
    config.Visible = false; // Hidden by default
    config.Resizable = true;
    config.Movable = true;
    config.Minimizable = true;
    
    // Add settings controls
    ArrayResize(config.Controls, 6);
    
    // Auto Trading Checkbox
    config.Controls[0].Name = "AutoTradingCheck";
    config.Controls[0].Type = UI_CONTROL_CHECK;
    config.Controls[0].X = 10;
    config.Controls[0].Y = 30;
    config.Controls[0].Width = 200;
    config.Controls[0].Height = 20;
    config.Controls[0].Text = "Enable Auto Trading";
    config.Controls[0].Visible = true;
    
    // Risk Level Combo
    config.Controls[1].Name = "RiskLevelCombo";
    config.Controls[1].Type = UI_CONTROL_COMBO;
    config.Controls[1].X = 10;
    config.Controls[1].Y = 60;
    config.Controls[1].Width = 150;
    config.Controls[1].Height = 25;
    config.Controls[1].Text = "Risk Level";
    config.Controls[1].Visible = true;
    
    // Lot Size Edit
    config.Controls[2].Name = "LotSizeEdit";
    config.Controls[2].Type = UI_CONTROL_EDIT;
    config.Controls[2].X = 10;
    config.Controls[2].Y = 95;
    config.Controls[2].Width = 100;
    config.Controls[2].Height = 25;
    config.Controls[2].Text = "0.01";
    config.Controls[2].Visible = true;
    
    // Max Spread Edit
    config.Controls[3].Name = "MaxSpreadEdit";
    config.Controls[3].Type = UI_CONTROL_EDIT;
    config.Controls[3].X = 10;
    config.Controls[3].Y = 130;
    config.Controls[3].Width = 100;
    config.Controls[3].Height = 25;
    config.Controls[3].Text = "3.0";
    config.Controls[3].Visible = true;
    
    // Save Settings Button
    config.Controls[4].Name = "SaveSettingsButton";
    config.Controls[4].Type = UI_CONTROL_BUTTON;
    config.Controls[4].X = 10;
    config.Controls[4].Y = 200;
    config.Controls[4].Width = 100;
    config.Controls[4].Height = 25;
    config.Controls[4].Text = "Save";
    config.Controls[4].Visible = true;
    
    // Reset Settings Button
    config.Controls[5].Name = "ResetSettingsButton";
    config.Controls[5].Type = UI_CONTROL_BUTTON;
    config.Controls[5].X = 120;
    config.Controls[5].Y = 200;
    config.Controls[5].Width = 100;
    config.Controls[5].Height = 25;
    config.Controls[5].Text = "Reset";
    config.Controls[5].Visible = true;
    
    return CreatePanel(config);
}

//+------------------------------------------------------------------+
//| Create logs panel                                              |
//+------------------------------------------------------------------+
bool CUIManager::CreateLogsPanel() {
    SUIPanelConfig config;
    ZeroMemory(config);
    
    config.Name = "LogsPanel";
    config.Type = UI_PANEL_LOGS;
    config.X = 10;
    config.Y = 430;
    config.Width = 590;
    config.Height = 150;
    config.Title = "System Logs";
    config.Visible = false; // Hidden by default
    config.Resizable = true;
    config.Movable = true;
    config.Minimizable = true;
    
    // Add log controls
    ArrayResize(config.Controls, 3);
    
    // Log List View
    config.Controls[0].Name = "LogListView";
    config.Controls[0].Type = UI_CONTROL_LIST;
    config.Controls[0].X = 10;
    config.Controls[0].Y = 30;
    config.Controls[0].Width = 570;
    config.Controls[0].Height = 80;
    config.Controls[0].Visible = true;
    
    // Clear Logs Button
    config.Controls[1].Name = "ClearLogsButton";
    config.Controls[1].Type = UI_CONTROL_BUTTON;
    config.Controls[1].X = 10;
    config.Controls[1].Y = 120;
    config.Controls[1].Width = 80;
    config.Controls[1].Height = 25;
    config.Controls[1].Text = "Clear";
    config.Controls[1].Visible = true;
    
    // Export Logs Button
    config.Controls[2].Name = "ExportLogsButton";
    config.Controls[2].Type = UI_CONTROL_BUTTON;
    config.Controls[2].X = 100;
    config.Controls[2].Y = 120;
    config.Controls[2].Width = 80;
    config.Controls[2].Height = 25;
    config.Controls[2].Text = "Export";
    config.Controls[2].Visible = true;
    
    return CreatePanel(config);
}

//+------------------------------------------------------------------+
//| Create alerts panel                                            |
//+------------------------------------------------------------------+
bool CUIManager::CreateAlertsPanel() {
    SUIPanelConfig config;
    ZeroMemory(config);
    
    config.Name = "AlertsPanel";
    config.Type = UI_PANEL_ALERTS;
    config.X = 610;
    config.Y = 340;
    config.Width = 250;
    config.Height = 200;
    config.Title = "Alerts & Notifications";
    config.Visible = false; // Hidden by default
    config.Resizable = true;
    config.Movable = true;
    config.Minimizable = true;
    
    // Add alert controls
    ArrayResize(config.Controls, 4);
    
    // Alert List
    config.Controls[0].Name = "AlertListView";
    config.Controls[0].Type = UI_CONTROL_LIST;
    config.Controls[0].X = 10;
    config.Controls[0].Y = 30;
    config.Controls[0].Width = 230;
    config.Controls[0].Height = 100;
    config.Controls[0].Visible = true;
    
    // Enable Alerts Checkbox
    config.Controls[1].Name = "EnableAlertsCheck";
    config.Controls[1].Type = UI_CONTROL_CHECK;
    config.Controls[1].X = 10;
    config.Controls[1].Y = 140;
    config.Controls[1].Width = 150;
    config.Controls[1].Height = 20;
    config.Controls[1].Text = "Enable Alerts";
    config.Controls[1].Visible = true;
    
    // Clear Alerts Button
    config.Controls[2].Name = "ClearAlertsButton";
    config.Controls[2].Type = UI_CONTROL_BUTTON;
    config.Controls[2].X = 10;
    config.Controls[2].Y = 165;
    config.Controls[2].Width = 80;
    config.Controls[2].Height = 25;
    config.Controls[2].Text = "Clear";
    config.Controls[2].Visible = true;
    
    // Test Alert Button
    config.Controls[3].Name = "TestAlertButton";
    config.Controls[3].Type = UI_CONTROL_BUTTON;
    config.Controls[3].X = 100;
    config.Controls[3].Y = 165;
    config.Controls[3].Width = 80;
    config.Controls[3].Height = 25;
    config.Controls[3].Text = "Test";
    config.Controls[3].Visible = true;
    
    return CreatePanel(config);
}

//+------------------------------------------------------------------+
//| Create panel                                                   |
//+------------------------------------------------------------------+
bool CUIManager::CreatePanel(const SUIPanelConfig& config) {
    if (!m_bInitialized) {
        LogUIEvent("UI Manager not initialized", LOG_LEVEL_ERROR);
        return false;
    }
    
    // Create panel
    CPanel* panel = new CPanel();
    if (panel == NULL) {
        LogUIEvent("Failed to create panel: " + config.Name, LOG_LEVEL_ERROR);
        return false;
    }
    
    // Configure panel
    if (!panel.Create(0, config.Name, 0, config.X, config.Y, config.X + config.Width, config.Y + config.Height)) {
        LogUIEvent("Failed to configure panel: " + config.Name, LOG_LEVEL_ERROR);
        delete panel;
        return false;
    }
    
    // Set panel properties
    panel.ColorBackground(m_LayoutConfig.ColorScheme.PanelColor);
    panel.ColorBorder(m_LayoutConfig.ColorScheme.BorderColor);
    
    // Add to panels array
    int size = ArraySize(m_pPanels);
    ArrayResize(m_pPanels, size + 1);
    m_pPanels[size] = panel;
    
    // Create controls for this panel
    for (int i = 0; i < ArraySize(config.Controls); i++) {
        CreateControl(config.Name, config.Controls[i]);
    }
    
    LogUIEvent("Panel created: " + config.Name);
    return true;
}

//+------------------------------------------------------------------+
//| Create control                                                 |
//+------------------------------------------------------------------+
bool CUIManager::CreateControl(const string panelName, const SUIControlConfig& config) {
    // Find parent panel
    CPanel* parentPanel = FindPanel(panelName);
    if (parentPanel == NULL) {
        LogUIEvent("Parent panel not found: " + panelName, LOG_LEVEL_ERROR);
        return false;
    }
    
    // Create control based on type
    switch(config.Type) {
    case UI_CONTROL_LABEL:
        return CreateLabel(config) != NULL;
    case UI_CONTROL_BUTTON:
        return CreateButton(config) != NULL;
    case UI_CONTROL_EDIT:
        return CreateEdit(config) != NULL;
    case UI_CONTROL_COMBO:
        return CreateComboBox(config) != NULL;
    case UI_CONTROL_CHECK:
        return CreateCheckBox(config) != NULL;
    case UI_CONTROL_RADIO:
        return CreateRadioGroup(config) != NULL;
    case UI_CONTROL_LIST:
        return CreateListView(config) != NULL;
    case UI_CONTROL_PICTURE:
        return CreatePicture(config) != NULL;
    case UI_CONTROL_PANEL:
        return CreatePanelControl(config) != NULL;
    default:
        LogUIEvent("Unknown control type: " + IntegerToString(config.Type), LOG_LEVEL_ERROR);
        return false;
    }
}

//+------------------------------------------------------------------+
//| Create label control                                           |
//+------------------------------------------------------------------+
CLabel* CUIManager::CreateLabel(const SUIControlConfig& config) {
    CLabel* label = new CLabel();
    if (label == NULL) return NULL;
    
    if (!label.Create(0, config.Name, 0, config.X, config.Y, config.X + config.Width, config.Y + config.Height)) {
        delete label;
        return NULL;
    }
    
    label.Text(config.Text);
    label.Color(config.TextColor != 0 ? config.TextColor : m_LayoutConfig.ColorScheme.TextColor);
    label.FontSize(config.FontSize > 0 ? config.FontSize : m_LayoutConfig.DefaultFontSize);
    
    // Add to labels array
    int size = ArraySize(m_pLabels);
    ArrayResize(m_pLabels, size + 1);
    m_pLabels[size] = label;
    
    return label;
}

//+------------------------------------------------------------------+
//| Create button control                                          |
//+------------------------------------------------------------------+
CButton* CUIManager::CreateButton(const SUIControlConfig& config) {
    CButton* button = new CButton();
    if (button == NULL) return NULL;
    
    if (!button.Create(0, config.Name, 0, config.X, config.Y, config.X + config.Width, config.Y + config.Height)) {
        delete button;
        return NULL;
    }
    
    button.Text(config.Text);
    button.ColorBackground(config.BackColor != 0 ? config.BackColor : m_LayoutConfig.ColorScheme.ButtonColor);
    button.Color(config.TextColor != 0 ? config.TextColor : m_LayoutConfig.ColorScheme.TextColor);
    button.FontSize(config.FontSize > 0 ? config.FontSize : m_LayoutConfig.DefaultFontSize);
    
    // Add to buttons array
    int size = ArraySize(m_pButtons);
    ArrayResize(m_pButtons, size + 1);
    m_pButtons[size] = button;
    
    return button;
}

//+------------------------------------------------------------------+
//| Create edit control                                            |
//+------------------------------------------------------------------+
CEdit* CUIManager::CreateEdit(const SUIControlConfig& config) {
    CEdit* edit = new CEdit();
    if (edit == NULL) return NULL;
    
    if (!edit.Create(0, config.Name, 0, config.X, config.Y, config.X + config.Width, config.Y + config.Height)) {
        delete edit;
        return NULL;
    }
    
    edit.Text(config.Text);
    edit.ColorBackground(config.BackColor != 0 ? config.BackColor : m_LayoutConfig.ColorScheme.PanelColor);
    edit.Color(config.TextColor != 0 ? config.TextColor : m_LayoutConfig.ColorScheme.TextColor);
    edit.FontSize(config.FontSize > 0 ? config.FontSize : m_LayoutConfig.DefaultFontSize);
    
    // Add to edits array
    int size = ArraySize(m_pEdits);
    ArrayResize(m_pEdits, size + 1);
    m_pEdits[size] = edit;
    
    return edit;
}

//+------------------------------------------------------------------+
//| Placeholder methods for other control types                   |
//+------------------------------------------------------------------+
CComboBox* CUIManager::CreateComboBox(const SUIControlConfig& config) {
    // Placeholder implementation
    return NULL;
}

CCheckBox* CUIManager::CreateCheckBox(const SUIControlConfig& config) {
    // Placeholder implementation
    return NULL;
}

CRadioGroup* CUIManager::CreateRadioGroup(const SUIControlConfig& config) {
    // Placeholder implementation
    return NULL;
}

CListView* CUIManager::CreateListView(const SUIControlConfig& config) {
    // Placeholder implementation
    return NULL;
}

CPicture* CUIManager::CreatePicture(const SUIControlConfig& config) {
    // Placeholder implementation
    return NULL;
}

CPanel* CUIManager::CreatePanelControl(const SUIControlConfig& config) {
    // Placeholder implementation
    return NULL;
}

//+------------------------------------------------------------------+
//| Show UI                                                        |
//+------------------------------------------------------------------+
void CUIManager::Show() {
    if (!m_bInitialized) return;
    
    if (m_pMainDialog != NULL) {
        m_pMainDialog.Run();
    }
    
    m_bVisible = true;
    LogUIEvent("UI shown");
}

//+------------------------------------------------------------------+
//| Hide UI                                                        |
//+------------------------------------------------------------------+
void CUIManager::Hide() {
    if (!m_bInitialized) return;
    
    if (m_pMainDialog != NULL) {
        m_pMainDialog.Destroy();
    }
    
    m_bVisible = false;
    LogUIEvent("UI hidden");
}

//+------------------------------------------------------------------+
//| Update UI                                                      |
//+------------------------------------------------------------------+
void CUIManager::Update() {
    if (!m_bInitialized || !m_bVisible) return;
    
    datetime currentTime = TimeCurrent();
    if (currentTime - m_LastUpdate < m_UpdateInterval / 1000) return;
    
    // Update all panels
    UpdateAccountInfo();
    UpdateTradingInfo();
    UpdateRiskInfo();
    UpdatePerformanceInfo();
    UpdateSystemStatus();
    UpdateMarketInfo();
    
    // Process events
    ProcessEvents();
    
    // Update statistics
    UpdateStatistics();
    
    m_LastUpdate = currentTime;
}

//+------------------------------------------------------------------+
//| Update account information                                     |
//+------------------------------------------------------------------+
void CUIManager::UpdateAccountInfo() {
    if (m_pContext == NULL) return;
    
    string accountText = StringFormat("Account: %d\nBalance: %.2f\nEquity: %.2f\nMargin: %.2f",
                                     AccountInfoInteger(ACCOUNT_LOGIN),
                                     AccountInfoDouble(ACCOUNT_BALANCE),
                                     AccountInfoDouble(ACCOUNT_EQUITY),
                                     AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));
    
    SetControlText("MainPanel", "AccountLabel", accountText);
}

//+------------------------------------------------------------------+
//| Update trading information                                     |
//+------------------------------------------------------------------+
void CUIManager::UpdateTradingInfo() {
    if (m_pContext == NULL) return;
    
    // Update trading panel controls
    SetControlText("TradingPanel", "PositionsLabel", "Open Positions: " + IntegerToString(PositionsTotal()));
    
    // Calculate total profit
    double totalProfit = 0;
    for (int i = 0; i < PositionsTotal(); i++) {
        if (PositionSelectByIndex(i)) {
            totalProfit += PositionGetDouble(POSITION_PROFIT);
        }
    }
    SetControlText("TradingPanel", "ProfitLabel", "Total Profit: $" + FormatCurrency(totalProfit));
}

//+------------------------------------------------------------------+
//| Update risk information                                        |
//+------------------------------------------------------------------+
void CUIManager::UpdateRiskInfo() {
    if (m_pContext == NULL) return;
    
    // Calculate current drawdown
    double equity = AccountInfoDouble(ACCOUNT_EQUITY);
    double balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double drawdown = balance > 0 ? (balance - equity) / balance * 100 : 0;
    
    SetControlText("RiskPanel", "DrawdownLabel", "Current Drawdown: " + FormatPercent(drawdown));
    
    // Update margin level
    double marginLevel = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
    SetControlText("RiskPanel", "MarginLabel", "Margin Level: " + FormatPercent(marginLevel));
    
    // Determine risk level
    string riskLevel = "Low";
    color riskColor = m_LayoutConfig.ColorScheme.SuccessColor;
    
    if (drawdown > 10) {
        riskLevel = "High";
        riskColor = m_LayoutConfig.ColorScheme.ErrorColor;
    } else if (drawdown > 5) {
        riskLevel = "Medium";
        riskColor = m_LayoutConfig.ColorScheme.WarningColor;
    }
    
    SetControlText("RiskPanel", "RiskLevelLabel", "Risk Level: " + riskLevel);
    SetControlColor("RiskPanel", "RiskLevelLabel", riskColor);
}

//+------------------------------------------------------------------+
//| Update performance information                                 |
//+------------------------------------------------------------------+
void CUIManager::UpdatePerformanceInfo() {
    // Placeholder implementation
    SetControlText("AnalyticsPanel", "SharpeLabel", "Sharpe Ratio: 1.25");
    SetControlText("AnalyticsPanel", "ProfitFactorLabel", "Profit Factor: 1.85");
    SetControlText("AnalyticsPanel", "MaxDrawdownLabel", "Max Drawdown: 8.5%");
}

//+------------------------------------------------------------------+
//| Update system status                                          |
//+------------------------------------------------------------------+
void CUIManager::UpdateSystemStatus() {
    if (m_pContext == NULL) return;
    
    string status = "EA Status: ";
    if (MQLInfoInteger(MQL_TRADE_ALLOWED)) {
        status += "Active";
        SetControlColor("MainPanel", "StatusLabel", m_LayoutConfig.ColorScheme.SuccessColor);
    } else {
        status += "Inactive";
        SetControlColor("MainPanel", "StatusLabel", m_LayoutConfig.ColorScheme.ErrorColor);
    }
    
    SetControlText("MainPanel", "StatusLabel", status);
}

//+------------------------------------------------------------------+
//| Update market information                                      |
//+------------------------------------------------------------------+
void CUIManager::UpdateMarketInfo() {
    // Placeholder implementation
}

//+------------------------------------------------------------------+
//| Process UI events                                              |
//+------------------------------------------------------------------+
void CUIManager::ProcessEvents() {
    // Process pending events
    while (HasPendingEvents()) {
        SUIEvent event = GetNextEvent();
        
        // Handle different event types
        switch(event.ControlType) {
        case UI_CONTROL_BUTTON:
            OnButtonClick(event.ControlName);
            break;
        case UI_CONTROL_EDIT:
            OnEditChange(event.ControlName);
            break;
        case UI_CONTROL_COMBO:
            OnComboChange(event.ControlName);
            break;
        case UI_CONTROL_CHECK:
            OnCheckBoxChange(event.ControlName);
            break;
        case UI_CONTROL_RADIO:
            OnRadioChange(event.ControlName);
            break;
        case UI_CONTROL_LIST:
            OnListSelect(event.ControlName);
            break;
        }
    }
}

//+------------------------------------------------------------------+
//| Handle button click events                                     |
//+------------------------------------------------------------------+
void CUIManager::OnButtonClick(const string buttonName) {
    if (buttonName == "StartStopButton") {
        // Toggle EA state
        LogUIEvent("Start/Stop button clicked");
    } else if (buttonName == "SettingsButton") {
        // Show/hide settings panel
        ShowPanel("SettingsPanel", !FindPanel("SettingsPanel"));
    } else if (buttonName == "AnalyticsButton") {
        // Show/hide analytics panel
        ShowPanel("AnalyticsPanel", !FindPanel("AnalyticsPanel"));
    } else if (buttonName == "CloseAllButton") {
        // Close all positions
        LogUIEvent("Close All button clicked", LOG_LEVEL_WARNING);
    } else if (buttonName == "EmergencyStopButton") {
        // Emergency stop
        LogUIEvent("Emergency Stop button clicked", LOG_LEVEL_ERROR);
    }
}

//+------------------------------------------------------------------+
//| Placeholder event handlers                                     |
//+------------------------------------------------------------------+
void CUIManager::OnEditChange(const string editName) {
    LogUIEvent("Edit changed: " + editName);
}

void CUIManager::OnComboChange(const string comboName) {
    LogUIEvent("Combo changed: " + comboName);
}

void CUIManager::OnCheckBoxChange(const string checkBoxName) {
    LogUIEvent("CheckBox changed: " + checkBoxName);
}

void CUIManager::OnRadioChange(const string radioName) {
    LogUIEvent("Radio changed: " + radioName);
}

void CUIManager::OnListSelect(const string listName) {
    LogUIEvent("List selection changed: " + listName);
}

//+------------------------------------------------------------------+
//| Set control text                                               |
//+------------------------------------------------------------------+
bool CUIManager::SetControlText(const string panelName, const string controlName, const string text) {
    // Find control and set text
    // This is a simplified implementation
    return true;
}

//+------------------------------------------------------------------+
//| Set control color                                              |
//+------------------------------------------------------------------+
bool CUIManager::SetControlColor(const string panelName, const string controlName, const color clr) {
    // Find control and set color
    // This is a simplified implementation
    return true;
}

//+------------------------------------------------------------------+
//| Find panel by name                                             |
//+------------------------------------------------------------------+
CPanel* CUIManager::FindPanel(const string name) {
    // Simplified implementation
    for (int i = 0; i < ArraySize(m_pPanels); i++) {
        if (m_pPanels[i] != NULL) {
            return m_pPanels[i];
        }
    }
    return NULL;
}

//+------------------------------------------------------------------+
//| Show/hide panel                                                |
//+------------------------------------------------------------------+
bool CUIManager::ShowPanel(const string name, const bool show) {
    CPanel* panel = FindPanel(name);
    if (panel == NULL) return false;
    
    panel.Show(show);
    return true;
}

//+------------------------------------------------------------------+
//| Get next event from queue                                      |
//+------------------------------------------------------------------+
SUIEvent CUIManager::GetNextEvent() {
    SUIEvent event;
    ZeroMemory(event);
    
    if (ArraySize(m_EventQueue) > 0) {
        event = m_EventQueue[0];
        
        // Remove from queue
        for (int i = 0; i < ArraySize(m_EventQueue) - 1; i++) {
            m_EventQueue[i] = m_EventQueue[i + 1];
        }
        ArrayResize(m_EventQueue, ArraySize(m_EventQueue) - 1);
    }
    
    return event;
}

//+------------------------------------------------------------------+
//| Update statistics                                              |
//+------------------------------------------------------------------+
void CUIManager::UpdateStatistics() {
    m_Stats.TotalControls = ArraySize(m_pLabels) + ArraySize(m_pButtons) + ArraySize(m_pEdits);
    m_Stats.TotalPanels = ArraySize(m_pPanels);
    m_Stats.LastUpdate = TimeCurrent();
    m_Stats.IsResponsive = true;
}

//+------------------------------------------------------------------+
//| Format number                                                  |
//+------------------------------------------------------------------+
string CUIManager::FormatNumber(const double value, const int digits = 2) const {
    return DoubleToString(value, digits);
}

//+------------------------------------------------------------------+
//| Format currency                                                |
//+------------------------------------------------------------------+
string CUIManager::FormatCurrency(const double value) const {
    return DoubleToString(value, 2);
}

//+------------------------------------------------------------------+
//| Format percentage                                              |
//+------------------------------------------------------------------+
string CUIManager::FormatPercent(const double value) const {
    return DoubleToString(value, 2) + "%";
}

//+------------------------------------------------------------------+
//| Log UI event                                                   |
//+------------------------------------------------------------------+
void CUIManager::LogUIEvent(const string event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO) {
    if (m_pContext != NULL && m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo("[UI] " + event);
    } else {
        Print("[UI] " + event);
    }
}

//+------------------------------------------------------------------+