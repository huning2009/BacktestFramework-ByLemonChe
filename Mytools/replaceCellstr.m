% ��cellstr�е�ĳ��Ԫ�ػ�����һ��Ԫ��
function x = replaceCellstr(x,str1,str2)
suoyin = strcmp(x,str1);
x(suoyin) = {str2};
end
