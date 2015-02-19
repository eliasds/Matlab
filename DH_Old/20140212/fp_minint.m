%% Reconstruct Minimum Intensity.
% Loads an image that can be read into the Fresnel Propagator.
% Version 3.0

function [Imin, zmap] = fp_minint(E0, zmin, zmax, numz, lambda, ps, zpad)

%z positions to reconstruct
z = linspace(zmin, zmax, numz);

%wb = waitbar(1/numz,'Reconstructing min intensity...');

%initialize Imin at the first z-step (field magnitude)
if nargin==7
    Imin = abs(fp_fresnelprop(E0, lambda, z(1), ps, zpad));
    zmap = ones(size(E0))*z(1);
else
    Imin = abs(fp_fresnelprop(E0, lambda, z(1), ps));
    zmap = ones(size(E0))*z(1);
end



%reconstruct the rest of the volume, tracking the intensity 
for i=2:numz
%    waitbar(i/numz,wb);
    
   %reconstruct at the next z-plane
    if nargin==7
         E1 = abs(fp_fresnelprop(E0, lambda, z(1), ps, zpad));
    else
         E1 = abs(fp_fresnelprop(E0, lambda, z(1), ps));
    end
    
    %compare, looking for minimum values
    minpix = E1<Imin;
    
    %update the memories
    Imin(minpix) = E1(minpix);
    zmap(minpix) = z(i);
    %figure(99); colormap gray
    %imagesc(abs(E1));
    %drawnow
    
end

%close(wb);