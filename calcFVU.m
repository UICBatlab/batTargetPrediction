function ssres=calcFVU(forFVU,forFVUP,dooutput)


meanhere = nanmean(forFVU);
sstot = nansum((forFVU-meanhere).^2);
ssres = nansum(forFVU.^2);
if dooutput
    disp(ssres)
end
meanhere = nanmean(forFVUP);
sstot = nansum((forFVUP-meanhere).^2);
ssres = nansum(forFVUP.^2);
filternan = @(x)x(~(isnan(forFVUP) | isnan(forFVU)));
if dooutput
    disp(ssres)
    disp('p value')
    [p,h,stats]=ranksum(filternan(forFVU).^2,filternan(forFVUP).^2)
    r= mean(filternan(forFVU).^2>filternan(forFVUP).^2)-mean(filternan(forFVU).^2<filternan(forFVUP).^2)
end
