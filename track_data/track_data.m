function [track, track_fast, track_slow, track_stop, track_slowcont, track_backforth] = track_data()
% track normal
accel = zeros(1,200);
accel(1:25) = 1;
accel(176:200) = -1;
track = repelem(cumsum(cumsum(accel)),10);
track = track / max(track) * 1575;
% track mismatch fast
accel = zeros(1,100);
accel(1:25) = 0.34285;
n=60;
accel(100-n+1:100) = -0.34285*25/n;
accel(126:150)=0.34285;
accel(246:270)=-0.34285;
track_fast = repelem(cumsum(cumsum(accel)),10);
track_fast = track_fast / max(track_fast) * 1575;
% track missmatch slow
accel = zeros(1,100);
accel(1:25) = 0.34285;
n=60;
accel(100-n+1:100) = -0.34285*25/n;
accel(136:160)=0.183;
accel(356:380)=-0.183;
track_slow = repelem(cumsum(cumsum(accel)),10);
track_slow = track_slow / max(track_slow) * 1575;
% track stop
track_stop=track_fast(1:2000); 
track_stop(1100:end)=track_stop(1100);
% track slow continuous
accel = zeros(1,400);
accel(1:25) = 1;
accel(376:400) = -1;
track_slowcont = repelem(cumsum(cumsum(accel)),10);
track_slowcont = track_slowcont / max(track_slowcont) * 1575;
% track back and forth
accel = zeros(1,400);
time = 1;
accel(time:time+24) = 0.23255;
time = time + 110;
accel(time-24:time) = -0.23255;
time = time + 20;
accel(time:time+24) = -0.23255;
time = time + 110;
accel(time-24:time) = 0.23255;
time = time + 20;
accel(time:time+24) = 0.341;
time = time + 200;
accel(time-24:time) = -0.341;

track_backforth = repelem(cumsum(cumsum(accel)),10);
track_backforth = track_backforth / max(track_backforth) * 1575;