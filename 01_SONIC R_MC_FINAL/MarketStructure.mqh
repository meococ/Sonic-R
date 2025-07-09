//+------------------------------------------------------------------+
//|                                          MarketStructure.mqh |
//|                                     Sonic R EA - SMC Engine |
//|                                     https://www.manus-ai.com |
//+------------------------------------------------------------------+
#property copyright "Manus AI"
#property version   "1.00"
#property strict

#include "SMC_Structures.mqh"
#include "SMC_Utils.mqh"

//+------------------------------------------------------------------+
//| CMarketStructure Class                                           |
//| Responsible for analyzing market structure based on SMC.         |
//+------------------------------------------------------------------+
class CMarketStructure
{
private:
    // Configuration
    MarketStructureConfig m_config;

    // Context
    string               m_symbol;
    ENUM_TIMEFRAMES      m_timeframe;
    
    // Data
    CArrayObj*           m_swing_points; // Array of SwingPoint
    CArrayObj*           m_structure_points; // Array of MarketStructurePoint

    // State
    MARKET_STRUCTURE_STATE m_market_state;

public:
    CMarketStructure(void);
   ~CMarketStructure(void);

    bool Initialize(const MarketStructureConfig &config, string symbol, ENUM_TIMEFRAMES timeframe);
    void Update();
    
    // Getters for analysis results
    int GetStructurePointsCount() const { return m_structure_points.Total(); }
    MarketStructurePoint* GetStructurePoint(int index) const { return (MarketStructurePoint*)m_structure_points.At(index); }
    MARKET_STRUCTURE_STATE GetMarketState() const { return m_market_state; }
    
    // Clear all data
    void Clear()
    {
        m_swing_points.Clear();
        m_structure_points.Clear();
        m_market_state = MARKET_STRUCTURE_STATE::UNDEFINED;
    }

private:
    void ScanInitialStructure();
    void UpdateStructure();
    void AddSwingPoint(const MqlRates &rates[], int index, SWING_POINT_TYPE type);
    bool IsBreakOfStructure(const MqlRates &rates[], int index);
    bool IsChangeOfCharacter(const MqlRates &rates[], int index);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CMarketStructure::CMarketStructure(void)
{
    m_swing_points = new CArrayObj();
    m_structure_points = new CArrayObj();
    m_market_state = MARKET_STRUCTURE_STATE::UNDEFINED;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CMarketStructure::~CMarketStructure(void)
{
    if(CheckPointer(m_swing_points) != POINTER_INVALID) delete m_swing_points;
    if(CheckPointer(m_structure_points) != POINTER_INVALID) delete m_structure_points;
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CMarketStructure::Initialize(const MarketStructureConfig &config, string symbol, ENUM_TIMEFRAMES timeframe)
{
    m_config = config;
    m_symbol = symbol;
    m_timeframe = timeframe;

    ScanInitialStructure();
    return true;
}

//+------------------------------------------------------------------+
//| Update                                                           |
//+------------------------------------------------------------------+
void CMarketStructure::Update()
{
    // Main update loop, called on every new candle
    UpdateStructure();
}

//+------------------------------------------------------------------+
//| ScanInitialStructure                                             |
//+------------------------------------------------------------------+
void CMarketStructure::ScanInitialStructure()
{
    // Logic to scan historical data and build the initial market structure
    MqlRates rates[];
    if(CopyRates(m_symbol, m_timeframe, 0, m_config.LookbackPeriod, rates) <= 0)
    {
        printf("Failed to copy rates for initial structure scan");
        return;
    }

    for(int i = ArraySize(rates) - 1 - m_config.PivotStrength; i >= m_config.PivotStrength; i--)
    {
        if(CSMCUtils::IsSwingHigh(rates, i, m_config.PivotStrength))
        {
            AddSwingPoint(rates, i, SWING_HIGH);
        }
        else if(CSMCUtils::IsSwingLow(rates, i, m_config.PivotStrength))
        {
            AddSwingPoint(rates, i, SWING_LOW);
        }
    }
}

//+------------------------------------------------------------------+
//| UpdateStructure                                                  |
//+------------------------------------------------------------------+
void CMarketStructure::UpdateStructure()
{
    // Logic to update structure with the latest candle data
    MqlRates rates[];
    if(CopyRates(m_symbol, m_timeframe, 0, m_config.PivotStrength * 2 + 1, rates) <= 0)
    {
        return;
    }

    int check_index = m_config.PivotStrength;

    if(CSMCUtils::IsSwingHigh(rates, check_index, m_config.PivotStrength))
    {
        AddSwingPoint(rates, check_index, SWING_HIGH);
        // Check for BOS/CHOCH after adding a new swing point
    }
    else if(CSMCUtils::IsSwingLow(rates, check_index, m_config.PivotStrength))
    {
        AddSwingPoint(rates, check_index, SWING_LOW);
        // Check for BOS/CHOCH after adding a new swing point
    }
}

//+------------------------------------------------------------------+
//| AddSwingPoint                                                    |
//+------------------------------------------------------------------+
void CMarketStructure::AddSwingPoint(const MqlRates &rates[], int index, SWING_POINT_TYPE type)
{
    SwingPoint* new_sp = new SwingPoint();
    new_sp.time = rates[index].time;
    new_sp.type = type;
    new_sp.price = (type == SWING_HIGH) ? rates[index].high : rates[index].low;

    // Avoid adding duplicate points
    if(m_swing_points.Total() > 0)
    {
        SwingPoint* last_sp = (SwingPoint*)m_swing_points.At(m_swing_points.Total() - 1);
        if(last_sp.time == new_sp.time)
        {
            delete new_sp;
            return;
        }
    }

    m_swing_points.Add(new_sp);

    // After adding a new point, check for structure changes
    if(IsBreakOfStructure(new_sp))
    {
        // Create and store BOS point
        MarketStructurePoint* bos_point = new MarketStructurePoint();
        bos_point.time = new_sp.time;
        bos_point.price = new_sp.price;
        bos_point.type = MARKET_STRUCTURE_POINT_TYPE::BOS;
        bos_point.swing_type = new_sp.type;
        m_structure_points.Add(bos_point);
        
        printf("BOS Detected at %s, Price: %.5f, Type: %s", 
               TimeToString(bos_point.time),
               bos_point.price,
               EnumToString(bos_point.swing_type));
    }
    else if(IsChangeOfCharacter(new_sp))
    {
        // Create and store CHOCH point
        MarketStructurePoint* choch_point = new MarketStructurePoint();
        choch_point.time = new_sp.time;
        choch_point.price = new_sp.price;
        choch_point.type = MARKET_STRUCTURE_POINT_TYPE::CHOCH;
        choch_point.swing_type = new_sp.type;
        m_structure_points.Add(choch_point);
        
        printf("CHOCH Detected at %s, Price: %.5f, Type: %s", 
               TimeToString(choch_point.time),
               choch_point.price,
               EnumToString(choch_point.swing_type));
    }
}

//+------------------------------------------------------------------+
//| IsBreakOfStructure                                               |
//+------------------------------------------------------------------+
bool CMarketStructure::IsBreakOfStructure(SwingPoint* new_sp)
{
    if(m_swing_points.Total() < 3) return false;

    // Find the last swing point of the same type before the new one
    SwingPoint *last_same_type_sp = NULL;
    for(int i = m_swing_points.Total() - 2; i >= 0; i--)
    {
        SwingPoint* sp = (SwingPoint*)m_swing_points.At(i);
        if(sp.type == new_sp.type)
        {
            last_same_type_sp = sp;
            break;
        }
    }

    if(last_same_type_sp == NULL) return false;

    // Bullish BOS: New swing high is higher than the previous swing high.
    if(m_market_state == BULLISH && new_sp.type == SWING_HIGH && new_sp.price > last_same_type_sp.price)
    {
        m_market_state = BULLISH; // Confirm trend
        return true;
    }
    
    // Bearish BOS: New swing low is lower than the previous swing low.
    if(m_market_state == BEARISH && new_sp.type == SWING_LOW && new_sp.price < last_same_type_sp.price)
    {
        m_market_state = BEARISH; // Confirm trend
        return true;
    }

    return false;
}

//+------------------------------------------------------------------+
//| IsChangeOfCharacter                                              |
//+------------------------------------------------------------------+
bool CMarketStructure::IsChangeOfCharacter(SwingPoint* new_sp)
{
    if(m_swing_points.Total() < 2) return false;

    // Find the last significant swing point of the opposite type
    SwingPoint* last_opposite_sp = NULL;
     for(int i = m_swing_points.Total() - 2; i >= 0; i--)
    {
        SwingPoint* sp = (SwingPoint*)m_swing_points.At(i);
        if(sp.type != new_sp.type)
        {
            last_opposite_sp = sp;
            break;
        }
    }

    if(last_opposite_sp == NULL) return false;

    // CHOCH from Bullish to Bearish: A swing low takes out the prior swing low.
    if(m_market_state == BULLISH && new_sp.type == SWING_LOW && new_sp.price < last_opposite_sp.price)
    {
        m_market_state = BEARISH;
        return true;
    }

    // CHOCH from Bearish to Bullish: A swing high takes out the prior swing high.
    if(m_market_state == BEARISH && new_sp.type == SWING_HIGH && new_sp.price > last_opposite_sp.price)
    {
        m_market_state = BULLISH;
        return true;
    }
    
    // Initial state detection
    if(m_market_state == UNDEFINED && m_swing_points.Total() >= 2)
    {
        SwingPoint* second_last_sp = (SwingPoint*)m_swing_points.At(m_swing_points.Total() - 2);
        if(new_sp.type == SWING_HIGH && second_last_sp.type == SWING_LOW)
        {
            if(new_sp.price > second_last_sp.price) m_market_state = BULLISH; // Higher High
        }
        else if(new_sp.type == SWING_LOW && second_last_sp.type == SWING_HIGH)
        {
            if(new_sp.price < second_last_sp.price) m_market_state = BEARISH; // Lower Low
        }
    }

    return false;
}