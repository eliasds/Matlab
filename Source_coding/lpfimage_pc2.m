function [ I ] = lpfimage_pc2( OBJ, Ns, w_NA, Nm, N_led, I_led)
%LPFIMAGE Computes the output image low-pass filtered by limited NA
%   OBJ: input spectrum
%   Ns = [Nsx,Nsy]: shift of center of lpf region
%   w_NA: lpf function defined by the pupil function
%   Nm = [N_mx,N_my]: output intensity size
%   N_led: # of pixel spread of LED in the spatial freq domain
%   I_led: intensity distribution of LED

%Define Fourier operators
F = @(x) ifftshift(fft2(fftshift(x)));
Ft = @(x) ifftshift(ifft2(fftshift(x)));

% Assumes N_m is even
[N_objy,N_objx] = size(OBJ);

I = 0;
% shift due to LED's finite size, assume N_led is always odd, 
% since the coherent limit should always correspond to Ns_led = 0 and
% N_led = 1
Ns_led = [-(N_led-1)/2:(N_led-1)/2];
[Ns_ledx,Ns_ledy] = meshgrid(Ns_led);

for n = 1:N_led^2
    cen = [N_objx/2+1,N_objy/2+1]+[Ns(1),Ns(2)]+[Ns_ledx(n),Ns_ledy(n)];
    S = OBJ(cen(2)-Nm(2)/2:cen(2)+Nm(2)/2-1,cen(1)-Nm(1)/2:cen(1)+Nm(1)/2-1);
    
    % physically acquired spectrum after lpf
    S_m = S.*w_NA;
    
    I = I+I_led(n)*abs(Ft(S_m)/N_objy/N_objx*Nm(1)*Nm(2)).^2;
end

% % not necessary, but make the normalization consistant to throw in a
% % constant factor 1/N_led^2 everywhere
% I = I/N_led^2;

end

