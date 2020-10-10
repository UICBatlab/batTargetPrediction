addpath track_data
load('data/shoutsControls.mat')% first load shouts.mat
namesBat = {{'B','24'},{'W', '80'}};
correction={-1, -8};
dates = {{'20200511', '20200512', '20200514','20200515','20200516'}};
dates{2} = dates{1}(2:end);
conditions = {'B-L','B-S', 'BnF', 'Catch'};
plotStore = cell(length(namesBat),length(conditions));
plotStoreCalls = cell(length(namesBat),length(conditions));

lengthTrack = 1500;
for idx_bat = 1 : length(namesBat)
    idx_bat
    tempdump = {};
    for idx_day = 1 : length(dates{idx_bat})
        idx_day;
        if true
            clear raw
            [~, ~, raw.(['d' dates{idx_bat}{idx_day}(7:8)])] = xlsread(['data/controls/' dates{idx_bat}{idx_day} '_PreyTracking.xlsx'], namesBat{idx_bat}{2});
            
            mainFolder = 'data/controls/';
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
            temp = csv_data;
            plotStore{idx_bat,find(strcmp(fieldaccessor, conditions))}(end+1,:)=bsxfun(@(x,y)x./y,temp(:,3)-temp(:,6)+correction{idx_bat},temp(:,1)-temp(:,4))';
            plotStoreCalls{idx_bat,find(strcmp(fieldaccessor, conditions))}(end+1,:)=metastore(idx_bat, idx_day,idx);
            tempdump{end+1}=temp;
            clear temp
        end
    end
end
%%
[track, track_fast, track_slow, track_stop, track_slowcont, track_backforth] = track_data();    