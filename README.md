# MT5 Fair Value Gap (FVG) Trading Strategy

[![MQL5](https://img.shields.io/badge/MQL5-Expert_Advisor-blue)](https://www.mql5.com)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

Профессиональная реализация стратегии торговли по Fair Value Gaps для MetaTrader 5.

## 📌 Особенности стратегии
- Торговля по FVG (Fair Value Gap)
- Маркет-ордера при обнаружении паттерна
- Stop Loss +15 пипсов от границы FVG
- Take Profit 2:1 Risk-Reward
- Ограничение количества сделок в день

## Установка
1. Скопируйте файлы в соответствующие папки MT5:
   - `Experts/ImbalanceEA.mq5` → `<MT5>/MQL5/Experts/`
   - `Indicators/Fvg.mq5` → `<MT5>/MQL5/Indicators/`
2. Перезапустите MetaTrader 5
3. Настройте параметры советника в терминале

## Параметры
```mql5
input double LotSize = 0.1;          // Размер лота
input int MaxTradesPerDay = 2;       // Макс. сделок в день
input double SL_BufferPips = 15.0;   // Буфер для SL (пипсы)
input double RR = 2.0;               // Risk-Reward ratio
```

## Теория
Fair Value Gap (FVG) - это ценовой разрыв, образующийся когда:
1. Средняя свеча полностью поглощается соседними
2. Между high/low соседних свечей образуется разрыв

## Как помочь проекту
- Сообщайте о баках в Issues
- Предлагайте улучшения через Pull Requests
- Делитесь результатами тестов
