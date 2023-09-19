//+------------------------------------------------------------------+
//|                                                         Test.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "VIET BOT THEO YEU CAU, Website: tailieuforex.com, SDT: 0971 926 248"
#property link      "https://www.tailieuforex.com"
#property version   "1.00"
#property strict
#include <socket-library.mqh>
#define TIMER_FREQUENCY_MS    500
#define def_X_CoSo 0
#define def_Y_COSO 50
#define def_CAO 25
#define def_RONG 45
#define KEY_R 82
enum ENM_Group
{
   V1,//V1
   V2,//V2
   REAL,//REAL
   ALL,//ALL GROUPS
};
input ENM_Group inpGroup=ALL;//Group Mamager:
input string   inpServerIp = "165.154.242.159";    // Server hostname or IP address
input ushort   inpServerPort = 64644;        // Server port

ClientSocket * glbClientSocketManager = NULL;
bool glbCreatedTimer = false;
struct  ThongTinClientGui
{
    string _TenTaiKhoan;
    string _FundName;
    string _TenGroup;
    int _IDTaiKhoan;
    string _AccBalance;
    string _AccEquity;
    string _ProfitDongLenh;
    string _ProfitHienTai;
    string _TrangThai;
    string _Orders;
    double _TongSoLotHomNayVao;
    int _TongSoNgayDaVaoLenh;
};
ThongTinClientGui glbThongTinClientGui[100];
int glbTongSoRowClient=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   glbCreatedTimer = EventSetMillisecondTimer(TIMER_FREQUENCY_MS) ;
   FunReset();  
   FunThietLapMauNenCuaChart();
   FunCreatTableHeader();
   FunLabelCreate(0,"TENMAY",20,20,"MAY MANAGER",clrYellow,15,"Arial",0,0,CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER) ;
  return(INIT_SUCCEEDED);
}
void FunReset()
{
   glbTongSoRowClient=0;
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    if (glbClientSocketManager) {
      delete glbClientSocketManager;
      glbClientSocketManager = NULL;
   }
   Print("Manager socket dung hoat dong");
   ObjectsDeleteAll();
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
      if (!glbCreatedTimer) glbCreatedTimer = EventSetMillisecondTimer(TIMER_FREQUENCY_MS);
}
void OnTimer()
{
    if (!glbClientSocketManager) 
    {
        glbClientSocketManager = new ClientSocket(inpServerIp, inpServerPort);
        if (glbClientSocketManager.IsSocketConnected()) {
            Print("Client connection succeeded");
            Comment("Client connection succeeded");
            glbClientSocketManager.Send("Manager\r\n");
            FunLabelDelete(0,"KetNoi");
        } else {
            Print("Client connection failed");
            Comment("Client connection failed");
            Sleep(30000);
        }
    }
   if (glbClientSocketManager.IsSocketConnected()) {
        // Send the current price as a CRLF-terminated message
        string strCommand;
        do 
        {
            strCommand = glbClientSocketManager.Receive("\r\n");
            if(strCommand!="")
            {
                ThongTinClientGui StrThongTinNhanDuoc=FunXuLyXauThongTinNhanDuocThanhStruct(strCommand);
                bool kt=false;
                for (int i = 0; i < glbTongSoRowClient; i++)
                {
                    if(StrThongTinNhanDuoc._IDTaiKhoan==glbThongTinClientGui[i]._IDTaiKhoan)
                    {
                        glbThongTinClientGui[i]=StrThongTinNhanDuoc;
                        kt=true;
                    }
                }
                if(kt==false)
                {
                     if(StrThongTinNhanDuoc._IDTaiKhoan>0)
                     {
                        if(inpGroup==ALL || StrThongTinNhanDuoc._TenGroup==FunDoiTenGroupSangString(inpGroup))
                        {
                           FunChenPhanTuVaoBang( StrThongTinNhanDuoc);
                           // glbThongTinClientGui[glbTongSoRowClient]=StrThongTinNhanDuoc;
                           // glbTongSoRowClient++;
                        }
                     }      
                }
            }
        } while (strCommand != "");
        for (int i = 0; i < glbTongSoRowClient; i++)
        {
                FunCreatRowOfTable(i);
        }
    } else 
    {
        // Either the connection above failed, or the socket has been closed since an earlier
        // connection. We handle this in the next block of code...
        Print("Server disconnected. Will retry.");
        Comment("Server disconnected. Will retry.");
        delete glbClientSocketManager;
        glbClientSocketManager = NULL;
        FunLabelCreate(0,"KetNoi",20,20,"SERVER DISCONNECTED",clrRed,15,"Arial",0,0,CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER) ;
        //ExpertRemove();
    }
}
void FunChenPhanTuVaoBang(ThongTinClientGui &strThongTinClient)
{
   int Vitri=FunTimViTriCanChen(strThongTinClient);
   glbTongSoRowClient++;
   for (int i = glbTongSoRowClient-1; i >Vitri; i--)
   {
      glbThongTinClientGui[i]=glbThongTinClientGui[i-1];
   }
   glbThongTinClientGui[Vitri]=strThongTinClient;
   
}
//+------------------------------------------------------------------+
int FunTimViTriCanChen(ThongTinClientGui &strThongTinClient)
{
   int k=-1, Vitri=glbTongSoRowClient;
   string Name;
   if((k=StringFind(strThongTinClient._TenTaiKhoan," ",0))>=0)
      Name=StringSubstr(strThongTinClient._TenTaiKhoan,k,StringLen(strThongTinClient._TenTaiKhoan)-k);
   else Name=strThongTinClient._TenTaiKhoan;
   for (int i = 0; i < glbTongSoRowClient; i++)
   {
      string XauSoSanh;
      if((k=StringFind(glbThongTinClientGui[i]._TenTaiKhoan," ",0))>=0)
         XauSoSanh=StringSubstr(glbThongTinClientGui[i]._TenTaiKhoan,k,StringLen(glbThongTinClientGui[i]._TenTaiKhoan)-k);
      else XauSoSanh=glbThongTinClientGui[i]._TenTaiKhoan;
      if(StringCompare(Name,XauSoSanh)<0)
      {
         Vitri=i;break;
      }
   }
   return Vitri;
}
//+------------------------------------------------------------------+
ThongTinClientGui FunXuLyXauThongTinNhanDuocThanhStruct(string strCommand)
{
   //Print("Thong tin: ",strCommand);
   string KetQuaXuLyXau[];
   int k=StringSplit(strCommand,',',KetQuaXuLyXau);
   ThongTinClientGui StrThongTinNhanDuoc;
   if(k>0)
   {
      StringReplace(KetQuaXuLyXau[0]," ","");
      StringToUpper(KetQuaXuLyXau[0]);
      StrThongTinNhanDuoc._TenTaiKhoan=KetQuaXuLyXau[0];
      StrThongTinNhanDuoc._FundName=KetQuaXuLyXau[1];
      StrThongTinNhanDuoc._TenGroup=StringSubstr(KetQuaXuLyXau[2],0,5);
      StrThongTinNhanDuoc._IDTaiKhoan=(int)StringToInteger(KetQuaXuLyXau[3]);
      StrThongTinNhanDuoc._AccBalance=(KetQuaXuLyXau[4]);
      StrThongTinNhanDuoc._AccEquity=(KetQuaXuLyXau[5]);
      StrThongTinNhanDuoc._ProfitDongLenh=(KetQuaXuLyXau[6]);
      StrThongTinNhanDuoc._ProfitHienTai=(KetQuaXuLyXau[7]);
      StrThongTinNhanDuoc._Orders=KetQuaXuLyXau[8];
      StrThongTinNhanDuoc._TrangThai=KetQuaXuLyXau[9];
       if(k>11)
      {
         StrThongTinNhanDuoc._TongSoLotHomNayVao=StringToDouble(KetQuaXuLyXau[10]);
         StrThongTinNhanDuoc._TongSoNgayDaVaoLenh=(int)StringToInteger(KetQuaXuLyXau[11]);
         
      }
     

   }
   return StrThongTinNhanDuoc;
}
//+------------------------------------------------------------------+
void FunThietLapMauNenCuaChart(const long chart_ID=0)
{
    ChartSetInteger(chart_ID,CHART_COLOR_BACKGROUND,clrBlack);
    ChartSetInteger(chart_ID,CHART_COLOR_FOREGROUND,clrWhite);
    ChartSetInteger(chart_ID,CHART_COLOR_GRID,clrNONE);
    ChartSetInteger(chart_ID,CHART_COLOR_CHART_UP,clrNONE);
    ChartSetInteger(chart_ID,CHART_COLOR_CHART_DOWN,clrNONE);
    ChartSetInteger(chart_ID,CHART_COLOR_CHART_LINE,clrNONE);
    ChartSetInteger(chart_ID,CHART_COLOR_CANDLE_BULL,clrNONE);
    ChartSetInteger(chart_ID,CHART_COLOR_CANDLE_BEAR,clrNONE);
    ChartSetInteger(chart_ID,CHART_COLOR_BACKGROUND,clrNONE);
    ChartSetInteger(chart_ID,CHART_COLOR_VOLUME,clrNONE);
    ChartSetInteger(chart_ID,CHART_COLOR_BID,clrNONE);
    ChartSetInteger(chart_ID,CHART_COLOR_ASK,clrNONE);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void FunCreatTableHeader()
{
    // Creat header
    FunLabelCreate(0,"No",def_X_CoSo+5,def_Y_COSO,"No",clrWhite) ;
    FunLabelCreate(0,"Name",def_X_CoSo+def_RONG-10,def_Y_COSO,"Name",clrWhite) ;
    FunLabelCreate(0,"Server",(int)(def_X_CoSo+3.5*def_RONG),def_Y_COSO,"Server",clrLimeGreen) ;
    FunLabelCreate(0,"Accout",(int)(def_X_CoSo+5.4*def_RONG),def_Y_COSO,"Accout",clrWhite) ;
    FunLabelCreate(0,"Group",def_X_CoSo+7.8*def_RONG,def_Y_COSO,"Group",clrWhite) ;
    FunLabelCreate(0,"Day",def_X_CoSo+9*def_RONG,def_Y_COSO,"Day",clrWhite) ;
    FunLabelCreate(0,"Balance",def_X_CoSo+10*def_RONG,def_Y_COSO,"Balance",clrWhite) ;
    FunLabelCreate(0,"Equity",def_X_CoSo+12.2*def_RONG,def_Y_COSO,"Equity",clrWhite) ;
    FunLabelCreate(0,"ToDayProfit",def_X_CoSo+14.2*def_RONG,def_Y_COSO,"ToDayProfit",clrWhite) ;
    FunLabelCreate(0,"Profit",(int)(def_X_CoSo+16.6*def_RONG),def_Y_COSO,"Profit",clrWhite) ;
    FunLabelCreate(0,"Orders",(int)(def_X_CoSo+18.6*def_RONG),def_Y_COSO,"Orders",clrWhite) ;
    FunLabelCreate(0,"Status",def_X_CoSo+24*def_RONG,def_Y_COSO,"Status",clrWhite) ;
}
//+------------------------------------------------------------------+
string FunDoiTenGroupSangString(ENM_Group TenGroup)
{
   if(TenGroup==V1) return "V1";
   else if(TenGroup==V2) return "V2";
   else if(TenGroup==REAL) return "REAL";
   else return "ALL";
}
//+------------------------------------------------------------------+
void FunCreatRowOfTable(int idxRow)
{
    string RowName_No="No"+IntegerToString(idxRow);
    string RowName_Name="Name"+IntegerToString(idxRow);
    string RowName_Server="Server"+IntegerToString(idxRow);
    string RowName_Accout="Accout"+IntegerToString(idxRow);
    string RowName_Group="Group"+IntegerToString(idxRow);
    string RowName_Day="Day"+IntegerToString(idxRow);
    string RowName_Balance="Balance"+IntegerToString(idxRow);
    string RowName_Equity="Equity"+IntegerToString(idxRow);
    string RowName_ToDayProfit="ToDayProfit"+IntegerToString(idxRow);
    string RowName_Profit="Profit"+IntegerToString(idxRow);
    string RowName_Status="Status"+IntegerToString(idxRow);
    string RowName_Orders="Orders"+IntegerToString(idxRow);
    int Y_COSO=def_Y_COSO+(idxRow+1)*def_CAO;
    FunLabelCreate(0,RowName_No,def_X_CoSo+5,Y_COSO,IntegerToString(idxRow+1),clrWhite) ;
    FunLabelCreate(0,RowName_Name,def_X_CoSo+def_RONG-10,Y_COSO,glbThongTinClientGui[idxRow]._TenTaiKhoan,clrWhite) ;
    FunLabelCreate(0,RowName_Server,(int)(def_X_CoSo+3.5*def_RONG),Y_COSO,glbThongTinClientGui[idxRow]._FundName,clrWhite) ;
    FunLabelCreate(0,RowName_Accout,(int)(def_X_CoSo+5.4*def_RONG),Y_COSO,IntegerToString(glbThongTinClientGui[idxRow]._IDTaiKhoan),clrWhite) ;
    FunLabelCreate(0,RowName_Group,def_X_CoSo+7.8*def_RONG,Y_COSO,glbThongTinClientGui[idxRow]._TenGroup,clrYellow) ;
    
    FunLabelCreate(0,RowName_Day,def_X_CoSo+9*def_RONG,Y_COSO,IntegerToString(glbThongTinClientGui[idxRow]._TongSoNgayDaVaoLenh),clrRed) ;
    if(glbThongTinClientGui[idxRow]._TongSoLotHomNayVao>0)
      FunLabelChangeColor(0,RowName_Day,C'8,241,8');

    FunLabelCreate(0,RowName_Balance,def_X_CoSo+10*def_RONG,Y_COSO,(glbThongTinClientGui[idxRow]._AccBalance),clrWhite) ;
    
    FunLabelCreate(0,RowName_Equity,def_X_CoSo+12.2*def_RONG,Y_COSO,(glbThongTinClientGui[idxRow]._AccEquity),clrWhite) ;
    
    FunLabelCreate(0,RowName_ToDayProfit,def_X_CoSo+14.2*def_RONG,Y_COSO,(glbThongTinClientGui[idxRow]._ProfitDongLenh),clrLimeGreen) ;
    if(StringToDouble(glbThongTinClientGui[idxRow]._ProfitDongLenh)<0)
        FunLabelChangeColor(0,RowName_ToDayProfit,clrRed);
    else if(StringToDouble(glbThongTinClientGui[idxRow]._ProfitDongLenh)==0)
        FunLabelChangeColor(0,RowName_ToDayProfit,clrWhite);
    
    
    FunLabelCreate(0,RowName_Profit,def_X_CoSo+(int)(16.6*def_RONG),Y_COSO,(glbThongTinClientGui[idxRow]._ProfitHienTai),clrLimeGreen) ;
    if(StringToDouble(glbThongTinClientGui[idxRow]._ProfitHienTai)<0)
        FunLabelChangeColor(0,RowName_Profit,clrRed);
    else if(StringToDouble(glbThongTinClientGui[idxRow]._ProfitHienTai)==0)
        FunLabelChangeColor(0,RowName_Profit,clrWhite); 

    FunLabelCreate(0,RowName_Orders,def_X_CoSo+(int)(18.6*def_RONG),Y_COSO,(glbThongTinClientGui[idxRow]._Orders),clrWhite) ;
    FunLabelCreate(0,RowName_Status,def_X_CoSo+24*def_RONG,Y_COSO,(glbThongTinClientGui[idxRow]._TrangThai),clrLimeGreen) ;
    if(glbThongTinClientGui[idxRow]._TrangThai=="Deactive")
        FunLabelChangeColor(0,RowName_Status,clrRed);
}
//+------------------------------------------------------------------+
void FunRemoveRowOfTable (int idxRow)
{
   string RowName_No="No"+IntegerToString(idxRow);
   string RowName_Name="Name"+IntegerToString(idxRow);
   string RowName_Server="Server"+IntegerToString(idxRow);
   string RowName_Accout="Accout"+IntegerToString(idxRow);
   string RowName_Group="Group"+IntegerToString(idxRow);
   string RowName_Day="Day"+IntegerToString(idxRow);
   string RowName_Balance="Balance"+IntegerToString(idxRow);
   string RowName_Equity="Equity"+IntegerToString(idxRow);
   string RowName_ToDayProfit="ToDayProfit"+IntegerToString(idxRow);
   string RowName_Profit="Profit"+IntegerToString(idxRow);
   string RowName_Status="Status"+IntegerToString(idxRow);
   string RowName_Orders="Orders"+IntegerToString(idxRow);
   FunLabelDelete(0,RowName_No);
   FunLabelDelete(0,RowName_Name);
   FunLabelDelete(0,RowName_Server);
   FunLabelDelete(0,RowName_Accout);
   FunLabelDelete(0,RowName_Group);
   FunLabelDelete(0,RowName_Day);
   FunLabelDelete(0,RowName_Balance);
   FunLabelDelete(0,RowName_Equity);
   FunLabelDelete(0,RowName_ToDayProfit);
   FunLabelDelete(0,RowName_Profit);
   FunLabelDelete(0,RowName_Status);
   FunLabelDelete(0,RowName_Orders);
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
                 const int               font_size=11,             // font size
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

void OnChartEvent(const int id,const long &lparam,const double& dparam,const string& sparam)
{
   if(id==CHARTEVENT_KEYDOWN)
   {
      if((int)lparam==KEY_R)
      {
         for(int i=0;i<glbTongSoRowClient; i++)
            FunRemoveRowOfTable(i);
         glbTongSoRowClient=0;
         if (glbClientSocketManager) {
         delete glbClientSocketManager;
         glbClientSocketManager = NULL;
   }
      }
   }
}

