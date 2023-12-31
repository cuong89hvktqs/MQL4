//+------------------------------------------------------------------+
//|                                           Qunag_BB_DaKhungTF.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
/*
*/
input string inpChannelName="@testmql4bot";//ID Kenh:
input string inpToken="1958439508:AAEMEKme2M9oX4aUyfPexA3h5C2N76sZziU";//Ma Token bot Telegram:
input ENUM_TIMEFRAMES inpKhungTinHieu=PERIOD_H4;// Khung tin hieu gia cat EMA:
input ENUM_TIMEFRAMES inpKhungVaoLenh=PERIOD_H1;// Khung vao lenh:
input double inpKhoiLuong=0.01;//Khoi luong vao lenh:
input int inpTP=200;//TP (pips):
input int inpSL=100;//SL (pips);
input int inpTrailingStop=50;// Trailing stop (pips):
input int inpSoNenVaoLenhTiep=14;// So nen vao lenh tiep theo:
input int inpMaTrungBinh=50;//MA Trung binh:
input int inpMaDai=200;//MA dai:
input ENUM_MA_METHOD inpMAKieu=MODE_EMA;//Loai MA:
input ENUM_APPLIED_PRICE inpMAGia=PRICE_CLOSE;// Gia tinh MA;
input int inpBB=20;// Kieu BB:
input ENUM_APPLIED_PRICE inpBBGia=PRICE_CLOSE;
input double inpBBDevitation=2;//BB devitation:
input int inpMagicNumber=123;// Magic number:
input int inpSlippage=50;//Slippage (points):
int glbTongLenh=0;
int glbTapLenh[100];
int glbDemNenVaoLenh=0;
int glbLoaiLenhDangVao=-1;
datetime glbTimeVaoLenh;// Moi nen chi co 1 lenh
string glbMessages="";
bool glbDaVaoLenh=false;// Khi ma50 cat ma 200 chi vao 1 lenh buy hoac sell duy nhat
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
      Print(Time[0]);
      glbTimeVaoLenh=Time[1];
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
   
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

double FunTinhMaValue(int MAPeriod, ENUM_TIMEFRAMES tf)
{
   return iMA(Symbol(),tf,MAPeriod,0,inpMAKieu,inpMAGia,0);
}

double FunTinhBBValueUpper(int BBPeriod)
{
   return iBands(Symbol(),0,inpBB,inpBBDevitation,0,inpBBGia,MODE_UPPER,0);
}

double FunTinhBBValueLow(int BBPeriod)
{
   return iBands(Symbol(),0,inpBB,inpBBDevitation,0,inpBBGia,MODE_LOWER,0);
}

//+------------------------------------------------------------------+
//-----------------------------------------Đặt lệnh-----------------------------------------
 int FunVaoLenh(int LoaiLenh, double DiemVaoLenh,double StopLossPips, double TakeProfitPips, double KhoiLuongVaoLenh)
{
    int Ticket=-1;
    double StopLoss=0,TakeProfit=0;
    if(KhoiLuongVaoLenh==0) return -1;
    
    if(LoaiLenh==OP_BUY || LoaiLenh==OP_BUYLIMIT || LoaiLenh==OP_BUYSTOP)
    {
       StopLoss=DiemVaoLenh-StopLossPips*10*Point();
       TakeProfit=DiemVaoLenh+TakeProfitPips*10*Point();  
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,"Vao lenh Buy",inpMagicNumber,0,clrBlue);
    }
    if(LoaiLenh==OP_SELL|| LoaiLenh==OP_SELLLIMIT || LoaiLenh==OP_SELLSTOP)
    {
      StopLoss=DiemVaoLenh+StopLossPips*10*Point();
       TakeProfit=DiemVaoLenh-TakeProfitPips*10*Point();  
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,"Vao lenh Sell",inpMagicNumber,0,clrRed);
    }
    return Ticket;
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

void FunDongTatCaCacLenh()
{
   while(glbTongLenh>0)
   {
      if(OrderSelect(glbTapLenh[glbTongLenh-1],SELECT_BY_TICKET,MODE_TRADES))
      {
         if(OrderType()==OP_BUY)
         {
            if(OrderClose(OrderTicket(),OrderLots(),Bid,inpSlippage,clrNONE))
            {
                glbMessages=StringFormat("Cap tien: %s\n\nHanh dong: DONG LENH\nTicket=%d \nLoi nhuan: %0.2f",OrderSymbol(),OrderTicket(),OrderProfit());
                glbBotTelegram.SendMessage(inpChannelName,glbMessages);
                glbTongLenh--;
            }
         }
         else
         {
            if(OrderClose(OrderTicket(),OrderLots(),Ask,inpSlippage,clrNONE))
            {
               glbMessages=StringFormat("Cap tien: %s\nHanh dong: DONG LENH\nTicket=%d \nLoi nhuan: %0.2f",OrderSymbol(),OrderTicket(),OrderProfit());
               glbBotTelegram.SendMessage(inpChannelName,glbMessages); 
               glbTongLenh--;
            }
         }   
      }
   }
   glbDemNenVaoLenh=0;
   glbLoaiLenhDangVao=-1;
   ArrayFill(glbTapLenh,0,100,0);
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
 bool FunKiemTraSangNenMoiChuaKhungTinHieu()
 {
   static datetime _LastBar=iTime(Symbol(),inpKhungTinHieu,0);
   //OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES);
   datetime currBar=iTime(Symbol(),inpKhungTinHieu,0);//iTime(OrderSymbol(),0,0);
   if(_LastBar!=currBar)
   {
      _LastBar=currBar;
      return true;
   }
   else return false;
 }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
 bool FunKiemTraSangNenMoiChuaKhungVaoLenh()
 {
   static datetime _LastBarKhungVaoLenh=iTime(Symbol(),inpKhungVaoLenh,0);
   //OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES);
   datetime currBarKhungVaoLenh=iTime(Symbol(),inpKhungVaoLenh,0);//iTime(OrderSymbol(),0,0);
   if(_LastBarKhungVaoLenh!=currBarKhungVaoLenh)
   {
      _LastBarKhungVaoLenh=currBarKhungVaoLenh;
      return true;
   }
   else return false;
 }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+ 
 void FunKiemTraLenhChamSLTP()
 {
   for(int i=0;i<glbTongLenh;i++)
   {
      if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET))
      {
         if(OrderCloseTime()>0)
         {
            glbMessages=StringFormat("Cap tien: %s\nHanh dong: DONG LENH.\nTicket=%d\nLoi nhuan: %0.2f",OrderSymbol(),OrderTicket(),OrderProfit());
            glbBotTelegram.SendMessage(inpChannelName,glbMessages);
            glbTapLenh[i]=0;
            for(int j=i+1;j<glbTongLenh;j++)
            {
               int Tam=glbTapLenh[j-1];
               glbTapLenh[j-1]=glbTapLenh[j];
               glbTapLenh[j]=Tam;
            }
            glbTongLenh--;
         }
      }
   }
   if(glbTongLenh==0)
   {
      glbDemNenVaoLenh=0;
      glbLoaiLenhDangVao=-1;
   }
 }
 
 void FunKiemTraLenhTrailingStop()
 {
    for(int i=0;i<glbTongLenh;i++)
   {
          FunTrailingStopTicket( glbTapLenh[i]);
   }
 }
 
 void FunTrailingStopTicket(int ticket)
{
   if(inpTrailingStop<=0) return;
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
      {    
         double DiemTrailingStop=inpTrailingStop*10;
         double SoPointLoiLo=FunCountProfitPoints(OrderTicket());
         if (SoPointLoiLo>DiemTrailingStop)
         {
            double StopLoss=0;
            if(OrderType()==1)//lệnh sell
            {
            
               StopLoss=Bid+ DiemTrailingStop*Point;
               if(OrderStopLoss()>StopLoss && StopLoss<OrderOpenPrice())
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),StopLoss,OrderTakeProfit(),0,clrNONE))
                     Print("Trailing stop lenh SELL that bai");            
            }
            else if(OrderType()==0)// Lệnh buy
            {
               StopLoss=Bid-DiemTrailingStop*Point;
               if(OrderStopLoss()<StopLoss &&StopLoss>OrderOpenPrice())
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),StopLoss,OrderTakeProfit(),0,clrNONE))
                     Print("Trailing stop lenh BUY that bai");               
            }
         }
         
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
 

bool FunKiemTraDieuKienDognLenhTheoMA(int LoaiLenh)// True: Thoa man dieu kien dong lenh, false khong thoa man
{
  
   double ma50_0=iMA(Symbol(),0,inpMaTrungBinh,0,inpMAKieu,inpMAGia,0);
   double ma50_1=iMA(Symbol(),0,inpMaTrungBinh,0,inpMAKieu,inpMAGia,1);
   double ma200_1=iMA(Symbol(),0,inpMaDai,0,inpMAKieu,inpMAGia,1);
    double ma200_0=iMA(Symbol(),0,inpMaDai,0,inpMAKieu,inpMAGia,0);
   //  Print("Kiem tra dong lenh buy sell");
    if(LoaiLenh==OP_BUY)
    {
      if(ma50_0<ma200_0 && ma50_1>=ma200_1) return true;
      else return false;
    }
    else if(LoaiLenh==OP_SELL)
    {
      if(ma50_0>ma200_0 && ma50_1<=ma200_1) return true;
      else return false;
    }
    else return false;
}

void FunKiemGiaoCatMA50VaMA200KhungLon()// True: Thoa man dieu kien dong lenh, false khong thoa man
{
  
   double ma50_0=iMA(Symbol(),0,inpMaTrungBinh,0,inpMAKieu,inpMAGia,0);
   double ma50_1=iMA(Symbol(),0,inpMaTrungBinh,0,inpMAKieu,inpMAGia,1);
   double ma200_1=iMA(Symbol(),0,inpMaDai,0,inpMAKieu,inpMAGia,1);
    double ma200_0=iMA(Symbol(),0,inpMaDai,0,inpMAKieu,inpMAGia,0);
   //  Print("Kiem tra dong lenh buy sell");
      if(ma50_0<ma200_0 && ma50_1>=ma200_1) 
      {
         glbBotTelegram.SendMessage(inpChannelName,"Cap tien: "+ Symbol()+"\nMA50 cat xuong MA200.");
         glbDaVaoLenh=false;
         return ;
      }
      if(ma50_0>ma200_0 && ma50_1<=ma200_1) 
      {
         glbBotTelegram.SendMessage(inpChannelName,"Cap tien: "+ Symbol()+"\nMA50 cat len MA200.");
         glbDaVaoLenh=false;
         return ;
      }
    
}