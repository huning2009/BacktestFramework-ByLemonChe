% ����model
function model = S3_Model1()

% ����ģ�Ͳ���
model.Params = ParamsTemplet();
model.Params.StartDate = 20180101;
model.Params.EndDate = 20181012;

% ���й�Ʊ���ֽ��ײ����Ľ����յ�����
model.Params.TradeDays = GenerateTradeDays(model.Params);

% ���ز����������
model.Factor = CalendarSpreadArbitrage('IC','IC1808.CFE','IC1809.CFE','5min');

end
