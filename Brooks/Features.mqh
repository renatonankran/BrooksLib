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
class CPullback
  {
public:
   int               bear_pb_counter_, bull_pb_counter_, high_counter_, low_counter_;
   bool              bear_pb_for_this_bar, bull_pb_for_this_bar;
   ALWAYS_IN         always_in_;

                     CPullback(): bear_pb_counter_(0),
                     bull_pb_counter_(0),
                     high_counter_(0),
                     low_counter_(0),
                     always_in_(ALWAYS_IN_RANGE) {};

   HIGHCOUNT         HighCounting(void);
   LOWCOUNT          LowCounting(void);
   PULLBACK          Pullback(int p_trend_size);
   void              ZeroPBFlags();
   void              SetAlwaysInDirection(ALWAYS_IN always);
   bool              HigherLowSequence(int size);
   bool              LowerHighSequence(int size);
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPullback::ZeroPBFlags()
  {
   bear_pb_for_this_bar=false;
   bull_pb_for_this_bar=false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPullback::SetAlwaysInDirection(ALWAYS_IN always_in)
  {
   always_in_=always_in;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PULLBACK CPullback::Pullback(int p_trend_size)
  {
   if(new_candle)
      ZeroPBFlags();

   if(!bear_pb_for_this_bar)
      if(HigherLowSequence(p_trend_size) && iClose(_Symbol,_Period,0)<iLow(_Symbol,_Period,1))
        {
         if(!ObjectCreate(0,(string)MathRand(),OBJ_TREND,0,iTime(_Symbol,_Period,1),iLow(_Symbol,_Period,1),iTime(_Symbol,_Period,0),iLow(_Symbol,_Period,1)))
           {
            Print(__FUNCTION__,
                  ": failed to create a trend line! Error code = ",GetLastError());
           }
         bear_pb_for_this_bar=true;
         return BEAR_PB;
        }

   if(!bull_pb_for_this_bar)
      if(LowerHighSequence(p_trend_size)&&iClose(_Symbol,_Period,0)>iHigh(_Symbol,_Period,1))
        {
         if(!ObjectCreate(0,(string)MathRand(),OBJ_TREND,0,iTime(_Symbol,_Period,1),iHigh(_Symbol,_Period,1),iTime(_Symbol,_Period,0),iHigh(_Symbol,_Period,1)))
           {
            Print(__FUNCTION__,
                  ": failed to create a trend line! Error code = ",GetLastError());
           }
         bull_pb_for_this_bar=true;
         return BULL_PB;
        }
   return NO_PB;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
HIGHCOUNT CPullback::HighCounting(void)
  {
   if(Pullback(2) == BEAR_PB)
      bear_pb_counter_++;
   if(bear_pb_counter_>0 && Pullback(2)==BULL_PB)
      high_counter_++;



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
         return H_5;
      default:
         return WRONG_VALUE;
     }
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
LOWCOUNT CPullback::LowCounting(void)
  {
   if(Pullback(2) == BULL_PB)
      bull_pb_counter_++;
   if(bull_pb_counter_>0 && Pullback(2)==BEAR_PB)
      low_counter_++;

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
         return L_5;
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
   for(int i = 1; i <= size-1; i++)
     {
      if(HigherLow(i))
         counter++;
     }
   if(counter == size-1)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPullback::LowerHighSequence(int size)
  {
   int counter = 0;
   for(int i = 1; i <= size-1; i++)
     {
      if(LowerHigh(i))
         counter++;
     }
   if(counter == size-1)
      return true;
   return false;
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
   void              Extend();
   GraphExtremeStruc GetNode(int index);
   void              IncrementIndexNRight(void);
   double            GetHigh(int index);
   double            GetLow(int index);
   int               GetLeftWeight(int index);
   int               GetRightWeight(int index);
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
void CGraphExtremes::Append(GraphExtremeStruc &node)
  {
   if(last_position_ >= ArraySize(graph_extremes_))
      Extend();

   graph_extremes_[last_position_] = GraphExtremeStruc(node.right_weight,
                                     node.timestamp,
                                     node.extreme_high,
                                     node.extreme_low);

   last_position_++;
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
void CGraphExtremes::IncrementIndexNRight(void)
  {
   int size = GetSize();
   for(int i = 0; i<size; i++)
      graph_extremes_[i].AddToIndex();
   graph_extremes_[GetLastIndex()].AddToRightWeight();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CManageExtremes
  {
public:
   CPullback         pullback_;
   CGraphExtremes    graph_extremes_;

                     CManageExtremes(void);

   void              Run(void);
   void              AppendIfExtreme(void);
   GraphExtremeStruc GetNode(int index=0);
  };



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CManageExtremes::CManageExtremes(void) {};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::Run(void)
  {
   if(new_candle)
     {
      graph_extremes_.IncrementIndexNRight();
     }

   AppendIfExtreme();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::AppendIfExtreme(void)
  {
   PULLBACK pb = pullback_.Pullback(2);
   int prev_right_weight = graph_extremes_.GetNode(graph_extremes_.GetLastIndex()-1).right_weight;
   if(pb == BULL_PB)
     {
      GraphExtremeStruc extreme(prev_right_weight,iTime(_Symbol,_Period,1),iHigh(_Symbol,_Period,1),iLow(_Symbol,_Period,1));
      graph_extremes_.Append(extreme);
     }
   if(pb == BEAR_PB)
     {
      GraphExtremeStruc extreme(prev_right_weight,iTime(_Symbol,_Period,1),iHigh(_Symbol,_Period,1),iLow(_Symbol,_Period,1));
      graph_extremes_.Append(extreme);
     }
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
GraphExtremeStruc CManageExtremes::GetNode(int index=0)
  {
   return graph_extremes_.GetNode(index);
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
   Print("today_datetime: ", today_datetime);
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
