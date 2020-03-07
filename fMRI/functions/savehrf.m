function [] = savehrf(data, subject, type)
%SAVEHRF Standardizes saving of simualted hrf
%   Detailed explanation goes here
    dlmwrite(fullfile('exports', 'hrf', [subject, '_', type, '.txt']), data);
end

