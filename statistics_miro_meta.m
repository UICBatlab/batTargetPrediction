automode = true;
bestshift = zeros(10,1);
bestshift_dumb = 0;
for idx = 2 : 10
    optionsCGAB.usePings = idx;
    statistics_miro(automode, bestshift, bestshift_dumb, optionsCGAB)
    close all
    statistics_miro_control(automode, bestshift, bestshift_dumb, optionsCGAB)
    close all
end
%%
[track, track_fast, track_slow, track_stop, track_slowcont, track_backforth] = track_data();
majorlims = [65, 130];
selectBats=[1:3,5];
selectBats2=[1,2];
lims_slowcont = round([find(track_slowcont>=track(650),1), find(track_slowcont>=track(1300),1)]/10+0.5);
lims_backforth = round([find(track_backforth>=track(650),1), find(track_backforth>=track(1300),1)]/10+0.5);

%%
for idx = 2 : 10
load(sprintf('getAllBats_%0.2u.mat', idx));
load(sprintf('getAllBatsControl_%0.2u.mat', idx));

ABC{1}=calcFVUsuperPrep(getAllBatsMimic, getAllBatsMimicP, getAllBats, 1, majorlims(1), majorlims(2));
ABC{2}=calcFVUsuperPrep(getAllBatsMimicOccluderNormal,getAllBatsMimicOccluderNormalP,getAllBats,2,majorlims(1),majorlims(2));
ABC{3}=calcFVUsuperPrep(getAllBatsMimicFast,getAllBatsMimicFastP,getAllBats,4,58,161);
ABC{4}=calcFVUsuperPrep(getAllBatsMimicFast,getAllBatsMimicFastP,getAllBats,4,162,215);
ABC{5}=calcFVUsuperPrep(getAllBatsMimicOccluderFast,getAllBatsMimicOccluderFastP,getAllBats,6,58,178);
ABC{6}=calcFVUsuperPrep(getAllBatsMimicOccluderFast,getAllBatsMimicOccluderFastP,getAllBats,6,179,215);
ABC{7}=calcFVUsuperPrep(getAllBatsMimicSlow,getAllBatsMimicSlowP,getAllBats,5,58,180);
ABC{8}=calcFVUsuperPrep(getAllBatsMimicSlow,getAllBatsMimicSlowP,getAllBats,5,181,235);
ABC{9}=calcFVUsuperPrep(getAllBatsMimicOccluderSlow,getAllBatsMimicOccluderSlowP,getAllBats,7,58,190);
ABC{10}=calcFVUsuperPrep(getAllBatsMimicOccluderSlow,getAllBatsMimicOccluderSlowP,getAllBats,7,191,235);
ABC{11}=calcFVUsuperPrep(getAllBatsMimicSlowCont, getAllBatsMimicSlowContP, getAllBats2, 2, lims_slowcont(1), lims_slowcont(2));
ABC{12}=calcFVUsuperPrep(getAllBatsMimicBackForth, getAllBatsMimicBackForthP, getAllBats2, 3, lims_backforth(1), lims_backforth(2));
ABC=[ABC{:}];
mean(cell2mat(ABC(1:2:end)))
mean(cell2mat(ABC(2:2:end)))
end
%%
disp('FVU values B-L vs models')
calcFVUsuper(getAllBatsMimic, getAllBatsMimicP, getAllBats, 1, majorlims(1), majorlims(2));
disp('FVU values O-L vs model')
calcFVUsuper(getAllBatsMimicOccluderNormal,getAllBatsMimicOccluderNormalP,getAllBats,2,majorlims(1),majorlims(2));
disp('FVU values B-Fast vs model first half')
calcFVUsuper(getAllBatsMimicFast,getAllBatsMimicFastP,getAllBats,4,58,161);
disp('FVU values B-Fast vs model second half')
calcFVUsuper(getAllBatsMimicFast,getAllBatsMimicFastP,getAllBats,4,162,215);
disp('FVU values O-Fast vs model first half')
calcFVUsuper(getAllBatsMimicOccluderFast,getAllBatsMimicOccluderFastP,getAllBats,6,58,178);
disp('FVU values O-Fast vs model second half')
calcFVUsuper(getAllBatsMimicOccluderFast,getAllBatsMimicOccluderFastP,getAllBats,6,179,215);
disp('FVU values B-Slow vs model first half')
calcFVUsuper(getAllBatsMimicSlow,getAllBatsMimicSlowP,getAllBats,5,58,180);
disp('FVU values B-Slow vs model second half')
calcFVUsuper(getAllBatsMimicSlow,getAllBatsMimicSlowP,getAllBats,5,181,235);
disp('FVU values O-Slow vs model first half')
calcFVUsuper(getAllBatsMimicOccluderSlow,getAllBatsMimicOccluderSlowP,getAllBats,7,58,190);
disp('FVU values O-Slow vs model second half')
calcFVUsuper(getAllBatsMimicOccluderSlow,getAllBatsMimicOccluderSlowP,getAllBats,7,191,235);
disp('FVU values B-S vs models')
calcFVUsuper(getAllBatsMimicSlowCont, getAllBatsMimicSlowContP, getAllBats2, 2, majorlims(1), majorlims(2));
