%calculation of transmission scores
clear all
close all
clc

filename = input('Please input the file location of the file to be processed using parenthesis: ');
format = stlGetFormat(filename);
if (strcmp(format,'ascii'))
    [v, f, n, name] = stlReadAscii(filename);
elseif (strcmp(format,'binary'))
    [v, f, n] = stlread(filename);
end
load polynomials

transmitter = input('What is the transmitter position in [x,y,z]? ');
transmitter_n = input('What is the transmitter normal in [x,y,z]? ');

m = zeros(1,3);
faceinf = zeros(length(f),1);

for i =1:length(f)
    a = v(f(i,1),:);    b = v(f(i,2),:);    c = v(f(i,3),:); %find the points
    if norm(a-transmitter)<75&&norm(b-transmitter)<75&&norm(c-transmitter)<75
    ac = c-a; ab = b-a;     %vectors describing the plane
    abXac = cross(ab,ac);   
    m(1,:) = a + (cross(abXac,ab)*norm(ac,2).^2 + cross(ac,abXac )*norm(ab,2).^2) / (2*norm(abXac,2).^2) ;
    distance = norm(transmitter-m(1,:),2);
    theta = acosd(dot(-transmitter_n,n(i,:))/(norm(transmitter_n,2)*norm(n(i,:),2)));
    alpha = acosd(dot(-transmitter_n,transmitter-m(1,:))/(norm(transmitter_n,2)*norm(transmitter-m(1,:),2))); 
    off_axis = sind(alpha)*distance;
    on_axis = abs(cosd(angle))*distance;
    dist_ll = sf_lole(theta,off_axis);
    dist_ln = sf_lo(theta,off_axis);
    
    if (distance<dist_ll)
        faceinf(i) = 1;
    elseif(distance>=dist_ll && distance<dist_ln)
        faceinf(i) = 2;
    else
        faceinf(i) = 3;
    end
    else 
        faceinf(i) = 3;
    end
end

lole = find(faceinf==1);
f_lole = f(lole,:);
stlwrite('lole.stl',f_lole,v,'FaceColor',[170 255 0])

lo = find(faceinf==2);
f_lo = f(lo,:);
stlwrite('lo.stl',f_lo,v,'FaceColor',[255 255 0])

notr = find(faceinf==3);
f_notr = f(notr,:);
stlwrite('notr.stl',f_notr,v)
