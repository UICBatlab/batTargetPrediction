function adjust_ticks(halfwaypoint)
xticks(halfwaypoint-5000:500:halfwaypoint+5000);
xticklabels(arrayfun(@(x){num2str(x)},-5000:500:5000));
