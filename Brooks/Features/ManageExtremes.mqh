//+------------------------------------------------------------------+
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
   LegStruc          leg_extremes_;

                     CManageExtremes(void);

   void              Run(void);
   void              FirstExtreme(void);
   void              FindYesterdayStructure(void);
   void              FindLegExtreme(int p_index);
   bool              PBStarted();
   GraphExtremeStruc GetLastNode(void);
   GraphExtremeStruc GetLastMajorNode(void);
   GraphExtremeStruc GetNode(int index = 0);
   double            RetracementLevel();
   bool              CheckForGap();
   int               CountPbBars();
   void              MarkPbConditions(void);
   void              MarkTriggers(int p_index);
   void              VerifyExtreme(void);
   bool              TypeOnePB();
   bool              TypeTwoPB();
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
   leg_extremes_.level = 1;
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
      MarkPbConditions();
      MarkTriggers(i);
      VerifyExtreme();
      FindLegExtreme(i);
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
void CManageExtremes::MarkPbConditions(void)
  {
   leg_extremes_.retracement_level = RetracementLevel();
   leg_extremes_.num_of_pb_bars = CountPbBars();
   leg_extremes_.pullback_gap = CheckForGap();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CManageExtremes::TypeOnePB()
  {
   return ((leg_extremes_.pullback_gap && leg_extremes_.retracement_level >= min_retracement_) ||
           (leg_extremes_.retracement_level >= min_retracement_ && leg_extremes_.num_of_pb_bars >= min_pb_bars_4_));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CManageExtremes::TypeTwoPB()
  {
   return (leg_extremes_.pullback_gap && leg_extremes_.num_of_pb_bars >= min_pb_bars_5_);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::MarkTriggers(int p_index = 0)
  {
   for(int i = 0; i < importance_ ; i++)
     {
      leg_extremes_.TypeOneTrigger = TypeOnePB();
      leg_extremes_.TypeTwoTrigger = TypeTwoPB();
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::VerifyExtreme(void)
  {
   GraphExtremeStruc last_node = GetLastNode();

   if(leg_extremes_.TypeOneTrigger == true ||
      leg_extremes_.TypeTwoTrigger == true)
     {
      if(last_node.hilo == HIGH)
        {
         GraphExtremeStruc extreme_low(leg_extremes_.min_timestamp,
                                       iHigh(_Symbol, _Period, iBarShift(_Symbol, _Period, leg_extremes_.min_timestamp, true)),
                                       leg_extremes_.min,
                                       LOW, 1);
         graph_extremes_.Append(extreme_low);
         leg_extremes_ = LegStruc(iLow(_Symbol, _Period, iBarShift(_Symbol, _Period, leg_extremes_.max_timestamp, true)),
                                  leg_extremes_.max,
                                  leg_extremes_.max_timestamp,
                                  leg_extremes_.max_timestamp);
        }
      if(last_node.hilo == LOW)
        {
         GraphExtremeStruc extreme_high(leg_extremes_.max_timestamp,
                                        leg_extremes_.max,
                                        iLow(_Symbol, _Period, iBarShift(_Symbol, _Period, leg_extremes_.max_timestamp, true)),
                                        HIGH, 1);
         graph_extremes_.Append(extreme_high);

         leg_extremes_ = LegStruc(leg_extremes_.min,
                                  iHigh(_Symbol, _Period, iBarShift(_Symbol, _Period, leg_extremes_.min_timestamp, true)),
                                  leg_extremes_.min_timestamp,
                                  leg_extremes_.min_timestamp);

        }
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CManageExtremes::FindLegExtreme(int p_index)
  {
   double current_min = iLow(_Symbol, _Period, p_index);
   double current_max = iHigh(_Symbol, _Period, p_index);
   GraphExtremeStruc last_node = GetLastNode();
   if(last_node.hilo == LOW)
     {
      if(leg_extremes_.min > current_min)
        {
         leg_extremes_.min = current_min;
         leg_extremes_.min_timestamp = iTime(_Symbol, _Period, p_index);
         int distance = CandleDistance(leg_extremes_.min_timestamp, leg_extremes_.max_timestamp);
         if((distance == 1 || distance == 2) &&
            leg_extremes_.max < current_max)
           {
            leg_extremes_.max = current_max;
            leg_extremes_.max_timestamp = iTime(_Symbol, _Period, p_index);
           }
         return;
        }

      if(leg_extremes_.max < current_max)
        {
         leg_extremes_.max = current_max;
         leg_extremes_.max_timestamp = iTime(_Symbol, _Period, p_index);
         leg_extremes_.min = current_min;
         leg_extremes_.min_timestamp = iTime(_Symbol, _Period, p_index);
        }
     }
   if(last_node.hilo == HIGH)
     {
      if(leg_extremes_.max < current_max)
        {
         leg_extremes_.max = current_max;
         leg_extremes_.max_timestamp = iTime(_Symbol, _Period, p_index);
         int distance = CandleDistance(leg_extremes_.min_timestamp, leg_extremes_.max_timestamp);
         if((distance == 1 || distance == 2) &&
            leg_extremes_.min > current_min)
           {
            leg_extremes_.min = current_min;
            leg_extremes_.min_timestamp = iTime(_Symbol, _Period, p_index);
           }
         return;
        }
      if(leg_extremes_.min > current_min)
        {
         leg_extremes_.max = current_max;
         leg_extremes_.max_timestamp = iTime(_Symbol, _Period, p_index);
         leg_extremes_.min = current_min;
         leg_extremes_.min_timestamp = iTime(_Symbol, _Period, p_index);
        }

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
GraphExtremeStruc CManageExtremes::GetNode(int index = 0)
  {
   return graph_extremes_.GetNode(index);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CManageExtremes::PBStarted()
  {
   if(leg_extremes_.max_timestamp == leg_extremes_.min_timestamp)
      return false;
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CManageExtremes::RetracementLevel()
  {
   GraphExtremeStruc last_node = GetLastNode();

   if(!PBStarted())
     {
      return 0;
     }
   if(last_node.hilo == HIGH)
     {
      double full_leg_range = last_node.extreme_high - leg_extremes_.min;
      double ret_price = leg_extremes_.max - leg_extremes_.min;
      return (ret_price / full_leg_range);
     }
   if(last_node.hilo == LOW)
     {
      double full_leg_range = leg_extremes_.max - last_node.extreme_low;
      double ret_price = leg_extremes_.max - leg_extremes_.min;
      return (ret_price / full_leg_range);
     }

   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CManageExtremes::CheckForGap()
  {
   if(!PBStarted())
      return false;

   int bar1 = iBarShift(_Symbol, _Period, leg_extremes_.min_timestamp, true);
   int bar2 = iBarShift(_Symbol, _Period, leg_extremes_.max_timestamp, true);
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
int CManageExtremes::CountPbBars()
  {
   if(!PBStarted())
      return 0;
   int bar1 = iBarShift(_Symbol, _Period, leg_extremes_.min_timestamp, true);
   int bar2 = iBarShift(_Symbol, _Period, leg_extremes_.max_timestamp, true);
   return MathAbs(bar1 - bar2) + 1;
  }

//+------------------------------------------------------------------+
