/*------------------------------------------------------------------------------------
   Name: TF-Slicer.mq4
   
   Description: Draw lines slicing up higher timeframe bars on an indicator 
                in a seperate chart window

	Note: Place ontop of the indicator you want divider lines on and set the required 
	      timeframe in the parameter tab. 
	      The line attributes can be changed in the indicator properties window.
   
   Change log:
       2014-01-04. Xaphod, v1.00
-------------------------------------------------------------------------------------*/
// Indicator properties
#property copyright "Copyright © 2014, Xaphod"
#property link      "http://www.xaphod.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Silver
#property indicator_width1  1
#property indicator_style1  STYLE_DOT
#property indicator_maximum 4
#property indicator_minimum 0.1

//#include <xPrint.mqh>

// Constant definitions
#define INDICATOR_NAME "TF-Slicer"
#define INDICATOR_VERSION "1.01"
#define DIVIDER_LINE 999999

// indicator parameters
extern int       TimeFrame=15;            // Timeframe: 0,1,5,15,30,60,240,1440 etc. Current Timeframe=0. 


// indicator buffers
double gdaLine[];

// Globals
int giRepaintBars;

//+------------------------------------------------------------------+
int init() {
  SetIndexStyle(0,DRAW_LINE);
  SetIndexBuffer(0,gdaLine);
  SetIndexLabel(0,NULL);
  giRepaintBars=TimeFrame/Period()+2; 
  IndicatorShortName("");
  return(0);
}

//+------------------------------------------------------------------+
int deinit() {
   return (0);
}


//+------------------------------------------------------------------+
int start() {
  int i, j, iNewBars, iCountedBars;
  static int iDivider=-1;
  static int iHTFBar=-1;

  
  // Get unprocessed bars
  iCountedBars=IndicatorCounted();
  if(iCountedBars < 0) return (-1); 
  if(iCountedBars>0) iCountedBars--;
  
  // Set bars to redraw
  if (NewBars(TimeFrame)>3)
    iNewBars=Bars-1;
  else
    iNewBars=Bars-iCountedBars;
  if (iNewBars<giRepaintBars)
    iNewBars=giRepaintBars;
  
  for(i=iNewBars; i>=0; i--) {
    // Reset lines on redraw of the whole buffer
    if (iNewBars==(Bars-1))
      gdaLine[i]=EMPTY_VALUE;
      
    // Shift index for higher time-frame
    if (TimeFrame>Period() )
      j=iBarShift(Symbol(), TimeFrame, Time[i]);
    else
      j=i;
    
    // DRAW. Flip divider line to the opposite level to make it draw the line
    if (iHTFBar!=j) {
      iHTFBar=j;      
      if (gdaLine[i]==EMPTY_VALUE) 
        if (TimeFrame>Period())
          iDivider *=-1;
    }
    // DON'T DRAW. Keep line on the same level if this is not a newbar bar
    if (gdaLine[i]==EMPTY_VALUE)
      if (TimeFrame>Period())
        gdaLine[i]=iDivider*DIVIDER_LINE;
  }
        
  return(0);
}
//+------------------------------------------------------------------+

//-----------------------------------------------------------------------------
// function: NewBars()
// Description: Return nr of new bars on a TF
//-----------------------------------------------------------------------------
int NewBars(int iPeriod) {
  static int iPrevSize=0;
  int iNewSize;
  int iNewBars;
  datetime tTimeArray[];
  
  ArrayCopySeries(tTimeArray,MODE_TIME,Symbol(),iPeriod);
  iNewSize=ArraySize(tTimeArray);
  iNewBars=iNewSize-iPrevSize;
  iPrevSize=iNewSize;
  return(iNewBars);
}




