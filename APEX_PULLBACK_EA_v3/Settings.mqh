//+------------------------------------------------------------------+
//|                                                     Settings.mqh |
//|                   Copyright 2025, APEX Forex - Mèo Cọc |
//|                                    https://www.apexforex.com |
//+------------------------------------------------------------------+
#pragma once

#ifndef APEX_SETTINGS_MQH_
#define APEX_SETTINGS_MQH_

#include "CommonStructs.mqh"

namespace ApexPullback
{
    // Forward declaration to break dependency cycle
    class CErrorHandler;

    //+------------------------------------------------------------------+
    //| CSettings Class                                                  |
    //| Encapsulates all EA input parameters and provides validation.    |
    //+------------------------------------------------------------------+
    class CSettings
    {
    private:
        EAContext* m_pContext;       // Pointer to the global context
        bool       m_initialized;      // Initialization flag

    public:
        // --- Constructor & Destructor ---
        CSettings();
       ~CSettings();

        // --- Initialization ---
        bool Initialize(EAContext* pContext);

        // --- Publicly Accessible Settings ---
        // These members are populated from the global input variables during Initialize()

        // General Settings
        long                  MagicNumber;
        string                OrderComment;

        // Logging & Display
        ENUM_LOG_LEVEL        LogLevel;
        ENUM_LOG_OUTPUT       LogOutput;
        bool                  EnableDetailedLogs;
        string                CsvLogFilename;
        bool                  DisplayDashboard;
        ENUM_DASHBOARD_THEME  DashboardTheme;
        int                   UpdateFrequencySeconds;
        bool                  DisableDashboardInBacktest;

        // Core Strategy
        ENUM_TIMEFRAMES       MainTimeframe;
        int                   EMA_Fast;
        int                   EMA_Medium;
        int                   EMA_Slow;
        bool                  UseMultiTimeframe;
        ENUM_TIMEFRAMES       HigherTimeframe;

        // Risk Management
        double                RiskPercent;
        double                StopLoss_ATR;
        double                TakeProfit_RR;
        int                   MaxPositions;
    };

    //+------------------------------------------------------------------+
    //| Constructor                                                      |
    //+------------------------------------------------------------------+
    CSettings::CSettings() : 
        m_pContext(NULL),
        m_initialized(false),
        MagicNumber(0),
        LogLevel(LOG_INFO),
        LogOutput(LOG_OUTPUT_CONSOLE),
        EnableDetailedLogs(true),
        DisplayDashboard(true),
        DashboardTheme(THEME_DARK),
        UpdateFrequencySeconds(5),
        DisableDashboardInBacktest(true),
        MainTimeframe(PERIOD_H1),
        EMA_Fast(21),
        EMA_Medium(50),
        EMA_Slow(200),
        UseMultiTimeframe(true),
        HigherTimeframe(PERIOD_H4),
        RiskPercent(1.0),
        StopLoss_ATR(2.0),
        TakeProfit_RR(2.0),
        MaxPositions(1)
    {
    }

    //+------------------------------------------------------------------+
    //| Destructor                                                       |
    //+------------------------------------------------------------------+
    CSettings::~CSettings()
    {
    }

    //+------------------------------------------------------------------+
    //| Initialize                                                       |
    //+------------------------------------------------------------------+
    bool CSettings::Initialize(EAContext* pContext)
    {
        if (m_initialized || pContext == NULL || pContext->pErrorHandler == NULL)
        {
            // Avoid re-initialization or initialization with invalid context
            return m_initialized;
        }

        m_pContext = pContext;
        CErrorHandler* pErrorHandler = m_pContext->pErrorHandler;

        // --- Load settings from global input variables ---
        // This is where we bridge the gap between MQL5's flat input structure and our object-oriented design.
        
        // General Settings
        MagicNumber = InpMagicNumber;
        OrderComment = InpOrderComment;

        // Logging & Display
        LogLevel = InpLogLevel;
        LogOutput = InpLogOutput;
        EnableDetailedLogs = InpEnableDetailedLogs;
        CsvLogFilename = InpCsvLogFilename;
        DisplayDashboard = InpDisplayDashboard;
        DashboardTheme = InpDashboardTheme;
        UpdateFrequencySeconds = InpUpdateFrequencySeconds;
        DisableDashboardInBacktest = InpDisableDashboardInBacktest;

        // Core Strategy
        MainTimeframe = InpMainTimeframe;
        EMA_Fast = InpEMA_Fast;
        EMA_Medium = InpEMA_Medium;
        EMA_Slow = InpEMA_Slow;
        UseMultiTimeframe = InpUseMultiTimeframe;
        HigherTimeframe = InpHigherTimeframe;

        // Risk Management
        RiskPercent = InpRiskPercent;
        StopLoss_ATR = InpStopLoss_ATR;
        TakeProfit_RR = InpTakeProfit_RR;
        MaxPositions = InpMaxPositions;

        // --- VALIDATION --- 
        // This is the critical value-add of the CSettings class.
        bool validationOk = true;

        if (MagicNumber <= 0)
        {
            pErrorHandler->HandleError(ERR_INVALID_PARAMETER, "Magic Number must be a positive integer.", __FUNCTION__);
            validationOk = false;
        }

        if (RiskPercent <= 0 || RiskPercent > 100)
        {
            pErrorHandler->HandleError(ERR_INVALID_PARAMETER, "Risk Percent must be between 0 and 100.", __FUNCTION__);
            validationOk = false;
        }

        if (StopLoss_ATR <= 0)
        {
            pErrorHandler->HandleError(ERR_INVALID_PARAMETER, "Stop Loss ATR multiplier must be positive.", __FUNCTION__);
            validationOk = false;
        }

        if (TakeProfit_RR <= 0)
        {
            pErrorHandler->HandleError(ERR_INVALID_PARAMETER, "Take Profit R:R must be positive.", __FUNCTION__);
            validationOk = false;
        }

        if (MaxPositions <= 0)
        {
            pErrorHandler->HandleError(ERR_INVALID_PARAMETER, "Max Positions must be a positive integer.", __FUNCTION__);
            validationOk = false;
        }
        
        if (EMA_Fast <= 0 || EMA_Medium <= 0 || EMA_Slow <= 0 || EMA_Fast >= EMA_Medium || EMA_Medium >= EMA_Slow)
        {
            pErrorHandler->HandleError(ERR_INVALID_PARAMETER, "EMA periods must be positive and in ascending order (Fast < Medium < Slow).", __FUNCTION__);
            validationOk = false;
        }

        m_initialized = validationOk;
        return m_initialized;
    }

} // namespace ApexPullback

#endif // APEX_SETTINGS_MQH_