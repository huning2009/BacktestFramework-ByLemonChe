% ����model
function model = ESOP_Model()

% ����ģ�Ͳ���
model.Params = ParamsTemplet();
model.Params.StartDate = 20180723;
model.Params.EndDate = 20180926;
model.Params.TradeFrequency = 1;
model.Params.HoldingDays = 50;
model.Params.IsEventsDriven = true;

model.Params.StockAccount.FuncToCalUseableCash = @CalAvailableCashForStock_EuqalToInitCash_Adj;

% ���ز����������
Factor = ESOPSignal();

% ����ɸѡ
% ֻѡ�� ����ת��
suoyin = cellfun(@(x)contains(x,'����ת��'),Factor.stock_source,'UniformOutput',false);
Factor = Factor(cell2mat(suoyin),:);

% �ɱ���������2% ���� Ա���ֲ���ֵ����50��
Factor = FactorSelector2(Factor,'shares_ratio',[0.02,inf]);
% Factor = FactorSelector2(Factor,'mkt_cap',[-inf,50]*10^8);

% ��ǰ��mode.Params.HoldingDays���Ա���ֹɼƻ���ҲҪ����
ForethDays = MoveDays(model.Params.StartDate,model.Params.HoldingDays,'Before',model.Params.WindTdays);
suoyin = Factor.TradeDays>=ForethDays&Factor.TradeDays<model.Params.StartDate;
Factor.TradeDays(suoyin) = model.Params.StartDate;

model.Factor = Factor(Factor.TradeDays>=model.Params.StartDate,:);

end
