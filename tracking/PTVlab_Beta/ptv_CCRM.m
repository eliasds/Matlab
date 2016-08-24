function [dis_result,indicator]=ptv_CCRM(image1,image2,min2frame,tn,tq,tqfcc,tqfrm,percentcc,percentrm,epsilon,...
    corrcc,minprob,ccmark,rmmark,hymark,minneifrm,indicator,det_num,det_area,lw,roi_inpt,...
    row1,col1,row2,col2,prev_dis_result,ninit,nframe,roirect)

% this function performs the PTV analysis.
% Algorithm made by PhD Wernher Brevis
% Modify for this interface by MSc Antoine Patalano (2012)
warning off %MATLAB:log:logOfZero
if numel(roi_inpt)>0
    xroi=roi_inpt(1);
    yroi=roi_inpt(2);
    widthroi=roi_inpt(3);
    heightroi=roi_inpt(4);
    image1_roi=double(image1(yroi:yroi+heightroi,xroi:xroi+widthroi));
    image2_roi=double(image2(yroi:yroi+heightroi,xroi:xroi+widthroi));
else
    xroi=0;
    yroi=0;
    image1_roi=double(image1);
    image2_roi=double(image2);
end
np2=length(row2);
np1=length(row1);
% if numel(mask_inpt)>0
%     cellmask=mask_inpt;
%     mask=zeros(size(image1_roi));
%     for i=1:size(cellmask,1);
%         masklayerx=cellmask{i,1};
%         masklayery=cellmask{i,2};
%         mask = mask + poly2mask(masklayerx-xroi,masklayery-yroi,size(image1_roi,1),size(image1_roi,2)); %kleineres eingangsbild und maske geshiftet
%     end
% else
%     mask=zeros(size(image1_roi));
% end
% mask(mask>1)=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%% Determining candidates and initializing probabilities for the relaxation method %%%%%%%%%%%%%%%%%%
if det_num==1
    [canpos,probis,l,maxprob,maxpos,row1,col1]=candiccrm(row1,col1,row2,col2,min2frame);
end

if det_area==1
    [canpos,probis,maxprob,maxpos,row1,col1]=candiccrmlw(row1,col1,row2,col2,lw);
    l(1:length(row1))=lw;
end

%pos2del=1;

%while pos2del~=0        % Cycle in order to ensure that the delted particles will be not neighbors
[row1,col1,posvecnei]=neiposccrm(row1,col1,tn);
%[row1,col1,posvecnei,canpos,probis,l,maxprob,maxpos,pos2del]=neiposccrm(row1,col1,tn,canpos,probis,l,maxprob,maxpos);
%end

%%%%%%%%% Determining correspondence in the second frame using Cross-correlation %%%%%%%%%%
if ccmark==1 | hymark==1  % All the vector of the Cc algorithm are eliminated for percent=100 so it is not necessary the
    %                                 % Cc analysis.
    disp('                               ');
    disp('--> Cross-correlation matching ...');
    
    %%%%% Reading images, just for cross-correlation method %%%%%%%%%%%%
    ima1=image1_roi;
    ima2=image2_roi;
    
    %% Determining temporal correspondence by cross-correlation, (row2,col2)
    %% have the coordinate of the particle position on frame 2.
    
    [row2,col2,correlation,velvector]=candicorrcc(row1,col1,canpos,ima1,ima2,l);
    
    %%%%%%%%%%%%%%%%%%%% Filtering cross-correlation results %%%%%%%%%%%%%%%%%
    
    [workpos,canpos,probis,maxprob,maxpos,validposcc]=filtercc(row1,col1,row2,col2,canpos,posvecnei,velvector,tqfcc,percentcc,probis,maxprob,maxpos,corrcc,correlation);
    
    
    
    mpcc=length(validposcc);           %%%% Information variable
    fpcc=length(workpos);              %%% Information variable
    
    
    if ccmark==1 | length(workpos)==0
        disp('                        ');
        disp('Nothing is analyzed by relaxation methods!')
        %
        mprm=0;    %%Information variable
        fprm=0;    %%Information variable
        
        
        
        
        if mpcc~=0
            %%%% Initialising identity in case of first frame analysis %%%%
            if  nframe==ninit
                dis_result(:,6)=[1:mpcc];
            end
            
            if indicator==1;
                [dis_result]=lagrangeannodata(prev_dis_result,dis_result,mpcc);
            end
            
            dis_result(:,1)=row1(validposcc);
            dis_result(:,2)=col1(validposcc);
            dis_result(:,3)=row2(validposcc);
            dis_result(:,4)=col2(validposcc);
            dis_result(:,5)=ones(length(dis_result(:,1)),1);
            
            if  nframe>ninit | indicator==0
                %%%% Execution of langrangian tracking %%%%%%%%
                
                [dis_result]=lagrangeanpathccrm(dis_result,prev_dis_result,roirect);
            end
            
            
        end
        
        if mpcc==0
            disresult=[];
            indicator=1;
            
        end
        
    end
    
end

clear ima1 ima2

if rmmark==1
    mpcc=0;
    fpcc=0;
end

if rmmark==1 | hymark==1
    
    if rmmark==1 | mpcc==0
        workpos=[1:length(row1)];
    end
    
    % %%%%%%%%%%%%%%%%%%% Correspondence using relaxation methods %%%%%%%%%%%%%%
    
    if length(workpos)~=0 % if workpos is empty the Rm step it is not necessary, that means that the Cc
        % algorithm  was able to complete the analysis.
        disp('--> Relaxation methods matching ...');
        clear col2 row2
        
        ask=0;
        iter=0;
        
        while ask~=1
            [canpos,probis,maxprob,maxpos,ask,workpos]=relaxationmatching(workpos,posvecnei,canpos,epsilon,probis,tq,maxprob,maxpos);
        end
        
        
        for i=1:length(canpos)
            row2(1,i)=canpos(i).data(maxpos(i),1);
            col2(1,i)=canpos(i).data(maxpos(i),2);
        end
        
        [validresult]=filterrm(col1,row1,col2-col1,row2-row1,posvecnei,tqfrm,percentrm,minprob,probis,maxprob,minneifrm);
        
        
        %         if length(validresult)~=0% check if no valid result
        
        
        %%%%%%%%%%%%%%%%%%%%%%%% Information %%%%%%%%%%%%%%%%%%%%%%%
        if hymark==1
            mprm=length(validresult)-mpcc;   %%%% Information variable
            fprm=fpcc-mprm;     %%%% Information variable
        end
        
        if rmmark==1
            mprm=length(validresult);
            fprm=length(canpos)-mprm;
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Indicator==1 means that previous file doesn't have data
        try
            n_data=length(validresult);
            
            if nframe==ninit | indicator==1
                dis_result(:,6)=[1:n_data];
            end
            %
            
            dis_result(:,1)=row1(validresult);
            dis_result(:,2)=col1(validresult);
            dis_result(:,3)=row2(validresult);
            dis_result(:,4)=col2(validresult);
            dis_result(:,5)=ones(length(dis_result(:,1)),1);
            %         end
            
            
            %% indicator==0 mean that previous data has data
            if  nframe>ninit |indicator==0
                %%%% Execution of langrangian tracking %%%%%%%%
                [dis_result]=lagrangeanpathccrm(dis_result,prev_dis_result,roirect);
            end
            
            %%%% In case there are no result indicator is set to 1
            %%%% and the next iteration will not read the previous
            %%%% data
        catch
        end
        
    end
end

if length(dis_result)~=0
    indicator=0;
end

disp(sprintf('--> Number of particles in image 1 of frame %d: %d',nframe, np1));
disp(sprintf('--> Number of particles in image 2 of frame %d: %d',nframe, np2));
disp(sprintf('--> Total matched particles by Cross-correlation: %d  (Filtered: %d)',mpcc,fpcc));
disp(sprintf('--> Total matched particles by Relaxation methods: %d  (Filtered: %d)',mprm,fprm));




end





