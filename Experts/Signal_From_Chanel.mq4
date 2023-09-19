//+------------------------------------------------------------------+
//|                                             Signal_from_Tele.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <Telegram\Telegram.mqh>
#define accountID 48177870
struct NgayThang
  {
   int          Ngay; // date
   int            Thang;  // bid price
   int            Nam;  // ask price
  };
NgayThang NgayHetHan={30,12,3022};

input string inpChannelName="@cuong89bot";//ID Kenh:
input string inpToken="1735772983:AAG4g3Qem_oGQN3bpTmztuLHiT67bQCsXWs";//Ma Token bot Telegram:
input int inpSlippage=50;
input bool inpChoPheoVaoLenhNguoc=false;//Cho phep vao lenh nguoc (false: khong cho phep):

class CMyBot: public CCustomBot
{
   public:
     void ProcessMessages(void)
     {
      for(int i=0; i<m_chats.Total(); i++)
        {
         CCustomChat *chat=m_chats.GetNodeAtIndex(i);
         //--- if the message is not processed
         if(!chat.m_new_one.done)
           {
            chat.m_new_one.done=true;
            string text=chat.m_new_one.message_text;

            //--- start
            if(text=="/start")
               SendMessage(chat.m_id,"Hello, world! I am bot. \xF680");

            //--- help
            if(text=="/help")
               SendMessage(chat.m_id,"My commands list: \n/start-start chatting with me \n/help-get help");
           }
        }
     }
     void ProcessMessagesGetLatestText(int &Total_signals, string &Messase_Signals[])
     {
      string text="";
      int Total=0;
    //  Print("m_chat:",m_chats.Total());
      //m_chats.Save("test.txt");
      for(int i=0; i<m_chats.Total(); i++)
      {
         CCustomChat *chat=m_chats.GetNodeAtIndex(i);
         if(!chat.m_new_one.done)
         {
            chat.m_new_one.done=true;
             text=chat.m_new_one.message_text;
             Messase_Signals[Total]=text;
             Total++;
         }
       }
       Total_signals=Total;
     }
     
};

struct Str_Tele_Signal
{
   int _id_name;
   string _symbol;
   int _order_type;
   double _lots;
   double _price;
   double _take_profit;
   double _stop_loss;
};

struct Str_Lenh_Vao
{
   int _id_ticket;
   Str_Tele_Signal _tele_signal;
};

Str_Tele_Signal glbTeleSignal;
Str_Lenh_Vao glbTapLenhVao[100];
int glbTongLenh=0;
CMyBot glbBotTelegram;
int glbSlippage=50;
int glbCheckConnectBot;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
      if(FunKiemDaHetHanChua(NgayHetHan)==true)return INIT_FAILED;
      if(AccountNumber()!=accountID)
      {
         Alert("Bot chi giao dich voi tai khoan mt4 co account ID= ",accountID);
         Print("Bot chi giao dich voi tai khoan mt4 co account ID= ",accountID);
         return INIT_FAILED;
      }
      glbSlippage=inpSlippage;
      glbBotTelegram.Token(inpToken);
      glbCheckConnectBot=glbBotTelegram.GetMe();
      EventSetTimer(2);// SAu 2 giay xu ly 1 lan
      OnTimer();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- 
    EventKillTimer(); 
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTimer()
{  

   //--- show error message end exit
   if(FunKiemDaHetHanChua(NgayHetHan)==true){ExpertRemove();return;}
   if(glbCheckConnectBot!=0)
     {
      Comment("Error: ",GetErrorDescription(glbCheckConnectBot));
      return;
     }
  // Comment("Bot name: ",glbBotTelegram.Name());
   Comment("Tong lenh:",glbTongLenh);
   FunProcessSignalTele();
   FunKiemTraDongLenhBangTay();

}
/*
void OnTick()
  {
//---
      FunProcessSignalTele();
      FunKiemTraDongLenhBangTay();
  }
  */
//+------------------------------------------------------------------+
void FunProcessSignalTele()
{
   // Caapj nhat msg moi
   int Total_Signal=0;
   string Message_Signal[100];
   
   glbBotTelegram.GetUpdatesV1_Chanel();
   glbBotTelegram.ProcessMessagesGetLatestText(Total_Signal,Message_Signal);
   // Xu ly msg den
   for(int j=0;j<Total_Signal;j++)
   {
      string TeleString=Message_Signal[j];
     // Print("Message:",TeleString);
      if(TeleString!="")
      {
         string Split_Tele_Strings[];
         int String_Total=StringSplit(TeleString,StringGetCharacter("\n",0),Split_Tele_Strings);
         if(String_Total==8)
         {
            ZeroMemory(glbTeleSignal);
            for(int i=0;i<String_Total;i++)
            {
               string Sub_String[];
               int tam=StringSplit(Split_Tele_Strings[i],StringGetCharacter(":",0),Sub_String);
               if(i==1) 
               {
                  StringReplace(Sub_String[1],".","");// Loai bo dau . : XAUUSD.
                  StringReplace(Sub_String[1],"'","");  // Loai bo dau . : XAUUSD'
               }
               //Loai bo khoang trang
               Sub_String[1]=StringTrimLeft(Sub_String[1]);
               Sub_String[1]=StringTrimRight(Sub_String[1]);
               // Gan gia tri cua xau cat duoc vao Struct Tele
               if(i==0)glbTeleSignal._id_name=(int)StringToInteger(Sub_String[1]);
               else if(i==1)glbTeleSignal._symbol=Sub_String[1];
               else if(i==2)glbTeleSignal._order_type=FunReturnOrderType(Sub_String[1]);
               else if(i==3)glbTeleSignal._lots=StringToDouble(Sub_String[1]);
               else if(i==4)glbTeleSignal._price=StringToDouble(Sub_String[1]);
               else if(i==5);
               else if(i==6)glbTeleSignal._stop_loss=StringToDouble(Sub_String[1]);
               else glbTeleSignal._take_profit=StringToDouble(Sub_String[1]);   
            }
            Print(FunPrintTeleSignal(glbTeleSignal));
            Comment(FunPrintTeleSignal(glbTeleSignal));
            int ticket=FunOrderFromTeleSignal(glbTeleSignal);
            if(ticket>0)
            {
               glbTapLenhVao[glbTongLenh]._id_ticket=ticket;
               glbTapLenhVao[glbTongLenh]._tele_signal=glbTeleSignal;
               glbTongLenh++;
            }
            else 
            {
               Comment("Vao lenh loi");
               Print("Vao lenh loi");
            }
         }
         else if(String_Total==5)
         {
            int id_name=0;
            string action;
            string symbol;
            double lots=0;
            for(int i=0;i<String_Total;i++)
            {
               string Sub_String[];
               int tam=StringSplit(Split_Tele_Strings[i],StringGetCharacter(":",0),Sub_String);
               if(i==2) 
               {
                  StringReplace(Sub_String[1],".","");// Loai bo dau . : XAUUSD.
                  StringReplace(Sub_String[1],"'","");  // Loai bo dau . : XAUUSD'
               }
               //Loai bo khoang trang
               Sub_String[1]=StringTrimLeft(Sub_String[1]);
               Sub_String[1]=StringTrimRight(Sub_String[1]);
               
               if(i==0)id_name=(int)StringToInteger(Sub_String[1]);
               else if(i==1) action=Sub_String[1];
               else if(i==2) 
               {
                  symbol=Sub_String[1];
               }
               else if(i==3) lots=StringToDouble(Sub_String[1]);              
            }
            if(action=="Order Closed") FunCloseOrderFromTeleSignal(id_name,lots);
         }
         else
         {
            Comment("BOT KHONG XU LY DUOC DU LIEU TU TELEGRAM");           
            Comment("BOT KHONG XU LY DUOC DU LIEU TU TELEGRAM. String: ",TeleString);
            //Alert("BOT KHONG XU LY DUOC DU LIEU TU TELEGRAM");
         }
         
      
      }
   }
   
   
}  


//+------------------------------------------------------------------+
int FunReturnOrderType(string StringOrder)
{
   //Print(StringOrder);
   if(StringOrder=="Buy")
      return OP_BUY;
   else if(StringOrder=="Sell")
      return OP_SELL;
   else if (StringOrder=="Buy Limit")
      return OP_BUYLIMIT;
   else if (StringOrder=="Sell Limit")
      return OP_SELLLIMIT;
   else if (StringOrder=="Buy Stop")
      return OP_BUYSTOP;
   else if (StringOrder=="Sell Stop")
      return OP_SELLSTOP;
   else return -1;
}
//+------------------------------------------------------------------+
int FunOrderFromTeleSignal(Str_Tele_Signal &tele_signal)
{
   int ticket;
  // Print(tele_signal._order_type);
   switch (tele_signal._order_type)
   {
      case OP_BUY:
         if(inpChoPheoVaoLenhNguoc==false)
         {
            Print("VAO LENH BUY");
            ticket=OrderSend(tele_signal._symbol,tele_signal._order_type,tele_signal._lots,MarketInfo(tele_signal._symbol,MODE_ASK),glbSlippage,tele_signal._stop_loss,tele_signal._take_profit,"EA",12345,0,clrNONE);
         }
         else
         {
            Print("VAO LENH NGUOC: SELL");
            ticket=OrderSend(tele_signal._symbol,OP_SELL,tele_signal._lots,MarketInfo(tele_signal._symbol,MODE_BID),glbSlippage,tele_signal._take_profit,tele_signal._stop_loss,"EA vao nguoc",12345,0,clrNONE);
         }
      break;
      case OP_SELL:
         if(inpChoPheoVaoLenhNguoc==false)
         {
            Print("VAO LENH SELL");
            ticket=OrderSend(tele_signal._symbol,tele_signal._order_type,tele_signal._lots,MarketInfo(tele_signal._symbol,MODE_BID),glbSlippage,tele_signal._stop_loss,tele_signal._take_profit,"EA",12345,0,clrNONE);
         }
         else
         {
            Print("VAO LENH NGUOC: BUY");
            ticket=OrderSend(tele_signal._symbol,OP_BUY,tele_signal._lots,MarketInfo(tele_signal._symbol,MODE_ASK),glbSlippage,tele_signal._take_profit,tele_signal._stop_loss,"EA vao nguoc",12345,0,clrNONE);
         }
      break;
      case OP_BUYLIMIT:
         ticket=OrderSend(tele_signal._symbol,tele_signal._order_type,tele_signal._lots,tele_signal._price,glbSlippage,tele_signal._stop_loss,tele_signal._take_profit,"EA",12345,0,clrNONE);
      break;
      case OP_SELLLIMIT:
         ticket=OrderSend(tele_signal._symbol,tele_signal._order_type,tele_signal._lots,tele_signal._price,glbSlippage,tele_signal._stop_loss,tele_signal._take_profit,"EA",12345,0,clrNONE);
      break;
      case OP_BUYSTOP:
         ticket=OrderSend(tele_signal._symbol,tele_signal._order_type,tele_signal._lots,tele_signal._price,glbSlippage,tele_signal._stop_loss,tele_signal._take_profit,"EA",12345,0,clrNONE);
      break;
      case OP_SELLSTOP:
         ticket=OrderSend(tele_signal._symbol,tele_signal._order_type,tele_signal._lots,tele_signal._price,glbSlippage,tele_signal._stop_loss,tele_signal._take_profit,"EA",12345,0,clrNONE);
      break;
      default:
         ticket=-1;
      break;
   }
   if(ticket==-1) Print("Loi vao lenh: ",GetLastError());
   return ticket;
}

//+------------------------------------------------------------------+
void FunCloseOrderFromTeleSignal(int id_signal_tele, double lots)
{
   if(lots==0) return;
   for(int i=0;i<glbTongLenh;i++)
   {
      if(glbTapLenhVao[i]._tele_signal._id_name==id_signal_tele)
      {
        int gia_tri_tra_ve_dong_lenh=FunCloseOrder(glbTapLenhVao[i]._id_ticket,lots);
        Print("Gia tri tra ve sau khi dong lenh:",gia_tri_tra_ve_dong_lenh);
        if(gia_tri_tra_ve_dong_lenh==0)// da dong toan bo lenh
        {
            // Loai bo lenh khoi tap lenh
            
            for(int j=i;j<glbTongLenh-1;j++)
            {
               glbTapLenhVao[j]=glbTapLenhVao[j+1];
            }
            glbTongLenh--;
        } 
        else if(gia_tri_tra_ve_dong_lenh>0)// Moi dong mot phan lenh
         {
            glbTapLenhVao[i]._id_ticket=gia_tri_tra_ve_dong_lenh;// gasn ticket moi vao tap lenh
         }
        else
         {
            Alert("Dong lenh bi loi");
         }
      }
   }
   
}

//+------------------------------------------------------------------+
// Neu la lenh buy, sell chi dong 1 phan lenh, tra ve tich ket moi
// neu dong toan bo lenh tra e gia tri 0
// neu doong lenh bi loi tra ve gia tri -1
int FunCloseOrder(int ticket, double lots)
{
   bool _check_close_order=false;
   int gia_tri_tra_ve=-1;
   if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
   {
      if(OrderLots()<lots) {Print("Donh lenh : ", ticket, " bi loi do vuot qua khoi luong cho phep");return -1;}
      if(OrderType()==OP_BUY)
      {
         _check_close_order=OrderClose(ticket,lots,MarketInfo(OrderSymbol(),MODE_BID),glbSlippage,clrNONE);
         if(_check_close_order==true)
         {
            if(OrderLots()>lots)
            {
               if(OrderSelect(OrdersTotal()-1,SELECT_BY_POS,MODE_TRADES))
               {
                  if(StringFind(OrderComment(),IntegerToString(ticket),0)>=0)
                     gia_tri_tra_ve=OrderTicket();
               }
            }
            else gia_tri_tra_ve=0;
         }
         else 
         {
           Print("Donh lenh : ", ticket, " bi loi do gian slippage");
            gia_tri_tra_ve=-1;
         }
         
      }  
      else if(OrderType()==OP_SELL)
      {
         _check_close_order=OrderClose(ticket,lots,MarketInfo(OrderSymbol(),MODE_ASK),glbSlippage,clrNONE);
         if(_check_close_order==true)
         {
            if(OrderLots()>lots)
            {
               if(OrderSelect(OrdersTotal()-1,SELECT_BY_POS,MODE_TRADES))
               {
                  if(StringFind(OrderComment(),IntegerToString(ticket),0)>=0)
                     gia_tri_tra_ve=OrderTicket();
               }
            }
            else gia_tri_tra_ve=0;
         }
         else 
         {
            gia_tri_tra_ve=-1;
             Print("Donh lenh : ", ticket, " bi loi do gian slippage");
         }
      }
      else
      {
        _check_close_order= OrderDelete(OrderTicket());
        if(_check_close_order==true)
         gia_tri_tra_ve=0;
        else 
        {
          gia_tri_tra_ve=-1;
          Print("Donh lenh limit, stop: ", ticket, " bi loi do sai ticket");
        }
      } 
   }
   return gia_tri_tra_ve;
}

string FunPrintTeleSignal(Str_Tele_Signal &tele_signal)
{
   return StringFormat("Name:%d\nSybol:%s\nType:%s\nLots:%0.2f\nPrice:%f\n,StopLoss:%f\nTakeProfit:%f",tele_signal._id_name,tele_signal._symbol,FunConvertOrderTypeToString(tele_signal._order_type),tele_signal._lots,tele_signal._price,tele_signal._stop_loss,tele_signal._take_profit);
}

string FunConvertOrderTypeToString(int order_type)
{
   switch(order_type)
   {
      case OP_BUY: return "Buy";
      break;
      case OP_SELL: return "Sell";
      break;
      case OP_BUYLIMIT: return "Buy Limit";
      break;
      case OP_SELLLIMIT: return "Sell Limit";
      break;
      case OP_BUYSTOP: return "Buy Stop";
      break;
      case OP_SELLSTOP: return "Sell Stop";
      break;
      default:return "Khong Xac Dinh";
      break;
   
   }
}

void FunKiemTraDongLenhBangTay()
{
   for(int i=0;i<glbTongLenh;i++)
   {
      if(OrderSelect(glbTapLenhVao[i]._id_ticket,SELECT_BY_TICKET))
      {
         if(OrderCloseTime()>0)
         {
            for(int j=i;j<glbTongLenh-1;j++)
            {
               glbTapLenhVao[j]=glbTapLenhVao[j+1];
            }
            glbTongLenh--;
         }
      }
   }
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


