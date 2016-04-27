function gpu_num = gpuUseful( minmem )
%gpuUseful.m Finds the most useful GPU on the system
%   Finds the GPU on the system with the most memory

default_minmem = 1E9;
if nargin < 1
    minmem = default_minmem;
end

gpu_num = 0;
try
    gpu_num = gpuDeviceCount; %Determines if there is a CUDA enabled GPU
%     gpuMem(gpu_num) = 0;
%     for L = 1:gpu_num %Gathers memory info on all GPUs
%         gpuInfo = gpuDevice(L);
%         gpuMem(L) = gpuInfo.TotalMemory;
%     end
%     [maxmem,gpu_num] = max(gpuMem);
%     if maxmem < minmem
%         gpu_num = 0;
%     end
catch err
    gpu_num = 0;
end

end

