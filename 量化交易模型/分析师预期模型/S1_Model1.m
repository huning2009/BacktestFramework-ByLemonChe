% ����model
function model = S1_Model1()

% ����ģ�Ͳ���
model.Params = ParamsTemplet();

model.Params.StartDate = 20090101;
model.Params.EndDate = 20181019;

% ���й�Ʊ���ֽ��ײ����Ľ����յ�����
model.Params.TradeFrequency = 5;
model.Params.TradeDays = GenerateTradeDays(model.Params);

% ���ز����������
% ��ȡ��ֵ�͹�Ʊ��飬�޳����̴��ǳ���9%
model.Factor = ProcessedFactor(@AnalystPredicateFactor,{180,2},@DropFactorThatRiseTooFast,{0.09},@GetPriceForFactor,{},@GetShareForFactor,{},@SplitStockPlate,{});
model.Factor.MarketValue = model.Factor.Open.*model.Factor.FloatAShare;

model.Factor.TargetProfitRate = model.Factor.FuquanTargetPriceOverAll./(model.Factor.Adj.*model.Factor.Open);

% ��ȡ���ֽ��������з�Χ�ڵ���������
[~,suffix,~] = My_intersect(model.Factor.TradeDays,model.Params.TradeDays);
model.Factor = model.Factor(suffix,:);

% �޳�ST��Ʊ
model.Factor = DropFactorWhichST(model.Factor);

end
