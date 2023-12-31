//+------------------------------------------------------------------+
//|                                                    WndEvents.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "Defines.mqh"
#include "WndContainer.mqh"
#include <Charts\Chart.mqh>
//+------------------------------------------------------------------+
//| Class for event handling                                         |
//+------------------------------------------------------------------+
class CWndEvents : public CWndContainer
  {
protected:
   CChart            m_chart;
   //--- Identifier and window number of the chart
   long              m_chart_id;
   int               m_subwin;
   //--- Program name
   string            m_program_name;
   //--- Short name of the indicator
   string            m_indicator_shortname;
   //---
private:
   //--- Event parameters
   int               m_id;
   long              m_lparam;
   double            m_dparam;
   string            m_sparam;
   //---
protected:
                     CWndEvents(void);
                    ~CWndEvents(void);
   //--- Virtual event handler of the chart
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam) {}
   //--- Timer
   void              OnTimerEvent(void);
   //---
public:
   //--- Event handlers of the chart
   void              ChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
private:
   void              ChartEventCustom(void);
   void              ChartEventClick(void);
   void              ChartEventMouseMove(void);
   void              ChartEventObjectClick(void);
   void              ChartEventEndEdit(void);
   void              ChartEventChartChange(void);
   //--- Checking events in controls
   void              CheckElementsEvents(void);
   //--- Identifying the sub-window number
   void              DetermineSubwindow(void);
   //--- Checking events of controls
   void              CheckSubwindowNumber(void);
   //--- Initialization of event parameters
   void              InitChartEventsParams(const int id,const long lparam,const double dparam,const string sparam);
   //--- Window displacement
   void              MovingWindow(void);
   //--- Checking events of all controls by timer
   void              CheckElementsEventsTimer(void);
   //---
protected:
   //--- Deleting an interface
   void              Destroy(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CWndEvents::CWndEvents(void) : m_chart_id(0),
                               m_subwin(0),
                               m_indicator_shortname("")
  {
//--- Enable the timer
   if(!::MQLInfoInteger(MQL_TESTER))
      ::EventSetMillisecondTimer(TIMER_STEP_MSC);
//--- Obtain the ID of the current chart
   m_chart.Attach();
//--- Enable tracking of mouse events
   m_chart.EventMouseMove(true);
//--- Identifying the sub-window number
   DetermineSubwindow();
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CWndEvents::~CWndEvents(void)
  {
//--- Delete the timer
   ::EventKillTimer();
//--- Enable management
   m_chart.MouseScroll(true);
   m_chart.SetInteger(CHART_DRAG_TRADE_LEVELS,true);
//--- Disable tracking mouse events
   m_chart.EventMouseMove(false);
//--- Detach from the chart
   m_chart.Detach();
//--- Delete a comment   
   ::Comment("");
  }
//+------------------------------------------------------------------+
//| Initialization of event variables                                |
//+------------------------------------------------------------------+
void CWndEvents::InitChartEventsParams(const int id,const long lparam,const double dparam,const string sparam)
  {
   m_id     =id;
   m_lparam =lparam;
   m_dparam =dparam;
   m_sparam =sparam;
  }
//+------------------------------------------------------------------+
//| Program event handling                                           |
//+------------------------------------------------------------------+
void CWndEvents::ChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- If the array is empty, leave
   if(CWndContainer::WindowsTotal()<1)
      return;
//--- Initialization of the fields of event parameters
   InitChartEventsParams(id,lparam,dparam,sparam);
//--- Verification of the events of interface controls
   CheckElementsEvents();
//--- Event of mouse displacement
   ChartEventMouseMove();
//--- Event of changing the chart properties
   ChartEventChartChange();
  }
//+------------------------------------------------------------------+
//| Verification of the control events                               |
//+------------------------------------------------------------------+
void CWndEvents::CheckElementsEvents(void)
  {
   int elements_total=CWndContainer::ElementsTotal(0);
   for(int e=0; e<elements_total; e++)
   {
      m_wnd[0].m_elements[e].OnEvent(m_id,m_lparam,m_dparam,m_sparam);
   }
//--- Forwarding the event to the application file
   OnEvent(m_id,m_lparam,m_dparam,m_sparam);
  }
//+------------------------------------------------------------------+
//| CHARTEVENT_CUSTOM event                                          |
//+------------------------------------------------------------------+
void CWndEvents::ChartEventCustom(void)
  {
  }
//+------------------------------------------------------------------+
//| CHARTEVENT CLICK event                                           |
//+------------------------------------------------------------------+
void CWndEvents::ChartEventClick(void)
  {
  }
//+------------------------------------------------------------------+
//| CHARTEVENT MOUSE MOVE event                                      |
//+------------------------------------------------------------------+
void CWndEvents::ChartEventMouseMove(void)
  {
//--- Leave, if this is not an event of the cursor displacement
   if(m_id!=CHARTEVENT_MOUSE_MOVE)
      return;
//--- Window displacement
   MovingWindow();
//--- Redraw chart
   m_chart.Redraw();
  }
//+------------------------------------------------------------------+
//| CHARTEVENT OBJECT CLICK event                                    |
//+------------------------------------------------------------------+
void CWndEvents::ChartEventObjectClick(void)
  {
  }
//+------------------------------------------------------------------+
//| CHARTEVENT OBJECT ENDEDIT event                                  |
//+------------------------------------------------------------------+
void CWndEvents::ChartEventEndEdit(void)
  {
  }
//+------------------------------------------------------------------+
//| CHARTEVENT CHART CHANGE event                                    |
//+------------------------------------------------------------------+
void CWndEvents::ChartEventChartChange(void)
  {
//--- Event of changing the chart properties
   if(m_id!=CHARTEVENT_CHART_CHANGE)
      return;
//--- Checking and updating the number of the program window
   CheckSubwindowNumber();
//--- Window displacement
   MovingWindow();
//--- Redraw chart
   m_chart.Redraw();
  }
//+------------------------------------------------------------------+
//| Timer                                                            |
//+------------------------------------------------------------------+
void CWndEvents::OnTimerEvent(void)
  {
//--- If the array is empty, leave  
   if(CWndContainer::WindowsTotal()<1)
      return;
//--- Checking events of all controls by timer
   CheckElementsEventsTimer();
//--- Redraw chart
   m_chart.Redraw();
  }
//+------------------------------------------------------------------+
//| Displacement of the window                                       |
//+------------------------------------------------------------------+
void CWndEvents::MovingWindow(void)
  {
//--- Window displacement
   int x=m_windows[0].X();
   int y=m_windows[0].Y();
   m_windows[0].Moving(x,y);
//--- Control displacement
   int elements_total=CWndContainer::ElementsTotal(0);
   for(int e=0; e<elements_total; e++)
      m_wnd[0].m_elements[e].Moving(x,y);
  }
//+------------------------------------------------------------------+
//| Checking all control events by timer                             |
//+------------------------------------------------------------------+
void CWndEvents::CheckElementsEventsTimer(void)
  {
   int elements_total=CWndContainer::ElementsTotal(0);
   for(int e=0; e<elements_total; e++)
      m_wnd[0].m_elements[e].OnEventTimer();
  }
//+------------------------------------------------------------------+
//| Identifying the sub-window number                                |
//+------------------------------------------------------------------+
void CWndEvents::DetermineSubwindow(void)
  {
//--- If program type is not an indicator, leave
   if(PROGRAM_TYPE!=PROGRAM_INDICATOR)
      return;
//--- Reset the last error
   ::ResetLastError();
//--- Identifying the number of the indicator window
   m_subwin=::ChartWindowFind();
//--- If identification of the number failed, leave
   if(m_subwin<0)
     {
      ::Print(__FUNCTION__," > Error when identifying the sub-window number: ",::GetLastError());
      return;
     }
//--- If this is not the main window of the chart
   if(m_subwin>0)
     {
      //--- Receive the common number of indicators in the specified sub-window
      int total=::ChartIndicatorsTotal(m_chart_id,m_subwin);
      //--- Receive the short name of the last indicator in the list
      string indicator_name=::ChartIndicatorName(m_chart_id,m_subwin,total-1);
      //--- If the sub-window already contains an indicator, remove the program from the chart
      if(total!=1)
        {
         ::Print(__FUNCTION__," > This sub-window already contains an indicator.");
         ::ChartIndicatorDelete(m_chart_id,m_subwin,indicator_name);
         return;
        }
     }
  }
//+------------------------------------------------------------------+
//| Verification and updating the number of the program window       |
//+------------------------------------------------------------------+
void CWndEvents::CheckSubwindowNumber(void)
  {
//--- If the program in the sub-window and the numbers do not match
   if(m_subwin!=0 && m_subwin!=::ChartWindowFind())
     {
      //--- Identify the sub-window number
      DetermineSubwindow();
      //--- Store in all controls
      int windows_total=CWndContainer::WindowsTotal();
      for(int w=0; w<windows_total; w++)
        {
         int elements_total=ElementsTotal(w);
         for(int e=0; e<elements_total; e++)
            m_wnd[w].m_elements[e].SubwindowNumber(m_subwin);
        }
     }
  }
//+------------------------------------------------------------------+
//| Deletion of all objects                                          |
//+------------------------------------------------------------------+
void CWndEvents::Destroy(void)
  {
   int window_total=CWndContainer::WindowsTotal();
   for(int w=0; w<window_total; w++)
     {
      int elements_total=CWndContainer::ElementsTotal(w);
      for(int e=0; e<elements_total; e++)
        {
         //--- If the pointer is invalid, move to the next
         if(::CheckPointer(m_wnd[w].m_elements[e])==POINTER_INVALID)
            continue;
         //--- Delete control objects
         m_wnd[w].m_elements[e].Delete();
        }
      //--- Empty control arrays
      ::ArrayFree(m_wnd[w].m_objects);
      ::ArrayFree(m_wnd[w].m_elements);
     }
//--- Empty form arrays
   ::ArrayFree(m_wnd);
   ::ArrayFree(m_windows);
  }
//+------------------------------------------------------------------+
