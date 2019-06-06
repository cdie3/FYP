%String writing for meshlab
clear all
close all
clc

%add relevant functions
addpath('1_MATLAB_functions') ;addpath('2_MATLAB_variables'); addpath('3_Datafit_testing');

%load the surface fit polynomials
load polynomials_22

%load the previously saved information
load prev_quickly

%Get the position of the transmitter and its normal as input and
%find the transformation matrix of the transmitter
mlstruct = parseXML(filename);
testing = mlstruct(2).Children(2).Children(tr_pos*2+2).Children(2).Children.Data  ;
transformation = cell2mat(cellfun(@str2num, mat2cell(testing, ones(size(testing,1),1), size(testing,2)),'UniformOutput',0));

transmitter = [0,-100,20];  %transmitter midpoint location of STL-file
transmitter_n = [0,10,0];   %transmitter norm of STL-file

transformation = inv(transformation);

t = transmitter; %transmitter position
tp = transmitter+transmitter_n; %point infront of the transmitter along the norm
%translate
tpt = tp*transformation(1:3,1:3)+[transformation(1,4),transformation(2,4),transformation(3,4)];
tt = t*transformation(1:3,1:3)+[transformation(1,4),transformation(2,4),transformation(3,4)];
%new transmitter position and norm
transmitter_n = (tpt-tt)/norm(tpt-tt);
transmitter = transmitter*transformation(1:3,1:3)+[transformation(1,4),transformation(2,4),transformation(3,4)];
save('2_MATLAB_variables\transmitter.mat','transmitter','transmitter_n')

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

%write the mlx file
fileID = fopen(sprintf('%s.mlx',mlxname),'w');
fprintf(fileID,'<!DOCTYPE FilterScript>\n<FilterScript>\n <filter name="Per Face Color Function">\n');
fprintf(fileID,'  <Param name="r" type="RichString" value="%s" tooltip="function to generate Red component. Expected Range 0-255" description="func r = "/>\n',r);
fprintf(fileID,'  <Param name="g" type="RichString" value="%s" tooltip="function to generate Green component. Expected Range 0-255" description="func g = "/>\n',g);
fprintf(fileID,'  <Param name="b" type="RichString" value="%s" tooltip="function to generate Blue component. Expected Range 0-255" description="func b = "/>\n',b);
fprintf(fileID,'  <Param name="a" type="RichString" value="255" tooltip="function to generate Alpha component. Expected Range 0-255" description="func alpha = "/>\n<Param name="onselected" type="RichBool" value="false" tooltip="if checked, only affects selected faces" description="only on selection"/>\n</filter>\n</FilterScript>');
fclose(fileID);

clearvars -except r g b