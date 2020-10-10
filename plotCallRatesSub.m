function [counts, nonbscounts]=plotCallRatesSub(plotStoreCalls,colors,timebased,lineThickness,xlimits)
xlimits(1)=min(1,xlimits(1)-250);
xlimits(2)=xlimits(2)+250;
filterHist=@(x)x(x>xlimits(1)&x<xlimits(2));
for i_cond=1:size(plotStoreCalls,2)
    callRates{i_cond} = cellfun(@(x){x'},plotStoreCalls(:,i_cond));
    callRates{i_cond}=[callRates{i_cond}{:}];
    nonbscounts{i_cond} = smooth(hist(filterHist(cell2mat(callRates{i_cond}')),xlimits(1):xlimits(2)),250)*1000;
    for idx = 1 : 6
        counts{i_cond}(:,idx) = smooth(hist(filterHist(cell2mat(callRates{i_cond}(idx:6:end)')),xlimits(1):xlimits(2)),250)*1000/length(callRates{i_cond}(idx:6:end));
    end
    assert(all(all(~isnan(counts{i_cond}))))
    
    distanceTrack = 300;
    if timebased
        idxarray=xlimits(1):xlimits(2);
    else
        idxarray=atan((smooth(track,12)-1000)/distanceTrack)*180/pi;
    end
    h=area(idxarray(20:end-20),[mean(counts{i_cond}(20:end-20,:),2)-std(counts{i_cond}(20:end-20,:),0,2)/sqrt(6),2*std(counts{i_cond}(20:end-20,:),0,2)/sqrt(6)]);
    h(1).LineStyle='none';
    h(2).LineStyle='none';
    h(1).FaceColor='none';
    h(2).FaceColor=[0.5,0.5,0.5];%colors{i_cond};
    h(2).FaceAlpha=0.35;
    
    plot(idxarray(20:end-20),mean(counts{i_cond}(20:end-20,:),2),'Color',colors{i_cond},'LineWidth',lineThickness)
end
