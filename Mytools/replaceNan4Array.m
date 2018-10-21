% ���ǰֵ
function m = replaceNan4Array(m,method,varargin)
switch method
    case 'PreviousValue'% ǰֵ
        if isnan(m(1))
            m(1)=0;
        end
        suffix = find(isnan(m));
        for i=1:length(suffix)
            m(suffix(i)) = m(suffix(i)-1);
        end
    case 'PostValue'% ��ֵ
        if isnan(m(end))
            m(end)=0;
        end
        suffix = find(isnan(m));
        for i=1:length(suffix)
            m(suffix(i)) = m(suffix(i)+1);
        end
    case 'Zero'% ��ֵ
        m(isnan(m)) = 0;
    case 'PreviousMean'% ǰ��ֵ
        step = varargin{1};
        m(isnan(1:step))=0;
        suffix = find(isnan(m));
        for i=1:length(suffix)
            m(suffix(i)) = mean(m(suffix(i)-step:suffix(i)-1));
        end
    case 'PostMean'% ���ֵ
        step = varargin{1};
        m(isnan(end-step+1:end))=0;
        suffix = find(isnan(m));
        for i=1:length(suffix)
            m(suffix(i)) = mean(m(suffix(i)+1:suffix(i)+step));
        end
end 