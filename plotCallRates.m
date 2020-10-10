function [counts, nonbscounts] = plotCallRates(plotStoreCalls,track,colors,xlimits,timebased,lineThickness,occluder,unbend, halfwaypoint)
subplot(2,1,2)
hold on
plotCallRatesSub(plotStoreCalls,colors,timebased,lineThickness,xlimits);
ylimstore=ylim;
if occluder
    plotOccluder(unbend, timebased,track,0,1,10);
end
[counts, nonbscounts] = plotCallRatesSub(plotStoreCalls,colors,timebased,lineThickness,xlimits);
ylim(ylimstore);
ylabel('Call rate [Hz]')
xlim(xlimits)
set(gca,'TickDir','out');
set(gca,'LineWidth',lineThickness);
if timebased
    xlabel('Time [ms]');
    adjust_ticks(halfwaypoint);
else
    xlabel('Target angle');
end
