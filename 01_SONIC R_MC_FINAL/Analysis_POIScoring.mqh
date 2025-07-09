//+------------------------------------------------------------------+
//|                                    Analysis_POIScoring.mqh |
//|                        Copyright 2024, MQL5-SOLUTIONS.IO |
//|                               https://www.mql5-solutions.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MQL5-SOLUTIONS.IO"
#property link      "https://www.mql5-solutions.io"
#property version   "1.00"

#include "Shared_DataStructures.mqh"

//+------------------------------------------------------------------+
//| Scoring Criteria Weights (can be made inputs later)              |
//+------------------------------------------------------------------+
#define WEIGHT_LIQUIDITY_SWEEP 25
#define WEIGHT_IMBALANCE 20
#define WEIGHT_FRESHNESS 15
#define WEIGHT_PD_ARRAY 15
#define WEIGHT_VOLUME_PROFILE 10
#define WEIGHT_CONFLUENCE 15



//+------------------------------------------------------------------+
//| POI Scoring Engine Class                                         |
//+------------------------------------------------------------------+
class CPOIScoringEngine
{
private:
    // Helper methods for calculating individual scores
    int CalculateLiquiditySweepScore(const OrderBlock &ob, const SwingPoint &structure[]);
    int CalculateImbalanceScore(const OrderBlock &ob, const FairValueGap &fvgs[]);
    int CalculateFreshnessScore(const OrderBlock &ob);
    int CalculatePDArrayScore(const OrderBlock &ob, const SwingPoint &leg_start, const SwingPoint &leg_end);
    int CalculateVolumeProfileScore(const OrderBlock &ob);
    int CalculateConfluenceScore(const OrderBlock &ob);

public:
    // Main method to score a given Point of Interest (Order Block)
    POIScore ScoreOrderBlock(const OrderBlock &ob, const MqlRates &rates[], const SwingPoint &structure[], const FairValueGap &fvgs[]);

    // Method to score a Fair Value Gap (can be added later)
    // POIScore ScoreFVG(const FairValueGap &fvg);
};

//+------------------------------------------------------------------+
//| Main Scoring Method Implementation                               |
//+------------------------------------------------------------------+
POIScore CPOIScoringEngine::ScoreOrderBlock(const OrderBlock &ob, const MqlRates &rates[], const SwingPoint &structure[], const FairValueGap &fvgs[])
{
    POIScore score;

    // Find the leg that the OB belongs to for context
    SwingPoint leg_start, leg_end;
    for(int i = ArraySize(structure) - 2; i >= 0; i--)
    {
        if(structure[i].time < ob.time && structure[i+1].time > ob.time)
        {
            leg_start = structure[i];
            leg_end = structure[i+1];
            break;
        }
    }

    score.liquiditySweepScore = CalculateLiquiditySweepScore(ob, structure);
    score.imbalanceScore = CalculateImbalanceScore(ob, fvgs);
    score.freshnessScore = CalculateFreshnessScore(ob);
    score.pdArrayScore = CalculatePDArrayScore(ob, leg_start, leg_end);
    score.volumeProfileScore = CalculateVolumeProfileScore(ob);
    score.confluenceScore = CalculateConfluenceScore(ob);

    // Calculate total weighted score
    score.totalScore = (score.liquiditySweepScore * WEIGHT_LIQUIDITY_SWEEP +
                        score.imbalanceScore * WEIGHT_IMBALANCE +
                        score.freshnessScore * WEIGHT_FRESHNESS +
                        score.pdArrayScore * WEIGHT_PD_ARRAY +
                        score.volumeProfileScore * WEIGHT_VOLUME_PROFILE +
                        score.confluenceScore * WEIGHT_CONFLUENCE) / 100;

    return score;
}

//+------------------------------------------------------------------+
//| Individual Score Calculations Implementation                     |
//+------------------------------------------------------------------+
int CPOIScoringEngine::CalculateLiquiditySweepScore(const OrderBlock &ob, const SwingPoint &structure[]) 
{
    // TODO: Find the swing point that this OB is supposed to have swept.
    // For now, placeholder.
    return 50; 
}

int CPOIScoringEngine::CalculateImbalanceScore(const OrderBlock &ob, const FairValueGap &fvgs[]) 
{
    // Check if the OB is directly followed by or adjacent to an FVG
    for(int i = 0; i < ArraySize(fvgs); i++)
    {
        // Bullish OB: FVG should be right after
        if(ob.type == 1 && fvgs[i].start_bar_index == ob.bar_index - 1)
        {
            // Check if the FVG is significant (e.g., larger than the OB body)
            return 100; // High score for clear imbalance
        }
        // Bearish OB: FVG should be right after
        if(ob.type == -1 && fvgs[i].start_bar_index == ob.bar_index - 1)
        {
            return 100; // High score for clear imbalance
        }
    }
    return 10; // Low score if no immediate FVG
}

int CPOIScoringEngine::CalculateFreshnessScore(const OrderBlock &ob) 
{
    // 100 if not mitigated, 0 if it is.
    return ob.is_mitigated ? 0 : 100; 
}

int CPOIScoringEngine::CalculatePDArrayScore(const OrderBlock &ob, const SwingPoint &leg_start, const SwingPoint &leg_end) 
{
    if(leg_start.time == 0 || leg_end.time == 0) return 50; // Neutral if leg not found

    double equilibrium = (leg_start.price + leg_end.price) / 2.0;

    // For a Bullish OB (demand), we want it to be in the discount zone.
    if(ob.type == 1)
    {
        if(ob.price_low < equilibrium) return 100; // Prime location
        else return 20; // Poor location
    }
    // For a Bearish OB (supply), we want it to be in the premium zone.
    else if(ob.type == -1)
    {
        if(ob.price_high > equilibrium) return 100; // Prime location
        else return 20; // Poor location
    }

    return 50; // Should not happen
}

int CPOIScoringEngine::CalculateVolumeProfileScore(const OrderBlock &ob) 
{
    // TODO: Requires integration with a Volume Profile indicator.
    // Check if the OB overlaps with a High Volume Node (HVN) or Point of Control (POC).
    return 50; // Placeholder
}

int CPOIScoringEngine::CalculateConfluenceScore(const OrderBlock &ob) 
{
    // TODO: Check for confluence with other factors like:
    // - MTF High/Low levels
    // - Major round numbers
    // - Other indicator signals (e.g., moving averages)
    return 50; // Placeholder
}
//+------------------------------------------------------------------+