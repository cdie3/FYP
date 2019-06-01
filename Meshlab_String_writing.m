%String writing for meshlab
clear all
close all
clc

%load the surface fit polynomials
load polynomials_22

%Get the position of the transmitter and its normal as input
tr_up = char(inputdlg('Has the transmitter position been updated using Meshlab? [y/n] '));
tr_up = 'y';
if tr_up == 'y'
    tr_pos = inputdlg('What is the file position of the transmitter file in MeshLab? ');
    tr_pos = str2num(cell2mat(tr_pos));
    mlstruct = parseXML('Example.mlp');
    testing = mlstruct(2).Children(2).Children(tr_pos*2+2).Children(2).Children.Data  ;
    transformation = cell2mat(cellfun(@str2num, mat2cell(testing, ones(size(testing,1),1), size(testing,2)),'UniformOutput',0));
    %[v,f,n] = stlGetFaces('transmitter_backup.stl');

    transmitter = [0,-100,20];  %transmitter midpoint location
    transmitter_n = [0,10,0];   %transmitter norm

    testmat = inv(transformation);

    t = transmitter;
    tp = transmitter+transmitter_n;
    tpt = tp*testmat(1:3,1:3)+[transformation(1,4),transformation(2,4),transformation(3,4)];
    tt = t*testmat(1:3,1:3)+[transformation(1,4),transformation(2,4),transformation(3,4)];
    transmitter_n = (tpt-tt)/norm(tpt-tt);
    transmitter = transmitter*testmat(1:3,1:3)+[transformation(1,4),transformation(2,4),transformation(3,4)];

    save('transmitter.mat','transmitter','transmitter_n')
    clear mlstruct t testing testmat tp tpt tr_pos tr_up transformation tt
else
    transmitter = inputdlg('What is the transmitter position in [x,y,z]? ');
    transmitter_n = inputdlg('What is the transmitter normal in [x,y,z]? ');
end

%find polynomial coefficients
p_lo = coeffvalues(sf_lo);
p_lole = coeffvalues(sf_lole);

%write the strings to calculate the angle and distances
angle_nn = sprintf("(acos((-fnx*%.3f+-fny*%.3f+-fnz*%.3f)/(sqrt(fnx^2+fny^2+fnz^2)*sqrt((%.3f)^2+(%.3f)^2+(%.3f)^2))))",transmitter_n(1),transmitter_n(2),transmitter_n(3),transmitter_n(1),transmitter_n(2),transmitter_n(3));
angle = sprintf("(acos((-(fnx-%.3f)*%.3f+-(fny-%.3f)*%.3f+-(fnz-%.3f)*%.3f)/(sqrt((fnx-%.3f)^2+(fny-%.3f)^2+(fnz-%.3f)^2)*sqrt((%.3f)^2+(%.3f)^2+(%.3f)^2))))",transmitter(1),transmitter_n(1),transmitter(2),transmitter_n(2),transmitter(3),transmitter_n(3),transmitter(1),transmitter(2),transmitter(3),transmitter_n(1),transmitter_n(2),transmitter_n(3));
off_axis_dist = sprintf("(sin%s*(sqrt((%.3f-x0)^2+(%.3f-y0)^2+(%.3f-z0)^2)))",angle,transmitter(1),transmitter(2),transmitter(3));
on_axis_dist = sprintf("(abs(cos%s)*(sqrt((%.3f-x0)^2+(%.3f-y0)^2+(%.3f-z0)^2)))",angle,transmitter(1),transmitter(2),transmitter(3));

%write the strings to calculate the LL and LN distances
poly_lo = sprintf("%.3f + %.3f*(180/3.14)*%s + %.3f*%s + %.3f*((180/3.14)*%s)^2 + %.3f*%s*(180/3.14)*%s+ %.3f*%s^2",p_lo(1),p_lo(2),angle_nn,p_lo(3),off_axis_dist,p_lo(4),angle_nn,p_lo(5),angle_nn,off_axis_dist,p_lo(6),off_axis_dist);
poly_lole = sprintf("%.3f + %.3f*(180/3.14)*%s + %.3f*%s + %.3f*((180/3.14)*%s)^2 + %.3f*%s*(180/3.14)*%s+ %.3f*%s^2",p_lole(1),p_lole(2),angle_nn,p_lole(3),off_axis_dist,p_lole(4),angle_nn,p_lole(5),angle_nn,off_axis_dist,p_lole(6),off_axis_dist);

color_scheme = str2num(cell2mat(inputdlg('To use [white,yellow,green] as colorscheme type 1, to use [red,yellow,green] type 2: ')));
%write the strings used as Meshlab filter input
if color_scheme == 1
    fprintf('[white,yellow,green] color scheme chosen\n')
    r = sprintf("255*(%s>%s)",on_axis_dist,poly_lole);
    g = sprintf("255");
    b = sprintf("255*(%s>%s)",on_axis_dist,poly_lo);
    clear NA angle tr_up angle_nn color_scheme off_axis_dist p_lo p_lole poly_lo poly_lole on_axis_dist sf_lo sf_lole transmitter transmitter_n
elseif color_scheme ==2
    fprintf('[red,yellow,green] color scheme chosen\n')
    g = sprintf("255*(%s<%s)",on_axis_dist,poly_lo);
    r = sprintf("255*(%s>%s)",on_axis_dist,poly_lole);
    b = sprintf("0");   
    clear ans angle tr_up angle_nn color_scheme off_axis_dist p_lo p_lole poly_lo poly_lole on_axis_dist sf_lo sf_lole transmitter transmitter_n
else 
    fprintf('Error')
end

fileID = fopen('script.mlx','w');
fprintf(fileID,'<!DOCTYPE FilterScript>\n<FilterScript>\n <filter name="Per Face Color Function">\n');
fprintf(fileID,'  <Param name="r" type="RichString" value="%s" tooltip="function to generate Red component. Expected Range 0-255" description="func r = "/>\n',r);
fprintf(fileID,'  <Param name="g" type="RichString" value="%s" tooltip="function to generate Green component. Expected Range 0-255" description="func g = "/>\n',g);
fprintf(fileID,'  <Param name="b" type="RichString" value="%s" tooltip="function to generate Blue component. Expected Range 0-255" description="func b = "/>\n',b);
fprintf(fileID,'  <Param name="a" type="RichString" value="255" tooltip="function to generate Alpha component. Expected Range 0-255" description="func alpha = "/>\n<Param name="onselected" type="RichBool" value="false" tooltip="if checked, only affects selected faces" description="only on selection"/>\n</filter>\n</FilterScript>');
fclose(fileID);
clear fileID ans