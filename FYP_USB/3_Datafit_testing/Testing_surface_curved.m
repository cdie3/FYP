close all
clear all
clc

%find the format of the stl file and read it into matlab
%f are the face indexes specifying which points were used for the face
%v are the vertices
filename = 'testsphere2.stl';
[v, f, n] = readStl(filename);

% stlPlot(v, f, name);

transmitter = [0,0,0];
transmitter_n = [50,50,50];
dist_full = 40;
dist_lossy = 50;

figure(2)
hold on
load sf
m = zeros(length(f),3);
distance = zeros(1,4);
%angle_nn = zeros(1,4);
for i =1:length(f)
    a = v(f(i,1),:);    b = v(f(i,2),:);    c = v(f(i,3),:); %find the points
%     if norm(a-transmitter)<75&&norm(b-transmitter)<75&&norm(c-transmitter)<75
    ac = c-a; ab = b-a;     %vectors describing the plane
    abXac = cross(ab,ac);   
    m(1,:) = a + (cross(abXac,ab)*norm(ac,2).^2 + cross(ac,abXac )*norm(ab,2).^2) / (2*norm(abXac,2).^2) ;
    distance = norm(transmitter-m(1,:),2);
    %if distance<75
    angle_nn = acosd(dot(-transmitter_n,n(i,:))/(norm(transmitter_n,2)*norm(n(i,:),2)));
    angle = acosd(dot(-transmitter_n,transmitter-m(1,:))/(norm(transmitter_n,2)*norm(transmitter-m(1,:),2))); 
    off_axis = sind(angle)*distance;
    on_axis = abs(cosd(angle))*distance;
    dist_lole = sf_lole(angle_nn,off_axis);
    dist_lo = sf_lo(angle_nn,off_axis);
    
    if (angle_nn<dist_lole)
        fill3([a(1) b(1) c(1)],[a(2) b(2) c(2)],[a(3) b(3) c(3)],'g')
    elseif(angle_nn>dist_lole && angle_nn<dist_lo)
        fill3([a(1) b(1) c(1)],[a(2) b(2) c(2)],[a(3) b(3) c(3)],'y')
    else
         fill3([a(1) b(1) c(1)],[a(2) b(2) c(2)],[a(3) b(3) c(3)],'r')
    end
            %text(m(i,1),m(i,2),m(i,3),sprintf('id: %d',i))
end
plot3(transmitter(1),transmitter(2),transmitter(3),'b*') %plot transmitter
plot3([transmitter(1),transmitter(1)+transmitter_n(1)],[transmitter(2),transmitter(2)+transmitter_n(2)],[transmitter(3),transmitter(3)+transmitter_n(3)],'b')

xlim([-10,100]); ylim([-10,100]); zlim([-10,100]);
xlabel('x');    ylabel('y');    zlabel('z');

figure(1) %plot the midpoints and edges
plot3(v(:,1),v(:,2),v(:,3),'r')
hold on
for i = 1:length(v/3)
plot3([m(i,1),m(i,1)+5*n(i,1)],[m(i,2),m(i,2)+5*n(i,2)],[m(i,3),m(i,3)+5*n(i,3)],'g')
end
plot3([transmitter(1),transmitter(1)+transmitter_n(1)],[transmitter(2),transmitter(2)+transmitter_n(2)],[transmitter(3),transmitter(3)+transmitter_n(3)],'g')
plot3(m(:,1),m(:,2),m(:,3),'b.')
xlabel('x');    ylabel('y');    zlabel('z');
figure(2)
