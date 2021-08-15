//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <Dev\Brooks\Directions.mqh>
#include <Dev\Brooks\AlwaysInEnum.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CCheckDirection
  {

public:
   CDirections       m_directions;
   int               m_current_index;
   datetime          m_start_time, m_end_time;
                     CCheckDirection(void);
                     CCheckDirection(datetime start_time, datetime end_time);
                    ~CCheckDirection(void);
   ALWAYS_IN         Direction(datetime currentCandle);
   void              LoadFile(string asset_prefix);
  };


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CCheckDirection::CCheckDirection(void) {}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CCheckDirection::CCheckDirection(datetime start_time, datetime end_time)
  {
   m_start_time = start_time;
   m_end_time = end_time;
   m_directions = CDirections();
   m_current_index = 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CCheckDirection::~CCheckDirection(void) {}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ALWAYS_IN CCheckDirection::Direction(datetime currentCandle)
  {
   if(currentCandle >= m_directions.GetItem(m_current_index+1).timestamp)
     {
      m_current_index++;
     }
   return m_directions.GetItem(m_current_index).direction;
  }
//+------------------------------------------------------------------+
void CCheckDirection::LoadFile(string asset_prefix){
   int h = FileOpen(asset_prefix+TimeToString(m_start_time, TIME_DATE)+"-"+TimeToString(m_end_time, TIME_DATE), FILE_READ|FILE_CSV|FILE_ANSI, ",");
   while(!FileIsEnding(h)){
      Print(FileReadString(h));
   }
   FileClose(h);
}