function [Output] = GetAnnualizedTotalReturnRatio(TotalReturn, Tdays)
% �껯��������,����������

NumOfTdays_InOneYear = 245;
Output = TotalReturn./(length(Tdays)/NumOfTdays_InOneYear);