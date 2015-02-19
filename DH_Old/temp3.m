tic
Z=20;
[M,N]=size(E0);
E2 = zeros(M,N,Z);
for L=1:Z
    E2(:,:,L)=fp_fresnelprop(E0,632.8E-9,L*9E-3/Z,6.5E-6/4,4096);
end
toc

tic
Z=20;
[M,N]=size(E0);
E3 = zeros(M,N,Z);
for L=1:Z
    E3(:,:,L)=fp_fresnelprop_gpu(E0,632.8E-9,L*9E-3/Z,6.5E-6/4,4096);
end
toc