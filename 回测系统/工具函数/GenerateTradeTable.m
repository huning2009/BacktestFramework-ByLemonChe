function [TradeTable, ChiCangTable] = GenerateTradeTable(ContractNeedingTrade,kind)
% ���ɽ�����ˮ�����봫�뽻�����ڡ����״��롢���׼۸񡢽�������
ContractNeedingTrade.Properties.VariableNames = {'tradedate','contractcode','tradeprice','tradelots'};

ChiCangTable = ContractNeedingTrade(ContractNeedingTrade.tradelots>0,:);
ChiCangTable.Properties.VariableNames = {'TradeDate','ContractCode','Price','Lots'};
% ��ԶԳ�͹�Ʊ�˻����׷ֱ����ò�ͬTradeAction��ContractType
if strcmp(kind,'hedge')
    tradeaction = {'short_open','short_cover'};
    contracttype = 'futures';
elseif strcmp(kind,'stock')
    tradeaction = {'long_open','long_cover'};
    contracttype = 'stock';
else
    error('�ݲ�֧�ָ����ʲ��Ľ���')
end
ChiCangTable{:,'ContractType'} = cellstr(contracttype);

% ���ɽ�����ˮ
TradeTable = array2table(zeros(1,7),'VariableNames',{'TradeDate','TradeTime','ContractCode','ContractType',...
    'TradeAction','Price','Lots'});
TradeTable(1,:) = [];
contractcodes = unique(ContractNeedingTrade.contractcode);
NumOfContracts = length(contractcodes);
for i=1:NumOfContracts
    suoyin = strcmp(ContractNeedingTrade.contractcode,contractcodes{i});
    TradeDays = ContractNeedingTrade{suoyin,'tradedate'};
    TradePrice = ContractNeedingTrade{suoyin,'tradeprice'};
    % λ���㣬����ٶ� 
    TradeLots = [0;ContractNeedingTrade{suoyin,'tradelots'}];
    Delta_TradeLots = TradeLots - arrayShift(TradeLots,-1,nan);
    Delta_TradeLots(1,:) = [];
    % ȥ��ƽ�ֵ����
    pingcang_suffix = (Delta_TradeLots==0);
    TradeDays(pingcang_suffix) = [];
    TradePrice(pingcang_suffix) = [];
    Delta_TradeLots(pingcang_suffix) = [];
    % ���ֺͼ������
    zengchi_suffix = (Delta_TradeLots>0);
    jianchi_suffix = (Delta_TradeLots<0);
    % 
    TradeAction = {};
    TradeAction(zengchi_suffix,:) = tradeaction(1);
    TradeAction(jianchi_suffix,:) = tradeaction(2);
    
    if isempty(TradeDays)
        continue
    end
    TradeTable = [TradeTable;[num2cell(TradeDays),cellstr(repmat('09:30:00',length(TradeDays),1)),...
        cellstr(repmat(contractcodes{i},length(TradeDays),1)),cellstr(repmat(contracttype,length(TradeDays),1)),...
        TradeAction,num2cell(TradePrice),num2cell(abs(Delta_TradeLots))]];
    
    disp(['���ɽ�����ˮ����',num2str(i),'/',num2str(NumOfContracts)])
end
