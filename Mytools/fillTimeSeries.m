% ����ȱ��ʱ���������������ʱ�����У�ȱʧֵ
function timeseries = fillTimeSeries(x,timeseries,replaceValue)

x = sortrows(x,1);
timeseries = sortrows(timeseries);

[~,b,c] = intersect(x(:,1),timeseries);
if length(b)<size(x,1)
    error('������ʱ�����е�����Ӧ��Ҫ��ȫ�������ڴ�����ʱ����������')
end

switch class(replaceValue)
    case 'double'   
        timeseries(:,2) = replaceValue;
        timeseries(c,2) = x(:,2);
    case 'char'
        timeseries(:,2) = nan;
        timeseries(c,2) = x(:,2);
        if replaceValue=='ForthValue'
            if isnan(timeseries(1,2))
                timeseries(1,2) = 0;
            end
            for i=2:size(timeseries,1)
                timeseries(i,2) = timeseries(i-1,2);
            end
        end
end