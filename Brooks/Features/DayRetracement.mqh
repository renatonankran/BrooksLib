//+------------------------------------------------------------------+
//|                                               DayRetracement.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <Dev\Brooks\Features\Structs\Index.mqh>
#include <Dev\Brooks\Features\Index.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CDayRetracement
  {
public:
   DayExtremeStruc   day_extreme_;
   CPullback         Pullback_;
   double            last_retracement_;
   double            retracement_50, retracement_70;
   datetime          time_bar_50, time_bar_70, empty_time;
   double            entry_50, entry_70;
   HILO              last_side_;

                     CDayRetracement(void): last_side_(WRONG_VALUE) {};
   void              Load(void);
   void              CalcRetracement(void);
   MqlTradeRequest   CalcEntry(void);
   bool              EntryTrigger(void);
   double            EntryPrice(void);
   double            TakeProfit(datetime p_bar_time);
   double            StopLoss(datetime p_bar_time);
   void              FindFirstBar(void);
   void              PrintSignal(void);
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDayRetracement::PrintSignal(void)
  {
   Print("last_side_: ", last_side_);
   Print("last_retracement_: ", last_retracement_);
   Print("time_bar_50: ", time_bar_50);
   Print("time_bar_70: ", time_bar_70);
   Print("candleCount: ", candleCount);
   Print("-------------------||-------------------");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDayRetracement::FindFirstBar(void)
  {
   if(last_side_ != day_extreme_.last_side)
     {
      last_side_ = day_extreme_.last_side;
      time_bar_50 = empty_time;
      time_bar_70 = empty_time;
      entry_70 = false;
      entry_50 = false;
     }
   if(last_retracement_ >= .5 && time_bar_50 == empty_time)
      time_bar_50 = iTime(_Symbol, _Period, 0);
   if(last_retracement_ >= .7 && time_bar_70 == empty_time)
      time_bar_70 = iTime(_Symbol, _Period, 0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MqlTradeRequest CDayRetracement::CalcEntry(void)
  {
   Load();

   MqlTradeRequest entry_info;
   entry_info.type = WRONG_VALUE;
   entry_info.action = TRADE_ACTION_DEAL;

//PrintSignal();

   if(candleCount > 8)
     {
      CalcRetracement();
      FindFirstBar();
      PULLBACK pb = Pullback_.Pullback(2);

      if(day_extreme_.last_side == HIGH)
        {
         if(last_retracement_ >= .70 && pb == BULL_PB && !entry_70)
           {
            entry_info.type = ORDER_TYPE_BUY;
            entry_info.sl = StopLoss(time_bar_70);
            entry_info.tp = TakeProfit(time_bar_70);
            entry_info.price = iHigh(_Symbol,_Period,1);
            if(entry_info.tp == 0)
               entry_info.type = WRONG_VALUE;
            entry_70 = true;
            return entry_info;
           }
         if(last_retracement_ >= .50 && pb == BULL_PB && !entry_50)
           {
            entry_info.type = ORDER_TYPE_BUY;
            entry_info.sl = StopLoss(time_bar_50);
            entry_info.tp = TakeProfit(time_bar_50);
            entry_info.price = iHigh(_Symbol,_Period,1);
            if(entry_info.tp == 0)
               entry_info.type = WRONG_VALUE;
            entry_50 = true;
            return entry_info;
           }
        }

        {
         if(day_extreme_.last_side == LOW)
           {
            if(last_retracement_ >= .70 && pb == BEAR_PB && !entry_70)
              {
               entry_info.type = ORDER_TYPE_SELL;
               entry_info.sl = StopLoss(time_bar_70);
               entry_info.tp = TakeProfit(time_bar_70);
               entry_info.price = iLow(_Symbol,_Period,1);
               if(entry_info.tp == 0)
                  entry_info.type = WRONG_VALUE;
               entry_70 = true;
               return entry_info;
              }
            if(last_retracement_ >= .50 && pb == BEAR_PB && !entry_50)
              {
               entry_info.type = ORDER_TYPE_SELL;
               entry_info.sl = StopLoss(time_bar_50);
               entry_info.tp = TakeProfit(time_bar_50);
               entry_info.price = iLow(_Symbol,_Period,1);
               if(entry_info.tp == 0)
                  entry_info.type = WRONG_VALUE;
               entry_50 = true;
               return entry_info;
              }
           }
        }
     }
   return entry_info;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDayRetracement::Load(void)
  {
   day_extreme_.Load();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDayRetracement::CalcRetracement(void)
  {
   if(day_extreme_.max_timestamp == day_extreme_.min_timestamp)
     {
      last_retracement_ = 0;
      retracement_50 = 0;
      retracement_70 = 0;
      return;
     }

   if(day_extreme_.last_side == HIGH)
     {
      double day_range = day_extreme_.GetDayMaxBarHigh() - day_extreme_.GetDayMinBarLow();
      double retracement_range = day_extreme_.GetDayMaxBarHigh() - iLow(_Symbol, PERIOD_M5, 0);
      retracement_50 = (day_range * .5) + day_extreme_.GetDayMinBarLow();
      retracement_70 = (day_range * .3) + day_extreme_.GetDayMinBarLow();
      if(day_range == 0)
        {
         last_retracement_ = 0;
         return;
        }
      last_retracement_ = retracement_range / day_range;
     }
   if(day_extreme_.last_side == LOW)
     {
      double day_range = day_extreme_.GetDayMaxBarHigh() - day_extreme_.GetDayMinBarLow();
      double retracement_range =  iHigh(_Symbol, PERIOD_M5, 0) - day_extreme_.GetDayMinBarLow();
      retracement_50 = (day_range * .5) + day_extreme_.GetDayMinBarLow();
      retracement_70 = (day_range * .7) + day_extreme_.GetDayMinBarLow();
      if(day_range == 0)
        {
         last_retracement_ = 0;
         return;
        }
      last_retracement_ = retracement_range / day_range;
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CDayRetracement::StopLoss(datetime p_bar_time)
  {
   int count = iBarShift(_Symbol, _Period, p_bar_time);
   if(day_extreme_.last_side == HIGH)
     {
      int index = iLowest(_Symbol, _Period, MODE_LOW, count, 0);
      return  iLow(_Symbol, _Period, index) - simbol_tick;
     }
   if(day_extreme_.last_side == LOW)
     {
      int index = iHighest(_Symbol, _Period, MODE_HIGH, count, 0);
      return iHigh(_Symbol, _Period, index) + simbol_tick;
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CDayRetracement::TakeProfit(datetime p_bar_time)
  {
   int count = iBarShift(_Symbol, _Period, p_bar_time);
   if(day_extreme_.last_side == HIGH)
     {
      int index = iLowest(_Symbol, _Period, MODE_LOW, count, 0);
      double diff = iClose(_Symbol, _Period, 0) - iLow(_Symbol, _Period, index);
      return diff + iClose(_Symbol, _Period, 0) - simbol_tick;
     }
   if(day_extreme_.last_side == LOW)
     {
      int index = iHighest(_Symbol, _Period, MODE_HIGH, count, 0);
      double diff = iHigh(_Symbol, _Period, index) - iClose(_Symbol, _Period, 0);
      return iClose(_Symbol, _Period, 0) - diff + simbol_tick;
     }
   return 0;
  }
//+------------------------------------------------------------------+
