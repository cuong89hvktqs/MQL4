//+------------------------------------------------------------------+
//|                                                      Program.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <EasyAndFastGUI\Controls\WndEvents.mqh>
#include "MainWindow.mqh"
//+------------------------------------------------------------------+
//| Class for creating an application                                |
//+------------------------------------------------------------------+
class CProgram : public CWndEvents
  {
public:
   //--- Window
   //CWindow           m_window;
   CMainWindow       m_window;
   
   //---
public:
                     CProgram(void);
                    ~CProgram(void);
   //--- Initialization/uninitialization
   void              OnInitEvent(void);
   void              OnDeinitEvent(const int reason);
   //--- Timer
   void              OnTimerEvent(void);
   //---
protected:
   //--- Chart event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //---
public:
   //--- Creates a trading panel
   bool              CreateTradePanel(void);
   //---
private:
   bool              CreateWindow(const string text);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CProgram::CProgram(void)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CProgram::~CProgram(void)
  {
  }
//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
void CProgram::OnInitEvent(void)
  {
  }
//+------------------------------------------------------------------+
//| Uninitialization                                                 |
//+------------------------------------------------------------------+
void CProgram::OnDeinitEvent(const int reason)
  {
   //--- Deleting an interface
   CWndEvents::Destroy();    
  }
//+------------------------------------------------------------------+
//| Timer                                                            |
//+------------------------------------------------------------------+
void CProgram::OnTimerEvent(void)
  {
   CWndEvents::OnTimerEvent();
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CProgram::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
  }
//+------------------------------------------------------------------+
//| Creates a trading panel                                          |
//+------------------------------------------------------------------+
bool CProgram::CreateTradePanel(void)
  {
//--- Creating a form for controls
   if(!CreateWindow("EXPERT PANEL"))
      return(false);
//--- Creating controls
// ...
//---
   m_chart.Redraw();
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates a form for controls                                      |
//+------------------------------------------------------------------+
bool CProgram::CreateWindow(const string caption_text)
  {
//--- Add a window pointer to the window array
   CWndContainer::AddWindow(m_window);
   
//--- Coordinates
   int x=1;
   int y=40;
//--- Properties
   m_window.Movable(true);
   m_window.XSize(240);
   m_window.YSize(195);
   m_window.WindowBgColor(clrDarkSlateGray);
//--- Creating a form
   if(!m_window.CreatMainWindow(m_chart_id,m_subwin,caption_text,x,y))
      return(false);
  // btn_1.Create(m_chart_id,"btn1",m_subwin,5,5,50,50);
//---
   return(true);
  }
//+------------------------------------------------------------------+
