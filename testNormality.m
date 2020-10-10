function testNormality (x,y)
%todo halfwaypoint limits
for idx = 1 : size(x,1)
    store(idx)=nansum((x(idx,123-60:123+20)-y(123-60:123+20)).^2);
    store4(idx)=nansum(x(idx,123-60:123+20)-y(123-60:123+20));

end
[h, p] = adtest(store)
[h, p, ci, stats] = ttest(store)
[h, p] = adtest(store4)
[h, p] = ttest(store4)
ranksum(store, zeros(1,1000))
ranksum(store4, zeros(1,1000))


for idx = 1 : size(x,2)
    store3(idx)=ranksum(x(:,idx),repmat(y(idx),1,1000));
end
figure
plot(store3)
mean(store3(123-60:123+20)>0.05)