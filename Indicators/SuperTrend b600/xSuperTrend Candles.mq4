/*------------------------------------------------------------------------------------
   Name: xSuperTrend.mq4
   Copyright ©2011, Xaphod, http://wwww.xaphod.com
   
   Description: SuperTrend Candles
	          
   Change log: 
       2011-12-01. Xaphod, v1.00 
          - First Release 
-------------------------------------------------------------------------------------*/
#property copyright "Copyright © 2011, Xaphod"
#property link      "http://wwww.xaphod.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Red
#property indicator_color2 LimeGreen
#property indicator_color3 Red
#property indicator_color4 LimeGreen
#property indicator_color5 CLR_NONE
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 3
#property indicator_width4 3
#property indicator_width5 1

// Constant definitions
#define INDICATOR_NAME "xSuperTrend Candles"
#define INDICATOR_VERSION "v1.00, www.xaphod.com"

// Indicator parameters
extern string Version.Info=INDICATOR_VERSION;
extern string SuperTrend.Info="——————————————————————————————";
extern int    SuperTrend.Period=10;      // SuperTrend ATR Period
extern double SuperTrend.Multiplier=1.7; // SuperTrend Multiplier

//---- buffers
double gadBearHL[];
double gadBullHL[];
double gadBearBuf[];
double gadBullBuf[];
double gadSuperTrend[];


//-----------------------------------------------------------------------------
// function: init()
// Description: Custom indicator initialization function.
//-----------------------------------------------------------------------------
int init() {
  //---- indicators
  SetIndexStyle(0,DRAW_HISTOGRAM);
  SetIndexBuffer(0, gadBearHL);
  SetIndexDrawBegin(0,SuperTrend.Period);
  SetIndexStyle(1,DRAW_HISTOGRAM);
  SetIndexBuffer(1, gadBullHL);
  SetIndexDrawBegin(1,SuperTrend.Period);
  SetIndexStyle(2,DRAW_HISTOGRAM);
  SetIndexBuffer(2, gadBearBuf);
  SetIndexDrawBegin(2,SuperTrend.Period);
  SetIndexStyle(3,DRAW_HISTOGRAM);
  SetIndexBuffer(3, gadBullBuf);
  SetIndexDrawBegin(3,SuperTrend.Period);
  SetIndexStyle(4,DRAW_LINE);
  SetIndexBuffer(4, gadSuperTrend);
  SetIndexDrawBegin(4,SuperTrend.Period);
  return(0);
}


//-----------------------------------------------------------------------------
// function: deinit()
// Description: Custom indicator deinitialization function.
//-----------------------------------------------------------------------------
int deinit() {
   return (0);
}

//-----------------------------------------------------------------------------
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
    
    // Draw Candles
    if (Close[i]>gadSuperTrend[i] || (Close[i]==gadSuperTrend[i] && Close[i+1]>gadSuperTrend[i+1])) {
      gadBearHL[i]=Low[i];
      gadBullHL[i]=High[i];
      if (Close[i]>Open[i]) {
        gadBearBuf[i]=Open[i];
        gadBullBuf[i]=Close[i];
      }
      else {
        gadBearBuf[i]=Close[i];
        gadBullBuf[i]=Open[i];
      }
    }
    else if (Close[i]<gadSuperTrend[i] || (Close[i]==gadSuperTrend[i] && Close[i+1]<gadSuperTrend[i+1])) {
      gadBearHL[i]=High[i];
      gadBullHL[i]=Low[i];
      if (Close[i]>Open[i]) {
        gadBearBuf[i]=Close[i];
        gadBullBuf[i]=Open[i];
      }
      else {
        gadBearBuf[i]=Open[i];
        gadBullBuf[i]=Close[i];
      }
    }
  }
  
  return(0);
}
//+------------------------------------------------------------------+