function HedgeTable = RegressBtwSingleStockAndMultiIndex(StocksNeedingTrade,FuncParams,Params)

WindowLength = FuncParams{1};
IndexPool = FuncParams{2};
HedgeMethod = FuncParams{3};
Alpha = FuncParams{4};

% ��ʼ��HedgeTable
HedgeTable = array2table(zeros(1,4));
HedgeTable.Properties.VariableNames = {'TradeDays','StockCode','HedgeCode','Proportion'};
HedgeTable(1,:) = [];
% 
WindTdays = importdata(Params.WindTdaysData);
TradeDays = unique(StocksNeedingTrade.TradeDays);
StartDate = MoveDays(TradeDays(1),WindowLength,'Before',WindTdays);
EndDate = MoveDays(TradeDays(end),1,'Before',WindTdays);
% ��ȡ��Ʊָ����ʷ������
for k=1:length(IndexPool)
    indexdata = GetIndexReturn(Params.IndexDailyData,IndexPool{k},-1,StartDate,EndDate);
    IndexReturn(:,k) = indexdata.Return;
end
tic;
% ��ȡ��Ʊ��ʷ������
StockCodes = unique(StocksNeedingTrade.StockCode);
NumOfIndex = length(IndexPool);
for k=1:length(StockCodes)
    StockData = GetStockReturn(Params.StockDailyData,StockCodes{k},-1,StartDate,EndDate);
    StockData(~strcmp(StockData.TRADE_STATUS,'����'),:) = [];
    StockData(isnan(StockData.Return),:) = [];
    suoyin = strcmp(StocksNeedingTrade.StockCode,StockCodes{k});
    TradeDays = StocksNeedingTrade.TradeDays(suoyin);
    for i=1:length(TradeDays)
        DateX = MoveDays(TradeDays(i),WindowLength,'Before',WindTdays);
        stockdata = StockData(StockData.DateTime<TradeDays(i)&StockData.DateTime>=DateX,:);
        % ƥ���Ӧ�����յĹ�Ʊָ��������������
        [~,suffix1,suffix2] = intersect(indexdata.DateTime,stockdata.DateTime);
        indexreturn = IndexReturn(suffix1,:);
        stockreturn = stockdata.Return(suffix2);
        % ��Ʊ�������Ʊָ��������ж�Ԫ���Իع�
        beta = My_lsqcurvefit(indexreturn,stockreturn);
        switch HedgeMethod
            case 'linearfit'
                proportion = beta(1:end-1) + Alpha;
            case 'linearfit&fixed'
                proportion = beta(1:end-1)*Alpha;
            case 'linearfit&corr'
                CorrelationCoefficient = corrcoef([stockreturn,indexreturn]);
                CorrelationCoefficient = CorrelationCoefficient(1,2:length(IndexPool)+1)';
                proportion = beta(1:end-1).*CorrelationCoefficient;
            otherwise
                error('��֧�ָ��ַ�ʽ����Գ����')
        end
        HedgeTable = [HedgeTable;[num2cell(ones(NumOfIndex,1)*TradeDays(i)),cellstr(repmat(StockCodes{k},NumOfIndex,1)),...
            cellstr(IndexPool'),num2cell(proportion)]];
    end
    disp(['����Գ����:',StockCodes{k}])
    toc;
end
      