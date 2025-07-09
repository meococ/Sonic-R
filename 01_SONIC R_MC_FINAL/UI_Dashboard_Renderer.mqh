//+------------------------------------------------------------------+
//|                                    UI_Dashboard_Renderer.mqh |
//|                        Copyright 2024, MQL5-SOLUTIONS.IO |
//|                               https://www.mql5-solutions.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MQL5-SOLUTIONS.IO"
#property link      "https://www.mql5-solutions.io"
#property version   "1.00"

#include "UI_Dashboard_State.mqh"
#include "Core_Defines.mqh"

//+------------------------------------------------------------------+
//| Dashboard Renderer Class                                         |
//+------------------------------------------------------------------+
class CDashboardRenderer
{
private:
    long                m_chart_id;
    string              m_obj_prefix;
    int                 m_x_pos;
    int                 m_y_pos;
    int                 m_width;
    int                 m_height;
    DashboardState      m_state;

    // Private methods for drawing specific parts
    void DrawPanel();
    void DrawStructureSection();
    void DrawTrend(const DashboardState &state);
    void DrawVolatility(const DashboardState &state);
    void DrawKeyLevelsSection();
    void DrawLabel(string name, int x, int y, string text, color clr=clrWhite, int font_size=8);


public:
    // Constructor
    CDashboardRenderer(long chart_id, string prefix, int x, int y, int w, int h)
    {
        m_chart_id = chart_id;
        m_obj_prefix = prefix;
        m_x_pos = x;
        m_y_pos = y;
        m_width = w;
        m_height = h;
    }

    // Main update function
    void Update(const DashboardState &state);

    // Cleanup
    void Clear();
};

//+------------------------------------------------------------------+
//| Update and redraw all dashboard components                       |
//+------------------------------------------------------------------+
void CDashboardRenderer::Update(const DashboardState &state)
{
    // Update the state
    m_state = state;

    // Redraw all components
    DrawPanel();
    DrawStructureSection();
    DrawTrend(state);
    DrawVolatility(state);
    DrawKeyLevelsSection();
}

//+------------------------------------------------------------------+
//| Helper to convert market state enum to string and color          |
//+------------------------------------------------------------------+
void GetStateStringAndColor(ENUM_MARKET_STATE state, string &text, color &clr)
{
    switch(state)
    {
        case BULLISH:   text = "BULLISH";   clr = clrLimeGreen; break;
        case BEARISH:   text = "BEARISH";   clr = clrIndianRed; break;
        case SIDEWAYS:  text = "SIDEWAYS";  clr = clrGoldenrod; break;
        case UNCERTAIN: text = "UNCERTAIN"; clr = clrGray;      break;
    }
}

//+------------------------------------------------------------------+
//| Draw the main panel background                                   |
//+------------------------------------------------------------------+
void CDashboardRenderer::DrawPanel()
{
    string name = m_obj_prefix + "_Panel";
    ObjectCreate(m_chart_id, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(m_chart_id, name, OBJPROP_XDISTANCE, m_x_pos);
    ObjectSetInteger(m_chart_id, name, OBJPROP_YDISTANCE, m_y_pos);
    ObjectSetInteger(m_chart_id, name, OBJPROP_XSIZE, m_width);
    ObjectSetInteger(m_chart_id, name, OBJPROP_YSIZE, m_height);
    ObjectSetInteger(m_chart_id, name, OBJPROP_BGCOLOR, clrBlack);
    ObjectSetInteger(m_chart_id, name, OBJPROP_BORDER_COLOR, clrGray);
    ObjectSetInteger(m_chart_id, name, OBJPROP_BACK, true);
}

//+------------------------------------------------------------------+
//| Draw Market Structure Section                                    |
//+------------------------------------------------------------------+
void CDashboardRenderer::DrawStructureSection()
{
    int y_offset = m_y_pos + 30;
    string label_text;
    color state_color;

    // Major Structure
    GetStateStringAndColor(m_state.majorStructure, label_text, state_color);
    DrawLabel(m_obj_prefix + "_MajorLabel", m_x_pos + 10, y_offset, "Major:");
    DrawLabel(m_obj_prefix + "_MajorValue", m_x_pos + 80, y_offset, label_text, state_color);
    y_offset += 20;

    // Primary Structure
    GetStateStringAndColor(m_state.primaryStructure, label_text, state_color);
    DrawLabel(m_obj_prefix + "_PrimaryLabel", m_x_pos + 10, y_offset, "Primary:");
    DrawLabel(m_obj_prefix + "_PrimaryValue", m_x_pos + 80, y_offset, label_text, state_color);
    y_offset += 20;

    // Sub Structure
    GetStateStringAndColor(m_state.subStructure, label_text, state_color);
    DrawLabel(m_obj_prefix + "_SubLabel", m_x_pos + 10, y_offset, "Sub:");
    DrawLabel(m_obj_prefix + "_SubValue", m_x_pos + 80, y_offset, label_text, state_color);
}

//+------------------------------------------------------------------+
//| Draw Trend section                                               |
//+------------------------------------------------------------------+
void CDashboardRenderer::DrawTrend(const DashboardState &state)
{
    // Implementation needed to draw trend direction and strength
}

//+------------------------------------------------------------------+
//| Draw Volatility section                                          |
//+------------------------------------------------------------------+
void CDashboardRenderer::DrawVolatility(const DashboardState &state)
{
    // Implementation needed to draw ATR and volatility level
}

//+------------------------------------------------------------------+
//| Draw Key Levels Section                                          |
//+------------------------------------------------------------------+
void CDashboardRenderer::DrawKeyLevelsSection()
{
    int y_offset = m_y_pos + 110;

    DrawLabel(m_obj_prefix + "_MajorHighLabel", m_x_pos + 10, y_offset, "Major High:");
    DrawLabel(m_obj_prefix + "_MajorHighValue", m_x_pos + 100, y_offset, DoubleToString(m_state.nextMajorHigh, _Digits));
    y_offset += 15;

    DrawLabel(m_obj_prefix + "_MajorLowLabel", m_x_pos + 10, y_offset, "Major Low:");
    DrawLabel(m_obj_prefix + "_MajorLowValue", m_x_pos + 100, y_offset, DoubleToString(m_state.nextMajorLow, _Digits));
}

//+------------------------------------------------------------------+
//| Clear all dashboard objects                                      |
//+------------------------------------------------------------------+
void CDashboardRenderer::Clear()
{
    ObjectsDeleteAll(m_chart_id, m_obj_prefix);
}

//+------------------------------------------------------------------+
//| Helper to draw a text label                                      |
//+------------------------------------------------------------------+
void CDashboardRenderer::DrawLabel(string name, int x, int y, string text, color clr=clrWhite, int font_size=8)
{
    ObjectCreate(m_chart_id, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(m_chart_id, name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(m_chart_id, name, OBJPROP_YDISTANCE, y);
    ObjectSetString(m_chart_id, name, OBJPROP_TEXT, text);
    ObjectSetInteger(m_chart_id, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(m_chart_id, name, OBJPROP_FONTSIZE, font_size);
    ObjectSetInteger(m_chart_id, name, OBJPROP_BACK, false);
    ObjectSetInteger(m_chart_id, name, OBJPROP_SELECTABLE, false);
}
//+------------------------------------------------------------------+