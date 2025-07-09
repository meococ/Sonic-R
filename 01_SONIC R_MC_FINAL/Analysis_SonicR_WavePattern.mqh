//+------------------------------------------------------------------+
//|                                 Analysis_SonicR_WavePattern.mqh |
//|                        Copyright 2024, MQL5-SOLUTIONS.IO |
//|                                  https://www.mql5-solutions.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MQL5-SOLUTIONS.IO"
#property link      "https://www.mql5-solutions.io"
#property version   "1.00"
#property strict

#include "Core_Logger.mqh"
#include "Analysis_Indicators.mqh"
#include "Core_SymbolInfo.mqh"
#include "Shared_DataStructures.mqh" // Centralized data structures
// #include "Core_MathHelper.mqh" // Assuming this exists for math functions - Let's include it later if needed.

//+------------------------------------------------------------------+
//| Class CSonicRWavePattern                                         |
//| Purpose: Elliott Wave pattern recognition and analysis           |
//+------------------------------------------------------------------+
class CSonicRWavePattern
{
public:
    // Structures and enums are now in Shared_DataStructures.mqh
    
private:
    // Core dependencies
    CLogger*         m_pLogger;
    CIndicators*     m_pIndicators;
    CSymbolInfo*     m_pSymbolInfo;
    
    // Configuration
    int              m_lookbackPeriod;      // Lookback period for analysis
    int              m_minWaveLength;       // Minimum wave length in bars
    double           m_fibTolerance;        // Fibonacci ratio tolerance
    double           m_strengthThreshold;   // Minimum strength threshold
    
    // Wave data
    SWavePattern     m_currentPattern;      // Current wave pattern
    SWavePoint       m_swingPoints[];       // Swing points history
    int              m_swingPointCount;     // Number of swing points
    
    // Fibonacci levels
    double           m_fibLevels[13];       // Standard Fibonacci levels
    
public:
    // Constructor & Destructor
                     CSonicRWavePattern();
                    ~CSonicRWavePattern();

    // Initialization
    bool Initialize(CLogger* pLogger, CIndicators* pIndicators, CSymbolInfo* pSymbolInfo);
    void Deinitialize();
    
    // Configuration
    void SetLookbackPeriod(int period) { m_lookbackPeriod = period; }
    void SetMinWaveLength(int length) { m_minWaveLength = length; }
    void SetFibTolerance(double tolerance) { m_fibTolerance = tolerance; }
    void SetStrengthThreshold(double threshold) { m_strengthThreshold = threshold; }
    
    // Main analysis functions
    bool AnalyzeWavePattern();
    bool UpdateCurrentWave();

    // Data Access
    SWavePattern* GetContext() { return &m_currentPattern; }

//+------------------------------------------------------------------+
//| Orchestrates the entire wave pattern analysis process.         |
//+------------------------------------------------------------------+
bool CSonicRWavePattern::AnalyzeWavePattern()
{
    if (m_pLogger == NULL)
    {
        Print("Logger not initialized in CSonicRWavePattern");
        return false;
    }

    m_pLogger.LogInfo("Starting new wave pattern analysis cycle.");

    // Step 1: Identify the latest swing points on the chart.
    if (!IdentifySwingPoints())
    {
        m_pLogger.LogWarning("Failed to identify any swing points. Analysis cannot proceed.");
        return false;
    }

    // Step 2: Classify the identified swing points into a wave structure.
    if (!ClassifyWaves())
    {
        m_pLogger.LogWarning("Failed to classify waves from swing points.");
        return false;
    }

    // Step 3: Validate the integrity of the identified impulse and correction patterns.
    bool isImpulseValid = ValidateImpulsePattern();
    bool isCorrectionValid = ValidateCorrectionPattern();

    if (!isImpulseValid && !isCorrectionValid)
    {
        m_pLogger.LogInfo("No valid Elliott Wave pattern was identified.");
        m_currentPattern.patternStrength = 0.0;
        return false;
    }

    // Step 4: Calculate the strength of the overall pattern.
    m_currentPattern.patternStrength = CalculatePatternStrength();

    // Step 5: Log the results of the analysis for debugging and verification.
    LogWaveAnalysis();

    m_pLogger.LogInfo("Wave pattern analysis cycle completed. Pattern strength: " + DoubleToString(m_currentPattern.patternStrength, 2));

    return true;
}

    bool IdentifySwingPoints();
    bool ClassifyWaves();

//+------------------------------------------------------------------+
//| Classify identified swing points into Elliott Wave patterns.     |
//+------------------------------------------------------------------+
bool CSonicRWavePattern::ClassifyWaves()
{
    if (m_swingPointCount < 2)
    {
        m_pLogger.LogInfo("Not enough swing points to classify waves.");
        return false;
    }

    // Reset current pattern
    ZeroMemory(m_currentPattern);
    m_currentPattern.patternStart = m_swingPoints[0].time;

    // Simple classification: assume the first 5 swings form an impulse pattern
    // and the next 3 form a correction. This is a major simplification and
    // would need a much more sophisticated rule engine for real-world use.

    int waveIndex = 0;
    for (int i = 0; i < m_swingPointCount - 1 && waveIndex < 13; i++)
    {
        SWaveInfo& wave = m_currentPattern.waves[waveIndex];
        wave.startPoint = m_swingPoints[i];
        wave.endPoint = m_swingPoints[i + 1];

        // Basic properties
        wave.length = MathAbs(wave.endPoint.price - wave.startPoint.price) / m_pSymbolInfo.PipValue();
        wave.duration = (wave.endPoint.time - wave.startPoint.time) / 60.0; // Duration in minutes
        wave.isComplete = true; // Assume complete for this analysis

        // Simplified Type Assignment (needs a proper state machine)
        if (waveIndex < 5) // First 5 waves are impulse sequence
        {
            wave.type = (ENUM_WAVE_TYPE)waveIndex;
            m_currentPattern.isImpulsePattern = true;
        }
        else // Next waves are corrective sequence
        {
            wave.type = (ENUM_WAVE_TYPE)(WAVE_CORRECTION_A + (waveIndex - 5));
            m_currentPattern.isCorrectionPattern = true;
        }
        
        // Calculate Fibonacci ratio relative to the previous wave
        if (waveIndex > 0)
        {
            const SWaveInfo& prevWave = m_currentPattern.waves[waveIndex - 1];
            if (prevWave.length > 0)
            {
                wave.fibRatio = wave.length / prevWave.length;
            }
        }

        // Calculate individual wave strength
        wave.strength = CalculateWaveStrength(wave);
        wave.description = GetWaveTypeString(wave.type);

        m_currentPattern.waveCount++;
        waveIndex++;
    }

    if (m_currentPattern.waveCount > 0)
    {
        m_currentPattern.lastUpdate = TimeCurrent();
        m_currentPattern.currentWave = m_currentPattern.waves[m_currentPattern.waveCount - 1].type;
        m_pLogger.LogInfo("Successfully classified " + (string)m_currentPattern.waveCount + " waves.");
        return true;
    }

    return false;
}


//+------------------------------------------------------------------+
//| Identify Swing Points using ZigZag                             |
//+------------------------------------------------------------------+
bool CSonicRWavePattern::IdentifySwingPoints()
{
    if(m_pIndicators == NULL || m_pSymbolInfo == NULL)
    {
        m_pLogger.LogError("Null pointer in IdentifySwingPoints");
        return false;
    }

    // 1. Get ZigZag indicator handle
    // Note: Parameters (Depth, Deviation, Backstep) should be configurable
    int zigzag_handle = m_pIndicators.iZigZag(_Symbol, _Period, 12, 5, 3);
    if(zigzag_handle == INVALID_HANDLE)
    {
        m_pLogger.LogError("Failed to create ZigZag indicator handle");
        return false;
    }

    // 2. Prepare arrays to copy ZigZag data
    double zigzag_buffer[];
    ArraySetAsSeries(zigzag_buffer, true);

    // 3. Copy the last N bars of ZigZag data
    if(CopyBuffer(zigzag_handle, 0, 0, m_lookbackPeriod, zigzag_buffer) <= 0)
    {
        m_pLogger.LogWarning("Failed to copy ZigZag buffer data");
        return false;
    }

    // 4. Clear previous swing points
    ArrayResize(m_swingPoints, 0);
    m_swingPointCount = 0;

    // 5. Iterate through ZigZag data to find non-zero values (the swings)
    for(int i = 0; i < m_lookbackPeriod; i++)
    {
        if(zigzag_buffer[i] > 0)
        {
            SWavePoint point;
            point.price = zigzag_buffer[i];
            point.barIndex = i;
            
            // To get the exact time, we need to query the bar's open time
            datetime times[];
            if(CopyTime(_Symbol, _Period, i, 1, times) > 0)
            {
                point.time = times[0];
            }

            // Determine if it's a high or low swing
            // This requires comparing with surrounding prices, a simple approximation:
            double high[], low[];
            CopyHigh(_Symbol, _Period, i, 1, high);
            CopyLow(_Symbol, _Period, i, 1, low);

            if(MathAbs(point.price - high[0]) < m_pSymbolInfo.PipValue())
            {
                point.isHigh = true;
                point.isLow = false;
            }
            else if(MathAbs(point.price - low[0]) < m_pSymbolInfo.PipValue())
            {
                point.isHigh = false;
                point.isLow = true;
            }
            
            // Add to our array of swing points
            int newSize = m_swingPointCount + 1;
            ArrayResize(m_swingPoints, newSize);
            m_swingPoints[m_swingPointCount] = point;
            m_swingPointCount++;
        }
    }

    // Sort swing points by time ascending
    // Custom sort function would be needed here if they are not already in order
    // For now, we assume they are copied in order from oldest to newest.

    if(m_pLogger != NULL)
        m_pLogger.LogInfo("Identified " + (string)m_swingPointCount + " swing points.");

    return m_swingPointCount > 0;
}

    
    // Wave pattern queries
    bool GetCurrentPattern(SWavePattern& pattern);
    bool GetWaveInfo(ENUM_WAVE_TYPE waveType, SWaveInfo& waveInfo);
    int GetSwingPoints(SWavePoint &points[], int count); // New method to get swing points
    bool IsImpulseWave(ENUM_WAVE_TYPE waveType);
    bool IsCorrectionWave(ENUM_WAVE_TYPE waveType);
    
    // Pattern validation
    bool ValidateImpulsePattern();
    bool ValidateCorrectionPattern();
    bool ValidateFibonacciRatios();

//+------------------------------------------------------------------+
//| Validate the impulse wave pattern against Elliott rules.         |
//+------------------------------------------------------------------+
bool CSonicRWavePattern::ValidateImpulsePattern()
{
    if (!m_currentPattern.isImpulsePattern || m_currentPattern.waveCount < 5)
        return false;

    SWaveInfo& w1 = m_currentPattern.waves[0];
    SWaveInfo& w2 = m_currentPattern.waves[1];
    SWaveInfo& w3 = m_currentPattern.waves[2];
    SWaveInfo& w4 = m_currentPattern.waves[3];
    SWaveInfo& w5 = m_currentPattern.waves[4];

    // Rule 1: Wave 2 cannot retrace more than 100% of Wave 1.
    if (w2.endPoint.price <= w1.startPoint.price) // For uptrend
    {
        m_pLogger.LogInfo("Impulse Validation Fail: Wave 2 retraced > 100% of Wave 1.");
        return false;
    }

    // Rule 2: Wave 3 can never be the shortest of the impulse waves (1, 3, 5).
    if (w3.length <= w1.length && w3.length <= w5.length)
    {
        m_pLogger.LogInfo("Impulse Validation Fail: Wave 3 is the shortest.");
        return false;
    }

    // Rule 3: Wave 4 does not overlap with the price territory of Wave 1.
    if (w4.endPoint.price <= w1.endPoint.price) // For uptrend
    {
        m_pLogger.LogInfo("Impulse Validation Fail: Wave 4 overlaps Wave 1.");
        return false;
    }

    m_pLogger.LogInfo("Impulse Wave Pattern is valid.");
    return true;
}

//+------------------------------------------------------------------+
//| Validate the correction wave pattern against Elliott rules.      |
//+------------------------------------------------------------------+
bool CSonicRWavePattern::ValidateCorrectionPattern()
{
    if (!m_currentPattern.isCorrectionPattern || m_currentPattern.waveCount < 8)
        return false; // Assumes an ABC correction after a 5-wave impulse

    SWaveInfo& wA = m_currentPattern.waves[5];
    SWaveInfo& wB = m_currentPattern.waves[6];
    SWaveInfo& wC = m_currentPattern.waves[7];

    // Basic ZigZag (5-3-5) validation (simplified)
    // A proper validation would need to check the sub-waves of A, B, and C.
    
    // Guideline: Wave B typically retraces 38.2% to 61.8% of Wave A.
    double retracement = wB.length / wA.length;
    if (retracement < 0.382 - m_fibTolerance || retracement > 0.618 + m_fibTolerance)
    {
        m_pLogger.LogInfo("Correction Guideline Fail: Wave B retracement is outside typical range.");
        // This is a guideline, not a strict rule, so we don't return false.
    }

    m_pLogger.LogInfo("Correction Wave Pattern is valid (basic check).");
    return true;
}

    
    // Strength calculations
    double CalculateWaveStrength(const SWaveInfo& wave);
    double CalculatePatternStrength();
    double GetOverallStrength() { return m_currentPattern.patternStrength; }
    
//+------------------------------------------------------------------+
//| Calculate Wave Strength based on multiple factors               |
//+------------------------------------------------------------------+
double CSonicRWavePattern::CalculateWaveStrength(const SWaveInfo& wave)
{
    if(!wave.isComplete) return 0.0;
    
    double strength = 0.0;
    double weightSum = 0.0;
    
    // 1. Length Factor (20% weight)
    const double LENGTH_WEIGHT = 0.20;
    double lengthScore = 0.0;
    
    // Compare wave length to average wave length
    double avgLength = 0.0;
    int validWaves = 0;
    for(int i = 0; i < m_currentPattern.waveCount; i++)
    {
        if(m_currentPattern.waves[i].isComplete)
        {
            avgLength += m_currentPattern.waves[i].length;
            validWaves++;
        }
    }
    if(validWaves > 0)
    {
        avgLength /= validWaves;
        lengthScore = wave.length > avgLength ? 1.0 : wave.length / avgLength;
    }
    strength += lengthScore * LENGTH_WEIGHT;
    weightSum += LENGTH_WEIGHT;
    
    // 2. Fibonacci Relationship (30% weight)
    const double FIB_WEIGHT = 0.30;
    double fibScore = 0.0;
    
    // Check if wave length matches common Fibonacci ratios (0.382, 0.618, 1.0, 1.618, 2.618)
    double fibLevels[] = {0.382, 0.618, 1.0, 1.618, 2.618};
    double minFibDiff = 1.0;
    
    for(int i = 0; i < ArraySize(fibLevels); i++)
    {
        double diff = MathAbs(wave.fibRatio - fibLevels[i]);
        if(diff < minFibDiff)
            minFibDiff = diff;
    }
    
    fibScore = 1.0 - MathMin(minFibDiff, 1.0);
    strength += fibScore * FIB_WEIGHT;
    weightSum += FIB_WEIGHT;
    
    // 3. Volume Analysis (25% weight)
    const double VOLUME_WEIGHT = 0.25;
    double volumeScore = 0.0;
    
    // Get volume data for wave duration
    long volumes[];
    if(CopyTickVolume(_Symbol, _Period, wave.startPoint.barIndex, 
                     wave.endPoint.barIndex - wave.startPoint.barIndex + 1, volumes) > 0)
    {
        // Calculate average volume for the wave period
        double avgVolume = 0;
        for(int i = 0; i < ArraySize(volumes); i++)
            avgVolume += volumes[i];
        avgVolume /= ArraySize(volumes);
        
        // Compare to recent market volume (last 20 bars)
        long recentVolumes[];
        if(CopyTickVolume(_Symbol, _Period, 0, 20, recentVolumes) > 0)
        {
            double recentAvgVolume = 0;
            for(int i = 0; i < ArraySize(recentVolumes); i++)
                recentAvgVolume += recentVolumes[i];
            recentAvgVolume /= ArraySize(recentVolumes);
            
            volumeScore = avgVolume > recentAvgVolume ? 1.0 : avgVolume / recentAvgVolume;
        }
    }
    strength += volumeScore * VOLUME_WEIGHT;
    weightSum += VOLUME_WEIGHT;
    
    // 4. Time Factor (15% weight)
    const double TIME_WEIGHT = 0.15;
    double timeScore = 0.0;
    
    // Check if wave duration is within reasonable bounds
    // Too short or too long waves are less reliable
    const int MIN_WAVE_BARS = 3;
    const int MAX_WAVE_BARS = 55; // Approximately 1 month on H1
    
    int waveBars = wave.endPoint.barIndex - wave.startPoint.barIndex;
    if(waveBars >= MIN_WAVE_BARS && waveBars <= MAX_WAVE_BARS)
    {
        timeScore = 1.0 - (double)(waveBars - MIN_WAVE_BARS) / (MAX_WAVE_BARS - MIN_WAVE_BARS);
    }
    strength += timeScore * TIME_WEIGHT;
    weightSum += TIME_WEIGHT;
    
    // 5. Pattern Context (10% weight)
    const double CONTEXT_WEIGHT = 0.10;
    double contextScore = 0.0;
    
    // Check if wave fits expected pattern sequence
    if(IsImpulseWave(wave.type))
    {
        // Impulse waves should be stronger in direction of trend
        if(wave.type == WAVE_IMPULSE_3) // Wave 3 should be strongest
            contextScore = 1.0;
        else if(wave.type == WAVE_IMPULSE_5) // Wave 5 often shows divergence
            contextScore = 0.7;
        else
            contextScore = 0.85;
    }
    else if(IsCorrectionWave(wave.type))
    {
        // Corrections should be weaker than impulses
        contextScore = 0.6;
    }
    
    strength += contextScore * CONTEXT_WEIGHT;
    weightSum += CONTEXT_WEIGHT;
    
    // Normalize final strength value
    if(weightSum > 0)
        strength /= weightSum;
        
    return MathMin(MathMax(strength, 0.0), 1.0); // Ensure result is between 0 and 1
}

    
    // Fibonacci analysis
    bool CalculateFibonacciLevels(const SWavePoint& start, const SWavePoint& end, double &levels[]);
    bool IsPriceAtFibLevel(double price, double tolerance = 0.0);
    double GetNearestFibLevel(double price);
    
    // Prediction functions
    bool PredictNextWave(SWaveInfo& predictedWave);
    bool GetWaveTargets(ENUM_WAVE_TYPE waveType, double &targets[]);
    
    // Utility functions
    string GetWaveTypeString(ENUM_WAVE_TYPE type);
    string GetWaveDegreeString(ENUM_WAVE_DEGREE degree);
    void LogWaveAnalysis();

//+------------------------------------------------------------------+
//| Calculate the overall strength of the identified pattern.        |
//+------------------------------------------------------------------+
double CSonicRWavePattern::CalculatePatternStrength()
{
    if (m_currentPattern.waveCount == 0) return 0.0;

    double totalStrength = 0;
    double totalWeight = 0;

    for (int i = 0; i < m_currentPattern.waveCount; i++)
    {
        SWaveInfo& wave = m_currentPattern.waves[i];
        double weight = 1.0; // Default weight

        // Assign higher weight to more significant waves
        if (wave.type == WAVE_IMPULSE_3) weight = 1.5;
        if (wave.type == WAVE_IMPULSE_5) weight = 1.2;

        totalStrength += wave.strength * weight;
        totalWeight += weight;
    }

    if (totalWeight == 0) return 0.0;

    return totalStrength / totalWeight;
}

//+------------------------------------------------------------------+
//| Converts a wave type enum to its string representation.          |
//+------------------------------------------------------------------+
string CSonicRWavePattern::GetWaveTypeString(ENUM_WAVE_TYPE type)
{
    switch (type)
    {
        case WAVE_IMPULSE_1: return "Impulse 1";
        case WAVE_IMPULSE_2: return "Impulse 2";
        case WAVE_IMPULSE_3: return "Impulse 3";
        case WAVE_IMPULSE_4: return "Impulse 4";
        case WAVE_IMPULSE_5: return "Impulse 5";
        case WAVE_CORRECTION_A: return "Correction A";
        case WAVE_CORRECTION_B: return "Correction B";
        case WAVE_CORRECTION_C: return "Correction C";
        default: return "Unknown";
    }
}

//+------------------------------------------------------------------+
//| Logs the details of the current wave pattern analysis.           |
//+------------------------------------------------------------------+
void CSonicRWavePattern::LogWaveAnalysis()
{
    if (m_pLogger == NULL || m_currentPattern.waveCount == 0) return;

    m_pLogger.LogInfo("--- Wave Pattern Analysis Report ---");
    m_pLogger.LogInfo("Identified Pattern Strength: " + DoubleToString(m_currentPattern.patternStrength, 2));
    m_pLogger.LogInfo("Total Waves: " + (string)m_currentPattern.waveCount);

    for (int i = 0; i < m_currentPattern.waveCount; i++)
    {
        SWaveInfo& wave = m_currentPattern.waves[i];
        string log = StringFormat("  Wave %s: Start(%.5f @ %s) -> End(%.5f @ %s), Length: %.1f pips, Strength: %.2f, Fib: %.3f",
                                  wave.description,
                                  wave.startPoint.price,
                                  TimeToString(wave.startPoint.time),
                                  wave.endPoint.price,
                                  TimeToString(wave.endPoint.time),
                                  wave.length,
                                  wave.strength,
                                  wave.fibRatio);
        m_pLogger.LogInfo(log);
    }
    m_pLogger.LogInfo("--- End of Report ---");
}

};
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSonicRWavePattern::CSonicRWavePattern() : m_pLogger(NULL),
                                           m_pIndicators(NULL),
                                           m_pSymbolInfo(NULL),
                                           m_lookbackPeriod(200),
                                           m_minWaveLength(5),
                                           m_fibTolerance(0.05),
                                           m_strengthThreshold(0.5),
                                           m_swingPointCount(0)
{
    ArrayInitialize(m_fibLevels, 0.0);
}
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSonicRWavePattern::~CSonicRWavePattern()
{
    Deinitialize();
}
//+------------------------------------------------------------------+
//| Initialize the wave pattern analyzer
//+------------------------------------------------------------------+
bool CSonicRWavePattern::Initialize(CLogger* pLogger, CIndicators* pIndicators, CSymbolInfo* pSymbolInfo)
{
    m_pLogger = pLogger;
    m_pIndicators = pIndicators;
    m_pSymbolInfo = pSymbolInfo;

    if(m_pLogger == NULL || m_pIndicators == NULL || m_pSymbolInfo == NULL)
    {
        Print("ERROR: CSonicRWavePattern::Initialize - Null dependency provided.");
        return false;
    }

    ArrayResize(m_swingPoints, 0);
    m_swingPointCount = 0;

    LOG_INFO("CSonicRWavePattern initialized successfully.");
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialize the wave pattern analyzer
//+------------------------------------------------------------------+
void CSonicRWavePattern::Deinitialize()
{
    if(m_pLogger)
        LOG_INFO("Deinitializing CSonicRWavePattern.");
    
    ArrayFree(m_swingPoints);
    m_swingPointCount = 0;
}

//+------------------------------------------------------------------+
//| Main analysis function to coordinate the process
//+------------------------------------------------------------------+
bool CSonicRWavePattern::AnalyzeWavePattern()
{
    if(!IdentifySwingPoints())
    {
        LOG_WARN(*m_pLogger, __FUNCTION__, "Failed to identify swing points. Wave analysis aborted.");
        return false;
    }

    if(!ClassifyWaves())
    {
        LOG_WARN(*m_pLogger, __FUNCTION__, "Failed to classify waves from swing points.");
        return false;
    }

    LOG_INFO("Wave pattern analysis completed successfully.");
    return true;
}

//+------------------------------------------------------------------+
//| Identify swing points using the ZigZag indicator
//+------------------------------------------------------------------+
bool CSonicRWavePattern::IdentifySwingPoints()
{
    if(m_pIndicators == NULL || m_pSymbolInfo == NULL)
        return false;

    // ZigZag parameters - these could be configurable
    int ExtDepth = 12;
    int ExtDeviation = 5;
    int ExtBackstep = 3;

    // Define the ZigZag indicator
    MqlIndicator anIndicator;
    anIndicator.name = "ZigZag";
    anIndicator.type = IND_CUSTOM;
    anIndicator.symbol = m_pSymbolInfo.Symbol();
    anIndicator.period = m_pSymbolInfo.Timeframe();
    anIndicator.parameters[0].type = TYPE_INT;
    anIndicator.parameters[0].integer_value = ExtDepth;
    anIndicator.parameters[1].type = TYPE_INT;
    anIndicator.parameters[1].integer_value = ExtDeviation;
    anIndicator.parameters[2].type = TYPE_INT;
    anIndicator.parameters[2].integer_value = ExtBackstep;
    anIndicator.num_parameters = 3;

    int handle = m_pIndicators.GetIndicatorHandle(anIndicator);
    if(handle == INVALID_HANDLE)
    {
        LOG_ERROR("Failed to get ZigZag indicator handle.");
        return false;
    }

    // Reset swing points
    ArrayResize(m_swingPoints, 0);
    m_swingPointCount = 0;

    double zigzagBuffer[];
    if(CopyBuffer(handle, 0, 0, m_lookbackPeriod, zigzagBuffer) <= 0)
    {
        LOG_ERROR("Failed to copy ZigZag buffer data.");
        return false;
    }

    MqlRates rates[];
    if(CopyRates(m_pSymbolInfo.Symbol(), m_pSymbolInfo.Timeframe(), 0, m_lookbackPeriod, rates) <= 0)
    {
        LOG_ERROR("Failed to copy rates for swing point analysis.");
        return false;
    }

    // Iterate backwards to find swing points
    for(int i = m_lookbackPeriod - 1; i >= 0; i--)
    {
        if(zigzagBuffer[i] > 0)
        {
            SWavePoint point;
            point.price = zigzagBuffer[i];
            point.time = rates[i].time;
            point.barIndex = i;
            point.isHigh = (point.price == rates[i].high);
            point.isLow = (point.price == rates[i].low);
            point.strength = 1.0; // Placeholder strength

            // Add to our array if it's a new point
            if(m_swingPointCount == 0 || m_swingPoints[m_swingPointCount - 1].price != point.price)
            {
                if(ArrayResize(m_swingPoints, m_swingPointCount + 1) > 0)
                {
                    m_swingPoints[m_swingPointCount] = point;
                    m_swingPointCount++;
                }
            }
        }
    }

    if(m_swingPointCount < 2)
    {
        LOG_INFO("Not enough swing points identified (" + (string)m_swingPointCount + ").");
        return false;
    }

    LOG_INFO("Identified " + (string)m_swingPointCount + " swing points.");
    return true;
}

//+------------------------------------------------------------------+
//| Classify waves based on the identified swing points
//+------------------------------------------------------------------+
bool CSonicRWavePattern::ClassifyWaves()
{
    if(m_swingPointCount < 6) // Need at least 6 points for a 5-wave pattern (0-1-2-3-4-5)
    {
        LOG_INFO("Insufficient swing points to classify a 5-wave pattern.");
        return false;
    }

    // --- Basic 5-Wave Impulse Pattern Recognition (Bullish Example) ---
    // This is a simplified starting point. A robust implementation is far more complex.

    // We iterate backwards through the swing points
    for(int i = m_swingPointCount - 1; i >= 5; i--)
    {
        SWavePoint p5 = m_swingPoints[i];     // Potential Wave 5 end
        SWavePoint p4 = m_swingPoints[i-1];   // Potential Wave 4 end
        SWavePoint p3 = m_swingPoints[i-2];   // Potential Wave 3 end
        SWavePoint p2 = m_swingPoints[i-3];   // Potential Wave 2 end
        SWavePoint p1 = m_swingPoints[i-4];   // Potential Wave 1 end
        SWavePoint p0 = m_swingPoints[i-5];   // Potential Wave 0 start

        // Rule 1: Wave 2 cannot retrace more than 100% of Wave 1.
        bool rule1 = (p2.price > p0.price);

        // Rule 2: Wave 3 cannot be the shortest of the impulse waves (1, 3, 5).
        double len1 = MathAbs(p1.price - p0.price);
        double len3 = MathAbs(p3.price - p2.price);
        double len5 = MathAbs(p5.price - p4.price);
        bool rule2 = (len3 > len1 && len3 > len5);

        // Rule 3: Wave 4 does not overlap with the price territory of Wave 1.
        bool rule3 = (p4.price > p1.price);

        if(rule1 && rule2 && rule3)
        {
            LOG_INFO("Potential bullish 5-wave impulse pattern found ending at bar " + (string)p5.barIndex);
            // Here you would populate the m_currentPattern struct
            // For now, we just log and return true
            return true;
        }
    }

    LOG_INFO("No clear 5-wave impulse pattern found in the current set of swing points.");
        return false; // No pattern found that matches the rules
}

//+------------------------------------------------------------------+
//| Get recent swing points                                          |
//+------------------------------------------------------------------+
int CSonicRWavePattern::GetSwingPoints(SWavePoint &points[], int count)
{
    int pointsToCopy = MathMin(count, m_swingPointCount);
    if(pointsToCopy <= 0)
        return 0;

    // Copy the most recent swing points
    if(ArrayCopy(points, m_swingPoints, 0, m_swingPointCount - pointsToCopy, pointsToCopy) > 0)
    {
        ArraySetAsSeries(points, true); // Ensure the copied array is in series order
        return pointsToCopy;
    }

    return 0;
}

//+------------------------------------------------------------------+
//| Log the current wave analysis results                            |
//+------------------------------------------------------------------+
void CSonicRWavePattern::LogWaveAnalysis()
{
    if(!m_pLogger) return;

    LOG_INFO("--- Wave Analysis Report ---");
    for(int i = 0; i < m_currentPattern.waveCount; i++)
    {
        SWaveInfo &wave = m_currentPattern.waves[i];
        string msg = StringFormat("Wave %s: Type=%s, Strength=%.2f, Length=%.1f pips, Duration=%.0f mins",
                                  wave.description, GetWaveTypeString(wave.type), wave.strength, wave.length, wave.duration);
        LOG_INFO(msg);
    }
    LOG_INFO("--------------------------");
}

//+------------------------------------------------------------------+
//| GetWaveTypeString (Utility)                                      |
//+------------------------------------------------------------------+
string CSonicRWavePattern::GetWaveTypeString(ENUM_WAVE_TYPE type)
{
    switch(type)
    {
        case WAVE_IMPULSE_1: return "Impulse 1";
        case WAVE_IMPULSE_2: return "Impulse 2";
        case WAVE_IMPULSE_3: return "Impulse 3";
        case WAVE_IMPULSE_4: return "Impulse 4";
        case WAVE_IMPULSE_5: return "Impulse 5";
        case WAVE_CORRECTION_A: return "Correction A";
        case WAVE_CORRECTION_B: return "Correction B";
        case WAVE_CORRECTION_C: return "Correction C";
        case WAVE_TRIANGLE: return "Triangle";
        case WAVE_FLAT: return "Flat";
        case WAVE_COMPLEX: return "Complex";
        default: return "Unknown";
    }
}

//+------------------------------------------------------------------+
//| GetWaveDegreeString (Utility)                                    |
//+------------------------------------------------------------------+
string CSonicRWavePattern::GetWaveDegreeString(ENUM_WAVE_DEGREE degree)
{
    switch(degree)
    {
        case DEGREE_GRAND_SUPERCYCLE: return "Grand Supercycle";
        case DEGREE_SUPERCYCLE: return "Supercycle";
        case DEGREE_CYCLE: return "Cycle";
        case DEGREE_PRIMARY: return "Primary";
        case DEGREE_INTERMEDIATE: return "Intermediate";
        case DEGREE_MINOR: return "Minor";
        case DEGREE_MINUTE: return "Minute";
        case DEGREE_MINUETTE: return "Minuette";
        case DEGREE_SUBMINUETTE: return "Subminuette";
        default: return "Unknown";
    }
}


