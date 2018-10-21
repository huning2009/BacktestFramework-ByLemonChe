function [Tdays,PNL,DetailInformation] = GetPNL(IdealTradeTable,Params)
% �������ÿ��ӯ���;�ֵ����
%   ʾ����
%       [PNL,Tdays] = GetPNL2(IdealTradeTable,Params.StartDate,Params.EndDate,...
%    StockTradeFeeRatio,FuturesTradeFeeRatio,MultiplierOfFuturePrice)

% ���ɻز⽻��ʱ������
Tdays = sort(GetTdays(Params.StartDate, Params.EndDate, Params.WindTdays),'ascend');
NumOfTdays = length(Tdays);
% ��ȡ�ز������ڵĽ�����ˮ
IdealTradeTable = IdealTradeTable((IdealTradeTable.TradeDate<=Params.EndDate)&(IdealTradeTable.TradeDate>=Params.StartDate),:);
% ��ȡ���к�Լ�Ĵ���
ContractCodes = unique(IdealTradeTable.ContractCode);
NumOfContracts = length(ContractCodes);
% ÿ�������
IncomeOfAllContract = zeros(NumOfTdays,NumOfContracts);
% ÿ�ս��׷��ñ�
TradeFeeOfAllContract = zeros(NumOfTdays,NumOfContracts);

for i=1:NumOfContracts
    % ��ȡÿ����Լ����ˮ��¼
    IdealTrade_OfEachContract = IdealTradeTable(strcmp(IdealTradeTable.ContractCode, ContractCodes{i}),:);
    % ��long_cover��short_open��Lots��Ϊ����
    A = union(find(strcmp(IdealTrade_OfEachContract.TradeAction,'long_cover')),find(strcmp(IdealTrade_OfEachContract.TradeAction,'short_open')));
    IdealTrade_OfEachContract{A,'Lots'} = IdealTrade_OfEachContract{A,'Lots'}*(-1);

    % �ҳ�ÿ�����������һ�����׼�¼��λ��
    LaterTradeDate = arrayShift(IdealTrade_OfEachContract.TradeDate,1,nan);
    LaterTradeDate(end) = 0;
    MatrPosOf_LastTradePerDay = find((IdealTrade_OfEachContract.TradeDate-LaterTradeDate)~=0);
    
    % �ۼƳֲ�
    IdealTrade_OfEachContract.cum_lots = cumsum(IdealTrade_OfEachContract.Lots);
    % �ú�Լ�����н������ϵ��ۼƳֲ�
    B = My_setdiff(Tdays,IdealTrade_OfEachContract.TradeDate(MatrPosOf_LastTradePerDay));
    C = sortrows([B,zeros(length(B),1)*nan;IdealTrade_OfEachContract{MatrPosOf_LastTradePerDay,{'TradeDate','cum_lots'}}],1,'ascend');
    CumLots = C(:,2);
    % ���ǰֵ:ע�⣡����Ϊ����ĳ��ĳ��Լ����ȫƽ�֣���CumLots(i)=0���������ֱ�Ӱ���������CumLots(j)==0�����ǰֵ�������Ǵ����
    if isnan(CumLots(1))
        CumLots(1) = 0;
    end
    for j=2:length(CumLots)
       if isnan(CumLots(j))
           CumLots(j)=CumLots(j-1);
       end
    end
    
    if strcmp(IdealTrade_OfEachContract{1,'ContractType'},'stock')
     	if sum(CumLots<0)>0
            error('��Ʊ��λ����Ϊ��')
     	end
        % ���׷���
        TradeFeeRatio = Params.StockAccount.TradeFeeRatio;
        % ��ȡÿ����������
        StockDailyData = GetStockDailyData(Params.DataPath.StockDailyData, ContractCodes{i}, 'CLOSE,ADJFACTOR', num2cell(Tdays));
        FuquanCloseOfStock = StockDailyData.CLOSE.*StockDailyData.ADJFACTOR;
        % ����ÿ������ͽ��׷���
        [IncomePerStock, TradeFeePerStock] = CalculateIncomeAndFee(IdealTrade_OfEachContract, FuquanCloseOfStock, CumLots, Tdays, TradeFeeRatio);
        % ���� 
        IncomeOfAllContract(:,i) = IncomePerStock;
        TradeFeeOfAllContract(:,i) = TradeFeePerStock;
    elseif strcmp(IdealTrade_OfEachContract{1,'ContractType'},'futures')
        % ���׷���
        TradeFeeRatio = Params.HedgeAccount.TradeFeeRatio;
        % �ڻ�����
        MultiplierOfFuturePrice = Params.HedgeAccount.FuturesMultiplier;
        % ��ȡÿ�չ�ָ����
        IndexDailyData = GetIndexDailyData(Params.DataPath.IndexDailyData, ContractCodes{i}, 'CLOSE', num2cell(Tdays));
        PriceOfFutures = IndexDailyData.CLOSE*MultiplierOfFuturePrice;
        % ����ÿ������ͽ��׷���
        [IncomePerFutures, TradeFeePerFutures] = CalculateIncomeAndFee(IdealTrade_OfEachContract, PriceOfFutures, CumLots, Tdays, TradeFeeRatio);
        % ����
        IncomeOfAllContract(:,i) = IncomePerFutures;
        TradeFeeOfAllContract(:,i) = TradeFeePerFutures;
    else
        disp(['type of contract[',ContractCodes{i},'] connot be recognized!'])
        continue
    end
    disp(['����P/L����',num2str(i),'/',num2str(NumOfContracts)]);
end

% ������Ϣ
DetailInformation.ContractCodes = ContractCodes;
DetailInformation.IncomeOfAllContract = IncomeOfAllContract;
DetailInformation.TradeFee = sum(TradeFeeOfAllContract,2);
% PNL
PNL = sum(IncomeOfAllContract,2)-DetailInformation.TradeFee;

end

%% ����ÿ������ͽ��׷���
function [IncomePerContract, TradeFeePerContract] = CalculateIncomeAndFee(IdealTrade_OfEachContract, TradePrice, CumLots, Tdays, TradeFeeRatio)
    NumOfTdays = length(Tdays);
    IncomePerContract = zeros(NumOfTdays,1);
    TradeFeePerContract = zeros(NumOfTdays,1);
    % �ҳ������ǰһ��ֲֲ�ȫΪ0����ţ�ǰ������ֲ���ͬ����û�н��׷��ã��ֲ�Ϊ0����û����������
    presume_cumlots = arrayShift(CumLots,-1,nan);
    presume_cumlots(1) = 0;
    Suffix_Tdays = find(CumLots~=0|presume_cumlots~=0);
    % ������͵��ַ��ò�Ϊ0�����
    for i=1:length(Suffix_Tdays)
        suffix = Suffix_Tdays(i);
        IdealTrade_OfEachContractEachDay = IdealTrade_OfEachContract(IdealTrade_OfEachContract.TradeDate==Tdays(suffix),:);
        if  suffix==Suffix_Tdays(1)
            IncomePerContract(suffix) = (TradePrice(suffix)-IdealTrade_OfEachContractEachDay{:,'Price'})'*IdealTrade_OfEachContractEachDay{:,'Lots'};  % ÿ������
            TradeFeePerContract(suffix) = IdealTrade_OfEachContractEachDay{:,'Price'}'*abs(IdealTrade_OfEachContractEachDay{:,'Lots'})*TradeFeeRatio;       % ����������������һ��
        else
            IncomePerContract(suffix) = (TradePrice(suffix)-[TradePrice(suffix-1);IdealTrade_OfEachContractEachDay{:,'Price'}])'*[CumLots(suffix-1);IdealTrade_OfEachContractEachDay{:,'Lots'}];
            TradeFeePerContract(suffix) = IdealTrade_OfEachContractEachDay{:,'Price'}'*abs(IdealTrade_OfEachContractEachDay{:,'Lots'})*TradeFeeRatio;
        end
    end
end