function [] = savehrf(data, exportDir, subject, type)
%SAVEHRF Standardizes saving of simualted hrf
%   Detailed explanation goes here
    dlmwrite(fullfile(exportDir, [subject, '_', type, '.txt']), data);
end

