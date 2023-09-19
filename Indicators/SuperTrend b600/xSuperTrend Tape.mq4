/*------------------------------------------------------------------------------------
   Name: xSuperTrend Tape.mq4
   Copyright ©2011, Xaphod, http://wwww.xaphod.com
   
   Description: SuperTrend Tape Chart
	          
   Change log: 
       2011-11-25. Xaphod, v1.00 
          - First Release 
-------------------------------------------------------------------------------------*/
// Indicator properties
#property copyright "Copyright © 2010, Xaphod"
#property link      "http://wwww.xaphod.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 LimeGreen
#property indicator_color2 Red
#property indicator_width1 4
#property indicator_width2 4
#property indicator_maximum 1
#property indicator_minimum 0
//#include <xDebug.mqh>

// Constant definitions
#define INDICATOR_NAME "xSuperTrend"
#define INDICATOR_VERSION "v1.00, www.xaphod.com"

// Indicator parameters
extern string Version.Info=INDICATOR_VERSION;
extern string SuperTrend.Info="——————————————————————————————";
extern int    SuperTrend.Period=10;      // SuperTrend ATR Period
extern double SuperTrend.Multiplier=1.7; // SuperTrend Multiplier

// Global module varables
double gadUpBuf[];
double gadDnBuf[];
double gadSuperTrend[];


//-----------------------------------------------------------------------------
// function: init()
// Description: Custom indicator initialization function.
//-----------------------------------------------------------------------------
int init() {
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(0, gadUpBuf);
   SetIndexLabel(0, NULL);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexBuffer(1, gadDnBuf);
   SetIndexLabel(1, NULL);
   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(2, gadSuperTrend);
   SetIndexLabel(2, NULL);
   IndicatorShortName(INDICATOR_NAME+"["+SuperTrend.Period+";"+DoubleToStr(SuperTrend.Multiplier,1)+"]");
  return(0);
}


//-----------------------------------------------------------------------------
// function: deinit()
// Description: Custom indicator deinitialization function.
//-----------------------------------------------------------------------------
int deinit() {
   return (0);
}


///-----------------------------------------------------------------------------
// function: start()
// Description: Custom indicator iteration function.
//-----------------------------------------------------------------------------
int start() {
  int iNewBars, iCountedBars, i;
  double dAtr,dUpperLevel, dLowerLevel;  
  
  // Get unprocessed ticks
  iCountedBars=IndicatorCounted();
  if(iCountedBars < 0) return (-1); 
  if(iCountedBars>0) iCountedBars--;
  iNewBars=Bars-iCountedBars;
  
  for(i=iNewBars; i>=0; i--) {
    // Calc SuperTrend
    dAtr = iATR(NULL, 0, SuperTrend.Period, i);
    dUpperLevel=(High[i]+Low[i])/2+SuperTrend.Multiplier*dAtr;
    dLowerLevel=(High[i]+Low[i])/2-SuperTrend.Multiplier*dAtr;
    
    // Set supertrend levels
    if (Close[i]>gadSuperTrend[i+1] && Close[i+1]<=gadSuperTrend[i+1]) {
      gadSuperTrend[i]=dLowerLevel;
    }
    else if (Close[i]<gadSuperTrend[i+1] && Close[i+1]>=gadSuperTrend[i+1]) {
      gadSuperTrend[i]=dUpperLevel;
    }
    else if (gadSuperTrend[i+1]<dLowerLevel)
        gadSuperTrend[i]=dLowerLevel;
    else if (gadSuperTrend[i+1]>dUpperLevel)
        gadSuperTrend[i]=dUpperLevel;
    else
      gadSuperTrend[i]=gadSuperTrend[i+1];
    
    // Draw Histo
    gadUpBuf[i]=EMPTY_VALUE;
    gadDnBuf[i]=EMPTY_VALUE;
    if (Close[i]>gadSuperTrend[i] || (Close[i]==gadSuperTrend[i] && Close[i+1]>gadSuperTrend[i+1])) 
      gadUpBuf[i]=1;
    else if (Close[i]<gadSuperTrend[i] || (Close[i]==gadSuperTrend[i] && Close[i+1]<gadSuperTrend[i+1])) 
      gadDnBuf[i]=1; 
  }
  
  return(0);
}
//+------------------------------------------------------------------+



