//+------------------------------------------------------------------+
//|                                                   MACDRSIADI.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|Expert strategy:                                                  |
//|    When MACD trade signal happen, chekc RSI, and STO status      |
//|    When STO trade signal happen, check RSI and MACD              |
//|    Always create Trailing stop together.                         |
//+------------------------------------------------------------------+



#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//--- input parameters
input double   TakeProfit=120.0;
input double   Lots=0.1;
input double   TrailingStop=20.0;
input double   StopLoss = 70.0;
input int      MaxOpenPosition = 1;
input double   MACDOpenLevel=3.0;
input double   MACDCloseLevel=2.0;
input int      MATrendPeriod=26;
input int      MASmaPeriod=9;
input int      MAFastEMAPeriod=12;
input int      MAShort = 10;
input int      MAMid = 20;
input int      MALong = 50;
input int      RSIPeriod=14;
input int      ADIPeriod=14;
input int      KPeriod = 5;
input int      DPeriod = 3;
input int      JPeriod = 3;
input int      PowerPeriod = 13;
input int      DDBTimeFrame = PERIOD_D1;
input int      INDICATORTimeFrame = PERIOD_D1;
input int      INDICATORPeriod = 5;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
      
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   // Cannot use variable to define the array size.    
   double Macd[5],MacdSignal[5], MacdHist[5];
   double Ma10[5], Ma20[5],Ma50[5];
   double RSI[5], ADI[5], STO_K[5], BullPower[5], BearPower[5];
   double Band1Upper[5], Band1Lower[5], Band2Upper[5], Band2Lower[5];

   //double StoBasePrevious, StoSignalPrevious;
   int    cnt,ticket,total;
   double recommendation = 0.0 , indicator = 0;
   
  
   if(Bars<100)
     {
      Print("bars less than 100");
      return;
     }
   if(TakeProfit<10)
     {
      Print("TakeProfit less than 10");
      return;
     }
     
   //Print("Start check trading condition");  
   
   for(int i=0;i< INDICATORPeriod;i++)
     {
         Macd[i] = iMACD(NULL,INDICATORTimeFrame,12,26,9,PRICE_CLOSE,MODE_MAIN,i);
         MacdSignal[i] = iMACD(NULL,INDICATORTimeFrame,12,26,9,PRICE_CLOSE,MODE_SIGNAL,i);
         MacdHist[i] = Macd[i] - MacdSignal[i];
         Ma10[i]=iMA(NULL,INDICATORTimeFrame,MAShort,0,MODE_SMA,PRICE_CLOSE,i);   
         Ma20[i]=iMA(NULL,INDICATORTimeFrame,MAMid,0,MODE_SMA,PRICE_CLOSE,i);
         Ma50[i]=iMA(NULL,INDICATORTimeFrame,MALong,0,MODE_SMA,PRICE_CLOSE,i);   
         RSI[i] = iRSI(NULL, INDICATORTimeFrame, RSIPeriod, PRICE_CLOSE, i);
         ADI[i] = iADX(NULL, INDICATORTimeFrame, ADIPeriod, PRICE_CLOSE, 0, i);
         STO_K[i] = iStochastic(NULL, INDICATORTimeFrame, 5, 3, 3, MODE_SMA, 1, MODE_MAIN, i);
         BullPower[i] = iBullsPower(NULL, INDICATORTimeFrame, PowerPeriod, PRICE_CLOSE, i);
         BearPower[i] = iBearsPower(NULL, INDICATORTimeFrame, PowerPeriod, PRICE_CLOSE, i);
         Band1Lower[i] = iBands(NULL,DDBTimeFrame,20, 1,0,PRICE_CLOSE,MODE_LOWER,i);
         Band1Upper[i] = iBands(NULL,DDBTimeFrame,20, 1,0,PRICE_CLOSE,MODE_UPPER,i);
         Band2Lower[i] = iBands(NULL,DDBTimeFrame,20, 2,0,PRICE_CLOSE,MODE_LOWER,i);
         Band2Upper[i] = iBands(NULL,DDBTimeFrame,20, 2,0,PRICE_CLOSE,MODE_UPPER,i); 
     }
     

   bool longconfident = LongConfident(RSI[0], ADI[0], STO_K[0], Ma10[0], Ma20[0],Ma50[0], Macd[0], MacdSignal[0]);
   bool shortconfident = ShortConfident(RSI[0], ADI[0], STO_K[0], Ma10[0], Ma20[0],Ma50[0], Macd[0], MacdSignal[0]);  
   total=OrdersTotal();
   
      if(total<MaxOpenPosition)
     {
      //--- no opened orders identified
      if(AccountFreeMargin()<(1000*Lots))
        {
         Print("We have no money. Free Margin = ",AccountFreeMargin());
         return;
        }
      
      //--- Calculation the recommendation ---
      
      //--- check for long position (BUY) possibility
      //if(MacdCurrent<0 && MacdCurrent>SignalCurrent && MacdPrevious<SignalPrevious && 
      //   MathAbs(MacdCurrent)>(MACDOpenLevel*Point) && MaCurrent>MaPrevious)            
      if (toLong(Band1Upper[0],Band1Upper[1], Band1Upper[2],Band2Upper[0],Band2Upper[1],Band2Upper[2],longconfident))
        {
         Print("RSI is ", RSI[0]);
         Print("ADI is ", ADI[0]);
         Print("K is " , STO_K[0]);
         Print("MACDHist is ", MacdHist[0]);
         Print("MACD is ", Macd[0]);
         Print("MA 10 is ", Ma10[0]);
         Print("MA 20 is ", Ma20[0]);
         Print("MA 50 is ", Ma50[0]);
         Print("Bull power is ", BullPower[0]);
         Print("Bear Power is ", BearPower[0]);
         
         
         double sl = MathMax(iLow(NULL,0,2), Ask - StopLoss * Point);
         ticket=OrderSend(Symbol(),OP_BUY,Lots, Ask, 3.0, sl ,Ask+TakeProfit*Point,"macd sample",16384,0,Green);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
               Print("BUY order opened : ",OrderOpenPrice());
           }
         else
            Print("Error opening BUY order : ",GetLastError());
         return;
        }
      //--- check for short position (SELL) possibility
      //if(MacdCurrent>0 && MacdCurrent<SignalCurrent && MacdPrevious>SignalPrevious && 
      //   MacdCurrent>(MACDOpenLevel*Point) && MaCurrent<MaPrevious)
      if(toShort(Band1Lower[0],Band1Lower[1], Band1Lower[2],Band2Lower[0],Band2Lower[1],Band2Lower[2], shortconfident))  // Conservative when Short
        {
         double sl = MathMin(Band1Lower[2], Bid + StopLoss * Point * 0.5);
         ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3.0,sl, Bid-TakeProfit*Point*0.5,"macd sample",16384,0,Red);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
               Print("SELL order opened : ",OrderOpenPrice());
           }
         else
            Print("Error opening SELL order : ",GetLastError());
        }
      //--- exit from the "no opened orders" block
      return;
     }


//--- it is important to enter the market correctly, but it is more important to exit it correctly...   
   for(cnt=0;cnt<total;cnt++)
     {
      if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderType()<=OP_SELL &&   // check for opened position 
         OrderSymbol()==Symbol())  // check for symbol
        {
         //--- long position is opened
         if(OrderType()==OP_BUY)
           {
            //--- should it be closed?
            //if(MacdCurrent>0 && MacdCurrent<SignalCurrent && MacdPrevious>SignalPrevious && 
            //   MacdCurrent>(MACDCloseLevel*Point))
            
            if(toShort(Band1Lower[0],Band1Lower[1], Band1Lower[2],Band2Lower[0],Band2Lower[1],Band2Lower[2], longconfident))
              {
               //--- close order and exit
               if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet))
                  Print("OrderClose error ",GetLastError());
               return;
              }
            //--- check for trailing stop
            if(TrailingStop>0)
              {
               if(Bid-OrderOpenPrice()>Point*TrailingStop)
                 {
                  if(OrderStopLoss()<Bid-Point*TrailingStop)
                    {
                     //--- modify order and exit
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green))
                        Print("OrderModify error ",GetLastError());
                     return;
                    }
                 }
              }
           }
         else // go to short position
           {
            //--- should it be closed?
            //if(MacdCurrent<0 && MacdCurrent>SignalCurrent && 
            //   MacdPrevious<SignalPrevious && MathAbs(MacdCurrent)>(MACDCloseLevel*Point))
            if (toLong(Band1Upper[0],Band1Upper[1], Band1Upper[2],Band2Upper[0],Band2Upper[1],Band2Upper[2],longconfident))            
              {
               //--- close order and exit
               if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet))
                  Print("OrderClose error ",GetLastError());
               return;
              }
            //--- check for trailing stop
            if(TrailingStop>0)
              {
               if((OrderOpenPrice()-Ask)>(Point*TrailingStop))
                 {
                  if((OrderStopLoss()>(Ask+Point*TrailingStop)) || (OrderStopLoss()==0))
                    {
                     //--- modify order and exit
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red))
                        Print("OrderModify error ",GetLastError());
                     return;
                    }
                 }
              }
           }
        }
     }   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Calculate Recommendation                                              |
//+------------------------------------------------------------------+


bool RSI_buy(double rsi){
   return (rsi < 70);
   //return true;
}

bool RSI_sell(double rsi){
   return (rsi > 80);
   //return false;
}

bool Macd_buy(double macd, double macdsignal){
   return MathAbs(macd)>(MACDOpenLevel*Point) && macd > macdsignal;
}

bool Macd_sell(double macd, double macdsignal){
   return macd < macdsignal;
}

bool Ma_buy(double ma1, double ma2){
   return ma1>ma2;
}

bool Ma_sell(double ma1, double ma2){
   return ma1<ma2;   
}

bool ADI_buy(double adi){
   return ( adi > 25 && adi <36);
   //return true;
}

bool ADI_sell(double adi){
   return (adi < 20 || adi > 45);   
}

bool STO_buy(double sto){
   return ( sto < 80);
   //return true;
}

bool STO_sell(double sto){
   return (sto > 90);
   //return false;
}


bool LongConfident(double rsi, double adi, double sto, double mashort , double mamid, double malong, double macd, double macdsignal) {
   
   return RSI_buy(rsi) && ADI_buy(adi) && STO_buy(sto) && Ma_buy(mashort, mamid) && Ma_buy(mamid, malong) && Macd_buy(macd, macdsignal);

}

bool ShortConfident(double rsi, double adi, double sto, double mashort, double mamid, double malong, double macd, double macdsignal){
   return RSI_sell(rsi) && ADI_sell(adi) && STO_sell(sto) && Ma_sell(mashort, mamid) && Ma_sell(mamid, malong) && Macd_sell(macd, macdsignal);
}

bool toLong(double b1h_0, double b1h_1, double b1h_2, double b2h_0, double b2h_1, double b2h_2, bool confident){   
   return (iClose(NULL,DDBTimeFrame,2) <= b1h_2 && iClose(NULL,DDBTimeFrame,1) > b1h_1 && (iClose(NULL,DDBTimeFrame,0) - b1h_0 >= 10 * Point) && 
           iClose(NULL,DDBTimeFrame,1) < b2h_1 && iClose(NULL,DDBTimeFrame,0) < b2h_0  && 
           confident);       
}

bool toShort(double b1l_0, double b1l_1, double b1l_2, double b2l_0, double b2l_1, double b2l_2, bool confident){
   return (iClose(NULL,DDBTimeFrame,2) >= b1l_2 && iClose(NULL,DDBTimeFrame,1) < b1l_1 && (b1l_0 - iClose(NULL,DDBTimeFrame,0)>= 10 * Point) && 
           iClose(NULL,DDBTimeFrame,1) > b2l_1 && iClose(NULL,DDBTimeFrame,0) > b2l_0 &&   
           confident);   
}