function data = readhrf(subject, type)
%SAVEHRF Standardizes saving of simualted hrf
%   Detailed explanation goes here
    data = dlmread(fullfile('exports', 'hrf', [subject, '_', type, '.txt']));
end