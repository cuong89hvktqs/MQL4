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
#include <Telegram\Telegram.mqh>
enum Enum_LoaiLenh{
   ONLY_BUY=OP_BUY,
   ONLY_SELL=OP_SELL,
};
enum Enum_KhoiLuongVaoLenh{
   TU_DONG_VAO=1,
   CHUAN_EU_GU=2,
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
input double inpSoLotToiDaChoMotLenh=20;//So Lot toi da cho 1 lenh (<= 100Lot):
input double inpHeSoHedging=2;//He so hedg:
input double inpHeSoNhayHedging;// He so nhay Hedg:
//input Enum_KhoiLuongVaoLenh inpKieuTinhLots=TU_DONG_VAO;// Cach tinh khoi luong lenh: Tu dong hoac theo chuan EU,GU:
//input bool inpCoVaoLenhSauKhiHedge=false;//Co cho phep vao lenh sau khi hedge: True-Co, False-Khong:
input string str1="CAI DAT SL THEO THOI GIAN";//CAI DAT SL THEO THOI GIAN
input int inpThoiGianGioBatDau=4;// Gio bat dau dat SL theo pip (0-23):
input int inpThoiGianPhutBatDau=0;// Phut bat dau dat SL theo pip (0-59):
input int inpThoiGianGioKetThuc=10;// Gio ket thuc dat SL theo pip (0-23): 
input int inpThoiGianPhutKetThuc=10;// Phut ket thuc dat SL theo pip ((0-59):
input double inpDiemSLTrongGio=3.5;// Diem SL (pips) trong khoang thoi gian tren:
input double inpDiemSLNgoaiThoiGian=10;// Diem SL (pips) ngoai khoang thoi gian tren:
input Enum_LoaiLenh inpLoaiLenh=ONLY_BUY;// Loai lenh dau tien:
input int inpSpreadToiDa=5;// Spread toi da cho phep vao lenh (points):
input bool inpChoPhepQuanLyLenhTay=true;// Co cho phep quan ly lenh bang tay:
input double inpBalanceCanhBao=1000;// Gui tin nhan khi Balance ve duoi nguong($):



input string inpComemtEA="EA";// Comment EA:
input int inpMagic=9;//Magic:
input int inpSlippage=50;//Slippage:
CCustomBot glbBotTelegram;
int glbSoLanHedg=0;
bool glbDangCoLenh=false;
double glbKhoiLuongHedgeDuDoHetMargin=0;
//int glbTicketHedge=-1;
int glbTapLenhHedge[200];
int glbTongSoLenhHedge=0;
bool glbDaGuiTinNhanBalance=false;
string glbTenCapTienEU="EURUSD";
string glbTenCapTienGU="GBPUSD";
string glbmsg1="CHE DO: ";
string glbmsg2="KL HIEN TAI: ";
string glbmsg3="Banalce: ";
string glbmsg4="Equity: ";
string glbmsg5="Free Margin: ";
string glbmsg6="So lan da Hedge: ";
string glbmsg7="He so Hedge: ";
CPanel glbMyPanel;
double glbKhoiLuongChuan[200]={0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.09,0.1,0.11,0.12,0.13,0.14,0.15,0.16,0.17,0.18,0.19,0.2,0.21,0.22,0.23,0.24,0.25,0.26,0.27,0.28,0.29,0.3,0.31,0.32,0.33,0.34,0.35,0.36,0.37,0.38,0.39,0.4,0.41,0.42,0.43,0.44,0.45,0.46,0.47,0.48,0.49,0.5,0.51,0.52,0.53,0.54,0.55,0.56,0.57,0.58,0.59,0.6,0.61,0.62,0.63,0.64,0.65,0.66,0.67,0.68,0.69,0.7,0.71,0.72,0.73,0.74,0.75,0.76,0.77,0.78,0.79,0.8,0.81,0.82,0.83,0.84,0.85,0.86,0.87,0.88,0.89,0.9,0.91,0.92,0.93,0.94,0.95,0.96,0.97,0.98,0.99,1,1.01,1.02,1.03,1.04,1.05,1.06,1.07,1.08,1.09,1.1,1.11,1.12,1.13,1.14,1.15,1.16,1.17,1.18,1.19,1.2,1.21,1.22,1.23,1.24,1.25,1.26,1.27,1.28,1.29,1.3,1.31,1.32,1.33,1.34,1.35,1.36,1.37,1.38,1.39,1.4,1.41,1.42,1.43,1.44,1.45,1.46,1.47,1.48,1.49,1.5,1.51,1.52,1.53,1.54,1.55,1.56,1.57,1.58,1.59,1.6,1.61,1.62,1.63,1.64,1.65,1.66,1.67,1.68,1.69,1.7,1.71,1.72,1.73,1.74,1.75,1.76,1.77,1.78,1.79,1.8,1.81,1.82,1.83,1.84,1.85,1.86,1.87,1.88,1.89,1.9,1.91,1.92,1.93,1.94,1.95,1.96,1.97,1.98,1.99,2};
double glbLotEUChuan[200]={0.54,1.09,1.63,2.18,2.72,3.26,3.81,4.35,4.89,5.44,5.98,6.52,7.07,7.61,8.16,8.7,9.24,9.79,10.33,10.87,11.42,11.96,12.51,13.05,13.59,14.14,14.68,15.22,15.77,16.31,16.86,17.4,17.94,18.49,19.03,19.57,20.12,20.66,21.2,21.75,22.29,22.83,23.38,23.92,24.47,25.02,26.11,27.19,28.28,29.37,30.46,31.54,32.63,33.72,34.8,35.89,36.98,38.07,39.15,40.24,41.33,42.42,43.5,44.59,45.68,46.77,47.85,48.94,50.03,51.11,52.2,53.29,54.37,55.46,56.55,57.64,58.73,59.81,60.9,61.99,63.08,64.16,65.25,66.34,46.21,68.52,69.6,70.69,71.78,72.87,73.96,75.04,76.13,77.22,78.31,79.4,80.74,81.56,82.65,83.74,84.82,85.91,87,88.08,89.18,90.27,91.35,92.44,93.53,94.62,95.7,96.8,97.89,98.97,100.07,101.16,102.25,103.34,104.43,105.52,106.6,107.68,108.77,109.86,110.95,112.03,113.12,114.21,115.3,116.38,117.47,118.56,119.65,120.74,121.83,122.92,124.01,125.1,126.18,127.27,128.36,129.45,130.53,131.62,132.71,133.8,134.88,135.97,137.06,138.15,139.24,140.32,141.41,142.5,143.59,144.67,145.76,146.85,147.94,149.03,150.12,151.21,152.29,153.38,154.47,155.55,156.64,157.73,158.81,159.89,160.98,162.07,163.15,164.24,165.34,166.43,167.51,168.6,169.9,170.78,171.84,172.94,174.03,175.24,177.42,179.63,181.78,183.96,186.14,188.32,190.5,192.67,194.87,197.06,199.25,201.19,203.34,205.55,207.68,209.85};
double glbLotGUChuan[200]={0.65,1.3,1.95,2.6,3.25,3.9,4.55,5.2,5.86,6.51,7.16,7.81,8.46,9.11,9.76,10.41,11.06,11.71,12.36,13.01,13.66,14.31,14.96,15.61,16.26,16.92,17.57,18.22,18.87,19.52,20.17,20.82,21.47,22.13,22.78,23.43,24.08,24.73,25.73,27.07,28.37,29.68,31.01,32.31,33.61,34.91,36.21,37.52,38.82,40.12,41.42,42.72,44.03,45.33,46.64,47.94,49.24,50.54,51.85,53.15,54.45,55.75,57.05,58.35,59.66,60.96,62.26,63.56,64.87,66.17,67.46,68.76,70.06,71.37,72.66,73.97,75.28,76.57,77.87,79.18,80.48,81.78,83.08,84.39,85.69,87,88.3,89.6,90.89,92.2,93.5,94.8,96.1,97.4,98.67,99.98,101.28,102.59,103.2,105.2,106.51,107.82,109.14,110.44,111.74,113.03,114.34,115.64,116.95,118.25,119.55,120.86,122.16,123.46,124.76,126.06,127.37,128.67,129.99,131.29,132.58,133.88,135.18,136.49,137.79,139.1,140.4,141.69,142.99,144.3,145.6,146.9,148.2,149.5,150.79,152.09,153.39,154.69,156,157.3,158.6,159.91,161.21,162.52,163.82,165.12,166.43,167.73,169.02,170.33,171.63,172.93,174.23,176.07,178.67,181.28,183.91,186.52,189.07,191.68,194.27,196.68,199.21,201.75,204.35,206.95,209.55,212.16,214.87,217.47,220.05,222.67,225.27,227.88,230.48,233.1,235.66,238.26,240.89,243.47,246.02,248.56,251.17,253.75,256.35,258.96,261.57,264.17,266.79,269.4,272.05,274.65,277.23,279.82,282.39,284.99,287.59,290.19,292.79,295.42};
double glbSoPipSL=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
      if(FunKiemTraHetHan(NgayHetHan)==false){MessageBox("Bot het han su dung");return INIT_FAILED;}
      /*
      if(inpKieuTinhLots==CHUAN_EU_GU)
      {
         if(Symbol()!=glbTenCapTienEU && Symbol()!=glbTenCapTienGU)
          {  MessageBox("Voi kieu tinh khoi luong theo CHUAN_EU_GU cap tien vao lenh phai la EU, GU. Va Balance <=300$");return INIT_FAILED;}
      }
      */
      glbBotTelegram.Token(inpToken);
      string msgTele=StringFormat("Cap Tien: %s\nKet noi MT4 va telegram Thanh cong.",Symbol());
      glbBotTelegram.SendMessage(inpChannelName,msgTele);
       
      glbMyPanel.ColorBackground(clrDarkSlateGray);
      FunButtonCreate(0,"btnDongTatCaLenh",0,2,130,150,40,CORNER_LEFT_LOWER,ANCHOR_LEFT_LOWER,"DONG TAT CA LENH","Arial",9,clrBlue,clrRed);
      FunButtonCreate(0,"btnDongTatCaLenhLo",0,2,175,150,40,CORNER_LEFT_LOWER,ANCHOR_LEFT_LOWER,"DONG TAT CA LENH LO","Arial",9,clrBlue,clrPink);
      FunLabelCreate(0,"lblMsg1",0,4,72,CORNER_LEFT_LOWER,ANCHOR_LEFT_LOWER,glbmsg1,"Arial",9,clrYellow);
      FunLabelCreate(0,"lblMsg2",0,4,60,CORNER_LEFT_LOWER,ANCHOR_LEFT_LOWER,glbmsg2,"Arial",9,clrYellow);
      FunLabelCreate(0,"lblMsg3",0,4,48,CORNER_LEFT_LOWER,ANCHOR_LEFT_LOWER,glbmsg3,"Arial",9,clrYellow);
      FunLabelCreate(0,"lblMsg4",0,4,36,CORNER_LEFT_LOWER,ANCHOR_LEFT_LOWER,glbmsg4,"Arial",9,clrYellow);
      FunLabelCreate(0,"lblMsg5",0,4,24,CORNER_LEFT_LOWER,ANCHOR_LEFT_LOWER,glbmsg5,"Arial",9,clrYellow);
      FunLabelCreate(0,"lblMsg6",0,4,12,CORNER_LEFT_LOWER,ANCHOR_LEFT_LOWER,glbmsg6,"Arial",9,clrYellow);
      FunLabelCreate(0,"lblMsg7",0,4,0,CORNER_LEFT_LOWER,ANCHOR_LEFT_LOWER,glbmsg7,"Arial",9,clrYellow);

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
      double HeSoHedg= inpHeSoHedging+ glbSoLanHedg*inpHeSoNhayHedging;
      glbSoPipSL=FunChonSLTheoThoiGian();
      Comment("So pip SL gio hien tai: ",IntegerToString( glbSoPipSL));
      string msg="";
      
      if(inpLoaiLenh==ONLY_BUY)
          glbmsg1="CHE DO: ONLY BUY\n"  ;
      else  glbmsg1="CHE DO: ONLY SELL\n" ;
         glbmsg2="KL HIEN TAI: "+DoubleToString(FunTinhKhoiLuongHedge(),2);
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
      
      if(FunKiemTraThoaManSpread()==false)return;
      if(FunKiemTraDangCoLenhKhong()==false)// chuaw co lenh
      {
         //if(Symbol()==glbTenCapTienEU || Symbol()==glbTenCapTienGU)
         //   FunVaoLenhFullMarginChuanEUGU();
         //else
            FunVaoLenhFullMarginV2();
         return;
      }
      if(glbTongSoLenhHedge>0)// Dang co lenh hedge, 
      {
         if(glbKhoiLuongHedgeDuDoHetMargin>0 && AccountFreeMargin()>0)
            FunVaoLenhHedingConDuDoHetMargin();
         //Kiem tra dong lenh hedge
         FunXuLyKhiCoLenhHedgeBiDong();
            return;
      }
    
      if((AccountEquity()/inpTienGoc)>=HeSoHedg && glbTongSoLenhHedge==0)//
      {
         
          //Print("Vao lenh Hedge.");
         FunVaoLenhHeding();// Tinh toan vao lenh Hedge
         if(glbTongSoLenhHedge>0) glbSoLanHedg++;
         return;
      }
      if(FunKiemTraSangNenMoiChua()==true)
      {       
         if(glbSoPipSL>0) FunDongCacLenhTheoSoPipLo();
         //Print("Sang nen moi vaolenh tiep");
         //FunVaoLenhFullMargin();
         //if(Symbol()==glbTenCapTienEU || Symbol()==glbTenCapTienGU)
         //   FunVaoLenhFullMarginChuanEUGU();
         //else
            FunVaoLenhFullMarginV2();
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
               {kt=true;break;}
            else
            {
               if(OrderMagicNumber()==inpMagic)
               {kt=true;break;}
            }                       
         }
      }
   }
   return kt; 
}

//+------------------------------------------------------------------+
void FunVaoLenhFullMarginV2()
{
   double  minLot  = MarketInfo(Symbol(), MODE_MINLOT);
   double  maxLot  = inpSoLotToiDaChoMotLenh;//MarketInfo(Symbol(), MODE_MAXLOT);
   double lotStep=MarketInfo(Symbol(),MODE_LOTSTEP);
   
   double tick_value = MarketInfo(Symbol(),MODE_TICKVALUE);
   while(true)
   {
      int ticket=-1;
      if (inpLoaiLenh==ONLY_BUY)
      {
             ticket=FunVaoLenh(OP_BUY,maxLot);           
      }
      else  ticket=FunVaoLenh(OP_SELL,maxLot);
      if(ticket<=0)break;
   }
   double lot=NormalizeDouble((AccountFreeMargin()/(200*tick_value)),2);  // để 180 point
   while (AccountFreeMargin()>0)
   {
      
      lot = NormalizeDouble(MathMin(lot*0.8,lot -minLot),2);
      if(lot < minLot){lot=minLot;}
      if (inpLoaiLenh==ONLY_BUY)
      {
         FunVaoLenh(OP_BUY,lot);
         
      }
      else FunVaoLenh(OP_SELL,lot);
      if(lot==minLot)break;
   }  
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void FunVaoLenhFullMarginChuanEUGU()
{
   int vt=-1;
   while (AccountFreeMargin()>0)
   {
      if(Symbol()==glbTenCapTienEU && AccountFreeMargin()<glbLotEUChuan[0]) break;
      if(Symbol()==glbTenCapTienGU && AccountFreeMargin()<glbLotGUChuan[0]) break;
      
      vt=FunTinhViTriKhoiLuongTheoChuanEUGU(AccountFreeMargin());
     Print("Vitri: ",vt);
      if(vt==-1)break;
      else
      {
         Print("Khoi luong: ",glbKhoiLuongChuan[vt]," vi tri: ",vt);
         if (inpLoaiLenh==ONLY_BUY)
         {
            FunVaoLenh(OP_BUY,glbKhoiLuongChuan[vt]);
            
         }
         else FunVaoLenh(OP_SELL,glbKhoiLuongChuan[vt]);
      }
   }  
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

int FunTinhViTriKhoiLuongTheoChuanEUGU(double FreeMagin)
{
   int vt=-1;
   if(Symbol()==glbTenCapTienEU)
   {
      int i=0;
      while(glbLotEUChuan[i]<=FreeMagin)
      {
         i++;
         if(i==200)break;
      }
      vt=i-1;
     // Print("Vi tri:",vt, " Gia tri: ",glbLotEUChuan[vt]);
   }
   else if(Symbol()==glbTenCapTienGU)
   {
      int i=0;
      while(glbLotGUChuan[i]<=FreeMagin)
      {
         i++;
         if(i==200)break;
      }
      vt=i-1;
      //Print("Vi tri:",vt, " Gia tri: ",glbLotEUChuan[vt]);
   }
   return vt;
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
   double Spread = MarketInfo(Symbol(), MODE_SPREAD);
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
double FunChonSLTheoThoiGian()
{
   datetime timelocal=TimeCurrent();
   double gio=TimeHour(timelocal)+ double(TimeMinute(timelocal))/60;
   double GioBatDau=inpThoiGianGioBatDau+double(inpThoiGianPhutBatDau)/60;
   double GioKetThuc=inpThoiGianGioKetThuc+double(inpThoiGianPhutKetThuc)/60;
   if(gio>=GioBatDau && gio<GioKetThuc) return inpDiemSLTrongGio;
   else return inpDiemSLNgoaiThoiGian;

}
//+------------------------------------------------------------------+

void FunVaoLenhHeding()
{
      double KhoiLuong=0;
      int Ticket=-1;
      double  maxLot  = inpSoLotToiDaChoMotLenh;//(Symbol(), MODE_MAXLOT);
      glbTongSoLenhHedge=0;
     // if((AccountEquity()/inpTienGoc)>=HeSoHedg && glbTicketHedge<=0)
    //  {
         // vao lenh hedge
         KhoiLuong=FunTinhKhoiLuongHedge();        
         if(KhoiLuong>0)
         {
           
           while(KhoiLuong>=maxLot)
           {
               if(inpLoaiLenh==ONLY_BUY) Ticket=FunVaoLenh(OP_SELL,maxLot);
               else Ticket=FunVaoLenh(OP_BUY,maxLot);
               if(Ticket>0)
               {
                  glbTapLenhHedge[glbTongSoLenhHedge]=Ticket;
                  glbTongSoLenhHedge++;
                  KhoiLuong-=maxLot;
               }
               if(AccountFreeMargin()<=0)break;    
           }
           if(KhoiLuong>0 && KhoiLuong<maxLot && AccountFreeMargin()>0)
           {
           
               if(inpLoaiLenh==ONLY_BUY) Ticket=FunVaoLenh(OP_SELL,KhoiLuong);
               else Ticket=FunVaoLenh(OP_BUY,KhoiLuong);
               if(Ticket>0)
               {
                  glbTapLenhHedge[glbTongSoLenhHedge]=Ticket;
                  glbTongSoLenhHedge++;
                  KhoiLuong=0;
               }
           }

         } 
         glbKhoiLuongHedgeDuDoHetMargin=KhoiLuong;
    //  }
      if(glbTongSoLenhHedge>0) glbBotTelegram.SendMessage(inpChannelName,"CANH BAO: DA VAO LENH HEDGE");
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void FunVaoLenhHedingConDuDoHetMargin()
{       
   double  maxLot  = inpSoLotToiDaChoMotLenh;//(Symbol(), MODE_MAXLOT);
   int Ticket=-1;
   if(glbKhoiLuongHedgeDuDoHetMargin>0)
   {
           
      while(glbKhoiLuongHedgeDuDoHetMargin>=maxLot)
      {
         if(inpLoaiLenh==ONLY_BUY) Ticket=FunVaoLenh(OP_SELL,maxLot);
         else Ticket=FunVaoLenh(OP_BUY,maxLot);
         if(Ticket>0)
         {
            glbTapLenhHedge[glbTongSoLenhHedge]=Ticket;
            glbTongSoLenhHedge++;
            glbKhoiLuongHedgeDuDoHetMargin-=maxLot;
         }
         if(AccountFreeMargin()<=0)break;    
      }
      if(glbKhoiLuongHedgeDuDoHetMargin>0 && glbKhoiLuongHedgeDuDoHetMargin<maxLot && AccountFreeMargin()>0)
      {
           
         if(inpLoaiLenh==ONLY_BUY) Ticket=FunVaoLenh(OP_SELL,glbKhoiLuongHedgeDuDoHetMargin);
         else Ticket=FunVaoLenh(OP_BUY,glbKhoiLuongHedgeDuDoHetMargin);
         if(Ticket>0)
         {
            glbTapLenhHedge[glbTongSoLenhHedge]=Ticket;
            glbTongSoLenhHedge++;
            glbKhoiLuongHedgeDuDoHetMargin=0;
         }
      }

   } 
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
               if(OrderType()==inpLoaiLenh)
                  KhoiLuong+=OrderLots();
               else KhoiLuong-=OrderLots();
            }
            else
            {
               if(OrderMagicNumber()==inpMagic)
               {
                  if(OrderType()==inpLoaiLenh)
                     KhoiLuong+=OrderLots();
                  else KhoiLuong-=OrderLots();          
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
         if(OrderSymbol()==Symbol() && OrderType()==inpLoaiLenh)
         {
            if(inpChoPhepQuanLyLenhTay==true)
            {
               if(OrderType()==OP_BUY)
               {
                  SoPipLoiLo=(Bid-OrderOpenPrice())/(10*Point);
                  if(SoPipLoiLo <0 && MathAbs(SoPipLoiLo)>=glbSoPipSL)
                     OrderClose(OrderTicket(),OrderLots(),Bid,inpSpreadToiDa*10,clrNONE);
               }
               else
               {
                  SoPipLoiLo=(OrderOpenPrice()-Ask)/(10*Point);
                  if(SoPipLoiLo <0 && MathAbs(SoPipLoiLo)>=glbSoPipSL)
                     OrderClose(OrderTicket(),OrderLots(),Ask,inpSpreadToiDa*10,clrNONE);
               }
            }
            else
            {
               if(OrderMagicNumber()==inpMagic)
               {
                  if(OrderType()==OP_BUY)
                  {
                     SoPipLoiLo=(Bid-OrderOpenPrice())/(10*Point);
                     if(SoPipLoiLo <0 && MathAbs(SoPipLoiLo)>=glbSoPipSL)
                        OrderClose(OrderTicket(),OrderLots(),Bid,inpSpreadToiDa*10,clrNONE);
                  }
                  else
                  {
                     SoPipLoiLo=(OrderOpenPrice()-Ask)/(10*Point);
                     if(SoPipLoiLo <0 && MathAbs(SoPipLoiLo)>=glbSoPipSL)
                        OrderClose(OrderTicket(),OrderLots(),Ask,inpSpreadToiDa*10,clrNONE);
                  }         
               }
            }  
         }
      }
   }
   
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
         FunDongTatCaCacLenh();
      }
       if(sparam=="btnDongTatCaLenhLo")
      {
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
int FunPhanThapPhanKhoiLuong()
{
   double lot_step=MarketInfo(Symbol(),MODE_LOTSTEP);
   if(lot_step==0.01) return 2;
   if(lot_step==0.05) return 2;
   if(lot_step==0.1) return 1;
   return 0;
}


void FunXuLyKhiCoLenhHedgeBiDong()
{
   FunKiemTraDongLenhHedgeBangTay();
  // FunKiemTraXoaLenhHedgeKhoiMang();
}


//+------------------------------------------------------------------+ 
//+------------------------------------------------------------------+
 void FunKiemTraDongLenhHedgeBangTay()
{
   for(int i=0;i<glbTongSoLenhHedge;i++)
   {
      if(OrderSelect(glbTapLenhHedge[i],SELECT_BY_TICKET))
      {
         if(OrderCloseTime()>0)
         {
            FunDongTatCaCacLenhHedge();
         }
      }
   }
}


//+------------------------------------------------------------------+
 void FunDongTatCaCacLenhHedge()
{
   while(glbTongSoLenhHedge>0)
   {
      if(OrderSelect(glbTapLenhHedge[glbTongSoLenhHedge-1],SELECT_BY_TICKET))
      {
         if(OrderCloseTime()>0)
         {
            glbTapLenhHedge[glbTongSoLenhHedge-1]=-1;
            glbTongSoLenhHedge--;
         }
         else
         {
            if(OrderType()==OP_BUY)
            {
               if(!OrderClose(OrderTicket(),OrderLots(),Bid,inpSlippage,clrBlue))
               {
                  Print(Symbol(),": Loi dong lenh Buy");   
               }
               else 
               {  glbTapLenhHedge[glbTongSoLenhHedge-1]=-1;glbTongSoLenhHedge--;
               }
                  
            }
            else if(OrderType()==OP_SELL)
            {
               if(!OrderClose(OrderTicket(),OrderLots(),Ask,inpSlippage,clrRed))
               {
                  Print(Symbol(),":Loi dong lenh Sell");  
               }
               else 
               {  
                  glbTapLenhHedge[glbTongSoLenhHedge-1]=-1;glbTongSoLenhHedge--;   
              }
            }
         }
      }
   }          
}

//+------------------------------------------------------------------+
 //+------------------------------------------------------------------+
void FunKiemTraXoaLenhHedgeKhoiMang()
{
   for(int i=0;i<glbTongSoLenhHedge;i++)
   {
      if(OrderSelect(glbTapLenhHedge[i],SELECT_BY_TICKET))
      {
         if(OrderCloseTime()>0)
         {
            for(int j=i;j<glbTongSoLenhHedge-1;j++)
            {
               glbTapLenhHedge[j]=glbTapLenhHedge[j+1];
            }
            glbTongSoLenhHedge--;
         }
      }
   }
}

