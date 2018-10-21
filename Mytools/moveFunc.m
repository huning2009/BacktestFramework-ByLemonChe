function [Output] = moveFunc(matr, window, func, direction)
%   ��matrix�������ƽ�Ʋ���������ƽ�ƴ����е���ֵ����������
%       window:���ڴ�С
%       func: ��window�еľ���ĺ�������
%       direction: �ƶ�����
%   ʾ��;
%       moveFunc(matr, window, func, direction)

N = size(matr,1);
switch direction
    case 'Before'
        for i=1:N
            if i-window(2)+1>0
                Output(i,:) = func(matr(i-window(2)+1:i-window(1),:));
            end
        end
        Output(1:window(2)-1,:) = nan;
    case 'After'
        for i=1:N
            if i+window(2)-1<=N
                Output(i,:) = func(matr(i+window(1):i+window(2)-1,:));
            end
        end
        Output = [Output; zeros(window(2)-1, size(Output,2))*nan];
end
end

