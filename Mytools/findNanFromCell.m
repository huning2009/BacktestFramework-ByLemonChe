function [Output] = findNanFromCell(cellmatr)
% ��cell�������ҵ�nanֵ�����
Output = logical(zeros(size(cellmatr)));
for i=1:length(cellmatr)
    if isnan(cellmatr{i})
        Output(i) = true;
    else
        Output(i) = false;
    end
end