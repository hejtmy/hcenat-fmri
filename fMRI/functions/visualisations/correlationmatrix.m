function [] = correlationmatrix(corrMatrix, graphtitle, xlabs, ylabs)
%AVERAGECORRELATION Summary of this function goes here
%   Detailed explanation goes here
    imagesc(corrMatrix);
    colorbar;
    title(graphtitle);
    xticks(1:numel(xlabs));
    xticklabels(xlabs);
    xtickangle(65);
    yticks(1:numel(ylabs));
    yticklabels(ylabs);
end

