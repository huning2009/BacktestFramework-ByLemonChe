% ����ÿֻ���ɵ�ӯ�����
function PerformanceTable = EachStock_Performance(model)

StockAccount = model.Backtest.StockAccount;
Params = model.Params;

Tdays = StockAccount.Tdays;
StockCodes = StockAccount.DetailInformation.ContractCodes;
IncomeOfAllStocks = StockAccount.DetailInformation.IncomeOfAllContract;

HoldingDays = sum(IncomeOfAllStocks~=0,1)';  % ����ֲֵ�ǰ�����������Ϊ0�����������������
ProportionOfHoldingDaysToAllTdays = HoldingDays./length(Tdays); % �ֲ�ʱ��ռģ���ܻز�ʱ���ı���
AbsoluteReturn = sum(IncomeOfAllStocks)';    % ��������
AbsoluteReturnRatio = sum(IncomeOfAllStocks)'./Params.StockAccount.InitCash;  % ����ڹ�Ʊ�˻���ʼ�ʽ�ľ���������
AnnualizedReturnRatio = GetAnnualizedTotalReturnRatio(AbsoluteReturnRatio,Tdays);   % �껯������

StockName = GetStockName(StockCodes,importdata(Params.DataPath.StockBasicData));    % ��Ʊ����
% Industry = GetStockIndustryByDate(StockCodes,str2num(datestr(today,'yyyymmdd')),1,importdata(Params.DataPath.StockIndustryData));   % ������ҵ

PerformanceTable = table(StockCodes,StockName,HoldingDays,ProportionOfHoldingDaysToAllTdays,AbsoluteReturn,AbsoluteReturnRatio,AnnualizedReturnRatio);