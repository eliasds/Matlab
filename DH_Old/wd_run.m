%List all files needed to run wisker detection

%first create and analyze DH-0001.mat for best erosion/dilation parameters
%then incorporate wd_xyzt.m into wd_iminsave_gpu.m before saving .mat file
fp_avg_bgfiles.m %~1 min
%fp_imin_gpu.m
wd_iminsave_gpu.m %~2 hours
%wd_auto.m
wd_xyzt.m %~20 min
%wd_3dplot.m
wd_3dplot_video.m
