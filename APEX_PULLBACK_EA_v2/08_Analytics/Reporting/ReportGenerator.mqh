//+------------------------------------------------------------------+
//|                                        ReportGenerator.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "../../01_Core/CommonStructs.mqh"

//+------------------------------------------------------------------+
//| Report generator enumerations                                  |
//+------------------------------------------------------------------+
enum ENUM_REPORT_TYPE {
    REPORT_TYPE_PERFORMANCE,        // Performance report
    REPORT_TYPE_RISK,               // Risk analysis report
    REPORT_TYPE_TRADE_ANALYSIS,     // Trade analysis report
    REPORT_TYPE_OPTIMIZATION,       // Optimization report
    REPORT_TYPE_BACKTEST,           // Backtest report
    REPORT_TYPE_WALK_FORWARD,       // Walk-forward report
    REPORT_TYPE_MONTE_CARLO,        // Monte Carlo report
    REPORT_TYPE_STRESS_TEST,        // Stress test report
    REPORT_TYPE_PORTFOLIO,          // Portfolio report
    REPORT_TYPE_BENCHMARK,          // Benchmark comparison
    REPORT_TYPE_SUMMARY,            // Executive summary
    REPORT_TYPE_DETAILED,           // Detailed analysis
    REPORT_TYPE_CUSTOM              // Custom report
};

enum ENUM_REPORT_FORMAT {
    REPORT_FORMAT_HTML,             // HTML format
    REPORT_FORMAT_PDF,              // PDF format
    REPORT_FORMAT_CSV,              // CSV format
    REPORT_FORMAT_JSON,             // JSON format
    REPORT_FORMAT_XML,              // XML format
    REPORT_FORMAT_EXCEL,            // Excel format
    REPORT_FORMAT_TEXT,             // Plain text
    REPORT_FORMAT_MARKDOWN          // Markdown format
};

enum ENUM_REPORT_TEMPLATE {
    TEMPLATE_STANDARD,              // Standard template
    TEMPLATE_EXECUTIVE,             // Executive template
    TEMPLATE_TECHNICAL,             // Technical template
    TEMPLATE_REGULATORY,            // Regulatory template
    TEMPLATE_INVESTOR,              // Investor template
    TEMPLATE_ACADEMIC,              // Academic template
    TEMPLATE_MINIMAL,               // Minimal template
    TEMPLATE_COMPREHENSIVE,         // Comprehensive template
    TEMPLATE_CUSTOM                 // Custom template
};

enum ENUM_CHART_STYLE {
    CHART_STYLE_PROFESSIONAL,       // Professional style
    CHART_STYLE_MODERN,             // Modern style
    CHART_STYLE_CLASSIC,            // Classic style
    CHART_STYLE_MINIMAL,            // Minimal style
    CHART_STYLE_COLORFUL,           // Colorful style
    CHART_STYLE_MONOCHROME,         // Monochrome style
    CHART_STYLE_CUSTOM              // Custom style
};

enum ENUM_REPORT_SECTION {
    SECTION_EXECUTIVE_SUMMARY,      // Executive summary
    SECTION_PERFORMANCE_OVERVIEW,   // Performance overview
    SECTION_RISK_ANALYSIS,          // Risk analysis
    SECTION_TRADE_STATISTICS,       // Trade statistics
    SECTION_DRAWDOWN_ANALYSIS,      // Drawdown analysis
    SECTION_BENCHMARK_COMPARISON,   // Benchmark comparison
    SECTION_OPTIMIZATION_RESULTS,   // Optimization results
    SECTION_BACKTEST_RESULTS,       // Backtest results
    SECTION_WALK_FORWARD_RESULTS,   // Walk-forward results
    SECTION_MONTE_CARLO_RESULTS,    // Monte Carlo results
    SECTION_STRESS_TEST_RESULTS,    // Stress test results
    SECTION_PORTFOLIO_ANALYSIS,     // Portfolio analysis
    SECTION_RECOMMENDATIONS,        // Recommendations
    SECTION_APPENDIX,               // Appendix
    SECTION_CUSTOM                  // Custom section
};

enum ENUM_REPORT_STATUS {
    REPORT_STATUS_PENDING,          // Report pending
    REPORT_STATUS_GENERATING,       // Report generating
    REPORT_STATUS_COMPLETED,        // Report completed
    REPORT_STATUS_FAILED,           // Report failed
    REPORT_STATUS_CANCELLED,        // Report cancelled
    REPORT_STATUS_ARCHIVED          // Report archived
};

//+------------------------------------------------------------------+
//| Report generator structures                                    |
//+------------------------------------------------------------------+
struct SReportSection {
    ENUM_REPORT_SECTION Type;       // Section type
    string Title;                   // Section title
    string Content;                 // Section content
    string Charts[];                // Chart file paths
    string Tables[];                // Table data
    bool IsEnabled;                 // Is section enabled
    int Order;                      // Section order
    string Template;                // Section template
};

struct SReportConfiguration {
    // Basic settings
    ENUM_REPORT_TYPE Type;          // Report type
    ENUM_REPORT_FORMAT Format;      // Report format
    ENUM_REPORT_TEMPLATE Template;  // Report template
    string Title;                   // Report title
    string Subtitle;                // Report subtitle
    string Author;                  // Report author
    string Company;                 // Company name
    string Logo;                    // Company logo path
    
    // Content settings
    SReportSection Sections[];      // Report sections
    int SectionCount;               // Number of sections
    bool IncludeCharts;             // Include charts
    bool IncludeTables;             // Include tables
    bool IncludeAppendix;           // Include appendix
    
    // Chart settings
    ENUM_CHART_STYLE ChartStyle;    // Chart style
    int ChartWidth;                 // Chart width
    int ChartHeight;                // Chart height
    string ChartColors[];           // Chart colors
    
    // Output settings
    string OutputPath;              // Output directory
    string FileName;                // Output file name
    bool OpenAfterGeneration;       // Open after generation
    bool EmailAfterGeneration;      // Email after generation
    string EmailRecipients[];       // Email recipients
    
    // Data settings
    datetime StartDate;             // Data start date
    datetime EndDate;               // Data end date
    string Symbols[];               // Symbols to include
    ENUM_TIMEFRAMES Timeframes[];   // Timeframes to include
    
    // Advanced settings
    bool IncludeRawData;            // Include raw data
    bool CompressOutput;            // Compress output
    string Watermark;               // Report watermark
    bool IncludeDisclaimer;         // Include disclaimer
    string CustomCSS;               // Custom CSS for HTML
    string CustomJS;                // Custom JavaScript
};

struct SReportData {
    // Performance data
    double TotalReturn;             // Total return
    double AnnualizedReturn;        // Annualized return
    double Volatility;              // Volatility
    double SharpeRatio;             // Sharpe ratio
    double MaxDrawdown;             // Maximum drawdown
    double CalmarRatio;             // Calmar ratio
    
    // Trade data
    int TotalTrades;                // Total trades
    int WinningTrades;              // Winning trades
    int LosingTrades;               // Losing trades
    double WinRate;                 // Win rate
    double ProfitFactor;            // Profit factor
    double AverageWin;              // Average win
    double AverageLoss;             // Average loss
    
    // Risk data
    double VaR95;                   // Value at Risk (95%)
    double CVaR95;                  // Conditional VaR (95%)
    double BetaToMarket;            // Beta to market
    double AlphaToMarket;           // Alpha to market
    double TrackingError;           // Tracking error
    
    // Time series data
    double EquityValues[];          // Equity curve values
    datetime EquityTimes[];         // Equity curve times
    double DrawdownValues[];        // Drawdown values
    datetime DrawdownTimes[];       // Drawdown times
    double MonthlyReturns[];        // Monthly returns
    datetime MonthlyDates[];        // Monthly dates
    
    // Additional data
    string Comments[];              // Comments
    string Warnings[];              // Warnings
    string Recommendations[];       // Recommendations
};

struct SReportInfo {
    string ReportId;                // Report identifier
    ENUM_REPORT_TYPE Type;          // Report type
    ENUM_REPORT_FORMAT Format;      // Report format
    ENUM_REPORT_STATUS Status;      // Report status
    datetime CreationTime;          // Creation time
    datetime CompletionTime;        // Completion time
    string FilePath;                // Output file path
    int FileSize;                   // File size in bytes
    string Author;                  // Report author
    string Title;                   // Report title
    double GenerationTime;          // Generation time in seconds
    string ErrorMessage;            // Error message if failed
};

struct SReportStatistics {
    // Generation statistics
    int TotalReports;               // Total reports generated
    int SuccessfulReports;          // Successful reports
    int FailedReports;              // Failed reports
    
    // Performance statistics
    double TotalGenerationTime;     // Total generation time
    double AverageGenerationTime;   // Average generation time
    double FastestGeneration;       // Fastest generation
    double SlowestGeneration;       // Slowest generation
    
    // Size statistics
    int TotalFileSize;              // Total file size
    int AverageFileSize;            // Average file size
    int LargestFile;                // Largest file size
    int SmallestFile;               // Smallest file size
    
    // Format statistics
    int HTMLReports;                // HTML reports count
    int PDFReports;                 // PDF reports count
    int CSVReports;                 // CSV reports count
    int JSONReports;                // JSON reports count
    int ExcelReports;               // Excel reports count
    
    // Error statistics
    int TotalErrors;                // Total errors
    string LastError;               // Last error message
    datetime LastErrorTime;         // Last error time
};

//+------------------------------------------------------------------+
//| Report Generator Class                                         |
//+------------------------------------------------------------------+
class CReportGenerator {
private:
    EAContext* m_pContext;
    
    // Configuration
    SReportConfiguration m_Config;
    
    // Reports
    SReportInfo m_Reports[];
    int m_ReportCount;
    SReportInfo m_CurrentReport;
    
    // Statistics
    SReportStatistics m_Statistics;
    
    // Internal state
    bool m_bInitialized;
    datetime m_LastGeneration;
    
    // Templates
    string m_Templates[];
    int m_TemplateCount;
    
    // Helper methods
    bool LoadTemplate(ENUM_REPORT_TEMPLATE templateType);
    bool GenerateHTML(const SReportData& data, string& output);
    bool GeneratePDF(const SReportData& data, const string filePath);
    bool GenerateCSV(const SReportData& data, const string filePath);
    bool GenerateJSON(const SReportData& data, string& output);
    bool GenerateExcel(const SReportData& data, const string filePath);
    
    // Section generators
    string GenerateExecutiveSummary(const SReportData& data);
    string GeneratePerformanceOverview(const SReportData& data);
    string GenerateRiskAnalysis(const SReportData& data);
    string GenerateTradeStatistics(const SReportData& data);
    string GenerateDrawdownAnalysis(const SReportData& data);
    string GenerateBenchmarkComparison(const SReportData& data);
    string GenerateRecommendations(const SReportData& data);
    
    // Chart generators
    bool GenerateEquityChart(const SReportData& data, const string filePath);
    bool GenerateDrawdownChart(const SReportData& data, const string filePath);
    bool GenerateMonthlyReturnsChart(const SReportData& data, const string filePath);
    bool GenerateRiskReturnChart(const SReportData& data, const string filePath);
    
    // Table generators
    string GeneratePerformanceTable(const SReportData& data);
    string GenerateTradeTable(const SReportData& data);
    string GenerateRiskTable(const SReportData& data);
    string GenerateMonthlyTable(const SReportData& data);
    
    // Utility methods
    string FormatNumber(double value, int decimals = 2);
    string FormatPercentage(double value, int decimals = 2);
    string FormatDate(datetime time);
    string EscapeHTML(const string text);
    string EscapeCSV(const string text);
    bool ValidateConfiguration();
    void LogError(const string message);
    void LogActivity(const string message);
    
public:
    // Constructor/Destructor
    CReportGenerator();
    ~CReportGenerator();
    
    // Initialization
    bool Initialize(EAContext* context);
    bool Deinitialize();
    bool Configure(const SReportConfiguration& config);
    
    // Report generation
    bool GenerateReport(const SReportData& data);
    bool GenerateReport(const SReportData& data, const string fileName);
    bool GenerateCustomReport(const SReportData& data, const SReportSection& sections[]);
    bool RegenerateReport(const string reportId);
    
    // Configuration methods
    bool SetReportType(ENUM_REPORT_TYPE type);
    bool SetReportFormat(ENUM_REPORT_FORMAT format);
    bool SetReportTemplate(ENUM_REPORT_TEMPLATE templateType);
    bool SetOutputPath(const string path);
    bool SetChartStyle(ENUM_CHART_STYLE style);
    bool AddSection(const SReportSection& section);
    bool RemoveSection(ENUM_REPORT_SECTION sectionType);
    bool EnableSection(ENUM_REPORT_SECTION sectionType, bool enable = true);
    
    // Template management
    bool LoadCustomTemplate(const string templatePath);
    bool SaveTemplate(const string templatePath);
    bool GetAvailableTemplates(string& templates[]);
    bool SetCustomCSS(const string css);
    bool SetCustomJS(const string js);
    
    // Report management
    bool GetReportInfo(const string reportId, SReportInfo& info);
    bool GetAllReports(SReportInfo& reports[]);
    bool DeleteReport(const string reportId);
    bool ArchiveReport(const string reportId);
    bool EmailReport(const string reportId, const string recipients[]);
    
    // Batch operations
    bool GenerateBatchReports(const SReportData& data[], const string fileNames[]);
    bool ScheduleReport(const SReportData& data, datetime scheduleTime);
    bool GenerateComparison(const SReportData& data1, const SReportData& data2, const string fileName);
    
    // Export/Import
    bool ExportConfiguration(const string filePath);
    bool ImportConfiguration(const string filePath);
    bool ExportReportList(const string filePath);
    
    // Chart management
    bool GenerateChart(const SReportData& data, ENUM_CHART_TYPE chartType, const string filePath);
    bool SetChartDimensions(int width, int height);
    bool SetChartColors(const string colors[]);
    bool AddWatermark(const string text);
    
    // Validation
    bool ValidateReportData(const SReportData& data);
    bool ValidateOutputPath(const string path);
    bool TestTemplate(ENUM_REPORT_TEMPLATE templateType);
    
    // Information getters
    SReportConfiguration GetConfiguration() const { return m_Config; }
    SReportStatistics GetStatistics() const { return m_Statistics; }
    int GetReportCount() const { return m_ReportCount; }
    datetime GetLastGeneration() const { return m_LastGeneration; }
    
    // Utility methods
    string GetReportTypeName(ENUM_REPORT_TYPE type);
    string GetReportFormatName(ENUM_REPORT_FORMAT format);
    string GetReportTemplateName(ENUM_REPORT_TEMPLATE templateType);
    string GetChartStyleName(ENUM_CHART_STYLE style);
    string GetSectionName(ENUM_REPORT_SECTION section);
    string GetStatusName(ENUM_REPORT_STATUS status);
    
    // Status
    bool IsInitialized() const { return m_bInitialized; }
    bool IsGenerating() const;
};

//+------------------------------------------------------------------+
//| Constructor                                                     |
//+------------------------------------------------------------------+
CReportGenerator::CReportGenerator() {
    m_pContext = NULL;
    m_ReportCount = 0;
    m_TemplateCount = 0;
    m_bInitialized = false;
    m_LastGeneration = 0;
    
    ZeroMemory(m_Config);
    ZeroMemory(m_Statistics);
    ZeroMemory(m_CurrentReport);
    
    // Set default configuration
    m_Config.Type = REPORT_TYPE_PERFORMANCE;
    m_Config.Format = REPORT_FORMAT_HTML;
    m_Config.Template = TEMPLATE_STANDARD;
    m_Config.Title = "Trading Performance Report";
    m_Config.Subtitle = "Generated by APEX Pullback EA";
    m_Config.Author = "APEX Trading System";
    m_Config.Company = "";
    m_Config.Logo = "";
    
    m_Config.SectionCount = 0;
    m_Config.IncludeCharts = true;
    m_Config.IncludeTables = true;
    m_Config.IncludeAppendix = false;
    
    m_Config.ChartStyle = CHART_STYLE_PROFESSIONAL;
    m_Config.ChartWidth = 800;
    m_Config.ChartHeight = 600;
    
    m_Config.OutputPath = "Reports";
    m_Config.FileName = "";
    m_Config.OpenAfterGeneration = false;
    m_Config.EmailAfterGeneration = false;
    
    m_Config.StartDate = 0;
    m_Config.EndDate = 0;
    
    m_Config.IncludeRawData = false;
    m_Config.CompressOutput = false;
    m_Config.Watermark = "";
    m_Config.IncludeDisclaimer = true;
    m_Config.CustomCSS = "";
    m_Config.CustomJS = "";
}

//+------------------------------------------------------------------+
//| Destructor                                                      |
//+------------------------------------------------------------------+
CReportGenerator::~CReportGenerator() {
    Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize report generator                                    |
//+------------------------------------------------------------------+
bool CReportGenerator::Initialize(EAContext* context) {
    if (context == NULL) {
        LogError("Invalid context provided");
        return false;
    }
    
    m_pContext = context;
    
    // Initialize arrays
    ArrayResize(m_Reports, 100);        // Support 100 reports
    ArrayResize(m_Templates, 20);       // Support 20 templates
    ArrayResize(m_Config.Sections, 20); // Support 20 sections
    ArrayResize(m_Config.ChartColors, 10); // Support 10 colors
    ArrayResize(m_Config.EmailRecipients, 10); // Support 10 recipients
    ArrayResize(m_Config.Symbols, 10);  // Support 10 symbols
    ArrayResize(m_Config.Timeframes, 10); // Support 10 timeframes
    
    m_ReportCount = 0;
    m_TemplateCount = 0;
    
    // Initialize statistics
    m_Statistics.TotalReports = 0;
    m_Statistics.SuccessfulReports = 0;
    m_Statistics.FailedReports = 0;
    m_Statistics.TotalGenerationTime = 0;
    m_Statistics.AverageGenerationTime = 0;
    m_Statistics.FastestGeneration = DBL_MAX;
    m_Statistics.SlowestGeneration = 0;
    m_Statistics.TotalFileSize = 0;
    m_Statistics.AverageFileSize = 0;
    m_Statistics.LargestFile = 0;
    m_Statistics.SmallestFile = INT_MAX;
    m_Statistics.LastErrorTime = 0;
    
    // Set default chart colors
    m_Config.ChartColors[0] = "#1f77b4"; // Blue
    m_Config.ChartColors[1] = "#ff7f0e"; // Orange
    m_Config.ChartColors[2] = "#2ca02c"; // Green
    m_Config.ChartColors[3] = "#d62728"; // Red
    m_Config.ChartColors[4] = "#9467bd"; // Purple
    
    // Create output directory if it doesn't exist
    if (!FolderCreate(m_Config.OutputPath)) {
        LogActivity("Output directory already exists or created: " + m_Config.OutputPath);
    }
    
    m_bInitialized = true;
    m_LastGeneration = TimeCurrent();
    
    LogActivity("Report generator initialized successfully");
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize report generator                                  |
//+------------------------------------------------------------------+
bool CReportGenerator::Deinitialize() {
    if (m_bInitialized) {
        // Clear arrays
        ArrayFree(m_Reports);
        ArrayFree(m_Templates);
        ArrayFree(m_Config.Sections);
        ArrayFree(m_Config.ChartColors);
        ArrayFree(m_Config.EmailRecipients);
        ArrayFree(m_Config.Symbols);
        ArrayFree(m_Config.Timeframes);
        
        m_ReportCount = 0;
        m_TemplateCount = 0;
        
        m_bInitialized = false;
        m_pContext = NULL;
        
        LogActivity("Report generator deinitialized");
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Configure report generator                                     |
//+------------------------------------------------------------------+
bool CReportGenerator::Configure(const SReportConfiguration& config) {
    m_Config = config;
    
    if (!ValidateConfiguration()) {
        LogError("Invalid configuration provided");
        return false;
    }
    
    // Create output directory if it doesn't exist
    if (m_Config.OutputPath != "" && !FolderCreate(m_Config.OutputPath)) {
        LogActivity("Output directory already exists or created: " + m_Config.OutputPath);
    }
    
    LogActivity("Report generator configured successfully");
    return true;
}

//+------------------------------------------------------------------+
//| Generate report                                                |
//+------------------------------------------------------------------+
bool CReportGenerator::GenerateReport(const SReportData& data) {
    string fileName = "";
    if (m_Config.FileName != "") {
        fileName = m_Config.FileName;
    } else {
        fileName = StringFormat("Report_%s_%d", 
                               TimeToString(TimeCurrent(), TIME_DATE), 
                               GetTickCount());
    }
    
    return GenerateReport(data, fileName);
}

bool CReportGenerator::GenerateReport(const SReportData& data, const string fileName) {
    if (!m_bInitialized) {
        LogError("Report generator not initialized");
        return false;
    }
    
    if (!ValidateReportData(data)) {
        LogError("Invalid report data provided");
        return false;
    }
    
    LogActivity("Generating report: " + fileName);
    
    datetime startTime = GetMicrosecondCount();
    
    // Initialize current report info
    ZeroMemory(m_CurrentReport);
    m_CurrentReport.ReportId = StringFormat("RPT_%d_%d", GetTickCount(), MathRand());
    m_CurrentReport.Type = m_Config.Type;
    m_CurrentReport.Format = m_Config.Format;
    m_CurrentReport.Status = REPORT_STATUS_GENERATING;
    m_CurrentReport.CreationTime = TimeCurrent();
    m_CurrentReport.Author = m_Config.Author;
    m_CurrentReport.Title = m_Config.Title;
    
    m_Statistics.TotalReports++;
    
    bool success = false;
    string filePath = m_Config.OutputPath + "\\" + fileName;
    
    // Generate report based on format
    switch (m_Config.Format) {
        case REPORT_FORMAT_HTML: {
            string htmlContent;
            if (GenerateHTML(data, htmlContent)) {
                int fileHandle = FileOpen(filePath + ".html", FILE_WRITE | FILE_TXT);
                if (fileHandle != INVALID_HANDLE) {
                    FileWriteString(fileHandle, htmlContent);
                    FileClose(fileHandle);
                    success = true;
                    m_CurrentReport.FilePath = filePath + ".html";
                }
            }
            break;
        }
        
        case REPORT_FORMAT_PDF:
            success = GeneratePDF(data, filePath + ".pdf");
            if (success) m_CurrentReport.FilePath = filePath + ".pdf";
            break;
            
        case REPORT_FORMAT_CSV:
            success = GenerateCSV(data, filePath + ".csv");
            if (success) m_CurrentReport.FilePath = filePath + ".csv";
            break;
            
        case REPORT_FORMAT_JSON: {
            string jsonContent;
            if (GenerateJSON(data, jsonContent)) {
                int fileHandle = FileOpen(filePath + ".json", FILE_WRITE | FILE_TXT);
                if (fileHandle != INVALID_HANDLE) {
                    FileWriteString(fileHandle, jsonContent);
                    FileClose(fileHandle);
                    success = true;
                    m_CurrentReport.FilePath = filePath + ".json";
                }
            }
            break;
        }
        
        case REPORT_FORMAT_EXCEL:
            success = GenerateExcel(data, filePath + ".xlsx");
            if (success) m_CurrentReport.FilePath = filePath + ".xlsx";
            break;
            
        default:
            LogError("Unsupported report format");
            break;
    }
    
    // Calculate generation time
    datetime endTime = GetMicrosecondCount();
    m_CurrentReport.GenerationTime = (double)(endTime - startTime) / 1000000.0; // Convert to seconds
    
    // Update report status
    if (success) {
        m_CurrentReport.Status = REPORT_STATUS_COMPLETED;
        m_CurrentReport.CompletionTime = TimeCurrent();
        
        // Get file size
        if (FileIsExist(m_CurrentReport.FilePath)) {
            // Placeholder for file size calculation
            m_CurrentReport.FileSize = 1024; // Placeholder
        }
        
        // Store report info
        if (m_ReportCount < ArraySize(m_Reports)) {
            m_Reports[m_ReportCount] = m_CurrentReport;
            m_ReportCount++;
        }
        
        // Update statistics
        m_Statistics.SuccessfulReports++;
        m_Statistics.TotalGenerationTime += m_CurrentReport.GenerationTime;
        m_Statistics.AverageGenerationTime = m_Statistics.TotalGenerationTime / m_Statistics.SuccessfulReports;
        
        if (m_CurrentReport.GenerationTime < m_Statistics.FastestGeneration) {
            m_Statistics.FastestGeneration = m_CurrentReport.GenerationTime;
        }
        if (m_CurrentReport.GenerationTime > m_Statistics.SlowestGeneration) {
            m_Statistics.SlowestGeneration = m_CurrentReport.GenerationTime;
        }
        
        // Update format statistics
        switch (m_Config.Format) {
            case REPORT_FORMAT_HTML: m_Statistics.HTMLReports++; break;
            case REPORT_FORMAT_PDF: m_Statistics.PDFReports++; break;
            case REPORT_FORMAT_CSV: m_Statistics.CSVReports++; break;
            case REPORT_FORMAT_JSON: m_Statistics.JSONReports++; break;
            case REPORT_FORMAT_EXCEL: m_Statistics.ExcelReports++; break;
        }
        
        LogActivity(StringFormat("Report generated successfully: %s (%.2f seconds)", 
                                m_CurrentReport.FilePath, m_CurrentReport.GenerationTime));
        
        // Open report if requested
        if (m_Config.OpenAfterGeneration) {
            // Placeholder for opening report
            LogActivity("Opening report: " + m_CurrentReport.FilePath);
        }
        
        // Email report if requested
        if (m_Config.EmailAfterGeneration && ArraySize(m_Config.EmailRecipients) > 0) {
            EmailReport(m_CurrentReport.ReportId, m_Config.EmailRecipients);
        }
    } else {
        m_CurrentReport.Status = REPORT_STATUS_FAILED;
        m_CurrentReport.ErrorMessage = "Report generation failed";
        m_Statistics.FailedReports++;
        LogError("Failed to generate report: " + fileName);
    }
    
    m_LastGeneration = TimeCurrent();
    return success;
}

//+------------------------------------------------------------------+
//| Generate HTML report                                           |
//+------------------------------------------------------------------+
bool CReportGenerator::GenerateHTML(const SReportData& data, string& output) {
    output = "";
    
    // HTML header
    output += "<!DOCTYPE html>\n";
    output += "<html lang='en'>\n";
    output += "<head>\n";
    output += "    <meta charset='UTF-8'>\n";
    output += "    <meta name='viewport' content='width=device-width, initial-scale=1.0'>\n";
    output += "    <title>" + EscapeHTML(m_Config.Title) + "</title>\n";
    
    // CSS styles
    output += "    <style>\n";
    output += "        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }\n";
    output += "        .container { max-width: 1200px; margin: 0 auto; background-color: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }\n";
    output += "        .header { text-align: center; border-bottom: 2px solid #333; padding-bottom: 20px; margin-bottom: 30px; }\n";
    output += "        .title { font-size: 28px; font-weight: bold; color: #333; margin-bottom: 10px; }\n";
    output += "        .subtitle { font-size: 16px; color: #666; }\n";
    output += "        .section { margin-bottom: 30px; }\n";
    output += "        .section-title { font-size: 20px; font-weight: bold; color: #333; border-bottom: 1px solid #ddd; padding-bottom: 10px; margin-bottom: 15px; }\n";
    output += "        .metric-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 15px; margin-bottom: 20px; }\n";
    output += "        .metric-card { background-color: #f8f9fa; border: 1px solid #e9ecef; border-radius: 6px; padding: 15px; }\n";
    output += "        .metric-label { font-size: 14px; color: #666; margin-bottom: 5px; }\n";
    output += "        .metric-value { font-size: 24px; font-weight: bold; color: #333; }\n";
    output += "        .positive { color: #28a745; }\n";
    output += "        .negative { color: #dc3545; }\n";
    output += "        .table { width: 100%; border-collapse: collapse; margin-top: 15px; }\n";
    output += "        .table th, .table td { border: 1px solid #ddd; padding: 8px; text-align: left; }\n";
    output += "        .table th { background-color: #f8f9fa; font-weight: bold; }\n";
    output += "        .footer { text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; color: #666; font-size: 12px; }\n";
    
    if (m_Config.CustomCSS != "") {
        output += m_Config.CustomCSS + "\n";
    }
    
    output += "    </style>\n";
    output += "</head>\n";
    output += "<body>\n";
    
    // Report container
    output += "<div class='container'>\n";
    
    // Header
    output += "<div class='header'>\n";
    if (m_Config.Logo != "") {
        output += "<img src='" + m_Config.Logo + "' alt='Logo' style='max-height: 60px; margin-bottom: 15px;'>\n";
    }
    output += "<div class='title'>" + EscapeHTML(m_Config.Title) + "</div>\n";
    if (m_Config.Subtitle != "") {
        output += "<div class='subtitle'>" + EscapeHTML(m_Config.Subtitle) + "</div>\n";
    }
    output += "<div style='margin-top: 15px; color: #666; font-size: 14px;'>\n";
    output += "Generated on " + FormatDate(TimeCurrent()) + " by " + EscapeHTML(m_Config.Author) + "\n";
    output += "</div>\n";
    output += "</div>\n";
    
    // Executive Summary
    output += "<div class='section'>\n";
    output += "<div class='section-title'>Executive Summary</div>\n";
    output += GenerateExecutiveSummary(data);
    output += "</div>\n";
    
    // Performance Overview
    output += "<div class='section'>\n";
    output += "<div class='section-title'>Performance Overview</div>\n";
    output += GeneratePerformanceOverview(data);
    output += "</div>\n";
    
    // Risk Analysis
    output += "<div class='section'>\n";
    output += "<div class='section-title'>Risk Analysis</div>\n";
    output += GenerateRiskAnalysis(data);
    output += "</div>\n";
    
    // Trade Statistics
    output += "<div class='section'>\n";
    output += "<div class='section-title'>Trade Statistics</div>\n";
    output += GenerateTradeStatistics(data);
    output += "</div>\n";
    
    // Drawdown Analysis
    if (ArraySize(data.DrawdownValues) > 0) {
        output += "<div class='section'>\n";
        output += "<div class='section-title'>Drawdown Analysis</div>\n";
        output += GenerateDrawdownAnalysis(data);
        output += "</div>\n";
    }
    
    // Recommendations
    if (ArraySize(data.Recommendations) > 0) {
        output += "<div class='section'>\n";
        output += "<div class='section-title'>Recommendations</div>\n";
        output += GenerateRecommendations(data);
        output += "</div>\n";
    }
    
    // Disclaimer
    if (m_Config.IncludeDisclaimer) {
        output += "<div class='section'>\n";
        output += "<div class='section-title'>Disclaimer</div>\n";
        output += "<p style='font-size: 12px; color: #666; line-height: 1.5;'>\n";
        output += "This report is for informational purposes only and does not constitute investment advice. ";
        output += "Past performance is not indicative of future results. Trading involves substantial risk of loss ";
        output += "and is not suitable for all investors. Please consult with a qualified financial advisor before making any investment decisions.\n";
        output += "</p>\n";
        output += "</div>\n";
    }
    
    // Footer
    output += "<div class='footer'>\n";
    output += "Report generated by APEX Pullback EA v14.0<br>\n";
    output += "© 2024 APEX Trading Systems. All rights reserved.\n";
    if (m_Config.Watermark != "") {
        output += "<br>" + EscapeHTML(m_Config.Watermark);
    }
    output += "</div>\n";
    
    output += "</div>\n"; // Close container
    
    // Custom JavaScript
    if (m_Config.CustomJS != "") {
        output += "<script>\n" + m_Config.CustomJS + "\n</script>\n";
    }
    
    output += "</body>\n";
    output += "</html>\n";
    
    return true;
}

//+------------------------------------------------------------------+
//| Generate executive summary                                     |
//+------------------------------------------------------------------+
string CReportGenerator::GenerateExecutiveSummary(const SReportData& data) {
    string summary = "";
    
    summary += "<div class='metric-grid'>\n";
    
    // Total Return
    string returnClass = (data.TotalReturn >= 0) ? "positive" : "negative";
    summary += "<div class='metric-card'>\n";
    summary += "<div class='metric-label'>Total Return</div>\n";
    summary += "<div class='metric-value " + returnClass + "'>" + FormatPercentage(data.TotalReturn) + "</div>\n";
    summary += "</div>\n";
    
    // Annualized Return
    returnClass = (data.AnnualizedReturn >= 0) ? "positive" : "negative";
    summary += "<div class='metric-card'>\n";
    summary += "<div class='metric-label'>Annualized Return</div>\n";
    summary += "<div class='metric-value " + returnClass + "'>" + FormatPercentage(data.AnnualizedReturn) + "</div>\n";
    summary += "</div>\n";
    
    // Sharpe Ratio
    returnClass = (data.SharpeRatio >= 1.0) ? "positive" : (data.SharpeRatio >= 0) ? "" : "negative";
    summary += "<div class='metric-card'>\n";
    summary += "<div class='metric-label'>Sharpe Ratio</div>\n";
    summary += "<div class='metric-value " + returnClass + "'>" + FormatNumber(data.SharpeRatio) + "</div>\n";
    summary += "</div>\n";
    
    // Maximum Drawdown
    summary += "<div class='metric-card'>\n";
    summary += "<div class='metric-label'>Maximum Drawdown</div>\n";
    summary += "<div class='metric-value negative'>" + FormatPercentage(data.MaxDrawdown) + "</div>\n";
    summary += "</div>\n";
    
    // Win Rate
    returnClass = (data.WinRate >= 50) ? "positive" : "negative";
    summary += "<div class='metric-card'>\n";
    summary += "<div class='metric-label'>Win Rate</div>\n";
    summary += "<div class='metric-value " + returnClass + "'>" + FormatPercentage(data.WinRate) + "</div>\n";
    summary += "</div>\n";
    
    // Total Trades
    summary += "<div class='metric-card'>\n";
    summary += "<div class='metric-label'>Total Trades</div>\n";
    summary += "<div class='metric-value'>" + IntegerToString(data.TotalTrades) + "</div>\n";
    summary += "</div>\n";
    
    summary += "</div>\n";
    
    return summary;
}

//+------------------------------------------------------------------+
//| Generate performance overview                                  |
//+------------------------------------------------------------------+
string CReportGenerator::GeneratePerformanceOverview(const SReportData& data) {
    string overview = "";
    
    overview += GeneratePerformanceTable(data);
    
    return overview;
}

//+------------------------------------------------------------------+
//| Generate performance table                                     |
//+------------------------------------------------------------------+
string CReportGenerator::GeneratePerformanceTable(const SReportData& data) {
    string table = "";
    
    table += "<table class='table'>\n";
    table += "<thead>\n";
    table += "<tr><th>Metric</th><th>Value</th></tr>\n";
    table += "</thead>\n";
    table += "<tbody>\n";
    
    table += "<tr><td>Total Return</td><td>" + FormatPercentage(data.TotalReturn) + "</td></tr>\n";
    table += "<tr><td>Annualized Return</td><td>" + FormatPercentage(data.AnnualizedReturn) + "</td></tr>\n";
    table += "<tr><td>Volatility</td><td>" + FormatPercentage(data.Volatility) + "</td></tr>\n";
    table += "<tr><td>Sharpe Ratio</td><td>" + FormatNumber(data.SharpeRatio) + "</td></tr>\n";
    table += "<tr><td>Maximum Drawdown</td><td>" + FormatPercentage(data.MaxDrawdown) + "</td></tr>\n";
    table += "<tr><td>Calmar Ratio</td><td>" + FormatNumber(data.CalmarRatio) + "</td></tr>\n";
    
    table += "</tbody>\n";
    table += "</table>\n";
    
    return table;
}

//+------------------------------------------------------------------+
//| Generate risk analysis                                         |
//+------------------------------------------------------------------+
string CReportGenerator::GenerateRiskAnalysis(const SReportData& data) {
    string analysis = "";
    
    analysis += "<div class='metric-grid'>\n";
    
    // VaR 95%
    analysis += "<div class='metric-card'>\n";
    analysis += "<div class='metric-label'>Value at Risk (95%)</div>\n";
    analysis += "<div class='metric-value negative'>" + FormatPercentage(data.VaR95) + "</div>\n";
    analysis += "</div>\n";
    
    // CVaR 95%
    analysis += "<div class='metric-card'>\n";
    analysis += "<div class='metric-label'>Conditional VaR (95%)</div>\n";
    analysis += "<div class='metric-value negative'>" + FormatPercentage(data.CVaR95) + "</div>\n";
    analysis += "</div>\n";
    
    // Beta
    analysis += "<div class='metric-card'>\n";
    analysis += "<div class='metric-label'>Beta to Market</div>\n";
    analysis += "<div class='metric-value'>" + FormatNumber(data.BetaToMarket) + "</div>\n";
    analysis += "</div>\n";
    
    // Alpha
    string alphaClass = (data.AlphaToMarket >= 0) ? "positive" : "negative";
    analysis += "<div class='metric-card'>\n";
    analysis += "<div class='metric-label'>Alpha to Market</div>\n";
    analysis += "<div class='metric-value " + alphaClass + "'>" + FormatPercentage(data.AlphaToMarket) + "</div>\n";
    analysis += "</div>\n";
    
    analysis += "</div>\n";
    
    return analysis;
}

//+------------------------------------------------------------------+
//| Generate trade statistics                                      |
//+------------------------------------------------------------------+
string CReportGenerator::GenerateTradeStatistics(const SReportData& data) {
    string stats = "";
    
    stats += GenerateTradeTable(data);
    
    return stats;
}

//+------------------------------------------------------------------+
//| Generate trade table                                           |
//+------------------------------------------------------------------+
string CReportGenerator::GenerateTradeTable(const SReportData& data) {
    string table = "";
    
    table += "<table class='table'>\n";
    table += "<thead>\n";
    table += "<tr><th>Metric</th><th>Value</th></tr>\n";
    table += "</thead>\n";
    table += "<tbody>\n";
    
    table += "<tr><td>Total Trades</td><td>" + IntegerToString(data.TotalTrades) + "</td></tr>\n";
    table += "<tr><td>Winning Trades</td><td>" + IntegerToString(data.WinningTrades) + "</td></tr>\n";
    table += "<tr><td>Losing Trades</td><td>" + IntegerToString(data.LosingTrades) + "</td></tr>\n";
    table += "<tr><td>Win Rate</td><td>" + FormatPercentage(data.WinRate) + "</td></tr>\n";
    table += "<tr><td>Profit Factor</td><td>" + FormatNumber(data.ProfitFactor) + "</td></tr>\n";
    table += "<tr><td>Average Win</td><td>" + FormatPercentage(data.AverageWin) + "</td></tr>\n";
    table += "<tr><td>Average Loss</td><td>" + FormatPercentage(data.AverageLoss) + "</td></tr>\n";
    
    table += "</tbody>\n";
    table += "</table>\n";
    
    return table;
}

//+------------------------------------------------------------------+
//| Generate drawdown analysis                                     |
//+------------------------------------------------------------------+
string CReportGenerator::GenerateDrawdownAnalysis(const SReportData& data) {
    string analysis = "";
    
    analysis += "<p>Drawdown analysis shows the peak-to-trough decline in portfolio value.</p>\n";
    
    return analysis;
}

//+------------------------------------------------------------------+
//| Generate recommendations                                        |
//+------------------------------------------------------------------+
string CReportGenerator::GenerateRecommendations(const SReportData& data) {
    string recommendations = "";
    
    recommendations += "<ul>\n";
    for (int i = 0; i < ArraySize(data.Recommendations); i++) {
        recommendations += "<li>" + EscapeHTML(data.Recommendations[i]) + "</li>\n";
    }
    recommendations += "</ul>\n";
    
    return recommendations;
}

//+------------------------------------------------------------------+
//| Generate CSV report                                            |
//+------------------------------------------------------------------+
bool CReportGenerator::GenerateCSV(const SReportData& data, const string filePath) {
    int fileHandle = FileOpen(filePath, FILE_WRITE | FILE_CSV);
    if (fileHandle == INVALID_HANDLE) {
        LogError("Failed to create CSV file: " + filePath);
        return false;
    }
    
    // Write header
    FileWrite(fileHandle, "Metric", "Value");
    
    // Write performance metrics
    FileWrite(fileHandle, "Total Return (%)", data.TotalReturn);
    FileWrite(fileHandle, "Annualized Return (%)", data.AnnualizedReturn);
    FileWrite(fileHandle, "Volatility (%)", data.Volatility);
    FileWrite(fileHandle, "Sharpe Ratio", data.SharpeRatio);
    FileWrite(fileHandle, "Maximum Drawdown (%)", data.MaxDrawdown);
    FileWrite(fileHandle, "Calmar Ratio", data.CalmarRatio);
    
    // Write trade metrics
    FileWrite(fileHandle, "Total Trades", data.TotalTrades);
    FileWrite(fileHandle, "Winning Trades", data.WinningTrades);
    FileWrite(fileHandle, "Losing Trades", data.LosingTrades);
    FileWrite(fileHandle, "Win Rate (%)", data.WinRate);
    FileWrite(fileHandle, "Profit Factor", data.ProfitFactor);
    FileWrite(fileHandle, "Average Win (%)", data.AverageWin);
    FileWrite(fileHandle, "Average Loss (%)", data.AverageLoss);
    
    // Write risk metrics
    FileWrite(fileHandle, "VaR 95% (%)", data.VaR95);
    FileWrite(fileHandle, "CVaR 95% (%)", data.CVaR95);
    FileWrite(fileHandle, "Beta to Market", data.BetaToMarket);
    FileWrite(fileHandle, "Alpha to Market (%)", data.AlphaToMarket);
    FileWrite(fileHandle, "Tracking Error (%)", data.TrackingError);
    
    FileClose(fileHandle);
    
    LogActivity("CSV report generated: " + filePath);
    return true;
}

//+------------------------------------------------------------------+
//| Generate JSON report                                           |
//+------------------------------------------------------------------+
bool CReportGenerator::GenerateJSON(const SReportData& data, string& output) {
    output = "{\n";
    output += "  \"report\": {\n";
    output += "    \"title\": \"" + m_Config.Title + "\",\n";
    output += "    \"generated\": \"" + FormatDate(TimeCurrent()) + "\",\n";
    output += "    \"author\": \"" + m_Config.Author + "\",\n";
    
    output += "    \"performance\": {\n";
    output += "      \"totalReturn\": " + DoubleToString(data.TotalReturn, 2) + ",\n";
    output += "      \"annualizedReturn\": " + DoubleToString(data.AnnualizedReturn, 2) + ",\n";
    output += "      \"volatility\": " + DoubleToString(data.Volatility, 2) + ",\n";
    output += "      \"sharpeRatio\": " + DoubleToString(data.SharpeRatio, 2) + ",\n";
    output += "      \"maxDrawdown\": " + DoubleToString(data.MaxDrawdown, 2) + ",\n";
    output += "      \"calmarRatio\": " + DoubleToString(data.CalmarRatio, 2) + "\n";
    output += "    },\n";
    
    output += "    \"trades\": {\n";
    output += "      \"totalTrades\": " + IntegerToString(data.TotalTrades) + ",\n";
    output += "      \"winningTrades\": " + IntegerToString(data.WinningTrades) + ",\n";
    output += "      \"losingTrades\": " + IntegerToString(data.LosingTrades) + ",\n";
    output += "      \"winRate\": " + DoubleToString(data.WinRate, 2) + ",\n";
    output += "      \"profitFactor\": " + DoubleToString(data.ProfitFactor, 2) + ",\n";
    output += "      \"averageWin\": " + DoubleToString(data.AverageWin, 2) + ",\n";
    output += "      \"averageLoss\": " + DoubleToString(data.AverageLoss, 2) + "\n";
    output += "    },\n";
    
    output += "    \"risk\": {\n";
    output += "      \"var95\": " + DoubleToString(data.VaR95, 2) + ",\n";
    output += "      \"cvar95\": " + DoubleToString(data.CVaR95, 2) + ",\n";
    output += "      \"betaToMarket\": " + DoubleToString(data.BetaToMarket, 2) + ",\n";
    output += "      \"alphaToMarket\": " + DoubleToString(data.AlphaToMarket, 2) + ",\n";
    output += "      \"trackingError\": " + DoubleToString(data.TrackingError, 2) + "\n";
    output += "    }\n";
    
    output += "  }\n";
    output += "}\n";
    
    return true;
}

//+------------------------------------------------------------------+
//| Validate configuration                                         |
//+------------------------------------------------------------------+
bool CReportGenerator::ValidateConfiguration() {
    if (m_Config.Title == "") {
        LogError("Report title cannot be empty");
        return false;
    }
    
    if (m_Config.OutputPath == "") {
        LogError("Output path cannot be empty");
        return false;
    }
    
    if (m_Config.ChartWidth <= 0 || m_Config.ChartHeight <= 0) {
        LogError("Invalid chart dimensions");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Validate report data                                           |
//+------------------------------------------------------------------+
bool CReportGenerator::ValidateReportData(const SReportData& data) {
    if (data.TotalTrades < 0) {
        LogError("Invalid total trades count");
        return false;
    }
    
    if (data.WinningTrades + data.LosingTrades > data.TotalTrades) {
        LogError("Inconsistent trade counts");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Format number                                                  |
//+------------------------------------------------------------------+
string CReportGenerator::FormatNumber(double value, int decimals = 2) {
    return DoubleToString(value, decimals);
}

//+------------------------------------------------------------------+
//| Format percentage                                              |
//+------------------------------------------------------------------+
string CReportGenerator::FormatPercentage(double value, int decimals = 2) {
    return DoubleToString(value, decimals) + "%";
}

//+------------------------------------------------------------------+
//| Format date                                                    |
//+------------------------------------------------------------------+
string CReportGenerator::FormatDate(datetime time) {
    return TimeToString(time, TIME_DATE | TIME_MINUTES);
}

//+------------------------------------------------------------------+
//| Escape HTML                                                    |
//+------------------------------------------------------------------+
string CReportGenerator::EscapeHTML(const string text) {
    string result = text;
    StringReplace(result, "&", "&amp;");
    StringReplace(result, "<", "&lt;");
    StringReplace(result, ">", "&gt;");
    StringReplace(result, "\"", "&quot;");
    StringReplace(result, "'", "&#39;");
    return result;
}

//+------------------------------------------------------------------+
//| Get report type name                                           |
//+------------------------------------------------------------------+
string CReportGenerator::GetReportTypeName(ENUM_REPORT_TYPE type) {
    switch (type) {
        case REPORT_TYPE_PERFORMANCE: return "Performance Report";
        case REPORT_TYPE_RISK: return "Risk Analysis Report";
        case REPORT_TYPE_TRADE_ANALYSIS: return "Trade Analysis Report";
        case REPORT_TYPE_OPTIMIZATION: return "Optimization Report";
        case REPORT_TYPE_BACKTEST: return "Backtest Report";
        case REPORT_TYPE_WALK_FORWARD: return "Walk-Forward Report";
        case REPORT_TYPE_MONTE_CARLO: return "Monte Carlo Report";
        case REPORT_TYPE_STRESS_TEST: return "Stress Test Report";
        case REPORT_TYPE_PORTFOLIO: return "Portfolio Report";
        case REPORT_TYPE_BENCHMARK: return "Benchmark Comparison";
        case REPORT_TYPE_SUMMARY: return "Executive Summary";
        case REPORT_TYPE_DETAILED: return "Detailed Analysis";
        case REPORT_TYPE_CUSTOM: return "Custom Report";
        default: return "Unknown";
    }
}

//+------------------------------------------------------------------+
//| Log error message                                              |
//+------------------------------------------------------------------+
void CReportGenerator::LogError(const string message) {
    if (m_pContext != NULL && m_pContext.Logger != NULL) {
        m_pContext.Logger.LogError("ReportGenerator", message);
    }
    
    m_Statistics.TotalErrors++;
    m_Statistics.LastError = message;
    m_Statistics.LastErrorTime = TimeCurrent();
    
    Print("[ReportGenerator ERROR] " + message);
}

//+------------------------------------------------------------------+
//| Log activity message                                            |
//+------------------------------------------------------------------+
void CReportGenerator::LogActivity(const string message) {
    if (m_pContext != NULL && m_pContext.Logger != NULL) {
        m_pContext.Logger.LogInfo("ReportGenerator", message);
    }
    
    Print("[ReportGenerator] " + message);
}

//+------------------------------------------------------------------+
//| Set report type                                                |
//+------------------------------------------------------------------+
bool CReportGenerator::SetReportType(ENUM_REPORT_TYPE type) {
    m_Config.Type = type;
    LogActivity("Report type set to: " + GetReportTypeName(type));
    return true;
}

//+------------------------------------------------------------------+
//| Set report format                                              |
//+------------------------------------------------------------------+
bool CReportGenerator::SetReportFormat(ENUM_REPORT_FORMAT format) {
    m_Config.Format = format;
    LogActivity("Report format set to: " + GetReportFormatName(format));
    return true;
}

//+------------------------------------------------------------------+
//| Get report format name                                         |
//+------------------------------------------------------------------+
string CReportGenerator::GetReportFormatName(ENUM_REPORT_FORMAT format) {
    switch (format) {
        case REPORT_FORMAT_HTML: return "HTML";
        case REPORT_FORMAT_PDF: return "PDF";
        case REPORT_FORMAT_CSV: return "CSV";
        case REPORT_FORMAT_JSON: return "JSON";
        case REPORT_FORMAT_XML: return "XML";
        case REPORT_FORMAT_EXCEL: return "Excel";
        case REPORT_FORMAT_TEXT: return "Text";
        case REPORT_FORMAT_MARKDOWN: return "Markdown";
        default: return "Unknown";
    }
}

//+------------------------------------------------------------------+
//| Generate PDF report (placeholder)                              |
//+------------------------------------------------------------------+
bool CReportGenerator::GeneratePDF(const SReportData& data, const string filePath) {
    // Placeholder implementation
    LogActivity("PDF generation not implemented yet: " + filePath);
    return false;
}

//+------------------------------------------------------------------+
//| Generate Excel report (placeholder)                            |
//+------------------------------------------------------------------+
bool CReportGenerator::GenerateExcel(const SReportData& data, const string filePath) {
    // Placeholder implementation
    LogActivity("Excel generation not implemented yet: " + filePath);
    return false;
}

//+------------------------------------------------------------------+
//| Is generating report                                           |
//+------------------------------------------------------------------+
bool CReportGenerator::IsGenerating() const {
    return (m_CurrentReport.Status == REPORT_STATUS_GENERATING);
}

//+------------------------------------------------------------------+
//| Email report (placeholder)                                     |
//+------------------------------------------------------------------+
bool CReportGenerator::EmailReport(const string reportId, const string recipients[]) {
    LogActivity("Email functionality not implemented yet for report: " + reportId);
    return false;
}

//+------------------------------------------------------------------+
//| Get all reports                                                |
//+------------------------------------------------------------------+
bool CReportGenerator::GetAllReports(SReportInfo& reports[]) {
    ArrayResize(reports, m_ReportCount);
    for (int i = 0; i < m_ReportCount; i++) {
        reports[i] = m_Reports[i];
    }
    return true;
}

//+------------------------------------------------------------------+
//| Get report info                                                |
//+------------------------------------------------------------------+
bool CReportGenerator::GetReportInfo(const string reportId, SReportInfo& info) {
    for (int i = 0; i < m_ReportCount; i++) {
        if (m_Reports[i].ReportId == reportId) {
            info = m_Reports[i];
            return true;
        }
    }
    return false;
}

//+------------------------------------------------------------------+
//| Additional placeholder methods                                 |
//+------------------------------------------------------------------+
bool CReportGenerator::SetReportTemplate(ENUM_REPORT_TEMPLATE templateType) {
    m_Config.Template = templateType;
    return true;
}

bool CReportGenerator::SetOutputPath(const string path) {
    m_Config.OutputPath = path;
    return FolderCreate(path);
}

bool CReportGenerator::SetChartStyle(ENUM_CHART_STYLE style) {
    m_Config.ChartStyle = style;
    return true;
}

bool CReportGenerator::AddSection(const SReportSection& section) {
    if (m_Config.SectionCount < ArraySize(m_Config.Sections)) {
        m_Config.Sections[m_Config.SectionCount] = section;
        m_Config.SectionCount++;
        return true;
    }
    return false;
}

bool CReportGenerator::RemoveSection(ENUM_REPORT_SECTION sectionType) {
    // Placeholder implementation
    return true;
}

bool CReportGenerator::EnableSection(ENUM_REPORT_SECTION sectionType, bool enable = true) {
    // Placeholder implementation
    return true;
}

bool CReportGenerator::LoadCustomTemplate(const string templatePath) {
    // Placeholder implementation
    return true;
}

bool CReportGenerator::SaveTemplate(const string templatePath) {
    // Placeholder implementation
    return true;
}

bool CReportGenerator::GetAvailableTemplates(string& templates[]) {
    // Placeholder implementation
    return true;
}

bool CReportGenerator::SetCustomCSS(const string css) {
    m_Config.CustomCSS = css;
    return true;
}

bool CReportGenerator::SetCustomJS(const string js) {
    m_Config.CustomJS = js;
    return true;
}

bool CReportGenerator::DeleteReport(const string reportId) {
    // Placeholder implementation
    return true;
}

bool CReportGenerator::ArchiveReport(const string reportId) {
    // Placeholder implementation
    return true;
}

bool CReportGenerator::GenerateBatchReports(const SReportData& data[], const string fileNames[]) {
    // Placeholder implementation
    return true;
}

bool CReportGenerator::ScheduleReport(const SReportData& data, datetime scheduleTime) {
    // Placeholder implementation
    return true;
}

bool CReportGenerator::GenerateComparison(const SReportData& data1, const SReportData& data2, const string fileName) {
    // Placeholder implementation
    return true;
}

bool CReportGenerator::ExportConfiguration(const string filePath) {
    // Placeholder implementation
    return true;
}

bool CReportGenerator::ImportConfiguration(const string filePath) {
    // Placeholder implementation
    return true;
}

bool CReportGenerator::ExportReportList(const string filePath) {
    // Placeholder implementation
    return true;
}

bool CReportGenerator::GenerateChart(const SReportData& data, ENUM_CHART_TYPE chartType, const string filePath) {
    // Placeholder implementation
    return true;
}

bool CReportGenerator::SetChartDimensions(int width, int height) {
    m_Config.ChartWidth = width;
    m_Config.ChartHeight = height;
    return true;
}

bool CReportGenerator::SetChartColors(const string colors[]) {
    int size = MathMin(ArraySize(colors), ArraySize(m_Config.ChartColors));
    for (int i = 0; i < size; i++) {
        m_Config.ChartColors[i] = colors[i];
    }
    return true;
}

bool CReportGenerator::AddWatermark(const string text) {
    m_Config.Watermark = text;
    return true;
}

bool CReportGenerator::ValidateOutputPath(const string path) {
    return (path != "");
}

bool CReportGenerator::TestTemplate(ENUM_REPORT_TEMPLATE templateType) {
    // Placeholder implementation
    return true;
}

bool CReportGenerator::GenerateCustomReport(const SReportData& data, const SReportSection& sections[]) {
    // Placeholder implementation
    return true;
}

bool CReportGenerator::RegenerateReport(const string reportId) {
    // Placeholder implementation
    return true;
}

string CReportGenerator::GetReportTemplateName(ENUM_REPORT_TEMPLATE templateType) {
    switch (templateType) {
        case TEMPLATE_STANDARD: return "Standard";
        case TEMPLATE_EXECUTIVE: return "Executive";
        case TEMPLATE_TECHNICAL: return "Technical";
        case TEMPLATE_REGULATORY: return "Regulatory";
        case TEMPLATE_INVESTOR: return "Investor";
        case TEMPLATE_ACADEMIC: return "Academic";
        case TEMPLATE_MINIMAL: return "Minimal";
        case TEMPLATE_COMPREHENSIVE: return "Comprehensive";
        case TEMPLATE_CUSTOM: return "Custom";
        default: return "Unknown";
    }
}

string CReportGenerator::GetChartStyleName(ENUM_CHART_STYLE style) {
    switch (style) {
        case CHART_STYLE_PROFESSIONAL: return "Professional";
        case CHART_STYLE_MODERN: return "Modern";
        case CHART_STYLE_CLASSIC: return "Classic";
        case CHART_STYLE_MINIMAL: return "Minimal";
        case CHART_STYLE_COLORFUL: return "Colorful";
        case CHART_STYLE_MONOCHROME: return "Monochrome";
        case CHART_STYLE_CUSTOM: return "Custom";
        default: return "Unknown";
    }
}

string CReportGenerator::GetSectionName(ENUM_REPORT_SECTION section) {
    switch (section) {
        case SECTION_EXECUTIVE_SUMMARY: return "Executive Summary";
        case SECTION_PERFORMANCE_OVERVIEW: return "Performance Overview";
        case SECTION_RISK_ANALYSIS: return "Risk Analysis";
        case SECTION_TRADE_STATISTICS: return "Trade Statistics";
        case SECTION_DRAWDOWN_ANALYSIS: return "Drawdown Analysis";
        case SECTION_BENCHMARK_COMPARISON: return "Benchmark Comparison";
        case SECTION_OPTIMIZATION_RESULTS: return "Optimization Results";
        case SECTION_BACKTEST_RESULTS: return "Backtest Results";
        case SECTION_WALK_FORWARD_RESULTS: return "Walk-Forward Results";
        case SECTION_MONTE_CARLO_RESULTS: return "Monte Carlo Results";
        case SECTION_STRESS_TEST_RESULTS: return "Stress Test Results";
        case SECTION_PORTFOLIO_ANALYSIS: return "Portfolio Analysis";
        case SECTION_RECOMMENDATIONS: return "Recommendations";
        case SECTION_APPENDIX: return "Appendix";
        case SECTION_CUSTOM: return "Custom";
        default: return "Unknown";
    }
}

string CReportGenerator::GetStatusName(ENUM_REPORT_STATUS status) {
    switch (status) {
        case REPORT_STATUS_PENDING: return "Pending";
        case REPORT_STATUS_GENERATING: return "Generating";
        case REPORT_STATUS_COMPLETED: return "Completed";
        case REPORT_STATUS_FAILED: return "Failed";
        case REPORT_STATUS_CANCELLED: return "Cancelled";
        case REPORT_STATUS_ARCHIVED: return "Archived";
        default: return "Unknown";
    }
}

// Additional helper methods (placeholders)
bool CReportGenerator::LoadTemplate(ENUM_REPORT_TEMPLATE templateType) { return true; }
bool CReportGenerator::GenerateEquityChart(const SReportData& data, const string filePath) { return true; }
bool CReportGenerator::GenerateDrawdownChart(const SReportData& data, const string filePath) { return true; }
bool CReportGenerator::GenerateMonthlyReturnsChart(const SReportData& data, const string filePath) { return true; }
bool CReportGenerator::GenerateRiskReturnChart(const SReportData& data, const string filePath) { return true; }
string CReportGenerator::GenerateRiskTable(const SReportData& data) { return ""; }
string CReportGenerator::GenerateMonthlyTable(const SReportData& data) { return ""; }
string CReportGenerator::GenerateBenchmarkComparison(const SReportData& data) { return ""; }
string CReportGenerator::EscapeCSV(const string text) { return text; }

//+------------------------------------------------------------------+