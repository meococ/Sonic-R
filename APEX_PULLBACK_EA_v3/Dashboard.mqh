//+------------------------------------------------------------------+
//|                                                   Dashboard.mqh |
//+------------------------------------------------------------------+

#ifndef DASHBOARD_MQH_
#define DASHBOARD_MQH_

#include "CommonStructs.mqh"

// BẮT ĐẦU NAMESPACE
namespace ApexPullback
{

// FORWARD DECLARATIONS - Kiến trúc tối ưu
// Chỉ khai báo những class mà Dashboard thực sự cần sử dụng
// class CMarketProfile;     // Đã có trong CommonStructs.mqh thông qua EAContext
// class CRiskManager;       // Đã có trong CommonStructs.mqh thông qua EAContext
// class CNewsFilter;        // Đã có trong CommonStructs.mqh thông qua EAContext
// class CAssetDNA;          // Đã có trong CommonStructs.mqh thông qua EAContext
class CAssetProfiler; // Giả sử đây là một lớp riêng biệt không có trong EAContext hoặc cần forward declare

//+------------------------------------------------------------------+
//| Hàm GetAdaptiveModeString                                        |
//+------------------------------------------------------------------+
// Hàm hỗ trợ để lấy chuỗi ENUM_ADAPTIVE_MODE
string GetAdaptiveModeString(ENUM_ADAPTIVE_MODE mode)
{
    switch(mode)
    {
        case MODE_MANUAL: return "Manual";
        case MODE_CONSERVATIVE: return "Conservative";
        case MODE_BALANCED: return "Balanced";
        case MODE_AGGRESSIVE: return "Aggressive";
        case MODE_LOG_ONLY: return "Log Only";
        case MODE_ADAPTIVE_TRAILING: return "Adaptive Trailing";
        case MODE_DYNAMIC_LOT: return "Dynamic Lot";
        case MODE_HYBRID: return "Hybrid";
        default: return "Unknown";
    }
}

//+------------------------------------------------------------------+
//| Lớp Dashboard                                                     |
//+------------------------------------------------------------------+

class CDashboard
{
public:
   // --- Constructor / Destructor ---
                     CDashboard(); // Constructor mặc định
                    ~CDashboard(void);

   // --- Initialization & Deinitialization ---
   void              Initialize(EAContext* context); // Truyền context ở đây
   void              Deinitialize(void);

   // --- Core Update & Event Handling ---
   void              Update(void);
   void              OnClick(const string& object_name);

   // --- UI Component Creation ---
   void              CreateAllComponents(void);

   // --- UI Component Updates ---
   void              UpdateAllComponents(void);
   void              UpdateInteractiveControls(void);

   // --- Helper Methods ---
   string            GetObjPrefix(void) const { return m_obj_prefix; }
   bool              IsVisible(void) const; // Implement this based on some logic if needed

private:
   // --- Core References ---
   EAContext*        m_context;           // Pointer to the main EA context
   long              m_chart_id;

   // --- UI Management ---
   CArrayObj         *m_chart_objects;     // Manages all dashboard chart objects
   string            m_obj_prefix;         // Prefix for all object names

   // --- Display Parameters ---
   string            m_symbol;
   string            m_ea_version;
   string            m_order_comment;

   // --- Positioning & Sizing ---
   int               m_dash_x;
   int               m_dash_y;
   int               m_width;
   int               m_height;

   // --- Theming & Colors ---
   ENUM_DASHBOARD_THEME m_theme;
   color             m_bg_color;
   color             m_title_color;
   color             m_text_color;
   color             m_value_color;
   color             m_alert_color;
   color             m_success_color;
   color             m_border_color;

   // --- UI Component Toggles ---
   bool              m_show_detailed_profile;
   bool              m_show_news;
   bool              m_show_performance;

   // --- Interactive Control IDs ---
   string            m_btn_pause_id;
   string            m_btn_close_all_id;
   string            m_dd_risk_mode_id;
   string            m_dd_risk_option_conservative_id;
   string            m_dd_risk_option_balanced_id;
   string            m_dd_risk_option_aggressive_id;
   bool              m_is_risk_dropdown_open;

   // --- Performance Tracking ---
   datetime          m_last_performance_update;
   int               m_performance_update_interval; // seconds

   // --- Performance Metrics ---
   double            m_current_equity;
   double            m_current_drawdown;
   double            m_current_sharpe;
   double            m_current_sortino;
   double            m_current_calmar;
   double            m_daily_pnl;
   double            m_weekly_pnl;
   double            m_monthly_pnl;
   int               m_total_trades;
   double            m_win_rate;
   double            m_profit_factor;

   // --- Mini Charts ---
   struct MiniChartData {
      double Values[];
      datetime Times[];
      int MaxPoints;
      double MinValue;
      double MaxValue;
      color LineColor;
      string Title;
      void Init() {
         MaxPoints = 100;
         MinValue = 0.0;
         MaxValue = 0.0;
         LineColor = clrCyan;
         Title = "";
      }
   };

   MiniChartData      m_equity_chart;
   MiniChartData      m_drawdown_chart;
   MiniChartData      m_sharpe_chart;
   MiniChartData      m_profit_chart;

   // --- Performance & Chart Methods ---
   void              UpdatePerformanceMetrics(void);
   void              ShowPerformanceMetrics(void);
   void              ShowTradeStatistics(void);
   void              ShowRiskMetrics(void);
   void              ShowTimeBasedReturns(void);
   void              AddEquityPoint(double equity);
   void              AddDrawdownPoint(double drawdown);
   void              AddSharpePoint(double sharpe);
   void              AddProfitPoint(double profit);
   void              DrawMiniChart(const MiniChartData& data, int startY, int height);
   void              UpdateMiniCharts(void);

   // --- Formatting Helpers ---
   string            FormatMetric(double value, int digits = 2);
   string            FormatPercentage(double value);
   string            FormatCurrency(double value);
   color             GetColorByValue(double value, bool isPositiveBetter = true);

   // --- Private Methods ---
   void              ApplyTheme(void);
   void              InitializeColors(void);
   void              CreateComponent(ENUM_DASHBOARD_COMPONENT component);
   void              CreateBackground(void);
   void              CreateHeader(void);
   void              CreateMarketPanel(void);
   void              CreateRiskPanel(void);
   void              CreateNewsPanel(void);
   void              CreatePerformancePanel(void);
   void              CreateInteractiveControls(void);
   void              CreatePauseButton(void);
   void              CreateCloseAllButton(void);
   void              CreateRiskModeDropdown(void);
   void              CreateRiskModeDropdownOptions(void);
   void              DeleteRiskModeDropdownOptions(void);

   // --- UI Update Methods ---
   void              UpdateHeader(void);
   void              UpdateMarketPanel(void);
   void              UpdateRiskPanel(void);
   void              UpdateNewsPanel(void);
   void              UpdatePerformancePanel(void);

   // --- Helper Methods ---
   CChartLabel*      CreateLabel(const string name, int x, int y, const string text, color clr, int font_size = 8, const string font = "Arial");
   void              DeleteObjectsByPrefix(const string prefix);
   color             GetTrendColor(ENUM_MARKET_TREND trend);
   color             GetRegimeColor(ENUM_MARKET_REGIME regime);
   string            GetTrendString(ENUM_MARKET_TREND trend);
   string            GetRegimeString(ENUM_MARKET_REGIME regime);
   string GetSessionString(ENUM_SESSION session);
   }
   else
   {
      status_text = "TRADING ACTIVE";
      status_color = m_success_color;
   }

   ObjectSetString(m_chart_id, status_name, OBJPROP_TEXT, status_text);
   ObjectSetInteger(m_chart_id, status_name, OBJPROP_COLOR, status_color);
}

//+------------------------------------------------------------------+
//| CreateMarketPanel                                                |
//+------------------------------------------------------------------+
void CDashboard::CreateMarketPanel(void)
{
   int y_pos = m_dash_y + 40;
   int x_pos = m_dash_x + 10;
   int col_width = (m_width - 20) / 2;

   // Panel Title
   CreateLabel(m_obj_prefix + "MarketTitle", x_pos, y_pos, "MARKET SENTIMENT", m_title_color, 9, "Arial Bold");
   y_pos += 20;

   // --- Left Column ---
   CreateLabel(m_obj_prefix + "BidLabel", x_pos, y_pos, "Bid:", m_text_color);
   CreateLabel(m_obj_prefix + "BidValue", x_pos + 50, y_pos, "-", m_value_color);
   y_pos += 15;
   CreateLabel(m_obj_prefix + "AskLabel", x_pos, y_pos, "Ask:", m_text_color);
   CreateLabel(m_obj_prefix + "AskValue", x_pos + 50, y_pos, "-", m_value_color);
   y_pos += 15;
   CreateLabel(m_obj_prefix + "SpreadLabel", x_pos, y_pos, "Spread:", m_text_color);
   CreateLabel(m_obj_prefix + "SpreadValue", x_pos + 50, y_pos, "-", m_value_color);

   // --- Right Column ---
   y_pos = m_dash_y + 60; // Reset Y for the right column
   x_pos += col_width;
   CreateLabel(m_obj_prefix + "TrendLabel", x_pos, y_pos, "Trend:", m_text_color);
   CreateLabel(m_obj_prefix + "TrendValue", x_pos + 50, y_pos, "-", m_value_color);
   y_pos += 15;
   CreateLabel(m_obj_prefix + "RegimeLabel", x_pos, y_pos, "Regime:", m_text_color);

} // END NAMESPACE ApexPullback

#endif // DASHBOARD_MQH_
   CreateLabel(m_obj_prefix + "RegimeValue", x_pos + 50, y_pos, "-", m_value_color);
   y_pos += 15;
   CreateLabel(m_obj_prefix + "SessionLabel", x_pos, y_pos, "Session:", m_text_color);
   CreateLabel(m_obj_prefix + "SessionValue", x_pos + 50, y_pos, "-", m_value_color);
}

//+------------------------------------------------------------------+
//| UpdateMarketPanel                                                |
//+------------------------------------------------------------------+
void CDashboard::UpdateMarketPanel(void)
{
   if(!m_context || !m_context->pMarketData) return;

   // Update prices and spread
   ObjectSetString(m_chart_id, m_obj_prefix + "BidValue", OBJPROP_TEXT, DoubleToString(m_context->pMarketData->CurrentBid, _Digits));
   ObjectSetString(m_chart_id, m_obj_prefix + "AskValue", OBJPROP_TEXT, DoubleToString(m_context->pMarketData->CurrentAsk, _Digits));
   ObjectSetString(m_chart_id, m_obj_prefix + "SpreadValue", OBJPROP_TEXT, IntegerToString(m_context->pMarketData->CurrentSpreadInPoints));

   // Update trend
   string trend_str = GetTrendString(m_context->pMarketData->PrimaryTrend);
   color trend_color = GetTrendColor(m_context->pMarketData->PrimaryTrend);
   ObjectSetString(m_chart_id, m_obj_prefix + "TrendValue", OBJPROP_TEXT, trend_str);
   ObjectSetInteger(m_chart_id, m_obj_prefix + "TrendValue", OBJPROP_COLOR, trend_color);

   // Update regime
   string regime_str = GetRegimeString(m_context->pMarketData->CurrentRegime);
   color regime_color = GetRegimeColor(m_context->pMarketData->CurrentRegime);
   ObjectSetString(m_chart_id, m_obj_prefix + "RegimeValue", OBJPROP_TEXT, regime_str);
   ObjectSetInteger(m_chart_id, m_obj_prefix + "RegimeValue", OBJPROP_COLOR, regime_color);
   
   // Update session
   string session_str = GetSessionString(m_context->pMarketData->CurrentSession);
   ObjectSetString(m_chart_id, m_obj_prefix + "SessionValue", OBJPROP_TEXT, session_str);
}

//+------------------------------------------------------------------+
//| CreateRiskPanel                                                  |
//+------------------------------------------------------------------+
void CDashboard::CreateRiskPanel(void)
{
   int y_pos = m_dash_y + 125; // Position below Market Panel
   int x_pos = m_dash_x + 10;

   // Panel Title
   CreateLabel(m_obj_prefix + "RiskTitle", x_pos, y_pos, "RISK MANAGEMENT", m_title_color, 9, "Arial Bold");
   y_pos += 20;

   // Risk Mode
   CreateLabel(m_obj_prefix + "RiskModeLabel", x_pos, y_pos, "Mode:", m_text_color);
   CreateLabel(m_obj_prefix + "RiskModeValue", x_pos + 80, y_pos, "-", m_value_color);
   y_pos += 15;

   // Calculated Lot Size
   CreateLabel(m_obj_prefix + "LotSizeLabel", x_pos, y_pos, "Lot Size:", m_text_color);
   CreateLabel(m_obj_prefix + "LotSizeValue", x_pos + 80, y_pos, "-", m_value_color);
   y_pos += 15;

   // Stop Loss
   CreateLabel(m_obj_prefix + "StopLossLabel", x_pos, y_pos, "Stop Loss (pips):", m_text_color);
   CreateLabel(m_obj_prefix + "StopLossValue", x_pos + 80, y_pos, "-", m_value_color);
}

//+------------------------------------------------------------------+
//| UpdateRiskPanel                                                  |
//+------------------------------------------------------------------+
void CDashboard::UpdateRiskPanel(void)
{
   if(!m_context || !m_context->pRiskManager) return;

   // Update Risk Mode
   string mode_str = GetAdaptiveModeString(m_context->pRiskManager->GetCurrentAdaptiveMode());
   ObjectSetString(m_chart_id, m_obj_prefix + "RiskModeValue", OBJPROP_TEXT, mode_str);

   // Update Lot Size
   ObjectSetString(m_chart_id, m_obj_prefix + "LotSizeValue", OBJPROP_TEXT, DoubleToString(m_context->pRiskManager->GetLastCalculatedLotSize(), 2));

   // Update Stop Loss
   ObjectSetString(m_chart_id, m_obj_prefix + "StopLossValue", OBJPROP_TEXT, DoubleToString(m_context->pRiskManager->GetLastCalculatedSLPips(), 1));
}

//+------------------------------------------------------------------+
//| CreatePerformancePanel                                           |
//+------------------------------------------------------------------+
void CDashboard::CreatePerformancePanel(void)
{
   int y_pos = m_dash_y + 195; // Position below Risk Panel
   int x_pos = m_dash_x + 10;
   int col_width = (m_width - 20) / 2;

   // Panel Title
   CreateLabel(m_obj_prefix + "PerfTitle", x_pos, y_pos, "PERFORMANCE", m_title_color, 9, "Arial Bold");
   y_pos += 20;

   // --- Left Column ---
   CreateLabel(m_obj_prefix + "NetPLLabel", x_pos, y_pos, "Net P/L:", m_text_color);
   CreateLabel(m_obj_prefix + "NetPLValue", x_pos + 70, y_pos, "$0.00", m_value_color);
   y_pos += 15;
   CreateLabel(m_obj_prefix + "WinRateLabel", x_pos, y_pos, "Win Rate:", m_text_color);
   CreateLabel(m_obj_prefix + "WinRateValue", x_pos + 70, y_pos, "0.0%", m_value_color);
   y_pos += 15;
   CreateLabel(m_obj_prefix + "TotalTradesLabel", x_pos, y_pos, "Trades:", m_text_color);
   CreateLabel(m_obj_prefix + "TotalTradesValue", x_pos + 70, y_pos, "0", m_value_color);

   // --- Right Column ---
   y_pos = m_dash_y + 215; // Reset Y for the right column
   x_pos += col_width;
   CreateLabel(m_obj_prefix + "ProfitFactorLabel", x_pos, y_pos, "Profit Factor:", m_text_color);
   CreateLabel(m_obj_prefix + "ProfitFactorValue", x_pos + 70, y_pos, "0.00", m_value_color);
   y_pos += 15;
   CreateLabel(m_obj_prefix + "DrawdownLabel", x_pos, y_pos, "Drawdown:", m_text_color);
   CreateLabel(m_obj_prefix + "DrawdownValue", x_pos + 70, y_pos, "0.0%", m_value_color);
   y_pos += 15;
   CreateLabel(m_obj_prefix + "AvgTradeLabel", x_pos, y_pos, "Avg Trade:", m_text_color);
   CreateLabel(m_obj_prefix + "AvgTradeValue", x_pos + 70, y_pos, "$0.00", m_value_color);
}

//+------------------------------------------------------------------+
//| UpdatePerformancePanel                                           |
//+------------------------------------------------------------------+
void CDashboard::UpdatePerformancePanel(void)
{
   // Net P/L
   string net_pl_str = "$" + DoubleToString(m_perf_net_pl, 2);
   color net_pl_color = (m_perf_net_pl >= 0) ? m_success_color : m_alert_color;
   ObjectSetString(m_chart_id, m_obj_prefix + "NetPLValue", OBJPROP_TEXT, net_pl_str);
   ObjectSetInteger(m_chart_id, m_obj_prefix + "NetPLValue", OBJPROP_COLOR, net_pl_color);

   // Win Rate
   string win_rate_str = DoubleToString(m_perf_win_rate, 1) + "%";
   ObjectSetString(m_chart_id, m_obj_prefix + "WinRateValue", OBJPROP_TEXT, win_rate_str);

   // Total Trades
   ObjectSetString(m_chart_id, m_obj_prefix + "TotalTradesValue", OBJPROP_TEXT, IntegerToString(m_perf_total_trades));

   // Profit Factor
   string pf_str = DoubleToString(m_perf_profit_factor, 2);
   color pf_color = (m_perf_profit_factor >= 1.0) ? m_success_color : m_alert_color;
   ObjectSetString(m_chart_id, m_obj_prefix + "ProfitFactorValue", OBJPROP_TEXT, pf_str);
   ObjectSetInteger(m_chart_id, m_obj_prefix + "ProfitFactorValue", OBJPROP_COLOR, pf_color);

   // Drawdown
   string dd_str = DoubleToString(m_perf_max_drawdown_pct, 1) + "%";
   ObjectSetString(m_chart_id, m_obj_prefix + "DrawdownValue", OBJPROP_TEXT, dd_str);

   // Avg Trade
   string avg_trade_str = "$" + DoubleToString(m_perf_avg_trade, 2);
   color avg_trade_color = (m_perf_avg_trade >= 0) ? m_success_color : m_alert_color;
   ObjectSetString(m_chart_id, m_obj_prefix + "AvgTradeValue", OBJPROP_TEXT, avg_trade_str);
   ObjectSetInteger(m_chart_id, m_obj_prefix + "AvgTradeValue", OBJPROP_COLOR, avg_trade_color);
}

//+------------------------------------------------------------------+
//| CreateInteractiveControls                                        |
//+------------------------------------------------------------------+
void CDashboard::CreateInteractiveControls(void)
{
   int y_pos = m_dash_y + m_height - 30;
   int x_pos = m_dash_x + 10;
   int button_width = 100;
   int button_height = 20;

   // Pause Trading Button
   m_pause_button_id = CreateButton(m_obj_prefix + "PauseButton", x_pos, y_pos, button_width, button_height, "Pause Trading");
   x_pos += button_width + 10;

   // Close All Button
   m_close_all_button_id = CreateButton(m_obj_prefix + "CloseAllButton", x_pos, y_pos, button_width, button_height, "Close All Trades");
   x_pos += button_width + 10;

   // Risk Mode Dropdown
   int dropdown_width = 120;
   CreateLabel(m_obj_prefix + "RiskDropdownLabel", x_pos, y_pos + 2, "Risk:", m_text_color);
   m_risk_dropdown_id = CreateDropdown(m_obj_prefix + "RiskDropdown", x_pos + 35, y_pos, dropdown_width, button_height);
   AddDropdownItem(m_risk_dropdown_id, "Conservative");
   AddDropdownItem(m_risk_dropdown_id, "Balanced");
   AddDropdownItem(m_risk_dropdown_id, "Aggressive");
   SetDropdownValueFromEnum(m_risk_dropdown_id, m_context->RiskMode);
}

//+------------------------------------------------------------------+
//| UpdateInteractiveControls                                        |
//+------------------------------------------------------------------+
void CDashboard::UpdateInteractiveControls(void)
{
    if (!m_context) return;

   if(m_context->IsTradingPaused)
   {
      // ObjectSetString(m_chart_id, m_pause_button_id, OBJPROP_TEXT, "Resume Trading");
   }
   else
   {
      // ObjectSetString(m_chart_id, m_pause_button_id, OBJPROP_TEXT, "Pause Trading");
   }

   // Update dropdown to reflect external changes if any
   if(m_context->pRiskManager)
   {
      // SetDropdownValueFromEnum(m_risk_dropdown_id, m_context->pRiskManager->GetCurrentAdaptiveMode());
   }
}

//+------------------------------------------------------------------+
//| Helper: CreateLabel                                              |
//+------------------------------------------------------------------+
CChartLabel* CDashboard::CreateLabel(const string name, int x, int y, const string text, color clr, int font_size=8, const string font="Arial")
{
    CChartLabel* label = new CChartLabel();
    if(CheckPointer(label) == POINTER_INVALID) return NULL;

    if(!label.Create(m_chart_id, name, 0, x, y))
    {
        delete label;
        return NULL;
    }

    label.Text(text);
    label.Color(clr);
    label.Font(font);
    label.FontSize(font_size);
    label.Anchor(ANCHOR_LEFT_UPPER);
    label.Corner(CORNER_LEFT_UPPER);
    m_chart_objects.Add(label);
    return label;
}   ObjectSetInteger(m_chart_id, name, OBJPROP_FONTSIZE, font_size);
   ObjectSetString(m_chart_id, name, OBJPROP_FONT, font);
   ObjectSetInteger(m_chart_id, name, OBJPROP_ANCHOR, anchor);
   ObjectSetInteger(m_chart_id, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(m_chart_id, name, OBJPROP_BACK, true);
   ArrayAdd(m_chart_objects, name);
}

//+------------------------------------------------------------------+
//| Helper: CreateButton                                             |
//+------------------------------------------------------------------+
string CDashboard::CreateButton(string name, int x, int y, int width, int height, string text)
{
   if(ObjectFind(m_chart_id, name) != -1) return name; // Already exists

   if(!ObjectCreate(m_chart_id, name, OBJ_BUTTON, 0, 0, 0))
   {
      m_logger.LogFormat(L_ERROR, "Failed to create button '%s'. Error %d", name, GetLastError());
      return "";
   }
   ObjectSetInteger(m_chart_id, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(m_chart_id, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(m_chart_id, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(m_chart_id, name, OBJPROP_YSIZE, height);
   ObjectSetString(m_chart_id, name, OBJPROP_TEXT, text);
   ObjectSetInteger(m_chart_id, name, OBJPROP_BGCOLOR, m_bg_color_light);
   ObjectSetInteger(m_chart_id, name, OBJPROP_BORDER_COLOR, m_border_color);
   ObjectSetInteger(m_chart_id, name, OBJPROP_COLOR, m_text_color);
   ObjectSetInteger(m_chart_id, name, OBJPROP_FONTSIZE, 8);
   ObjectSetString(m_chart_id, name, OBJPROP_FONT, "Arial");
   ObjectSetInteger(m_chart_id, name, OBJPROP_STATE, false);
   ObjectSetInteger(m_chart_id, name, OBJPROP_BACK, false);
   ArrayAdd(m_chart_objects, name);
   return name;
}

//+------------------------------------------------------------------+
//| Helper: CreateDropdown                                           |
//+------------------------------------------------------------------+
string CDashboard::CreateDropdown(string name, int x, int y, int width, int height)
{
   if(ObjectFind(m_chart_id, name) != -1) return name; // Already exists

   if(!ObjectCreate(m_chart_id, name, OBJ_COMBOBOX, 0, 0, 0))
   {
      m_logger.LogFormat(L_ERROR, "Failed to create dropdown '%s'. Error %d", name, GetLastError());
      return "";
   }
   ObjectSetInteger(m_chart_id, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(m_chart_id, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(m_chart_id, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(m_chart_id, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(m_chart_id, name, OBJPROP_BGCOLOR, m_bg_color_light);
   ObjectSetInteger(m_chart_id, name, OBJPROP_BORDER_COLOR, m_border_color);
   ObjectSetInteger(m_chart_id, name, OBJPROP_COLOR, m_text_color);
   ObjectSetInteger(m_chart_id, name, OBJPROP_FONTSIZE, 8);
   ObjectSetString(m_chart_id, name, OBJPROP_FONT, "Arial");
   ObjectSetInteger(m_chart_id, name, OBJPROP_BACK, false);
   ArrayAdd(m_chart_objects, name);
   return name;
}

//+------------------------------------------------------------------+
//| Helper: AddDropdownItem                                          |
//+------------------------------------------------------------------+
void CDashboard::AddDropdownItem(string dropdown_name, string item_text)
{
   if(ObjectFind(m_chart_id, dropdown_name) == -1) return;
   ChartSetString(m_chart_id, CHART_OBJ_ADD, dropdown_name, item_text);
}

//+------------------------------------------------------------------+
//| Helper: SetDropdownValueFromEnum                                 |
//+------------------------------------------------------------------+
void CDashboard::SetDropdownValueFromEnum(string dropdown_name, ENUM_RISK_MODE risk_mode)
{
   if(ObjectFind(m_chart_id, dropdown_name) == -1) return;
   string mode_str = EnumToString(risk_mode);
   StringSubstr(mode_str, 5); // Remove "RISK_"
   TextCase(mode_str, TEXT_CASE_PROPER);
   ObjectSetString(m_chart_id, dropdown_name, OBJPROP_TEXT, mode_str);
}

//+------------------------------------------------------------------+
//| Helper: GetTrendString                                           |
//+------------------------------------------------------------------+
string CDashboard::GetTrendString(ENUM_MARKET_TREND trend)
{
   switch(trend)
   {
      case TREND_UP:   return "Uptrend";
      case TREND_DOWN: return "Downtrend";
      default:         return "Ranging";
   }
}

//+------------------------------------------------------------------+
//| Helper: GetRegimeString                                          |
//+------------------------------------------------------------------+
string CDashboard::GetRegimeString(ENUM_MARKET_REGIME regime)
{
   switch(regime)
   {
      case REGIME_TRENDING:    return "Trending";
      case REGIME_VOLATILE:    return "Volatile";
      case REGIME_REVERSION:   return "Mean Reversion";
      default:                 return "Low Volume";
   }
}

//+------------------------------------------------------------------+
//| Helper: GetSessionString                                         |
//+------------------------------------------------------------------+
string CDashboard::GetSessionString(ENUM_TRADING_SESSION session)
{
   switch(session)
   {
      case SESSION_LONDON:  return "London";
      case SESSION_NEWYORK: return "New York";
      case SESSION_ASIAN:   return "Asian";
      default:              return "Overlap/Closed";
   }
}

//+------------------------------------------------------------------+
//| Helper: GetTrendColor                                            |
//+------------------------------------------------------------------+
color CDashboard::GetTrendColor(ENUM_MARKET_TREND trend)
{
   switch(trend)
   {
      case TREND_UP:   return m_success_color;
      case TREND_DOWN: return m_alert_color;
      default:         return m_text_color;
   }
}

//+------------------------------------------------------------------+
//| Helper: GetRegimeColor                                           |
//+------------------------------------------------------------------+
color CDashboard::GetRegimeColor(ENUM_MARKET_REGIME regime)
{
   switch(regime)
   {
      case REGIME_TRENDING:    return C'33,150,243'; // Blue
      case REGIME_VOLATILE:    return C'255,152,0';  // Orange
      case REGIME_REVERSION:   return C'76,175,80';   // Green
      default:                 return m_text_color;
   }
}

//+------------------------------------------------------------------+
//| Helper: DeleteObjectsByPrefix                                    |
//+------------------------------------------------------------------+
void CDashboard::DeleteObjectsByPrefix(void)
{
   // A more robust way to delete objects to avoid issues with deletion during iteration
   int total = ObjectsTotal(m_chart_id, -1, -1);
   string to_delete[];
   ArrayResize(to_delete, 0);

   for(int i = 0; i < total; i++)
   {
      string name = ObjectName(m_chart_id, i, -1, -1);
      if(StringFind(name, m_obj_prefix) == 0)
      {
         ArrayAdd(to_delete, name);
      }
   }

   int delete_count = ArraySize(to_delete);
   for(int i = 0; i < delete_count; i++)
   {
      if(ObjectFind(m_chart_id, to_delete[i]) != -1)
      {
         ObjectDelete(m_chart_id, to_delete[i]);
      }
   }
   m_logger.LogFormat(L_INFO, "%d dashboard objects deleted.", delete_count);
}

//+------------------------------------------------------------------+
//| Update                                                           |
//+------------------------------------------------------------------+
void CDashboard::Update(void)
{
   if(!m_context || !m_chart_objects) return;

   UpdateAllComponents();
   ChartRedraw(m_chart_id);
}
   bool              m_show_news;
   bool              m_show_performance;

   // --- Interactive Control IDs ---
   string            m_btn_pause_id;
   string            m_btn_close_all_id;
   string            m_dd_risk_mode_id;
   string            m_dd_risk_option_conservative_id;
   string            m_dd_risk_option_balanced_id;
   string            m_dd_risk_option_aggressive_id;
   bool              m_is_risk_dropdown_open;

   // --- Private Methods ---
   void              ApplyTheme(void);
   void              InitializeColors(void);
   void              CreateComponent(ENUM_DASHBOARD_COMPONENT component);
   void              CreateBackground(void);
   void              CreateHeader(void);
   void              CreateMarketPanel(void);
   void              CreateRiskPanel(void);
   void              CreateNewsPanel(void);
   void              CreatePerformancePanel(void);
   void              CreateInteractiveControls(void);
   void              CreatePauseButton(void);
   void              CreateCloseAllButton(void);
   void              CreateRiskModeDropdown(void);
   void              CreateRiskModeDropdownOptions(void);
   void              DeleteRiskModeDropdownOptions(void);

   // --- UI Update Methods ---
   void              UpdateHeader(void);
   void              UpdateMarketPanel(void);
   void              UpdateRiskPanel(void);
   void              UpdateNewsPanel(void);
   void              UpdatePerformancePanel(void);

   // --- Helper Methods ---
   CChartLabel*      CreateLabel(const string name, int x, int y, const string text, color clr, int font_size = 8, const string font = "Arial");
   void              DeleteObjectsByPrefix(const string prefix);
   color             GetTrendColor(ENUM_MARKET_TREND trend);
   color             GetRegimeColor(ENUM_MARKET_REGIME regime);
   string            GetTrendString(ENUM_MARKET_TREND trend);
   string            GetRegimeString(ENUM_MARKET_REGIME regime);
   string            GetSessionString(ENUM_SESSION session);

public:
                     CDashboard(void);
                    ~CDashboard(void);

   bool              Initialize(EAContext *context, long chart_id);
   void              Deinitialize(const int reason = 0);
   void              Update(void);
   void              OnClick(const string object_name);

   // --- Configuration ---
   void              SetPosition(int x, int y) { m_dash_x = x; m_dash_y = y; }
   void              SetSize(int width, int height) { m_width = width; m_height = height; }
   void              SetTheme(ENUM_DASHBOARD_THEME theme) { m_theme = theme; ApplyTheme(); }
   void              ShowDetailedProfile(bool show) { m_show_detailed_profile = show; }
   void              ShowNews(bool show) { m_show_news = show; }
   void              ShowPerformance(bool show) { m_show_performance = show; }
};

//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CDashboard::CDashboard(void)
{
   m_context = NULL;
   m_logger = NULL;
   m_chart_id = 0;
   m_chart_objects = new CArrayObj();

   m_dash_x = 20;
   m_dash_y = 20;
   m_width = 320;
   m_height = 550;
   m_theme = THEME_LIGHT;

   m_obj_prefix = "APEX_DASH_" + (string)m_chart_id + "_";

   m_show_detailed_profile = true;
   m_show_news = true;
   m_show_performance = true;
   
   m_is_risk_dropdown_open = false;
}

//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
CDashboard::~CDashboard(void)
{
   Deinitialize(0);
   if(CheckPointer(m_chart_objects) == POINTER_VALID)
     {
      delete m_chart_objects;
      m_chart_objects = NULL;
     }
}

//+------------------------------------------------------------------+
//| Initialize
//+------------------------------------------------------------------+
bool CDashboard::Initialize(EAContext *context, long chart_id)
{
   if(CheckPointer(context) == POINTER_INVALID) return false;
   m_context = context;
   m_logger = context->Logger;
   m_chart_id = chart_id;

   m_obj_prefix = "APEX_DASH_" + (string)m_chart_id + "_";

   m_symbol = m_context->Symbol;
   m_ea_version = m_context->EAVersion;
   m_order_comment = m_context->OrderComment;

   ApplyTheme();

   Deinitialize(0);

   // Create all components
   CreateBackground();
   CreateHeader();
   CreateMarketPanel();
   CreateRiskPanel();
   if(m_show_news) CreateNewsPanel();
   if(m_show_performance) CreatePerformancePanel();
   CreateInteractiveControls();

   Update(); // Initial data population

   ChartRedraw(m_chart_id);
   return true;
}

//+------------------------------------------------------------------+
//| Deinitialize
//+------------------------------------------------------------------+
void CDashboard::Deinitialize(const int reason)
{
   if(CheckPointer(m_chart_objects) != POINTER_VALID) return;

   // This loop correctly deletes the objects and removes them from the array
   m_chart_objects.Delete(0, m_chart_objects.Total());
   m_chart_objects.Clear();
   
   // A final cleanup just in case
   ObjectsDeleteAll(m_chart_id, m_obj_prefix);
   ChartRedraw(m_chart_id);
}

//+------------------------------------------------------------------+
//| Clear (Replaced by Deinitialize)
//+------------------------------------------------------------------+
void CDashboard::Clear() // This function is now conceptually replaced by Deinitialize
{
   Deinitialize(0);
}

//+------------------------------------------------------------------+
//| Create Interactive Controls
//+------------------------------------------------------------------+
void CDashboard::CreateInteractiveControls()
{
    // Define IDs for interactive elements
    m_btn_pause_id = m_obj_prefix + "PauseButton";
    m_btn_close_all_id = m_obj_prefix + "CloseAllButton";
    m_dd_risk_mode_id = m_obj_prefix + "RiskModeDD";
    m_dd_risk_option_conservative_id = m_obj_prefix + "RiskModeOptConservative";
    m_dd_risk_option_balanced_id = m_obj_prefix + "RiskModeOptBalanced";
    m_dd_risk_option_aggressive_id = m_obj_prefix + "RiskModeOptAggressive";
    m_is_risk_dropdown_open = false;

    // Create the actual controls
    CreatePauseButton();
    CreateCloseAllButton();
    CreateRiskModeDropdown();
}

//+------------------------------------------------------------------+
//| Create Pause Button
//+------------------------------------------------------------------+
void CDashboard::CreatePauseButton()
{
    int buttonX = m_dash_x + 10;
    int buttonY = m_dash_y + m_height - 40;
    int buttonWidth = 130;
    int buttonHeight = 25;

    bool isPaused = m_context && m_context->TradeManager ? m_context->TradeManager->IsTradingPaused() : false;

    CChartButton *button = new CChartButton(m_context);
    if(CheckPointer(button) == POINTER_INVALID) return;

    if(button.Create(m_chart_id, m_btn_pause_id, 0, buttonX, buttonY, buttonWidth, buttonHeight))
    {
        button.SetText(isPaused ? "RESUME TRADES" : "PAUSE NEW TRADES");
        button.SetColor(m_text_color);
        button.SetColorBackground(isPaused ? m_alert_color : m_success_color);
        button.SetColorBorder(m_border_color);
        button.SetFontSize(8);
        button.SetFont("Arial");
        button.State(isPaused);
        m_chart_objects.Add(button);
    }
    else
    {
        if(m_logger) m_logger->LogError("Failed to create Pause button");
        delete button;
    }
}

//+------------------------------------------------------------------+
//| Create Close All Button
//+------------------------------------------------------------------+
void CDashboard::CreateCloseAllButton()
{
    int buttonX = m_dash_x + 10 + 130 + 10;
    int buttonY = m_dash_y + m_height - 40;
    int buttonWidth = 130;
    int buttonHeight = 25;

    CChartButton *button = new CChartButton(m_context);
    if(CheckPointer(button) == POINTER_INVALID) return;

    if(button.Create(m_chart_id, m_btn_close_all_id, 0, buttonX, buttonY, buttonWidth, buttonHeight))
    {
        button.SetText("CLOSE ALL POSITIONS");
        button.SetColor(m_text_color);
        button.SetColorBackground((color)0xFFE0E0);
        button.SetColorBorder(m_alert_color);
        button.SetFontSize(8);
        button.SetFont("Arial");
        m_chart_objects.Add(button);
    }
    else
    {
        if(m_logger) m_logger->LogError("Failed to create Close All button");
        delete button;
    }
}

//+------------------------------------------------------------------+
//| Create Risk Mode Dropdown
//+------------------------------------------------------------------+
void CDashboard::CreateRiskModeDropdown()
{
    int ddX = m_dash_x + 10;
    int ddY = m_dash_y + m_height - 40 - 30;
    int ddWidth = 270;
    int ddHeight = 25;

    string currentRiskModeStr = "Unknown";
    if(m_context && m_context->RiskManager)
    {
        currentRiskModeStr = GetAdaptiveModeString(m_context->RiskManager->GetAdaptiveMode());
    }

    CChartButton *button = new CChartButton(m_context);
    if(CheckPointer(button) == POINTER_INVALID) return;

    if(button.Create(m_chart_id, m_dd_risk_mode_id, 0, ddX, ddY, ddWidth, ddHeight))
    {
        button.SetText("RISK MODE: " + currentRiskModeStr + " ▼");
        button.SetColor(m_text_color);
        button.SetColorBackground(m_bg_color);
        button.SetColorBorder(m_border_color);
        button.SetFontSize(8);
        button.SetFont("Arial");
        m_chart_objects.Add(button);
    }
    else
    {
        if(m_logger) m_logger->LogError("Failed to create Risk Mode dropdown");
        delete button;
    }
}

//+------------------------------------------------------------------+
//| Create Risk Mode Dropdown Options
//+------------------------------------------------------------------+
void CDashboard::CreateRiskModeDropdownOptions()
{
    if(m_is_risk_dropdown_open) return;

    CChartButton *main_dd = (CChartButton*)m_chart_objects.Search(m_dd_risk_mode_id);
    if(CheckPointer(main_dd) == POINTER_INVALID) return;

    int optionX = main_dd.X_Distance();
    int optionY = main_dd.Y_Distance() - 25; // Start above the main button
    int optionWidth = main_dd.X_Size();
    int optionHeight = 25;

    string options_text[] = {GetAdaptiveModeString(MODE_AGGRESSIVE), GetAdaptiveModeString(MODE_BALANCED), GetAdaptiveModeString(MODE_CONSERVATIVE)};
    string options_ids[] = {m_dd_risk_option_aggressive_id, m_dd_risk_option_balanced_id, m_dd_risk_option_conservative_id};

    for(int i = 0; i < ArraySize(options_text); i++)
    {
        CChartButton *button = new CChartButton(m_context);
        if(CheckPointer(button) == POINTER_INVALID) continue;

        if(button.Create(m_chart_id, options_ids[i], 0, optionX, optionY, optionWidth, optionHeight))
        {
            button.SetText(options_text[i]);
            button.SetColorBackground(m_bg_color);
            button.SetColorBorder(m_border_color);
            button.SetFontSize(8);
            m_chart_objects.Add(button);
        }
        else
        {
            if(m_logger) m_logger->LogError("Failed to create risk mode option: " + options_text[i]);
            delete button;
        }
        optionY -= optionHeight; // Move up for the next button
    }

    main_dd.SetText(StringSubstr(main_dd.Text(), 0, StringLen(main_dd.Text()) - 1) + "▲");
    m_is_risk_dropdown_open = true;
    ChartRedraw(m_chart_id);
}

//+------------------------------------------------------------------+
//| Delete Risk Mode Dropdown Options
//+------------------------------------------------------------------+
void CDashboard::DeleteRiskModeDropdownOptions()
{
    if(!m_is_risk_dropdown_open) return;

    string ids[] = {m_dd_risk_option_conservative_id, m_dd_risk_option_balanced_id, m_dd_risk_option_aggressive_id};
    for(int i = 0; i < ArraySize(ids); i++)
    {
        for(int j = m_chart_objects.Total() - 1; j >= 0; j--)
        {
            CObject *obj = m_chart_objects.At(j);
            if(CheckPointer(obj) != POINTER_INVALID && obj.Name() == ids[i])
            {
                m_chart_objects.Delete(j); // This also deletes the object
                break; 
            }
        }
    }

    CChartButton *main_dd = (CChartButton*)m_chart_objects.Search(m_dd_risk_mode_id);
    if(CheckPointer(main_dd) != POINTER_INVALID)
    {
        main_dd.SetText(StringSubstr(main_dd.Text(), 0, StringLen(main_dd.Text()) - 1) + "▼");
    }

    m_is_risk_dropdown_open = false;
    ChartRedraw(m_chart_id);
}

//+------------------------------------------------------------------+
//| Handle OnClick Event
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Update - Main refresh function
//+------------------------------------------------------------------+
void CDashboard::Update(void)
{
    if(!m_context) return;

    // Update all visible components
    UpdateHeader();
    UpdateMarketPanel();
    UpdateRiskPanel();
    if(m_show_news) UpdateNewsPanel();
    if(m_show_performance) UpdatePerformancePanel();

    ChartRedraw(m_chart_id);
}

//+------------------------------------------------------------------+
//| Create Background
//+------------------------------------------------------------------+
void CDashboard::CreateBackground()
{
    CChartRectangle *bg = new CChartRectangle(m_context);
    if(CheckPointer(bg) == POINTER_INVALID) return;

    if(bg.Create(m_chart_id, m_obj_prefix + "Background", 0, m_dash_x, m_dash_y, m_width, m_height))
    {
        bg.SetColorBackground(m_bg_color);
        bg.SetColorBorder(m_border_color);
        bg.SetCorner(CORNER_LEFT_UPPER);
        bg.SetStyle(STYLE_SOLID);
        bg.SetWidth(1);
        bg.SetSelectable(false);
        bg.SetBack(true);
        m_chart_objects.Add(bg);
    }
    else
    {
        if(m_logger) m_logger->LogError("Failed to create Dashboard background");
        delete bg;
    }
}

//+------------------------------------------------------------------+
//| Create Header
//+------------------------------------------------------------------+
void CDashboard::CreateHeader()
{
    int current_y = m_dash_y + 10;
    CreateLabel(m_obj_prefix + "Title", m_dash_x + 10, current_y, "APEX PULLBACK EA", m_title_color, 12, "Arial Black");
    current_y += 20;
    CreateLabel(m_obj_prefix + "Version", m_dash_x + 10, current_y, "Version: " + m_ea_version, m_text_color, 8);
    current_y += 15;
    CreateLabel(m_obj_prefix + "Symbol", m_dash_x + 10, current_y, "Symbol: " + m_symbol, m_text_color, 8);
    current_y += 15;
    CreateLabel(m_obj_prefix + "Status_Label", m_dash_x + 10, current_y, "Status:", m_text_color, 8);
    CreateLabel(m_obj_prefix + "Status_Value", m_dash_x + 80, current_y, "Initializing...", m_value_color, 8);
}

//+------------------------------------------------------------------+
//| Update Header
//+------------------------------------------------------------------+
void CDashboard::UpdateHeader()
{
    if(!m_context || !m_context->TradeManager) return;

    string status_text = "Unknown";
    color status_color = m_value_color;

    if(m_context->TradeManager->IsTradingPaused())
    {
        status_text = "TRADING PAUSED";
        status_color = m_alert_color;
    }
    else
    {
        status_text = "ACTIVE";
        status_color = m_success_color;
    }

    CChartLabel *status_label = (CChartLabel*)m_chart_objects.Search(m_obj_prefix + "Status_Value");
    if(CheckPointer(status_label) != POINTER_INVALID)
    {
        status_label->SetText(status_text);
        status_label->SetColor(status_color);
    }
}

//+------------------------------------------------------------------+
//| Create a Label Helper
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Create Market Panel
//+------------------------------------------------------------------+
void CDashboard::CreateMarketPanel()
{
    int y_start = m_dash_y + 80;
    int x_col1 = m_dash_x + 10;
    int x_col2 = m_dash_x + 150;

    CreateLabel(m_obj_prefix + "MarketTitle", x_col1, y_start, "--- MARKET CONTEXT ---", m_title_color, 9, "Arial Bold");
    y_start += 20;

    // Column 1
    CreateLabel(m_obj_prefix + "TrendLabel", x_col1, y_start, "Primary Trend:", m_text_color);
    CreateLabel(m_obj_prefix + "TrendValue", x_col1 + 80, y_start, "...", m_value_color);
    y_start += 15;
    CreateLabel(m_obj_prefix + "RegimeLabel", x_col1, y_start, "Market Regime:", m_text_color);
    CreateLabel(m_obj_prefix + "RegimeValue", x_col1 + 80, y_start, "...", m_value_color);
    y_start += 15;
    CreateLabel(m_obj_prefix + "VolatilityLabel", x_col1, y_start, "Volatility:", m_text_color);
    CreateLabel(m_obj_prefix + "VolatilityValue", x_col1 + 80, y_start, "...", m_value_color);

    // Column 2
    y_start = m_dash_y + 80 + 20; // Reset Y for second column
    CreateLabel(m_obj_prefix + "SessionLabel", x_col2, y_start, "Session:", m_text_color);
    CreateLabel(m_obj_prefix + "SessionValue", x_col2 + 60, y_start, "...", m_value_color);
    y_start += 15;
    CreateLabel(m_obj_prefix + "SpreadLabel", x_col2, y_start, "Spread:", m_text_color);
    CreateLabel(m_obj_prefix + "SpreadValue", x_col2 + 60, y_start, "...", m_value_color);
}

//+------------------------------------------------------------------+
//| Update Market Panel
//+------------------------------------------------------------------+
void CDashboard::UpdateMarketPanel()
{
    if(!m_context || !m_context->AssetDNA) return;

    // Update Trend
    CChartLabel *trend_value = (CChartLabel*)m_chart_objects.Search(m_obj_prefix + "TrendValue");
    if(CheckPointer(trend_value) != POINTER_INVALID)
    {
        ENUM_MARKET_TREND trend = m_context->AssetDNA->GetPrimaryTrend();
        trend_value->SetText(GetTrendString(trend));
        trend_value->SetColor(GetTrendColor(trend));
    }

    // Update Regime
    CChartLabel *regime_value = (CChartLabel*)m_chart_objects.Search(m_obj_prefix + "RegimeValue");
    if(CheckPointer(regime_value) != POINTER_INVALID)
    {
        ENUM_MARKET_REGIME regime = m_context->AssetDNA->GetMarketRegime();
        regime_value->SetText(GetRegimeString(regime));
        regime_value->SetColor(GetRegimeColor(regime));
    }
    
    // Update Volatility
    CChartLabel *volatility_value = (CChartLabel*)m_chart_objects.Search(m_obj_prefix + "VolatilityValue");
    if(CheckPointer(volatility_value) != POINTER_INVALID)
    {
        double atr_value = m_context->AssetDNA->GetVolatilityATR();
        volatility_value->SetText(DoubleToString(atr_value, _Digits) + " pips");
    }

    // Update Session
    CChartLabel *session_value = (CChartLabel*)m_chart_objects.Search(m_obj_prefix + "SessionValue");
    if(CheckPointer(session_value) != POINTER_INVALID)
    {
        session_value->SetText(GetSessionString(m_context->AssetDNA->GetCurrentSession()));
    }

    // Update Spread
    CChartLabel *spread_value = (CChartLabel*)m_chart_objects.Search(m_obj_prefix + "SpreadValue");
    if(CheckPointer(spread_value) != POINTER_INVALID)
    {
        spread_value->SetText(IntegerToString(m_context->Spread) + " pts");
    }
}

//+------------------------------------------------------------------+
//| Create Risk Panel
//+------------------------------------------------------------------+
void CDashboard::CreateRiskPanel()
{
    int y_start = m_dash_y + 170;
    int x_col1 = m_dash_x + 10;

    CreateLabel(m_obj_prefix + "RiskTitle", x_col1, y_start, "--- RISK & PERFORMANCE ---", m_title_color, 9, "Arial Bold");
    y_start += 20;

    CreateLabel(m_obj_prefix + "MaxRiskLabel", x_col1, y_start, "Max Risk/Trade:", m_text_color);
    CreateLabel(m_obj_prefix + "MaxRiskValue", x_col1 + 120, y_start, "...", m_value_color);
    y_start += 15;
    CreateLabel(m_obj_prefix + "DailyDDLabel", x_col1, y_start, "Daily Drawdown:", m_text_color);
    CreateLabel(m_obj_prefix + "DailyDDValue", x_col1 + 120, y_start, "...", m_alert_color);
    y_start += 15;
    CreateLabel(m_obj_prefix + "NextLotLabel", x_col1, y_start, "Next Lot Size:", m_text_color);
    CreateLabel(m_obj_prefix + "NextLotValue", x_col1 + 120, y_start, "...", m_value_color);
}

//+------------------------------------------------------------------+
//| Update Risk Panel
//+------------------------------------------------------------------+
void CDashboard::UpdateRiskPanel()
{
    if(!m_context || !m_context->RiskManager || !m_context->PositionManager) return;

    // Update Max Risk
    CChartLabel *max_risk_value = (CChartLabel*)m_chart_objects.Search(m_obj_prefix + "MaxRiskValue");
    if(CheckPointer(max_risk_value) != POINTER_INVALID)
    {
        max_risk_value->SetText(DoubleToString(m_context->RiskManager->GetMaxRiskPerTrade() * 100, 2) + "%");
    }

    // Update Daily DD
    CChartLabel *daily_dd_value = (CChartLabel*)m_chart_objects.Search(m_obj_prefix + "DailyDDValue");
    if(CheckPointer(daily_dd_value) != POINTER_INVALID)
    {
        daily_dd_value->SetText(DoubleToString(m_context->RiskManager->GetCurrentDailyDrawdown() * 100, 2) + "%");
    }

    // Update Next Lot Size
    CChartLabel *next_lot_value = (CChartLabel*)m_chart_objects.Search(m_obj_prefix + "NextLotValue");
    if(CheckPointer(next_lot_value) != POINTER_INVALID)
    {
        // This is a placeholder, as calculating the exact next lot size might be complex here.
        // A simplified version might just show the base lot.
        next_lot_value->SetText(DoubleToString(m_context->RiskManager->GetBaseLotSize(), 2));
    }
}

//+------------------------------------------------------------------+
//| Helper Functions for String/Color Conversion
//+------------------------------------------------------------------+
string CDashboard::GetTrendString(ENUM_MARKET_TREND trend)
{
    switch(trend)
    {
        case TREND_UP: return "Uptrend";
        case TREND_DOWN: return "Downtrend";
        default: return "Ranging";
    }
}

color CDashboard::GetTrendColor(ENUM_MARKET_TREND trend)
{
    switch(trend)
    {
        case TREND_UP: return clrLimeGreen;
        case TREND_DOWN: return clrIndianRed;
        default: return clrGoldenrod;
    }
}

string CDashboard::GetRegimeString(ENUM_MARKET_REGIME regime)
{
    switch(regime)
    {
        case REGIME_TRENDING: return "Trending";
        case REGIME_RANGING: return "Ranging";
        case REGIME_VOLATILE: return "Volatile";
        default: return "Undefined";
    }
}

color CDashboard::GetRegimeColor(ENUM_MARKET_REGIME regime)
{
    switch(regime)
    {
        case REGIME_TRENDING: return clrCornflowerBlue;
        case REGIME_RANGING: return clrOrange;
        case REGIME_VOLATILE: return clrOrchid;
        default: return m_value_color;
    }
}

//+------------------------------------------------------------------+
//| Create News Panel
//+------------------------------------------------------------------+
void CDashboard::CreateNewsPanel()
{
    int y_start = m_dash_y + 250;
    int x_col1 = m_dash_x + 10;

    CreateLabel(m_obj_prefix + "NewsTitle", x_col1, y_start, "--- UPCOMING NEWS ---", m_title_color, 9, "Arial Bold");
    y_start += 20;

    CreateLabel(m_obj_prefix + "NextNewsLabel", x_col1, y_start, "Next Event:", m_text_color);
    CreateLabel(m_obj_prefix + "NextNewsValue", x_col1 + 80, y_start, "N/A", m_value_color);
    y_start += 15;
    CreateLabel(m_obj_prefix + "TimeTillLabel", x_col1, y_start, "Time Until:", m_text_color);
    CreateLabel(m_obj_prefix + "TimeTillValue", x_col1 + 80, y_start, "--:--:--", m_value_color);
}

//+------------------------------------------------------------------+
//| Update News Panel
//+------------------------------------------------------------------+
void CDashboard::UpdateNewsPanel()
{
    if(!m_context || !m_context->NewsFilter) return;

    NewsEvent next_event = m_context->NewsFilter->GetNextHighImpactEvent();
    string event_name = "N/A";
    string time_till = "--:--:--";
    color time_color = m_value_color;

    if(next_event.timestamp > 0)
    {
        event_name = next_event.title;
        long seconds_till = next_event.timestamp - TimeCurrent();
        if(seconds_till > 0)
        {
            time_till = TimeToString(seconds_till, TIME_MINUTES | TIME_SECONDS);
            if(seconds_till < 60 * 15) // Less than 15 minutes
            {
                time_color = m_alert_color;
            }
        }
        else
        {
            time_till = "Passed";
        }
    }

    CChartLabel *name_label = (CChartLabel*)m_chart_objects.Search(m_obj_prefix + "NextNewsValue");
    if(CheckPointer(name_label) != POINTER_INVALID) name_label.SetText(event_name);

    CChartLabel *time_label = (CChartLabel*)m_chart_objects.Search(m_obj_prefix + "TimeTillValue");
    if(CheckPointer(time_label) != POINTER_INVALID)
    {
        time_label.SetText(time_till);
        time_label.SetColor(time_color);
    }
}

//+------------------------------------------------------------------+
//| Create Performance Panel
//+------------------------------------------------------------------+
void CDashboard::CreatePerformancePanel()
{
    int y_start = m_dash_y + 300;
    int x_col1 = m_dash_x + 10;

    CreateLabel(m_obj_prefix + "PerfTitle", x_col1, y_start, "--- PERFORMANCE ---", m_title_color, 9, "Arial Bold");
    y_start += 20;

    CreateLabel(m_obj_prefix + "PnlLabel", x_col1, y_start, "Total P/L:", m_text_color);
    CreateLabel(m_obj_prefix + "PnlValue", x_col1 + 120, y_start, "...", m_value_color);
    y_start += 15;
    CreateLabel(m_obj_prefix + "WinRateLabel", x_col1, y_start, "Win Rate:", m_text_color);
    CreateLabel(m_obj_prefix + "WinRateValue", x_col1 + 120, y_start, "...", m_value_color);
    y_start += 15;
    CreateLabel(m_obj_prefix + "TradesLabel", x_col1, y_start, "Total Trades:", m_text_color);
    CreateLabel(m_obj_prefix + "TradesValue", x_col1 + 120, y_start, "...", m_value_color);
}

//+------------------------------------------------------------------+
//| Update Performance Panel
//+------------------------------------------------------------------+
void CDashboard::UpdatePerformancePanel()
{
    if(!m_context || !m_context->PerformanceTracker) return;

    // Update P/L
    CChartLabel *pnl_value = (CChartLabel*)m_chart_objects.Search(m_obj_prefix + "PnlValue");
    if(CheckPointer(pnl_value) != POINTER_INVALID)
    {
        double pnl = m_context->PerformanceTracker->GetTotalNetProfit();
        pnl_value->SetText(DoubleToString(pnl, 2));
        pnl_value->SetColor(pnl >= 0 ? m_success_color : m_alert_color);
    }

    // Update Win Rate
    CChartLabel *win_rate_value = (CChartLabel*)m_chart_objects.Search(m_obj_prefix + "WinRateValue");
    if(CheckPointer(win_rate_value) != POINTER_INVALID)
    {
        win_rate_value->SetText(DoubleToString(m_context->PerformanceTracker->GetWinRate() * 100, 2) + "%");
    }

    // Update Total Trades
    CChartLabel *trades_value = (CChartLabel*)m_chart_objects.Search(m_obj_prefix + "TradesValue");
    if(CheckPointer(trades_value) != POINTER_INVALID)
    {
        trades_value->SetText(IntegerToString(m_context->PerformanceTracker->GetTotalTrades()));
    }
}

//+------------------------------------------------------------------+
//| Apply Theme
//+------------------------------------------------------------------+
void CDashboard::ApplyTheme()
{
    InitializeColors();
    // Future: Could redraw existing objects with new colors if needed
}

//+------------------------------------------------------------------+
//| Initialize Colors
//+------------------------------------------------------------------+
void CDashboard::InitializeColors()
{
    if(m_theme == THEME_DARK)
    {
        m_bg_color = (color)0xFF2E2E2E;
        m_title_color = (color)0xFFFFFFFF;
        m_text_color = (color)0xFFD0D0D0;
        m_value_color = (color)0xFFFFFFFF;
        m_border_color = (color)0xFF555555;
    }
    else // THEME_LIGHT
    {
        m_bg_color = (color)0xFFF0F0F0;
        m_title_color = (color)0xFF000000;
        m_text_color = (color)0xFF333333;
        m_value_color = (color)0xFF000000;
        m_border_color = (color)0xFFCCCCCC;
    }
    // Universal colors
    m_success_color = clrSeaGreen;
    m_alert_color = clrFirebrick;
}


string CDashboard::GetSessionString(ENUM_SESSION session)
{
    switch(session)
    {
        case SESSION_ASIAN: return "Asian";
        case SESSION_LONDON: return "London";
        case SESSION_NEWYORK: return "New York";
        case SESSION_OVERLAP: return "Overlap";
        default: return "Closed";
    }
}


//+------------------------------------------------------------------+
//| Create a Label Helper
//+------------------------------------------------------------------+
CChartLabel* CDashboard::CreateLabel(const string name, int x, int y, const string text, color clr, int font_size=8, const string font="Arial")
{
    CChartLabel *label = new CChartLabel(m_context);
    if(CheckPointer(label) == POINTER_INVALID) return NULL;

    if(label.Create(m_chart_id, name, 0, x, y))
    {
        label->SetText(text);
        label->SetFont(font, font_size);
        label->SetColor(clr);
        label->SetAnchor(ANCHOR_LEFT_UPPER);
        label->SetSelectable(false);
        m_chart_objects.Add(label);
        return label;
    }
    else
    {
        if(m_logger) m_logger->LogError("Failed to create label: " + name);
        delete label;
        return NULL;
    }
}

//+------------------------------------------------------------------+
//| Handle OnClick Event
//+------------------------------------------------------------------+
void CDashboard::OnClick(string object_name)
{
    if(!m_context || !m_context->TradeManager || !m_context->RiskManager) return;

    // 1. Pause/Resume Button
    if(object_name == m_btn_pause_id)
    {
        bool isPaused = m_context->TradeManager->TogglePauseTrading();
        CChartButton* button = (CChartButton*)m_chart_objects.Search(m_btn_pause_id);
        if(CheckPointer(button) != POINTER_INVALID)
        {
            button->State(isPaused);
            button->SetText(isPaused ? "RESUME TRADES" : "PAUSE NEW TRADES");
            button->SetColorBackground(isPaused ? m_alert_color : m_success_color);
            if(m_logger) m_logger->LogInfo(isPaused ? "Trading paused via Dashboard." : "Trading resumed via Dashboard.");
            ChartRedraw(m_chart_id);
        }
        return;
    }

    // 2. Close All Button
    if(object_name == m_btn_close_all_id)
    {
        m_context->TradeManager->CloseAllPositionsAsync();
        if(m_logger) m_logger->LogInfo("Close All Positions command sent via Dashboard.");
        return;
    }

    // 3. Risk Mode Dropdown
    if(object_name == m_dd_risk_mode_id)
    {
        if(m_is_risk_dropdown_open)
        {
            DeleteRiskModeDropdownOptions();
        }
        else
        {
            CreateRiskModeDropdownOptions();
        }
        return;
    }

    // 4. Dropdown Options
    ENUM_ADAPTIVE_RISK_MODE newMode = WRONG_VALUE;
    string newModeLogText = "";
    if(object_name == m_dd_risk_option_conservative_id) { newMode = MODE_CONSERVATIVE; newModeLogText = "Conservative"; }
    if(object_name == m_dd_risk_option_balanced_id)     { newMode = MODE_BALANCED;     newModeLogText = "Balanced"; }
    if(object_name == m_dd_risk_option_aggressive_id)   { newMode = MODE_AGGRESSIVE;   newModeLogText = "Aggressive"; }

    if(newMode != WRONG_VALUE)
    {
        m_context->RiskManager->SetAdaptiveMode(newMode);
        if(m_logger) m_logger->LogInfo("Risk Mode set to " + newModeLogText + " via Dashboard.");

        CChartButton* main_dd = (CChartButton*)m_chart_objects.Search(m_dd_risk_mode_id);
        if(CheckPointer(main_dd) != POINTER_INVALID)
        {
            main_dd.SetText("RISK MODE: " + GetAdaptiveModeString(newMode)); // The delete function will add the arrow
        }
        
        DeleteRiskModeDropdownOptions(); // This also redraws the chart
        return;
    }
}
    ChartRedraw();
}

//+------------------------------------------------------------------+
//| Cập nhật Dashboard                                                |
//+------------------------------------------------------------------+
// void CDashboard::Update(MarketProfileData &profile) // Sẽ lấy profile từ context
void CDashboard::Update() // Called on every tick
{
    if(CheckPointer(m_context) == POINTER_INVALID) return;

    // Update all dynamic data panels
    UpdateHeader();
    UpdateMarketPanel();
    UpdateRiskPanel();
    UpdateNewsPanel();
    UpdatePerformancePanel();

    // Redraw chart to reflect changes
    ChartRedraw(m_chart_id);
}
{
    // m_LastProfile = profile; // Không cần nữa
    
    // Xóa các đối tượng cũ trước khi vẽ lại (ngoại trừ các control tương tác)
    DeleteObjectsByPrefix(m_ObjPrefix + "HEADER_");
    DeleteObjectsByPrefix(m_ObjPrefix + "MARKET_");
    DeleteObjectsByPrefix(m_ObjPrefix + "RISK_");
    DeleteObjectsByPrefix(m_ObjPrefix + "NEWS_");
    DeleteObjectsByPrefix(m_ObjPrefix + "PERF_");
    DeleteObjectsByPrefix(m_ObjPrefix + "VZ_");

    CreateHeader();
    CreateMarketPanel();
    CreateRiskPanel();
    // CreateNewsPanel(); // Tạm thời tắt nếu chưa cần
    // CreatePerformancePanel(); // Tạm thời tắt nếu chưa cần
    // CreateValueZoneVisualizer(); // Tạm thời tắt nếu chưa cần

    // Cập nhật trạng thái nút Pause
    if(ObjectFind(0, m_btnPauseTradesID) != -1 && m_Context->TradeManager != NULL)
    {
        bool isPaused = m_Context->TradeManager->IsTradingPaused();
        ObjectSetString(0, m_btnPauseTradesID, OBJPROP_TEXT, isPaused ? "RESUME TRADES" : "PAUSE NEW TRADES");
        ObjectSetInteger(0, m_btnPauseTradesID, OBJPROP_BGCOLOR, isPaused ? m_AlertColor : m_SuccessColor);
        ObjectSetInteger(0, m_btnPauseTradesID, OBJPROP_STATE, isPaused);
    }
    
    // Cập nhật text của dropdown Risk Mode
    if(ObjectFind(0, m_ddRiskModeID) != -1 && m_Context->RiskManager != NULL)
    {
        string currentRiskModeStr = GetAdaptiveModeString(m_Context->RiskManager->GetAdaptiveMode());
        string currentText = ObjectGetString(0, m_ddRiskModeID, OBJPROP_TEXT);
        string arrow = m_isRiskModeDropdownOpen ? " ▲" : " ▼";
        ObjectSetString(0, m_ddRiskModeID, OBJPROP_TEXT, "RISK MODE: " + currentRiskModeStr + arrow);
    }

    ChartRedraw();
}

//+------------------------------------------------------------------+
//| Tạo Background                                                   |
//+------------------------------------------------------------------+
void CDashboard::CreateBackground()
{
    string name = m_ObjPrefix + "BG";
    ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, m_DashX);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, m_DashY);
    ObjectSetInteger(0, name, OBJPROP_XSIZE, m_Width);
    ObjectSetInteger(0, name, OBJPROP_YSIZE, m_Height);
    ObjectSetInteger(0, name, OBJPROP_BGCOLOR, m_BackgroundColor);
    ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, m_ChartBorderColor);
    ObjectSetInteger(0, name, OBJPROP_BACK, true);
}

//+------------------------------------------------------------------+
//| Tạo Header                                                       |
//+------------------------------------------------------------------+
void CDashboard::CreateHeader()
{
    string name = m_ObjPrefix + "HEADER_TITLE";
    int yPos = m_DashY + 10;
    
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, m_DashX + 10);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
    ObjectSetString(0, name, OBJPROP_TEXT, "APEX PULLBACK EA " + m_EAVersion);
    ObjectSetInteger(0, name, OBJPROP_COLOR, m_TitleColor);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 12);
    ObjectSetString(0, name, OBJPROP_FONT, "Arial Bold");

    yPos += 20;
    name = m_ObjPrefix + "HEADER_SYMBOL";
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, m_DashX + 10);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
    ObjectSetString(0, name, OBJPROP_TEXT, "Symbol: " + m_Symbol);
    ObjectSetInteger(0, name, OBJPROP_COLOR, m_TextColor);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);

    // Thêm đường kẻ ngang
    yPos += 15;
    name = m_ObjPrefix + "HEADER_SEPARATOR";
    ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, m_DashX + 5);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
    ObjectSetInteger(0, name, OBJPROP_XSIZE, m_Width - 10);
    ObjectSetInteger(0, name, OBJPROP_YSIZE, 1);
    ObjectSetInteger(0, name, OBJPROP_BGCOLOR, m_ChartBorderColor);
    ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_NONE);
}

//+------------------------------------------------------------------+
//| Tạo Market Panel                                                 |
//+------------------------------------------------------------------+
void CDashboard::CreateMarketPanel()
{
    if (!m_Context->MarketProfile) return;

    int yPos = m_DashY + 50; // Vị trí bắt đầu của panel này
    int xPos = m_DashX + 10;
    int lineHeight = 15;

    string name = m_ObjPrefix + "MARKET_TITLE";
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xPos);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
    ObjectSetString(0, name, OBJPROP_TEXT, "MARKET PROFILE");
    ObjectSetInteger(0, name, OBJPROP_COLOR, m_TitleColor);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 10);
    ObjectSetString(0, name, OBJPROP_FONT, "Arial Bold");

    yPos += lineHeight + 5;

    // Market Regime
    name = m_ObjPrefix + "MARKET_REGIME_LABEL";
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xPos);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
    ObjectSetString(0, name, OBJPROP_TEXT, "Regime:");
    ObjectSetInteger(0, name, OBJPROP_COLOR, m_TextColor);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);

    name = m_ObjPrefix + "MARKET_REGIME_VALUE";
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xPos + 80);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
    ENUM_MARKET_REGIME regime = m_Context->MarketProfile->GetCurrentRegime();
    ObjectSetString(0, name, OBJPROP_TEXT, GetRegimeString(regime));
    ObjectSetInteger(0, name, OBJPROP_COLOR, GetRegimeColor(regime));
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
    yPos += lineHeight;

    // Market Trend
    name = m_ObjPrefix + "MARKET_TREND_LABEL";
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xPos);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
    ObjectSetString(0, name, OBJPROP_TEXT, "Trend:");
    ObjectSetInteger(0, name, OBJPROP_COLOR, m_TextColor);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);

    name = m_ObjPrefix + "MARKET_TREND_VALUE";
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xPos + 80);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
    ENUM_MARKET_TREND trend = m_Context->MarketProfile->GetCurrentTrend();
    ObjectSetString(0, name, OBJPROP_TEXT, GetTrendString(trend));
    ObjectSetInteger(0, name, OBJPROP_COLOR, GetTrendColor(trend));
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
    yPos += lineHeight;
    
    // Session
    name = m_ObjPrefix + "MARKET_SESSION_LABEL";
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xPos);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
    ObjectSetString(0, name, OBJPROP_TEXT, "Session:");
    ObjectSetInteger(0, name, OBJPROP_COLOR, m_TextColor);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);

    name = m_ObjPrefix + "MARKET_SESSION_VALUE";
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xPos + 80);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
    ENUM_SESSION session = m_Context->MarketProfile->GetCurrentSession();
    ObjectSetString(0, name, OBJPROP_TEXT, GetSessionString(session));
    ObjectSetInteger(0, name, OBJPROP_COLOR, m_ValueColor);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
    yPos += lineHeight;

    // Volatility
    name = m_ObjPrefix + "MARKET_VOLA_LABEL";
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xPos);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
    ObjectSetString(0, name, OBJPROP_TEXT, "Volatility:");
    ObjectSetInteger(0, name, OBJPROP_COLOR, m_TextColor);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);

    name = m_ObjPrefix + "MARKET_VOLA_VALUE";
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xPos + 80);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
    ObjectSetString(0, name, OBJPROP_TEXT, DoubleToString(m_Context->MarketProfile->GetVolatilityIndex(), 2));
    ObjectSetInteger(0, name, OBJPROP_COLOR, m_ValueColor);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
    yPos += lineHeight;
    
    // Value Area High
    name = m_ObjPrefix + "MARKET_VAH_LABEL";
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xPos);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
    ObjectSetString(0, name, OBJPROP_TEXT, "VAH:");
    ObjectSetInteger(0, name, OBJPROP_COLOR, m_TextColor);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);

    name = m_ObjPrefix + "MARKET_VAH_VALUE";
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xPos + 80);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
    ObjectSetString(0, name, OBJPROP_TEXT, DoubleToString(m_Context->MarketProfile->GetValueAreaHigh(),_Digits));
    ObjectSetInteger(0, name, OBJPROP_COLOR, m_ValueColor);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
    yPos += lineHeight;

    // Value Area Low
    name = m_ObjPrefix + "MARKET_VAL_LABEL";
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xPos);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
    ObjectSetString(0, name, OBJPROP_TEXT, "VAL:");
    ObjectSetInteger(0, name, OBJPROP_COLOR, m_TextColor);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);

    name = m_ObjPrefix + "MARKET_VAL_VALUE";
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xPos + 80);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
    ObjectSetString(0, name, OBJPROP_TEXT, DoubleToString(m_Context->MarketProfile->GetValueAreaLow(),_Digits));
    ObjectSetInteger(0, name, OBJPROP_COLOR, m_ValueColor);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
    yPos += lineHeight;

    // Point of Control
    name = m_ObjPrefix + "MARKET_POC_LABEL";
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xPos);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
    ObjectSetString(0, name, OBJPROP_TEXT, "POC:");
    ObjectSetInteger(0, name, OBJPROP_COLOR, m_TextColor);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);

    name = m_ObjPrefix + "MARKET_POC_VALUE";
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xPos + 80);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
    ObjectSetString(0, name, OBJPROP_TEXT, DoubleToString(m_Context->MarketProfile->GetPointOfControl(),_Digits));
    ObjectSetInteger(0, name, OBJPROP_COLOR, m_ValueColor);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
    yPos += lineHeight;
}

//+------------------------------------------------------------------+
//| Tạo Risk Panel                                                   |
//+------------------------------------------------------------------+
void CDashboard::CreateRiskPanel()
{
    if (!m_Context->RiskManager) return;

    int yPos = m_DashY + 50 + 8*15 + 10; // Vị trí bắt đầu của panel này (sau Market Panel)
    int xPos = m_DashX + 10;
    int lineHeight = 15;

    string name = m_ObjPrefix + "RISK_TITLE";
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xPos);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
    ObjectSetString(0, name, OBJPROP_TEXT, "RISK MANAGEMENT");
    ObjectSetInteger(0, name, OBJPROP_COLOR, m_TitleColor);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 10);
    ObjectSetString(0, name, OBJPROP_FONT, "Arial Bold");

    yPos += lineHeight + 5;

    // Current Risk Mode
    name = m_ObjPrefix + "RISK_MODE_LABEL";
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xPos);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
    ObjectSetString(0, name, OBJPROP_TEXT, "Risk Mode:");
    ObjectSetInteger(0, name, OBJPROP_COLOR, m_TextColor);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);

    name = m_ObjPrefix + "RISK_MODE_VALUE";
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xPos + 100);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
    ObjectSetString(0, name, OBJPROP_TEXT, GetAdaptiveModeString(m_Context->RiskManager->GetAdaptiveMode()));
    ObjectSetInteger(0, name, OBJPROP_COLOR, m_ValueColor);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
    yPos += lineHeight;

    // Max Risk Per Trade
    name = m_ObjPrefix + "RISK_MAXRISK_LABEL";
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xPos);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
    ObjectSetString(0, name, OBJPROP_TEXT, "Max Risk/Trade:");
    ObjectSetInteger(0, name, OBJPROP_COLOR, m_TextColor);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);

    name = m_ObjPrefix + "RISK_MAXRISK_VALUE";
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xPos + 100);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
    ObjectSetString(0, name, OBJPROP_TEXT, DoubleToString(m_Context->RiskManager->GetMaxRiskPerTrade() * 100, 2) + "%");
    ObjectSetInteger(0, name, OBJPROP_COLOR, m_ValueColor);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
    yPos += lineHeight;

    // Current Lot Size
    name = m_ObjPrefix + "RISK_LOTSIZE_LABEL";
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xPos);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
    ObjectSetString(0, name, OBJPROP_TEXT, "Current Lot:");
    ObjectSetInteger(0, name, OBJPROP_COLOR, m_TextColor);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);

    name = m_ObjPrefix + "RISK_LOTSIZE_VALUE";
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xPos + 100);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
    // Giả sử có hàm GetCurrentCalculatedLot() trong RiskManager
    ObjectSetString(0, name, OBJPROP_TEXT, DoubleToString(m_Context->RiskManager->GetCurrentCalculatedLot(), 2)); 
    ObjectSetInteger(0, name, OBJPROP_COLOR, m_ValueColor);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
    yPos += lineHeight;
    
    // Daily Drawdown Limit
    name = m_ObjPrefix + "RISK_DDLIMIT_LABEL";
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xPos);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
    ObjectSetString(0, name, OBJPROP_TEXT, "Daily DD Limit:");
    ObjectSetInteger(0, name, OBJPROP_COLOR, m_TextColor);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);

    name = m_ObjPrefix + "RISK_DDLIMIT_VALUE";
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xPos + 100);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
    ObjectSetString(0, name, OBJPROP_TEXT, DoubleToString(m_Context->RiskManager->GetDailyDrawdownLimit() * 100, 2) + "%");
    ObjectSetInteger(0, name, OBJPROP_COLOR, m_ValueColor);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
    yPos += lineHeight;

    // Current Daily Drawdown
    name = m_ObjPrefix + "RISK_CURR_DD_LABEL";
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xPos);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
    ObjectSetString(0, name, OBJPROP_TEXT, "Current Daily DD:");
    ObjectSetInteger(0, name, OBJPROP_COLOR, m_TextColor);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);

    name = m_ObjPrefix + "RISK_CURR_DD_VALUE";
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xPos + 100);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yPos);
    double currentDD = m_Context->RiskManager->GetCurrentDailyDrawdownPercentage();
    ObjectSetString(0, name, OBJPROP_TEXT, DoubleToString(currentDD * 100, 2) + "%");
    ObjectSetInteger(0, name, OBJPROP_COLOR, (currentDD >= m_Context->RiskManager->GetDailyDrawdownLimit() * 0.8) ? m_AlertColor : m_ValueColor ); // Highlight if near limit
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
    yPos += lineHeight;
}

// Các hàm Get...Color/String đã có ở đầu file
//+------------------------------------------------------------------+
//| Lấy màu cho Trend                                                 |
//+------------------------------------------------------------------+
color CDashboard::GetTrendColor(ENUM_MARKET_TREND trend)
{
    switch(trend)
    {
        case TREND_UP: return (color)0x00B050; // Green
        case TREND_DOWN: return (color)0xFF0000; // Red
        case TREND_SIDEWAYS: return (color)0xFFC000; // Orange
        default: return m_TextColor;
    }
}

//+------------------------------------------------------------------+
//| Lấy màu cho Regime                                                |
//+------------------------------------------------------------------+
color CDashboard::GetRegimeColor(ENUM_MARKET_REGIME regime)
{
    switch(regime)
    {
        case REGIME_TRENDING_UP: return (color)0x00B050;
        case REGIME_TRENDING_DOWN: return (color)0xFF0000;
        case REGIME_RANGING: return (color)0xFFC000;
        case REGIME_VOLATILE_EXPANSION: return (color)0x7030A0; // Purple
        case REGIME_CONSOLIDATION: return (color)0x0070C0; // Blue
        default: return m_TextColor;
    }
}

//+------------------------------------------------------------------+
//| Lấy chuỗi cho Trend                                               |
//+------------------------------------------------------------------+
string CDashboard::GetTrendString(ENUM_MARKET_TREND trend)
{
    return EnumToString(trend);
}

//+------------------------------------------------------------------+
//| Lấy chuỗi cho Regime                                              |
//+------------------------------------------------------------------+
string CDashboard::GetRegimeString(ENUM_MARKET_REGIME regime)
{
    return EnumToString(regime);
}

//+------------------------------------------------------------------+
//| Lấy chuỗi cho Session                                             |
//+------------------------------------------------------------------+
string CDashboard::GetSessionString(ENUM_SESSION session)
{
    return EnumToString(session);
}

//+------------------------------------------------------------------+
//| Xóa đối tượng theo prefix                                        |
//+------------------------------------------------------------------+
void CDashboard::DeleteObjectsByPrefix(string prefix)
{
    for(int i = ObjectsTotal(0) - 1; i >= 0; i--)
    {
        string objName = ObjectName(0, i);
        if(StringFind(objName, prefix, 0) == 0)
        {
            ObjectDelete(0, objName);
        }
    }
}

// Các hàm CreateNewsPanel, CreatePerformancePanel, CreateValueZoneVisualizer, DrawMiniChart
// cần được implement nếu m_ShowNews, m_ShowPerformance, m_ShowDetailedProfile là true
// và nếu chúng được gọi trong Update(). Hiện tại chúng đang được comment out trong Update().

// Placeholder cho các hàm chưa implement đầy đủ
void CDashboard::CreateNewsPanel(){
    // TODO: Implement News Panel
    if (!m_Context->NewsFilter || !m_ShowNews) return;
    // ... logic hiển thị news ...
}
void CDashboard::CreatePerformancePanel(){
    // TODO: Implement Performance Panel
    if(!m_ShowPerformance) return;
    // ... logic hiển thị performance ...
}
void CDashboard::CreateValueZoneVisualizer(){
    // TODO: Implement Value Zone Visualizer
    if(!m_ShowDetailedProfile || !m_Context->MarketProfile) return;
    // ... logic vẽ value zone ...
}
void CDashboard::DrawMiniChart(string name, int x, int y, int width, int height, double &data[], 
                      double minValue, double maxValue, color lineColor, string title,
                      string subtitle, bool showGrid){
    // TODO: Implement Mini Chart drawing
}

} // END namespace ApexPullback