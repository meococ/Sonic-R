//+------------------------------------------------------------------+
//|                                    FileCommunicationJSON.mqh |
//|                         Copyright 2023-2024, ApexPullback EA |
//|                                     https://www.apexpullback.com |
//+------------------------------------------------------------------+

#ifndef FILE_COMMUNICATION_JSON_MQH_
#define FILE_COMMUNICATION_JSON_MQH_

// === ENHANCED JSON PARSER INCLUDE ===
#include "JSONParser.mqh"

// Implementation cho JSON Protocol trong Master-Slave Architecture
// Theo đề xuất kỹ thuật: Sử dụng JSON format cho PROPOSAL và DECISION messages

namespace ApexPullback {

//+------------------------------------------------------------------+
//| Send JSON Proposal Message (Slave -> Master)                    |
//+------------------------------------------------------------------+
bool CFileCommunication::SendJSONProposal(const TradingProposal& proposal)
{
    if (!m_Logger) {
        return false;
    }
    
    // Generate unique signal ID
    string signalID = GenerateSignalID(proposal.Symbol, proposal.ProposalTime);
    
    // Serialize proposal to JSON
    string jsonData = SerializeProposalToJSON(proposal);
    
    if (jsonData == "") {
        if (m_Logger) {
            m_Logger->LogError("[JSON PROTOCOL] Failed to serialize proposal to JSON");
        }
        return false;
    }
    
    // Create filename with signal ID
    string filename = StringFormat("%s\\PROPOSAL_%s_%s.json", 
                                   m_CommunicationFolder, 
                                   m_EAIdentifier, 
                                   signalID);
    
    // Write JSON to file with lock mechanism
    string lockFile = filename + ".lock";
    
    if (!CreateLockFile(lockFile)) {
        if (m_Logger) {
            m_Logger->LogWarning("[JSON PROTOCOL] Failed to create lock for proposal file");
        }
        return false;
    }
    
    // Write JSON data to file
    int fileHandle = FileOpen(filename, FILE_WRITE | FILE_TXT | FILE_ANSI);
    if (fileHandle == INVALID_HANDLE) {
        ReleaseLockFile(lockFile);
        if (m_Logger) {
            m_Logger->LogError("[JSON PROTOCOL] Failed to create proposal file: " + filename);
        }
        return false;
    }
    
    FileWrite(fileHandle, jsonData);
    FileClose(fileHandle);
    
    // Release lock
    ReleaseLockFile(lockFile);
    
    if (m_Logger) {
        string logMsg = StringFormat(
            "[JSON PROTOCOL] Proposal sent - Signal: %s, Symbol: %s, Type: %s, Confidence: %.2f",
            signalID, proposal.Symbol, 
            (proposal.OrderType == ORDER_TYPE_BUY) ? "BUY" : "SELL",
            proposal.SignalConfidenceScore
        );
        m_Logger->LogInfo(logMsg);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Send JSON Decision Message (Master -> Slave)                    |
//+------------------------------------------------------------------+
bool CFileCommunication::SendJSONDecision(const TradingDecision& decision)
{
    if (!m_Logger) {
        return false;
    }
    
    // Serialize decision to JSON
    string jsonData = SerializeDecisionToJSON(decision);
    
    if (jsonData == "") {
        if (m_Logger) {
            m_Logger->LogError("[JSON PROTOCOL] Failed to serialize decision to JSON");
        }
        return false;
    }
    
    // Create filename with proposal ID reference
    string filename = StringFormat("%s\\DECISION_%s_%s.json", 
                                   m_CommunicationFolder, 
                                   decision.SlaveEAID, 
                                   decision.ProposalID);
    
    // Write JSON to file with lock mechanism
    string lockFile = filename + ".lock";
    
    if (!CreateLockFile(lockFile)) {
        if (m_Logger) {
            m_Logger->LogWarning("[JSON PROTOCOL] Failed to create lock for decision file");
        }
        return false;
    }
    
    // Write JSON data to file
    int fileHandle = FileOpen(filename, FILE_WRITE | FILE_TXT | FILE_ANSI);
    if (fileHandle == INVALID_HANDLE) {
        ReleaseLockFile(lockFile);
        if (m_Logger) {
            m_Logger->LogError("[JSON PROTOCOL] Failed to create decision file: " + filename);
        }
        return false;
    }
    
    FileWrite(fileHandle, jsonData);
    FileClose(fileHandle);
    
    // Release lock
    ReleaseLockFile(lockFile);
    
    if (m_Logger) {
        string decisionStr = "";
        switch(decision.DecisionType) {
            case DECISION_APPROVE: decisionStr = "APPROVE"; break;
            case DECISION_APPROVE_MODIFIED: decisionStr = "APPROVE_MODIFIED"; break;
            case DECISION_REJECT: decisionStr = "REJECT"; break;
            case DECISION_DEFER: decisionStr = "DEFER"; break;
            default: decisionStr = "UNKNOWN"; break;
        }
        
        string logMsg = StringFormat(
            "[JSON PROTOCOL] Decision sent - Proposal: %s, Decision: %s, Lot: %.2f",
            decision.ProposalID, decisionStr, decision.FinalLotSize
        );
        m_Logger->LogInfo(logMsg);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Serialize Trading Proposal to JSON                              |
//+------------------------------------------------------------------+
string CFileCommunication::SerializeProposalToJSON(const TradingProposal& proposal)
{
    // Generate signal ID
    string signalID = GenerateSignalID(proposal.Symbol, proposal.ProposalTime);
    
    // Build JSON string theo format đề xuất
    string json = "{";
    json += "\"msg_type\": \"PROPOSAL\",";
    json += "\"slave_id\": \"" + proposal.SlaveEAID + "\",";
    json += "\"signal_id\": \"" + signalID + "\",";
    json += "\"symbol\": \"" + proposal.Symbol + "\",";
    json += "\"direction\": \"" + ((proposal.OrderType == ORDER_TYPE_BUY) ? "BUY" : "SELL") + "\",";
    
    // Strategy mapping
    string strategyStr = "PULLBACK_TREND";
    switch(proposal.ProposedStrategy) {
        case STRATEGY_PULLBACK_TREND: strategyStr = "PULLBACK_TREND"; break;
        case STRATEGY_BREAKOUT: strategyStr = "BREAKOUT"; break;
        case STRATEGY_REVERSAL: strategyStr = "REVERSAL"; break;
        case STRATEGY_MOMENTUM: strategyStr = "MOMENTUM"; break;
        default: strategyStr = "PULLBACK_TREND"; break;
    }
    json += "\"strategy\": \"" + strategyStr + "\",";
    
    json += StringFormat("\"confidence_score\": %.3f,", proposal.SignalConfidenceScore);
    json += StringFormat("\"entry_price\": %.5f,", proposal.EntryPrice);
    json += StringFormat("\"sl_price\": %.5f,", proposal.StopLoss);
    json += StringFormat("\"tp_price\": %.5f,", proposal.TakeProfit);
    json += StringFormat("\"proposed_lot_size\": %.2f,", proposal.ProposedLotSize);
    json += StringFormat("\"risk_reward_ratio\": %.2f,", proposal.RiskRewardRatio);
    json += StringFormat("\"expected_profit_pips\": %.1f,", proposal.ExpectedProfitPips);
    json += StringFormat("\"max_risk_pips\": %.1f,", proposal.MaxRiskPips);
    json += StringFormat("\"current_volatility\": %.5f,", proposal.CurrentVolatility);
    json += StringFormat("\"current_spread\": %.1f,", proposal.CurrentSpread);
    json += StringFormat("\"correlation_risk\": %.3f,", proposal.CorrelationRisk);
    json += StringFormat("\"urgency_level\": %d,", proposal.UrgencyLevel);
    json += "\"has_news_conflict\": " + (proposal.HasNewsConflict ? "true" : "false") + ",";
    
    // Market regime
    string regimeStr = "UNKNOWN";
    switch(proposal.MarketRegime) {
        case REGIME_TRENDING_BULL: regimeStr = "TRENDING_BULL"; break;
        case REGIME_TRENDING_BEAR: regimeStr = "TRENDING_BEAR"; break;
        case REGIME_RANGING: regimeStr = "RANGING"; break;
        case REGIME_VOLATILE: regimeStr = "VOLATILE"; break;
        case REGIME_BREAKOUT: regimeStr = "BREAKOUT"; break;
        default: regimeStr = "UNKNOWN"; break;
    }
    json += "\"market_regime\": \"" + regimeStr + "\",";
    
    json += StringFormat("\"proposal_time\": %d,", (int)proposal.ProposalTime);
    json += StringFormat("\"expiry_time\": %d,", (int)proposal.ExpiryTime);
    json += "\"signal_reason\": \"" + proposal.SignalReason + "\"";
    
    json += "}";
    
    return json;
}

//+------------------------------------------------------------------+
//| Serialize Trading Decision to JSON                              |
//+------------------------------------------------------------------+
string CFileCommunication::SerializeDecisionToJSON(const TradingDecision& decision)
{
    // Build JSON string theo format đề xuất
    string json = "{";
    json += "\"msg_type\": \"DECISION\",";
    json += "\"signal_id\": \"" + decision.ProposalID + "\",";
    
    // Decision type
    string decisionStr = "UNKNOWN";
    switch(decision.DecisionType) {
        case DECISION_APPROVE: decisionStr = "APPROVE"; break;
        case DECISION_APPROVE_MODIFIED: decisionStr = "APPROVE_MODIFIED"; break;
        case DECISION_REJECT: decisionStr = "REJECT"; break;
        case DECISION_DEFER: decisionStr = "DEFER"; break;
        default: decisionStr = "UNKNOWN"; break;
    }
    json += "\"decision\": \"" + decisionStr + "\",";
    
    if (decision.DecisionType == DECISION_APPROVE || decision.DecisionType == DECISION_APPROVE_MODIFIED) {
        json += StringFormat("\"final_lot_size\": %.2f,", decision.FinalLotSize);
        json += StringFormat("\"final_entry_price\": %.5f,", decision.FinalEntryPrice);
        json += StringFormat("\"final_sl_price\": %.5f,", decision.FinalStopLoss);
        json += StringFormat("\"final_tp_price\": %.5f,", decision.FinalTakeProfit);
        json += StringFormat("\"allocated_risk_percent\": %.2f,", decision.AllocatedRiskPercent);
        json += StringFormat("\"risk_adjustment_factor\": %.3f,", decision.RiskAdjustmentFactor);
        json += "\"reason_code\": \"APPROVED_OK\",";
    } else if (decision.DecisionType == DECISION_REJECT) {
        // Rejection reason
        string reasonCode = "UNKNOWN";
        switch(decision.RejectionReason) {
            case REJECT_HIGH_CORRELATION: reasonCode = "HIGH_CORRELATION"; break;
            case REJECT_MAX_EXPOSURE: reasonCode = "MAX_EXPOSURE_REACHED"; break;
            case REJECT_LOW_CONFIDENCE: reasonCode = "LOW_CONFIDENCE"; break;
            case REJECT_POOR_RISK_REWARD: reasonCode = "POOR_RISK_REWARD"; break;
            case REJECT_MARKET_CONDITIONS: reasonCode = "UNFAVORABLE_MARKET"; break;
            case REJECT_NEWS_EVENT: reasonCode = "NEWS_CONFLICT"; break;
            case REJECT_DRAWDOWN_LIMIT: reasonCode = "DRAWDOWN_LIMIT"; break;
            case REJECT_VOLATILITY_HIGH: reasonCode = "HIGH_VOLATILITY"; break;
            case REJECT_SPREAD_TOO_WIDE: reasonCode = "WIDE_SPREAD"; break;
            case REJECT_TIME_FILTER: reasonCode = "TIME_RESTRICTION"; break;
            default: reasonCode = "UNKNOWN"; break;
        }
        json += "\"reason_code\": \"" + reasonCode + "\",";
        json += "\"rejection_details\": \"" + decision.RejectionDetails + "\",";
    } else if (decision.DecisionType == DECISION_DEFER) {
        json += "\"reason_code\": \"DEFERRED\",";
        json += StringFormat("\"valid_until\": %d,", (int)decision.ValidUntil);
    }
    
    // Portfolio context
    json += StringFormat("\"current_portfolio_risk\": %.2f,", decision.CurrentPortfolioRisk);
    json += StringFormat("\"available_risk_capacity\": %.2f,", decision.AvailableRiskCapacity);
    json += StringFormat("\"current_position_count\": %d,", decision.CurrentPositionCount);
    json += StringFormat("\"decision_time\": %d,", (int)decision.DecisionTime);
    
    if (decision.SpecialInstructions != "") {
        json += "\"special_instructions\": \"" + decision.SpecialInstructions + "\",";
    }
    
    json += "\"require_confirmation\": " + (decision.RequireConfirmation ? "true" : "false");
    
    json += "}";
    
    return json;
}

//+------------------------------------------------------------------+
//| Generate Unique Signal ID                                       |
//+------------------------------------------------------------------+
string CFileCommunication::GenerateSignalID(const string& symbol, datetime timestamp)
{
    // Format: SYMBOL_TIMESTAMP_RANDOM
    int randomNum = MathRand() % 10000;
    string signalID = StringFormat("%s_%d_%04d", symbol, (int)timestamp, randomNum);
    return signalID;
}

//+------------------------------------------------------------------+
//| Parse JSON Proposal (Master receives from Slave)                |
//+------------------------------------------------------------------+
bool CFileCommunication::ParseJSONProposal(const string& jsonData, TradingProposal& proposal)
{
    // Enhanced JSON parsing using robust parser
    CJSONParser parser(true); // Strict mode
    
    // Validate JSON structure first
    if (!parser.ValidateJSON(jsonData)) {
        m_Logger->LogError("[JSON PROTOCOL] Invalid JSON structure: " + parser.GetLastError());
        return false;
    }
    
    // Validate message type
    string msgType;
    if (!parser.ParseString(jsonData, "msg_type", msgType) || msgType != "PROPOSAL") {
        m_Logger->LogError("[JSON PROTOCOL] Invalid or missing msg_type");
        return false;
    }
    
    // Parse required fields with error checking
    if (!parser.ParseString(jsonData, "slave_id", proposal.SlaveEAID)) {
        m_Logger->LogError("[JSON PROTOCOL] Failed to parse slave_id: " + parser.GetLastError());
        return false;
    }
    
    if (!parser.ParseString(jsonData, "symbol", proposal.Symbol)) {
        m_Logger->LogError("[JSON PROTOCOL] Failed to parse symbol: " + parser.GetLastError());
        return false;
    }
    
    string direction;
    if (!parser.ParseString(jsonData, "direction", direction)) {
        m_Logger->LogError("[JSON PROTOCOL] Failed to parse direction: " + parser.GetLastError());
        return false;
    }
    proposal.OrderType = (direction == "BUY") ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
    
    // Parse numeric fields with validation
    if (!parser.ParseDouble(jsonData, "confidence_score", proposal.SignalConfidenceScore)) {
        m_Logger->LogWarning("[JSON PROTOCOL] Failed to parse confidence_score, using default");
        proposal.SignalConfidenceScore = 0.0;
    }
    
    if (!parser.ParseDouble(jsonData, "entry_price", proposal.EntryPrice)) {
        m_Logger->LogError("[JSON PROTOCOL] Failed to parse entry_price: " + parser.GetLastError());
        return false;
    }
    
    if (!parser.ParseDouble(jsonData, "sl_price", proposal.StopLoss)) {
        m_Logger->LogWarning("[JSON PROTOCOL] Failed to parse sl_price, using 0");
        proposal.StopLoss = 0.0;
    }
    
    if (!parser.ParseDouble(jsonData, "tp_price", proposal.TakeProfit)) {
        m_Logger->LogWarning("[JSON PROTOCOL] Failed to parse tp_price, using 0");
        proposal.TakeProfit = 0.0;
    }
    
    if (!parser.ParseDouble(jsonData, "proposed_lot_size", proposal.ProposedLotSize)) {
        m_Logger->LogError("[JSON PROTOCOL] Failed to parse proposed_lot_size: " + parser.GetLastError());
        return false;
    }
    
    // Parse optional fields
    parser.ParseDouble(jsonData, "risk_reward_ratio", proposal.RiskRewardRatio);
    parser.ParseDouble(jsonData, "expected_profit_pips", proposal.ExpectedProfitPips);
    parser.ParseDouble(jsonData, "max_risk_pips", proposal.MaxRiskPips);
    parser.ParseDouble(jsonData, "current_volatility", proposal.CurrentVolatility);
    parser.ParseDouble(jsonData, "current_spread", proposal.CurrentSpread);
    parser.ParseDouble(jsonData, "correlation_risk", proposal.CorrelationRisk);
    parser.ParseInt(jsonData, "urgency_level", proposal.UrgencyLevel);
    parser.ParseBool(jsonData, "has_news_conflict", proposal.HasNewsConflict);
    parser.ParseString(jsonData, "signal_reason", proposal.SignalReason);
    parser.ParseDateTime(jsonData, "proposal_time", proposal.ProposalTime);
    parser.ParseDateTime(jsonData, "expiry_time", proposal.ExpiryTime);
    
    return true;
}

//+------------------------------------------------------------------+
//| Parse JSON Decision (Slave receives from Master)                |
//+------------------------------------------------------------------+
bool CFileCommunication::ParseJSONDecision(const string& jsonData, TradingDecision& decision)
{
    // Enhanced JSON parsing using robust parser
    CJSONParser parser(true); // Strict mode
    
    // Validate JSON structure first
    if (!parser.ValidateJSON(jsonData)) {
        m_Logger->LogError("[JSON PROTOCOL] Invalid JSON structure: " + parser.GetLastError());
        return false;
    }
    
    // Validate message type
    string msgType;
    if (!parser.ParseString(jsonData, "msg_type", msgType) || msgType != "DECISION") {
        m_Logger->LogError("[JSON PROTOCOL] Invalid or missing msg_type");
        return false;
    }
    
    // Parse required fields
    if (!parser.ParseString(jsonData, "signal_id", decision.ProposalID)) {
        m_Logger->LogError("[JSON PROTOCOL] Failed to parse signal_id: " + parser.GetLastError());
        return false;
    }
    
    string decisionStr;
    if (!parser.ParseString(jsonData, "decision", decisionStr)) {
        m_Logger->LogError("[JSON PROTOCOL] Failed to parse decision: " + parser.GetLastError());
        return false;
    }
    
    // Map decision string to enum
    if (decisionStr == "APPROVE") {
        decision.DecisionType = DECISION_APPROVE;
    } else if (decisionStr == "APPROVE_MODIFIED") {
        decision.DecisionType = DECISION_APPROVE_MODIFIED;
    } else if (decisionStr == "REJECT") {
        decision.DecisionType = DECISION_REJECT;
    } else if (decisionStr == "DEFER") {
        decision.DecisionType = DECISION_DEFER;
    } else {
        m_Logger->LogWarning("[JSON PROTOCOL] Unknown decision type: " + decisionStr + ", defaulting to REJECT");
        decision.DecisionType = DECISION_REJECT;
    }
    
    // Parse numeric fields with validation
    if (!parser.ParseDouble(jsonData, "final_lot_size", decision.FinalLotSize)) {
        m_Logger->LogWarning("[JSON PROTOCOL] Failed to parse final_lot_size, using 0");
        decision.FinalLotSize = 0.0;
    }
    
    parser.ParseDouble(jsonData, "final_entry_price", decision.FinalEntryPrice);
    parser.ParseDouble(jsonData, "final_sl_price", decision.FinalStopLoss);
    parser.ParseDouble(jsonData, "final_tp_price", decision.FinalTakeProfit);
    parser.ParseDouble(jsonData, "allocated_risk_percent", decision.AllocatedRiskPercent);
    parser.ParseDouble(jsonData, "risk_adjustment_factor", decision.RiskAdjustmentFactor);
    
    // Portfolio info
    parser.ParseDouble(jsonData, "current_portfolio_risk", decision.CurrentPortfolioRisk);
    parser.ParseDouble(jsonData, "available_risk_capacity", decision.AvailableRiskCapacity);
    parser.ParseInt(jsonData, "current_position_count", decision.CurrentPositionCount);
    parser.ParseDateTime(jsonData, "decision_time", decision.DecisionTime);
    
    parser.ParseBool(jsonData, "require_confirmation", decision.RequireConfirmation);
    parser.ParseString(jsonData, "special_instructions", decision.SpecialInstructions);
    
    return true;
}

// Legacy helper functions removed - now using enhanced CJSONParser class
// These functions have been replaced by the robust JSON parsing methods
// in the CJSONParser class for better error handling and validation

} // End namespace ApexPullback

#endif // FILE_COMMUNICATION_JSON_MQH_