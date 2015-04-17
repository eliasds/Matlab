close all;
clear all;clc;

addpath('./Functions');



load dandelion.mat


% number of detector pixels
pixel_num=1024;

% size of detector pixels (um)
detector_size=5.2;

% wavelength (um)
lambda=0.633;

% distance between each axial plane (um)
deltaZ=8000;

% distance from detector to first reconstructed plane (um)
offsetZ=0;

% number of axial planes
nz=10;

% number of zeros to pad matrix by in each direction
pad_size=100;


shrinkage_factor=pixel_num/size(g,1);
sensor_size=pixel_num*detector_size;
deltaX=detector_size*shrinkage_factor;
deltaY=detector_size*shrinkage_factor;

figure;imagesc(abs(g));title('CapturedData');axis image;



g=padarray(g,[pad_size pad_size]);
range=pad_size*2+pixel_num;

[nx ny]=size(g);

Nx=nx;
Ny=ny*nz*2;
Nz=1;

E0=ones(nx,ny);


[Phase3D Pupil]=MyMakingPhase3D(nx,ny,nz,lambda,...
    deltaX,deltaY,deltaZ,offsetZ,sensor_size);

PhaseTmesPupil=Phase3D.*Pupil;

E=MyFieldsPropagation(E0,nx,ny,nz,Phase3D,Pupil);

g=MyC2V(g(:));

transf=MyAdjointOperatorPropagation(g,E,nx,ny,nz,Phase3D,Pupil);
transf=reshape(abs(MyV2C(transf)),nx,ny,nz);
figure;imagesc(plotdatacube(transf));title('BackPropagation');axis image;drawnow;



A = @(f_twist) MyForwardOperatorPropagation(f_twist,E,nx,ny,nz,Phase3D,Pupil);
AT = @(g) MyAdjointOperatorPropagation(g,E,nx,ny,nz,Phase3D,Pupil);


tau = 0.01;
piter = 4;
tolA = 1e-6;
iterations = 500; 


Psi = @(f,th) MyTVpsi(f,th,0.05,piter,Nx,Ny,Nz);
Phi = @(f) MyTVphi(f,Nx,Ny,Nz);


[f_reconstruct,dummy,obj_twist,...
    times_twist,dummy,mse_twist]= ...
    TwIST(g,A,tau,...
    'AT', AT, ...
    'Psi', Psi, ...
    'Phi',Phi, ...
    'Initialization',2,...
    'Monotone',1,...
    'StopCriterion',1,...
    'MaxIterA',iterations,...
    'MinIterA',iterations,...
    'ToleranceA',tolA,...
    'Verbose', 1);



f_reconstruct=reshape(MyV2C(f_reconstruct),nx,ny,nz);
figure;imagesc(plotdatacube(abs(f_reconstruct)));title('Reconstruction');axis image;drawnow;

g=reshape(MyV2C(g),nx,ny);

save result.mat f_reconstruct