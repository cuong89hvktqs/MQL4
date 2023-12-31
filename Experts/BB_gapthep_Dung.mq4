//+------------------------------------------------------------------+
//|                                          BB_DongNenXanh_Dung.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
/*
//+------------------------------------------------------------------+
 Expert initialization function   
        lệnh buy: vào lệnh khi nến đóng cửa tại giá thị trường, nến xanh, giá đóng cửa trên biên trên của BB     
        SL đáy nến, tỷ lệ rủi ro 1, chỉ có 1 lệnh đang chạy      
        Nếu SL thì gấp đôi khối lượng, khi nào TP trở lại khối lượng ban đầu     
        Khối lượng ban đầu để theo giá trị là 10 usd có thể điều chỉnh được   
        Lệnh sell thì điều kiện ngược lại, SL trên đỉnh nến + 10 point
//+------------------------------------------------------------------+
*/
input double inpTienVaoLenh=3;//So tien cho 1 lenh ($):
input double inpTyLeRuiRo=1;//Ty le rui ro:
input double inpTyLeGapThep=2;//Ty le gap thep lenh:
input int   inpBBPeriod=20;// BB Period:
input int inpBBDeviations=1;//BB Deviations:
input int inpBBApplied=PRICE_CLOSE;
input int inpCCIPeriod=11;// RSI period:
input int inpRSIBuy=70;//RSI Buy:
input int inpRSISell=30;//RSI sell:
input int inpRSIApplied=PRICE_CLOSE;
input double inpDoLechPipCaiSL=0.5;// Do lech khi cai SL (pips):
input int inpThoiGianMoBot=8;// Thoi gian bat dau chay bot (Gio server)
input int inpChiTieuLoiNhuanNgay=10;// Chi tieu loi nhuan ngay ($):
input int inpSlippage=50;//Slippage:
struct NgayThang
  {
   int          Ngay; // date
   int            Thang;  // bid price
   int            Nam;  // ask price
  };
NgayThang NgayHetHan={15,10,3022};
int glbTongLenhAm=0;
int glbTicKet=-1;
int glbSlippage=50;
double glbTongLoiNhuan;
int OnInit()
  {
//---
      if(FunKiemDaHetHanChua(NgayHetHan)==true)return INIT_FAILED;
      glbSlippage=inpSlippage;
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
         
         if(glbTicKet==-1)
         {
            if(FunKiemSangNgayMoiChua()==true)
            {
               Print("Sang Ngay mơi");
               if(glbTongLoiNhuan>=inpChiTieuLoiNhuanNgay)
                  glbTongLoiNhuan=0;
            }
            if(glbTongLoiNhuan>=inpChiTieuLoiNhuanNgay)
            {
                Comment("Dung vao lenh. Tong loi nhuan:", glbTongLoiNhuan);
                Print("Dung vao lenh. Tong loi nhuan:", glbTongLoiNhuan);
                return;
            }
            if(glbTongLoiNhuan==0 && FunKiemTraThoiGianVaoLenh()==false)
            {
                Comment("Sang ngay moi. Chua den gio vao lenh");
                Print("Sang ngay moi. Chua den gio vao lenh");
                return;
            }
            
            double SoTienVaoLenh=0;
            double StopLoss=0;
            double TackeProfit=0;
            double KhoiLuongVaoLenh=0;
            int DieuKienVaoLenh=FunKiemTraDieuKienVaoLenh();
            if(DieuKienVaoLenh==0)//Vao lenh buy
            {
              Comment("Vao lenh BUY. Tong lenh am truoc do:",glbTongLenhAm);
              SoTienVaoLenh=MathPow(inpTyLeGapThep,glbTongLenhAm)*inpTienVaoLenh;
              StopLoss=Low[1]-inpDoLechPipCaiSL*10*Point();
              TackeProfit=(Ask-StopLoss)*inpTyLeRuiRo+Ask;
              KhoiLuongVaoLenh=FunTinhKhoiLuongVaoLenh(StopLoss,Ask,SoTienVaoLenh);
              int ticket=FunVaoLenh(OP_BUY,Ask,StopLoss,TackeProfit,KhoiLuongVaoLenh);
              if(ticket>0)glbTicKet=ticket;
              else 
              {
               Comment("Vao lenh BUY bi loi");
               Print("Loi lenh Buy:");
              }
            }
            else if(DieuKienVaoLenh==1)//Vao lenh sell
            {
                 Comment("Vao lenh SELL. Tong lenh am truoc do:",glbTongLenhAm);
                 SoTienVaoLenh=MathPow(inpTyLeGapThep,glbTongLenhAm)*inpTienVaoLenh;
                 StopLoss=High[1]+inpDoLechPipCaiSL*10*Point();
                 TackeProfit=Bid-(StopLoss-Bid)*inpTyLeRuiRo;
                 KhoiLuongVaoLenh=FunTinhKhoiLuongVaoLenh(StopLoss,Bid,SoTienVaoLenh);
                 int ticket=FunVaoLenh(OP_SELL,Bid,StopLoss,TackeProfit,KhoiLuongVaoLenh);
                 if(ticket>0)glbTicKet=ticket;
                 else 
                 {
                  Comment("Vao lenh SELL bi loi");
                  Print("Loi lenh SELL:");
                 }
            }
            else Comment("Chua thoa man dieu kien vao lenh. Tong lenh am truoc do:",glbTongLenhAm, "\nTong loi nhuan:",DoubleToString(glbTongLoiNhuan,2));
         }
      }
      if(glbTicKet>0)
      {
         if(OrderSelect(glbTicKet,SELECT_BY_TICKET,MODE_TRADES))
         {
            if(OrderCloseTime()>0)//Lenh da dong
            {
               glbTicKet=-1;
               if(OrderProfit()>0)glbTongLenhAm=0;
               else glbTongLenhAm++;
               glbTongLoiNhuan+=OrderProfit()+OrderSwap()+OrderCommission();
               Comment("Dong lenh. CHo lenh moi. Tong lenh am:",glbTongLenhAm,"\nTong loi nhuan:",DoubleToString(glbTongLoiNhuan,2));
            }
            else Comment("Dang co lenh. Tong lenh am truoc do:",glbTongLenhAm,"\nTong loi nhuan:",DoubleToString(glbTongLoiNhuan,2));
         }
      }
  }
//+------------------------------------------------------------------+

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
 //-----------------------------------------Đặt lệnh-----------------------------------------
 int FunVaoLenh(int LoaiLenh, double DiemVaoLenh,double StopLoss, double TakeProfit, double KhoiLuongVaoLenh)
{
    int Ticket=-1;
    if(KhoiLuongVaoLenh==0) return -1;
    
    if(LoaiLenh==OP_BUY || LoaiLenh==OP_BUYLIMIT || LoaiLenh==OP_BUYSTOP)
    {
         
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,glbSlippage,StopLoss,TakeProfit,"Vao lenh Buy",0,0,clrBlue);
    }
    if(LoaiLenh==OP_SELL|| LoaiLenh==OP_SELLLIMIT || LoaiLenh==OP_SELLSTOP)
    {
      
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,glbSlippage,StopLoss,TakeProfit,"Vao lenh Sell",0,0,clrRed);
    }
    return Ticket;
}

 //---------------------------------Tinh khoi luong vao lenh-----------------------------------------
double FunTinhKhoiLuongVaoLenh(double stoploss, double diemvaolenh, double SoTienRuiRo)
{
   if(SoTienRuiRo>0)
   {
      double point=MathAbs(stoploss-diemvaolenh)/Point();
      double nTickValue=MarketInfo(Symbol(),MODE_TICKVALUE);
      double TongLoChoPhep=SoTienRuiRo;
      double khoiluongvaolenh=NormalizeDouble(TongLoChoPhep/(point*nTickValue),2);
      if(khoiluongvaolenh<0.01)khoiluongvaolenh=0.01;
      return khoiluongvaolenh;
   }
   else return 0;
   
}

int FunKiemTraDieuKienVaoLenh()//-1: Chưa thỏa mãn đk, 0: Buy; 1:SELL
{
   int KiemTraNenXanh=-1;//: 0 la xanh, 1 la do
   if(Open[1]<Close[1])KiemTraNenXanh=0;
   else if(Open[1]>Close[1]) KiemTraNenXanh=1;
   double BBTren=iBands(Symbol(),PERIOD_CURRENT,inpBBPeriod,inpBBDeviations,0,inpBBApplied,MODE_UPPER,1);
   double BBDuoi=iBands(Symbol(),PERIOD_CURRENT,inpBBPeriod,inpBBDeviations,0,inpBBApplied,MODE_LOWER,1);
   double RsiValue=iRSI(Symbol(),0,inpCCIPeriod,inpRSIApplied,0);
   if(KiemTraNenXanh==0 && Close[1] >BBTren && RsiValue>inpRSIBuy) 
   {
      
      return 0;
   }   
   if(KiemTraNenXanh==1 && Close[1]<BBDuoi && RsiValue<inpRSISell) 
   {
      return 1;
   }
   return -1;  
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


bool FunKiemTraThoiGianVaoLenh()
{
   datetime timelocal=TimeCurrent();//TimeLocal();
   int gio=TimeHour(timelocal);
   if(gio>=inpThoiGianMoBot) return true;
   else return false;
}

bool FunKiemSangNgayMoiChua()
{
   static int _LastDay=TimeDay(TimeCurrent());
   
   //OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES);
   int currDay=TimeDay(TimeCurrent());//iTime(OrderSymbol(),0,0);
   Print("Last day:",_LastDay, "  Curr day:",currDay);
   if(_LastDay!=currDay)
   {
      _LastDay=currDay;
      return true;
   }
   else return false;
}
