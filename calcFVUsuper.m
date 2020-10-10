function RSS = calcFVUsuper(allBatsMimic,allBatsMimicP,allBats,idx,startpoint,endpoint, shift,dooutput)
if nargin == 6
    shift = 0;
    dooutput  = true;
end
forFVU = nanmean(allBatsMimic{idx}(:, startpoint:endpoint) - allBats{idx}(:, startpoint:endpoint) + shift);
forFVUP = nanmean(allBatsMimicP{idx}(:, startpoint:endpoint) - allBats{idx}(:, startpoint:endpoint) + shift);
RSS = calcFVU(forFVU,forFVUP,dooutput);
