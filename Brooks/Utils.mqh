//+------------------------------------------------------------------+
//|                                                        Utils.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

datetime lastCandleTimeStamp;
MqlDateTime day;
int candleCount = 0;
bool new_candle = false;
double simbol_tick;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NewCandle()
  {
   datetime currentTimeStamp = iTime(_Symbol, _Period, 0);
   if(currentTimeStamp != lastCandleTimeStamp)
     {
      lastCandleTimeStamp = currentTimeStamp;
      candleCount++;
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double IsNewDay()
  {
   MqlDateTime current;
   TimeToStruct(TimeCurrent(), current);
   if(day.day != current.day)
     {
      day.day = current.day;
      candleCount = 0;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsDayEnd()
  {
   MqlDateTime candle_timestamp, m_end_time_stru;
   datetime m_end_time;

   TimeToStruct(iTime(_Symbol, _Period, 0), candle_timestamp);
   m_end_time_stru.day = candle_timestamp.day;
   m_end_time_stru.mon = candle_timestamp.mon;
   m_end_time_stru.year = candle_timestamp.year;
   m_end_time_stru.hour = 17;
   m_end_time_stru.min = 50;
   m_end_time_stru.sec = 0;
   m_end_time = StructToTime(m_end_time_stru);

   if(iTime(_Symbol, _Period, 0) >= m_end_time)
      return true;

   return false;
  }
//+------------------------------------------------------------------+
