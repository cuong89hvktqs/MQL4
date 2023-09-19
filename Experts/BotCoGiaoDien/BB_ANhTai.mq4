//+------------------------------------------------------------------+
//|                                                    BB_ANhTai.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property  indicator_chart_window
#include <Controls\Panel.mqh>
/*
   Bot vao lenh buy khi : thiet lap canh buy
   nen tang nam ngoai band duoi
   nen do cat band duoi bang gia dong cua va moa cua
   SL, TP theo than nen truoc do hoac cai tl tp bang tay
*/
enum ENUM_LOAI_LENH{
   CANH_BUY,
   CANH_SELL
};
enum ENUM_CAI_SLTP{
   TU_DONG,
   CAI_TAY
};
struct NgayThang
  {
   int          Ngay; // date
   int            Thang;  // bid price
   int            Nam;  // ask price
  };
NgayThang NgayHetHan={25,09,3022};
input double inpKhoiLuongVaoLenh=0.01;// Khoi luong vao lenh:
input int inpTongLenhAm=3;// Tong lenh am cho phep:
input int inpTongLoiNhuanToiDaTatCaCacCapTien=15;// Loi nhuan toi da cua tat ca cac cap tien ($):
input ENUM_LOAI_LENH inpLoaiLenh=CANH_BUY;// Loai lenh can vao:
input string inpThamSoSL="CAI DAT THAM SO CHO SL";//STOPLOSS:
input ENUM_CAI_SLTP inpKieuSL=TU_DONG;// Kieu SL:
input int inpBoiSoSLSpread=2;// Boi so spread SL:
input double inpSLTay=0;// Tham so SL bang tay:
input string inpThamSoTP="CAI DAT THAM SO CHO TP";//TAKE PROFIT:
input ENUM_CAI_SLTP inpKieuTP=TU_DONG;// Kieu TP:
input int inpBoiSoTPSpread=2;// Boi so spread TP:
input double inpTPTay=0;// Tham so TP bang tay:
input int inpMagicNumber=12345;// Magic number:
input int inpSlippage=50;//Slipage:
input string bb="THAM SO BOLINGER";// CAI DAT:
input int inpBBPeriod=20;// Kieu BB:
input ENUM_APPLIED_PRICE inpBBGia=PRICE_CLOSE;// Gia tinh BB
input double inpBBDevitation=2;//BB devitation:


CPanel myPanel;
ENUM_LOAI_LENH glbLoaiLenh=inpLoaiLenh;
double glbSLTay=0, glbTPTay=0;
int glbBoiSoSL=0,glbBoiSoTP=0;
int glbTongLenh=0;
int glbTapLenh[100];
ENUM_CAI_SLTP glbKieuSL, glbKieuTP;
int glbMaxProfit=0;
double glbDieuKienGiaDongNen=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
      glbLoaiLenh=inpLoaiLenh;
      glbSLTay=inpSLTay;glbBoiSoSL=inpBoiSoSLSpread;
      glbTPTay=inpTPTay; glbBoiSoTP=inpBoiSoTPSpread;
      glbKieuSL=inpKieuSL;
      glbKieuTP=inpKieuTP;
      glbMaxProfit=inpTongLoiNhuanToiDaTatCaCacCapTien;
      if(FunKiemDaHetHanChua(NgayHetHan)==true)return INIT_FAILED;
      myPanel.Create(0,"Bang",0,0,70,159,445);
      myPanel.ColorBackground(clrDarkSlateGray);
      FunLabelCreate(0,"LableRisk",0,20,75,0,"RISK MANAGEMENT","Arial",9,clrYellow);
      FunLabelCreate(0,"lblLenhCanh",0,4,110,0,"LOAI LENH","Arial",9,clrYellow);
     // Fun
      FunEditCreate(0,"edtLoaiLenh",0,80,105,70,30,FunTenLenh(),"Arial",12,ALIGN_CENTER,false,CORNER_LEFT_UPPER,clrRed,clrWhite);
      FunButtonCreate(0,"btnTinhSell",0,4,140,70,40,CORNER_LEFT_UPPER,"SELLING","Arial",9,clrBlue,clrPink);
      FunButtonCreate(0,"btnTinhBuy",0,80,140,75,40,CORNER_LEFT_UPPER,"BUYING","Arial",9,clrYellow,clrBlue);
      FunButtonCreate(0,"btnSL",0,0,190,158,40,CORNER_LEFT_UPPER,"CAI DAT STOPLOSS","Arial",9,clrYellow,clrBlue);
      
      FunLabelCreate(0,"lblSLTuDong",0,4,235,0,"BOI SO AUTOSL","Arial",9,clrYellow);
      FunEditCreate(0,"edtSLTuDong",0,105,235,50,20,DoubleToString(inpBoiSoSLSpread,0),"Arial",12,ALIGN_CENTER,false,CORNER_LEFT_UPPER,clrRed,clrWhite);
      
      FunLabelCreate(0,"lblSLTay",0,4,260,0,"SL TAY:","Arial",9,clrYellow);
      FunEditCreate(0,"edtSLTay",0,55,260,100,20,DoubleToString(inpSLTay,Digits),"Arial",12,ALIGN_CENTER,false,CORNER_LEFT_UPPER,clrRed,clrWhite);
       
      FunButtonCreate(0,"btnTP",0,0,285,158,40,CORNER_LEFT_UPPER,"CAI DAT TP","Arial",9,clrYellow,clrBlue);
      
       FunLabelCreate(0,"lblTPTuDong",0,4,335,0,"BOI SO AUTOTP","Arial",9,clrYellow);
       FunEditCreate(0,"edtTPTuDong",0,105,332,50,20,DoubleToString(inpBoiSoTPSpread,0),"Arial",12,ALIGN_CENTER,false,CORNER_LEFT_UPPER,clrRed,clrWhite);
       
       FunLabelCreate(0,"lblTPTay",0,4,360,0,"TP TAY:","Arial",9,clrYellow);
       FunEditCreate(0,"edtTPTay",0,55,360,100,20,DoubleToString(inpTPTay,Digits),"Arial",12,ALIGN_CENTER,false,CORNER_LEFT_UPPER,clrRed,clrWhite);
       
       FunLabelCreate(0,"lblLoiNhuan",0,4,390,0,"Max profit ($):","Arial",9,clrYellow);
       FunEditCreate(0,"edtTongLoiNhuan",0,100,390,50,20,IntegerToString(inpTongLoiNhuanToiDaTatCaCacCapTien),"Arial",12,ALIGN_CENTER,false,CORNER_LEFT_UPPER,clrRed,clrWhite);
       
       FunLabelCreate(0,"lblGiaDongNen",0,4,422,0,"DK dong nen:","Arial",9,clrYellow);
       FunEditCreate(0,"edtGiaDongNen",0,82,420,73,20,DoubleToString(inpTPTay,Digits),"Arial",12,ALIGN_CENTER,false,CORNER_LEFT_UPPER,clrRed,clrWhite);
      
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
      ObjectsDeleteAll(0);
  }

  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
      
      if(glbTongLenh>0)
         FunXoaLenhDaDongKhoiMang();
      FunCaiDatSLTPChoLenhVaoBangTay();
      if(FunTinhTongLoiNhuan()>=glbMaxProfit && glbMaxProfit>0) FunDongTatCaCacLenh();
      if(FunKiemTraSangNenMoiChua())
      {
         // Thoa man dieu kien sell chua
         if(FunKiemTraDieuKienVaoLenh()==true)
         {
            double GiaSL=0, GiaTP=0;
            int ticket=-1;
            FunTinhSLTPChoLenh(GiaSL,GiaTP,glbLoaiLenh);
            if(glbLoaiLenh==CANH_BUY)
            {
               ticket=FunVaoLenhSLTPTheoGia(OP_BUY,Ask,GiaSL,GiaTP,inpKhoiLuongVaoLenh);
            }
            else
            {
               ticket=FunVaoLenhSLTPTheoGia(OP_SELL,Bid,GiaSL,GiaTP,inpKhoiLuongVaoLenh);
            }
            if(ticket>0)
            {
               glbTapLenh[glbTongLenh]=ticket;
               glbTongLenh++;
            }
         }
      }
      Comment("Lenh dang canh vao: ", FunTenLenh(), "\nTong so lenh dang quan ly: ",glbTongLenh, "\nTong lo toi da cho phep: ",glbMaxProfit);
  }
  //+------------------------------------------------------------------+
 bool FunKiemTraDieuKienVaoLenh()// -1: SELL; 1: Buy: 0: Chua xac dinh
 {
   int kt=0;
   if(glbLoaiLenh==CANH_BUY)
   {
      // Nen tang ngoai band thi buy
      // nen giam cat bend: buy
      double BB_down=iBands(Symbol(),0,inpBBPeriod,inpBBDevitation,0,inpBBGia,MODE_LOWER,1);
      if(glbDieuKienGiaDongNen>0)
      {
         if(Close[1]>glbDieuKienGiaDongNen)
            return false;
      }
      if(Close[1]<Open[1] && Close[1]<BB_down && Open[1]>BB_down)// nen giam va cat BB
         return true;
      if(Close[1]>Open[1] && Open[1]<BB_down)// Nen xanh nam ngoai band
         return true;
      return false;
   }
   else
   {
      double BB_up=iBands(Symbol(),0,inpBBPeriod,inpBBDevitation,0,inpBBGia,MODE_UPPER,1);
      if(glbDieuKienGiaDongNen>0)
      {
         if(Close[1]<glbDieuKienGiaDongNen)
            return false;
      }
      if(Close[1]>Open[1] && Close[1]>BB_up && Open[1]<BB_up)// nen tang va cat BB 
         return true;
      if(Close[1]<Open[1] && Close[1]>BB_up)// Nen giam nam ngoai band
         return true;
      return false;
   }
 } 
 //+------------------------------------------------------------------+
 
int FunDemSoLenhAm()
{
   int dem=0;
   for(int i=0;i<glbTongLenh;i++)
   {
      if(OrderSelect(glbTapLenh[i],SELECT_BY_TICKET,MODE_TRADES))
      {
         if(OrderProfit()<0)dem++;
      }
   }
   return dem;
} 
 //+------------------------------------------------------------------+
 void FunTinhSLTPChoLenh(double &GiaSL, double &GiaTP, ENUM_LOAI_LENH loailenh)
 {
  // double GiaThapNhatSo1=0;
  // double GiaCaoNhatNenSo1=0;
   double DoDaiThanNen=MathAbs(Close[1]-Open[1]);
  // if(Close[1]>Open[1]) {GiaThapNhatSo1=Open[1]; GiaCaoNhatNenSo1=Close[1];}
 //  else {GiaCaoNhatNenSo1=Open[1]; GiaThapNhatSo1=Close[1];};
   if(glbKieuSL==TU_DONG)
   {
      
      if(loailenh==CANH_BUY)
         GiaSL=Ask-DoDaiThanNen-glbBoiSoSL*MarketInfo(Symbol(),MODE_SPREAD)*Point();
      else GiaSL=Bid+DoDaiThanNen+glbBoiSoSL*MarketInfo(Symbol(),MODE_SPREAD)*Point();
         
   }
   else
   {
      GiaSL=glbSLTay;
   }
   if(glbKieuTP==TU_DONG)
   {
      if(loailenh==CANH_BUY)
         GiaTP=Ask+DoDaiThanNen+glbBoiSoTP*MarketInfo(Symbol(),MODE_SPREAD)*Point();
      else GiaTP=Bid-DoDaiThanNen-glbBoiSoTP*MarketInfo(Symbol(),MODE_SPREAD)*Point();
   }
   else
   {
      GiaTP=glbTPTay;
   }
 } 
 
 //+------------------------------------------------------------------+ 
int FunVaoLenhSLTPTheoPip(int LoaiLenh, double DiemVaoLenh,double StopLossPips, double TakeProfitPips, double KhoiLuongVaoLenh)
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
int FunVaoLenhSLTPTheoGia(int LoaiLenh, double DiemVaoLenh,double GiaStopLoss=0, double GiaTakeProfit=0, double KhoiLuongVaoLenh=0)
{
    int Ticket=-1;
    double StopLoss=GiaStopLoss,TakeProfit=GiaTakeProfit;
    Print("Gia vao lenh: ",DiemVaoLenh, " SL: ", StopLoss, " TP: ",TakeProfit);
    if(KhoiLuongVaoLenh==0) return -1;
    
    if(LoaiLenh==OP_BUY || LoaiLenh==OP_BUYLIMIT || LoaiLenh==OP_BUYSTOP)
    { 
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,"Vao lenh Buy",inpMagicNumber,0,clrBlue);
    }
    if(LoaiLenh==OP_SELL|| LoaiLenh==OP_SELLLIMIT || LoaiLenh==OP_SELLSTOP)
    { 
      Ticket=OrderSend(Symbol(),LoaiLenh,KhoiLuongVaoLenh,DiemVaoLenh,inpSlippage,StopLoss,TakeProfit,"Vao lenh Sell",inpMagicNumber,0,clrRed);
    }
    return Ticket;
}
//+------------------------------------------------------------------+
void FunXoaLenhDaDongKhoiMang()
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
//+------------------------------------------------------------------+
void FunCaiDatSLTPChoLenhVaoBangTay()
{
   double GiaSL=0, GiaTP=0;
   int LoaiLenhCanCaiSLTP=-1;
   if(glbLoaiLenh==CANH_BUY) LoaiLenhCanCaiSLTP=OP_BUY;
   else LoaiLenhCanCaiSLTP=OP_SELL;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         // Chi set SL, TP cho lenh bang tay
         if(OrderSymbol()==Symbol() && OrderType()==LoaiLenhCanCaiSLTP && OrderMagicNumber()!=inpMagicNumber)
         {
            if(OrderStopLoss()==0 || OrderTakeProfit()==0)
            {
               FunTinhSLTPChoLenh(GiaSL,GiaTP,glbLoaiLenh);
               if(OrderStopLoss()>0) GiaSL=OrderStopLoss();
               if(OrderTakeProfit()>0) GiaTP=OrderProfit();
               OrderModify(OrderTicket(),OrderOpenPrice(),GiaSL,GiaTP,0,clrNONE);
            }
            
         }
      }
   }
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
 


//+------------------------------------------------------------------+ 
bool FunKiemDaHetHanChua(NgayThang &HanCanKiemTra)// False: Chua; True: Roi
{
   bool kt=false;
   if(Year()>HanCanKiemTra.Nam)
    {
         MessageBox("EA het han su dung. De gia han Vui long truy cap website tailieuforex.com. Hoac lien he SDT: 0989149111");
         ExpertRemove();
         kt=true;
    }
      if(Year()==HanCanKiemTra.Nam && Month()>HanCanKiemTra.Thang)
    {
         MessageBox("EA het han su dung. De gia han Vui long truy cap website tailieuforex.com. Hoac lien he SDT: 0989149111");
         ExpertRemove();
         kt=true;   
    }
    if(Year()==HanCanKiemTra.Nam && Month()==HanCanKiemTra.Thang && Day()>HanCanKiemTra.Ngay)  
    {
        MessageBox("EA het han su dung. De gia han Vui long truy cap website tailieuforex.com. Hoac lien he SDT: 0989149111");
         ExpertRemove();
         kt=true;
    }
    return kt;
}
//+------------------------------------------------------------------+
double FunTinhTongLoiNhuan()
{
   double tong=0;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         tong+=OrderProfit()+OrderSwap()+OrderCommission();
      }
   }
   return tong;
}
//+------------------------------------------------------------------+
void FunDongTatCaCacLenh()
{
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderCloseTime()<=0)
         {
            if(OrderType()==OP_BUY)
            {
               OrderClose(OrderTicket(),OrderLots(),Bid,inpSlippage,clrNONE);
            }
            else if(OrderType()==OP_SELL)
            {
               OrderClose(OrderTicket(),OrderLots(),Ask,inpSlippage,clrNONE);
            }
            else OrderDelete(OrderTicket());
         }
      }
   }
  
}

//+------------------------------------------------------------------+
string FunTenLenh()
{
   if(inpLoaiLenh==CANH_BUY) return "BUY";
   else  return "SELL";
   
}

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
   if(FunKiemDaHetHanChua(NgayHetHan)==true) return;
   if(id==CHARTEVENT_OBJECT_CLICK )
   {
      
      if(sparam=="btnTinhSell")
      {
         FunEditTextChange(0,"edtLoaiLenh","SELL");
         glbLoaiLenh=CANH_SELL;
      }
      if(sparam=="btnTinhBuy")
      {
        FunEditTextChange(0,"edtLoaiLenh","BUY");
        glbLoaiLenh=CANH_BUY;
         
      }
      if(sparam=="hLineGiaVaoLenh")
   //   ObjectMove("LableGiaCaoNhat",0,Time[0],ObjectGet("GiaCaoNhat",OBJPROP_PRICE1));
   
      ChartRedraw();
   }
   if(id==CHARTEVENT_OBJECT_ENDEDIT)
   {
      if(sparam=="edtTongLoiNhuan")
      {
         string MaxProfit="";
         FunEditTextGet(MaxProfit,0,"edtTongLoiNhuan");
        
         if(StringToInteger(MaxProfit)>0)
         {
             glbMaxProfit=StringToInteger(MaxProfit);        
         }
      }
      if(sparam=="edtSLTay")
      {
         string SLTay="";
         FunEditTextGet(SLTay,0,"edtSLTay");
         glbSLTay=StringToDouble(SLTay);
         if(glbSLTay>0)
         {
            FunEditTextChange(0,"edtSLTuDong",IntegerToString(0));
            glbKieuSL=CAI_TAY;
            glbBoiSoSL=0;           
         }
      }
      if(sparam=="edtSLTuDong")
      {
         string SLTuDong="";
         FunEditTextGet(SLTuDong,0,"edtSLTuDong");
         glbBoiSoSL=StringToInteger(SLTuDong);
         if(glbBoiSoSL>0)
         {
            FunEditTextChange(0,"edtSLTay",DoubleToString(0,Digits));
            glbKieuSL=TU_DONG;
            glbSLTay=0;           
         }
      }
      if(sparam=="edtTPTay")
      {
         string TPTay="";
         FunEditTextGet(TPTay,0,"edtTPTay");
         glbTPTay=StringToDouble(TPTay);
         if(glbTPTay>0)
         {
            FunEditTextChange(0,"edtTPTuDong",IntegerToString(0));
            glbKieuTP=CAI_TAY;
            glbBoiSoTP=0;           
         }
      }
      if(sparam=="edtTPTuDong")
      {
         string TPTuDong="";
         FunEditTextGet(TPTuDong,0,"edtTPTuDong");
         glbBoiSoTP=StringToInteger(TPTuDong);
         if(glbBoiSoTP>0)
         {
            FunEditTextChange(0,"edtTPTay",DoubleToString(0,Digits));
            glbKieuTP=TU_DONG;
            glbTPTay=0;           
         }
      }
      if(sparam=="edtGiaDongNen")
      {
         string GiaDongNen="";
         FunEditTextGet(GiaDongNen,0,"edtGiaDongNen");
         if(StringToDouble(GiaDongNen)>0)
         {
            glbDieuKienGiaDongNen=  StringToDouble(GiaDongNen)  ; 
            Print("Dieu kien gia dong nen: ",glbDieuKienGiaDongNen)  ;
         }
      }
   }
}
//+------------------------------------------------------------------+
//| Create the button                                      |
//+------------------------------------------------------------------+
bool FunButtonCreate(const string name="text",
               const string text="text",
               const int       sub_window=0,      // subwindow index
               double    price=0,           // price
               const color     clr=clrYellow)
{
    if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
      //--- reset the error value
      ResetLastError();
      //--- create a text
   if(!ObjectCreate(name,OBJ_TEXT,sub_window,Time[0],price))
     {
      Print(__FUNCTION__,
            ": failed to create a text! Error code = ",GetLastError());
      return(false);
     }
    ObjectSetText(name,text,10,NULL,clr);
    return true;  
}               
//+------------------------------------------------------------------+
//| Delete a object                                         |
//+------------------------------------------------------------------+
bool FunObjectDelete(
                 const string name="TextGiaCaoNhat") //  name
  {
//--- reset the error value
   ResetLastError();
//--- delete a texy
   if(!ObjectDelete(name))
     {
      Print(__FUNCTION__,
            ": failed to delete a object! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the button                                                |
//+------------------------------------------------------------------+
bool FunButtonCreate(const long              chart_ID=0,               // chart's ID
                  const string            name="Button",            // button name
                  const int               sub_window=0,             // subwindow index
                  const int               x=0,                      // X coordinate
                  const int               y=0,                      // Y coordinate
                  const int               width=50,                 // button width
                  const int               height=18,                // button height
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
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
//| Change button text                                               |
//+------------------------------------------------------------------+
bool FunButtonTextChange(const long   chart_ID=0,    // chart's ID
                      const string name="Button", // button name
                      const string text="Text")   // text
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
//| Change button text                                               |
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
                 const string            text="Label",             // text
                 const string            font="Arial",             // font
                 const int               font_size=10,             // font size
                 const color             clr=clrRed,               // color
                 const double            angle=0.0,                // text slope
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type
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
//| Create a bitmap in the chart window                              |
//+------------------------------------------------------------------+
bool FunBitmapCreate(const long            chart_ID=0,        // chart's ID
                  const string          name="Bitmap",     // bitmap name
                  const int             sub_window=0,      // subwindow index
                  datetime              time=0,            // anchor point time
                  double                price=0,           // anchor point price
                  const string          file="",           // bitmap file name
                  const int             width=10,          // visibility scope X coordinate
                  const int             height=10,         // visibility scope Y coordinate
                  const int             x_offset=0,        // visibility scope shift by X axis
                  const int             y_offset=0,        // visibility scope shift by Y axis
                  const color           clr=clrRed,        // border color when highlighted
                  const ENUM_LINE_STYLE style=STYLE_SOLID, // line style when highlighted
                  const int             point_width=1,     // move point size
                  const bool            back=false,        // in the background
                  const bool            selection=false,   // highlight to move
                  const bool            hidden=true,       // hidden in the object list
                  const long            z_order=0)         // priority for mouse click
  {
//--- set anchor point coordinates if they are not set
   ChangeBitmapEmptyPoint(time,price);
//--- reset the error value
   ResetLastError();
//--- create a bitmap
   if(!ObjectCreate(chart_ID,name,OBJ_BITMAP,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": failed to create a bitmap in the chart window! Error code = ",GetLastError());
      return(false);
     }
//--- set the path to the image file
   if(!ObjectSetString(chart_ID,name,OBJPROP_BMPFILE,file))
     {
      Print(__FUNCTION__,
            ": failed to load the image! Error code = ",GetLastError());
      return(false);
     }
//--- set visibility scope for the image; if width or height values
//--- exceed the width and height (respectively) of a source image,
//--- it is not drawn; in the opposite case,
//--- only the part corresponding to these values is drawn
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the part of an image that is to be displayed in the visibility scope
//--- the default part is the upper left area of an image; the values allow
//--- performing a shift from this area displaying another part of the image
   ObjectSetInteger(chart_ID,name,OBJPROP_XOFFSET,x_offset);
   ObjectSetInteger(chart_ID,name,OBJPROP_YOFFSET,y_offset);
//--- set the border color when object highlighting mode is enabled
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set the border line style when object highlighting mode is enabled
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set a size of the anchor point for moving an object
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,point_width);
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
//| Check anchor point values and set default values                 |
//| for empty ones                                                   |
//+------------------------------------------------------------------+
void ChangeBitmapEmptyPoint(datetime &time,double &price)
  {
//--- if the point's time is not set, it will be on the current bar
   if(!time)
      time=TimeCurrent();
//--- if the point's price is not set, it will have Bid value
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
  }
 //+------------------------------------------------------------------+
//| Delete the rectangle label                                       |
//+------------------------------------------------------------------+
bool FunRectLabelDelete(const long   chart_ID=0,       // chart's ID
                     const string name="RectLabel") // label name
  {
//--- reset the error value
   ResetLastError();
//--- delete the label
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a rectangle label! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
 //+------------------------------------------------------------------+
//| Create rectangle label                                           |
//+------------------------------------------------------------------+
  bool FunRectLabelCreate(const long             chart_ID=0,               // chart's ID
                     const string           name="RectLabel",         // label name
                     const int              sub_window=0,             // subwindow index
                     const int              x=0,                      // X coordinate
                     const int              y=0,                      // Y coordinate
                     const int              width=50,                 // width
                     const int              height=18,                // height
                     const color            back_clr=C'236,233,216',  // background color
                     const ENUM_BORDER_TYPE border=BORDER_SUNKEN,     // border type
                     const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                     const color            clr=clrRed,               // flat border color (Flat)
                     const ENUM_LINE_STYLE  style=STYLE_SOLID,        // flat border style
                     const int              line_width=1,             // flat border width
                     const bool             back=false,               // in the background
                     const bool             selection=false,          // highlight to move
                     const bool             hidden=true,              // hidden in the object list
                     const long             z_order=0)                // priority for mouse click
  {
//--- reset the error value
   if(ObjectFind(chart_ID,name)>=0)
   {
      FunRectLabelDelete(chart_ID,name);
   }
   ResetLastError();
//--- create a rectangle label
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create a rectangle label! Error code = ",GetLastError());
      return(false);
     }
//--- set label coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set label size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border type
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set flat border color (in Flat mode)
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set flat border line style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set flat border width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width);
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
//| Create Edit object                                               |
//+------------------------------------------------------------------+
bool FunEditCreate(const long             chart_ID=0,               // chart's ID
                const string           name="Edit",              // object name
                const int              sub_window=0,             // subwindow index
                const int              x=0,                      // X coordinate
                const int              y=0,                      // Y coordinate
                const int              width=50,                 // width
                const int              height=18,                // height
                const string           text="Text",              // text
                const string           font="Arial",             // font
                const int              font_size=10,             // font size
                const ENUM_ALIGN_MODE  align=ALIGN_CENTER,       // alignment type
                const bool             read_only=false,          // ability to edit
                const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                const color            clr=clrBlack,             // text color
                const color            back_clr=clrWhite,        // background color
                const color            border_clr=clrNONE,       // border color
                const bool             back=false,               // in the background
                const bool             selection=false,          // highlight to move
                const bool             hidden=true,              // hidden in the object list
                const long             z_order=0)                // priority for mouse click
  {
//--- reset the error value
   if(ObjectFind(chart_ID,name)>=0)
   {
      FunEditDelete(chart_ID,name);
   }
   ResetLastError();
//--- create edit field
   if(!ObjectCreate(chart_ID,name,OBJ_EDIT,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create \"Edit\" object! Error code = ",GetLastError());
      return(false);
     }
//--- set object coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set object size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the type of text alignment in the object
   ObjectSetInteger(chart_ID,name,OBJPROP_ALIGN,align);
//--- enable (true) or cancel (false) read-only mode
   ObjectSetInteger(chart_ID,name,OBJPROP_READONLY,read_only);
//--- set the chart's corner, relative to which object coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set text color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border color
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
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
//| Return Edit object text                                          |
//+------------------------------------------------------------------+
bool FunEditTextGet(string      &text,        // text
                 const long   chart_ID=0,  // chart's ID
                 const string name="Edit") // object name
  {
//--- reset the error value
   ResetLastError();
//--- get object text
   if(!ObjectGetString(chart_ID,name,OBJPROP_TEXT,0,text))
     {
      Print(__FUNCTION__,
            ": failed to get the text! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Change Edit object's text                                        |
//+------------------------------------------------------------------+
bool FunEditTextChange(const long   chart_ID=0,  // chart's ID
                    const string name="Edit", // object name
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
//| Delete Edit object                                               |
//+------------------------------------------------------------------+
bool FunEditDelete(const long   chart_ID=0,  // chart's ID
                const string name="Edit") // object name
  {
//--- reset the error value
   ResetLastError();
//--- delete the label
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete \"Edit\" object! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }