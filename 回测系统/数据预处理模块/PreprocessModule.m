% ����Ԥ����ģ��
function StockAccount = PreprocessModule(Factor,Params)
% ��ʼ��
StockNeedingTrade = table();

% ���п�����Ҫ�ֲֵĹ�Ʊ
StockCodes = unique(Factor.StockCode);
StockNum = length(StockCodes);
% �������г����жϳֲ�����Ľ�������
OpenTradeDays = GenerateTradeDays(Params);
% û�������������ʱ���Գֲֹ�Ʊǿ��ƽ�ֵĽ�������
CloseTradeDays = MoveDays(OpenTradeDays,Params.HoldingDays,'After',Params.WindTdays);
% ������Ҫ������λ�Ľ�������
TradeDays = unique([OpenTradeDays;CloseTradeDays]);
% ȷ��֤ȯ���׵�����۸������
PriceType = Params.StockAccount.TradePriceType;

for i=1:StockNum
    % ��ȡָ���Ŀ��������ϵĸ�֧���ɵ���������
    StockFactor = Factor(strcmp(Factor.StockCode,StockCodes{i}),:);
    % ��ȡ���׼�
    StockData = GetStockDailyData(Params.DataPath.StockDailyData,StockCodes{i},[PriceType,',ADJFACTOR,TRADE_STATUS'],num2cell(TradeDays));
    if isempty(StockData)
        warning(['��ǰTradeDays��û����������[',StockCodes{i},']'])
        continue
    end
    TradePrice = StockData{:,PriceType};
    FuquanTradePrice = TradePrice.*StockData.ADJFACTOR;
    % ����״̬
    TradeStatus = StockData.TRADE_STATUS;
    if isa(TradeStatus,'double')
        warning(['��ǰTradeDays�¹�Ʊ����״̬Ϊnan���޷���ɽ���[',StockCodes{i},']']);
        continue
    end
    % ��Ʊ����
    StockCode = cellstr(repmat(StockCodes{i},length(TradeDays),1));
    % ���óֱֲ�ʶ
    IsHold = ones(length(TradeDays),1)*nan;
    [~,suffix1,~] = intersect(OpenTradeDays,StockFactor.TradeDays);
    for j=1:length(suffix1)
        IsHold(TradeDays>=OpenTradeDays(suffix1(j))&TradeDays<CloseTradeDays(suffix1(j))) = 1;
    end
    suffix2 = find(isnan(IsHold));   % ��IsHold~=1��TradeDays����Ϊƽ������
    [~,suffix3,~] = intersect(TradeDays(suffix2),CloseTradeDays(suffix1));
    IsHold(suffix2(suffix3)) = 0;
       
    NeedingTrade = table(TradeDays,StockCode,IsHold,TradePrice,FuquanTradePrice,TradeStatus);
    StockNeedingTrade = [StockNeedingTrade; NeedingTrade(~isnan(IsHold),:)];
    disp(['��ȡ��Ʊ���׼۸�[',PriceType,']����',num2str(i),'/',num2str(StockNum)]);
end

% ������¼�������ģ�ͣ����ֲֹ�Ʊû�з����ı�ʱ�������µ�����λ
if Params.IsEventsDriven
    StockTradeDays = unique(StockNeedingTrade.TradeDays);
    for i=length(StockTradeDays):-1:2
        suoyin1 = StockNeedingTrade.TradeDays==StockTradeDays(i-1);
        suoyin2 = StockNeedingTrade.TradeDays==StockTradeDays(i);
        if isequal(StockNeedingTrade(suoyin1,{'StockCode','IsHold'}),StockNeedingTrade(suoyin2,{'StockCode','IsHold'}))
            StockNeedingTrade.IsHold(suoyin2) = nan;
        end
    end
    StockNeedingTrade = StockNeedingTrade(~isnan(StockNeedingTrade.IsHold),:);
end

% ���ǿ��ƽ���գ�IsHold==0����trade_status��Ϊ�����ס�����Ҫʹ�����ǰһ�����յ����̼۽������
suffix_NoEfficientTradeDays = find((StockNeedingTrade.IsHold==0)&(~strcmp(StockNeedingTrade.TradeStatus,'����')));
NumOfNoEfficientTradeDays = length(suffix_NoEfficientTradeDays);
for i=1:NumOfNoEfficientTradeDays
    suffix1 = suffix_NoEfficientTradeDays(i);
    stockdata = GetStockDailyData_AtNearDate(Params.DataPath.StockDailyData,char(StockNeedingTrade{suffix1,'StockCode'}),'CLOSE,ADJFACTOR',StockNeedingTrade{suffix1,'TradeDays'},'Before'); 
    StockNeedingTrade{suffix1,'TradePrice'} = stockdata.CLOSE;
    StockNeedingTrade{suffix1,'FuquanTradePrice'} = stockdata.CLOSE*stockdata.ADJFACTOR;
    disp(['ǿ��ƽ���ղ�����Ч�����յ����������',num2str(i),'/',num2str(NumOfNoEfficientTradeDays)]);
    % TradeStatusΪnan���У������������е��������ݵ�ʱ�䷶Χ�����߸ù�Ʊ�Ѿ����У���Ҫ����ʹ�����ǰ���̼۽���ǿ��ƽ�֣�ͬʱ�޸Ľ�������
    if cellfun(@(x) isa(x,'double'),StockNeedingTrade{suffix1,'TradeStatus'})
        StockNeedingTrade{suffix1,'TradeDays'} = stockdata.DateTime;
    end
end


% ����ֹ����
% if Params.StopLoss
%     



% ֤ȯ���׵�ʱ�䷶Χ���ܹ������Ѿ��ڵĵײ����ݵ�ʱ�䷶Χ
StockAccount.TradeDays = TradeDays(TradeDays<=Params.DataPath.DataEndDate);
StockAccount.StockNeedingTrade = StockNeedingTrade(StockNeedingTrade.TradeDays<=Params.DataPath.DataEndDate,:);
