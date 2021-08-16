//+------------------------------------------------------------------+
//|                                                   Directions.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <Dev\Brooks\DirectionStruct.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CDirections
  {

public:
   s_Directions      always_direction[];
   int               lastPosition;

                     CDirections(void);
                    ~CDirections();
   void              Append(int direction, datetime time);
   s_Directions      Pop(void);
   void              Extend(void);
   void              Trim(void);
   int               GetSize(void);
   s_Directions      GetItem(int index);
   void              PrintArray(void);
  };
//+------------------------------------------------------------------+
void CDirections::CDirections(void)
  {
   lastPosition = 0;
   ArrayResize(always_direction,512);
   PrintArray();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDirections::~CDirections(void) {}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDirections::Append(int direction,datetime time)
  {
   if(ArraySize(always_direction)<=lastPosition)
     {
      Extend();
     }
   always_direction[lastPosition].direction=(ALWAYS_IN)direction;
   always_direction[lastPosition].timestamp=time;
   lastPosition++;
  }
//+------------------------------------------------------------------+
void CDirections::Extend(void)
  {
   ArrayResize(always_direction,ArraySize(always_direction)+512);
  }
//+------------------------------------------------------------------+
void CDirections::Trim(void)
  {
   ArrayResize(always_direction,lastPosition);
  }
//+------------------------------------------------------------------+
s_Directions CDirections::Pop(void)
  {
   s_Directions dir;
   if(lastPosition==0) return dir;
   int last_tmp = lastPosition;
   lastPosition--;
   return always_direction[last_tmp];
  }
//+------------------------------------------------------------------+
s_Directions CDirections::GetItem(int index)
  {
   return always_direction[index];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CDirections::GetSize(void)
  {
   return lastPosition;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDirections::PrintArray()
  {
   for(int i=0; i<GetSize(); i++)
     {
      Print(always_direction[i].timestamp," ",always_direction[i].direction);
     }

  }
//+------------------------------------------------------------------+
