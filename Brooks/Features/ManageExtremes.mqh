//+------------------------------------------------------------------+
//|                                                    MajorHiLo.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"



#include <Dev\Brooks\Features\Pullback.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CManageExtremes
  {
public:
   bool              found_first_extreme_;
   int               importance_;
   CPullback         pullback_;
   CGraphExtremes    graph_extremes_;
   MinMaxStruc       leg1_extremes,
                     leg2_extremes,
                     leg3_extremes,
                     leg4_extremes;

                     CManageExtremes(void): importance_(1) {};

   void              Run(void);
   void              AppendIfCrossed(int p_index=0);
   void              AppendIfChangedDirection(int p_index=0);
   void              LegExtreme(int p_index=0, int p_importance=1, HILO p_hilo=WRONG_VALUE);
   void              FindYesterdayStructure(void);
   void              FirstExtreme(void);
   int               GetLastIndex(void);
   void              ChangeImportance(void);
   bool              IsCrossingOldLow(MinMaxStruc &p_leg, int p_index=0);
   void              PBStarted(MinMaxStruc &p_leg);
   GraphExtremeStruc GetNode(int index=0);
  };


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::Run(void)
  {
   if(new_candle)
     {
      graph_extremes_.IncrementRight();
     }
   if(!found_first_extreme_)
     {
      FirstExtreme();
      FindYesterdayStructure();
      found_first_extreme_=true;
     }



  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::PBStarted(MinMaxStruc &p_leg)
  {
   int bar1 = iBarShift(_Symbol,_Period,p_leg.min_timestamp,true);
   int bar2 = iBarShift(_Symbol,_Period,p_leg.max_timestamp,true);
   if(pullback_.OverlapLevel(bar1,bar2) <= 0.15)
     {
      p_leg.pullback_started = true;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CManageExtremes::GetLastIndex()
  {
   return graph_extremes_.GetLastIndex();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CManageExtremes::IsCrossingOldLow(MinMaxStruc &p_leg, int p_index=0)
  {
   double current_min = iLow(_Symbol,_Period,p_index);
   double current_max = iHigh(_Symbol,_Period,p_index);
   if(current_min < p_leg.min && p_leg.min_timestamp < iTime(_Symbol,_Period,1))
      return true;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::AppendIfCrossed(int p_index=0)
  {
   GraphExtremeStruc last_node = GetNode(GetLastIndex());
   double current_min = iLow(_Symbol,_Period,p_index);
   double current_max = iHigh(_Symbol,_Period,p_index);
   PBStarted(leg1_extremes);
   int prev_right_weight = GetNode(GetLastIndex()).right_weight;

   if(last_node.hilo == HIGH &&
      leg1_extremes.pullback_started &&
      current_min < leg1_extremes.min)
     {
      GraphExtremeStruc extreme_low(0,
                                    leg1_extremes.min_timestamp,
                                    iHigh(_Symbol,_Period,iBarShift(_Symbol,_Period,leg1_extremes.min_timestamp,true)),
                                    leg1_extremes.min,
                                    LOW,1);
      graph_extremes_.Append(extreme_low);

      GraphExtremeStruc extreme_pb(0,
                                   leg1_extremes.max_timestamp,
                                   leg1_extremes.max,
                                   iLow(_Symbol,_Period,iBarShift(_Symbol,_Period,leg1_extremes.max_timestamp,true)),
                                   HIGH,1);
      graph_extremes_.Append(extreme_pb);

      leg1_extremes.pullback_started = false;
     }
   if(last_node.hilo == LOW &&
      leg1_extremes.pullback_started &&
      current_max > leg1_extremes.max)
     {
      GraphExtremeStruc extreme_high(0,
                                     leg1_extremes.max_timestamp,
                                     leg1_extremes.max,
                                     iLow(_Symbol,_Period,iBarShift(_Symbol,_Period,leg1_extremes.max_timestamp,true)),
                                     HIGH,1);
      graph_extremes_.Append(extreme_high);

      GraphExtremeStruc extreme_pb(0,
                                   leg1_extremes.min_timestamp,
                                   iHigh(_Symbol,_Period,iBarShift(_Symbol,_Period,leg1_extremes.min_timestamp,true)),
                                   leg1_extremes.min,
                                   LOW,1);
      graph_extremes_.Append(extreme_pb);

      leg1_extremes.pullback_started = false;
     }

   LegExtreme(p_index, importance_, last_node.hilo);
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::AppendIfChangedDirection(int p_index=0)
  {
   GraphExtremeStruc last_node = GetNode(GetLastIndex());
   double current_min = iLow(_Symbol,_Period,p_index);
   double current_max = iHigh(_Symbol,_Period,p_index);
   int prev_right_weight = GetNode(GetLastIndex()).right_weight;

   if(last_node.hilo == HIGH &&
      current_max > last_node.extreme_high)
     {
      GraphExtremeStruc extreme_low(0,
                                    leg1_extremes.min_timestamp,
                                    iHigh(_Symbol,_Period,iBarShift(_Symbol,_Period,leg1_extremes.min_timestamp,true)),
                                    leg1_extremes.min,
                                    LOW,1);
      graph_extremes_.Append(extreme_low);
      leg1_extremes.pullback_started = false;
      last_node = GetNode(GetLastIndex());
      LegExtreme(p_index, importance_, last_node.hilo);
     }
   if(last_node.hilo == LOW &&
      current_min < last_node.extreme_low)
     {
      GraphExtremeStruc extreme_high(0,
                                     leg1_extremes.max_timestamp,
                                     leg1_extremes.max,
                                     iLow(_Symbol,_Period,iBarShift(_Symbol,_Period,leg1_extremes.max_timestamp,true)),
                                     HIGH,1);
      graph_extremes_.Append(extreme_high);
      leg1_extremes.pullback_started = false;
      last_node = GetNode(GetLastIndex());
      LegExtreme(p_index, importance_, last_node.hilo);
     }
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
GraphExtremeStruc CManageExtremes::GetNode(int index=0)
  {
   return graph_extremes_.GetNode(index);
  }

void

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::ChangeImportance(void)
  {
   ++importance_;
   if(importance_>4)
      importance_ = 1;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::LegExtreme(int p_index=0, int p_importance=1, HILO p_hilo=WRONG_VALUE)
  {
   double current_min = iLow(_Symbol,_Period,p_index);
   double current_max = iHigh(_Symbol,_Period,p_index);


   if(p_hilo == LOW)
     {
      switch(p_importance)
        {
         case 1:
            if(leg1_extremes.min > current_min)
              {
               CreateArrow(OBJ_ARROW_BUY, current_min);
               leg1_extremes.min = current_min;
               leg1_extremes.min_timestamp = iTime(_Symbol,_Period,p_index);
              }

            if(leg1_extremes.max < current_max)
              {
               CreateArrow(OBJ_ARROW_BUY, current_min);
               CreateArrow(OBJ_ARROW_SELL, current_max);
               leg1_extremes.max = current_max;
               leg1_extremes.max_timestamp = iTime(_Symbol,_Period,p_index);
               leg1_extremes.min = current_min;
               leg1_extremes.min_timestamp = iTime(_Symbol,_Period,p_index);
              }
            break;
         case 2:
            if(leg2_extremes.min > current_min)
              {
               CreateArrow(OBJ_ARROW_BUY, current_min);
               leg2_extremes.min = current_min;
               leg2_extremes.min_timestamp = iTime(_Symbol,_Period,p_index);
              }
            if(leg2_extremes.max < current_max)
              {
               CreateArrow(OBJ_ARROW_BUY, current_min);
               CreateArrow(OBJ_ARROW_SELL, current_max);
               leg2_extremes.max = current_max;
               leg2_extremes.max_timestamp = iTime(_Symbol,_Period,p_index);
               leg2_extremes.min = current_min;
               leg2_extremes.min_timestamp = iTime(_Symbol,_Period,p_index);
              }
            break;
         case 3:
            if(leg3_extremes.min > current_min)
              {
               CreateArrow(OBJ_ARROW_BUY, current_min);
               leg3_extremes.min = current_min;
               leg3_extremes.min_timestamp = iTime(_Symbol,_Period,p_index);
              }
            if(leg3_extremes.max < current_max)
              {
               CreateArrow(OBJ_ARROW_BUY, current_min);
               CreateArrow(OBJ_ARROW_SELL, current_max);
               leg3_extremes.max = current_max;
               leg3_extremes.max_timestamp = iTime(_Symbol,_Period,p_index);
               leg3_extremes.min = current_min;
               leg3_extremes.min_timestamp = iTime(_Symbol,_Period,p_index);
              }
            break;
         case 4:
            if(leg4_extremes.min > current_min)
              {
               CreateArrow(OBJ_ARROW_BUY, current_min);
               leg4_extremes.min = current_min;
               leg4_extremes.min_timestamp = iTime(_Symbol,_Period,p_index);
              }
            if(leg4_extremes.max < current_max)
              {
               CreateArrow(OBJ_ARROW_BUY, current_min);
               CreateArrow(OBJ_ARROW_SELL, current_max);
               leg4_extremes.max = current_max;
               leg4_extremes.max_timestamp = iTime(_Symbol,_Period,p_index);
               leg4_extremes.min = current_min;
               leg4_extremes.min_timestamp = iTime(_Symbol,_Period,p_index);
              }
            break;
         default:
            break;
        }
     }

   if(p_hilo == HIGH)
     {
      switch(p_importance)
        {
         case 1:
            if(leg1_extremes.min > current_min)
              {
               leg1_extremes.max = current_max;
               leg1_extremes.max_timestamp = iTime(_Symbol,_Period,p_index);
               leg1_extremes.min = current_min;
               leg1_extremes.min_timestamp = iTime(_Symbol,_Period,p_index);
               CreateArrow(OBJ_ARROW_BUY, current_min);
               CreateArrow(OBJ_ARROW_SELL, current_max);
              }
            if(leg1_extremes.max < current_max)
              {
               leg1_extremes.max = current_max;
               leg1_extremes.max_timestamp = iTime(_Symbol,_Period,p_index);
               CreateArrow(OBJ_ARROW_SELL, current_max);
              }
            break;
         case 2:
            if(leg2_extremes.min > current_min)
              {
               leg2_extremes.max = current_max;
               leg2_extremes.max_timestamp = iTime(_Symbol,_Period,p_index);
               leg2_extremes.min = current_min;
               leg2_extremes.min_timestamp = iTime(_Symbol,_Period,p_index);
               CreateArrow(OBJ_ARROW_BUY, current_min);
               CreateArrow(OBJ_ARROW_SELL, current_max);
              }
            if(leg2_extremes.max < current_max)
              {
               CreateArrow(OBJ_ARROW_SELL, current_max);
               leg2_extremes.max = current_max;
               leg2_extremes.max_timestamp = iTime(_Symbol,_Period,p_index);
              }
            break;
         case 3:
            if(leg3_extremes.min > current_min)
              {
               leg3_extremes.max = current_max;
               leg3_extremes.max_timestamp = iTime(_Symbol,_Period,p_index);
               leg3_extremes.min = current_min;
               leg3_extremes.min_timestamp = iTime(_Symbol,_Period,p_index);
               CreateArrow(OBJ_ARROW_BUY, current_min);
               CreateArrow(OBJ_ARROW_SELL, current_max);
              }
            if(leg3_extremes.max < current_max)
              {
               CreateArrow(OBJ_ARROW_SELL, current_max);
               leg3_extremes.max = current_max;
               leg3_extremes.max_timestamp = iTime(_Symbol,_Period,p_index);
              }
            break;
         case 4:
            if(leg4_extremes.min > current_min)
              {
               leg4_extremes.max = current_max;
               leg4_extremes.max_timestamp = iTime(_Symbol,_Period,p_index);
               leg4_extremes.min = current_min;
               leg4_extremes.min_timestamp = iTime(_Symbol,_Period,p_index);
               CreateArrow(OBJ_ARROW_BUY, current_min);
               CreateArrow(OBJ_ARROW_SELL, current_max);
              }
            if(leg4_extremes.max < current_max)
              {
               CreateArrow(OBJ_ARROW_SELL, current_max);
               leg4_extremes.max = current_max;
               leg4_extremes.max_timestamp = iTime(_Symbol,_Period,p_index);
              }
            break;
         default:
            break;
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::FirstExtreme(void)
  {
   int size = CountDistanceFromCurrentCandle(1);
   int high_index = iHighest(_Symbol,_Period,MODE_HIGH,19,size-18);
   int low_index = iLowest(_Symbol,_Period,MODE_LOW,19,size-18);

   if(high_index<=low_index)
     {
      GraphExtremeStruc extreme(0,
                                iTime(_Symbol,_Period,low_index),
                                iHigh(_Symbol,_Period,low_index),
                                iLow(_Symbol,_Period,low_index),
                                LOW,
                                1);
      graph_extremes_.Append(extreme);
     }
   if(low_index<high_index)
     {
      GraphExtremeStruc extreme(0,
                                iTime(_Symbol,_Period,high_index),
                                iHigh(_Symbol,_Period,high_index),
                                iLow(_Symbol,_Period,high_index),
                                HIGH,
                                1);
      graph_extremes_.Append(extreme);
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::FindYesterdayStructure(void)
  {
   int size = CountDistanceFromCurrentCandle(1);
   int first_extreme_index = iBarShift(_Symbol,_Period,GetNode(0).timestamp,true);
   int difference = size-first_extreme_index;
   for(int i = size-difference ; i >= 0 ; i--)
     {
      AppendIfChangedDirection(i);
      AppendIfCrossed(i);
     }
   for(int i = 0 ; i<graph_extremes_.GetSize(); i++)
      GetNode(i).PrintNode();
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateArrow(ENUM_OBJECT p_obj, double p_price)
  {
   if(p_obj == OBJ_ARROW_SELL)
     {
      ObjectDelete(0,"downArrow");
      if(!ObjectCreate(0,"downArrow",p_obj,0,iTime(_Symbol,_Period,0),p_price))
        {
         Print(__FUNCTION__,
               ": failed to create a trend line! Error code = ",GetLastError());
        }
     }

   if(p_obj == OBJ_ARROW_BUY)
     {
      ObjectDelete(0,"upArrow");
      if(!ObjectCreate(0,"upArrow",p_obj,0,iTime(_Symbol,_Period,0),p_price))
        {
         Print(__FUNCTION__,
               ": failed to create a trend line! Error code = ",GetLastError());
        }
     }

  }
//+------------------------------------------------------------------+
