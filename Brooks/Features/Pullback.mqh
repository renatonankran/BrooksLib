//+------------------------------------------------------------------+
//|                                                    CPullback.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <Dev\Brooks\Features\FeaturesUtils.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPullback
  {
public:
   int               bear_pb_counter_, bull_pb_counter_, high_counter_, low_counter_;
   bool              bear_pb_for_this_bar, bull_pb_for_this_bar;

                     CPullback(): bear_pb_counter_(0),
                     bull_pb_counter_(0),
                     high_counter_(0),
                     low_counter_(0) {};

   HIGHCOUNT         HighCounting(void);
   LOWCOUNT          LowCounting(void);
   PULLBACK          Pullback(int p_trend_size);
   void              ZeroPBFlags();
   bool              HigherLowSequence(int size);
   bool              LowerHighSequence(int size);
   double            OverlapLevel(int bar1, int bar2);
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPullback::ZeroPBFlags()
  {
   bear_pb_for_this_bar = false;
   bull_pb_for_this_bar = false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PULLBACK CPullback::Pullback(int p_trend_size)
  {
   if(new_candle)
      ZeroPBFlags();

   if(!bear_pb_for_this_bar)
      if(HigherLowSequence(p_trend_size) && iClose(_Symbol, _Period, 0) < iLow(_Symbol, _Period, 1))
        {
         if(!ObjectCreate(0, (string)MathRand(), OBJ_TREND, 0, iTime(_Symbol, _Period, 1), iLow(_Symbol, _Period, 1), iTime(_Symbol, _Period, 0), iLow(_Symbol, _Period, 1)))
           {
            Print(__FUNCTION__,
                  ": failed to create a trend line! Error code = ", GetLastError());
           }
         bear_pb_for_this_bar = true;
         return BEAR_PB;
        }

   if(!bull_pb_for_this_bar)
      if(LowerHighSequence(p_trend_size) && iClose(_Symbol, _Period, 0) > iHigh(_Symbol, _Period, 1))
        {
         if(!ObjectCreate(0, (string)MathRand(), OBJ_TREND, 0, iTime(_Symbol, _Period, 1), iHigh(_Symbol, _Period, 1), iTime(_Symbol, _Period, 0), iHigh(_Symbol, _Period, 1)))
           {
            Print(__FUNCTION__,
                  ": failed to create a trend line! Error code = ", GetLastError());
           }
         bull_pb_for_this_bar = true;
         return BULL_PB;
        }
   return NO_PB;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
HIGHCOUNT CPullback::HighCounting(void)
  {
   if(Pullback(2) == BULL_PB)
      ++high_counter_;


   switch(high_counter_)
     {
      case 1:
         return H_1;
      case 2:
         return H_2;
      case 3:
         return H_3;
      case 4:
         return H_4;
      case 5:
        {
         high_counter_ = 0;
         return H_5;
        }

      default:
         return WRONG_VALUE;
     }
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
LOWCOUNT CPullback::LowCounting(void)
  {
   if(Pullback(2) == BEAR_PB)
      ++low_counter_;

   switch(low_counter_)
     {
      case 1:
         return L_1;
      case 2:
         return L_2;
      case 3:
         return L_3;
      case 4:
         return L_4;
      case 5:
        {
         low_counter_ = 0;
         return L_5;
        }

      default:
         return WRONG_VALUE;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPullback::HigherLowSequence(int size)
  {
   int counter = 0;
   for(int i = 1; i <= size - 1; i++)
     {
      if(HigherLow(i))
         ++counter;
     }
   if(counter == size - 1)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPullback::LowerHighSequence(int size)
  {
   int counter = 0;
   for(int i = 1; i <= size - 1; i++)
     {
      if(LowerHigh(i))
         ++counter;
     }
   if(counter == size - 1)
      return true;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CPullback::OverlapLevel(int bar1, int bar2)
  {
   double total_range = 1;
   double intersection = 1;
   double bar1_high = iHigh(_Symbol, _Period, bar1);
   double bar2_high = iHigh(_Symbol, _Period, bar2);

   if(bar2_high <= bar1_high)
     {
      total_range = iHigh(_Symbol, _Period, bar1) - iLow(_Symbol, _Period, bar2);
      intersection = iHigh(_Symbol, _Period, bar2) - iLow(_Symbol, _Period, bar1);
     }
   if(bar2_high > bar1_high)
     {
      total_range = iHigh(_Symbol, _Period, bar2) - iLow(_Symbol, _Period, bar1);
      intersection = iHigh(_Symbol, _Period, bar1) - iLow(_Symbol, _Period, bar2);
     }
   if(total_range == 0)
      return 1000;
   return intersection / total_range; // returns the degree of positive overlap and negative or no overlap

  }

//+------------------------------------------------------------------+
