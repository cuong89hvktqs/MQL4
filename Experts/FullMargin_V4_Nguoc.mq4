//+------------------------------------------------------------------+
//|                                           AnhTinh_FullMargin.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <Controls/Panel.mqh>
// Bot khi có giao cắt MA5 và MA20 đóng lệnh cũ, mở lệnh mới và gửi tín hiệu về telegram
/*
Em có thể sửa con V4 thành: Dưới 25 của rsi là nó mua, đến trên 70 của rsi là nó ngưng.
 Rsi trên 75 là nó bán, đến  rsi 30 là nó ngưng. Làm con mới nó mua bán ngược lại con cũ á em
*/
#include <Telegram\Telegram.mqh>
enum Enum_LoaiLenh{
   ONLY_BUY=OP_BUY,
   ONLY_SELL=OP_SELL,
   RSI=-1,
};
enum Enum_VaoLenhRSI{
   TU_DONG=0,
   THU_CONG=1,
};
struct NgayThang
  {
   int          Ngay; // date
   int            Thang;  // bid price
   int            Nam;  // ask price
  };
NgayThang NgayHetHan={30,04,3022};
//--- input parameters
input string inpChannelName="@fullmargin2022";//ID Kenh:
input string inpToken="5182615557:AAGduLjk6KIp2Bze6xSfLmgJqeGPa7klDG4";//Ma Token bot Telegram:
input double inpTienGoc=1000;// Tien goc ban dau:
input double inpHeSoHedging=2;//He so hedg:
input double inpHeSoNhayHedging;// He so nhay Hedg:
input double inpDiemTP=0;// Diem TP (pips)(<=0: Khong su dung):
input double inpDiemSL=3.5;// Diem SL (pips)(<=0: Khong su dung):
input Enum_LoaiLenh inpLoaiLenh=RSI;// Loai lenh dau tien:
input int inpCCIPeriod=7;// RSI period:
input double inpRSIMoLenhMua=25;// RSI bat dau MO lenh mua <=:
input double inpRSIDongLenhMua=70;// RSI bat dau DONG lenh mua >=:
input double inpRSIMoLenhBan=75;// RSI bat dau MO lenh ban >=:
input double inpRSIDongLenhBan=30;// RSI bat dau DONG lenh ban <=:
input Enum_VaoLenhRSI inpRSICachVaoLenh=TU_DONG;
input ENUM_TIMEFRAMES inpRSITimeframe=PERIOD_CURRENT;// Timeframe tinh RSI:
input int inpSpreadToiDa=5;// Spread toi da cho phep vao lenh (pips):
input bool inpChoPhepQuanLyLenhTay=true;// Co cho phep quan ly lenh bang tay:
input double inpBalanceCanhBao=10;// Gui tin nhan khi Balance ve duoi nguong($):
input string inpComemtEA="EA";// Comment EA:
input int inpMagic=9;//Magic:
CCustomBot glbBotTelegram;
int glbSoLanHedg=0;
bool glbDangCoLenh=false;
int glbTicketHedge=-1;
bool glbDaGuiTinNhanBalance=false;
bool glbDaGuiTinNhanRSI=false;
int glbDemTinNhanRSI=0;
double glbRSI=0;
//int glbLoaiLenhVaoTheoRSI=-1;
int glbLoaiLenhVao=-1;
int glbChoPhepVaoLenh=0; // O: Khong cho phép, -1: Cho phép vào sell liên tục; 1: Cho phép vào buy liên tục
string glbTenCapTienEU="EURUSD";
string glbTenCapTienGU="GBPUSD";
string glbmsg1="CHE DO: ";
string glbmsg2="KL HIEN TAI: ";
string glbmsg3="Banalce: ";
string glbmsg4="Equity: ";
string glbmsg5="Free Margin: ";
string glbmsg6="So lan da Hedge: ";
string glbmsg7="He so Hedge: ";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
      if(FunKiemTraHetHan(NgayHetHan)==false){MessageBox("Bot het han su dung");return INIT_FAILED;}
      if(inpLoaiLenh==RSI)
      {
         if(inpRSIMoLenhBan>=inpRSIDongLenhMua && inpRSIDongLenhMua>=inpRSIDongLenhBan && inpRSIDongLenhBan>=inpRSIMoLenhMua);
         else {MessageBox("CAC THAM SO MO, DONG LENH THEO RSI DANG SAI. VUI LONG SUA LAI");return INIT_FAILED;}
      }
      glbBotTelegram.Token(inpToken);
      string msgTele=StringFormat("Cap Tien: %s\nKet noi MT4 va telegram Thanh cong.",Symbol());
      glbBotTelegram.SendMessage(inpChannelName,msgTele);
       glbDaGuiTinNhanRSI=false;
       glbDaGuiTinNhanBalance=false;
      FunButtonCreate(0,"btnDongTatCaLenh",0,2,130,150,40,CORNER_LEFT_LOWER,ANCHOR_LEFT_LOWER,"DONG TAT CA LENH","Arial",9,clrBlue,clrRed);
      FunButtonCreate(0,"btnDongTatCaLenhLo",0,2,175,150,40,CORNER_LEFT_LOWER,ANCHOR_LEFT_LOWER,"DONG TAT CA LENH LO","Arial",9,clrBlue,clrPink);
      FunLabelCreate(0,"lblMsg1",0,4,72,CORNER_LEFT_LOWER,ANCHOR_LEFT_LOWER,glbmsg1,"Arial",9,clrYellow);
      FunLabelCreate(0,"lblMsg2",0,4,60,CORNER_LEFT_LOWER,ANCHOR_LEFT_LOWER,glbmsg2,"Arial",9,clrYellow);
      FunLabelCreate(0,"lblMsg3",0,4,48,CORNER_LEFT_LOWER,ANCHOR_LEFT_LOWER,glbmsg3,"Arial",9,clrYellow);
      FunLabelCreate(0,"lblMsg4",0,4,36,CORNER_LEFT_LOWER,ANCHOR_LEFT_LOWER,glbmsg4,"Arial",9,clrYellow);
      FunLabelCreate(0,"lblMsg5",0,4,24,CORNER_LEFT_LOWER,ANCHOR_LEFT_LOWER,glbmsg5,"Arial",9,clrYellow);
      FunLabelCreate(0,"lblMsg6",0,4,12,CORNER_LEFT_LOWER,ANCHOR_LEFT_LOWER,glbmsg6,"Arial",9,clrYellow);
      FunLabelCreate(0,"lblMsg7",0,4,0,CORNER_LEFT_LOWER,ANCHOR_LEFT_LOWER,glbmsg7,"Arial",9,clrYellow);
     // glbLoaiLenhVao=-1;
     // glbChoPhepVaoLenh=0;

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
      FunButtonDelete(0,"btnDongTatCaLenh");
      FunButtonDelete(0,"btnDongTatCaLenhLo");
      FunLabelDelete(0,"lblMsg1");
      FunLabelDelete(0,"lblMsg2");
      FunLabelDelete(0,"lblMsg3");
      FunLabelDelete(0,"lblMsg4");
      FunLabelDelete(0,"lblMsg5");
      FunLabelDelete(0,"lblMsg6");
      FunLabelDelete(0,"lblMsg7");
      //glbMyPanel.Destroy();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
      //Comment("");
      double HeSoHedg= inpHeSoHedging+ glbSoLanHedg*inpHeSoNhayHedging;
      string msg="";
      
      if(inpLoaiLenh==ONLY_BUY)
          glbmsg1="CHE DO: ONLY BUY\n"  ;
      else if (inpLoaiLenh==ONLY_SELL)glbmsg1="CHE DO: ONLY SELL\n" ;
      else glbmsg1="CHE DO: RSI\n" ;
      
         glbmsg2="KL BUY : "+DoubleToString(FunTinhKhoiLuong(OP_BUY),2)+"  KL SELL : "+DoubleToString(FunTinhKhoiLuong(OP_SELL),2);
         glbmsg3="Banalce: "+DoubleToString(AccountBalance(),2);
         glbmsg4="Equity: "+DoubleToString(AccountEquity(),2);
         glbmsg5="Free Margin: "+DoubleToString(AccountFreeMargin(),2);
         glbmsg6="So lan da Hedge: "+DoubleToString(glbSoLanHedg,1);
         glbmsg7="He so hedge: "+DoubleToString(HeSoHedg,1) + "  Equity lan hedge tiep: "+DoubleToString(inpTienGoc*HeSoHedg,2);
      FunLabelTextChange(0,"lblMsg1",glbmsg1);
      FunLabelTextChange(0,"lblMsg2",glbmsg2);
      FunLabelTextChange(0,"lblMsg3",glbmsg3);
      FunLabelTextChange(0,"lblMsg4",glbmsg4);
      FunLabelTextChange(0,"lblMsg5",glbmsg5);
      FunLabelTextChange(0,"lblMsg6",glbmsg6);
      FunLabelTextChange(0,"lblMsg7",glbmsg7);
      if(AccountBalance()<=inpBalanceCanhBao )
      {
            if( glbDaGuiTinNhanBalance==false)
            {
               glbBotTelegram.SendMessage(inpChannelName,"CANH BAO: CAN NAP TIEN TANG BALANCE");
               glbDaGuiTinNhanBalance=true;
            }
      }
      else glbDaGuiTinNhanBalance=false;
           
      if(FunKiemTraThoaManSpread()==false)
      {
         Print("SPread vuot muc cho phep");
         return;
      }
      
      
      if(glbTicketHedge>0)// Dang co lenh hedge, 
      {
         //Print("Dang co lenh Hedge");
         Comment("Dang co lenh Hedge");
         if(OrderSelect(glbTicketHedge,SELECT_BY_TICKET,MODE_TRADES))
         {
            if(OrderCloseTime()>0)
               glbTicketHedge=-1;
         }
            return;
      }
    
      if((AccountEquity()/inpTienGoc)>=HeSoHedg && glbTicketHedge<=0)//
      {
         Print("Tinh Toan Vao lenh Hedge");
         glbTicketHedge=FunVaoLenhHeding();// Tinh toan vao lenh Hedge
         if(glbTicketHedge>0) glbSoLanHedg++;
         return;
      }
      if(FunKiemTraSangNenMoiChua()==true)
      {       
         if(FunKiemTraDangCoLenhKhong()==false)// chuaw co lenh
         {
              Print("glbCHoPhepVaoLenhRSI=",glbChoPhepVaoLenh);
               if(inpLoaiLenh==ONLY_BUY||inpLoaiLenh==ONLY_SELL)
               {
                  FunVaoLenhFullMargin(inpLoaiLenh);
                  glbLoaiLenhVao=inpLoaiLenh;
               }
               else
               {
                  if(glbChoPhepVaoLenh==0)
                  {
                     glbRSI=FunTinhRSI(1);
                     if(glbRSI>=inpRSIMoLenhBan)
                     {  
                        
                        if(inpRSICachVaoLenh==TU_DONG)
                        {   
                           Comment("Mo lenh SELL");
                           FunVaoLenhFullMargin(OP_SELL);/*glbLoaiLenhVaoTheoRSI=OP_SELL;*/glbLoaiLenhVao=OP_SELL;glbChoPhepVaoLenh=-1;
                        }
                        else
                        {
                           if(glbDaGuiTinNhanRSI==false)
                           {
                              glbBotTelegram.SendMessage(inpChannelName,"CANH BAO DIEM BAN. RSI="+DoubleToString(glbRSI,2)); 
                              glbDaGuiTinNhanRSI=true;
                               Comment("RSI=",glbRSI);
                           }
                        }
                        
                      }
                      else if(glbRSI<=inpRSIMoLenhMua) 
                      {
                        if(inpRSICachVaoLenh==TU_DONG)
                        {
                           Comment("Mo lenh BUY");
                           FunVaoLenhFullMargin(OP_BUY);/*glbLoaiLenhVaoTheoRSI=OP_BUY;*/glbLoaiLenhVao=OP_BUY;glbChoPhepVaoLenh=1;
                        }
                         else
                        {
                           if(glbDaGuiTinNhanRSI==false)
                           {
                              glbBotTelegram.SendMessage(inpChannelName,"CANH BAO DIEM MUA. RSI="+DoubleToString(glbRSI,2));
                              glbDaGuiTinNhanRSI=true;
                               Comment("RSI=",glbRSI);
                           }
                        }
                      }
                      else {Comment("MUA khi RSI <=",inpRSIMoLenhMua,"\nBAN khi RSI>= ",inpRSIMoLenhBan,"\nRSI Nen truoc=",DoubleToString(glbRSI,2));glbDaGuiTinNhanRSI=false;}
                  }                 
                  else // dang cho phép vào lệnh
                  {
                      Print("Tinh toan de vao lenh tu dong khi khong co lenh, nhung Gia tri RSI trong khoang:",inpRSIDongLenhBan,"-",inpRSIDongLenhMua);
                      FunVaoLenhFullMargin(glbLoaiLenhVao);
                  }
            }
         }
         else // đang có lệnh
         {
            
           // Print("Dang co lenh. glbChoPhepVaolenh=",glbChoPhepVaoLenh);
            Comment("Lenh dang vào:",FunTenLoaiLenhDangVao(glbLoaiLenhVao), "\nLenh Buy dong lenh khi RSI>=",inpRSIDongLenhMua,"\nLenh Sell dong lenh khi RSI<=",inpRSIDongLenhBan,"\nRSI(1)=",FunTinhRSI(1));
            if(inpDiemSL>0) 
            {
              // Print("Dong cac lenh co so pip lo >= ",inpDiemSL);
               FunDongCacLenhTheoSoPipLo();
            } 
            if(inpDiemTP>0) 
            {
               //Print("Dong cac lenh co so pip Lai >= ",inpDiemTP);
               FunDongCacLenhTheoSoPipLoi();
            } 
             if(inpLoaiLenh==ONLY_BUY||inpLoaiLenh==ONLY_SELL)
            {
                Print("Vao lenh tu dong khi sang nen moi");
                FunVaoLenhFullMargin(inpLoaiLenh);
            }
            else
            {
                 glbRSI=FunTinhRSI(1);
                if(inpLoaiLenh==RSI)
                {
                     if(glbLoaiLenhVao==OP_SELL && glbRSI<=inpRSIDongLenhBan)
                     {
                        Print("Dong tat ca ca lenh sell theo RSI. RSI(1)=",glbRSI);
                        FunDongTatCaCacLenh();
                        glbLoaiLenhVao=-1;
                        glbChoPhepVaoLenh=0;
                     }
                     if(glbLoaiLenhVao==OP_BUY && glbRSI>=inpRSIDongLenhMua)
                     {
                        Print("Dong tat ca ca lenh Buy theo RSI. RSI(1)=",glbRSI);
                        FunDongTatCaCacLenh();
                        glbLoaiLenhVao=-1;
                        glbChoPhepVaoLenh=0;
                     }
                 }
                 if(FunKiemTraDangCoLenhKhong())// đang có lệnh sau khi cắt lệnh teho số pips thì vào tiếp fullmargin
                 {
                     Print("Tinh toan free margin de vao lenh tiep");
                     FunVaoLenhFullMargin(glbLoaiLenhVao);
                 }
                 else // đã hết lệnh sau khi cắt lệnh theo số pips
                 {
                     if(glbChoPhepVaoLenh==-1)
                     { 
                           Print("Vao tiep lenh SELL do chi so RSI trong khoang: ",inpRSIDongLenhBan,"-",inpRSIDongLenhMua);
                           FunVaoLenhFullMargin(OP_SELL); glbLoaiLenhVao=OP_SELL;
                     }
                     else if (glbChoPhepVaoLenh==1)
                     { 
                           Print("Vao tiep lenh BUY do chi so RSI trong khoang: ",inpRSIDongLenhBan,"-",inpRSIDongLenhMua);
                           FunVaoLenhFullMargin(OP_BUY);glbLoaiLenhVao=OP_BUY;
                     }
                     else glbLoaiLenhVao=-1;
                     
                 }                                 
            }
         }
         if(AccountBalance()<=inpBalanceCanhBao)
         {
            glbBotTelegram.SendMessage(inpChannelName,"CANH BAO: CAN NAP TIEN TANG BALANCE");
         }                   
      } 
          
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
 bool FunKiemTraSangNenMoiChua()// roi: true; chua: false
 {
   static datetime _LastBar=Time[0];
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
bool FunKiemTraDangCoLenhKhong()
{
   bool kt=false;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderSymbol()==Symbol())
         {
            if(inpChoPhepQuanLyLenhTay==true)
               {kt=true;glbLoaiLenhVao=OrderType();break;}
            else
            {
               if(OrderMagicNumber()==inpMagic)
               {kt=true;glbLoaiLenhVao=OrderType();break;}
            }                       
         }
      }
   }
   return kt; 
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void FunVaoLenhFullMargin(int LoaiLenh)
{
   double  minLot  = MarketInfo(Symbol(), MODE_MINLOT);
   double tick_value = MarketInfo(Symbol(),MODE_TICKVALUE);
   double lot=NormalizeDouble((AccountFreeMargin()/(200*tick_value)),2);  // để 180 point
   while (AccountFreeMargin()>0)
   {
      
      lot = NormalizeDouble(MathMin(lot*0.8,lot -minLot),2);
     // Print("Vao lenh voi khoi luong:",lot);
      if(lot < minLot){lot=minLot;}
      FunVaoLenh(LoaiLenh,lot);
      if(lot==minLot)break;
   }  
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int FunVaoLenh(int LoaiLenh, double KhoiLuong)
{
   int ticket=-1;
   double lot=NormalizeDouble(KhoiLuong, MODE_DIGITS);
   if(LoaiLenh==OP_BUY)
      ticket=OrderSend(Symbol(),OP_BUY,lot,Ask,inpSpreadToiDa*10,0,0,inpComemtEA,inpMagic,0,clrBlue);
   else 
      ticket=OrderSend(Symbol(),OP_SELL,lot,Bid,inpSpreadToiDa*10,0,0,inpComemtEA,inpMagic,0,clrRed);
      
   return ticket;
}
 //+------------------------------------------------------------------+
//+------------------------------------------------------------------+

bool FunKiemTraThoaManSpread()
{
   bool kt=true;
   double Spread = MarketInfo(Symbol(), MODE_SPREAD)/10;
   if(Spread >inpSpreadToiDa)kt=false;
   return kt;
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void FunGuiThongBaoBalance()
{
   if(AccountBalance()<inpBalanceCanhBao)
      glbBotTelegram.SendMessage(inpChannelName,"CANH BAO: CAN NAP TIEN TANG BALANCE");
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

int FunVaoLenhHeding()
{
      double KhoiLuong=0;
      int Ticket=-1;
     // if((AccountEquity()/inpTienGoc)>=HeSoHedg && glbTicketHedge<=0)
    //  {
         // vao lenh hedge
         KhoiLuong=FunTinhKhoiLuongHedge();
         if(KhoiLuong>0)
         {
            if(inpLoaiLenh==ONLY_BUY) Ticket=FunVaoLenh(OP_SELL,KhoiLuong);
            else if(inpLoaiLenh==ONLY_SELL) Ticket=FunVaoLenh(OP_BUY,KhoiLuong);
            else
               Ticket=FunVaoLenh((glbLoaiLenhVao+1)%2,KhoiLuong);
         } 
    //  }
      if(Ticket>0) glbBotTelegram.SendMessage(inpChannelName,"CANH BAO: DA VAO LENH HEDGE");
      return Ticket; 
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double FunTinhKhoiLuongHedge()
{
   double KhoiLuong=0;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderSymbol()==Symbol())
         {
            if(inpChoPhepQuanLyLenhTay==true)
            {
              // if(OrderType()==inpLoaiLenh)
                  KhoiLuong+=OrderLots();
             //  else KhoiLuong-=OrderLots();
            }
            else
            {
               if(OrderMagicNumber()==inpMagic)
               {
                 // if(OrderType()==inpLoaiLenh)
                     KhoiLuong+=OrderLots();
                 // else KhoiLuong-=OrderLots();          
               }
            }  
         
         }
      }
   }
   if(KhoiLuong<0) KhoiLuong=0;
   return KhoiLuong;
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double FunTinhKhoiLuong(int LoaiLenh)
{
   double KhoiLuong=0;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderSymbol()==Symbol())
         {
            if(inpChoPhepQuanLyLenhTay==true)
            {
               if(OrderType()==LoaiLenh)
                  KhoiLuong+=OrderLots();
            }
            else
            {
               if(OrderMagicNumber()==inpMagic)
               {
                  if(OrderType()==LoaiLenh)
                     KhoiLuong+=OrderLots();         
               }
            }  
         
         }
      }
   }
   return KhoiLuong;
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

void FunDongTatCaCacLenh()
{
  // Print(OrdersTotal());
   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
        // Print("Pos:",i,"  Dong lenh ",OrderTicket());
         if(OrderSymbol()==Symbol())
         {
            
            if(OrderType()==OP_SELL)
               OrderClose(OrderTicket(),OrderLots(),Ask,inpSpreadToiDa*10,clrNONE);
            else OrderClose(OrderTicket(),OrderLots(),Bid,inpSpreadToiDa*10,clrNONE);
         }
      }
   }
   //glbLoaiLenhVaoTheoRSI=-1;
   glbDaGuiTinNhanRSI=false;
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

void FunDongTatCaCacLenhDangLo()
{
   for(int i=OrdersTotal()-1;i>=0;i--)
   {
       if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderSymbol()==Symbol()&& OrderProfit()<0)
         {
            if(OrderType()==OP_SELL)
               OrderClose(OrderTicket(),OrderLots(),Ask,inpSpreadToiDa*10,clrNONE);
            else OrderClose(OrderTicket(),OrderLots(),Bid,inpSpreadToiDa*10,clrNONE);
         }
      }
   }
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void FunDongCacLenhTheoSoPipLo()
{
   //Print("Kiem tra dong lenh theo SL");
   double SoPipLoiLo=0;
    for(int i=OrdersTotal()-1;i>=0;i--)
   {
       if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderSymbol()==Symbol())
         {
            if(inpChoPhepQuanLyLenhTay==true)
            {
               if(OrderType()==OP_BUY)
               {
                  SoPipLoiLo=(Bid-OrderOpenPrice())/(10*Point);
                  if(SoPipLoiLo <0 && MathAbs(SoPipLoiLo)>=inpDiemSL)
                  {
                     Print("Dong  lenh khi so pip lo >= ",inpDiemSL, " Ticket=",OrderTicket());
                     OrderClose(OrderTicket(),OrderLots(),Bid,inpSpreadToiDa*10,clrNONE);
                  }
               }
               else
               {
                  SoPipLoiLo=(OrderOpenPrice()-Ask)/(10*Point);
                  if(SoPipLoiLo <0 && MathAbs(SoPipLoiLo)>=inpDiemSL)
                  {
                     Print("Dong  lenh khi so pip lo >= ",inpDiemSL, " Ticket=",OrderTicket());
                     OrderClose(OrderTicket(),OrderLots(),Ask,inpSpreadToiDa*10,clrNONE);
                  }
               }
            }
            else
            {
               if(OrderMagicNumber()==inpMagic)
               {
                  if(OrderType()==OP_BUY)
                  {
                     SoPipLoiLo=(Bid-OrderOpenPrice())/(10*Point);
                     if(SoPipLoiLo <0 && MathAbs(SoPipLoiLo)>=inpDiemSL)
                     {
                        Print("Dong  lenh khi so pip lo >= ",inpDiemSL, " Ticket=",OrderTicket());
                        OrderClose(OrderTicket(),OrderLots(),Bid,inpSpreadToiDa*10,clrNONE);
                     }
                  }
                  else
                  {
                     SoPipLoiLo=(OrderOpenPrice()-Ask)/(10*Point);
                     if(SoPipLoiLo <0 && MathAbs(SoPipLoiLo)>=inpDiemSL)
                     {
                        Print("Dong  lenh khi so pip lo >= ",inpDiemSL, " Ticket=",OrderTicket());
                        OrderClose(OrderTicket(),OrderLots(),Ask,inpSpreadToiDa*10,clrNONE);
                      }
                  }         
               }
            }  
         }
      }
   }
   
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void FunDongCacLenhTheoSoPipLoi()
{
   //Print("Kiem tra dong lenh theo SL");
   double SoPipLoiLo=0;
    for(int i=OrdersTotal()-1;i>=0;i--)
   {
       if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderSymbol()==Symbol())
         {
            if(inpChoPhepQuanLyLenhTay==true)
            {
               if(OrderType()==OP_BUY)
               {
                  SoPipLoiLo=(Bid-OrderOpenPrice())/(10*Point);
                  if(SoPipLoiLo >0 && MathAbs(SoPipLoiLo)>=inpDiemTP)
                  {
                     Print("Dong  lenh khi so pip LAI >= ",inpDiemSL, " Ticket=",OrderTicket());
                     OrderClose(OrderTicket(),OrderLots(),Bid,inpSpreadToiDa*10,clrNONE);
                  }
               }
               else
               {
                  SoPipLoiLo=(OrderOpenPrice()-Ask)/(10*Point);
                  if(SoPipLoiLo >0 && MathAbs(SoPipLoiLo)>=inpDiemTP)
                  {
                     Print("Dong  lenh khi so pip LAI >= ",inpDiemSL, " Ticket=",OrderTicket());
                     OrderClose(OrderTicket(),OrderLots(),Ask,inpSpreadToiDa*10,clrNONE);
                  }
               }
            }
            else
            {
               if(OrderMagicNumber()==inpMagic)
               {
                  if(OrderType()==OP_BUY)
                  {
                     SoPipLoiLo=(Bid-OrderOpenPrice())/(10*Point);
                     if(SoPipLoiLo >0 && MathAbs(SoPipLoiLo)>=inpDiemTP)
                     {
                        Print("Dong  lenh khi so pip LAI >= ",inpDiemSL, " Ticket=",OrderTicket());
                        OrderClose(OrderTicket(),OrderLots(),Bid,inpSpreadToiDa*10,clrNONE);
                     }
                  }
                  else
                  {
                     SoPipLoiLo=(OrderOpenPrice()-Ask)/(10*Point);
                     if(SoPipLoiLo >0 && MathAbs(SoPipLoiLo)>=inpDiemTP)
                     {
                        Print("Dong  lenh khi so pip LAI >= ",inpDiemSL, " Ticket=",OrderTicket());
                        OrderClose(OrderTicket(),OrderLots(),Ask,inpSpreadToiDa*10,clrNONE);
                     }
                  }         
               }
            }  
         }
      }
   }
   
}
//+------------------------------------------------------------------+
double FunTinhRSI(int shift)
{
   return iRSI(Symbol(),inpRSITimeframe,inpCCIPeriod,PRICE_CLOSE,shift);
}
//+------------------------------------------------------------------+
bool FunButtonCreate(const long              chart_ID=0,               // chart's ID
                  const string            name="Button",            // button name
                  const int               sub_window=0,             // subwindow index
                  const int               x=0,                      // X coordinate
                  const int               y=0,                      // Y coordinate
                  const int               width=50,                 // button width
                  const int               height=18,                // button height
                  const ENUM_BASE_CORNER  corner=CORNER_RIGHT_UPPER, // chart corner for anchoring
                  const ENUM_ANCHOR_POINT anchor=ANCHOR_RIGHT_UPPER,
                  const string            text="Button",            // text
                  const string            font="Arial",             // font
                  const int               font_size=10,             // font size
                  const color             clr=clrBlack,             // text color
                  const color             back_clr=C'236,233,216',  // background color
                  const color             border_clr=clrNONE,       // border color
                  const bool              state=false,              // pressed/released
                  const bool              back=false,               // in the background
                  const bool              selection=false,          // highlight to move
                  const bool              hidden=true,              // hidden in the object list
                  const long              z_order=0)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
   if(ObjectFind(chart_ID,name)>=0)
   {
      FunButtonDelete(chart_ID,name);
   }
//--- create the charbutton
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the button! Error code = ",GetLastError());
      return(false);
     }
//--- set button coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set button size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set text color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border color
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- set button state
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
//--- enable (true) or disable (false) the mode of moving the button by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
  
//+------------------------------------------------------------------+
//| Change button text Color                                                |
//+------------------------------------------------------------------+
void FunButtonCreateV2(long   chart_id=0,
                 string name="Button",
                 int    chart_corner=CORNER_RIGHT_UPPER,
                 int    anchor_point=ANCHOR_RIGHT_UPPER,
                 string text_label="",
                 int    x_distan=50,
                 int    y_distan=50,
                 const color   txt_clr=clrBlack,             // text color
                  const color  back_clr=C'236,233,216',  // background color
                  const color   border_clr=clrNONE       // border colo
                  )
  {
//---
   if(ObjectCreate(chart_id,name,OBJ_BUTTON,0,0,0))
     {
      ObjectSetInteger(chart_id,name,OBJPROP_CORNER,chart_corner);
      ObjectSetInteger(chart_id,name,OBJPROP_ANCHOR,anchor_point);
      ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,x_distan);
      ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,x_distan);
      
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text_label);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,txt_clr);
       //--- set background color
      ObjectSetInteger(chart_id,name,OBJPROP_BGCOLOR,back_clr);
    //--- set border color
      ObjectSetInteger(chart_id,name,OBJPROP_BORDER_COLOR,border_clr);
      ObjectSetInteger(chart_id,name,OBJPROP_BACK,false);
   //--- set button state
      ObjectSetInteger(chart_id,name,OBJPROP_STATE,false);
   //--- enable (true) or disable (false) the mode of moving the button by mouse
      ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(chart_id,name,OBJPROP_SELECTED,false);
   //--- hide (true) or display (false) graphical object name in the object list
      ObjectSetInteger(chart_id,name,OBJPROP_HIDDEN,true);
   //--- set the priority for receiving the event of a mouse click in the chart
      ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,0);
     }
   else
      Print("Failed to create the object OBJ_LABEL ",name,", Error code = ", GetLastError());
  }  
//+------------------------------------------------------------------+
//| Change button text Color                                                |
//+------------------------------------------------------------------+
bool FunButtonColorTextChange(const long   chart_ID=0,    // chart's ID
                      const string name="Button", // button name
                      const color clr=clrBlack)   // text
  {
//--- reset the error value
   ResetLastError();
//--- change object text
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr))
     {
      Print(__FUNCTION__,
            ": failed to change the text color! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Delete the button                                                |
//+------------------------------------------------------------------+
bool FunButtonDelete(const long   chart_ID=0,    // chart's ID
                  const string name="Button") // button name
  {
//--- reset the error value
   ResetLastError();
//--- delete the button
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete the button! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Create a text label                                              |
//+------------------------------------------------------------------+
bool FunLabelCreate(const long              chart_ID=0,               // chart's ID
                 const string            name="Label",             // label name
                 const int               sub_window=0,             // subwindow index
                 const int               x=0,                      // X coordinate
                 const int               y=0,                      // Y coordinate
                 const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type
                 const string            text="Label",             // text
                 const string            font="Arial",             // font
                 const int               font_size=10,             // font size
                 const color             clr=clrRed,               // color
                 const double            angle=0.0,                // text slope           
                 const bool              back=false,               // in the background
                 const bool              selection=false,          // highlight to move
                 const bool              hidden=true,              // hidden in the object list
                 const long              z_order=0)                // priority for mouse click
  {
//--- reset the error value
   if(ObjectFind(chart_ID,name)>=0)
   {
      FunLabelDelete(chart_ID,name);
   }
   ResetLastError();
//--- create a text label
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create text label! Error code = ",GetLastError());
      return(false);
     }
//--- set label coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the slope angle of the text
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
  
  //+------------------------------------------------------------------+
//| Change the object text                                           |
//+------------------------------------------------------------------+
bool FunLabelTextChange(const long   chart_ID=0,   // chart's ID
                     const string name="Label", // object name
                     const string text="Text")  // text
  {
//--- reset the error value
   ResetLastError();
//--- change object text
   if(!ObjectSetString(chart_ID,name,OBJPROP_TEXT,text))
     {
      Print(__FUNCTION__,
            ": failed to change the text! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
 //+------------------------------------------------------------------+
//| Delete a text label                                              |
//+------------------------------------------------------------------+
bool FunLabelDelete(const long   chart_ID=0,   // chart's ID
                 const string name="Label") // label name
  {
//--- reset the error value
   ResetLastError();
//--- delete the label
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a text label! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }  
  
//+------------------------------------------------------------------+
//| Creating Text object                                             |
//+------------------------------------------------------------------+
bool FunTextCreate(const long              chart_ID=0,               // chart's ID
                const string            name="Text",              // object name
                const int               sub_window=0,             // subwindow index
                 datetime               x=0,                      // X coordinate
                  double               y=0,                      // Y coordinate
                 const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type
                const string            text="Text",              // the text itself
                const string            font="Arial",             // font
                const int               font_size=10,             // font size
                const color             clr=clrRed,               // color
                const double            angle=0.0,                // text slope                
                const bool              back=false,               // in the background
                const bool              selection=false,          // highlight to move
                const bool              hidden=true,              // hidden in the object list
                const long              z_order=0)                // priority for mouse click
  {

//--- reset the error value
   ResetLastError();
//--- create Text object
   ChangeTextEmptyPoint(x,y);
   if(!ObjectCreate(chart_ID,name,OBJ_TEXT,sub_window,x,y))
     {
      Print(__FUNCTION__,
            ": failed to create \"Text\" object! Error code = ",GetLastError());
      return(false);
     }
//--- set label coordinates
  // ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
  // ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
   //--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the slope angle of the text
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the object by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
 //+------------------------------------------------------------------+
//| Check anchor point values and set default values                 |
//| for empty ones                                                   |
//+------------------------------------------------------------------+
void ChangeTextEmptyPoint(datetime &time,double &price)
  {
//--- if the point's time is not set, it will be on the current bar
   if(!time)
      time=TimeCurrent();
//--- if the point's price is not set, it will have Bid value
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
  }  
  //+------------------------------------------------------------------+
//| Change the object text                                           |
//+------------------------------------------------------------------+
bool FunTextChange(const long   chart_ID=0,  // chart's ID
                const string name="Text", // object name
                const string text="Text") // text
  {
//--- reset the error value
   ResetLastError();
//--- change object text
   if(!ObjectSetString(chart_ID,name,OBJPROP_TEXT,text))
     {
      Print(__FUNCTION__,
            ": failed to change the text! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Delete Text object                                               |
//+------------------------------------------------------------------+
bool FunTextDelete(const long   chart_ID=0,  // chart's ID
                const string name="Text") // object name
  {
//--- reset the error value
   ResetLastError();
//--- delete the object
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete \"Text\" object! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
  //+------------------------------------------------------------------+
//| chart event                                                        |
//+------------------------------------------------------------------+

  void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{

   if(id==CHARTEVENT_OBJECT_CLICK)
   {
      if(sparam=="btnDongTatCaLenh")
      {
         Print("Dong tat ca ca lenh theo button");
         FunDongTatCaCacLenh();
         glbLoaiLenhVao=-1;
         glbChoPhepVaoLenh=0;
      }
       if(sparam=="btnDongTatCaLenhLo")
      {
         Print("Dong tat ca ca lenh LO theo button");
         FunDongTatCaCacLenhDangLo();
      }          
   }
}

  //+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool FunKiemTraHetHan(NgayThang &HanCanKiemTra)// False: Da het han; True: Chưa
{
   bool kt=true;
   if(Year()>HanCanKiemTra.Nam)
    {
         MessageBox("EA het han su dung. De gia han Vui long truy cap website tailieuforex.com. Hoac lien he SDT: 0989149111");
         ExpertRemove();
         kt=false;
    }
      if(Year()==HanCanKiemTra.Nam && Month()>HanCanKiemTra.Thang)
    {
         MessageBox("EA het han su dung. De gia han Vui long truy cap website tailieuforex.com. Hoac lien he SDT: 0989149111");
         ExpertRemove();
         kt=false;   
    }
    if(Year()==HanCanKiemTra.Nam && Month()==HanCanKiemTra.Thang && Day()>HanCanKiemTra.Ngay)  
    {
        MessageBox("EA het han su dung. De gia han Vui long truy cap website tailieuforex.com. Hoac lien he SDT: 0989149111");
         ExpertRemove();
         kt=false;
    }
    return kt;
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
string FunTenLoaiLenhDangVao(int LoaiLenh)
{
   if(LoaiLenh==0)return "OP_BUY";
   else if(LoaiLenh==1) return "OP_SELL";
   else return IntegerToString(LoaiLenh);
}