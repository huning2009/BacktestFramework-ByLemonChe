% ѡ��ֵ����ǰ20%���������±� 
function suoyin = findBottomN(x,bottom,varargin)
[a,b] = sort(x,'ascend');
n = ceil(bottom*length(a));

MinN = 0;
MaxN = inf;
for i=1:length(varargin)/2
    switch varargin{i*2-1}
        case 'MinN'
            MinN = varargin{i*2};
        case 'MaxN'
            MaxN = varargin{i*2};
    end
end

if MaxN<MinN
    error('Ҫ�����������ֵ���ܴ���Ҫ����������ֵ')
else
    n = min(max(min(MaxN,n),MinN),length(x));
end

suffix = b(1:n);
suoyin = logical(zeros(length(x),1));
suoyin(suffix) = true;
