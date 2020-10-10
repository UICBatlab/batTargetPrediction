function testNormality2 (x,y,z)
for idx = 1 : size(x,1)
    store(idx)=nansum((x(idx,123-60:123+20)-z(:,123-60:123+20)).^2);
end
for idx = 1 : size(y,1)
    store2(idx)=nansum((y(idx,123-60:123+20)-z(:,123-60:123+20)).^2);
end
[h, p] = adtest(store)
[h, p] = adtest(store2)
ranksum(store, store2)
[h,p, ci, stats]=ttest2(store, store2)
