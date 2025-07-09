//+------------------------------------------------------------------+
//|                                           AnalyticsManager.mqh |
//|                                    APEX Pullback EA v5.0 FINAL   |
//|                                  Copyright 2024, APEX Trading   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, APEX Trading"
#property link      ""
#property version   "1.00"
#property strict

#include "../../01_Core/CommonStructs.mqh"
// #include "Performance/PerformanceAnalyzer.mqh" // Included via CommonStructs or directly where needed
#include "Risk/RiskAnalyzer.mqh"
#include "Market/MarketAnalyzer.mqh"
// #include "Reporting/ReportGenerator.mqh" // Included via CommonStructs or directly where needed

//+------------------------------------------------------------------+
//| Manages all analytics components                                 |
//+------------------------------------------------------------------+
class CAnalyticsManager
{
private:
    EAContext* m_pContext;                   // Pointer to the main EA context

    // --- Analytics Modules ---
    CRiskAnalyzer*        m_pRiskAnalyzer;
    CMarketAnalyzer*      m_pMarketAnalyzer;

    // --- Configuration ---
    bool m_bRiskAnalysisEnabled;
    bool m_bMarketAnalysisEnabled;

public:
    CAnalyticsManager();
    ~CAnalyticsManager();

    bool Initialize(EAContext* context);
    void Deinitialize();
    void Update();
    void OnTimer();

    // --- Getters for Modules ---
    CRiskAnalyzer*        GetRiskAnalyzer()        { return m_pRiskAnalyzer; }
    CMarketAnalyzer*      GetMarketAnalyzer()      { return m_pMarketAnalyzer; }

    // --- Public Interface ---
    double GetHealthScore();
    void RunDiagnostics();
    string GetSystemReport();
    void UpdateConfiguration(EAContext* context);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CAnalyticsManager::CAnalyticsManager()
{
    m_pContext = NULL;
    m_pRiskAnalyzer = NULL;
    m_pMarketAnalyzer = NULL;

    // Default configurations
    m_bRiskAnalysisEnabled = true;
    m_bMarketAnalysisEnabled = true;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CAnalyticsManager::~CAnalyticsManager()
{
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CAnalyticsManager::Initialize(EAContext* context)
{
    m_pContext = context;
    if(!m_pContext)
    {
        // Log error
        return false;
    }

    if(m_bRiskAnalysisEnabled)
    {
        m_pRiskAnalyzer = new CRiskAnalyzer();
        if(!m_pRiskAnalyzer->Initialize(m_pContext))
        {
            // Log error
            return false;
        }
    }

    if(m_bMarketAnalysisEnabled)
    {
        m_pMarketAnalyzer = new CMarketAnalyzer();
        if(!m_pMarketAnalyzer->Initialize(m_pContext))
        {
            // Log error
            return false;
        }
    }

    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CAnalyticsManager::Deinitialize()
{
    if(m_pRiskAnalyzer)        { delete m_pRiskAnalyzer;        m_pRiskAnalyzer = NULL; }
    if(m_pMarketAnalyzer)      { delete m_pMarketAnalyzer;      m_pMarketAnalyzer = NULL; }
}

//+------------------------------------------------------------------+
//| Update                                                           |
//+------------------------------------------------------------------+
void CAnalyticsManager::Update()
{
    if(m_pMarketAnalyzer && m_bMarketAnalysisEnabled)
    {
        // m_pMarketAnalyzer->Update(); // Assuming Update method exists
    }
}

//+------------------------------------------------------------------+
//| OnTimer                                                          |
//+------------------------------------------------------------------+
void CAnalyticsManager::OnTimer()
{
    if(m_pRiskAnalyzer && m_bRiskAnalysisEnabled)
    {
        if(m_pContext && m_pContext->pAccountInfo)
        {
             // This logic might be better placed in the RiskManager itself
             // m_pRiskAnalyzer->UpdateRiskMetrics(m_pContext->pAccountInfo->Equity());
        }
    }

    // Performance calculation would be triggered from here, but logic needs to be defined
}

//+------------------------------------------------------------------+
//| GetHealthScore                                                   |
//+------------------------------------------------------------------+
double CAnalyticsManager::GetHealthScore()
{
    double score = 100.0;
    int checks = 0;

    if (m_pRiskAnalyzer && m_bRiskAnalysisEnabled)
    {
        // Example: Reduce score based on drawdown
        // score -= m_pRiskAnalyzer->GetCurrentDrawdown() * 10;
        checks++;
    }

    if (m_pMarketAnalyzer && m_bMarketAnalysisEnabled)
    {
        // Example: Reduce score if market conditions are unfavorable
        // if(m_pMarketAnalyzer->GetVolatility() > SomeThreshold) score -= 10;
        checks++;
    }

    return MathMax(0, score); // Ensure score doesn't go below 0
}

//+------------------------------------------------------------------+
//| RunDiagnostics                                                   |
//+------------------------------------------------------------------+
void CAnalyticsManager::RunDiagnostics()
{
    Print("--- AnalyticsManager Diagnostics ---");
    PrintFormat("Risk Analysis Enabled: %s", m_bRiskAnalysisEnabled ? "Yes" : "No");
    PrintFormat("Market Analysis Enabled: %s", m_bMarketAnalysisEnabled ? "Yes" : "No");

    if (m_pRiskAnalyzer && m_bRiskAnalysisEnabled)
    {
        // m_pRiskAnalyzer->RunDiagnostics(); // Assuming method exists
    }
    if (m_pMarketAnalyzer && m_bMarketAnalysisEnabled)
    {
        // m_pMarketAnalyzer->RunDiagnostics(); // Assuming method exists
    }
    Print("-------------------------------------");
}

//+------------------------------------------------------------------+
//| GetSystemReport                                                  |
//+------------------------------------------------------------------+
string CAnalyticsManager::GetSystemReport()
{
    string report = "=== Analytics Report ===\n";
    
    if (m_pRiskAnalyzer && m_bRiskAnalysisEnabled)
    {        
        // report += m_pRiskAnalyzer->GetReport(); // Assuming method exists
    }
    else
    {
        report += "Risk Analyzer: Disabled\n";
    }

    if (m_pMarketAnalyzer && m_bMarketAnalysisEnabled)
    {
        // report += m_pMarketAnalyzer->GetReport(); // Assuming method exists
    }
    else
    {
        report += "Market Analyzer: Disabled\n";
    }

    return report;
}

//+------------------------------------------------------------------+
//| UpdateConfiguration                                              |
//+------------------------------------------------------------------+
void CAnalyticsManager::UpdateConfiguration(EAContext* context)
{
    m_pContext = context;
    if (!m_pContext)
    {
        // Log error
        return;
    }

    // Update enabled flags from context if they exist, otherwise use defaults
    // Example:
    // m_bRiskAnalysisEnabled = m_pContext->InputParams.EnableRiskAnalysis;
    // m_bMarketAnalysisEnabled = m_pContext->InputParams.EnableMarketAnalysis;

    if (m_pRiskAnalyzer)
    {
        m_pRiskAnalyzer->UpdateConfiguration(m_pContext);
    }
    if (m_pMarketAnalyzer)
    {        
        m_pMarketAnalyzer->UpdateConfiguration(m_pContext);
    }
}
//+------------------------------------------------------------------+