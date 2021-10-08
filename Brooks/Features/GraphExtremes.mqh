//+------------------------------------------------------------------+
//|                                                GraphExtremes.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <Dev\Brooks\Features\Structs\Index.mqh>

class CGraphExtremes
  {
public:
   GraphExtremeStruc major_extremes_[], complete_extremes_[];
   int               last_major_position_, last_complete_position_;

                     CGraphExtremes(void);
                    ~CGraphExtremes(void){};
   void              Append(GraphExtremeStruc &node);
   void              Insert(int p_position, GraphExtremeStruc &node);
   void              Extend(GraphExtremeStruc &arr[]);
   int               GetMajorSize(void);
   int               GetLastMajorIndex(void);
   GraphExtremeStruc GetMajorNode(int index);
   GraphExtremeStruc GetNode(int index);
   void              IncrementRight(void);
   int               GetSizeComplete(void);
   int               GetLastIndexComplete(void);
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CGraphExtremes::CGraphExtremes(void)
  {
   last_major_position_ = 0;
   last_complete_position_ = 0;
   ArrayResize(major_extremes_, 256);
   ArrayResize(complete_extremes_, 256);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGraphExtremes::Append(GraphExtremeStruc &node)
  {
   if(last_major_position_ >= ArraySize(major_extremes_))
      Extend(major_extremes_);
   if(last_complete_position_ >= ArraySize(complete_extremes_))
      Extend(complete_extremes_);

   if(node.importance == 1)
     {
      major_extremes_[last_major_position_] = node;
      ++last_major_position_;
     }

   complete_extremes_[last_complete_position_] = node;
   ++last_complete_position_;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGraphExtremes::Extend(GraphExtremeStruc &arr[])
  {
   ArrayResize(arr, ArraySize(arr) + 256);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CGraphExtremes::GetMajorSize(void)
  {
   return last_major_position_;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CGraphExtremes::GetLastMajorIndex(void)
  {
   int tmp = last_major_position_ - 1;
   if(tmp < 0)
      return 0;
   return tmp;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
GraphExtremeStruc CGraphExtremes::GetMajorNode(int index)
  {
   GraphExtremeStruc graph;
   if(index < 0)
      return graph;
   return major_extremes_[index];
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CGraphExtremes::GetSizeComplete(void)
  {
   return last_complete_position_;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CGraphExtremes::GetLastIndexComplete(void)
  {
   int tmp = last_complete_position_ - 1;
   if(tmp < 0)
      return 0;
   return tmp;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
GraphExtremeStruc CGraphExtremes::GetNode(int index)
  {
   GraphExtremeStruc graph;
   if(index < 0)
      return graph;
   return complete_extremes_[index];
  }


//+------------------------------------------------------------------+

