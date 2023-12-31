//+------------------------------------------------------------------+
//|                                                Buy_sell_gold.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
/*
Buy sell lien tuc
Cu di X gia la buy sell tiep
Ngoai vung gia can tren: Chi sell
Ngoai vung gia can duoi: chi buy
*/
struct NgayThang
  {
   int          Ngay; // date
   int            Thang;  // bid price
   int            Nam;  // ask price
  };
NgayThang glbNgayHetHan={30,02,3023};
struct Str_Gia_lenh
{
   double VungGia;
   int TicketBuy;
   int TicketSell;
};
input double inpKhoiLuong=0.01;//Khoi luong vao lenh:
input double inpCanTren=0;//Gia Can tren:
input double inpCanDuoi=0;// Gia can duoi:
input double inpBuocNhay=10;// Buoc nhay gia (pips):
input int inpMagicNumber=123;//Magic number:
input int inpSlippage=50;//Slippage:
int glbSlippage=0;
Str_Gia_lenh glbTapVungGiaVaoLenh[200];
int glbTongVungGiaVaoLenh=0;
int glbLenhChoSell=-1;
int glbLenhChoBuy=-1;
double glbCanTrenGanNhat=0;
double glbCanDuoiGanNhat=0;
double glbBuocNhay=0;
Str_Gia_lenh glbLenhCanTren, glbLenhCanDuoi;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   glbSlippage=inpSlippage;
   glbBuocNhay=inpBuocNhay*10*Point();
   //glbTongVungGiaVaoLenh=0;
   if(FunKiemTraHetHan(glbNgayHetHan)==false)
      return INIT_FAILED;
   if(inpCanTren==inpCanDuoi || (inpCanTren==0 || inpCanDuoi==0))
   {
      MessageBox("Loi Nhap gia tri tham so truoc khi vao lenh");
      Print("Loi Nhap gia tri tham so truoc khi vao lenh");
      return INIT_FAILED;
   }
   if(glbTongVungGiaVaoLenh==0)
   {
      // Khoi tao can tren, can duoi
      FunTimCanTrenCanDuoiGanNhatKhiKhoiTaoBot();
      /*
      if(Bid>inpCanTren)
      {
         glbCanTrenGanNhat=0;
         glbCanDuoiGanNhat=inpCanTren;
         glbLenhCanTren.VungGia=0;
         glbLenhCanDuoi.VungGia=inpCanTren;
      }
      if(Bid<inpCanDuoi)
      {
         glbCanTrenGanNhat=inpCanDuoi;
         glbCanDuoiGanNhat=0;
         glbLenhCanDuoi.VungGia=0;
         glbLenhCanTren.VungGia=inpCanDuoi;
      }
      */
      glbLenhCanTren.VungGia=glbCanTrenGanNhat;
      glbLenhCanDuoi.VungGia=glbCanDuoiGanNhat;
      if(glbCanTrenGanNhat>0)
      {
        
        // glbLenhCanTren.TicketBuy=FunVaoLenh(OP_BUYSTOP,glbLenhCanTren.VungGia,0,glbLenhCanTren.VungGia+glbBuocNhay,inpKhoiLuong);
        // glbLenhCanTren.TicketSell=FunVaoLenh(OP_SELLLIMIT,glbLenhCanTren.VungGia,0,glbLenhCanTren.VungGia-glbBuocNhay,inpKhoiLuong);
         
         glbTapVungGiaVaoLenh[glbTongVungGiaVaoLenh]=FunVaoLenhMoiChoCanTren(glbCanTrenGanNhat);
         glbTongVungGiaVaoLenh++;
      }
      if(glbCanDuoiGanNhat>0)
      {
        // glbLenhCanDuoi.TicketSell=FunVaoLenh(OP_SELLSTOP,glbLenhCanDuoi.VungGia,0,glbLenhCanDuoi.VungGia-glbBuocNhay,inpKhoiLuong);
        // glbLenhCanDuoi.TicketBuy=FunVaoLenh(OP_BUYLIMIT,glbLenhCanDuoi.VungGia,0,glbLenhCanDuoi.VungGia+glbBuocNhay,inpKhoiLuong);
         glbTapVungGiaVaoLenh[glbTongVungGiaVaoLenh]=FunVaoLenhMoiChoCanDuoi(glbCanDuoiGanNhat);
         glbTongVungGiaVaoLenh++;
      }
   }
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
      //Print("Can tren: ", glbCanTrenGanNhat, "Can duoi: ", glbCanDuoiGanNhat);   
      Comment("Can tren: ", glbCanTrenGanNhat, "Can duoi: ", glbCanDuoiGanNhat);   
      if((glbCanTrenGanNhat>0 && Bid>=glbCanTrenGanNhat) || (glbCanDuoiGanNhat>0 && Bid <=glbCanDuoiGanNhat))
      {
         // Xoa lenh bi dong
         FunXoaLenhBiDong();
         // Xac dinh can tren, can duoi moi
         if(glbCanTrenGanNhat>0 && Bid>=glbCanTrenGanNhat)
         {
            glbCanDuoiGanNhat=glbCanTrenGanNhat-glbBuocNhay;
            glbCanTrenGanNhat=glbCanTrenGanNhat+glbBuocNhay;
         }
         else
         {
            glbCanTrenGanNhat=glbCanDuoiGanNhat+glbBuocNhay;
            glbCanDuoiGanNhat=glbCanDuoiGanNhat-glbBuocNhay;
         }
         Print("Can tren moi: ", glbCanTrenGanNhat, "Can duoi moi: ", glbCanDuoiGanNhat, " Gia hien tai: ", Bid);   
         int vtCanTren=FunTimViTriCuaVungGiaTrongMang(glbCanTrenGanNhat);
         if(vtCanTren>=0)
         {
            FunXuLyVungGiaCanTrenCoSanTrongMang(vtCanTren);            
         }
         else
         {
            glbTapVungGiaVaoLenh[glbTongVungGiaVaoLenh]=FunVaoLenhMoiChoCanTren(glbCanTrenGanNhat);
            glbTongVungGiaVaoLenh++;
         }
         int vtCanDuoi=FunTimViTriCuaVungGiaTrongMang(glbCanDuoiGanNhat);
         if(vtCanDuoi>=0)
         {
            FunXuLyVungGiaCanDuoiCoSanTrongMang(vtCanDuoi);
         }
         else
         {
            glbTapVungGiaVaoLenh[glbTongVungGiaVaoLenh]=FunVaoLenhMoiChoCanDuoi(glbCanDuoiGanNhat);
            glbTongVungGiaVaoLenh++;
         }
         // Xoa cac lenh cho cua cac vung gia nawm tren can tren va nam duoi can duoi
         for(int i=0;i<glbTongVungGiaVaoLenh;i++)
         {
            if(glbTapVungGiaVaoLenh[i].VungGia>glbCanTrenGanNhat || glbTapVungGiaVaoLenh[i].VungGia<glbCanDuoiGanNhat)
            {
               if(OrderSelect(glbTapVungGiaVaoLenh[i].TicketBuy,SELECT_BY_TICKET,MODE_TRADES))
               {
                  if(OrderType()==OP_BUYSTOP || OrderType()==OP_BUYLIMIT)
                  {
                     if(OrderDelete(OrderTicket()))
                        glbTapVungGiaVaoLenh[i].TicketBuy=-1;
                  }
               }
               if(OrderSelect(glbTapVungGiaVaoLenh[i].TicketSell,SELECT_BY_TICKET,MODE_TRADES))
               {
                  if(OrderType()==OP_SELLSTOP || OrderType()==OP_SELLLIMIT)
                  {
                     if(OrderDelete(OrderTicket()))
                        glbTapVungGiaVaoLenh[i].TicketSell=-1;
                  }
               }              
            }         
         }
      }
  }
 //+------------------------------------------------------------------+ 
 
void FunTimCanTrenCanDuoiGanNhatKhiKhoiTaoBot()
{
   if(Bid>=inpCanTren)
   {
      glbCanTrenGanNhat=0;
      glbCanDuoiGanNhat=inpCanTren;
   }
   else if(Bid<=inpCanDuoi)
   {
      glbCanTrenGanNhat=inpCanDuoi;
      glbCanDuoiGanNhat=0;   
   }
   else
   {
      double CanTren=0;
      CanTren=inpCanDuoi;
      while(CanTren<Bid)
      {
         CanTren+=glbBuocNhay;
      }
      glbCanTrenGanNhat=CanTren;
      glbCanDuoiGanNhat=CanTren-glbBuocNhay;
   }
}
void FunXoaLenhBiDong()
{
  for(int i=0;i<glbTongVungGiaVaoLenh;i++)
  {
    if(OrderSelect(glbTapVungGiaVaoLenh[i].TicketBuy,SELECT_BY_TICKET,MODE_TRADES))
    {
      if(OrderCloseTime()>0)
         glbTapVungGiaVaoLenh[i].TicketBuy=-1;
    }
    if(OrderSelect(glbTapVungGiaVaoLenh[i].TicketSell,SELECT_BY_TICKET,MODE_TRADES))
    {
      if(OrderCloseTime()>0)
         glbTapVungGiaVaoLenh[i].TicketSell=-1;
    }           
  }
}
//+------------------------------------------------------------------+
void FunXuLyVungGiaCanTrenCoSanTrongMang(int i)//i val vi tri
{
   /*
   int vitriVungGiaTrenGanNhat=FunTimViTriCuaVungGiaTrongMang(glbTapVungGiaVaoLenh[i].VungGia+glbBuocNhay);
   if(vitriVungGiaTrenGanNhat>=0)
   {
      if(glbTapVungGiaVaoLenh[i].TicketBuy<=0)// can tren chua co lenh buy stop, dich lenh buy stop o can tren gan nhat ve day
      {
         if(OrderSelect(glbTapVungGiaVaoLenh[vitriVungGiaTrenGanNhat].TicketBuy,SELECT_BY_TICKET,MODE_TRADES))
         {
            if(OrderType()==OP_BUYSTOP)
            {
               if(OrderModify(OrderTicket(),OrderOpenPrice()-glbBuocNhay,OrderStopLoss(),OrderTakeProfit()-glbBuocNhay,0,clrNONE))
               {
                  glbTapVungGiaVaoLenh[i].TicketBuy=glbTapVungGiaVaoLenh[vitriVungGiaTrenGanNhat].TicketBuy;
                  glbTapVungGiaVaoLenh[vitriVungGiaTrenGanNhat].TicketBuy=-1;
               }
            }
         }
      }
      else // can tren dang co lenh buy roi
      {
         // Xo lenh buy stop cua can tren gan nhat
         if(OrderSelect(glbTapVungGiaVaoLenh[vitriVungGiaTrenGanNhat].TicketBuy,SELECT_BY_TICKET,MODE_TRADES))
         {
            if(OrderType()==OP_BUYSTOP)
            {
               if(OrderDelete(OrderTicket()))
                  glbTapVungGiaVaoLenh[vitriVungGiaTrenGanNhat].TicketBuy=-1;
            }
         }
      }
      
      if(glbTapVungGiaVaoLenh[i].TicketSell<=0)// can tren chua co lenh SELL limit, dich lenh SELL limit o can tren gan nhat ve day
      {
         if(OrderSelect(glbTapVungGiaVaoLenh[vitriVungGiaTrenGanNhat].TicketSell,SELECT_BY_TICKET,MODE_TRADES))
         {
            if(OrderType()==OP_SELLLIMIT)
            {
               if(OrderModify(OrderTicket(),OrderOpenPrice()-glbBuocNhay,OrderStopLoss(),OrderTakeProfit()-glbBuocNhay,0,clrNONE))
               {
                  glbTapVungGiaVaoLenh[i].TicketSell=glbTapVungGiaVaoLenh[vitriVungGiaTrenGanNhat].TicketSell;
                  glbTapVungGiaVaoLenh[vitriVungGiaTrenGanNhat].TicketSell=-1;
               }
            }
         }
      }
      else // can tren dang co lenh sell roi
      {
         // Xo lenh sell cua can tren gan nhat
         if(OrderSelect(glbTapVungGiaVaoLenh[vitriVungGiaTrenGanNhat].TicketSell,SELECT_BY_TICKET,MODE_TRADES))
         {
            if(OrderType()==OP_SELLLIMIT)
            {
               if(OrderDelete(OrderTicket()))
                  glbTapVungGiaVaoLenh[vitriVungGiaTrenGanNhat].TicketSell=-1;
            }
         }
      }
   }
   */
   if(glbTapVungGiaVaoLenh[i].VungGia>inpCanTren) // chi co lenh sell
   {
      if(glbTapVungGiaVaoLenh[i].TicketSell<=0)
         glbTapVungGiaVaoLenh[i].TicketSell=FunVaoLenh(OP_SELLLIMIT,glbTapVungGiaVaoLenh[i].VungGia,0,glbTapVungGiaVaoLenh[i].VungGia-glbBuocNhay,inpKhoiLuong);
      
   }
   else if(glbTapVungGiaVaoLenh[i].VungGia<inpCanDuoi)// Chi co lenh buy
   {
      if(glbTapVungGiaVaoLenh[i].TicketBuy<=0)
         glbTapVungGiaVaoLenh[i].TicketBuy=FunVaoLenh(OP_BUYSTOP,glbTapVungGiaVaoLenh[i].VungGia,0,glbTapVungGiaVaoLenh[i].VungGia+glbBuocNhay,inpKhoiLuong);
   }
   else // co ca buy va sell
   {
      if(glbTapVungGiaVaoLenh[i].TicketBuy<=0)
         glbTapVungGiaVaoLenh[i].TicketBuy=FunVaoLenh(OP_BUYSTOP,glbTapVungGiaVaoLenh[i].VungGia,0,glbTapVungGiaVaoLenh[i].VungGia+glbBuocNhay,inpKhoiLuong);
      if(glbTapVungGiaVaoLenh[i].TicketSell<=0)
         glbTapVungGiaVaoLenh[i].TicketSell=FunVaoLenh(OP_SELLLIMIT,glbTapVungGiaVaoLenh[i].VungGia,0,glbTapVungGiaVaoLenh[i].VungGia-glbBuocNhay,inpKhoiLuong);
   }
   Print("CAP NHAT LENH CUA VUNG GIA CAN TREN: LENH BUY : ", glbTapVungGiaVaoLenh[i].TicketBuy, " LENH SELL : ", glbTapVungGiaVaoLenh[i].TicketSell);
}

//+------------------------------------------------------------------+
void FunXuLyVungGiaCanDuoiCoSanTrongMang(int i)
{
   /*
   int vitriVungGiaCanDuoiGanNhat=FunTimViTriCuaVungGiaTrongMang(glbTapVungGiaVaoLenh[i].VungGia-glbBuocNhay);
   if(vitriVungGiaCanDuoiGanNhat>=0)
   {
      if(glbTapVungGiaVaoLenh[i].TicketSell<=0)// chua co lenh SELL STOP
      {
         if(OrderSelect(glbTapVungGiaVaoLenh[vitriVungGiaCanDuoiGanNhat].TicketSell,SELECT_BY_TICKET,MODE_TRADES))
         {
            if(OrderType()==OP_SELLSTOP)
            {
               if(OrderModify(OrderTicket(),OrderOpenPrice()+glbBuocNhay,OrderStopLoss(),OrderTakeProfit()+glbBuocNhay,0,clrNONE))
               {
                  glbTapVungGiaVaoLenh[i].TicketSell=glbTapVungGiaVaoLenh[vitriVungGiaCanDuoiGanNhat].TicketSell;
                  glbTapVungGiaVaoLenh[vitriVungGiaCanDuoiGanNhat].TicketSell=-1;
               }
               
            }
         }
      }
      else
      {
         // Xoa lenh SELL STOP o can duoi gan nhat
         if(OrderSelect(glbTapVungGiaVaoLenh[vitriVungGiaCanDuoiGanNhat].TicketSell,SELECT_BY_TICKET,MODE_TRADES))
         {
            if(OrderType()==OP_SELLSTOP)
            {
               if(OrderDelete(OrderTicket()))
                  glbTapVungGiaVaoLenh[vitriVungGiaCanDuoiGanNhat].TicketSell=-1;
            }
         }
      }
      
      if(glbTapVungGiaVaoLenh[i].TicketBuy<=0)// chua co lenh buy limt
      {
         if(OrderSelect(glbTapVungGiaVaoLenh[vitriVungGiaCanDuoiGanNhat].TicketBuy,SELECT_BY_TICKET,MODE_TRADES))
         {
            if(OrderType()==OP_BUYLIMIT)
            {
               if(OrderModify(OrderTicket(),OrderOpenPrice()+glbBuocNhay,OrderStopLoss(),OrderTakeProfit()+glbBuocNhay,0,clrNONE))
               {
                  glbTapVungGiaVaoLenh[i].TicketBuy=glbTapVungGiaVaoLenh[vitriVungGiaCanDuoiGanNhat].TicketBuy;
                  glbTapVungGiaVaoLenh[vitriVungGiaCanDuoiGanNhat].TicketBuy=-1;
               }
            }
         }
      }
      else
      {
         // Xo lenh buy limit cua can duoi gan nhat
         if(OrderSelect(glbTapVungGiaVaoLenh[vitriVungGiaCanDuoiGanNhat].TicketSell,SELECT_BY_TICKET,MODE_TRADES))
         {
            if(OrderType()==OP_BUYLIMIT)
            {
               if(OrderDelete(OrderTicket()))
                  glbTapVungGiaVaoLenh[vitriVungGiaCanDuoiGanNhat].TicketSell=-1;
            }
         }
      }
      
   }
   */
   if(glbTapVungGiaVaoLenh[i].VungGia>inpCanTren) // chi co lenh sell
   {
      if(glbTapVungGiaVaoLenh[i].TicketSell<=0)
         glbTapVungGiaVaoLenh[i].TicketSell=FunVaoLenh(OP_SELLSTOP,glbTapVungGiaVaoLenh[i].VungGia,0,glbTapVungGiaVaoLenh[i].VungGia-glbBuocNhay,inpKhoiLuong);
   }
   else if(glbTapVungGiaVaoLenh[i].VungGia<inpCanDuoi)// Chi co lenh buys
   {
      
      if(glbTapVungGiaVaoLenh[i].TicketBuy<=0)
         glbTapVungGiaVaoLenh[i].TicketBuy=FunVaoLenh(OP_BUYLIMIT,glbTapVungGiaVaoLenh[i].VungGia,0,glbTapVungGiaVaoLenh[i].VungGia+glbBuocNhay,inpKhoiLuong);
   }
   else // co ca buy va sell
   {
      if(glbTapVungGiaVaoLenh[i].TicketBuy<=0)
         glbTapVungGiaVaoLenh[i].TicketBuy=FunVaoLenh(OP_BUYLIMIT,glbTapVungGiaVaoLenh[i].VungGia,0,glbTapVungGiaVaoLenh[i].VungGia+glbBuocNhay,inpKhoiLuong);
      if(glbTapVungGiaVaoLenh[i].TicketSell<=0)
         glbTapVungGiaVaoLenh[i].TicketSell=FunVaoLenh(OP_SELLSTOP,glbTapVungGiaVaoLenh[i].VungGia,0,glbTapVungGiaVaoLenh[i].VungGia-glbBuocNhay,inpKhoiLuong);
   }
   Print("CAP NHAT LENH CUA VUNG GIA CAN DUOI. LENH BUY : ", glbTapVungGiaVaoLenh[i].TicketBuy, " LENH SELL : ", glbTapVungGiaVaoLenh[i].TicketSell);
}
//+------------------------------------------------------------------+
Str_Gia_lenh FunVaoLenhMoiChoCanTren(double VungGiaCanTren)
{
    Str_Gia_lenh VungGiaLenh;
    VungGiaLenh.VungGia=VungGiaCanTren;
    if(VungGiaCanTren>inpCanTren)
    {
       VungGiaLenh.TicketBuy=-1;
       VungGiaLenh.TicketSell=FunVaoLenh(OP_SELLLIMIT,VungGiaCanTren,0,VungGiaCanTren-glbBuocNhay,inpKhoiLuong);
    }
    else if(VungGiaCanTren<inpCanDuoi)
    {   
      VungGiaLenh.TicketSell=-1;
      VungGiaLenh.TicketBuy=FunVaoLenh(OP_BUYSTOP,VungGiaCanTren,0,VungGiaCanTren+glbBuocNhay,inpKhoiLuong);
    }
    else
    {
         VungGiaLenh.TicketBuy=FunVaoLenh(OP_BUYSTOP,VungGiaCanTren,0,VungGiaCanTren+glbBuocNhay,inpKhoiLuong);
         VungGiaLenh.TicketSell=FunVaoLenh(OP_SELLLIMIT,VungGiaCanTren,0,VungGiaCanTren-glbBuocNhay,inpKhoiLuong);
    }
    Print("VUNG GIA LENH CAN TREN DUOC THEM VAO MANG. LENH BUY STOP: ", VungGiaLenh.TicketBuy, " LENH SELL LIMIT: ", VungGiaLenh.TicketSell);
  return VungGiaLenh;
}
//+------------------------------------------------------------------+
Str_Gia_lenh FunVaoLenhMoiChoCanDuoi(double VungGiaCanDuoi)
{
   Str_Gia_lenh VungGiaLenh;
    VungGiaLenh.VungGia=VungGiaCanDuoi;
    if(VungGiaCanDuoi>inpCanTren)
    {
      VungGiaLenh.TicketBuy=-1;
      VungGiaLenh.TicketSell=FunVaoLenh(OP_SELLSTOP,VungGiaCanDuoi,0,VungGiaCanDuoi-glbBuocNhay,inpKhoiLuong);
    }
    else if(VungGiaCanDuoi<inpCanDuoi)
    {    
      VungGiaLenh.TicketSell=-1;
      VungGiaLenh.TicketBuy=FunVaoLenh(OP_BUYLIMIT,VungGiaCanDuoi,0,VungGiaCanDuoi+glbBuocNhay,inpKhoiLuong);
    }
    else
    {
         VungGiaLenh.TicketBuy=FunVaoLenh(OP_BUYLIMIT,VungGiaCanDuoi,0,VungGiaCanDuoi+glbBuocNhay,inpKhoiLuong);
         VungGiaLenh.TicketSell=FunVaoLenh(OP_SELLSTOP,VungGiaCanDuoi,0,VungGiaCanDuoi-glbBuocNhay,inpKhoiLuong);
    }
    Print("VUNG GIA LENH CAN DUOI DUOC THEM VAO MANG. LENH BUY LIMIT: ", VungGiaLenh.TicketBuy, " LENH SELL STOP: ", VungGiaLenh.TicketSell);
   return VungGiaLenh;
}
//+------------------------------------------------------------------+
// 
int FunTimViTriCuaVungGiaTrongMang(double VungGiaCanTim)
{
   for(int i=0;i<glbTongVungGiaVaoLenh;i++)
   {
      if(glbTapVungGiaVaoLenh[i].VungGia==VungGiaCanTim)
         return i;
   }
   return -1;
}
//+------------------------------------------------------------------+
int FunVaoLenh(int LoaiLenh, double DiemVaoLenh,double StopLoss, double TakeProfit, double KhoiLuongVaoLenh)
{
    int Ticket=-1;
    if(KhoiLuongVaoLenh==0) return -1;
    if(LoaiLenh==OP_BUY || LoaiLenh==OP_BUYLIMIT || LoaiLenh==OP_BUYSTOP)
    { 
      //if(StopLoss>=DiemVaoLenh || TakeProfit<=DiemVaoLenh) return -1;
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,"Vao lenh Buy",inpMagicNumber,0,clrBlue);
    }
    if(LoaiLenh==OP_SELL|| LoaiLenh==OP_SELLLIMIT || LoaiLenh==OP_SELLSTOP)
    {  
      //if(StopLoss<=DiemVaoLenh || TakeProfit>=DiemVaoLenh) return -1;
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,"Vao lenh Sell",inpMagicNumber,0,clrRed);
    }
    if(Ticket==-1)
      Print("Loi vao lenh. Gia hien tai: ", Bid, " Lenh vao: ",FunTraVeTenLenh(LoaiLenh), " Gia vao lenh: ", DiemVaoLenh," SL: ",StopLoss, " TP: ", TakeProfit);
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
 