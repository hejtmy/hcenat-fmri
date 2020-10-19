TR = 3;

load([pwd '\data\comps_20181204_121411.mat']);
% The components are in pulse X component X participant format

% The csv exports are in a pulse X participant format - similarly to the
% comps with the exception of the second dimension being separated
nSubjects = size(comps, 3);
filteredComponents = nan(size(comps));
for i = 1:nSubjects
    for j = 1:size(comps, 2)
        % Applying butter filter on 1D time series
        filteredComponents(:,j,i) = butter_filter(comps(:,j,i), ...
            TR, 0.009, 0.05);
    end
end

% Difference between 1D and 2D export
sum(sum(sum(abs(filteredComponents-filteredComponentsOriginal))))

%% Preparing folders
pthComps = fullfile(pwd, 'exports', 'components');
if ~exist(pthComps), mkdir(pthComps); end;

pthCompsRaw = fullfile(pthComps, 'raw');
if ~exist(pthCompsRaw), mkdir(pthCompsRaw); end;
pthCompsFiltered = fullfile(pthComps, 'filtered');
if ~exist(pthCompsFiltered), mkdir(pthCompsFiltered); end;

%% Exporting
for i = 1:size(comps, 2)
    out = squeeze(comps(:, i, :));
    outFilt = squeeze(filteredComponents(:, i, :));
    disp(['exporting component ', int2str(i)]);
    dlmwrite(fullfile(pthCompsRaw, ['raw_component_', int2str(i), '.csv']),...
        out, 'delimiter', ',', 'precision', 6);
    dlmwrite(fullfile(pthCompsFiltered, ['filt_component_', int2str(i), '.csv']),...
        outFilt, 'delimiter', ',', 'precision', 6);
end
