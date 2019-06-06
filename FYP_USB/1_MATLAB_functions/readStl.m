function [f,v,n] = readStl(file)
%check the format of the file and run ascii or binary protocol dependent on
%input
if ~exist(file,'file')
        error(['File ''%s'' not found. If the file is not on MATLAB''s path' ...
               ', be sure to specify the full path to the file.'], file);
end

format = stlGetFormat(file);

if (strcmp(format,'ascii'))
    [v, f, n] = stlReadAscii(file);
elseif (strcmp(format,'binary'))
    [v, f, n] = stlReadBinary(file);
end

end

function format = stlGetFormat(fileName)
%STLGETFORMAT identifies the format of the STL file and returns 'binary' or
%'ascii'

fid = fopen(fileName);
% Check the file size first, since binary files MUST have a size of 84+(50*n)
fseek(fid,0,1);         % Go to the end of the file
fidSIZE = ftell(fid);   % Check the size of the file
if rem(fidSIZE-84,50) > 0
    format = 'ascii';
else
    % Files with a size of 84+(50*n), might be either ascii or binary...
    % Read first 80 characters of the file.
    % For an ASCII file, the data should begin immediately (give or take a few
    % blank lines or spaces) and the first word must be 'solid'.
    % For a binary file, the first 80 characters contains the header.
    % It is bad practice to begin the header of a binary file with the word
    % 'solid', so it can be used to identify whether the file is ASCII or
    % binary.
    fseek(fid,0,-1); % go to the beginning of the file
    header = strtrim(char(fread(fid,80,'uchar')')); % trim leading and trailing spaces
    isSolid = strcmp(header(1:min(5,length(header))),'solid'); % take first 5 char
    fseek(fid,-80,1); % go to the end of the file minus 80 characters
    tail = char(fread(fid,80,'uchar')');
    isEndSolid = strfind(tail,'endsolid');
    
    % Double check by reading the last 80 characters of the file.
    % For an ASCII file, the data should end (give or take a few
    % blank lines or spaces) with 'endsolid <object_name>'.
    % If the last 80 characters contains the word 'endsolid' then this
    % confirms that the file is indeed ASCII.
    if isSolid && isEndSolid
        format = 'ascii';
    else
        format = 'binary';
    end
end
fclose(fid);
end 

function [v, f, n] = stlReadAscii(file)

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
% Francis Esmonde-White, May 2010
end


function [f,v,n] = stlReadBinary(file)
% STLREAD imports geometry from an STL file into MATLAB.
%    FV = STLREAD(FILENAME) imports triangular faces from the ASCII or binary
%    STL file idicated by FILENAME, and returns the patch struct FV, with fields
%    'faces' and 'vertices'.
%
%    [F,V] = STLREAD(FILENAME) returns the faces F and vertices V separately.
%
%    [F,V,N] = STLREAD(FILENAME) also returns the face normal vectors.
%
%    The faces and vertices are arranged in the format used by the PATCH plot
%    object.

% Copyright 2011 The MathWorks, Inc.

    if ~exist(file,'file')
        error(['File ''%s'' not found. If the file is not on MATLAB''s path' ...
               ', be sure to specify the full path to the file.'], file);
    end
    
    fid = fopen(file,'r');    
    if ~isempty(ferror(fid))
        error(lasterror); %#ok
    end
    
    M = fread(fid,inf,'uint8=>uint8');
    fclose(fid);
    
    F = [];
    V = [];
    N = [];
    
    if length(M) < 84
        error('MATLAB:stlread:incorrectFormat', ...
              'Incomplete header information in binary STL file.');
    end
    
    % Bytes 81-84 are an unsigned 32-bit integer specifying the number of faces
    % that follow.
    numFaces = typecast(M(81:84),'uint32');
    %numFaces = double(numFaces);
    if numFaces == 0
        warning('MATLAB:stlread:nodata','No data in STL file.');
        return
    end
    
    T = M(85:end);
    F = NaN(numFaces,3);
    V = NaN(3*numFaces,3);
    N = NaN(numFaces,3);
    
    numRead = 0;
    while numRead < numFaces
        % Each facet is 50 bytes
        %  - Three single precision values specifying the face normal vector
        %  - Three single precision values specifying the first vertex (XYZ)
        %  - Three single precision values specifying the second vertex (XYZ)
        %  - Three single precision values specifying the third vertex (XYZ)
        %  - Two unused bytes
        i1    = 50 * numRead + 1;
        i2    = i1 + 50 - 1;
        facet = T(i1:i2)';
        
        n  = typecast(facet(1:12),'single');
        v1 = typecast(facet(13:24),'single');
        v2 = typecast(facet(25:36),'single');
        v3 = typecast(facet(37:48),'single');
        
        n = double(n);
        v = double([v1; v2; v3]);
        
        % Figure out where to fit these new vertices, and the face, in the
        % larger F and V collections.        
        fInd  = numRead + 1;        
        vInd1 = 3 * (fInd - 1) + 1;
        vInd2 = vInd1 + 3 - 1;
        
        V(vInd1:vInd2,:) = v;
        F(fInd,:)        = vInd1:vInd2;
        N(fInd,:)        = n;
        
        numRead = numRead + 1;
    end
    [f,v,n] = [F,V,N];

end

