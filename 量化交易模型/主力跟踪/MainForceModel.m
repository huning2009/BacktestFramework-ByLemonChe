function model = MainForceModel()

model.Params = ParamsTemplet();
model.Params.TradeFrequency = 1;
model.Params.StartDate = 20180101;        % �ز⿪ʼʱ��
model.Params.EndDate = 20181012;    % �ز����ʱ��

model.Params.IsEventsDriven = 1;    % ʱ������

model.Factor = ProcessedFactor(@MainForceTrace,{20},@DropFactorThatRiseTooFast,{0.09},@GetPriceForFactor,{},@GetShareForFactor,{},...
    @DropFactorWhichNew,{250});
model.Factor.MarketValue = model.Factor.Open.*model.Factor.FloatAShare;

model.Factor = model.Factor(model.Factor.TradeDays>=model.Params.StartDate&model.Factor.TradeDays<=model.Params.EndDate,:);

% �޳�ST
model.Factor = DropFactorWhichST(model.Factor);

% �޳����첻�ܹ����׵����ӣ�����״̬��Ϊ�����ס�
model.Factor = CircleAccordingStockCodes(unique(model.Factor.StockCode),@DropFactorWhichCannotTrade);
function Output = DropFactorWhichCannotTrade(StockCode)
    Factor = model.Factor(strcmp(model.Factor.StockCode,StockCode),:);
    stockdata = GetStockDailyData(model.Params.DataPath.StockDailyData,StockCode,'TRADE_STATUS',num2cell(Factor.TradeDays));
    Output = Factor(strcmp(stockdata.TRADE_STATUS,'����'),:);
end

end