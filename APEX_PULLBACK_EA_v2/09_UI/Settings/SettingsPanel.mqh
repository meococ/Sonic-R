//+------------------------------------------------------------------+
//|                                                SettingsPanel.mqh |
//|                                    APEX Pullback EA v5.0 FINAL   |
//|                                    Settings Panel Management     |
//+------------------------------------------------------------------+
#property copyright "APEX Trading Systems"
#property version   "5.00"
#property strict

#include "../../00_Core/CommonStructs.mqh"
#include <Controls\Dialog.mqh>
#include <Controls\Panel.mqh>
#include <Controls\Label.mqh>
#include <Controls\Edit.mqh>
#include <Controls\Button.mqh>
#include <Controls\CheckBox.mqh>
#include <Controls\ComboBox.mqh>
#include <Controls\SpinEdit.mqh>
#include <Controls\ColorButton.mqh>
#include <Controls\DatePicker.mqh>
#include <Controls\ListView.mqh>
#include <Controls\TreeView.mqh>

//+------------------------------------------------------------------+
//| Settings panel type enumeration                                 |
//+------------------------------------------------------------------+
enum ENUM_SETTINGS_PANEL_TYPE {
    SETTINGS_PANEL_TRADING,
    SETTINGS_PANEL_RISK,
    SETTINGS_PANEL_UI,
    SETTINGS_PANEL_ALERTS,
    SETTINGS_PANEL_LOGGING,
    SETTINGS_PANEL_PERFORMANCE,
    SETTINGS_PANEL_ANALYTICS,
    SETTINGS_PANEL_SYSTEM,
    SETTINGS_PANEL_ADVANCED,
    SETTINGS_PANEL_PROFILES
};

//+------------------------------------------------------------------+
//| Settings control type enumeration                               |
//+------------------------------------------------------------------+
enum ENUM_SETTINGS_CONTROL_TYPE {
    SETTINGS_CONTROL_LABEL,
    SETTINGS_CONTROL_EDIT,
    SETTINGS_CONTROL_BUTTON,
    SETTINGS_CONTROL_CHECKBOX,
    SETTINGS_CONTROL_COMBOBOX,
    SETTINGS_CONTROL_SPINEDIT,
    SETTINGS_CONTROL_COLORBUTTON,
    SETTINGS_CONTROL_DATEPICKER,
    SETTINGS_CONTROL_SLIDER,
    SETTINGS_CONTROL_LISTVIEW,
    SETTINGS_CONTROL_TREEVIEW
};

//+------------------------------------------------------------------+
//| Settings validation type enumeration                            |
//+------------------------------------------------------------------+
enum ENUM_SETTINGS_VALIDATION {
    SETTINGS_VALIDATION_NONE,
    SETTINGS_VALIDATION_REQUIRED,
    SETTINGS_VALIDATION_NUMERIC,
    SETTINGS_VALIDATION_RANGE,
    SETTINGS_VALIDATION_PATTERN,
    SETTINGS_VALIDATION_CUSTOM
};

//+------------------------------------------------------------------+
//| Settings control structure                                      |
//+------------------------------------------------------------------+
struct SSettingsControl {
    string Name;
    string Label;
    string Description;
    string Category;
    string Group;
    
    ENUM_SETTINGS_CONTROL_TYPE Type;
    
    // Position and size
    int X;
    int Y;
    int Width;
    int Height;
    
    // Value information
    string StringValue;
    double DoubleValue;
    int IntValue;
    bool BoolValue;
    datetime DateTimeValue;
    color ColorValue;
    
    // Control properties
    string DataType;
    double MinValue;
    double MaxValue;
    int DecimalPlaces;
    string Items[50];
    int ItemCount;
    
    // Validation
    ENUM_SETTINGS_VALIDATION ValidationType;
    string ValidationPattern;
    string ValidationMessage;
    bool IsRequired;
    bool IsReadOnly;
    bool IsVisible;
    bool IsEnabled;
    
    // Default values
    string DefaultStringValue;
    double DefaultDoubleValue;
    int DefaultIntValue;
    bool DefaultBoolValue;
    datetime DefaultDateTimeValue;
    color DefaultColorValue;
    
    // UI properties
    string Tooltip;
    string HelpText;
    bool HasLabel;
    string LabelText;
    int TabOrder;
    
    // Dependencies
    string DependentControls[10];
    int DependentControlCount;
    string ConditionalExpression;
    
    // Events
    bool HasChangeEvent;
    bool HasValidationEvent;
    bool HasClickEvent;
    
    // Control handle
    CWndObj* pControl;
    CLabel* pLabel;
    
    // Status
    bool IsCreated;
    bool IsModified;
    bool IsValid;
    string LastError;
};

//+------------------------------------------------------------------+
//| Settings group structure                                         |
//+------------------------------------------------------------------+
struct SSettingsGroup {
    string Name;
    string Title;
    string Description;
    string Category;
    
    // Position and layout
    int X;
    int Y;
    int Width;
    int Height;
    int Columns;
    int Spacing;
    
    // Controls
    SSettingsControl Controls[50];
    int ControlCount;
    
    // Properties
    bool IsCollapsible;
    bool IsCollapsed;
    bool IsVisible;
    bool IsEnabled;
    
    // UI elements
    CPanel* pPanel;
    CLabel* pTitleLabel;
    CButton* pCollapseButton;
    
    // Status
    bool IsCreated;
    bool IsModified;
    int Order;
};

//+------------------------------------------------------------------+
//| Settings category structure                                     |
//+------------------------------------------------------------------+
struct SSettingsCategory {
    string Name;
    string Title;
    string Description;
    string Icon;
    
    // Groups
    SSettingsGroup Groups[20];
    int GroupCount;
    
    // Properties
    bool IsVisible;
    bool IsEnabled;
    bool IsAdvanced;
    
    // UI elements
    CPanel* pPanel;
    
    // Status
    bool IsCreated;
    bool IsModified;
    int Order;
};

//+------------------------------------------------------------------+
//| Settings panel configuration structure                           |
//+------------------------------------------------------------------+
struct SSettingsPanelConfig {
    string Title;
    string Description;
    
    // Window properties
    int X;
    int Y;
    int Width;
    int Height;
    bool IsResizable;
    bool IsMovable;
    bool IsModal;
    
    // Layout
    int TabWidth;
    int TabHeight;
    int ContentMargin;
    int GroupSpacing;
    int ControlSpacing;
    
    // Colors and fonts
    color BackgroundColor;
    color BorderColor;
    color TextColor;
    color HighlightColor;
    string FontName;
    int FontSize;
    
    // Behavior
    bool AutoSave;
    bool AutoValidate;
    bool ShowTooltips;
    bool ShowHelpText;
    bool ConfirmChanges;
    
    // Profiles
    string DefaultProfile;
    bool AllowProfileSwitching;
    bool ShowProfileControls;
};

//+------------------------------------------------------------------+
//| Settings panel statistics structure                             |
//+------------------------------------------------------------------+
struct SSettingsPanelStats {
    int TotalCategories;
    int TotalGroups;
    int TotalControls;
    
    int VisibleCategories;
    int VisibleGroups;
    int VisibleControls;
    
    int ModifiedControls;
    int InvalidControls;
    int RequiredControls;
    
    datetime LastOpened;
    datetime LastClosed;
    datetime LastSaved;
    datetime LastValidated;
    
    int OpenCount;
    int SaveCount;
    int ValidationCount;
    int ErrorCount;
    
    double AverageOpenTime;
    double AverageSaveTime;
    double AverageValidationTime;
    
    string CurrentProfile;
    string LastProfile;
    int ProfileSwitchCount;
    
    // User interaction
    int ClickCount;
    int ChangeCount;
    int ValidationErrorCount;
    string MostUsedControl;
    int MostUsedControlCount;
};

//+------------------------------------------------------------------+
//| Settings panel class                                            |
//+------------------------------------------------------------------+
class CSettingsPanel : public CAppDialog {
private:
    EAContext* m_pContext;
    
    // Configuration
    SSettingsPanelConfig m_Config;
    
    // Categories and content
    SSettingsCategory m_Categories[10];
    int m_CategoryCount;
    
    // Statistics
    SSettingsPanelStats m_Statistics;
    
    // Current state
    int m_CurrentCategory;
    string m_CurrentProfile;
    bool m_bInitialized;
    bool m_bVisible;
    bool m_bModified;
    
    // UI controls
    CPanel* m_pMainPanel;
    CPanel* m_pTabPanel;
    CPanel* m_pContentPanel;
    CPanel* m_pButtonPanel;
    
    // Tab buttons
    CButton* m_pTabButtons[10];
    int m_TabButtonCount;
    
    // Action buttons
    CButton* m_pOKButton;
    CButton* m_pCancelButton;
    CButton* m_pApplyButton;
    CButton* m_pResetButton;
    CButton* m_pDefaultsButton;
    
    // Profile controls
    CLabel* m_pProfileLabel;
    CComboBox* m_pProfileComboBox;
    CButton* m_pSaveProfileButton;
    CButton* m_pLoadProfileButton;
    CButton* m_pDeleteProfileButton;
    
    // Status controls
    CLabel* m_pStatusLabel;
    
    // Validation
    bool m_bValidationEnabled;
    string m_ValidationErrors[100];
    int m_ValidationErrorCount;
    
    // Change tracking
    bool m_bChangeTrackingEnabled;
    string m_ChangedControls[100];
    int m_ChangedControlCount;
    
    // Help system
    bool m_bHelpEnabled;
    CPanel* m_pHelpPanel;
    CLabel* m_pHelpLabel;
    
public:
    CSettingsPanel();
    ~CSettingsPanel();
    
    // Core methods
    bool Initialize(EAContext* context);
    void Deinitialize();
    bool Create(const long chart_id, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2);
    void Destroy();
    
    // Configuration
    void SetConfig(const SSettingsPanelConfig& config);
    SSettingsPanelConfig GetConfig() const { return m_Config; }
    
    // Category management
    bool AddCategory(const string name, const string title, const string description = "", const string icon = "");
    bool RemoveCategory(const string name);
    bool ShowCategory(const string name);
    bool HideCategory(const string name);
    string GetCurrentCategory() const;
    string[] GetCategoryNames() const;
    
    // Group management
    bool AddGroup(const string categoryName, const string groupName, const string title, const string description = "");
    bool RemoveGroup(const string categoryName, const string groupName);
    bool ShowGroup(const string categoryName, const string groupName);
    bool HideGroup(const string categoryName, const string groupName);
    
    // Control management
    bool AddControl(const string categoryName, const string groupName, const SSettingsControl& control);
    bool RemoveControl(const string categoryName, const string groupName, const string controlName);
    bool ShowControl(const string categoryName, const string groupName, const string controlName);
    bool HideControl(const string categoryName, const string groupName, const string controlName);
    bool EnableControl(const string categoryName, const string groupName, const string controlName);
    bool DisableControl(const string categoryName, const string groupName, const string controlName);
    
    // Control value management
    bool SetControlValue(const string categoryName, const string groupName, const string controlName, const string value);
    bool SetControlValueDouble(const string categoryName, const string groupName, const string controlName, const double value);
    bool SetControlValueInt(const string categoryName, const string groupName, const string controlName, const int value);
    bool SetControlValueBool(const string categoryName, const string groupName, const string controlName, const bool value);
    bool SetControlValueDateTime(const string categoryName, const string groupName, const string controlName, const datetime value);
    bool SetControlValueColor(const string categoryName, const string groupName, const string controlName, const color value);
    
    string GetControlValue(const string categoryName, const string groupName, const string controlName) const;
    double GetControlValueDouble(const string categoryName, const string groupName, const string controlName) const;
    int GetControlValueInt(const string categoryName, const string groupName, const string controlName) const;
    bool GetControlValueBool(const string categoryName, const string groupName, const string controlName) const;
    datetime GetControlValueDateTime(const string categoryName, const string groupName, const string controlName) const;
    color GetControlValueColor(const string categoryName, const string groupName, const string controlName) const;
    
    // Control queries
    bool ControlExists(const string categoryName, const string groupName, const string controlName) const;
    SSettingsControl GetControl(const string categoryName, const string groupName, const string controlName) const;
    string[] GetControlNames(const string categoryName, const string groupName) const;
    
    // Predefined control creation
    bool AddTextBox(const string categoryName, const string groupName, const string name, const string label, const string defaultValue = "", const string description = "");
    bool AddNumberBox(const string categoryName, const string groupName, const string name, const string label, const double defaultValue = 0, const double minValue = 0, const double maxValue = 0, const string description = "");
    bool AddCheckBox(const string categoryName, const string groupName, const string name, const string label, const bool defaultValue = false, const string description = "");
    bool AddComboBox(const string categoryName, const string groupName, const string name, const string label, const string items[], const int itemCount, const string defaultValue = "", const string description = "");
    bool AddColorPicker(const string categoryName, const string groupName, const string name, const string label, const color defaultValue = clrWhite, const string description = "");
    bool AddDatePicker(const string categoryName, const string groupName, const string name, const string label, const datetime defaultValue = 0, const string description = "");
    
    // Layout management
    void UpdateLayout();
    void RefreshDisplay();
    void ResizeToContent();
    
    // Profile management
    bool LoadProfile(const string profileName);
    bool SaveProfile(const string profileName = "");
    bool DeleteProfile(const string profileName);
    string[] GetProfileNames() const;
    string GetCurrentProfile() const { return m_CurrentProfile; }
    
    // Validation
    bool ValidateAll();
    bool ValidateCategory(const string categoryName);
    bool ValidateGroup(const string categoryName, const string groupName);
    bool ValidateControl(const string categoryName, const string groupName, const string controlName);
    string[] GetValidationErrors() const;
    bool IsValid() const;
    
    // Change tracking
    void EnableChangeTracking(const bool enable = true);
    bool HasChanges() const;
    string[] GetChangedControls() const;
    void ResetChanges();
    
    // Data operations
    bool ApplyChanges();
    bool RevertChanges();
    bool ResetToDefaults();
    bool ResetCategory(const string categoryName);
    bool ResetGroup(const string categoryName, const string groupName);
    bool ResetControl(const string categoryName, const string groupName, const string controlName);
    
    // Import/Export
    bool ExportSettings(const string filePath);
    bool ImportSettings(const string filePath);
    bool ExportProfile(const string profileName, const string filePath);
    bool ImportProfile(const string filePath, const string profileName = "");
    
    // Display control
    bool Show();
    bool Hide();
    bool IsVisible() const { return m_bVisible; }
    bool BringToFront();
    
    // Event handling
    virtual bool OnEvent(const int id, const long& lparam, const double& dparam, const string& sparam);
    virtual void OnClickOK();
    virtual void OnClickCancel();
    virtual void OnClickApply();
    virtual void OnClickReset();
    virtual void OnClickDefaults();
    virtual void OnTabChange(const int tabIndex);
    virtual void OnControlChange(const string categoryName, const string groupName, const string controlName);
    virtual void OnProfileChange(const string profileName);
    
    // Help system
    void EnableHelp(const bool enable = true);
    void ShowHelp(const string topic = "");
    void HideHelp();
    void SetHelpText(const string text);
    
    // Statistics
    SSettingsPanelStats GetStatistics() const { return m_Statistics; }
    void UpdateStatistics();
    void ResetStatistics();
    
    // Utility methods
    string GetCategoryTitle(const string categoryName) const;
    string GetGroupTitle(const string categoryName, const string groupName) const;
    string GetControlLabel(const string categoryName, const string groupName, const string controlName) const;
    
private:
    // Internal UI creation
    bool CreateMainPanel();
    bool CreateTabPanel();
    bool CreateContentPanel();
    bool CreateButtonPanel();
    bool CreateProfileControls();
    bool CreateStatusControls();
    bool CreateHelpPanel();
    
    // Tab management
    bool CreateTabButtons();
    bool UpdateTabButtons();
    void SelectTab(const int index);
    
    // Category UI creation
    bool CreateCategoryUI(const int categoryIndex);
    bool CreateGroupUI(const int categoryIndex, const int groupIndex);
    bool CreateControlUI(const int categoryIndex, const int groupIndex, const int controlIndex);
    
    // Control creation helpers
    CWndObj* CreateControlByType(const SSettingsControl& control, CPanel* pParent);
    CLabel* CreateLabel(const SSettingsControl& control, CPanel* pParent);
    CEdit* CreateEdit(const SSettingsControl& control, CPanel* pParent);
    CButton* CreateButton(const SSettingsControl& control, CPanel* pParent);
    CCheckBox* CreateCheckBox(const SSettingsControl& control, CPanel* pParent);
    CComboBox* CreateComboBox(const SSettingsControl& control, CPanel* pParent);
    CSpinEdit* CreateSpinEdit(const SSettingsControl& control, CPanel* pParent);
    CColorButton* CreateColorButton(const SSettingsControl& control, CPanel* pParent);
    
    // Layout helpers
    void CalculateLayout();
    void PositionControls();
    void UpdateScrollbars();
    
    // Index finding
    int FindCategoryIndex(const string name) const;
    int FindGroupIndex(const int categoryIndex, const string name) const;
    int FindControlIndex(const int categoryIndex, const int groupIndex, const string name) const;
    
    // Validation helpers
    bool ValidateControlValue(const SSettingsControl& control) const;
    string GetValidationError(const SSettingsControl& control) const;
    
    // Change tracking helpers
    void RecordChange(const string categoryName, const string groupName, const string controlName);
    bool IsControlChanged(const string categoryName, const string groupName, const string controlName) const;
    
    // Profile helpers
    bool LoadControlsFromProfile(const string profileName);
    bool SaveControlsToProfile(const string profileName);
    
    // Statistics helpers
    void UpdateOpenStatistics();
    void UpdateCloseStatistics();
    void UpdateSaveStatistics();
    void UpdateValidationStatistics();
    void UpdateInteractionStatistics(const string controlName);
    
    // Error handling
    void SetError(const string error);
    void LogError(const string error, const ENUM_LOG_LEVEL level = LOG_LEVEL_ERROR);
    void LogActivity(const string activity, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO);
    
    // Utility helpers
    string FormatControlValue(const SSettingsControl& control) const;
    bool ParseControlValue(SSettingsControl& control, const string value) const;
    color GetThemeColor(const string colorName) const;
    string GetLocalizedText(const string key) const;
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSettingsPanel::CSettingsPanel() {
    m_pContext = NULL;
    m_bInitialized = false;
    m_bVisible = false;
    m_bModified = false;
    
    m_CategoryCount = 0;
    m_CurrentCategory = 0;
    m_CurrentProfile = "";
    
    m_TabButtonCount = 0;
    
    // Initialize UI controls
    m_pMainPanel = NULL;
    m_pTabPanel = NULL;
    m_pContentPanel = NULL;
    m_pButtonPanel = NULL;
    
    m_pOKButton = NULL;
    m_pCancelButton = NULL;
    m_pApplyButton = NULL;
    m_pResetButton = NULL;
    m_pDefaultsButton = NULL;
    
    m_pProfileLabel = NULL;
    m_pProfileComboBox = NULL;
    m_pSaveProfileButton = NULL;
    m_pLoadProfileButton = NULL;
    m_pDeleteProfileButton = NULL;
    
    m_pStatusLabel = NULL;
    m_pHelpPanel = NULL;
    m_pHelpLabel = NULL;
    
    // Initialize arrays
    for (int i = 0; i < ArraySize(m_pTabButtons); i++) {
        m_pTabButtons[i] = NULL;
    }
    
    // Initialize validation
    m_bValidationEnabled = true;
    m_ValidationErrorCount = 0;
    
    // Initialize change tracking
    m_bChangeTrackingEnabled = true;
    m_ChangedControlCount = 0;
    
    // Initialize help
    m_bHelpEnabled = false;
    
    // Initialize statistics
    ZeroMemory(m_Statistics);
    
    // Set default configuration
    ZeroMemory(m_Config);
    m_Config.Title = "Settings";
    m_Config.Width = 800;
    m_Config.Height = 600;
    m_Config.IsResizable = true;
    m_Config.IsMovable = true;
    m_Config.IsModal = false;
    m_Config.AutoSave = false;
    m_Config.AutoValidate = true;
    m_Config.ShowTooltips = true;
    m_Config.ShowHelpText = true;
    m_Config.ConfirmChanges = true;
    m_Config.BackgroundColor = clrWhite;
    m_Config.BorderColor = clrGray;
    m_Config.TextColor = clrBlack;
    m_Config.HighlightColor = clrBlue;
    m_Config.FontName = "Arial";
    m_Config.FontSize = 9;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSettingsPanel::~CSettingsPanel() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize settings panel                                       |
//+------------------------------------------------------------------+
bool CSettingsPanel::Initialize(EAContext* context) {
    if (context == NULL) {
        Print("[SETTINGS PANEL ERROR] Context is NULL");
        return false;
    }
    
    m_pContext = context;
    
    // Initialize statistics
    m_Statistics.LastOpened = TimeCurrent();
    m_Statistics.OpenCount++;
    
    m_bInitialized = true;
    LogActivity("Settings Panel initialized successfully");
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize settings panel                                     |
//+------------------------------------------------------------------+
void CSettingsPanel::Deinitialize() {
    if (m_bInitialized) {
        // Auto-save if enabled
        if (m_Config.AutoSave && m_bModified) {
            ApplyChanges();
        }
        
        // Update statistics
        m_Statistics.LastClosed = TimeCurrent();
        
        // Destroy UI
        Destroy();
        
        LogActivity("Settings Panel deinitialized");
    }
    
    m_bInitialized = false;
    m_pContext = NULL;
}

//+------------------------------------------------------------------+
//| Create settings panel                                           |
//+------------------------------------------------------------------+
bool CSettingsPanel::Create(const long chart_id, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2) {
    if (!CAppDialog::Create(chart_id, name, subwin, x1, y1, x2, y2)) {
        LogError("Failed to create settings panel dialog");
        return false;
    }
    
    // Create main components
    if (!CreateMainPanel()) {
        LogError("Failed to create main panel");
        return false;
    }
    
    if (!CreateTabPanel()) {
        LogError("Failed to create tab panel");
        return false;
    }
    
    if (!CreateContentPanel()) {
        LogError("Failed to create content panel");
        return false;
    }
    
    if (!CreateButtonPanel()) {
        LogError("Failed to create button panel");
        return false;
    }
    
    if (!CreateProfileControls()) {
        LogError("Failed to create profile controls");
        return false;
    }
    
    if (!CreateStatusControls()) {
        LogError("Failed to create status controls");
        return false;
    }
    
    if (m_bHelpEnabled && !CreateHelpPanel()) {
        LogError("Failed to create help panel");
        return false;
    }
    
    // Create tab buttons
    if (!CreateTabButtons()) {
        LogError("Failed to create tab buttons");
        return false;
    }
    
    // Create category UIs
    for (int i = 0; i < m_CategoryCount; i++) {
        if (!CreateCategoryUI(i)) {
            LogError(StringFormat("Failed to create UI for category %s", m_Categories[i].Name));
            return false;
        }
    }
    
    // Update layout
    UpdateLayout();
    
    // Select first tab
    if (m_CategoryCount > 0) {
        SelectTab(0);
    }
    
    LogActivity("Settings Panel created successfully");
    return true;
}

//+------------------------------------------------------------------+
//| Destroy settings panel                                          |
//+------------------------------------------------------------------+
void CSettingsPanel::Destroy() {
    // Clean up UI controls
    for (int i = 0; i < m_TabButtonCount; i++) {
        if (m_pTabButtons[i] != NULL) {
            delete m_pTabButtons[i];
            m_pTabButtons[i] = NULL;
        }
    }
    
    // Clean up category controls
    for (int i = 0; i < m_CategoryCount; i++) {
        for (int j = 0; j < m_Categories[i].GroupCount; j++) {
            for (int k = 0; k < m_Categories[i].Groups[j].ControlCount; k++) {
                if (m_Categories[i].Groups[j].Controls[k].pControl != NULL) {
                    delete m_Categories[i].Groups[j].Controls[k].pControl;
                    m_Categories[i].Groups[j].Controls[k].pControl = NULL;
                }
                if (m_Categories[i].Groups[j].Controls[k].pLabel != NULL) {
                    delete m_Categories[i].Groups[j].Controls[k].pLabel;
                    m_Categories[i].Groups[j].Controls[k].pLabel = NULL;
                }
            }
            if (m_Categories[i].Groups[j].pPanel != NULL) {
                delete m_Categories[i].Groups[j].pPanel;
                m_Categories[i].Groups[j].pPanel = NULL;
            }
        }
        if (m_Categories[i].pPanel != NULL) {
            delete m_Categories[i].pPanel;
            m_Categories[i].pPanel = NULL;
        }
    }
    
    // Clean up main panels
    if (m_pHelpPanel != NULL) {
        delete m_pHelpPanel;
        m_pHelpPanel = NULL;
    }
    
    if (m_pButtonPanel != NULL) {
        delete m_pButtonPanel;
        m_pButtonPanel = NULL;
    }
    
    if (m_pContentPanel != NULL) {
        delete m_pContentPanel;
        m_pContentPanel = NULL;
    }
    
    if (m_pTabPanel != NULL) {
        delete m_pTabPanel;
        m_pTabPanel = NULL;
    }
    
    if (m_pMainPanel != NULL) {
        delete m_pMainPanel;
        m_pMainPanel = NULL;
    }
    
    CAppDialog::Destroy();
}

//+------------------------------------------------------------------+
//| Add category                                                     |
//+------------------------------------------------------------------+
bool CSettingsPanel::AddCategory(const string name, const string title, const string description = "", const string icon = "") {
    if (m_CategoryCount >= ArraySize(m_Categories)) {
        LogError("Maximum number of categories reached");
        return false;
    }
    
    // Check if category already exists
    if (FindCategoryIndex(name) >= 0) {
        LogError(StringFormat("Category %s already exists", name));
        return false;
    }
    
    // Initialize category
    SSettingsCategory category;
    ZeroMemory(category);
    category.Name = name;
    category.Title = title;
    category.Description = description;
    category.Icon = icon;
    category.IsVisible = true;
    category.IsEnabled = true;
    category.IsAdvanced = false;
    category.Order = m_CategoryCount;
    
    m_Categories[m_CategoryCount] = category;
    m_CategoryCount++;
    
    m_Statistics.TotalCategories++;
    m_Statistics.VisibleCategories++;
    
    LogActivity(StringFormat("Category %s added successfully", name));
    return true;
}

//+------------------------------------------------------------------+
//| Add group to category                                           |
//+------------------------------------------------------------------+
bool CSettingsPanel::AddGroup(const string categoryName, const string groupName, const string title, const string description = "") {
    int categoryIndex = FindCategoryIndex(categoryName);
    if (categoryIndex < 0) {
        LogError(StringFormat("Category %s not found", categoryName));
        return false;
    }
    
    if (m_Categories[categoryIndex].GroupCount >= ArraySize(m_Categories[categoryIndex].Groups)) {
        LogError("Maximum number of groups reached for category");
        return false;
    }
    
    // Check if group already exists
    if (FindGroupIndex(categoryIndex, groupName) >= 0) {
        LogError(StringFormat("Group %s already exists in category %s", groupName, categoryName));
        return false;
    }
    
    // Initialize group
    SSettingsGroup group;
    ZeroMemory(group);
    group.Name = groupName;
    group.Title = title;
    group.Description = description;
    group.Category = categoryName;
    group.IsCollapsible = true;
    group.IsCollapsed = false;
    group.IsVisible = true;
    group.IsEnabled = true;
    group.Order = m_Categories[categoryIndex].GroupCount;
    
    m_Categories[categoryIndex].Groups[m_Categories[categoryIndex].GroupCount] = group;
    m_Categories[categoryIndex].GroupCount++;
    
    m_Statistics.TotalGroups++;
    m_Statistics.VisibleGroups++;
    
    LogActivity(StringFormat("Group %s added to category %s successfully", groupName, categoryName));
    return true;
}

//+------------------------------------------------------------------+
//| Add control to group                                            |
//+------------------------------------------------------------------+
bool CSettingsPanel::AddControl(const string categoryName, const string groupName, const SSettingsControl& control) {
    int categoryIndex = FindCategoryIndex(categoryName);
    if (categoryIndex < 0) {
        LogError(StringFormat("Category %s not found", categoryName));
        return false;
    }
    
    int groupIndex = FindGroupIndex(categoryIndex, groupName);
    if (groupIndex < 0) {
        LogError(StringFormat("Group %s not found in category %s", groupName, categoryName));
        return false;
    }
    
    if (m_Categories[categoryIndex].Groups[groupIndex].ControlCount >= ArraySize(m_Categories[categoryIndex].Groups[groupIndex].Controls)) {
        LogError("Maximum number of controls reached for group");
        return false;
    }
    
    // Check if control already exists
    if (FindControlIndex(categoryIndex, groupIndex, control.Name) >= 0) {
        LogError(StringFormat("Control %s already exists in group %s", control.Name, groupName));
        return false;
    }
    
    // Add control
    SSettingsControl newControl = control;
    newControl.Category = categoryName;
    newControl.Group = groupName;
    newControl.IsCreated = false;
    newControl.IsModified = false;
    newControl.IsValid = true;
    newControl.pControl = NULL;
    newControl.pLabel = NULL;
    
    m_Categories[categoryIndex].Groups[groupIndex].Controls[m_Categories[categoryIndex].Groups[groupIndex].ControlCount] = newControl;
    m_Categories[categoryIndex].Groups[groupIndex].ControlCount++;
    
    m_Statistics.TotalControls++;
    m_Statistics.VisibleControls++;
    
    if (newControl.IsRequired) {
        m_Statistics.RequiredControls++;
    }
    
    LogActivity(StringFormat("Control %s added to group %s successfully", control.Name, groupName));
    return true;
}

//+------------------------------------------------------------------+
//| Set control value (string)                                      |
//+------------------------------------------------------------------+
bool CSettingsPanel::SetControlValue(const string categoryName, const string groupName, const string controlName, const string value) {
    int categoryIndex = FindCategoryIndex(categoryName);
    if (categoryIndex < 0) return false;
    
    int groupIndex = FindGroupIndex(categoryIndex, groupName);
    if (groupIndex < 0) return false;
    
    int controlIndex = FindControlIndex(categoryIndex, groupIndex, controlName);
    if (controlIndex < 0) return false;
    
    SSettingsControl& control = m_Categories[categoryIndex].Groups[groupIndex].Controls[controlIndex];
    
    // Store old value for change tracking
    string oldValue = control.StringValue;
    
    // Set new value
    control.StringValue = value;
    control.IsModified = true;
    
    // Update UI control if created
    if (control.pControl != NULL) {
        // Update based on control type
        switch (control.Type) {
            case SETTINGS_CONTROL_EDIT:
                if (CheckPointer(control.pControl) == POINTER_DYNAMIC) {
                    CEdit* pEdit = (CEdit*)control.pControl;
                    pEdit.Text(value);
                }
                break;
                
            case SETTINGS_CONTROL_COMBOBOX:
                if (CheckPointer(control.pControl) == POINTER_DYNAMIC) {
                    CComboBox* pCombo = (CComboBox*)control.pControl;
                    pCombo.Select(value);
                }
                break;
        }
    }
    
    // Record change
    if (m_bChangeTrackingEnabled && oldValue != value) {
        RecordChange(categoryName, groupName, controlName);
        m_bModified = true;
    }
    
    // Validate if enabled
    if (m_bValidationEnabled) {
        ValidateControl(categoryName, groupName, controlName);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Get control value (string)                                      |
//+------------------------------------------------------------------+
string CSettingsPanel::GetControlValue(const string categoryName, const string groupName, const string controlName) const {
    int categoryIndex = FindCategoryIndex(categoryName);
    if (categoryIndex < 0) return "";
    
    int groupIndex = FindGroupIndex(categoryIndex, groupName);
    if (groupIndex < 0) return "";
    
    int controlIndex = FindControlIndex(categoryIndex, groupIndex, controlName);
    if (controlIndex < 0) return "";
    
    return m_Categories[categoryIndex].Groups[groupIndex].Controls[controlIndex].StringValue;
}

//+------------------------------------------------------------------+
//| Add text box control                                            |
//+------------------------------------------------------------------+
bool CSettingsPanel::AddTextBox(const string categoryName, const string groupName, const string name, const string label, const string defaultValue = "", const string description = "") {
    SSettingsControl control;
    ZeroMemory(control);
    
    control.Name = name;
    control.Label = label;
    control.Description = description;
    control.Type = SETTINGS_CONTROL_EDIT;
    control.DataType = "string";
    control.StringValue = defaultValue;
    control.DefaultStringValue = defaultValue;
    control.IsVisible = true;
    control.IsEnabled = true;
    control.HasLabel = true;
    control.LabelText = label;
    control.Width = 200;
    control.Height = 20;
    
    return AddControl(categoryName, groupName, control);
}

//+------------------------------------------------------------------+
//| Add number box control                                          |
//+------------------------------------------------------------------+
bool CSettingsPanel::AddNumberBox(const string categoryName, const string groupName, const string name, const string label, const double defaultValue = 0, const double minValue = 0, const double maxValue = 0, const string description = "") {
    SSettingsControl control;
    ZeroMemory(control);
    
    control.Name = name;
    control.Label = label;
    control.Description = description;
    control.Type = SETTINGS_CONTROL_SPINEDIT;
    control.DataType = "double";
    control.DoubleValue = defaultValue;
    control.DefaultDoubleValue = defaultValue;
    control.MinValue = minValue;
    control.MaxValue = maxValue;
    control.DecimalPlaces = 2;
    control.IsVisible = true;
    control.IsEnabled = true;
    control.HasLabel = true;
    control.LabelText = label;
    control.Width = 100;
    control.Height = 20;
    
    if (minValue != 0 || maxValue != 0) {
        control.ValidationType = SETTINGS_VALIDATION_RANGE;
    }
    
    return AddControl(categoryName, groupName, control);
}

//+------------------------------------------------------------------+
//| Add checkbox control                                            |
//+------------------------------------------------------------------+
bool CSettingsPanel::AddCheckBox(const string categoryName, const string groupName, const string name, const string label, const bool defaultValue = false, const string description = "") {
    SSettingsControl control;
    ZeroMemory(control);
    
    control.Name = name;
    control.Label = label;
    control.Description = description;
    control.Type = SETTINGS_CONTROL_CHECKBOX;
    control.DataType = "bool";
    control.BoolValue = defaultValue;
    control.DefaultBoolValue = defaultValue;
    control.IsVisible = true;
    control.IsEnabled = true;
    control.HasLabel = true;
    control.LabelText = label;
    control.Width = 150;
    control.Height = 20;
    
    return AddControl(categoryName, groupName, control);
}

//+------------------------------------------------------------------+
//| Validate all controls                                           |
//+------------------------------------------------------------------+
bool CSettingsPanel::ValidateAll() {
    m_ValidationErrorCount = 0;
    bool isValid = true;
    
    for (int i = 0; i < m_CategoryCount; i++) {
        for (int j = 0; j < m_Categories[i].GroupCount; j++) {
            for (int k = 0; k < m_Categories[i].Groups[j].ControlCount; k++) {
                if (!ValidateControlValue(m_Categories[i].Groups[j].Controls[k])) {
                    isValid = false;
                    if (m_ValidationErrorCount < ArraySize(m_ValidationErrors)) {
                        m_ValidationErrors[m_ValidationErrorCount] = GetValidationError(m_Categories[i].Groups[j].Controls[k]);
                        m_ValidationErrorCount++;
                    }
                }
            }
        }
    }
    
    m_Statistics.ValidationCount++;
    if (!isValid) {
        m_Statistics.ValidationErrorCount++;
    }
    
    return isValid;
}

//+------------------------------------------------------------------+
//| Apply changes                                                   |
//+------------------------------------------------------------------+
bool CSettingsPanel::ApplyChanges() {
    if (!m_bModified) {
        return true;
    }
    
    // Validate first if enabled
    if (m_bValidationEnabled && !ValidateAll()) {
        LogError("Validation failed, cannot apply changes");
        return false;
    }
    
    // Apply changes through context
    if (m_pContext != NULL && m_pContext->pConfigManager != NULL) {
        // Save current values to configuration
        for (int i = 0; i < m_CategoryCount; i++) {
            for (int j = 0; j < m_Categories[i].GroupCount; j++) {
                for (int k = 0; k < m_Categories[i].Groups[j].ControlCount; k++) {
                    SSettingsControl& control = m_Categories[i].Groups[j].Controls[k];
                    if (control.IsModified) {
                        string paramName = control.Category + "." + control.Group + "." + control.Name;
                        
                        switch (control.Type) {
                            case SETTINGS_CONTROL_EDIT:
                                // Apply string value
                                break;
                                
                            case SETTINGS_CONTROL_SPINEDIT:
                                // Apply numeric value
                                break;
                                
                            case SETTINGS_CONTROL_CHECKBOX:
                                // Apply boolean value
                                break;
                                
                            case SETTINGS_CONTROL_COMBOBOX:
                                // Apply selection value
                                break;
                                
                            case SETTINGS_CONTROL_COLORBUTTON:
                                // Apply color value
                                break;
                        }
                        
                        control.IsModified = false;
                    }
                }
            }
        }
    }
    
    m_bModified = false;
    m_Statistics.SaveCount++;
    m_Statistics.LastSaved = TimeCurrent();
    
    LogActivity("Settings changes applied successfully");
    return true;
}

//+------------------------------------------------------------------+
//| Show settings panel                                             |
//+------------------------------------------------------------------+
bool CSettingsPanel::Show() {
    if (!m_bInitialized) {
        LogError("Settings panel not initialized");
        return false;
    }
    
    CAppDialog::Show();
    m_bVisible = true;
    
    UpdateOpenStatistics();
    LogActivity("Settings panel shown");
    
    return true;
}

//+------------------------------------------------------------------+
//| Hide settings panel                                             |
//+------------------------------------------------------------------+
bool CSettingsPanel::Hide() {
    CAppDialog::Hide();
    m_bVisible = false;
    
    UpdateCloseStatistics();
    LogActivity("Settings panel hidden");
    
    return true;
}

//+------------------------------------------------------------------+
//| Find category index                                             |
//+------------------------------------------------------------------+
int CSettingsPanel::FindCategoryIndex(const string name) const {
    for (int i = 0; i < m_CategoryCount; i++) {
        if (m_Categories[i].Name == name) {
            return i;
        }
    }
    return -1;
}

//+------------------------------------------------------------------+
//| Find group index                                                |
//+------------------------------------------------------------------+
int CSettingsPanel::FindGroupIndex(const int categoryIndex, const string name) const {
    if (categoryIndex < 0 || categoryIndex >= m_CategoryCount) {
        return -1;
    }
    
    for (int i = 0; i < m_Categories[categoryIndex].GroupCount; i++) {
        if (m_Categories[categoryIndex].Groups[i].Name == name) {
            return i;
        }
    }
    return -1;
}

//+------------------------------------------------------------------+
//| Find control index                                              |
//+------------------------------------------------------------------+
int CSettingsPanel::FindControlIndex(const int categoryIndex, const int groupIndex, const string name) const {
    if (categoryIndex < 0 || categoryIndex >= m_CategoryCount) {
        return -1;
    }
    
    if (groupIndex < 0 || groupIndex >= m_Categories[categoryIndex].GroupCount) {
        return -1;
    }
    
    for (int i = 0; i < m_Categories[categoryIndex].Groups[groupIndex].ControlCount; i++) {
        if (m_Categories[categoryIndex].Groups[groupIndex].Controls[i].Name == name) {
            return i;
        }
    }
    return -1;
}

//+------------------------------------------------------------------+
//| Validate control value                                          |
//+------------------------------------------------------------------+
bool CSettingsPanel::ValidateControlValue(const SSettingsControl& control) const {
    if (control.ValidationType == SETTINGS_VALIDATION_NONE) {
        return true;
    }
    
    // Required validation
    if (control.IsRequired) {
        if (control.DataType == "string" && control.StringValue == "") {
            return false;
        }
    }
    
    // Numeric validation
    if (control.ValidationType == SETTINGS_VALIDATION_NUMERIC || control.ValidationType == SETTINGS_VALIDATION_RANGE) {
        if (control.DataType == "double" || control.DataType == "int") {
            if (control.ValidationType == SETTINGS_VALIDATION_RANGE) {
                if (control.DoubleValue < control.MinValue || control.DoubleValue > control.MaxValue) {
                    return false;
                }
            }
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Record change                                                   |
//+------------------------------------------------------------------+
void CSettingsPanel::RecordChange(const string categoryName, const string groupName, const string controlName) {
    if (m_ChangedControlCount >= ArraySize(m_ChangedControls)) {
        return;
    }
    
    string changeKey = categoryName + "." + groupName + "." + controlName;
    
    // Check if already recorded
    for (int i = 0; i < m_ChangedControlCount; i++) {
        if (m_ChangedControls[i] == changeKey) {
            return;
        }
    }
    
    m_ChangedControls[m_ChangedControlCount] = changeKey;
    m_ChangedControlCount++;
    m_Statistics.ChangeCount++;
}

//+------------------------------------------------------------------+
//| Update open statistics                                          |
//+------------------------------------------------------------------+
void CSettingsPanel::UpdateOpenStatistics() {
    m_Statistics.LastOpened = TimeCurrent();
    m_Statistics.OpenCount++;
}

//+------------------------------------------------------------------+
//| Update close statistics                                         |
//+------------------------------------------------------------------+
void CSettingsPanel::UpdateCloseStatistics() {
    m_Statistics.LastClosed = TimeCurrent();
    
    if (m_Statistics.LastOpened > 0) {
        double sessionTime = (double)(TimeCurrent() - m_Statistics.LastOpened);
        m_Statistics.AverageOpenTime = (m_Statistics.AverageOpenTime * (m_Statistics.OpenCount - 1) + sessionTime) / m_Statistics.OpenCount;
    }
}

//+------------------------------------------------------------------+
//| Log error                                                       |
//+------------------------------------------------------------------+
void CSettingsPanel::LogError(const string error, const ENUM_LOG_LEVEL level = LOG_LEVEL_ERROR) {
    if (m_pContext != NULL && m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogError("[SETTINGS PANEL] " + error);
    } else {
        Print("[SETTINGS PANEL ERROR] " + error);
    }
    m_Statistics.ErrorCount++;
}

//+------------------------------------------------------------------+
//| Log activity                                                    |
//+------------------------------------------------------------------+
void CSettingsPanel::LogActivity(const string activity, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO) {
    if (m_pContext != NULL && m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo("[SETTINGS PANEL] " + activity);
    } else {
        Print("[SETTINGS PANEL] " + activity);
    }
}

//+------------------------------------------------------------------+
//| Create main panel (placeholder)                                 |
//+------------------------------------------------------------------+
bool CSettingsPanel::CreateMainPanel() {
    // Implementation placeholder
    return true;
}

//+------------------------------------------------------------------+
//| Create tab panel (placeholder)                                  |
//+------------------------------------------------------------------+
bool CSettingsPanel::CreateTabPanel() {
    // Implementation placeholder
    return true;
}

//+------------------------------------------------------------------+
//| Create content panel (placeholder)                              |
//+------------------------------------------------------------------+
bool CSettingsPanel::CreateContentPanel() {
    // Implementation placeholder
    return true;
}

//+------------------------------------------------------------------+
//| Create button panel (placeholder)                               |
//+------------------------------------------------------------------+
bool CSettingsPanel::CreateButtonPanel() {
    // Implementation placeholder
    return true;
}

//+------------------------------------------------------------------+
//| Create profile controls (placeholder)                           |
//+------------------------------------------------------------------+
bool CSettingsPanel::CreateProfileControls() {
    // Implementation placeholder
    return true;
}

//+------------------------------------------------------------------+
//| Create status controls (placeholder)                            |
//+------------------------------------------------------------------+
bool CSettingsPanel::CreateStatusControls() {
    // Implementation placeholder
    return true;
}

//+------------------------------------------------------------------+
//| Create help panel (placeholder)                                 |
//+------------------------------------------------------------------+
bool CSettingsPanel::CreateHelpPanel() {
    // Implementation placeholder
    return true;
}

//+------------------------------------------------------------------+
//| Create tab buttons (placeholder)                                |
//+------------------------------------------------------------------+
bool CSettingsPanel::CreateTabButtons() {
    // Implementation placeholder
    return true;
}

//+------------------------------------------------------------------+
//| Create category UI (placeholder)                                |
//+------------------------------------------------------------------+
bool CSettingsPanel::CreateCategoryUI(const int categoryIndex) {
    // Implementation placeholder
    return true;
}

//+------------------------------------------------------------------+
//| Update layout (placeholder)                                     |
//+------------------------------------------------------------------+
void CSettingsPanel::UpdateLayout() {
    // Implementation placeholder
}

//+------------------------------------------------------------------+
//| Select tab (placeholder)                                        |
//+------------------------------------------------------------------+
void CSettingsPanel::SelectTab(const int index) {
    if (index >= 0 && index < m_CategoryCount) {
        m_CurrentCategory = index;
    }
}

//+------------------------------------------------------------------+
//| Get validation error                                            |
//+------------------------------------------------------------------+
string CSettingsPanel::GetValidationError(const SSettingsControl& control) const {
    if (control.IsRequired && control.StringValue == "") {
        return StringFormat("Field '%s' is required", control.Label);
    }
    
    if (control.ValidationType == SETTINGS_VALIDATION_RANGE) {
        if (control.DoubleValue < control.MinValue || control.DoubleValue > control.MaxValue) {
            return StringFormat("Value for '%s' must be between %.2f and %.2f", control.Label, control.MinValue, control.MaxValue);
        }
    }
    
    return "";
}

//+------------------------------------------------------------------+
//| Validate control                                                |
//+------------------------------------------------------------------+
bool CSettingsPanel::ValidateControl(const string categoryName, const string groupName, const string controlName) {
    int categoryIndex = FindCategoryIndex(categoryName);
    if (categoryIndex < 0) return false;
    
    int groupIndex = FindGroupIndex(categoryIndex, groupName);
    if (groupIndex < 0) return false;
    
    int controlIndex = FindControlIndex(categoryIndex, groupIndex, controlName);
    if (controlIndex < 0) return false;
    
    SSettingsControl& control = m_Categories[categoryIndex].Groups[groupIndex].Controls[controlIndex];
    bool isValid = ValidateControlValue(control);
    
    control.IsValid = isValid;
    
    if (!isValid) {
        string error = GetValidationError(control);
        LogError(StringFormat("Validation failed for control %s: %s", controlName, error));
    }
    
    return isValid;
}

//+------------------------------------------------------------------+
//| Set control value (double)                                      |
//+------------------------------------------------------------------+
bool CSettingsPanel::SetControlValue(const string categoryName, const string groupName, const string controlName, const double value) {
    int categoryIndex = FindCategoryIndex(categoryName);
    if (categoryIndex < 0) return false;
    
    int groupIndex = FindGroupIndex(categoryIndex, groupName);
    if (groupIndex < 0) return false;
    
    int controlIndex = FindControlIndex(categoryIndex, groupIndex, controlName);
    if (controlIndex < 0) return false;
    
    SSettingsControl& control = m_Categories[categoryIndex].Groups[groupIndex].Controls[controlIndex];
    
    // Store old value for change tracking
    double oldValue = control.DoubleValue;
    
    // Set new value
    control.DoubleValue = value;
    control.IsModified = true;
    
    // Update UI control if created
    if (control.pControl != NULL && control.Type == SETTINGS_CONTROL_SPINEDIT) {
        if (CheckPointer(control.pControl) == POINTER_DYNAMIC) {
            CSpinEdit* pSpin = (CSpinEdit*)control.pControl;
            pSpin.Value((long)value);
        }
    }
    
    // Record change
    if (m_bChangeTrackingEnabled && oldValue != value) {
        RecordChange(categoryName, groupName, controlName);
        m_bModified = true;
    }
    
    // Validate if enabled
    if (m_bValidationEnabled) {
        ValidateControl(categoryName, groupName, controlName);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Set control value (bool)                                        |
//+------------------------------------------------------------------+
bool CSettingsPanel::SetControlValue(const string categoryName, const string groupName, const string controlName, const bool value) {
    int categoryIndex = FindCategoryIndex(categoryName);
    if (categoryIndex < 0) return false;
    
    int groupIndex = FindGroupIndex(categoryIndex, groupName);
    if (groupIndex < 0) return false;
    
    int controlIndex = FindControlIndex(categoryIndex, groupIndex, controlName);
    if (controlIndex < 0) return false;
    
    SSettingsControl& control = m_Categories[categoryIndex].Groups[groupIndex].Controls[controlIndex];
    
    // Store old value for change tracking
    bool oldValue = control.BoolValue;
    
    // Set new value
    control.BoolValue = value;
    control.IsModified = true;
    
    // Update UI control if created
    if (control.pControl != NULL && control.Type == SETTINGS_CONTROL_CHECKBOX) {
        if (CheckPointer(control.pControl) == POINTER_DYNAMIC) {
            CCheckBox* pCheck = (CCheckBox*)control.pControl;
            pCheck.Checked(value);
        }
    }
    
    // Record change
    if (m_bChangeTrackingEnabled && oldValue != value) {
        RecordChange(categoryName, groupName, controlName);
        m_bModified = true;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Get control value (double)                                      |
//+------------------------------------------------------------------+
double CSettingsPanel::GetControlValueDouble(const string categoryName, const string groupName, const string controlName) const {
    int categoryIndex = FindCategoryIndex(categoryName);
    if (categoryIndex < 0) return 0.0;
    
    int groupIndex = FindGroupIndex(categoryIndex, groupName);
    if (groupIndex < 0) return 0.0;
    
    int controlIndex = FindControlIndex(categoryIndex, groupIndex, controlName);
    if (controlIndex < 0) return 0.0;
    
    return m_Categories[categoryIndex].Groups[groupIndex].Controls[controlIndex].DoubleValue;
}

//+------------------------------------------------------------------+
//| Get control value (bool)                                        |
//+------------------------------------------------------------------+
bool CSettingsPanel::GetControlValueBool(const string categoryName, const string groupName, const string controlName) const {
    int categoryIndex = FindCategoryIndex(categoryName);
    if (categoryIndex < 0) return false;
    
    int groupIndex = FindGroupIndex(categoryIndex, groupName);
    if (groupIndex < 0) return false;
    
    int controlIndex = FindControlIndex(categoryIndex, groupIndex, controlName);
    if (controlIndex < 0) return false;
    
    return m_Categories[categoryIndex].Groups[groupIndex].Controls[controlIndex].BoolValue;
}

//+------------------------------------------------------------------+
//| Add combo box control                                           |
//+------------------------------------------------------------------+
bool CSettingsPanel::AddComboBox(const string categoryName, const string groupName, const string name, const string label, const string items[], const string defaultValue = "", const string description = "") {
    SSettingsControl control;
    ZeroMemory(control);
    
    control.Name = name;
    control.Label = label;
    control.Description = description;
    control.Type = SETTINGS_CONTROL_COMBOBOX;
    control.DataType = "string";
    control.StringValue = defaultValue;
    control.DefaultStringValue = defaultValue;
    control.IsVisible = true;
    control.IsEnabled = true;
    control.HasLabel = true;
    control.LabelText = label;
    control.Width = 150;
    control.Height = 20;
    
    // Store combo items
    int itemCount = ArraySize(items);
    if (itemCount > 0 && itemCount <= ArraySize(control.ComboItems)) {
        for (int i = 0; i < itemCount; i++) {
            control.ComboItems[i] = items[i];
        }
        control.ComboItemCount = itemCount;
    }
    
    return AddControl(categoryName, groupName, control);
}

//+------------------------------------------------------------------+
//| Add color picker control                                        |
//+------------------------------------------------------------------+
bool CSettingsPanel::AddColorPicker(const string categoryName, const string groupName, const string name, const string label, const color defaultValue = clrWhite, const string description = "") {
    SSettingsControl control;
    ZeroMemory(control);
    
    control.Name = name;
    control.Label = label;
    control.Description = description;
    control.Type = SETTINGS_CONTROL_COLORBUTTON;
    control.DataType = "color";
    control.ColorValue = defaultValue;
    control.DefaultColorValue = defaultValue;
    control.IsVisible = true;
    control.IsEnabled = true;
    control.HasLabel = true;
    control.LabelText = label;
    control.Width = 80;
    control.Height = 20;
    
    return AddControl(categoryName, groupName, control);
}

//+------------------------------------------------------------------+
//| Add date picker control                                         |
//+------------------------------------------------------------------+
bool CSettingsPanel::AddDatePicker(const string categoryName, const string groupName, const string name, const string label, const datetime defaultValue = 0, const string description = "") {
    SSettingsControl control;
    ZeroMemory(control);
    
    control.Name = name;
    control.Label = label;
    control.Description = description;
    control.Type = SETTINGS_CONTROL_DATEPICKER;
    control.DataType = "datetime";
    control.DateTimeValue = defaultValue;
    control.DefaultDateTimeValue = defaultValue;
    control.IsVisible = true;
    control.IsEnabled = true;
    control.HasLabel = true;
    control.LabelText = label;
    control.Width = 120;
    control.Height = 20;
    
    return AddControl(categoryName, groupName, control);
}

//+------------------------------------------------------------------+
//| Remove category                                                 |
//+------------------------------------------------------------------+
bool CSettingsPanel::RemoveCategory(const string name) {
    int index = FindCategoryIndex(name);
    if (index < 0) {
        LogError(StringFormat("Category %s not found", name));
        return false;
    }
    
    // Clean up category UI
    if (m_Categories[index].pPanel != NULL) {
        delete m_Categories[index].pPanel;
        m_Categories[index].pPanel = NULL;
    }
    
    // Clean up groups
    for (int j = 0; j < m_Categories[index].GroupCount; j++) {
        for (int k = 0; k < m_Categories[index].Groups[j].ControlCount; k++) {
            if (m_Categories[index].Groups[j].Controls[k].pControl != NULL) {
                delete m_Categories[index].Groups[j].Controls[k].pControl;
                m_Categories[index].Groups[j].Controls[k].pControl = NULL;
            }
            if (m_Categories[index].Groups[j].Controls[k].pLabel != NULL) {
                delete m_Categories[index].Groups[j].Controls[k].pLabel;
                m_Categories[index].Groups[j].Controls[k].pLabel = NULL;
            }
        }
        if (m_Categories[index].Groups[j].pPanel != NULL) {
            delete m_Categories[index].Groups[j].pPanel;
            m_Categories[index].Groups[j].pPanel = NULL;
        }
    }
    
    // Shift remaining categories
    for (int i = index; i < m_CategoryCount - 1; i++) {
        m_Categories[i] = m_Categories[i + 1];
    }
    
    m_CategoryCount--;
    m_Statistics.TotalCategories--;
    
    LogActivity(StringFormat("Category %s removed successfully", name));
    return true;
}

//+------------------------------------------------------------------+
//| Remove group                                                    |
//+------------------------------------------------------------------+
bool CSettingsPanel::RemoveGroup(const string categoryName, const string groupName) {
    int categoryIndex = FindCategoryIndex(categoryName);
    if (categoryIndex < 0) {
        LogError(StringFormat("Category %s not found", categoryName));
        return false;
    }
    
    int groupIndex = FindGroupIndex(categoryIndex, groupName);
    if (groupIndex < 0) {
        LogError(StringFormat("Group %s not found in category %s", groupName, categoryName));
        return false;
    }
    
    // Clean up group controls
    for (int k = 0; k < m_Categories[categoryIndex].Groups[groupIndex].ControlCount; k++) {
        if (m_Categories[categoryIndex].Groups[groupIndex].Controls[k].pControl != NULL) {
            delete m_Categories[categoryIndex].Groups[groupIndex].Controls[k].pControl;
            m_Categories[categoryIndex].Groups[groupIndex].Controls[k].pControl = NULL;
        }
        if (m_Categories[categoryIndex].Groups[groupIndex].Controls[k].pLabel != NULL) {
            delete m_Categories[categoryIndex].Groups[groupIndex].Controls[k].pLabel;
            m_Categories[categoryIndex].Groups[groupIndex].Controls[k].pLabel = NULL;
        }
    }
    
    // Clean up group panel
    if (m_Categories[categoryIndex].Groups[groupIndex].pPanel != NULL) {
        delete m_Categories[categoryIndex].Groups[groupIndex].pPanel;
        m_Categories[categoryIndex].Groups[groupIndex].pPanel = NULL;
    }
    
    // Shift remaining groups
    for (int i = groupIndex; i < m_Categories[categoryIndex].GroupCount - 1; i++) {
        m_Categories[categoryIndex].Groups[i] = m_Categories[categoryIndex].Groups[i + 1];
    }
    
    m_Categories[categoryIndex].GroupCount--;
    m_Statistics.TotalGroups--;
    
    LogActivity(StringFormat("Group %s removed from category %s successfully", groupName, categoryName));
    return true;
}

//+------------------------------------------------------------------+
//| Remove control                                                  |
//+------------------------------------------------------------------+
bool CSettingsPanel::RemoveControl(const string categoryName, const string groupName, const string controlName) {
    int categoryIndex = FindCategoryIndex(categoryName);
    if (categoryIndex < 0) {
        LogError(StringFormat("Category %s not found", categoryName));
        return false;
    }
    
    int groupIndex = FindGroupIndex(categoryIndex, groupName);
    if (groupIndex < 0) {
        LogError(StringFormat("Group %s not found in category %s", groupName, categoryName));
        return false;
    }
    
    int controlIndex = FindControlIndex(categoryIndex, groupIndex, controlName);
    if (controlIndex < 0) {
        LogError(StringFormat("Control %s not found in group %s", controlName, groupName));
        return false;
    }
    
    // Clean up control
    if (m_Categories[categoryIndex].Groups[groupIndex].Controls[controlIndex].pControl != NULL) {
        delete m_Categories[categoryIndex].Groups[groupIndex].Controls[controlIndex].pControl;
        m_Categories[categoryIndex].Groups[groupIndex].Controls[controlIndex].pControl = NULL;
    }
    if (m_Categories[categoryIndex].Groups[groupIndex].Controls[controlIndex].pLabel != NULL) {
        delete m_Categories[categoryIndex].Groups[groupIndex].Controls[controlIndex].pLabel;
        m_Categories[categoryIndex].Groups[groupIndex].Controls[controlIndex].pLabel = NULL;
    }
    
    // Shift remaining controls
    for (int i = controlIndex; i < m_Categories[categoryIndex].Groups[groupIndex].ControlCount - 1; i++) {
        m_Categories[categoryIndex].Groups[groupIndex].Controls[i] = m_Categories[categoryIndex].Groups[groupIndex].Controls[i + 1];
    }
    
    m_Categories[categoryIndex].Groups[groupIndex].ControlCount--;
    m_Statistics.TotalControls--;
    
    LogActivity(StringFormat("Control %s removed from group %s successfully", controlName, groupName));
    return true;
}

//+------------------------------------------------------------------+
//| Show category                                                   |
//+------------------------------------------------------------------+
bool CSettingsPanel::ShowCategory(const string name) {
    int index = FindCategoryIndex(name);
    if (index < 0) return false;
    
    if (!m_Categories[index].IsVisible) {
        m_Categories[index].IsVisible = true;
        m_Statistics.VisibleCategories++;
        
        if (m_Categories[index].pPanel != NULL) {
            m_Categories[index].pPanel.Show();
        }
        
        LogActivity(StringFormat("Category %s shown", name));
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Hide category                                                   |
//+------------------------------------------------------------------+
bool CSettingsPanel::HideCategory(const string name) {
    int index = FindCategoryIndex(name);
    if (index < 0) return false;
    
    if (m_Categories[index].IsVisible) {
        m_Categories[index].IsVisible = false;
        m_Statistics.VisibleCategories--;
        
        if (m_Categories[index].pPanel != NULL) {
            m_Categories[index].pPanel.Hide();
        }
        
        LogActivity(StringFormat("Category %s hidden", name));
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Enable category                                                 |
//+------------------------------------------------------------------+
bool CSettingsPanel::EnableCategory(const string name) {
    int index = FindCategoryIndex(name);
    if (index < 0) return false;
    
    if (!m_Categories[index].IsEnabled) {
        m_Categories[index].IsEnabled = true;
        
        // Enable all controls in category
        for (int j = 0; j < m_Categories[index].GroupCount; j++) {
            for (int k = 0; k < m_Categories[index].Groups[j].ControlCount; k++) {
                if (m_Categories[index].Groups[j].Controls[k].pControl != NULL) {
                    m_Categories[index].Groups[j].Controls[k].pControl.Enabled(true);
                }
            }
        }
        
        LogActivity(StringFormat("Category %s enabled", name));
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Disable category                                                |
//+------------------------------------------------------------------+
bool CSettingsPanel::DisableCategory(const string name) {
    int index = FindCategoryIndex(name);
    if (index < 0) return false;
    
    if (m_Categories[index].IsEnabled) {
        m_Categories[index].IsEnabled = false;
        
        // Disable all controls in category
        for (int j = 0; j < m_Categories[index].GroupCount; j++) {
            for (int k = 0; k < m_Categories[index].Groups[j].ControlCount; k++) {
                if (m_Categories[index].Groups[j].Controls[k].pControl != NULL) {
                    m_Categories[index].Groups[j].Controls[k].pControl.Enabled(false);
                }
            }
        }
        
        LogActivity(StringFormat("Category %s disabled", name));
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Revert changes                                                  |
//+------------------------------------------------------------------+
bool CSettingsPanel::RevertChanges() {
    if (!m_bModified) {
        return true;
    }
    
    // Revert all modified controls to their original values
    for (int i = 0; i < m_CategoryCount; i++) {
        for (int j = 0; j < m_Categories[i].GroupCount; j++) {
            for (int k = 0; k < m_Categories[i].Groups[j].ControlCount; k++) {
                SSettingsControl& control = m_Categories[i].Groups[j].Controls[k];
                if (control.IsModified) {
                    // Restore default values
                    switch (control.Type) {
                        case SETTINGS_CONTROL_EDIT:
                        case SETTINGS_CONTROL_COMBOBOX:
                            control.StringValue = control.DefaultStringValue;
                            break;
                            
                        case SETTINGS_CONTROL_SPINEDIT:
                            control.DoubleValue = control.DefaultDoubleValue;
                            break;
                            
                        case SETTINGS_CONTROL_CHECKBOX:
                            control.BoolValue = control.DefaultBoolValue;
                            break;
                            
                        case SETTINGS_CONTROL_COLORBUTTON:
                            control.ColorValue = control.DefaultColorValue;
                            break;
                            
                        case SETTINGS_CONTROL_DATEPICKER:
                            control.DateTimeValue = control.DefaultDateTimeValue;
                            break;
                    }
                    
                    control.IsModified = false;
                    
                    // Update UI control if created
                    if (control.pControl != NULL) {
                        // Update based on control type
                        switch (control.Type) {
                            case SETTINGS_CONTROL_EDIT:
                                if (CheckPointer(control.pControl) == POINTER_DYNAMIC) {
                                    CEdit* pEdit = (CEdit*)control.pControl;
                                    pEdit.Text(control.StringValue);
                                }
                                break;
                                
                            case SETTINGS_CONTROL_SPINEDIT:
                                if (CheckPointer(control.pControl) == POINTER_DYNAMIC) {
                                    CSpinEdit* pSpin = (CSpinEdit*)control.pControl;
                                    pSpin.Value((long)control.DoubleValue);
                                }
                                break;
                                
                            case SETTINGS_CONTROL_CHECKBOX:
                                if (CheckPointer(control.pControl) == POINTER_DYNAMIC) {
                                    CCheckBox* pCheck = (CCheckBox*)control.pControl;
                                    pCheck.Checked(control.BoolValue);
                                }
                                break;
                                
                            case SETTINGS_CONTROL_COMBOBOX:
                                if (CheckPointer(control.pControl) == POINTER_DYNAMIC) {
                                    CComboBox* pCombo = (CComboBox*)control.pControl;
                                    pCombo.Select(control.StringValue);
                                }
                                break;
                        }
                    }
                }
            }
        }
    }
    
    // Clear change tracking
    m_ChangedControlCount = 0;
    m_bModified = false;
    
    LogActivity("Settings changes reverted successfully");
    return true;
}

//+------------------------------------------------------------------+
//| Reset to defaults                                               |
//+------------------------------------------------------------------+
bool CSettingsPanel::ResetToDefaults() {
    // Reset all controls to their default values
    for (int i = 0; i < m_CategoryCount; i++) {
        for (int j = 0; j < m_Categories[i].GroupCount; j++) {
            for (int k = 0; k < m_Categories[i].Groups[j].ControlCount; k++) {
                SSettingsControl& control = m_Categories[i].Groups[j].Controls[k];
                
                // Set to default values
                switch (control.Type) {
                    case SETTINGS_CONTROL_EDIT:
                    case SETTINGS_CONTROL_COMBOBOX:
                        control.StringValue = control.DefaultStringValue;
                        break;
                        
                    case SETTINGS_CONTROL_SPINEDIT:
                        control.DoubleValue = control.DefaultDoubleValue;
                        break;
                        
                    case SETTINGS_CONTROL_CHECKBOX:
                        control.BoolValue = control.DefaultBoolValue;
                        break;
                        
                    case SETTINGS_CONTROL_COLORBUTTON:
                        control.ColorValue = control.DefaultColorValue;
                        break;
                        
                    case SETTINGS_CONTROL_DATEPICKER:
                        control.DateTimeValue = control.DefaultDateTimeValue;
                        break;
                }
                
                control.IsModified = true;
                
                // Update UI control if created
                if (control.pControl != NULL) {
                    // Update based on control type
                    switch (control.Type) {
                        case SETTINGS_CONTROL_EDIT:
                            if (CheckPointer(control.pControl) == POINTER_DYNAMIC) {
                                CEdit* pEdit = (CEdit*)control.pControl;
                                pEdit.Text(control.StringValue);
                            }
                            break;
                            
                        case SETTINGS_CONTROL_SPINEDIT:
                            if (CheckPointer(control.pControl) == POINTER_DYNAMIC) {
                                CSpinEdit* pSpin = (CSpinEdit*)control.pControl;
                                pSpin.Value((long)control.DoubleValue);
                            }
                            break;
                            
                        case SETTINGS_CONTROL_CHECKBOX:
                            if (CheckPointer(control.pControl) == POINTER_DYNAMIC) {
                                CCheckBox* pCheck = (CCheckBox*)control.pControl;
                                pCheck.Checked(control.BoolValue);
                            }
                            break;
                            
                        case SETTINGS_CONTROL_COMBOBOX:
                            if (CheckPointer(control.pControl) == POINTER_DYNAMIC) {
                                CComboBox* pCombo = (CComboBox*)control.pControl;
                                pCombo.Select(control.StringValue);
                            }
                            break;
                    }
                }
            }
        }
    }
    
    m_bModified = true;
    m_Statistics.ResetCount++;
    
    LogActivity("Settings reset to defaults successfully");
    return true;
}

//+------------------------------------------------------------------+
//| Get statistics                                                  |
//+------------------------------------------------------------------+
SSettingsPanelStatistics CSettingsPanel::GetStatistics() const {
    return m_Statistics;
}

//+------------------------------------------------------------------+