function StockNeedingTrade = CalTradeLotsForStock_StockEqual(StockAccount)
% �����Ʊ�˻��ֲ�����
% ��Ȩ�����ʽ�

% Ĭ�ϳֲ�����Ϊ0
StockNeedingTrade = StockAccount.StockNeedingTrade;
StockNeedingTrade{:,'TradeLots'} = 0;
% ÿ��������
for i=1:length(StockAccount.TradeDays)
    CashBeforeTrading = StockAccount.CashBeforeTrading(i);
    suoyin = (StockNeedingTrade.TradeDays==StockAccount.TradeDays(i))&(StockNeedingTrade.IsHold==1);
    StockNum = sum(StockNeedingTrade{suoyin,'IsHold'});
    StockNeedingTrade{suoyin,'TradeLots'} = floor((CashBeforeTrading/StockNum)./StockNeedingTrade{suoyin,'FuquanTradePrice'});
    disp(['�����Ʊ�ֲ�����:',num2str(StockAccount.TradeDays(i))])
end
