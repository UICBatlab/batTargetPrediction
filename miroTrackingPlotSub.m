function hStore = miroTrackingPlotSub(plotStore, conditions, colors,idxarray,idx_bat,magicfun,unbend,timebased,titleFlag,xlimits,idxarray_store,lineThickness,halfwaypoint)
hold on
linestart = 65;
for i_conditions = 1 : length(conditions)
    mftemp = magicfun(plotStore{idx_bat,i_conditions});
    mftemp(all(feval(@(x)x==0|isnan(x),diff(mftemp,1,2)),2),:)=[];
    hStore{i_conditions} = plot(idxarray{1},nanmean(mftemp)+1000,'Color',colors{i_conditions},'LineWidth',lineThickness);
    % the +1000 is to make the area command work in an unproblematic
    % fashion
end
if ~unbend && ~ timebased
    plot([-linestart,linestart],[1000-linestart,1000+linestart], '--k', 'LineWidth', lineThickness);
end
if timebased
    for idx_store = 1 : length(idxarray_store)
        flag = {};
        if idx_store>1
            flag={'HandleVisibility','off'};
        end
        plot(1:10:10*length(idxarray_store{idx_store}), idxarray_store{idx_store}+1000, '--k', 'LineWidth', lineThickness,flag{:});
    end
end
if ~ unbend && ~ timebased
    ylabel('Head angle');
end
if ~unbend
    ylim([1000-85,1000+50]);
else
    ylim([1000-50,1000+50]);
end
yticks([1000-45,1000,1000+45]);
yticklabels({'-45','0','45'});
xlim(xlimits);
if ~timebased
    xlabel('Target angle');
    
    % xticks([-45,0,45]);
else
    xlabel('Time [ms]');
    adjust_ticks(halfwaypoint);
end

if ~unbend
    ylabel('Head angle');
end
if titleFlag
    if idx_bat == 1
        title('Blue 24')
        
    end
    if idx_bat == 2
        title('Green 38')
        
    end
    if idx_bat == 3
        title('White 80')
        
    end
end
set(gca,'TickDir','out');
set(gca,'LineWidth',lineThickness);
end