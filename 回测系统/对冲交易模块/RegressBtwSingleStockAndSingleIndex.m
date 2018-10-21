% �����뵥ֻ��Ʊָ���Գ壬���������ϵ����ߵĹ�Ʊָ��
function HedgeTable = RegressBtwSingleStockAndSingleIndex(StocksNeedingTrade,FuncParams,Settings)

WindowLength = FuncParams{1};
IndexPool = FuncParams{2};
HedgeMethod = FuncParams{3};
Alpha = FuncParams{4};

% ��ʼ��HedgeTable
HedgeTable = StocksNeedingTrade(:,{'TradeDays','StockCode'});
% 
WindTdays = importdata(Settings.WindTdaysDataPath);
TradeDays = unique(StocksNeedingTrade.TradeDays);
StartDate = MoveDays(TradeDays(1),WindowLength,'Before',WindTdays);
EndDate = MoveDays(TradeDays(end),1,'Before',WindTdays);
% ��ȡ��Ʊָ����ʷ������
for k=1:length(IndexPool)
    indexdata = GetIndexReturn(Settings.IndexDailyDataPath,IndexPool{k},-1,StartDate,EndDate);
    IndexReturn(:,k) = indexdata.Return;
end
tic;
% ��ȡ��Ʊ��ʷ������
StockCodes = unique(StocksNeedingTrade.StockCode);
for k=1:length(StockCodes)
    StockData = GetStockReturn(Settings.StockDailyDataPath,StockCodes{k},-1,StartDate,EndDate);
    StockData(~strcmp(StockData.TRADE_STATUS,'����'),:) = [];
    StockData(isnan(StockData.Return),:) = [];
    suffix = find(strcmp(StocksNeedingTrade.StockCode,StockCodes{k}));
    TradeDays = StocksNeedingTrade.TradeDays(suffix);
    for i=1:length(TradeDays)
        DateX = MoveDays(TradeDays(i),WindowLength,'Before',WindTdays);
        stockdata = StockData(StockData.DateTime<TradeDays(i)&StockData.DateTime>=DateX,:);
        % ƥ���Ӧ�����յĹ�Ʊָ��������������
        [~,suffix1,suffix2] = intersect(indexdata.DateTime,stockdata.DateTime);
        indexreturn = IndexReturn(suffix1,:);
        stockreturn = stockdata.Return(suffix2);
        % �������ϵ��
        CorrelationCoefficient = corrcoef([stockreturn,indexreturn]);
        CorrelationCoefficient = CorrelationCoefficient(1,2:length(IndexPool)+1);
        [a,b] = max(CorrelationCoefficient);
        if isnan(a)
            error('���ϵ������Ϊnan���������');
        end
        % ����Գ����
        switch HedgeMethod
            case 'fixed'
                proportion = Alpha;
            case 'linearfit'
                LinearFit = regstats(stockreturn,indexreturn(:,b),'linear','beta');
                proportion = Alpha + LinearFit.beta(2);
            case 'linearfit&corr'
                LinearFit = regstats(stockreturn,indexreturn(:,b),'linear','beta');
                proportion = Alpha + LinearFit.beta(2)*a;
            otherwise
                error('��֧�ָ��ַ�������Գ����')
        end
        HedgeTable{suffix(i),'HedgeCode'} = cellstr(IndexPool{b});
        HedgeTable{suffix(i),'Proportion'} = proportion;
    end
    disp(['����Գ����:',StockCodes{k}])
    toc;
end
      