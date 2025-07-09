//+------------------------------------------------------------------+
//|                                   SonicR_CommonStructs.mqh      |
//|              Sonic R System - Central Context & Forward Decls   |
//|                              Đại Bàng Architecture              |
//+------------------------------------------------------------------+
#ifndef SONICR_COMMON_STRUCTS_MQH
#define SONICR_COMMON_STRUCTS_MQH

// SINGLE DEPENDENCY
#include "SonicR_Enums.mqh"

// BẮT ĐẦU NAMESPACE
namespace ApexSonicR {

//+------------------------------------------------------------------+
//| FORWARD DECLARATIONS - PREVENT CIRCULAR DEPENDENCIES            |
//+------------------------------------------------------------------+

// Forward declarations for main classes
class CLogger;
class CSettings;
class CSymbolInfo;
class CErrorHandler;
class CTimeManager;
class CSessionManager;

// Note: CAppSymbolInfo will be aliased to CSymbolInfo in the code that uses it

//+------------------------------------------------------------------+
//| MISSING STRUCTURES                                               |
//+------------------------------------------------------------------+
struct SDivergenceInfo {
    bool        isValid;
    double      strength;
    int         bars;
    datetime    time;
    double      price;
    double      indicator_value;
    
    SDivergenceInfo() : isValid(false), strength(0.0), bars(0), time(0), price(0.0), indicator_value(0.0) {}
};

struct SOscillatorContext {
    double      value;
    double      signal;
    double      histogram;
    bool        isValid;
    
    SOscillatorContext() : value(0.0), signal(0.0), histogram(0.0), isValid(false) {}
};

//+------------------------------------------------------------------+
//| CENTRAL CONTEXT CLASS - MAIN CONTAINER                          |
//+------------------------------------------------------------------+
class CEaContext 
{
public:
    // Core components
    CLogger*            logger;
    CSettings*          settings;
    CSymbolInfo*        symbolInfo;
    CErrorHandler*      errorHandler;
    CTimeManager*       timeManager;
    CSessionManager*    sessionManager;
    
    // Runtime state
    bool                isInitialized;
    bool                isTradingEnabled;
    datetime            lastTickTime;
    int                 magicNumber;
    string              expertName;
    
    // Constructor
    CEaContext() : 
        logger(NULL),
        settings(NULL),
        symbolInfo(NULL),
        errorHandler(NULL),
        timeManager(NULL),
        sessionManager(NULL),
        isInitialized(false),
        isTradingEnabled(false),
        lastTickTime(0),
        magicNumber(0),
        expertName("SonicR_EA")
    {
    }
    
    // Destructor
    ~CEaContext() {
        // Cleanup handled in EA deinit
    }
};

} // END NAMESPACE ApexSonicR

#endif // SONICR_COMMON_STRUCTS_MQH 