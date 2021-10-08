//+------------------------------------------------------------------+
//|                                              DayExtremeStruc.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <Dev\Brooks\Features\FeaturesUtils.mqh>

struct DayExtremeStruc
  {
   datetime          min_timestamp;
   datetime          max_timestamp;
   double            highest_close;
   double            lowest_close;
   HILO              last_side;
   bool              stop_finding_side;
   void              Load(ENUM_TIMEFRAMES p_tf = PERIOD_M5, int days = 0);
   void              LoadYesterday(int start, int count, ENUM_TIMEFRAMES p_tf = PERIOD_M5);
   double            GetDayMinBarHigh(ENUM_TIMEFRAMES p_tf = PERIOD_M5);
   double            GetDayMinBarLow(ENUM_TIMEFRAMES p_tf = PERIOD_M5);
   double            GetDayMaxBarHigh(ENUM_TIMEFRAMES p_tf = PERIOD_M5);
   double            GetDayMaxBarLow(ENUM_TIMEFRAMES p_tf = PERIOD_M5);
   int               GetDayMinIndex(ENUM_TIMEFRAMES p_tf = PERIOD_M5);
   int               GetDayMaxIndex(ENUM_TIMEFRAMES p_tf = PERIOD_M5);
   void              StopFindingSide(bool flag = true);
   void              PrintStruc(void);
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int DayExtremeStruc::GetDayMinIndex(ENUM_TIMEFRAMES p_tf = 5)
  {
   return iBarShift(_Symbol, p_tf, min_timestamp, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int DayExtremeStruc::GetDayMaxIndex(ENUM_TIMEFRAMES p_tf = 5)
  {
   return iBarShift(_Symbol, p_tf, max_timestamp, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DayExtremeStruc::StopFindingSide(bool flag = true)
  {
   stop_finding_side = flag;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DayExtremeStruc::Load(ENUM_TIMEFRAMES p_tf = PERIOD_M5, int days = 0)
  {
   int count_today = CountDistanceFromCurrentCandle(0, p_tf) + 1;
   int count_complete = CountDistanceFromCurrentCandle(days, p_tf) + 1;
   int past = count_complete - count_today;
   if(past > 0)
     {
      LoadYesterday(count_today, past, p_tf);
      return;
     }

   int low_index = iLowest(_Symbol, p_tf, MODE_LOW, count_today - 1, 1);
   int high_index = iHighest(_Symbol, p_tf, MODE_HIGH, count_today - 1, 1);
   int low_close_index = iLowest(_Symbol, p_tf, MODE_CLOSE, count_today - 1, 1);
   int high_close_index = iHighest(_Symbol, p_tf, MODE_CLOSE, count_today - 1, 1);

   datetime min_timestamp_tmp = iTime(_Symbol, p_tf, low_index);
   datetime max_timestamp_tmp = iTime(_Symbol, p_tf, high_index);
   lowest_close = iClose(_Symbol, p_tf, low_close_index);
   highest_close = iClose(_Symbol, p_tf, high_close_index);

   if(high_index == count_today - 1 && IsBearBar(high_index))
      highest_close = iOpen(_Symbol, _Period, high_index);
   if(low_index == count_today - 1 && IsBullBar(low_index))
      lowest_close = iOpen(_Symbol, _Period, low_index);

   if(!stop_finding_side && max_timestamp_tmp != max_timestamp)
     {
      last_side = HIGH;
      max_timestamp = max_timestamp_tmp;
     }
   if(!stop_finding_side && min_timestamp_tmp != min_timestamp)
     {
      last_side = LOW;
      min_timestamp = min_timestamp_tmp;
     }
   if(min_timestamp == max_timestamp)
      last_side = -1;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DayExtremeStruc::LoadYesterday(int start, int count, ENUM_TIMEFRAMES p_tf = PERIOD_M5)
  {
   int low_index = iLowest(_Symbol, p_tf, MODE_LOW, count, start);
   int high_index = iHighest(_Symbol, p_tf, MODE_HIGH, count, start);
   min_timestamp = iTime(_Symbol, p_tf, low_index);
   max_timestamp = iTime(_Symbol, p_tf, high_index);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double DayExtremeStruc::GetDayMaxBarHigh(ENUM_TIMEFRAMES p_tf = PERIOD_M5)
  {
   return iHigh(_Symbol, p_tf, GetDayMaxIndex(p_tf));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double DayExtremeStruc::GetDayMaxBarLow(ENUM_TIMEFRAMES p_tf = PERIOD_M5)
  {
   return iLow(_Symbol, p_tf, GetDayMaxIndex(p_tf));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double DayExtremeStruc::GetDayMinBarHigh(ENUM_TIMEFRAMES p_tf = PERIOD_M5)
  {
   return iHigh(_Symbol, p_tf, GetDayMinIndex(p_tf));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double DayExtremeStruc::GetDayMinBarLow(ENUM_TIMEFRAMES p_tf = PERIOD_M5)
  {
   return iLow(_Symbol, p_tf, GetDayMinIndex(p_tf));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DayExtremeStruc::PrintStruc(void)
  {
   Print("min_timestamp: ", min_timestamp);
   Print("max_timestamp: ", max_timestamp);
   Print("highest_close: ", highest_close);
   Print("lowest_close: ", lowest_close);
   Print("stop_finding_side: ", stop_finding_side);
   Print("last_side: ", last_side);
  }

//+------------------------------------------------------------------+
