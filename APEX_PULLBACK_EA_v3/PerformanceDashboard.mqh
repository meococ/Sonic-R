//+------------------------------------------------------------------+
//| Performance Dashboard - Real-time Visualization                 |
//| Copyright 2024, APEX PULLBACK EA v14.0                          |
//+------------------------------------------------------------------+
#ifndef PERFORMANCE_DASHBOARD_MQH
#define PERFORMANCE_DASHBOARD_MQH

#include "CommonStructs.mqh"      // Core structures, enums, and inputs
#include <ChartObjects/ChartObjectsLines.mqh>
#include <ChartObjects/ChartObjectsShapes.mqh>
#include <ChartObjects/ChartObjectsTxtControls.mqh>

namespace ApexPullback {

//+------------------------------------------------------------------+
//| Dashboard Panel Configuration                                    |
//+------------------------------------------------------------------+
struct DashboardConfig {
    int PanelX;
    int PanelY;
    int PanelWidth;
    int PanelHeight;
    color BackgroundColor;
    color TextColor;
    color PositiveColor;
    color NegativeColor;
    color NeutralColor;
    int FontSize;
    string FontName;
    bool ShowMiniCharts;
    bool ShowRealTimeMetrics;
    bool ShowTradeHistory;
    
    DashboardConfig() {
        PanelX = 20;
        PanelY = 50;
        PanelWidth = 350;
        PanelHeight = 600;
        BackgroundColor = C'25,25,25';
        TextColor = clrWhite;
        PositiveColor = clrLimeGreen;
        NegativeColor = clrRed;
        NeutralColor = clrGray;
        FontSize = 9;
        FontName = "Consolas";
        ShowMiniCharts = true;
        ShowRealTimeMetrics = true;
        ShowTradeHistory = true;
    }
};

//+------------------------------------------------------------------+
//| Mini Chart Data Structure                                       |
//+------------------------------------------------------------------+
struct MiniChartData {
    double Values[];
    datetime Times[];
    int MaxPoints;
    double MinValue;
    double MaxValue;
    color LineColor;
    string Title;
    
    MiniChartData() {
        MaxPoints = 100;
        MinValue = 0.0;
        MaxValue = 0.0;
        LineColor = clrCyan;
        Title = "";
    }
};

//+------------------------------------------------------------------+
//| Performance Dashboard Class                                     |
//+------------------------------------------------------------------+
class CPerformanceDashboard {
private:
    EAContext* m_Context;
    DashboardConfig m_Config;
    
    // Chart objects for dashboard
    CChartObjectRectangle* m_BackgroundPanel;
    CChartObjectLabel* m_Labels[];
    CChartObjectTrendLine* m_MiniChartLines[];
    
    // Dashboard data
    MiniChartData m_EquityChart;
    MiniChartData m_DrawdownChart;
    MiniChartData m_SharpeChart;
    MiniChartData m_ProfitChart;
    
    // Update tracking
    datetime m_LastUpdate;
    int m_UpdateInterval;  // seconds
    
    // Display metrics
    double m_CurrentEquity;
    double m_CurrentDrawdown;
    double m_CurrentSharpe;
    double m_CurrentSortino;
    double m_CurrentCalmar;
    double m_DailyPnL;
    double m_WeeklyPnL;
    double m_MonthlyPnL;
    int m_TotalTrades;
    double m_WinRate;
    double m_ProfitFactor;
    
    // Chart management
    int m_LabelCount;
    int m_LineCount;
    
public:
    // Constructor & Destructor
    CPerformanceDashboard();
    ~CPerformanceDashboard();
    
    // Initialization
    bool Initialize(EAContext* context);
    void SetConfiguration(const DashboardConfig& config);
    bool CreateDashboard();
    void DestroyDashboard();
    
    // Real-time updates
    void OnTick();
    void UpdateMetrics();
    void UpdateMiniCharts();
    void RefreshDisplay();
    
    // Data management
    void AddEquityPoint(double equity);
    void AddDrawdownPoint(double drawdown);
    void AddSharpePoint(double sharpe);
    void AddProfitPoint(double profit);
    
    // Display methods
    void ShowPerformanceMetrics();
    void ShowTradeStatistics();
    void ShowRiskMetrics();
    void ShowTimeBasedReturns();
    void DrawMiniChart(const MiniChartData& data, int startY, int height);
    
    // Chart object management
    bool CreateLabel(string name, string text, int x, int y, color clr = clrWhite);
    bool CreateMiniChartLine(string name, int x1, int y1, int x2, int y2, color clr = clrCyan);
    void UpdateLabel(string name, string text, color clr = clrWhite);
    
    // Utility methods
    string FormatMetric(double value, int digits = 2);
    string FormatPercentage(double value);
    string FormatCurrency(double value);
    color GetColorByValue(double value, bool isPositiveBetter = true);
    
    // Configuration
    void SetUpdateInterval(int seconds) { m_UpdateInterval = seconds; }
    void SetPanelPosition(int x, int y);
    void SetPanelSize(int width, int height);
    void ToggleMiniCharts(bool show);
    
    // Getters
    bool IsVisible() const;
    datetime GetLastUpdate() const { return m_LastUpdate; }
    DashboardConfig GetConfiguration() const { return m_Config; }
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPerformanceDashboard::CPerformanceDashboard() {
    m_Context = NULL;
    m_BackgroundPanel = NULL;
    m_LastUpdate = 0;
    m_UpdateInterval = 1;  // 1 second
    m_LabelCount = 0;
    m_LineCount = 0;
    
    // Initialize metrics
    m_CurrentEquity = 0.0;
    m_CurrentDrawdown = 0.0;
    m_CurrentSharpe = 0.0;
    m_CurrentSortino = 0.0;
    m_CurrentCalmar = 0.0;
    m_DailyPnL = 0.0;
    m_WeeklyPnL = 0.0;
    m_MonthlyPnL = 0.0;
    m_TotalTrades = 0;
    m_WinRate = 0.0;
    m_ProfitFactor = 0.0;
    
    // Initialize mini charts
    m_EquityChart.Title = "Equity Curve";
    m_EquityChart.LineColor = clrLimeGreen;
    m_DrawdownChart.Title = "Drawdown";
    m_DrawdownChart.LineColor = clrRed;
    m_SharpeChart.Title = "Sharpe Ratio";
    m_SharpeChart.LineColor = clrCyan;
    m_ProfitChart.Title = "Daily P&L";
    m_ProfitChart.LineColor = clrYellow;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPerformanceDashboard::~CPerformanceDashboard() {
    DestroyDashboard();
}

//+------------------------------------------------------------------+
//| Initialize dashboard                                             |
//+------------------------------------------------------------------+
bool CPerformanceDashboard::Initialize(EAContext* context) {
    if (context == NULL) {
        Print("[PerformanceDashboard] ERROR: Context is NULL");
        return false;
    }
    
    m_Context = context;
    
    if (!CreateDashboard()) {
        Print("[PerformanceDashboard] ERROR: Failed to create dashboard");
        return false;
    }
    
    if (m_Context->Logger != NULL) {
        m_Context->Logger->LogInfo("Performance Dashboard initialized successfully");
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Create dashboard                                                 |
//+------------------------------------------------------------------+
bool CPerformanceDashboard::CreateDashboard() {
    // Create background panel
    m_BackgroundPanel = new CChartObjectRectangle();
    if (m_BackgroundPanel == NULL) {
        return false;
    }
    
    string panelName = "APEX_Dashboard_Panel";
    if (!m_BackgroundPanel.Create(0, panelName, 0, 
        m_Config.PanelX, m_Config.PanelY,
        m_Config.PanelX + m_Config.PanelWidth, m_Config.PanelY + m_Config.PanelHeight)) {
        delete m_BackgroundPanel;
        m_BackgroundPanel = NULL;
        return false;
    }
    
    m_BackgroundPanel.Color(m_Config.BackgroundColor);
    m_BackgroundPanel.Fill(true);
    m_BackgroundPanel.Width(2);
    m_BackgroundPanel.Style(STYLE_SOLID);
    
    // Create title
    CreateLabel("APEX_Dashboard_Title", "APEX PULLBACK EA v14.0 - Performance Dashboard", 
                m_Config.PanelX + 10, m_Config.PanelY + 10, clrWhite);
    
    return true;
}

//+------------------------------------------------------------------+
//| Destroy dashboard                                                |
//+------------------------------------------------------------------+
void CPerformanceDashboard::DestroyDashboard() {
    // Delete background panel
    if (m_BackgroundPanel != NULL) {
        m_BackgroundPanel.Delete();
        delete m_BackgroundPanel;
        m_BackgroundPanel = NULL;
    }
    
    // Delete all labels
    for (int i = 0; i < ArraySize(m_Labels); i++) {
        if (m_Labels[i] != NULL) {
            m_Labels[i].Delete();
            delete m_Labels[i];
        }
    }
    ArrayFree(m_Labels);
    
    // Delete all lines
    for (int i = 0; i < ArraySize(m_MiniChartLines); i++) {
        if (m_MiniChartLines[i] != NULL) {
            m_MiniChartLines[i].Delete();
            delete m_MiniChartLines[i];
        }
    }
    ArrayFree(m_MiniChartLines);
    
    m_LabelCount = 0;
    m_LineCount = 0;
}

//+------------------------------------------------------------------+
//| OnTick - Real-time updates                                      |
//+------------------------------------------------------------------+
void CPerformanceDashboard::OnTick() {
    datetime currentTime = TimeCurrent();
    
    if (currentTime - m_LastUpdate >= m_UpdateInterval) {
        UpdateMetrics();
        RefreshDisplay();
        m_LastUpdate = currentTime;
    }
}

//+------------------------------------------------------------------+
//| Update metrics from PerformanceTracker                          |
//+------------------------------------------------------------------+
void CPerformanceDashboard::UpdateMetrics() {
    if (m_Context == NULL || m_Context->PerformanceTracker == NULL) {
        return;
    }
    
    // Get current metrics from PerformanceTracker
    m_CurrentEquity = AccountEquity();
    m_CurrentDrawdown = m_Context->PerformanceTracker->GetCurrentDrawdown();
    m_CurrentSharpe = m_Context->PerformanceTracker->GetSharpeRatio();
    m_CurrentSortino = m_Context->PerformanceTracker->GetSortinoRatio();
    m_CurrentCalmar = m_Context->PerformanceTracker->GetCalmarRatio();
    m_TotalTrades = m_Context->PerformanceTracker->GetTotalTrades();
    m_WinRate = m_Context->PerformanceTracker->GetWinRate();
    m_ProfitFactor = m_Context->PerformanceTracker->GetProfitFactor();
    
    // Calculate time-based returns
    m_DailyPnL = m_Context->PerformanceTracker->GetDailyReturn();
    m_WeeklyPnL = m_Context->PerformanceTracker->GetWeeklyReturn();
    m_MonthlyPnL = m_Context->PerformanceTracker->GetMonthlyReturn();
    
    // Update mini charts
    if (m_Config.ShowMiniCharts) {
        UpdateMiniCharts();
    }
}

//+------------------------------------------------------------------+
//| Update mini charts                                              |
//+------------------------------------------------------------------+
void CPerformanceDashboard::UpdateMiniCharts() {
    AddEquityPoint(m_CurrentEquity);
    AddDrawdownPoint(m_CurrentDrawdown);
    AddSharpePoint(m_CurrentSharpe);
    AddProfitPoint(m_DailyPnL);
}

//+------------------------------------------------------------------+
//| Refresh display                                                  |
//+------------------------------------------------------------------+
void CPerformanceDashboard::RefreshDisplay() {
    ShowPerformanceMetrics();
    ShowTradeStatistics();
    ShowRiskMetrics();
    ShowTimeBasedReturns();
    
    if (m_Config.ShowMiniCharts) {
        DrawMiniChart(m_EquityChart, m_Config.PanelY + 200, 60);
        DrawMiniChart(m_DrawdownChart, m_Config.PanelY + 280, 60);
        DrawMiniChart(m_SharpeChart, m_Config.PanelY + 360, 60);
        DrawMiniChart(m_ProfitChart, m_Config.PanelY + 440, 60);
    }
}

//+------------------------------------------------------------------+
//| Show performance metrics                                         |
//+------------------------------------------------------------------+
void CPerformanceDashboard::ShowPerformanceMetrics() {
    int yPos = m_Config.PanelY + 40;
    int lineHeight = 18;
    
    // Performance Metrics Section
    CreateLabel("APEX_Perf_Header", "=== PERFORMANCE METRICS ===", 
                m_Config.PanelX + 10, yPos, clrYellow);
    yPos += lineHeight + 5;
    
    // Sharpe Ratio
    string sharpeText = "Sharpe Ratio: " + FormatMetric(m_CurrentSharpe, 3);
    color sharpeColor = GetColorByValue(m_CurrentSharpe, true);
    CreateLabel("APEX_Sharpe", sharpeText, m_Config.PanelX + 15, yPos, sharpeColor);
    yPos += lineHeight;
    
    // Sortino Ratio
    string sortinoText = "Sortino Ratio: " + FormatMetric(m_CurrentSortino, 3);
    color sortinoColor = GetColorByValue(m_CurrentSortino, true);
    CreateLabel("APEX_Sortino", sortinoText, m_Config.PanelX + 15, yPos, sortinoColor);
    yPos += lineHeight;
    
    // Calmar Ratio
    string calmarText = "Calmar Ratio: " + FormatMetric(m_CurrentCalmar, 3);
    color calmarColor = GetColorByValue(m_CurrentCalmar, true);
    CreateLabel("APEX_Calmar", calmarText, m_Config.PanelX + 15, yPos, calmarColor);
    yPos += lineHeight;
    
    // Current Drawdown
    string ddText = "Current Drawdown: " + FormatPercentage(m_CurrentDrawdown);
    color ddColor = GetColorByValue(m_CurrentDrawdown, false);
    CreateLabel("APEX_Drawdown", ddText, m_Config.PanelX + 15, yPos, ddColor);
}

//+------------------------------------------------------------------+
//| Show trade statistics                                            |
//+------------------------------------------------------------------+
void CPerformanceDashboard::ShowTradeStatistics() {
    int yPos = m_Config.PanelY + 130;
    int lineHeight = 18;
    
    // Trade Statistics Section
    CreateLabel("APEX_Trade_Header", "=== TRADE STATISTICS ===", 
                m_Config.PanelX + 10, yPos, clrYellow);
    yPos += lineHeight + 5;
    
    // Total Trades
    string tradesText = "Total Trades: " + IntegerToString(m_TotalTrades);
    CreateLabel("APEX_TotalTrades", tradesText, m_Config.PanelX + 15, yPos, m_Config.TextColor);
    yPos += lineHeight;
    
    // Win Rate
    string winRateText = "Win Rate: " + FormatPercentage(m_WinRate);
    color winRateColor = GetColorByValue(m_WinRate, true);
    CreateLabel("APEX_WinRate", winRateText, m_Config.PanelX + 15, yPos, winRateColor);
    yPos += lineHeight;
    
    // Profit Factor
    string pfText = "Profit Factor: " + FormatMetric(m_ProfitFactor, 2);
    color pfColor = GetColorByValue(m_ProfitFactor - 1.0, true);
    CreateLabel("APEX_ProfitFactor", pfText, m_Config.PanelX + 15, yPos, pfColor);
}

//+------------------------------------------------------------------+
//| Show time-based returns                                         |
//+------------------------------------------------------------------+
void CPerformanceDashboard::ShowTimeBasedReturns() {
    int yPos = m_Config.PanelY + 520;
    int lineHeight = 18;
    
    // Time-based Returns Section
    CreateLabel("APEX_Returns_Header", "=== TIME-BASED RETURNS ===", 
                m_Config.PanelX + 10, yPos, clrYellow);
    yPos += lineHeight + 5;
    
    // Daily P&L
    string dailyText = "Daily P&L: " + FormatCurrency(m_DailyPnL);
    color dailyColor = GetColorByValue(m_DailyPnL, true);
    CreateLabel("APEX_DailyPnL", dailyText, m_Config.PanelX + 15, yPos, dailyColor);
    yPos += lineHeight;
    
    // Weekly P&L
    string weeklyText = "Weekly P&L: " + FormatCurrency(m_WeeklyPnL);
    color weeklyColor = GetColorByValue(m_WeeklyPnL, true);
    CreateLabel("APEX_WeeklyPnL", weeklyText, m_Config.PanelX + 15, yPos, weeklyColor);
    yPos += lineHeight;
    
    // Monthly P&L
    string monthlyText = "Monthly P&L: " + FormatCurrency(m_MonthlyPnL);
    color monthlyColor = GetColorByValue(m_MonthlyPnL, true);
    CreateLabel("APEX_MonthlyPnL", monthlyText, m_Config.PanelX + 15, yPos, monthlyColor);
}

//+------------------------------------------------------------------+
//| Create label                                                     |
//+------------------------------------------------------------------+
bool CPerformanceDashboard::CreateLabel(string name, string text, int x, int y, color clr = clrWhite) {
    // Check if label already exists
    for (int i = 0; i < ArraySize(m_Labels); i++) {
        if (m_Labels[i] != NULL && m_Labels[i].Name() == name) {
            m_Labels[i].Description(text);
            m_Labels[i].Color(clr);
            return true;
        }
    }
    
    // Create new label
    ArrayResize(m_Labels, m_LabelCount + 1);
    m_Labels[m_LabelCount] = new CChartObjectLabel();
    
    if (m_Labels[m_LabelCount] == NULL) {
        return false;
    }
    
    if (!m_Labels[m_LabelCount].Create(0, name, 0, x, y)) {
        delete m_Labels[m_LabelCount];
        m_Labels[m_LabelCount] = NULL;
        return false;
    }
    
    m_Labels[m_LabelCount].Description(text);
    m_Labels[m_LabelCount].Color(clr);
    m_Labels[m_LabelCount].FontSize(m_Config.FontSize);
    m_Labels[m_LabelCount].Font(m_Config.FontName);
    
    m_LabelCount++;
    return true;
}

//+------------------------------------------------------------------+
//| Add equity point to mini chart                                  |
//+------------------------------------------------------------------+
void CPerformanceDashboard::AddEquityPoint(double equity) {
    int size = ArraySize(m_EquityChart.Values);
    
    if (size >= m_EquityChart.MaxPoints) {
        // Shift array left
        for (int i = 0; i < size - 1; i++) {
            m_EquityChart.Values[i] = m_EquityChart.Values[i + 1];
            m_EquityChart.Times[i] = m_EquityChart.Times[i + 1];
        }
        m_EquityChart.Values[size - 1] = equity;
        m_EquityChart.Times[size - 1] = TimeCurrent();
    } else {
        ArrayResize(m_EquityChart.Values, size + 1);
        ArrayResize(m_EquityChart.Times, size + 1);
        m_EquityChart.Values[size] = equity;
        m_EquityChart.Times[size] = TimeCurrent();
    }
    
    // Update min/max
    if (size == 0) {
        m_EquityChart.MinValue = equity;
        m_EquityChart.MaxValue = equity;
    } else {
        m_EquityChart.MinValue = MathMin(m_EquityChart.MinValue, equity);
        m_EquityChart.MaxValue = MathMax(m_EquityChart.MaxValue, equity);
    }
}

//+------------------------------------------------------------------+
//| Format metric value                                             |
//+------------------------------------------------------------------+
string CPerformanceDashboard::FormatMetric(double value, int digits = 2) {
    return DoubleToString(value, digits);
}

//+------------------------------------------------------------------+
//| Format percentage                                                |
//+------------------------------------------------------------------+
string CPerformanceDashboard::FormatPercentage(double value) {
    return DoubleToString(value * 100, 2) + "%";
}

//+------------------------------------------------------------------+
//| Format currency                                                  |
//+------------------------------------------------------------------+
string CPerformanceDashboard::FormatCurrency(double value) {
    return "$" + DoubleToString(value, 2);
}

//+------------------------------------------------------------------+
//| Get color by value                                              |
//+------------------------------------------------------------------+
color CPerformanceDashboard::GetColorByValue(double value, bool isPositiveBetter = true) {
    if (isPositiveBetter) {
        if (value > 0) return m_Config.PositiveColor;
        else if (value < 0) return m_Config.NegativeColor;
        else return m_Config.NeutralColor;
    } else {
        if (value < 0) return m_Config.PositiveColor;
        else if (value > 0) return m_Config.NegativeColor;
        else return m_Config.NeutralColor;
    }
}

} // namespace ApexPullback

#endif // PERFORMANCE_DASHBOARD_MQH