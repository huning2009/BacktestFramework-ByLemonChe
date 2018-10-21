% ��Գֲ���ϵ�����ֵ�ı仯����̬�����Գ�
function NewHedgeTable = DynamicHedgeToSinglePosition(StockChiCangTable,Params)

% ���Գ��˻���ֵ���Ʊ�˻���ֵ����5%�����µ���-5%ʱ�����µ����Գ��˻�
ProportionToAdjustHedge = Params.HedgeAccount.HedgeFuncParams{1};
% ���Ʊָ���ĶԳ巽ʽ
HedgeMethod = Params.HedgeAccount.HedgeFuncParams{2};
% ����Գ�����ĺ����Ĳ���
ParamsToCalProportion = Params.HedgeAccount.HedgeFuncParams{3};

% ѡ����Ҫ�����Գ��������
StockCodes = unique(StockChiCangTable.StockCode);
SuffixToHedge = [];
for j=1:length(StockCodes)
    SuffixOfStock = find(strcmp(StockChiCangTable.StockCode,StockCodes{j}));
    MarketValue = StockChiCangTable.MarketValue(SuffixOfStock);
    % ȷ����Ҫ�����Գ��λ��ʱ��ڵ�
    SuffixToSuffix = 1;
    i = 2;
    while i<=length(MarketValue)
        CumIncreaseOfMarketValue = MarketValue(i:end)/MarketValue(i-1)-1;
        suffix = min([find(CumIncreaseOfMarketValue>=ProportionToAdjustHedge(2),1),find(CumIncreaseOfMarketValue<=ProportionToAdjustHedge(1),1)]);
        if isempty(suffix)
            break;
        end
        SuffixToSuffix = [SuffixToSuffix;suffix+i-1];
        i = suffix+i;
    end
    SuffixToHedge = [SuffixToHedge;SuffixOfStock(SuffixToSuffix)];
    disp(['��Ҫ�����Գ��λ����:',StockCodes{j}])
end
StocksToHedge = StockChiCangTable(SuffixToHedge,{'TradeDays','StockCode'});

% ����Գ��
HedgeTable = table();
switch HedgeMethod
    case 'fixed' % ����������Ʊָ���̶������Գ�
        % ��Ʊָ����
        IndexPool = ParamsToCalProportion{1};
        % ָ���Գ����
        Proportion = ParamsToCalProportion{2};
        for i=1:length(IndexPool)
            StockChiCangTable{SuffixToHedge,'HedgeCode'} = cellstr(repmat(IndexPool{i},height(StocksToHedge),1));
            StockChiCangTable{SuffixToHedge,'Proportion'} = Proportion(i);
            HedgeTable = [HedgeTable;StockChiCangTable(:,{'TradeDays','StockCode','MarketValue','HedgeCode','Proportion'})];
        end
    case 'simpleregress'    % ����������Ʊָ��һԪ�ع�
        % ���Իع����ʷʱ�䳤��
        WindowLength = ParamsToCalProportion{1};
        % ��Ʊָ����
        IndexPool = ParamsToCalProportion{2};
        % ����Գ�����ľ��巽��
        CalProportionMethod = ParamsToCalProportion{3};
        % ����Գ�����Ĳ���
        Alpha = ParamsToCalProportion{4};
        a = RegressBtwSingleStockAndSingleIndex(StocksToHedge,{WindowLength,IndexPool,CalProportionMethod,Alpha},Settings);
        StockChiCangTable{SuffixToHedge,'HedgeCode'} = a.HedgeCode;
        StockChiCangTable{SuffixToHedge,'Proportion'} = a.Proportion;
        HedgeTable = StockChiCangTable(:,{'TradeDays','StockCode','MarketValue','HedgeCode','Proportion'});
    case 'multiregress'   % ����������Ʊָ����Ԫ�ع�
        % ���Իع����ʷʱ�䳤��
        WindowLength = ParamsToCalProportion{1};
        % ��Ʊָ����
        IndexPool = ParamsToCalProportion{2};
        % ����Գ�����ľ��巽��
        CalProportionMethod = ParamsToCalProportion{3};
        % ����Գ�����Ĳ���
        Alpha = ParamsToCalProportion{4};
        a = RegressBtwSingleStockAndMultiIndex(StocksToHedge,{WindowLength,IndexPool,CalProportionMethod,Alpha},Params);
        for i=1:length(IndexPool)
            suoyin = strcmp(a.HedgeCode,IndexPool{i});
            StockChiCangTable{SuffixToHedge,'HedgeCode'} = a.HedgeCode(suoyin);
            StockChiCangTable{SuffixToHedge,'Proportion'} = a.Proportion(suoyin);
            HedgeTable = [HedgeTable;StockChiCangTable(:,{'TradeDays','StockCode','MarketValue','HedgeCode','Proportion'})];
        end
    otherwise 
        error('��֧�ָ��ַ�������Գ����')
end

HedgeTable = sortrows(HedgeTable,{'StockCode','TradeDays'},'ascend');
% ���Գ����Ϊ0��ֵ�޸�Ϊnan
HedgeTable.Proportion(HedgeTable.Proportion==0)=nan;

% ����Ҫ�����Գ���У�ά��ǰһ�����յĶԳ��λ
HedgeCode_List = HedgeTable.HedgeCode;
MarketValue_List = HedgeTable.MarketValue;
for i=1:length(StockCodes)
    suffix = find(strcmp(HedgeTable.StockCode,StockCodes{i}));
    TradeDays = unique(HedgeTable.TradeDays(suffix));
    for j=1:length(TradeDays)
        suoyin = HedgeTable.TradeDays(suffix)==TradeDays(j);
        if ~isnan(sum(HedgeTable.Proportion(suffix(suoyin))))
            b = HedgeTable(suffix(suoyin),:);
        end
        HedgeCode_List(suffix(suoyin),:) = b.HedgeCode;
        MarketValue_List(suffix(suoyin),:) = b.MarketValue;
    end
    disp(['����Ҫ�����Գ��λ����:',StockCodes{i}])
end
HedgeTable.HedgeCode = HedgeCode_List;
HedgeTable.MarketValue = MarketValue_List;

% ��ȡ�ڻ��Գ�۸�
HedgeCodes = unique(HedgeTable.HedgeCode);
for i=1:length(HedgeCodes)
    suoyin = strcmp(HedgeTable.HedgeCode,HedgeCodes{i});
    IndexData = GetIndexDailyData(Params.DataPath.IndexDailyData,HedgeCodes{i},'OPEN',num2cell(HedgeTable.TradeDays(suoyin)));
    HedgeTable{suoyin,'TradePrice'} = IndexData.OPEN;
    TradeLots = HedgeTable.MarketValue(suoyin).*HedgeTable.Proportion(suoyin)./IndexData.OPEN;
    HedgeTable{suoyin,'TradeLots'} = replaceNan4Array(TradeLots,'PreviousValue');
end

% ����ÿ��ĶԳ��λ
[Gi,Gv] = group(HedgeTable,{'TradeDays','HedgeCode','TradePrice'},@(x)sum(cell2mat(x)),'TradeLots');
NewHedgeTable = cell2table([Gi,num2cell(Gv)],'VariableNames',{'TradeDays','HedgeCode','TradePrice','TradeLots'});
