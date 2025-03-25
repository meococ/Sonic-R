//+------------------------------------------------------------------+
//|                                      SonicR_PropSettings.mqh     |
//|                SonicR PropFirm EA - PropFirm Settings Component  |
//+------------------------------------------------------------------+
#property copyright "SonicR Trading Systems"
#property link      "https://sonicr.com"

#include "SonicR_Logger.mqh"

// Forward declarations cho các class được sử dụng
class CRiskManager;
class CAdaptiveFilters;
class CSessionFilter;
class CPVSRA;
class CSonicRCore;
class CEntryManager;
class CExitManager;

// Khai báo extern ở mức độ file (toàn cục)
extern CRiskManager* g_riskManager;
extern CAdaptiveFilters* g_adaptiveFilters;
extern CSessionFilter* g_sessionFilter;
extern CPVSRA* g_pvsra;
extern CSonicRCore* g_sonicCore;
extern CEntryManager* g_entryManager;
extern CExitManager* g_exitManager;

// PropFirm types
enum ENUM_PROP_FIRM
{
    PROP_FIRM_FTMO,        // FTMO
    PROP_FIRM_THE5ERS,     // The5ers
    PROP_FIRM_E8,          // E8 Funding
    PROP_FIRM_MFF,         // MyForexFunds
    PROP_FIRM_CUSTOM       // Custom Settings
};

// Challenge phases
enum ENUM_CHALLENGE_PHASE
{
    PHASE_CHALLENGE,       // Challenge Phase
    PHASE_VERIFICATION,    // Verification Phase
    PHASE_FUNDED           // Funded Account
};

// PropFirm settings class for challenge management
class CPropSettings
{
private:
    // Logger
    CLogger* m_logger;
    
    // PropFirm settings
    ENUM_PROP_FIRM m_propFirm;             // Current PropFirm
    ENUM_CHALLENGE_PHASE m_phase;          // Current challenge phase
    
    // Target and limits
    double m_targetProfit;                 // Target profit percentage
    double m_maxDrawdown;                  // Maximum drawdown allowed
    double m_maxDailyDrawdown;             // Maximum daily drawdown
    int m_maxDaysAllowed;                  // Maximum days allowed
    
    // Challenge progress
    double m_currentProfit;                // Current profit percentage
    double m_maxDrawdownReached;           // Maximum drawdown reached
    double m_maxDailyDrawdownReached;      // Maximum daily drawdown reached
    int m_daysElapsed;                     // Days elapsed in challenge
    
    // Custom values
    double m_customTargetProfit;           // Custom target profit
    double m_customMaxDrawdown;            // Custom max drawdown
    double m_customDailyDrawdown;          // Custom daily drawdown
    
    // Initial account values
    double m_initialBalance;               // Initial account balance
    double m_initialEquity;                // Initial account equity
    datetime m_challengeStartDate;         // Challenge start date
    
    // Time management
    int m_challengeTotalDays;             // Total days in the challenge
    int m_challengeRemainingDays;         // Remaining days in the challenge
    
    // Emergency mode
    bool m_isEmergencyMode;
    bool m_isCloseToTarget;
    
    // Helper methods
    void ConfigurePropFirm();
    void CalculateProgress();
    void LogProgress();
    
public:
    // Constructor
    CPropSettings(ENUM_PROP_FIRM propFirm = PROP_FIRM_FTMO, 
                 ENUM_CHALLENGE_PHASE phase = PHASE_CHALLENGE);
    
    // Destructor
    ~CPropSettings();
    
    // Main methods
    void Update();
    void Reset();
    ENUM_CHALLENGE_PHASE AutoDetectPhase();
    
    // Setters
    void SetPropFirm(ENUM_PROP_FIRM propFirm);
    void SetPhase(ENUM_CHALLENGE_PHASE phase);
    void SetCustomValues(double targetProfit, double maxDrawdown, double dailyDrawdown);
    
    // Getters
    ENUM_PROP_FIRM GetPropFirm() const { return m_propFirm; }
    ENUM_CHALLENGE_PHASE GetPhase() const { return m_phase; }
    
    double GetTargetProfit() const { return m_targetProfit; }
    double GetMaxDrawdown() const { return m_maxDrawdown; }
    double GetMaxDailyDrawdown() const { return m_maxDailyDrawdown; }
    int GetMaxDaysAllowed() const { return m_maxDaysAllowed; }
    
    double GetCurrentProfit() const { return m_currentProfit; }
    double GetMaxDrawdownReached() const { return m_maxDrawdownReached; }
    double GetProgressPercentage() const;
    int GetRemainingDays() const;
    
    // Time management
    void SetChallengeTimeframe(datetime startDate, int totalDays);
    int GetTotalDays() const { return m_challengeTotalDays; }
    datetime GetStartDate() const { return m_challengeStartDate; }
    double GetProgressPercent() const;
    
    // Emergency mode
    bool IsEmergencyMode() const { return m_isEmergencyMode; }
    bool IsCloseToTarget() const { return m_isCloseToTarget; }
    
    // PropFirm-specific optimizations
    void OptimizeForPropFirm();
    void OptimizeForFTMO();
    void OptimizeForThe5ers();
    void OptimizeForMFF();
    void OptimizeForE8();
    
    // Set dependencies
    void SetLogger(CLogger* logger) { m_logger = logger; }
    
    // Utility
    string GetStatusText() const;
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPropSettings::CPropSettings(ENUM_PROP_FIRM propFirm, ENUM_CHALLENGE_PHASE phase)
{
    m_logger = NULL;
    
    // Set initial values
    m_propFirm = propFirm;
    m_phase = phase;
    
    // Initialize progress variables
    m_currentProfit = 0.0;
    m_maxDrawdownReached = 0.0;
    m_maxDailyDrawdownReached = 0.0;
    m_daysElapsed = 0;
    
    // Initialize custom values with defaults
    m_customTargetProfit = 10.0;
    m_customMaxDrawdown = 10.0;
    m_customDailyDrawdown = 5.0;
    
    // Store initial account values
    m_initialBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    m_initialEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    m_challengeStartDate = TimeCurrent();
    
    // Initialize time management variables
    m_challengeTotalDays = 30; // Default 30 days
    m_challengeRemainingDays = m_challengeTotalDays;
    
    // Configure PropFirm settings
    ConfigurePropFirm();
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPropSettings::~CPropSettings()
{
    // Nothing to clean up
}

//+------------------------------------------------------------------+
//| Configure settings based on PropFirm and phase                   |
//+------------------------------------------------------------------+
void CPropSettings::ConfigurePropFirm()
{
    // Default settings
    m_targetProfit = 10.0;
    m_maxDrawdown = 10.0;
    m_maxDailyDrawdown = 5.0;
    m_maxDaysAllowed = 30;
    
    // Adjust based on PropFirm
    switch(m_propFirm) {
        case PROP_FIRM_FTMO:
            // FTMO settings
            m_targetProfit = 10.0;     // 10% target
            m_maxDrawdown = 10.0;      // 10% max drawdown
            m_maxDailyDrawdown = 5.0;  // 5% daily max drawdown
            m_maxDaysAllowed = 30;     // 30 days challenge
            break;
            
        case PROP_FIRM_THE5ERS:
            // The5ers settings
            m_targetProfit = 6.0;      // 6% target (lower)
            m_maxDrawdown = 4.0;       // 4% max drawdown (stricter)
            m_maxDailyDrawdown = 4.0;  // 4% daily max drawdown
            m_maxDaysAllowed = 60;     // 60 days challenge (more time)
            break;
            
        case PROP_FIRM_MFF:
            // MyForexFunds settings
            m_targetProfit = 10.0;     // 10% target
            m_maxDrawdown = 12.0;      // 12% max drawdown (more relaxed)
            m_maxDailyDrawdown = 5.0;  // 5% daily max drawdown
            m_maxDaysAllowed = 30;     // 30 days challenge
            break;
            
        case PROP_FIRM_E8:
            // E8 Funding settings
            m_targetProfit = 8.0;      // 8% target
            m_maxDrawdown = 8.0;       // 8% max drawdown
            m_maxDailyDrawdown = 4.0;  // 4% daily max drawdown
            m_maxDaysAllowed = 45;     // 45 days challenge
            break;
            
        case PROP_FIRM_CUSTOM:
            // Custom settings
            m_targetProfit = m_customTargetProfit;
            m_maxDrawdown = m_customMaxDrawdown;
            m_maxDailyDrawdown = m_customDailyDrawdown;
            m_maxDaysAllowed = 30;     // Default to 30 days
            break;
    }
    
    // Adjust based on phase
    switch(m_phase) {
        case PHASE_CHALLENGE:
            // No adjustments for challenge phase (base values)
            break;
            
        case PHASE_VERIFICATION:
            // Verification phase (typically same as challenge)
            break;
            
        case PHASE_FUNDED:
            // Funded phase (can be more relaxed)
            m_targetProfit *= 0.8;     // 80% of challenge target (more achievable)
            m_maxDaysAllowed = 30;     // Reset to 30 days (monthly target)
            break;
    }
    
    // Log configuration
    if(m_logger) {
        m_logger.Info("PropFirm configured: " + EnumToString(m_propFirm) + 
                    ", Phase: " + EnumToString(m_phase));
        
        m_logger.Info("Settings: Target=" + DoubleToString(m_targetProfit, 1) + 
                    "%, MaxDD=" + DoubleToString(m_maxDrawdown, 1) + 
                    "%, DailyDD=" + DoubleToString(m_maxDailyDrawdown, 1) + 
                    "%, Days=" + IntegerToString(m_maxDaysAllowed));
    }
}

//+------------------------------------------------------------------+
//| Update progress calculations                                     |
//+------------------------------------------------------------------+
void CPropSettings::Update()
{
    // Calculate current values
    CalculateProgress();
    
    // Log progress periodically
    static datetime lastProgressLog = 0;
    if(TimeCurrent() - lastProgressLog > 3600) { // Log hourly
        LogProgress();
        lastProgressLog = TimeCurrent();
    }
}

//+------------------------------------------------------------------+
//| Calculate challenge progress                                     |
//+------------------------------------------------------------------+
void CPropSettings::CalculateProgress()
{
    // Get current account values
    double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    
    // Calculate current profit percentage
    if(m_initialBalance > 0) {
        m_currentProfit = (currentBalance - m_initialBalance) / m_initialBalance * 100.0;
    }
    
    // Calculate current drawdown
    double highWaterMark = MathMax(m_initialEquity, currentEquity);
    for(int i = 0; i < OrdersHistoryTotal(); i++) {
        if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
            double closedProfit = OrderProfit();
            highWaterMark = MathMax(highWaterMark, m_initialEquity + closedProfit);
        }
    }
    
    double currentDrawdown = (highWaterMark - currentEquity) / highWaterMark * 100.0;
    m_maxDrawdownReached = MathMax(m_maxDrawdownReached, currentDrawdown);
    
    // Calculate daily drawdown (simplified - would need daily tracking in a real implementation)
    static datetime lastDay = 0;
    datetime currentDay = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
    
    if(currentDay != lastDay) {
        // Reset daily high water mark on new day
        static double dailyHighWaterMark = currentEquity;
        dailyHighWaterMark = currentEquity;
        lastDay = currentDay;
    }
    
    static double dailyHighWaterMark = currentEquity;
    dailyHighWaterMark = MathMax(dailyHighWaterMark, currentEquity);
    
    double dailyDrawdown = (dailyHighWaterMark - currentEquity) / dailyHighWaterMark * 100.0;
    m_maxDailyDrawdownReached = MathMax(m_maxDailyDrawdownReached, dailyDrawdown);
    
    // Calculate days elapsed
    m_daysElapsed = (int)((TimeCurrent() - m_challengeStartDate) / (24 * 3600));
}

//+------------------------------------------------------------------+
//| Log challenge progress                                           |
//+------------------------------------------------------------------+
void CPropSettings::LogProgress()
{
    if(!m_logger) return;
    
    m_logger.Info("Challenge Progress: " + DoubleToString(GetProgressPercentage(), 1) + "% complete");
    m_logger.Info("Profit: " + DoubleToString(m_currentProfit, 2) + "% / " + 
                DoubleToString(m_targetProfit, 2) + "%");
    
    m_logger.Info("Max DD: " + DoubleToString(m_maxDrawdownReached, 2) + "% / " + 
                DoubleToString(m_maxDrawdown, 2) + "%");
    
    m_logger.Info("Days: " + IntegerToString(m_daysElapsed) + " / " + 
                IntegerToString(m_maxDaysAllowed) + " (" + 
                IntegerToString(GetRemainingDays()) + " remaining)");
}

//+------------------------------------------------------------------+
//| Reset challenge progress                                         |
//+------------------------------------------------------------------+
void CPropSettings::Reset()
{
    // Reset progress variables
    m_currentProfit = 0.0;
    m_maxDrawdownReached = 0.0;
    m_maxDailyDrawdownReached = 0.0;
    m_daysElapsed = 0;
    
    // Reset start date and initial values
    m_challengeStartDate = TimeCurrent();
    m_initialBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    m_initialEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    
    // Reset time management variables
    m_challengeTotalDays = 30; // Default 30 days
    m_challengeRemainingDays = m_challengeTotalDays;
    
    if(m_logger) {
        m_logger.Info("Challenge progress reset. New start date: " + 
                    TimeToString(m_challengeStartDate));
    }
}

//+------------------------------------------------------------------+
//| Auto-detect challenge phase based on account metrics             |
//+------------------------------------------------------------------+
ENUM_CHALLENGE_PHASE CPropSettings::AutoDetectPhase()
{
    // Get account info
    long accountNumber = AccountInfoInteger(ACCOUNT_LOGIN);
    string accountName = AccountInfoString(ACCOUNT_NAME);
    double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    
    // Look for phase indicators in account name or number
    if(StringFind(accountName, "CHALL", 0) >= 0 || 
       StringFind(accountName, "PHASE1", 0) >= 0) {
        if(m_logger) m_logger.Info("Auto-detected CHALLENGE phase from account name");
        return PHASE_CHALLENGE;
    }
    else if(StringFind(accountName, "VERIF", 0) >= 0 || 
            StringFind(accountName, "PHASE2", 0) >= 0) {
        if(m_logger) m_logger.Info("Auto-detected VERIFICATION phase from account name");
        return PHASE_VERIFICATION;
    }
    else if(StringFind(accountName, "FUND", 0) >= 0 || 
            StringFind(accountName, "LIVE", 0) >= 0) {
        if(m_logger) m_logger.Info("Auto-detected FUNDED phase from account name");
        return PHASE_FUNDED;
    }
    
    // Try to detect based on account balance
    // This is just a heuristic - real detection would need more specific logic
    if(accountBalance >= 100000) {
        if(m_logger) m_logger.Info("Auto-detected FUNDED phase from large account balance");
        return PHASE_FUNDED;
    }
    
    // Default to challenge phase if can't detect
    if(m_logger) m_logger.Info("Could not auto-detect phase, defaulting to CHALLENGE");
    return PHASE_CHALLENGE;
}

//+------------------------------------------------------------------+
//| Set PropFirm type                                                |
//+------------------------------------------------------------------+
void CPropSettings::SetPropFirm(ENUM_PROP_FIRM propFirm)
{
    if(m_propFirm != propFirm) {
        m_propFirm = propFirm;
        ConfigurePropFirm();
        
        // Apply PropFirm-specific optimizations
        OptimizeForPropFirm();
    }
}

//+------------------------------------------------------------------+
//| Set challenge phase                                              |
//+------------------------------------------------------------------+
void CPropSettings::SetPhase(ENUM_CHALLENGE_PHASE phase)
{
    if(m_phase != phase) {
        m_phase = phase;
        ConfigurePropFirm();
    }
}

//+------------------------------------------------------------------+
//| Set custom PropFirm values                                       |
//+------------------------------------------------------------------+
void CPropSettings::SetCustomValues(double targetProfit, double maxDrawdown, double dailyDrawdown)
{
    m_customTargetProfit = targetProfit;
    m_customMaxDrawdown = maxDrawdown;
    m_customDailyDrawdown = dailyDrawdown;
    
    if(m_propFirm == PROP_FIRM_CUSTOM) {
        ConfigurePropFirm();
    }
}

//+------------------------------------------------------------------+
//| Get challenge progress percentage                                |
//+------------------------------------------------------------------+
double CPropSettings::GetProgressPercentage() const
{
    if(m_targetProfit <= 0) return 0.0;
    
    return MathMin(100.0, m_currentProfit / m_targetProfit * 100.0);
}

//+------------------------------------------------------------------+
//| Get remaining days in challenge                                  |
//+------------------------------------------------------------------+
int CPropSettings::GetRemainingDays() const
{
    return MathMax(0, m_maxDaysAllowed - m_daysElapsed);
}

//+------------------------------------------------------------------+
//| Get status text for diagnostics                                  |
//+------------------------------------------------------------------+
string CPropSettings::GetStatusText() const
{
    string status = "PropFirm Settings Status:\n";
    
    // PropFirm and phase
    status += "PropFirm: " + EnumToString(m_propFirm) + "\n";
    status += "Phase: " + EnumToString(m_phase) + "\n";
    
    // Targets and limits
    status += "Target Profit: " + DoubleToString(m_targetProfit, 1) + "%\n";
    status += "Max Drawdown: " + DoubleToString(m_maxDrawdown, 1) + "%\n";
    status += "Max Daily DD: " + DoubleToString(m_maxDailyDrawdown, 1) + "%\n";
    status += "Max Days: " + IntegerToString(m_maxDaysAllowed) + "\n";
    
    // Current progress
    status += "Current Profit: " + DoubleToString(m_currentProfit, 1) + "%\n";
    status += "Max DD Reached: " + DoubleToString(m_maxDrawdownReached, 1) + "%\n";
    status += "Progress: " + DoubleToString(GetProgressPercentage(), 1) + "%\n";
    status += "Days Elapsed: " + IntegerToString(m_daysElapsed) + 
             " (" + IntegerToString(GetRemainingDays()) + " remaining)\n";
    
    return status;
}

//+------------------------------------------------------------------+
//| Set challenge timeframe                                          |
//+------------------------------------------------------------------+
void CPropSettings::SetChallengeTimeframe(datetime startDate, int totalDays)
{
    m_challengeStartDate = startDate;
    m_challengeTotalDays = totalDays;
    
    // Calculate remaining days
    int secondsPerDay = 24 * 60 * 60;
    int secondsElapsed = (int)(TimeCurrent() - m_challengeStartDate);
    int daysElapsed = secondsElapsed / secondsPerDay;
    
    m_challengeRemainingDays = m_challengeTotalDays - daysElapsed;
    
    // Ensure remaining days is not negative
    if(m_challengeRemainingDays < 0) {
        m_challengeRemainingDays = 0;
    }
}

//+------------------------------------------------------------------+
//| Get progress percentage of challenge                             |
//+------------------------------------------------------------------+
double CPropSettings::GetProgressPercent() const
{
    if(m_challengeTotalDays <= 0) return 0.0;
    
    double daysElapsed = m_challengeTotalDays - m_challengeRemainingDays;
    return 100.0 * daysElapsed / m_challengeTotalDays;
}

//+------------------------------------------------------------------+
//| PropFirm-specific optimizations                                  |
//+------------------------------------------------------------------+
void CPropSettings::OptimizeForPropFirm()
{
    if(m_logger) m_logger.Info("Optimizing EA parameters for " + EnumToString(m_propFirm));
    
    switch(m_propFirm) {
        case PROP_FIRM_FTMO:
            OptimizeForFTMO();
            break;
            
        case PROP_FIRM_THE5ERS:
            OptimizeForThe5ers();
            break;
            
        case PROP_FIRM_MFF:
            OptimizeForMFF();
            break;
            
        case PROP_FIRM_E8:
            OptimizeForE8();
            break;
            
        case PROP_FIRM_CUSTOM:
            // Custom settings already set
            break;
            
        default:
            if(m_logger) m_logger.Warning("Unknown PropFirm type, using default settings");
            break;
    }
}

//+------------------------------------------------------------------+
//| FTMO specific optimizations                                      |
//+------------------------------------------------------------------+
void CPropSettings::OptimizeForFTMO()
{
    // FTMO strategy: Balance between win rate and profit factor
    
    // Risk parameters
    if(g_riskManager != NULL) {
        // FTMO has 10% max DD, 5% daily DD
        // Be conservative - stay below limits
        g_riskManager.SetRiskPercent(0.5);     // 0.5% per trade
        g_riskManager.SetMaxDailyDD(3.5);      // 3.5% daily DD limit
        g_riskManager.SetMaxTotalDD(7.0);      // 7% total DD limit
        g_riskManager.SetMaxTradesPerDay(3);   // Limit to 3 trades per day
        
        // Set recovery mode to be more conservative
        g_riskManager.SetRecoveryMode(true, 0.5);  // 50% reduction in recovery
        
        if(m_logger) m_logger.Info("FTMO: Risk parameters optimized");
    }
    
    // Session filter
    if(g_sessionFilter != NULL) {
        // FTMO is more European-focused
        g_sessionFilter.SetSessionSettings(true, true, true, false);  // All except Asian
        g_sessionFilter.SetFridaySettings(true, 16);  // Trade Friday until 16:00 GMT
        
        if(m_logger) m_logger.Info("FTMO: Session settings optimized");
    }
    
    // PVSRA settings
    if(g_pvsra != NULL) {
        // Higher volume thresholds for more quality
        g_pvsra.SetParameters(20, 10, 3);
        g_pvsra.SetThresholds(1.7, 0.6);
        
        if(m_logger) m_logger.Info("FTMO: PVSRA settings optimized");
    }
    
    // Entry settings
    if(g_entryManager != NULL) {
        // Focus on quality over quantity
        g_entryManager.SetMinRR(1.8);              // Higher R:R
        g_entryManager.SetMinSignalQuality(75.0);  // Higher quality threshold
        g_entryManager.SetUseScoutEntries(false);  // No scout entries
        
        if(m_logger) m_logger.Info("FTMO: Entry settings optimized");
    }
    
    // Exit settings
    if(g_exitManager != NULL) {
        // Conservative exit strategy
        g_exitManager.SetPartialCloseSettings(true, 60.0, 1.5, 2.5);  // Close 60% at TP1
        g_exitManager.SetBreakEvenSettings(true, 0.6, 5.0);          // Earlier breakeven
        g_exitManager.SetTrailingSettings(true, 1.3, 15.0, true);    // Start trailing earlier
        
        if(m_logger) m_logger.Info("FTMO: Exit settings optimized");
    }
    
    // Adaptive filters (if available)
    if(g_adaptiveFilters != NULL) {
        // Set more conservative thresholds
        g_adaptiveFilters.SetProgressThresholds(35.0, 75.0);  // Emergency at 35%, conservative at 75%
        
        if(m_logger) m_logger.Info("FTMO: Adaptive filters optimized");
    }
}

//+------------------------------------------------------------------+
//| The5ers specific optimizations                                   |
//+------------------------------------------------------------------+
void CPropSettings::OptimizeForThe5ers()
{
    // The5ers strategy: Ultra conservative
    
    // Risk parameters - The5ers has stricter drawdown requirements
    if(g_riskManager != NULL) {
        g_riskManager.SetRiskPercent(0.4);     // Lower risk per trade
        g_riskManager.SetMaxDailyDD(2.5);      // Lower daily DD limit
        g_riskManager.SetMaxTotalDD(3.5);      // Lower total DD limit
        g_riskManager.SetMaxTradesPerDay(2);   // Fewer trades per day
        g_riskManager.SetRecoveryMode(true, 0.4);  // More aggressive reduction
        
        if(m_logger) m_logger.Info("The5ers: Risk parameters optimized - ultra conservative");
    }
    
    // Session filter
    if(g_sessionFilter != NULL) {
        // Only the best sessions
        g_sessionFilter.SetSessionSettings(true, true, true, false);
        g_sessionFilter.SetFridaySettings(false, 0);  // No Friday trading
        
        if(m_logger) m_logger.Info("The5ers: Session settings optimized - only best sessions");
    }
    
    // PVSRA settings
    if(g_pvsra != NULL) {
        // Even higher thresholds
        g_pvsra.SetParameters(25, 10, 4);  // Longer volume average period, more confirmation bars
        g_pvsra.SetThresholds(1.8, 0.5);   // Higher volume threshold, lower spread threshold
        
        if(m_logger) m_logger.Info("The5ers: PVSRA settings optimized - higher quality");
    }
    
    // Entry settings
    if(g_entryManager != NULL) {
        // Very high quality only
        g_entryManager.SetMinRR(2.0);              // Higher R:R
        g_entryManager.SetMinSignalQuality(80.0);  // Higher quality threshold
        g_entryManager.SetUseScoutEntries(false);  // No scout entries
        
        if(m_logger) m_logger.Info("The5ers: Entry settings optimized - high quality only");
    }
    
    // Exit settings
    if(g_exitManager != NULL) {
        // Very conservative exits
        g_exitManager.SetPartialCloseSettings(true, 70.0, 1.4, 2.5);  // Close 70% at TP1
        g_exitManager.SetBreakEvenSettings(true, 0.5, 5.0);          // Very early breakeven
        g_exitManager.SetTrailingSettings(true, 1.2, 10.0, true);    // Tight trailing
        
        if(m_logger) m_logger.Info("The5ers: Exit settings optimized - conservative exits");
    }
    
    // Adaptive filters (if available)
    if(g_adaptiveFilters != NULL) {
        // Very conservative thresholds
        g_adaptiveFilters.SetProgressThresholds(40.0, 70.0);  // Even earlier emergency & conservative modes
        
        if(m_logger) m_logger.Info("The5ers: Adaptive filters optimized - very conservative");
    }
}

//+------------------------------------------------------------------+
//| MFF specific optimizations                                       |
//+------------------------------------------------------------------+
void CPropSettings::OptimizeForMFF()
{
    // MFF strategy: More balanced, slightly higher risk
    
    // Risk parameters - MFF has more relaxed drawdown limits
    if(g_riskManager != NULL) {
        g_riskManager.SetRiskPercent(0.7);     // Higher risk per trade
        g_riskManager.SetMaxDailyDD(3.5);      // Standard daily DD limit
        g_riskManager.SetMaxTotalDD(8.0);      // Higher total DD limit
        g_riskManager.SetMaxTradesPerDay(4);   // More trades allowed
        g_riskManager.SetRecoveryMode(true, 0.6);  // Less reduction in recovery
        
        if(m_logger) m_logger.Info("MFF: Risk parameters optimized - more balanced approach");
    }
    
    // Session filter
    if(g_sessionFilter != NULL) {
        // Allow all major sessions
        g_sessionFilter.SetSessionSettings(true, true, true, false);
        g_sessionFilter.SetFridaySettings(true, 18);  // Trade Friday until later
        
        if(m_logger) m_logger.Info("MFF: Session settings optimized - more trading hours");
    }
    
    // PVSRA settings
    if(g_pvsra != NULL) {
        // Standard thresholds
        g_pvsra.SetParameters(20, 10, 3);  // Standard settings
        g_pvsra.SetThresholds(1.5, 0.7);   // Standard thresholds
        
        if(m_logger) m_logger.Info("MFF: PVSRA settings optimized - standard quality");
    }
    
    // Entry settings
    if(g_entryManager != NULL) {
        // Standard quality
        g_entryManager.SetMinRR(1.5);              // Standard R:R
        g_entryManager.SetMinSignalQuality(70.0);  // Standard quality threshold
        g_entryManager.SetUseScoutEntries(true);   // Allow scout entries in strong trends
        
        if(m_logger) m_logger.Info("MFF: Entry settings optimized - more trading opportunities");
    }
    
    // Exit settings
    if(g_exitManager != NULL) {
        // Standard exit strategy
        g_exitManager.SetPartialCloseSettings(true, 50.0, 1.5, 2.5);  // Close 50% at TP1
        g_exitManager.SetBreakEvenSettings(true, 0.7, 10.0);         // Standard breakeven
        g_exitManager.SetTrailingSettings(true, 1.5, 20.0, true);    // Looser trailing
        
        if(m_logger) m_logger.Info("MFF: Exit settings optimized - balanced exits");
    }
    
    // Adaptive filters (if available)
    if(g_adaptiveFilters != NULL) {
        // Standard thresholds
        g_adaptiveFilters.SetProgressThresholds(30.0, 80.0);  // Standard thresholds
        
        if(m_logger) m_logger.Info("MFF: Adaptive filters optimized - standard settings");
    }
}

//+------------------------------------------------------------------+
//| E8 Funding specific optimizations                                |
//+------------------------------------------------------------------+
void CPropSettings::OptimizeForE8()
{
    // E8 Funding strategy: Balanced approach with moderate risk
    
    // Risk parameters - Using E8 specific settings
    if(g_riskManager != NULL) {
        g_riskManager.SetRiskPercent(0.6);     // Moderate risk per trade
        g_riskManager.SetMaxDailyDD(3.0);      // Moderate daily DD limit
        g_riskManager.SetMaxTotalDD(7.0);      // Standard total DD limit
        g_riskManager.SetMaxTradesPerDay(3);   // Standard trades per day
        g_riskManager.SetRecoveryMode(true, 0.5);  // Standard reduction in recovery
        
        if(m_logger) m_logger.Info("E8: Risk parameters optimized - balanced approach");
    }
    
    // Session filter
    if(g_sessionFilter != NULL) {
        // Focus on main sessions
        g_sessionFilter.SetSessionSettings(true, true, true, false);  // All major sessions except Asian
        g_sessionFilter.SetFridaySettings(true, 17);  // Trade Friday until 17:00 GMT
        
        if(m_logger) m_logger.Info("E8: Session settings optimized - main trading sessions");
    }
    
    // PVSRA settings
    if(g_pvsra != NULL) {
        // Balanced thresholds
        g_pvsra.SetParameters(22, 10, 3);  // Slightly longer volume average period
        g_pvsra.SetThresholds(1.6, 0.65);  // Balanced thresholds
        
        if(m_logger) m_logger.Info("E8: PVSRA settings optimized - balanced quality");
    }
    
    // Entry settings
    if(g_entryManager != NULL) {
        // Good quality entries
        g_entryManager.SetMinRR(1.7);              // Good R:R
        g_entryManager.SetMinSignalQuality(72.0);  // Good quality threshold
        g_entryManager.SetUseScoutEntries(true);   // Allow limited scout entries
        
        if(m_logger) m_logger.Info("E8: Entry settings optimized - good quality entries");
    }
    
    // Exit settings
    if(g_exitManager != NULL) {
        // Balanced exit strategy using user-specified parameters
        g_exitManager.SetPartialCloseSettings(true, 55.0, 1.4, 2.3);  // 55% partial close at TP1
        g_exitManager.SetBreakEvenSettings(true, 0.65, 7.0);         // Moderate breakeven
        g_exitManager.SetTrailingSettings(true, 1.4, 15.0, true);    // Balanced trailing
        
        if(m_logger) m_logger.Info("E8: Exit settings optimized - balanced exits");
    }
    
    // Adaptive filters (if available)
    if(g_adaptiveFilters != NULL) {
        // Balanced thresholds
        g_adaptiveFilters.SetProgressThresholds(32.0, 78.0);  // Balanced thresholds
        
        if(m_logger) m_logger.Info("E8: Adaptive filters optimized - balanced settings");
    }
}