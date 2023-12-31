//+------------------------------------------------------------------+
//|                                                Quang_BB_3EMA.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Telegram\Telegram.mqh>
CCustomBot glbBotTelegram;
struct NgayThang
  {
   int          Ngay; // date
   int            Thang;  // bid price
   int            Nam;  // ask price
  };
NgayThang NgayHetHan={12,03,3022};
input string inpChannelName="@testmql4bot";//ID Kenh:
input string inpToken="1735772983:AAFn532QW457WhYRKszyONT1zznnCh_hORE";//Ma Token bot Telegram:
input double inpKhoiLuongCoSo=0.1;// Khoi luong ban dau(lots):
input double inpSL=50;// SL (pips):
input double inpTP=100;// TP (pips):
input double inpChoPhepTraling=false;// Co cho phép traiing khi cham dieu kien dong lenh:
input double inpDiemBatDauTrailing=50;// Diem bat dau traling (Pips):
input double inpDemNenLenhTiepTheo=14;// So nen cho lenh tiep theo:
input int inpDoDaiNenToiDaVaoLenh=100;//Do dai toi da cua nen vao lenh (pips):
input string EMA="THAM SO CUA EMA";// EMA:

input int inpMAPeriodShortBuy = 3;//MABUY (Short):
input ENUM_MA_METHOD inpMAMethodShortBuy = MODE_SMA;//MA Method Buy (Short):
input ENUM_APPLIED_PRICE inpAppliedPriceShortBuy=PRICE_LOW;// MA price type buy (Short):

input int inpMAPeriodShortSell = 3;//MASELL (Short):
input ENUM_MA_METHOD inpMAMethodShortSell = MODE_SMA;//MA Method sell (Short):
input ENUM_APPLIED_PRICE inpAppliedPriceShortSell=PRICE_HIGH;// MA price type sell (Short):

input int inpMAPeriodShort_Medium = 30;//MA2 (Short 2):
input ENUM_MA_METHOD inpMAMethodShort_Medium = MODE_EMA;//MA2 Method (Short2):
input ENUM_APPLIED_PRICE inpAppliedPriceShort_Medium=PRICE_CLOSE;// MA2 price type (Short2):

input int inpMAPeriodMedium=50;//MA (medium):
input ENUM_MA_METHOD inpMAMethodMedium = MODE_EMA;//MA Method (medium):
input ENUM_APPLIED_PRICE inpAppliedPriceMedium=PRICE_CLOSE;// MA price type (medium):

input int inpMAPeriodLong = 89;//MA (Long):
input ENUM_MA_METHOD inpMAMethodLong = MODE_EMA;//MA Method (Long):
input ENUM_APPLIED_PRICE inpAppliedPriceLong=PRICE_CLOSE;// MA price type (Long):
/////////THAM SO MO LENH MUA////////////////////////////////
input string BB_OpenBuy="THAM SO CUA BOLINGER BAND MO LENH MUA";// BOLINGER BAND:
input int inpPeriodBB=50;// 
input double  inpDeviationBB=2;
input int inpAppliedPriceBB=PRICE_CLOSE;
input int inpShiftBB=0;
/////////DICH SL KHI CHAM BB TREN HOẠC BB DUOI CUA CAC LENH////////////////////////////////
input string BB_ThamSoBoSung="THAM SO PIPS DỊCH SL KHI CHAM BB TREN HOẠC BB DUOI";// THAM SO BO SUNG:
input int inpSoPipLoiNhuanCanDatKhiChamBB=25;//Loi nhuan toi thieu dat duoc khi chạm BB (pips):
input int inpSoPipDichLenhVeKhiChamBB=20;//Diem Dich SL cua lenh ve khi cham BB(pips):

int glbTapLenh[100];

int glbTongLenh=0;
int glbSlippage=50;
int glbDemNenSell=0;// 
int glbDemNenBuy=0;
int glbLoaiLenhVaoGanNhat=0;//-1: Lenh gan nhat la sell; 1: Buy; 0: Chua co lenh nao
int glbTicket=-1;
string glbMessages="";
bool glbDaGuiTinNhanKhiCHamCanhBB=false;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
      glbBotTelegram.Token(inpToken);
      string msgTele=StringFormat("Cap Tien: %s\nKet noi MT4 va telegram Thanh cong.",Symbol());
      glbBotTelegram.SendMessage(inpChannelName,msgTele);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
      if(FunKiemTraSangNenMoiChua())
      {
         if(glbDemNenBuy>0 && glbTongLenh>0) glbDemNenBuy++;
         if(glbDemNenSell>0&& glbTongLenh>0)glbDemNenSell++;
         int KiemTraBuySell=FunKiemTraBuySell();
         if(KiemTraBuySell==1)// Thoa man dieu kien buy
         {
            //Neu laf lenh buy dau tien
            if(glbLoaiLenhVaoGanNhat==-1 ||glbLoaiLenhVaoGanNhat==0)
            {
               FunReset();
               Print("Vao lenh BUY dau tien theo xu huong moi");
               glbTicket=FunVaoLenh(OP_BUY);
               if(glbTicket>0)
               {
                  // Gui tin nhan ve tele
                  
                  // Cap nhat DL
                 
                  glbTapLenh[glbTongLenh]=glbTicket;
                  glbTongLenh++;
                  glbTicket=-1;
                  glbDemNenBuy=1;
                  glbLoaiLenhVaoGanNhat=1;
                  glbDemNenSell=0;
                   glbMessages=StringFormat("Cap Tien: %s\nLoaiLenh:BUY",Symbol());
                  glbBotTelegram.SendMessage(inpChannelName,glbMessages);
               }
            }
            else //Neu la lenh buy tiep theo can kiem tra dieu kien nen
            {
               
               if(glbDemNenBuy>inpDemNenLenhTiepTheo)
               {
                  Print("Vao lenh BUY tiep theo. SO nen Buy hien tai:",glbDemNenBuy );
                  glbTicket=FunVaoLenh(OP_BUY);
                  if(glbTicket>0)
                  {             
                     // Cap nhat DL
                     glbTapLenh[glbTongLenh]=glbTicket;
                     glbTongLenh++;
                     glbTicket=-1;
                     glbDemNenBuy=1;
                     glbMessages=StringFormat("Cap Tien: %s\nLoaiLenh:BUY",Symbol());
                     glbBotTelegram.SendMessage(inpChannelName,glbMessages);
                  }
               }
            }
         }
         else if(KiemTraBuySell==-1)
         {
            //Neu laf lenh sell dau tien
            if(glbLoaiLenhVaoGanNhat==1 ||glbLoaiLenhVaoGanNhat==0)
            {
               Print("Vao lenh SELL dau tien theo xu huong moi");
               glbTicket=FunVaoLenh(OP_SELL);
               if(glbTicket>0)
               {
                  // Cap nhat DL
                  glbTapLenh[glbTongLenh]=glbTicket;
                  glbTongLenh++;
                  glbTicket=-1;
                  glbDemNenSell=1;
                  glbLoaiLenhVaoGanNhat=-1;
                  glbDemNenBuy=0;
                  glbMessages=StringFormat("Cap Tien: %s\nLoaiLenh:SELL",Symbol());
                  glbBotTelegram.SendMessage(inpChannelName,glbMessages);
                  
               }
            }
            else //Neu la lenh buy tiep theo can kiem tra dieu kien nen
            {
               if(glbDemNenSell>inpDemNenLenhTiepTheo)
               {
                  Print("Vao lenh SELL tiep theo. SO nen SELL hien tai:",glbDemNenSell );
                  glbTicket=FunVaoLenh(OP_SELL);
                  if(glbTicket>0)
                  {
                     // Cap nhat DL
                     glbTapLenh[glbTongLenh]=glbTicket;
                     glbTongLenh++;
                     glbTicket=-1;
                     glbDemNenSell=1;
                     glbMessages=StringFormat("Cap Tien: %s\nLoaiLenh:SELL",Symbol());
                     glbBotTelegram.SendMessage(inpChannelName,glbMessages);
                  }
               }
            }
         }
         else
            Comment("Doi lenh. Kieu kien vao lenh:",FunKiemTraBuySell(),"\nDem nen buy:",glbDemNenBuy,"\nDemNenSell:",glbDemNenSell);
         
         
      }
      if(inpChoPhepTraling) FunTrailingStop();
      FunHamGuiThongBaoKhiDangCoLenhGiaChamBB();
      //xoa cac lenh da dong trong mang
       int i=0;
       while(i<glbTongLenh)
       {
         if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET))
         {
            if(OrderCloseTime()>0)
            {
               for(int j=i; j<=glbTongLenh-2; j++)
               {
      			   glbTapLenh[j] = glbTapLenh[j+1]; //Dịch các phần tử sang trái 1 vị trí
      			}
      		   glbTongLenh--; //Giảm số phần tử bớt 1
            }
            else i++;  
         }
       }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
 bool FunKiemTraSangNenMoiChua()
 {
   static datetime _LastBar=Time[0];
   //OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES);
   datetime currBar=Time[0];//iTime(OrderSymbol(),0,0);
   if(_LastBar!=currBar)
   {
      _LastBar=currBar;
      return true;
   }
   else return false;
 }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double FunTinhGiaTriMa(int MAperiod,int MA_Method,int MA_Applied_Price,int shift)
{
   return iMA(Symbol(),PERIOD_CURRENT,MAperiod,0,MA_Method,MA_Applied_Price,shift);
}
//+------------------------------------------------------------------+
 double FunTinhGiaTriBB(int PeriodBB, double DeviationBB, int AppliedPriceBB,int ModeUpOrLow, int shift=0)
 {
   //return iBands(Symbol(),0,inpPeriodBB,inpDeviationBB,0,inpAppliedPriceBB,ModeUpOrLow,shift);
   return iBands(Symbol(),0,PeriodBB,DeviationBB,0,AppliedPriceBB,ModeUpOrLow,shift);
 }
 
 int FunKiemTraBuySell()//-1: tin hieu Sell, 1: Tin hieu Buy
{
      // Kiem tra buy
      

      double _BBThap1=FunTinhGiaTriBB(inpPeriodBB,inpDeviationBB,inpAppliedPriceBB,MODE_LOWER,1);
       double _BBThap2=FunTinhGiaTriBB(inpPeriodBB,inpDeviationBB,inpAppliedPriceBB,MODE_LOWER,2);
      double _BBCao1=FunTinhGiaTriBB(inpPeriodBB,inpDeviationBB,inpAppliedPriceBB,MODE_UPPER,1); 
       double _BBCao2=FunTinhGiaTriBB(inpPeriodBB,inpDeviationBB,inpAppliedPriceBB,MODE_UPPER,2); 
       
      double _MAShort1Buy=FunTinhGiaTriMa(inpMAPeriodShortBuy,inpMAMethodShortBuy,inpAppliedPriceShortBuy,1);
      double _MAShort2Buy=FunTinhGiaTriMa(inpMAPeriodShortBuy,inpMAMethodShortBuy,inpAppliedPriceShortBuy,2);
      
      double _MAShort1Sell=FunTinhGiaTriMa(inpMAPeriodShortSell,inpMAMethodShortSell,inpAppliedPriceShortSell,1);
      double _MAShort2Sell=FunTinhGiaTriMa(inpMAPeriodShortSell,inpMAMethodShortSell,inpAppliedPriceShortSell,2);
      
      double _MAShort_Medium=FunTinhGiaTriMa(inpMAPeriodShort_Medium,inpMAMethodShort_Medium,inpAppliedPriceShort_Medium,1);
      double _MALong=FunTinhGiaTriMa(inpMAPeriodLong,inpMAMethodLong,inpAppliedPriceLong,1);
      double _MAMedium=FunTinhGiaTriMa(inpMAPeriodMedium,inpMAMethodMedium,inpAppliedPriceMedium,1);
      // Kiem tra buy
      if(_MAShort2Buy<=_BBThap2 && _MAShort1Buy>=_BBThap1 && FunTinhSoPipDoDaiCuaNen(1)<inpDoDaiNenToiDaVaoLenh) // Duong ma
      {
            Print("MA 3 cat len BB");
            if(_MAShort_Medium>_MAMedium && _MAMedium>_MALong)
            {
               Print("THOA MAN DIEU KIEN BUY");
               ArrowSellCreate(0,"ArrowBuy_"+(string)1,0,0,High[1],clrBlueViolet);
               return 1;
            }
      }
      
      if(_MAShort2Sell>=_BBCao2 && _MAShort1Sell<=_BBCao1 && FunTinhSoPipDoDaiCuaNen(1)<inpDoDaiNenToiDaVaoLenh) 
      {
         Print("MA 3 cat xuong BB");
         if(_MAShort_Medium < _MAMedium && _MAMedium<_MALong)
         {
            Print("THOA MAN DIEU KIEN SELL");
            ArrowSellCreate(0,"ArrowSell_"+(string)1,0,0,High[1],clrYellow);
            return -1;    
         }
      }
      return 0;
   
}
//+------------------------------------------------------------------+

int FunVaoLenh(int LoaiLenh)
{
   int _ticket=-1;
   double _KhoiLuongVaoLenh=inpKhoiLuongCoSo;
   if(LoaiLenh==OP_BUY)
   {
      _ticket= OrderSend(Symbol(),OP_BUY,_KhoiLuongVaoLenh,Ask,glbSlippage,Bid-inpSL*10*Point,Bid+inpTP*10*Point,"EAB uy",0,0,clrBlue);
   }
   else if(LoaiLenh==OP_SELL)
   {
      _ticket= OrderSend(Symbol(),OP_SELL,_KhoiLuongVaoLenh,Bid,glbSlippage,Bid+inpSL*10*Point,Bid-inpTP*10*Point,"EA Sell",0,0,clrRed);
   }
   if(_ticket==-1) Print("Loi vao lenh");
   return _ticket;
   
}
//+------------------------------------------------------------------+

void FunReset()
{
   ArrayFill(glbTapLenh,0,99,-1);

   glbTongLenh=0;
   glbDemNenSell=0;// 
   glbDemNenBuy=0;
    glbDaGuiTinNhanKhiCHamCanhBB=false;
}

//+------------------------------------------------------------------+
void FunTrailingStop()
{
   for(int i=0;i<glbTongLenh;i++)
   {
      if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES))
      {
         if(OrderType()==OP_BUY)
         {
            if(((Bid-OrderOpenPrice())/Point)>(inpDiemBatDauTrailing*10)&& (OrderStopLoss()==0||OrderStopLoss()<(Bid-(inpDiemBatDauTrailing*10)*Point)))
            {
   
               if(OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid-(inpDiemBatDauTrailing*10)*Point,Digits),OrderTakeProfit(),0,clrNONE))
               {
                 ;
               }
               else
               {
                  Print("Loi modify lenh BUY: ",Bid-(inpDiemBatDauTrailing*10)*Point," ",GetLastError());
               }            
            } 
         }
         else
         {
            if(((OrderOpenPrice()-Ask)/Point)>(inpDiemBatDauTrailing*10)&& (OrderStopLoss()==0|| OrderStopLoss()>((inpDiemBatDauTrailing*10)*Point+Ask)))
            {
   
               if(OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble((inpDiemBatDauTrailing*10)*Point+Ask,Digits),OrderTakeProfit(),0,clrNONE))
               {
                  ;
               }
               else
               {
                  Print("Loi modify lenh SELL: ",Ask+(inpDiemBatDauTrailing*10)*Point,"  ", GetLastError());
               }              
            } 
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Create Sell sign                                                 |
//+------------------------------------------------------------------+
bool ArrowSellCreate(const long            chart_ID=0,        // chart's ID
                     const string          name="ArrowSell",  // sign name
                     const int             sub_window=0,      // subwindow index
                     datetime              time=0,            // anchor point time
                     double                price=0,           // anchor point price
                     const color           clr=C'225,68,29',  // sign color
                     const ENUM_LINE_STYLE style=STYLE_SOLID, // line style (when highlighted)
                     const int             width=1,           // line size (when highlighted)
                     const bool            back=false,        // in the background
                     const bool            selection=false,   // highlight to move
                     const bool            hidden=true,       // hidden in the object list
                     const long            z_order=0)         // priority for mouse click
  {
//--- set anchor point coordinates if they are not set
   ChangeArrowEmptyPoint(time,price);
//--- reset the error value
   ResetLastError();
//--- create the sign
   if(!ObjectCreate(chart_ID,name,OBJ_ARROW_SELL,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": failed to create \"Sell\" sign! Error code = ",GetLastError());
      return(false);
     }
//--- set a sign color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set a line style (when highlighted)
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set a line size (when highlighted)
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the sign by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
  void ChangeArrowEmptyPoint(datetime &time,double &price)
  {
//--- if the point's time is not set, it will be on the current bar
   if(!time)
      time=TimeCurrent();
//--- if the point's price is not set, it will have Bid value
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
  }
  //+------------------------------------------------------------------+
//+------------------------------------------------------------------+
string FunTenLoaiLenhDangVao(int LoaiLenh)
{
   if(LoaiLenh==0)return "OP_BUY";
   else if(LoaiLenh==1) return "OP_SELL";
   else return IntegerToString(LoaiLenh);
}

void FunHamGuiThongBaoKhiDangCoLenhGiaChamBB()
{
   // Nếu là lệnh buy.. gia chạm BB trên làm 2 việc
   /*
   + Nếu đang dương >200 point dịch SL về + 200 point
   + nếu đang dương, âm < 200 point thi không làm gì
   + gửi tin nhắn về telegram
   */
   if(glbTongLenh>0)
   {
      // Kieerm tra xem gia co cat BB khong
      
      double _BBThap=FunTinhGiaTriBB(inpPeriodBB,inpDeviationBB,inpAppliedPriceBB,MODE_LOWER,0);
      double _BBCao=FunTinhGiaTriBB(inpPeriodBB,inpDeviationBB,inpAppliedPriceBB,MODE_UPPER,0); 
      if(Low[0]<=_BBCao && High[0]>=_BBCao) // Nen cat canh tren cua BB
      {
         if(glbDaGuiTinNhanKhiCHamCanhBB==true) return;
         for(int i=0;i<glbTongLenh; i++)
         {
            OrderSelect(glbTapLenh[i],SELECT_BY_TICKET);
            if(OrderType()==OP_BUY)
            {
               double SoPipLoiLoHienTai=FunCountProfitPoints(OrderTicket())/10;
               double GiaDichSL=OrderOpenPrice()+inpSoPipDichLenhVeKhiChamBB*10*Point();
               if(SoPipLoiLoHienTai>=inpSoPipLoiNhuanCanDatKhiChamBB && OrderStopLoss()<GiaDichSL)
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),GiaDichSL,OrderTakeProfit(),0,clrNONE);
                  Print("Dich SL lenh buy do cham BB tren. Ticket=",OrderTicket());
               }
               string msg=StringFormat("GIA CHAM CANH BB TREN. DICH SL CHO TICKET LENH BUY:%d",OrderTicket());
               glbBotTelegram.SendMessage(inpChannelName,msg);
                
            }
         }
         glbDaGuiTinNhanKhiCHamCanhBB=true;
         return;
      }
      if (Low[0]<=_BBThap && High[0]>=_BBThap)
      {
         if(glbDaGuiTinNhanKhiCHamCanhBB==true) return;
         for(int i=0;i<glbTongLenh; i++)
         {
            OrderSelect(glbTapLenh[i],SELECT_BY_TICKET);
            if(OrderType()==OP_SELL)
            {
               double SoPipLoiLoHienTai=FunCountProfitPoints(OrderTicket())/10;
               double GiaDichSL=OrderOpenPrice()-inpSoPipDichLenhVeKhiChamBB*10*Point();
               if(SoPipLoiLoHienTai>=inpSoPipLoiNhuanCanDatKhiChamBB && OrderStopLoss()>GiaDichSL)
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),GiaDichSL,OrderTakeProfit(),0,clrNONE);
                  Print("Dich SL lenh buy do cham BB duoi. Ticket=",OrderTicket());
               }
               string msg=StringFormat("GIA CHAM CANH BB TREN. DICH SL CHO TICKET LENH SELL:%d",OrderTicket());
               glbBotTelegram.SendMessage(inpChannelName,msg);
                
            }
         }
         glbDaGuiTinNhanKhiCHamCanhBB=true;
         return;
      }
      glbDaGuiTinNhanKhiCHamCanhBB=false;
   }
}

 
 //+------------------------------------------------------------------+
//+------------------------------------------------------------------+
 double FunCountProfitPoints(int TichKet)
 {
      double SoPointLoiLoHienTai=0; 
      if( OrderSelect( TichKet,SELECT_BY_TICKET,MODE_TRADES))
         {
            if(OrderType()==OP_BUY)
            {
               SoPointLoiLoHienTai=(Bid -OrderOpenPrice())/Point;
            }
            else if(OrderType()==OP_SELL)
            {
               SoPointLoiLoHienTai=(OrderOpenPrice()-Ask)/Point;
            }
         }      
      return NormalizeDouble(SoPointLoiLoHienTai,2);
 }
 double FunTinhSoPipDoDaiCuaNen(int index) 
 {
   return (High[index]-Low[index])/(10*Point());
 }