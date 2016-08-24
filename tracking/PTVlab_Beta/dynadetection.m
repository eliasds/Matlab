function [i,j]=dynadetection(ima,t_base,c_t,ask)
% imasaved=ima;
% ima=ima(457:501,219:273);
t_base=40;
c_t=10;
ask=1;
finalima=zeros(size(ima));

%    a=figure;
%    figure(a)
%      subplot(2,2,1)
%     imshow(ima)
%     title('Imagen Actualizada')
%     subplot(2,2,2)
%     imshow(ima)
%     title('Imagen Binarizada con Umbral de base')
%     subplot(2,2,3)
%     imshow(ima)
%     title('"Diferencia" dif=(Promedio - Umbral de base)')
%     subplot(2,2,4)
%     imshow(ima)
%     title('Posición de particulas')
%     spaceplots([0 0 0 0],[0 0])
   
 imasaved=ima;

  indexname=0;
while ask==1
%   indexname=indexname+1;

    ima2=im2bw(ima,t_base/255);     
    [L, num] = bwlabel(ima2); 
    warning('off')
    [meanI]=regionprops(L,ima,'MeanIntensity');
    warning('on')
    pix_pos=regionprops(L,'PixelIdxList');
    mI=cell2mat(struct2cell(meanI));
  
    diff=abs(mI-t_base);    

    pos=find(diff<c_t);   
    finalima(cat(1,pix_pos(pos).PixelIdxList)')=1;    
    pos2=find(diff>=c_t);
    
    
    
    
    if length(pos2)==0
        ask=0;
    end
    
    if length(pos2)~=0
        ima(cat(1,pix_pos(pos2).PixelIdxList)')=ima(cat(1,pix_pos(pos2).PixelIdxList)')-1;
      


% figure(a)
%   subplot(2,2,1)
%     imshow(ima)
%     title('Imagen Actualizada','Color','blue')
%     
%     subplot(2,2,2)
%     imshow(ima2)
%     title('Imagen Binarizada con Umbral de base','Color','blue')
%     
%     subplot(2,2,3)    
%     plot([1:length(diff)],diff,'.')
%     hold on   
%     plot(pos,diff(pos),'.r')
%     red=plot([1 length(diff)],[c_t c_t],'r');
%     legend(red,'Umbral de Contraste Predeterminado')
%     set(gca,'OuterPosition',[0.017 -0.01 0.42 0.48])
%      title('"Diferencia" dif=(Promedio - Umbral de base)','Color','blue')
%     grid on
%     set(gca,'XTick',[],'YLim',[0 70],'XLim',[1 length(diff)],'ygrid','on'); 
%     ylabel('Intensidad')
%     hold off
   
    
% subplot(2,2,4)
%     imshow(0*finalima)
% %     imshow(finalima(242:307,184:233))
%     title('Reconstrucción de las particulas','Color','blue')
    

%  subplot(2,2,3)   
% 
% index=num2str(indexname,'%04i')
% 
% 
% subplot(2,2,2)
% 
%  ima3=255*uint8(ima2);
% %     ima3(cat(1,pix_pos(pos).PixelIdxList)')=125;
%     rgbImage = repmat(ima3,[1 1 3]);
% %     R=rgbImage(:,:,1);
%     G=rgbImage(:,:,2);
%     B=rgbImage(:,:,3);
%     
%     G(cat(1,pix_pos(pos).PixelIdxList)')=0;
%     B(cat(1,pix_pos(pos).PixelIdxList)')=0;
%     rgbImage(:,:,2)=G;
%     rgbImage(:,:,3)=B;    
%     imshow(rgbImage)
%     title('Imagen Binarizada con Umbral de base','Color','blue')

%    subplot(2,2,4)
%     imshow(finalima) 
%     title('Reconstrucción de las particulas','Color','blue')   
  
    end
    
end


[L, num] = bwlabel(finalima);
centro_pos=regionprops(L,'centroid');
C=cat(1,centro_pos.Centroid)';
i=C(2,:);
j=C(1,:);
% subplot(2,2,1)
% figure
% imshow(ima)
% hold on
% plot(C(1,:),C(2,:),'xr')
% title(['c_t=' num2str(c_t) ' y t_base='  num2str(t_base)])
% exportfig(gcf,fullfile('C:\Documents and Settings\Administrador\Mis documentos\Laboratorio_LH\PhD\Dropbox\8_PTVProto\Evaluación_de algoritmos\dynadetection.m\',['c_t=' num2str(c_t) ' y t_base='  num2str(t_base)]),...
%     'color','rgb','format','bmp','resolution',96*1,'FontMode', 'scaled','Bounds','loose');

            