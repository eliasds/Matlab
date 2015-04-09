function [ ph ] = DPC_tik( Idpc, H, reg )
%DPC_TIK recover phase ph based on DPC data Idpc, with transfer function H
%and regularization parameter reg
%ph = sum_i (H_i^* F(Idpc_i))/(sum_i(abs(H_i)^2)+reg


F = @(x) fftshift(fft2(ifftshift(x)));
Ft = @(x) fftshift(ifft2(ifftshift(x)));

if size(Idpc,3)==size(H,3)
    ph = -real(Ft(sum(F(Idpc).*conj(H),3)./(sum(abs(H).^2,3)+reg)));
else
    error('DPC data should have the same dimension as the transfer function');
end
end

