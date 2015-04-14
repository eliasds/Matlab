%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%              G E R C H B E R G - S A X T O N              %%%%%%%%
%%%%%%%%                     A L G O R I T H M                     %%%%%%%%
%%%%%%%%  ( M U L T I P L E - P L A N E   P R O P A G A T I O N )  %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function uses the Gerchberg-Saxton algorithm to recover phase.
% Propagates guessed phase to multiple planes upon each iteration. To
% illustrate, suppose we have a stack of images [Mn ... M1 C P1 ... Pn].
% Then during each iteration, the center image C will be propagated to 
% planes P1 ... Pn, and the results will be replaces with their respective
% measured intensities. These will all be propagated back to the center,
% where we take the measured center intensity and the average of the phase
% results. Then the process is repeated for planes M1 ... Mn. This
% completes one iteration.
%
% Inputs:
%   - Inten:    Stack of intensity images
%   - I0_idx:   center image plane index in stack
%   - zvec:     vector indicating z values for images in stack
%   - num_imgs: number of images to use on either side of the center plane
%   - ps:       pixel size
%   - lambda:   wavelength
%   - N:        number of loops to perform
%
% Outputs:
%   - phi:      phase matrix corresponding to intensity at center plane
%               recovered by the algorithm
%
% Notes:
%   - INPUT IMAGES [I0, I1, I2] MUST OF EQUAL SIZE. 
%   - The units for ps, lambda, and dz MUST BE CONSISTENT.
%   - dz is the distance between I0 and I1, should be the negative of the
%     distance from I0 and I2
%
% Laura Waller, Gautam Gunjala, July 2014
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ phi ] = ... 
    gs_multiple_plane( Inten, I0_idx, zvec, num_imgs, ps, lambda, N, callbacks )

[n,m,~] = size(Inten);
E0_est = sqrt(Inten(:,:,I0_idx)).*exp(1i*zeros(n,m));

callbacks.progress(0) ;
for iternum = 1:N
	if callbacks.canceled(), return ; end
    
    % Propagate forward and replace with measured intensity
    prop = propagate(E0_est, lambda, zvec(I0_idx+1:I0_idx+num_imgs), ps);
    prop = sqrt(Inten(:,:,I0_idx+1:I0_idx+num_imgs)).*exp(1i*angle(prop));
    
    % Propagate all planes back to center
    for i = 1: num_imgs
        prop(:,:,i) = angle(propagate(prop(:,:,i),lambda, ...
            -1*zvec(I0_idx+i),ps));
    end
    
    % Replace with center plane intensity
    E0_est = sqrt(Inten(:,:,I0_idx)).*exp(1i*mean(prop,3));
    
    % Flip stack for negative propagation
    stk_temp = flipdim(Inten(:,:,I0_idx-num_imgs:I0_idx-1),3);
    z_temp = fliplr(zvec(I0_idx-num_imgs:I0_idx-1));
    
    % Propagate backward and replace with measured intensity
    prop = propagate(E0_est, lambda, z_temp, ps);
    prop = sqrt(stk_temp).*exp(1i*angle(prop));
    
    % Propagate all planes back to center
    for i = 1: num_imgs
        prop(:,:,i) = angle(propagate(prop(:,:,i),lambda, ...
            -1*z_temp(i),ps));
    end
    
    % Replace with center plane intensity
    E0_est = sqrt(Inten(:,:,I0_idx)).*exp(1i*mean(prop,3));
    callbacks.progress(iternum/N) ;
end

phi = angle(E0_est);