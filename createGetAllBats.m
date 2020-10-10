function [getAllBats, getAllBatsMimic, plotStoreCallsMimic, getAllBatsMimicP, plotStoreCallsMimicP] = createGetAllBats(conditions, track, plotStore, plotStoreCalls, options)
if ~exist('options','var')
    
end
shiftAngle = 10 * pi / 180;
distanceTrack = 300;
centerpointTrack = 1000;
for selectCondition = 1 : length(conditions)
    counter = 1;
    s=repelem((track-centerpointTrack)/distanceTrack,1,100); % linear movement of target in coordinates analog to head data (x/y)
    s=[zeros(1,1E5),s]; % 1 second of padding
    filterlargeandsmall = @(x)x(x<options.lengthintime&x>0); 
    for idx_bat = 1 : size(plotStore,1)
        for idx_run = 1 : size(plotStoreCalls{idx_bat,selectCondition},1)
            temp = zeros(1,options.lengthintime*100);
            tempP = zeros(1,options.lengthintime*100);
            mic_constant = 0; % no mic position consideration 
            if (size(plotStore,1)==3)&&idx_bat>1 %the next lines only works if we have all three bats
                mic_constant = -2; %in ms, distance to mic divided by speed of sound
            end
            C = round(filterlargeandsmall(plotStoreCalls{idx_bat,selectCondition}{idx_run}+mic_constant)*100)'+1E5;
            %timepoints is the times of all calls in 10us units, offset by 1s
            if isempty(C)
                temp2=temp;
                temp2P=tempP;
            else
                C = [length(s) C]; %add bogus call so that v pred line works correctly
                y = round(1E2*sqrt((s*distanceTrack).^2+distanceTrack^2)/346); %346 is speed of sound in mm/ms at RT, this is the correction for the target position
                y(1:1E5)=0; %first second is just padding
                newtimepoints = round(C+y(C)); % timepoints are in 10us units, it's when the call hits the track
                J = repelem([2 2:(length(newtimepoints)-1)], [newtimepoints(2) diff(newtimepoints(2:end))]);
                J(end : (options.lengthintime*1E2+1E5)) = J(end);
                t = 1 : (options.lengthintime*1E2+1E5);
                temp3 = s(C(J(t-y))+y);
                y(end)=0; 
                vpred = (s(C(J(t-y))+y)-s(C(J(t-y)-1)+y(C(J(t-y)-1)))) ./ (C(J(t-y))-C(J(t-y)-1));
                delimiters = [find(vpred(1:end-1)-vpred(2:end)~=0), length(vpred)]; % last index of left
                for idx = length(delimiters) : -1 : 2
                    vpred(1, delimiters(idx - 1) + 1 : delimiters (idx)) = ...
                        mean(vpred(1, delimiters(max(1,idx-options.usePings+2):idx)));
                end
                
                spred = vpred .* (t-C(J(t-y))-y);
                temp3P = s(C(J(t-y)))+spred;
                temp2 = temp3(1E5+1:end);
                temp2P = temp3P(1E5+1:end);
            end
            plotStoreCallsMimic{idx_bat,selectCondition}(idx_run,:)=temp2(1:1000:end);
            plotStoreCallsMimicP{idx_bat,selectCondition}(idx_run,:)=temp2P(1:1000:options.lengthintime*100);
        end
        xsel = counter:counter+size(plotStore{idx_bat,selectCondition},1)-1;
        ysel = 1:size(plotStore{idx_bat,selectCondition},2);
        getAllBats{selectCondition}(xsel, ysel) = atan(plotStore{idx_bat, selectCondition});
        getAllBatsMimic{selectCondition}(xsel, :) = atan(plotStoreCallsMimic{idx_bat, selectCondition});
        getAllBatsMimicP{selectCondition}(xsel, :) = atan(plotStoreCallsMimicP{idx_bat, selectCondition});
        
        counter=counter+size(plotStore{idx_bat,selectCondition});
    end
    getAllBatsMimic{selectCondition}(getAllBatsMimic{selectCondition}==0)=NaN;
    getAllBatsMimicP{selectCondition}(getAllBatsMimicP{selectCondition}==0)=NaN;
end
