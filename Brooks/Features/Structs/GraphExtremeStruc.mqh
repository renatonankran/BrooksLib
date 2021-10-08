//+------------------------------------------------------------------+
//|                                            GraphExtremeStruc.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include <Dev\Brooks\Enums.mqh>

struct GraphExtremeStruc
  {
                     GraphExtremeStruc(): hilo(WRONG_VALUE) {};
                     GraphExtremeStruc(datetime p_timestamp,
                     double p_extreme_high,
                     double p_extreme_low,
                     HILO p_hilo,
                     int p_importance = 1);

   int               importance;
   HILO              hilo;
   bool              closed;
   datetime          timestamp;
   double            extreme_high;
   double            extreme_low;
   int               GetBarIndex(void);
   void              Close(void);
   void              PrintNode(void);
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
GraphExtremeStruc::GraphExtremeStruc(datetime p_timestamp,
                                     double p_extreme_high,
                                     double p_extreme_low,
                                     HILO p_hilo,
                                     int p_importance = 1)
  {
   hilo = p_hilo;
   importance = p_importance;
   timestamp = p_timestamp;
   extreme_high = p_extreme_high;
   extreme_low = p_extreme_low;
  }

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
   Print("closed: ", closed);
   Print("timestamp: ", timestamp);
   Print("extreme_high: ", extreme_high);
   Print("extreme_low: ", extreme_low);
   Print("HILO: ", hilo);
   Print("importance: ", importance);
  }



//+------------------------------------------------------------------+