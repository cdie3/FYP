%datafitting
clear
clc
close all

%add the revelant Matlab functions and data
addpath('1_MATLAB_functions') ;addpath('2_MATLAB_variables'); addpath('3_Datafit_testing');

%specify the name of the saved polynomial
%choose polynomials_22 for changing the polynomial for the MeshLab
%calculation
%additional coefficients will be ignored
save_name = 'polynomials';
poly_form = 'poly45';
fit_lole = 'LAR';
fit_lo = 'Bisquare';

%import data from excel spreadsheet
fileID = fopen('data.txt');
A = fscanf(fileID,'%f');
array = zeros((length(A)/11),11);
for i = 1:length(A)/11
    array(i,:) = A((i+((i-1)*10)):(i+10+((i-1)*10)));
end
data = array;

%define variables
p_val = zeros(2,3,7);
angle_lole =[]; on_axis_lole=[]; off_axis_lole =[];
angle_lo =[]; on_axis_lo=[]; off_axis_lo =[];
 
cnt = 1;
for k = 0:5:30 %make a plot for each increment of x, 0 to 30mm
    %copy data for temporary working
    data2 = data;
 
    %delete rows where x value is not of interest
    data2(data2(:,2)~=k | isnan(data2(:,2)),:) = [];
 
    %copy rows to produce symmetrical results for negative angles if x=0
    if(k==0)
        sz = size(data2);
        for j = 1:sz(1)
           sz2 = size(data2);
           if(data2(j,1)~=0)
               data2(sz2(1)+1,:) = data2(j,:);
               data2(sz2(1)+1,1) = -data2(sz2(1)+1,1);
           end
        end
    end
 
    %sort rows by angle
    [Y,I] = sort(data2(:,1));
    data2 = data2(I,:);
    
    %populate x axis data
    xx = data2(:,1);
    
    %set maximum z value
    zmax = 60;
    
    %populate y axis data for each x axis value - five bar length values: 
    %[unknown, lossless, lossy, dropout, unknown]
    %check size of data array
    sz = size(data2);
   
    yy = [];
    for j = 1:sz(1)
        if(data2(j,10)==0 || data2(j,10)==1) 
            if(data2(j,10)==0)
                yy(j,1) = 0;
                yy(j,2) = data2(j,8);
            else
                yy(j,1) = data2(j,8);
                yy(j,2) = 0;
            end
            if(data2(j,11)==0)
                yy(j,3) = data2(j,9)-data2(j,8);
                yy(j,4) = zmax-data2(j,9);
                yy(j,5) = 0;
            else
                yy(j,3) = data2(j,9)-data2(j,8);
                yy(j,4) = 0;
                yy(j,5) = zmax-data2(j,9);
            end
        elseif(data2(j,10)==2);
            yy(j,:) = [0,data2(j,8),0,0,zmax-data2(j,8)];
        elseif(data2(j,10)==3);
            yy(j,:) = [zmax,0,0,0,0];
        elseif(data2(j,10)==4);
            yy(j,:) = [20,0,0,zmax-20,0];    
        elseif(data2(j,10)==5);
            yy(j,:) = [data2(j,8),0,0,zmax-data2(j,8),0];        
        end
    end
 
    xtes = -100:1:100;
    y2 = yy(yy(:,2)>0,2)+yy(yy(:,2)>0,1);
    x2 = xx(yy(:,2)>0);
    y3 = yy(yy(:,3)>0,3)+yy(yy(:,3)>0,2)+yy(yy(:,3)>0,1);
    x3 = xx(yy(:,3)>0);
    cnt = cnt+1;
    
    %populate the variables
    angle_lole = [angle_lole;x2];
    on_axis_lole = [on_axis_lole;y2];
    angle_lo = [angle_lo;x3];
    on_axis_lo = [on_axis_lo;y3];
    off_axis_lole = [off_axis_lole;k*ones(length(x2),1)];
    off_axis_lo = [off_axis_lo;k*ones(length(x3),1)];
end

%fit the raw data with the best polynomial
sf_lole = fit([angle_lole, off_axis_lole],on_axis_lole,poly_form,'Robust',fit_lole)
sf_lo = fit([angle_lo, off_axis_lo],on_axis_lo,poly_form,'Robust',fit_lo)

%plot the LL transition surface
figure
plot(sf_lole,[angle_lole,off_axis_lole],on_axis_lole);
xlabel('x')
ylabel('z')
zlabel('y')
title('Lossless - Lossy')
figure
ind = find(on_axis_lo==16|on_axis_lo==17.2|on_axis_lo==19.5);
angle_lo(ind) =[];on_axis_lo(ind) =[]; off_axis_lo(ind) =[];

%plot the LN transition surface
plot(sf_lo,[angle_lo,off_axis_lo],on_axis_lo);
xlabel('Angle in degrees');
ylabel('Off axis distance in cm');
zlabel('On axis distance in cm')
title('Lossy - No Transmission')

%plot both transitionary surfaces
figure
h = plot(sf_lole,[angle_lole,off_axis_lole],on_axis_lole);
hold on
i = plot(sf_lo,[angle_lo,off_axis_lo],on_axis_lo);
xlabel('Angle in degrees');
ylabel('Off axis distance');
zlabel('On axis distance')
title('Data fitting of both lossy (yellow) and lossless (green) transmission data points')
set(h(1),'FaceColor','g');
set(i(1),'FaceColor','y');
zlim([10 65])
save(sprintf('2_MATLAB_variables\%s',save_name),'sf_lole','sf_lo')
