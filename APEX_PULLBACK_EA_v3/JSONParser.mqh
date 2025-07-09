//+------------------------------------------------------------------+
//|                                                   JSONParser.mqh |
//|              APEX Pullback EA v14.0 - Enhanced JSON Parser       |
//+------------------------------------------------------------------+

#ifndef JSONPARSER_MQH_
#define JSONPARSER_MQH_

#include "CommonStructs.mqh"

// BẮT ĐẦU NAMESPACE
namespace ApexPullback {

//+------------------------------------------------------------------+
//| Enhanced JSON Parser Class                                       |
//+------------------------------------------------------------------+
class CJSONParser {
private:
    string m_lastError;
    bool   m_strictMode;
    
    // Helper methods
    string TrimWhitespace(const string& str) const;
    bool   IsValidJSONChar(const ushort ch) const;
    string EscapeString(const string& str) const;
    string UnescapeString(const string& str) const;
    int    FindNextToken(const string& json, int startPos, const string& token) const;
    bool   ValidateJSONStructure(const string& json) const;
    
public:
    // Constructor
    CJSONParser(bool strictMode = true);
    ~CJSONParser();
    
    // Core parsing methods
    bool   ParseString(const string& json, const string& key, string& result);
    bool   ParseDouble(const string& json, const string& key, double& result);
    bool   ParseInt(const string& json, const string& key, int& result);
    bool   ParseBool(const string& json, const string& key, bool& result);
    bool   ParseDateTime(const string& json, const string& key, datetime& result);
    
    // Array parsing methods
    bool   ParseStringArray(const string& json, const string& key, string& result[]) const;
    bool   ParseDoubleArray(const string& json, const string& key, double& result[]) const;
    
    // Object validation
    bool   ValidateJSON(const string& json);
    bool   HasKey(const string& json, const string& key) const;
    
    // JSON building methods
    string BuildJSONString(const string& key, const string& value) const;
    string BuildJSONNumber(const string& key, double value, int precision = 5) const;
    string BuildJSONBool(const string& key, bool value) const;
    string BuildJSONDateTime(const string& key, datetime value) const;
    
    // Utility methods
    string GetLastError() const { return m_lastError; }
    void   ClearError() { m_lastError = ""; }
    bool   IsStrictMode() const { return m_strictMode; }
    void   SetStrictMode(bool strict) { m_strictMode = strict; }
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CJSONParser::CJSONParser(bool strictMode = true) {
    m_strictMode = strictMode;
    m_lastError = "";
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CJSONParser::~CJSONParser() {
    // Cleanup if needed
}

//+------------------------------------------------------------------+
//| Parse String Value from JSON                                     |
//+------------------------------------------------------------------+
bool CJSONParser::ParseString(const string& json, const string& key, string& result) {
    if (json == "" || key == "") {
        m_lastError = "Empty JSON or key";
        return false;
    }
    
    // Look for key pattern: "key": "value"
    string searchPattern = "\"" + key + "\":";
    int startPos = StringFind(json, searchPattern);
    
    if (startPos == -1) {
        m_lastError = "Key '" + key + "' not found";
        return false;
    }
    
    // Find start of value, skipping whitespace
    int valueStart = startPos + StringLen(searchPattern);
    while (valueStart < StringLen(json) && 
           (StringGetCharacter(json, valueStart) == ' ' || 
            StringGetCharacter(json, valueStart) == '\t' ||
            StringGetCharacter(json, valueStart) == '\n' ||
            StringGetCharacter(json, valueStart) == '\r')) {
        valueStart++;
    }
    
    // Value must start with a quote
    if (valueStart >= StringLen(json) || StringGetCharacter(json, valueStart) != '"') {
        m_lastError = "Invalid string format for key '" + key + "', expected '\"'";
        return false;
    }
    valueStart++; // Skip opening quote
    
    // Find end of value (handle escaped quotes)
    int valueEnd = valueStart;
    bool escaped = false;
    
    while (valueEnd < StringLen(json)) {
        ushort ch = StringGetCharacter(json, valueEnd);
        
        if (escaped) {
            escaped = false;
        } else if (ch == '\\') {
            escaped = true;
        } else if (ch == '"') {
            break;
        }
        valueEnd++;
    }
    
    if (valueEnd >= StringLen(json)) {
        m_lastError = "Unterminated string for key '" + key + "'";
        return false;
    }
    
    result = StringSubstr(json, valueStart, valueEnd - valueStart);
    
    // Unescape if needed
    if (StringFind(result, "\\") != -1) {
        result = UnescapeString(result);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Parse Double Value from JSON                                     |
//+------------------------------------------------------------------+
bool CJSONParser::ParseDouble(const string& json, const string& key, double& result) {
    if (json == "" || key == "") {
        m_lastError = "Empty JSON or key";
        return false;
    }
    
    // Look for key pattern: "key": number
    string searchPattern = "\"" + key + "\":";
    int startPos = StringFind(json, searchPattern);
    
    if (startPos == -1) {
        m_lastError = "Key '" + key + "' not found";
        return false;
    }
    
    startPos += StringLen(searchPattern);
    
    // Skip whitespace
    while (startPos < StringLen(json) && 
           (StringGetCharacter(json, startPos) == ' ' || 
            StringGetCharacter(json, startPos) == '\t' ||
            StringGetCharacter(json, startPos) == '\n' ||
            StringGetCharacter(json, startPos) == '\r')) {
        startPos++;
    }
    
    // Find end of number
    int endPos = startPos;
    while (endPos < StringLen(json)) {
        ushort ch = StringGetCharacter(json, endPos);
        if (ch == ',' || ch == '}' || ch == ']' || ch == ' ' || 
            ch == '\t' || ch == '\n' || ch == '\r') {
            break;
        }
        endPos++;
    }
    
    if (endPos == startPos) {
        m_lastError = "No numeric value found for key '" + key + "'";
        return false;
    }
    
    string valueStr = StringSubstr(json, startPos, endPos - startPos);
    valueStr = TrimWhitespace(valueStr);
    
    // Validate numeric format
    bool hasDecimal = false;
    bool hasSign = false;
    
    for (int i = 0; i < StringLen(valueStr); i++) {
        ushort ch = StringGetCharacter(valueStr, i);
        
        if (ch == '+' || ch == '-') {
            if (i != 0 || hasSign) {
                m_lastError = "Invalid numeric format for key '" + key + "'";
                return false;
            }
            hasSign = true;
        } else if (ch == '.') {
            if (hasDecimal) {
                m_lastError = "Multiple decimal points for key '" + key + "'";
                return false;
            }
            hasDecimal = true;
        } else if (ch < '0' || ch > '9') {
            m_lastError = "Invalid character in number for key '" + key + "'";
            return false;
        }
    }
    
    result = StringToDouble(valueStr);
    return true;
}

//+------------------------------------------------------------------+
//| Parse Integer Value from JSON                                    |
//+------------------------------------------------------------------+
bool CJSONParser::ParseInt(const string& json, const string& key, int& result) {
    double doubleResult;
    if (!ParseDouble(json, key, doubleResult)) {
        return false;
    }
    
    // Check if it's actually an integer
    if (doubleResult != (int)doubleResult) {
        m_lastError = "Value for key '" + key + "' is not an integer";
        return false;
    }
    
    result = (int)doubleResult;
    return true;
}

//+------------------------------------------------------------------+
//| Parse Boolean Value from JSON                                    |
//+------------------------------------------------------------------+
bool CJSONParser::ParseBool(const string& json, const string& key, bool& result) {
    string stringResult;
    if (!ParseString(json, key, stringResult)) {
        // Try parsing as unquoted boolean
        string searchPattern = "\"" + key + "\":";
        int startPos = StringFind(json, searchPattern);
        
        if (startPos == -1) {
            m_lastError = "Key '" + key + "' not found";
            return false;
        }
        
        startPos += StringLen(searchPattern);
        
        // Skip whitespace
        while (startPos < StringLen(json) && 
               (StringGetCharacter(json, startPos) == ' ' || 
                StringGetCharacter(json, startPos) == '\t')) {
            startPos++;
        }
        
        if (StringSubstr(json, startPos, 4) == "true") {
            result = true;
            return true;
        } else if (StringSubstr(json, startPos, 5) == "false") {
            result = false;
            return true;
        }
        
        return false;
    }
    
    StringToLower(stringResult);
    if (stringResult == "true" || stringResult == "1") {
        result = true;
        return true;
    } else if (stringResult == "false" || stringResult == "0") {
        result = false;
        return true;
    }
    
    m_lastError = "Invalid boolean value for key '" + key + "'";
    return false;
}

//+------------------------------------------------------------------+
//| Parse DateTime Value from JSON                                   |
//+------------------------------------------------------------------+
bool CJSONParser::ParseDateTime(const string& json, const string& key, datetime& result) {
    double timestamp;
    if (!ParseDouble(json, key, timestamp)) {
        return false;
    }
    
    result = (datetime)timestamp;
    return true;
}

//+------------------------------------------------------------------+
//| Validate JSON Structure                                          |
//+------------------------------------------------------------------+
bool CJSONParser::ValidateJSON(const string& json) {
    if (json == "") {
        m_lastError = "Empty JSON string";
        return false;
    }
    
    string trimmed = TrimWhitespace(json);
    
    if (StringLen(trimmed) < 2) {
        m_lastError = "JSON too short";
        return false;
    }
    
    // Must start with { and end with }
    if (StringGetCharacter(trimmed, 0) != '{' || 
        StringGetCharacter(trimmed, StringLen(trimmed) - 1) != '}') {
        m_lastError = "JSON must be an object (start with { and end with })";
        return false;
    }
    
    // Basic bracket matching
    int braceCount = 0;
    int bracketCount = 0;
    bool inString = false;
    bool escaped = false;
    
    for (int i = 0; i < StringLen(trimmed); i++) {
        ushort ch = StringGetCharacter(trimmed, i);
        
        if (escaped) {
            escaped = false;
            continue;
        }
        
        if (ch == '\\') {
            escaped = true;
            continue;
        }
        
        if (ch == '"') {
            inString = !inString;
            continue;
        }
        
        if (!inString) {
            if (ch == '{') braceCount++;
            else if (ch == '}') braceCount--;
            else if (ch == '[') bracketCount++;
            else if (ch == ']') bracketCount--;
            
            if (braceCount < 0 || bracketCount < 0) {
                m_lastError = "Mismatched brackets in JSON";
                return false;
            }
        }
    }
    
    if (braceCount != 0 || bracketCount != 0) {
        m_lastError = "Unmatched brackets in JSON";
        return false;
    }
    
    if (inString) {
        m_lastError = "Unterminated string in JSON";
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Check if Key Exists in JSON                                      |
//+------------------------------------------------------------------+
bool CJSONParser::HasKey(const string& json, const string& key) const {
    string searchPattern = "\"" + key + "\":";
    return StringFind(json, searchPattern) != -1;
}

//+------------------------------------------------------------------+
//| Build JSON String Field                                          |
//+------------------------------------------------------------------+
string CJSONParser::BuildJSONString(const string& key, const string& value) const {
    return "\"" + key + "\": \"" + EscapeString(value) + "\"";
}

//+------------------------------------------------------------------+
//| Build JSON Number Field                                          |
//+------------------------------------------------------------------+
string CJSONParser::BuildJSONNumber(const string& key, double value, int precision = 5) const {
    return "\"" + key + "\": " + DoubleToString(value, precision);
}

//+------------------------------------------------------------------+
//| Build JSON Boolean Field                                         |
//+------------------------------------------------------------------+
string CJSONParser::BuildJSONBool(const string& key, bool value) const {
    return "\"" + key + "\": " + (value ? "true" : "false");
}

//+------------------------------------------------------------------+
//| Build JSON DateTime Field                                        |
//+------------------------------------------------------------------+
string CJSONParser::BuildJSONDateTime(const string& key, datetime value) const {
    return "\"" + key + "\": " + IntegerToString((int)value);
}

//+------------------------------------------------------------------+
//| Helper: Trim Whitespace                                          |
//+------------------------------------------------------------------+
string CJSONParser::TrimWhitespace(const string& str) const {
    if (str == "") return "";
    
    int start = 0;
    int end = StringLen(str) - 1;
    
    // Trim from start
    while (start <= end) {
        ushort ch = StringGetCharacter(str, start);
        if (ch != ' ' && ch != '\t' && ch != '\n' && ch != '\r') break;
        start++;
    }
    
    // Trim from end
    while (end >= start) {
        ushort ch = StringGetCharacter(str, end);
        if (ch != ' ' && ch != '\t' && ch != '\n' && ch != '\r') break;
        end--;
    }
    
    if (start > end) return "";
    
    return StringSubstr(str, start, end - start + 1);
}

//+------------------------------------------------------------------+
//| Helper: Escape String for JSON                                   |
//+------------------------------------------------------------------+
string CJSONParser::EscapeString(const string& str) const {
    string result = str;
    
    // Replace backslashes first
    StringReplace(result, "\\", "\\\\");
    
    // Replace quotes
    StringReplace(result, "\"", "\\\"");
    
    // Replace control characters
    StringReplace(result, "\n", "\\n");
    StringReplace(result, "\r", "\\r");
    StringReplace(result, "\t", "\\t");
    
    return result;
}

//+------------------------------------------------------------------+
//| Helper: Unescape String from JSON                                |
//+------------------------------------------------------------------+
string CJSONParser::UnescapeString(const string& str) const {
    string result = str;
    
    // Replace escaped characters
    StringReplace(result, "\\n", "\n");
    StringReplace(result, "\\r", "\r");
    StringReplace(result, "\\t", "\t");
    StringReplace(result, "\\\"", "\"");
    StringReplace(result, "\\\\", "\\");
    
    return result;
}

} // End namespace ApexPullback

#endif // JSONPARSER_MQH_