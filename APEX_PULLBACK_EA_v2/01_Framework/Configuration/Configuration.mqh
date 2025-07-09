//+------------------------------------------------------------------+
//|                                                Configuration.mqh |
//|                Configuration.mqh - APEX Pullback EA v5 FINAL    |
//|      Description: Centralized configuration management system    |
//|                   with validation, persistence, and dynamic     |
//|                   parameter adjustment capabilities.             |
//+------------------------------------------------------------------+

#ifndef CONFIGURATION_MQH_
#define CONFIGURATION_MQH_

#include "..\..\CommonStructs.mqh"

namespace ApexPullback {

//+------------------------------------------------------------------+
//| Configuration Validation Result                                  |
//+------------------------------------------------------------------+
struct SConfigValidationResult {
    bool                  IsValid;              // Overall validation result
    string                ErrorMessage;         // Error description if invalid
    string                WarningMessage;       // Warning message if applicable
    int                   ErrorCount;           // Number of validation errors
    int                   WarningCount;         // Number of validation warnings
};

//+------------------------------------------------------------------+
//| Configuration Backup Structure                                   |
//+------------------------------------------------------------------+
struct SConfigBackup {
    datetime              BackupTime;           // When backup was created
    EAInput               Parameters;           // Backed up parameters
    string                BackupReason;         // Reason for backup
    bool                  IsValid;              // Backup validity flag
};

//+------------------------------------------------------------------+
//| CConfigManager - Centralized Configuration Management           |
//+------------------------------------------------------------------+
class CConfigManager {
private:
    EAContext*            m_pContext;           // Reference to EA context
    bool                  m_bInitialized;      // Initialization status
    
    // Configuration management
    SConfigBackup         m_ConfigBackups[5];  // Configuration backups (rolling)
    int                   m_iBackupIndex;      // Current backup index
    datetime              m_LastValidationTime; // Last validation timestamp
    
    // File paths
    string                m_sConfigFile;       // Configuration file path
    string                m_sBackupPath;       // Backup directory path
    
    // Validation settings
    static const double   MIN_LOT_SIZE;        // Minimum lot size
    static const double   MAX_LOT_SIZE;        // Maximum lot size
    static const int      MIN_STOP_LOSS;      // Minimum stop loss
    static const int      MAX_STOP_LOSS;      // Maximum stop loss
    static const int      MIN_TAKE_PROFIT;    // Minimum take profit
    static const int      MAX_TAKE_PROFIT;    // Maximum take profit
    
public:
    //--- Constructor/Destructor ---
    CConfigManager();
    ~CConfigManager();
    
    //--- Core Methods ---
    bool                  Initialize(EAContext* context);
    void                  Deinitialize();
    bool                  IsInitialized() const { return m_bInitialized; }
    
    //--- Configuration Loading/Saving ---
    bool                  LoadConfiguration();
    bool                  SaveConfiguration();
    bool                  LoadFromFile(const string& file_path);
    bool                  SaveToFile(const string& file_path);
    
    //--- Parameter Validation ---
    SConfigValidationResult ValidateConfiguration();
    SConfigValidationResult ValidateGeneralSettings();
    SConfigValidationResult ValidateStrategySettings();
    SConfigValidationResult ValidateRiskSettings();
    SConfigValidationResult ValidateAdvancedSettings();
    
    //--- Parameter Management ---
    bool                  UpdateParameter(const string& param_name, const string& param_value);
    bool                  ResetToDefaults();
    bool                  ApplyPreset(const ENUM_STRATEGY_PRESET preset);
    
    //--- Backup and Recovery ---
    bool                  CreateBackup(const string& reason = "Manual backup");
    bool                  RestoreFromBackup(const int backup_index = 0);
    bool                  HasValidBackup();
    string                GetBackupInfo();
    
    //--- Dynamic Adjustment ---
    bool                  AdjustForMarketConditions();
    bool                  AdjustForAccountSize();
    bool                  AdjustForVolatility(const double volatility);
    bool                  AdjustForDrawdown(const double drawdown_percent);
    
    //--- Utility Methods ---
    string                GetConfigurationSummary();
    bool                  IsParameterValid(const string& param_name, const string& param_value);
    string                GetParameterDescription(const string& param_name);
    
private:
    //--- Internal Methods ---
    bool                  ValidateNumericRange(const double value, const double min_val, const double max_val, const string& param_name);
    bool                  ValidateIntegerRange(const int value, const int min_val, const int max_val, const string& param_name);
    bool                  CreateConfigDirectories();
    string                GenerateConfigFileName();
    bool                  WriteConfigToFile(const string& file_path, const EAInput& params);
    bool                  ReadConfigFromFile(const string& file_path, EAInput& params);
    void                  SetDefaultParameters();
    bool                  ValidateSymbolSettings();
    bool                  ValidateTimeSettings();
    bool                  ValidateBrokerCompatibility();
};

// Static constants definition
const double CConfigManager::MIN_LOT_SIZE = 0.01;
const double CConfigManager::MAX_LOT_SIZE = 100.0;
const int CConfigManager::MIN_STOP_LOSS = 10;
const int CConfigManager::MAX_STOP_LOSS = 1000;
const int CConfigManager::MIN_TAKE_PROFIT = 10;
const int CConfigManager::MAX_TAKE_PROFIT = 2000;

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CConfigManager::CConfigManager() {
    m_pContext = NULL;
    m_bInitialized = false;
    m_iBackupIndex = 0;
    m_LastValidationTime = 0;
    
    // Initialize backup array
    for (int i = 0; i < ArraySize(m_ConfigBackups); i++) {
        m_ConfigBackups[i].IsValid = false;
        m_ConfigBackups[i].BackupTime = 0;
        m_ConfigBackups[i].BackupReason = "";
    }
    
    // Set file paths
    m_sConfigFile = "";
    m_sBackupPath = "";
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CConfigManager::~CConfigManager() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CConfigManager::Initialize(EAContext* context) {
    if (m_bInitialized) {
        return true;
    }
    
    m_pContext = context;
    if (m_pContext == NULL) {
        Print("[CONFIG] Context is NULL");
        return false;
    }
    
    // Create configuration directories
    if (!CreateConfigDirectories()) {
        if (m_pContext->pLogger != NULL) {
            m_pContext->pLogger->LogError("Failed to create configuration directories", __FUNCTION__);
        }
        return false;
    }
    
    // Generate configuration file path
    m_sConfigFile = GenerateConfigFileName();
    
    // Set default parameters first
    SetDefaultParameters();
    
    // Try to load existing configuration
    if (!LoadConfiguration()) {
        if (m_pContext->pLogger != NULL) {
            m_pContext->pLogger->LogWarning("Could not load existing configuration, using defaults", __FUNCTION__);
        }
    }
    
    // Validate configuration
    SConfigValidationResult validation = ValidateConfiguration();
    if (!validation.IsValid) {
        if (m_pContext->pLogger != NULL) {
            m_pContext->pLogger->LogError(StringFormat("Configuration validation failed: %s", validation.ErrorMessage), __FUNCTION__);
        }
        
        // Try to reset to defaults
        ResetToDefaults();
        validation = ValidateConfiguration();
        
        if (!validation.IsValid) {
            return false;
        }
    }
    
    // Create initial backup
    CreateBackup("Initial configuration");
    
    m_bInitialized = true;
    
    if (m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo("Configuration system initialized successfully", __FUNCTION__);
        m_pContext->pLogger->LogInfo(GetConfigurationSummary(), __FUNCTION__);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CConfigManager::Deinitialize() {
    if (!m_bInitialized) {
        return;
    }
    
    // Save current configuration
    SaveConfiguration();
    
    if (m_pContext != NULL && m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo("Configuration system shutting down", __FUNCTION__);
    }
    
    m_bInitialized = false;
}

//+------------------------------------------------------------------+
//| Load Configuration                                               |
//+------------------------------------------------------------------+
bool CConfigManager::LoadConfiguration() {
    if (m_sConfigFile == "") {
        return false;
    }
    
    return LoadFromFile(m_sConfigFile);
}

//+------------------------------------------------------------------+
//| Save Configuration                                               |
//+------------------------------------------------------------------+
bool CConfigManager::SaveConfiguration() {
    if (m_sConfigFile == "") {
        return false;
    }
    
    return SaveToFile(m_sConfigFile);
}

//+------------------------------------------------------------------+
//| Load From File                                                   |
//+------------------------------------------------------------------+
bool CConfigManager::LoadFromFile(const string& file_path) {
    if (!m_bInitialized || m_pContext == NULL) {
        return false;
    }
    
    EAInput temp_params;
    if (!ReadConfigFromFile(file_path, temp_params)) {
        return false;
    }
    
    // Backup current configuration before loading new one
    CreateBackup("Before loading from file");
    
    // Apply loaded parameters
    m_pContext->Inputs = temp_params;
    
    // Validate loaded configuration
    SConfigValidationResult validation = ValidateConfiguration();
    if (!validation.IsValid) {
        if (m_pContext->pLogger != NULL) {
            m_pContext->pLogger->LogError(StringFormat("Loaded configuration is invalid: %s", validation.ErrorMessage), __FUNCTION__);
        }
        
        // Restore from backup
        RestoreFromBackup(0);
        return false;
    }
    
    if (m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo(StringFormat("Configuration loaded from: %s", file_path), __FUNCTION__);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Save To File                                                     |
//+------------------------------------------------------------------+
bool CConfigManager::SaveToFile(const string& file_path) {
    if (!m_bInitialized || m_pContext == NULL) {
        return false;
    }
    
    if (!WriteConfigToFile(file_path, m_pContext->Inputs)) {
        if (m_pContext->pLogger != NULL) {
            m_pContext->pLogger->LogError(StringFormat("Failed to save configuration to: %s", file_path), __FUNCTION__);
        }
        return false;
    }
    
    if (m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo(StringFormat("Configuration saved to: %s", file_path), __FUNCTION__);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Validate Configuration                                           |
//+------------------------------------------------------------------+
SConfigValidationResult CConfigManager::ValidateConfiguration() {
    SConfigValidationResult result;
    result.IsValid = true;
    result.ErrorMessage = "";
    result.WarningMessage = "";
    result.ErrorCount = 0;
    result.WarningCount = 0;
    
    if (!m_bInitialized || m_pContext == NULL) {
        result.IsValid = false;
        result.ErrorMessage = "Configuration not initialized";
        result.ErrorCount = 1;
        return result;
    }
    
    // Validate different sections
    SConfigValidationResult general = ValidateGeneralSettings();
    SConfigValidationResult strategy = ValidateStrategySettings();
    SConfigValidationResult risk = ValidateRiskSettings();
    SConfigValidationResult advanced = ValidateAdvancedSettings();
    
    // Combine results
    result.ErrorCount = general.ErrorCount + strategy.ErrorCount + risk.ErrorCount + advanced.ErrorCount;
    result.WarningCount = general.WarningCount + strategy.WarningCount + risk.WarningCount + advanced.WarningCount;
    
    if (result.ErrorCount > 0) {
        result.IsValid = false;
        result.ErrorMessage = StringFormat("Configuration has %d errors", result.ErrorCount);
    }
    
    if (result.WarningCount > 0) {
        result.WarningMessage = StringFormat("Configuration has %d warnings", result.WarningCount);
    }
    
    m_LastValidationTime = TimeCurrent();
    
    return result;
}

//+------------------------------------------------------------------+
//| Validate General Settings                                        |
//+------------------------------------------------------------------+
SConfigValidationResult CConfigManager::ValidateGeneralSettings() {
    SConfigValidationResult result;
    result.IsValid = true;
    result.ErrorCount = 0;
    result.WarningCount = 0;
    
    // Validate lot size
    if (!ValidateNumericRange(m_pContext->Inputs.LotSize, MIN_LOT_SIZE, MAX_LOT_SIZE, "LotSize")) {
        result.ErrorCount++;
        result.IsValid = false;
    }
    
    // Validate stop loss
    if (!ValidateIntegerRange(m_pContext->Inputs.StopLoss, MIN_STOP_LOSS, MAX_STOP_LOSS, "StopLoss")) {
        result.ErrorCount++;
        result.IsValid = false;
    }
    
    // Validate take profit
    if (!ValidateIntegerRange(m_pContext->Inputs.TakeProfit, MIN_TAKE_PROFIT, MAX_TAKE_PROFIT, "TakeProfit")) {
        result.ErrorCount++;
        result.IsValid = false;
    }
    
    // Validate magic number
    if (m_pContext->Inputs.MagicNumber <= 0) {
        result.ErrorCount++;
        result.IsValid = false;
    }
    
    return result;
}

//+------------------------------------------------------------------+
//| Validate Strategy Settings                                       |
//+------------------------------------------------------------------+
SConfigValidationResult CConfigManager::ValidateStrategySettings() {
    SConfigValidationResult result;
    result.IsValid = true;
    result.ErrorCount = 0;
    result.WarningCount = 0;
    
    // Validate pullback percentage
    if (m_pContext->Inputs.PullbackPercentage <= 0 || m_pContext->Inputs.PullbackPercentage > 100) {
        result.ErrorCount++;
        result.IsValid = false;
    }
    
    // Validate trend strength threshold
    if (m_pContext->Inputs.TrendStrengthThreshold <= 0 || m_pContext->Inputs.TrendStrengthThreshold > 100) {
        result.ErrorCount++;
        result.IsValid = false;
    }
    
    // Validate timeframe consistency
    if (m_pContext->Inputs.AnalysisTimeframe == PERIOD_CURRENT) {
        result.WarningCount++;
    }
    
    return result;
}

//+------------------------------------------------------------------+
//| Validate Risk Settings                                           |
//+------------------------------------------------------------------+
SConfigValidationResult CConfigManager::ValidateRiskSettings() {
    SConfigValidationResult result;
    result.IsValid = true;
    result.ErrorCount = 0;
    result.WarningCount = 0;
    
    // Validate risk percentage
    if (m_pContext->Inputs.RiskPercentage <= 0 || m_pContext->Inputs.RiskPercentage > 10) {
        if (m_pContext->Inputs.RiskPercentage > 5) {
            result.WarningCount++; // High risk warning
        }
        if (m_pContext->Inputs.RiskPercentage <= 0 || m_pContext->Inputs.RiskPercentage > 10) {
            result.ErrorCount++;
            result.IsValid = false;
        }
    }
    
    // Validate max daily loss
    if (m_pContext->Inputs.MaxDailyLoss <= 0 || m_pContext->Inputs.MaxDailyLoss > 50) {
        result.ErrorCount++;
        result.IsValid = false;
    }
    
    // Validate max positions
    if (m_pContext->Inputs.MaxPositions <= 0 || m_pContext->Inputs.MaxPositions > 20) {
        result.ErrorCount++;
        result.IsValid = false;
    }
    
    return result;
}

//+------------------------------------------------------------------+
//| Validate Advanced Settings                                       |
//+------------------------------------------------------------------+
SConfigValidationResult CConfigManager::ValidateAdvancedSettings() {
    SConfigValidationResult result;
    result.IsValid = true;
    result.ErrorCount = 0;
    result.WarningCount = 0;
    
    // Validate slippage
    if (m_pContext->Inputs.MaxSlippage < 0 || m_pContext->Inputs.MaxSlippage > 100) {
        result.ErrorCount++;
        result.IsValid = false;
    }
    
    // Validate news filter minutes
    if (m_pContext->Inputs.NewsFilterMinutes < 0 || m_pContext->Inputs.NewsFilterMinutes > 1440) {
        result.ErrorCount++;
        result.IsValid = false;
    }
    
    return result;
}

//+------------------------------------------------------------------+
//| Create Backup                                                    |
//+------------------------------------------------------------------+
bool CConfigManager::CreateBackup(const string& reason = "Manual backup") {
    if (!m_bInitialized || m_pContext == NULL) {
        return false;
    }
    
    // Store backup
    m_ConfigBackups[m_iBackupIndex].BackupTime = TimeCurrent();
    m_ConfigBackups[m_iBackupIndex].Parameters = m_pContext->Inputs;
    m_ConfigBackups[m_iBackupIndex].BackupReason = reason;
    m_ConfigBackups[m_iBackupIndex].IsValid = true;
    
    // Move to next backup slot
    m_iBackupIndex = (m_iBackupIndex + 1) % ArraySize(m_ConfigBackups);
    
    if (m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo(StringFormat("Configuration backup created: %s", reason), __FUNCTION__);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Restore From Backup                                              |
//+------------------------------------------------------------------+
bool CConfigManager::RestoreFromBackup(const int backup_index = 0) {
    if (!m_bInitialized || m_pContext == NULL) {
        return false;
    }
    
    if (backup_index < 0 || backup_index >= ArraySize(m_ConfigBackups)) {
        return false;
    }
    
    if (!m_ConfigBackups[backup_index].IsValid) {
        return false;
    }
    
    // Restore parameters
    m_pContext->Inputs = m_ConfigBackups[backup_index].Parameters;
    
    if (m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo(StringFormat("Configuration restored from backup: %s", 
                                               m_ConfigBackups[backup_index].BackupReason), __FUNCTION__);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Reset To Defaults                                                |
//+------------------------------------------------------------------+
bool CConfigManager::ResetToDefaults() {
    if (!m_bInitialized || m_pContext == NULL) {
        return false;
    }
    
    // Create backup before reset
    CreateBackup("Before reset to defaults");
    
    // Set default parameters
    SetDefaultParameters();
    
    if (m_pContext->pLogger != NULL) {
        m_pContext->pLogger->LogInfo("Configuration reset to defaults", __FUNCTION__);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Internal Methods                                                 |
//+------------------------------------------------------------------+
bool CConfigManager::ValidateNumericRange(const double value, const double min_val, const double max_val, const string& param_name) {
    if (value < min_val || value > max_val) {
        if (m_pContext->pLogger != NULL) {
            m_pContext->pLogger->LogError(StringFormat("%s value %.2f is out of range [%.2f, %.2f]", 
                                                    param_name, value, min_val, max_val), __FUNCTION__);
        }
        return false;
    }
    return true;
}

bool CConfigManager::ValidateIntegerRange(const int value, const int min_val, const int max_val, const string& param_name) {
    if (value < min_val || value > max_val) {
        if (m_pContext->pLogger != NULL) {
            m_pContext->pLogger->LogError(StringFormat("%s value %d is out of range [%d, %d]", 
                                                    param_name, value, min_val, max_val), __FUNCTION__);
        }
        return false;
    }
    return true;
}

bool CConfigManager::CreateConfigDirectories() {
    string terminal_path = TerminalInfoString(TERMINAL_DATA_PATH);
    m_sBackupPath = terminal_path + "\\MQL5\\Files\\APEX_Config\\";
    
    // Create directory if it doesn't exist
    if (!FolderCreate("APEX_Config", FILE_COMMON)) {
        // Directory might already exist, which is fine
    }
    
    return true;
}

string CConfigManager::GenerateConfigFileName() {
    return "APEX_Config\\apex_pullback_v5.cfg";
}

void CConfigManager::SetDefaultParameters() {
    if (m_pContext == NULL) return;
    
    // Set safe default values
    m_pContext->Inputs.LotSize = 0.1;
    m_pContext->Inputs.StopLoss = 50;
    m_pContext->Inputs.TakeProfit = 100;
    m_pContext->Inputs.MagicNumber = 12345;
    m_pContext->Inputs.RiskPercentage = 2.0;
    m_pContext->Inputs.MaxDailyLoss = 5.0;
    m_pContext->Inputs.MaxPositions = 3;
    m_pContext->Inputs.PullbackPercentage = 38.2;
    m_pContext->Inputs.TrendStrengthThreshold = 70.0;
    m_pContext->Inputs.MaxSlippage = 3;
    m_pContext->Inputs.NewsFilterMinutes = 30;
    m_pContext->Inputs.AnalysisTimeframe = PERIOD_H1;
    m_pContext->Inputs.TradingEnabled = true;
    m_pContext->Inputs.UseNewsFilter = true;
    m_pContext->Inputs.UseTrailingStop = true;
}

string CConfigManager::GetConfigurationSummary() {
    if (m_pContext == NULL) return "Configuration not available";
    
    return StringFormat("Config Summary - Lot: %.2f | SL: %d | TP: %d | Risk: %.1f%% | MaxPos: %d | Pullback: %.1f%%",
                        m_pContext->Inputs.LotSize,
                        m_pContext->Inputs.StopLoss,
                        m_pContext->Inputs.TakeProfit,
                        m_pContext->Inputs.RiskPercentage,
                        m_pContext->Inputs.MaxPositions,
                        m_pContext->Inputs.PullbackPercentage);
}

} // namespace ApexPullback

#endif // CONFIGURATION_MQH_