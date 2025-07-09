//+------------------------------------------------------------------+
//|                                          PortfolioManager.mqh |
//|                      APEX PULLBACK EA v14.0 - Professional Edition|
//|               Copyright 2023-2024, APEX Trading Systems           |
//+------------------------------------------------------------------+

#ifndef PORTFOLIOMANAGER_MQH
#define PORTFOLIOMANAGER_MQH

#include "CommonStructs.mqh" // For TradeProposal and EAContext



namespace ApexPullback {

//+------------------------------------------------------------------+
//| Class CPortfolioManager                                          |
//| Quản lý danh mục đầu tư tổng thể, ra quyết định giao dịch        |
//+------------------------------------------------------------------+
class CPortfolioManager
{
private:
    CLogger* m_Logger;
    CNewsFilter* m_NewsFilter; // Để kiểm tra sự kiện vĩ mô
    CPositionManager* m_PositionManager; // Để truy cập thông tin vị thế đang mở
    CRiskManager* m_RiskManager;         // Để truy cập thông tin rủi ro tổng thể
    CArrayObj m_TradeProposals;          // Dùng CArrayObj để lưu các đề xuất
    double m_CorrelationMatrix[28][28]; // Ma trận tương quan (ví dụ cho 28 cặp tiền chính)
    string m_SymbolIndexMap[28];        // Ánh xạ từ tên symbol sang chỉ số của ma trận
    // Thêm các thành viên khác sau này

    // Cấu hình
    double m_MaxTotalRisk; // % rủi ro tối đa cho toàn bộ danh mục
    double m_MaxCorrelationAllowed; // Ngưỡng tương quan tối đa cho phép
    // ... các cấu hình khác

    // Phương thức nội bộ
    void LoadProposals(); // Tải các đề xuất giao dịch (từ Global Variables hoặc file)
    void AnalyzeProposals(); // Phân tích chung (nếu có)
    ENUM_PORTFOLIO_DECISION DecideOnProposal(const TradeProposal &proposal); // Ra quyết định cho một đề xuất
    void WriteDecisionToGVs(const TradeProposal &proposal, ENUM_PORTFOLIO_DECISION decision, double adjustedLotFactor = 1.0); // Ghi quyết định vào Global Variables
    double CalculateTotalRisk(); // Tính tổng rủi ro hiện tại
    bool IsRiskConcentrated(const TradeProposal &proposal, double maxConcentration); // Kiểm tra tập trung rủi ro
    double GetCurrencyRiskExposure(const string currency); // Tính rủi ro cho một đồng tiền cụ thể

public:
    CPortfolioManager(CLogger* logger, CNewsFilter* newsFilter, CPositionManager* posManager, CRiskManager* riskManager);
    ~CPortfolioManager();

    bool Initialize(double maxTotalRisk, double maxCorrelation);
    void Deinitialize();

    void ProcessTradeProposals(); // Hàm chính để xử lý các đề xuất giao dịch

    // Các hàm getter/setter cho cấu hình nếu cần
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPortfolioManager::CPortfolioManager(CLogger* logger, CNewsFilter* newsFilter, CPositionManager* posManager, CRiskManager* riskManager)
{
    m_Logger = logger;
    m_NewsFilter = newsFilter;
    m_PositionManager = posManager;
    m_RiskManager = riskManager;
    m_TradeProposals.FreeMode(true); // Quan trọng: Cho phép CArrayObj tự xóa các con trỏ khi dọn dẹp
    m_MaxTotalRisk = 0.05; // Mặc định 5% tổng rủi ro
    m_MaxCorrelationAllowed = 0.7; // Mặc định tương quan 70%
    InitializeCorrelationMatrix(); // Khởi tạo ma trận tương quan
    if(m_Logger != NULL) m_Logger.LogInfo("CPortfolioManager: Instance created.");
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPortfolioManager::~CPortfolioManager()
{
    if(m_Logger != NULL) m_Logger.LogInfo("CPortfolioManager: Instance destroyed.");
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CPortfolioManager::Initialize(double maxTotalRisk, double maxCorrelation)
{
    m_MaxTotalRisk = maxTotalRisk;
    m_MaxCorrelationAllowed = maxCorrelation;

    if(m_Logger == NULL)
    {
        // Không thể ghi log nếu logger là NULL, nhưng đây là một kiểm tra quan trọng
        printf("CPortfolioManager Error: Logger is NULL during initialization.");
        return false;
    }
    if(m_NewsFilter == NULL)
    {
        m_Logger.LogError("CPortfolioManager: NewsFilter is NULL during initialization.");
        return false;
    }
    if(m_PositionManager == NULL)
    {
        m_Logger.LogError("CPortfolioManager: PositionManager is NULL during initialization.");
        return false;
    }
    if(m_RiskManager == NULL)
    {
        m_Logger.LogError("CPortfolioManager: RiskManager is NULL during initialization.");
        return false;
    }

    m_Logger.LogInfo("CPortfolioManager: Initialized successfully.");
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CPortfolioManager::Deinitialize()
{
    // Dọn dẹp tài nguyên nếu có
    m_TradeProposals.Clear(); // Xóa tất cả các đối tượng trong mảng và giải phóng bộ nhớ nếu cần
    if(m_Logger != NULL) m_Logger.LogInfo("CPortfolioManager: Deinitialized.");
}

//+------------------------------------------------------------------+
//| LoadProposals                                                    |
//+------------------------------------------------------------------+
// Method to load trade proposals from Global Variables
void CPortfolioManager::LoadProposals()
{
    if(m_Logger == NULL) {
        printf("CPortfolioManager Error: Logger is NULL in LoadProposals.");
        return;
    }
    m_Logger.LogInfo("CPortfolioManager: Loading trade proposals from GVs...");
    m_TradeProposals.Clear(); // Clear previous proposals

    // Iterate through GVs looking for proposals. 
    // Proposal GVs are expected to be named like: EAContext.GVProposalPrefix + Symbol + EAContext.GVProposalSuffix
    // e.g., "PM_Proposal_EURUSD_12345" where 12345 is the chart ID or magic number for uniqueness.
    // For simplicity, we'll scan for GVs starting with a known prefix.
    // A more robust system might involve slaves registering their proposal GV names.

    long chart_id = ChartID(); // Or some other unique identifier for this EA instance if needed.
    string base_gv_prefix = m_EAContext.Input.PortfolioManagement.GVProposalPrefix; // e.g., "PM_Proposal_"

    int total = GlobalVariablesTotal();
    int checked = 0;
    datetime last_cleanup_time = 0;
    string gv_name;

    for(int i = total - 1; i >= 0; i--) // Iterate backwards for safe deletion
    {
        gv_name = GlobalVariableName(i);
        if(StringFind(gv_name, base_gv_prefix, 0) == 0) // Check if GV name starts with our prefix
        {
            // Further check if it's a proposal GV and not a decision GV
            // Assuming proposal GVs don't contain the decision suffix, or have a specific format
            if(StringFind(gv_name, m_EAContext.Input.PortfolioManagement.GVDecisionSuffix, 0) == -1)
            {
                string gv_value_str = GlobalVariableGet(gv_name);
                datetime gv_set_time = GlobalVariableTime(gv_name);

                // Basic check for stale GVs (e.g., older than 5 minutes)
                if(gv_set_time > 0 && (TimeCurrent() - gv_set_time) > m_EAContext.Input.PortfolioManagement.GVProposalTimeoutSeconds) 
                {
                    m_Logger.LogWarningFormat("CPortfolioManager: Stale proposal GV '%s' found (age %d sec). Deleting.", 
                                            gv_name, TimeCurrent() - gv_set_time);
                    GlobalVariableDel(gv_name);
                    continue;
                }

                if(gv_value_str != "" && gv_value_str != "PROCESSING" && gv_value_str != "DELETING")
                {
                    // Mark as being processed to prevent other instances (if any) or quick re-reads
                    if(!GlobalVariableSet(gv_name, "PROCESSING"))
                    {
                        m_Logger.LogWarningFormat("CPortfolioManager: Failed to set GV '%s' to PROCESSING. Skipping.", gv_name);
                        continue;
                    }

                    TradeProposal* proposal = new TradeProposal(); // Create on heap for CArrayObj
                    if(proposal.FromString(gv_value_str))
                    {
                        // proposal.GVProposalName should be set by FromString if it's part of the string
                        // or we can set it here if it's not.
                        if(proposal.GVProposalName == "") proposal.GVProposalName = gv_name; 
                        // Construct decision GV name based on proposal's details
                        proposal.GVDecisionName = m_EAContext.Input.PortfolioManagement.GVDecisionPrefix + 
                                                  proposal.Symbol + "_" + 
                                                  IntegerToString(proposal.MagicNumber) + 
                                                  m_EAContext.Input.PortfolioManagement.GVDecisionSuffix;

                        m_TradeProposals.Add(proposal);
                        m_Logger.LogInfoFormat("CPortfolioManager: Loaded proposal from %s: [Symbol: %s, Type: %s, Risk: %.2f%%, Magic: %d, DecisionGV: %s]",
                                               gv_name, proposal.Symbol, EnumToString(proposal.OrderType), proposal.RiskPercent, proposal.MagicNumber, proposal.GVDecisionName);
                        
                        // Now that it's loaded and marked PROCESSING, we can delete the original proposal GV.
                        // The decision will be written to a *new* GV (proposal.GVDecisionName).
                        if(GlobalVariableDel(gv_name))
                        {
                            m_Logger.LogInfoFormat("CPortfolioManager: Cleared proposal GV %s after loading.", gv_name);
                        }
                        else
                        {
                            m_Logger.LogErrorFormat("CPortfolioManager: FAILED to clear proposal GV %s after loading. Error: %d", gv_name, GetLastError());
                        }
                    }
                    else
                    {
                        delete proposal; // Clean up if FromString failed
                        m_Logger.LogWarningFormat("CPortfolioManager: Failed to parse proposal from %s: %s. Deleting GV.", gv_name, gv_value_str);
                        GlobalVariableDel(gv_name); // Delete unparseable GV
                    }
                }
                else if (gv_value_str == "PROCESSING" || gv_value_str == "DELETING")
                {
                    // Potentially another master instance is handling it, or it's marked for deletion by slave.
                    // Add a timeout for these states as well to prevent stuck GVs.
                    if(gv_set_time > 0 && (TimeCurrent() - gv_set_time) > m_EAContext.Input.PortfolioManagement.GVProposalTimeoutSeconds * 2) // Longer timeout for processing/deleting states
                    {
                         m_Logger.LogWarningFormat("CPortfolioManager: Stale proposal GV '%s' in state '%s' (age %d sec). Deleting.", 
                                            gv_name, gv_value_str, TimeCurrent() - gv_set_time);
                        GlobalVariableDel(gv_name);
                    }
                }
            }
        }
        checked++;
        if(checked % 100 == 0) Sleep(1); // Small pause during large GV scan
    }
    m_Logger.LogInfoFormat("CPortfolioManager: Loaded %d proposals after scanning GVs.", m_TradeProposals.Total());
}

//+------------------------------------------------------------------+
//| InitializeCorrelationMatrix                                      |
//+------------------------------------------------------------------+
void CPortfolioManager::InitializeCorrelationMatrix(string filePath)
{
    if(m_Logger == NULL) {
        printf("CPortfolioManager Error: Logger is NULL in InitializeCorrelationMatrix.");
        return;
    }
    m_Logger.LogInfoFormat("CPortfolioManager: Initializing correlation matrix from '%s'...", filePath);

    m_SymbolIndexMap.Clear();
    m_CorrelationMatrix.Clear(); // Clear existing matrix data

    // TODO: Implement robust CSV loading for the correlation matrix.
    // The CSV should have symbols as headers for rows and columns.
    // Example CSV format:
    // Symbol,EURUSD,GBPUSD,USDJPY
    // EURUSD,1.0,0.7,-0.5
    // GBPUSD,0.7,1.0,-0.3
    // USDJPY,-0.5,-0.3,1.0

    if(filePath == "" || !FileIsExist(filePath, FILE_COMMON | FILE_READ)){
        m_Logger.LogWarningFormat("CPortfolioManager: Correlation matrix file '%s' not found or path is empty. Using placeholder data.", filePath);
        // Fallback to placeholder data if file not found
        string symbols[] = {"EURUSD", "GBPUSD", "USDJPY", "AUDUSD", "USDCAD", "NZDUSD", "EURJPY", "GBPJPY", "XAUUSD"};
        m_CorrelationMatrix.Resize(ArraySize(symbols), ArraySize(symbols));
        for(int i = 0; i < ArraySize(symbols); i++)
        {
            m_SymbolIndexMap.Set(symbols[i], i);
            for(int j = 0; j < ArraySize(symbols); j++)
            {
                if(i == j) m_CorrelationMatrix.Set(i, j, 1.0);
                else m_CorrelationMatrix.Set(i, j, 0.0); // Default to no correlation
            }
        }
        int idx_eurusd = GetSymbolIndex("EURUSD");
        int idx_gbpusd = GetSymbolIndex("GBPUSD");
        if(idx_eurusd != -1 && idx_gbpusd != -1) { m_CorrelationMatrix.Set(idx_eurusd, idx_gbpusd, 0.7); m_CorrelationMatrix.Set(idx_gbpusd, idx_eurusd, 0.7); }
        int idx_usdjpy = GetSymbolIndex("USDJPY");
        if(idx_eurusd != -1 && idx_usdjpy != -1) { m_CorrelationMatrix.Set(idx_eurusd, idx_usdjpy, -0.5); m_CorrelationMatrix.Set(idx_usdjpy, idx_eurusd, -0.5); }
        m_Logger.LogInfoFormat("CPortfolioManager: Correlation matrix initialized for %d symbols (placeholder data).", ArraySize(symbols));
        return;
    }

    // Actual CSV Loading Logic (Simplified example, needs robust error handling and parsing)
    int fileHandle = FileOpen(filePath, FILE_READ|FILE_CSV|FILE_ANSI, ',');
    if(fileHandle == INVALID_HANDLE)
    {
        m_Logger.LogErrorFormat("CPortfolioManager: Failed to open correlation matrix file '%s'. Error: %d", filePath, GetLastError());
        // Potentially fall back to placeholder or stop initialization
        return;
    }

    // Read header to get symbols
    CArrayString *headerSymbols = new CArrayString();
    string firstCell = FileReadString(fileHandle); // Skip first cell (e.g., "Symbol")
    while(!FileIsEnding(fileHandle) && !FileIsLineEnding(fileHandle))
    {
        headerSymbols.Add(FileReadString(fileHandle));
    }
    FileReadString(fileHandle); // Consume rest of the line ending

    if(headerSymbols.Total() == 0)
    {
        m_Logger.LogErrorFormat("CPortfolioManager: No symbols found in header of correlation matrix file '%s'.", filePath);
        FileClose(fileHandle);
        delete headerSymbols;
        return;
    }

    m_CorrelationMatrix.Resize(headerSymbols.Total(), headerSymbols.Total());
    for(int i=0; i<headerSymbols.Total(); i++)
    {
        m_SymbolIndexMap.Set(headerSymbols.At(i), i);
    }

    int row = 0;
    while(!FileIsEnding(fileHandle) && row < headerSymbols.Total())
    {
        string rowSymbol = FileReadString(fileHandle); // Read the symbol for the current row
        int rowIndex = GetSymbolIndex(rowSymbol);
        if(rowIndex == -1)
        {
            m_Logger.LogWarningFormat("CPortfolioManager: Symbol '%s' from matrix file not in header map. Skipping row.", rowSymbol);
            // Skip rest of the line
            while(!FileIsEnding(fileHandle) && !FileIsLineEnding(fileHandle)) FileReadString(fileHandle);
            FileReadString(fileHandle); // Consume line ending
            row++;
            continue;
        }

        for(int col = 0; col < headerSymbols.Total(); col++)
        {
            if(FileIsLineEnding(fileHandle) || FileIsEnding(fileHandle))
            {
                m_Logger.LogWarningFormat("CPortfolioManager: Unexpected end of line/file while reading correlations for %s. Row %d, Col %d", rowSymbol, row, col);
                break;
            }
            double val = FileReadDouble(fileHandle);
            m_CorrelationMatrix.Set(rowIndex, col, val); // Assuming columns in CSV match headerSymbols order
        }
        FileReadString(fileHandle); // Consume rest of the line ending if any
        row++;
    }

    FileClose(fileHandle);
    delete headerSymbols;
    m_Logger.LogInfoFormat("CPortfolioManager: Correlation matrix successfully loaded for %d symbols from '%s'.", m_SymbolIndexMap.Size(), filePath);
}

//+------------------------------------------------------------------+
//| GetSymbolIndex (Helper)                                          |
//+------------------------------------------------------------------+
int CPortfolioManager::GetSymbolIndex(const string symbol_name)
{
    for(int i=0; i < ArraySize(m_SymbolIndexMap); i++)
    {
        if(m_SymbolIndexMap[i] == symbol_name) return i;
    }
    return -1; // Không tìm thấy
}

//+------------------------------------------------------------------+
//| AnalyzeProposals                                                 |
//+------------------------------------------------------------------+
// Placeholder for more complex analysis if needed (e.g., ranking, prioritizing)
void CPortfolioManager::AnalyzeProposals()
{
    if(m_Logger == NULL) {
        printf("CPortfolioManager Error: Logger is NULL in AnalyzeProposals.");
        return;
    }
    m_Logger.LogInfo("CPortfolioManager: Analyzing proposals (currently a placeholder)...");
    // TODO: Implement if complex inter-proposal analysis is needed before individual decisions.
    // For example, if there are multiple competing proposals for limited capital/risk.
    // This could involve sorting m_TradeProposals by quality score, potential reward/risk, etc.
    // And then potentially rejecting lower quality proposals if higher quality ones consume available risk budget.
    // For now, proposals are processed independently by DecideOnProposal.
}

//+------------------------------------------------------------------+
//| DecideOnProposal                                                 |
//+------------------------------------------------------------------+
ENUM_PORTFOLIO_DECISION CPortfolioManager::DecideOnProposal(TradeProposal &proposal) // Nhận bằng tham chiếu để có thể cập nhật
{
    if(m_Logger != NULL) m_Logger.LogInfoFormat("CPortfolioManager: ==> Entering DecideOnProposal for %s %s...", proposal.Symbol, EnumToString(proposal.OrderType)); // Added log
    if(m_Logger == NULL || m_NewsFilter == NULL || m_RiskManager == NULL || m_PositionManager == NULL)
    {
        if(m_Logger != NULL) m_Logger.LogError("CPortfolioManager: Critical module (Logger, NewsFilter, RiskManager, or PositionManager) is NULL in DecideOnProposal.");
        return DECISION_REJECT; // Không thể ra quyết định nếu thiếu module quan trọng
    }

    if(m_Logger != NULL) m_Logger.LogInfoFormat("CPortfolioManager: Deciding on proposal for %s %s, Quality: %.2f, Risk: %.2f%%", 
                                                proposal.Symbol, EnumToString(proposal.OrderType), proposal.SignalQuality, proposal.RiskPercent * 100);

    // 1. Kiểm tra Sự kiện Vĩ mô
    // TODO: Cần xác định time frame cho IsInNewsWindow (ví dụ: trong 30 phút tới)
    datetime checkTime = TimeCurrent() + 30 * 60; // Kiểm tra tin trong 30 phút tới
    if(m_NewsFilter.IsInNewsWindow(proposal.Symbol, checkTime, checkTime)) // Giả sử IsInNewsWindow kiểm tra một khoảng thời gian
    {
        if(m_Logger != NULL) m_Logger.LogInfoFormat("CPortfolioManager: Proposal for %s REJECTED/POSTPONED due to upcoming news.", proposal.Symbol);
        // return DECISION_POSTPONE; // Hoặc REJECT tùy chiến lược
        return DECISION_REJECT;
    }

    // 2. Kiểm tra Rủi ro Tổng thể
    double currentTotalRisk = m_RiskManager.GetTotalOpenRiskPercent(); // Hàm này cần được implement trong CRiskManager
    if(m_Logger != NULL) m_Logger.LogDebugFormat("CPortfolioManager: Current total open risk: %.2f%%. Proposal risk: %.2f%%. Max total risk: %.2f%%", 
                                                currentTotalRisk * 100, proposal.RiskPercent * 100, m_MaxTotalRisk * 100);
    if((currentTotalRisk + proposal.RiskPercent) > m_MaxTotalRisk)
    {
        if(m_Logger != NULL) m_Logger.LogInfoFormat("CPortfolioManager: Proposal for %s REJECTED due to exceeding max total risk (%.2f%% + %.2f%% > %.2f%%).", 
                                                    proposal.Symbol, currentTotalRisk*100, proposal.RiskPercent*100, m_MaxTotalRisk*100);
        // TODO: Có thể xem xét DECISION_ADJUST_LOT ở đây nếu rủi ro vượt không quá nhiều
        return DECISION_REJECT;
    }

    // 3. Kiểm tra Tương quan (Correlation)
    int proposalSymbolIndex = GetSymbolIndex(proposal.Symbol);
    if(proposalSymbolIndex != -1)
    {
        for(int i = 0; i < m_PositionManager.GetOpenPositionsCount(); i++) // Hàm GetOpenPositionsCount() cần có trong CPositionManager
        {
            string openPositionSymbol = m_PositionManager.GetOpenPositionSymbol(i); // Hàm GetOpenPositionSymbol(index) cần có
            ENUM_POSITION_TYPE openPositionDirection = m_PositionManager.GetOpenPositionDirection(i); // Hàm GetOpenPositionDirection(index) cần có
            int openSymbolIndex = GetSymbolIndex(openPositionSymbol);

            if(openSymbolIndex != -1)
            {
                double correlation = m_CorrelationMatrix[proposalSymbolIndex][openSymbolIndex];
                // Chỉ xem xét nếu cả hai cùng hướng (BUY-BUY hoặc SELL-SELL) hoặc ngược hướng (BUY-SELL) tùy vào dấu của correlation
                // Ví dụ đơn giản: nếu tương quan dương mạnh và cùng hướng, hoặc tương quan âm mạnh và ngược hướng -> có thể tăng rủi ro
                bool sameDirection = (proposal.OrderType == ORDER_TYPE_BUY && openPositionDirection == POSITION_TYPE_BUY) || 
                                     (proposal.OrderType == ORDER_TYPE_SELL && openPositionDirection == POSITION_TYPE_SELL);
                
                if(m_Logger != NULL) m_Logger.LogDebugFormat("CPortfolioManager: Checking correlation for %s vs open %s. Corr: %.2f. Same direction: %s", 
                                                            proposal.Symbol, openPositionSymbol, correlation, sameDirection ? "true" : "false");

                // Nếu tương quan dương mạnh và cùng hướng
                if(correlation > m_MaxCorrelationAllowed && sameDirection)
                {
                    if(m_Logger != NULL) m_Logger.LogInfoFormat("CPortfolioManager: Proposal for %s REJECTED due to high positive correlation (%.2f > %.2f) with open %s (same direction).", 
                                                                proposal.Symbol, correlation, m_MaxCorrelationAllowed, openPositionSymbol);
                    return DECISION_REJECT;
                }
                // Nếu tương quan âm mạnh và ngược hướng (ví dụ: Mua EURUSD, Bán USDCHF, corr(EURUSD,USDCHF) ~ -0.9)
                // Điều này cũng làm tăng rủi ro theo một hướng (ví dụ: Long USD exposure)
                // Logic này cần được xem xét cẩn thận hơn dựa trên ma trận tương quan và cách nó được xây dựng.
                // Ví dụ: nếu corr(A,B) = -0.8, Mua A và Bán B -> cùng chiều rủi ro.
                // if(correlation < -m_MaxCorrelationAllowed && !sameDirection) // Logic này cần kiểm tra kỹ
                // {
                //     if(m_Logger != NULL) m_Logger.LogInfoFormat("CPortfolioManager: Proposal for %s REJECTED due to high negative correlation (%.2f < %.2f) with open %s (opposite direction, implies same underlying risk direction).", 
                //                                                 proposal.Symbol, correlation, -m_MaxCorrelationAllowed, openPositionSymbol);
                //     return DECISION_REJECT;
                // }
            }
        }
    }
    else
    {
        if(m_Logger != NULL) m_Logger.LogWarningFormat("CPortfolioManager: Symbol %s not found in correlation matrix map. Skipping correlation check.", proposal.Symbol);
    }

    // 4. Kiểm tra Tập trung Rủi ro (Risk Concentration)
    double riskConcentrationLimit = 0.60; // 60% tổng rủi ro cho một đồng tiền
    if (IsRiskConcentrated(proposal, riskConcentrationLimit)) {
        if(m_Logger != NULL) m_Logger.LogInfoFormat("CPortfolioManager: Proposal for %s REJECTED due to risk concentration.", proposal.Symbol);
        return DECISION_REJECT;
    }
    if(m_Logger != NULL) m_Logger.LogDebug("CPortfolioManager: Risk concentration check - PASSED.");


    // 5. Ra quyết định Cuối cùng
    if(m_Logger != NULL) m_Logger.LogInfoFormat("CPortfolioManager: Proposal for %s %s APPROVED.", proposal.Symbol, EnumToString(proposal.OrderType));
    return DECISION_APPROVE;
}

//+------------------------------------------------------------------+
//| WriteDecisionToGVs                                               |
//+------------------------------------------------------------------+
void CPortfolioManager::WriteDecisionToGVs(const TradeProposal &proposal_const, ENUM_PORTFOLIO_DECISION decision_val, double adjustedLotFactor = 1.0) // Ghi quyết định vào Global Variables
{
    if(m_Logger == NULL) {
        printf("CPortfolioManager Error: Logger is NULL in WriteDecisionToGVs.");
        return;
    }

    TradeProposal proposal_to_write = proposal_const; // Create a mutable copy
    proposal_to_write.decision = decision_val;        // Set the decision in the mutable copy
    // If 'adjustedLotFactor' needs to be part of the JSON, add a field to TradeProposal struct and set it here.
    // proposal_to_write.adjustedLotFactor = adjustedLotFactor; // Example if field exists

    if(proposal_to_write.GVDecisionName == "")
    {
        m_Logger.LogErrorFormat("CPortfolioManager: Cannot write decision for proposal on %s, GVDecisionName is empty.", proposal_to_write.Symbol);
        return;
    }

    string decision_json_str = proposal_to_write.ToString(); // This now serializes the proposal (including decision) to JSON

    if(GlobalVariableSet(proposal_to_write.GVDecisionName, decision_json_str))
    {
        m_Logger.LogInfoFormat("CPortfolioManager: JSON Decision '%s' for %s (Magic: %d) written to GV '%s'. AdjustedLotFactor: %.2f. JSON: %s", 
                                EnumToString(decision_val), proposal_to_write.Symbol, proposal_to_write.MagicNumber, proposal_to_write.GVDecisionName, adjustedLotFactor, decision_json_str);
    }
    else
    {                            
        m_Logger.LogErrorFormat("CPortfolioManager: Failed to write JSON decision to GV '%s' for proposal on %s. Error: %d", proposal_to_write.GVDecisionName, proposal_to_write.Symbol, GetLastError());
    }

    // The original proposal GV (proposal_to_write.GVProposalName) is deleted in LoadProposals after successful parsing.
    // However, to be absolutely sure it's cleaned up after a decision is made, we can add a deletion here too.
    // This also handles cases where a proposal might not be fully processed by LoadProposals but a decision is still made (less likely).
    if(GlobalVariableCheck(proposal_to_write.GVProposalName)) {
        GlobalVariableDel(proposal_to_write.GVProposalName);
        if(m_Logger != NULL) m_Logger.LogDebugFormat("CPortfolioManager: Cleaned up proposal GV: %s after writing decision.", proposal_to_write.GVProposalName);
    }
    // If there's a specific need to clean up proposal_to_write.GVProposalName here, the logic would need careful review
    // to ensure it doesn't conflict with LoadProposals.
}

//+------------------------------------------------------------------+
//| ProcessTradeProposals                                            |
//+------------------------------------------------------------------+
void CPortfolioManager::ProcessTradeProposals()
{
    if(m_Logger == NULL) {
        printf("CPortfolioManager Error: Logger is NULL in ProcessTradeProposals.");
        return;
    }
    m_Logger.LogInfo("CPortfolioManager: Starting to process trade proposals.");

    LoadProposals();    // Tải các đề xuất mới
    AnalyzeProposals(); // Phân tích chung (nếu có)

    for(int i = 0; i < m_TradeProposals.Total(); i++)
    {
        TradeProposal* proposal = m_TradeProposals.At(i);
        if(proposal == NULL) continue;

        ENUM_PORTFOLIO_DECISION raw_decision = DecideOnProposal(*proposal); // Ra quyết định cho từng proposal
        proposal.Decision = raw_decision; // Store the raw decision
        
        double adjustedLotFactor = 1.0; // Default lot factor
        ENUM_PORTFOLIO_DECISION final_decision_for_gv = raw_decision;

        if(raw_decision == DECISION_ADJUST_LOT)
        {
            // TODO: Implement sophisticated lot adjustment logic in DecideOnProposal or a separate helper.
            // This logic should determine the appropriate adjustedLotFactor.
            // For example, it could be based on available margin, overall portfolio risk, specific rules for the symbol, etc.
            // DecideOnProposal might populate a field like 'proposal.RecommendedLotFactor' or return it somehow.
            // For now, using a placeholder value if DECISION_ADJUST_LOT is returned.
            adjustedLotFactor = m_EAContext.Input.PortfolioManagement.DefaultLotAdjustmentFactor; // e.g., 0.5 from inputs
            final_decision_for_gv = DECISION_APPROVED; // Convert ADJUST_LOT to APPROVE with the new factor for GV communication
            if(m_Logger != NULL) m_Logger.LogInfoFormat("CPortfolioManager: Proposal for %s resulted in ADJUST_LOT. Applying factor %.2f and sending as APPROVE.", proposal.Symbol, adjustedLotFactor);
        }
        else if(raw_decision == DECISION_APPROVED)
        {
            // Standard approval, full requested lot (factor 1.0) unless proposal itself has a different suggestion
            // adjustedLotFactor = proposal.SuggestedFactor; // if proposal carries this
        }

        WriteDecisionToGVs(*proposal, final_decision_for_gv, adjustedLotFactor);
    }
    // Clear proposals after processing. Important to do this on the heap objects from CArrayObj
    // m_TradeProposals.Clear(); // This would just clear pointers, not delete objects.
    while(m_TradeProposals.Total() > 0)
    {
        TradeProposal* p = m_TradeProposals.Detach(); // Detach from end
        if(p != NULL) delete p;
    }

    m_Logger.LogInfo("CPortfolioManager: Finished processing trade proposals.");
}

//+------------------------------------------------------------------+
//| CalculateTotalRisk                                               |
//+------------------------------------------------------------------+
double CPortfolioManager::CalculateTotalRisk()
{
    if(m_RiskManager == NULL)
    {
        if(m_Logger != NULL) m_Logger.LogError("CPortfolioManager: RiskManager is NULL in CalculateTotalRisk.");
        return 0.0;
    }
    // This should ideally use a more sophisticated way to get total risk from RiskManager
    // or sum up risks from m_PositionManager if RiskManager doesn't provide a direct portfolio-wide risk.
    return m_RiskManager.GetTotalOpenRiskPercent(); // Assuming this function exists and gives current total risk
}

//+------------------------------------------------------------------+
//| IsRiskConcentrated                                               |
//+------------------------------------------------------------------+
bool CPortfolioManager::IsRiskConcentrated(const TradeProposal &proposal, double maxConcentration)
{
    if(m_PositionManager == NULL || m_RiskManager == NULL)
    {
        if(m_Logger != NULL) m_Logger.LogError("CPortfolioManager: PositionManager or RiskManager is NULL in IsRiskConcentrated.");
        return true; // Fail safe: assume concentrated if modules are missing
    }

    string baseCurrency, quoteCurrency;
    StringSplit(proposal.Symbol, '/', baseCurrency, quoteCurrency); // Basic split, assumes XXX/YYY format
    if(quoteCurrency == "") { // For symbols like XAUUSD, EURJPY etc.
        if(StringLen(proposal.Symbol) == 6) {
             baseCurrency = StringSubstr(proposal.Symbol, 0, 3);
             quoteCurrency = StringSubstr(proposal.Symbol, 3, 3);
        } else {
            if(m_Logger != NULL) m_Logger.LogWarningFormat("CPortfolioManager: Could not parse currencies from symbol '%s' in IsRiskConcentrated.", proposal.Symbol);
            return false; // Cannot determine, so assume not concentrated for now
        }
    }

    double baseCurrencyExposure = GetCurrencyRiskExposure(baseCurrency);
    double quoteCurrencyExposure = GetCurrencyRiskExposure(quoteCurrency);

    // Estimate risk added by this proposal to each currency
    // This is a simplification. True exposure depends on whether it's a buy or sell.
    // For a BUY of Base/Quote, exposure increases for Base, decreases for Quote (if selling Quote to buy Base)
    // For a SELL of Base/Quote, exposure decreases for Base, increases for Quote
    double proposalRisk = proposal.RiskPercent;
    double newBaseExposure, newQuoteExposure;

    if(proposal.OrderType == ORDER_TYPE_BUY) // Buying Base, Selling Quote
    {
        newBaseExposure = baseCurrencyExposure + proposalRisk;
        // For quote currency, if we are selling it, its 'long' exposure effectively decreases or 'short' exposure increases.
        // This logic needs to be very careful about how exposure is defined (e.g., net long/short).
        // Simplification: consider absolute exposure change for now.
        newQuoteExposure = quoteCurrencyExposure + proposalRisk; // Simplified: adding risk to both involved currencies' exposure pool
    }
    else // Selling Base, Buying Quote
    {
        newBaseExposure = baseCurrencyExposure + proposalRisk; // Simplified
        newQuoteExposure = quoteCurrencyExposure + proposalRisk;
    }
    
    double totalPortfolioRisk = CalculateTotalRisk() + proposalRisk;
    if (totalPortfolioRisk == 0) return false; // Avoid division by zero

    if ((newBaseExposure / totalPortfolioRisk) > maxConcentration) {
        if(m_Logger != NULL) m_Logger.LogInfoFormat("CPortfolioManager: Risk concentration for %s (%.2f%% of total risk %.2f%%) would exceed limit %.2f%% on %s proposal.", 
            baseCurrency, (newBaseExposure/totalPortfolioRisk)*100, totalPortfolioRisk*100, maxConcentration*100, proposal.Symbol);
        return true;
    }
    if ((newQuoteExposure / totalPortfolioRisk) > maxConcentration) {
        if(m_Logger != NULL) m_Logger.LogInfoFormat("CPortfolioManager: Risk concentration for %s (%.2f%% of total risk %.2f%%) would exceed limit %.2f%% on %s proposal.", 
            quoteCurrency, (newQuoteExposure/totalPortfolioRisk)*100, totalPortfolioRisk*100, maxConcentration*100, proposal.Symbol);
        return true;
    }

    return false;
}

//+------------------------------------------------------------------+
//| GetCurrencyRiskExposure                                          |
//+------------------------------------------------------------------+
double CPortfolioManager::GetCurrencyRiskExposure(const string currency)
{
    if(m_PositionManager == NULL || m_RiskManager == NULL)
    {
        if(m_Logger != NULL) m_Logger.LogError("CPortfolioManager: PositionManager or RiskManager is NULL in GetCurrencyRiskExposure.");
        return 0.0;
    }

    double totalExposure = 0.0;
    for(int i = 0; i < m_PositionManager.GetOpenPositionsCount(); i++)
    {
        string symbol = m_PositionManager.GetOpenPositionSymbol(i);
        double positionRisk = m_RiskManager.GetPositionRiskPercent(m_PositionManager.GetOpenPositionTicket(i)); // Needs GetPositionRiskPercent(ticket) in RiskManager
        
        string base, quote;
        StringSplit(symbol, '/', base, quote);
        if(quote == "") { // For symbols like XAUUSD, EURJPY etc.
            if(StringLen(symbol) == 6) {
                 base = StringSubstr(symbol, 0, 3);
                 quote = StringSubstr(symbol, 3, 3);
            } else continue; // Skip if symbol format is unexpected
        }

        if(StringCompare(base, currency, false) == 0)
        {
            // If it's BaseCurrency/XXX and we are BUYING, exposure to BaseCurrency increases.
            // If it's BaseCurrency/XXX and we are SELLING, exposure to BaseCurrency decreases (or short exposure increases).
            // This needs careful handling of long/short exposure. For simplicity, sum absolute risks involving the currency.
            totalExposure += positionRisk;
        }
        if(StringCompare(quote, currency, false) == 0)
        {
            // If it's XXX/QuoteCurrency and we are BUYING XXX, we are selling QuoteCurrency, exposure to QuoteCurrency decreases.
            // If it's XXX/QuoteCurrency and we are SELLING XXX, we are buying QuoteCurrency, exposure to QuoteCurrency increases.
            totalExposure += positionRisk;
        }
    }
    return totalExposure;
}

} // namespace ApexPullback

#endif // PORTFOLIO_MANAGER_MQH