function pVal=pValues(a,b,track,occluder,occluderFactor,helperfunction,testfunction)
for idx = 1 : min(size(a,2),size(b,2))
    nanfilter=@(x)x(~isnan(x));
    if all(isnan(a(:,idx))) || all(isnan(b(:,idx)))
        pVal(idx)=NaN;
    else
        switch testfunction
            case 'ttest2'
                [~, pVal(idx)] = ttest2(nanfilter(helperfunction(a(:,idx))),nanfilter(helperfunction(b(:,idx))));
            case 'ttest'
                [~, pVal(idx),ci, stats] = ttest(nanfilter(helperfunction(a(:,idx)-b(idx))))
            
            case 'ranksum'   
                 pVal(idx) = ranksum(nanfilter(helperfunction(a(:,idx))),nanfilter(helperfunction(b(:,idx))));
            case 'signrank'
                 notnans = ~(isnan(helperfunction(a(:,idx))) | isnan(helperfunction(a(:,idx))));
                 pVal(idx) = signrank(helperfunction(a(notnans,idx)),helperfunction(b(notnans,idx)));
            otherwise
                error('testfunction not supported');
        end
           
    end
end
figure
if occluder
    plotOccluder(0,1,track,0,occluderFactor,1);
end
hold on
plot (repelem(pVal,1,100))
plot([repelem(0.05,1,length(pVal)*100)],'r')
ylim([0,1]);

prod(pVal(~isnan(pVal)));