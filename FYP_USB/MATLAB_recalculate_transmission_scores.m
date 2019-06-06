%calculation of transmission scores
clear all
close all
clc
addpath('1_MATLAB_functions') 

%find the correct file
filename = char(input('Please input the file name of the stl file to be processed: '));
filename = sprintf('%s.stl',filename);

[v, f, n] = readStl(filename);

load polynomials

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
    load transmitter
end
save('2_MATLAB_variables\transmitter.mat','transmitter','transmitter_n')

%define the color scheme
color_scheme = str2num(cell2mat(input('To use [white,yellow,green] as colorscheme type 1, to use [red,yellow,green] type 2: ')));

m = zeros(1,3);
faceinf = zeros(length(f),1);

for i =1:length(f)
    a = v(f(i,1),:);    b = v(f(i,2),:);    c = v(f(i,3),:); %find the points
    if norm(a-transmitter)<75&&norm(b-transmitter)<75&&norm(c-transmitter)<75
    ac = c-a; ab = b-a;     %vectors describing the plane
    abXac = cross(ab,ac);   %cross product to find the midpoint
    m(1,:) = a + (cross(abXac,ab)*norm(ac,2).^2 + cross(ac,abXac )*norm(ab,2).^2) / (2*norm(abXac,2).^2) ;
    distance = norm(transmitter-m(1,:),2);
    theta = acosd(dot(-transmitter_n,n(i,:))/(norm(transmitter_n,2)*norm(n(i,:),2)));
    alpha = acosd(dot(-transmitter_n,transmitter-m(1,:))/(norm(transmitter_n,2)*norm(transmitter-m(1,:),2))); 
    off_axis = sind(alpha)*distance;
    on_axis = abs(cosd(angle))*distance;
    dist_ll = sf_lole(theta,off_axis);
    dist_ln = sf_lo(theta,off_axis);
    
    if (on_axis<dist_ll)
        faceinf(i) = 1;
    elseif(on_axis>=dist_ll && on_axis<dist_ln)
        faceinf(i) = 2;
    else
        faceinf(i) = 3;
    end
    else 
        faceinf(i) = 3;
    end
end
%write the STL-files with their corresponding color
addpath('4_STL_MATLAB_output')
if color_scheme == 1
    lole = find(faceinf==1);
    f_lole = f(lole,:);
    stlwrite('4_STL_MATLAB_output\lole.stl',f_lole,v,'FaceColor',[170 255 0])

    lo = find(faceinf==2);
    f_lo = f(lo,:);
    stlwrite('4_STL_MATLAB_output\lo.stl',f_lo,v,'FaceColor',[255 255 0])

    notr = find(faceinf==3);
    f_notr = f(notr,:);
    stlwrite('4_STL_MATLAB_output\notr.stl',f_notr,v);
elseif color_scheme ==2
    lole = find(faceinf==1);
    f_lole = f(lole,:);
    stlwrite('4_STL_MATLAB_output\lole.stl',f_lole,v,'FaceColor',[170 255 0])

    lo = find(faceinf==2);
    f_lo = f(lo,:);
    stlwrite('4_STL_MATLAB_output\lo.stl',f_lo,v,'FaceColor',[255 255 0])

    notr = find(faceinf==3);
    f_notr = f(notr,:);
    stlwrite('4_STL_MATLAB_output\notr.stl',f_notr,v,'FaceColor',[255 0 0])   
else 
    fprintf('Error')
end

