function y = calcFVUsuperPrep(allBatsMimic,allBatsMimicP,allBats,idx,startpoint,endpoint)
forFVU = nanmean(allBatsMimic{idx}(:, startpoint:endpoint) - allBats{idx}(:, startpoint:endpoint));
forFVUP = nanmean(allBatsMimicP{idx}(:, startpoint:endpoint) - allBats{idx}(:, startpoint:endpoint));
y = {forFVU, forFVUP};
