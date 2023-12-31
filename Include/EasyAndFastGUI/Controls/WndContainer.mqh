//+------------------------------------------------------------------+
//|                                                 WndContainer.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property strict
#include "Window.mqh"
//+------------------------------------------------------------------+
//| Class for storing all the objects of the interface               |
//+------------------------------------------------------------------+
class CWndContainer
  {
protected:
   //--- Window array
   CWindow          *m_windows[];
   //--- Structure of control arrays
   struct WindowElements
     {
      //--- Common array of all objects
      CChartObject     *m_objects[];
      //--- Common array of all controls
      CElement         *m_elements[];
     };
   //--- Array of arrays of controls for each window
   WindowElements    m_wnd[];
   //---
private:
   //--- Control counter
   int               m_counter_element_id;
   //---
protected:
                     CWndContainer();
                    ~CWndContainer();
   //---
public:
   //--- Number of windows in the interface
   int               WindowsTotal(void) { return(::ArraySize(m_windows)); }
   //--- Number of objects of all controls
   int               ObjectsElementsTotal(const int window_index);
   //--- Number of controls
   int               ElementsTotal(const int window_index);
   //---
protected:
   //--- Adds window pointer to the base of the interface controls
   void              AddWindow(CWindow &object);
   //--- Adds pointers to the control objects to the common array
   template<typename T>
   void              AddToObjectsArray(const int window_index,T &object);
   //--- Adds object pointer to the array
   void              AddToArray(const int window_index,CChartObject &object);
   //---
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CWndContainer::CWndContainer(void)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CWndContainer::~CWndContainer(void)
  {
  }
//+------------------------------------------------------------------+
//| Returns number of objects by the specified window index          |
//+------------------------------------------------------------------+
int CWndContainer::ObjectsElementsTotal(const int window_index)
  {
   if(window_index>=::ArraySize(m_wnd))
     {
      ::Print(PREVENTING_OUT_OF_RANGE);
      return(WRONG_VALUE);
     }
//---
   return(::ArraySize(m_wnd[window_index].m_objects));
  }
//+------------------------------------------------------------------+
//| Returns the number of controls by the specified window index     |
//+------------------------------------------------------------------+
int CWndContainer::ElementsTotal(const int window_index)
  {
   if(window_index>=::ArraySize(m_wnd))
     {
      ::Print(PREVENTING_OUT_OF_RANGE);
      return(WRONG_VALUE);
     }
//---
   return(::ArraySize(m_wnd[window_index].m_elements));
  }
//+------------------------------------------------------------------+
//| Adds window pointer to the base of interface controls            |
//+------------------------------------------------------------------+
void CWndContainer::AddWindow(CWindow &object)
  {
   int windows_total=::ArraySize(m_windows);
//--- If there are not any windows, zero the control counter
   if(windows_total<=0)
      m_counter_element_id=0;
//--- Add pointer to the window array
   ::ArrayResize(m_wnd,windows_total+1);
   ::ArrayResize(m_windows,windows_total+1);
   m_windows[windows_total]=::GetPointer(object);
//--- Add pointer to the common array of controls
   int elements_total=::ArraySize(m_wnd[windows_total].m_elements);
   ::ArrayResize(m_wnd[windows_total].m_elements,elements_total+1);
   m_wnd[windows_total].m_elements[elements_total]=::GetPointer(object);
//--- Add control objects to the common array of objects
   AddToObjectsArray(windows_total,object);
//--- Set identifier and store the id of the last control
   m_windows[windows_total].Id(m_counter_element_id);
   m_windows[windows_total].LastId(m_counter_element_id);
//--- Increase the counter of control identifiers
   m_counter_element_id++;
  }
//+------------------------------------------------------------------+
//| Adds pointers of control objects to the common array             |
//+------------------------------------------------------------------+
template<typename T>
void CWndContainer::AddToObjectsArray(const int window_index,T &object)
  {
   int total=object.ObjectsElementTotal();
   for(int i=0; i<total; i++)
      AddToArray(window_index,object.Object(i));
  }
//+------------------------------------------------------------------+
//| Adds an object pointer to an array                               |
//+------------------------------------------------------------------+
void CWndContainer::AddToArray(const int window_index,CChartObject &object)
  {
   int size=::ArraySize(m_wnd[window_index].m_objects);
   ::ArrayResize(m_wnd[window_index].m_objects,size+1);
   m_wnd[window_index].m_objects[size]=::GetPointer(object);
  }
//+------------------------------------------------------------------+
