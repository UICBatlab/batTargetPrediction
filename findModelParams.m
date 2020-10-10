function [RSS_store, RSS, bestshift, bestshift_dumb, RSS_dumb, RSS_dumb_shift] = findModelParams(conditionselect, conditions, track, track_here, plotStore, plotStoreCalls, majorlims, lengthintime, selectBats)
lims_here = round([find(track_here>=track(majorlims(1)*10),1), find(track_here>=track(majorlims(2)*10),1)]/10+0.5)
optionsCGAB.lengthintime = lengthintime;
for idx = 2 : 10
    optionsCGAB.usePings = idx
    [getAllBats,getAllBatsMimic,~,getAllBatsMimicP] = createGetAllBats(conditions, track,plotStore(selectBats,:),plotStoreCalls(selectBats,:),optionsCGAB);
    for shift = 0:0.001:20
        RSS_store{idx}(round(shift * 1000 + 1)) = calcFVUsuper(getAllBatsMimic, getAllBatsMimicP, getAllBats, conditionselect, lims_here(1), lims_here(2), shift * pi / 180, false);
    end 
    bestshift(idx) = find (RSS_store{idx} == min(RSS_store{idx}));
    RSS(idx) = calcFVUsuper(getAllBatsMimic, getAllBatsMimicP, getAllBats, conditionselect, lims_here(1), lims_here(2),(bestshift(idx)-1)/1000 * pi / 180,false);
    
end

bestshift_dumb = -nanmean(nanmean(getAllBatsMimic{conditionselect}(:,lims_here(1):lims_here(2))-getAllBats{conditionselect}(:,lims_here(1):lims_here(2))));

RSS_dumb = calcFVUsuper(getAllBatsMimic, getAllBatsMimic, getAllBats, conditionselect, lims_here(1), lims_here(2),0, false);
RSS_dumb_shift = calcFVUsuper(getAllBatsMimic, getAllBatsMimic, getAllBats, conditionselect, lims_here(1), lims_here(2),bestshift_dumb, false);