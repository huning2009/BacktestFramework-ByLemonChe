function [GroupIndex,GroupResult] = group(table, field, func, tofield)
% ����table��ĳ�����Խ��з��飬���ҶԷ�����к�������
% �������ڶ���ֵ�͵������Խ��з���

[tb,~,G] = unique(table(:,field));
value = splitapply(func,table2cell(table(:,tofield)),G);

GroupIndex = table2cell(tb);
GroupResult = value;
    