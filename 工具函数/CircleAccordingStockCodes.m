% ����ÿֻ��Ʊ����ѭ����������ѭ������
function Factor = CircleAccordingStockCodes(StockCodes,Func,varargin)

Factor = {};
FactorSplitByStock = {};
for i=1:length(StockCodes)
    disp(['����Ʊ�������μ��㣺',StockCodes{i}])  
    
    Result = Func(StockCodes{i},varargin{:});
    if isempty(Result)
        continue
    end
    Result.StockCode = cellstr(repmat(StockCodes{i},size(Result,1),1));
    
    FactorSplitByStock = [FactorSplitByStock;Result];
    
   	% ����ÿ��ȱ�����������
    if size(FactorSplitByStock,1) >500000 || i==length(StockCodes)
        Factor = [Factor;FactorSplitByStock];
        FactorSplitByStock = {};
    end
end
