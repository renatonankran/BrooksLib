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
   MinMaxStruc       legs_extremes_[4];

                     CManageExtremes(void);

   void              Run(void);
   void              FirstExtreme(void);
   void              FindYesterdayStructure(void);
   void              AppendIfChangedDirection(int p_index, MinMaxStruc &leg);
   void              AppendIfCrossed(int p_index=0);
   void              UpdateAllLegs(int p_index=0, int p_importance=1);
   void              FindLegExtreme(int p_index, MinMaxStruc &p_leg);
   void              PBStarted(MinMaxStruc &p_leg);
   void              CheckCrossing(int p_index, MinMaxStruc &p_leg);
   HILO              FindPbOrientation(int p_level);
   void              ChangeImportance(int p_level_crossed=WRONG_VALUE);
   bool              IsCrossingOldLow(MinMaxStruc &p_leg, int p_index=0);
   GraphExtremeStruc GetLastNode(void);
   GraphExtremeStruc GetLastMajorNode(void);
   GraphExtremeStruc GetNode(int index=0);
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CManageExtremes::CManageExtremes()
  {
   importance_ = 1;
   for(int i = 0; i<4; ++i)
      legs_extremes_[i].level = i+1;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::Run(void)
  {
   if(!found_first_extreme_)
     {
      //graph_extremes_.Append(GraphExtremeStruc(0,D'2020.07.15 16:45:00',105845,0,HIGH,1));
      FirstExtreme();
      FindYesterdayStructure();
      found_first_extreme_=true;
     }
//AppendIfCrossed(0);
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
      AppendIfChangedDirection(i, legs_extremes_[0]);
      AppendIfCrossed(i);
     }
   for(int i = 0 ; i<graph_extremes_.GetSizeComplete(); i++)
      GetNode(i).PrintNode();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::AppendIfChangedDirection(int p_index, MinMaxStruc &leg)
  {
   GraphExtremeStruc last_node = GetLastNode();
   double current_min = iLow(_Symbol,_Period,p_index);
   double current_max = iHigh(_Symbol,_Period,p_index);
   Print("last_node: ",last_node.timestamp);
   if(last_node.hilo == HIGH &&
      current_max > last_node.extreme_high)
     {
      GraphExtremeStruc extreme_low(0,
                                    leg.min_timestamp,
                                    iHigh(_Symbol,_Period,iBarShift(_Symbol,_Period,leg.min_timestamp,true)),
                                    leg.min,
                                    LOW,
                                    last_node.importance);
      graph_extremes_.Append(extreme_low);
      leg.pullback_started = false;
      UpdateAllLegs(p_index, importance_);
     }
   if(last_node.hilo == LOW &&
      current_min < last_node.extreme_low)
     {
      GraphExtremeStruc extreme_high(0,
                                     leg.max_timestamp,
                                     leg.max,
                                     iLow(_Symbol,_Period,iBarShift(_Symbol,_Period,leg.max_timestamp,true)),
                                     HIGH,
                                     last_node.importance);
      graph_extremes_.Append(extreme_high);
      leg.pullback_started = false;
      UpdateAllLegs(p_index, importance_);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::AppendIfCrossed(int p_index=0)
  {
   for(int i = 0 ; i < importance_ ; ++i)
     {
      PBStarted(legs_extremes_[i]);
      CheckCrossing(p_index, legs_extremes_[i]);
     }

//ChangeImportance(WRONG_VALUE);
//Print("Import: ", importance_);
   UpdateAllLegs(p_index, importance_);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::UpdateAllLegs(int p_index=0, int p_importance=1)
  {
   for(int i = 0; i < p_importance; ++i)
      FindLegExtreme(p_index,legs_extremes_[i]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::FindLegExtreme(int p_index, MinMaxStruc &p_leg)
  {
   double current_min = iLow(_Symbol,_Period,p_index);
   double current_max = iHigh(_Symbol,_Period,p_index);
   HILO hilo = FindPbOrientation(p_leg.level);

   if(hilo == LOW)
     {
      if(p_leg.min > current_min)
        {
         CreateArrow(OBJ_ARROW_BUY, current_min);
         p_leg.min = current_min;
         p_leg.min_timestamp = iTime(_Symbol,_Period,p_index);
        }

      if(p_leg.max < current_max)
        {
         CreateArrow(OBJ_ARROW_BUY, current_min);
         CreateArrow(OBJ_ARROW_SELL, current_max);
         p_leg.max = current_max;
         p_leg.max_timestamp = iTime(_Symbol,_Period,p_index);
         p_leg.min = current_min;
         p_leg.min_timestamp = iTime(_Symbol,_Period,p_index);
        }
     }
   if(hilo == HIGH)
     {
      if(p_leg.min > current_min)
        {
         p_leg.max = current_max;
         p_leg.max_timestamp = iTime(_Symbol,_Period,p_index);
         p_leg.min = current_min;
         p_leg.min_timestamp = iTime(_Symbol,_Period,p_index);
         CreateArrow(OBJ_ARROW_BUY, current_min);
         CreateArrow(OBJ_ARROW_SELL, current_max);
        }
      if(p_leg.max < current_max)
        {
         p_leg.max = current_max;
         p_leg.max_timestamp = iTime(_Symbol,_Period,p_index);
         CreateArrow(OBJ_ARROW_SELL, current_max);
        }
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
void CManageExtremes::CheckCrossing(int p_index, MinMaxStruc &p_leg)
  {
   HILO hilo = FindPbOrientation(p_leg.level);
   double current_min = iLow(_Symbol,_Period,p_index);
   double current_max = iHigh(_Symbol,_Period,p_index);

   if(hilo == HIGH &&
      p_leg.pullback_started &&
      current_min < p_leg.min)
     {
      GraphExtremeStruc extreme_low(0,
                                    p_leg.min_timestamp,
                                    iHigh(_Symbol,_Period,iBarShift(_Symbol,_Period,p_leg.min_timestamp,true)),
                                    p_leg.min,
                                    LOW,1);
      graph_extremes_.Append(extreme_low);

      GraphExtremeStruc extreme_pb(0,
                                   p_leg.max_timestamp,
                                   p_leg.max,
                                   iLow(_Symbol,_Period,iBarShift(_Symbol,_Period,p_leg.max_timestamp,true)),
                                   HIGH,1);
      graph_extremes_.Append(extreme_pb);

      p_leg.pullback_started = false;
     }
   if(hilo == LOW &&
      p_leg.pullback_started &&
      current_max > p_leg.max)
     {
      GraphExtremeStruc extreme_high(0,
                                     p_leg.max_timestamp,
                                     p_leg.max,
                                     iLow(_Symbol,_Period,iBarShift(_Symbol,_Period,p_leg.max_timestamp,true)),
                                     HIGH,1);
      graph_extremes_.Append(extreme_high);

      GraphExtremeStruc extreme_pb(0,
                                   p_leg.min_timestamp,
                                   iHigh(_Symbol,_Period,iBarShift(_Symbol,_Period,p_leg.min_timestamp,true)),
                                   p_leg.min,
                                   LOW,1);
      graph_extremes_.Append(extreme_pb);

      p_leg.pullback_started = false;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
HILO CManageExtremes::FindPbOrientation(int p_level)
  {
   GraphExtremeStruc last_major = GetLastMajorNode();
   switch(p_level)
     {
      case 1:
         return last_major.hilo;
         break;
      case 2:
         if(last_major.hilo == HIGH)
            return LOW;
         else
            return HIGH;
         break;
      case 3:
         return last_major.hilo;
         break;
      case 4:
         if(last_major.hilo == HIGH)
            return LOW;
         else
            return HIGH;
         break;
      default:
         return WRONG_VALUE;
     }
  }

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
//|                                                                  |
//+------------------------------------------------------------------+
GraphExtremeStruc CManageExtremes::GetLastNode()
  {
   return graph_extremes_.GetNode(graph_extremes_.GetLastIndexComplete());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
GraphExtremeStruc CManageExtremes::GetLastMajorNode()
  {
   return graph_extremes_.GetMajorNode(graph_extremes_.GetLastMajorIndex());
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
GraphExtremeStruc CManageExtremes::GetNode(int index=0)
  {
   return graph_extremes_.GetNode(index);
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
