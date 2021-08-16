//+------------------------------------------------------------------+
//|                                                     Features.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

// Trend bars in trend movement, bull bars in acending movement.

#include <Dev\Brooks\Structs.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MicroChannelStruc MicroChannel(int p_min_size, MicroChannelStruc &channelInfo)
  {
   int bear_mc=0,bull_mc=0;
   MicroChannelStruc mc;

   for(int i=0; i<p_min_size; i++)
     {
      if(HigherLow(i+1)&&(IsBullBar(i+1)))
        {
         bull_mc++;
         if(bull_mc==p_min_size)
           {

            if(channelInfo.ChannelOrientation == NO_CHANNEL || channelInfo.ChannelOrientation == BEAR_MC)
              {
               mc.ChannelOrientation = BULL_MC;
               mc.size=p_min_size+1;
              }
            if(channelInfo.ChannelOrientation == BULL_MC)
              {
               mc.ChannelOrientation = BULL_MC;
               mc.size = channelInfo.size++;
               mc.start_arrow_name = channelInfo.start_arrow_name;
               mc.end_arrow_name = channelInfo.end_arrow_name;
              }

            return mc;
           }

        }
      if(LowerHigh(i+1)&&(IsBearBar(i+1)))
        {
         bear_mc++;
         if(bear_mc==p_min_size)
           {
            if(channelInfo.ChannelOrientation == NO_CHANNEL || channelInfo.ChannelOrientation == BULL_MC)
              {
               mc.ChannelOrientation = BEAR_MC;
               mc.size=p_min_size+1;
              }
            if(channelInfo.ChannelOrientation == BEAR_MC)
              {
               mc.ChannelOrientation = BEAR_MC;
               mc.size = channelInfo.size++;
               mc.start_arrow_name = channelInfo.start_arrow_name;
               mc.end_arrow_name = channelInfo.end_arrow_name;
              }

            return mc;
           }

        }
     }

   return mc;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HigherLow(int index)
  {
   if(iLow(_Symbol,_Period,index+1)<iLow(_Symbol,_Period,index))
      return true;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LowerHigh(int index)
  {
   if(iHigh(_Symbol,_Period,index+1)>iHigh(_Symbol,_Period,index))
      return true;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsBullBar(int index)
  {
   if(iOpen(_Symbol,_Period,index) < iClose(_Symbol,_Period,index))
      return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsBearBar(int index)
  {
   if(iOpen(_Symbol,_Period,index) > iClose(_Symbol,_Period,index))
      return true;
   return false;
  }
//+------------------------------------------------------------------+
bool IsDoji(int index)
  {
   double body_size=MathAbs(iOpen(_Symbol,_Period,index)-iClose(_Symbol,_Period,index));
   double candle_size=MathAbs(iHigh(_Symbol,_Period,index)-iLow(_Symbol,_Period,index));
   if(candle_size==0) return true;
   if(body_size/candle_size < 40)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
