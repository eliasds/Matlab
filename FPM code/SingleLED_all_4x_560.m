clear all; clc; close all;

addpath(['C:\Users\Lei\Dropbox\Berkeley\LEDArray\MatlabCodes\Coded_Illumination\Source_coding']);
main_dir = ['D:\Ptychography Application\LargeScaleSample\FruitFlyEmbryo\data\4x\'];

subfolderlist = dir([main_dir,'Fr*']);

Np = 560;
Nedge = 160;
max_ampl = 14;
ma_ph = pi;
mi_ph = -pi;

for p = 1:length(subfolderlist)
    folder_name = subfolderlist(p).name;
    file_dir = [main_dir,folder_name,'\'];
    out_maindir = folder_name;
    out_maindir = [out_maindir,'\'];
    mkdir(out_maindir);
    AlterProj_SingleLED_NewSetup_patch(file_dir, out_maindir, Np, Nedge);
    Stitch_FullFoV(out_maindir,Np,Nedge,max_ampl,ma_ph,mi_ph);
end


