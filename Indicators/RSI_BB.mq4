//------------------------------------------------------------------
#property copyright ""
#property description " "
#property link      ""
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 CLR_NONE
#property indicator_color3 LimeGreen
#property indicator_color4 LimeGreen
#property indicator_style2 STYLE_DOT

//
//
//
//
//

extern int    RsiLength  = 14;
extern int    RsiPrice   = PRICE_CLOSE;
extern int    HalfLength = 50;
extern int    DevPeriod  = 50;
extern double Deviations = 2;
extern bool   UseAlert   = false;
extern bool   DrawArrows = false;

double buffer1[];
double buffer2[];
double buffer3[];
double buffer4[];

//------------------------------------------------------------------
////| //---------tham số giới hạn sử dụng EA ----------------------------------------


    bool chi_chay_demo=false;
    int tai_khoan_gioi_han=0;
    bool gioi_han_thoi_gian=false;
    datetime han_su_dung=D'';  //cấu trúc D'năm.tháng.ngày giờ:phút'   
//------------------------------------------------------------------
//
//
//
//

int init()
{
   HalfLength=MathMax(HalfLength,1);
         SetIndexBuffer(0,buffer1); 
         SetIndexBuffer(1,buffer2);
         SetIndexBuffer(2,buffer3); 
         SetIndexBuffer(3,buffer4);
   return(0);
}
int deinit() 
{
  DellObj(PrefixArrow);
  
 return(0); 
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int start()
{

   if(chi_chay_demo)
   if(!IsTesting() && !IsDemo()) {Alert(""); return(0);}
   if(tai_khoan_gioi_han>0)
   if(AccountNumber()!=tai_khoan_gioi_han) {Alert(""); return(0);}
   if(gioi_han_thoi_gian && TimeCurrent()>=han_su_dung)
   {Alert(""); return(0);}
   
   //-------------------------------------------------------------------
   int i,j,k,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=MathMin(Bars-1,Bars-counted_bars+HalfLength);

   //
   //
   //
   //
   //
   static datetime timeLastAlert = NULL;
   
   for (i=limit; i>=0; i--) buffer1[i] = iRSI(NULL,0,RsiLength,RsiPrice,i);
   for (i=limit; i>=0; i--)
   {
      double dev  = iStdDevOnArray(buffer1,0,DevPeriod,0,MODE_SMA,i);
      double sum  = (HalfLength+1)*buffer1[i];
      double sumw = (HalfLength+1);
      for(j=1, k=HalfLength; j<=HalfLength; j++, k--)
      {
         sum  += k*buffer1[i+j];
         sumw += k;
         if (j<=i)
         {
            sum  += k*buffer1[i-j];
            sumw += k;
         }
      }
      buffer2[i] = sum/sumw;
      buffer3[i] = buffer2[i]+dev*Deviations;
      buffer4[i] = buffer2[i]-dev*Deviations;
      
      if( buffer1[i] >= buffer3[i] /*&& buffer1[i+1] < buffer3[i+1]*/ )
      { 
         if( DrawArrows ) ArrowDn(Time[i], High[i]);
         
         if( UseAlert && i == 0 && Time[0] != timeLastAlert )
         {
            Alert(" UP ! - "+Symbol()+" - HILL - "+convert(Period()));
            timeLastAlert = Time[0];
         }
      }
      
      if( buffer1[i] <= buffer4[i] /*&& buffer1[i+1] > buffer4[i+1] */)
      { 
         if( DrawArrows ) ArrowUp(Time[i], Low[i]);

         if( UseAlert && i == 0 && Time[0] != timeLastAlert )
         {
            Alert(" DOWN ! - "+Symbol()+" - HILL - "+convert(Period()));
            timeLastAlert = Time[0];
         }         
      }
   }
   return(0);
}


    color ColorDn = Crimson;
 color ColorUp = DodgerBlue;
  int     CodDn = 226;
  int     CodUp = 225;
 extern int      Sise = 11;
  string   Font = "Verdana";
 
// ti init() if(ObjectFind("100s")<0)GetText(3,"100s","BuySell Pro",LawnGreen,5,5,7); 
 
 
string PrefixArrow = "ArrowsHill"; 
//+==================================================================+
//+==================================================================+
void ArrowUp(datetime tim,double pr)
{if(ObjectFind(PrefixArrow+"TextUp"+tim)==-1)
 {if(ObjectCreate(PrefixArrow+"TextUp"+tim,OBJ_TEXT,0,tim,pr-GetDistSdvig()))
  ObjectSetText(PrefixArrow+"TextUp"+tim,CharToStr(CodUp),Sise,"WingDings",ColorUp);
 }
}

//+==================================================================+
//+==================================================================+
void ArrowDn(datetime tim,double pr)
{if(ObjectFind(PrefixArrow+"TextDn"+tim)==-1)
 {if(ObjectCreate(PrefixArrow+"TextDn"+tim,OBJ_TEXT,0,tim,pr+GetDistSdvig()))
  ObjectSetText(PrefixArrow+"TextDn"+tim,CharToStr(CodDn),Sise,"WingDings",ColorDn);
 }
}
extern double TextSdvigMnoj = 0.5;
double GetDistSdvig(){  return( iATR(NULL, 0,100, 1) * TextSdvigMnoj); }
//+------------------------------------------------------------------+
//
void DellObj( string dell )
{
  string name;
   for(int i = ObjectsTotal()-1 ; i >=0 ; i-- ){
      name = ObjectName(i);
      if( StringFind(name, dell) != EMPTY )
         ObjectDelete(name);
   }
}


string convert(int itf)
{
   switch (itf)
   {
      case 1: return("M1");
      case 5: return("M5");
      case 15: return("M15");
      case 30: return("M30");
      case 60: return("H1");
      case 240: return("H4");
      case 1440: return("D1");
      case PERIOD_W1: return("W1");
      case PERIOD_MN1: return("MN");
      default: return("?");
      
   };
}