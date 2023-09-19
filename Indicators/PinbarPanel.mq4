/**************************************************************************
Indicator: 
==========
         Displays a panel showing chosen pairs and timeframes and
         the number of bars merged to form a PinBar.
**************************************************************************/
#property copyright "onedognight"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

//#include "PinbarCalcs.mqh"           //Function to do all the calcs

extern string	xPairs = "AUDCAD,AUDCHF,AUDJPY,AUDNZD,AUDUSD,CADJPY,CHFJPY,EURAUD,EURCAD,EURCHF,EURGBP,EURJPY,EURNZD,EURUSD,GBPAUD,GBPCAD,GBPCHF,GBPJPY,GBPNZD,GBPUSD,NZDJPY,NZDUSD,USDCAD,USDCHF,USDJPY";
extern string	xTimeframes = "H1,H4,D1,W1,MN";
extern int     MaxMergeBars = 4;

string	FontName = "Consolas"; // A fixed-width font lines up nicely
int		FontSize=11;
color    FontColor=MediumSlateBlue;
int      x_width = 18;        //pixels width for each timeframe display column
int      x_offset;            //pixels from the RHS
int      y_depth = 12;        //pixels depth for each display line

int		PairCount;           // Number of currency pairs
int      iP;                  // Indexer for Pairs
string	Pairs[];             // Pairs array ("EURUSD" etc)

int		TfCount;            // Number of timeframes  
int      iT;                 // Indexer for TimeFrames
string	TfDescs[];          // TimeFrame array ("M1","M5" etc)
int		Timeframes[];	     // TimeFrame array (in minutes)

double BuyPB[];              // arrays for pinbar markers on current chart
double SellPB[];

//int      TimeStamp;          // controls the run frequency for this indi

string objPrefix ;	        // prefix for all objects drawn by this indicator
string objId ;

bool alerted=false;

//**************************************************************************
// Convert timeframe description to minutes
//**************************************************************************
int TfDescToTimeframe(string Str)
{
   if( Str == "M1" )   return(PERIOD_M1);
   if( Str == "M5" )   return(PERIOD_M5);
   if( Str == "M15" )  return(PERIOD_M15);
   if( Str == "M30" )  return(PERIOD_M30);
   if( Str == "H1" )   return(PERIOD_H1);
   if( Str == "H4" )   return(PERIOD_H4);
   if( Str == "D1" )   return(PERIOD_D1);
   if( Str == "W1" )   return(PERIOD_W1);
   if( Str == "MN" )   return(PERIOD_MN1);
   return(-1);
}//endfunction TfDescToTimeframe

//**************************************************************************
// init function
//************************************************************************
int init()
{
//xPairs="EURUSD"; xTimeframes="H1"; MaxMergeBars=1; // used for testing
	objPrefix = WindowExpertName();
	
   	// Disply the Panel Heading
	x_offset = 1;       //NB MT4 won't accept an x_offset of zero from the RHS.
	objId = objPrefix + "PanelHead";
   ObjectCreate(objId, OBJ_LABEL, 0, 0, 0);
   ObjectSet(objId, OBJPROP_CORNER, 1);      //Anchored to top-right of chart
   ObjectSet(objId, OBJPROP_XDISTANCE, x_offset);
   ObjectSet(objId, OBJPROP_YDISTANCE, y_depth);
   ObjectSetText(objId,"(MultiBar) Pinbars", FontSize, FontName, FontColor);

      // Check and Store Timeframes	
   xTimeframes=xTimeframes + ","; //ensure trailing comma
   int Len_xTimeframes = StringLen(xTimeframes);
   iT=0;
   for(int start=0; start<Len_xTimeframes;)  //NB 'start' is incremented inside the loop
   {  
      string TfDesc = StringSubstr(xTimeframes,start,StringFind(xTimeframes,",",start)-start); //Extract timeframe description from csv string
      start = start+StringLen(TfDesc)+1;  //set start to point to next character past the current timeframe and the comma
      int Timeframe = TfDescToTimeframe(TfDesc);    //get the 'minutes' for this timeframe    
      if( Timeframe != -1 )    // If this is a valid timeframe
      {
         ArrayResize(TfDescs,iT+1);             
         ArrayResize(Timeframes,iT+1);             
         TfDescs[iT]    =  TfDesc;        //stack timeframe description in array
         Timeframes[iT] =  Timeframe;     //stack timeframe minutes in array
         iT++;
      } // endif( Timeframe != 0)
   } // endfor(int start=0; start<Len_xTimeframes;)
   
   TfCount = iT;     // preserve the timeframes count

      // Display timeframe column headings
   for(iT=0; iT<TfCount; iT++)
   {
      TfDesc = TfDescs[iT];
      x_offset = (TfCount-iT-1)*x_width + 1;  //mark the RH edge of the column

      objId = objPrefix + TfDesc + "_Hd";
      ObjectCreate(objId,OBJ_LABEL,0,0,0,0,0);
      ObjectSet(objId,OBJPROP_CORNER,1);
      ObjectSet(objId,OBJPROP_XDISTANCE,x_offset);
      ObjectSet(objId,OBJPROP_YDISTANCE,2*y_depth);
      ObjectSetText(objId,TfDesc,FontSize-2,FontName,Blue);
   } //endfor(iT=0; iT<TfCount; iT++)
   
   
      // Check, store & display Pair symbols
   x_offset = 1 + (TfCount*x_width);
   xPairs=xPairs + ","; //ensure trailing comma
   int Len_xPairs = StringLen(xPairs);
   iP=0;
   for(start=0; start<Len_xPairs;)
   {
      string Pair = StringSubstr(xPairs,start,StringFind(xPairs,",",start)-start); //Extract pair from csv string
      start = start+StringLen(Pair)+1;   //point to past the pair and the comma
      if( iTime(Pair,0,0) != 0)          // verify Pair is a valid pair
      {
         ArrayResize(Pairs,iP+1);             
         Pairs[iP]=Pair;
   		objId = objPrefix + Pair;
		   ObjectCreate(objId,OBJ_LABEL,0,0,0,0,0);
		   ObjectSet(objId,OBJPROP_CORNER,1);
		   ObjectSet(objId,OBJPROP_XDISTANCE,x_offset);
		   ObjectSet(objId,OBJPROP_YDISTANCE,(iP+3)*y_depth);
		   ObjectSetText(objId,Pair,FontSize,FontName,FontColor);
         iP++;
      } // endif( iTime(Pair,0,0) != 0)
   } // endfor(start=0; start<Len_xPairs;)
   
   PairCount = iP;      // preserve the Pairs count

      // Create one signal object for each timeframe/pair
   for(iT=0; iT<TfCount; iT++)
   {
      Timeframe   = Timeframes[iT];
      
      for(iP=0; iP<PairCount; iP++)
      {
         Pair = Pairs[iP];
         
   	   x_offset = (TfCount-iT-1)*x_width + 1;      //pixels from RHS
			objId = objPrefix + Pair + Timeframe;
			ObjectCreate(objId,OBJ_LABEL,0,0,0,0,0);
 			ObjectSet(objId,OBJPROP_CORNER,1);
   		ObjectSet(objId,OBJPROP_XDISTANCE,x_offset);
			ObjectSet(objId,OBJPROP_YDISTANCE,(iP+3)*y_depth);
		   ObjectSetText(objId,"0",FontSize-2,FontName,FontColor);
      }//Next iP
         
   }//Next iT

   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,233);      // Wingding up arrow
   SetIndexEmptyValue(0,0.0);
   SetIndexBuffer(0,BuyPB);
   SetIndexLabel(0,"PB UP");
   
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,234);      // Wingding down arrow
   SetIndexEmptyValue(1,0.0);   
   SetIndexBuffer(1,SellPB);
   SetIndexLabel(1,"PB DOWN");
      
}//endfunction init()

//**************************************************************************
// deinitialization function
//**************************************************************************
int deinit()
{
	for (int i = ObjectsTotal(); i >= 0; i--)
	{
		string objname = ObjectName(i);
		if (StringFind(objname, objPrefix, 0) > -1) ObjectDelete(objname);
   }//endfor (int i = ObjectsTotal(); i >= 0; i--)
}//endfunction deinit()

//**************************************************************************
// start function
//**************************************************************************
int start()
{
   /*
      // Reduce the run frequency (once per minute)
   int ThisMin = TimeMinute( TimeCurrent() );
   if( TimeStamp == ThisMin ) return;
   TimeStamp = ThisMin;
   */
   
   Trawl();       // Go looking for what you want
   
   MarkCurrentChart();
//if(!alerted) Alert(BuyPB[2]+" "+SellPB[2]); alerted=true;      
}//Endfunction start()


//**************************************************************************
// Trawl function
//**************************************************************************
void Trawl()
{  /*
   Trawl through all the desired timeframes and pairs looking for your
   particular condition.
   */
   
   int i = 1;     // used as a bar index (we are concerned only with bar[1])
//i=2; //used for testing
      // Cycle thru timeframes   
   for(iT=0; iT<TfCount; iT++)
   {
      int Timeframe   = Timeframes[iT];


         // Cycle thru pairs
      for(iP=0; iP<PairCount; iP++)
      {
         string Pair = Pairs[iP];
         
         int result = PinbarFind(Pair, Timeframe, MaxMergeBars, i);
            // Presume no result
         string signal = result;
         color ShowColor = Khaki;
         
            // Test for condition of interest
         if( result<0 )
         {
            ShowColor=Red;
            signal=-result;
         }
         if( result>0 )
         {
            ShowColor=Green;
         }

   	      // Change Signal Objects   
		   objId = objPrefix + Pair + Timeframe;
 		   ObjectSetText(objId,signal,FontSize-2,FontName,ShowColor);
      
      }//next iP
         
   }//next iT

}

//**************************************************************************
// MarkCurrentChart function
//**************************************************************************
void MarkCurrentChart()
{
   int evaluated_bars=IndicatorCounted();
   if (evaluated_bars>0) evaluated_bars--; //---- the latest evaluated bar will be re-evaluated
   int limit = Bars-evaluated_bars;
   
   for(int i=limit; i>0; i--)
   {
      int result = PinbarFind(Symbol(),Period(),MaxMergeBars,i);
      
      if( result != 0 )
         {
         double BarRange = High[i]-Low[i];
         if( result<0 )
            { SellPB[i]=NormalizeDouble(High[i]+BarRange/2,Digits); }
         else
            { BuyPB[i]=NormalizeDouble(Low[i]-BarRange/2,Digits); }
         }
      
   }  //Next i
   return;

}

//**************************************************************************
// analysis function
//**************************************************************************
int PinbarFind(string pair, int timeframe, int mergebars, int i)
{
      /*
      A PinBar has a long shadow (nose) formed by a runaway price which returns to
      somewhere near the open. The opposite shadow is small or non-existent. The nose
      sticks out from the preceding bars (and should stick out from subsequent bars). I
      like pinbars to be longer than the average.
      Engulfer formations can be thought of as pinbars which take two (or more) bars
      to develop.
      This function finds pinbar formations for up to 'mergebars' concecutive bars
      finishing at bar[i]. It will RETURN plus or minus the number of bars merged
      to form the pinbar.
      */
   int result=0;
   
   for(int j=1; j<=mergebars; j++)
   {   
      double O = iOpen(pair,timeframe, i+j-1),                            // Open comes from j bars ago
             H = iHigh(pair,timeframe,iHighest(pair,timeframe,MODE_HIGH,j,i)),   // Highest High of j Bars
             L = iLow(pair,timeframe,iLowest(pair,timeframe,MODE_LOW,j,i)),      // Lowest Low of j Bars
             C = iClose(pair,timeframe,i);                                // Close comes from Bar[i]
      double BarRange = H-L;
      int   PrevBar = i+j;
      double atrRange = iATR(pair,timeframe,4,PrevBar); // recent ATR
      
      if( BarRange > atrRange )       // Not a trivial Bar
      {
         if(      BarRange > 4*( H - MathMin(O,C))                   // Long nose...
               && L+0.25*BarRange < iLow(pair,timeframe,PrevBar)     // ...protruding below previous Bar...
               && L < iLow(pair,timeframe,iLowest(pair,timeframe,MODE_LOW,10,PrevBar))  )    //...and lowest low for a few bars
         {
            result = j;
            break;
         }
         
         else
         if(      BarRange > 4*( MathMax(O,C) - L )                  // Long nose...
               && H-0.25*BarRange > iHigh(pair,timeframe,PrevBar)    // ...jutting above previous Bar...
               && H > iHigh(pair,timeframe,iHighest(pair,timeframe,MODE_HIGH,10,PrevBar)))   // ...and highest high for a few Bars
         {
            result = -j;
            break;
         }
      }
   }  // Next j
   
   return(result);
   
}//endfunction PinbarFind()


