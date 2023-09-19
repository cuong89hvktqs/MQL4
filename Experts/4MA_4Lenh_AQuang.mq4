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
CCustomBot glbBotTelegram;
input string inpChannelName="@botnvc89";//ID Kenh:
input string inpToken="1958439508:AAEMEKme2M9oX4aUyfPexA3h5C2N76sZziU";//Ma Token bot Telegram:
input double inpKhoiLuong=0.01;//Khoi luong vao lenh:
input int inpTP=100;//TP (pips):
input int inpSL=50;//SL (pips);
input int inpTrailingStop=50;// Trailing stop (pips):
input int inpSoNenVaoLenhTiep=14;// So nen vao lenh tiep theo:
input string inpStr1="THAM SO MA MO LENH";// CAI DAT THAM SO MA MO LENH
input ENUM_TIMEFRAMES inpTFKhungLon=PERIOD_CURRENT;//Timeframe khung tinh MA:
input int inpMAPeriod13 =13;// MA ngan:
input ENUM_MA_METHOD inpMAMethod13 = MODE_EMA;//MA Method ngan:
input ENUM_APPLIED_PRICE inpAppliedPrice13 =PRICE_CLOSE;// MA applied price ngan: 
input int inpMAPeriod34 =21;// MA trung binh 1 :
input ENUM_MA_METHOD inpMAMethod34  = MODE_EMA;//MA Method trung binh 1 :
input ENUM_APPLIED_PRICE inpAppliedPrice34 =PRICE_CLOSE;// MA applied price trung binh 1  :
input int inpMAPeriod50 =50;// MA trung binh 2 :
input ENUM_MA_METHOD inpMAMethod50  = MODE_EMA;//MA Method trung binh 2 :
input ENUM_APPLIED_PRICE inpAppliedPrice50 =PRICE_CLOSE;// MA applied price trung binh 2 :
input int inpMAPeriod89 =89;// MA dai :
input ENUM_MA_METHOD inpMAMethod89  = MODE_EMA;//MA Method dai :
input ENUM_APPLIED_PRICE inpAppliedPrice89 =PRICE_CLOSE;// MA applied price dai :
input string str0="THAM SO HAI DUONG BB VA MA120";//CAI DAT THAM SO BB:
input int inpBandPeriod=20; //Band period:
input double inpBandDevitation=2;//Band devitation:
input ENUM_APPLIED_PRICE inpBandAppliedPrice=PRICE_CLOSE;// BAnd applied price:
input int inpMAPeriod120 =120;// MA Giao cat BB:
input ENUM_MA_METHOD inpMAMethod120  = MODE_EMA;//MA Method Giao cat BB:
input ENUM_APPLIED_PRICE inpAppliedPrice120 =PRICE_CLOSE;// MA applied price Giao cat BB:

input string inpStr2="THAM SO MA DONG LENH";// CAI DAT THAM SO MA DONG LENH
input ENUM_TIMEFRAMES inpDongLenhMATF=PERIOD_CURRENT;//Timeframe khung tinh MA dong lenh:
input int inpDongLenhMAPeriod55 =55;// MA ngan dong lenh  :
input ENUM_MA_METHOD inpDongLenhMethod55  = MODE_EMA;//MA Method ngan dong lenh :
input ENUM_APPLIED_PRICE inpDongLenhAppliedPrice55 =PRICE_CLOSE;// MA applied price ngan dong lenh:
input int inpDongLenhMAPeriod90 =90;// MA dai dong lenh:
input ENUM_MA_METHOD inpDongLenhMAMethod90  = MODE_EMA;//MA Method dai dong lenh :
input ENUM_APPLIED_PRICE inpDongLenhAppliedPrice90 =PRICE_CLOSE;// MA applied price dai dong lenh :



input int inpMagicNumber=123;// Magic number:
input int inpSlippage=50;//Slippage (points):

//int glbCanhVaoLenh=-1;// 0: Canh Buy, 1: Canh sell
int glbDemNenVaoLenhTheoMA13=0;
int glbDemNenVaoLenhTheoMA34=0;
int glbDemNenVaoLenhTheoMA50=0;
int glbDemNenVaoLenhTheoMA89=0;
string glbMessages="";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
     glbBotTelegram.Token(inpToken);
     string msgTele=StringFormat("Cap Tien: %s\nKet noi MT4 va telegram Thanh cong.",Symbol());
      glbBotTelegram.SendMessage(inpChannelName,msgTele); 
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
    /* int CanhLenh=FunKiemTraGiaoCatMA50MA89CanhVaoLenh();
    {
        if(CanhLenh!=glbCanhVaoLenh && CanhLenh>=0)
        {
            glbCanhVaoLenh=CanhLenh;
            FunReset();// Reset dem nen vao lenh
        }
    } */
    if(FunKiemTraSangNenMoiChuaKhungLon()==true)
    {
        if(glbDemNenVaoLenhTheoMA13>0)glbDemNenVaoLenhTheoMA13++;
        if(glbDemNenVaoLenhTheoMA34>0)glbDemNenVaoLenhTheoMA34++;
        if(glbDemNenVaoLenhTheoMA50>0)glbDemNenVaoLenhTheoMA50++;
        if(glbDemNenVaoLenhTheoMA89>0)glbDemNenVaoLenhTheoMA89++;
        FunKiemTraBBCatLenMA120();
    }
    if(FunKiemTraSangNenMoiChuaKhungDongLenhTheoMAGiaoCat())
    {
        if(FunKiemTraGiaoCatMA55MA90CanhDongLenh()==0)
        {
            Print("DONG TAT CAC CAC LENH SELL KHI DOI XU HUONG");
            FunDongTatCaCacLenh(OP_SELL);
            FunReset();

        }
        else if(FunKiemTraGiaoCatMA55MA90CanhDongLenh()==1)
        {
             Print("DONG TAT CAC CAC LENH BUY KHI DOI XU HUONG");
            FunDongTatCaCacLenh(OP_BUY);
            FunReset();
        }
    }
    //if(glbCanhVaoLenh==0)//Canh buy
    {
        FunKiemTraVaoLenhBuy();
    }
   // else if(glbCanhVaoLenh==1)//Canh sell
    {
        //Print("Tim dk sell");
         FunKiemTraVaoLenhSell();
    }
    // DICH SL theo Trailing stop
    for (int i = 0; i < OrdersTotal(); i++)
    {
        if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue;
        if(OrderSymbol()==Symbol() && OrderMagicNumber()==inpMagicNumber)   
            FunTrailingStopTicket(OrderTicket(),inpTrailingStop);  
    }
    
    string s="";
    s+="\nDem nen khi cham MA "+IntegerToString(inpMAPeriod13)+": "+IntegerToString(glbDemNenVaoLenhTheoMA13);
    s+="\nDem nen khi cham MA "+IntegerToString(inpMAPeriod34)+": "+IntegerToString(glbDemNenVaoLenhTheoMA34);
    s+="\nDem nen khi cham MA "+IntegerToString(inpMAPeriod50)+": "+IntegerToString(glbDemNenVaoLenhTheoMA50);
    s+="\nDem nen khi cham MA "+IntegerToString(inpMAPeriod89)+": "+IntegerToString(glbDemNenVaoLenhTheoMA89);
    if(FunKiemTraDieuKienViTriCacMA()==0)Comment("CANH BUY"+s);
    else if(FunKiemTraDieuKienViTriCacMA()==1)Comment("CANH SELL"+s);
    else Comment("CHO DOI XU HUONG XUAT HIEN");
    FunXuLyGuiTinNhanTelegram();
}
//+------------------------------------------------------------------+
void FunKiemTraVaoLenhBuy()
{
    int Ticket=-1;
    if (FunKiemTraDieuKienViTriCacMA()==0)//MA13>MA34>MA50>MA89
    {
        if( FunKiemTraChamMADeBuy(inpMAPeriod13) ==true && 
            (glbDemNenVaoLenhTheoMA13==0 || glbDemNenVaoLenhTheoMA13>inpSoNenVaoLenhTiep))
        {
            if((Ticket=FunVaoLenh(OP_BUY,Ask,inpSL,inpTP,inpKhoiLuong,inpMAPeriod13))>0)
            {
                glbDemNenVaoLenhTheoMA13=1;
            }
               
        }
        if( FunKiemTraChamMADeBuy(inpMAPeriod34) ==true && 
            (glbDemNenVaoLenhTheoMA34==0 || glbDemNenVaoLenhTheoMA34>inpSoNenVaoLenhTiep))
        {
            if((Ticket=FunVaoLenh(OP_BUY,Ask,inpSL,inpTP,inpKhoiLuong,inpMAPeriod34))>0)
            {
                glbDemNenVaoLenhTheoMA34=1;
            }
                
        }
        if( FunKiemTraChamMADeBuy(inpMAPeriod50) ==true && 
            (glbDemNenVaoLenhTheoMA50==0 || glbDemNenVaoLenhTheoMA50>inpSoNenVaoLenhTiep))
        {
            if((Ticket=FunVaoLenh(OP_BUY,Ask,inpSL,inpTP,inpKhoiLuong,inpMAPeriod50))>0)
            {
                glbDemNenVaoLenhTheoMA50=1;
            }
                
        }
        if( FunKiemTraChamMADeBuy(inpMAPeriod89) ==true && 
            (glbDemNenVaoLenhTheoMA89==0 || glbDemNenVaoLenhTheoMA89>inpSoNenVaoLenhTiep))
        {
            if((Ticket=FunVaoLenh(OP_BUY,Ask,inpSL,inpTP,inpKhoiLuong,inpMAPeriod89))>0)
            {
                glbDemNenVaoLenhTheoMA89=1;
            }
                
        }
    }
    
}
//+------------------------------------------------------------------+
void FunKiemTraVaoLenhSell()
{
    int Ticket=-1;
    if (FunKiemTraDieuKienViTriCacMA()==1)//MA13<MA34<MA50<MA89
    {
        //Print("Thoa Man 4 duong MA");
        if( FunKiemTraChamMADeSell(inpMAPeriod13) ==true && 
            (glbDemNenVaoLenhTheoMA13==0 || glbDemNenVaoLenhTheoMA13>inpSoNenVaoLenhTiep))
        {
            if((Ticket=FunVaoLenh(OP_SELL,Bid,inpSL,inpTP,inpKhoiLuong,inpMAPeriod13))>0)
            {
                glbDemNenVaoLenhTheoMA13=1;
            }
                
        }
        if( FunKiemTraChamMADeSell(inpMAPeriod34) ==true && 
            (glbDemNenVaoLenhTheoMA34==0 || glbDemNenVaoLenhTheoMA34>inpSoNenVaoLenhTiep))
        {
            if((Ticket=FunVaoLenh(OP_SELL,Bid,inpSL,inpTP,inpKhoiLuong,inpMAPeriod34))>0)
            {
                glbDemNenVaoLenhTheoMA34=1;

            }
        }
        if( FunKiemTraChamMADeSell(inpMAPeriod50) ==true && 
            (glbDemNenVaoLenhTheoMA50==0 || glbDemNenVaoLenhTheoMA50>inpSoNenVaoLenhTiep))
        {
            if((Ticket=FunVaoLenh(OP_SELL,Bid,inpSL,inpTP,inpKhoiLuong,inpMAPeriod50))>0)
            {
                 glbDemNenVaoLenhTheoMA50=1;
            }
               
        }
        if( FunKiemTraChamMADeSell(inpMAPeriod89) ==true && 
            (glbDemNenVaoLenhTheoMA89==0 || glbDemNenVaoLenhTheoMA89>inpSoNenVaoLenhTiep))
        {
            if((Ticket=FunVaoLenh(OP_SELL,Bid,inpSL,inpTP,inpKhoiLuong,inpMAPeriod89))>0)
            {
                glbDemNenVaoLenhTheoMA89=1;
            }
                
        }
    }
}
//+------------------------------------------------------------------+
bool FunKiemTraChamMADeBuy(int MAPeriod)
{
    double MAVAlue0, MAValue1;;
    bool kt=false;
    if(MAPeriod==inpMAPeriod13)
    {
        MAVAlue0=FunTinhMAValue(inpTFKhungLon,inpMAPeriod13 ,inpMAMethod13 ,inpAppliedPrice13 ,0);
        MAValue1=FunTinhMAValue(inpTFKhungLon,inpMAPeriod13 ,inpMAMethod13 ,inpAppliedPrice13 ,1);
        if(Close[1]>MAValue1 && MAVAlue0>=Bid)kt=true;
    }
    else if (MAPeriod==inpMAPeriod34)
    {
        MAVAlue0=FunTinhMAValue(inpTFKhungLon,inpMAPeriod34 ,inpMAMethod34 ,inpAppliedPrice34,0);
        MAValue1=FunTinhMAValue(inpTFKhungLon,inpMAPeriod34 ,inpMAMethod34 ,inpAppliedPrice34 ,1);
        if(Close[1]>MAValue1 && MAVAlue0>=Bid)kt=true;
    }
    else if (MAPeriod==inpMAPeriod50)
    {
        MAVAlue0=FunTinhMAValue(inpTFKhungLon,inpMAPeriod50 ,inpMAMethod50 ,inpAppliedPrice50 ,0);
        MAValue1=FunTinhMAValue(inpTFKhungLon,inpMAPeriod50 ,inpMAMethod50 ,inpAppliedPrice50 ,1);
        if(Close[1]>MAValue1 && MAVAlue0>=Bid)kt=true;
    }
    else 
    {
        MAVAlue0=FunTinhMAValue(inpTFKhungLon,inpMAPeriod89 ,inpMAMethod89 ,inpAppliedPrice89 ,0);
        MAValue1=FunTinhMAValue(inpTFKhungLon,inpMAPeriod89 ,inpMAMethod89 ,inpAppliedPrice89 ,1);
        if(Close[1]>MAValue1 && MAVAlue0>=Bid)kt=true;
    }
    //Print("Bine kiem tra : ", kt);
     return kt;   
}
//+------------------------------------------------------------------+
bool FunKiemTraChamMADeSell(int MAPeriod)
{
    double MAVAlue0, MAValue1;;
    bool kt=false;
    if(MAPeriod==inpMAPeriod13)
    {
        MAVAlue0=FunTinhMAValue(inpTFKhungLon,inpMAPeriod13 ,inpMAMethod13 ,inpAppliedPrice13 ,0);
        MAValue1=FunTinhMAValue(inpTFKhungLon,inpMAPeriod13 ,inpMAMethod13 ,inpAppliedPrice13 ,1);
        if(Close[1]<MAValue1 && MAVAlue0<=Bid)kt=true;
    }
    else if (MAPeriod==inpMAPeriod34)
    {
        MAVAlue0=FunTinhMAValue(inpTFKhungLon,inpMAPeriod34 ,inpMAMethod34 ,inpAppliedPrice34,0);
        MAValue1=FunTinhMAValue(inpTFKhungLon,inpMAPeriod34 ,inpMAMethod34 ,inpAppliedPrice34 ,1);
        if(Close[1]<MAValue1 && MAVAlue0<=Bid)kt=true;
    }
    else if (MAPeriod==inpMAPeriod50)
    {
        MAVAlue0=FunTinhMAValue(inpTFKhungLon,inpMAPeriod50 ,inpMAMethod50 ,inpAppliedPrice50 ,0);
        MAValue1=FunTinhMAValue(inpTFKhungLon,inpMAPeriod50 ,inpMAMethod50 ,inpAppliedPrice50 ,1);
        if(Close[1]<MAValue1 && MAVAlue0<=Bid)kt=true;
    }
    else 
    {
        MAVAlue0=FunTinhMAValue(inpTFKhungLon,inpMAPeriod89 ,inpMAMethod89 ,inpAppliedPrice89 ,0);
        MAValue1=FunTinhMAValue(inpTFKhungLon,inpMAPeriod89 ,inpMAMethod89 ,inpAppliedPrice89 ,1);
        if(Close[1]<MAValue1 && MAVAlue0<=Bid)kt=true;
    }
    //Print("Gia cham MA ",MAPeriod, " Value : ",MAVAlue0, " Value 1: ", MAValue1, " Close price: ", Close[1], " Kt =",kt);
     return kt;   
}
//+------------------------------------------------------------------+
//Điều kiện 1 lúc nào củng phải thoả: 13 > 34 > 50 > 89: Tra ve 0
int FunKiemTraDieuKienViTriCacMA()
{
    double MA13, MA21,MA50,MA89,MA120_0, MA120_1;
    MA13=FunTinhMAValue(inpTFKhungLon,inpMAPeriod13 ,inpMAMethod13 ,inpAppliedPrice13 ,0);
    MA21=FunTinhMAValue(inpTFKhungLon,inpMAPeriod34 ,inpMAMethod34 ,inpAppliedPrice34 ,0);
    MA50=FunTinhMAValue(inpTFKhungLon,inpMAPeriod50 ,inpMAMethod50 ,inpAppliedPrice50 ,0);
    MA89=FunTinhMAValue(inpTFKhungLon,inpMAPeriod89 ,inpMAMethod89 ,inpAppliedPrice89 ,0);
    MA120_0=FunTinhMAValue(inpTFKhungLon,inpMAPeriod120 ,inpMAMethod120 ,inpAppliedPrice120 ,0);
    MA120_1=FunTinhMAValue(inpTFKhungLon,inpMAPeriod120 ,inpMAMethod120 ,inpAppliedPrice120 ,1);
    double BBTren, BBDuoi,BBTren_1, BBDuoi_1;
    BBTren=iBands(Symbol(),PERIOD_CURRENT,inpBandPeriod,inpBandDevitation,0,inpBandAppliedPrice,MODE_UPPER,0);
    BBDuoi=iBands(Symbol(),PERIOD_CURRENT,inpBandPeriod,inpBandDevitation,0,inpBandAppliedPrice,MODE_LOWER,0);
    BBTren_1=iBands(Symbol(),PERIOD_CURRENT,inpBandPeriod,inpBandDevitation,0,inpBandAppliedPrice,MODE_UPPER,1);
    BBDuoi_1=iBands(Symbol(),PERIOD_CURRENT,inpBandPeriod,inpBandDevitation,0,inpBandAppliedPrice,MODE_LOWER,1);
    if(MA13>MA21 && MA21>MA50 && MA50>MA89 && BBDuoi_1>=MA120_1 && BBDuoi>=MA120_0) return 0;
    if(MA13<MA21 && MA21 <MA50 && MA50<MA89 && BBTren_1<=MA120_1 && BBTren<=MA120_0) return 1;
    return -1;
}
//+------------------------------------------------------------------+
void FunKiemTraBBCatLenMA120()
{
    double BBTren_0, BBDuoi_0,BBTren_1, BBDuoi_1,MA120_0, MA120_1;
    BBTren_0=iBands(Symbol(),PERIOD_CURRENT,inpBandPeriod,inpBandDevitation,0,inpBandAppliedPrice,MODE_UPPER,1);
    BBDuoi_0=iBands(Symbol(),PERIOD_CURRENT,inpBandPeriod,inpBandDevitation,0,inpBandAppliedPrice,MODE_LOWER,1);
    BBTren_1=iBands(Symbol(),PERIOD_CURRENT,inpBandPeriod,inpBandDevitation,0,inpBandAppliedPrice,MODE_UPPER,2);
    BBDuoi_1=iBands(Symbol(),PERIOD_CURRENT,inpBandPeriod,inpBandDevitation,0,inpBandAppliedPrice,MODE_LOWER,2);
    MA120_0=FunTinhMAValue(inpTFKhungLon,inpMAPeriod120 ,inpMAMethod120 ,inpAppliedPrice120 ,1);
    MA120_1=FunTinhMAValue(inpTFKhungLon,inpMAPeriod120 ,inpMAMethod120 ,inpAppliedPrice120 ,2);
    if(BBDuoi_1<MA120_1 && BBDuoi_0>MA120_0) FunGuiTinNhan("BB DUOI CAT LEN MA120 ");
    if(BBTren_1>MA120_1 && BBTren_0<MA120_0) FunGuiTinNhan("BB TREN CAT XUONG MA120 ");
    return;
}
 
//+------------------------------------------------------------------+

double FunTinhMAValue(ENUM_TIMEFRAMES MA_TimeFrame, int MA_Period, ENUM_MA_METHOD MA_Method, ENUM_APPLIED_PRICE MA_Applied_price, int shift=0)
{
   return iMA(Symbol(),MA_TimeFrame,MA_Period,0,MA_Method,MA_Applied_price,shift);
    
}

//********************************************************************/
int FunKiemTraGiaoCatMA50MA89CanhVaoLenh()//0: Cat len, 1: Cat xuong, -1: khong xac dinh
{
   double MA50_shift1, MA50_shift0, MA89_shift1,MA89_shift0;
   MA50_shift0=FunTinhMAValue(inpTFKhungLon,inpMAPeriod50 ,inpMAMethod50 ,inpAppliedPrice50 ,1);
   MA89_shift0=FunTinhMAValue(inpTFKhungLon,inpMAPeriod89 ,inpMAMethod89 ,inpAppliedPrice89 ,1);
   MA50_shift1=FunTinhMAValue(inpTFKhungLon,inpMAPeriod50 ,inpMAMethod50 ,inpAppliedPrice50 ,2);
   MA89_shift1=FunTinhMAValue(inpTFKhungLon,inpMAPeriod89 ,inpMAMethod89 ,inpAppliedPrice89 ,2);
   if(MA50_shift1<=MA89_shift1 && MA50_shift0>=MA89_shift0) return 0;
   if(MA50_shift1>=MA89_shift1 && MA50_shift0<=MA89_shift0) return 1;
   return -1;
} 

//********************************************************************/
int FunKiemTraGiaoCatMA55MA90CanhDongLenh()//0: Cat len, 1: Cat xuong, -1: khong xac dinh
{
   double MA50_shift1, MA50_shift0, MA89_shift1,MA89_shift0;
   MA50_shift0=FunTinhMAValue(inpDongLenhMATF,inpDongLenhMAPeriod55,inpDongLenhMethod55 ,inpDongLenhAppliedPrice55 ,1);
   MA89_shift0=FunTinhMAValue(inpDongLenhMATF,inpDongLenhMAPeriod90,inpDongLenhMAMethod90 ,inpDongLenhAppliedPrice90,1);
   MA50_shift1=FunTinhMAValue(inpDongLenhMATF,inpDongLenhMAPeriod55,inpDongLenhMethod55 ,inpDongLenhAppliedPrice55 ,2);
   MA89_shift1=FunTinhMAValue(inpDongLenhMATF,inpDongLenhMAPeriod90,inpDongLenhMAMethod90 ,inpDongLenhAppliedPrice90 ,2);
   if(MA50_shift1<=MA89_shift1 && MA50_shift0>MA89_shift0) return 0;
   if(MA50_shift1>=MA89_shift1 && MA50_shift0<MA89_shift0) return 1;
   return -1;
} 
//********************************************************************/
bool FunKiemTraSangNenMoiChuaKhungLon()
{
   static datetime _NenCuoi=iTime(Symbol(),inpTFKhungLon,0);
   datetime _NenHienTai=iTime(Symbol(),inpTFKhungLon,0);
   if(_NenCuoi!=_NenHienTai)
   {
      _NenCuoi=_NenHienTai;
      return true;
   }
   else return false;
 }

bool FunKiemTraSangNenMoiChuaKhungDongLenhTheoMAGiaoCat()
{
static datetime _NenCuoiKhungMAGiaoCat=iTime(Symbol(),inpDongLenhMATF,0);
   datetime _NenHienTaiKhungMAGiaoCat=iTime(Symbol(),inpDongLenhMATF,0);
   if(_NenCuoiKhungMAGiaoCat!=_NenHienTaiKhungMAGiaoCat)
   {
      _NenCuoiKhungMAGiaoCat=_NenHienTaiKhungMAGiaoCat;
      return true;
   }
   else return false;
}
//-----------------------------------------Đặt lệnh-----------------------------------------
 int FunVaoLenh(int LoaiLenh, double DiemVaoLenh,double StopLossPips, double TakeProfitPips, double KhoiLuongVaoLenh, int MAChamVaoLenh)
{
    int Ticket=-1;
    double StopLoss=0,TakeProfit=0;
    if(KhoiLuongVaoLenh==0) return -1;
    
    if(LoaiLenh==OP_BUY || LoaiLenh==OP_BUYLIMIT || LoaiLenh==OP_BUYSTOP)
    {
       StopLoss=DiemVaoLenh-StopLossPips*10*Point();
       TakeProfit=DiemVaoLenh+TakeProfitPips*10*Point();  
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,"BUY_"+IntegerToString(MAChamVaoLenh),inpMagicNumber,0,clrBlue);
    }
    if(LoaiLenh==OP_SELL|| LoaiLenh==OP_SELLLIMIT || LoaiLenh==OP_SELLSTOP)
    {
      StopLoss=DiemVaoLenh+StopLossPips*10*Point();
       TakeProfit=DiemVaoLenh-TakeProfitPips*10*Point();  
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,"SELL_"+IntegerToString(MAChamVaoLenh),inpMagicNumber,0,clrRed);
    }
    return Ticket;
}
void FunReset()
{
    glbDemNenVaoLenhTheoMA13=0;
    glbDemNenVaoLenhTheoMA34=0;
    glbDemNenVaoLenhTheoMA50=0;
    glbDemNenVaoLenhTheoMA89=0;
}

void FunDongTatCaCacLenh(int LoaiLenh)
{
    for (int i = OrdersTotal()-1; i >=0; i--)
    {
        if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue;
        if(OrderSymbol()==Symbol()&&OrderMagicNumber()==inpMagicNumber && OrderType()==LoaiLenh)
        {
            if(LoaiLenh==OP_BUY) OrderClose(OrderTicket(),OrderLots(),Bid,inpSlippage,clrNONE);
            else OrderClose(OrderTicket(),OrderLots(),Ask,inpSlippage,clrNONE);
        }
    }
    
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
 //*********************************************************************************************************************************************
 int glbTongLenh=0;
 string glbMsg="";
 int glbTapLenh[100];
 void FunXuLyGuiTinNhanTelegram()
 {
    if(OrdersTotal()>glbTongLenh)
    {
        if(OrderSelect(OrdersTotal()-1,SELECT_BY_POS,MODE_TRADES))
        {
            if(OrderType()==OP_BUY||OrderType()==OP_SELL)
                glbMsg=StringFormat("%s\n%s %s\nGiá khớp lệnh: %s\n==> SL: %s \n==> TP: %s \nKieu vao MA: %s",TimeToString(TimeLocal()),FunChuyenDoiLenh(OrderType()),OrderSymbol(),DoubleToString(OrderOpenPrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),
                                DoubleToString(OrderStopLoss(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),DoubleToString(OrderTakeProfit(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),OrderComment());
            else
                glbMsg=StringFormat("%s\nMỞ LỆNH CHỜ: %s %s\nGiá khớp lệnh: %s\n==> SL: %s \n==> TP: %s \nKieu vao MA: %s",TimeToString(TimeLocal()),FunChuyenDoiLenh(OrderType()),OrderSymbol(),DoubleToString(OrderOpenPrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),
                                DoubleToString(OrderStopLoss(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),DoubleToString(OrderTakeProfit(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),OrderComment());
            FunGuiTinNhan(glbMsg);
            FunThemLenhMoi(OrderTicket());
        }
        
    }
        // Xoa phan tu 
    else if(OrdersTotal()<glbTongLenh)
    {
        FunXoaLenhDaDong();
    }
    else
    {
        //FunKiemTraLenhThayDoi();
        ;
    }
        // Xử lý trường hợp đóng lệnh 1 phần
    FunXuLyDongLenhMotPhan();
 }
 string FunChuyenDoiLenh(int LoaiLenh)
{
   switch (LoaiLenh) {
    case OP_BUY: return("BUY");
    case OP_SELL: return("SELL");
    case OP_BUYLIMIT: return("BUY LIMIT");
    case OP_SELLLIMIT: return("SELL LIMIT");
    case OP_BUYSTOP: return("BUY STOP");
    case OP_SELLSTOP: return("SELL STOP");
    default: return("???");
    }
}
////=======================================================================
void FunGuiTinNhan(string msg)
{
    glbBotTelegram.SendMessage(inpChannelName,msg);
    
}

//=======================================================================
 void FunXuLyDongLenhMotPhan()
 {
   for(int i=0;i<glbTongLenh;i++)
   {
      
      OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES);    
      if(OrderCloseTime()>0)
      {
         double GiaMoLenh=OrderOpenPrice();
         double GiaDongLenh=OrderClosePrice();
         int  PipProfit=0;
         if(OrderType()%2==0)PipProfit=(int)NormalizeDouble((OrderClosePrice()-OrderOpenPrice())/(10*MarketInfo(OrderSymbol(),MODE_POINT)),0);
         else PipProfit=(int)NormalizeDouble((OrderOpenPrice()-OrderClosePrice())/(10*MarketInfo(OrderSymbol(),MODE_POINT)),0);
         double Lot=OrderLots();
         string Ticket=IntegerToString(OrderTicket());
         for(int j=OrdersTotal()-1;j>=0;j--)
         {
            OrderSelect(j,SELECT_BY_POS,MODE_TRADES);
            // Đây là phần lệnh còn lại do đóng một phần
            Print(OrderComment());
            Print(StringFind(OrderComment(),Ticket));
            if(StringFind(OrderComment(),Ticket)>=0)
            {
               string PhanTramLenhDong=DoubleToString((100*Lot)/(Lot+OrderLots()),0);
               if(PipProfit<=0)
                  glbMsg=StringFormat("%s\n(ĐÓNG MỘT PHẦN LỆNH)\nĐóng %s%% khối lượng lệnh: %s %s\nGiá mở lệnh: %s\nGiá đóng lệnh: %s (%d pips)",TimeToString(TimeLocal()),PhanTramLenhDong,FunChuyenDoiLenh(OrderType()),OrderSymbol(),
                                  DoubleToString(GiaMoLenh,(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),DoubleToString(GiaDongLenh,(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),PipProfit);
               else
                  glbMsg=StringFormat("%s\n(ĐÓNG MỘT PHẦN LỆNH)\nĐóng %s%% khối lượng lệnh: %s %s\nGiá mở lệnh: %s\nGiá đóng lệnh: %s (+%d pips)",TimeToString(TimeLocal()),PhanTramLenhDong,FunChuyenDoiLenh(OrderType()),OrderSymbol(),
                                  DoubleToString(GiaMoLenh,(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),DoubleToString(GiaDongLenh,(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),PipProfit);
               
               FunGuiTinNhan(glbMsg);
               break;
            }
         }
         
      }
   }
 
 }

 //=======================================================================
void FunXoaLenhDaDong()
{
    //xoa cac lenh da dong trong mang
    int i=0;
    while(i<glbTongLenh)
    {
      if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET))
      if(OrderCloseTime()>0)
      {
         //Print("Ticket close:",OrderTicket());
         if(OrderType()==OP_BUY)
         {
            int PipProfit=(int)NormalizeDouble((OrderClosePrice()-OrderOpenPrice())/(10*MarketInfo(OrderSymbol(),MODE_POINT)),0);
            if(StringFind(OrderComment(),"from")>=0)
            {
               if(PipProfit<=0)
                  glbMsg=StringFormat("%s\nĐÓNG PHẦN LỆNH CÒN LẠI\nLệnh: %s %s\nGiá mở lệnh: %s\nGiá đóng lệnh: %s (%d pips)",TimeToString(TimeLocal()),FunChuyenDoiLenh(OrderType()),OrderSymbol(),DoubleToString(OrderOpenPrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),DoubleToString(OrderClosePrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),PipProfit);
               else glbMsg=StringFormat("%s\nĐÓNG PHẦN LỆNH CÒN LẠI\nLệnh: %s %s\nGiá mở lệnh: %s\nGiá đóng lệnh: %s (+%d pips)",TimeToString(TimeLocal()),FunChuyenDoiLenh(OrderType()),OrderSymbol(),DoubleToString(OrderOpenPrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),DoubleToString(OrderClosePrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),PipProfit);
            }
            else 
            {
               if(PipProfit<=0)
                  glbMsg=StringFormat("%s\nĐÓNG LỆNH: %s %s\nGiá mở lệnh: %s\nGiá đóng lệnh: %s (%d pips)",TimeToString(TimeLocal()),FunChuyenDoiLenh(OrderType()),OrderSymbol(),DoubleToString(OrderOpenPrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),DoubleToString(OrderClosePrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),PipProfit);
               else glbMsg=StringFormat("%s\nĐÓNG LỆNH: %s %s\nGiá mở lệnh: %s\nGiá đóng lệnh: %s (+%d pips)",TimeToString(TimeLocal()),FunChuyenDoiLenh(OrderType()),OrderSymbol(),DoubleToString(OrderOpenPrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),DoubleToString(OrderClosePrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),PipProfit);
            }
            FunGuiTinNhan(glbMsg);
         }
         else if(OrderType()==OP_SELL)
         {
            
            int glbPipProfit=(int)NormalizeDouble((OrderOpenPrice()-OrderClosePrice())/(10*MarketInfo(OrderSymbol(),MODE_POINT)),0);
            if(StringFind(OrderComment(),"from")>=0)
            {
               if(glbPipProfit<=0)
                  glbMsg=StringFormat("%s\nĐÓNG PHẦN LỆNH CÒN LẠI\nLệnh: %s %s\nGiá mở lệnh: %s\nGiá đóng lệnh: %s (%d pips)",TimeToString(TimeLocal()),FunChuyenDoiLenh(OrderType()),OrderSymbol(),DoubleToString(OrderOpenPrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),DoubleToString(OrderClosePrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),glbPipProfit);
               else glbMsg=StringFormat("%s\nĐÓNG PHẦN LỆNH CÒN LẠI\nLệnh: %s %s\nGiá mở lệnh: %s\nGiá đóng lệnh: %s (+%d pips)",TimeToString(TimeLocal()),FunChuyenDoiLenh(OrderType()),OrderSymbol(),DoubleToString(OrderOpenPrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),DoubleToString(OrderClosePrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),glbPipProfit);
            }
            else   
            {
               if(glbPipProfit<=0)
                  glbMsg=StringFormat("ĐÓNG LỆNH: %s %s\nGiá mở lệnh: %s\nGiá đóng lệnh: %s (%d pips)",FunChuyenDoiLenh(OrderType()),OrderSymbol(),DoubleToString(OrderOpenPrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),DoubleToString(OrderClosePrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),glbPipProfit);
               else glbMsg=StringFormat("ĐÓNG LỆNH: %s %s\nGiá mở lệnh: %s\nGiá đóng lệnh: %s (+%d pips)",FunChuyenDoiLenh(OrderType()),OrderSymbol(),DoubleToString(OrderOpenPrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),DoubleToString(OrderClosePrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),glbPipProfit);
            }
            FunGuiTinNhan(glbMsg);
         }
         else
         {  
            glbMsg=StringFormat("%s\nXÓA LỆNH CHỜ: %s %s giá %s",TimeToString(TimeLocal()),FunChuyenDoiLenh(OrderType()),OrderSymbol(),DoubleToString(OrderOpenPrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)));
            FunGuiTinNhan(glbMsg);
         }        
         for(int j=i; j<=glbTongLenh-2; j++)
         {
			   glbTapLenh[j] = glbTapLenh[j+1]; //Dịch các phần tử sang trái 1 vị trí
		}
		   glbTongLenh--; //Giảm số phần tử bớt 1
		   
      }
      else i++;  
    }
}

//=======================================================================
void FunThemLenhMoi(int Ticket)
{
   {
     // LenhX._ticket=FunCatBotKhoiLuongCuaLenh(LenhX._ticket);
      glbTapLenh[glbTongLenh]=Ticket; //Thêm x vào vị trí vt
	   glbTongLenh++; //Tăng số phần tử lên 1		
	}
}


 