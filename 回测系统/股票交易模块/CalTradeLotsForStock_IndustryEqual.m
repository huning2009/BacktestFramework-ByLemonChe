function StocksNeedingTrade = CalTradeLotsForStock_IndustryEqual(StocksNeedingTrade,TotalCashForStock)
% �����Ʊ�˻��ֲ�����
% ��ҵƽ�������ʽ�

% ��ȡ��ҵ����
settings = Settings();
IndustryData = importdata(settings.IndustryDataPath);
stockcodes = unique(StocksNeedingTrade.StockCode);
for i=1:length(stockcodes)
    suoyin = strcmp(StocksNeedingTrade.StockCode,stockcodes{i});
    IndustryDataForStock = GetStockIndustryByDate(stockcodes{i},StocksNeedingTrade.TradeDays(suoyin),0,IndustryData);
    StocksNeedingTrade{suoyin,{'IndustryName_C1','IndustryName_C2','IndustryName_C3'}} = IndustryDataForStock{:,3:end};
    disp(['��ȡ������ҵ����:',stockcodes{i}])
end
% ����û����ҵ���ݵ��У�ǿ���ڸ���ƽ��
StocksNeedingTrade{strcmp(StocksNeedingTrade.IndustryName_C3,''),'IsHold'} = 0;

% Ĭ�ϳֲ�����Ϊ0
StocksNeedingTrade{:,'TradeLots'} = 0;
% ÿ��������
TradeDays = unique(StocksNeedingTrade.TradeDays);
for i=1:length(TradeDays)
    suffix = find((StocksNeedingTrade.TradeDays==TradeDays(i))&(StocksNeedingTrade.IsHold==1));
    if length(suffix)<1
        continue
    end
    Industry = unique(StocksNeedingTrade.IndustryName_C3(suffix));
    NumOfIndustry = length(Industry);
    k=[];
    for j=1:NumOfIndustry
        suoyin = strcmp(StocksNeedingTrade.IndustryName_C3(suffix),Industry{j});
        k(suoyin,:) = 1/NumOfIndustry/sum(suoyin);
    end
    StocksNeedingTrade{suffix,'TradeLots'} = floor((TotalCashForStock.*k)./StocksNeedingTrade{suffix,'FuquanOpen'});
    disp(['�����Ʊ�ֲ�����:',num2str(TradeDays(i))])
end
