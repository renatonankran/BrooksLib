//+------------------------------------------------------------------+
//|                                                   EntryStruc.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

struct EntryInfoStruc
  {
   double             open_price;
   double             stop_loss;
   double             take_profit;
   ENUM_POSITION_TYPE position_type;
  };

//+------------------------------------------------------------------+
