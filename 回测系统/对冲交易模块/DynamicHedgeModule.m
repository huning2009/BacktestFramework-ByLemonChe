% ��̬�Գ�
function [FuturesTradeTable, FuturesChiCangTable, HedgeTable] = DynamicHedgeModule(StocksNeedingTrade,Params)
StocksNeedingTrade = sortrows(StocksNeedingTrade,{'StockCode','TradeDays'},'ascend');

% ÿ�������յĹ�Ʊ�ֲּ�¼
StockChiCangTable = table();

% ����StocksNeedingTrade������ת��Ϊÿ�������յĳֲּ�¼������ÿ��������ʱ�ĳֲ�����
StockCodes = unique(StocksNeedingTrade.StockCode);
SuoyinOfCoverDays = StocksNeedingTrade.IsHold==0;

for i=1:length(StockCodes)
    SuoyinOfStock = strcmp(StocksNeedingTrade.StockCode,StockCodes{i});
    % �ù�Ʊ�ֲֵĽ���������
    TradeDaysOfTransction = StocksNeedingTrade.TradeDays(SuoyinOfStock);
    TradeDays = GetTdays(TradeDaysOfTransction(1),TradeDaysOfTransction(end),Params.WindTdays);
    % ÿ�������յĳֲ�����
    [~,a,~] = intersect(TradeDays,TradeDaysOfTransction);
    TradeLots = zeros(size(TradeDays))*nan;
    TradeLots(a,:) = StocksNeedingTrade.TradeLots(SuoyinOfStock);
    TradeLots = replaceNan4Array(TradeLots,'PreviousValue');    % ���ǰֵ
    % ֻ����ƽ���յ��У�ɾ�������ֲ�����Ϊ0����
    CoverDays = StocksNeedingTrade.TradeDays(SuoyinOfStock&SuoyinOfCoverDays);
    [~,a,~] = intersect(TradeDays,CoverDays);   % ����ɾ�����е�����
    TradeDays = TradeDays(sort([find(TradeLots~=0);a]));
    TradeLots = TradeLots(sort([find(TradeLots~=0);a]));
    % ÿ�������յĸ�Ȩ���̼�
    stockdata = GetStockDailyData(Params.DataPath.StockDailyData,StockCodes{i},'CLOSE,OPEN,ADJFACTOR,TRADE_STATUS',num2cell(TradeDays));
    % �������״̬��Ϊ'����',�򽫵��쿪�̼��滻Ϊ���ǰ���̼�
    suffix = find(isnan(stockdata.OPEN)&~strcmp(stockdata.TRADE_STATUS,'����'));
    for k=1:length(suffix)
        if suffix(k)==1
            stockdata2 = GetStockDailyData_AtNearDate(Params.DataPath.StockDailyData,StockCodes{i},'CLOSE,ADJFACTOR,TRADE_STATUS',TradeDays(1),'Before');
            stockdata.OPEN(1) = stockdata2.CLOSE;
            stockdata.ADJFACTOR(1) = stockdata2.ADJFACTOR;
        else
            stockdata.OPEN(suffix(k)) = stockdata.CLOSE(suffix(k)-1);
            stockdata.ADJFACTOR(suffix(k)) = stockdata.ADJFACTOR(suffix(k)-1);
        end
    end
    % ���㸴Ȩ���̼�
    FuquanOpen = stockdata.OPEN.*stockdata.ADJFACTOR;
    StockCode = cellstr(repmat(StockCodes{i},size(TradeDays,1),1));
    % �ϲ���ChiCangTable
    StockChiCangTable = [StockChiCangTable;table(TradeDays,StockCode,FuquanOpen,TradeLots)];
    disp(['��ȡ��Ʊÿ�������յĿ��̼�:',StockCodes{i}]);
end
% �����Ʊÿ����ֵ
StockChiCangTable.MarketValue = StockChiCangTable.FuquanOpen.*StockChiCangTable.TradeLots;

% ������ֵ�仯��̬�Գ�
HedgeTable = Params.HedgeAccount.HedgeFunc(StockChiCangTable,Params);
[FuturesTradeTable, FuturesChiCangTable] = GenerateTradeTable(HedgeTable,'hedge');
    