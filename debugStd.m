figure;subplot(2,1,1);scatter(plotStore{1}(:,83),atan(plotStore{1}(:,83)));subplot(2,1,2);scatter(plotStore{2}(:,83),atan(plotStore{2}(:,83)));
nanfilter=@(x)x(~isnan(x));
a=nanfilter(plotStore{1}(:,83));
b=nanfilter(plotStore{2}(:,83));
[mean(a), mean(b), mean(atan(a)), mean(atan(b))]
[std(a),std(b),std(atan(a)),std(atan(b))]
scatterrand=@(x,y)scatter(x+rand(size(x))/5-0.1,y);
figure;subplot(2,1,1);scatterrand((a-mean(a)).^2,(atan(a)-mean(atan(a))).^2);subplot(2,1,2);scatterrand((b-mean(b)).^2,(atan(b)-mean(atan(b))).^2)