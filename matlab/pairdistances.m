%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Overview

% In this code, we learn how to compute pairwise distances between particles
% in the plane. We then try to put this on the GPU, and see if we can get
% a speedup.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Start with a list of points whose distance we know analytically.

points = [ 0,0 ; 1,1 ; 2,2 ; 3,3 ];
N = length(points);
%disp([sum(abs(points(1,:)-points(2,:)).^2),sum(abs(points(1,:)-points(3,:)).^2)]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Repeat the calculation using for loops
for i = 1:length(points)-1
    for j = i+1:length(points)
        disp([i,j]);
	disp(sum(abs(points(i,:)-points(j,:)).^2))
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Partially vectorize calculation

% To so this, we must first get (i,j) pairs into a new matrix.
% Then we can take the norm of each row of the matrix in a vectorized manner. 
seps=zeros(N*(N-1)/2,2);
counter=0;
for i = 1:length(points)-1
    for j = i+1:length(points)
	counter=counter+1;
        seps(counter,:)=points(i,:)-points(j,:);
    end
end
disp(vecnorm(seps,2,2));
%disp(counter)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Overlap matrix technique
tic
N=10000;
points = rand(N,2);
ovl = points*points';
norms = diag(ovl);
dists = zeros(N*(N-1)/2,1);
counter = 0;
for i = 1:length(points)-1
    for j = i+1:length(points)
        counter=counter+1;
        dists(counter)=norms(i)+norms(j)-2*ovl(i,j);
    end
end
%disp(dists)
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%You run out of RAM somewhere between 10000 and 50000, but this
%technique is pretty good!

%disp("CPU");
%tic
%N=50000;
%points = rand(N,2);
%ovl = points*points';
%norms = diag(ovl);
%onevec=ones(1,N);
%rows=norms*onevec;
%cols = rows.';
%pdm = rows+cols-2*ovl;
%toc

disp("GPU");
tic
N=50000;
points = gpuArray(rand(N,2));
ovl = points*points';
norms = diag(ovl);
onevec=gpuArray(ones(1,N));
rows=norms*onevec;
cols = rows.';
pdm = rows+cols-2*ovl;
toc
