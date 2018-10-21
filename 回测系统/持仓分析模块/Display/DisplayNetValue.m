function DisplayNetValue(NetValue,Tdays)

% ��ͼ
plot(NetValue);
% ����ʱ����
x_tick = 1:ceil(size(Tdays,1)/30):size(Tdays,1);
set(gca,'XTick',x_tick);
set(gca,'XTickLabel',num2str(Tdays(x_tick,1)));
set(gca,'XTickLabelRotation', -45);
% ����ͼ��
legend('��ֵ','location','BestOutside');
% ����ͼ�񳤿�
set(gcf,'unit','normalized','position',[0.1,0.3,0.6,0.5]);
