% ����Params������Ҫ���н��׳�������ڵ�����
% �ز⿪ʼʱ�䣬�ز����ʱ�䣬����Ƶ��
function TradeDays = GenerateTradeDays(Params)

switch class(Params.TradeFrequency)
    case 'double'
        TradeDays = GetTdaysWithEqualDifference(Params.StartDate,Params.EndDate,Params.TradeFrequency,Params.WindTdays);
    case 'char'
        switch Params.TradeFrequency
            case 'monthly'
                TradeDays = GetFirstTdaysEveryMonth(Params.StartDate,Params.EndDate,Params.WindTdays);
            otherwise
                error('����[TradeFrequency]�������')
        end
    otherwise
            error('����[TradeFrequency]�������')
end