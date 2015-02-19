function [E1,H] = fp_fresnelprop_gpu_call(E0,lambda,Z,ps,zpad)

maxfilesgpu=35;
iter=length(Z)/maxfilesgpu;

for L = 1:iter;
    E1 = fp_fresnelprop_gpu(E0,lambda,Z((L-1)*maxfilesgpu+1:L*maxfilesgpu),ps,zpad);
    
end
    