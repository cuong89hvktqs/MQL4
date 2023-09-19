//+------------------------------------------------------------------+
//|                                                         Test.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "VIET BOT THEO YEU CAU, Website: tailieuforex.com, SDT: 0971 926 248"
#property link      "https://www.tailieuforex.com"
#property version   "1.00"
#property strict
enum ENM_KIEU_CAT_LENH
{
   ENM_THEO_CCI,// THEO CCI
   ENM_THEO_BAND //THEO BAND CUA BB
};
// input double inpKhoiLuong=0.01;//Khoi luong ban dau:
input int inpSoLenhToiDa=10;// So lenh toi da:
input double inpSoLotToiDa=10;//So lot toi da:
//input double inpKhoangCachMaKhiVaoLenh=30;// Khoang cach gia voi MA khi vao lenh dau tien (pips):
input double inpKhoangCachNhoiLenhDauTien=50;//Khoang cach nhoi lenh dau tien (pips):
input bool inpChoPhepDongLenhKhiCoTinHieuNguoc=true;// Cho phep dong lenh khi xuat hien tin hieu nguoc:
input ENM_KIEU_CAT_LENH inpKieuDongLenh=ENM_THEO_BAND;// Kieu dong lenh khi xuat hien tin hieu nguoc:
input double inpHeSoNhoiLenh=2;// He so nhan khoi luong:
input double inpKhoiLuong=0.01;//Khoi luong ban dau:
input int inpSoPipTP=50;// So pips TP (pips):
input int inpSoPipSL=0;// So pips SL ban dau (pips):
input string str0="THAM SO HAI DUONG BB VA CCI ";//CAI DAT THAM SO MA:
input int inpBandPeriod=20; //Band period:
input double inpBandDevitation=2.5;//Band devitation:
input ENUM_APPLIED_PRICE inpBandAppliedPrice=PRICE_CLOSE;// BAnd applied price:
input int inpCCIPeriod=14; //CCI period:
input ENUM_APPLIED_PRICE inpCCIAppliedPrice=PRICE_CLOSE;//CCI applied price:
input double inpCCIDuoi=-100;// CCI can duoi:
input double inpCCITren=100;//CCI can tren:

input int inpSlippage=50;// Do truot gia (slippage):
input int inpMagicNumber=123;// Magic number:
input string inpCommentBuy="Buy";//Comment  lenh buy:
input string inpCommentSell="Sell";//Comment  lenh sell:
input double inpKhungGioBatDauMoLenh=0;// Khung gio bat dau mo lenh (Gio san):
input double inpKhungGioKetThucMoLenh=24 ;// Khung gio Ket thuc mo lenh (Gio san):

double glbMyPoint=0;
double glbKhoiLuongCoSo=0;
int glbLoaiLenh;
int glbTapLenh[100];
int glbTongLenh=0;
double glbGiaNhoiLenhTiepTheo;
double glbSoLotCuaLenhTiepTheo;
double glbGiaDongTatCaCacLenh;

struct NgayThang
  {
   int          Ngay; // date
   int            Thang;  // bid price
   int            Nam;  // ask price
  };
NgayThang glbNgayHetHan={30,10,2023};

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    if(FunKiemTraChuaHetHan(glbNgayHetHan)==false)return INIT_FAILED;
    glbMyPoint=10*FunTinhGiaTriPoint(Symbol());
    glbKhoiLuongCoSo=inpKhoiLuong;
    FunTimLenhCoSo();   
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
    string Comments="";
   if(glbTongLenh<=0)
   {
        Comments="Doi lenh";
        if(FunKiemTraGioVaoLenh()==true)
        {
            int DieuKienVaoLenh=FunKiemTraDieuKienVaoLenh();
            if(DieuKienVaoLenh>=0)
            {
                
                int ticket=-1;
                if(DieuKienVaoLenh==1)ticket=FunVaoLenh(OP_SELL,Bid,inpSoPipSL,inpSoPipTP,glbKhoiLuongCoSo,inpCommentSell+"-1",inpMagicNumber);
                else ticket=FunVaoLenh(OP_BUY,Ask,inpSoPipSL,inpSoPipTP,glbKhoiLuongCoSo,inpCommentBuy+"-1",inpMagicNumber);
                if(ticket>0)
                {
                     glbLoaiLenh=DieuKienVaoLenh;
                     glbTapLenh[glbTongLenh]=ticket;
                     glbTongLenh++;
                     glbGiaNhoiLenhTiepTheo=FunTinhGiaCachNhoiLenhTiepTheo();
                     glbSoLotCuaLenhTiepTheo=FunTinhKhoiLuongVaoLenhTiepThep();
                     glbGiaDongTatCaCacLenh=FunCapNhatGiaDongLenh();
                }
            }
        }
        else Comments="Chua toi gio vao lenh";
   }
   else
   {
      if(inpChoPhepDongLenhKhiCoTinHieuNguoc) FunDongLenhKhiCatMA();
      FunKiemTraDongLenhBangTay();
      if(glbTongLenh==0)return;

      if(FunKiemTraGioVaoLenh()==true) FunKiemTraNhoiLenh();
      Comments="Tong lenh: "+IntegerToString(glbTongLenh);
      if(glbGiaDongTatCaCacLenh>0)
      Comments+="\nGia dong lenh: "+DoubleToString(glbGiaDongTatCaCacLenh,Digits);
      if(glbTongLenh==inpSoLenhToiDa || glbSoLotCuaLenhTiepTheo>inpSoLotToiDa) 
      {
         Comments+="\nKhong vao them lenh do da dat toi da";
      }
      else
      {
         if(glbGiaNhoiLenhTiepTheo>0)
         Comments+="\nGia vao lenh tiep theo: "+DoubleToString(glbGiaNhoiLenhTiepTheo,Digits);
         if(glbSoLotCuaLenhTiepTheo>0) Comments+="\nKhoi luong lenh tiep theo: "+DoubleToString(glbSoLotCuaLenhTiepTheo,FunTinhPhanThapPhanKhoiLuong());
      }
   }
   Comment(Comments);
   
}

//+------------------------------------------------------------------+
void FunKiemTraNhoiLenh()
{
   if(glbTongLenh==inpSoLenhToiDa || glbSoLotCuaLenhTiepTheo>inpSoLotToiDa) 
   {
      return;
   }
   int ticket=-1;
   double SoPipTP=0;
   string Comments;
   if(glbLoaiLenh==OP_BUY)
   {  
      Comments=inpCommentBuy+"-"+IntegerToString(glbTongLenh+1);
      if(Ask<=glbGiaNhoiLenhTiepTheo)
        ticket=FunVaoLenh(OP_BUY,Ask,0,SoPipTP,glbSoLotCuaLenhTiepTheo,Comments,inpMagicNumber);
   }
   else
   {
      Comments=inpCommentSell+"-"+IntegerToString(glbTongLenh+1);
      if(Bid>=glbGiaNhoiLenhTiepTheo)
        ticket=FunVaoLenh(OP_SELL,Bid,0,SoPipTP,glbSoLotCuaLenhTiepTheo,Comments,inpMagicNumber);
   }
   if(ticket>0)
   {
      glbTapLenh[glbTongLenh]=ticket;
      glbTongLenh++;
      glbGiaNhoiLenhTiepTheo=FunTinhGiaCachNhoiLenhTiepTheo();
      glbSoLotCuaLenhTiepTheo=FunTinhKhoiLuongVaoLenhTiepThep();
      glbGiaDongTatCaCacLenh=FunCapNhatGiaDongLenh();
   }
}
//+------------------------------------------------------------------+
double FunTinhGiaCachNhoiLenhTiepTheo()
{
   double BuocLenhTiepTheo;
    double GiaNhoiLenhTiepTheo=0;
    BuocLenhTiepTheo=inpKhoangCachNhoiLenhDauTien;//*(glbTongLenh);
    if(!OrderSelect(glbTapLenh[glbTongLenh-1],SELECT_BY_TICKET)) return -1;
    if(OrderType()==OP_BUY) GiaNhoiLenhTiepTheo=OrderOpenPrice()-BuocLenhTiepTheo*glbMyPoint;
    else GiaNhoiLenhTiepTheo=OrderOpenPrice()+BuocLenhTiepTheo*glbMyPoint;
    GiaNhoiLenhTiepTheo=NormalizeDouble(GiaNhoiLenhTiepTheo,Digits);
    if(GiaNhoiLenhTiepTheo>0) FunHLineCreate(0,"hLineGiaNhoiLenh",0,GiaNhoiLenhTiepTheo,clrRed,STYLE_SOLID,1,true);
    return GiaNhoiLenhTiepTheo;
}
//+------------------------------------------------------------------+
double FunCapNhatGiaDongLenh()
{
   double LoiNhuanCanDatDuocTP=0;
   double DiemDongTatCaCacLenhTP=0;
    double TongComVaSwap=0;
   double TongTheoGia=0;
   double TongKhoiLuong=0;
   double nTickValue=MarketInfo(Symbol(),MODE_TICKVALUE);
   if(glbLoaiLenh==OP_BUY)
   {
      for(int i=0;i<glbTongLenh;i++)
      {
         if(!OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES)) continue;
         TongComVaSwap+=OrderCommission()+OrderSwap();
         TongTheoGia+=OrderOpenPrice()*OrderLots();
         TongKhoiLuong+=OrderLots();
      }
      LoiNhuanCanDatDuocTP=TongKhoiLuong*inpSoPipTP*glbMyPoint*nTickValue/Point();
      if(LoiNhuanCanDatDuocTP==0)DiemDongTatCaCacLenhTP=0;
      else
         DiemDongTatCaCacLenhTP=(((LoiNhuanCanDatDuocTP-TongComVaSwap)*Point()/nTickValue)+TongTheoGia)/TongKhoiLuong;
   }
   else
   {
      
      for(int i=0;i<glbTongLenh;i++)
      {
         if(!OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES)) continue;
         TongComVaSwap+=OrderCommission()+OrderSwap();
         TongTheoGia+=OrderOpenPrice()*OrderLots();
         TongKhoiLuong+=OrderLots();
      }
      //Print("Tong com:",TongComVaSwap," TongTheoGia:",TongTheoGia," Tong Khoi Luong:",TongKhoiLuong);
      LoiNhuanCanDatDuocTP=TongKhoiLuong*inpSoPipTP*glbMyPoint*nTickValue/Point();
      //Print("Tong lenh sell:",glbTongLenh," Loi nhuan can dat duoc:",LoiNhuanCanDatDuocTP);
      if(LoiNhuanCanDatDuocTP==0)DiemDongTatCaCacLenhTP=0;
      else
         DiemDongTatCaCacLenhTP=(TongTheoGia-((LoiNhuanCanDatDuocTP-TongComVaSwap)*Point()/nTickValue))/TongKhoiLuong;
   }
   if(DiemDongTatCaCacLenhTP>0)
   {
      FunHLineCreate(0,"hLineGiaDongLenh",0,DiemDongTatCaCacLenhTP,clrGreen,STYLE_SOLID,1,true);
      for (int i = 0; i < glbTongLenh; i++)
      {
         if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES))
            OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),DiemDongTatCaCacLenhTP,0,clrNONE);
      }
      
   } 
   return DiemDongTatCaCacLenhTP;
}
//+------------------------------------------------------------------+
double FunTinhKhoiLuongVaoLenhTiepThep()
{
   if(glbTongLenh==0) return inpKhoiLuong;
   double KhoiLuongDuKien=inpKhoiLuong*MathPow(inpHeSoNhoiLenh,glbTongLenh);
   KhoiLuongDuKien=NormalizeDouble(KhoiLuongDuKien,FunTinhPhanThapPhanKhoiLuong());
   return KhoiLuongDuKien;
}
//+------------------------------------------------------------------+
int FunKiemTraDieuKienVaoLenh()//0: Buy, 1: sell
{
    double BBTren, BBDuoi, RSIValue;
    BBTren=iBands(Symbol(),PERIOD_CURRENT,inpBandPeriod,inpBandDevitation,0,inpBandAppliedPrice,MODE_UPPER,0);
    BBDuoi=iBands(Symbol(),PERIOD_CURRENT,inpBandPeriod,inpBandDevitation,0,inpBandAppliedPrice,MODE_LOWER,0);
    RSIValue=iCCI(Symbol(),PERIOD_CURRENT,inpCCIPeriod,inpCCIAppliedPrice,0);
    if(RSIValue>=inpCCITren && Bid>BBTren) return 1;
    if(RSIValue<=inpCCIDuoi && Bid <BBDuoi) return 0;
    return -1;
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
 void FunKiemTraDongLenhBangTay()
{
   for(int i=0;i<glbTongLenh;i++)
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
void FunDongLenhKhiCatMA()
{
    int DieuKienVaoLenhMoi=FunTinHieuCatLenh();
    bool DieuKienDongLenh=(glbLoaiLenh==OP_BUY && DieuKienVaoLenhMoi==1)||(glbLoaiLenh==OP_SELL && DieuKienVaoLenhMoi==0);
    if(DieuKienDongLenh)
    {
        FunDongTatCaCacLenh();
    }

}
int FunTinHieuCatLenh()//0: CAT LENH SELL, 1 : CAT LENH BUY
{
    double BBTren, BBDuoi, RSIValue;
   if(inpKieuDongLenh==ENM_THEO_BAND)
   {
      BBTren=iBands(Symbol(),PERIOD_CURRENT,inpBandPeriod,inpBandDevitation,0,inpBandAppliedPrice,MODE_UPPER,1);
      BBDuoi=iBands(Symbol(),PERIOD_CURRENT,inpBandPeriod,inpBandDevitation,0,inpBandAppliedPrice,MODE_LOWER,1);
      if(Bid>BBTren) return 1;
      if(Bid <BBDuoi) return 0;
   }
   else // THEO CCI
   {
      RSIValue=iCCI(Symbol(),PERIOD_CURRENT,inpCCIPeriod,inpCCIAppliedPrice,1);
      if(RSIValue>=inpCCITren) return 1;
      if(RSIValue<=inpCCIDuoi) return 0;
   }
   return -1;
}
//+----------------------------------------------------------------------------------------------------+
bool FunDongLenh(int Ticket)
{
    if(OrderSelect(Ticket,SELECT_BY_TICKET))
    {
        if(OrderType()==OP_BUY)return OrderClose(Ticket,OrderLots(),Bid,inpSlippage,clrNONE);
        else return OrderClose(Ticket,OrderLots(),Ask,inpSlippage,clrNONE);
    }
    return false;
}
//+------------------------------------------------------------------+
int FunTinhPhanThapPhanKhoiLuong()
{
   double lot_step=MarketInfo(Symbol(),MODE_LOTSTEP);
   if(lot_step==0.01) return 2;
   if(lot_step==0.05) return 2;
   if(lot_step==0.1) return 1;
   return 0;
}
//+------------------------------------------------------------------+
void FunDichHoaVon(int ticket, int SoPipDeDichHoaVon)
{
   if( OrderSelect( ticket,SELECT_BY_TICKET,MODE_TRADES))
   {
      if(OrderType()==OP_BUY)
      {
         if(OrderStopLoss()<OrderOpenPrice())
         {
            if(Bid>=(OrderOpenPrice()+SoPipDeDichHoaVon*glbMyPoint))
               if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+10*Point(),OrderTakeProfit(),0,clrNONE))
                Print("Dia hoa von LOI");   
         }
      }
      else if(OrderType()==OP_SELL)
      {
         if(OrderStopLoss()>OrderOpenPrice())
         {
            if(Bid<=(OrderOpenPrice()-SoPipDeDichHoaVon*glbMyPoint))
               if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-10*Point(),OrderTakeProfit(),0,clrNONE))
                  Print("hoa von bi LOI");  
         }
      }
      
   }
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
//+----------------------------------------------------------------------------------------------------+
bool FunKiemTraGioVaoLenh()// True: DUng gio vao lenh
{
   datetime timelocal=TimeCurrent();//TimeLocal();
   double gio=TimeHour(timelocal)+ double(TimeMinute(timelocal))/60;
   if (inpKhungGioBatDauMoLenh<inpKhungGioKetThucMoLenh)
   {
      if(gio>=inpKhungGioBatDauMoLenh && gio<inpKhungGioKetThucMoLenh) return true;
      else return false;
   }
   else
   {
      if(gio>=inpKhungGioBatDauMoLenh && gio<inpKhungGioKetThucMoLenh) return false;
      else return true;
   }
}
//+----------------------------------------------------------------------------------------------------+
int FunVaoLenhThiTruong(int LoaiLenh,double StopLossPips, double TakeProfitPips, double KhoiLuongVaoLenh, int MagicID)
{
    int Ticket=-1;
    double StopLoss=0,TakeProfit=0;
    double DiemVaoLenh;
    if(KhoiLuongVaoLenh==0) return -1;
    
    if(LoaiLenh==OP_BUY )
    {
       DiemVaoLenh=Ask;
       if(StopLossPips>0)StopLoss=DiemVaoLenh-StopLossPips*10*Point();
       if(TakeProfitPips>0)TakeProfit=DiemVaoLenh+TakeProfitPips*10*Point();  
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,inpCommentBuy,MagicID,0,clrBlue);
    }
    if(LoaiLenh==OP_SELL)
    {
       DiemVaoLenh=Bid;
       if(StopLossPips>0)StopLoss=DiemVaoLenh+StopLossPips*10*Point();
       if(TakeProfitPips>0)TakeProfit=DiemVaoLenh-TakeProfitPips*10*Point();  
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,inpCommentSell,MagicID,0,clrRed);
    }
    return Ticket;
}
//+----------------------------------------------------------------------------------------------------+
double FunTinhMAValue(ENUM_TIMEFRAMES MA_TimeFrame, int MA_Period, ENUM_MA_METHOD MA_Method, ENUM_APPLIED_PRICE MA_Applied_price, int shift=0)
{
   return iMA(Symbol(),MA_TimeFrame,MA_Period,0,MA_Method,MA_Applied_price,shift);
}

//+----------------------------------------------------------------------------------------------------+
int FunVaoLenh(int LoaiLenh, double DiemVaoLenh,double StopLossPips, double TakeProfitPips, double KhoiLuongVaoLenh, string CommentLenh, int  MagicID)
{
    int Ticket=-1;
    double StopLoss=0,TakeProfit=0;
    if(KhoiLuongVaoLenh==0) return -1;
    
    if(LoaiLenh==OP_BUY || LoaiLenh==OP_BUYLIMIT || LoaiLenh==OP_BUYSTOP)
    {
       if(StopLossPips>0)StopLoss=DiemVaoLenh-StopLossPips*10*Point();
       if(TakeProfitPips>0)TakeProfit=DiemVaoLenh+TakeProfitPips*10*Point();  
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,CommentLenh,MagicID,0,clrBlue);
    }
    if(LoaiLenh==OP_SELL|| LoaiLenh==OP_SELLLIMIT || LoaiLenh==OP_SELLSTOP)
    {
       if(StopLossPips>0)StopLoss=DiemVaoLenh+StopLossPips*10*Point();
       if(TakeProfitPips>0)TakeProfit=DiemVaoLenh-TakeProfitPips*10*Point();  
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,CommentLenh,MagicID,0,clrRed);
    }
    return Ticket;
}
//+----------------------------------------------------------------------------------------------------+
void FunTimLenhCoSo()
{
   glbTongLenh=0;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderSymbol()==Symbol()&& OrderType()<2 && OrderMagicNumber()==inpMagicNumber)
         {
            glbTapLenh[glbTongLenh]=OrderTicket();
            glbTongLenh++;
            if(glbTongLenh==1)
            {
                glbLoaiLenh=OrderType();
                glbKhoiLuongCoSo=OrderLots();
            }
         }
      }
   }
}

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
 double FunTinhGiaTriPoint(string Sym1)
{
   double DigitSym=MarketInfo(Sym1,MODE_DIGITS); //Tinh so ky tu thap phan sau dau phay cua ma Symbol1
   double PointSym=MarketInfo(Sym1,MODE_POINT); // Gia tri point
   int Dig=1;
   if(StringFind(Sym1,"GOL",0) >-1 || StringFind(Sym1,"XAU",0))
   {
        if(DigitSym==3) Dig=10;
   }
   if(StringFind(Sym1,"SIL",0) >-1 || StringFind(Sym1,"XGU",0) >-1) 
   {
       ;//Chua xu ly
   }
   return(Dig*PointSym);
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
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
               {  glbTapLenh[glbTongLenh-1]=-1;glbTongLenh--;
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
                  glbTapLenh[glbTongLenh-1]=-1;glbTongLenh--;
               }
            }
         }
      }
   }
}
//+------------------------------------------------------------------+
//| TẬP HỢP CÁC HÀM XỬ LÝ ĐƯỜNG LINE                                 |
//+------------------------------------------------------------------+

bool FunHLineCreate(const long            chart_ID=0,        // chart's ID
                 const string          name="HLine",      // line name
                 const int             sub_window=0,      // subwindow index
                 double                price=0,           // line price
                 const color           clr=clrRed,        // line color
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style
                 const int             width=1,           // line width
                 const bool            back=true,        // in the background
                 const bool            selection=true,    // highlight to move
                 const bool            hidden=true,       // hidden in the object list
                 const long            z_order=0)         // priority for mouse click
  {
//--- if the price is not set, set it at the current Bid price level
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   if(ObjectFind(chart_ID,name)>=0)
   {
      FunHLineDelete(chart_ID,name);
   }
   ResetLastError();
//--- create a horizontal line
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
     {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- set line color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
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
//| Delete a horizontal line                                         |
//+------------------------------------------------------------------+
bool FunHLineDelete(const long   chart_ID=0,   // chart's ID
                 const string name="HLine") // line name
  {
//--- reset the error value
   ResetLastError();
//--- delete a horizontal line
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }

//+------------------------------------------------------------------+
bool FunKiemTraChuaHetHan(NgayThang &HanCanKiemTra)// False: Da het han; True: Chưa
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
