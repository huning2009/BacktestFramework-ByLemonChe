% ��ʼ�ز�
function model = BacktestStart(model)

disp('��������ģ��')
disp(model.Params)

% ��������Ԥ����
Backtest.StockAccount = PreprocessModule(model.Factor,model.Params);
% ��Ʊ�˻�����
Backtest.StockAccount = StockTradeModule(Backtest.StockAccount,model.Params);
% �����Ʊ�˻�PNL
[Backtest.StockAccount.Tdays,Backtest.StockAccount.PNL,Backtest.StockAccount.DetailInformation] = GetPNL(Backtest.StockAccount.TradeTable,model.Params);

% �Գ�
if model.Params.HedgeAccount.IsHedge
    disp('���жԳ�')
    % �Գ��˻�����
    [Backtest.HedgeAccount.TradeTable,Backtest.HedgeAccount.ChiCangTable,Backtest.HedgeAccount.HedgeTable] = DynamicHedgeModule(Backtest.StockAccount.StockNeedingTrade,model.Params);
    % ����Գ��˻�PNL
    [Backtest.HedgeAccount.Tdays,Backtest.HedgeAccount.PNL,Backtest.HedgeAccount.DetailInformation] = GetPNL(Backtest.HedgeAccount.TradeTable,model.Params);
    PNL = Backtest.StockAccount.PNL + Backtest.HedgeAccount.PNL;
else
    PNL = Backtest.StockAccount.PNL;
end

Backtest.Tdays = Backtest.StockAccount.Tdays;
Backtest.PNL = PNL;
model.Backtest = Backtest;