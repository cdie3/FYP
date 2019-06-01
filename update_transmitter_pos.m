mlstruct = parseXML('Example.mlp');
testing = mlstruct(2).Children(2).Children(6).Children(2).Children.Data;
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


