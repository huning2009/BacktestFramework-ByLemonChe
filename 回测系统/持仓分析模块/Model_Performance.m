% ����ģ����������س����
function Performance = Model_Performance(model,varargin)

Backtest = model.Backtest;
Params = model.Params;

% ���㾻ֵ
Performance.Tdays = Backtest.Tdays;
Performance.NetValue = cumsum(Backtest.PNL)/model.Params.TotalInitCash+1;   % ��ֵ

% ��׼�ʲ�
IndexReturn = GetIndexReturn(Params.DataPath.IndexDailyData,Params.BenchAsset.AssetCode,-1,'Close/Close',num2cell(Backtest.Tdays));

% ����ָ��
Performance.TotalReturn = GetTotalReturnRatio(Backtest.PNL,Params.TotalInitCash);     % ��������
Performance.AnnualizedTotalReturn = GetAnnualizedTotalReturnRatio(Performance.TotalReturn,Backtest.Tdays); % �껯������
Performance.AnnualizedSharpe = GetShapeRatio(Backtest.PNL);  % ������
Performance.MaxDrawDown =  GetMaxDrawDown(Backtest.PNL,Params.TotalInitCash);    % ���س�
Performance.AnnualizedReturnToMaxDrawDown = Performance.AnnualizedTotalReturn/Performance.MaxDrawDown;      % �����ʻس���
Performance.WinRatio = sum((Backtest.PNL./Params.TotalInitCash - IndexReturn.Return)>0)/length(Performance.Tdays);

% ��ʼ����ͼԪ��
title = ['ģ�;�ֵ����[',num2str(Performance.Tdays(1)),'-',num2str(Performance.Tdays(end)),']'];
for i=1:2:length(varargin)
    switch varargin{i}
        case 'title'
            title = varargin{i+1};
    end
end

% ��ֵ����ͼ
figure
My_plot(@plot,[Performance.NetValue,cumsum(IndexReturn.Return)+1],'xticklabel',Performance.Tdays,'legendlabel',{'ģ�;�ֵ',['��׼�ʲ�[',Params.BenchAsset.AssetCode,']']},...
    'title',title)