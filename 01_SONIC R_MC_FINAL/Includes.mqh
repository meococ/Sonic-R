//+------------------------------------------------------------------+
//|                                                     Includes.mqh |
//|                            Sonic R MC EA - Include Management    |
//|                     Đại Bàng Architecture - Clean Dependencies   |
//+------------------------------------------------------------------+
#ifndef INCLUDES_MQH
#define INCLUDES_MQH

//+------------------------------------------------------------------+
//| LEVEL 0: FOUNDATION - ENUMS & FORWARD DECLARATIONS               |
//+------------------------------------------------------------------+
#include "SonicR_Enums.mqh"
#include "SonicR_CommonStructs.mqh"

//+------------------------------------------------------------------+
//| LEVEL 1: DATA STRUCTURES (Depends on Enums)                     |
//+------------------------------------------------------------------+
#include "Shared_DataStructures.mqh"

//+------------------------------------------------------------------+
//| LEVEL 2: CORE INFRASTRUCTURE (No dependencies on other modules) |
//+------------------------------------------------------------------+
#include "Core_Defines.mqh"
#include "Core_Settings.mqh"
#include "Core_Inputs.mqh"
#include "Core_Logger.mqh"
#include "Core_ErrorHandler.mqh"
#include "Core_TimeManager.mqh"
#include "Core_SessionManager.mqh"
#include "Core_SymbolInfo.mqh"
#include "Core_Context.mqh"
#include "Core_Core.mqh"

//+------------------------------------------------------------------+
//| LEVEL 3: ANALYSIS FOUNDATIONS (Depends on Core)                 |
//+------------------------------------------------------------------+
#include "Analysis_Indicators.mqh"
#include "Analysis_BrokerHealth.mqh"
#include "SMC_Config.mqh"
#include "SMC_Structures.mqh"
#include "SMC_Utils.mqh"

//+------------------------------------------------------------------+
//| LEVEL 4: ADVANCED ANALYSIS (Depends on Level 3)                 |
//+------------------------------------------------------------------+
#include "Analysis_MarketAnalysisManager.mqh"
#include "FairValueGaps.mqh"
#include "OrderBlocks.mqh"
#include "MarketStructure.mqh"
#include "Analysis_SonicR_Dragon.mqh"
#include "Analysis_SonicR_DragonBand.mqh"
#include "Analysis_SonicR_MarketStructure.mqh"
#include "Analysis_SonicR_Oscillator.mqh"
#include "Analysis_SonicR_PVSRA.mqh"
#include "Analysis_SonicR_SupportResistance.mqh"
#include "Analysis_SonicR_WavePattern.mqh"
#include "Analysis_POIScoring.mqh"
#include "Analysis_SMC.mqh"
#include "Analysis_MarketProfile.mqh"

//+------------------------------------------------------------------+
//| LEVEL 5: SIGNAL & STRATEGY (Depends on Analysis)                |
//+------------------------------------------------------------------+
#include "Signal_Engine.mqh"
#include "Signal_Strategy.mqh"
#include "Signal_SonicR_Integration.mqh"
#include "Signal_SonicR_Classic_Strategy.mqh"
#include "Signal_SonicR_Advanced_Strategy.mqh"
#include "Signal_SonicR_ScoutEntry.mqh"
#include "Signal_Confirmation.mqh"

//+------------------------------------------------------------------+
//| LEVEL 6: RISK & TRADE MANAGEMENT (Depends on Signals)           |
//+------------------------------------------------------------------+
#include "Risk_Manager.mqh"
#include "Risk_CircuitBreaker.mqh"
#include "Trade_Manager.mqh"

//+------------------------------------------------------------------+
//| LEVEL 7: UI & PERFORMANCE (Depends on All Above)                |
//+------------------------------------------------------------------+
#include "UI_Dashboard_State.mqh"
#include "UI_Dashboard_Renderer.mqh"
#include "UI_Dashboard_Manager.mqh"
#include "Performance_Tracker.mqh"

#endif // INCLUDES_MQH