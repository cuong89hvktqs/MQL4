//+------------------------------------------------------------------+
//|                                      Socket_Client_indicator.mq4 |
//|                                                 Nguyen Van Cuong |
//|                                         https://tailieuforex.com |
//+------------------------------------------------------------------+
#property copyright "Nguyen Van Cuong"
#property link      "https://tailieuforex.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#include <socket-library.mqh>
#define TIMER_FREQUENCY_MS    500
#import "kernel32.dll" 
int GetComputerNameA(string lpBuffer, string nSize);
#import

#import "Secur32.dll"
bool GetUserNameExW(int type, string& buffer, int &size);
#import
enum ENM_Group
{
   V1,//V1
   V2,//V2
   REAL//REAL
};
struct  TongBuySell
{
   string _CapTien;
   double _LotBuy;
   double _LotSell;
};

input string   inpName = "";    // Client name (default Computer name):
input ENM_Group   inpGroup = V1;   // Client group :
input string inpFundName="";// Fund name:
input string   inpServerIp = "165.154.242.159";    // Server hostname or IP address
input ushort   inpServerPort = 64644;        // Server port

ClientSocket * glbClientSocket = NULL;
bool glbCreatedTimer = false;
int glbSoNgayDaVaoLenhTruocDo=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
//---
   glbSoNgayDaVaoLenhTruocDo=FunDemSoNgayVaoLenh();
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
//---
   if(FunKiemTraSangNgayMoiChua())
   {
      glbSoNgayDaVaoLenhTruocDo=FunDemSoNgayVaoLenh();
   }
   if (!glbCreatedTimer) glbCreatedTimer = EventSetMillisecondTimer(TIMER_FREQUENCY_MS);
   if(!glbClientSocket) return rates_total;
   if (glbClientSocket.IsSocketConnected()) {
      // Send the current price as a CRLF-terminated message
      string strMsg = FunMessage() + "\r\n";
      //Print(strMsg);
      glbClientSocket.Send(strMsg);
      
   } else {
      // Either the connection above failed, or the socket has been closed since an earlier
      // connection. We handle this in the next block of code...
   }
   
   // If the socket is closed, destroy it, and attempt a new connection
   // on the next call to OnTick()
   if (!glbClientSocket.IsSocketConnected()) {
      // Destroy the server socket. A new connection
      // will be attempted on the next tick
      Print("Client mat ket noi. Ket noi lai.");
      delete glbClientSocket;
      glbClientSocket = NULL;
   }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
  void OnTimer()
  {
   if (!glbClientSocket) 
   {
      glbClientSocket = new ClientSocket(inpServerIp, inpServerPort);
      if (glbClientSocket.IsSocketConnected()) {
         Print("Client ket noi thanh cong");
         Comment("Client ket noi thanh cong");
         glbClientSocket.Send("Client\r\n");
         FunLabelCreate(0,"KetNoi",20,20,"SERVER CONNECTED",clrLimeGreen,15,"Arial",0,0,CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER) ;
      } else {
         Print("Client ket noi that bai");
         Comment("Client ket noi that bai");
         FunLabelCreate(0,"KetNoi",20,20,"SERVER DISCONNECTED",clrRed,15,"Arial",0,0,CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER) ;
         Sleep(30000);
      }
   }
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if (glbClientSocket) {
      delete glbClientSocket;
      glbClientSocket = NULL;
   }
   ObjectsDeleteAll();
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
string FunMessage()
{
   string str="";
   if(inpName!="")str+=inpName;
   else str+=FunGetComputerName();
   str+=","+inpFundName;
   StringToUpper(str);
   str+=","+FunDoiTenGroupSangString(inpGroup)+ ","+IntegerToString(AccountNumber())+","+
   FunDoiRaDauXauThapPhanCuaDuLieuLon(AccountBalance())+","+FunDoiRaDauXauThapPhanCuaDuLieuLon(AccountEquity());
   double ToDayProfit=0;
   double Profit=0;
   double Lots=0;
   double TongSoLotVaoNgayHomNay=0;
   for(int i=0;i<OrdersHistoryTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
      {
         if(TimeToString(OrderCloseTime(),TIME_DATE)==TimeToString(TimeCurrent(),TIME_DATE))
         {
            ToDayProfit+=OrderProfit()+OrderSwap()+OrderCommission();
            TongSoLotVaoNgayHomNay+=OrderLots();
         }
      }
   }
   string strOrders="";
   TongBuySell BoCapTien[10];
   int DemBoCapTien=0;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderType()<=1)
         {
            Profit+=OrderProfit()+OrderCommission()+OrderSwap();
            // strOrders+=OrderSymbol();
            // strOrders+="  "+FunTraVeTenLenh(OrderType());
            // strOrders+="  "+DoubleToString(OrderLots(),2)+";";
            bool kt=false;
            TongSoLotVaoNgayHomNay+=OrderLots();
            for(int j=0;j<DemBoCapTien;j++)
            {
               if(BoCapTien[j]._CapTien!=OrderSymbol())continue;
               if(OrderType()==OP_BUY)BoCapTien[j]._LotBuy+=OrderLots();
               else BoCapTien[j]._LotSell+=OrderLots();
               kt=true;
            }
            if(kt==false)
            {
               TongBuySell CapTienThemVao;
               CapTienThemVao._CapTien=OrderSymbol();
               if(OrderType()==OP_BUY){CapTienThemVao._LotBuy=OrderLots();CapTienThemVao._LotSell=0;}
               else {CapTienThemVao._LotSell=OrderLots();CapTienThemVao._LotBuy=0;}
               BoCapTien[DemBoCapTien]=CapTienThemVao;
               DemBoCapTien++;
            }
         }
      }
   }
   for (int i = 0; i < DemBoCapTien; i++)
   {
      if(i>=1)strOrders+="  ";
      strOrders+= BoCapTien[i]._CapTien;
      if(BoCapTien[i]._LotBuy>0) strOrders+=" B "+DoubleToStr(BoCapTien[i]._LotBuy,2);
      if(BoCapTien[i]._LotSell>0) strOrders+=" S "+DoubleToStr(BoCapTien[i]._LotSell,2);
   }
   str +=","+FunDoiRaDauXauThapPhanCuaDuLieuLon(ToDayProfit)+ ","+FunDoiRaDauXauThapPhanCuaDuLieuLon(Profit)+","+strOrders+","+DoubleToString(TongSoLotVaoNgayHomNay,2);
   if(TongSoLotVaoNgayHomNay>0)str+=","+IntegerToString(glbSoNgayDaVaoLenhTruocDo);
   else str+=","+IntegerToString(glbSoNgayDaVaoLenhTruocDo+1);
   return str;
}
string FunDoiTenGroupSangString(ENM_Group TenGroup)
{
   if(TenGroup==V1) return "V1";
   else if(TenGroup==V2) return "V2";
   else return "REAL";
}
//+------------------------------------------------------------------+
string FunGetComputerName()
{
    string pcNameBuffer;
    int size = 2047;
    createStringBuffer(pcNameBuffer,size);      
    GetUserNameExW(2, pcNameBuffer, size);
    string PCName="";
    if(StringFind(pcNameBuffer,"\\")>=0)PCName=StringSubstr(pcNameBuffer,StringFind(pcNameBuffer,"\\")+1,0);
    else PCName=pcNameBuffer;
    return PCName;
}
void createStringBuffer(string& buff, int minLen=1024) {
   buff = "_";
   while(StringLen(buff)<=minLen) {
      StringAdd(buff,buff);
   }   
}


string FunTraVeTenLenh(int LoaiLenh)
 {
   switch (LoaiLenh)
   {
      case OP_BUY: return "B";
      break;
      case OP_SELL:return "S";
      break;
      case OP_BUYLIMIT:return "BUY LIMIT";
      break;
      case OP_SELLLIMIT:return "SELL LIMIT";
      break;
      case OP_BUYSTOP:return "BUY STOP";
      break;
      case OP_SELLSTOP:return "SELL STOP";
      break;
      default: return "ERROR";
   }
 }
 string  FunDoiRaDauXauThapPhanCuaDuLieuLon(double DuLieuLon) // Dinh dang: 122.456
{
   
   string Xau="";
   int tam=(int) MathAbs(DuLieuLon) ;
   int dem=0;
   if (tam==0)
   {
      return "0";
   }
   
   while (tam>0)
   {
      string PhanDu=IntegerToString(tam%1000);
      tam=tam/1000;
      dem++;

      if(StringLen(PhanDu)==1)PhanDu=StringConcatenate("00",PhanDu);
      else if(StringLen(PhanDu)==2)PhanDu=StringConcatenate("0",PhanDu);
      else if(StringLen(PhanDu)==0)PhanDu="000";

      if(dem==1)Xau=StringConcatenate((PhanDu),Xau);
      else Xau=StringConcatenate((PhanDu),".",Xau);
   }
   while (StringGetChar(Xau,0)=='0' && StringLen(Xau)>1)
   {
      Xau=StringSubstr(Xau,1,StringLen(Xau));
   }
   if((int)DuLieuLon<0)Xau=StringConcatenate("-",Xau);
   return Xau;
}
//+------------------------------------------------------------------+
//| Create a text label                                              |
//+------------------------------------------------------------------+
bool FunLabelCreate(const long              chart_ID=0,               // chart's ID
                 const string            name="Label",             // label name               
                 const int               x=0,                      // X coordinate
                 const int               y=0,                      // Y coordinate
                 const string            text="Label",             // text
                 const color             clr=clrWheat,               // color
                 const int               font_size=10,             // font size
                 const string            font="Arial",             // font
                 const int               sub_window=0,             // subwindow index
                 const double            angle=0.0,                // text slope
                 const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring              
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
//| Change the object text                                           |
//+------------------------------------------------------------------+
bool FunLabelChangeText(const long   chart_ID=0,  // chart's ID
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
bool FunLabelChangeColor(const long   chart_ID=0,  // chart's ID
                const string name="Text", // object name
                const color clr=clrWhite) // text
  {
//--- reset the error value
   ResetLastError();
//--- change object text
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr))
     {
      Print(__FUNCTION__,
            ": failed to change the color! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }

  bool FunKiemTraSangNgayMoiChua()
  {
      static datetime _LastDay=iTime(Symbol(),PERIOD_CURRENT,0);
      datetime _CurrentDay=iTime(Symbol(),PERIOD_CURRENT,0);
      if(_LastDay!=_CurrentDay)
      {
         _LastDay=_CurrentDay;
         return true;
      }
      return false;
  }

  int FunDemSoNgayVaoLenh()
  {
      string tam="1989.1.1";
      int Dem=0;
      for (int  i = 0; i < OrdersHistoryTotal(); i++)
      {
         if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))continue;
         
         if(TimeToString(OrderOpenTime(),TIME_DATE)!=tam)
         {
            tam=TimeToStr(OrderOpenTime(),TIME_DATE);
            Dem++;
         }
      }
      Print("So nhay vao lenh: ",Dem);
      return Dem;
  }