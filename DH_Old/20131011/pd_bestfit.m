screensize=[1,1,800,700];
fig101=figure(101);set(fig101,'colormap',gray,'Position',screensize);
figure(101);colormap gray; imagesc(E0); colorbar;
title('Initial (typical) Hologram','FontSize',20);
daspect([1 1 1]); xlabel('(0.8 mm)');
 hold on;plot(Xman,Yman,'.g','MarkerSize',20);hold off;
fig102=figure(102);set(fig102,'Position',screensize);
figure(102);imagesc(Imin); colorbar; hold on;plot(Xauto,Yauto,'.b','MarkerSize',24);plot(Xman,Yman,'.g','MarkerSize',6);hold off;
daspect([1 1 1]); 
fig103=figure(103);set(fig103,'Position',screensize);
figure(103);imagesc(Imin); colorbar;
daspect([1 1 1]); 

 %  128.231*6.5E-6/8.4
 
%
clear d2 d3 d4;
A=[Xman;Yman]';
B=[Xauto;Yauto]';
d2=eucdist2(A,B);
d3=d2<4;
d4= zeros(size(d3));
d4(d3)=d2(d3);
numel(nonzeros(d4))
%