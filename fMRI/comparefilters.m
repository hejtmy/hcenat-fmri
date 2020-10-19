TR = 3;

load([pwd '\data\comps_20181204_121411.mat']);
% The components are in pulse X component X participant format

% The csv exports are in a pulse X participant format - similarly to the
% comps with the exception of the second dimension being separated
nSubjects = size(comps, 3);

filteredComponentsOriginal = nan(size(comps)); % This is not being exported
for i = 1:nSubjects
    % Applying butter filter on 2D matrix
    filteredComponentsOriginal(:,:,i) = butter_filter(comps(:,:,i),...
        TR, 0.009, 0.05);
end

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
