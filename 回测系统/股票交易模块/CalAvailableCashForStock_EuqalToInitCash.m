function CashBeforeTrading = CalAvailableCashForStock_EuqalToInitCash(StockAccount,Params)
% ÿ���������ڿ������ڹ�Ʊ�˻����ֵ��ֽ�Ϊ��ʼ�ʽ�
CashBeforeTrading = ones(size(StockAccount.TradeDays))*Params.StockAccount.InitCash;

end