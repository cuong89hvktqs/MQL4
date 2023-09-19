/**************************************************************************
Indicator: 
==========
         Displays a panel showing chosen pairs and timeframes that
         have just experienced a moving-average cross-over.
**************************************************************************/
#property copyright "onedognight"
#property indicator_chart_window
#property indicator_buffers 2       // one for each MA
#property indicator_color1 Green
#property indicator_color2 Red

extern string	xPairs = "AUDCAD,AUDCHF,AUDJPY,AUDNZD,AUDUSD,CADJPY,CHFJPY,EURAUD,EURCAD,EURCHF,EURGBP,EURJPY,EURNZD,EURUSD,GBPAUD,GBPCAD,GBPCHF,GBPJPY,GBPNZD,GBPUSD,NZDJPY,NZDUSD,USDCAD,USDCHF,USDJPY";
extern string	xTimeframes = "H1,H4,D1,W1,MN";
extern int     MA1Period = 4;       // Quick MA
extern int     MA2Period = 20;      // Slow MA

   // Placement, size and appearance of the panel
string	FontName = "Consolas"; // A fixed-width font lines up nicely
int		FontSize=11;
color    FontColor=MediumSlateBlue;
int      x_width = 18;        //pixels width for each timeframe display column
int      x_offset;            //pixels from the RHS
int      y_depth = 12;        //pixels depth for each display line

int		PairCount;           // Number of currency pairs
int      iP;                  // Indexer for Pairs
string	Pairs[];             // Pairs array ("EURUSD" etc)

int		TfCount;             // Number of timeframes  
int      iT;                  // Indexer for TimeFrames
string	TfDescs[];           // TimeFrame array ("M1","M5" etc)
int		Timeframes[];	      // TimeFrame array (in minutes)

double MA1_Buffer[];          // arrays for indicators on current chart
double MA2_Buffer[];

//int      TimeStamp;           // controls the run frequency for this indi

string objPrefix ;	         // holds a prefix for all objects drawn by this indicator
string objId ;

bool alerted=false;           // used when testing






/***************************************************************************
 initialize function
 (Stuff that gets done once when the program starts up)
***************************************************************************/
int init()
{
//xPairs="EURUSD"; xTimeframes="H1"; // used for testing
	objPrefix = WindowExpertName();
	
   	// Display the Panel Heading
   	// (NB Start 1 x y_depth down from the top to leave room for any attached expert display)
	x_offset = 1;       //NB MT4 won't accept an x_offset of zero from the RHS.
	objId = objPrefix + "Heading";
   ObjectCreate(objId, OBJ_LABEL,0,0,0);
   ObjectSet(objId, OBJPROP_CORNER, 1);      //Anchored to top-right of chart
   ObjectSet(objId, OBJPROP_XDISTANCE, x_offset);
   ObjectSet(objId, OBJPROP_YDISTANCE, y_depth);
   ObjectSetText(objId,"SMA X-overs", FontSize, FontName, FontColor);

      // Check and Store Timeframes	
   xTimeframes=xTimeframes + ","; //ensure trailing comma
   int Len_xTimeframes = StringLen(xTimeframes);
   iT=0;
   for(int start=0; start<Len_xTimeframes;)  //NB 'start' is incremented inside the loop
   {  
      string TfDesc = StringSubstr(xTimeframes,start,StringFind(xTimeframes,",",start)-start); //Extract timeframe description from csv string
      start = start+StringLen(TfDesc)+1;  //set start to point to next character past the current timeframe and the comma
      int Timeframe = GetMinutes(TfDesc);    //get the 'minutes' for this timeframe    
      if( Timeframe != -1 )    // If this is a valid timeframe
      {
         ArrayResize(TfDescs,iT+1);       //make room             
         ArrayResize(Timeframes,iT+1);    //make room         
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
      x_offset = (TfCount-iT-1)*x_width + 1;  //mark the RH edge of this column
      objId = objPrefix + TfDesc + "_Hd";
      ObjectCreate(objId,OBJ_LABEL,0,0,0);
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
		   ObjectCreate(objId,OBJ_LABEL,0,0,0);
		   ObjectSet(objId,OBJPROP_CORNER,1);
		   ObjectSet(objId,OBJPROP_XDISTANCE,x_offset);
		   ObjectSet(objId,OBJPROP_YDISTANCE,(iP+3)*y_depth);
		   ObjectSetText(objId,Pair,FontSize,FontName,FontColor);
         iP++;
      } // endif( iTime(Pair,0,0) != 0)
   } // endfor(start=0; start<Len_xPairs;)
   PairCount = iP;      // preserve the Pairs count

      // Create one signal object for each timeframe/pair combination
   for(iT=0; iT<TfCount; iT++)
   {
      Timeframe   = Timeframes[iT];
      
      for(iP=0; iP<PairCount; iP++)
      {
         Pair = Pairs[iP];
         
   	   x_offset = (TfCount-iT-1)*x_width + 1;      //pixels from RHS
			objId = objPrefix + Pair + Timeframe;
			ObjectCreate(objId,OBJ_LABEL,0,0,0);
 			ObjectSet(objId,OBJPROP_CORNER,1);
   		ObjectSet(objId,OBJPROP_XDISTANCE,x_offset);
			ObjectSet(objId,OBJPROP_YDISTANCE,(iP+3)*y_depth);
		   ObjectSetText(objId,"0",FontSize-2,FontName,FontColor);
      }//Next iP
         
   }//Next iT
   

   SetIndexBuffer(0,MA1_Buffer);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexLabel(0,"MA1");
   
   SetIndexBuffer(1,MA2_Buffer);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexLabel(1,"MA2");
      
}//endfunction init()






/**************************************************************************
 Cleanup function
 (just prior to this program shutting down)
**************************************************************************/
int deinit()
{
	for (int i = ObjectsTotal(); i >= 0; i--)
	{
		string objname = ObjectName(i);
		if (StringFind(objname, objPrefix, 0) > -1) ObjectDelete(objname);
   }//endfor (int i = ObjectsTotal(); i >= 0; i--)
}//endfunction deinit()






/**************************************************************************
 Main function
 (This bit happens at every tick)
**************************************************************************/
int start()
{
   /*
      // Reduce the run frequency (once per minute)
   int ThisMin = TimeMinute( TimeCurrent() );
   if( TimeStamp == ThisMin ) return;
   TimeStamp = ThisMin;
   */
   
   Trawl();       // Go looking for what you want
   
   MarkCurrentChart(); // Mark up the current chart
   
}//Endfunction start()







/**************************************************************************
 Trawl function
 Visit each timeframe and pair combination looking for
 our particular condition (eg a moving average cross-over)
//**************************************************************************/
void Trawl()
{
      // Set the bar index. At this stage, I am only looking at the most
      // recently completed bar (ie Bar[1])   
   int i = 1;
//i=2; //used for testing

      // Cycle thru timeframes   
   for(iT=0; iT<TfCount; iT++)
   {
      int Timeframe   = Timeframes[iT];

         // Cycle thru pairs
      for(iP=0; iP<PairCount; iP++)
      {
         string Pair = Pairs[iP];
         
         int result = Analyse(Pair, Timeframe, i);
         
            // Interpret the result
            // ====================
            
            // Presume no result
         string signal = CharToStr(167);  //Wingding 'nothing doing'
         color ShowColor = Khaki;         //Use a really bland color
         
            // Test for condition of interest
         if( result<0 )
         {
            signal=CharToStr(234);  //Wingding down-arrow
            ShowColor=Red;
         }
         if( result>0 )
         {
            signal=CharToStr(233);  //Wingding up-arrow
            ShowColor=Green;
         }

   	      // Change Signal Objects   
		   objId = objPrefix + Pair + Timeframe;
 		   ObjectSetText(objId,signal,FontSize-2,"Wingdings",ShowColor);
      
      }//next iP
         
   }//next iT

}






//**************************************************************************
// MarkCurrentChart function
//**************************************************************************
void MarkCurrentChart()
{
   int counted_bars=IndicatorCounted();
   if (counted_bars>0) counted_bars--; //---- the latest evaluated bar will be re-evaluated
   int limit = Bars-counted_bars;
   
   for(int i=limit; i>0; i--)
   {
      MA1_Buffer[i]=iMA(NULL,0,MA1Period,0,MODE_SMA,PRICE_CLOSE,i);
      MA2_Buffer[i]=iMA(NULL,0,MA2Period,0,MODE_SMA,PRICE_CLOSE,i);
   }  //Next i
   return;

}






//**************************************************************************
// analysis function
//**************************************************************************
int Analyse(string pair, int timeframe, int i)
{
   double MA1     = iMA(pair,timeframe,MA1Period,0,MODE_SMA,PRICE_CLOSE,1);
   double prevMA1 = iMA(pair,timeframe,MA1Period,0,MODE_SMA,PRICE_CLOSE,2);
   double MA2     = iMA(pair,timeframe,MA2Period,0,MODE_SMA,PRICE_CLOSE,1);
   double prevMA2 = iMA(pair,timeframe,MA2Period,0,MODE_SMA,PRICE_CLOSE,2);
   
   if(MA1>MA2 && prevMA1<prevMA2) return(1);
   if(MA2>MA1 && prevMA2<prevMA1) return(-1);
   return(0);
   
}//endfunction Analyse






//**************************************************************************
// Convert timeframe description to minutes
//**************************************************************************
int GetMinutes(string str)
{
   if( str == "M1" )   return(PERIOD_M1);
   if( str == "M5" )   return(PERIOD_M5);
   if( str == "M15" )  return(PERIOD_M15);
   if( str == "M30" )  return(PERIOD_M30);
   if( str == "H1" )   return(PERIOD_H1);
   if( str == "H4" )   return(PERIOD_H4);
   if( str == "D1" )   return(PERIOD_D1);
   if( str == "W1" )   return(PERIOD_W1);
   if( str == "MN" )   return(PERIOD_MN1);
   return(-1);
}//endfunction GetMinutes


