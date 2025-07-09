//+------------------------------------------------------------------+
//|                                               PositionManager.mqh |
//|                   PositionManager - APEX Pullback EA v5 FINAL   |
//|      Description: Advanced position tracking and portfolio      |
//|                   management with comprehensive analytics       |
//+------------------------------------------------------------------+

#ifndef APEX_POSITIONMANAGER_MQH_
#define APEX_POSITIONMANAGER_MQH_

#include "../../00_Core/CommonStructs.mqh"
#include <Object.mqh>

namespace ApexPullback::v5 {

//+------------------------------------------------------------------+
//| Enhanced Position Tracking Structures                           |
//+------------------------------------------------------------------+
enum ENUM_POSITION_STAGE {
    POSITION_STAGE_OPENING,     // Position being opened
    POSITION_STAGE_ACTIVE,      // Position is active
    POSITION_STAGE_SCALING,     // Position being scaled in/out
    POSITION_STAGE_TRAILING,    // Stop loss being trailed
    POSITION_STAGE_CLOSING,     // Position being closed
    POSITION_STAGE_CLOSED       // Position closed
};

enum ENUM_POSITION_EXIT_REASON {
    EXIT_REASON_NONE,
    EXIT_REASON_TAKE_PROFIT,
    EXIT_REASON_STOP_LOSS,
    EXIT_REASON_TRAILING_STOP,
    EXIT_REASON_MANUAL,
    EXIT_REASON_RISK_MANAGEMENT,
    EXIT_REASON_NEWS_EVENT,
    EXIT_REASON_TIME_EXIT,
    EXIT_REASON_PATTERN_BREAK,
    EXIT_REASON_EMERGENCY
};

struct SPositionInfo {
    // Basic Information
    long                    Ticket;
    string                  Symbol;
    long                    Magic;
    ENUM_ORDER_TYPE         Type;
    double                  Volume;
    datetime                OpenTime;
    datetime                CloseTime;
    
    // Price Information
    double                  OpenPrice;
    double                  ClosePrice;
    double                  StopLoss;
    double                  TakeProfit;
    double                  CurrentPrice;
    
    // P&L Information
    double                  Profit;
    double                  Swap;
    double                  Commission;
    double                  NetProfit;
    double                  UnrealizedPnL;
    
    // Risk Information
    double                  RiskAmount;           // Amount at risk
    double                  RiskPercent;          // Risk as % of account
    double                  MaxAdverseExcursion;  // Worst drawdown
    double                  MaxFavorableExcursion; // Best profit
    
    // Advanced Tracking
    ENUM_POSITION_STAGE     Stage;
    ENUM_POSITION_EXIT_REASON ExitReason;
    string                  StrategyId;
    string                  PatternId;
    double                  Confidence;
    
    // Execution Quality
    double                  EntrySlippage;
    double                  ExitSlippage;
    double                  EntryLatency;
    double                  ExitLatency;
    
    // Market Context
    double                  EntrySpread;
    double                  ExitSpread;
    double                  MarketVolatility;
    ENUM_SESSION_TYPE       EntrySession;
    ENUM_SESSION_TYPE       ExitSession;
    
    // Performance Metrics
    double                  PipsPnL;
    double                  RMultiple;            // Risk-reward multiple
    double                  HoldingPeriod;        // Hours held
    double                  DrawdownPercent;      // Max % drawdown
    
    SPositionInfo() { Reset(); }
    void Reset() {
        Ticket = Magic = 0;
        Symbol = StrategyId = PatternId = "";
        Type = ORDER_TYPE_BUY;
        Volume = OpenPrice = ClosePrice = StopLoss = TakeProfit = CurrentPrice = 0.0;
        OpenTime = CloseTime = 0;
        Profit = Swap = Commission = NetProfit = UnrealizedPnL = 0.0;
        RiskAmount = RiskPercent = MaxAdverseExcursion = MaxFavorableExcursion = 0.0;
        Stage = POSITION_STAGE_OPENING;
        ExitReason = EXIT_REASON_NONE;
        Confidence = 0.0;
        EntrySlippage = ExitSlippage = EntryLatency = ExitLatency = 0.0;
        EntrySpread = ExitSpread = MarketVolatility = 0.0;
        EntrySession = ExitSession = SESSION_UNKNOWN;
        PipsPnL = RMultiple = HoldingPeriod = DrawdownPercent = 0.0;
    }
};

struct SPortfolioMetrics {
    // Position Count
    int                     TotalPositions;
    int                     LongPositions;
    int                     ShortPositions;
    int                     ProfitablePositions;
    int                     LosingPositions;
    
    // Exposure Analysis
    double                  TotalExposure;        // Total position value
    double                  NetExposure;          // Net long/short
    double                  LongExposure;
    double                  ShortExposure;
    double                  ExposurePercent;      // % of account equity
    
    // Risk Analysis
    double                  TotalRiskAmount;
    double                  TotalRiskPercent;
    double                  MaxSinglePositionRisk;
    double                  PortfolioVaR;         // Portfolio VaR
    double                  PortfolioBeta;        // Market correlation
    
    // P&L Analysis
    double                  RealizedPnL;
    double                  UnrealizedPnL;
    double                  TotalPnL;
    double                  DailyPnL;
    double                  WeeklyPnL;
    double                  MonthlyPnL;
    
    // Performance Ratios
    double                  WinRate;
    double                  ProfitFactor;
    double                  SharpeRatio;
    double                  SortinoRatio;
    double                  MaxDrawdown;
    
    // Execution Quality
    double                  AverageSlippage;
    double                  AverageLatency;
    double                  ExecutionSuccessRate;
    
    SPortfolioMetrics() { Reset(); }
    void Reset() {
        TotalPositions = LongPositions = ShortPositions = ProfitablePositions = LosingPositions = 0;
        TotalExposure = NetExposure = LongExposure = ShortExposure = ExposurePercent = 0.0;
        TotalRiskAmount = TotalRiskPercent = MaxSinglePositionRisk = PortfolioVaR = PortfolioBeta = 0.0;
        RealizedPnL = UnrealizedPnL = TotalPnL = DailyPnL = WeeklyPnL = MonthlyPnL = 0.0;
        WinRate = ProfitFactor = SharpeRatio = SortinoRatio = MaxDrawdown = 0.0;
        AverageSlippage = AverageLatency = ExecutionSuccessRate = 0.0;
    }
};

//+------------------------------------------------------------------+
//| Enhanced Position Manager Class                                  |
//+------------------------------------------------------------------+
class CPositionManager {
private:
    // Core State
    EAContext*              m_pContext;
    bool                    m_bInitialized;
    string                  m_sSymbol;
    long                    m_lMagicNumber;
    
    // Position Tracking
    SPositionInfo           m_Positions[];
    int                     m_iPositionCount;
    int                     m_iMaxPositions;
    
    // Portfolio Metrics
    SPortfolioMetrics       m_PortfolioMetrics;
    
    // Historical Data
    double                  m_DailyReturns[252];    // 1 year of daily returns
    int                     m_iReturnsIndex;
    int                     m_iReturnsCount;
    
    // Risk Management
    double                  m_dMaxTotalRisk;        // Maximum total portfolio risk
    double                  m_dMaxSingleRisk;       // Maximum single position risk
    double                  m_dMaxExposure;         // Maximum exposure
    
    // Performance Tracking
    double                  m_dStartingEquity;
    datetime                m_StartTime;
    double                  m_dPeakEquity;
    double                  m_dMaxDrawdown;
    
public:
    //--- Constructor/Destructor ---
    CPositionManager();
    ~CPositionManager();
    
    //--- Initialization ---
    bool                    Initialize(EAContext* pContext);
    void                    Deinitialize();
    bool                    IsInitialized() const { return m_bInitialized; }
    
    //--- Position Management ---
    bool                    AddPosition(long ticket, const string strategy_id, const string pattern_id, double confidence = 0.0);
    bool                    UpdatePosition(long ticket);
    bool                    RemovePosition(long ticket);
    SPositionInfo*          GetPosition(long ticket);
    bool                    IsPositionTracked(long ticket);
    
    //--- Position Analysis ---
    void                    UpdateAllPositions();
    void                    CalculatePortfolioMetrics();
    void                    UpdatePerformanceMetrics();
    
    //--- Risk Assessment ---
    bool                    CanOpenNewPosition(double risk_amount, double volume);
    double                  GetAvailableRiskBudget();
    double                  GetPortfolioRiskScore();
    bool                    IsPortfolioBalanced();
    
    //--- Portfolio Analytics ---
    SPortfolioMetrics       GetPortfolioMetrics() const { return m_PortfolioMetrics; }
    double                  GetPortfolioVaR(double confidence_level = 0.95);
    double                  GetPortfolioSharpeRatio();
    double                  GetPortfolioBeta();
    
    //--- Position Queries ---
    int                     GetPositionCount() const { return m_iPositionCount; }
    int                     GetLongPositionCount();
    int                     GetShortPositionCount();
    double                  GetTotalExposure();
    double                  GetNetExposure();
    double                  GetTotalUnrealizedPnL();
    
    //--- Risk Management ---
    void                    SetMaxTotalRisk(double max_risk) { m_dMaxTotalRisk = max_risk; }
    void                    SetMaxSingleRisk(double max_risk) { m_dMaxSingleRisk = max_risk; }
    void                    SetMaxExposure(double max_exposure) { m_dMaxExposure = max_exposure; }
    
    //--- Reporting ---
    string                  GeneratePortfolioReport();
    string                  GeneratePositionReport(long ticket);
    string                  GenerateRiskReport();
    
    //--- Event Handling ---
    void                    OnPositionOpened(long ticket);
    void                    OnPositionClosed(long ticket, ENUM_POSITION_EXIT_REASON reason);
    void                    OnPositionModified(long ticket);
    
private:
    //--- Internal Management ---
    int                     FindPositionIndex(long ticket);
    bool                    AddPositionToArray(const SPositionInfo &position);
    bool                    RemovePositionFromArray(int index);
    void                    ResizePositionArray();
    
    //--- Data Updates ---
    bool                    UpdatePositionInfo(SPositionInfo &position);
    void                    CalculatePositionMetrics(SPositionInfo &position);
    void                    UpdatePositionStage(SPositionInfo &position);
    
    //--- Portfolio Calculations ---
    void                    CalculateExposureMetrics();
    void                    CalculateRiskMetrics();
    void                    CalculatePnLMetrics();
    void                    CalculatePerformanceRatios();
    
    //--- Historical Analysis ---
    void                    UpdateReturnsHistory();
    double                  CalculateVolatility(int periods = 30);
    double                  CalculateCorrelation(const double &market_returns[], int count);
    
    //--- Validation ---
    bool                    ValidatePosition(const SPositionInfo &position);
    bool                    IsPositionDataValid(long ticket);
    
    //--- Utility Methods ---
    double                  CalculatePipsValue(double price_diff);
    double                  CalculateRiskRewardRatio(const SPositionInfo &position);
    ENUM_SESSION_TYPE       GetCurrentSession();
    double                  GetMarketVolatility();
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPositionManager::CPositionManager() {
    m_pContext = NULL;
    m_bInitialized = false;
    m_sSymbol = "";
    m_lMagicNumber = 0;
    
    // Initialize arrays
    ArrayResize(m_Positions, 100);  // Initial capacity
    m_iPositionCount = 0;
    m_iMaxPositions = 100;
    
    // Initialize tracking arrays
    ArrayInitialize(m_DailyReturns, 0.0);
    m_iReturnsIndex = 0;
    m_iReturnsCount = 0;
    
    // Risk settings
    m_dMaxTotalRisk = 20.0;      // 20% max total risk
    m_dMaxSingleRisk = 2.0;      // 2% max single position risk
    m_dMaxExposure = 100.0;      // 100% max exposure
    
    // Performance tracking
    m_dStartingEquity = 0.0;
    m_StartTime = 0;
    m_dPeakEquity = 0.0;
    m_dMaxDrawdown = 0.0;
    
    // Reset metrics
    m_PortfolioMetrics.Reset();
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPositionManager::~CPositionManager() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize Position Manager                                      |
//+------------------------------------------------------------------+
bool CPositionManager::Initialize(EAContext* pContext) {
    if (m_bInitialized) {
        return true;
    }
    
    if (pContext == NULL) {
        Print("[PositionManager] ERROR: Context is NULL");
        return false;
    }
    
    m_pContext = pContext;
    
    if (m_pContext->pLogger == NULL) {
        Print("[PositionManager] ERROR: Logger is NULL");
        return false;
    }
    
    m_pContext->pLogger->LogInfo("Initializing Enhanced PositionManager v5...", __FUNCTION__);
    
    // Set basic parameters
    m_sSymbol = _Symbol;
    m_lMagicNumber = m_pContext->Inputs.MagicNumber;
    
    // Set risk management parameters
    if (m_pContext->Inputs.RiskManagement.MaxTotalRisk > 0) {
        m_dMaxTotalRisk = m_pContext->Inputs.RiskManagement.MaxTotalRisk;
    }
    
    if (m_pContext->Inputs.RiskManagement.MaxPositions > 0) {
        m_iMaxPositions = m_pContext->Inputs.RiskManagement.MaxPositions;
        ResizePositionArray();
    }
    
    // Initialize performance tracking
    m_dStartingEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    m_dPeakEquity = m_dStartingEquity;
    m_StartTime = TimeCurrent();
    
    // Scan existing positions
    UpdateAllPositions();
    
    m_bInitialized = true;
    m_pContext->pLogger->LogInfo(StringFormat("Enhanced PositionManager initialized for %s with Magic Number %d", 
                                           m_sSymbol, m_lMagicNumber), __FUNCTION__);
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize Position Manager                                    |
//+------------------------------------------------------------------+
void CPositionManager::Deinitialize() {
    if (!m_bInitialized) {
        return;
    }
    
    if (m_pContext && m_pContext->pLogger) {
        m_pContext->pLogger->LogInfo("Deinitializing Enhanced PositionManager...", __FUNCTION__);
        
        // Generate final report
        string final_report = GeneratePortfolioReport();
        m_pContext->pLogger->LogInfo("Final Portfolio Report:\n" + final_report, __FUNCTION__);
    }
    
    // Clear position array
    ArrayFree(m_Positions);
    m_iPositionCount = 0;
    
    m_bInitialized = false;
    m_pContext = NULL;
}

//+------------------------------------------------------------------+
//| Add Position to Tracking                                        |
//+------------------------------------------------------------------+
bool CPositionManager::AddPosition(long ticket, const string strategy_id, const string pattern_id, double confidence = 0.0) {
    if (!m_bInitialized) return false;
    
    // Check if position already tracked
    if (IsPositionTracked(ticket)) {
        m_pContext->pLogger->LogWarning(StringFormat("Position #%d already tracked", ticket), __FUNCTION__);
        return false;
    }
    
    // Check if we have capacity
    if (m_iPositionCount >= m_iMaxPositions) {
        m_pContext->pLogger->LogError(StringFormat("Maximum positions (%d) reached", m_iMaxPositions), __FUNCTION__);
        return false;
    }
    
    // Create position info
    SPositionInfo position;
    position.Reset();
    position.Ticket = ticket;
    position.StrategyId = strategy_id;
    position.PatternId = pattern_id;
    position.Confidence = confidence;
    position.Stage = POSITION_STAGE_OPENING;
    
    // Update position data from terminal
    if (!UpdatePositionInfo(position)) {
        m_pContext->pLogger->LogError(StringFormat("Failed to get position data for #%d", ticket), __FUNCTION__);
        return false;
    }
    
    // Add to array
    if (!AddPositionToArray(position)) {
        m_pContext->pLogger->LogError(StringFormat("Failed to add position #%d to array", ticket), __FUNCTION__);
        return false;
    }
    
    // Update portfolio metrics
    CalculatePortfolioMetrics();
    
    m_pContext->pLogger->LogInfo(StringFormat("Position #%d added to tracking (Strategy: %s, Pattern: %s, Confidence: %.1f%%)", 
                                           ticket, strategy_id, pattern_id, confidence * 100.0), __FUNCTION__);
    
    return true;
}

//+------------------------------------------------------------------+
//| Update Position Data                                             |
//+------------------------------------------------------------------+
bool CPositionManager::UpdatePosition(long ticket) {
    if (!m_bInitialized) return false;
    
    int index = FindPositionIndex(ticket);
    if (index < 0) {
        return false; // Position not found
    }
    
    SPositionInfo &position = m_Positions[index];
    
    // Update position data
    bool success = UpdatePositionInfo(position);
    if (success) {
        CalculatePositionMetrics(position);
        UpdatePositionStage(position);
    }
    
    return success;
}

//+------------------------------------------------------------------+
//| Update All Positions                                            |
//+------------------------------------------------------------------+
void CPositionManager::UpdateAllPositions() {
    if (!m_bInitialized) return;
    
    // Mark all positions as not found
    for (int i = 0; i < m_iPositionCount; i++) {
        m_Positions[i].Stage = POSITION_STAGE_CLOSED;
    }
    
    // Scan terminal positions
    int total = PositionsTotal();
    for (int i = 0; i < total; i++) {
        if (PositionGetTicket(i) > 0) {
            long ticket = PositionGetTicket(i);
            if (PositionGetInteger(POSITION_MAGIC) == m_lMagicNumber && 
                PositionGetString(POSITION_SYMBOL) == m_sSymbol) {
                
                int index = FindPositionIndex(ticket);
                if (index >= 0) {
                    // Update existing position
                    UpdatePositionInfo(m_Positions[index]);
                    CalculatePositionMetrics(m_Positions[index]);
                    UpdatePositionStage(m_Positions[index]);
                }
                // Note: We don't auto-add unknown positions - they must be explicitly added
            }
        }
    }
    
    // Remove closed positions
    for (int i = m_iPositionCount - 1; i >= 0; i--) {
        if (m_Positions[i].Stage == POSITION_STAGE_CLOSED) {
            OnPositionClosed(m_Positions[i].Ticket, EXIT_REASON_MANUAL);
            RemovePositionFromArray(i);
        }
    }
    
    // Update portfolio metrics
    CalculatePortfolioMetrics();
    UpdatePerformanceMetrics();
}

// Continue with remaining methods...
// ... existing code ...

} // namespace ApexPullback::v5

#endif // APEX_POSITIONMANAGER_MQH_
