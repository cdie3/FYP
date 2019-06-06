close all
clear all
clc

%find the format of the stl file and read it into matlab
%f are the face indexes specifying which points were used for the face
%v are the vertices

load planes_backup
%transmitter position and distance spec
transmitter = [15,50,38.5];
transmitter_n = [0,0,-15];
load flatsur
dist_full = 12;
dist_lossy = 15;

figure(2)
hold on
for k = 0:4
for j = 0:20
m = zeros(length(f),3);
distance = zeros(1,4);
angle = zeros(1,4);
off_axis = zeros(length(f),1);
dist_lole = zeros(length(f),1);
dist_lo = zeros(length(f),1);
for i =1:length(f)
    a = v(f(i,1),:)+[0,5,0]*j+[30,0,0]*k;    b = v(f(i,2),:)+[30,0,0]*k+[0,5,0]*j;    c = v(f(i,3),:)+[30,0,0]*k+[0,5,0]*j; %find the points
    ac = c-a; ab = b-a;     %vectors describing the plane
    abXac = cross(ab,ac);   
    %calculate the midpoints of each face
    m(i,:) = a + (cross(abXac,ab)*norm(ac,2).^2 + cross(ac,abXac )*norm(ab,2).^2) / (2*norm(abXac,2).^2) ;
    %calculate the distance between midpoint and transmitter
    distance(i) = norm(transmitter-m(i,:),2);
    angle(i) = acosd(dot(-transmitter_n,transmitter-m(i,:))/(norm(transmitter_n,2)*norm(transmitter-m(i,:),2)));
    angle_nn(i) = acosd(dot(-transmitter_n,n(i,:))/(norm(transmitter_n,2)*norm(n(i,:),2)));
    off_axis(i) = sind(angle(i))*distance(i);
    %distance(i) = off_axis(i);
    dist_lole = sf_lole(angle_nn(i),off_axis(i));
    dist_lo = sf_lo(angle_nn(i),off_axis(i));
    %plot the shaded faces
    if (distance(i) < dist_lole)
        fill3([a(1) b(1) c(1)],[a(2) b(2) c(2)],[a(3) b(3) c(3)],'g')
    elseif(distance(i)>=dist_lole && distance(i)<dist_lo)
        fill3([a(1) b(1) c(1)],[a(2) b(2) c(2)],[a(3) b(3) c(3)],'y')
    else
        fill3([a(1) b(1) c(1)],[a(2) b(2) c(2)],[a(3) b(3) c(3)],'r')
    end
       
end
end
end
plot3(transmitter(1),transmitter(2),transmitter(3),'b*') %plot transmitter
plot3([transmitter(1),transmitter(1)+transmitter_n(1)],[transmitter(2),transmitter(2)+transmitter_n(2)],[transmitter(3),transmitter(3)+transmitter_n(3)],'b')

xlim([-5,100]); ylim([-5,100]); zlim([-5,100]);
xlabel('x');    ylabel('y');    zlabel('z');
% 
% figure(1) %plot the midpoints and edges
% plot3(v(:,1),v(:,2),v(:,3),'r')
% hold on
% for i = 1:length(v/3)
% plot3([m(i,1),m(i,1)+5*n(i,1)],[m(i,2),m(i,2)+5*n(i,2)],[m(i,3),m(i,3)+5*n(i,3)],'g')
% end
% plot3([transmitter(1),transmitter(1)+transmitter_n(1)],[transmitter(2),transmitter(2)+transmitter_n(2)],[transmitter(3),transmitter(3)+transmitter_n(3)],'g')
% plot3(m(:,1),m(:,2),m(:,3),'b.')
% xlabel('x');    ylabel('y');    zlabel('z');
figure(2)
