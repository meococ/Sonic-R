//+------------------------------------------------------------------+
//|                FileCommunication.mqh - APEX Pullback EA v14.0   |
//+------------------------------------------------------------------+
#ifndef FILE_COMMUNICATION_MQH_
#define FILE_COMMUNICATION_MQH_

#include "CommonStructs.mqh"

// BẮT ĐẦU NAMESPACE
namespace ApexPullback {

//+------------------------------------------------------------------+
//| Communication Message Types                                      |
//+------------------------------------------------------------------+
enum ENUM_MESSAGE_TYPE {
    MSG_PROPOSAL,           // Slave -> Master: Trading proposal
    MSG_DECISION,           // Master -> Slave: Trading decision
    MSG_STATUS_UPDATE,      // Slave -> Master: Status update
    MSG_PORTFOLIO_UPDATE,   // Master -> Slave: Portfolio update
    MSG_EMERGENCY_STOP,     // Master -> Slave: Emergency stop
    MSG_HEARTBEAT,          // Bidirectional: Health check
    MSG_UNKNOWN
};

//+------------------------------------------------------------------+
//| Decision Types from Master                                       |
//+------------------------------------------------------------------+
enum ENUM_DECISION_TYPE {
    DECISION_APPROVE,       // Approve with original parameters
    DECISION_APPROVE_MODIFIED, // Approve with modified parameters
    DECISION_REJECT,        // Reject the proposal
    DECISION_DEFER,         // Defer decision (wait)
    DECISION_UNKNOWN
};

//+------------------------------------------------------------------+
//| Rejection Reasons                                                |
//+------------------------------------------------------------------+
enum ENUM_REJECTION_REASON {
    REJECT_HIGH_CORRELATION,    // High correlation with existing positions
    REJECT_MAX_EXPOSURE,        // Maximum exposure reached
    REJECT_LOW_CONFIDENCE,      // Signal confidence too low
    REJECT_POOR_RISK_REWARD,    // Poor risk/reward ratio
    REJECT_MARKET_CONDITIONS,   // Unfavorable market conditions
    REJECT_NEWS_EVENT,          // News event conflict
    REJECT_DRAWDOWN_LIMIT,      // Drawdown limit reached
    REJECT_VOLATILITY_HIGH,     // Volatility too high
    REJECT_SPREAD_TOO_WIDE,     // Spread too wide
    REJECT_TIME_FILTER,         // Time filter restriction
    REJECT_UNKNOWN
};

//+------------------------------------------------------------------+
//| Enum cho các loại message Portfolio (Legacy Support)            |
//+------------------------------------------------------------------+
enum ENUM_PORTFOLIO_MESSAGE_TYPE {
    PM_MSG_PROPOSAL = 0,         // Đề xuất giao dịch
    PM_MSG_APPROVAL,             // Phê duyệt
    PM_MSG_REJECTION,            // Từ chối
    PM_MSG_STATUS,               // Trạng thái
    PM_MSG_HEARTBEAT,            // Heartbeat
    PM_MSG_EMERGENCY_STOP,       // Dừng khẩn cấp
    PM_MSG_RISK_WARNING,         // Cảnh báo rủi ro
    PM_MSG_PORTFOLIO_UPDATE,     // Cập nhật portfolio
    PM_MSG_CORRELATION_ALERT,    // Cảnh báo correlation
    PM_MSG_EXPOSURE_LIMIT,       // Giới hạn exposure
    PM_MSG_PERFORMANCE_REPORT    // Báo cáo hiệu suất
};

//+------------------------------------------------------------------+
//| Trading Proposal Structure (Slave -> Master)                    |
//+------------------------------------------------------------------+
struct TradingProposal {
    // Basic Trade Information
    string SlaveEAID;               // Unique ID of slave EA
    string Symbol;                  // Trading symbol
    ENUM_ORDER_TYPE OrderType;      // BUY or SELL
    double EntryPrice;              // Proposed entry price
    double StopLoss;                // Proposed stop loss
    double TakeProfit;              // Proposed take profit
    double ProposedLotSize;         // Proposed lot size
    
    // Signal Quality Metrics
    double SignalConfidenceScore;   // Signal confidence (0.0 - 1.0)
    double RiskRewardRatio;         // Risk/reward ratio
    double ExpectedProfitPips;      // Expected profit in pips
    double MaxRiskPips;             // Maximum risk in pips
    
    // Market Context
    ENUM_MARKET_REGIME MarketRegime; // Current market regime
    ENUM_TRADING_STRATEGY ProposedStrategy; // Proposed strategy
    double CurrentVolatility;       // Current volatility (ATR)
    double CurrentSpread;           // Current spread
    
    // Timing Information
    datetime ProposalTime;          // Time of proposal
    datetime ExpiryTime;            // Proposal expiry time
    int UrgencyLevel;               // Urgency level (1-5)
    
    // Additional Context
    string SignalReason;            // Reason for signal generation
    double CorrelationRisk;         // Estimated correlation risk
    bool HasNewsConflict;           // News event conflict flag
    
    // Constructor
    TradingProposal() {
        SlaveEAID = "";
        Symbol = "";
        OrderType = WRONG_VALUE;
        EntryPrice = 0.0;
        StopLoss = 0.0;
        TakeProfit = 0.0;
        ProposedLotSize = 0.0;
        SignalConfidenceScore = 0.0;
        RiskRewardRatio = 0.0;
        ExpectedProfitPips = 0.0;
        MaxRiskPips = 0.0;
        MarketRegime = REGIME_UNKNOWN;
        ProposedStrategy = STRATEGY_UNKNOWN;
        CurrentVolatility = 0.0;
        CurrentSpread = 0.0;
        ProposalTime = 0;
        ExpiryTime = 0;
        UrgencyLevel = 1;
        SignalReason = "";
        CorrelationRisk = 0.0;
        HasNewsConflict = false;
    }
};

//+------------------------------------------------------------------+
//| Trading Decision Structure (Master -> Slave)                    |
//+------------------------------------------------------------------+
struct TradingDecision {
    // Decision Information
    string ProposalID;              // Reference to original proposal
    string SlaveEAID;               // Target slave EA ID
    ENUM_DECISION_TYPE DecisionType; // Type of decision
    
    // Approved Parameters (if approved)
    double FinalLotSize;            // Final approved lot size
    double FinalEntryPrice;         // Final entry price (if modified)
    double FinalStopLoss;           // Final stop loss (if modified)
    double FinalTakeProfit;         // Final take profit (if modified)
    
    // Risk Management
    double AllocatedRiskPercent;    // Allocated risk percentage
    double MaxPositionSize;         // Maximum position size allowed
    double RiskAdjustmentFactor;    // Risk adjustment factor
    
    // Rejection Information (if rejected)
    ENUM_REJECTION_REASON RejectionReason; // Reason for rejection
    string RejectionDetails;        // Detailed rejection explanation
    
    // Portfolio Context
    double CurrentPortfolioRisk;    // Current portfolio risk level
    double AvailableRiskCapacity;   // Available risk capacity
    int CurrentPositionCount;       // Current number of positions
    
    // Timing
    datetime DecisionTime;          // Time of decision
    datetime ValidUntil;            // Decision validity period
    
    // Additional Instructions
    string SpecialInstructions;     // Special trading instructions
    bool RequireConfirmation;       // Require confirmation before execution
    
    // Constructor
    TradingDecision() {
        ProposalID = "";
        SlaveEAID = "";
        DecisionType = DECISION_UNKNOWN;
        FinalLotSize = 0.0;
        FinalEntryPrice = 0.0;
        FinalStopLoss = 0.0;
        FinalTakeProfit = 0.0;
        AllocatedRiskPercent = 0.0;
        MaxPositionSize = 0.0;
        RiskAdjustmentFactor = 1.0;
        RejectionReason = REJECT_UNKNOWN;
        RejectionDetails = "";
        CurrentPortfolioRisk = 0.0;
        AvailableRiskCapacity = 0.0;
        CurrentPositionCount = 0;
        DecisionTime = 0;
        ValidUntil = 0;
        SpecialInstructions = "";
        RequireConfirmation = false;
    }
};

//+------------------------------------------------------------------+
//| Status Update Structure (Slave -> Master)                       |
//+------------------------------------------------------------------+
struct StatusUpdate {
    // EA Information
    string SlaveEAID;               // Slave EA ID
    string Symbol;                  // Trading symbol
    datetime UpdateTime;            // Update timestamp
    
    // Performance Metrics
    double CurrentEquity;           // Current equity
    double CurrentBalance;          // Current balance
    double CurrentDrawdown;         // Current drawdown %
    double DailyPnL;               // Daily P&L
    double WeeklyPnL;              // Weekly P&L
    double MonthlyPnL;             // Monthly P&L
    
    // Position Information
    int OpenPositions;              // Number of open positions
    double TotalExposure;           // Total exposure amount
    double UnrealizedPnL;          // Unrealized P&L
    double UsedMargin;             // Used margin
    
    // Risk Metrics
    double CurrentRiskPercent;      // Current risk percentage
    double MaxDrawdownToday;        // Maximum drawdown today
    bool IsRiskLimitExceeded;       // Risk limit exceeded flag
    bool IsEmergencyStopActive;     // Emergency stop status
    
    // Market Conditions
    ENUM_MARKET_REGIME CurrentRegime; // Current market regime
    double CurrentVolatility;       // Current volatility
    double AverageSpread;           // Average spread
    
    // EA Health
    bool IsEAHealthy;               // EA health status
    string LastError;               // Last error message
    int ErrorCount;                 // Error count
    datetime LastTradeTime;         // Last trade execution time
    
    // Constructor
    StatusUpdate() {
        SlaveEAID = "";
        Symbol = "";
        UpdateTime = 0;
        CurrentEquity = 0.0;
        CurrentBalance = 0.0;
        CurrentDrawdown = 0.0;
        DailyPnL = 0.0;
        WeeklyPnL = 0.0;
        MonthlyPnL = 0.0;
        OpenPositions = 0;
        TotalExposure = 0.0;
        UnrealizedPnL = 0.0;
        UsedMargin = 0.0;
        CurrentRiskPercent = 0.0;
        MaxDrawdownToday = 0.0;
        IsRiskLimitExceeded = false;
        IsEmergencyStopActive = false;
        CurrentRegime = REGIME_UNKNOWN;
        CurrentVolatility = 0.0;
        AverageSpread = 0.0;
        IsEAHealthy = true;
        LastError = "";
        ErrorCount = 0;
        LastTradeTime = 0;
    }
};

//+------------------------------------------------------------------+
//| Communication Message Structure                                   |
//+------------------------------------------------------------------+
struct CommunicationMessage {
    // Header
    ENUM_MESSAGE_TYPE MessageType;  // Type of message
    string MessageID;               // Unique message ID
    string SenderID;                // Sender EA ID
    string RecipientID;             // Recipient EA ID (empty for broadcast)
    datetime Timestamp;             // Message timestamp
    int Priority;                   // Message priority (1-5)
    
    // Payload (only one should be used based on MessageType)
    TradingProposal Proposal;       // Trading proposal data
    TradingDecision Decision;       // Trading decision data
    StatusUpdate Status;            // Status update data
    
    // Additional Data
    string AdditionalData;          // Additional JSON or string data
    bool RequiresAcknowledgment;    // Requires acknowledgment flag
    datetime ExpiryTime;            // Message expiry time
    
    // Constructor
    CommunicationMessage() {
        MessageType = MSG_UNKNOWN;
        MessageID = "";
        SenderID = "";
        RecipientID = "";
        Timestamp = 0;
        Priority = 3;
        AdditionalData = "";
        RequiresAcknowledgment = false;
        ExpiryTime = 0;
    }
};

//+------------------------------------------------------------------+
//| Cấu trúc thông điệp Portfolio nâng cao (Legacy Support)         |
//+------------------------------------------------------------------+
struct PortfolioMessage {
    // Message Header
    datetime timestamp;           // Thời gian tạo message
    string messageId;             // ID duy nhất của message
    string senderEA;             // Tên EA gửi
    string receiverEA;           // Tên EA nhận ("ALL" cho broadcast)
    ENUM_PORTFOLIO_MESSAGE_TYPE messageType; // Loại message
    int priority;                // Độ ưu tiên (1-10)
    bool processed;              // Đã xử lý chưa
    datetime expiryTime;         // Thời gian hết hạn
    
    // Trade Information
    string symbol;               // Symbol liên quan
    int orderType;               // Loại lệnh (OP_BUY, OP_SELL)
    double lotSize;              // Lot size đề xuất
    double entryPrice;           // Giá vào dự kiến
    double stopLoss;             // Stop Loss
    double takeProfit;           // Take Profit
    string tradeReason;          // Lý do giao dịch
    
    // Risk Management
    double riskPercent;          // Risk % của account
    double correlationRisk;      // Rủi ro correlation
    double exposurePercent;      // % exposure hiện tại
    double maxDrawdownRisk;      // Rủi ro drawdown tối đa
    
    // Portfolio Data
    double portfolioEquity;      // Equity tổng
    double portfolioBalance;     // Balance tổng
    double portfolioProfit;      // Profit/Loss tổng
    double portfolioMargin;      // Margin sử dụng
    int totalPositions;          // Tổng số positions
    
    // Status & Alerts
    string statusMessage;        // Thông điệp trạng thái
    string alertMessage;         // Thông điệp cảnh báo
    double alertSeverity;        // Mức độ nghiêm trọng (0-100)
    bool requiresImmediate;      // Yêu cầu xử lý ngay
    
    // Performance Metrics
    double winRate;              // Tỷ lệ thắng
    double profitFactor;         // Profit Factor
    double sharpeRatio;          // Sharpe Ratio
    double maxDrawdown;          // Max Drawdown
    
    // Constructor
    PortfolioMessage() {
        timestamp = TimeCurrent();
        messageId = "";
        senderEA = "";
        receiverEA = "";
        messageType = PM_MSG_STATUS;
        priority = 5;
        processed = false;
        expiryTime = TimeCurrent() + 300; // 5 minutes default
        
        symbol = "";
        orderType = -1;
        lotSize = 0.0;
        entryPrice = 0.0;
        stopLoss = 0.0;
        takeProfit = 0.0;
        tradeReason = "";
        
        riskPercent = 0.0;
        correlationRisk = 0.0;
        exposurePercent = 0.0;
        maxDrawdownRisk = 0.0;
        
        portfolioEquity = 0.0;
        portfolioBalance = 0.0;
        portfolioProfit = 0.0;
        portfolioMargin = 0.0;
        totalPositions = 0;
        
        statusMessage = "";
        alertMessage = "";
        alertSeverity = 0.0;
        requiresImmediate = false;
        
        winRate = 0.0;
        profitFactor = 0.0;
        sharpeRatio = 0.0;
        maxDrawdown = 0.0;
    }
};

//+------------------------------------------------------------------+
//| Cấu trúc thông điệp Master/Slave (Backward Compatibility)      |
//+------------------------------------------------------------------+
struct MasterSlaveMessage {
    datetime timestamp;           // Thời gian tạo message
    string senderEA;             // Tên EA gửi
    string receiverEA;           // Tên EA nhận ("ALL" cho broadcast)
    string messageType;          // Loại message: "PROPOSAL", "APPROVAL", "REJECTION", "STATUS"
    string symbol;               // Symbol liên quan
    int orderType;               // Loại lệnh (OP_BUY, OP_SELL)
    double lotSize;              // Lot size đề xuất
    double entryPrice;           // Giá vào dự kiến
    double stopLoss;             // Stop Loss
    double takeProfit;           // Take Profit
    string reason;               // Lý do đề xuất/từ chối
    int priority;                // Độ ưu tiên (1-10)
    bool processed;              // Đã xử lý chưa
    
    // Constructor
    MasterSlaveMessage() {
        timestamp = TimeCurrent();
        senderEA = "";
        receiverEA = "";
        messageType = "";
        symbol = "";
        orderType = -1;
        lotSize = 0.0;
        entryPrice = 0.0;
        stopLoss = 0.0;
        takeProfit = 0.0;
        reason = "";
        priority = 5;
        processed = false;
    }
};

//+------------------------------------------------------------------+
//| Lớp quản lý giao tiếp Portfolio nâng cao                       |
//+------------------------------------------------------------------+
class CFileCommunication {
private:
    CLogger* m_Logger;
    string m_CommunicationFolder;
    string m_LockFilePrefix;
    string m_MessageFilePrefix;
    string m_PortfolioPrefix;
    string m_HeartbeatPrefix;
    string m_EAIdentifier;
    bool m_IsMaster;
    int m_MaxRetries;
    int m_LockTimeoutMs;
    
    // Portfolio Management
    datetime m_LastHeartbeat;
    int m_HeartbeatInterval;
    bool m_IsPortfolioMode;
    string m_PortfolioId;
    
    // Message Queue Management
    PortfolioMessage m_MessageQueue[];
    int m_QueueSize;
    int m_MaxQueueSize;
    
    // Connection Monitoring
    string m_ConnectedEAs[];
    datetime m_LastSeenEAs[];
    int m_ConnectionTimeout;
    
public:
    CFileCommunication();
    ~CFileCommunication();
    
    // Initialization
    bool Initialize(CLogger* logger, string eaIdentifier, bool isMaster = false);
    bool InitializePortfolioMode(string portfolioId, int heartbeatInterval = 30);
    void Cleanup();
    
    // Advanced Communication Methods
     bool SendTradingProposal(const TradingProposal& proposal);
     bool SendTradingDecision(const TradingDecision& decision);
     bool SendStatusUpdate(const StatusUpdate& status);
     bool SendEmergencyStop(const string& targetSlaveId, const string& reason);
     bool SendHeartbeat(const string& targetId);
     
     // Message Reception
     bool ReceiveCommunicationMessages(CommunicationMessage& messages[]);
     bool ParseCommunicationMessage(const string& messageData, CommunicationMessage& message);
     
     // V14.0: JSON Protocol for Master-Slave Architecture
     bool SendJSONProposal(const TradingProposal& proposal);
     bool SendJSONDecision(const TradingDecision& decision);
     bool ReceiveJSONMessages(string& jsonMessages[]);
     string SerializeProposalToJSON(const TradingProposal& proposal);
     string SerializeDecisionToJSON(const TradingDecision& decision);
     bool ParseJSONProposal(const string& jsonData, TradingProposal& proposal);
     bool ParseJSONDecision(const string& jsonData, TradingDecision& decision);
     string GenerateSignalID(const string& symbol, datetime timestamp);
    
    // Message Processing
    bool ProcessCommunicationMessage(const CommunicationMessage& message);
    string GenerateMessageID();
    bool ValidateMessage(const CommunicationMessage& message);
    string SerializeTradingProposal(const TradingProposal& proposal);
    string SerializeTradingDecision(const TradingDecision& decision);
    string SerializeStatusUpdate(const StatusUpdate& status);
    
    // Legacy Message operations (Backward Compatibility)
    bool SendMessage(const MasterSlaveMessage& message);
    bool ReceiveMessages(MasterSlaveMessage& messages[]);
    bool SendProposal(string symbol, int orderType, double lotSize, double entryPrice, 
                     double stopLoss, double takeProfit, string reason, int priority = 5);
    bool SendApproval(string originalSender, string symbol, string reason = "");
    bool SendRejection(string originalSender, string symbol, string reason = "");
    bool SendStatus(string status, string details = "");
    
    // Portfolio Message Operations
    bool SendPortfolioMessage(const PortfolioMessage& message);
    bool ReceivePortfolioMessages(PortfolioMessage& messages[]);
    bool SendTradeProposal(string symbol, int orderType, double lotSize, double entryPrice,
                          double stopLoss, double takeProfit, string reason, 
                          double riskPercent, double correlationRisk, int priority = 5);
    bool SendRiskWarning(string symbol, double severity, string alertMessage, bool immediate = false);
    bool SendEmergencyStop(string reason, double severity = 100.0);
    bool SendPortfolioUpdate(double equity, double balance, double profit, double margin, int positions);
    bool SendPerformanceReport(double winRate, double profitFactor, double sharpeRatio, double maxDD);
    bool SendHeartbeat();
    
    // Portfolio Management
    bool IsPortfolioModeActive() const { return m_IsPortfolioMode; }
    string GetPortfolioId() const { return m_PortfolioId; }
    bool CheckConnectedEAs();
    bool IsEAConnected(string eaId);
    int GetConnectedEACount();
    string GetConnectedEAsList();
    
    // Message Queue Management
    bool AddToQueue(const PortfolioMessage& message);
    bool ProcessQueue();
    bool ClearQueue();
    int GetQueueSize() const { return m_QueueSize; }
    bool IsQueueFull() const { return m_QueueSize >= m_MaxQueueSize; }
    
    // Advanced File operations
    bool CreateLockFile(string filename);
    bool ReleaseLockFile(string filename);
    bool WaitForLock(string filename, int timeoutMs = 5000);
    bool IsFileLocked(string filename);
    bool CreateBackupFile(string filename);
    bool RestoreFromBackup(string filename);
    
    // Enhanced Utility functions
    void CleanupOldMessages(int maxAgeMinutes = 60);
    void CleanupExpiredMessages();
    int GetPendingMessageCount();
    int GetPendingPortfolioMessageCount();
    bool HasPendingMessages();
    bool HasPendingPortfolioMessages();
    bool ValidateMessageIntegrity(const PortfolioMessage& message);
    
    // Monitoring & Diagnostics
    bool GenerateConnectionReport();
    bool GenerateMessageStatistics();
    double GetMessageThroughput(); // Messages per minute
    bool CheckSystemHealth();
    
private:
    // Legacy Helper Methods
    string GenerateMessageFilename();
    string GenerateLockFilename(string baseFilename);
    bool WriteMessageToFile(const MasterSlaveMessage& message, string filename);
    bool ReadMessageFromFile(MasterSlaveMessage& message, string filename);
    bool SerializeMessage(const MasterSlaveMessage& message, string& serialized);
    bool DeserializeMessage(string serialized, MasterSlaveMessage& message);
    void LogMessage(const MasterSlaveMessage& message, string action);
    
    // Portfolio Helper Methods
    string GeneratePortfolioMessageFilename();
    string GenerateHeartbeatFilename();
    string GenerateMessageId();
    bool WritePortfolioMessageToFile(const PortfolioMessage& message, string filename);
    bool ReadPortfolioMessageFromFile(PortfolioMessage& message, string filename);
    bool SerializePortfolioMessage(const PortfolioMessage& message, string& serialized);
    bool DeserializePortfolioMessage(string serialized, PortfolioMessage& message);
    void LogPortfolioMessage(const PortfolioMessage& message, string action);
    
    // Connection Management
    bool UpdateEAConnection(string eaId);
    bool RemoveDisconnectedEAs();
    bool WriteHeartbeatFile();
    bool ReadHeartbeatFiles();
    
    // Queue Management
    bool ResizeQueue(int newSize);
    bool SortQueueByPriority();
    bool RemoveExpiredFromQueue();
    
    // Utility
    string MessageTypeToString(ENUM_PORTFOLIO_MESSAGE_TYPE msgType);
    ENUM_PORTFOLIO_MESSAGE_TYPE StringToMessageType(string msgTypeStr);
    bool IsValidSymbol(string symbol);
    bool IsValidPrice(double price);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CFileCommunication::CFileCommunication() {
    m_Logger = NULL;
    m_CommunicationFolder = "APEX_Communication";
    m_LockFilePrefix = "lock_";
    m_MessageFilePrefix = "msg_";
    m_EAIdentifier = "";
    m_IsMaster = false;
    m_MaxRetries = 3;
    m_LockTimeoutMs = 5000;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CFileCommunication::~CFileCommunication() {
    Cleanup();
}

//+------------------------------------------------------------------+
//| Khởi tạo hệ thống giao tiếp                                     |
//+------------------------------------------------------------------+
bool CFileCommunication::Initialize(CLogger* logger, string eaIdentifier, bool isMaster = false) {
    m_Logger = logger;
    m_EAIdentifier = eaIdentifier;
    m_IsMaster = isMaster;
    
    // Tạo thư mục giao tiếp nếu chưa có
    if (!FolderCreate(m_CommunicationFolder, FILE_COMMON)) {
        if (GetLastError() != ERR_FILE_CANNOT_OPEN) { // Folder might already exist
            if (m_Logger) {
                m_Logger->LogError(StringFormat("Failed to create communication folder: %s, Error: %d", 
                    m_CommunicationFolder, GetLastError()));
            }
            return false;
        }
    }
    
    // Cleanup old messages on startup
    CleanupOldMessages(60);
    
    if (m_Logger) {
        m_Logger->LogInfo(StringFormat("FileCommunication initialized - EA: %s, Master: %s", 
            m_EAIdentifier, m_IsMaster ? "Yes" : "No"));
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Dọn dẹp tài nguyên                                              |
//+------------------------------------------------------------------+
void CFileCommunication::Cleanup() {
    // Release any locks held by this EA
    // Note: In practice, you might want to track which locks this EA holds
    if (m_Logger) {
        m_Logger->LogInfo("FileCommunication cleanup completed");
    }
}

//+------------------------------------------------------------------+
//| Advanced Communication Methods Implementation                    |
//+------------------------------------------------------------------+

// Send Trading Proposal (Slave -> Master)
bool CFileCommunication::SendTradingProposal(const TradingProposal& proposal) {
    CommunicationMessage message;
    message.MessageType = MSG_PROPOSAL;
    message.MessageID = GenerateMessageID();
    message.SenderID = proposal.SlaveEAID;
    message.RecipientID = "MASTER";
    message.Timestamp = TimeCurrent();
    message.Priority = proposal.UrgencyLevel;
    message.Proposal = proposal;
    message.RequiresAcknowledgment = true;
    message.ExpiryTime = proposal.ExpiryTime;
    
    return ProcessCommunicationMessage(message);
}

// Send Trading Decision (Master -> Slave)
bool CFileCommunication::SendTradingDecision(const TradingDecision& decision) {
    CommunicationMessage message;
    message.MessageType = MSG_DECISION;
    message.MessageID = GenerateMessageID();
    message.SenderID = "MASTER";
    message.RecipientID = decision.SlaveEAID;
    message.Timestamp = TimeCurrent();
    message.Priority = (decision.DecisionType == DECISION_REJECT) ? 5 : 3;
    message.Decision = decision;
    message.RequiresAcknowledgment = true;
    message.ExpiryTime = decision.ValidUntil;
    
    return ProcessCommunicationMessage(message);
}

// Send Status Update (Slave -> Master)
bool CFileCommunication::SendStatusUpdate(const StatusUpdate& status) {
    CommunicationMessage message;
    message.MessageType = MSG_STATUS_UPDATE;
    message.MessageID = GenerateMessageID();
    message.SenderID = status.SlaveEAID;
    message.RecipientID = "MASTER";
    message.Timestamp = TimeCurrent();
    message.Priority = status.IsRiskLimitExceeded ? 4 : 2;
    message.Status = status;
    message.RequiresAcknowledgment = false;
    message.ExpiryTime = TimeCurrent() + 300; // 5 minutes
    
    return ProcessCommunicationMessage(message);
}

// Process Communication Message
bool CFileCommunication::ProcessCommunicationMessage(const CommunicationMessage& message) {
    if (!ValidateMessage(message)) {
        return false;
    }
    
    // Serialize message to string format
    string messageData = "";
    messageData += "MessageType=" + IntegerToString((int)message.MessageType) + "|";
    messageData += "MessageID=" + message.MessageID + "|";
    messageData += "SenderID=" + message.SenderID + "|";
    messageData += "RecipientID=" + message.RecipientID + "|";
    messageData += "Timestamp=" + IntegerToString(message.Timestamp) + "|";
    messageData += "Priority=" + IntegerToString(message.Priority) + "|";
    
    // Add payload based on message type
    switch(message.MessageType) {
        case MSG_PROPOSAL:
            messageData += SerializeTradingProposal(message.Proposal);
            break;
        case MSG_DECISION:
            messageData += SerializeTradingDecision(message.Decision);
            break;
        case MSG_STATUS_UPDATE:
            messageData += SerializeStatusUpdate(message.Status);
            break;
        default:
            messageData += "AdditionalData=" + message.AdditionalData;
            break;
    }
    
    // Create filename based on message type and recipient
    string filename = m_CommunicationFolder + "\\" + message.RecipientID + "_" + 
                     IntegerToString((int)message.MessageType) + "_" + 
                     message.MessageID + ".msg";
    
    int handle = FileOpen(filename, FILE_WRITE | FILE_TXT | FILE_COMMON);
    if (handle == INVALID_HANDLE) {
        return false;
    }
    
    FileWriteString(handle, messageData);
    FileClose(handle);
    
    return true;
}

// Generate unique message ID
string CFileCommunication::GenerateMessageID() {
    static int messageCounter = 0;
    messageCounter++;
    return IntegerToString(TimeCurrent()) + "_" + IntegerToString(messageCounter);
}

// Validate message
bool CFileCommunication::ValidateMessage(const CommunicationMessage& message) {
    if (message.MessageType == MSG_UNKNOWN) return false;
    if (message.MessageID == "") return false;
    if (message.SenderID == "") return false;
    if (message.Timestamp <= 0) return false;
    
    return true;
}

// Serialize Trading Proposal
string CFileCommunication::SerializeTradingProposal(const TradingProposal& proposal) {
    string data = "";
    data += "SlaveEAID=" + proposal.SlaveEAID + "|";
    data += "Symbol=" + proposal.Symbol + "|";
    data += "OrderType=" + IntegerToString((int)proposal.OrderType) + "|";
    data += "EntryPrice=" + DoubleToString(proposal.EntryPrice, 5) + "|";
    data += "StopLoss=" + DoubleToString(proposal.StopLoss, 5) + "|";
    data += "TakeProfit=" + DoubleToString(proposal.TakeProfit, 5) + "|";
    data += "ProposedLotSize=" + DoubleToString(proposal.ProposedLotSize, 2) + "|";
    data += "SignalConfidenceScore=" + DoubleToString(proposal.SignalConfidenceScore, 3) + "|";
    data += "RiskRewardRatio=" + DoubleToString(proposal.RiskRewardRatio, 2) + "|";
    data += "MarketRegime=" + IntegerToString((int)proposal.MarketRegime) + "|";
    data += "ProposedStrategy=" + IntegerToString((int)proposal.ProposedStrategy) + "|";
    data += "SignalReason=" + proposal.SignalReason + "|";
    data += "UrgencyLevel=" + IntegerToString(proposal.UrgencyLevel);
    
    return data;
}

// Serialize Trading Decision
string CFileCommunication::SerializeTradingDecision(const TradingDecision& decision) {
    string data = "";
    data += "ProposalID=" + decision.ProposalID + "|";
    data += "SlaveEAID=" + decision.SlaveEAID + "|";
    data += "DecisionType=" + IntegerToString((int)decision.DecisionType) + "|";
    data += "FinalLotSize=" + DoubleToString(decision.FinalLotSize, 2) + "|";
    data += "AllocatedRiskPercent=" + DoubleToString(decision.AllocatedRiskPercent, 2) + "|";
    data += "RiskAdjustmentFactor=" + DoubleToString(decision.RiskAdjustmentFactor, 2) + "|";
    
    if (decision.DecisionType == DECISION_REJECT) {
        data += "RejectionReason=" + IntegerToString((int)decision.RejectionReason) + "|";
        data += "RejectionDetails=" + decision.RejectionDetails + "|";
    }
    
    data += "SpecialInstructions=" + decision.SpecialInstructions;
    
    return data;
}

// Serialize Status Update
string CFileCommunication::SerializeStatusUpdate(const StatusUpdate& status) {
    string data = "";
    data += "SlaveEAID=" + status.SlaveEAID + "|";
    data += "Symbol=" + status.Symbol + "|";
    data += "CurrentEquity=" + DoubleToString(status.CurrentEquity, 2) + "|";
    data += "CurrentDrawdown=" + DoubleToString(status.CurrentDrawdown, 2) + "|";
    data += "DailyPnL=" + DoubleToString(status.DailyPnL, 2) + "|";
    data += "OpenPositions=" + IntegerToString(status.OpenPositions) + "|";
    data += "TotalExposure=" + DoubleToString(status.TotalExposure, 2) + "|";
    data += "CurrentRiskPercent=" + DoubleToString(status.CurrentRiskPercent, 2) + "|";
    data += "IsRiskLimitExceeded=" + (status.IsRiskLimitExceeded ? "true" : "false") + "|";
    data += "IsEmergencyStopActive=" + (status.IsEmergencyStopActive ? "true" : "false") + "|";
    data += "IsEAHealthy=" + (status.IsEAHealthy ? "true" : "false") + "|";
    data += "LastError=" + status.LastError;
    
    return data;
 }
 
 // Send Emergency Stop
 bool CFileCommunication::SendEmergencyStop(const string& targetSlaveId, const string& reason) {
     CommunicationMessage message;
     message.MessageType = MSG_EMERGENCY_STOP;
     message.MessageID = GenerateMessageID();
     message.SenderID = "MASTER";
     message.RecipientID = targetSlaveId;
     message.Timestamp = TimeCurrent();
     message.Priority = 5; // Highest priority
     message.AdditionalData = "Reason=" + reason;
     message.RequiresAcknowledgment = true;
     message.ExpiryTime = TimeCurrent() + 60; // 1 minute
     
     return ProcessCommunicationMessage(message);
 }
 
 // Send Heartbeat
 bool CFileCommunication::SendHeartbeat(const string& targetId) {
     CommunicationMessage message;
     message.MessageType = MSG_HEARTBEAT;
     message.MessageID = GenerateMessageID();
     message.SenderID = m_EAInstanceId;
     message.RecipientID = targetId;
     message.Timestamp = TimeCurrent();
     message.Priority = 1; // Low priority
     message.RequiresAcknowledgment = false;
     message.ExpiryTime = TimeCurrent() + 30; // 30 seconds
     
     return ProcessCommunicationMessage(message);
 }
 
 // Receive Communication Messages
 bool CFileCommunication::ReceiveCommunicationMessages(CommunicationMessage& messages[]) {
     ArrayResize(messages, 0);
     
     string searchPattern = m_CommunicationFolder + "\\" + m_EAInstanceId + "_*.msg";
     string filename;
     long searchHandle = FileFindFirst(searchPattern, filename);
     
     if (searchHandle == INVALID_HANDLE) {
         return false;
     }
     
     do {
         string fullPath = m_CommunicationFolder + "\\" + filename;
         int handle = FileOpen(fullPath, FILE_READ | FILE_TXT | FILE_COMMON);
         
         if (handle != INVALID_HANDLE) {
             string messageData = FileReadString(handle);
             FileClose(handle);
             
             CommunicationMessage message;
             if (ParseCommunicationMessage(messageData, message)) {
                 int size = ArraySize(messages);
                 ArrayResize(messages, size + 1);
                 messages[size] = message;
             }
             
             // Delete processed message file
             FileDelete(fullPath, FILE_COMMON);
         }
     } while (FileFindNext(searchHandle, filename));
     
     FileFindClose(searchHandle);
     
     return ArraySize(messages) > 0;
 }
 
 // Parse Communication Message
 bool CFileCommunication::ParseCommunicationMessage(const string& messageData, CommunicationMessage& message) {
     string parts[];
     int count = StringSplit(messageData, '|', parts);
     
     if (count < 6) return false;
     
     // Parse header
     for (int i = 0; i < count; i++) {
         string keyValue[];
         if (StringSplit(parts[i], '=', keyValue) == 2) {
             string key = keyValue[0];
             string value = keyValue[1];
             
             if (key == "MessageType") {
                 message.MessageType = (ENUM_MESSAGE_TYPE)StringToInteger(value);
             } else if (key == "MessageID") {
                 message.MessageID = value;
             } else if (key == "SenderID") {
                 message.SenderID = value;
             } else if (key == "RecipientID") {
                 message.RecipientID = value;
             } else if (key == "Timestamp") {
                 message.Timestamp = (datetime)StringToInteger(value);
             } else if (key == "Priority") {
                 message.Priority = StringToInteger(value);
             }
         }
     }
     
     return true;
 }
 
 //+------------------------------------------------------------------+
 //| Legacy Message Operations (Backward Compatibility)              |
 //+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Gửi message                                                      |
//+------------------------------------------------------------------+
bool CFileCommunication::SendMessage(const MasterSlaveMessage& message) {
    string filename = GenerateMessageFilename();
    string lockFilename = GenerateLockFilename(filename);
    
    // Tạo lock file
    if (!CreateLockFile(lockFilename)) {
        if (m_Logger) {
            m_Logger->LogWarning(StringFormat("Failed to create lock for message file: %s", filename));
        }
        return false;
    }
    
    bool success = false;
    
    // Ghi message vào file
    if (WriteMessageToFile(message, filename)) {
        success = true;
        LogMessage(message, "SENT");
    } else {
        if (m_Logger) {
            m_Logger->LogError(StringFormat("Failed to write message to file: %s", filename));
        }
    }
    
    // Release lock
    ReleaseLockFile(lockFilename);
    
    return success;
}

//+------------------------------------------------------------------+
//| Nhận messages                                                    |
//+------------------------------------------------------------------+
bool CFileCommunication::ReceiveMessages(MasterSlaveMessage& messages[]) {
    ArrayResize(messages, 0);
    
    string searchPattern = m_CommunicationFolder + "\\" + m_MessageFilePrefix + "*.txt";
    string filename;
    long searchHandle = FileFindFirst(searchPattern, filename, FILE_COMMON);
    
    if (searchHandle == INVALID_HANDLE) {
        return true; // No messages found, not an error
    }
    
    do {
        string fullPath = m_CommunicationFolder + "\\" + filename;
        string lockFilename = GenerateLockFilename(fullPath);
        
        // Kiểm tra xem file có bị lock không
        if (!IsFileLocked(lockFilename)) {
            // Tạo lock để đọc
            if (CreateLockFile(lockFilename)) {
                MasterSlaveMessage msg;
                if (ReadMessageFromFile(msg, fullPath)) {
                    // Kiểm tra xem message có dành cho EA này không
                    if (msg.receiverEA == "ALL" || msg.receiverEA == m_EAIdentifier) {
                        // Thêm vào array
                        int newSize = ArraySize(messages) + 1;
                        ArrayResize(messages, newSize);
                        messages[newSize - 1] = msg;
                        
                        LogMessage(msg, "RECEIVED");
                    }
                    
                    // Xóa file message sau khi đọc (hoặc đánh dấu đã xử lý)
                    FileDelete(fullPath, FILE_COMMON);
                }
                
                ReleaseLockFile(lockFilename);
            }
        }
    } while (FileFindNext(searchHandle, filename));
    
    FileFindClose(searchHandle);
    
    return true;
}

//+------------------------------------------------------------------+
//| Gửi đề xuất giao dịch                                           |
//+------------------------------------------------------------------+
bool CFileCommunication::SendProposal(string symbol, int orderType, double lotSize, double entryPrice,
                                      double stopLoss, double takeProfit, string reason, int priority = 5) {
    MasterSlaveMessage msg;
    msg.senderEA = m_EAIdentifier;
    msg.receiverEA = "MASTER"; // Gửi đến Master EA
    msg.messageType = "PROPOSAL";
    msg.symbol = symbol;
    msg.orderType = orderType;
    msg.lotSize = lotSize;
    msg.entryPrice = entryPrice;
    msg.stopLoss = stopLoss;
    msg.takeProfit = takeProfit;
    msg.reason = reason;
    msg.priority = priority;
    
    return SendMessage(msg);
}

//+------------------------------------------------------------------+
//| Gửi phê duyệt                                                   |
//+------------------------------------------------------------------+
bool CFileCommunication::SendApproval(string originalSender, string symbol, string reason = "") {
    MasterSlaveMessage msg;
    msg.senderEA = m_EAIdentifier;
    msg.receiverEA = originalSender;
    msg.messageType = "APPROVAL";
    msg.symbol = symbol;
    msg.reason = reason;
    
    return SendMessage(msg);
}

//+------------------------------------------------------------------+
//| Gửi từ chối                                                     |
//+------------------------------------------------------------------+
bool CFileCommunication::SendRejection(string originalSender, string symbol, string reason = "") {
    MasterSlaveMessage msg;
    msg.senderEA = m_EAIdentifier;
    msg.receiverEA = originalSender;
    msg.messageType = "REJECTION";
    msg.symbol = symbol;
    msg.reason = reason;
    
    return SendMessage(msg);
}

//+------------------------------------------------------------------+
//| Gửi trạng thái                                                  |
//+------------------------------------------------------------------+
bool CFileCommunication::SendStatus(string status, string details = "") {
    MasterSlaveMessage msg;
    msg.senderEA = m_EAIdentifier;
    msg.receiverEA = "ALL";
    msg.messageType = "STATUS";
    msg.reason = status + (details != "" ? " - " + details : "");
    
    return SendMessage(msg);
}

//+------------------------------------------------------------------+
//| Tạo lock file                                                   |
//+------------------------------------------------------------------+
bool CFileCommunication::CreateLockFile(string filename) {
    for (int retry = 0; retry < m_MaxRetries; retry++) {
        int handle = FileOpen(filename, FILE_WRITE | FILE_TXT | FILE_COMMON);
        if (handle != INVALID_HANDLE) {
            FileWriteString(handle, StringFormat("Locked by %s at %s", m_EAIdentifier, TimeToString(TimeCurrent())));
            FileClose(handle);
            return true;
        }
        
        Sleep(100); // Wait 100ms before retry
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Giải phóng lock file                                            |
//+------------------------------------------------------------------+
bool CFileCommunication::ReleaseLockFile(string filename) {
    return FileDelete(filename, FILE_COMMON);
}

//+------------------------------------------------------------------+
//| Chờ lock được giải phóng                                        |
//+------------------------------------------------------------------+
bool CFileCommunication::WaitForLock(string filename, int timeoutMs = 5000) {
    datetime startTime = GetTickCount();
    
    while (IsFileLocked(filename)) {
        if (GetTickCount() - startTime > timeoutMs) {
            return false; // Timeout
        }
        Sleep(50);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Kiểm tra file có bị lock không                                  |
//+------------------------------------------------------------------+
bool CFileCommunication::IsFileLocked(string filename) {
    return FileIsExist(filename, FILE_COMMON);
}

//+------------------------------------------------------------------+
//| Dọn dẹp messages cũ                                             |
//+------------------------------------------------------------------+
void CFileCommunication::CleanupOldMessages(int maxAgeMinutes = 60) {
    string searchPattern = m_CommunicationFolder + "\\" + m_MessageFilePrefix + "*.txt";
    string filename;
    long searchHandle = FileFindFirst(searchPattern, filename, FILE_COMMON);
    
    if (searchHandle == INVALID_HANDLE) {
        return;
    }
    
    datetime cutoffTime = TimeCurrent() - maxAgeMinutes * 60;
    int deletedCount = 0;
    
    do {
        string fullPath = m_CommunicationFolder + "\\" + filename;
        
        // Lấy thời gian tạo file
        datetime fileTime;
        if (FileGetInteger(fullPath, FILE_CREATE_DATE, fileTime, FILE_COMMON)) {
            if (fileTime < cutoffTime) {
                if (FileDelete(fullPath, FILE_COMMON)) {
                    deletedCount++;
                }
            }
        }
    } while (FileFindNext(searchHandle, filename));
    
    FileFindClose(searchHandle);
    
    if (deletedCount > 0 && m_Logger) {
        m_Logger->LogInfo(StringFormat("Cleaned up %d old message files", deletedCount));
    }
}

//+------------------------------------------------------------------+
//| Đếm số message đang chờ                                         |
//+------------------------------------------------------------------+
int CFileCommunication::GetPendingMessageCount() {
    string searchPattern = m_CommunicationFolder + "\\" + m_MessageFilePrefix + "*.txt";
    string filename;
    long searchHandle = FileFindFirst(searchPattern, filename, FILE_COMMON);
    
    if (searchHandle == INVALID_HANDLE) {
        return 0;
    }
    
    int count = 0;
    do {
        count++;
    } while (FileFindNext(searchHandle, filename));
    
    FileFindClose(searchHandle);
    return count;
}

//+------------------------------------------------------------------+
//| Kiểm tra có message đang chờ không                              |
//+------------------------------------------------------------------+
bool CFileCommunication::HasPendingMessages() {
    return GetPendingMessageCount() > 0;
}

//+------------------------------------------------------------------+
//| Tạo tên file message                                            |
//+------------------------------------------------------------------+
string CFileCommunication::GenerateMessageFilename() {
    return StringFormat("%s\\%s%s_%d_%d.txt", 
        m_CommunicationFolder, 
        m_MessageFilePrefix, 
        m_EAIdentifier, 
        TimeCurrent(), 
        GetTickCount());
}

//+------------------------------------------------------------------+
//| Tạo tên file lock                                               |
//+------------------------------------------------------------------+
string CFileCommunication::GenerateLockFilename(string baseFilename) {
    return baseFilename + ".lock";
}

//+------------------------------------------------------------------+
//| Ghi message vào file                                            |
//+------------------------------------------------------------------+
bool CFileCommunication::WriteMessageToFile(const MasterSlaveMessage& message, string filename) {
    string serialized;
    if (!SerializeMessage(message, serialized)) {
        return false;
    }
    
    int handle = FileOpen(filename, FILE_WRITE | FILE_TXT | FILE_COMMON);
    if (handle == INVALID_HANDLE) {
        return false;
    }
    
    FileWriteString(handle, serialized);
    FileClose(handle);
    
    return true;
}

//+------------------------------------------------------------------+
//| Đọc message từ file                                             |
//+------------------------------------------------------------------+
bool CFileCommunication::ReadMessageFromFile(MasterSlaveMessage& message, string filename) {
    int handle = FileOpen(filename, FILE_READ | FILE_TXT | FILE_COMMON);
    if (handle == INVALID_HANDLE) {
        return false;
    }
    
    string serialized = FileReadString(handle);
    FileClose(handle);
    
    return DeserializeMessage(serialized, message);
}

//+------------------------------------------------------------------+
//| Serialize message thành string                                  |
//+------------------------------------------------------------------+
bool CFileCommunication::SerializeMessage(const MasterSlaveMessage& message, string& serialized) {
    serialized = StringFormat("%d|%s|%s|%s|%s|%d|%.5f|%.5f|%.5f|%.5f|%s|%d|%s",
        (long)message.timestamp,
        message.senderEA,
        message.receiverEA,
        message.messageType,
        message.symbol,
        message.orderType,
        message.lotSize,
        message.entryPrice,
        message.stopLoss,
        message.takeProfit,
        message.reason,
        message.priority,
        message.processed ? "1" : "0"
    );
    
    return true;
}

//+------------------------------------------------------------------+
//| Deserialize string thành message                                |
//+------------------------------------------------------------------+
bool CFileCommunication::DeserializeMessage(string serialized, MasterSlaveMessage& message) {
    string parts[];
    int count = StringSplit(serialized, '|', parts);
    
    if (count < 13) {
        return false;
    }
    
    message.timestamp = (datetime)StringToInteger(parts[0]);
    message.senderEA = parts[1];
    message.receiverEA = parts[2];
    message.messageType = parts[3];
    message.symbol = parts[4];
    message.orderType = (int)StringToInteger(parts[5]);
    message.lotSize = StringToDouble(parts[6]);
    message.entryPrice = StringToDouble(parts[7]);
    message.stopLoss = StringToDouble(parts[8]);
    message.takeProfit = StringToDouble(parts[9]);
    message.reason = parts[10];
    message.priority = (int)StringToInteger(parts[11]);
    message.processed = (parts[12] == "1");
    
    return true;
}

//+------------------------------------------------------------------+
//| Log message                                                      |
//+------------------------------------------------------------------+
void CFileCommunication::LogMessage(const MasterSlaveMessage& message, string action) {
    if (!m_Logger) return;
    
    string logText = StringFormat("%s Message - Type: %s, From: %s, To: %s, Symbol: %s, Reason: %s",
        action,
        message.messageType,
        message.senderEA,
        message.receiverEA,
        message.symbol,
        message.reason
    );
    
    m_Logger->LogInfo(logText);
}

} // namespace ApexPullback

#endif // FILE_COMMUNICATION_MQH_