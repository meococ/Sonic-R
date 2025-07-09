//+------------------------------------------------------------------+
//|                                       UI_Dashboard_State.mqh |
//|                        Copyright 2024, MQL5-SOLUTIONS.IO |
//|                               https://www.mql5-solutions.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MQL5-SOLUTIONS.IO"
#property link      "https://www.mql5-solutions.io"
#property version   "1.00"

#include "Shared_DataStructures.mqh"

//+------------------------------------------------------------------+
//| Struct for Dashboard State                                       |
//+------------------------------------------------------------------+
struct DashboardState
{
    // Market Structure
    ENUM_MARKET_REGIME   majorStructure;
    ENUM_MARKET_REGIME   primaryStructure;
    ENUM_MARKET_REGIME   subStructure;

    // Trend
    string              trendDirection;
    int                 trendStrength; // 0-100

    // Volatility
    double              atrValue;
    string              volatilityLevel; // Low, Medium, High

    // Key Levels
    double              nextMajorHigh;
    double              nextMajorLow;
    double              nextPrimaryHigh;
    double              nextPrimaryLow;

    // Session Information
    string              currentSession;
    long                timeToNextSession;

    // Constructor
    void DashboardState() 
    {
        majorStructure = UNCERTAIN;
        primaryStructure = UNCERTAIN;
        subStructure = UNCERTAIN;
        trendDirection = "N/A";
        trendStrength = 0;
        atrValue = 0.0;
        volatilityLevel = "N/A";
        nextMajorHigh = 0.0;
        nextMajorLow = 0.0;
        nextPrimaryHigh = 0.0;
        nextPrimaryLow = 0.0;
        currentSession = "N/A";
        timeToNextSession = 0;
    }
};

//+------------------------------------------------------------------+