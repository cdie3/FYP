function [v, f, n] = stlReadAscii(file)
if ~exist(file,'file')
        error(['File ''%s'' not found. If the file is not on MATLAB''s path' ...
               ', be sure to specify the full path to the file.'], file);
end
fid   =  fopen(file);

cellcontent = textscan(fid,'%s','delimiter','\n'); % read all the file and put content in cells
content = cellcontent{:}(logical(~strcmp(cellcontent{:},''))); % remove all blank lines
fclose(fid);

% read the vector normals
normals = char(content(logical(strncmp(content,'facet normal',12))));
n = str2num(normals(:,13:end));

% read the vertex coordinates (vertices)
vertices = char(content(logical(strncmp(content,'vertex',6))));
v = str2num(vertices(:,7:end));
nvert = size(vertices,1); % number of vertices
nfaces = sum(strcmp(content,'endfacet')); % number of faces
if (nvert == 3*nfaces)
    f = reshape(1:nvert,[3 nfaces])'; % create faces
end

end

