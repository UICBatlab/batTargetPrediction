degraded_donotuse
addpath track_data
load('data/shoutsFast.mat')% first load shouts.mat
namesBat = {{'B','24'}};
dates = {{'20200128', '20200129', '20200203','20200205','20200206'}};
conditions = {'B-L','B-F', 'Catch'};
plotStore = cell(length(namesBat),length(conditions));
plotStoreCalls = cell(length(namesBat),length(conditions));

for idx_bat = 1 : length(namesBat)
    idx_bat
    tempdump = {};
    for idx_day = 1 : length(dates{idx_bat})
        idx_day;
        if true
            clear raw
            [~, ~, raw.(['d' dates{idx_bat}{idx_day}(7:8)])] = xlsread(['data/fastvel/excl/' dates{idx_bat}{idx_day} '_PreyTracking.xlsx']);
            
            mainFolder = 'data/fastvel/';
            particleT = [filesep namesBat{idx_bat}{1} namesBat{idx_bat}{2}];
            qualityindicator = 9;
            typeindicator = 4;
            mirofileidx=3;
        end
        badcases = {'N'};
        raww = raw.(['d' dates{idx_bat}{idx_day}(7:8)]);
        micsis = raww(2:end,mirofileidx);
        for idx = 1 : length(micsis)
            if all(cellfun(@(x)any(isnan(x)),raww(idx+1,1:6)))
                continue;
            end
            assert(any(strcmp([badcases, {'Y'}],raww{idx+1,qualityindicator}))||any(isnan(raww{idx+1,qualityindicator})));
            secondaryproblematic = {};
            
            if any(isnan(raww{idx+1,qualityindicator}))&&size(raww,2)>qualityindicator
                assert(any(strcmp(secondaryproblematic,raww{idx+1,qualityindicator+1}))||any(isnan(raww{idx+1,qualityindicator+1})));
            end
            if any(strcmp(badcases,raww{idx+1,qualityindicator}))||(size(raww,2)>qualityindicator && any(strcmp(secondaryproblematic,raww{idx+1,qualityindicator+1})))
                continue
            end
            if isempty(metastore(idx_bat, idx_day,idx))
                continue
            end
            fieldaccessor = strrep(raww{idx+1,typeindicator},'B-Catch','Catch');
            if ~(any(strcmp(fieldaccessor, conditions)))
                continue
            end
            
            particleThere = particleT;
            filename_csv = [mainFolder dates{idx_bat}{idx_day} particleThere '/trial_' num2str(micsis{idx}) '_xyzpts.csv'];
            if exist(filename_csv, 'file')
                csv_data = csvread(filename_csv,1,0);
            else
                warning(filename_csv);
                continue;
            end
            columnsToSelect = [1,4];
            temp = csv_data;
            %             if (find(strcmp(strrep(raww{idx+1,typeindicator},'B-Catch','Catch'), conditions)))==1 && idx~=12
            %                 continue
            %             end
            correction={-1, 0, -8, 0, 0};
            plotStore{idx_bat,find(strcmp(fieldaccessor, conditions))}(end+1,:)=bsxfun(@(x,y)x./y,temp(:,3)-temp(:,6)+correction{idx_bat},temp(:,1)-temp(:,4))';
            plotStoreCalls{idx_bat,find(strcmp(fieldaccessor, conditions))}(end+1,:)=metastore(idx_bat, idx_day,idx);
            tempdump{end+1}=temp;
            clear temp
        end
    end
end
%%
[track, track_fast, track_slow, track_stop] = track_data();
