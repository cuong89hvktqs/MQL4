//+------------------------------------------------------------------+
//|                                                         Test.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "VIET BOT THEO YEU CAU, Website: tailieforex.com, SDT: 0971 926 248"
#property link      "https://www.tailieforex.com"
#property version   "1.00"
#property strict
enum ENM_LOAI_LENH
{
   ENM_BUY,//BUY
   ENM_SELL//SELL
};
struct NgayThang
  {
   int          Ngay; // date
   int            Thang;  // bid price
   int            Nam;  // ask price
  };
input double inpKhoiLuong=0.01;//Khoi luong ban dau:
input ENM_LOAI_LENH inpLoaiLenh=ENM_BUY;// Loai lenh:
input int inpSLPip=20;// SL (pips):
input int inpTPPip=20;//TP (pips):
input double inpHeSoNhanKhoiLuong=2;// He so nhan khoi luong:
input double inpKhoiLuongToiDa=2;//Khoi luong toi da cua mot lenh (lots):
input int inpThoiGianBatDau=3;// Thoi gian bat dau (Gio the San):
input int inpThoiGianKetThuc=23;//Thoi gian ket thuc (Gio ket thuc):
input int inpMagicNumber=123;// Magic number:
input int inpSlippage=50;// Do truot gia (slippage):

NgayThang NgayHetHan={03,07,2023};
int glbTicket=-1;
int glbTongLenhDaVao=0;
double glbKhoiLuongHienTai=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   if(FunKiemTraHetHan(NgayHetHan)==false) return INIT_FAILED;  
   if(glbTicket==-1) FunKhoiTaoTimLenhKhiBotThoat(); 
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
   
   if(glbTicket>0)
   {
      Comment("Lenh dang vao: ", glbTicket, "\nTong lenh da vao truoc do: ",glbTongLenhDaVao);
      if(OrderSelect(glbTicket,SELECT_BY_TICKET,MODE_TRADES))
      {
         if(OrderCloseTime()>0)
         {
            if(OrderProfit()>0)
            {
               glbTicket=-1; glbTongLenhDaVao=0;
            }
            else
            {
                  glbTicket=-1;
            }
         }
      }
   }
   if(glbTicket==-1)
   {
      if(glbTongLenhDaVao<=0)// Lenh dau tien cua mot chu ky
      {
         if(FunKiemTraGioVaoLenh()==true)
            FunVaoLenhTheoMartingel();
         else Comment("Chua den gio vao lenh");
      }
      else
         FunVaoLenhTheoMartingel();
      
   }
   
}
//+------------------------------------------------------------------+
void FunKhoiTaoTimLenhKhiBotThoat()
{
   double KhoiLuongDaVao=0;
   double KhoiLuongCoSo=inpKhoiLuong;
   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==inpMagicNumber)
      {
         glbTicket=OrderTicket();
         KhoiLuongDaVao=OrderLots();
         break;
      }
   }
   if(glbTicket<=0) return;
   int dem=1;
   while (KhoiLuongCoSo<KhoiLuongDaVao)
   {
     
      KhoiLuongCoSo=inpKhoiLuong*MathPow(inpHeSoNhanKhoiLuong,dem);
       dem++;
      KhoiLuongCoSo=NormalizeDouble(KhoiLuongCoSo,FunPhanThapPhanKhoiLuong());
      if(dem>100)break;;
   }
   if(KhoiLuongCoSo==KhoiLuongDaVao) glbTongLenhDaVao=dem;
   else {MessageBox("Loi khong tinh toan duoc so lenh da vao truoc do");ExpertRemove();}
   
   return;
}
//+------------------------------------------------------------------+
void  FunVaoLenhTheoMartingel()
{
   double KhoiLuongSeVao, MinLot;
   int LoaiLenhSeVao;
   KhoiLuongSeVao=inpKhoiLuong*MathPow(inpHeSoNhanKhoiLuong,glbTongLenhDaVao);
   KhoiLuongSeVao=NormalizeDouble(KhoiLuongSeVao,FunPhanThapPhanKhoiLuong());
   MinLot=MarketInfo(Symbol(),MODE_MINLOT);
   if(KhoiLuongSeVao<MinLot)KhoiLuongSeVao=MinLot;
   if(KhoiLuongSeVao>inpKhoiLuongToiDa)return;
   if(inpLoaiLenh==OP_BUY)
   {
      if(glbTongLenhDaVao%2==0) 
         LoaiLenhSeVao=OP_BUY;
      else LoaiLenhSeVao=OP_SELL;
   }
   else
   {
      if(glbTongLenhDaVao%2==0) 
         LoaiLenhSeVao=OP_SELL;
      else LoaiLenhSeVao=OP_BUY;
   }
   if(LoaiLenhSeVao==OP_BUY)
   {
      glbTicket=FunVaoLenhMoi(LoaiLenhSeVao,Ask,inpSLPip,inpTPPip,KhoiLuongSeVao);
      if(glbTicket>0) glbTongLenhDaVao++;
   }
       
   else 
   {
      glbTicket= FunVaoLenhMoi(LoaiLenhSeVao,Ask,inpSLPip,inpTPPip,KhoiLuongSeVao);
      if(glbTicket>0) glbTongLenhDaVao++;
   }
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
int FunVaoLenhMoi(int LoaiLenh, double DiemVaoLenh,double StopLossPips, double TakeProfitPips, double KhoiLuongVaoLenh)
{
    int Ticket=-1;
    double StopLoss=0,TakeProfit=0;
    if(KhoiLuongVaoLenh==0) return -1;
    
    if(LoaiLenh==OP_BUY || LoaiLenh==OP_BUYLIMIT || LoaiLenh==OP_BUYSTOP)
    {
       if(StopLossPips>0)StopLoss=DiemVaoLenh-StopLossPips*10*Point();
       if(TakeProfitPips>0)TakeProfit=DiemVaoLenh+TakeProfitPips*10*Point();  
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,"Vao lenh Buy",inpMagicNumber,0,clrBlue);
    }
    if(LoaiLenh==OP_SELL|| LoaiLenh==OP_SELLLIMIT || LoaiLenh==OP_SELLSTOP)
    {
       if(StopLossPips>0)StopLoss=DiemVaoLenh+StopLossPips*10*Point();
       if(TakeProfitPips>0)TakeProfit=DiemVaoLenh-TakeProfitPips*10*Point();  
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,"Vao lenh Sell",inpMagicNumber,0,clrRed);
    }
    return Ticket;
}
//+------------------------------------------------------------------+

bool FunKiemTraGioVaoLenh()// True: DUng gio vao lenh
{
   if(inpThoiGianBatDau==0 && inpThoiGianKetThuc==0) return true;
   datetime timelocal=TimeCurrent();//TimeLocal();
   double gio=TimeHour(timelocal)+ double(TimeMinute(timelocal))/60;;
   if(gio>=inpThoiGianBatDau && gio<inpThoiGianKetThuc) return true;
   else return false;
}
//+------------------------------------------------------------------+
int FunPhanThapPhanKhoiLuong()
{
   double lot_step=MarketInfo(Symbol(),MODE_LOTSTEP);
   if(lot_step==0.01) return 2;
   if(lot_step==0.05) return 2;
   if(lot_step==0.1) return 1;
   return 0;
}