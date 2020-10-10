function statistics_miro_control(automode, bestshift, bestshift_dumb, optionsCGAB)
miroTracking_control()
figure('Position',[500 500 396 508])
subplot(2,1,1)
selectBats2=[1,2];
optionsCGAB.lengthintime = 4000;
if ~exist('automode','var')
    optionsCGAB.usePings = 5;
    load('bestshift')
end
bestshiftnonP = bestshift_dumb;

lims_slowcont = round([find(track_slowcont>=track(650),1), find(track_slowcont>=track(1300),1)]/10+0.5);

[getAllBats2,getAllBatsMimicSlowCont,~,getAllBatsMimicSlowContP] = createGetAllBats(conditions, track_slowcont,plotStore(selectBats2,:),plotStoreCalls(selectBats2,:),optionsCGAB);
getAllBatsMimicSlowContS = cellfun(@(x){x + bestshiftnonP}, getAllBatsMimicSlowCont);
getAllBatsMimicSlowContPS = cellfun(@(x){x + (bestshift(optionsCGAB.usePings) - 1)/1000 * pi / 180}, getAllBatsMimicSlowContP);

options = struct(...
    'namesBat',{{'all'}},...
    'conditions',{{'B-S'}},...
    'plotStore',{getAllBats2(2)},...
    'Nstart',1,...
    'Nplot',400,...
    'plotColumn',0,...
    'track',{{track_slowcont}},...
    'xlimits',[650,4500],... %[-70,50]
    'timebased',true,...
    'subplotting',false,...
    'occluder',false,...
    'titleFlag',false,...
    'unbend',false,...
    'colors',{{[255, 88, 51]/255,[255, 88, 51]/255,[255, 88, 51]/255,[255, 10, 51]/255}},...
    'lineThickness',1,...
    'labelTrack','target',...
    'showN',false, ...
    'halfwaypoint', find(track_slowcont>1000,1));

miroTrackingPlot(options);
%xlim([580 1360])

selectCondition=[2];
plotCallRates(plotStoreCalls(selectBats2,selectCondition),track,options.colors(selectCondition),options.xlimits, options.timebased,options.lineThickness,options.occluder,options.unbend,options.halfwaypoint);
figure
options.unbend=true;
options.conditions={'difference to target (head angle)'};
miroTrackingPlot(options);
title('B-S vs track')
ylim([950 1050])

 
figure
options.unbend=true;
options.conditions={'Non-Predictive Model','Predictive Model'}%, 'Offset Non-Predictive Model Shift', 'Offset Predictive Model Shift'};
options.plotStore={...
    getAllBatsMimicSlowCont{2} - getAllBats2{2}(:, 1:400), ...
    getAllBatsMimicSlowContPS{2} - getAllBats2{2}(:, 1:400)};

options.track={repmat(1000,1,4000)};
options.colors={[237, 38, 151]/255,[127, 11, 222]/255,[255, 88, 51]/255,[255, 10, 51]/255};;
options.labelTrack='data';
miroTrackingPlot(options);
title('B-S vs models')
xlim([651 3991])
ylim([950 1050])
disp('FVU values B-S vs models') 
calcFVUsuper(getAllBatsMimicSlowCont, getAllBatsMimicSlowContP, getAllBats2, 2, lims_slowcont(1), lims_slowcont(2));
calcFVUsuper(getAllBatsMimicSlowContS, getAllBatsMimicSlowContPS, getAllBats2, 2, lims_slowcont(1), lims_slowcont(2));
%% figure 2
figure('Position',[500 500 396 508])
subplot(2,1,1)
selectBats2=[1,2];
optionsCGAB.lengthintime = 4610;
bestshiftnonP = bestshift_dumb;

lims_backforth = round([find(track_backforth>=track(650),1), find(track_backforth>=track(1300),1)]/10+0.5);

[getAllBats2,getAllBatsMimicBackForth,~,getAllBatsMimicBackForthP] = createGetAllBats(conditions, track_backforth,plotStore(selectBats2,:),plotStoreCalls(selectBats2,:),optionsCGAB);
getAllBatsMimicBackForthS = cellfun(@(x){x + bestshiftnonP}, getAllBatsMimicBackForth);
getAllBatsMimicBackForthPS = cellfun(@(x){x + (bestshift(optionsCGAB.usePings) - 1)/1000 * pi / 180}, getAllBatsMimicBackForthP);

options = struct(...
    'namesBat',{{'all'}},...
    'conditions',{{'BnF'}},...
    'plotStore',{getAllBats2(3)},...
    'Nstart',1,...
    'Nplot',461,...
    'plotColumn',0,...
    'track',{{track_backforth}},...
    'xlimits',[650,4500],... %[-70,50]
    'timebased',true,...
    'subplotting',false,...
    'occluder',false,...
    'titleFlag',false,...
    'unbend',false,...
    'colors',{{[255, 88, 51]/255,[116,255,247]/255,[255, 88, 51]/255,[255, 10, 51]/255}},...
    'lineThickness',1,...
    'labelTrack','target',...
    'showN',false, ...
    'halfwaypoint', find(track_backforth>1000,1));

miroTrackingPlot(options);
%xlim([580 1360])

selectCondition=[3];
plotCallRates(plotStoreCalls(selectBats2,selectCondition),track,options.colors(selectCondition),options.xlimits, options.timebased,options.lineThickness,options.occluder,options.unbend,options.halfwaypoint);
figure
options.unbend=true;
options.conditions={'difference to target (head angle)'};
miroTrackingPlot(options);
title('BnF vs track')
ylim([950 1050])

 
figure
options.unbend=true;

options.conditions={'Non-Predictive Model','Predictive Model'};

options.plotStore={...
    getAllBatsMimicBackForth{2} - getAllBats2{2}(:, 1:461), ...
    getAllBatsMimicBackForthPS{2} - getAllBats2{2}(:, 1:461)};

options.track={repmat(1000,1,4610)};
options.colors={[237, 38, 151]/255,[127, 11, 222]/255,[255, 88, 51]/255,[255, 10, 51]/255};
options.labelTrack='data';
miroTrackingPlot(options);
title('BnF vs models')
%xlim([580 1250])
ylim([890 1050])
disp('FVU values BnF vs models 910ms:3910ms') 
calcFVUsuper(getAllBatsMimicBackForth, getAllBatsMimicBackForthP, getAllBats2, 3, lims_backforth(1), lims_backforth(2));
calcFVUsuper(getAllBatsMimicBackForthS, getAllBatsMimicBackForthPS, getAllBats2, 3, lims_backforth(1), lims_backforth(2));
disp('FVU values BnF vs models first part 0ms:2500ms') 

calcFVUsuper(getAllBatsMimicBackForth, getAllBatsMimicBackForthP, getAllBats2, 3, 1, 250);
calcFVUsuper(getAllBatsMimicBackForthS, getAllBatsMimicBackForthPS, getAllBats2, 3, 1, 250);
disp('FVU values BnF vs models second part 2500ms:3910ms') 
calcFVUsuper(getAllBatsMimicBackForth, getAllBatsMimicBackForthP, getAllBats2, 3, 250, lims_backforth(2));
calcFVUsuper(getAllBatsMimicBackForthS, getAllBatsMimicBackForthPS, getAllBats2, 3, 250, lims_backforth(2));

%%
disp('Slow Slow PvsNP')
calcFVUsuper(getAllBatsMimicSlowContPS, getAllBatsMimicSlowCont, getAllBats2, 2, lims_slowcont(1), lims_slowcont(2));
disp('BnF U all PvsNP')
calcFVUsuper(getAllBatsMimicBackForthPS, getAllBatsMimicBackForth, getAllBats2, 3, lims_backforth(1), lims_backforth(2));
disp('BnF U 1st PvsNP')
calcFVUsuper(getAllBatsMimicBackForthPS, getAllBatsMimicBackForth, getAllBats2, 3, 1, 250);
disp('BnF U 2nd PvsNP')
calcFVUsuper(getAllBatsMimicBackForthPS, getAllBatsMimicBackForth, getAllBats2, 3, 250, lims_backforth(2));

%%
save(sprintf('getAllBatsControl_%0.2u.mat', optionsCGAB.usePings) ,'getAllBats*');

end
