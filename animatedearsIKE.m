
clear
close all

 dayday='20180311'
 trial='6'



a = csvread(['\\batserve.win.ad.jhu.edu\data1\Angie\Ike\target prediction\Miro tracking\',dayday,'\trial_',trial,'_xyzpts.csv'],1,0);

leftear=[a(:,1),a(:,2),a(:,3)];
rightear=[a(:,4),a(:,5),a(:,6)];


x= sgolayfilt(leftear(:,1),3,9);
y= sgolayfilt(leftear(:,2),3,9);
z= sgolayfilt(leftear(:,3),3,9);

xr= sgolayfilt(rightear(:,1),3,9);
yr= sgolayfilt(rightear(:,2),3,9);
zr= sgolayfilt(rightear(:,3),3,9);


plot3(xr,yr,zr,'LineWidth',2, 'Color', [66, 122, 244]/255)
hold on
plot3(x,y,z,'LineWidth',2,'Color', 'm')

grid on;

view(0,90)

title('Right and Left Ear Position in Space')

xlabel('Horizontal Position in Space')
ylabel('Vertical Position in Space')




hold on
mKr=[xr(60),yr(60),zr(60)]
plot3(mKr(1),mKr(2),mKr(3),'o','MarkerSize',10,'MarkerFaceColor','k','MarkerEdgeColor','k')


mKl=[x(60),y(60),z(60)]
plot3(mKl(1),mKl(2),mKl(3),'o','MarkerSize',10,'MarkerFaceColor','k','MarkerEdgeColor','k')

mKsr=[xr(1),yr(1),zr(1)]
plot3(mKsr(1),mKsr(2),mKsr(3),'o','MarkerSize',10,'MarkerFaceColor','g','MarkerEdgeColor','g')

mKsl=[x(1),y(1),z(1)]
plot3(mKsl(1),mKsl(2),mKsl(3),'o','MarkerSize',10,'MarkerFaceColor','g','MarkerEdgeColor','g')

mKer=[xr(220),yr(220),zr(220)]
plot3(mKer(1),mKer(2),mKer(3),'o','MarkerSize',10,'MarkerFaceColor','r', 'MarkerEdgeColor', 'r')

mKel=[x(221),y(221),z(221)]
plot3(mKel(1),mKel(2),mKel(3),'o','MarkerSize',10,'MarkerFaceColor','r','MarkerEdgeColor','r')

legend('right ear', 'left ear','600 ms R', '600 ms L', 'start R', 'start L', 'end R', 'end L','Location','northeastoutside')

%saveas(gcf,['\\batserve.win.ad.jhu.edu\data1\Angie\Ike\FIgure',dayday,trial,'.png'])

%


%curveL=animatedline('LineWidth',2,'Color',[0 0 1]);
% curveR=animatedline('LineWidth',2,'Color',[1 0 0]);

% view(-171,71)
% 
% axis vis3d;


%hold on;
% 
% for i=1:length(x)
%     addpoints(curveL,x(i),y(i),z(i));
%     addpoints(curveR,xr(i),yr(i),zr(i))
%     headL=scatter3(x(i),y(i),z(i));
%     headR=scatter3(xr(i),yr(i),zr(i));
%     drawnow
%     pause(0.01);
%     delete(headL);
%     delete(headR);
% end

