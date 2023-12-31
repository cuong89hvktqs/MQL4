//+------------------------------------------------------------------+
//|                                              DucQuy_Telegram.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Telegram\Telegram.mqh>
struct NgayThang
  {
   int          Ngay; // date
   int            Thang;  // bid price
   int            Nam;  // ask price
  };
NgayThang NgayHetHan={10,4,2023};
struct Lenh
  {
   int _Ticket;
   int _LoaiLenh; // date
   double _GiaVaoLenh;
   double _GiaSL;
   double _GiaTP;
  };
 


 int glbTongLenh=0;
 Lenh glbTapLenh[200];
 int glbSoCapTienGiaoDichTrongTuan=0;
//--- input parameters
input string InpChannelName="@botnvc89";//ID Kenh:
input string InpToken="1958439508:AAEMEKme2M9oX4aUyfPexA3h5C2N76sZziU";//Ma Token bot Telegram:
input string InpGorupName="Cuong Nguyen";// Ten Người gửi tin hieu:
input bool InpChoPhepHienThiKhoiLuong=true;// Cho phep hien thi khoi luog giao dich: 
 string InpXauThongBaoKhiVaoLenh="Note: the signal is for reference only";


string glbMsg="";
int glbPipSL=0;
int glbPipTP=0;
int glbPipProfit=0;
bool glbDaGuiTinNhanLoiNhuan=false;
string glbXauKhuyenCao=0;
string glbXauThongBao="\nLƯU Ý:\n\tLuôn tuân thủ quản trị vốn.\n\tGiới hạn mức lỗ tối đa không quá 5%/lệnh.\n\tHãy nhớ: Còn vốn là còn có cơ hội thoát nghèo, hết vốn thì chắc chắn nghèo bền vững.";
CCustomBot bot;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
      // Câu lệnh để xác định thời gian hết hạn dùng bot
      glbTongLenh=0;
      ZeroMemory(glbTapLenh);
      if(FunKiemTraHetHan(NgayHetHan)==false){MessageBox("Bot het han su dung");return INIT_FAILED;}
      for(int i=0;i<OrdersTotal();i++)
      {
         Lenh LenhMoi;
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         {
            LenhMoi._Ticket=OrderTicket();
            LenhMoi._LoaiLenh=OrderType();
            LenhMoi._GiaVaoLenh=OrderOpenPrice();
            LenhMoi._GiaSL=OrderStopLoss();
            LenhMoi._GiaTP=OrderTakeProfit();
            
         }
         
         FunThemLenhMoi(LenhMoi);
      }
       bot.Token(InpToken);
       FunGuiTinNhan("GMT+7: "+TimeToString(TimeLocal())+"\nCHART: " +Symbol()+ "\nKET NOI BOT THANH CONG");
      // Print(TimeToString(TimeLocal()));
      //FunGuiTinNhan("Hello");
      //bot.SendChatAction(InpChannelName,ACTION_UPLOAD_PHOTO);
     // bot.SendPhoto(-1708370887,"1.jpg");
     // bot.SendPhoto(1708370887,InpChannelName,"1.jpg");
     // FunTinhLoiNhuanTuan();
     /*
     int file_handel=FileOpen("input.txt",FILE_READ|FILE_BIN);
     if(file_handel!=INVALID_HANDLE)
     {
         glbXauKhuyenCao=FileReadString(file_handel,FileSize(file_handel));
     }
     Print(glbXauKhuyenCao);
     FunGuiTinNhan(glbXauKhuyenCao);
     */
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
      if(OrdersTotal()>glbTongLenh)
      {
         Lenh LenhMoi;
         if(OrderSelect(OrdersTotal()-1,SELECT_BY_POS,MODE_TRADES))
         {
            LenhMoi._Ticket=OrderTicket();
            LenhMoi._LoaiLenh=OrderType();
            LenhMoi._GiaVaoLenh=OrderOpenPrice();
            LenhMoi._GiaSL=OrderStopLoss();
            LenhMoi._GiaTP=OrderTakeProfit();
            if(LenhMoi._GiaTP>0)
               glbPipTP=(int)NormalizeDouble(MathAbs(LenhMoi._GiaTP-LenhMoi._GiaVaoLenh)/(10*MarketInfo(OrderSymbol(),MODE_POINT)),0);
            else glbPipTP=0;
            if(LenhMoi._GiaSL>0)
               glbPipSL=(int)NormalizeDouble(MathAbs(LenhMoi._GiaSL-LenhMoi._GiaVaoLenh)/(10*MarketInfo(OrderSymbol(),MODE_POINT)),0);         
            else glbPipSL=0;
            /*
            if(OrderSymbol()=="XAUUSD" && inpPhanThapPhanGold==3) 
            {
               glbPipTP=(int)(glbPipTP/10);
               glbPipSL=(int)(glbPipSL/10);
            }
            */
           
            if(OrderType()==OP_BUY||OrderType()==OP_SELL)
            {
               glbMsg=StringFormat("Người gửi: %s\nGMT+7: %s\n%s %s\nGiá khớp lệnh: %s\n==> SL: %s (-%d pips)\n==> TP: %s (+%d pips)",InpGorupName,TimeToString(TimeLocal()),FunChuyenDoiLenh(OrderType()),OrderSymbol(),DoubleToString(OrderOpenPrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),
                                DoubleToString(OrderStopLoss(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),glbPipSL,DoubleToString(OrderTakeProfit(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),glbPipTP);
            }
            else
            {
               glbMsg=StringFormat("Người gửi: %s\nGMT+7: %s\nMỞ LỆNH CHỜ: %s %s\nGiá khớp lệnh: %s\n==> SL: %s (-%d pips)\n==> TP: %s (+%d pips)",InpGorupName,TimeToString(TimeLocal()),FunChuyenDoiLenh(OrderType()),OrderSymbol(),DoubleToString(OrderOpenPrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),
                                DoubleToString(OrderStopLoss(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),glbPipSL,DoubleToString(OrderTakeProfit(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),glbPipTP);
            }
            if(InpChoPhepHienThiKhoiLuong==true) glbMsg+="\nLOTS: "+DoubleToString(OrderLots(),FunTinhLotDecimal(OrderSymbol()));
            if(InpXauThongBaoKhiVaoLenh!="")glbMsg+="\n"+glbXauThongBao;
            FunGuiTinNhan(glbMsg);
         }
         FunThemLenhMoi(LenhMoi);
      }
      // Xoa phan tu 
      else if(OrdersTotal()<glbTongLenh)
      {
         FunXoaLenhDaDong();
      }
      else
      {
         FunKiemTraLenhThayDoi();
      }
      // Xử lý trường hợp đóng lệnh 1 phần
      FunXuLyDongLenhMotPhan();
      // Xử lý thông báo lợi nhuận trong tuần
      Comment("Tong so lenh hien tai: ",glbTongLenh);
  }
//+------------------------------------------------------------------+


int FunTinhLotDecimal(string SymbolNameString)
{
   double lot_step=MarketInfo(SymbolNameString,MODE_LOTSTEP);
   if(lot_step==0.01) return 2;
   if(lot_step==0.05) return 2;
   if(lot_step==0.1) return 1;
   return 0;
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
string FunChuyenDoiKhungThoiGian()
{
   int TimeFrame=Period();
   switch (TimeFrame) {
    case PERIOD_M1: return("M1");
    case PERIOD_M5: return("M5");
    case PERIOD_M15: return("M15");
    case PERIOD_H1: return("H1");
    case PERIOD_H4: return("H4");
    case PERIOD_D1: return("D1");
    case PERIOD_W1: return("W1");
    case PERIOD_MN1: return("MN1");
    default: return("???");
    }
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
//=======================================================================
void FunThemLenhMoi(Lenh &LenhX)
{
   {
     // LenhX._ticket=FunCatBotKhoiLuongCuaLenh(LenhX._ticket);
      glbTapLenh[glbTongLenh]=LenhX; //Thêm x vào vị trí vt
	   glbTongLenh++; //Tăng số phần tử lên 1		
	}
}

//=======================================================================
void FunXoaLenhDaDong()
{
    //xoa cac lenh da dong trong mang
    int i=0;
    while(i<glbTongLenh)
    {
      if(OrderSelect(glbTapLenh[i]._Ticket,SELECT_BY_TICKET))
      if(OrderCloseTime()>0)
      {
         //Print("Ticket close:",OrderTicket());
         if(OrderType()==OP_BUY)
         {
            glbPipProfit=(int)NormalizeDouble((OrderClosePrice()-OrderOpenPrice())/(10*MarketInfo(OrderSymbol(),MODE_POINT)),0);
            /*
            if(OrderSymbol()=="XAUUSD" && inpPhanThapPhanGold==3) 
            {
               glbPipProfit=(int)(glbPipProfit/10);
            }
            */
            // Lệnh này đã đóng 1 phần trước đó

            if(StringFind(OrderComment(),"from")>=0)
            {
               if(glbPipProfit<=0)
                  glbMsg=StringFormat("Người gửi: %s\nGMT+7: %s\nĐÓNG PHẦN LỆNH CÒN LẠI\nLệnh: %s %s\nGiá mở lệnh: %s\nGiá đóng lệnh: %s (%d pips)",InpGorupName,TimeToString(TimeLocal()),FunChuyenDoiLenh(OrderType()),OrderSymbol(),DoubleToString(OrderOpenPrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),DoubleToString(OrderClosePrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),glbPipProfit);
               else glbMsg=StringFormat("GMT+7: %s\nĐÓNG PHẦN LỆNH CÒN LẠI\nLệnh: %s %s\nGiá mở lệnh: %s\nGiá đóng lệnh: %s (+%d pips)",TimeToString(TimeLocal()),FunChuyenDoiLenh(OrderType()),OrderSymbol(),DoubleToString(OrderOpenPrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),DoubleToString(OrderClosePrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),glbPipProfit);
            }
            else 
            {
               if(glbPipProfit<=0)
                  glbMsg=StringFormat("Người gửi: %s\nGMT+7: %s\nĐÓNG LỆNH: %s %s\nGiá mở lệnh: %s\nGiá đóng lệnh: %s (%d pips)",InpGorupName,TimeToString(TimeLocal()),FunChuyenDoiLenh(OrderType()),OrderSymbol(),DoubleToString(OrderOpenPrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),DoubleToString(OrderClosePrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),glbPipProfit);
               else glbMsg=StringFormat("Người gửi:%s\nGMT+7: %s\nĐÓNG LỆNH: %s %s\nGiá mở lệnh: %s\nGiá đóng lệnh: %s (+%d pips)",InpGorupName,TimeToString(TimeLocal()),FunChuyenDoiLenh(OrderType()),OrderSymbol(),DoubleToString(OrderOpenPrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),DoubleToString(OrderClosePrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),glbPipProfit);
            }
            if(InpChoPhepHienThiKhoiLuong==true) glbMsg+="\nLOTS: "+DoubleToString(OrderLots(),FunTinhLotDecimal(OrderSymbol()));
            if(InpXauThongBaoKhiVaoLenh!="")glbMsg+="\n"+glbXauThongBao;
            FunGuiTinNhan(glbMsg);
         }
         else if(OrderType()==OP_SELL)
         {
            
            glbPipProfit=(int)NormalizeDouble((OrderOpenPrice()-OrderClosePrice())/(10*MarketInfo(OrderSymbol(),MODE_POINT)),0);
             /*
             if(OrderSymbol()=="XAUUSD" && inpPhanThapPhanGold==3) 
            {
               glbPipProfit=(int)(glbPipProfit/10);
            }
            */
            if(StringFind(OrderComment(),"from")>=0)
            {
               if(glbPipProfit<=0)
                  glbMsg=StringFormat("Người gửi: %s\nGMT+7: %s\nĐÓNG PHẦN LỆNH CÒN LẠI\nLệnh: %s %s\nGiá mở lệnh: %s\nGiá đóng lệnh: %s (%d pips)",InpGorupName,TimeToString(TimeLocal()),FunChuyenDoiLenh(OrderType()),OrderSymbol(),DoubleToString(OrderOpenPrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),DoubleToString(OrderClosePrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),glbPipProfit);
               else glbMsg=StringFormat("Người gửi:%s\nGMT+7: %s\nĐÓNG PHẦN LỆNH CÒN LẠI\nLệnh: %s %s\nGiá mở lệnh: %s\nGiá đóng lệnh: %s (+%d pips)",InpGorupName,TimeToString(TimeLocal()),FunChuyenDoiLenh(OrderType()),OrderSymbol(),DoubleToString(OrderOpenPrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),DoubleToString(OrderClosePrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),glbPipProfit);
            }
            else   
            {
               if(glbPipProfit<=0)
                  glbMsg=StringFormat("Người gửi: %s\nGMT+7: %s\nĐÓNG LỆNH: %s %s\nGiá mở lệnh: %s\nGiá đóng lệnh: %s (%d pips)",InpGorupName,TimeToString(TimeLocal()),FunChuyenDoiLenh(OrderType()),OrderSymbol(),DoubleToString(OrderOpenPrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),DoubleToString(OrderClosePrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),glbPipProfit);
               else glbMsg=StringFormat("Người gửi: %s\nGMT+7: %s\nĐÓNG LỆNH: %s %s\nGiá mở lệnh: %s\nGiá đóng lệnh: %s (+%d pips)",InpGorupName,TimeToString(TimeLocal()),FunChuyenDoiLenh(OrderType()),OrderSymbol(),DoubleToString(OrderOpenPrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),DoubleToString(OrderClosePrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),glbPipProfit);
            }
            if(InpChoPhepHienThiKhoiLuong==true) glbMsg+="\nLOTS: "+DoubleToString(OrderLots(),FunTinhLotDecimal(OrderSymbol()));
            if(InpXauThongBaoKhiVaoLenh!="")glbMsg+="\n"+glbXauThongBao;
            FunGuiTinNhan(glbMsg);
         }
         else
         {  
            glbMsg=StringFormat("Người gửi: %s\nGMT+7: %s\nXÓA LỆNH CHỜ: %s %s giá %s",InpGorupName,TimeToString(TimeLocal()),FunChuyenDoiLenh(OrderType()),OrderSymbol(),DoubleToString(OrderOpenPrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)));
            if(InpChoPhepHienThiKhoiLuong==true) glbMsg+="\nLOTS: "+DoubleToString(OrderLots(),FunTinhLotDecimal(OrderSymbol()));
            if(InpXauThongBaoKhiVaoLenh!="")glbMsg+="\n"+glbXauThongBao;
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


////=======================================================================
int FunTimPhanTuTrongMang(Lenh &a[],int &n, int ticket)
{
   for(int i=0;i<n;i++)
   {
      if(a[i]._Ticket==ticket)
         return i;
   }
   return -1;
}

////=======================================================================
void FunKiemTraLenhThayDoi()
{
   for(int i=0;i<glbTongLenh;i++)
   {       
      OrderSelect(glbTapLenh[i]._Ticket,SELECT_BY_TICKET,MODE_TRADES);
      if(OrderType()!=glbTapLenh[i]._LoaiLenh)
      {
         
         if(glbTapLenh[i]._GiaTP>0)
               glbPipTP=(int)NormalizeDouble(MathAbs(glbTapLenh[i]._GiaTP-glbTapLenh[i]._GiaVaoLenh)/(10*MarketInfo(OrderSymbol(),MODE_POINT)),0);
         else glbPipTP=0;
         if(glbTapLenh[i]._GiaSL>0)
               glbPipSL=(int)NormalizeDouble(MathAbs(glbTapLenh[i]._GiaSL-glbTapLenh[i]._GiaVaoLenh)/(10*MarketInfo(OrderSymbol(),MODE_POINT)),0);         
         else glbPipSL=0;
         /*
         if(OrderSymbol()=="XAUUSD" && inpPhanThapPhanGold==3) 
         {
             glbPipTP=(int)(glbPipTP/10);
             glbPipSL=(int)(glbPipSL/10);
         }
         */
         glbMsg=StringFormat("Người gửi: %s\nGMT+7: %s\n(KHỚP LỆNH CHỜ)\nLệnh %s %s Chuyển thành %s\nGiá vào lệnh: %s\n==> SL: %s (-%d pips)\n==> TP: %s (+%d pips)",InpGorupName,TimeToString(TimeLocal()),FunChuyenDoiLenh(glbTapLenh[i]._LoaiLenh),OrderSymbol(),FunChuyenDoiLenh(OrderType()),DoubleToString(OrderOpenPrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),
                              DoubleToString(OrderStopLoss(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),glbPipSL,DoubleToString(OrderTakeProfit(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),glbPipTP);
         if(InpChoPhepHienThiKhoiLuong==true) glbMsg+="\nLOTS: "+DoubleToString(OrderLots(),FunTinhLotDecimal(OrderSymbol()));
         if(InpXauThongBaoKhiVaoLenh!="")glbMsg+="\n"+glbXauThongBao;
         FunGuiTinNhan(glbMsg);
         glbTapLenh[i]._LoaiLenh=OrderType();
         
      }
      if(OrderOpenPrice()!=glbTapLenh[i]._GiaVaoLenh && OrderType()!=OP_BUY && OrderType()!=OP_SELL)
      {
         double GiaKhopLenhCu=glbTapLenh[i]._GiaVaoLenh;
         glbTapLenh[i]._Ticket=OrderTicket();
         glbTapLenh[i]._LoaiLenh=OrderType();
         glbTapLenh[i]._GiaVaoLenh=OrderOpenPrice();
         glbTapLenh[i]._GiaSL=OrderStopLoss();
         glbTapLenh[i]._GiaTP=OrderTakeProfit();       
         if(glbTapLenh[i]._GiaTP>0)
               glbPipTP=(int)NormalizeDouble(MathAbs(glbTapLenh[i]._GiaTP-glbTapLenh[i]._GiaVaoLenh)/(10*MarketInfo(OrderSymbol(),MODE_POINT)),0);
         else glbPipTP=0;
         if(glbTapLenh[i]._GiaSL>0)
               glbPipSL=(int)NormalizeDouble(MathAbs(glbTapLenh[i]._GiaSL-glbTapLenh[i]._GiaVaoLenh)/(10*MarketInfo(OrderSymbol(),MODE_POINT)),0);         
         else glbPipSL=0; 
         /*  
         if(OrderSymbol()=="XAUUSD" && inpPhanThapPhanGold==3) 
         {
             glbPipTP=(int)(glbPipTP/10);
             glbPipSL=(int)(glbPipSL/10);
         }   
         */
         glbMsg=StringFormat("Người gửi: %s\nGMT+7: %s\n(THAY ĐỔI GIÁ KHỚP LỆNH CHỜ)\nLệnh %s %s Thay đổi giá khớp lệnh %s thành: %s\n==> SL: %s (-%d pips)\n==> TP: %s (+%d pips)",InpGorupName,TimeToString(TimeLocal()),FunChuyenDoiLenh(OrderType()),OrderSymbol(),DoubleToString(GiaKhopLenhCu,(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),DoubleToString(OrderOpenPrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),
                              DoubleToString(OrderStopLoss(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),glbPipSL,DoubleToString(OrderTakeProfit(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),glbPipTP);
         if(InpChoPhepHienThiKhoiLuong==true) glbMsg+="\nLOTS: "+DoubleToString(OrderLots(),FunTinhLotDecimal(OrderSymbol()));
         if(InpXauThongBaoKhiVaoLenh!="")glbMsg+="\n"+glbXauThongBao;
         FunGuiTinNhan(glbMsg);
      }
      if(OrderTakeProfit()!=glbTapLenh[i]._GiaTP)
      {
         glbTapLenh[i]._GiaTP=OrderTakeProfit();
         if(glbTapLenh[i]._GiaTP>0)
               glbPipTP=(int)NormalizeDouble(MathAbs(glbTapLenh[i]._GiaTP-glbTapLenh[i]._GiaVaoLenh)/(10*MarketInfo(OrderSymbol(),MODE_POINT)),2);
         else glbPipTP=0;
         /*
         if(OrderSymbol()=="XAUUSD" && inpPhanThapPhanGold==3) 
         {
             glbPipTP=(int)(glbPipTP/10);
         }
         */
         if(glbTapLenh[i]._GiaSL>0)
               glbPipSL=(int)NormalizeDouble(MathAbs(glbTapLenh[i]._GiaSL-glbTapLenh[i]._GiaVaoLenh)/(10*MarketInfo(OrderSymbol(),MODE_POINT)),2);         
         else glbPipSL=0; 
         glbMsg=StringFormat("Người gửi: %s\nGMT+7: %s\n(THAY ĐỔI GIÁ TP)\n%s %s\nGiá mở lệnh: %s\n==> SL: %s (-%d pips)\n==> TP: %s (+%d pips)",InpGorupName,TimeToString(TimeLocal()),FunChuyenDoiLenh(OrderType()),OrderSymbol(),DoubleToString(OrderOpenPrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),
                              DoubleToString(OrderStopLoss(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),(int)glbPipSL,DoubleToString(OrderTakeProfit(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),(int)glbPipTP);
         if(InpChoPhepHienThiKhoiLuong==true) glbMsg+="\nLOTS: "+DoubleToString(OrderLots(),FunTinhLotDecimal(OrderSymbol()));
         if(InpXauThongBaoKhiVaoLenh!="")glbMsg+="\n"+glbXauThongBao;
         FunGuiTinNhan(glbMsg);
         
      }
      if(OrderStopLoss()!=glbTapLenh[i]._GiaSL)
      {
         glbTapLenh[i]._GiaSL=OrderStopLoss();
         if(glbTapLenh[i]._GiaTP>0)
               glbPipTP=(int)NormalizeDouble(MathAbs(glbTapLenh[i]._GiaTP-glbTapLenh[i]._GiaVaoLenh)/(10*MarketInfo(OrderSymbol(),MODE_POINT)),2);
         else glbPipTP=0;
         if(glbTapLenh[i]._GiaSL>0)
               glbPipSL=(int)NormalizeDouble(MathAbs(glbTapLenh[i]._GiaSL-glbTapLenh[i]._GiaVaoLenh)/(10*MarketInfo(OrderSymbol(),MODE_POINT)),2);         
         else glbPipSL=0; 
         /*
         if(OrderSymbol()=="XAUUSD" && inpPhanThapPhanGold==3) 
         {
             glbPipTP=(int)(glbPipTP/10);
             glbPipSL=(int)(glbPipSL/10);
         }
         */
         glbMsg=StringFormat("Người gửi: %s\nGMT+7: %s\n(THAY ĐỔI GIÁ SL)\n%s %s\nGiá mở lệnh: %s\n==> SL: %s (-%d pips)\n==> TP: %s (+%d pips)",InpGorupName,TimeToString(TimeLocal()),FunChuyenDoiLenh(OrderType()),OrderSymbol(),DoubleToString(OrderOpenPrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),
                                DoubleToString(OrderStopLoss(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),glbPipSL,DoubleToString(OrderTakeProfit(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),glbPipTP);
         if(InpChoPhepHienThiKhoiLuong==true) glbMsg+="\nLOTS: "+DoubleToString(OrderLots(),FunTinhLotDecimal(OrderSymbol()));
         if(InpXauThongBaoKhiVaoLenh!="")glbMsg+="\n"+glbXauThongBao;
         FunGuiTinNhan(glbMsg);
      }
      
   }
}
////=======================================================================
 void FunXuLyDongLenhMotPhan()
 {
   for(int i=0;i<glbTongLenh;i++)
   {
      
      OrderSelect(glbTapLenh[i]._Ticket,SELECT_BY_TICKET,MODE_TRADES);    
      if(OrderCloseTime()>0)
      {
         double GiaMoLenh=OrderOpenPrice();
         double GiaDongLenh=OrderClosePrice();
         int  PipProfit=0;
         if(OrderType()%2==0)PipProfit=(int)NormalizeDouble((OrderClosePrice()-OrderOpenPrice())/(10*MarketInfo(OrderSymbol(),MODE_POINT)),0);
         else PipProfit=(int)NormalizeDouble((OrderOpenPrice()-OrderClosePrice())/(10*MarketInfo(OrderSymbol(),MODE_POINT)),0);
         /*
         if(OrderSymbol()=="XAUUSD" && inpPhanThapPhanGold==3) 
         {
             PipProfit=(int)(PipProfit/10);
         }
         */
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
               
               glbTapLenh[i]._Ticket=OrderTicket();
               glbTapLenh[i]._LoaiLenh=OrderType();
               glbTapLenh[i]._GiaVaoLenh=OrderOpenPrice();
               glbTapLenh[i]._GiaSL=OrderStopLoss();
               glbTapLenh[i]._GiaTP=OrderTakeProfit();
               string PhanTramLenhDong=DoubleToString((100*Lot)/(Lot+OrderLots()),0);
               if(PipProfit<=0)
                  glbMsg=StringFormat("Người gửi: %s\nGMT+7: %s\n(ĐÓNG MỘT PHẦN LỆNH)\nĐóng %s%% khối lượng lệnh: %s %s\nGiá mở lệnh: %s\nGiá đóng lệnh: %s (%d pips)",InpGorupName,TimeToString(TimeLocal()),PhanTramLenhDong,FunChuyenDoiLenh(OrderType()),OrderSymbol(),
                                  DoubleToString(GiaMoLenh,(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),DoubleToString(GiaDongLenh,(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),PipProfit);
               else
                  glbMsg=StringFormat("Người gửi: %s\nGMT+7: %s\n(ĐÓNG MỘT PHẦN LỆNH)\nĐóng %s%% khối lượng lệnh: %s %s\nGiá mở lệnh: %s\nGiá đóng lệnh: %s (+%d pips)",InpGorupName,TimeToString(TimeLocal()),PhanTramLenhDong,FunChuyenDoiLenh(OrderType()),OrderSymbol(),
                                  DoubleToString(GiaMoLenh,(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),DoubleToString(GiaDongLenh,(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),PipProfit);
               
               if(InpChoPhepHienThiKhoiLuong==true) glbMsg+="\nLOTS: "+DoubleToString(Lot,FunTinhLotDecimal(OrderSymbol()));
               if(InpXauThongBaoKhiVaoLenh!="")glbMsg+="\n"+glbXauThongBao;
               FunGuiTinNhan(glbMsg);
               break;
            }
         }
         
      }
   }
 
 }
 
 ////=======================================================================
void FunGuiTinNhan(string msg)
{
    bot.SendMessage(InpChannelName,msg);
    
}
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
 
//+------------------------------------------------------------------+

 
 
