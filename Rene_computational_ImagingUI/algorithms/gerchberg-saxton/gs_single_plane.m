%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%            G E R C H B E R G - S A X T O N            %%%%%%%%%%
%%%%%%%%%%                   A L G O R I T H M                   %%%%%%%%%%
%%%%%%%%%%  ( S I N G L E - P L A N E   P R O P A G A T I O N )  %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function uses the Gerchberg-Saxton algorithm to recover phase.
% Propagates guessed phase to a single plane upon each iteration.
%
% Inputs:
%   - Im:       lower image plane intensity
%   - I0:       center image plane intensity
%   - Ip:       upper image plane intensity
%   - dz:       distance between I0 and Ip (I0 and Im)
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

function [ phi ] = gs_single_plane( Im, I0, Ip, dz, ps, lambda, N )

[n,m] = size(I0);
aest0 = sqrt(I0).*exp(1i*zeros(n,m));

for iternum=1:N
    
    % Propagate from I0 to Ip and replace intensity with measurement
    aest1 = propagate(aest0, lambda, dz, ps);
    aest1 = sqrt(Ip).*exp(1i*angle(aest1));
    
    % Propagate from Ip to I0 and replace intensity with measurement
    aest0 = propagate(aest1, lambda, -dz, ps);
    aest0 = sqrt(I0).*exp(1i*angle(aest0));
    
    % Propagate from I0 to Im and replace intensity with measurement
    aestm1 = propagate(aest0, lambda, -dz, ps);
    aestm1 = sqrt(Im).*exp(1i*angle(aestm1));
    
    % Propagate from Im to I0 and replace intensity with measurement
    aest0 = propagate(aestm1, lambda, dz, ps);
    aest0 = sqrt(I0).*exp(1i*angle(aest0));

end

phi = angle(aest0);