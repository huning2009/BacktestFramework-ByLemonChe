function StockAccount = StockTradeModule(StockAccount,Params) 

% ȷ�������ڹ�Ʊ���ֵ��ܽ��
StockAccount.CashBeforeTrading = Params.StockAccount.FuncToCalUseableCash(StockAccount,Params);
% ȷ������Ʊ�ֲ�����
StockAccount.StockNeedingTrade = Params.StockAccount.FuncToCalTradeLots(StockAccount);
% ���ɹ�Ʊ������ˮ
[StockAccount.TradeTable, StockAccount.HoldingTable] = GenerateTradeTable(StockAccount.StockNeedingTrade(:,{'TradeDays','StockCode','FuquanTradePrice','TradeLots'}),'stock');
