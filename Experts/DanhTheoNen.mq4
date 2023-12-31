//+------------------------------------------------------------------+
//|                                                  DanhTheoNen.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
/*
Bot vào lệnh SELL cho cây nến SỐ 1 có SL là đỉnh râu của nến đỏ. 
Trường hợp 1 nếu nến xanh ý nó xuống luôn thì kệ nó xuống vì k đặt TP. 
Trường hợp 2 nếu nến xanh đó lên chạm SL (đương nhiên cắt thua lệnh đó) 
nhưng vào tiếp 1 lệnh từ điểm SL lệnh BUY và có SL = đỉnh dưới râu nên trước. 
Trường hợp 3 như nên xanh chạy lên và hết 15' đóng nến xanh mà k chạm SL 
vì đang chạy ngược so với mình đánh nên BOT tự động cắt lỗ. Thì hết giờ nến đóng chỗ nào ta cắt lệnh SELL cho cây nến SỐ 2
 đi đặt lệnh BUY từ giá trị đóng nến và có SL = đỉnh râu dưới cây nến xanh 
 
Cây nến SỐ 2 chạy lên xanh luôn và đóng nến xanh khi hết 15' tiếp theo. 
- Bot chuẩn bị đánh lệnh tiếp cho cây nến SÔ 3. 
=> Hết 15' của cây nến 2 đóng xanh dịch SL của lệnh BUY trước vào râu nến dưới của cây nến SÔ 2. 
Vào nhồi tiếp lệnh BUY cho cây nến Số 3 và đặt SL bằng râu dưới của nến SỐ 2  

Cây nến SỐ 2 chạy lên xanh luôn và đóng nến xanh khi hết 15' tiếp theo. 
- Bot chuẩn bị đánh lệnh tiếp cho cây nến SÔ 3. 
=> Hết 15' của cây nến 2 đóng xanh dịch SL của lệnh BUY trước vào râu nến dưới của cây nến SÔ 2. 
Vào nhồi tiếp lệnh BUY cho cây nến Số 3 và đặt SL bằng râu dưới của nến SỐ 2 
Cây nến SỐ 4 đi xuống chạm SL của 3 lệnh BUY trước đó nên tự động cắt. Cùng lúc cắt 3 lệnh BUY đó đánh lệnh SELL và đặt SL bằng đỉnh râu trên của cây nến Số 3. 
Trường hợp 1 nếu cây nến SỐ 4 nó lại quét SL của lệnh SELL . Thi khi chạm SL của lệnh SELL ta lại đánh lệnh BUY tiếp và có SL bằng đáy dưới nến SỐ 3. 
Cây nến SỐ 4 đi xuống chạm SL của 3 lệnh BUY trước đó nên tự động cắt. Cùng lúc cắt 3 lệnh BUY đó đánh lệnh SELL và đặt SL bằng đỉnh râu trên của cây nến Số 3. 
Trường hợp 1 nếu cây nến SỐ 4 nó lại quét SL của lệnh SELL . Thi khi chạm SL của lệnh SELL ta lại đánh lệnh BUY tiếp và có SL bằng đáy dưới nến SỐ 3. 
Nhồi lệnh kiểu ntn
Vd 
lệnh 1 đầu tiên là 100% 
Lệnh 2 là 50% lệnh số 1 
Lệnh 3 là 50% lệnh số 2
Lệnh 4 bằng lệnh số 3 
Lệnh 5 bằng lệnh số 3
Lệnh 6 bằng lệnh số 3
N lệnh..... = lệnh số 3
Tỉ lệ mình sẽ vào là 
Lệnh 1 là 0,4
Lệnh 2 là 0,2
Lệnh 3 là 0,1 
Lệnh 4 là 0,1
Lệnh 5 đến N lệnh bằng 0,1

*/
struct NgayThang
  {
   int          Ngay; // date
   int            Thang;  // bid price
   int            Nam;  // ask price
  };
NgayThang NgayHetHan={15,01,3023};

input double inpKhoiLuongCoSo=1;//Khoi luong lenh dau tien:
input int inpMagicNumber=2022;// Magic number:
input int inpSlippage=50;// DO truot gia:
input double inpStartTime=8;// Thoi Gian Bat Dau vao lenh (Server time):
input double inpEndTime=22;// Thoi Gian Ket Thuc vao lenh(Server time):
int glbTongSoLenh=0;
int glbTapLenh[100];
int glbTicKet=-1;
int glbLoaiLenhDangVao=-1;// -1: Chua xac dinh, 0: Buy, 1: Sell
int glbLenhStop=-1;
int glbSlippage=inpSlippage;
int glbMagicNumber=inpMagicNumber;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
       glbSlippage=inpSlippage;
       glbMagicNumber=inpMagicNumber;
       if(FunKiemDaHetHanChua(NgayHetHan)==true)return INIT_FAILED;
      
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
      if(FunKiemTraDenGioVaoLenh()==false)
      {
         if(glbTongSoLenh>0)
         {
            FunDongTatCaCacLenh();
            if(glbLenhStop>0) // xoa lenh Buy stop
            {
                if(OrderDelete(glbLenhStop))glbLenhStop=-1;
            }
         } 
         Comment("CHUA DEN GIO VAO LENH");
         return;  
      }
      FunKiemTraXoaLenhKhoiMang();
      if(glbLenhStop>0)
      {
         if(OrderSelect(glbLenhStop,SELECT_BY_TICKET,MODE_TRADES))
         {
            
            if(OrderType()==OP_BUY|| OrderType()==OP_SELL)
            {
               
               glbLoaiLenhDangVao=OrderType();
               FunDongTatCaCacLenh();
               glbTongSoLenh=0;
               glbTapLenh[glbTongSoLenh]=glbLenhStop;
               glbLenhStop=-1;
               glbTongSoLenh++;
               if(glbLoaiLenhDangVao==OP_BUY)
               {
                  glbLoaiLenhDangVao=0;
                  Print("Vao LENH SELL STOP DO CHAM SL");
                  glbLenhStop=FunVaoLenh(OP_SELLSTOP,Low[1],High[1],0,inpKhoiLuongCoSo);  
               }        
               else if(glbLoaiLenhDangVao==OP_SELL)
               {
                  glbLoaiLenhDangVao=1;
                  Print("Vao LENH BUY STOP DO CHAM SL");
                  glbLenhStop=FunVaoLenh(OP_BUYSTOP,High[1],Low[1],0,inpKhoiLuongCoSo);         
               }
            }
            if(OrderCloseTime()>0 && (OrderType()==OP_BUYSTOP|| OrderType()==OP_SELLSTOP)) {glbLenhStop=-1;}
         }
      }
      if(FunKiemTraSangNenMoiChua()==true)
      {
         Print("Thoi gian sang lenh moi:",TimeCurrent());
         FunXuLyLenhKhiSangNenMoi();
      }
      Comment("Tong lenh dang co: ",glbTongSoLenh,"\nTicket stop: ",glbLenhStop);
  }
//+------------------------------------------------------------------+
void FunXuLyLenhKhiSangNenMoi()
{
   if(FunKiemTraNenXanhDo()==0)// Nen xanh
         {
            
            if(glbLoaiLenhDangVao==-1)
            {
               // Vao lenh buy
               glbTicKet=FunVaoLenh(OP_BUY,Ask,Low[1],0,FunTinhKhoiLuongVaoLenhTiepTheo());
               if(glbTicKet>0)
               {
                  glbTapLenh[glbTongSoLenh]=glbTicKet;
                  glbTongSoLenh++;
                  glbLoaiLenhDangVao=0;
                  // Vao lenh sell stop
                  glbLenhStop=FunVaoLenh(OP_SELLSTOP,Low[1],High[1],0,inpKhoiLuongCoSo);
                  
               }
            }
            // DOng tat ca lenh sell, mo lenh buy
            else if(glbLoaiLenhDangVao==1)// Dang co lenh sell
            {
               FunDongTatCaCacLenh();// DOng tat ca lenh sell
               if(glbLenhStop>0) // xoa lenh Buy stop
               {
                  if(OrderDelete(glbLenhStop))glbLenhStop=-1;
               }
               // Vao lenh buy
               glbTicKet=FunVaoLenh(OP_BUY,Ask,Low[1],0,FunTinhKhoiLuongVaoLenhTiepTheo());
               if(glbTicKet>0)
               {
                  glbTapLenh[glbTongSoLenh]=glbTicKet;
                  glbTongSoLenh++;
                  glbLoaiLenhDangVao=0;
                  // Vao lenh sell stop
                  glbLenhStop=FunVaoLenh(OP_SELLSTOP,Low[1],High[1],0,inpKhoiLuongCoSo);
                  
               }
            }
            else if(glbLoaiLenhDangVao==0)// Dang co san lenh  buy
            {
               // Mo lenh buy moi , 
               glbTicKet=FunVaoLenh(OP_BUY,Ask,Low[1],0,FunTinhKhoiLuongVaoLenhTiepTheo());
               if(glbTicKet>0)
               {
                  glbTapLenh[glbTongSoLenh]=glbTicKet;
                  glbTongSoLenh++;
               }
               // Dich chuyen SL lenh buy
               FunDichChuyenStopLoss(Low[1]); 
               if(glbLenhStop>0)
               {
                  if(OrderSelect(glbLenhStop,SELECT_BY_TICKET,MODE_TRADES))
                  {
                     if(OrderOpenPrice()<Low[1])
                        OrderModify(glbLenhStop,Low[1],High[1],0,0,0);
                  }             
               }         
            }
         }
         else if(FunKiemTraNenXanhDo()==1)// Neens do
         {
           
            if(glbLoaiLenhDangVao==-1)
            {
               glbTicKet=FunVaoLenh(OP_SELL,Bid,High[1],0,FunTinhKhoiLuongVaoLenhTiepTheo());
               if(glbTicKet>0)
               {
                  glbTapLenh[glbTongSoLenh]=glbTicKet;
                  glbTongSoLenh++;
                  glbLoaiLenhDangVao=1;
                   // Vao lenh buy stop
                  glbLenhStop=FunVaoLenh(OP_BUYSTOP,High[1],Low[1],0,inpKhoiLuongCoSo);
               }
            }
             // Dong tat ca lenh buy, mo lenh sell
            else if(glbLoaiLenhDangVao==0)// Dang co lenh buy
            {
               FunDongTatCaCacLenh();
               if(glbLenhStop>0) // xoa lenh sell stop
               {
                  if(OrderDelete(glbLenhStop))glbLenhStop=-1;
               }
               glbTicKet=FunVaoLenh(OP_SELL,Bid,High[1],0,FunTinhKhoiLuongVaoLenhTiepTheo());
               if(glbTicKet>0)
               {
                  glbTapLenh[glbTongSoLenh]=glbTicKet;
                  glbTongSoLenh++;
                  glbLoaiLenhDangVao=1;
                   // Vao lenh buy stop
                  glbLenhStop=FunVaoLenh(OP_BUYSTOP,High[1],Low[1],0,inpKhoiLuongCoSo);
               }
            }
            else if(glbLoaiLenhDangVao==1)// Dang co san lenh  sell
            {
               // Mo lenh sell moi , 
               glbTicKet=FunVaoLenh(OP_SELL,Bid,High[1],0,FunTinhKhoiLuongVaoLenhTiepTheo());
               if(glbTicKet>0)
               {
                  glbTapLenh[glbTongSoLenh]=glbTicKet;
                  glbTongSoLenh++;
               }
               // Dich chuyen SL lenh sell
               FunDichChuyenStopLoss(High[1]);    
               if(glbLenhStop>0)
               {
                  if(OrderSelect(glbLenhStop,SELECT_BY_TICKET,MODE_TRADES))
                  {
                     if(OrderOpenPrice()>High[1])
                        OrderModify(glbLenhStop,High[1],Low[1],0,0,0);
                  } 
               }               
            }
         }
}
void FunDichChuyenStopLoss(double GiaStopLossMoi)
{
   for(int i=0;i<glbTongSoLenh;i++)
   {
      if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES))
      {
         if(OrderType()==OP_BUY)
         {
            if(OrderStopLoss()<GiaStopLossMoi)
               OrderModify(OrderTicket(),OrderOpenPrice(),GiaStopLossMoi,OrderTakeProfit(),0,0);
         }
         else if(OrderType()==OP_SELL)
         {
            if(OrderStopLoss()>GiaStopLossMoi)
               OrderModify(OrderTicket(),OrderOpenPrice(),GiaStopLossMoi,OrderTakeProfit(),0,0);
         }
      }
   }
}
//+------------------------------------------------------------------+

int FunKiemTraNenXanhDo()//-1: Trung tinh, 0: Nen Xanh, 1: Nen do
{
   if(Close[1]>Open[1]) return 0;
   else if(Close[1]<Open[1]) return 1;
   else return -1;
}
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

double FunTinhKhoiLuongVaoLenhTiepTheo()
{

   if(glbTongSoLenh==0) return inpKhoiLuongCoSo;
   if(glbTongSoLenh==1) return FunHamLamTronKhoiLuong(0.5*inpKhoiLuongCoSo);
   if(glbTongSoLenh==2) return FunHamLamTronKhoiLuong(0.5*0.5*inpKhoiLuongCoSo);
   return FunHamLamTronKhoiLuong(0.5*0.5*inpKhoiLuongCoSo);
}

double FunHamLamTronKhoiLuong(double khoiluong)
{
   double khoi_luong_nho_nhat=MarketInfo(Symbol(),MODE_MINLOT);
   double khoiluongvaolenh=NormalizeDouble(khoiluong,FunTinhLotDecimal());
   if(khoiluongvaolenh<khoi_luong_nho_nhat)khoiluongvaolenh=khoi_luong_nho_nhat;
   return khoiluongvaolenh;
   
}
int FunTinhLotDecimal()
{
   double lot_step=MarketInfo(Symbol(),MODE_LOTSTEP);
   if(lot_step==0.01) return 2;
   if(lot_step==0.05) return 2;
   if(lot_step==0.1) return 1;
   return 0;
}

//-----------------------------------------Đặt lệnh-----------------------------------------
 int FunVaoLenh(int LoaiLenh, double DiemVaoLenh,double StopLossPrice, double TakeProfitPrice, double KhoiLuongVaoLenh)
{
    int Ticket=-1;
    double StopLoss=StopLossPrice,TakeProfit=TakeProfitPrice;
    if(KhoiLuongVaoLenh==0) return -1;
    
    if(LoaiLenh==OP_BUY || LoaiLenh==OP_BUYLIMIT || LoaiLenh==OP_BUYSTOP)
    { 
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,"Vao lenh Buy",glbMagicNumber,0,clrBlue);
    }
    if(LoaiLenh==OP_SELL|| LoaiLenh==OP_SELLLIMIT || LoaiLenh==OP_SELLSTOP)
    {
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,"Vao lenh Sell",glbMagicNumber,0,clrRed);
    }
    return Ticket;
}
//+------------------------------------------------------------------+
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
   if(glbTongSoLenh==0) glbLoaiLenhDangVao=-1;
}

void FunDongTatCaCacLenh()
{
   while(glbTongSoLenh>0)
   {
      if(OrderSelect(glbTapLenh[glbTongSoLenh-1],SELECT_BY_TICKET))
      {
         if(OrderCloseTime()>0)
         {
            glbTapLenh[glbTongSoLenh-1]=-1;
            glbTongSoLenh--;
            string s=StringFormat("Cap tien: %s\nDONG LENH: %s\nTicket: %d\nPROFIT: %0.2f",Symbol(),FunTraVeTenLenh(OrderType()),OrderTicket(),OrderProfit());
            SendNotification(s);
         }
         else
         {
            if(OrderType()==OP_BUY)
            {
               if(!OrderClose(OrderTicket(),OrderLots(),Bid,500,clrBlue))
               {
                  Print(Symbol(),": Loi dong lenh Buy");
                  SendNotification(StringFormat("Cap tien: %s\nLOI KHI DONG LENH BUY: ERROR",Symbol()));   
               }
               else 
               {  glbTapLenh[glbTongSoLenh-1]=-1;glbTongSoLenh--;
                  string s=StringFormat("Cap tien: %s\nDONG LENH: %s\nTicket: %d \nPROFIT: %0.2f",Symbol(),FunTraVeTenLenh(OrderType()),OrderTicket(),OrderProfit());
                  SendNotification(s);
               }
                  
            }
            else if(OrderType()==OP_SELL)
            {
               if(!OrderClose(OrderTicket(),OrderLots(),Ask,500,clrRed))
               {
                  Print(Symbol(),":Loi dong lenh Sell");
                  SendNotification(StringFormat("Cap tien: %s\n LOI KHI DONG LENH SELL: ERROR",Symbol()));   
               }
               else 
               {  
                  glbTapLenh[glbTongSoLenh-1]=-1;glbTongSoLenh--;
                  string s=StringFormat("Cap tien: %s\nDONG LENH %s\nTicket: %d\nPROFIT: %0.2f",Symbol(),FunTraVeTenLenh(OrderType()),OrderTicket(),OrderOpenPrice(),OrderProfit());
                  SendNotification(s);
              }
            }
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
bool FunKiemTraDenGioVaoLenh()
{
   datetime timelocal=TimeCurrent();//TimeLocal();
   double gio=TimeHour(timelocal)+ double(TimeMinute(timelocal))/60;;
   if(gio>=inpStartTime && gio<inpEndTime) return true;
   else return false;
}

//+------------------------------------------------------------------+ 
bool FunKiemDaHetHanChua(NgayThang &HanCanKiemTra)// False: Chua; True: Roi
{
   bool kt=false;
   if(Year()>HanCanKiemTra.Nam)
    {
         MessageBox("EA het han su dung. De gia han Vui long truy cap website tailieuforex.com. Hoac lien he SDT: 0971926248");
         ExpertRemove();
         kt=true;
    }
      if(Year()==HanCanKiemTra.Nam && Month()>HanCanKiemTra.Thang)
    {
         MessageBox("EA het han su dung. De gia han Vui long truy cap website tailieuforex.com. Hoac lien he SDT: 0971926248");
         ExpertRemove();
         kt=true;   
    }
    if(Year()==HanCanKiemTra.Nam && Month()==HanCanKiemTra.Thang && Day()>HanCanKiemTra.Ngay)  
    {
        MessageBox("EA het han su dung. De gia han Vui long truy cap website tailieuforex.com. Hoac lien he SDT: 0971926248");
         ExpertRemove();
         kt=true;
    }
    return kt;
}