function [Output] = GetTotalReturnRatio(PNL, StartupCash)
% ������������
%   ���������ʽ�� TotalReturnRatio = (PV_end - PV_start)/PV_start

Output = sum(PNL)/StartupCash;