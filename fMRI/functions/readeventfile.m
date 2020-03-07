function out = readeventfile(pth, format)
%READEVENTFILE Summary of this function goes here
%   Detailed explanation goes here
fid = fopen(pth);
if(fid < 0), return; end
out = textscan(fid,format,'HeaderLines',1,'Delimiter',',');
end

