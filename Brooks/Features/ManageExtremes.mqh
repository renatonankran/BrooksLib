﻿//+------------------------------------------------------------------+
//|                                               ManageExtremes.mqh |
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
   int               min_pb_bars_4_, min_pb_bars_5_;
   double            min_retracement_;
   CPullback         pullback_;
   CGraphExtremes    graph_extremes_;
   LegStruc          legs_extremes_[4];

                     CManageExtremes(void);

   void              Run(void);
   void              FirstExtreme(void);
   void              FindYesterdayStructure(void);
   void              AppendIfChangedDirection(int p_index = 0);
   void              CheckDirectionChange(int p_index, LegStruc &leg);
   bool              CheckCrossing(int p_index, LegStruc &p_leg);
   void              UpdateAllLegs(int p_index = 0);
   void              FindLegExtreme(int p_index, LegStruc &p_leg);
   HILO              FindPbOrientation(int p_level);
   void              IncreaseImportance();
   bool              IsCrossingOldLow(LegStruc &p_leg, int p_index = 0);
   bool              PBStarted(LegStruc &p_leg);
   GraphExtremeStruc GetLastNode(void);
   GraphExtremeStruc GetLastMajorNode(void);
   GraphExtremeStruc GetNode(int index = 0);
   double            RetracementLevel(LegStruc &p_leg);
   bool              CheckForGap(LegStruc &p_leg);
   int               CountPbBars(LegStruc &p_leg);
   int               CountTriggerBars(LegStruc &p_leg, int p_index);
   void              MarkPbConditions(void);
   void              MarkTriggers(int p_index);
   void              VerifyExtreme(void);
   bool              TypeOnePB(LegStruc &p_leg);
   bool              TypeTwoPB(LegStruc &p_leg);
   void              ResetLegs(void);
   void              TransferLegs(void);
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CManageExtremes::CManageExtremes()
  {
   importance_ = 1;
   min_retracement_ = 0.48;
   min_pb_bars_5_ = 5;
   min_pb_bars_4_ = 4;
   for(int i = 0; i < 4; ++i)
      legs_extremes_[i].level = i + 1;
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
      found_first_extreme_ = true;
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::FirstExtreme(void)
  {
   int size = CountDistanceFromCurrentCandle(3);
   int high_index = iHighest(_Symbol, _Period, MODE_HIGH, 19, size - 18);
   int low_index = iLowest(_Symbol, _Period, MODE_LOW, 19, size - 18);

   if(high_index <= low_index)
     {
      GraphExtremeStruc extreme(iTime(_Symbol, _Period, low_index),
                                iHigh(_Symbol, _Period, low_index),
                                iLow(_Symbol, _Period, low_index),
                                LOW,
                                1);
      graph_extremes_.Append(extreme);
     }
   if(low_index < high_index)
     {
      GraphExtremeStruc extreme(iTime(_Symbol, _Period, high_index),
                                iHigh(_Symbol, _Period, high_index),
                                iLow(_Symbol, _Period, high_index),
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
   int size = CountDistanceFromCurrentCandle(3);
   int first_extreme_index = iBarShift(_Symbol, _Period, GetNode(0).timestamp, true);
   int difference = size - first_extreme_index;
   for(int i = size - difference ; i >= 0 ; i--)
     {

      //AppendIfChangedDirection(i);
      MarkPbConditions();
      MarkTriggers(i);
      Print("Time: ", iTime(_Symbol, _Period, i));
      for(int j = 0; j < importance_; j++)
         legs_extremes_[j].PrintLeg();
      //GetLastMajorNode().PrintNode();
      //Print("Import: ", importance_);
      VerifyExtreme();
      UpdateAllLegs(i);
      //IncreaseImportance();

     }
   for(int i = 0 ; i < graph_extremes_.GetSizeComplete(); i++)
     {
      GraphExtremeStruc node = GetNode(i);
      if(node.hilo == HIGH)
         CreateLabel(node.hilo, node.extreme_high, node.timestamp, node.importance);
      else
         CreateLabel(node.hilo, node.extreme_low, node.timestamp, node.importance);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::ResetLegs(void)
  {
   for(int i = 0; i < importance_; i++)
     {
      legs_extremes_[i].Reset();
     }
   importance_ = 1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::MarkPbConditions(void)
  {
   for(int i = 0; i < importance_; i++)
     {
      legs_extremes_[i].retracement_level = RetracementLevel(legs_extremes_[i]);
      legs_extremes_[i].num_of_pb_bars = CountPbBars(legs_extremes_[i]);
      legs_extremes_[i].pullback_gap = CheckForGap(legs_extremes_[i]);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::AppendIfChangedDirection(int p_index = 0)
  {
   for(int i = 0 ; i < importance_ ; ++i)
     {
      CheckDirectionChange(p_index, legs_extremes_[i]);
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::CheckDirectionChange(int p_index, LegStruc &p_leg)
  {
   GraphExtremeStruc last_node = GetLastNode();
   double current_min = iLow(_Symbol, _Period, p_index);
   double current_max = iHigh(_Symbol, _Period, p_index);
   Print("last_node: ", last_node.timestamp);
   if(last_node.hilo == HIGH &&
      current_max > last_node.extreme_high)
     {
      GraphExtremeStruc extreme_low(p_leg.min_timestamp,
                                    iHigh(_Symbol, _Period, iBarShift(_Symbol, _Period, p_leg.min_timestamp, true)),
                                    p_leg.min,
                                    LOW,
                                    last_node.importance);
      graph_extremes_.Append(extreme_low);
      p_leg.Reset();
      UpdateAllLegs(p_index);
     }
   if(last_node.hilo == LOW &&
      current_min < last_node.extreme_low)
     {
      GraphExtremeStruc extreme_high(p_leg.max_timestamp,
                                     p_leg.max,
                                     iLow(_Symbol, _Period, iBarShift(_Symbol, _Period, p_leg.max_timestamp, true)),
                                     HIGH,
                                     last_node.importance);
      graph_extremes_.Append(extreme_high);
      p_leg.Reset();
      UpdateAllLegs(p_index);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::IncreaseImportance()
  {
   for(int i = 0; i < importance_; i++)
     {
      if(TypeOnePB(legs_extremes_[i]) || TypeTwoPB(legs_extremes_[i]))
        {
         importance_ = legs_extremes_[i].level + 1;
         if(importance_ > 4)
            importance_ = 4;
        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CManageExtremes::TypeOnePB(LegStruc &p_leg)
  {
   return ((p_leg.pullback_gap && p_leg.retracement_level >= min_retracement_) ||
           (p_leg.retracement_level >= min_retracement_ && p_leg.num_of_pb_bars >= min_pb_bars_4_));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CManageExtremes::TypeTwoPB(LegStruc &p_leg)
  {
   return (p_leg.pullback_gap && p_leg.num_of_pb_bars >= min_pb_bars_5_);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::MarkTriggers(int p_index = 0)
  {
   for(int i = 0; i < importance_ ; i++)
     {
      Print("Level: ", legs_extremes_[i].level);
      legs_extremes_[i].TypeOneTrigger = TypeOnePB(legs_extremes_[i]);
      legs_extremes_[i].TypeTwoTrigger = TypeTwoPB(legs_extremes_[i]);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::VerifyExtreme(void)
  {
   GraphExtremeStruc last_node = GetLastNode();

   for(int i = 0; i < importance_; i++)
     {
      if(legs_extremes_[i].TypeOneTrigger == true ||
         legs_extremes_[i].TypeTwoTrigger == true)
        {
         if(legs_extremes_[i].level == 1)
           {
            if(last_node.hilo == HIGH)
              {
               GraphExtremeStruc extreme_low(legs_extremes_[i].min_timestamp,
                                             iHigh(_Symbol, _Period, iBarShift(_Symbol, _Period, legs_extremes_[i].min_timestamp, true)),
                                             legs_extremes_[i].min,
                                             LOW, 1);
               graph_extremes_.Append(extreme_low);
               legs_extremes_[i] = LegStruc(iLow(_Symbol, _Period, iBarShift(_Symbol, _Period, legs_extremes_[i].max_timestamp, true)),
                                            legs_extremes_[i].max,
                                            legs_extremes_[i].max_timestamp,
                                            legs_extremes_[i].max_timestamp);
               //ResetLegs();
              }
            if(last_node.hilo == LOW)
              {
               GraphExtremeStruc extreme_high(legs_extremes_[i].max_timestamp,
                                              legs_extremes_[i].max,
                                              iLow(_Symbol, _Period, iBarShift(_Symbol, _Period, legs_extremes_[i].max_timestamp, true)),
                                              HIGH, 1);
               graph_extremes_.Append(extreme_high);

               legs_extremes_[i] = LegStruc(legs_extremes_[i].min,
                                            iHigh(_Symbol, _Period, iBarShift(_Symbol, _Period, legs_extremes_[i].min_timestamp, true)),
                                            legs_extremes_[i].min_timestamp,
                                            legs_extremes_[i].min_timestamp);
               //ResetLegs();
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::UpdateAllLegs(int p_index = 0)
  {
   for(int i = 0; i < importance_; ++i)
     {
      int next = i + 1;
      if(i + 1 > 3)
         next = 3;
      if(legs_extremes_[next].min_timestamp < legs_extremes_[i].min_timestamp ||
         legs_extremes_[next].max_timestamp < legs_extremes_[i].max_timestamp)
         legs_extremes_[next].Reset();

      FindLegExtreme(p_index, legs_extremes_[i]);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::FindLegExtreme(int p_index, LegStruc &p_leg)
  {
   double current_min = iLow(_Symbol, _Period, p_index);
   double current_max = iHigh(_Symbol, _Period, p_index);
   HILO hilo = FindPbOrientation(p_leg.level);
   if(hilo == LOW)
     {
      if(p_leg.min > current_min)
        {
         p_leg.min = current_min;
         p_leg.min_timestamp = iTime(_Symbol, _Period, p_index);
         int distance = CandleDistance(p_leg.min_timestamp, p_leg.max_timestamp);
         if((distance == 1 || distance == 2) &&
            p_leg.max < current_max)
           {
            p_leg.max = current_max;
            p_leg.max_timestamp = iTime(_Symbol, _Period, p_index);
           }
         return;
        }

      if(p_leg.max < current_max)
        {
         p_leg.max = current_max;
         p_leg.max_timestamp = iTime(_Symbol, _Period, p_index);
         p_leg.min = current_min;
         p_leg.min_timestamp = iTime(_Symbol, _Period, p_index);
        }
     }
   if(hilo == HIGH)
     {
      if(p_leg.max < current_max)
        {
         p_leg.max = current_max;
         p_leg.max_timestamp = iTime(_Symbol, _Period, p_index);
         int distance = CandleDistance(p_leg.min_timestamp, p_leg.max_timestamp);
         if((distance == 1 || distance == 2) &&
            p_leg.min > current_min)
           {
            p_leg.min = current_min;
            p_leg.min_timestamp = iTime(_Symbol, _Period, p_index);
           }
         return;
        }
      if(p_leg.min > current_min)
        {
         p_leg.max = current_max;
         p_leg.max_timestamp = iTime(_Symbol, _Period, p_index);
         p_leg.min = current_min;
         p_leg.min_timestamp = iTime(_Symbol, _Period, p_index);
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CManageExtremes::CheckCrossing(int p_index, LegStruc &p_leg)
  {
   HILO hilo = FindPbOrientation(p_leg.level);
   double current_min = iLow(_Symbol, _Period, p_index);
   double current_max = iHigh(_Symbol, _Period, p_index);

   if(hilo == HIGH && p_leg.pullback_gap && current_min < p_leg.min)
      return true;
   if(hilo == LOW && p_leg.pullback_gap && current_max > p_leg.max)
      return true;
   return false;
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
void CreateLabel(HILO p_dir, double p_price, datetime p_time, int p_imp)
  {
   if(p_dir == HIGH)
     {
      string name = "High" + (string)MathRand();
      if(!ObjectCreate(0, name, OBJ_TEXT, 0, p_time, p_price))
        {
         Print(__FUNCTION__,
               ": failed to create a Label! Error code = ", GetLastError());
        }
      ObjectSetString(0, name, OBJPROP_TEXT, (string)p_imp);
     }

   if(p_dir == LOW)
     {
      string name = "Low" + (string)MathRand();
      if(!ObjectCreate(0, name, OBJ_TEXT, 0, p_time, p_price))
        {
         Print(__FUNCTION__,
               ": failed to create a Label! Error code = ", GetLastError());
        }
      ObjectSetString(0, name, OBJPROP_TEXT, (string)p_imp);
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
bool CManageExtremes::IsCrossingOldLow(LegStruc &p_leg, int p_index = 0)
  {
   double current_min = iLow(_Symbol, _Period, p_index);
   double current_max = iHigh(_Symbol, _Period, p_index);
   if(current_min < p_leg.min && p_leg.min_timestamp < iTime(_Symbol, _Period, 1))
      return true;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
GraphExtremeStruc CManageExtremes::GetNode(int index = 0)
  {
   return graph_extremes_.GetNode(index);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CManageExtremes::PBStarted(LegStruc &p_leg)
  {
   if(p_leg.max_timestamp == p_leg.min_timestamp)
      return false;
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CManageExtremes::RetracementLevel(LegStruc &p_leg)
  {
   GraphExtremeStruc last_node = GetLastNode();

   for(int i = 0; i < importance_; i++)
     {
      HILO hilo = FindPbOrientation(p_leg.level);

      if(!PBStarted(p_leg))
        {
         return 0;
        }
      if(hilo == HIGH)
        {
         double full_leg_range = last_node.extreme_high - p_leg.min;
         double ret_price = p_leg.max - p_leg.min;
         return (ret_price / full_leg_range);
        }
      if(hilo == LOW)
        {
         double full_leg_range = p_leg.max - last_node.extreme_low;
         double ret_price = p_leg.max - p_leg.min;
         return (ret_price / full_leg_range);
        }
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CManageExtremes::CheckForGap(LegStruc &p_leg)
  {
   if(p_leg.min_timestamp == p_leg.max_timestamp)
      return false;

   int bar1 = iBarShift(_Symbol, _Period, p_leg.min_timestamp, true);
   int bar2 = iBarShift(_Symbol, _Period, p_leg.max_timestamp, true);
   if(bar1 > bar2)
      for(int i = bar2 ; i < bar1; i++)
        {
         if(pullback_.OverlapLevel(bar1, i) <= 0)
            return true;
        }
   else
      for(int i = bar1 ; i < bar2; i++)
        {
         if(pullback_.OverlapLevel(i, bar2) <= 0)
            return true;
        }

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CManageExtremes::CountPbBars(LegStruc &p_leg)
  {
   if(!PBStarted(p_leg))
      return 0;
   int bar1 = iBarShift(_Symbol, _Period, p_leg.min_timestamp, true);
   int bar2 = iBarShift(_Symbol, _Period, p_leg.max_timestamp, true);
   return MathAbs(bar1 - bar2) + 1;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CManageExtremes::CountTriggerBars(LegStruc &p_leg, int p_index)
  {
   if(p_leg.min_timestamp == p_leg.max_timestamp)
      return 0;
   if(p_leg.min_timestamp < p_leg.max_timestamp)
     {
      return iBarShift(_Symbol, _Period, p_leg.min_timestamp, true) - p_index + 1;
     }
   else
     {
      return iBarShift(_Symbol, _Period, p_leg.max_timestamp, true) - p_index  + 1;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::TransferLegs(void)
  {
//Put the leg not triggered yet to first leg
   for(int i = importance_ - 1 ; i > 0; i--)
     {
      if(PBStarted(legs_extremes_[i]))
        {
         legs_extremes_[i - 1].Update(legs_extremes_[i]);
        }

     }
  }

//+------------------------------------------------------------------+
