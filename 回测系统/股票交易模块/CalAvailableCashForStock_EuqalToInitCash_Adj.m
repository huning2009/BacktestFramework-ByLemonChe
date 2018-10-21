function [CashBeforeTrading,StockNum] = CalAvailableCashForStock_EuqalToInitCash_Adj(StockAccount,Params)
% ÿ���������ڿ������ڹ�Ʊ�˻����ֵ��ֽ�Ϊ��ʼ�ʽ�
% ����ǰ�ֲֹ�Ʊ��������ָ���Ĺ�Ʊ����ʱ�����������ֲ���
[Gi,StockNum] = group(StockAccount.StockNeedingTrade(StockAccount.StockNeedingTrade.IsHold==1,:),'TradeDays',@length,'StockCode');
StockNum = fillTimeSeries([cell2mat(Gi),StockNum],StockAccount.TradeDays,0);    % ���ĳ�첻�ֲ֣���StockNum����Ϊ0

CashBeforeTrading = min(StockNum(:,2),Params.StockAccount.LeastStockNum)./Params.StockAccount.LeastStockNum*Params.StockAccount.InitCash;
end