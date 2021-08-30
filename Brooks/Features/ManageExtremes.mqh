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
   void              UpdateLegsExtremes(int p_index=0, int p_importance=1, HILO p_hilo=WRONG_VALUE);
   void              ChangeImportance(int p_level_crossed=WRONG_VALUE);
   bool              IsCrossingOldLow(MinMaxStruc &p_leg, int p_index=0);
   void              PBStarted(MinMaxStruc &p_leg);
   void              CheckCrossing(int p_index, MinMaxStruc &leg, GraphExtremeStruc &node);
   void              CheckCrossingForAllLegs(GraphExtremeStruc &node, int p_index=0, int p_importance=1);
   GraphExtremeStruc GetLastNode(void);
   GraphExtremeStruc GetNode(int index=0);
  };


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
      AppendIfChangedDirection(i);
      AppendIfCrossed(i);
     }
   for(int i = 0 ; i<graph_extremes_.GetSize(); i++)
      GetNode(i).PrintNode();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::AppendIfChangedDirection(int p_index=0)
  {
   GraphExtremeStruc last_node = GetLastNode();
   double current_min = iLow(_Symbol,_Period,p_index);
   double current_max = iHigh(_Symbol,_Period,p_index);
   int prev_right_weight = GetLastNode().right_weight;

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
      last_node = GetLastNode();
      UpdateLegsExtremes(p_index, importance_, last_node.hilo);
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
      last_node = GetLastNode();
      UpdateLegsExtremes(p_index, importance_, last_node.hilo);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::AppendIfCrossed(int p_index=0)
  {
   GraphExtremeStruc last_node = GetLastNode();
   double current_min = iLow(_Symbol,_Period,p_index);
   double current_max = iHigh(_Symbol,_Period,p_index);
   PBStarted(leg1_extremes);

   CheckCrossing(p_index, leg1_extremes, last_node);
   ChangeImportance(WRONG_VALUE);
   Print("Import: ", importance_);
   UpdateLegsExtremes(p_index, importance_, last_node.hilo);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::UpdateLegsExtremes(int p_index=0, int p_importance=1, HILO p_hilo=WRONG_VALUE)
  {
   if(p_hilo == LOW)
     {
      switch(p_importance)
        {
         case 1:
            LegExtreme(p_index,1,LOW);
            break;
         case 2:
            LegExtreme(p_index,1,LOW);
            LegExtreme(p_index,2,HIGH);
            break;
         case 3:
            LegExtreme(p_index,1,LOW);
            LegExtreme(p_index,2,HIGH);
            LegExtreme(p_index,3,LOW);
            break;
         case 4:
            LegExtreme(p_index,1,LOW);
            LegExtreme(p_index,2,HIGH);
            LegExtreme(p_index,3,LOW);
            LegExtreme(p_index,4,HIGH);
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
            LegExtreme(p_index,1,HIGH);
            break;
         case 2:
            LegExtreme(p_index,1,HIGH);
            LegExtreme(p_index,2,LOW);
            break;
         case 3:
            LegExtreme(p_index,1,HIGH);
            LegExtreme(p_index,2,LOW);
            LegExtreme(p_index,3,HIGH);
            break;
         case 4:
            LegExtreme(p_index,1,HIGH);
            LegExtreme(p_index,2,LOW);
            LegExtreme(p_index,3,HIGH);
            LegExtreme(p_index,4,LOW);
            break;
         default:
            break;
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
void CManageExtremes::CheckCrossing(int p_index, MinMaxStruc &leg, GraphExtremeStruc &node)
  {

   double current_min = iLow(_Symbol,_Period,p_index);
   double current_max = iHigh(_Symbol,_Period,p_index);

   if(node.hilo == HIGH &&
      leg.pullback_started &&
      current_min < leg.min)
     {
      GraphExtremeStruc extreme_low(0,
                                    leg.min_timestamp,
                                    iHigh(_Symbol,_Period,iBarShift(_Symbol,_Period,leg.min_timestamp,true)),
                                    leg.min,
                                    LOW,1);
      graph_extremes_.Append(extreme_low);

      GraphExtremeStruc extreme_pb(0,
                                   leg.max_timestamp,
                                   leg.max,
                                   iLow(_Symbol,_Period,iBarShift(_Symbol,_Period,leg.max_timestamp,true)),
                                   HIGH,1);
      graph_extremes_.Append(extreme_pb);

      leg.pullback_started = false;
     }
   if(node.hilo == LOW &&
      leg.pullback_started &&
      current_max > leg.max)
     {
      GraphExtremeStruc extreme_high(0,
                                     leg.max_timestamp,
                                     leg.max,
                                     iLow(_Symbol,_Period,iBarShift(_Symbol,_Period,leg.max_timestamp,true)),
                                     HIGH,1);
      graph_extremes_.Append(extreme_high);

      GraphExtremeStruc extreme_pb(0,
                                   leg.min_timestamp,
                                   iHigh(_Symbol,_Period,iBarShift(_Symbol,_Period,leg.min_timestamp,true)),
                                   leg.min,
                                   LOW,1);
      graph_extremes_.Append(extreme_pb);

      leg.pullback_started = false;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::ChangeImportance(int p_level_crossed=WRONG_VALUE)
  {
   if(leg1_extremes.max_timestamp!=leg1_extremes.min_timestamp)
      importance_ = 2;
   if(leg2_extremes.max_timestamp!=leg2_extremes.min_timestamp)
      importance_ = 3;
   if(leg3_extremes.max_timestamp!=leg3_extremes.min_timestamp)
      importance_ = 4;

   if(p_level_crossed == 1)
     {
      leg1_extremes.max_timestamp = TimeCurrent();
      leg1_extremes.min_timestamp = TimeCurrent();
      leg2_extremes.max_timestamp = TimeCurrent();
      leg2_extremes.min_timestamp = TimeCurrent();
      leg3_extremes.max_timestamp = TimeCurrent();
      leg3_extremes.min_timestamp = TimeCurrent();
      leg4_extremes.max_timestamp = TimeCurrent();
      leg4_extremes.min_timestamp = TimeCurrent();
      importance_ = 1;
     }
   if(p_level_crossed == 2)
     {
      leg2_extremes.max_timestamp = TimeCurrent();
      leg2_extremes.min_timestamp = TimeCurrent();
      leg3_extremes.max_timestamp = TimeCurrent();
      leg3_extremes.min_timestamp = TimeCurrent();
      leg4_extremes.max_timestamp = TimeCurrent();
      leg4_extremes.min_timestamp = TimeCurrent();
      importance_ = 2;
     }

   if(p_level_crossed == 3)
     {
      leg3_extremes.max_timestamp = TimeCurrent();
      leg3_extremes.min_timestamp = TimeCurrent();
      leg4_extremes.max_timestamp = TimeCurrent();
      leg4_extremes.min_timestamp = TimeCurrent();
      importance_ = 3;
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::CheckCrossingForAllLegs(GraphExtremeStruc &node, int p_index=0, int p_importance=1)
  {
   switch(p_importance)
     {
      case 1:
         CheckCrossing(p_index,leg1_extremes,node);
         break;
      case 2:
         CheckCrossing(p_index,leg1_extremes,node);
         CheckCrossing(p_index,leg2_extremes,node);
         break;
      case 3:
         CheckCrossing(p_index,leg1_extremes,node);
         CheckCrossing(p_index,leg2_extremes,node);
         CheckCrossing(p_index,leg3_extremes,node);
         break;
      case 4:
         CheckCrossing(p_index,leg1_extremes,node);
         CheckCrossing(p_index,leg2_extremes,node);
         CheckCrossing(p_index,leg3_extremes,node);
         CheckCrossing(p_index,leg4_extremes,node);
         break;
      default:
         break;
     }
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
   return graph_extremes_.GetNode(graph_extremes_.GetLastIndex());
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
