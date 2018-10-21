% ��Գֲ���ϵ�����ֵ�ı仯����̬�����Գ�
function HedgeTable = DynamicHedgeToTotalPosition(StockChiCangTable,HedgeFuncParams,Settings)
% ���Գ��˻���ֵ���Ʊ�˻���ֵ����5%�����µ���-5%ʱ�����µ����Գ��˻�
ProportionToAdjustHedge = HedgeFuncParams{1};
% ��Ʊָ����
IndexPool = HedgeFuncParams{2};
% ����Գ�����ķ�ʽ
HedgeMethod = HedgeFuncParams{3};

% ��Ʊ�˻�����ֵ
a = cell2mat(group(StockChiCangTable,'TradeDays',@(x)sum(cell2mat(x)),'MarketValue'));
AllTradeDays = a(:,1);
MarketValue = a(:,2);
% ȷ����Ҫ�����Գ��λ��ʱ��ڵ�
SuffixToAdjustHedge = 1;
i = 2;
while 1
    CumIncreaseOfMarketValue = MarketValue(i:end)/MarketValue(i-1)-1;
    suffix = min([find(CumIncreaseOfMarketValue>=ProportionToAdjustHedge(2),1),find(CumIncreaseOfMarketValue<=ProportionToAdjustHedge(1),1)]);
    if isempty(suffix)
        break;
    end
    SuffixToAdjustHedge = [SuffixToAdjustHedge;suffix+i];
    i = suffix+i+1;
end
% ����Գ�����������ɶԳ��
HedgeTable = table();
switch HedgeMethod
    case 'fixed'
        % ��ָ���Ĺ�Ʊָ������ָ�������ĶԳ�
        HedgeProportion = HedgeFuncParams{4};
        if length(HedgeProportion)~=length(IndexPool)
            error('��Ҫָ����Գ���������ͬ�ĶԳ����')
        end
        for i=1:length(IndexPool)
            TradeDays = AllTradeDays(SuffixToAdjustHedge);
            indexdata = GetIndexDailyData(Settings.IndexDailyDataPath,IndexPool{i},'OPEN',num2cell(TradeDays));
            TradePrice = indexdata.OPEN;
            TradeLots = floor(MarketValue(SuffixToAdjustHedge).*HedgeProportion(i)./TradePrice);
            HedgeCode = cellstr(repmat(IndexPool{i},size(SuffixToAdjustHedge,1),1));
            HedgeTable = [HedgeTable;table(TradeDays,HedgeCode,TradePrice,TradeLots)];
        end
    case 'linearfit'
        
    otherwise 
        error('��֧�ָ��ַ�������Գ����')
end

%% �ֲ���ϵ������������Ʊָ���Ķ�Ԫ�ع����Գ��


