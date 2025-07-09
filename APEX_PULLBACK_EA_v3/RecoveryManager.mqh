//+------------------------------------------------------------------+
//| RecoveryManager.mqh                                              |
//| Quản lý phục hồi và tái tạo metadata cho EA                     |
//| Copyright 2024, Apex Trading Systems                             |
//+------------------------------------------------------------------+
#ifndef RECOVERYMANAGER_MQH_
#define RECOVERYMANAGER_MQH_

#include "CommonStructs.mqh"

// BẮT ĐẦU NAMESPACE
namespace ApexPullback {

//+------------------------------------------------------------------+
//| Enum định nghĩa trạng thái phục hồi                             |
//+------------------------------------------------------------------+
enum ENUM_RECOVERY_STATUS {
    RECOVERY_SUCCESS,           // Phục hồi thành công
    RECOVERY_PARTIAL,           // Phục hồi một phần
    RECOVERY_FAILED,            // Phục hồi thất bại
    RECOVERY_NO_POSITIONS,      // Không có vị thế nào cần phục hồi
    RECOVERY_INVALID_MAGIC      // Magic number không hợp lệ
};

//+------------------------------------------------------------------+
//| Enum định nghĩa loại metadata được phục hồi                     |
//+------------------------------------------------------------------+
enum ENUM_METADATA_TYPE {
    META_STRATEGY_TYPE,         // Loại chiến lược
    META_ENTRY_REASON,          // Lý do vào lệnh
    META_RISK_LEVEL,           // Mức độ rủi ro
    META_CORRELATION_GROUP,     // Nhóm tương quan
    META_TIMEFRAME,            // Khung thời gian
    META_SIGNAL_STRENGTH,      // Độ mạnh tín hiệu
    META_MARKET_CONDITION,     // Điều kiện thị trường
    META_PORTFOLIO_WEIGHT      // Trọng số trong danh mục
};

//+------------------------------------------------------------------+
//| Struct chứa thông tin metadata được phục hồi                    |
//+------------------------------------------------------------------+
struct RecoveredMetadata {
    ulong ticket;                   // Ticket của lệnh
    string symbol;                  // Symbol
    int orderType;                  // Loại lệnh
    double lotSize;                 // Khối lượng
    double entryPrice;              // Giá vào
    double stopLoss;                // Stop Loss
    double takeProfit;              // Take Profit
    datetime openTime;              // Thời gian mở
    string comment;                 // Comment gốc
    
    // Metadata được phục hồi
    string strategyType;            // Loại chiến lược
    string entryReason;             // Lý do vào lệnh
    double riskLevel;               // Mức độ rủi ro (0-100)
    string correlationGroup;        // Nhóm tương quan
    ENUM_TIMEFRAMES timeframe;      // Khung thời gian
    double signalStrength;          // Độ mạnh tín hiệu (0-100)
    string marketCondition;         // Điều kiện thị trường
    double portfolioWeight;         // Trọng số trong danh mục
    
    // Trạng thái phục hồi
    bool isFullyRecovered;          // Có phục hồi đầy đủ không
    string recoveryErrors;          // Lỗi trong quá trình phục hồi
    datetime recoveryTime;          // Thời gian phục hồi
};

//+------------------------------------------------------------------+
//| Struct cấu hình cho Recovery Manager                             |
//+------------------------------------------------------------------+
struct RecoveryConfig {
    bool enableAutoRecovery;        // Bật tự động phục hồi
    bool enableMetadataRecovery;    // Bật phục hồi metadata
    bool enableRiskRecalculation;   // Bật tính toán lại rủi ro
    bool enableCorrelationCheck;    // Bật kiểm tra tương quan
    
    int maxRecoveryAttempts;        // Số lần thử phục hồi tối đa
    int recoveryTimeoutMs;          // Timeout cho mỗi lần phục hồi
    
    string metadataDelimiter;       // Ký tự phân cách metadata
    string backupFolder;            // Thư mục backup
    
    bool createBackupOnRecovery;    // Tạo backup khi phục hồi
    bool validateRecoveredData;     // Validate dữ liệu đã phục hồi
};

//+------------------------------------------------------------------+
//| Lớp quản lý phục hồi EA                                         |
//+------------------------------------------------------------------+
class CRecoveryManager {
private:
    CLogger* m_Logger;
    RecoveryConfig m_Config;
    int m_MagicNumber;
    string m_EAName;
    
    // Dữ liệu phục hồi
    RecoveredMetadata m_RecoveredPositions[];
    int m_RecoveredCount;
    
    // Thống kê phục hồi
    int m_TotalPositionsFound;
    int m_SuccessfulRecoveries;
    int m_PartialRecoveries;
    int m_FailedRecoveries;
    datetime m_LastRecoveryTime;
    
public:
    CRecoveryManager();
    ~CRecoveryManager();
    
    // Khởi tạo
    bool Initialize(CLogger* logger, int magicNumber, string eaName);
    bool SetConfig(const RecoveryConfig& config);
    void Cleanup();
    
    // Phục hồi chính
    ENUM_RECOVERY_STATUS RecoverAllPositions();
    ENUM_RECOVERY_STATUS RecoverPosition(ulong ticket);
    bool RecoverMetadataFromComment(string comment, RecoveredMetadata& metadata);
    
    // Quản lý metadata
    bool ParseMetadataFromComment(string comment, RecoveredMetadata& metadata);
    string EncodeMetadataToComment(const RecoveredMetadata& metadata);
    bool ValidateMetadata(const RecoveredMetadata& metadata);
    bool UpdatePositionMetadata(ulong ticket, const RecoveredMetadata& metadata);
    
    // Phân tích và tái tạo
    bool AnalyzeMarketConditionAtEntry(const RecoveredMetadata& metadata, string& condition);
    bool RecalculateRiskLevel(const RecoveredMetadata& metadata, double& newRiskLevel);
    bool DetermineStrategyType(const RecoveredMetadata& metadata, string& strategyType);
    bool AssignCorrelationGroup(const RecoveredMetadata& metadata, string& group);
    
    // Backup và khôi phục
    bool CreateRecoveryBackup();
    bool SaveRecoveredDataToFile(string filename = "");
    bool LoadRecoveredDataFromFile(string filename = "");
    
    // Validation và kiểm tra
    bool ValidateRecoveredPositions();
    bool CheckPositionConsistency(const RecoveredMetadata& metadata);
    bool VerifyRiskParameters(const RecoveredMetadata& metadata);
    bool CheckCorrelationConflicts();
    
    // Thống kê và báo cáo
    int GetRecoveredPositionCount() const { return m_RecoveredCount; }
    int GetTotalPositionsFound() const { return m_TotalPositionsFound; }
    int GetSuccessfulRecoveries() const { return m_SuccessfulRecoveries; }
    int GetPartialRecoveries() const { return m_PartialRecoveries; }
    int GetFailedRecoveries() const { return m_FailedRecoveries; }
    double GetRecoverySuccessRate() const;
    
    bool GenerateRecoveryReport(string& report);
    bool LogRecoveryStatistics();
    
    // Truy cập dữ liệu
    bool GetRecoveredPosition(int index, RecoveredMetadata& metadata);
    bool FindRecoveredPositionByTicket(ulong ticket, RecoveredMetadata& metadata);
    bool GetRecoveredPositionsBySymbol(string symbol, RecoveredMetadata& positions[]);
    bool GetRecoveredPositionsByStrategy(string strategyType, RecoveredMetadata& positions[]);
    
    // Cấu hình
    RecoveryConfig GetConfig() const { return m_Config; }
    bool IsAutoRecoveryEnabled() const { return m_Config.enableAutoRecovery; }
    bool IsMetadataRecoveryEnabled() const { return m_Config.enableMetadataRecovery; }
    
private:
    // Helper methods
    bool ScanOpenPositions();
    bool ExtractMetadataField(string comment, string fieldName, string& value);
    bool ParseDoubleFromMetadata(string value, double& result);
    bool ParseIntFromMetadata(string value, int& result);
    bool ParseBoolFromMetadata(string value, bool& result);
    ENUM_TIMEFRAMES ParseTimeframeFromString(string tfString);
    string TimeframeToString(ENUM_TIMEFRAMES tf);
    
    // Validation helpers
    bool IsValidSymbol(string symbol);
    bool IsValidPrice(double price);
    bool IsValidLotSize(double lotSize);
    bool IsValidRiskLevel(double riskLevel);
    bool IsValidSignalStrength(double strength);
    
    // Backup helpers
    string GenerateBackupFilename();
    bool WriteRecoveryDataToFile(string filename, const RecoveredMetadata& data[], int count);
    bool ReadRecoveryDataFromFile(string filename, RecoveredMetadata& data[], int& count);
    
    // Error handling
    void LogRecoveryError(string function, string error, ulong ticket = 0);
    void LogRecoveryWarning(string function, string warning, ulong ticket = 0);
    void LogRecoveryInfo(string function, string info, ulong ticket = 0);
    
    // Utility
    string RecoveryStatusToString(ENUM_RECOVERY_STATUS status);
    string MetadataTypeToString(ENUM_METADATA_TYPE type);
    bool ResizeRecoveredArray(int newSize);
    void ClearRecoveredData();
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CRecoveryManager::CRecoveryManager() {
    m_Logger = NULL;
    m_MagicNumber = 0;
    m_EAName = "";
    m_RecoveredCount = 0;
    m_TotalPositionsFound = 0;
    m_SuccessfulRecoveries = 0;
    m_PartialRecoveries = 0;
    m_FailedRecoveries = 0;
    m_LastRecoveryTime = 0;
    
    // Cấu hình mặc định
    m_Config.enableAutoRecovery = true;
    m_Config.enableMetadataRecovery = true;
    m_Config.enableRiskRecalculation = true;
    m_Config.enableCorrelationCheck = true;
    m_Config.maxRecoveryAttempts = 3;
    m_Config.recoveryTimeoutMs = 5000;
    m_Config.metadataDelimiter = "|";
    m_Config.backupFolder = "Recovery";
    m_Config.createBackupOnRecovery = true;
    m_Config.validateRecoveredData = true;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CRecoveryManager::~CRecoveryManager() {
    Cleanup();
}

//+------------------------------------------------------------------+
//| Khởi tạo Recovery Manager                                        |
//+------------------------------------------------------------------+
bool CRecoveryManager::Initialize(CLogger* logger, int magicNumber, string eaName) {
    if (logger == NULL) {
        Print("[RecoveryManager] ERROR: Logger không được cung cấp");
        return false;
    }
    
    if (magicNumber <= 0) {
        Print("[RecoveryManager] ERROR: Magic number không hợp lệ: ", magicNumber);
        return false;
    }
    
    m_Logger = logger;
    m_MagicNumber = magicNumber;
    m_EAName = eaName;
    
    // Tạo thư mục backup nếu cần
    if (m_Config.createBackupOnRecovery) {
        string backupPath = m_Config.backupFolder;
        if (!FolderCreate(backupPath, FILE_COMMON)) {
            LogRecoveryWarning("Initialize", "Không thể tạo thư mục backup: " + backupPath);
        }
    }
    
    LogRecoveryInfo("Initialize", StringFormat("Khởi tạo thành công - EA: %s, Magic: %d", m_EAName, m_MagicNumber));
    
    return true;
}

//+------------------------------------------------------------------+
//| Thiết lập cấu hình                                              |
//+------------------------------------------------------------------+
bool CRecoveryManager::SetConfig(const RecoveryConfig& config) {
    m_Config = config;
    
    LogRecoveryInfo("SetConfig", "Cấu hình đã được cập nhật");
    
    return true;
}

//+------------------------------------------------------------------+
//| Dọn dẹp                                                         |
//+------------------------------------------------------------------+
void CRecoveryManager::Cleanup() {
    ClearRecoveredData();
    m_Logger = NULL;
}

//+------------------------------------------------------------------+
//| Phục hồi tất cả vị thế                                          |
//+------------------------------------------------------------------+
ENUM_RECOVERY_STATUS CRecoveryManager::RecoverAllPositions() {
    if (m_Logger == NULL) {
        return RECOVERY_FAILED;
    }
    
    LogRecoveryInfo("RecoverAllPositions", "Bắt đầu quá trình phục hồi tất cả vị thế...");
    
    // Tạo backup trước khi phục hồi
    if (m_Config.createBackupOnRecovery) {
        CreateRecoveryBackup();
    }
    
    // Reset thống kê
    m_TotalPositionsFound = 0;
    m_SuccessfulRecoveries = 0;
    m_PartialRecoveries = 0;
    m_FailedRecoveries = 0;
    ClearRecoveredData();
    
    // Quét tất cả vị thế mở
    if (!ScanOpenPositions()) {
        LogRecoveryError("RecoverAllPositions", "Không thể quét các vị thế mở");
        return RECOVERY_FAILED;
    }
    
    if (m_TotalPositionsFound == 0) {
        LogRecoveryInfo("RecoverAllPositions", "Không tìm thấy vị thế nào cần phục hồi");
        return RECOVERY_NO_POSITIONS;
    }
    
    LogRecoveryInfo("RecoverAllPositions", StringFormat("Tìm thấy %d vị thế cần phục hồi", m_TotalPositionsFound));
    
    // Validate dữ liệu đã phục hồi
    if (m_Config.validateRecoveredData) {
        ValidateRecoveredPositions();
    }
    
    // Kiểm tra xung đột tương quan
    if (m_Config.enableCorrelationCheck) {
        CheckCorrelationConflicts();
    }
    
    m_LastRecoveryTime = TimeCurrent();
    
    // Xác định trạng thái phục hồi
    ENUM_RECOVERY_STATUS status;
    if (m_FailedRecoveries == 0) {
        if (m_PartialRecoveries == 0) {
            status = RECOVERY_SUCCESS;
        } else {
            status = RECOVERY_PARTIAL;
        }
    } else {
        status = RECOVERY_FAILED;
    }
    
    // Log kết quả
    LogRecoveryStatistics();
    
    return status;
}

//+------------------------------------------------------------------+
//| Quét các vị thế mở                                              |
//+------------------------------------------------------------------+
bool CRecoveryManager::ScanOpenPositions() {
    int totalPositions = PositionsTotal();
    
    for (int i = 0; i < totalPositions; i++) {
        ulong ticket = PositionGetTicket(i);
        if (ticket == 0) continue;
        
        // Kiểm tra magic number
        if (PositionGetInteger(POSITION_MAGIC) != m_MagicNumber) continue;
        
        m_TotalPositionsFound++;
        
        // Phục hồi vị thế này
        ENUM_RECOVERY_STATUS status = RecoverPosition(ticket);
        
        switch (status) {
            case RECOVERY_SUCCESS:
                m_SuccessfulRecoveries++;
                break;
            case RECOVERY_PARTIAL:
                m_PartialRecoveries++;
                break;
            default:
                m_FailedRecoveries++;
                break;
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Phục hồi một vị thế cụ thể                                      |
//+------------------------------------------------------------------+
ENUM_RECOVERY_STATUS CRecoveryManager::RecoverPosition(ulong ticket) {
    if (!PositionSelectByTicket(ticket)) {
        LogRecoveryError("RecoverPosition", "Không thể chọn vị thế", ticket);
        return RECOVERY_FAILED;
    }
    
    // Tăng kích thước mảng nếu cần
    if (m_RecoveredCount >= ArraySize(m_RecoveredPositions)) {
        if (!ResizeRecoveredArray(m_RecoveredCount + 10)) {
            LogRecoveryError("RecoverPosition", "Không thể mở rộng mảng phục hồi", ticket);
            return RECOVERY_FAILED;
        }
    }
    
    RecoveredMetadata metadata;
    
    // Thu thập thông tin cơ bản
    metadata.ticket = ticket;
    metadata.symbol = PositionGetString(POSITION_SYMBOL);
    metadata.orderType = (int)PositionGetInteger(POSITION_TYPE);
    metadata.lotSize = PositionGetDouble(POSITION_VOLUME);
    metadata.entryPrice = PositionGetDouble(POSITION_PRICE_OPEN);
    metadata.stopLoss = PositionGetDouble(POSITION_SL);
    metadata.takeProfit = PositionGetDouble(POSITION_TP);
    metadata.openTime = (datetime)PositionGetInteger(POSITION_TIME);
    metadata.comment = PositionGetString(POSITION_COMMENT);
    metadata.recoveryTime = TimeCurrent();
    
    // Phục hồi metadata từ comment
    bool metadataRecovered = false;
    if (m_Config.enableMetadataRecovery) {
        metadataRecovered = RecoverMetadataFromComment(metadata.comment, metadata);
    }
    
    // Nếu không phục hồi được metadata, thử phân tích và tái tạo
    if (!metadataRecovered) {
        // Xác định loại chiến lược dựa trên thông tin có sẵn
        DetermineStrategyType(metadata, metadata.strategyType);
        
        // Phân tích điều kiện thị trường tại thời điểm vào lệnh
        AnalyzeMarketConditionAtEntry(metadata, metadata.marketCondition);
        
        // Tính toán lại mức độ rủi ro
        if (m_Config.enableRiskRecalculation) {
            RecalculateRiskLevel(metadata, metadata.riskLevel);
        }
        
        // Gán nhóm tương quan
        AssignCorrelationGroup(metadata, metadata.correlationGroup);
        
        metadata.isFullyRecovered = false;
        metadata.recoveryErrors = "Metadata được tái tạo từ phân tích";
    } else {
        metadata.isFullyRecovered = true;
        metadata.recoveryErrors = "";
    }
    
    // Validate metadata
    if (m_Config.validateRecoveredData) {
        if (!ValidateMetadata(metadata)) {
            LogRecoveryWarning("RecoverPosition", "Metadata không hợp lệ", ticket);
            metadata.isFullyRecovered = false;
            metadata.recoveryErrors += "; Validation failed";
        }
    }
    
    // Lưu vào mảng
    m_RecoveredPositions[m_RecoveredCount] = metadata;
    m_RecoveredCount++;
    
    LogRecoveryInfo("RecoverPosition", 
                   StringFormat("Phục hồi vị thế %s - %s: %s", 
                               metadata.symbol, 
                               (metadata.isFullyRecovered ? "Đầy đủ" : "Một phần"),
                               metadata.strategyType), 
                   ticket);
    
    return metadata.isFullyRecovered ? RECOVERY_SUCCESS : RECOVERY_PARTIAL;
}

//+------------------------------------------------------------------+
//| Phục hồi metadata từ comment                                    |
//+------------------------------------------------------------------+
bool CRecoveryManager::RecoverMetadataFromComment(string comment, RecoveredMetadata& metadata) {
    if (StringLen(comment) == 0) {
        return false;
    }
    
    bool hasMetadata = false;
    
    // Trích xuất các trường metadata
    if (ExtractMetadataField(comment, "STRATEGY", metadata.strategyType)) hasMetadata = true;
    if (ExtractMetadataField(comment, "REASON", metadata.entryReason)) hasMetadata = true;
    if (ExtractMetadataField(comment, "CORRELATION", metadata.correlationGroup)) hasMetadata = true;
    if (ExtractMetadataField(comment, "MARKET", metadata.marketCondition)) hasMetadata = true;
    
    string tempValue;
    if (ExtractMetadataField(comment, "RISK", tempValue)) {
        if (ParseDoubleFromMetadata(tempValue, metadata.riskLevel)) hasMetadata = true;
    }
    
    if (ExtractMetadataField(comment, "SIGNAL", tempValue)) {
        if (ParseDoubleFromMetadata(tempValue, metadata.signalStrength)) hasMetadata = true;
    }
    
    if (ExtractMetadataField(comment, "WEIGHT", tempValue)) {
        if (ParseDoubleFromMetadata(tempValue, metadata.portfolioWeight)) hasMetadata = true;
    }
    
    if (ExtractMetadataField(comment, "TF", tempValue)) {
        metadata.timeframe = ParseTimeframeFromString(tempValue);
        if (metadata.timeframe != PERIOD_CURRENT) hasMetadata = true;
    }
    
    return hasMetadata;
}

//+------------------------------------------------------------------+
//| Trích xuất trường metadata từ comment                           |
//+------------------------------------------------------------------+
bool CRecoveryManager::ExtractMetadataField(string comment, string fieldName, string& value) {
    string searchPattern = fieldName + "=";
    int startPos = StringFind(comment, searchPattern);
    
    if (startPos == -1) {
        return false;
    }
    
    startPos += StringLen(searchPattern);
    int endPos = StringFind(comment, m_Config.metadataDelimiter, startPos);
    
    if (endPos == -1) {
        endPos = StringLen(comment);
    }
    
    value = StringSubstr(comment, startPos, endPos - startPos);
    StringTrimLeft(value);
    StringTrimRight(value);
    
    return StringLen(value) > 0;
}

//+------------------------------------------------------------------+
//| Tính tỷ lệ thành công phục hồi                                  |
//+------------------------------------------------------------------+
double CRecoveryManager::GetRecoverySuccessRate() const {
    if (m_TotalPositionsFound == 0) {
        return 0.0;
    }
    
    return (double)m_SuccessfulRecoveries / m_TotalPositionsFound * 100.0;
}

//+------------------------------------------------------------------+
//| Log thống kê phục hồi                                           |
//+------------------------------------------------------------------+
bool CRecoveryManager::LogRecoveryStatistics() {
    if (m_Logger == NULL) {
        return false;
    }
    
    string stats = StringFormat(
        "=== THỐNG KÊ PHỤC HỒI ===\n" +
        "Tổng vị thế tìm thấy: %d\n" +
        "Phục hồi thành công: %d\n" +
        "Phục hồi một phần: %d\n" +
        "Phục hồi thất bại: %d\n" +
        "Tỷ lệ thành công: %.2f%%\n" +
        "Thời gian phục hồi: %s",
        m_TotalPositionsFound,
        m_SuccessfulRecoveries,
        m_PartialRecoveries,
        m_FailedRecoveries,
        GetRecoverySuccessRate(),
        TimeToString(m_LastRecoveryTime)
    );
    
    LogRecoveryInfo("LogRecoveryStatistics", stats);
    
    return true;
}

//+------------------------------------------------------------------+
//| Resize mảng phục hồi                                            |
//+------------------------------------------------------------------+
bool CRecoveryManager::ResizeRecoveredArray(int newSize) {
    if (newSize <= 0) {
        return false;
    }
    
    return ArrayResize(m_RecoveredPositions, newSize) >= 0;
}

//+------------------------------------------------------------------+
//| Xóa dữ liệu phục hồi                                            |
//+------------------------------------------------------------------+
void CRecoveryManager::ClearRecoveredData() {
    ArrayFree(m_RecoveredPositions);
    m_RecoveredCount = 0;
}

//+------------------------------------------------------------------+
//| Log lỗi phục hồi                                                |
//+------------------------------------------------------------------+
void CRecoveryManager::LogRecoveryError(string function, string error, ulong ticket = 0) {
    if (m_Logger == NULL) return;
    string message = function + "(): " + error;
    if (ticket > 0) {
        message += StringFormat(" (Ticket: %d)", (int)ticket);
    }
    m_Logger->LogError("RecoveryManager", message, true);
}

//+------------------------------------------------------------------+
//| Log cảnh báo phục hồi                                           |
//+------------------------------------------------------------------+
void CRecoveryManager::LogRecoveryWarning(string function, string warning, ulong ticket = 0) {
    if (m_Logger != NULL) {
        string message = StringFormat("[%s] %s", function, warning);
        if (ticket > 0) {
            message += StringFormat(" (Ticket: %d)", (int)ticket);
        }
        m_Logger->LogWarning("RecoveryManager", message);
    }
}

//+------------------------------------------------------------------+
//| Log thông tin phục hồi                                          |
//+------------------------------------------------------------------+
void CRecoveryManager::LogRecoveryInfo(string function, string info, ulong ticket = 0) {
    if (m_Logger != NULL) {
        string message = StringFormat("[%s] %s", function, info);
        if (ticket > 0) {
            message += StringFormat(" (Ticket: %d)", (int)ticket);
        }
        m_Logger->LogInfo("RecoveryManager", message);
    }
}

// Các phương thức khác sẽ được implement trong phần tiếp theo...
// (Do giới hạn độ dài, chỉ hiển thị các phương thức chính)

} // END NAMESPACE ApexPullback
#endif // RECOVERYMANAGER_MQH_