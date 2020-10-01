load([pwd '\data\comps_20181204_121411.mat']);

%The csv exports are in a pulse X participant format - similarly to the
%comps with the exception of the second dimension being separated

pthComps = fullfile(pwd, 'exports', 'components');
if ~exist(pthComps), mkdir(pthComps); end;

for i = 1:size(comps, 2)
    out = squeeze(comps(:, 1, :));
    pthComp = fullfile(pthComps, strcat('component_', string(i), '.csv'));
    dlmwrite(pthComp, out, 'delimiter', ',');
end
