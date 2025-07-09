//+------------------------------------------------------------------+
//|                  Signal_Strategy.mqh - Base Interface            |
//|                  APEX Pullback EA v4.6 - Flat Architecture       |
//|      "Namespace removed for global scope compatibility"          |
//+------------------------------------------------------------------+

#ifndef APEX_SIGNAL_STRATEGY_MQH_
#define APEX_SIGNAL_STRATEGY_MQH_

#include "Core_Defines.mqh"
#include "Core_Logger.mqh"

// Forward declarations for dependency injection
class CIndicators;
class CWaveAnalysis;
class CPVSRAAnalysis;
class CSonicRDragon;

//+------------------------------------------------------------------+
//| SSignalInfo - Standardized Signal Information Structure        |
//+------------------------------------------------------------------+
struct SSignalInfo
{
    ENUM_SIGNAL_TYPE    Type;               // Signal type (BUY, SELL, NONE)
    double              EntryPrice;         // Recommended entry price
    double              StopLoss;           // Stop loss price
    double              TakeProfit;         // Take profit price
    double              Strength;           // Signal strength (0.0 to 1.0)
    datetime            Timestamp;          // Time of signal generation
    string              Comment;            // Signal description

    void SSignalInfo() { Reset(); }
    void Reset()
    {
        Type = SIGNAL_NONE;
        EntryPrice = 0;
        StopLoss = 0;
        TakeProfit = 0;
        Strength = 0;
        Timestamp = 0;
        Comment = "";
    }
};

//+------------------------------------------------------------------+
//| ISignalStrategy - Interface for all signal generation strategies |
//+------------------------------------------------------------------+
class ISignalStrategy
{
public:
    virtual ~ISignalStrategy() {}

    // --- Core Methods ---
    virtual bool Initialize(CLogger* pLogger, CIndicators* pIndicators, CWaveAnalysis* pWave, CPVSRAAnalysis* pPVSRA, CSonicRDragon* pDragon) = 0;
    virtual ENUM_SIGNAL_TYPE CheckForSignal() = 0;
    virtual SSignalInfo GetLastSignalInfo() = 0;
    virtual void Reset() = 0;
};

#endif // APEX_SIGNAL_STRATEGY_MQH_