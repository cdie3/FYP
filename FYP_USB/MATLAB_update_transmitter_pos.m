%add relevant functions
addpath('1_MATLAB_functions') ;addpath('2_MATLAB_variables'); addpath('3_Datafit_testing');

%input whether the transmitter has been updated using MeshLab
tr_up = char(inputdlg('Has the transmitter position been updated using Meshlab? [y/n] '));
if tr_up == 'y'
    prev = char(inputdlg('Do you want to use the previously saved MeshLab project settings? [y/n] '));
    if prev == 'y'
        load prev
    else
        filename = char(inputdlg('What is the name of the MeshLab file? '));
        filename = sprintf('%s.mlp',filename);
        tr_pos = inputdlg('What is the file position of the transmitter file in MeshLab? ');
        tr_pos = str2num(cell2mat(tr_pos));
    end
    %find the transformation matrix of the transmitter
    mlstruct = parseXML(filename);
    testing = mlstruct(2).Children(2).Children(tr_pos*2+2).Children(2).Children.Data  ;
    transformation = cell2mat(cellfun(@str2num, mat2cell(testing, ones(size(testing,1),1), size(testing,2)),'UniformOutput',0));

    transmitter = [0,-100,20];  %transmitter midpoint location
    transmitter_n = [0,10,0];   %transmitter norm

    transformation = inv(transformation);

    t = transmitter; %transmitter position
    tp = transmitter+transmitter_n; %point infront of the transmitter along the norm
    %translate
    tpt = tp*transformation(1:3,1:3)+[transformation(1,4),transformation(2,4),transformation(3,4)];
    tt = t*transformation(1:3,1:3)+[transformation(1,4),transformation(2,4),transformation(3,4)];
    %new transmitter position and norm
    transmitter_n = (tpt-tt)/norm(tpt-tt);
    transmitter = transmitter*transformation(1:3,1:3)+[transformation(1,4),transformation(2,4),transformation(3,4)];
    save('2_MATLAB_variables\prev.mat','filename','tr_pos')
else
    transmitter = inputdlg('What is the transmitter position in [x,y,z]? ');
    transmitter_n = inputdlg('What is the transmitter normal in [x,y,z]? ');
end
save('2_MATLAB_variables\transmitter.mat','transmitter','transmitter_n')
clear all

