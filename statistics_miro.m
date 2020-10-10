function statistics_miro(automode, bestshift, bestshift_dumb, optionsCGAB)
miroTracking()
%%
majorlims = [65, 130];
selectBats=[1:3,5];
lengthintime = 2000;
if ~exist('automode','var')
    [RSS_store, RSS, bestshift, bestshift_dumb, RSS_dumb, RSS_dumb_shift] = findModelParams(1,conditions, track, track, plotStore, plotStoreCalls, majorlims, lengthintime, selectBats);
end

%% figure 1 combined
%close all

figure('Position',[500 500 396 508])
subplot(2,1,1)
bestshiftnonP = bestshift_dumb;
optionsCGAB.lengthintime = 2000;
if ~exist('automode','var')
    optionsCGAB.usePings = 5;
end
[getAllBats,getAllBatsMimic,~,getAllBatsMimicP] = createGetAllBats(conditions, track,plotStore(selectBats,:),plotStoreCalls(selectBats,:), optionsCGAB);
getAllBatsMimicS = cellfun(@(x){x + bestshiftnonP}, getAllBatsMimic);
getAllBatsMimicPS = cellfun(@(x){x + (bestshift(optionsCGAB.usePings) - 1)/1000 * pi / 180}, getAllBatsMimicP);
options = struct(...
    'namesBat',{{'all'}},...
    'conditions',{{'real head angle','catch'}},...
    'plotStore',{[getAllBats(1), getAllBats(3)]},...
    'Nstart',1,...
    'Nplot',200,...
    'plotColumn',0,...
    'track',{{track}},...
    'xlimits',majorlims*10,... %[-70,50]
    'timebased',true,...
    'subplotting',false,...
    'occluder',false,...
    'titleFlag',false,...
    'unbend',false,...
    'colors',{{[1,155,99]/255,[116,22,247]/255,[116,22,247]/255,[116,22,247]/255}},...
    'lineThickness',1,...
    'labelTrack','target',...
    'showN',false, ...
    'halfwaypoint', find(track>1000,1));

miroTrackingPlot(options);
%xlim([580 1360])

selectCondition=[1,3];
plotCallRates(plotStoreCalls(selectBats,selectCondition),track,options.colors(selectCondition),options.xlimits, options.timebased,options.lineThickness,options.occluder,options.unbend,options.halfwaypoint);

figure
options.unbend=true;
options.conditions={'difference to target (head angle)'};
options.plotStore = options.plotStore(1);
miroTrackingPlot(options);
title('B-L vs track')
ylim([950 1050])


figure
options.unbend=false;
options.conditions={'Offset Non-Predictive Model','Offset Predictive Model', 'Offset Non-Predictive Model Shift', 'Offset Predictive Model Shift'};
options.plotStore={...
    getAllBatsMimic{1} - getAllBats{1}(:, 1:200), ...
    getAllBatsMimicP{1} - getAllBats{1}(:, 1:200), ...
    getAllBatsMimicS{1} - getAllBats{1}(:, 1:200), ...
    getAllBatsMimicPS{1} - getAllBats{1}(:, 1:200)};
options.track={repmat(1000,1,2000)};
options.colors={[144, 12, 63]/255,[255, 88, 51]/255,[255, 0, 51]/255, [144, 0, 250]/255};
options.labelTrack='data';
miroTrackingPlot(options);
title('B-L vs models')
%xlim([580 1250])
ylim([950 1050])
disp('FVU values B-L vs models')
calcFVUsuper(getAllBatsMimic, getAllBatsMimicP, getAllBats, 1, majorlims(1), majorlims(2));
calcFVUsuper(getAllBatsMimicS, getAllBatsMimicPS, getAllBats, 1, majorlims(1), majorlims(2));

pValues(getAllBats{1}(:,1:200),atan((track(1:10:end)-1000)/300),{track},options.occluder,0,@(x)x,'ttest');
testNormality(getAllBats{1}(:,1:200),atan((track(1:10:end)-1000)/300))
clear ad_store ci stats
splitter = 1
getallbatstemp = getAllBats{1}(:,1:200)-atan((track(1:10:end)-1000)/300);
for idx = 1:200/splitter
    flatten=@(x)x(:);
    [~, ad_store(idx,1)]=adtest(flatten(getAllBats{1}(:,(idx-1)*splitter+1:idx*splitter)));
    [~, ad_store(idx,3),ci{idx},stats{idx}]=ttest(flatten(getallbatstemp(:,(idx-1)*splitter+1:idx*splitter,:)))
    
end

figure; plot(ad_store(:,3))    
%%
if ~exist('automode','var')
    forplotting=[zeros(1,20001);cell2mat(RSS_store')];
    forplotting(1,:)=min(forplotting(:));
    leftlimit = 5000;
    rightlimit = 7000;
    forplotting(:,[1:leftlimit-1, rightlimit+1:end])=min(forplotting(:));
    imagesc(log(forplotting));
    xlim([leftlimit, rightlimit]);
    ylim([2,10]);
    forplotting=[zeros(1,20001);cell2mat(RSS_store')];
    forplotting(1,:)=min(forplotting(:));
    
    leftlimit = 1;
    rightlimit = 20000;
    forplotting(:,[1:leftlimit-1, rightlimit+1:end])=min(forplotting(:));
    figure
    imagesc(log(forplotting));
    xlim([leftlimit, rightlimit]);
    ylim([2,10]);
    figure;
    plot([2:10],cellfun(@(x)x(1),RSS_store(2:end)));
    figure;
    
    for shift = 0:0.001:20
        RSS_dumb(round(shift * 1000 + 1)) = calcFVUsuper(getAllBatsMimic, getAllBatsMimic, getAllBats, 1, majorlims(1), majorlims(2), shift * pi / 180, false);
    end
    plot(RSS_dumb);
end
%% figure 2
figure('Position',[500 500 441 508])
subplot(2,1,1)
options.xlimits = [580,1300];
options.occluder=true;
options.labelTrack='target';
options.track={track};
options.colors={[1,155,99]/255,[247,157,22]/255,[116,22,247]/255,[116,22,247]/255};
leftlimit_pre = 6210;
rightlimit_pre = 8210;
plotStoreCallsOccluderNormal = cellfun(@(x){cellfun(@(y){y(y<leftlimit_pre/10|y>rightlimit_pre/10)},x)},plotStoreCalls);
[~,getAllBatsMimicOccluderNormal,~,getAllBatsMimicOccluderNormalP] = createGetAllBats(conditions, track,plotStore(selectBats,:),plotStoreCallsOccluderNormal(selectBats,:), optionsCGAB);
getAllBatsMimicOccluderNormalS = cellfun(@(x){x + bestshiftnonP}, getAllBatsMimicOccluderNormal);
getAllBatsMimicOccluderNormalPS = cellfun(@(x){x + (bestshift(optionsCGAB.usePings) - 1)/1000 * pi / 180}, getAllBatsMimicOccluderNormalP);

options.plotStore = [getAllBats(1), getAllBats(2)];
options.conditions = {'unoccluded','occluded'};

[~, leftlimit,rightlimit]=miroTrackingPlot(options);
options.colors={[1,155,99]/255,[247,157,22]/255,[116,22,247]/255,[247,157,22]/255};
selectCondition=1:2;

[vocalizations, nonbs_vocalizations] = plotCallRates(plotStoreCalls(selectBats,selectCondition),options.track,options.colors(selectCondition),options.xlimits,options.timebased,options.lineThickness,options.occluder,options.unbend,options.halfwaypoint);

figure
subplot(2,1,1);

hold on

options.unbend = true;
miroTrackingPlot(options);
%xlim([580 1250])
ylim([950 1050])
plotCallRates(plotStoreCalls(selectBats,selectCondition),options.track,options.colors(selectCondition),options.xlimits,options.timebased,options.lineThickness,options.occluder,options.unbend,options.halfwaypoint);
%xlim([580 1250])
options.occluder = false;



figure
options.unbend=false;
options.conditions={'Offset Non-Predictive Model','Offset Predictive Model', 'Offset Non-Predictive Model Shift', 'Offset Predictive Model Shift'};
options.plotStore={ ...
    getAllBatsMimicOccluderNormal{2} - getAllBats{2}(:, 1:200),...
    getAllBatsMimicOccluderNormalP{2} - getAllBats{2}(:, 1:200),...
    getAllBatsMimicOccluderNormalS{2} - getAllBats{2}(:, 1:200),...
    getAllBatsMimicOccluderNormalPS{2} - getAllBats{2}(:, 1:200)};

options.track={repmat(1000,1,2000)};
options.colors={[144, 12, 63]/255,[255, 88, 51]/255,[255, 0, 51]/255, [144, 0, 250]/255};
options.labelTrack='data';
miroTrackingPlot(options);
title('O-L vs models')
%xlim([580 1250])
ylim([950 1050])
disp('FVU values O-L vs model')
calcFVUsuper(getAllBatsMimicOccluderNormal,getAllBatsMimicOccluderNormalP,getAllBats,2,majorlims(1),majorlims(2));
calcFVUsuper(getAllBatsMimicOccluderNormalS,getAllBatsMimicOccluderNormalPS,getAllBats,2,majorlims(1),majorlims(2));
testNormality2(getAllBats{1},getAllBats{2},atan((track(1:10:end)-1000)/300))
rd = [720,970]
[p,h]=adtest(cellfun(@(x)length(x(x>rd(1)&x<rd(2))),cat(1,plotStoreCalls{[1:3,5],2})))
[p,h]=adtest(cellfun(@(x)length(x(x>rd(1)&x<rd(2))),cat(1,plotStoreCalls{[1:3,5],1})))
[p,h]=ttest2(cellfun(@(x)length(x(x>rd(1)&x<rd(2))),cat(1,plotStoreCalls{[1:3,5],1})),(cellfun(@(x)length(x(x>rd(1)&x<rd(2))),cat(1,plotStoreCalls{[1:3,5],2}))))
clear ad_store ci stats
splitter = 5
for idx = 1:1550/splitter
    flatten=@(x)x(:);
    [~, ad_store(idx,1)]=adtest(flatten(vocalizations{1}((idx-1)*splitter+1:idx*splitter,:)));
    [~, ad_store(idx,2)]=adtest(flatten(vocalizations{2}((idx-1)*splitter+1:idx*splitter,:)));
    [~, ad_store(idx,3),ci{idx},stats{idx}]=ttest2(flatten(vocalizations{1}((idx-1)*splitter+1:idx*splitter,:)),flatten(vocalizations{2}((idx-1)*splitter+1:idx*splitter,:)));
    
end

figure; plot(ad_store(:,3))

%% figure 3
figure;
subplot(2,1,1);
title('Velocity Change Fast');
hold on
options.conditions={'unoccluded MF','occluded MF'};
options.xlimits=[580,2100];
options.track={track_fast};
options.Nplot=270;
options.occluder=true;
options.plotStore=[getAllBats(4), getAllBats(6)];
options.colors={[1,155,99]/255,[247,157,22]/255,[116,22,247]/255,[116,22,247]/255};
options.halfwaypoint = find(track_fast>1000,1);
[~,leftlimit_fast,rightlimit_fast]=miroTrackingPlot(options);
bootstrapN = 10;
inflectionpoints=detdelaysBatadjust(getAllBats,1:2,leftlimit_fast,rightlimit_fast,bootstrapN,250);
disp('mean diff')
disp((nanmean(inflectionpoints(2,:))-nanmean(inflectionpoints(1,:)))*10);
disp('std diff')
disp(sum(nanstd(inflectionpoints')*10)/sqrt(2))
options.colors={[1,155,99]/255,[247,157,22]/255,[247,157,22]/255,[247,157,22]/255};

vocalizations_fast = plotCallRates(plotStoreCalls(selectBats,[4,6]),options.track,options.colors,options.xlimits, options.timebased,options.lineThickness,options.occluder,options.unbend,options.halfwaypoint);

figure
subplot(2,1,1);
title('Mismatch Fast');
hold on

options.unbend = true;
options.labelTrack='target';
miroTrackingPlot(options);
%xlim([580 2150])
ylim([950 1050])
plotCallRates(plotStoreCalls(selectBats,[4,6]),options.track,options.colors,options.xlimits, options.timebased,options.lineThickness,options.occluder,options.unbend,options.halfwaypoint);
options.unbend = false;
%xlim([580 2150])

options.occluder = false;

plotStoreCallsOccluderFast = cellfun(@(x){cellfun(@(y){y(y<leftlimit_fast/10|y>rightlimit_fast/10)},x)},plotStoreCalls);
optionsCGAB.lengthintime = 2700;
[~,getAllBatsMimicFast,~,getAllBatsMimicFastP] = createGetAllBats(conditions, track_fast,plotStore(selectBats,:),plotStoreCalls(selectBats,:),optionsCGAB);
[~,getAllBatsMimicOccluderFast,~,getAllBatsMimicOccluderFastP] = createGetAllBats(conditions, track_fast,plotStore(selectBats,:),plotStoreCallsOccluderFast(selectBats,:),optionsCGAB);
getAllBatsMimicFastS = cellfun(@(x){x + bestshiftnonP}, getAllBatsMimicFast);
getAllBatsMimicFastPS = cellfun(@(x){x + (bestshift(optionsCGAB.usePings) - 1)/1000 * pi / 180}, getAllBatsMimicFastP);
getAllBatsMimicOccluderFastS = cellfun(@(x){x + bestshiftnonP}, getAllBatsMimicOccluderFast);
getAllBatsMimicOccluderFastPS = cellfun(@(x){x + (bestshift(optionsCGAB.usePings) - 1)/1000 * pi / 180}, getAllBatsMimicOccluderFastP);





figure
options.unbend=false;
options.conditions={'Offset Non-Predictive Model','Offset Predictive Model', 'Offset Non-Predictive Model Shift', 'Offset Predictive Model Shift'};
options.plotStore={...
    getAllBatsMimicFast{4} - getAllBats{4}(:, 1:270), ...
    getAllBatsMimicFastP{4} - getAllBats{4}(:, 1:270), ...
    getAllBatsMimicFastS{4} - getAllBats{4}(:, 1:270), ...
    getAllBatsMimicFastPS{4} - getAllBats{4}(:, 1:270)};

options.track={repmat(1000,1,2500)};
options.colors={[144, 12, 63]/255,[255, 88, 51]/255,[255, 0, 51]/255, [144, 0, 250]/255};
options.labelTrack='data';
miroTrackingPlot(options);
title('B-Fast vs models')
%xlim([580 2150])
ylim([950 1050])
disp('FVU values B-Fast vs model first half')
calcFVUsuper(getAllBatsMimicFast,getAllBatsMimicFastP,getAllBats,4,58,161);
calcFVUsuper(getAllBatsMimicFastS,getAllBatsMimicFastPS,getAllBats,4,58,161);

disp('FVU values B-Fast vs model second half')
calcFVUsuper(getAllBatsMimicFast,getAllBatsMimicFastP,getAllBats,4,162,215);
calcFVUsuper(getAllBatsMimicFastS,getAllBatsMimicFastPS,getAllBats,4,162,215);





figure
options.unbend=false;
options.conditions={'Offset Non-Predictive Model','Offset Predictive Model', 'Offset Non-Predictive Model Shift', 'Offset Predictive Model Shift'};
options.plotStore={ ...
    getAllBatsMimicOccluderFast{6} - getAllBats{6}(:, 1:270), ...
    getAllBatsMimicOccluderFastP{6} - getAllBats{6}(:, 1:270) ...
    getAllBatsMimicOccluderFastS{6} - getAllBats{6}(:, 1:270) ...
    getAllBatsMimicOccluderFastPS{6} - getAllBats{6}(:, 1:270)};
options.track={repmat(1000,1,2500)};
options.colors={[144, 12, 63]/255,[255, 88, 51]/255,[255, 0, 51]/255, [144, 0, 250]/255};
options.labelTrack='data';
miroTrackingPlot(options);
title('O-Fast vs models')
%xlim([580 2150])
ylim([950 1050])

disp('FVU values O-Fast vs model first half')
calcFVUsuper(getAllBatsMimicOccluderFast,getAllBatsMimicOccluderFastP,getAllBats,6,58,178);
calcFVUsuper(getAllBatsMimicOccluderFastS,getAllBatsMimicOccluderFastPS,getAllBats,6,58,178);

disp('FVU values O-Fast vs model second half')
calcFVUsuper(getAllBatsMimicOccluderFast,getAllBatsMimicOccluderFastP,getAllBats,6,179,215);
calcFVUsuper(getAllBatsMimicOccluderFastS,getAllBatsMimicOccluderFastPS,getAllBats,6,179,215);



%% figure 4
figure;
subplot(2,1,1);
title('Velocity Change Slow');
hold on
options.conditions={'unoccluded MS','occluded MS'};
options.xlimits=[580,2600];
options.track={track_slow};
options.Nplot=380;
options.occluder=true;
options.plotStore=[getAllBats(5), getAllBats(7)];
options.halfwaypoint = find(track_slow>1000,1);

options.colors={[1,155,99]/255,[247,157,22]/255,[247,157,22]/255};
[h,leftlimit_slow,rightlimit_slow]=miroTrackingPlot(options);
bootstrapN = 10;
inflectionpoints=detdelaysBatadjust(getAllBats,3:4,leftlimit_slow,rightlimit_slow,bootstrapN,170);
disp('mean diff')
disp((nanmean(inflectionpoints(2,:))-nanmean(inflectionpoints(1,:)))*10);
disp('std diff')
disp(sum(nanstd(inflectionpoints')*10)/sqrt(2))
options.colors={[1,155,99]/255,[247,157,22]/255};
vocalizations_slow = plotCallRates(plotStoreCalls(selectBats,[5,7]),options.track,options.colors,options.xlimits, options.timebased,options.lineThickness,options.occluder,options.unbend,options.halfwaypoint);

figure
subplot(2,1,1);
title('Mismatch Slow');
hold on

options.unbend = true;
options.labelTrack='target';
miroTrackingPlot(options);
%xlim([580 2350])
plotCallRates(plotStoreCalls(selectBats,[5,7]),options.track,options.colors,options.xlimits, options.timebased,options.lineThickness,options.occluder,options.unbend,options.halfwaypoint);
options.unbend = false;
%xlim([580 2600])

options.occluder = false;
plotStoreCallsOccluderSlow = cellfun(@(x){cellfun(@(y){y(y<leftlimit_slow/10|y>rightlimit_slow/10)},x)},plotStoreCalls);
optionsCGAB.lengthintime = 3800;

[~,getAllBatsMimicOccluderSlow,~,getAllBatsMimicOccluderSlowP] = createGetAllBats(conditions, track_slow,plotStore(selectBats,:),plotStoreCallsOccluderSlow(selectBats,:),optionsCGAB);
[~,getAllBatsMimicSlow,~,getAllBatsMimicSlowP] = createGetAllBats(conditions, track_slow,plotStore(selectBats,:),plotStoreCalls(selectBats,:),optionsCGAB);
getAllBatsMimicSlowS = cellfun(@(x){x + bestshiftnonP}, getAllBatsMimicSlow);
getAllBatsMimicSlowPS = cellfun(@(x){x + (bestshift(optionsCGAB.usePings) - 1)/1000 * pi / 180}, getAllBatsMimicSlowP);
getAllBatsMimicOccluderSlowS = cellfun(@(x){x + bestshiftnonP}, getAllBatsMimicOccluderSlow);
getAllBatsMimicOccluderSlowPS = cellfun(@(x){x + (bestshift(optionsCGAB.usePings) - 1)/1000 * pi / 180}, getAllBatsMimicOccluderSlowP);



figure
options.unbend=false;
options.conditions={'Offset Non-Predictive Model','Offset Predictive Model', 'Offset Non-Predictive Model Shift', 'Offset Predictive Model Shift'};
options.plotStore={...
    getAllBatsMimicSlow{5} - getAllBats{5}(:, 1:380), ...
    getAllBatsMimicSlowP{5} - getAllBats{5}(:, 1:380), ...
    getAllBatsMimicSlowS{5} - getAllBats{5}(:, 1:380), ...
    getAllBatsMimicSlowPS{5} - getAllBats{5}(:, 1:380)};
options.track={repmat(1000,1,2500)};
options.colors={[144, 12, 63]/255,[255, 88, 51]/255,[255, 0, 51]/255, [144, 0, 250]/255};
options.labelTrack='data';
miroTrackingPlot(options);
title('B-Slow vs models')
%xlim([580 2350])
ylim([950 1050])
disp('FVU values B-Slow vs model first half')
calcFVUsuper(getAllBatsMimicSlow,getAllBatsMimicSlowP,getAllBats,5,58,180);
calcFVUsuper(getAllBatsMimicSlowS,getAllBatsMimicSlowPS,getAllBats,5,58,180);

disp('FVU values B-Slow vs model second half')
calcFVUsuper(getAllBatsMimicSlow,getAllBatsMimicSlowP,getAllBats,5,181,235);
calcFVUsuper(getAllBatsMimicSlowS,getAllBatsMimicSlowPS,getAllBats,5,181,235);


figure
options.unbend=false;
options.conditions={'Offset Non-Predictive Model','Offset Predictive Model', 'Offset Non-Predictive Model Shift', 'Offset Predictive Model Shift'};
options.plotStore={ ...
    getAllBatsMimicOccluderSlow{7} - getAllBats{7}(:, 1:380), ...
    getAllBatsMimicOccluderSlowP{7} - getAllBats{7}(:, 1:380), ...
    getAllBatsMimicOccluderSlowS{7} - getAllBats{7}(:, 1:380), ...
    getAllBatsMimicOccluderSlowPS{7} - getAllBats{7}(:, 1:380)};
options.track={repmat(1000,1,2500)};
options.colors={[144, 12, 63]/255,[255, 88, 51]/255,[255, 0, 51]/255, [144, 0, 250]/255};
options.labelTrack='data';
miroTrackingPlot(options);
title('O-Slow vs models')
%xlim([580 2350])
ylim([950 1050])

disp('FVU values O-Slow vs model first half')
calcFVUsuper(getAllBatsMimicOccluderSlow,getAllBatsMimicOccluderSlowP,getAllBats,7,58,190);
calcFVUsuper(getAllBatsMimicOccluderSlowS,getAllBatsMimicOccluderSlowPS,getAllBats,7,58,190);

disp('FVU values O-Slow vs model second half')
calcFVUsuper(getAllBatsMimicOccluderSlow,getAllBatsMimicOccluderSlowP,getAllBats,7,191,235);
calcFVUsuper(getAllBatsMimicOccluderSlowS,getAllBatsMimicOccluderSlowPS,getAllBats,7,191,235);

options.occluder = false;

%% figure 6
figure('Position',[500 500 396 508])
subplot(2,1,1)
options = struct(...
    'namesBat',{{'all'}},...
    'conditions',{{'simple motion', 'Catch', 'Velocity Change Fast', 'Velocity Change Slow'}},...
    'plotStore',{[getAllBats(1), getAllBats(3), getAllBats(4), getAllBats(5)]},...
    'Nstart',1,...
    'Nplot',800,...
    'plotColumn',0,...
    'track',{{track,track_fast,track_slow}},...
    'xlimits',[650,3000],... %[-70,50]
    'timebased',true,...
    'subplotting',false,...
    'occluder',false,...
    'titleFlag',false,...
    'unbend',false,...
    'colors',{{[1,155,99]/255,[116,22,247]/255,[116,22,0]/255,[0,22,247]/255}},...
    'lineThickness',1,...
    'labelTrack','target',...
    'showN',false, ...
    'halfwaypoint',0);

miroTrackingPlot(options);
%xlim([580 1360])

selectCondition=[1,3,4,5];
plotCallRates(plotStoreCalls(selectBats,selectCondition),track,options.colors,options.xlimits, options.timebased,options.lineThickness,options.occluder,options.unbend,options.halfwaypoint);
%% stat differences
disp('BLvsOL')
calcFVUsuper(getAllBatsMimicPS,getAllBatsMimicOccluderNormalPS,getAllBats,2,majorlims(1),majorlims(2));%Bl OL
disp('BL PvsNP')
calcFVUsuper(getAllBatsMimicPS,getAllBatsMimicOccluderNormal,getAllBats,1,majorlims(1),majorlims(2)); %BL PvsN
disp('OL PvsNP')
calcFVUsuper(getAllBatsMimicOccluderNormalPS,getAllBatsMimicOccluderNormal,getAllBats,2,majorlims(1),majorlims(2));%OL PvsN
disp('Fast U 1st PvsNP')
calcFVUsuper(getAllBatsMimicFastPS,getAllBatsMimicFast,getAllBats,4,58,161);
disp('Fast U 2nd PvsNP')
calcFVUsuper(getAllBatsMimicFastPS,getAllBatsMimicFast,getAllBats,4,162,215);
disp('Fast O 1st PvsNP')
calcFVUsuper(getAllBatsMimicOccluderFastPS,getAllBatsMimicOccluderFast,getAllBats,6,58,178);
disp('Fast O 2nd PvsNP')
calcFVUsuper(getAllBatsMimicOccluderFastPS,getAllBatsMimicOccluderFast,getAllBats,6,179,215);
disp('Slow U 1st PvsNP')
calcFVUsuper(getAllBatsMimicSlowPS,getAllBatsMimicSlow,getAllBats,5,58,180);
disp('Slow U 2nd PvsNP')
calcFVUsuper(getAllBatsMimicSlowPS,getAllBatsMimicSlow,getAllBats,5,181,235);
disp('Slow O 1st PvsNP')
calcFVUsuper(getAllBatsMimicOccluderSlowPS,getAllBatsMimicOccluderSlow,getAllBats,7,58,190);
disp('Slow O 2nd PvsNP')
calcFVUsuper(getAllBatsMimicOccluderSlowPS,getAllBatsMimicOccluderSlow,getAllBats,7,191,235);
%%
save(sprintf('getAllBats_%0.2u.mat', optionsCGAB.usePings) ,'getAllBats*');



%%
clear kedx kedx2

for idx = 4:7 % 'B-MF', 'B-MS', 'O-MF', 'O-MS'
    if mod(idx,2)==0
        offset = 74;
    else
        offset =1;
    end
    vocalizations_here=[vocalizations_fast(1), vocalizations_slow(1), vocalizations_fast(2), vocalizations_slow(2)];
    temp=nanmean(atan(getAllBats{idx}));
    temp2=nanmean(vocalizations_here{idx-3}');
    temp2=temp2(100:10:end);
    if mod(idx,2)==0
        temp=temp(offset:208);
        temp2=temp2(offset:208);
    else
        temp=temp(offset:250);
        temp2=temp2(offset:250);
    end
    temp=temp-linspace(temp(1),temp(end),length(temp));
    temp2=temp2-linspace(temp2(1),temp2(end),length(temp2));
    [~,kedx]=min(temp(150-offset:200-offset));
    [~,kedx2]=min(temp2(100-offset:200-offset));
    disp([conditions{idx} ' : ' num2str(10*(kedx+149)) ', '  num2str(10*(kedx2+99))]);
end
for idx = 4:7 % 'B-MF', 'B-MS', 'O-MF', 'O-MS'
    
    for idx2 = 1 : 6
        
        if mod(idx,2)==0
            offset = 74;
        else
            offset =1;
        end
        vocalizations_here=[vocalizations_fast(1), vocalizations_slow(1), vocalizations_fast(2), vocalizations_slow(2)];
        temp=nanmean(atan(getAllBats{idx}(idx2:6:end,:)));
        temp2=vocalizations_here{idx-3}';
        temp2=nanmean(temp2(setdiff(1:6,idx2),:));
        temp2=temp2(100:10:end);
        if mod(idx,2)==0
            temp=temp(offset:208);
            temp2=temp2(offset:208);
        else
            temp=temp(offset:250);
            temp2=temp2(offset:250);
        end
        temp=temp-linspace(temp(1),temp(end),length(temp));
        temp2=temp2-linspace(temp2(1),temp2(end),length(temp2));
        [~,kedx(idx2)]=min(temp(150-offset:200-offset));
        [~,kedx2(idx2)]=min(temp2(100-offset:200-offset));
        
    end
    disp([conditions{idx} ' sem : ' num2str(10*std(kedx+149)/sqrt(6)) ', '  num2str(10*std(kedx2+99)/sqrt(6))]);
    
end
%% stats for suppl 2
majorlims = [65, 130];

calcFVUsuper(getAllBatsMimicOccluderNormalPS, getAllBatsMimicPS, getAllBats, 1, majorlims(1), majorlims(2));

calcFVUsuper(getAllBatsMimic, getAllBatsMimicPS, getAllBats, 1, majorlims(1), majorlims(2));
calcFVUsuper(getAllBatsMimicOccluderNormal, getAllBatsMimicOccluderNormalPS, getAllBats, 2, majorlims(1), majorlims(2));

clc
calcFVUsuper(getAllBatsMimicFast,getAllBatsMimicFastPS,getAllBats,4,58,161);
calcFVUsuper(getAllBatsMimicFast,getAllBatsMimicFastPS,getAllBats,4,162,215);
clc

calcFVUsuper(getAllBatsMimicOccluderFast,getAllBatsMimicOccluderFastPS,getAllBats,6,58,178);
calcFVUsuper(getAllBatsMimicOccluderFast,getAllBatsMimicOccluderFastPS,getAllBats,6,179,215);



calcFVUsuper(getAllBatsMimicSlow,getAllBatsMimicSlowPS,getAllBats,5,58,180);
calcFVUsuper(getAllBatsMimicSlow,getAllBatsMimicSlowPS,getAllBats,5,181,235);

calcFVUsuper(getAllBatsMimicOccluderSlow,getAllBatsMimicOccluderSlowPS,getAllBats,7,58,190);
calcFVUsuper(getAllBatsMimicOccluderSlow,getAllBatsMimicOccluderSlowPS,getAllBats,7,191,235);
end