function [Output]=dropDuplicate(x,unique_fields)
% �Ժ���nan��table����Ψһ�ֶ���(unique_fields)ȥ��
%       ���ӣ�������create_date,code,org_nameȥ��)
%       dropDuplcate(predicatedata,'create_date,code,org_name')
%   
%   ˵����
%       ���table�в�����nan�����ֱ��ʹ��unique����

[~, mark]=unique(x(:,unique_fields));
Output=x(mark,:);
        