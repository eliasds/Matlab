clear all; clc; close all;

addpath(['C:\Users\Lei\Dropbox\Berkeley\LEDArray\MatlabCodes\Coded_Illumination\Source_coding']);
main_dir = ['D:\Ptychography Application\PathologySlides\Human Carcinoma of Esophagus\data\'];

subfolderlist = dir([main_dir,'Eso*']);

Np = 220;
Nedge = 26;
max_ampl = 7;
ma_ph = pi;
mi_ph = -pi;

for p = 1:length(subfolderlist)
    folder_name = subfolderlist(p).name;
    file_dir = [main_dir,folder_name,'\'];
    out_maindir = [folder_name,'-',num2str(Np),'-',num2str(Nedge)];
    out_maindir = [out_maindir,'\'];
    mkdir(out_maindir);
    AlterProj_SingleLED_NewSetup_patch(file_dir, out_maindir, Np, Nedge);
    Stitch_FullFoV(out_maindir,Np,Nedge,max_ampl,ma_ph,mi_ph);
end


