//+------------------------------------------------------------------+
//|                                                     Features.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link "https://www.mql5.com"

#define DAY_SEC 86400

#include <Dev\Brooks\Structs.mqh>
#include <Dev\Brooks\Utils.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MicroChannelStruc MicroChannel(int p_min_size, MicroChannelStruc &channelInfo)
  {
   int bear_mc = 0, bull_mc = 0;
   MicroChannelStruc mc;

   for(int i = 0; i < p_min_size; i++)
     {
      if(HigherLow(i + 1) && (IsBullBar(i + 1)||IsDoji(i+1)))
        {
         bull_mc++;
         if(bull_mc == p_min_size)
           {
            if(channelInfo.ChannelOrientation == NO_CHANNEL || channelInfo.ChannelOrientation == BEAR_MC)
              {
               mc.ChannelOrientation = BULL_MC;
               mc.size = p_min_size + 1;
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
      if(LowerHigh(i + 1) && (IsBearBar(i + 1)||IsDoji(i+1)))
        {
         bear_mc++;
         if(bear_mc == p_min_size)
           {
            if(channelInfo.ChannelOrientation == NO_CHANNEL || channelInfo.ChannelOrientation == BULL_MC)
              {
               mc.ChannelOrientation = BEAR_MC;
               mc.size = p_min_size + 1;
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
   if(iLow(_Symbol, _Period, index + 1) < iLow(_Symbol, _Period, index))
      return true;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LowerHigh(int index)
  {
   if(iHigh(_Symbol, _Period, index + 1) > iHigh(_Symbol, _Period, index))
      return true;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsBullBar(int index)
  {
   if(iOpen(_Symbol, _Period, index) < iClose(_Symbol, _Period, index))
      return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsBearBar(int index)
  {
   if(iOpen(_Symbol, _Period, index) > iClose(_Symbol, _Period, index))
      return true;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsDoji(int index)
  {
   double body_size = MathAbs(iOpen(_Symbol, _Period, index) - iClose(_Symbol, _Period, index));
   double candle_size = MathAbs(iHigh(_Symbol, _Period, index) - iLow(_Symbol, _Period, index));
   if(candle_size == 0)
      return true;
   if(body_size / candle_size < 40)
      return true;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountDistanceFromCurrentCandle(int days=0,ENUM_TIMEFRAMES time_frame=0)
  {
   MqlDateTime today;
   TimeCurrent(today);
   today.hour = 0;
   today.min = 1;
   today.sec = 0;
   datetime today_datetime = StructToTime(today);
   today_datetime-=(days*DAY_SEC);
   return iBarShift(_Symbol,time_frame,today_datetime,false)-1;
  }

bool first_run=true;
MINMAX MinOrMaxLastOld(int days=1)
  {
   MINMAX min_max=WRONG_VALUE;

   if(candleCount==0)
      first_run = true;
   if(first_run && IsBearBar(1))
     {
      first_run=false;
      return MIN;
     }
   if(first_run && IsBullBar(1))
     {
      first_run=false;
      return MAX;
     }

   int size = CountDistanceFromCurrentCandle(days);
   Print("size: ",size);
   double last_high = iHigh(_Symbol,_Period,size);
   double last_low = iLow(_Symbol,_Period,size);

   for(int i=size; i>=0; i--)
     {
      double current_high = iHigh(_Symbol,_Period,i);
      double current_low = iLow(_Symbol,_Period,i);
      if(current_high >= last_high)
        {
         min_max = MAX;
         last_high = current_high;
         Print("last_high: ",last_high);
        }
      if(current_low <= last_low)
        {
         min_max = MIN;
         last_low = current_low;
         Print("last_low: ",last_low);
        }
     }
   return min_max;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MINMAX MinOrMaxLast(int days=1)
  {
   int size = CountDistanceFromCurrentCandle(days);

   int high_index = iHighest(_Symbol,_Period,MODE_HIGH,size,0);
   int low_index = iLowest(_Symbol,_Period,MODE_LOW,size,0);

   if(high_index<low_index)
      return MAX;
   if(low_index<high_index)
      return MIN;

   if(low_index==high_index)
     {
      if(IsBearBar(low_index))
        {
         return MIN;
        }
      if(IsBullBar(high_index))
        {
         return MAX;
        }
      else
         return WRONG_VALUE;
     }

   return WRONG_VALUE;

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MINMAX PeriodMinOrMax(int p_count, int p_start)
  {
   int high_index = iHighest(_Symbol,_Period,MODE_HIGH,p_count,p_start);
   int low_index = iLowest(_Symbol,_Period,MODE_LOW,p_count,p_start);
   Print(iTime(_Symbol,_Period,high_index));
   if(high_index<low_index)
      return MAX;
   if(low_index<high_index)
      return MIN;

   if(low_index==high_index)
     {
      if(IsBearBar(low_index))
        {
         return MIN;
        }
      if(IsBullBar(high_index))
        {
         return MAX;
        }
      else
         return WRONG_VALUE;
     }

   return WRONG_VALUE;

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGraphExtremes
  {
public:
   GraphExtremeStruc graph_extremes_[];
   int               last_position_;

                     CGraphExtremes(void);
                    ~CGraphExtremes(void);
   void              Append(GraphExtremeStruc &node);
   void              Insert(int p_position, GraphExtremeStruc &node);
   void              Extend();
   GraphExtremeStruc GetNode(int index);
   void              IncrementRight(void);
   int               GetSize(void);
   int               GetLastIndex(void);
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CGraphExtremes::CGraphExtremes(void)
  {
   last_position_=0;
   ArrayResize(graph_extremes_, 256);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CGraphExtremes::~CGraphExtremes(void) {}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGraphExtremes::Append(GraphExtremeStruc &node)
  {
   if(last_position_ >= ArraySize(graph_extremes_))
      Extend();

   graph_extremes_[last_position_] = node;

   ++last_position_;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGraphExtremes::Extend(void)
  {
   ArrayResize(graph_extremes_, ArraySize(graph_extremes_)+256);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CGraphExtremes::GetSize(void)
  {
   return last_position_;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CGraphExtremes::GetLastIndex(void)
  {
   int tmp = last_position_-1;
   if(tmp<0)
      return 0;
   return tmp;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
GraphExtremeStruc CGraphExtremes::GetNode(int index)
  {
   GraphExtremeStruc graph;
   if(index<0)
      return graph;
   return graph_extremes_[index];
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGraphExtremes::IncrementRight(void)
  {
   graph_extremes_[GetLastIndex()].AddToRightWeight();
  }
  
//+------------------------------------------------------------------+
