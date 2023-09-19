//+------------------------------------------------------------------+
//|                                                         Test.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "VIET BOT THEO YEU CAU, Website: tailieuforex.com, SDT: 0971 926 248"
#property link      "https://www.tailieuforex.com"
#property version   "1.00"
#property strict
#include <Telegram\Telegram.mqh>
input string inpChannelName="@botnvc89";//ID Kenh:
input string inpToken="1958439508:AAEMEKme2M9oX4aUyfPexA3h5C2N76sZziU";//Ma Token bot Telegram:
input double inpKhoiLuong=0.01;//Khoi luong vao lenh:
input int inpTP=50;//TP (pips):
input int inpSL=50;//SL (pips);
input int inpTrailingStop=20;// Trailing stop (pips):
input string str="CAI DAT THAM SO INDICATOR";// CAI DAT THAM SO CUSTUM INDICATOR RSI_BB
input int inpRSILenght=14;//RsiLength:
input int inpRSIPrice=0;//RSIPrice:
input int inpHalfLength=50;//HalfLength:
input int inpDevPeriod=50;//DevPeriod:
input double inpDeviations=2.0;//Deviations:
//input int inpSise=11;//Sise:

input double inpStartTime=8;// Thoi Gian Bat Dau vao lenh (Server time):
input double inpEndTime=22;// Thoi Gian Ket Thuc vao lenh(Server time):
input int inpSlippage=50;// Do truot gia (slippage):
input int inpMagicNumber=123;// Magic number:
CCustomBot glbBotTelegram;

int glbTongLenh=0;
int glbTapLenh[200];
int glbKieuLenhDangVao;
string glbMSg;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    glbBotTelegram.Token(inpToken);
    string msgTele=StringFormat("Bot Cap Tien: %s\nKet noi MT4 va telegram Thanh cong.",Symbol());
    glbBotTelegram.SendMessage(inpChannelName,msgTele);  
    if(glbTongLenh==0)  FunKhoiTaoBot();
  return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{

   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   if(FunKiemTraSangNenMoiChua())
   {
      int TinHieu=FunKiemTraDieuKienVaoLenh();
      FunXuLyVaoLenh(TinHieu);
   }
   if(glbTongLenh>0)
   {
      for (int i = 0; i < glbTongLenh; i++)
      {
         if(inpTrailingStop>0) FunTrailingStopTicket(glbTapLenh[i],inpTrailingStop);
         if(!OrderSelect(glbTapLenh[i],SELECT_BY_TICKET))continue;
         if(OrderCloseTime()>0)
         {
            Print("DONG LENH DO CHAM SL HOAC TP");
            for(int j=i;j<glbTongLenh-1;j++)
            {
               glbTapLenh[j]=glbTapLenh[j+1];
            }
            glbTongLenh--;
            string s=StringFormat("Cap tien: %s\nDONG LENH: %s\nTicket: %d\nPROFIT: %0.2f",OrderSymbol(),FunTraVeTenLenh(OrderType()),OrderTicket(),OrderProfit());
            glbBotTelegram.SendMessage(inpChannelName,s);
         }
      }  
      Comment("Tong lenh dang co: ",glbTongLenh, "\nLoai lenh dang vao: ",FunTraVeTenLenh(glbKieuLenhDangVao));
   }
   else Comment("Doi lenh");
}
//+------------------------------------------------------------------+
void FunXuLyVaoLenh(int TinHieu)
{
   if(TinHieu<0)return;
   if(TinHieu!=glbKieuLenhDangVao && glbTongLenh>0)
   {
      Print("DONG LEH DO DOI XU HUONG");
      FunDongTatCaCacLenh();
      glbTongLenh=0;
   }
   int Ticket=FunVaoLenh(TinHieu, Ask,inpSL,inpTP,inpKhoiLuong,glbTongLenh+1);
   if(Ticket>0)
   {
      glbTapLenh[glbTongLenh]=Ticket;
      glbTongLenh++;
      glbKieuLenhDangVao=TinHieu;
      OrderSelect(Ticket,SELECT_BY_TICKET);
      glbMSg="Cap tien: "+Symbol()+"\nKhung Trade: "+FunTenTimeFrame()+"\nHanh dong: "+OrderComment()+"\nTicket: "+IntegerToString(Ticket);
      glbBotTelegram.SendMessage(inpChannelName,glbMSg);
   }
}
//+------------------------------------------------------------------+
void FunKhoiTaoBot()
{
   for (int i = 0; i < OrdersTotal(); i++)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue;
      if(OrderSymbol()==Symbol() && OrderType()<=1 && OrderMagicNumber()>0)
      {
         glbTapLenh[glbTongLenh]=OrderTicket();
         glbTongLenh++;
         if(glbTongLenh==1) glbKieuLenhDangVao=OrderType();
      }
   }
}
//+------------------------------------------------------------------+
int FunKiemTraDieuKienVaoLenh()
{
    double RSI_1,RSI_2,BBTren_1,BBTren_2,BBDuoi_1,BBDuoi_2;;
    RSI_1=iCustom(Symbol(),PERIOD_CURRENT,"RSI_BB.ex4",inpRSILenght,inpRSIPrice,inpHalfLength,inpDevPeriod,inpDeviations,false,false,11,0.5,0,1);
    RSI_2=iCustom(Symbol(),PERIOD_CURRENT,"RSI_BB.ex4",inpRSILenght,inpRSIPrice,inpHalfLength,inpDevPeriod,inpDeviations,false,false,11,0.5,0,2);

    BBTren_1=iCustom(Symbol(),PERIOD_CURRENT,"RSI_BB.ex4",inpRSILenght,inpRSIPrice,inpHalfLength,inpDevPeriod,inpDeviations,false,false,11,0.5,2,1);
    BBTren_2=iCustom(Symbol(),PERIOD_CURRENT,"RSI_BB.ex4",inpRSILenght,inpRSIPrice,inpHalfLength,inpDevPeriod,inpDeviations,false,false,11,0.5,2,2);

    BBDuoi_1=iCustom(Symbol(),PERIOD_CURRENT,"RSI_BB.ex4",inpRSILenght,inpRSIPrice,inpHalfLength,inpDevPeriod,inpDeviations,false,false,11,0.5,3,1);
    BBDuoi_2=iCustom(Symbol(),PERIOD_CURRENT,"RSI_BB.ex4",inpRSILenght,inpRSIPrice,inpHalfLength,inpDevPeriod,inpDeviations,false,false,11,0.5,3,2);

    if(RSI_1<BBTren_1 && RSI_2>BBTren_2) return 1;//Tin hieu SELL
    if(RSI_1>BBDuoi_1 && RSI_2<BBDuoi_2) return 0;
    return -1;
}


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

//+*-----------------------------------------------------------------+
void FunDongTatCaCacLenh()
{
   while(glbTongLenh>0)
   {
      if(OrderSelect(glbTapLenh[glbTongLenh-1],SELECT_BY_TICKET))
      {
         if(OrderCloseTime()>0)
         {
            glbTapLenh[glbTongLenh-1]=-1;
            glbTongLenh--;
            string s=StringFormat("Cap tien: %s\nDONG LENH: %s\nTicket: %d\nPROFIT: %0.2f",Symbol(),FunTraVeTenLenh(OrderType()),OrderTicket(),OrderProfit());
            glbBotTelegram.SendMessage(inpChannelName,s);
         }
         else
         {
            if(OrderType()==OP_BUY)
            {
               if(!OrderClose(OrderTicket(),OrderLots(),Bid,500,clrBlue))
               {
                  Print(Symbol(),": Loi dong lenh Buy");
                  glbBotTelegram.SendMessage(inpChannelName,StringFormat("Cap tien: %s\nLOI KHI DONG LENH BUY: ERROR",Symbol()));   
               }
               else 
               {  glbTapLenh[glbTongLenh-1]=-1;glbTongLenh--;
                  string s=StringFormat("Cap tien: %s\nDONG LENH: %s\nTicket: %d \nPROFIT: %0.2f",Symbol(),FunTraVeTenLenh(OrderType()),OrderTicket(),OrderProfit());
                  glbBotTelegram.SendMessage(inpChannelName,s);
               }
                  
            }
            else if(OrderType()==OP_SELL)
            {
               if(!OrderClose(OrderTicket(),OrderLots(),Ask,500,clrRed))
               {
                  Print(Symbol(),":Loi dong lenh Sell");
                  glbBotTelegram.SendMessage(inpChannelName,StringFormat("Cap tien: %s\n LOI KHI DONG LENH SELL: ERROR",Symbol()));   
               }
               else 
               {  
                  glbTapLenh[glbTongLenh-1]=-1;glbTongLenh--;
                  //glbTongLoiLoCuaTatCaCacChuKy+=OrderProfit()+OrderCommission()+OrderSwap(); 
                  string s=StringFormat("Cap tien: %s\nDONG LENH %s\nTicket: %d\nPROFIT: %0.2f",Symbol(),FunTraVeTenLenh(OrderType()),OrderTicket(),OrderOpenPrice(),OrderProfit());
                  glbBotTelegram.SendMessage(inpChannelName,s);   
              }
            }
         }
      }
   }
   /*
   while(glbLenhLimit>0)
   {
      if(OrderDelete(glbLenhLimit))
      {
         glbLenhLimit=-1;
          glbBotTelegram.SendMessage(inpChannelName,StringFormat("Cap tien: %s\nXOA LENH LIMIT\nTicket: %d",Symbol(),glbLenhLimit));   
       }
   }
   */
}

string FunTraVeTenLenh(int LoaiLenh)
 {
   switch (LoaiLenh)
   {
      case OP_BUY: return "BUY";
      break;
      case OP_SELL:return "SELL";
      break;
      case OP_BUYLIMIT:return "BUY LIMIT";
      break;
      case OP_SELLLIMIT:return "SELL LIMIT";
      break;
      case OP_BUYSTOP:return "BUY STOP";
      break;
      case OP_SELLSTOP:return "SELL STOP";
      break;
      default: return "ERROR";
   }
 }
 //+------------------------------------------------------------------+
int FunVaoLenh(int LoaiLenh, double DiemVaoLenh,double StopLossPips, double TakeProfitPips, double KhoiLuongVaoLenh, int MagicNumber)
{
    int Ticket=-1;
    double StopLoss=0,TakeProfit=0;
    if(KhoiLuongVaoLenh==0) return -1;
    
    if(LoaiLenh==OP_BUY || LoaiLenh==OP_BUYLIMIT || LoaiLenh==OP_BUYSTOP)
    {
       if(StopLossPips>0)StopLoss=DiemVaoLenh-StopLossPips*10*Point();
       if(TakeProfitPips>0)TakeProfit=DiemVaoLenh+TakeProfitPips*10*Point();  
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,
                        "BUY Lenh "+IntegerToString(MagicNumber),MagicNumber,0,clrBlue);
    }
    if(LoaiLenh==OP_SELL|| LoaiLenh==OP_SELLLIMIT || LoaiLenh==OP_SELLSTOP)
    {
       if(StopLossPips>0)StopLoss=DiemVaoLenh+StopLossPips*10*Point();
       if(TakeProfitPips>0)TakeProfit=DiemVaoLenh-TakeProfitPips*10*Point();  
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,
                        "SELL Lenh "+IntegerToString(MagicNumber),MagicNumber,0,clrRed);
    }
    return Ticket;
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool FunKiemTraGioVaoLenh()// True: DUng gio vao lenh
{
   datetime timelocal=TimeCurrent();//TimeLocal();
   double gio=TimeHour(timelocal)+ double(TimeMinute(timelocal))/60;;
   if(inpStartTime<=inpEndTime)
      if(gio>=inpStartTime && gio<inpEndTime) return true;
      else return false;
   else // De lenh xuyen dem nen gio ket thuc < gio mo lenh
      if(gio>=inpEndTime&&gio<inpStartTime) return false;
      else return true;
}
void FunTrailingStopTicket(int ticket, int pipTrailingStop)
{
      if(pipTrailingStop<=0) return;
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
      {    
         double DiemTrailingStop=pipTrailingStop*10;
         double SoPointLoiLo=FunCountProfitPoints(OrderTicket());
         if (SoPointLoiLo>DiemTrailingStop)
         {
            double StopLoss=0;
            if(OrderType()==1)//lệnh sell
            {
            
               StopLoss=Bid+ DiemTrailingStop*Point();
               if(OrderStopLoss()>StopLoss && StopLoss<OrderOpenPrice())
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),StopLoss,OrderTakeProfit(),0,clrNONE))
                     Print("Trailing stop lenh SELL that bai");            
            }
            else if(OrderType()==0)// Lệnh buy
            {
               StopLoss=Bid-DiemTrailingStop*Point();
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

 //+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void FunKiemTraXoaLenhKhoiMang()
{
   for(int i=0;i<glbTongLenh;i++)
   {
      if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET))
      {
         if(OrderCloseTime()>0)
         {
            for(int j=i;j<glbTongLenh-1;j++)
            {
               glbTapLenh[j]=glbTapLenh[j+1];
            }
            glbTongLenh--;
         }
      }
   }
}

string FunTenTimeFrame()
{
   switch (Period())
   {
      case PERIOD_M1:
         return "KHUNG M1";
      case PERIOD_M5:
         return "KHUNG M5";
      case PERIOD_M15:
         return "KHUNG M15";
      case PERIOD_M30:
         return "KHUNG M30";
      case PERIOD_H1:
         return "KHUNG H1";
      case PERIOD_H4:
         return "KHUNG H4";
      case PERIOD_D1:
         return "KHUNG D1";
      case PERIOD_W1:
         return "KHUNG W1";
      case PERIOD_MN1:
         return "KHUNG MN1";
      default:
         return "LOI XAC DINH KHUNG THOI GIAN";
   }
}