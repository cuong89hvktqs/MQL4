//+------------------------------------------------------------------+
//|                                    BotGapThem_HoangQuangManh.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

struct NgayThang
  {
   int          Ngay; // date
   int            Thang;  // bid price
   int            Nam;  // ask price
  };
NgayThang NgayHetHan={30,04,3023};
input double inpKhoiLuongCoSo=0.01;//Khoi luong co so ban dau:
input double inpHeSoNhanKhoiLuong=3;// He so nhan khoi luong:
input int inpKhoangCachCoSo=40;//Khoang cach co so (Pips):
input double inpHeSoA=1; // He so a:
input double inpHeSoB=1;// He so b:
input int inpKhoiLuongDungNhoiLenh=20;//KhoiLuong dung nhoi lenh (Lots):
input int inpMagicNumber=12345;// Magic number:
input int inpSlippage=100;// Slippage:

int glbLenhStopBuyDauTien=-1;
int glbLenhStopSellDauTien=-1;
int glbLoaiLenhCuaLenhTruocDo=-1;
int glbTongSoLenh=0;
int glbTapLenh[100];
int glbLenhCho=-1;
double glbTongKhoiLuongDaVao=0;
double glbGiaVaoLenhTruocDo=0;
double glbKhoiLuongVaoLenhTruocDo=0;
double glbKhoangCachCoSo=0;//=inpKhoangcachCoSo neu lenh dau tien la buy
double glbVungGiaTPToanBoLenh=0;// Can cu vao lenh dau tien la buy hay sell
double glbVungGiaSLToanBoLenh=0;// Can cu vao lenh dau tien la buy hay sell
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
      if(glbTongSoLenh==0)
         FunXuLyKhiBotBiThoat();
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
      if(FunKiemTraSangNenMoiChua()==true)
      {
         if(glbTongSoLenh==0)
         {
            if(glbLenhStopBuyDauTien<0 && glbLenhStopSellDauTien<0)
            {
               // Vao 2 lenh stop dau tien
               glbLenhStopBuyDauTien=FunVaoLenh(OP_BUYSTOP,Ask+inpKhoangCachCoSo*10*Point(),0,inpKhoangCachCoSo,inpKhoiLuongCoSo);
               glbLenhStopSellDauTien=FunVaoLenh(OP_SELLSTOP,Bid-inpKhoangCachCoSo*10*Point(),0,inpKhoangCachCoSo,inpKhoiLuongCoSo);
            }
         }
         
      }
      if(glbLenhStopBuyDauTien>0 && glbLenhStopSellDauTien>0)
      {
         
         if(OrderSelect(glbLenhStopBuyDauTien,SELECT_BY_TICKET,MODE_TRADES))
         {
            if(OrderCloseTime()>0)
            {
               OrderDelete(glbLenhStopSellDauTien);
               glbLenhStopBuyDauTien=-1;
               glbLenhStopSellDauTien=-1;  
               return;
            }
            else if(OrderType()==OP_BUY)// Lenh hit
            {
               OrderDelete(glbLenhStopSellDauTien);
               glbTapLenh[glbTongSoLenh]=OrderTicket();
               glbTongSoLenh++;
               glbKhoiLuongVaoLenhTruocDo=OrderLots();
               glbGiaVaoLenhTruocDo=OrderOpenPrice();
               glbLoaiLenhCuaLenhTruocDo=OP_BUY; 
               glbTongKhoiLuongDaVao+=OrderLots();
               glbLenhStopBuyDauTien=-1;
               glbLenhStopSellDauTien=-1;  
               FunVaoLenhChoTiepTheo();   
               return;    
            }
         }
         if(OrderSelect(glbLenhStopSellDauTien,SELECT_BY_TICKET,MODE_TRADES))
         {
            if(OrderCloseTime()>0)
            {
               OrderDelete(glbLenhStopBuyDauTien);
               glbLenhStopBuyDauTien=-1;
               glbLenhStopSellDauTien=-1;  
               return;
            }
            else if(OrderType()==OP_SELL)// Lenh hit
            {
               OrderDelete(glbLenhStopBuyDauTien);
               glbTapLenh[glbTongSoLenh]=OrderTicket();
               glbTongSoLenh++;
               glbKhoiLuongVaoLenhTruocDo=OrderLots();
               glbGiaVaoLenhTruocDo=OrderOpenPrice();
               glbLoaiLenhCuaLenhTruocDo=OP_SELL;
               glbTongKhoiLuongDaVao+=OrderLots();  
               glbLenhStopBuyDauTien=-1;
               glbLenhStopSellDauTien=-1; 
               FunVaoLenhChoTiepTheo();  
               return;        
            }
         }        
      }
      if(glbTongSoLenh>0)
      {
         FunKiemTraDongLenhBangTay();      
      }
      if(glbLenhCho>0)
      {
         if(OrderSelect(glbLenhCho,SELECT_BY_TICKET,MODE_TRADES))
         {
            if(OrderType()==OP_BUY||OrderType()==OP_SELL)//Lenh cho da hit
            {
               glbTapLenh[glbTongSoLenh]=OrderTicket();
               glbTongSoLenh++;
               glbGiaVaoLenhTruocDo=OrderOpenPrice();
               glbKhoiLuongVaoLenhTruocDo=OrderLots();
               glbLoaiLenhCuaLenhTruocDo=OrderType();
               glbTongKhoiLuongDaVao+=OrderLots();
               double GiaSLLenhCho=OrderStopLoss();
               double GiaTPLenhCho=OrderTakeProfit();
               FunDichSLTPSauKhiHitLenhLimit(OrderType(),GiaTPLenhCho,GiaSLLenhCho);
               glbLenhCho=-1;
               FunVaoLenhChoTiepTheo();
            }
         }
      }
      if(glbTongSoLenh<=0)
         Comment("Doi lenh.\nLenh BUY STOP: ", glbLenhStopBuyDauTien, "\nLenh SELL STOP: ", glbLenhStopSellDauTien);
      else Comment("Tong so lenh: ", glbTongSoLenh, "\nSo Lots da vao: ",glbTongKhoiLuongDaVao,"\nLenh cho: ", glbLenhCho);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+  
 void FunVaoLenhChoTiepTheo()
 {
   double KhoiLuong=0, DiemVaoLenh=0, PipSL=0,PipTP=0, KhoangCachNhoiLenh=0;
   int LoaiLenhCho, ticket=-1;;
   KhoiLuong=inpHeSoNhanKhoiLuong*glbKhoiLuongVaoLenhTruocDo;
   KhoiLuong=NormalizeDouble(KhoiLuong,FunPhanThapPhanKhoiLuong());
   if(KhoiLuong+glbTongKhoiLuongDaVao>inpKhoiLuongDungNhoiLenh)
   {
      Print("DA VAO DU KHOI LUONG CHO PHEP. KHONG VAO THEM LENH CHO STOP");
      return;
   }
   
   KhoangCachNhoiLenh=TinhKhoangCachDeNhoiLenhCho();
   
   PipTP=TinhSoPipTPCuaLenhCho();
   if(glbLoaiLenhCuaLenhTruocDo==OP_BUY)
   {
      LoaiLenhCho=OP_SELLSTOP;
      DiemVaoLenh=glbGiaVaoLenhTruocDo-KhoangCachNhoiLenh*10*Point();
      
   }
   else 
   {
      LoaiLenhCho=OP_BUYSTOP;
      DiemVaoLenh=glbGiaVaoLenhTruocDo+KhoangCachNhoiLenh*10*Point();
   }
   DiemVaoLenh=NormalizeDouble(DiemVaoLenh,Digits);
   ticket=FunVaoLenh(LoaiLenhCho,DiemVaoLenh,0,PipTP,KhoiLuong);
   if(ticket<0)
      Print("VAO LENH CHO BI LOI. LOAI LENH: ", LoaiLenhCho, " Diem vao lenh: ", DiemVaoLenh, " Khoi luong: ", KhoiLuong, "PipTP: ", PipTP);
   glbLenhCho=ticket;
 }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+  
short FunKiemTraNenXanhHayDo()//0: Xanh, 1; Do, -1: khong xac dinh
{
   if(Close[1]>Open[1]) return 0;
   if(Close[1]<Open[1]) return 1;
   return -1;
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void FunXuLyKhiBotBiThoat()
{
   // Dem so lenh cho
   int DemSoLenhCho=0;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderMagicNumber()==inpMagicNumber && OrderSymbol()==Symbol())
         {
            if(OrderType()==OP_BUY||OrderType()==OP_SELL)
            {
               glbTapLenh[glbTongSoLenh]=OrderTicket();
               glbTongSoLenh++;
               glbTongKhoiLuongDaVao+=OrderLots();
            }
            else 
            {  
               glbLenhCho=OrderTicket();
               DemSoLenhCho++;
            }
         }
      }
   }
   if(DemSoLenhCho>1) FunReSet();// Dang co 2 lenh cho, khong xac dinh duowc
   if(glbLenhCho<=0) FunReSet();// Khong co lenh cho nao
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double TinhSoPipTPCuaLenhCho()
{
   double KhoangCach=0;
   if(glbTongSoLenh==1)
      KhoangCach=inpKhoangCachCoSo;
   else
      KhoangCach=inpKhoangCachCoSo+inpKhoangCachCoSo*inpHeSoA*MathPow(inpHeSoB,glbTongSoLenh-2);
   return (KhoangCach);
   
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double TinhKhoangCachDeNhoiLenhCho()
{
   double KhoangCach=0;
   if(glbTongSoLenh==1)
      KhoangCach=inpKhoangCachCoSo;
   else
      KhoangCach=inpKhoangCachCoSo+inpKhoangCachCoSo*inpHeSoA*MathPow(inpHeSoB,glbTongSoLenh-2);
   return (KhoangCach);   
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void FunDichSLTPSauKhiHitLenhLimit(int LoaiLenhVuaHitLimit, double GiaTPLenhLimit, double GiaSLLenhLimit)
{
   for(int i=0;i<glbTongSoLenh;i++)
   {
      if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES))
      {
         double GiaSL=0;
         double GiaTP=0;
         if(OrderType()==LoaiLenhVuaHitLimit)
         {
             if(GiaSLLenhLimit==0)GiaSL=OrderStopLoss();
             else GiaSL=GiaSLLenhLimit;
             if(GiaTPLenhLimit==0)GiaTP=OrderTakeProfit();
             else GiaTP=GiaTPLenhLimit;
             
         }
         else 
         {
            if(GiaTPLenhLimit==0)GiaSL=OrderStopLoss();
             else GiaSL=GiaTPLenhLimit;
             if(GiaSLLenhLimit==0)GiaTP=OrderTakeProfit();
             else GiaTP=GiaSLLenhLimit;
            
         }
         if(GiaSL!=OrderStopLoss() || GiaTP!=OrderTakeProfit())
         {
            if(OrderModify(OrderTicket(),OrderOpenPrice(),GiaSL,GiaTP,clrNONE)==false)
            {
               Print("Loi dich SL, TP. Ticket: ",OrderTicket(), "Gia SL: ", GiaSL, " GiaTP: ", GiaTP);
            }
        }
         
      }
   }
}
//+------------------------------------------------------------------+
void FunKiemTraXoaLenhKhoiMang()
{
   for(int i=0;i<glbTongSoLenh;i++)
   {
      if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET))
      {
         if(OrderCloseTime()>0)
         {
            for(int j=i;j<glbTongSoLenh-1;j++)
            {
               glbTapLenh[j]=glbTapLenh[j+1];
            }
            glbTongSoLenh--;
         }
      }
   }
}


//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
 void FunKiemTraDongLenhBangTay()
{
   for(int i=0;i<glbTongSoLenh;i++)
   {
      if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET))
      {
         if(OrderCloseTime()>0)
         {
            FunDongTatCaCacLenh();
         }
      }
   }
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int FunPhanThapPhanKhoiLuong()
{
   double lot_step=MarketInfo(Symbol(),MODE_LOTSTEP);
   if(lot_step==0.01) return 2;
   if(lot_step==0.05) return 2;
   if(lot_step==0.1) return 1;
   return 0;
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
 void FunDongTatCaCacLenh()
{
   while(glbTongSoLenh>0)
   {
      if(OrderSelect(glbTapLenh[glbTongSoLenh-1],SELECT_BY_TICKET))
      {
         if(OrderCloseTime()>0)
         {
            //glbTongLoiLoCuaTatCaCacChuKy+=OrderProfit()+OrderCommission()+OrderSwap();
            glbTapLenh[glbTongSoLenh-1]=-1;
            glbTongSoLenh--;
         }
         else
         {
            if(OrderType()==OP_BUY)
            {
               if(!OrderClose(OrderTicket(),OrderLots(),Bid,500,clrBlue))
               {
                  Print(Symbol(),": Loi dong lenh Buy");
               }
               else 
               {  glbTapLenh[glbTongSoLenh-1]=-1;glbTongSoLenh--;
               }
                  
            }
            else if(OrderType()==OP_SELL)
            {
               if(!OrderClose(OrderTicket(),OrderLots(),Ask,500,clrRed))
               {
                  Print(Symbol(),":Loi dong lenh Sell");  
               }
               else 
               {  
                  glbTapLenh[glbTongSoLenh-1]=-1;glbTongSoLenh--;
              }
            }
         }
      }
   }
   while(glbLenhCho>0)
   {
      if(OrderDelete(glbLenhCho))
      {
         glbLenhCho=-1;  
      }
   }
   FunReSet();
 }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void FunReSet()
{
   glbTongSoLenh=0;
   glbLoaiLenhCuaLenhTruocDo=-1;
   glbKhoiLuongVaoLenhTruocDo=0;
   glbLenhCho=-1;
   glbGiaVaoLenhTruocDo=0;
   glbKhoangCachCoSo=0;
   glbTongKhoiLuongDaVao=0;
   glbLenhStopBuyDauTien=-1;
   glbLenhStopSellDauTien=-1;
}
 //+------------------------------------------------------------------+
//+------------------------------------------------------------------+
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
      case OP_SELLLIMIT:return "SELL";
      break;
      case OP_BUYSTOP:return "BUY STOP";
      break;
      case OP_SELLSTOP:return "SELL STOP";
      break;
      default: return "ERROR";
   }
 }
int FunVaoLenh(int LoaiLenh, double DiemVaoLenh,double StopLossPips, double TakeProfitPips, double KhoiLuongVaoLenh)
{
    int Ticket=-1;
    double StopLoss=0,TakeProfit=0;
    if(KhoiLuongVaoLenh==0) return -1;
    
    if(LoaiLenh==OP_BUY || LoaiLenh==OP_BUYLIMIT || LoaiLenh==OP_BUYSTOP)
    {
       if(StopLossPips>0)StopLoss=DiemVaoLenh-StopLossPips*10*Point();
       if(TakeProfitPips>0)TakeProfit=DiemVaoLenh+TakeProfitPips*10*Point(); 
       StopLoss=NormalizeDouble(StopLoss,Digits); 
       TakeProfit=NormalizeDouble(TakeProfit,Digits); 
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,"Vao lenh Buy",inpMagicNumber,0,clrBlue);
    }
    if(LoaiLenh==OP_SELL|| LoaiLenh==OP_SELLLIMIT || LoaiLenh==OP_SELLSTOP)
    {
       if(StopLossPips>0)StopLoss=DiemVaoLenh+StopLossPips*10*Point();
       if(TakeProfitPips>0)TakeProfit=DiemVaoLenh-TakeProfitPips*10*Point();  
       StopLoss=NormalizeDouble(StopLoss,Digits); 
       TakeProfit=NormalizeDouble(TakeProfit,Digits); 
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,"Vao lenh Sell",inpMagicNumber,0,clrRed);
    }
    return Ticket;
}
int FunVaoLenhBuySellNgayLapTuc(int LoaiLenh,double StopLossPips, double TakeProfitPips, double KhoiLuongVaoLenh)
{
    int Ticket=-1;
    double StopLoss=0,TakeProfit=0;
    if(KhoiLuongVaoLenh==0) return -1;
    
    if(LoaiLenh==OP_BUY)
    {
       if(StopLossPips>0)StopLoss=Ask-StopLossPips*10*Point();
       if(TakeProfitPips>0)TakeProfit=Ask+TakeProfitPips*10*Point();  
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,Ask,inpSlippage,StopLoss,TakeProfit,"Vao lenh Buy",inpMagicNumber,0,clrBlue);
    }
    if(LoaiLenh==OP_SELL)
    {
       if(StopLossPips>0)StopLoss=Bid+StopLossPips*10*Point();
       if(TakeProfitPips>0)TakeProfit=Bid-TakeProfitPips*10*Point();  
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,Bid,inpSlippage,StopLoss,TakeProfit,"Vao lenh Sell",inpMagicNumber,0,clrRed);
    }
    return Ticket;
}

//+------------------------------------------------------------------+
bool FunKiemTraHetHan(NgayThang &HanCanKiemTra)// False: Da het han; True: Chưa
{
   bool kt=true;
   if(Year()>HanCanKiemTra.Nam)
    {
         MessageBox("EA het han su dung. De gia han Vui long truy cap website tailieuforex.com. Hoac lien he SDT: 0971926248");
         ExpertRemove();
         kt=false;
    }
      if(Year()==HanCanKiemTra.Nam && Month()>HanCanKiemTra.Thang)
    {
         MessageBox("EA het han su dung. De gia han Vui long truy cap website tailieuforex.com. Hoac lien he SDT: 0971926248");
         ExpertRemove();
         kt=false;   
    }
    if(Year()==HanCanKiemTra.Nam && Month()==HanCanKiemTra.Thang && Day()>HanCanKiemTra.Ngay)  
    {
        MessageBox("EA het han su dung. De gia han Vui long truy cap website tailieuforex.com. Hoac lien he SDT: 0971926248");
         ExpertRemove();
         kt=false;
    }
    return kt;
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
