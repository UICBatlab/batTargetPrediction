function [inflectionpoints]=detdelaysBatadjust(getAllBats,triallist,leftlimit,rightlimit,bootstrapN,searchlimit)
inflectionpoints = nan(length(triallist),bootstrapN);
endpoint=round(rightlimit/100);
startpoint=endpoint-100;
for meta_trial = 1:length(triallist)
    trial=triallist(meta_trial);
    if trial==1
        idxtrial=4;
    elseif trial==2
        idxtrial=6;
    elseif trial==3
        idxtrial=5;
    elseif trial==4
        idxtrial=7;
    end
    for idx_bootstrap = 1 : bootstrapN
        bootstrapBats = getAllBats{idxtrial};
        bootstrapBats(idx_bootstrap:bootstrapN:end,:)= [];
        segbehindocc=bootstrapBats(:,startpoint:endpoint);
        
        segment=atan(nanmean(segbehindocc));%added atan
        [coeffs1]=linearfittingSEGMENT(segment);
        y=@(x)(coeffs1{1}(1)*x+coeffs1{1}(2));
        
        
        
        testsection=bootstrapBats(:,round(leftlimit/100:searchlimit));
        %figure;
        pVal=pValues(testsection,y(1:length(testsection)),[],false,0,@(x)x,'ttest2');
        close;
        %figure; plot(testsection');hold on; plot(y(1:length(testsection)))
        [~,inflectionpoint]=min(pVal);
        if ~isempty(inflectionpoint)
            inflectionpoints(meta_trial,idx_bootstrap) = inflectionpoint;
        end
    end
end

