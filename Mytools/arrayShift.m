function [Output] = arrayShift(A, n, replace)
% ������A��Ԫ�����Ͻ�nλ
%   arrayShift(A,n)
index = 1:size(A,1);
shift_index = index + n;

Output = zeros(size(A))*replace;
if n>=0
    Output(index(1:end-n),:) = A(shift_index(1:end-n),:);
else
    Output(index(1-n:end),:) = A(shift_index(1-n:end),:);
end