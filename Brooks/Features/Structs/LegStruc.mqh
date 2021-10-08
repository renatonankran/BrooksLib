//+------------------------------------------------------------------+
//|                                                     LegStruc.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include <Dev\Brooks\Enums.mqh>
#define MAX_DBL 9999999999
#define MIN_DBL 0

struct LegStruc
  {
   double            min;
   double            max;
   datetime          min_timestamp, max_timestamp;
   bool              pullback_gap;
   double            retracement_level;
   int               num_of_pb_bars;
   bool              TypeOneTrigger;
   bool              TypeTwoTrigger;
   bool              breakout;
   int               level;
                     LegStruc(): min(MAX_DBL), max(MIN_DBL) {};
                     LegStruc(double min, double max, datetime min_timestamp, datetime max_timestamp);
   void              PrintLeg(void);
   void              Reset(void);
   void              Update(LegStruc &p_leg);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
LegStruc::LegStruc(double p_min, double p_max, datetime p_min_timestamp, datetime p_max_timestamp)
  {
   min = p_min;
   max = p_max;
   min_timestamp = p_min_timestamp;
   max_timestamp = p_max_timestamp;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LegStruc::Update(LegStruc &p_leg)
  {
   min = p_leg.min;
   max = p_leg.max;
   min_timestamp = p_leg.min_timestamp;
   max_timestamp = p_leg.max_timestamp;
   pullback_gap = p_leg.pullback_gap;
   retracement_level = p_leg.retracement_level;
   num_of_pb_bars = p_leg.num_of_pb_bars;
   TypeOneTrigger = p_leg.TypeOneTrigger;
   TypeTwoTrigger = p_leg.TypeTwoTrigger;
   breakout = p_leg.breakout;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LegStruc::Reset(void)
  {
   datetime time = TimeCurrent() - 2 * DAY_SEC;
   min = MAX_DBL;
   max = MIN_DBL;
   min_timestamp = time;
   max_timestamp = time;
   pullback_gap = false;
   retracement_level = 0;
   num_of_pb_bars = 0 ;
   TypeOneTrigger = false;
   TypeTwoTrigger = false;
   breakout = false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LegStruc::PrintLeg(void)
  {
   Print("level: ", level);
   Print("min: ", min);
   Print("max: ", max);
   Print("min_timestamp: ", min_timestamp);
   Print("max_timestamp: ", max_timestamp);
   Print("pullback_gap: ", pullback_gap);
   Print("retracement_level: ", retracement_level);
   Print("num_of_pb_bars: ", num_of_pb_bars);
   Print("TypeOneTrigger: ", TypeOneTrigger);
   Print("TypeTwoTrigger: ", TypeTwoTrigger);
   Print("breakout: ", breakout);
  }
//+------------------------------------------------------------------+

