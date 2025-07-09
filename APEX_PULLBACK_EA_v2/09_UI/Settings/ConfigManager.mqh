//+------------------------------------------------------------------+
//|                                                ConfigManager.mqh |
//|                                    APEX Pullback EA v5.0 FINAL   |
//|                                    Configuration Management      |
//+------------------------------------------------------------------+
#property copyright "APEX Trading Systems"
#property version   "5.00"
#property strict

#include "../../00_Core/CommonStructs.mqh"

//+------------------------------------------------------------------+
//| Configuration type enumeration                                  |
//+------------------------------------------------------------------+
enum ENUM_CONFIG_TYPE {
    CONFIG_TYPE_TRADING,
    CONFIG_TYPE_RISK,
    CONFIG_TYPE_UI,
    CONFIG_TYPE_ALERTS,
    CONFIG_TYPE_LOGGING,
    CONFIG_TYPE_PERFORMANCE,
    CONFIG_TYPE_ANALYTICS,
    CONFIG_TYPE_SYSTEM,
    CONFIG_TYPE_CUSTOM
};

//+------------------------------------------------------------------+
//| Configuration scope enumeration                                 |
//+------------------------------------------------------------------+
enum ENUM_CONFIG_SCOPE {
    CONFIG_SCOPE_GLOBAL,
    CONFIG_SCOPE_SYMBOL,
    CONFIG_SCOPE_TIMEFRAME,
    CONFIG_SCOPE_SESSION,
    CONFIG_SCOPE_USER,
    CONFIG_SCOPE_TEMPORARY
};

//+------------------------------------------------------------------+
//| Configuration format enumeration                                |
//+------------------------------------------------------------------+
enum ENUM_CONFIG_FORMAT {
    CONFIG_FORMAT_INI,
    CONFIG_FORMAT_JSON,
    CONFIG_FORMAT_XML,
    CONFIG_FORMAT_BINARY,
    CONFIG_FORMAT_CSV,
    CONFIG_FORMAT_REGISTRY
};

//+------------------------------------------------------------------+
//| Configuration status enumeration                                |
//+------------------------------------------------------------------+
enum ENUM_CONFIG_STATUS {
    CONFIG_STATUS_LOADED,
    CONFIG_STATUS_MODIFIED,
    CONFIG_STATUS_SAVED,
    CONFIG_STATUS_ERROR,
    CONFIG_STATUS_LOCKED,
    CONFIG_STATUS_READONLY
};

//+------------------------------------------------------------------+
//| Configuration validation level enumeration                      |
//+------------------------------------------------------------------+
enum ENUM_CONFIG_VALIDATION {
    CONFIG_VALIDATION_NONE,
    CONFIG_VALIDATION_BASIC,
    CONFIG_VALIDATION_STRICT,
    CONFIG_VALIDATION_CUSTOM
};

//+------------------------------------------------------------------+
//| Configuration parameter structure                               |
//+------------------------------------------------------------------+
struct SConfigParameter {
    string Name;
    string Description;
    string Category;
    string Section;
    
    // Value information
    string StringValue;
    double DoubleValue;
    int IntValue;
    bool BoolValue;
    datetime DateTimeValue;
    color ColorValue;
    
    // Type and constraints
    string DataType; // "string", "double", "int", "bool", "datetime", "color"
    double MinValue;
    double MaxValue;
    string AllowedValues[50];
    int AllowedValueCount;
    
    // Metadata
    bool IsRequired;
    bool IsReadOnly;
    bool IsHidden;
    bool IsAdvanced;
    bool RequiresRestart;
    
    // Default values
    string DefaultStringValue;
    double DefaultDoubleValue;
    int DefaultIntValue;
    bool DefaultBoolValue;
    datetime DefaultDateTimeValue;
    color DefaultColorValue;
    
    // Validation
    string ValidationPattern;
    string ValidationMessage;
    ENUM_CONFIG_VALIDATION ValidationLevel;
    
    // UI information
    string UIControl; // "textbox", "combobox", "checkbox", "slider", "colorpicker", "datepicker"
    string UIGroup;
    int UIOrder;
    string UITooltip;
    
    // History
    datetime LastModified;
    string ModifiedBy;
    string ChangeReason;
    
    // Dependencies
    string DependentParameters[20];
    int DependentParameterCount;
    string ConditionalExpression;
};

//+------------------------------------------------------------------+
//| Configuration profile structure                                 |
//+------------------------------------------------------------------+
struct SConfigProfile {
    string Name;
    string Description;
    string Author;
    string Version;
    datetime CreatedDate;
    datetime ModifiedDate;
    
    ENUM_CONFIG_TYPE Type;
    ENUM_CONFIG_SCOPE Scope;
    ENUM_CONFIG_STATUS Status;
    
    // Parameters
    SConfigParameter Parameters[500];
    int ParameterCount;
    
    // File information
    string FilePath;
    ENUM_CONFIG_FORMAT Format;
    string Checksum;
    
    // Metadata
    string Tags[20];
    int TagCount;
    string Category;
    int Priority;
    
    // Validation
    bool IsValid;
    string ValidationErrors[50];
    int ValidationErrorCount;
    
    // Backup information
    string BackupPath;
    datetime LastBackup;
    bool AutoBackup;
    
    // Access control
    bool IsLocked;
    string LockedBy;
    datetime LockTime;
    
    // Usage statistics
    int LoadCount;
    int SaveCount;
    datetime LastAccessed;
    double AverageLoadTime;
};

//+------------------------------------------------------------------+
//| Configuration template structure                                |
//+------------------------------------------------------------------+
struct SConfigTemplate {
    string Name;
    string Description;
    string Category;
    ENUM_CONFIG_TYPE Type;
    
    // Template parameters
    SConfigParameter TemplateParameters[200];
    int TemplateParameterCount;
    
    // Template metadata
    string Author;
    string Version;
    datetime CreatedDate;
    bool IsBuiltIn;
    bool IsCustomizable;
    
    // Usage information
    int UsageCount;
    double Rating;
    string Comments[10];
    int CommentCount;
};

//+------------------------------------------------------------------+
//| Configuration change structure                                  |
//+------------------------------------------------------------------+
struct SConfigChange {
    datetime Timestamp;
    string ParameterName;
    string OldValue;
    string NewValue;
    string ChangedBy;
    string Reason;
    string ProfileName;
    ENUM_CONFIG_TYPE ConfigType;
};

//+------------------------------------------------------------------+
//| Configuration statistics structure                              |
//+------------------------------------------------------------------+
struct SConfigStats {
    int TotalProfiles;
    int LoadedProfiles;
    int ModifiedProfiles;
    int ErrorProfiles;
    
    int ProfilesByType[9];
    int ProfilesByScope[6];
    int ProfilesByStatus[6];
    
    int TotalParameters;
    int ModifiedParameters;
    int InvalidParameters;
    
    datetime LastLoad;
    datetime LastSave;
    datetime LastValidation;
    
    double AverageLoadTime;
    double AverageSaveTime;
    double AverageValidationTime;
    
    int LoadOperations;
    int SaveOperations;
    int ValidationOperations;
    int ErrorOperations;
    
    // Change tracking
    int TotalChanges;
    datetime LastChange;
    string MostChangedParameter;
    int MostChangedParameterCount;
    
    // Performance metrics
    double MemoryUsageMB;
    int CacheHits;
    int CacheMisses;
    double CacheHitRatio;
};

//+------------------------------------------------------------------+
//| Configuration manager class                                     |
//+------------------------------------------------------------------+
class CConfigManager {
private:
    EAContext* m_pContext;
    
    // Configuration storage
    SConfigProfile m_Profiles[100];
    int m_ProfileCount;
    
    // Templates
    SConfigTemplate m_Templates[50];
    int m_TemplateCount;
    
    // Change history
    SConfigChange m_Changes[1000];
    int m_ChangeCount;
    
    // Statistics
    SConfigStats m_Statistics;
    
    // Current state
    string m_CurrentProfile;
    bool m_bInitialized;
    bool m_bAutoSave;
    bool m_bAutoBackup;
    
    // Cache
    string m_CachedProfileNames[100];
    int m_CachedProfileCount;
    
    // Validation
    bool m_bValidationEnabled;
    ENUM_CONFIG_VALIDATION m_DefaultValidationLevel;
    
    // File management
    string m_ConfigDirectory;
    string m_BackupDirectory;
    string m_TemplateDirectory;
    
    // Error handling
    string m_LastError;
    int m_ErrorCount;
    
public:
    CConfigManager();
    ~CConfigManager();
    
    // Core methods
    bool Initialize(EAContext* context);
    void Deinitialize();
    void Update();
    
    // Profile management
    bool CreateProfile(const string name, const ENUM_CONFIG_TYPE type, const ENUM_CONFIG_SCOPE scope);
    bool LoadProfile(const string name);
    bool SaveProfile(const string name = "");
    bool DeleteProfile(const string name);
    bool CopyProfile(const string sourceName, const string targetName);
    bool RenameProfile(const string oldName, const string newName);
    bool ExportProfile(const string name, const string filePath, const ENUM_CONFIG_FORMAT format = CONFIG_FORMAT_INI);
    bool ImportProfile(const string filePath, const string profileName = "");
    
    // Profile queries
    string[] GetProfileNames() const;
    string[] GetProfilesByType(const ENUM_CONFIG_TYPE type) const;
    string[] GetProfilesByScope(const ENUM_CONFIG_SCOPE scope) const;
    SConfigProfile GetProfile(const string name) const;
    bool ProfileExists(const string name) const;
    string GetCurrentProfile() const { return m_CurrentProfile; }
    
    // Parameter management
    bool SetParameter(const string parameterName, const string value, const string profileName = "");
    bool SetParameterDouble(const string parameterName, const double value, const string profileName = "");
    bool SetParameterInt(const string parameterName, const int value, const string profileName = "");
    bool SetParameterBool(const string parameterName, const bool value, const string profileName = "");
    bool SetParameterDateTime(const string parameterName, const datetime value, const string profileName = "");
    bool SetParameterColor(const string parameterName, const color value, const string profileName = "");
    
    string GetParameter(const string parameterName, const string profileName = "") const;
    double GetParameterDouble(const string parameterName, const string profileName = "") const;
    int GetParameterInt(const string parameterName, const string profileName = "") const;
    bool GetParameterBool(const string parameterName, const string profileName = "") const;
    datetime GetParameterDateTime(const string parameterName, const string profileName = "") const;
    color GetParameterColor(const string parameterName, const string profileName = "") const;
    
    bool ParameterExists(const string parameterName, const string profileName = "") const;
    bool RemoveParameter(const string parameterName, const string profileName = "");
    
    // Parameter definition
    bool DefineParameter(const string name, const string dataType, const string defaultValue, const string description = "", const string category = "", const string profileName = "");
    bool DefineParameterDouble(const string name, const double defaultValue, const double minValue = 0, const double maxValue = 0, const string description = "", const string category = "", const string profileName = "");
    bool DefineParameterInt(const string name, const int defaultValue, const int minValue = 0, const int maxValue = 0, const string description = "", const string category = "", const string profileName = "");
    bool DefineParameterBool(const string name, const bool defaultValue, const string description = "", const string category = "", const string profileName = "");
    bool DefineParameterEnum(const string name, const string allowedValues[], const int valueCount, const string defaultValue, const string description = "", const string category = "", const string profileName = "");
    
    // Parameter metadata
    bool SetParameterMetadata(const string parameterName, const string description, const string category, const bool isRequired = false, const bool isReadOnly = false, const string profileName = "");
    bool SetParameterUI(const string parameterName, const string uiControl, const string uiGroup, const int uiOrder, const string uiTooltip = "", const string profileName = "");
    bool SetParameterValidation(const string parameterName, const string validationPattern, const string validationMessage, const ENUM_CONFIG_VALIDATION validationLevel = CONFIG_VALIDATION_BASIC, const string profileName = "");
    bool SetParameterDependencies(const string parameterName, const string dependentParameters[], const int dependentCount, const string conditionalExpression = "", const string profileName = "");
    
    // Parameter queries
    string[] GetParameterNames(const string profileName = "") const;
    string[] GetParametersByCategory(const string category, const string profileName = "") const;
    string[] GetParametersByType(const string dataType, const string profileName = "") const;
    SConfigParameter GetParameterInfo(const string parameterName, const string profileName = "") const;
    
    // Template management
    bool CreateTemplate(const string name, const string description, const ENUM_CONFIG_TYPE type, const string category = "");
    bool LoadTemplate(const string templateName, const string profileName);
    bool SaveTemplate(const string templateName, const string profileName);
    bool DeleteTemplate(const string templateName);
    string[] GetTemplateNames() const;
    string[] GetTemplatesByType(const ENUM_CONFIG_TYPE type) const;
    SConfigTemplate GetTemplate(const string templateName) const;
    
    // Built-in templates
    bool CreateDefaultTradingTemplate();
    bool CreateDefaultRiskTemplate();
    bool CreateDefaultUITemplate();
    bool CreateDefaultAlertTemplate();
    bool CreateDefaultLoggingTemplate();
    
    // Validation
    bool ValidateProfile(const string profileName = "");
    bool ValidateParameter(const string parameterName, const string value, const string profileName = "");
    string[] GetValidationErrors(const string profileName = "") const;
    bool IsProfileValid(const string profileName = "") const;
    
    // Backup and restore
    bool BackupProfile(const string profileName = "");
    bool RestoreProfile(const string profileName, const datetime backupDate);
    string[] GetBackupDates(const string profileName) const;
    bool CleanupBackups(const int maxBackups = 10);
    
    // Change tracking
    void EnableChangeTracking(const bool enable = true);
    SConfigChange[] GetChanges(const string profileName = "", const datetime fromDate = 0, const datetime toDate = 0) const;
    SConfigChange[] GetParameterChanges(const string parameterName, const string profileName = "") const;
    bool UndoLastChange(const string profileName = "");
    bool RedoLastUndo(const string profileName = "");
    
    // Configuration comparison
    string[] CompareProfiles(const string profile1, const string profile2) const;
    string[] GetDifferentParameters(const string profile1, const string profile2) const;
    bool MergeProfiles(const string sourceProfile, const string targetProfile, const bool overwriteExisting = false);
    
    // Import/Export
    bool ExportToINI(const string profileName, const string filePath);
    bool ImportFromINI(const string filePath, const string profileName);
    bool ExportToJSON(const string profileName, const string filePath);
    bool ImportFromJSON(const string filePath, const string profileName);
    bool ExportToXML(const string profileName, const string filePath);
    bool ImportFromXML(const string filePath, const string profileName);
    
    // Batch operations
    bool SetMultipleParameters(const string parameterNames[], const string values[], const int count, const string profileName = "");
    bool ResetParametersToDefault(const string parameterNames[], const int count, const string profileName = "");
    bool ResetProfileToDefault(const string profileName = "");
    bool CopyParameters(const string sourceProfile, const string targetProfile, const string parameterNames[], const int count);
    
    // Search and filter
    string[] SearchParameters(const string searchTerm, const string profileName = "") const;
    string[] FilterParametersByCategory(const string category, const string profileName = "") const;
    string[] FilterParametersByType(const string dataType, const string profileName = "") const;
    string[] FilterParametersByValue(const string value, const string profileName = "") const;
    
    // Configuration monitoring
    void StartMonitoring();
    void StopMonitoring();
    bool IsMonitoring() const;
    void CheckForChanges();
    
    // Auto-save and auto-backup
    void EnableAutoSave(const bool enable = true, const int intervalSeconds = 300);
    void EnableAutoBackup(const bool enable = true, const int intervalSeconds = 3600);
    bool IsAutoSaveEnabled() const { return m_bAutoSave; }
    bool IsAutoBackupEnabled() const { return m_bAutoBackup; }
    
    // Statistics and reporting
    SConfigStats GetStatistics() const { return m_Statistics; }
    void UpdateStatistics();
    void ResetStatistics();
    string GenerateReport(const string profileName = "") const;
    string GenerateUsageReport() const;
    string GenerateChangeReport(const datetime fromDate = 0, const datetime toDate = 0) const;
    
    // Configuration optimization
    void OptimizeProfiles();
    void CompactStorage();
    void RebuildCache();
    void CleanupUnusedParameters();
    
    // Error handling
    string GetLastError() const { return m_LastError; }
    int GetErrorCount() const { return m_ErrorCount; }
    void ClearErrors();
    
    // Configuration directories
    void SetConfigDirectory(const string directory);
    void SetBackupDirectory(const string directory);
    void SetTemplateDirectory(const string directory);
    string GetConfigDirectory() const { return m_ConfigDirectory; }
    string GetBackupDirectory() const { return m_BackupDirectory; }
    string GetTemplateDirectory() const { return m_TemplateDirectory; }
    
    // Utility methods
    string GetConfigTypeString(const ENUM_CONFIG_TYPE type) const;
    string GetConfigScopeString(const ENUM_CONFIG_SCOPE scope) const;
    string GetConfigFormatString(const ENUM_CONFIG_FORMAT format) const;
    string GetConfigStatusString(const ENUM_CONFIG_STATUS status) const;
    string GetValidationLevelString(const ENUM_CONFIG_VALIDATION level) const;
    
private:
    // Internal profile management
    int FindProfileIndex(const string name) const;
    bool AddProfile(const SConfigProfile& profile);
    bool RemoveProfile(const int index);
    bool UpdateProfile(const int index, const SConfigProfile& profile);
    
    // Internal parameter management
    int FindParameterIndex(const string parameterName, const string profileName) const;
    bool AddParameter(const SConfigParameter& parameter, const string profileName);
    bool RemoveParameter(const int parameterIndex, const string profileName);
    bool UpdateParameter(const int parameterIndex, const SConfigParameter& parameter, const string profileName);
    
    // File operations
    bool LoadProfileFromFile(const string filePath, SConfigProfile& profile);
    bool SaveProfileToFile(const SConfigProfile& profile, const string filePath);
    bool FileExists(const string filePath) const;
    bool CreateDirectory(const string directory) const;
    string GenerateChecksum(const SConfigProfile& profile) const;
    
    // Validation helpers
    bool ValidateParameterValue(const SConfigParameter& parameter, const string value) const;
    bool ValidateParameterConstraints(const SConfigParameter& parameter) const;
    bool ValidateParameterDependencies(const SConfigParameter& parameter, const string profileName) const;
    
    // Change tracking helpers
    void RecordChange(const string parameterName, const string oldValue, const string newValue, const string reason, const string profileName);
    void CleanupChangeHistory();
    
    // Template helpers
    int FindTemplateIndex(const string templateName) const;
    bool AddTemplate(const SConfigTemplate& template);
    bool RemoveTemplate(const int index);
    
    // Cache management
    void UpdateCache();
    void ClearCache();
    bool IsCached(const string profileName) const;
    
    // Backup helpers
    string GenerateBackupFileName(const string profileName, const datetime backupDate) const;
    bool CreateBackupDirectory(const string profileName) const;
    
    // Statistics helpers
    void UpdateLoadStatistics(const double loadTime);
    void UpdateSaveStatistics(const double saveTime);
    void UpdateValidationStatistics(const double validationTime);
    void UpdateErrorStatistics();
    
    // Error handling
    void SetError(const string error);
    void LogError(const string error, const ENUM_LOG_LEVEL level = LOG_LEVEL_ERROR);
    
    // Utility helpers
    string ConvertValueToString(const SConfigParameter& parameter) const;
    bool ConvertStringToValue(SConfigParameter& parameter, const string value) const;
    bool IsValidDataType(const string dataType) const;
    bool IsValidUIControl(const string uiControl) const;
    
    // Default value helpers
    void SetDefaultValue(SConfigParameter& parameter) const;
    bool HasDefaultValue(const SConfigParameter& parameter) const;
    
    // Logging
    void LogConfigActivity(const string activity, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CConfigManager::CConfigManager() {
    m_pContext = NULL;
    m_bInitialized = false;
    m_bAutoSave = false;
    m_bAutoBackup = false;
    
    m_ProfileCount = 0;
    m_TemplateCount = 0;
    m_ChangeCount = 0;
    
    m_CurrentProfile = "";
    
    m_CachedProfileCount = 0;
    
    m_bValidationEnabled = true;
    m_DefaultValidationLevel = CONFIG_VALIDATION_BASIC;
    
    m_ConfigDirectory = "Config";
    m_BackupDirectory = "Config\\Backup";
    m_TemplateDirectory = "Config\\Templates";
    
    m_LastError = "";
    m_ErrorCount = 0;
    
    // Initialize arrays
    ArrayInitialize(m_CachedProfileNames, "");
    
    // Initialize statistics
    ZeroMemory(m_Statistics);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CConfigManager::~CConfigManager() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize Configuration Manager                                |
//+------------------------------------------------------------------+
bool CConfigManager::Initialize(EAContext* context) {
    if (context == NULL) {
        Print("[CONFIG MANAGER ERROR] Context is NULL");
        return false;
    }
    
    m_pContext = context;
    
    // Create directories if they don't exist
    CreateDirectory(m_ConfigDirectory);
    CreateDirectory(m_BackupDirectory);
    CreateDirectory(m_TemplateDirectory);
    
    // Create built-in templates
    CreateDefaultTradingTemplate();
    CreateDefaultRiskTemplate();
    CreateDefaultUITemplate();
    CreateDefaultAlertTemplate();
    CreateDefaultLoggingTemplate();
    
    // Update cache
    UpdateCache();
    
    m_bInitialized = true;
    LogConfigActivity("Configuration Manager initialized successfully");
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize Configuration Manager                              |
//+------------------------------------------------------------------+
void CConfigManager::Deinitialize() {
    if (m_bInitialized) {
        // Auto-save current profile if enabled
        if (m_bAutoSave && m_CurrentProfile != "") {
            SaveProfile();
        }
        
        LogConfigActivity("Configuration Manager deinitialized");
    }
    
    m_bInitialized = false;
    m_pContext = NULL;
}

//+------------------------------------------------------------------+
//| Update method                                                   |
//+------------------------------------------------------------------+
void CConfigManager::Update() {
    if (!m_bInitialized) {
        return;
    }
    
    // Update statistics
    UpdateStatistics();
    
    // Check for auto-save
    if (m_bAutoSave) {
        // Auto-save logic would go here
    }
    
    // Check for auto-backup
    if (m_bAutoBackup) {
        // Auto-backup logic would go here
    }
}

//+------------------------------------------------------------------+
//| Create profile                                                  |
//+------------------------------------------------------------------+
bool CConfigManager::CreateProfile(const string name, const ENUM_CONFIG_TYPE type, const ENUM_CONFIG_SCOPE scope) {
    if (name == "" || ProfileExists(name)) {
        SetError("Profile name is empty or already exists: " + name);
        return false;
    }
    
    if (m_ProfileCount >= ArraySize(m_Profiles)) {
        SetError("Maximum number of profiles reached");
        return false;
    }
    
    SConfigProfile profile;
    ZeroMemory(profile);
    
    profile.Name = name;
    profile.Description = "Configuration profile: " + name;
    profile.Author = "ConfigManager";
    profile.Version = "1.0";
    profile.CreatedDate = TimeCurrent();
    profile.ModifiedDate = TimeCurrent();
    
    profile.Type = type;
    profile.Scope = scope;
    profile.Status = CONFIG_STATUS_LOADED;
    
    profile.ParameterCount = 0;
    
    profile.FilePath = m_ConfigDirectory + "\\" + name + ".ini";
    profile.Format = CONFIG_FORMAT_INI;
    profile.Checksum = "";
    
    profile.TagCount = 0;
    profile.Category = GetConfigTypeString(type);
    profile.Priority = 0;
    
    profile.IsValid = true;
    profile.ValidationErrorCount = 0;
    
    profile.BackupPath = m_BackupDirectory + "\\" + name;
    profile.LastBackup = 0;
    profile.AutoBackup = m_bAutoBackup;
    
    profile.IsLocked = false;
    profile.LockedBy = "";
    profile.LockTime = 0;
    
    profile.LoadCount = 0;
    profile.SaveCount = 0;
    profile.LastAccessed = TimeCurrent();
    profile.AverageLoadTime = 0;
    
    if (!AddProfile(profile)) {
        SetError("Failed to add profile: " + name);
        return false;
    }
    
    LogConfigActivity("Profile created: " + name);
    return true;
}

//+------------------------------------------------------------------+
//| Load profile                                                    |
//+------------------------------------------------------------------+
bool CConfigManager::LoadProfile(const string name) {
    if (name == "") {
        SetError("Profile name is empty");
        return false;
    }
    
    int index = FindProfileIndex(name);
    if (index < 0) {
        SetError("Profile not found: " + name);
        return false;
    }
    
    SConfigProfile& profile = m_Profiles[index];
    
    // Check if profile is locked
    if (profile.IsLocked) {
        SetError("Profile is locked: " + name);
        return false;
    }
    
    datetime startTime = GetMicrosecondCount();
    
    // Load from file if exists
    if (FileExists(profile.FilePath)) {
        if (!LoadProfileFromFile(profile.FilePath, profile)) {
            SetError("Failed to load profile from file: " + profile.FilePath);
            return false;
        }
    }
    
    // Update statistics
    profile.LoadCount++;
    profile.LastAccessed = TimeCurrent();
    
    datetime endTime = GetMicrosecondCount();
    double loadTime = (double)(endTime - startTime) / 1000.0;
    profile.AverageLoadTime = (profile.AverageLoadTime * (profile.LoadCount - 1) + loadTime) / profile.LoadCount;
    
    UpdateLoadStatistics(loadTime);
    
    m_CurrentProfile = name;
    
    LogConfigActivity("Profile loaded: " + name + " in " + DoubleToString(loadTime, 2) + "ms");
    return true;
}

//+------------------------------------------------------------------+
//| Save profile                                                    |
//+------------------------------------------------------------------+
bool CConfigManager::SaveProfile(const string name = "") {
    string profileName = (name == "") ? m_CurrentProfile : name;
    
    if (profileName == "") {
        SetError("No profile specified for saving");
        return false;
    }
    
    int index = FindProfileIndex(profileName);
    if (index < 0) {
        SetError("Profile not found: " + profileName);
        return false;
    }
    
    SConfigProfile& profile = m_Profiles[index];
    
    // Check if profile is read-only
    if (profile.Status == CONFIG_STATUS_READONLY) {
        SetError("Profile is read-only: " + profileName);
        return false;
    }
    
    datetime startTime = GetMicrosecondCount();
    
    // Save to file
    if (!SaveProfileToFile(profile, profile.FilePath)) {
        SetError("Failed to save profile to file: " + profile.FilePath);
        return false;
    }
    
    // Update profile metadata
    profile.ModifiedDate = TimeCurrent();
    profile.Status = CONFIG_STATUS_SAVED;
    profile.SaveCount++;
    profile.Checksum = GenerateChecksum(profile);
    
    datetime endTime = GetMicrosecondCount();
    double saveTime = (double)(endTime - startTime) / 1000.0;
    
    UpdateSaveStatistics(saveTime);
    
    LogConfigActivity("Profile saved: " + profileName + " in " + DoubleToString(saveTime, 2) + "ms");
    return true;
}

//+------------------------------------------------------------------+
//| Set parameter                                                   |
//+------------------------------------------------------------------+
bool CConfigManager::SetParameter(const string parameterName, const string value, const string profileName = "") {
    string targetProfile = (profileName == "") ? m_CurrentProfile : profileName;
    
    if (targetProfile == "") {
        SetError("No profile specified");
        return false;
    }
    
    int profileIndex = FindProfileIndex(targetProfile);
    if (profileIndex < 0) {
        SetError("Profile not found: " + targetProfile);
        return false;
    }
    
    SConfigProfile& profile = m_Profiles[profileIndex];
    
    int paramIndex = FindParameterIndex(parameterName, targetProfile);
    if (paramIndex < 0) {
        // Parameter doesn't exist, create it
        if (!DefineParameter(parameterName, "string", value, "", "", targetProfile)) {
            return false;
        }
        paramIndex = FindParameterIndex(parameterName, targetProfile);
    }
    
    if (paramIndex < 0) {
        SetError("Failed to create parameter: " + parameterName);
        return false;
    }
    
    SConfigParameter& parameter = profile.Parameters[paramIndex];
    
    // Check if parameter is read-only
    if (parameter.IsReadOnly) {
        SetError("Parameter is read-only: " + parameterName);
        return false;
    }
    
    // Validate value
    if (m_bValidationEnabled && !ValidateParameterValue(parameter, value)) {
        SetError("Invalid parameter value: " + parameterName + " = " + value);
        return false;
    }
    
    // Record change
    string oldValue = parameter.StringValue;
    
    // Set new value
    parameter.StringValue = value;
    parameter.LastModified = TimeCurrent();
    parameter.ModifiedBy = "ConfigManager";
    
    // Convert to appropriate data type
    ConvertStringToValue(parameter, value);
    
    // Update profile status
    profile.Status = CONFIG_STATUS_MODIFIED;
    profile.ModifiedDate = TimeCurrent();
    
    // Record change
    RecordChange(parameterName, oldValue, value, "Parameter updated", targetProfile);
    
    LogConfigActivity("Parameter set: " + parameterName + " = " + value + " in profile " + targetProfile);
    return true;
}

//+------------------------------------------------------------------+
//| Get parameter                                                   |
//+------------------------------------------------------------------+
string CConfigManager::GetParameter(const string parameterName, const string profileName = "") const {
    string targetProfile = (profileName == "") ? m_CurrentProfile : profileName;
    
    if (targetProfile == "") {
        return "";
    }
    
    int paramIndex = FindParameterIndex(parameterName, targetProfile);
    if (paramIndex < 0) {
        return "";
    }
    
    int profileIndex = FindProfileIndex(targetProfile);
    if (profileIndex < 0) {
        return "";
    }
    
    const SConfigParameter& parameter = m_Profiles[profileIndex].Parameters[paramIndex];
    return parameter.StringValue;
}

//+------------------------------------------------------------------+
//| Define parameter                                                |
//+------------------------------------------------------------------+
bool CConfigManager::DefineParameter(const string name, const string dataType, const string defaultValue, const string description = "", const string category = "", const string profileName = "") {
    string targetProfile = (profileName == "") ? m_CurrentProfile : profileName;
    
    if (targetProfile == "" || name == "") {
        SetError("Profile name or parameter name is empty");
        return false;
    }
    
    int profileIndex = FindProfileIndex(targetProfile);
    if (profileIndex < 0) {
        SetError("Profile not found: " + targetProfile);
        return false;
    }
    
    SConfigProfile& profile = m_Profiles[profileIndex];
    
    // Check if parameter already exists
    if (FindParameterIndex(name, targetProfile) >= 0) {
        SetError("Parameter already exists: " + name);
        return false;
    }
    
    // Check if we have space for more parameters
    if (profile.ParameterCount >= ArraySize(profile.Parameters)) {
        SetError("Maximum number of parameters reached for profile: " + targetProfile);
        return false;
    }
    
    // Validate data type
    if (!IsValidDataType(dataType)) {
        SetError("Invalid data type: " + dataType);
        return false;
    }
    
    SConfigParameter parameter;
    ZeroMemory(parameter);
    
    parameter.Name = name;
    parameter.Description = description;
    parameter.Category = category;
    parameter.Section = "General";
    
    parameter.StringValue = defaultValue;
    parameter.DataType = dataType;
    
    parameter.MinValue = 0;
    parameter.MaxValue = 0;
    parameter.AllowedValueCount = 0;
    
    parameter.IsRequired = false;
    parameter.IsReadOnly = false;
    parameter.IsHidden = false;
    parameter.IsAdvanced = false;
    parameter.RequiresRestart = false;
    
    parameter.DefaultStringValue = defaultValue;
    
    parameter.ValidationPattern = "";
    parameter.ValidationMessage = "";
    parameter.ValidationLevel = m_DefaultValidationLevel;
    
    parameter.UIControl = "textbox";
    parameter.UIGroup = category;
    parameter.UIOrder = profile.ParameterCount;
    parameter.UITooltip = description;
    
    parameter.LastModified = TimeCurrent();
    parameter.ModifiedBy = "ConfigManager";
    parameter.ChangeReason = "Parameter defined";
    
    parameter.DependentParameterCount = 0;
    parameter.ConditionalExpression = "";
    
    // Convert default value to appropriate data type
    ConvertStringToValue(parameter, defaultValue);
    
    // Set default values
    SetDefaultValue(parameter);
    
    // Add parameter to profile
    profile.Parameters[profile.ParameterCount] = parameter;
    profile.ParameterCount++;
    
    // Update profile status
    profile.Status = CONFIG_STATUS_MODIFIED;
    profile.ModifiedDate = TimeCurrent();
    
    LogConfigActivity("Parameter defined: " + name + " in profile " + targetProfile);
    return true;
}

//+------------------------------------------------------------------+
//| Create default trading template                                 |
//+------------------------------------------------------------------+
bool CConfigManager::CreateDefaultTradingTemplate() {
    SConfigTemplate template;
    ZeroMemory(template);
    
    template.Name = "Default Trading";
    template.Description = "Default trading configuration template";
    template.Category = "Trading";
    template.Type = CONFIG_TYPE_TRADING;
    template.Author = "APEX Trading Systems";
    template.Version = "1.0";
    template.CreatedDate = TimeCurrent();
    template.IsBuiltIn = true;
    template.IsCustomizable = true;
    template.UsageCount = 0;
    template.Rating = 5.0;
    template.CommentCount = 0;
    
    // Define template parameters
    template.TemplateParameterCount = 0;
    
    // Add basic trading parameters
    SConfigParameter param;
    
    // Lot size
    ZeroMemory(param);
    param.Name = "LotSize";
    param.Description = "Trading lot size";
    param.Category = "Trading";
    param.DataType = "double";
    param.DoubleValue = 0.01;
    param.DefaultDoubleValue = 0.01;
    param.MinValue = 0.01;
    param.MaxValue = 100.0;
    param.UIControl = "textbox";
    param.UIGroup = "Basic";
    param.UIOrder = 1;
    template.TemplateParameters[template.TemplateParameterCount++] = param;
    
    // Max trades
    ZeroMemory(param);
    param.Name = "MaxTrades";
    param.Description = "Maximum number of concurrent trades";
    param.Category = "Trading";
    param.DataType = "int";
    param.IntValue = 5;
    param.DefaultIntValue = 5;
    param.MinValue = 1;
    param.MaxValue = 100;
    param.UIControl = "textbox";
    param.UIGroup = "Basic";
    param.UIOrder = 2;
    template.TemplateParameters[template.TemplateParameterCount++] = param;
    
    // Enable trading
    ZeroMemory(param);
    param.Name = "EnableTrading";
    param.Description = "Enable automated trading";
    param.Category = "Trading";
    param.DataType = "bool";
    param.BoolValue = true;
    param.DefaultBoolValue = true;
    param.UIControl = "checkbox";
    param.UIGroup = "Basic";
    param.UIOrder = 3;
    template.TemplateParameters[template.TemplateParameterCount++] = param;
    
    return AddTemplate(template);
}

//+------------------------------------------------------------------+
//| Create default risk template                                    |
//+------------------------------------------------------------------+
bool CConfigManager::CreateDefaultRiskTemplate() {
    SConfigTemplate template;
    ZeroMemory(template);
    
    template.Name = "Default Risk";
    template.Description = "Default risk management configuration template";
    template.Category = "Risk";
    template.Type = CONFIG_TYPE_RISK;
    template.Author = "APEX Trading Systems";
    template.Version = "1.0";
    template.CreatedDate = TimeCurrent();
    template.IsBuiltIn = true;
    template.IsCustomizable = true;
    template.UsageCount = 0;
    template.Rating = 5.0;
    template.CommentCount = 0;
    
    template.TemplateParameterCount = 0;
    
    SConfigParameter param;
    
    // Max risk per trade
    ZeroMemory(param);
    param.Name = "MaxRiskPerTrade";
    param.Description = "Maximum risk per trade as percentage of account";
    param.Category = "Risk";
    param.DataType = "double";
    param.DoubleValue = 2.0;
    param.DefaultDoubleValue = 2.0;
    param.MinValue = 0.1;
    param.MaxValue = 10.0;
    param.UIControl = "textbox";
    param.UIGroup = "Risk Limits";
    param.UIOrder = 1;
    template.TemplateParameters[template.TemplateParameterCount++] = param;
    
    // Max daily loss
    ZeroMemory(param);
    param.Name = "MaxDailyLoss";
    param.Description = "Maximum daily loss as percentage of account";
    param.Category = "Risk";
    param.DataType = "double";
    param.DoubleValue = 5.0;
    param.DefaultDoubleValue = 5.0;
    param.MinValue = 1.0;
    param.MaxValue = 20.0;
    param.UIControl = "textbox";
    param.UIGroup = "Risk Limits";
    param.UIOrder = 2;
    template.TemplateParameters[template.TemplateParameterCount++] = param;
    
    // Stop loss
    ZeroMemory(param);
    param.Name = "StopLoss";
    param.Description = "Default stop loss in pips";
    param.Category = "Risk";
    param.DataType = "int";
    param.IntValue = 50;
    param.DefaultIntValue = 50;
    param.MinValue = 10;
    param.MaxValue = 500;
    param.UIControl = "textbox";
    param.UIGroup = "Trade Management";
    param.UIOrder = 3;
    template.TemplateParameters[template.TemplateParameterCount++] = param;
    
    return AddTemplate(template);
}

//+------------------------------------------------------------------+
//| Create default UI template                                      |
//+------------------------------------------------------------------+
bool CConfigManager::CreateDefaultUITemplate() {
    SConfigTemplate template;
    ZeroMemory(template);
    
    template.Name = "Default UI";
    template.Description = "Default user interface configuration template";
    template.Category = "UI";
    template.Type = CONFIG_TYPE_UI;
    template.Author = "APEX Trading Systems";
    template.Version = "1.0";
    template.CreatedDate = TimeCurrent();
    template.IsBuiltIn = true;
    template.IsCustomizable = true;
    template.UsageCount = 0;
    template.Rating = 5.0;
    template.CommentCount = 0;
    
    template.TemplateParameterCount = 0;
    
    SConfigParameter param;
    
    // Show dashboard
    ZeroMemory(param);
    param.Name = "ShowDashboard";
    param.Description = "Show trading dashboard";
    param.Category = "UI";
    param.DataType = "bool";
    param.BoolValue = true;
    param.DefaultBoolValue = true;
    param.UIControl = "checkbox";
    param.UIGroup = "Display";
    param.UIOrder = 1;
    template.TemplateParameters[template.TemplateParameterCount++] = param;
    
    // Dashboard position
    ZeroMemory(param);
    param.Name = "DashboardPosition";
    param.Description = "Dashboard position on screen";
    param.Category = "UI";
    param.DataType = "string";
    param.StringValue = "TopLeft";
    param.DefaultStringValue = "TopLeft";
    param.AllowedValueCount = 4;
    param.AllowedValues[0] = "TopLeft";
    param.AllowedValues[1] = "TopRight";
    param.AllowedValues[2] = "BottomLeft";
    param.AllowedValues[3] = "BottomRight";
    param.UIControl = "combobox";
    param.UIGroup = "Display";
    param.UIOrder = 2;
    template.TemplateParameters[template.TemplateParameterCount++] = param;
    
    return AddTemplate(template);
}

//+------------------------------------------------------------------+
//| Create default alert template                                   |
//+------------------------------------------------------------------+
bool CConfigManager::CreateDefaultAlertTemplate() {
    SConfigTemplate template;
    ZeroMemory(template);
    
    template.Name = "Default Alerts";
    template.Description = "Default alert configuration template";
    template.Category = "Alerts";
    template.Type = CONFIG_TYPE_ALERTS;
    template.Author = "APEX Trading Systems";
    template.Version = "1.0";
    template.CreatedDate = TimeCurrent();
    template.IsBuiltIn = true;
    template.IsCustomizable = true;
    template.UsageCount = 0;
    template.Rating = 5.0;
    template.CommentCount = 0;
    
    template.TemplateParameterCount = 0;
    
    SConfigParameter param;
    
    // Enable alerts
    ZeroMemory(param);
    param.Name = "EnableAlerts";
    param.Description = "Enable alert notifications";
    param.Category = "Alerts";
    param.DataType = "bool";
    param.BoolValue = true;
    param.DefaultBoolValue = true;
    param.UIControl = "checkbox";
    param.UIGroup = "General";
    param.UIOrder = 1;
    template.TemplateParameters[template.TemplateParameterCount++] = param;
    
    // Sound alerts
    ZeroMemory(param);
    param.Name = "SoundAlerts";
    param.Description = "Enable sound alerts";
    param.Category = "Alerts";
    param.DataType = "bool";
    param.BoolValue = true;
    param.DefaultBoolValue = true;
    param.UIControl = "checkbox";
    param.UIGroup = "Sound";
    param.UIOrder = 2;
    template.TemplateParameters[template.TemplateParameterCount++] = param;
    
    return AddTemplate(template);
}

//+------------------------------------------------------------------+
//| Create default logging template                                 |
//+------------------------------------------------------------------+
bool CConfigManager::CreateDefaultLoggingTemplate() {
    SConfigTemplate template;
    ZeroMemory(template);
    
    template.Name = "Default Logging";
    template.Description = "Default logging configuration template";
    template.Category = "Logging";
    template.Type = CONFIG_TYPE_LOGGING;
    template.Author = "APEX Trading Systems";
    template.Version = "1.0";
    template.CreatedDate = TimeCurrent();
    template.IsBuiltIn = true;
    template.IsCustomizable = true;
    template.UsageCount = 0;
    template.Rating = 5.0;
    template.CommentCount = 0;
    
    template.TemplateParameterCount = 0;
    
    SConfigParameter param;
    
    // Log level
    ZeroMemory(param);
    param.Name = "LogLevel";
    param.Description = "Logging level";
    param.Category = "Logging";
    param.DataType = "string";
    param.StringValue = "INFO";
    param.DefaultStringValue = "INFO";
    param.AllowedValueCount = 5;
    param.AllowedValues[0] = "DEBUG";
    param.AllowedValues[1] = "INFO";
    param.AllowedValues[2] = "WARNING";
    param.AllowedValues[3] = "ERROR";
    param.AllowedValues[4] = "CRITICAL";
    param.UIControl = "combobox";
    param.UIGroup = "General";
    param.UIOrder = 1;
    template.TemplateParameters[template.TemplateParameterCount++] = param;
    
    // Enable file logging
    ZeroMemory(param);
    param.Name = "EnableFileLogging";
    param.Description = "Enable logging to file";
    param.Category = "Logging";
    param.DataType = "bool";
    param.BoolValue = true;
    param.DefaultBoolValue = true;
    param.UIControl = "checkbox";
    param.UIGroup = "Output";
    param.UIOrder = 2;
    template.TemplateParameters[template.TemplateParameterCount++] = param;
    
    return AddTemplate(template);
}

//+------------------------------------------------------------------+
//| Helper methods                                                  |
//+------------------------------------------------------------------+
int CConfigManager::FindProfileIndex(const string name) const {
    for (int i = 0; i < m_ProfileCount; i++) {
        if (m_Profiles[i].Name == name) {
            return i;
        }
    }
    return -1;
}

int CConfigManager::FindParameterIndex(const string parameterName, const string profileName) const {
    int profileIndex = FindProfileIndex(profileName);
    if (profileIndex < 0) {
        return -1;
    }
    
    const SConfigProfile& profile = m_Profiles[profileIndex];
    for (int i = 0; i < profile.ParameterCount; i++) {
        if (profile.Parameters[i].Name == parameterName) {
            return i;
        }
    }
    return -1;
}

int CConfigManager::FindTemplateIndex(const string templateName) const {
    for (int i = 0; i < m_TemplateCount; i++) {
        if (m_Templates[i].Name == templateName) {
            return i;
        }
    }
    return -1;
}

bool CConfigManager::AddProfile(const SConfigProfile& profile) {
    if (m_ProfileCount >= ArraySize(m_Profiles)) {
        return false;
    }
    
    m_Profiles[m_ProfileCount] = profile;
    m_ProfileCount++;
    return true;
}

bool CConfigManager::AddTemplate(const SConfigTemplate& template) {
    if (m_TemplateCount >= ArraySize(m_Templates)) {
        return false;
    }
    
    m_Templates[m_TemplateCount] = template;
    m_TemplateCount++;
    return true;
}

bool CConfigManager::ProfileExists(const string name) const {
    return FindProfileIndex(name) >= 0;
}

bool CConfigManager::IsValidDataType(const string dataType) const {
    return (dataType == "string" || dataType == "double" || dataType == "int" || 
            dataType == "bool" || dataType == "datetime" || dataType == "color");
}

bool CConfigManager::ValidateParameterValue(const SConfigParameter& parameter, const string value) const {
    // Basic validation based on data type
    if (parameter.DataType == "double") {
        double doubleValue = StringToDouble(value);
        if (parameter.MinValue != 0 || parameter.MaxValue != 0) {
            return (doubleValue >= parameter.MinValue && doubleValue <= parameter.MaxValue);
        }
    } else if (parameter.DataType == "int") {
        int intValue = (int)StringToInteger(value);
        if (parameter.MinValue != 0 || parameter.MaxValue != 0) {
            return (intValue >= parameter.MinValue && intValue <= parameter.MaxValue);
        }
    } else if (parameter.DataType == "bool") {
        return (value == "true" || value == "false" || value == "1" || value == "0");
    }
    
    // Check allowed values
    if (parameter.AllowedValueCount > 0) {
        for (int i = 0; i < parameter.AllowedValueCount; i++) {
            if (parameter.AllowedValues[i] == value) {
                return true;
            }
        }
        return false;
    }
    
    return true;
}

bool CConfigManager::ConvertStringToValue(SConfigParameter& parameter, const string value) const {
    if (parameter.DataType == "double") {
        parameter.DoubleValue = StringToDouble(value);
    } else if (parameter.DataType == "int") {
        parameter.IntValue = (int)StringToInteger(value);
    } else if (parameter.DataType == "bool") {
        parameter.BoolValue = (value == "true" || value == "1");
    } else if (parameter.DataType == "datetime") {
        parameter.DateTimeValue = StringToTime(value);
    } else if (parameter.DataType == "color") {
        parameter.ColorValue = (color)StringToInteger(value);
    }
    
    return true;
}

void CConfigManager::SetDefaultValue(SConfigParameter& parameter) const {
    if (parameter.DataType == "double") {
        parameter.DefaultDoubleValue = parameter.DoubleValue;
    } else if (parameter.DataType == "int") {
        parameter.DefaultIntValue = parameter.IntValue;
    } else if (parameter.DataType == "bool") {
        parameter.DefaultBoolValue = parameter.BoolValue;
    } else if (parameter.DataType == "datetime") {
        parameter.DefaultDateTimeValue = parameter.DateTimeValue;
    } else if (parameter.DataType == "color") {
        parameter.DefaultColorValue = parameter.ColorValue;
    }
}

void CConfigManager::RecordChange(const string parameterName, const string oldValue, const string newValue, const string reason, const string profileName) {
    if (m_ChangeCount >= ArraySize(m_Changes)) {
        // Remove oldest change to make room
        for (int i = 0; i < m_ChangeCount - 1; i++) {
            m_Changes[i] = m_Changes[i + 1];
        }
        m_ChangeCount--;
    }
    
    SConfigChange change;
    change.Timestamp = TimeCurrent();
    change.ParameterName = parameterName;
    change.OldValue = oldValue;
    change.NewValue = newValue;
    change.ChangedBy = "ConfigManager";
    change.Reason = reason;
    change.ProfileName = profileName;
    change.ConfigType = CONFIG_TYPE_CUSTOM; // Would need to determine actual type
    
    m_Changes[m_ChangeCount] = change;
    m_ChangeCount++;
}

void CConfigManager::UpdateStatistics() {
    m_Statistics.TotalProfiles = m_ProfileCount;
    
    // Count profiles by status
    int loaded = 0, modified = 0, error = 0;
    for (int i = 0; i < m_ProfileCount; i++) {
        switch(m_Profiles[i].Status) {
        case CONFIG_STATUS_LOADED:
            loaded++;
            break;
        case CONFIG_STATUS_MODIFIED:
            modified++;
            break;
        case CONFIG_STATUS_ERROR:
            error++;
            break;
        }
    }
    
    m_Statistics.LoadedProfiles = loaded;
    m_Statistics.ModifiedProfiles = modified;
    m_Statistics.ErrorProfiles = error;
    
    // Count total parameters
    int totalParams = 0;
    for (int i = 0; i < m_ProfileCount; i++) {
        totalParams += m_Profiles[i].ParameterCount;
    }
    m_Statistics.TotalParameters = totalParams;
    
    m_Statistics.TotalChanges = m_ChangeCount;
    if (m_ChangeCount > 0) {
        m_Statistics.LastChange = m_Changes[m_ChangeCount - 1].Timestamp;
    }
}

string CConfigManager::GetConfigTypeString(const ENUM_CONFIG_TYPE type) const {
    switch(type) {
    case CONFIG_TYPE_TRADING: return "Trading";
    case CONFIG_TYPE_RISK: return "Risk";
    case CONFIG_TYPE_UI: return "UI";
    case CONFIG_TYPE_ALERTS: return "Alerts";
    case CONFIG_TYPE_LOGGING: return "Logging";
    case CONFIG_TYPE_PERFORMANCE: return "Performance";
    case CONFIG_TYPE_ANALYTICS: return "Analytics";
    case CONFIG_TYPE_SYSTEM: return "System";
    case CONFIG_TYPE_CUSTOM: return "Custom";
    default: return "Unknown";
    }
}

string CConfigManager::GetConfigScopeString(const ENUM_CONFIG_SCOPE scope) const {
    switch(scope) {
    case CONFIG_SCOPE_GLOBAL: return "Global";
    case CONFIG_SCOPE_SYMBOL: return "Symbol";
    case CONFIG_SCOPE_TIMEFRAME: return "Timeframe";
    case CONFIG_SCOPE_SESSION: return "Session";
    case CONFIG_SCOPE_USER: return "User";
    case CONFIG_SCOPE_TEMPORARY: return "Temporary";
    default: return "Unknown";
    }
}

string CConfigManager::GetConfigStatusString(const ENUM_CONFIG_STATUS status) const {
    switch(status) {
    case CONFIG_STATUS_LOADED: return "Loaded";
    case CONFIG_STATUS_MODIFIED: return "Modified";
    case CONFIG_STATUS_SAVED: return "Saved";
    case CONFIG_STATUS_ERROR: return "Error";
    case CONFIG_STATUS_LOCKED: return "Locked";
    case CONFIG_STATUS_READONLY: return "ReadOnly";
    default: return "Unknown";
    }
}

//+------------------------------------------------------------------+
//| File operation placeholders                                     |
//+------------------------------------------------------------------+
bool CConfigManager::LoadProfileFromFile(const string filePath, SConfigProfile& profile) {
    // Placeholder implementation for loading profile from file
    // In a real implementation, this would parse the file format (INI, JSON, etc.)
    // and populate the profile structure
    return true;
}

bool CConfigManager::SaveProfileToFile(const SConfigProfile& profile, const string filePath) {
    // Placeholder implementation for saving profile to file
    // In a real implementation, this would serialize the profile structure
    // to the specified file format
    return true;
}

bool CConfigManager::FileExists(const string filePath) const {
    // Check if file exists
    int handle = FileOpen(filePath, FILE_READ | FILE_BIN);
    if (handle != INVALID_HANDLE) {
        FileClose(handle);
        return true;
    }
    return false;
}

bool CConfigManager::CreateDirectory(const string directory) const {
    // Create directory if it doesn't exist
    return FolderCreate(directory, 0);
}

string CConfigManager::GenerateChecksum(const SConfigProfile& profile) const {
    // Generate a simple checksum based on profile content
    string content = profile.Name + profile.Description + IntegerToString(profile.ParameterCount);
    return IntegerToString(StringLen(content));
}

void CConfigManager::UpdateLoadStatistics(const double loadTime) {
    m_Statistics.LoadOperations++;
    m_Statistics.AverageLoadTime = (m_Statistics.AverageLoadTime * (m_Statistics.LoadOperations - 1) + loadTime) / m_Statistics.LoadOperations;
    m_Statistics.LastLoad = TimeCurrent();
}

void CConfigManager::UpdateSaveStatistics(const double saveTime) {
    m_Statistics.SaveOperations++;
    m_Statistics.AverageSaveTime = (m_Statistics.AverageSaveTime * (m_Statistics.SaveOperations - 1) + saveTime) / m_Statistics.SaveOperations;
    m_Statistics.LastSave = TimeCurrent();
}

void CConfigManager::UpdateValidationStatistics(const double validationTime) {
    m_Statistics.ValidationOperations++;
    m_Statistics.AverageValidationTime = (m_Statistics.AverageValidationTime * (m_Statistics.ValidationOperations - 1) + validationTime) / m_Statistics.ValidationOperations;
    m_Statistics.LastValidation = TimeCurrent();
}

void CConfigManager::UpdateErrorStatistics() {
    m_Statistics.ErrorOperations++;
    m_ErrorCount++;
}

void CConfigManager::SetError(const string error) {
    m_LastError = error;
    UpdateErrorStatistics();
    LogError(error);
}

void CConfigManager::LogError(const string error, const ENUM_LOG_LEVEL level = LOG_LEVEL_ERROR) {
    if (m_pContext != NULL && m_pContext.pLogger != NULL) {
        m_pContext.pLogger.LogMessage(level, "[CONFIG MANAGER] " + error);
    } else {
        Print("[CONFIG MANAGER ERROR] " + error);
    }
}

void CConfigManager::LogConfigActivity(const string activity, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO) {
    if (m_pContext != NULL && m_pContext.pLogger != NULL) {
        m_pContext.pLogger.LogMessage(level, "[CONFIG MANAGER] " + activity);
    } else {
        Print("[CONFIG MANAGER] " + activity);
    }
}

void CConfigManager::UpdateCache() {
    m_CachedProfileCount = 0;
    for (int i = 0; i < m_ProfileCount && i < ArraySize(m_CachedProfileNames); i++) {
        m_CachedProfileNames[i] = m_Profiles[i].Name;
        m_CachedProfileCount++;
    }
}

void CConfigManager::ClearCache() {
    ArrayInitialize(m_CachedProfileNames, "");
    m_CachedProfileCount = 0;
}

bool CConfigManager::IsCached(const string profileName) const {
    for (int i = 0; i < m_CachedProfileCount; i++) {
        if (m_CachedProfileNames[i] == profileName) {
            return true;
        }
    }
    return false;
}

//+------------------------------------------------------------------+