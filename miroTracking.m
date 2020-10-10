addpath track_data
load('data/shouts.mat')% first load shouts.mat
namesBat = {{'B','24'},{'G','38'},{'W','80'},{'DB','8'},{'W','28'}};
correction={-1, 0, -8, 0, 0}; % ear correction per bat
dates = {{'20180309', '20180311', '20180312', '20180313','20180315','20180316'},...
    {'20180912','20180913','20180914','20180916','20180917','EMPTYDAY','20180919','20180920','20180921','20180923','20180924','20180925'}};
dates{3}=dates{2};
dates{4}={'20190429','20190430','20190501','20190502','20190503','20190505','20190507','20190508','20190509','20190511','20190512','20190513'};
dates{5}=[dates{4}(1:end-1) {'20190514','20190515'}];
conditions = {'B-L','O-L', 'Catch', 'B-MF', 'B-MS', 'O-MF', 'O-MS','O-stop','B-stop'};
plotStore = cell(length(namesBat),length(conditions));
plotStoreCalls = cell(length(namesBat),length(conditions));

for idx_bat = 1 : length(namesBat)
    idx_bat
    tempdump = {};
    if idx_bat == 1
        [~, xls_info] = xlsfinfo('data/Blue24 Data.xlsx');
        xls_info=xls_info(2:end); %disregard first two sheets
        xls_info{1}='March 9th';
        clear raw
        for idx = 1 : length(xls_info)
            particle0 ='';
            if idx == 1
                particle0='0';
            end
            [~, ~, raw.(['d' particle0 xls_info{idx}(7:end-2)])] = xlsread('data/Blue24 Data.xlsx',idx+1);
        end
        mainFolder = 'data/Miro tracking/';
        particleT = '';
        qualityindicator = 6;
        typeindicator = 2;
        mirofileidx=1;
    end
    for idx_day = 1 : length(dates{idx_bat})
        idx_day;
        if idx_bat>1 && idx_day==6
            continue
        end
        
        if idx_bat>1
            clear raw
            [~, ~, raw.(['d' dates{idx_bat}{idx_day}(7:8)])] = xlsread(['data/SmallFlightRoom/' dates{idx_bat}{idx_day} '_PreyTracking.xlsx'],namesBat{idx_bat}{2});
            
            mainFolder = 'data/green38andwhite80/';
            particleT = [filesep namesBat{idx_bat}{1} namesBat{idx_bat}{2}];
            if idx_bat > 3
                mainFolder= ['data/' ];
            end
            if idx_bat == 4
                particleT='/B8';
            end
            qualityindicator = 9;
            typeindicator = 4;
            mirofileidx=3;
        end
        badcases = {'Wrong distance', 'Don''t Use', 'Not good','VG; mic was covered', 'DO NOT USE', 'Bad', 'Ok (not focused)','Useless','N','N ','M'};
        raww = raw.(['d' dates{idx_bat}{idx_day}(7:8)]);
        micsis = raww(2:end,mirofileidx);
        for idx = 1 : length(micsis)
            if all(cellfun(@(x)any(isnan(x)),raww(idx+1,1:6)))
                continue;
            end
            assert(any(strcmp([badcases, {'VG','E','G','Avg','OK','Excellent', 'Very good','Good','Average','Ok','Not great catch trial','Y'}],raww{idx+1,qualityindicator}))||any(isnan(raww{idx+1,qualityindicator})));
            secondaryproblematic = {'not much calling','wrong distance, no audio','It was 1m DO NOT USE','Camera triggered twice','Tether not attached, don’t use','Video didn''t save'};
            
            if any(isnan(raww{idx+1,qualityindicator}))&&size(raww,2)>qualityindicator
                if ~isempty(strfind(raww{idx+1,qualityindicator+1}, 'Tether not attached, do'))
                    raww{idx+1,qualityindicator+1} = 'Tether not attached, don’t use';
                end
                assert(any(strcmp(secondaryproblematic,raww{idx+1,qualityindicator+1}))||any(isnan(raww{idx+1,qualityindicator+1})));
            end
            if any(strcmp(badcases,raww{idx+1,qualityindicator}))||(size(raww,2)>qualityindicator && any(strcmp(secondaryproblematic,raww{idx+1,qualityindicator+1})))
                continue
            end
            if idx_bat>1 && isnan(raww{idx+1,qualityindicator-1}) %video done field empty
                continue;
            end
            if isempty(metastore(idx_bat, idx_day,idx))
                continue
            end
            fieldaccessor = strrep(strrep(raww{idx+1,typeindicator},'B-Catch','Catch'),'Stop','stop');
            if idx_bat == 1 && idx_day == 1 && length(raww{idx+1,2})<3
                fieldaccessor = ['B-', fieldaccessor];
            end
            if ~(any(strcmp(fieldaccessor, conditions)))
                continue
            end
            
            if (idx_bat ==1 && ((idx_day == 2 && (idx < 5 || idx == 27 || idx == 30)) || (idx_day ==5 && idx == 3) || (idx_day==6 && (idx==26||idx==29||idx==32))))
                continue;
            end
            if idx_bat ==4 && idx_day==5 && idx >23
                continue;
            end
            if idx_bat == 5 && idx_day==1
                continue;
            end
            particleThere = particleT;
            if idx_bat == 2 && idx_day==2
                particleThere = '/W38';
            end
            csv_data = csvread([mainFolder dates{idx_bat}{idx_day} particleThere '/trial_' num2str(micsis{idx}) '_xyzpts.csv'],1,0);
            columnsToSelect = [1,4];
            temp = csv_data;
            %             if (find(strcmp(strrep(raww{idx+1,typeindicator},'B-Catch','Catch'), conditions)))==1 && idx~=12
            %                 continue
            %             end
            
            plotStore{idx_bat,find(strcmp(fieldaccessor, conditions))}(end+1,:)=bsxfun(@(x,y)x./y,temp(:,3)-temp(:,6)+correction{idx_bat},temp(:,1)-temp(:,4))';
            plotStoreCalls{idx_bat,find(strcmp(fieldaccessor, conditions))}(end+1,:)=metastore(idx_bat, idx_day,idx);
            tempdump{end+1}=temp;
            clear temp
        end
    end
    allears = cell2mat(tempdump((cellfun(@(x)min(size(x)),tempdump)))');
    nanstd(sum((allears(:,1:3)-allears(:,4:6)).^2,2))
    nanmean(sum((allears(:,1:3)-allears(:,4:6)).^2,2))
end
%%
[track, track_fast, track_slow, track_stop] = track_data();
