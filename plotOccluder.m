function [h,leftlimit,rightlimit]=plotOccluder(unbend, timebased,track,offset,factor,thinning)
for idx_track = 1 : length(track)
    track{idx_track} = track{idx_track}(1:thinning:end);
    leftC=-55; % occludor was curved so size was adjusted to represent reality during experiments and not initially intended length
    rightC=-37;
    if ~unbend && ~ timebased
        leftlimit = atan(leftC/30)*180/pi; 
        rightlimit = atan(rightC/30)*180/pi;
    end
    if timebased
        leftlimit=find(track{idx_track}>leftC*10+1000,1)*10; 
        rightlimit=find(track{idx_track}>rightC*10+1000,1)*10;
    end
    if isempty(rightlimit)
        rightlimit = length(track{idx_track})*10;
    end
    h1=80;
    h=patch([leftlimit*factor,leftlimit*factor, rightlimit*factor,rightlimit*factor],[offset-h1,offset+h1,offset+h1,offset-h1],[0.5,0.5,0.5],'HandleVisibility','off');
    h.FaceAlpha=0.5;
    h.LineStyle='none';
end
end