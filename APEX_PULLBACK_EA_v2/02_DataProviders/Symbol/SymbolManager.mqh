//+------------------------------------------------------------------+
//|                                               SymbolManager.mqh |
//|                SymbolManager.mqh - APEX Pullback EA v5 FINAL    |
//|      Description: Comprehensive symbol management with          |
//|                   trading specifications, market sessions,      |
//|                   and symbol-specific configurations.           |
//+------------------------------------------------------------------+

#ifndef SYMBOL_MANAGER_MQH_
#define SYMBOL_MANAGER_MQH_

#include "..\..\00_Core\CommonStructs.mqh"

//+------------------------------------------------------------------+
//| Symbol Trading Specifications                                   |
//+------------------------------------------------------------------+
struct SSymbolSpecs {
    string                Symbol;               // Symbol name
    int                   Digits;               // Number of digits
    double                Point;                // Point value
    double                TickSize;             // Tick size
    double                TickValue;            // Tick value in account currency
    double                ContractSize;         // Contract size
    double                MinLot;               // Minimum lot size
    double                MaxLot;               // Maximum lot size
    double                LotStep;              // Lot step
    double                MarginRequired;       // Margin required per lot
    int                   StopLevel;            // Stop level in points
    int                   FreezeLevel;          // Freeze level in points
    ENUM_SYMBOL_CALC_MODE CalcMode;             // Calculation mode
    ENUM_SYMBOL_TRADE_MODE TradeMode;           // Trade mode
    ENUM_SYMBOL_TRADE_EXECUTION TradeExecution; // Trade execution mode
    bool                  IsValid;              // Specifications validity
};

//+------------------------------------------------------------------+
//| Symbol Market Information                                        |
//+------------------------------------------------------------------+
struct SSymbolMarketInfo {
    double                Bid;                  // Current bid price
    double                Ask;                 // Current ask price
    double                Last;                // Last trade price
    double                Spread;              // Current spread in points
    long                  Volume;              // Current volume
    long                  VolumeHigh;          // Highest volume of the day
    long                  VolumeLow;           // Lowest volume of the day
    datetime              Time;                // Last quote time
    ENUM_SYMBOL_TRADE_MODE TradeMode;          // Current trade mode
    bool                  IsTradeAllowed;      // Trading allowed flag
    bool                  IsQuoteSession;      // Quote session active
    bool                  IsTradeSession;      // Trade session active
};

//+------------------------------------------------------------------+
//| Symbol Session Information                                       |
//+------------------------------------------------------------------+
struct SSymbolSession {
    ENUM_DAY_OF_WEEK      DayOfWeek;           // Day of week
    datetime              SessionBegin;        // Session begin time
    datetime              SessionEnd;          // Session end time
    bool                  IsActive;            // Session active flag
    string                SessionName;         // Session name
};

//+------------------------------------------------------------------+
//| Symbol Statistics                                                |
//+------------------------------------------------------------------+
struct SSymbolStatistics {
    double                DailyHigh;           // Daily high
    double                DailyLow;            // Daily low
    double                DailyRange;          // Daily range
    double                WeeklyHigh;          // Weekly high
    double                WeeklyLow;           // Weekly low
    double                MonthlyHigh;         // Monthly high
    double                MonthlyLow;          // Monthly low
    double                AverageSpread;       // Average spread
    double                MinSpread;           // Minimum spread
    double                MaxSpread;           // Maximum spread
    long                  AverageVolume;       // Average volume
    double                Volatility;          // Price volatility
    datetime              LastUpdate;          // Last statistics update
};

//+------------------------------------------------------------------+
//| Symbol Configuration                                             |
//+------------------------------------------------------------------+
struct SSymbolConfig {
    double                MaxSpreadAllowed;     // Maximum allowed spread
    double                MinVolumeRequired;    // Minimum volume required
    bool                  AllowTrading;         // Allow trading flag
    bool                  AllowLongPositions;   // Allow long positions
    bool                  AllowShortPositions;  // Allow short positions
    double                MaxPositionSize;      // Maximum position size
    double                RiskPerTrade;         // Risk per trade percentage
    int                   MaxPositions;         // Maximum concurrent positions
    bool                  UseNewsFilter;        // Use news filter
    bool                  UseSessionFilter;     // Use session filter
};

//+------------------------------------------------------------------+
//| CSymbolManager - Comprehensive Symbol Management                |
//+------------------------------------------------------------------+
class CSymbolManager {
private:
    EAContext*            m_pContext;           // Reference to EA context
    bool                  m_bInitialized;      // Initialization status
    string                m_CurrentSymbol;      // Current symbol
    
    // Symbol information
    SSymbolSpecs          m_Specs;              // Symbol specifications
    SSymbolMarketInfo     m_MarketInfo;         // Market information
    SSymbolStatistics     m_Statistics;         // Symbol statistics
    SSymbolConfig         m_Config;             // Symbol configuration
    
    // Session management
    SSymbolSession        m_Sessions[];         // Trading sessions
    int                   m_SessionCount;       // Number of sessions
    
    // Update intervals
    datetime              m_LastMarketUpdate;   // Last market info update
    datetime              m_LastStatsUpdate;    // Last statistics update
    
    // Monitoring settings
    static const int      MARKET_UPDATE_INTERVAL;
    static const int      STATS_UPDATE_INTERVAL;
    static const double   MAX_SPREAD_MULTIPLIER;
    
public:
    //--- Constructor/Destructor ---
    CSymbolManager();
    ~CSymbolManager();
    
    //--- Core Methods ---
    bool                  Initialize(EAContext* context, const string& symbol = "");
    void                  Deinitialize();
    bool                  IsInitialized() const { return m_bInitialized; }
    void                  Update();
    
    //--- Symbol Information ---
    string                GetSymbol() const { return m_CurrentSymbol; }
    bool                  SetSymbol(const string& symbol);
    SSymbolSpecs          GetSpecs() const { return m_Specs; }
    SSymbolMarketInfo     GetMarketInfo() const { return m_MarketInfo; }
    SSymbolStatistics     GetStatistics() const { return m_Statistics; }
    
    //--- Trading Specifications ---
    int                   GetDigits();
    double                GetPoint();
    double                GetTickSize();
    double                GetTickValue();
    double                GetContractSize();
    double                GetMinLot();
    double                GetMaxLot();
    double                GetLotStep();
    double                GetMarginRequired();
    int                   GetStopLevel();
    int                   GetFreezeLevel();
    
    //--- Market Information ---
    double                GetBid();
    double                GetAsk();
    double                GetLast();
    double                GetSpread();
    long                  GetVolume();
    datetime              GetQuoteTime();
    
    //--- Trading Conditions ---
    bool                  IsTradeAllowed();
    bool                  IsLongAllowed();
    bool                  IsShortAllowed();
    bool                  IsSpreadAcceptable();
    bool                  IsVolumeAcceptable();
    bool                  CanOpenPosition(const ENUM_ORDER_TYPE order_type, const double lot_size);
    
    //--- Position Sizing ---
    double                NormalizeLotSize(const double lot_size);
    double                CalculateMaxLotSize(const double risk_amount);
    double                CalculatePositionSize(const double risk_percent, const double stop_loss_points);
    bool                  ValidateLotSize(const double lot_size);
    
    //--- Session Management ---
    bool                  LoadTradingSessions();
    bool                  IsInTradingSession();
    bool                  IsInQuoteSession();
    SSymbolSession        GetCurrentSession();
    string                GetSessionName();
    datetime              GetNextSessionStart();
    datetime              GetSessionEnd();
    
    //--- Statistics ---
    void                  UpdateStatistics();
    double                GetDailyRange();
    double                GetAverageSpread();
    double                GetVolatility(const int periods = 20);
    bool                  IsHighVolatilityPeriod();
    
    //--- Configuration ---
    bool                  LoadConfiguration();

}; // END CLASS CSymbolManager

    bool                  SaveConfiguration();
    void                  SetMaxSpread(const double max_spread);
    void                  SetMinVolume(const long min_volume);
    void                  SetRiskPerTrade(const double risk_percent);
    SSymbolConfig         GetConfiguration() const { return m_Config; }
    
    //--- Utility Methods ---
    double                PointsToPrice(const double points);
    double                PriceToPoints(const double price_diff);
    string                FormatPrice(const double price);
    bool                  IsValidPrice(const double price);
    double                RoundToTickSize(const double price);
    
    //--- Information Methods ---
    string                GetSymbolSummary();
    string                GetMarketSummary();
    string                GetTradingSummary();
    
private:
    //--- Internal Methods ---
    bool                  LoadSymbolSpecs();
    void                  UpdateMarketInfo();
    bool                  ValidateSymbol(const string& symbol);
    void                  CalculateStatistics();
    void                  DetectTradingSessions();
    bool                  IsSessionActive(const SSymbolSession& session);
    void                  LogSymbolEvent(const string& event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO);
    void                  InitializeDefaultConfig();
    double                CalculateAverageSpread();
    double                CalculateVolatility();
};

// Static constants definition
const int CSymbolManager::MARKET_UPDATE_INTERVAL = 1;     // 1 second
const int CSymbolManager::STATS_UPDATE_INTERVAL = 60;    // 1 minute
const double CSymbolManager::MAX_SPREAD_MULTIPLIER = 3.0; // 3x normal spread

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSymbolManager::CSymbolManager(EAContext* context) {
    m_pContext = context;
    m_bInitialized = false;
    m_CurrentSymbol = "";
    m_SessionCount = 0;
    m_LastMarketUpdate = 0;
    m_LastStatsUpdate = 0;
    
    // Initialize structures
    ZeroMemory(m_Specs);
    ZeroMemory(m_MarketInfo);
    ZeroMemory(m_Statistics);
    ZeroMemory(m_Config);
    
    // Resize sessions array
    ArrayResize(m_Sessions, 10); // Support up to 10 sessions
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSymbolManager::~CSymbolManager() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CSymbolManager::Initialize(const string& symbol = "") {
    if (m_bInitialized) {
        return true;
    }
    
    if (m_pContext == NULL) {
        Print("[SYMBOL_MANAGER] Context is NULL");
        return false;
    }
    
    // Set symbol
    m_CurrentSymbol = (symbol == "") ? _Symbol : symbol;
    
    // Validate symbol
    if (!ValidateSymbol(m_CurrentSymbol)) {
        if (m_pContext->pLogger != NULL) {
            m_pContext->pLogger->LogError("Invalid symbol: " + m_CurrentSymbol, __FUNCTION__);
        }
        return false;
    }
    
    // Load symbol specifications
    if (!LoadSymbolSpecs()) {
        if (m_pContext->pLogger != NULL) {
            m_pContext->pLogger->LogError("Failed to load symbol specifications", __FUNCTION__);
        }
        return false;
    }
    
    // Load trading sessions
    if (!LoadTradingSessions()) {
        if (m_pContext->pLogger != NULL) {
            m_pContext->pLogger->LogWarning("Failed to load trading sessions", __FUNCTION__);
        }
    }
    
    // Initialize configuration
    InitializeDefaultConfig();
    LoadConfiguration();
    
    // Update market information
    UpdateMarketInfo();
    UpdateStatistics();
    
    m_bInitialized = true;
    
    if (m_pContext->pLogger != NULL) {
            m_pContext->pLogger->LogInfo("SymbolManager initialized for: " + m_CurrentSymbol, __FUNCTION__);
            m_pContext->pLogger->LogInfo(GetSymbolSummary(), __FUNCTION__);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CSymbolManager::Deinitialize() {
    if (!m_bInitialized) {
        return;
    }
    
    // Save configuration
    SaveConfiguration();
    
    if (m_pContext != NULL && m_pContext->pLogger != NULL) {
            m_pContext->pLogger->LogInfo(GetTradingSummary(), __FUNCTION__);
            m_pContext->pLogger->LogInfo("SymbolManager shutting down", __FUNCTION__);
    }
    
    m_bInitialized = false;
}

//+------------------------------------------------------------------+
//| Update                                                           |
//+------------------------------------------------------------------+
void CSymbolManager::Update() {
    if (!m_bInitialized) {
        return;
    }
    
    datetime current_time = TimeCurrent();
    
    // Update market information
    if (current_time - m_LastMarketUpdate >= MARKET_UPDATE_INTERVAL) {
        UpdateMarketInfo();
        m_LastMarketUpdate = current_time;
    }
    
    // Update statistics
    if (current_time - m_LastStatsUpdate >= STATS_UPDATE_INTERVAL) {
        UpdateStatistics();
        m_LastStatsUpdate = current_time;
    }
}

//+------------------------------------------------------------------+
//| Set Symbol                                                       |
//+------------------------------------------------------------------+
bool CSymbolManager::SetSymbol(const string& symbol) {
    if (!ValidateSymbol(symbol)) {
        return false;
    }
    
    if (symbol == m_CurrentSymbol) {
        return true; // Already set
    }
    
    m_CurrentSymbol = symbol;
    
    // Reload specifications
    if (!LoadSymbolSpecs()) {
        LogSymbolEvent("Failed to reload symbol specifications for: " + symbol, LOG_LEVEL_ERROR);
        return false;
    }
    
    // Reload sessions
    LoadTradingSessions();
    
    // Update market info
    UpdateMarketInfo();
    UpdateStatistics();
    
    LogSymbolEvent("Symbol changed to: " + symbol, LOG_LEVEL_INFO);
    
    return true;
}

//+------------------------------------------------------------------+
//| Get Trading Specifications                                       |
//+------------------------------------------------------------------+
int CSymbolManager::GetDigits() {
    return m_Specs.Digits;
}

double CSymbolManager::GetPoint() {
    return m_Specs.Point;
}

double CSymbolManager::GetTickSize() {
    return m_Specs.TickSize;
}

double CSymbolManager::GetTickValue() {
    return m_Specs.TickValue;
}

double CSymbolManager::GetMinLot() {
    return m_Specs.MinLot;
}

double CSymbolManager::GetMaxLot() {
    return m_Specs.MaxLot;
}

double CSymbolManager::GetLotStep() {
    return m_Specs.LotStep;
}

int CSymbolManager::GetStopLevel() {
    return m_Specs.StopLevel;
}

int CSymbolManager::GetFreezeLevel() {
    return m_Specs.FreezeLevel;
}

//+------------------------------------------------------------------+
//| Get Market Information                                           |
//+------------------------------------------------------------------+
double CSymbolManager::GetBid() {
    return m_MarketInfo.Bid;
}

double CSymbolManager::GetAsk() {
    return m_MarketInfo.Ask;
}

double CSymbolManager::GetSpread() {
    return m_MarketInfo.Spread;
}

long CSymbolManager::GetVolume() {
    return m_MarketInfo.Volume;
}

//+------------------------------------------------------------------+
//| Trading Conditions                                               |
//+------------------------------------------------------------------+
bool CSymbolManager::IsTradeAllowed() {
    if (!m_bInitialized) {
        return false;
    }
    
    // Check symbol trade mode
    if (m_MarketInfo.TradeMode == SYMBOL_TRADE_MODE_DISABLED) {
        return false;
    }
    
    // Check if trading is allowed in configuration
    if (!m_Config.AllowTrading) {
        return false;
    }
    
    // Check trading session
    if (m_Config.UseSessionFilter && !IsInTradingSession()) {
        return false;
    }
    
    // Check spread
    if (!IsSpreadAcceptable()) {
        return false;
    }
    
    // Check volume
    if (!IsVolumeAcceptable()) {
        return false;
    }
    
    return true;
}

bool CSymbolManager::IsSpreadAcceptable() {
    if (m_Config.MaxSpreadAllowed <= 0) {
        return true; // No spread limit
    }
    
    return m_MarketInfo.Spread <= m_Config.MaxSpreadAllowed;
}

bool CSymbolManager::IsVolumeAcceptable() {
    if (m_Config.MinVolumeRequired <= 0) {
        return true; // No volume requirement
    }
    
    return m_MarketInfo.Volume >= m_Config.MinVolumeRequired;
}

bool CSymbolManager::CanOpenPosition(const ENUM_ORDER_TYPE order_type, const double lot_size) {
    if (!IsTradeAllowed()) {
        return false;
    }
    
    // Check position direction
    if (order_type == ORDER_TYPE_BUY && !m_Config.AllowLongPositions) {
        return false;
    }
    
    if (order_type == ORDER_TYPE_SELL && !m_Config.AllowShortPositions) {
        return false;
    }
    
    // Check lot size
    if (!ValidateLotSize(lot_size)) {
        return false;
    }
    
    // Check maximum position size
    if (m_Config.MaxPositionSize > 0 && lot_size > m_Config.MaxPositionSize) {
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Position Sizing                                                  |
//+------------------------------------------------------------------+
double CSymbolManager::NormalizeLotSize(const double lot_size) {
    if (!m_bInitialized) {
        return 0.0;
    }
    
    double normalized = lot_size;
    
    // Ensure within bounds
    if (normalized < m_Specs.MinLot) {
        normalized = m_Specs.MinLot;
    } else if (normalized > m_Specs.MaxLot) {
        normalized = m_Specs.MaxLot;
    }
    
    // Round to lot step
    if (m_Specs.LotStep > 0) {
        normalized = MathRound(normalized / m_Specs.LotStep) * m_Specs.LotStep;
    }
    
    return normalized;
}

double CSymbolManager::CalculatePositionSize(const double risk_percent, const double stop_loss_points) {
    if (!m_bInitialized || risk_percent <= 0 || stop_loss_points <= 0) {
        return 0.0;
    }
    
    double account_balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double risk_amount = account_balance * risk_percent / 100.0;
    
    double tick_value = GetTickValue();
    double tick_size = GetTickSize();
    
    if (tick_value <= 0 || tick_size <= 0) {
        return 0.0;
    }
    
    double stop_loss_value = stop_loss_points * tick_value / tick_size;
    double lot_size = risk_amount / stop_loss_value;
    
    return NormalizeLotSize(lot_size);
}

bool CSymbolManager::ValidateLotSize(const double lot_size) {
    if (!m_bInitialized) {
        return false;
    }
    
    if (lot_size < m_Specs.MinLot || lot_size > m_Specs.MaxLot) {
        return false;
    }
    
    // Check lot step
    if (m_Specs.LotStep > 0) {
        double remainder = fmod(lot_size, m_Specs.LotStep);
        if (remainder > 0.0001) { // Small tolerance for floating point
            return false;
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Session Management                                               |
//+------------------------------------------------------------------+
bool CSymbolManager::IsInTradingSession() {
    if (m_SessionCount == 0) {
        return true; // No session restrictions
    }
    
    for (int i = 0; i < m_SessionCount; i++) {
        if (IsSessionActive(m_Sessions[i])) {
            return true;
        }
    }
    
    return false;
}

SSymbolSession CSymbolManager::GetCurrentSession() {
    SSymbolSession empty_session;
    ZeroMemory(empty_session);
    
    if (m_SessionCount == 0) {
        return empty_session;
    }
    
    for (int i = 0; i < m_SessionCount; i++) {
        if (IsSessionActive(m_Sessions[i])) {
            return m_Sessions[i];
        }
    }
    
    return empty_session;
}

//+------------------------------------------------------------------+
//| Statistics                                                       |
//+------------------------------------------------------------------+
void CSymbolManager::UpdateStatistics() {
    if (!m_bInitialized) {
        return;
    }
    
    CalculateStatistics();
    m_Statistics.LastUpdate = TimeCurrent();
}

double CSymbolManager::GetDailyRange() {
    return m_Statistics.DailyRange;
}

double CSymbolManager::GetAverageSpread() {
    return m_Statistics.AverageSpread;
}

double CSymbolManager::GetVolatility(const int periods = 20) {
    return CalculateVolatility();
}

//+------------------------------------------------------------------+
//| Utility Methods                                                  |
//+------------------------------------------------------------------+
double CSymbolManager::PointsToPrice(const double points) {
    return points * m_Specs.Point;
}

double CSymbolManager::PriceToPoints(const double price_diff) {
    return (m_Specs.Point > 0) ? price_diff / m_Specs.Point : 0.0;
}

string CSymbolManager::FormatPrice(const double price) {
    return DoubleToString(price, m_Specs.Digits);
}

bool CSymbolManager::IsValidPrice(const double price) {
    return (price > 0 && price < DBL_MAX);
}

double CSymbolManager::RoundToTickSize(const double price) {
    if (m_Specs.TickSize <= 0) {
        return price;
    }
    
    return MathRound(price / m_Specs.TickSize) * m_Specs.TickSize;
}

//+------------------------------------------------------------------+
//| Information Methods                                              |
//+------------------------------------------------------------------+
string CSymbolManager::GetSymbolSummary() {
    return StringFormat("Symbol: %s | Digits: %d | Point: %g | Spread: %.1f | MinLot: %g | MaxLot: %g",
                        m_CurrentSymbol,
                        m_Specs.Digits,
                        m_Specs.Point,
                        m_MarketInfo.Spread,
                        m_Specs.MinLot,
                        m_Specs.MaxLot);
}

string CSymbolManager::GetMarketSummary() {
    return StringFormat("Market: Bid=%.5f | Ask=%.5f | Spread=%.1f | Volume=%d | Session=%s",
                        m_MarketInfo.Bid,
                        m_MarketInfo.Ask,
                        m_MarketInfo.Spread,
                        m_MarketInfo.Volume,
                        GetSessionName());
}

string CSymbolManager::GetTradingSummary() {
    return StringFormat("Trading: Allowed=%s | Long=%s | Short=%s | SpreadOK=%s | VolumeOK=%s",
                        IsTradeAllowed() ? "Yes" : "No",
                        m_Config.AllowLongPositions ? "Yes" : "No",
                        m_Config.AllowShortPositions ? "Yes" : "No",
                        IsSpreadAcceptable() ? "Yes" : "No",
                        IsVolumeAcceptable() ? "Yes" : "No");
}

//+------------------------------------------------------------------+
//| Internal Methods                                                 |
//+------------------------------------------------------------------+
bool CSymbolManager::LoadSymbolSpecs() {
    if (m_CurrentSymbol == "") {
        return false;
    }
    
    // Load symbol specifications
    m_Specs.Symbol = m_CurrentSymbol;
    m_Specs.Digits = (int)SymbolInfoInteger(m_CurrentSymbol, SYMBOL_DIGITS);
    m_Specs.Point = SymbolInfoDouble(m_CurrentSymbol, SYMBOL_POINT);
    m_Specs.TickSize = SymbolInfoDouble(m_CurrentSymbol, SYMBOL_TRADE_TICK_SIZE);
    m_Specs.TickValue = SymbolInfoDouble(m_CurrentSymbol, SYMBOL_TRADE_TICK_VALUE);
    m_Specs.ContractSize = SymbolInfoDouble(m_CurrentSymbol, SYMBOL_TRADE_CONTRACT_SIZE);
    m_Specs.MinLot = SymbolInfoDouble(m_CurrentSymbol, SYMBOL_VOLUME_MIN);
    m_Specs.MaxLot = SymbolInfoDouble(m_CurrentSymbol, SYMBOL_VOLUME_MAX);
    m_Specs.LotStep = SymbolInfoDouble(m_CurrentSymbol, SYMBOL_VOLUME_STEP);
    m_Specs.StopLevel = (int)SymbolInfoInteger(m_CurrentSymbol, SYMBOL_TRADE_STOPS_LEVEL);
    m_Specs.FreezeLevel = (int)SymbolInfoInteger(m_CurrentSymbol, SYMBOL_TRADE_FREEZE_LEVEL);
    m_Specs.CalcMode = (ENUM_SYMBOL_CALC_MODE)SymbolInfoInteger(m_CurrentSymbol, SYMBOL_TRADE_CALC_MODE);
    m_Specs.TradeMode = (ENUM_SYMBOL_TRADE_MODE)SymbolInfoInteger(m_CurrentSymbol, SYMBOL_TRADE_MODE);
    m_Specs.TradeExecution = (ENUM_SYMBOL_TRADE_EXECUTION)SymbolInfoInteger(m_CurrentSymbol, SYMBOL_TRADE_EXEMODE);
    
    // Validate specifications
    m_Specs.IsValid = (m_Specs.Point > 0 && m_Specs.TickSize > 0 && 
                       m_Specs.MinLot > 0 && m_Specs.MaxLot >= m_Specs.MinLot);
    
    if (!m_Specs.IsValid) {
        LogSymbolEvent("Invalid symbol specifications loaded", LOG_LEVEL_ERROR);
        return false;
    }
    
    return true;
}

void CSymbolManager::UpdateMarketInfo() {
    if (m_CurrentSymbol == "") {
        return;
    }
    
    m_MarketInfo.Bid = SymbolInfoDouble(m_CurrentSymbol, SYMBOL_BID);
    m_MarketInfo.Ask = SymbolInfoDouble(m_CurrentSymbol, SYMBOL_ASK);
    m_MarketInfo.Last = SymbolInfoDouble(m_CurrentSymbol, SYMBOL_LAST);
    m_MarketInfo.Volume = SymbolInfoInteger(m_CurrentSymbol, SYMBOL_VOLUME);
    m_MarketInfo.VolumeHigh = SymbolInfoInteger(m_CurrentSymbol, SYMBOL_VOLUMEHIGH);
    m_MarketInfo.VolumeLow = SymbolInfoInteger(m_CurrentSymbol, SYMBOL_VOLUMELOW);
    m_MarketInfo.Time = (datetime)SymbolInfoInteger(m_CurrentSymbol, SYMBOL_TIME);
    m_MarketInfo.TradeMode = (ENUM_SYMBOL_TRADE_MODE)SymbolInfoInteger(m_CurrentSymbol, SYMBOL_TRADE_MODE);
    
    // Calculate spread
    if (m_MarketInfo.Bid > 0 && m_MarketInfo.Ask > 0 && m_Specs.Point > 0) {
        m_MarketInfo.Spread = (m_MarketInfo.Ask - m_MarketInfo.Bid) / m_Specs.Point;
    }
    
    // Update trading flags
    m_MarketInfo.IsTradeAllowed = (m_MarketInfo.TradeMode != SYMBOL_TRADE_MODE_DISABLED);
    m_MarketInfo.IsQuoteSession = IsInQuoteSession();
    m_MarketInfo.IsTradeSession = IsInTradingSession();
}

bool CSymbolManager::ValidateSymbol(const string& symbol) {
    if (symbol == "") {
        return false;
    }
    
    // Try to select the symbol
    if (!SymbolSelect(symbol, true)) {
        return false;
    }
    
    // Check if symbol exists in market watch
    return SymbolInfoInteger(symbol, SYMBOL_SELECT);
}

void CSymbolManager::CalculateStatistics() {
    // Get daily high/low
    m_Statistics.DailyHigh = SymbolInfoDouble(m_CurrentSymbol, SYMBOL_LASTHIGH);
    m_Statistics.DailyLow = SymbolInfoDouble(m_CurrentSymbol, SYMBOL_LASTLOW);
    
    if (m_Statistics.DailyHigh > 0 && m_Statistics.DailyLow > 0) {
        m_Statistics.DailyRange = m_Statistics.DailyHigh - m_Statistics.DailyLow;
    }
    
    // Calculate average spread
    m_Statistics.AverageSpread = CalculateAverageSpread();
    
    // Update min/max spread
    if (m_Statistics.MinSpread == 0 || m_MarketInfo.Spread < m_Statistics.MinSpread) {
        m_Statistics.MinSpread = m_MarketInfo.Spread;
    }
    
    if (m_MarketInfo.Spread > m_Statistics.MaxSpread) {
        m_Statistics.MaxSpread = m_MarketInfo.Spread;
    }
    
    // Calculate volatility
    m_Statistics.Volatility = CalculateVolatility();
}

void CSymbolManager::InitializeDefaultConfig() {
    m_Config.MaxSpreadAllowed = 50.0;        // 50 points
    m_Config.MinVolumeRequired = 0;          // No minimum volume
    m_Config.AllowTrading = true;
    m_Config.AllowLongPositions = true;
    m_Config.AllowShortPositions = true;
    m_Config.MaxPositionSize = 10.0;         // 10 lots
    m_Config.RiskPerTrade = 2.0;             // 2% per trade
    m_Config.MaxPositions = 5;               // 5 concurrent positions
    m_Config.UseNewsFilter = false;
    m_Config.UseSessionFilter = false;
}

double CSymbolManager::CalculateAverageSpread() {
    static double spread_sum = 0;
    static int spread_count = 0;
    
    if (m_MarketInfo.Spread > 0) {
        spread_sum += m_MarketInfo.Spread;
        spread_count++;
        return spread_sum / spread_count;
    }
    
    return m_Statistics.AverageSpread;
}

double CSymbolManager::CalculateVolatility() {
    // Simple volatility calculation based on daily range
    if (m_Statistics.DailyRange > 0 && m_MarketInfo.Bid > 0) {
        return m_Statistics.DailyRange / m_MarketInfo.Bid * 100.0; // Percentage
    }
    
    return 0.0;
}

bool CSymbolManager::IsSessionActive(const SSymbolSession& session) {
    datetime current_time = TimeCurrent();
    MqlDateTime dt;
    TimeToStruct(current_time, dt);
    
    // Check day of week
    if (session.DayOfWeek != (ENUM_DAY_OF_WEEK)dt.day_of_week) {
        return false;
    }
    
    // Check time range
    datetime current_seconds = dt.hour * 3600 + dt.min * 60 + dt.sec;
    
    MqlDateTime session_begin, session_end;
    TimeToStruct(session.SessionBegin, session_begin);
    TimeToStruct(session.SessionEnd, session_end);
    
    datetime begin_seconds = session_begin.hour * 3600 + session_begin.min * 60;
    datetime end_seconds = session_end.hour * 3600 + session_end.min * 60;
    
    if (begin_seconds <= end_seconds) {
        return (current_seconds >= begin_seconds && current_seconds <= end_seconds);
    } else {
        // Session crosses midnight
        return (current_seconds >= begin_seconds || current_seconds <= end_seconds);
    }
}

void CSymbolManager::LogSymbolEvent(const string& event, const ENUM_LOG_LEVEL level = LOG_LEVEL_INFO) {
    if (m_pContext != NULL && m_pContext->pLogger != NULL) {
        switch(level) {
            case LOG_LEVEL_ERROR:
                m_pContext->pLogger->LogError(event, __FUNCTION__);
                break;
            case LOG_LEVEL_WARNING:
                m_pContext->pLogger->LogWarning(event, __FUNCTION__);
                break;
            default:
                m_pContext->pLogger->LogInfo(event, __FUNCTION__);
        }
    }
}

} // namespace ApexPullback::v5

#endif // SYMBOL_MANAGER_MQH_