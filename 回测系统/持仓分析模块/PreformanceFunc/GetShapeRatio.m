function [OutputSharpe] = GetShapeRatio(PNL)
% ������
%   ���㹫ʽ
%   mean(PNL)*(252)^0.5/std(PNL)

NumOfTdays_InOneYear = 245;
OutputSharpe = (mean(PNL,1)./std(PNL))*(NumOfTdays_InOneYear)^0.5;