% 1:1�Գ�
function HedgeTable = HedgeWithFixedProportion(StocksNeedingTrade,FuncParams)

proportion = FuncParams{2};
hedgecode = FuncParams{1};

HedgeTable = StocksNeedingTrade(:,{'TradeDays','StockCode'});
HedgeTable{:,'HedgeCode'} = hedgecode;
HedgeTable{:,'Proportion'} = proportion;