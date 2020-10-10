function [h,leftlimit,rightlimit]=miroTrackingPlot(options)
track=cellfun(@(x){x(1:10:end)},options.track);
distanceTrack = 300;
semFactor = 1;

idxarray=cellfun(@(x){atan((x-1000)/distanceTrack)*180/pi},track);
idxarray_store = idxarray;
magicfun=@(x)(x(:,options.Nstart:options.Nstart+options.Nplot-1))*180/pi;
if options.unbend
    magicfun = @(x)magicfun(x)-idxarray{1};
    idxarray_store={zeros(size(idxarray_store{1}))};
end
if options.timebased
    idxarray=cellfun(@(x){1:10:options.Nplot*10},track);
end

for idx_bat = 1 : length(options.namesBat)
    if options.subplotting
        subplot(3,4,(idx_bat-1)*4+plotColumn+1);
    end
    hStore = miroTrackingPlotSub(options.plotStore, options.conditions, options.colors,idxarray,idx_bat,magicfun,options.unbend,options.timebased,options.titleFlag,options.xlimits,idxarray_store,options.lineThickness,options.halfwaypoint);
    if options.occluder
       [h,leftlimit,rightlimit]=plotOccluder(options.unbend, options.timebased,options.track,1000,0.1,1);
    end
    %set(gca,'FontSize',15)
    for idx_legend = 1 : length(options.conditions)
        N(idx_legend)=sum(sum((~isnan(magicfun(options.plotStore{idx_bat,idx_legend})))))/options.Nplot;
        if options.showN
            conditions_plot{idx_legend}=[options.conditions{idx_legend}, ' ' , num2str(round(N(idx_legend)))];
        else
            conditions_plot{idx_legend}=[options.conditions{idx_legend}];
        end
    end
    legend([conditions_plot, {options.labelTrack,'occlusion'}],'Location','northwest','AutoUpdate', 'off')
    
    legend boxoff
    for i_conditions = 1 : length(options.conditions)
        nansem = @(x)nanstd(x,0,1)./sqrt(sum(~isnan(x)))*semFactor;
        mftemp = magicfun(options.plotStore{idx_bat,i_conditions});
        mftemp(all(feval(@(x)x==0|isnan(x),diff(mftemp,1,2)),2),:)=[];
        h=area(idxarray{1},[nanmean(mftemp)-nansem(mftemp)+1000;2*nansem(mftemp)]');
        h(1).LineStyle='none';
        h(2).LineStyle='none';
        h(1).FaceColor='none';
        h(2).FaceColor=[0.5,0.5,0.5];%colors{i_conditions};
        h(2).FaceAlpha=0.35;
    end
    miroTrackingPlotSub(options.plotStore, options.conditions, options.colors,idxarray,idx_bat,magicfun,options.unbend,options.timebased,options.titleFlag,options.xlimits,idxarray_store,options.lineThickness,options.halfwaypoint);
    
end
