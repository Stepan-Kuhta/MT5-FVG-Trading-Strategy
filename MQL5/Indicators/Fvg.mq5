//+------------------------------------------------------------------+
//|                                                          Fvg.mq5 |
//|                                         Copyright 2024, rpanchyk |
//|                                      https://github.com/rpanchyk |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2024, rpanchyk"
#property link        "https://github.com/rpanchyk"
#property version     "1.03"
#property description "Indicator shows fair value gaps"

#property indicator_chart_window
#property indicator_plots 3
#property indicator_buffers 3

// types
enum ENUM_BORDER_STYLE
  {
   BORDER_STYLE_SOLID = STYLE_SOLID, // Solid
   BORDER_STYLE_DASH = STYLE_DASH // Dash
  };

// buffers
double FvgHighPriceBuffer[]; // Higher price of FVG
double FvgLowPriceBuffer[]; // Lower price of FVG
double FvgTrendBuffer[]; // Trend of FVG [0: NO, -1: DOWN, 1: UP]

// config
input group "Section :: Main";
input bool InpContinueToMitigation = true; // Continue to mitigation

input group "Section :: Style";
input color InpDownTrendColor = clrLightPink; // Down trend color
input color InpUpTrendColor = clrLightGreen; // Up trend color
input bool InpFill = true; // Fill solid (true) or transparent (false)
input ENUM_BORDER_STYLE InpBoderStyle = BORDER_STYLE_SOLID; // Border line style
input int InpBorderWidth = 2; // Border line width

input group "Section :: Dev";
input bool InpDebugEnabled = false; // Enable debug (verbose logging)

// constants
const string OBJECT_PREFIX = "FVG";
const string OBJECT_PREFIX_CONTINUATED = OBJECT_PREFIX + "CNT";
const string OBJECT_SEP = "#";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpDebugEnabled)
     {
      Print("Fvg indicator initialization started");
     }

   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   ArrayInitialize(FvgHighPriceBuffer, EMPTY_VALUE);
   ArraySetAsSeries(FvgHighPriceBuffer, true);
   SetIndexBuffer(0, FvgHighPriceBuffer, INDICATOR_DATA);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetString(0, PLOT_LABEL, "Fvg High");
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);

   ArrayInitialize(FvgLowPriceBuffer, EMPTY_VALUE);
   ArraySetAsSeries(FvgLowPriceBuffer, true);
   SetIndexBuffer(1, FvgLowPriceBuffer, INDICATOR_DATA);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetString(1, PLOT_LABEL, "Fvg Low");
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);

   ArrayInitialize(FvgTrendBuffer, EMPTY_VALUE);
   ArraySetAsSeries(FvgTrendBuffer, true);
   SetIndexBuffer(2, FvgTrendBuffer, INDICATOR_DATA);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetString(2, PLOT_LABEL, "Fvg Trend");
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);

   if(InpDebugEnabled)
     {
      Print("Fvg indicator initialization finished");
     }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(InpDebugEnabled)
     {
      Print("Fvg indicator deinitialization started");
     }

   ArrayFill(FvgHighPriceBuffer, 0, ArraySize(FvgHighPriceBuffer), EMPTY_VALUE);
   ArrayResize(FvgHighPriceBuffer, 0);
   ArrayFree(FvgHighPriceBuffer);

   ArrayFill(FvgLowPriceBuffer, 0, ArraySize(FvgLowPriceBuffer), EMPTY_VALUE);
   ArrayResize(FvgLowPriceBuffer, 0);
   ArrayFree(FvgLowPriceBuffer);

   ArrayFill(FvgTrendBuffer, 0, ArraySize(FvgTrendBuffer), EMPTY_VALUE);
   ArrayResize(FvgTrendBuffer, 0);
   ArrayFree(FvgTrendBuffer);

   if(!MQLInfoInteger(MQL_TESTER))
     {
      ObjectsDeleteAll(0, OBJECT_PREFIX);
     }

   if(InpDebugEnabled)
     {
      Print("Fvg indicator deinitialization finished");
     }
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
   if(rates_total == prev_calculated)
     {
      return rates_total;
     }

   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);

   if(InpContinueToMitigation)
     {
      int total = ObjectsTotal(0, 0, OBJ_RECTANGLE);
      for(int i = 0; i < total; i++)
        {
         string objName = ObjectName(0, i, 0, OBJ_RECTANGLE);
         if(StringFind(objName, OBJECT_PREFIX_CONTINUATED) == 0)
           {
            string result[];
            StringSplit(objName, StringGetCharacter(OBJECT_SEP, 0), result);

            datetime leftTime = StringToTime(result[1]);
            double leftPrice = StringToDouble(result[2]);
            datetime rightTime = time[0];
            double rightPrice = StringToDouble(result[4]);

            if(rightPrice < high[1] && rightPrice > low[1])
              {
               rightTime = time[1];
               if(ObjectDelete(0, objName))
                 {
                  DrawBox(leftTime, leftPrice, rightTime, rightPrice, false);
                 }
              }
            else
              {
               ObjectMove(0, objName, 1, rightTime, rightPrice);
               if(InpDebugEnabled)
                 {
                  PrintFormat("Expand box %s", objName);
                 }
              }
           }
        }
     }

   int limit = prev_calculated == 0 ? rates_total - 3 : rates_total - prev_calculated + 1;
   if(InpDebugEnabled)
     {
      PrintFormat("RatesTotal: %i, PrevCalculated: %i, Limit: %i", rates_total, prev_calculated, limit);
     }

   for(int i = 1; i < limit; i++)
     {
      double rightHighPrice = high[i];
      double rightLowPrice = low[i];
      double midHighPrice = high[i + 1];
      double midLowPrice = low[i + 1];
      double leftHighPrice = high[i + 2];
      double leftLowPrice = low[i + 2];

      datetime rightTime = time[i];
      datetime leftTime = time[i + 2];

      // Up trend
      bool upLeft = midLowPrice <= leftHighPrice && midLowPrice > leftLowPrice;
      bool upRight = midHighPrice >= rightLowPrice && midHighPrice < rightHighPrice;
      bool upGap = leftHighPrice < rightLowPrice;
      if(upLeft && upRight && upGap)
        {
         SetBuffers(i + 1, rightLowPrice, leftHighPrice, 1);

         if(InpContinueToMitigation)
           {
            rightTime = time[0];
            for(int j = i - 1; j > 0; j--) // Search mitigation bar
              {
               if((rightLowPrice < high[j] && rightLowPrice >= low[j]) || (leftHighPrice > low[j] && leftHighPrice <= high[j]))
                 {
                  rightTime = time[j];
                  break;
                 }
              }
           }

         DrawBox(leftTime, leftHighPrice, rightTime, rightLowPrice, InpContinueToMitigation && rightTime == time[0]);

         continue;
        }

      // Down trend
      bool downLeft = midHighPrice >= leftLowPrice && midHighPrice < leftHighPrice;
      bool downRight = midLowPrice <= rightHighPrice && midLowPrice > rightLowPrice;
      bool downGap = leftLowPrice > rightHighPrice;
      if(downLeft && downRight && downGap)
        {
         SetBuffers(i + 1, leftLowPrice, rightHighPrice, -1);

         if(InpContinueToMitigation)
           {
            rightTime = time[0];
            for(int j = i - 1; j > 0; j--) // Search mitigation bar
              {
               if((rightHighPrice <= high[j] && rightHighPrice > low[j]) || (leftLowPrice >= low[j] && leftLowPrice < high[j]))
                 {
                  rightTime = time[j];
                  break;
                 }
              }
           }

         DrawBox(leftTime, leftLowPrice, rightTime, rightHighPrice, InpContinueToMitigation && rightTime == time[0]);

         continue;
        }

      // Fvg not detected, set empty values to buffers
      SetBuffers(i + 1, 0, 0, 0);
     }

   return rates_total; // Set prev_calculated on next call
  }

//+------------------------------------------------------------------+
//| Updates buffers with indicator data                              |
//+------------------------------------------------------------------+
void SetBuffers(int index, double highPrice, double lowPrice, double trend)
  {
   FvgHighPriceBuffer[index] = highPrice;
   FvgLowPriceBuffer[index] = lowPrice;
   FvgTrendBuffer[index] = trend;

   if(InpDebugEnabled && trend != 0)
     {
      PrintFormat("Time: %s, FvgTrendBuffer: %f, FvgHighPriceBuffer: %f, FvgLowPriceBuffer: %f",
                  TimeToString(iTime(_Symbol, PERIOD_CURRENT, index)), FvgTrendBuffer[index],
                  FvgHighPriceBuffer[index], FvgLowPriceBuffer[index]);
     }
  }

//+------------------------------------------------------------------+
//| Draws FVG box                                                    |
//+------------------------------------------------------------------+
void DrawBox(datetime leftDt, double leftPrice, datetime rightDt, double rightPrice, bool continuated)
  {
   string objName = (continuated ? OBJECT_PREFIX_CONTINUATED : OBJECT_PREFIX)
                    + OBJECT_SEP
                    + TimeToString(leftDt)
                    + OBJECT_SEP
                    + DoubleToString(leftPrice)
                    + OBJECT_SEP
                    + TimeToString(rightDt)
                    + OBJECT_SEP
                    + DoubleToString(rightPrice);

   if(ObjectFind(0, objName) < 0)
     {
      ObjectCreate(0, objName, OBJ_RECTANGLE, 0, leftDt, leftPrice, rightDt, rightPrice);

      ObjectSetInteger(0, objName, OBJPROP_COLOR, leftPrice < rightPrice ? InpUpTrendColor : InpDownTrendColor);
      ObjectSetInteger(0, objName, OBJPROP_FILL, InpFill);
      ObjectSetInteger(0, objName, OBJPROP_STYLE, InpBoderStyle);
      ObjectSetInteger(0, objName, OBJPROP_WIDTH, InpBorderWidth);
      ObjectSetInteger(0, objName, OBJPROP_BACK, true);
      ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, objName, OBJPROP_SELECTED, false);
      ObjectSetInteger(0, objName, OBJPROP_HIDDEN, false);
      ObjectSetInteger(0, objName, OBJPROP_ZORDER, 0);

      if(InpDebugEnabled)
        {
         PrintFormat("Draw box: %s", objName);
        }
     }
  }
//+------------------------------------------------------------------+
