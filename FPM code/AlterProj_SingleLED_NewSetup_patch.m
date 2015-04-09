%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% inverse problem use alternating projection
% 2/28/2014
% experiments, 4/1/2014
% account for geometry WITHOUT condenser, 3/22/2014

% By Lei Tian, lei_tian@alum.mit.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function AlterProj_SingleLED_NewSetup_patch(filedir, out_maindir, Np, Nedge)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1 LED expt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numlit = 1;
% addpath(['C:\Users\Lei\Dropbox\Berkeley\LEDArray\MatlabCodes\Coded_Illumination\Source_coding']);
% addpath('C:\Users\Lei\Dropbox\Berkeley\LEDArray\MatlabCodes\Coded_Illumination\export_fig');

% filedir = ['C:\Users\Ziji\Desktop\processed-image\ptychography_data\2014-12-19\zebrafish1\'];
% filedir = ['C:\Users\Ziji\Desktop\test data\'];

imglist = dir([filedir,'ILED*.tif']);
% %% check regions
% % l = [146,148];
% % l = [127:129,146:148,165:167];
% l = [127,129,165,167];
% I = 0;
% for m = 1:length(l)
%     ll = l(m);
%     fn = [filedir,'ILED_0',num2str(ll),'.tif'];
%     tp = double(imread(fn));
%     I = I+tp;
% end
% 
% f1 = figure(101); imagesc(I,[2e3,5e3]*length(l)); axis image; colormap gray; axis off;
% 
% export_fig(f1,['I-',num2str(l),'.tif'],'-m2');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define the current processing patch starting coordinates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Np = 560;
% Nedge = 160;
ns10 = rem(2160-Nedge,Np-Nedge)/2+1;
ns20 = rem(2160-Nedge,Np-Nedge)/2+1;

ns1 = ns10:Np-Nedge:2160; ns1 = ns1(1:end-1);
ns2 = ns20:Np-Nedge:2560; ns2 = ns2(1:end-1);
[ns2,ns1] = meshgrid(ns2,ns1);

%%
for l = 1:length(ns1(:))
nstart = [ns1(l),ns2(l)];
% nstart = [850,850];
% nstart = [1000,281]-[Np,Np]/2;
fn = [filedir,'ILED_0147.tif'];
I = imread(fn);
figure(30); imagesc(I(nstart(1):nstart(1)+Np-1,nstart(2):nstart(2)+Np-1));  drawnow;
axis image; colormap gray; axis off; drawnow;
% setup output folder for each patch
out_dir = [out_maindir,'\Res-patch-',num2str(nstart(1)),'-',num2str(nstart(2)),'-',...
    num2str(numlit),'LED-Result-bfbg'];
mkdir(out_dir);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read in general system parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SystemSetup4x_15_1_6();

%% load in data
% LED intensity normalization from the calibration data
% load('..\Intensity-LED-calibrate\ILEDMean40x');
Nimg = Nled;
Imea = zeros(Np,Np,Nimg);
Ibk = zeros(Nimg,1);
for m = 1:Nimg
    fn = [filedir,imglist(m).name];
    I = imread(fn);
    Imea(:,:,m) = double(I(nstart(1):nstart(1)+Np-1,nstart(2):nstart(2)+Np-1));
    bk1 = mean2(double(I(2052:2070,263:273)));
    bk2 = mean2(double(I(1581:1593,1281:1300)));
%         bk3 = mean2(double(I(650:700,1100:1500)));
    Ibk(m) = mean([bk1,bk2]);
%         Ibk(m) = 200;
%         Inorm(:,:,m) = Imea(:,:,m)/ILEDMean40x(m);
    if Ibk(m)>300
         Ibk(m) = Ibk(m-1);
    end
end

% %% brightfield index
% idx_l = [146,127,165];
% idx_r = [148,129,167];
% 
% I_l = 0; I_r = 0;
% for m = 1:length(idx_l)
%     il = idx_l(m); ir = idx_r(m);
%     I_l = I_l+Imea(:,:,il);
%     I_r = I_r+Imea(:,:,ir);
% end
% I_l = I_l/mean2(I_l); I_r = I_r/mean2(I_r);
% DPC = (I_l-I_r)./(I_l+I_r+eps);
%% corresponding LED locations
% find the on-LED indices
ledidx = 1:Nled;
ledidx = reshape(ledidx,numlit,Nimg);
lit = Litidx(ledidx);
lit = reshape(lit,numlit,Nimg);
% [litv,lith] = ind2sub([32,32],lit);
% find the index to reorder the measurements so that the image contains the
% central LEDs will be used first during the updates
%dis_lit = sqrt((litv-lit_cenv-1).^2+(lith-lit_cenh-1).^2);
% [dis_lit2,idx_led] = sort(min(dis_lit,[],1));
[dis_lit2,idx_led] = sort(reshape(illumination_na_used,1,Nled));

Nsh_lit = zeros(numlit,Nimg);
Nsv_lit = zeros(numlit,Nimg);

for m = 1:Nimg
    % should make sure it always covers all the leds
    % index of LEDs are lit for each pattern
    %lit = condenseridx(ceil(rand(numlit,1)*Nled));
    % corresponding index of spatial freq for the LEDs are lit
    lit0 = lit(:,m);
    Nsh_lit(:,m) = idx_u(lit0);
    Nsv_lit(:,m) = idx_v(lit0);
end

% reorder the LED indices and intensity measurements according the previous
% dis_lit
Ns = [];
Ns(:,:,1) = Nsv_lit;
Ns(:,:,2) = Nsh_lit;

Imea_reorder = Imea(:,:,idx_led);
Ibk_reorder = Ibk(idx_led);
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pre-processing the data to DENOISING is IMPORTANT
% Denoise 1. background subtraction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Ithresh_reorder = Imea_reorder;
for m = 1:Nimg
    Itmp = Ithresh_reorder(:,:,m);
    Itmp = Itmp-Ibk_reorder(m);
    Itmp(Itmp<0) = 0;
    Ithresh_reorder(:,:,m) = Itmp;
    
end

Ns_reorder = Ns(:,idx_led,:);

clear Imea 

% %% additional median filter to get rid off extra bad background in darkfield
% for m = NBF+1:Nimg
%     Itmp = Ithresh_reorder(:,:,m);
%     Itmp = Itmp-median(Itmp(:));
%     Ithresh_reorder(:,:,m) = Itmp;
%     Ithresh_reorder(Ithresh_reorder<0) = 0;
% end

%% calculate median of each image
% Imedian = median(median(Ithresh_reorder,1),2);
% %% background esimtation 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % pre-processing the data to DENOISING is IMPORTANT
% % Denoise II. residual background estimation and subtraction for Darkfield 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% bg_para1 = 50;
% NDF_bg = 21;
% idx_bg = find(Imedian(NBF+1:NDF_bg)>bg_para1)+NBF;
% h = fspecial('average', [Np/2,Np/2]);
% 
% for m = 1:length(idx_bg)
%     mm = idx_bg(m);
%     Itmp = Ithresh_reorder(:,:,mm);
%     bg = imfilter(Itmp, h, 'replicate');
%     Itmp = Itmp-bg;
% %    Itmp(Itmp<0) = 0;
%     Ithresh_reorder(:,:,mm) = Itmp;
% 
% end


%% calculate the Brightfield image before correction
% I_bf0 = sum(Ithresh_reorder(:,:,1:NBF),3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pre-processing the data to DENOISING is IMPORTANT
% Denoise II. residual background estimation and subtraction for
% Brightfield
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% bg_para2 = Imedian(1)/3*2;
% idx_bg_bf = find(Imedian(1:NBF)<bg_para2);
% idx_bf = find(Imedian(1:NBF)>bg_para2);
% Ibg = mean(Imedian(idx_bf));
% 
% for m = 1:length(idx_bg_bf)
%     mm = idx_bg_bf(m);
%     Itmp = Ithresh_reorder(:,:,mm);
%     bg = imfilter(Itmp, h, 'replicate');
%     Itmp = Itmp-bg+Ibg;
%     Ithresh_reorder(:,:,mm) = Itmp;
% end

%% brightfield image after correction
% I_bf = sum(Ithresh_reorder(:,:,1:NBF),3)/NBF;

%% this part check if the calculation of brightfield and darkfield  matches the experiments
% illumination_na_reorder = illumination_na_used(idx_led);
% 
% for m = 1:Nimg
%     Imean(m) = mean2(Ithresh_reorder(:,:,m));
% end
% 
% snr = Imean(:)./Ibk_reorder(:);




%% reconstruction algorithm

Nused = Nled;
idx_used = 1:Nused;
% idx_used = [find(Imean(1:NBF)>Imean(1)*2/3),find(Imean(NBF+1:Nused)<Imean(1)/5)+NBF];
% based on observation, brightfield does not have negative effect even if
% it appears as DF, but if a DF becomes BF, it is based, so drop it
% bkthresh = 100;
% idx_used = [1:NBF,find(Imean(NBF+1:Nused)<bkthresh)+NBF];

% idx_err = [find(Imean(1:NBF)<Imean(1)*2/3),find(Imean(NBF+1:Nused)>100)+NBF];
% idx_err = [find(Imean(NBF+1:Nused)>bkthresh)+NBF];
% disp(['problematic frames are ',num2str(idx_err),' and are discarded']);

%%
I = Ithresh_reorder(:,:,idx_used);
Ns2 = Ns_reorder(:,idx_used,:);

% I = I(:,:,[1:12,14:end]);
% Ns2 = Ns2(:,[1:12,14:end],:);

% reconstruction algorithm
opts.tol = 1;
opts.maxIter = 3;
opts.minIter = 2;
opts.monotone = 1;
% 'full', display every subroutin,
% 'iter', display only results from outer loop
% 0, no display
opts.display = 'iter';
% this method does not work for global minimization method

% cen0 = round((N_obj+1)/2);
% r = size(Ns2,1);
% if r == 1
%     n0 = row(Ns2(1,1,:));
% else
%     r0 = sum(squeeze(Ns2(:,1,:)).^2,2);
%     [~,idx0] = min(r0);
%     n0 = row(Ns2(idx0,1,:));
% end
upsamp = @(x) padarray(x,[(N_obj-Np)/2,(N_obj-Np)/2]);

opts.O0 = F(sqrt(I(:,:,1)));
opts.O0 = upsamp(opts.O0);
opts.P0 = w_NA;
opts.Ps = w_NA;
opts.iters = 1;
opts.mode = 'fourier';
% adaptive intensity factor c = sum(I_est)/sum(I_mea)
opts.adaptive = 0;
opts.adaptivemask = I(:,:,1)>0;
% initilize scaling factor at all ones for the adaptive method
opts.scale = ones(Nled,1);
% index of led used in the experiment
opts.ledidx = ledidx(:,idx_led);
opts.OP_alpha = 1;
opts.OP_beta = 1e3;
opts.scale_tau = 1e-3;
opts.min_mode = 'seq';
opts.fourier_mode = 'projection';
opts.scale_mode = 'newton';
opts.scale_alpha = 0;
% opts.scale_alpha = .5;

%%
[O,P,err_pc,c] = AlterMin_Adaptive(I,[N_obj,N_obj],round(Ns2),opts);

f3 = figure(88);
subplot(221); imagesc(abs(O)); axis image; colormap gray; colorbar;
title('ampl(o)');
subplot(222); imagesc(-angle(O)); axis image; colormap gray; colorbar;
title('phase(o)');
subplot(223); imagesc(abs(P)); axis image; colormap gray; colorbar;
title('ampl(P)');
subplot(224); imagesc(angle(P)); axis image; colormap gray; colorbar;
title('phase(P)');

% f4 = figure(79); plot(c(1:Nused));
% title('adaptive intensity correction factor');

fn = ['RandLit-',num2str(numlit),'-',num2str(Nused)];
save([out_dir,'\',fn],'O','P','err_pc','c');

saveas(f3,[out_dir,'\R-',fn,'.png']);
% saveas(f2,[out_dir,'\err-',fn,'.png']);
fprintf([fn,' saved\n']);

% f1 = figure(66); imagesc(-angle(O),[-1,1]); axis image; colormap gray; axis off
% export_fig(f1,[out_dir,'\ph-',num2str(Np),'.tif'],'-m2');

end 
