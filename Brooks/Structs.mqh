//+------------------------------------------------------------------+
//|                                                      Structs.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include <Dev\Brooks\Enums.mqh>

struct MicroChannelStruc
  {
                     MicroChannelStruc(): ChannelOrientation(NO_CHANNEL), size(0), start_arrow_name("arrow"+(string)MathRand()), end_arrow_name("arrow"+(string)MathRand()) {};
   MICRO_CHANNEL     ChannelOrientation;
   int               size;
   string            start_arrow_name;
   string            end_arrow_name;
  };

struct GraphExtremeStruc
  {
                     GraphExtremeStruc();
                     GraphExtremeStruc(int p_right_weight,
                     datetime p_timestamp,
                     double p_extreme_high,
                     double p_extreme_low);

   int               index; // From current candle ArrayAsTimeseries. search O(n), insert O(n), retrive O(1)
   int               left_weight;
   int               right_weight;
   bool              closed;
   datetime          timestamp;
   double            extreme_high;
   double            extreme_low;
   void              AddToIndex(int val=1);
   void              AddToLeftWeight(int val=1);
   void              AddToRightWeight(int val=1);
   void              Close(void);
   void              PrintNode(void);
  };

GraphExtremeStruc::GraphExtremeStruc() {}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
GraphExtremeStruc::GraphExtremeStruc(int p_right_weight,
                                     datetime p_timestamp,
                                     double p_extreme_high,
                                     double p_extreme_low)
  {
   index = 1;
   right_weight = 1;
   left_weight = p_right_weight;
   timestamp = p_timestamp;
   extreme_high = p_extreme_high;
   extreme_low = p_extreme_low;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GraphExtremeStruc::AddToIndex(int val=1)
  {
   index+=val;
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GraphExtremeStruc::AddToLeftWeight(int val=1)
  {
   left_weight+=val;
  };

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
   Print("index: ",index);
   Print("left_weight: ", left_weight);
   Print("right_weight: ", right_weight);
   Print("closed: ", closed);
   Print("timestamp: ", timestamp);
   Print("extreme_high: ", extreme_high);
   Print("extreme_low: ", extreme_low);
  }
//+------------------------------------------------------------------+
