% ����ͼ
function Output = My_candle(StockData)
% StockData table����
% ���뺬�е��ֶ����� DateTime OPEN CLOSE HIGH LOW

Dates = datenum(num2str(StockData.DateTime),'yyyymmdd');
candle(StockData.HIGH,StockData.LOW,StockData.CLOSE,StockData.OPEN,'b',Dates)
