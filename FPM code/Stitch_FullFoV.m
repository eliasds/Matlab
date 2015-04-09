function Stitch_FullFoV(out_maindir,Np,overlap_data, ma, mi_ph, ma_ph)
%% image stitching based on alpha blending
% last modified on 5/8/2014
% by Lei Tian,(lei_tian@alum.mit.edu)

numlit = 1;
Nused = 293;
%% basic parameters for reconstruction
% Np = 560;
% overlap_data = 160;
ns1 = 1:Np-overlap_data:2160; ns1 = ns1(1:end-1);
ns2 = 1:Np-overlap_data:2560; ns2 = ns2(1:end-1);

out_dir = [out_maindir,'Res-patch-1-1-1LED-Result-bfbg'];
fn = [out_dir,'\RandLit-1-293'];
load(fn);

Nobj = size(O,1);
UpFactor = Nobj/Np;
overlap_O = UpFactor*overlap_data;

n1 = length(ns1)*(Nobj-overlap_O)+overlap_O;
n2 = length(ns2)*(Nobj-overlap_O)+overlap_O;

%% start stitching
obj_stitch = zeros(n1,n2);

l = 1:overlap_O;
ll = repmat(l,[Nobj,1]);
weight = (ll-1)/overlap_O;

% center
for m = 2:length(ns1)-1
    for n = 2:length(ns2)-1
        %% load in file
        out_dir = [out_maindir,'\Res-patch-',num2str(ns1(m)),'-',num2str(ns2(n)),'-',...
            num2str(numlit),'LED-Result-bfbg'];
        fn = [out_dir,'\RandLit-',num2str(numlit),'-',num2str(Nused)];
        load(fn);
        %% process edge pixels by alpha blending
        %         O1 = O;
        %         for ll = 1:overlap_O
        %             O(end-ll+1,:) = O(end-ll+1,:)*(ll-1)/overlap_O;
        %             O(ll,:) = O(ll,:)*(ll-1)/overlap_O;
        %             O(:,ll) = O(:,ll)*(ll-1)/overlap_O;
        %             O(:,end-ll+1) = O(:,end-ll+1)*(ll-1)/overlap_O;
        %         end
        O(Nobj:-1:Nobj-overlap_O+1,:) = O(Nobj:-1:Nobj-overlap_O+1,:).*weight';
        O(1:overlap_O,:) = O(1:overlap_O,:).*weight';
        O(:,1:overlap_O) = O(:,1:overlap_O).*weight;
        O(:,Nobj:-1:Nobj-overlap_O+1) = O(:,Nobj:-1:Nobj-overlap_O+1).*weight;
        
        na = [(m-1)*(Nobj-overlap_O)+1,(n-1)*(Nobj-overlap_O)+1];
        nb = na+[Nobj-1,Nobj-1];
        %         O_tmp = padarray(padarray(O1,[(m-1)*(Nobj-overlap_O),...
        %             (n-1)*(Nobj-overlap_O)],'pre'),...
        %             [(length(ns1)-m)*(Nobj-overlap_O),...
        %             (length(ns2)-n)*(Nobj-overlap_O)],'post');
        
        %         obj_stitch = obj_stitch+O_tmp;
        obj_stitch(na(1):nb(1),na(2):nb(2)) = obj_stitch(na(1):nb(1),na(2):nb(2))+O;
    end
end

%% top
for n = 2:length(ns2)-1
    m = 1;
    % load in file
    out_dir = [out_maindir,'\Res-patch-',num2str(ns1(m)),'-',num2str(ns2(n)),'-',...
        num2str(numlit),'LED-Result-bfbg'];
    fn = [out_dir,'\RandLit-',num2str(numlit),'-',num2str(Nused)];
    load(fn);
    
    % process edge pixels by alpha blending
    %     O = O;
    %     for ll = 1:overlap_O
    %         O(end-ll+1,:) = O(end-ll+1,:)*(ll-1)/overlap_O;
    %         %         O1(ll,:) = O1(ll,:)*(ll-1)/overlap_O;
    %         O(:,ll) = O(:,ll)*(ll-1)/overlap_O;
    %         O(:,end-ll+1) = O(:,end-ll+1)*(ll-1)/overlap_O;
    %     end
    
    O(Nobj:-1:Nobj-overlap_O+1,:) = O(Nobj:-1:Nobj-overlap_O+1,:).*weight';
    %         O(1:overlap_O,:) = O(1:overlap_O,:).*weight';
    O(:,1:overlap_O) = O(:,1:overlap_O).*weight;
    O(:,Nobj:-1:Nobj-overlap_O+1) = O(:,Nobj:-1:Nobj-overlap_O+1).*weight;
    
    %     O_tmp = padarray(padarray(O1,[(m-1)*(Nobj-overlap_O),...
    %         (n-1)*(Nobj-overlap_O)],'pre'),...
    %         [(length(ns1)-m)*(Nobj-overlap_O),...
    %         (length(ns2)-n)*(Nobj-overlap_O)],'post');
    %
    %     obj_stitch = obj_stitch+O_tmp;
    na = [(m-1)*(Nobj-overlap_O)+1,(n-1)*(Nobj-overlap_O)+1];
    nb = na+[Nobj-1,Nobj-1];
    %         O_tmp = padarray(padarray(O1,[(m-1)*(Nobj-overlap_O),...
    %             (n-1)*(Nobj-overlap_O)],'pre'),...
    %             [(length(ns1)-m)*(Nobj-overlap_O),...
    %             (length(ns2)-n)*(Nobj-overlap_O)],'post');
    
    %         obj_stitch = obj_stitch+O_tmp;
    obj_stitch(na(1):nb(1),na(2):nb(2)) = obj_stitch(na(1):nb(1),na(2):nb(2))+O;
    
end
%% bottom
for n = 2:length(ns2)-1
    m = length(ns1);
    % load in file
    out_dir = [out_maindir,'\Res-patch-',num2str(ns1(m)),'-',num2str(ns2(n)),'-',...
        num2str(numlit),'LED-Result-bfbg'];
    fn = [out_dir,'\RandLit-',num2str(numlit),'-',num2str(Nused)];
    load(fn);
    
    % process edge pixels by alpha blending
    %     O = O;
    %     for ll = 1:overlap_O
    %         %         O1(end-ll+1,:) = O1(end-ll+1,:)*(ll-1)/overlap_O;
    %         O(ll,:) = O(ll,:)*(ll-1)/overlap_O;
    %         O(:,ll) = O(:,ll)*(ll-1)/overlap_O;
    %         O(:,end-ll+1) = O(:,end-ll+1)*(ll-1)/overlap_O;
    %     end
    %          O(Nobj:-1:Nobj-overlap_O+1,:) = O(Nobj:-1:Nobj-overlap_O+1,:).*weight';
    O(1:overlap_O,:) = O(1:overlap_O,:).*weight';
    O(:,1:overlap_O) = O(:,1:overlap_O).*weight;
    O(:,Nobj:-1:Nobj-overlap_O+1) = O(:,Nobj:-1:Nobj-overlap_O+1).*weight;
    
    
    
    %     O_tmp = padarray(padarray(O1,[(m-1)*(Nobj-overlap_O),...
    %         (n-1)*(Nobj-overlap_O)],'pre'),...
    %         [(length(ns1)-m)*(Nobj-overlap_O),...
    %         (length(ns2)-n)*(Nobj-overlap_O)],'post');
    %
    %     obj_stitch = obj_stitch+O_tmp;
    na = [(m-1)*(Nobj-overlap_O)+1,(n-1)*(Nobj-overlap_O)+1];
    nb = na+[Nobj-1,Nobj-1];
    %         O_tmp = padarray(padarray(O1,[(m-1)*(Nobj-overlap_O),...
    %             (n-1)*(Nobj-overlap_O)],'pre'),...
    %             [(length(ns1)-m)*(Nobj-overlap_O),...
    %             (length(ns2)-n)*(Nobj-overlap_O)],'post');
    
    %         obj_stitch = obj_stitch+O_tmp;
    obj_stitch(na(1):nb(1),na(2):nb(2)) = obj_stitch(na(1):nb(1),na(2):nb(2))+O;
    
end
%% left
for m = 2:length(ns1)-1
    n = 1;
    % load in file
    out_dir = [out_maindir,'\Res-patch-',num2str(ns1(m)),'-',num2str(ns2(n)),'-',...
        num2str(numlit),'LED-Result-bfbg'];
    fn = [out_dir,'\RandLit-',num2str(numlit),'-',num2str(Nused)];
    load(fn);
    
    % process edge pixels by alpha blending
    %     O = O;
    %     for ll = 1:overlap_O
    %         O(end-ll+1,:) = O(end-ll+1,:)*(ll-1)/overlap_O;
    %         O(ll,:) = O(ll,:)*(ll-1)/overlap_O;
    %         %         O1(:,ll) = O1(:,ll)*(ll-1)/overlap_O;
    %         O(:,end-ll+1) = O(:,end-ll+1)*(ll-1)/overlap_O;
    %     end
    O(Nobj:-1:Nobj-overlap_O+1,:) = O(Nobj:-1:Nobj-overlap_O+1,:).*weight';
    O(1:overlap_O,:) = O(1:overlap_O,:).*weight';
    %         O(:,1:overlap_O) = O(:,1:overlap_O).*weight;
    O(:,Nobj:-1:Nobj-overlap_O+1) = O(:,Nobj:-1:Nobj-overlap_O+1).*weight;
    
    %     O_tmp = padarray(padarray(O1,[(m-1)*(Nobj-overlap_O),...
    %         (n-1)*(Nobj-overlap_O)],'pre'),...
    %         [(length(ns1)-m)*(Nobj-overlap_O),...
    %         (length(ns2)-n)*(Nobj-overlap_O)],'post');
    %
    %     obj_stitch = obj_stitch+O_tmp;
    na = [(m-1)*(Nobj-overlap_O)+1,(n-1)*(Nobj-overlap_O)+1];
    nb = na+[Nobj-1,Nobj-1];
    %         O_tmp = padarray(padarray(O1,[(m-1)*(Nobj-overlap_O),...
    %             (n-1)*(Nobj-overlap_O)],'pre'),...
    %             [(length(ns1)-m)*(Nobj-overlap_O),...
    %             (length(ns2)-n)*(Nobj-overlap_O)],'post');
    
    %         obj_stitch = obj_stitch+O_tmp;
    obj_stitch(na(1):nb(1),na(2):nb(2)) = obj_stitch(na(1):nb(1),na(2):nb(2))+O;
    
end
%% right
for m = 2:length(ns1)-1
    n = length(ns2);
    % load in file
    out_dir = [out_maindir,'\Res-patch-',num2str(ns1(m)),'-',num2str(ns2(n)),'-',...
        num2str(numlit),'LED-Result-bfbg'];
    fn = [out_dir,'\RandLit-',num2str(numlit),'-',num2str(Nused)];
    load(fn);
    
    % process edge pixels by alpha blending
    %     O = O;
    %     for ll = 1:overlap_O
    %         O(end-ll+1,:) = O(end-ll+1,:)*(ll-1)/overlap_O;
    %         O(ll,:) = O(ll,:)*(ll-1)/overlap_O;
    %         O(:,ll) = O(:,ll)*(ll-1)/overlap_O;
    %         %         O1(:,end-ll+1) = O1(:,end-ll+1)*(ll-1)/overlap_O;
    %     end
    O(Nobj:-1:Nobj-overlap_O+1,:) = O(Nobj:-1:Nobj-overlap_O+1,:).*weight';
    O(1:overlap_O,:) = O(1:overlap_O,:).*weight';
    O(:,1:overlap_O) = O(:,1:overlap_O).*weight;
    %         O(:,Nobj:-1:Nobj-overlap_O+1) = O(:,Nobj:-1:Nobj-overlap_O+1).*weight;
    
    %     O_tmp = padarray(padarray(O1,[(m-1)*(Nobj-overlap_O),...
    %         (n-1)*(Nobj-overlap_O)],'pre'),...
    %         [(length(ns1)-m)*(Nobj-overlap_O),...
    %         (length(ns2)-n)*(Nobj-overlap_O)],'post');
    %
    %     obj_stitch = obj_stitch+O_tmp;
    na = [(m-1)*(Nobj-overlap_O)+1,(n-1)*(Nobj-overlap_O)+1];
    nb = na+[Nobj-1,Nobj-1];
    %         O_tmp = padarray(padarray(O1,[(m-1)*(Nobj-overlap_O),...
    %             (n-1)*(Nobj-overlap_O)],'pre'),...
    %             [(length(ns1)-m)*(Nobj-overlap_O),...
    %             (length(ns2)-n)*(Nobj-overlap_O)],'post');
    
    %         obj_stitch = obj_stitch+O_tmp;
    obj_stitch(na(1):nb(1),na(2):nb(2)) = obj_stitch(na(1):nb(1),na(2):nb(2))+O;
    
end
%% Top left
m = 1; n = 1;
% load in file
out_dir = [out_maindir,'\Res-patch-',num2str(ns1(m)),'-',num2str(ns2(n)),'-',...
    num2str(numlit),'LED-Result-bfbg'];
fn = [out_dir,'\RandLit-',num2str(numlit),'-',num2str(Nused)];
load(fn);

% process edge pixels by alpha blending
% O = O;
% for ll = 1:overlap_O
%     O(end-ll+1,:) = O(end-ll+1,:)*(ll-1)/overlap_O;
%     %     O1(ll,:) = O1(ll,:)*(ll-1)/overlap_O;
%     %     O1(:,ll) = O1(:,ll)*(ll-1)/overlap_O;
%     O(:,end-ll+1) = O(:,end-ll+1)*(ll-1)/overlap_O;
% end

O(Nobj:-1:Nobj-overlap_O+1,:) = O(Nobj:-1:Nobj-overlap_O+1,:).*weight';
%         O(1:overlap_O,:) = O(1:overlap_O,:).*weight';
%         O(:,1:overlap_O) = O(:,1:overlap_O).*weight;
O(:,Nobj:-1:Nobj-overlap_O+1) = O(:,Nobj:-1:Nobj-overlap_O+1).*weight;

% O_tmp = padarray(padarray(O1,[(m-1)*(Nobj-overlap_O),...
%     (n-1)*(Nobj-overlap_O)],'pre'),...
%     [(length(ns1)-m)*(Nobj-overlap_O),...
%     (length(ns2)-n)*(Nobj-overlap_O)],'post');
%
% obj_stitch = obj_stitch+O_tmp;
na = [(m-1)*(Nobj-overlap_O)+1,(n-1)*(Nobj-overlap_O)+1];
nb = na+[Nobj-1,Nobj-1];
%         O_tmp = padarray(padarray(O1,[(m-1)*(Nobj-overlap_O),...
%             (n-1)*(Nobj-overlap_O)],'pre'),...
%             [(length(ns1)-m)*(Nobj-overlap_O),...
%             (length(ns2)-n)*(Nobj-overlap_O)],'post');

%         obj_stitch = obj_stitch+O_tmp;
obj_stitch(na(1):nb(1),na(2):nb(2)) = obj_stitch(na(1):nb(1),na(2):nb(2))+O;

%% Top right
m = 1; n = length(ns2);
% load in file
out_dir = [out_maindir,'\Res-patch-',num2str(ns1(m)),'-',num2str(ns2(n)),'-',...
    num2str(numlit),'LED-Result-bfbg'];
fn = [out_dir,'\RandLit-',num2str(numlit),'-',num2str(Nused)];
load(fn);

% process edge pixels by alpha blending
% O = O;
% for ll = 1:overlap_O
%     O(end-ll+1,:) = O(end-ll+1,:)*(ll-1)/overlap_O;
%     %         O1(ll,:) = O1(ll,:)*(ll-1)/overlap_O;
%     O(:,ll) = O(:,ll)*(ll-1)/overlap_O;
%     %     O1(:,end-ll+1) = O1(:,end-ll+1)*(ll-1)/overlap_O;
% end
O(Nobj:-1:Nobj-overlap_O+1,:) = O(Nobj:-1:Nobj-overlap_O+1,:).*weight';
%         O(1:overlap_O,:) = O(1:overlap_O,:).*weight';
O(:,1:overlap_O) = O(:,1:overlap_O).*weight;
%         O(:,Nobj:-1:Nobj-overlap_O+1) = O(:,Nobj:-1:Nobj-overlap_O+1).*weight;

% O_tmp = padarray(padarray(O1,[(m-1)*(Nobj-overlap_O),...
%     (n-1)*(Nobj-overlap_O)],'pre'),...
%     [(length(ns1)-m)*(Nobj-overlap_O),...
%     (length(ns2)-n)*(Nobj-overlap_O)],'post');
%
% obj_stitch = obj_stitch+O_tmp;
na = [(m-1)*(Nobj-overlap_O)+1,(n-1)*(Nobj-overlap_O)+1];
nb = na+[Nobj-1,Nobj-1];
%         O_tmp = padarray(padarray(O1,[(m-1)*(Nobj-overlap_O),...
%             (n-1)*(Nobj-overlap_O)],'pre'),...
%             [(length(ns1)-m)*(Nobj-overlap_O),...
%             (length(ns2)-n)*(Nobj-overlap_O)],'post');

%         obj_stitch = obj_stitch+O_tmp;
obj_stitch(na(1):nb(1),na(2):nb(2)) = obj_stitch(na(1):nb(1),na(2):nb(2))+O;

%% Bottom left
m = length(ns1); n = 1;
% load in file
out_dir = [out_maindir,'\Res-patch-',num2str(ns1(m)),'-',num2str(ns2(n)),'-',...
    num2str(numlit),'LED-Result-bfbg'];
fn = [out_dir,'\RandLit-',num2str(numlit),'-',num2str(Nused)];
load(fn);

% process edge pixels by alpha blending
% O = O;
% for ll = 1:overlap_O
%     %     O1(end-ll+1,:) = O1(end-ll+1,:)*(ll-1)/overlap_O;
%     O(ll,:) = O(ll,:)*(ll-1)/overlap_O;
%     %     O1(:,ll) = O1(:,ll)*(ll-1)/overlap_O;
%     O(:,end-ll+1) = O(:,end-ll+1)*(ll-1)/overlap_O;
% end

%         O(Nobj:-1:Nobj-overlap_O+1,:) = O(Nobj:-1:Nobj-overlap_O+1,:).*weight';
O(1:overlap_O,:) = O(1:overlap_O,:).*weight';
%         O(:,1:overlap_O) = O(:,1:overlap_O).*weight;
O(:,Nobj:-1:Nobj-overlap_O+1) = O(:,Nobj:-1:Nobj-overlap_O+1).*weight;

% O_tmp = padarray(padarray(O1,[(m-1)*(Nobj-overlap_O),...
%     (n-1)*(Nobj-overlap_O)],'pre'),...
%     [(length(ns1)-m)*(Nobj-overlap_O),...
%     (length(ns2)-n)*(Nobj-overlap_O)],'post');
%
% obj_stitch = obj_stitch+O_tmp;
na = [(m-1)*(Nobj-overlap_O)+1,(n-1)*(Nobj-overlap_O)+1];
nb = na+[Nobj-1,Nobj-1];
%         O_tmp = padarray(padarray(O1,[(m-1)*(Nobj-overlap_O),...
%             (n-1)*(Nobj-overlap_O)],'pre'),...
%             [(length(ns1)-m)*(Nobj-overlap_O),...
%             (length(ns2)-n)*(Nobj-overlap_O)],'post');

%         obj_stitch = obj_stitch+O_tmp;
obj_stitch(na(1):nb(1),na(2):nb(2)) = obj_stitch(na(1):nb(1),na(2):nb(2))+O;


%% Bottom right
m = length(ns1); n = length(ns2);
% load in file
out_dir = [out_maindir,'\Res-patch-',num2str(ns1(m)),'-',num2str(ns2(n)),'-',...
    num2str(numlit),'LED-Result-bfbg'];
fn = [out_dir,'\RandLit-',num2str(numlit),'-',num2str(Nused)];
load(fn);

% process edge pixels by alpha blending
% O = O;
% for ll = 1:overlap_O
%     %     O1(end-ll+1,:) = O1(end-ll+1,:)*(ll-1)/overlap_O;
%     O(ll,:) = O(ll,:)*(ll-1)/overlap_O;
%     O(:,ll) = O(:,ll)*(ll-1)/overlap_O;
%     %         O1(:,end-ll+1) = O1(:,end-ll+1)*(ll-1)/overlap_O;
% end
%         O(Nobj:-1:Nobj-overlap_O+1,:) = O(Nobj:-1:Nobj-overlap_O+1,:).*weight';
O(1:overlap_O,:) = O(1:overlap_O,:).*weight';
O(:,1:overlap_O) = O(:,1:overlap_O).*weight;
%         O(:,Nobj:-1:Nobj-overlap_O+1) = O(:,Nobj:-1:Nobj-overlap_O+1).*weight;

% O_tmp = padarray(padarray(O1,[(m-1)*(Nobj-overlap_O),...
%     (n-1)*(Nobj-overlap_O)],'pre'),...
%     [(length(ns1)-m)*(Nobj-overlap_O),...
%     (length(ns2)-n)*(Nobj-overlap_O)],'post');
%
% obj_stitch = obj_stitch+O_tmp;
na = [(m-1)*(Nobj-overlap_O)+1,(n-1)*(Nobj-overlap_O)+1];
nb = na+[Nobj-1,Nobj-1];
%         O_tmp = padarray(padarray(O1,[(m-1)*(Nobj-overlap_O),...
%             (n-1)*(Nobj-overlap_O)],'pre'),...
%             [(length(ns1)-m)*(Nobj-overlap_O),...
%             (length(ns2)-n)*(Nobj-overlap_O)],'post');

%         obj_stitch = obj_stitch+O_tmp;
obj_stitch(na(1):nb(1),na(2):nb(2)) = obj_stitch(na(1):nb(1),na(2):nb(2))+O;


fname_stitch = [out_maindir,'obj_stitch'];
save(fname_stitch,'obj_stitch','-v7.3');

%%
% ma = 6;
o = abs(obj_stitch);
o(o>ma)=ma;
o=uint8(o/ma*2^8);
% figure; imshow(o)
imwrite(o,[out_maindir,'ampl_fullFoV_1LED.tif']);
%%
op = angle(obj_stitch);
% op(op>ma_ph)=ma_ph;
% op(op<mi_ph) = mi_ph;
op=uint8((op-mi_ph)/(ma_ph-mi_ph)*2^8);
% figure; imshow(op)
imwrite(op,[out_maindir,'ph_fullFoV_1LED.tif']);

close all; clear; clc;
