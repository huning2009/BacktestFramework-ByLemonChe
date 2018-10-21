% ����ÿ�������ս���ѭ����������ѭ������
% ���������ս������ڵ�ѭ����������ó��������Ա�֤����������֮��Ķ�����
% ÿ��ѭ��ʱ�������п϶����ڵĲ������Ǹ�ѭ����Ӧ�Ľ�������
function Factor = CircleAccordingTradeDays(TradeDays,Func,varargin)

TradeDays = sortrows(TradeDays,'ascend');

Factor = {};
FactorSplitByYear = {};
for i=1:length(TradeDays)
    
    Result = Func(TradeDays(i),varargin{:});
    if isempty(Result)
        disp(['�����������μ��㣺',num2str(TradeDays(i))])  
        continue
    end
    
    FactorSplitByYear = [FactorSplitByYear;Result];
    disp(['�����������μ��㣺',num2str(TradeDays(i))]) 
    
    % ����ÿ��ȱ�����������
    if size(FactorSplitByYear,1) >500000 || i==length(TradeDays)
        Factor = [Factor;FactorSplitByYear];
        FactorSplitByYear = {};
    end
end
