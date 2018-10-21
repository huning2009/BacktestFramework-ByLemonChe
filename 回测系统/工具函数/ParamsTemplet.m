% ģ�Ͳ�����ģ��
% ��ģ����û�ж��ض��������и�ֵʱ����ʹ��Ĭ�ϵĲ���ֵ
function Output = ParamsTemplet()      
%% �ⲿ֧�����ݺ���������
% �ⲿ����·��
Output.DataPath = DataPath();
% ��������·��
Output.FactorPath = FactorPath();

% �����ⲿ����
Output.WindTdays = importdata(Output.DataPath.WindTdaysData);
Output.WindNdays = importdata(Output.DataPath.WindNdaysData);


%% ��Ʊ�˻�����
Output.StockAccount.InitCash = 100*10^4;    % ��Ʊ�˻���ʼ�ʽ�
Output.StockAccount.TradeFeeRatio = 0.003;  % ��Ʊ�˻����׷���
Output.StockAccount.TradePriceType = 'OPEN';    % Ĭ��ʹ�ÿ��̼���Ϊ��Ʊ���׼۸�

Output.StockAccount.FuncToCalUseableCash = @CalAvailableCashForStock_EuqalToInitCash;   % ����ÿ�ڵ���ʱ������ʹ�õ��ʽ�ķ���
Output.StockAccount.FuncToCalTradeLots = @CalTradeLotsForStock_StockEqual;      % ����ÿ�ڵ���ʱÿֻ��Ʊ�ĳֲֹ���

Output.StockAccount.LeastStockNum = 10;  % ���ֲֹ�Ʊ��������Nʱ����ȫ��

%% �Գ��˻�����
Output.HedgeAccount.IsHedge = 0;     % �Ƿ�Գ�
Output.HedgeAccount.ProportionToStockAccountInitCash = 0.3;         % �Գ��˻���ʼ�ʽ�����ڹ�Ʊ�˻���ʼ�ʽ�ı���
Output.HedgeAccount.FuturesMultiplier = 1;      % �ڻ����׳���
Output.HedgeAccount.TradeFeeRatio = 0.0006;     % �Գ��˻����׷���
Output.HedgeAccount.InitCash = Output.HedgeAccount.ProportionToStockAccountInitCash*Output.StockAccount.InitCash;   % �Գ��˻���ʼ�ʽ�

Output.HedgeAccount.HedgeFunc = @DynamicHedgeToSinglePosition;   % �Գ巽ʽ
Output.HedgeAccount.AssetCode = {'000905.SH'};    % ��ѡ��ĶԳ���
Output.HedgeAccount.HedgeFuncParams = {[-0.05,0.05],'fixed',{Output.HedgeAccount.AssetCode,1}};  % �Գ庯���Ĳ���


%% �ڻ��˻�����





%% �˻�����
Output.TotalInitCash = Output.HedgeAccount.IsHedge*Output.HedgeAccount.InitCash + Output.StockAccount.InitCash;         % ��ʼ�˻����ʽ�
Output.StartDate = 20090101;        % �ز⿪ʼʱ��
Output.EndDate = Output.DataPath.DataEndDate;    % �ز����ʱ��
Output.TradeFrequency = 5;  % ����Ƶ�ʣ���λ:�����գ���ʵ�ʽ����У���ʾÿ��������������һ�ν��׳���
Output.HoldingDays = Output.TradeFrequency; % ÿ�ε��ֺ�֤ȯ�ֲֵ�ʱ�䳤�ȣ�Ĭ��Ϊ��ǿ��ƽ��

% ֹ����
Output.StopLoss = 0;
Output.StopLossStandard = 0.02;

% �ز����ʱ�䲻�ó�����ǰ�Ѿ����ڵĵײ����ݵ�ʱ�䷶Χ
Output.EndDate = min(Output.EndDate,Output.DataPath.DataEndDate);

% �¼�������ģ��
Output.IsEventsDriven = false;

%% ��׼�Ƚ�
% ��׼�ʲ�
Output.BenchAsset.AssetCode = '000001.SH';

