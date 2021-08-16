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
//+------------------------------------------------------------------+
