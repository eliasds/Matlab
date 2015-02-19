%% Fresnel Propagation Image Loader Function.
% Loads an image that can be read into the Fresnel Propagator.
% Version 3.0


function [E0] = fp_imload(objectfile,background)
if nargin < 2
    background = 1;
else
    [~,~,ext]=fileparts(background);
    if strcmp(ext,'.mat')==1
        varnam=who('-file',background);
        background=load(background,varnam{1});
        background=background.(varnam{1});
    else
        background=double(imread(background));
    end
end
E0=(double(imread(objectfile))./background);
E0(isnan(E0)) = mean2(background);
%E0(E0>6)=6;

%
%% Finds center of image and crops to first radix2 (2048)
%comment this whole section out if not needed
X=1920;
Y=1088;
X=1024;
Y=1024;
[m,n]=size(E0);
center=round(size(E0)/2);
%radix2=2^(nextpow2(min(m,n))-1); %(2048)
radix2=2^(nextpow2(min(m,n))-2); %(1024)
%radix2=2^(nextpow2(min(m,n))-3); %(512)


%Center,Center
%E0=E0((center(1)+1-radix2/2):(center(1)+radix2/2),(center(2)+1-radix2/2):(center(2)+radix2/2));
%Top,Center
%E0=E0(1:radix2,(center(2)+1-radix2/2):(center(2)+radix2/2));
%Bottom,Center
%E0=E0(end-radix2+1:end,(center(2)+1-radix2/2):(center(2)+radix2/2));
%Center,Right
%Center,Left
%Custom,Center
%E0=E0(1500-1023:1600,(center(2)+1-radix2/2):(center(2)+radix2/2));


%1920 by 1088
%Center,Center
%E0=E0((center(1)+1-Y/2):(center(1)+Y/2),(center(2)+1-X/2):(center(2)+X/2));
%Top,Center
%E0=E0(1:Y,(center(2)+1-X/2):(center(2)+X/2));
%Bottom,Center
E0=E0(end-Y+1:end,(center(2)+1-X/2):(center(2)+X/2));
%Center,Right
%E0=E0((center(1)+1-Y/2):(center(1)+Y/2),end-X+1:end);
%Center,Left
%Custom,Center
%E0=E0(1500-1023:1600,(center(2)+1-radix2/2):(center(2)+radix2/2));