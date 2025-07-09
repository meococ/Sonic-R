//+------------------------------------------------------------------+
//|                                        TrailingStopManager.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "../../01_Core/CommonStructs.mqh"

//+------------------------------------------------------------------+
//| Trailing stop enumerations                                      |
//+------------------------------------------------------------------+
enum ENUM_TRAILING_TYPE {
    TRAILING_FIXED,              // Fixed distance trailing
    TRAILING_PERCENTAGE,         // Percentage-based trailing
    TRAILING_ATR,               // ATR-based trailing
    TRAILING_PARABOLIC_SAR,     // Parabolic SAR trailing
    TRAILING_MOVING_AVERAGE,    // Moving average trailing
    TRAILING_SUPPORT_RESISTANCE, // Support/resistance trailing
    TRAILING_VOLATILITY,        // Volatility-based trailing
    TRAILING_BREAKEVEN,         // Break-even trailing
    TRAILING_STEP,              // Step trailing
    TRAILING_ADAPTIVE,          // Adaptive trailing
    TRAILING_CUSTOM             // Custom trailing logic
};

enum ENUM_TRAILING_STATUS {
    TRAILING_INACTIVE,
    TRAILING_ACTIVE,
    TRAILING_PAUSED,
    TRAILING_TRIGGERED,
    TRAILING_COMPLETED,
    TRAILING_ERROR
};

enum ENUM_TRAILING_MODE {
    TRAILING_MODE_CONSERVATIVE,  // Conservative trailing
    TRAILING_MODE_MODERATE,      // Moderate trailing
    TRAILING_MODE_AGGRESSIVE,    // Aggressive trailing
    TRAILING_MODE_CUSTOM         // Custom mode
};

enum ENUM_BREAKEVEN_TYPE {
    BREAKEVEN_IMMEDIATE,         // Move to breakeven immediately
    BREAKEVEN_AFTER_DISTANCE,   // Move after certain distance
    BREAKEVEN_AFTER_PROFIT,     // Move after certain profit
    BREAKEVEN_NEVER             // Never move to breakeven
};

enum ENUM_TRAILING_TRIGGER {
    TRIGGER_IMMEDIATE,           // Start trailing immediately
    TRIGGER_AFTER_PROFIT,       // Start after profit threshold
    TRIGGER_AFTER_DISTANCE,     // Start after distance threshold
    TRIGGER_MANUAL              // Manual trigger
};

//+------------------------------------------------------------------+
//| Trailing stop structures                                        |
//+------------------------------------------------------------------+
struct STrailingConfig {
    ENUM_TRAILING_TYPE Type;
    ENUM_TRAILING_MODE Mode;
    ENUM_TRAILING_TRIGGER Trigger;
    ENUM_BREAKEVEN_TYPE BreakevenType;
    
    // Distance settings
    double TrailingDistance;     // Trailing distance (points/percentage)
    double MinTrailingDistance;  // Minimum trailing distance
    double MaxTrailingDistance;  // Maximum trailing distance
    double TrailingStep;         // Step size for trailing
    
    // Trigger settings
    double TriggerProfit;        // Profit threshold to start trailing
    double TriggerDistance;      // Distance threshold to start trailing
    double BreakevenDistance;    // Distance to move to breakeven
    double BreakevenProfit;      // Profit to move to breakeven
    
    // ATR settings
    int ATRPeriod;              // ATR period
    double ATRMultiplier;       // ATR multiplier
    
    // Moving average settings
    int MAPeriod;               // MA period
    ENUM_MA_METHOD MAMethod;    // MA method
    ENUM_APPLIED_PRICE MAPrice; // MA applied price
    
    // Parabolic SAR settings
    double SARStep;             // SAR step
    double SARMaximum;          // SAR maximum
    
    // Advanced settings
    bool EnablePartialClose;     // Enable partial position closing
    double PartialClosePercent;  // Percentage to close partially
    bool EnableTimeExit;         // Enable time-based exit
    int MaxHoldingTime;         // Maximum holding time (minutes)
    bool EnableVolatilityFilter; // Enable volatility filter
    double VolatilityThreshold; // Volatility threshold
    
    // Risk management
    double MaxLoss;             // Maximum allowed loss
    double MaxProfit;           // Maximum profit target
    bool EnableEmergencyStop;   // Enable emergency stop
    double EmergencyStopLevel;  // Emergency stop level
};

struct STrailingState {
    ulong PositionTicket;
    string Symbol;
    ENUM_POSITION_TYPE PositionType;
    ENUM_TRAILING_STATUS Status;
    
    double OpenPrice;
    double CurrentPrice;
    double CurrentStopLoss;
    double CurrentTakeProfit;
    double Volume;
    
    double LastTrailingPrice;    // Last price when trailing was updated
    double BestPrice;           // Best price achieved
    double TrailingLevel;       // Current trailing level
    double BreakevenLevel;      // Breakeven level
    
    datetime StartTime;
    datetime LastUpdateTime;
    datetime TriggerTime;       // When trailing was triggered
    
    bool IsTriggered;           // Whether trailing has been triggered
    bool IsBreakevenSet;        // Whether breakeven has been set
    bool IsPartialClosed;       // Whether partial close occurred
    
    int UpdateCount;            // Number of updates
    double TotalProfit;         // Total profit/loss
    double MaxProfit;           // Maximum profit achieved
    double MaxDrawdown;         // Maximum drawdown from peak
    
    string LastError;           // Last error message
};

struct STrailingStatistics {
    int TotalPositions;         // Total positions managed
    int ActiveTrailings;        // Currently active trailings
    int TriggeredTrailings;     // Triggered trailings
    int CompletedTrailings;     // Completed trailings
    int BreakevenHits;          // Breakeven hits
    int PartialCloses;          // Partial closes
    int EmergencyStops;         // Emergency stops
    
    double TotalProfit;         // Total profit from trailing
    double AverageProfit;       // Average profit per position
    double MaxProfit;           // Maximum profit achieved
    double MaxLoss;             // Maximum loss incurred
    double SuccessRate;         // Success rate percentage
    
    datetime FirstTrailing;     // First trailing start time
    datetime LastTrailing;      // Last trailing update time
    
    // Performance metrics
    double AverageHoldingTime;  // Average holding time
    double ProfitFactor;        // Profit factor
    double SharpeRatio;         // Sharpe ratio
    double MaxDrawdown;         // Maximum drawdown
};

struct STrailingAlert {
    ulong PositionTicket;
    string Symbol;
    ENUM_TRAILING_STATUS Status;
    string Message;
    datetime Timestamp;
    double Price;
    double StopLoss;
    bool IsUrgent;
};

//+------------------------------------------------------------------+
//| Trailing Stop Manager Class                                     |
//+------------------------------------------------------------------+
class CTrailingStopManager {
private:
    EAContext* m_pContext;
    
    // Configuration
    STrailingConfig m_Config;
    
    // Active trailing states
    STrailingState m_TrailingStates[];
    int m_StateCount;
    
    // Statistics
    STrailingStatistics m_Statistics;
    
    // Internal state
    bool m_bInitialized;
    bool m_bEnabled;
    datetime m_LastUpdate;
    
    // Helper methods
    bool UpdateTrailingStop(STrailingState& state);
    bool CalculateTrailingLevel(STrailingState& state, double& newLevel);
    bool CheckTriggerCondition(STrailingState& state);
    bool SetBreakeven(STrailingState& state);
    bool ExecutePartialClose(STrailingState& state);
    bool ModifyStopLoss(ulong ticket, double newStopLoss);
    bool CheckEmergencyConditions(STrailingState& state);
    bool ValidateTrailingLevel(const STrailingState& state, double level);
    
    // Calculation methods
    double CalculateFixedTrailing(const STrailingState& state);
    double CalculatePercentageTrailing(const STrailingState& state);
    double CalculateATRTrailing(const STrailingState& state);
    double CalculateParabolicSARTrailing(const STrailingState& state);
    double CalculateMATrailing(const STrailingState& state);
    double CalculateSupportResistanceTrailing(const STrailingState& state);
    double CalculateVolatilityTrailing(const STrailingState& state);
    double CalculateAdaptiveTrailing(const STrailingState& state);
    
    // Utility methods
    int FindStateIndex(ulong ticket);
    bool AddTrailingState(const STrailingState& state);
    bool RemoveTrailingState(ulong ticket);
    bool UpdateStatistics(const STrailingState& state);
    void SendAlert(const STrailingAlert& alert);
    void LogError(const string message);
    void LogActivity(const string message);
    
public:
    // Constructor/Destructor
    CTrailingStopManager();
    ~CTrailingStopManager();
    
    // Initialization
    bool Initialize(EAContext* context);
    bool Deinitialize();
    bool Configure(const STrailingConfig& config);
    
    // Main operations
    bool StartTrailing(ulong ticket);
    bool StopTrailing(ulong ticket);
    bool PauseTrailing(ulong ticket);
    bool ResumeTrailing(ulong ticket);
    bool UpdateAllTrailings();
    bool UpdateTrailing(ulong ticket);
    
    // Position management
    bool AddPosition(ulong ticket);
    bool RemovePosition(ulong ticket);
    bool IsPositionTracked(ulong ticket);
    int GetTrackedPositionCount();
    
    // Configuration management
    bool SetTrailingType(ENUM_TRAILING_TYPE type);
    bool SetTrailingDistance(double distance);
    bool SetTrailingMode(ENUM_TRAILING_MODE mode);
    bool SetBreakevenType(ENUM_BREAKEVEN_TYPE type);
    bool SetTriggerCondition(ENUM_TRAILING_TRIGGER trigger, double value);
    
    // Advanced features
    bool EnablePartialClose(bool enable, double percentage = 50.0);
    bool EnableTimeExit(bool enable, int maxTime = 1440);
    bool EnableVolatilityFilter(bool enable, double threshold = 0.02);
    bool EnableEmergencyStop(bool enable, double level = -100.0);
    
    // Manual operations
    bool TriggerTrailing(ulong ticket);
    bool SetManualBreakeven(ulong ticket);
    bool ExecuteManualPartialClose(ulong ticket, double percentage);
    bool SetManualStopLoss(ulong ticket, double stopLoss);
    
    // Information retrieval
    bool GetTrailingState(ulong ticket, STrailingState& state);
    STrailingConfig GetConfiguration() const { return m_Config; }
    STrailingStatistics GetStatistics() const { return m_Statistics; }
    bool GetActiveTrailings(ulong& tickets[]);
    
    // Analysis and reporting
    bool GenerateTrailingReport(string& report);
    bool GeneratePerformanceReport(string& report);
    double CalculateTrailingEfficiency();
    double CalculateAverageHoldingTime();
    
    // Optimization
    bool OptimizeTrailingParameters(const string symbol, int bars = 1000);
    bool BacktestTrailingStrategy(const string symbol, datetime from, datetime to);
    bool FindOptimalTrailingDistance(const string symbol);
    
    // Risk management
    bool CheckRiskLimits();
    bool ApplyRiskControls();
    bool ValidateTrailingSettings();
    
    // Alerts and notifications
    bool SetAlertLevel(ENUM_TRAILING_STATUS status, bool enable);
    bool SendTrailingAlert(ulong ticket, const string message);
    
    // Utility methods
    string GetTrailingTypeName(ENUM_TRAILING_TYPE type);
    string GetTrailingStatusName(ENUM_TRAILING_STATUS status);
    string GetTrailingModeName(ENUM_TRAILING_MODE mode);
    string GetBreakevenTypeName(ENUM_BREAKEVEN_TYPE type);
    
    // Status
    bool IsInitialized() const { return m_bInitialized; }
    bool IsEnabled() const { return m_bEnabled; }
    datetime GetLastUpdate() const { return m_LastUpdate; }
    
    // Control
    bool Enable(bool enable = true);
    bool Reset();
    bool ResetStatistics();
};

//+------------------------------------------------------------------+
//| Constructor                                                     |
//+------------------------------------------------------------------+
CTrailingStopManager::CTrailingStopManager() {
    m_pContext = NULL;
    m_StateCount = 0;
    m_bInitialized = false;
    m_bEnabled = true;
    m_LastUpdate = 0;
    
    ZeroMemory(m_Config);
    ZeroMemory(m_Statistics);
    
    // Set default configuration
    m_Config.Type = TRAILING_FIXED;
    m_Config.Mode = TRAILING_MODE_MODERATE;
    m_Config.Trigger = TRIGGER_IMMEDIATE;
    m_Config.BreakevenType = BREAKEVEN_AFTER_DISTANCE;
    
    m_Config.TrailingDistance = 50.0;      // 50 points
    m_Config.MinTrailingDistance = 10.0;   // 10 points
    m_Config.MaxTrailingDistance = 200.0;  // 200 points
    m_Config.TrailingStep = 10.0;          // 10 points
    
    m_Config.TriggerProfit = 30.0;         // 30 points profit
    m_Config.TriggerDistance = 20.0;       // 20 points distance
    m_Config.BreakevenDistance = 25.0;     // 25 points to breakeven
    m_Config.BreakevenProfit = 15.0;       // 15 points profit for breakeven
    
    m_Config.ATRPeriod = 14;
    m_Config.ATRMultiplier = 2.0;
    
    m_Config.MAPeriod = 20;
    m_Config.MAMethod = MODE_SMA;
    m_Config.MAPrice = PRICE_CLOSE;
    
    m_Config.SARStep = 0.02;
    m_Config.SARMaximum = 0.2;
    
    m_Config.EnablePartialClose = false;
    m_Config.PartialClosePercent = 50.0;
    m_Config.EnableTimeExit = false;
    m_Config.MaxHoldingTime = 1440;        // 24 hours
    m_Config.EnableVolatilityFilter = false;
    m_Config.VolatilityThreshold = 0.02;   // 2%
    
    m_Config.MaxLoss = -100.0;             // $100 max loss
    m_Config.MaxProfit = 500.0;            // $500 max profit
    m_Config.EnableEmergencyStop = true;
    m_Config.EmergencyStopLevel = -200.0;  // $200 emergency stop
}

//+------------------------------------------------------------------+
//| Destructor                                                      |
//+------------------------------------------------------------------+
CTrailingStopManager::~CTrailingStopManager() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize trailing stop manager                                |
//+------------------------------------------------------------------+
bool CTrailingStopManager::Initialize(EAContext* context) {
    if (context == NULL) {
        LogError("Invalid context provided");
        return false;
    }
    
    m_pContext = context;
    
    // Initialize arrays
    ArrayResize(m_TrailingStates, 100);  // Initial capacity for 100 positions
    m_StateCount = 0;
    
    // Initialize statistics
    m_Statistics.FirstTrailing = TimeCurrent();
    
    m_bInitialized = true;
    m_bEnabled = true;
    
    LogActivity("Trailing stop manager initialized successfully");
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize trailing stop manager                              |
//+------------------------------------------------------------------+
bool CTrailingStopManager::Deinitialize() {
    if (m_bInitialized) {
        // Stop all active trailings
        for (int i = 0; i < m_StateCount; i++) {
            if (m_TrailingStates[i].Status == TRAILING_ACTIVE) {
                m_TrailingStates[i].Status = TRAILING_INACTIVE;
            }
        }
        
        ArrayFree(m_TrailingStates);
        m_StateCount = 0;
        
        m_bInitialized = false;
        m_bEnabled = false;
        m_pContext = NULL;
        
        LogActivity("Trailing stop manager deinitialized");
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Configure trailing stop manager                                 |
//+------------------------------------------------------------------+
bool CTrailingStopManager::Configure(const STrailingConfig& config) {
    m_Config = config;
    
    // Validate configuration
    if (!ValidateTrailingSettings()) {
        LogError("Invalid trailing configuration provided");
        return false;
    }
    
    LogActivity("Trailing stop manager configured successfully");
    return true;
}

//+------------------------------------------------------------------+
//| Start trailing for a position                                   |
//+------------------------------------------------------------------+
bool CTrailingStopManager::StartTrailing(ulong ticket) {
    if (!m_bInitialized || !m_bEnabled) {
        LogError("Trailing stop manager not initialized or disabled");
        return false;
    }
    
    // Check if position exists
    if (!PositionSelectByTicket(ticket)) {
        LogError(StringFormat("Position #%I64u not found", ticket));
        return false;
    }
    
    // Check if already tracking this position
    int index = FindStateIndex(ticket);
    if (index >= 0) {
        // Update existing state
        m_TrailingStates[index].Status = TRAILING_ACTIVE;
        LogActivity(StringFormat("Resumed trailing for position #%I64u", ticket));
        return true;
    }
    
    // Create new trailing state
    STrailingState state;
    ZeroMemory(state);
    
    state.PositionTicket = ticket;
    state.Symbol = PositionGetString(POSITION_SYMBOL);
    state.PositionType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    state.Status = TRAILING_ACTIVE;
    
    state.OpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);
    state.CurrentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
    state.CurrentStopLoss = PositionGetDouble(POSITION_SL);
    state.CurrentTakeProfit = PositionGetDouble(POSITION_TP);
    state.Volume = PositionGetDouble(POSITION_VOLUME);
    
    state.LastTrailingPrice = state.CurrentPrice;
    state.BestPrice = state.CurrentPrice;
    state.TrailingLevel = state.CurrentStopLoss;
    
    state.StartTime = TimeCurrent();
    state.LastUpdateTime = state.StartTime;
    state.TriggerTime = 0;
    
    state.IsTriggered = (m_Config.Trigger == TRIGGER_IMMEDIATE);
    state.IsBreakevenSet = false;
    state.IsPartialClosed = false;
    
    state.UpdateCount = 0;
    state.TotalProfit = PositionGetDouble(POSITION_PROFIT);
    state.MaxProfit = state.TotalProfit;
    state.MaxDrawdown = 0.0;
    
    // Add to tracking array
    if (!AddTrailingState(state)) {
        LogError(StringFormat("Failed to add trailing state for position #%I64u", ticket));
        return false;
    }
    
    m_Statistics.TotalPositions++;
    m_Statistics.ActiveTrailings++;
    
    LogActivity(StringFormat("Started trailing for position #%I64u (%s)", ticket, state.Symbol));
    return true;
}

//+------------------------------------------------------------------+
//| Update all trailing stops                                       |
//+------------------------------------------------------------------+
bool CTrailingStopManager::UpdateAllTrailings() {
    if (!m_bInitialized || !m_bEnabled) {
        return false;
    }
    
    int updatedCount = 0;
    datetime currentTime = TimeCurrent();
    
    for (int i = m_StateCount - 1; i >= 0; i--) {
        STrailingState& state = m_TrailingStates[i];
        
        if (state.Status != TRAILING_ACTIVE) {
            continue;
        }
        
        // Check if position still exists
        if (!PositionSelectByTicket(state.PositionTicket)) {
            // Position closed, remove from tracking
            state.Status = TRAILING_COMPLETED;
            m_Statistics.ActiveTrailings--;
            m_Statistics.CompletedTrailings++;
            continue;
        }
        
        // Update current market data
        state.CurrentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
        state.CurrentStopLoss = PositionGetDouble(POSITION_SL);
        state.TotalProfit = PositionGetDouble(POSITION_PROFIT);
        
        // Update best price and drawdown
        if (state.PositionType == POSITION_TYPE_BUY) {
            if (state.CurrentPrice > state.BestPrice) {
                state.BestPrice = state.CurrentPrice;
            }
        } else {
            if (state.CurrentPrice < state.BestPrice) {
                state.BestPrice = state.CurrentPrice;
            }
        }
        
        if (state.TotalProfit > state.MaxProfit) {
            state.MaxProfit = state.TotalProfit;
        }
        
        double currentDrawdown = state.MaxProfit - state.TotalProfit;
        if (currentDrawdown > state.MaxDrawdown) {
            state.MaxDrawdown = currentDrawdown;
        }
        
        // Check emergency conditions
        if (CheckEmergencyConditions(state)) {
            continue;
        }
        
        // Check trigger condition
        if (!state.IsTriggered && CheckTriggerCondition(state)) {
            state.IsTriggered = true;
            state.TriggerTime = currentTime;
            m_Statistics.TriggeredTrailings++;
            
            STrailingAlert alert;
            alert.PositionTicket = state.PositionTicket;
            alert.Symbol = state.Symbol;
            alert.Status = TRAILING_TRIGGERED;
            alert.Message = "Trailing stop triggered";
            alert.Timestamp = currentTime;
            alert.Price = state.CurrentPrice;
            alert.StopLoss = state.CurrentStopLoss;
            alert.IsUrgent = false;
            SendAlert(alert);
        }
        
        // Update trailing stop if triggered
        if (state.IsTriggered) {
            if (UpdateTrailingStop(state)) {
                updatedCount++;
            }
        }
        
        // Check breakeven condition
        if (!state.IsBreakevenSet && m_Config.BreakevenType != BREAKEVEN_NEVER) {
            SetBreakeven(state);
        }
        
        // Check partial close condition
        if (!state.IsPartialClosed && m_Config.EnablePartialClose) {
            ExecutePartialClose(state);
        }
        
        state.LastUpdateTime = currentTime;
        state.UpdateCount++;
    }
    
    m_LastUpdate = currentTime;
    m_Statistics.LastTrailing = currentTime;
    
    if (updatedCount > 0) {
        LogActivity(StringFormat("Updated %d trailing stops", updatedCount));
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Update trailing stop for a specific position                    |
//+------------------------------------------------------------------+
bool CTrailingStopManager::UpdateTrailingStop(STrailingState& state) {
    double newTrailingLevel = 0.0;
    
    // Calculate new trailing level
    if (!CalculateTrailingLevel(state, newTrailingLevel)) {
        return false;
    }
    
    // Validate new level
    if (!ValidateTrailingLevel(state, newTrailingLevel)) {
        return false;
    }
    
    // Check if we need to update
    bool shouldUpdate = false;
    
    if (state.PositionType == POSITION_TYPE_BUY) {
        // For buy positions, only move stop loss up
        if (newTrailingLevel > state.CurrentStopLoss) {
            shouldUpdate = true;
        }
    } else {
        // For sell positions, only move stop loss down
        if (newTrailingLevel < state.CurrentStopLoss || state.CurrentStopLoss == 0.0) {
            shouldUpdate = true;
        }
    }
    
    if (!shouldUpdate) {
        return false;
    }
    
    // Execute the modification
    if (ModifyStopLoss(state.PositionTicket, newTrailingLevel)) {
        state.TrailingLevel = newTrailingLevel;
        state.CurrentStopLoss = newTrailingLevel;
        state.LastTrailingPrice = state.CurrentPrice;
        
        LogActivity(StringFormat("Updated trailing stop for #%I64u: %.5f", 
                                state.PositionTicket, newTrailingLevel));
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Calculate trailing level based on configuration                 |
//+------------------------------------------------------------------+
bool CTrailingStopManager::CalculateTrailingLevel(STrailingState& state, double& newLevel) {
    switch (m_Config.Type) {
        case TRAILING_FIXED:
            newLevel = CalculateFixedTrailing(state);
            break;
        case TRAILING_PERCENTAGE:
            newLevel = CalculatePercentageTrailing(state);
            break;
        case TRAILING_ATR:
            newLevel = CalculateATRTrailing(state);
            break;
        case TRAILING_PARABOLIC_SAR:
            newLevel = CalculateParabolicSARTrailing(state);
            break;
        case TRAILING_MOVING_AVERAGE:
            newLevel = CalculateMATrailing(state);
            break;
        case TRAILING_SUPPORT_RESISTANCE:
            newLevel = CalculateSupportResistanceTrailing(state);
            break;
        case TRAILING_VOLATILITY:
            newLevel = CalculateVolatilityTrailing(state);
            break;
        case TRAILING_ADAPTIVE:
            newLevel = CalculateAdaptiveTrailing(state);
            break;
        default:
            newLevel = CalculateFixedTrailing(state);
            break;
    }
    
    return (newLevel > 0.0);
}

//+------------------------------------------------------------------+
//| Calculate fixed distance trailing                               |
//+------------------------------------------------------------------+
double CTrailingStopManager::CalculateFixedTrailing(const STrailingState& state) {
    double point = SymbolInfoDouble(state.Symbol, SYMBOL_POINT);
    double distance = m_Config.TrailingDistance * point;
    
    if (state.PositionType == POSITION_TYPE_BUY) {
        return state.CurrentPrice - distance;
    } else {
        return state.CurrentPrice + distance;
    }
}

//+------------------------------------------------------------------+
//| Calculate percentage-based trailing                             |
//+------------------------------------------------------------------+
double CTrailingStopManager::CalculatePercentageTrailing(const STrailingState& state) {
    double percentage = m_Config.TrailingDistance / 100.0;
    
    if (state.PositionType == POSITION_TYPE_BUY) {
        return state.CurrentPrice * (1.0 - percentage);
    } else {
        return state.CurrentPrice * (1.0 + percentage);
    }
}

//+------------------------------------------------------------------+
//| Calculate ATR-based trailing                                    |
//+------------------------------------------------------------------+
double CTrailingStopManager::CalculateATRTrailing(const STrailingState& state) {
    int atrHandle = iATR(state.Symbol, PERIOD_CURRENT, m_Config.ATRPeriod);
    if (atrHandle == INVALID_HANDLE) {
        return CalculateFixedTrailing(state);  // Fallback to fixed
    }
    
    double atrValues[1];
    if (CopyBuffer(atrHandle, 0, 0, 1, atrValues) <= 0) {
        IndicatorRelease(atrHandle);
        return CalculateFixedTrailing(state);
    }
    
    double atrDistance = atrValues[0] * m_Config.ATRMultiplier;
    
    IndicatorRelease(atrHandle);
    
    if (state.PositionType == POSITION_TYPE_BUY) {
        return state.CurrentPrice - atrDistance;
    } else {
        return state.CurrentPrice + atrDistance;
    }
}

//+------------------------------------------------------------------+
//| Calculate Parabolic SAR trailing                                |
//+------------------------------------------------------------------+
double CTrailingStopManager::CalculateParabolicSARTrailing(const STrailingState& state) {
    int sarHandle = iSAR(state.Symbol, PERIOD_CURRENT, m_Config.SARStep, m_Config.SARMaximum);
    if (sarHandle == INVALID_HANDLE) {
        return CalculateFixedTrailing(state);
    }
    
    double sarValues[1];
    if (CopyBuffer(sarHandle, 0, 0, 1, sarValues) <= 0) {
        IndicatorRelease(sarHandle);
        return CalculateFixedTrailing(state);
    }
    
    double sarLevel = sarValues[0];
    IndicatorRelease(sarHandle);
    
    return sarLevel;
}

//+------------------------------------------------------------------+
//| Calculate moving average trailing                               |
//+------------------------------------------------------------------+
double CTrailingStopManager::CalculateMATrailing(const STrailingState& state) {
    int maHandle = iMA(state.Symbol, PERIOD_CURRENT, m_Config.MAPeriod, 
                      0, m_Config.MAMethod, m_Config.MAPrice);
    if (maHandle == INVALID_HANDLE) {
        return CalculateFixedTrailing(state);
    }
    
    double maValues[1];
    if (CopyBuffer(maHandle, 0, 0, 1, maValues) <= 0) {
        IndicatorRelease(maHandle);
        return CalculateFixedTrailing(state);
    }
    
    double maLevel = maValues[0];
    IndicatorRelease(maHandle);
    
    return maLevel;
}

//+------------------------------------------------------------------+
//| Validate trailing level                                         |
//+------------------------------------------------------------------+
bool CTrailingStopManager::ValidateTrailingLevel(const STrailingState& state, double level) {
    if (level <= 0.0) {
        return false;
    }
    
    double point = SymbolInfoDouble(state.Symbol, SYMBOL_POINT);
    double minDistance = m_Config.MinTrailingDistance * point;
    double maxDistance = m_Config.MaxTrailingDistance * point;
    
    double distance = 0.0;
    if (state.PositionType == POSITION_TYPE_BUY) {
        distance = state.CurrentPrice - level;
    } else {
        distance = level - state.CurrentPrice;
    }
    
    if (distance < minDistance || distance > maxDistance) {
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Modify stop loss for position                                   |
//+------------------------------------------------------------------+
bool CTrailingStopManager::ModifyStopLoss(ulong ticket, double newStopLoss) {
    if (!PositionSelectByTicket(ticket)) {
        return false;
    }
    
    string symbol = PositionGetString(POSITION_SYMBOL);
    double currentTP = PositionGetDouble(POSITION_TP);
    
    MqlTradeRequest request;
    MqlTradeResult result;
    
    ZeroMemory(request);
    ZeroMemory(result);
    
    request.action = TRADE_ACTION_SLTP;
    request.position = ticket;
    request.symbol = symbol;
    request.sl = newStopLoss;
    request.tp = currentTP;
    
    if (!OrderSend(request, result)) {
        LogError(StringFormat("Failed to modify stop loss for #%I64u: %s", 
                            ticket, result.comment));
        return false;
    }
    
    return (result.retcode == TRADE_RETCODE_DONE);
}

//+------------------------------------------------------------------+
//| Check trigger condition                                         |
//+------------------------------------------------------------------+
bool CTrailingStopManager::CheckTriggerCondition(STrailingState& state) {
    switch (m_Config.Trigger) {
        case TRIGGER_IMMEDIATE:
            return true;
            
        case TRIGGER_AFTER_PROFIT: {
            double point = SymbolInfoDouble(state.Symbol, SYMBOL_POINT);
            double profitDistance = 0.0;
            
            if (state.PositionType == POSITION_TYPE_BUY) {
                profitDistance = (state.CurrentPrice - state.OpenPrice) / point;
            } else {
                profitDistance = (state.OpenPrice - state.CurrentPrice) / point;
            }
            
            return (profitDistance >= m_Config.TriggerProfit);
        }
        
        case TRIGGER_AFTER_DISTANCE: {
            double point = SymbolInfoDouble(state.Symbol, SYMBOL_POINT);
            double moveDistance = 0.0;
            
            if (state.PositionType == POSITION_TYPE_BUY) {
                moveDistance = (state.CurrentPrice - state.LastTrailingPrice) / point;
            } else {
                moveDistance = (state.LastTrailingPrice - state.CurrentPrice) / point;
            }
            
            return (moveDistance >= m_Config.TriggerDistance);
        }
        
        case TRIGGER_MANUAL:
            return false;  // Must be triggered manually
            
        default:
            return true;
    }
}

//+------------------------------------------------------------------+
//| Find state index by ticket                                      |
//+------------------------------------------------------------------+
int CTrailingStopManager::FindStateIndex(ulong ticket) {
    for (int i = 0; i < m_StateCount; i++) {
        if (m_TrailingStates[i].PositionTicket == ticket) {
            return i;
        }
    }
    return -1;
}

//+------------------------------------------------------------------+
//| Add trailing state                                              |
//+------------------------------------------------------------------+
bool CTrailingStopManager::AddTrailingState(const STrailingState& state) {
    if (m_StateCount >= ArraySize(m_TrailingStates)) {
        // Resize array if needed
        int newSize = ArraySize(m_TrailingStates) + 50;
        if (ArrayResize(m_TrailingStates, newSize) < 0) {
            return false;
        }
    }
    
    m_TrailingStates[m_StateCount] = state;
    m_StateCount++;
    
    return true;
}

//+------------------------------------------------------------------+
//| Validate trailing settings                                      |
//+------------------------------------------------------------------+
bool CTrailingStopManager::ValidateTrailingSettings() {
    if (m_Config.TrailingDistance <= 0.0) {
        LogError("Invalid trailing distance");
        return false;
    }
    
    if (m_Config.MinTrailingDistance >= m_Config.MaxTrailingDistance) {
        LogError("Invalid trailing distance range");
        return false;
    }
    
    if (m_Config.ATRPeriod <= 0) {
        LogError("Invalid ATR period");
        return false;
    }
    
    if (m_Config.MAPeriod <= 0) {
        LogError("Invalid MA period");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Log error message                                               |
//+------------------------------------------------------------------+
void CTrailingStopManager::LogError(const string message) {
    if (m_pContext != NULL && m_pContext.pLogger != NULL) {
        m_pContext.pLogger.LogError("TrailingStopManager: " + message);
    } else {
        Print("TrailingStopManager ERROR: ", message);
    }
}

//+------------------------------------------------------------------+
//| Log activity message                                            |
//+------------------------------------------------------------------+
void CTrailingStopManager::LogActivity(const string message) {
    if (m_pContext != NULL && m_pContext.pLogger != NULL) {
        m_pContext.pLogger.LogInfo("TrailingStopManager: " + message);
    } else {
        Print("TrailingStopManager: ", message);
    }
}

//+------------------------------------------------------------------+
//| Get trailing type name                                          |
//+------------------------------------------------------------------+
string CTrailingStopManager::GetTrailingTypeName(ENUM_TRAILING_TYPE type) {
    switch (type) {
        case TRAILING_FIXED: return "Fixed";
        case TRAILING_PERCENTAGE: return "Percentage";
        case TRAILING_ATR: return "ATR";
        case TRAILING_PARABOLIC_SAR: return "Parabolic SAR";
        case TRAILING_MOVING_AVERAGE: return "Moving Average";
        case TRAILING_SUPPORT_RESISTANCE: return "Support/Resistance";
        case TRAILING_VOLATILITY: return "Volatility";
        case TRAILING_BREAKEVEN: return "Breakeven";
        case TRAILING_STEP: return "Step";
        case TRAILING_ADAPTIVE: return "Adaptive";
        case TRAILING_CUSTOM: return "Custom";
        default: return "Unknown";
    }
}

//+------------------------------------------------------------------+
//| Get trailing status name                                        |
//+------------------------------------------------------------------+
string CTrailingStopManager::GetTrailingStatusName(ENUM_TRAILING_STATUS status) {
    switch (status) {
        case TRAILING_INACTIVE: return "Inactive";
        case TRAILING_ACTIVE: return "Active";
        case TRAILING_PAUSED: return "Paused";
        case TRAILING_TRIGGERED: return "Triggered";
        case TRAILING_COMPLETED: return "Completed";
        case TRAILING_ERROR: return "Error";
        default: return "Unknown";
    }
}

//+------------------------------------------------------------------+
//| Placeholder implementations for remaining methods               |
//+------------------------------------------------------------------+
bool CTrailingStopManager::SetBreakeven(STrailingState& state) {
    // Placeholder implementation
    return true;
}

bool CTrailingStopManager::ExecutePartialClose(STrailingState& state) {
    // Placeholder implementation
    return true;
}

bool CTrailingStopManager::CheckEmergencyConditions(STrailingState& state) {
    // Placeholder implementation
    return false;
}

double CTrailingStopManager::CalculateSupportResistanceTrailing(const STrailingState& state) {
    return CalculateFixedTrailing(state);
}

double CTrailingStopManager::CalculateVolatilityTrailing(const STrailingState& state) {
    return CalculateFixedTrailing(state);
}

double CTrailingStopManager::CalculateAdaptiveTrailing(const STrailingState& state) {
    return CalculateFixedTrailing(state);
}

void CTrailingStopManager::SendAlert(const STrailingAlert& alert) {
    // Placeholder implementation
    LogActivity(StringFormat("Alert: %s for position #%I64u", alert.Message, alert.PositionTicket));
}

//+------------------------------------------------------------------+