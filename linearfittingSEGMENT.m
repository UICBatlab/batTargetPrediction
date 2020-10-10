function [coeffs1]=linearfittingSEGMENT(segbehindocc)
fitResults1 = polyfit(1:length(segbehindocc),segbehindocc,1);
coeffs1{1} = fitResults1;