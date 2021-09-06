//+------------------------------------------------------------------+
//|                                                      Structs.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include <Dev\Brooks\Enums.mqh>
#define MAX_DBL 9999999999
#define MIN_DBL 0

struct MicroChannelStruc
  {
                     MicroChannelStruc(): ChannelOrientation(NO_CHANNEL), size(0), start_arrow_name("arrow" + (string)MathRand()), end_arrow_name("arrow" + (string)MathRand()) {};
   MICRO_CHANNEL     ChannelOrientation;
   int               size;
   string            start_arrow_name;
   string            end_arrow_name;
  };
//+------------------------------------------------------------------+
struct GraphExtremeStruc
  {
                     GraphExtremeStruc(): hilo(WRONG_VALUE) {};
                     GraphExtremeStruc(int p_right_weight,
                     datetime p_timestamp,
                     double p_extreme_high,
                     double p_extreme_low,
                     HILO p_hilo,
                     int p_importance = 1);

   int               left_weight;
   int               right_weight;
   int               importance;
   HILO              hilo;
   bool              closed;
   datetime          timestamp;
   double            extreme_high;
   double            extreme_low;
   int               GetBarIndex(void);
   void              AddToRightWeight(int val = 1);
   void              Close(void);
   void              PrintNode(void);
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
GraphExtremeStruc::GraphExtremeStruc(int p_right_weight,
                                     datetime p_timestamp,
                                     double p_extreme_high,
                                     double p_extreme_low,
                                     HILO p_hilo,
                                     int p_importance = 1)
  {
   hilo = p_hilo;
   importance = p_importance;
   right_weight = 1;
   left_weight = p_right_weight;
   timestamp = p_timestamp;
   extreme_high = p_extreme_high;
   extreme_low = p_extreme_low;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GraphExtremeStruc::AddToRightWeight(int val = 1)
  {
   right_weight += val;
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GraphExtremeStruc::Close(void)
  {
   closed = true;
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GraphExtremeStruc::PrintNode(void)
  {
   Print("left_weight: ", left_weight);
   Print("right_weight: ", right_weight);
   Print("closed: ", closed);
   Print("timestamp: ", timestamp);
   Print("extreme_high: ", extreme_high);
   Print("extreme_low: ", extreme_low);
   Print("HILO: ", hilo);
   Print("importance: ", importance);
  }



//+------------------------------------------------------------------+
struct LegStruc
  {
   double            min;
   double            max;
   datetime          min_timestamp, max_timestamp;
   bool              pullback_gap;
   double            retracement_level;
   int               num_of_pb_bars;
   bool              gap_trigger;
   int               n_of_bars_trigger;
   bool              signal_bar_trigger;
   bool              breakout;
   int               level;
                     LegStruc(): min(MAX_DBL), max(MIN_DBL) {};
   void              PrintLeg(void);
   void              Reset(void);
   void              Update(LegStruc &p_leg);
  };

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
   gap_trigger = p_leg.gap_trigger;
   signal_bar_trigger = p_leg.signal_bar_trigger;
   n_of_bars_trigger = p_leg.n_of_bars_trigger;
   breakout = p_leg.breakout;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LegStruc::Reset(void)
  {
   datetime time = TimeCurrent() - 2*DAY_SEC;
   min = MAX_DBL;
   max = MIN_DBL;
   min_timestamp = time;
   max_timestamp = time;
   pullback_gap = false;
   retracement_level = 0;
   num_of_pb_bars = 0 ;
   n_of_bars_trigger = 0;
   signal_bar_trigger = false;
   gap_trigger = false;
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
   Print("gap_trigger: ", gap_trigger);
   Print("n_of_bars_trigger: ", n_of_bars_trigger);
   Print("signal_bar_trigger: ", signal_bar_trigger);
   Print("breakout: ", breakout);
  }
//+------------------------------------------------------------------+
