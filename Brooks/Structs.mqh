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
                     MicroChannelStruc(): ChannelOrientation(NO_CHANNEL), size(0), start_arrow_name("arrow"+(string)MathRand()), end_arrow_name("arrow"+(string)MathRand()) {};
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
                     int p_importance=1);

   int               left_weight;
   int               right_weight;
   int               importance;
   HILO              hilo;
   bool              closed;
   datetime          timestamp;
   double            extreme_high;
   double            extreme_low;
   int               GetBarIndex(void);
   void              AddToRightWeight(int val=1);
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
                                     int p_importance=1)
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
void GraphExtremeStruc::AddToRightWeight(int val=1)
  {
   right_weight+=val;
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GraphExtremeStruc::Close(void)
  {
   closed=true;
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
struct MinMaxStruc
  {
   double            min;
   double            max;
   datetime          min_timestamp, max_timestamp;
   bool              pullback_started;
                     MinMaxStruc(): min(MAX_DBL), max(MIN_DBL) {};
  };
//+------------------------------------------------------------------+
