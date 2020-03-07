function [name, type] = getcomponentname(filename)
%GETCOMPONENTNAME Summary of this function goes here
%   Detailed explanation goes here
[~, tok] = regexp(filename, '(.+?)_(.+?_.+?)_.+[.]csv', 'match', 'tokens');
if(numel(tok) > 0)
    type = tok{1}{1};
    name = tok{1}{2};
end
end

