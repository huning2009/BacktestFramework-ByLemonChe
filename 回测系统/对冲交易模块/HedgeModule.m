function [FuturesTradeTable, FuturesChiCangTable, HedgeTable] = HedgeModule(StocksNeedingTrade,TradeDays,FuncToCalHedgeProportion,FuncParams)
% ��ȡ�Գ�����ͳ�ʼ�Գ��
settings = Settings();
HedgeTable = FuncToCalHedgeProportion(StocksNeedingTrade,FuncParams,settings);
% ��ȡ��Ҫ�Գ�Ľ��
StocksNeedingTrade.TotalCapital = StocksNeedingTrade.FuquanOpen.*StocksNeedingTrade.TradeLots;
HedgeTable = join(HedgeTable,StocksNeedingTrade(:,{'TradeDays','StockCode','TotalCapital'}));
% ��ȡ�ڻ��Գ�۸�
HedgeCodes = unique(HedgeTable.HedgeCode);
for i=1:length(HedgeCodes)
    suoyin = strcmp(HedgeTable.HedgeCode,HedgeCodes{i});
    IndexData = GetIndexDailyData(settings.IndexDailyDataPath,HedgeCodes{i},'OPEN',num2cell(HedgeTable.TradeDays(suoyin)));
    HedgeTable{suoyin,'TradePrice'} = IndexData.OPEN;
end
% ���㽻�׹���
HedgeTable.TradeLots = floor(HedgeTable.TotalCapital.*HedgeTable.Proportion./HedgeTable.TradePrice);
% ����ÿ��ĶԳ��λ
NewHedgeTable = cell2table(group(HedgeTable,{'TradeDays','HedgeCode','TradePrice'},@(x)sum(cell2mat(x)),'TradeLots'),...
    'VariableNames',{'tradedate','hedgecode','tradeprice','tradelots'});
NewHedgeTable(NewHedgeTable.tradelots==0,:) = [];
% �����Գ���׼�¼
for i=1:length(HedgeCodes)
    suoyin = strcmp(NewHedgeTable.hedgecode,HedgeCodes{i});
    [~,a,~] = intersect(TradeDays,NewHedgeTable.tradedate(suoyin));
    suffix = a+1;
    suffix = suffix(suffix<=length(TradeDays));
    CoverDays = set_diff(TradeDays(suffix),NewHedgeTable.tradedate(suoyin));
    if isempty(CoverDays)
        continue
    end
    IndexData = GetIndexDailyData(settings.IndexDailyDataPath,HedgeCodes{i},'OPEN',num2cell(CoverDays));
    NewHedgeTable = [NewHedgeTable;[num2cell(CoverDays),cellstr(repmat(HedgeCodes{i},length(CoverDays),1)),...
        num2cell(IndexData.OPEN),num2cell(zeros(size(CoverDays)))]];
end 
% ���ɽ�����ˮ
[FuturesTradeTable, FuturesChiCangTable] = GenerateTradeTable(NewHedgeTable,'hedge');