//+------------------------------------------------------------------+
//|                                     UI_Dashboard_Manager.mqh |
//|                        Copyright 2024, MQL5-SOLUTIONS.IO |
//|                               https://www.mql5-solutions.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MQL5-SOLUTIONS.IO"
#property link      "https://www.mql5-solutions.io"
#property version   "1.00"

#include "UI_Dashboard_State.mqh"
#include "UI_Dashboard_Renderer.mqh"
#include "Core_Defines.mqh"
#include "Analysis_Structure.mqh"

//+------------------------------------------------------------------+
//| Dashboard Manager Class                                          |
//+------------------------------------------------------------------+
class CDashboardManager
{
private:
    DashboardState      m_state;
    CDashboardRenderer* m_renderer;
    CStructureAnalysis* m_structure_analyzer; // Assuming this class exists in Analysis_Structure.mqh

    // Private methods to gather data
    void CollectStructureData();
    void CollectTrendData();
    void CollectVolatilityData();
    void CollectKeyLevelsData();

public:
    // Constructor
    void CDashboardManager()
{
    m_renderer = new CDashboardRenderer(ChartID(), "DASH_SMC", 5, 5, 300, 200);
}

    // Destructor
    void ~CDashboardManager()
    {
        if(CheckPointer(m_renderer) == POINTER_DYNAMIC)
            delete m_renderer;
    }

    // Main update function
    void Update(const SwingPoint &major_structure[], const SwingPoint &primary_structure[], const SwingPoint &sub_structure[], const OrderBlock &order_blocks[], const FairValueGap &fvgs[]);

    // Cleanup
    void Clear();
};

//+------------------------------------------------------------------+
//| Main update function to be called on each tick/bar               |
//+------------------------------------------------------------------+
void CDashboardManager::Update(const SwingPoint &major_structure[], const SwingPoint &primary_structure[], const SwingPoint &sub_structure[], const OrderBlock &order_blocks[], const FairValueGap &fvgs[])
{
    // 1. Collect all necessary data
    CollectStructureData(major_structure, primary_structure, sub_structure);
    CollectTrendData(); // Placeholder
    CollectVolatilityData(); // Placeholder
    CollectKeyLevelsData(major_structure);

    // 2. Update the renderer with the new state
    if(CheckPointer(m_renderer) == POINTER_DYNAMIC)
        m_renderer->Update(m_state);
}

//+------------------------------------------------------------------+
//| Collect Market Structure Data                                    |
//+------------------------------------------------------------------+
void CDashboardManager::CollectStructureData(const SwingPoint &major[], const SwingPoint &primary[], const SwingPoint &sub[])
{
    // Determine bias from the last two points of each structure
    m_state.majorStructure = GetStructureState(major);
    m_state.primaryStructure = GetStructureState(primary);
    m_state.subStructure = GetStructureState(sub);
}

//+------------------------------------------------------------------+
//| Collect Trend Data                                               |
//+------------------------------------------------------------------+
void CDashboardManager::CollectTrendData()
{
    // Implementation needed: Use indicators like Moving Average
    // to determine trend and update m_state.trendDirection, etc.
}

//+------------------------------------------------------------------+
//| Collect Volatility Data                                          |
//+------------------------------------------------------------------+
void CDashboardManager::CollectVolatilityData()
{
    // Implementation needed: Use ATR indicator to determine volatility
    // and update m_state.atrValue, m_state.volatilityLevel, etc.
}

//+------------------------------------------------------------------+
//| Collect Key Levels Data                                          |
//+------------------------------------------------------------------+
void CDashboardManager::CollectKeyLevelsData(const SwingPoint &major[])
{
    SwingPoint last_high, last_low;
    GetLastSwingHighAndLow(major, last_high, last_low);
    m_state.nextMajorHigh = last_high.price;
    m_state.nextMajorLow = last_low.price;
}

//+------------------------------------------------------------------+
//| Helper to determine structure state (Bullish/Bearish)            |
//+------------------------------------------------------------------+
ENUM_MARKET_STATE GetStructureState(const SwingPoint &points[])
{
    int size = ArraySize(points);
    if(size < 4) return UNCERTAIN; // Need at least 4 points to compare two highs and two lows

    SwingPoint p1 = points[size-1]; // Last point
    SwingPoint p2 = points[size-2]; // Previous point
    SwingPoint p3 = points[size-3]; // Point before previous
    SwingPoint p4 = points[size-4]; // Point before that

    // Looking for HH and HL for Bullish trend
    if(p1.type == SWING_HIGH && p2.type == SWING_LOW && p3.type == SWING_HIGH && p4.type == SWING_LOW)
    {
        if(p1.price > p3.price && p2.price > p4.price) return BULLISH;
    }

    // Looking for LL and LH for Bearish trend
    if(p1.type == SWING_LOW && p2.type == SWING_HIGH && p3.type == SWING_LOW && p4.type == SWING_HIGH)
    {
        if(p1.price < p3.price && p2.price < p4.price) return BEARISH;
    }

    return SIDEWAYS; // Otherwise, it's ranging or in a complex pullback
}

//+------------------------------------------------------------------+
//| Helper to get the last swing high and low                        |
//+------------------------------------------------------------------+
void GetLastSwingHighAndLow(const SwingPoint &points[], SwingPoint &last_high, SwingPoint &last_low)
{
    for(int i = ArraySize(points) - 1; i >= 0; i--)
    {
        if(points[i].type == SWING_HIGH && last_high.time == 0) last_high = points[i];
        if(points[i].type == SWING_LOW && last_low.time == 0) last_low = points[i];
        if(last_high.time != 0 && last_low.time != 0) break;
    }
}

//+------------------------------------------------------------------+
//| Clear all dashboard objects                                      |
//+------------------------------------------------------------------+
void CDashboardManager::Clear()
{
    if(CheckPointer(m_renderer) == POINTER_DYNAMIC)
        m_renderer.Clear();
}
//+------------------------------------------------------------------+