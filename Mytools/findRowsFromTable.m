function Output = findRowsFromTable(tb,rowcell)
% ��table���ҵ���rowcell��ȫ��ȵ��У��������е��±꣬�����ж���

tb.suffix = (1:height(tb))';
suoyin = Suoyin(tb{:,1},rowcell{1});

if length(rowcell)>1 
    for i=2:length(rowcell)
        suoyin = suoyin&(Suoyin(tb{:,i},rowcell{i}));
        if sum(suoyin)<1
            Output = [];
            return
        end
    end
end
Output = find(suoyin);


function Output = Suoyin(tbcolumn,value)
if isa(tbcolumn,'double')||isa(tbcolumn,'logical')
    Output = tbcolumn==value;
elseif isa(tbcolumn,'cell')
    Output = cellfun(@(x) isequal(x,value),tbcolumn);
else
    error('��֧�ָ������͵�����')
end