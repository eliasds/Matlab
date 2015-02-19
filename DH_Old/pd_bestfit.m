screensize=[1,1,750,700];
fig101=figure(101);set(fig101,'colormap',gray,'Position',screensize);
figure(101);colormap gray; imagesc(E0); hold on;plot(Xman,Yman,'.g','MarkerSize',20);hold off;
fig102=figure(102);set(fig102,'Position',screensize);
figure(102);imagesc(Imin);hold on;plot(Xauto,Yauto,'.b','MarkerSize',20);plot(Xman,Yman,'.g','MarkerSize',8);hold off;

A=[Xman;Yman]';
B=[Xauto;Yauto]';
d2=eucdist2(A,B);
d3=d2<6;
d4= zeros(size(d3));
d4(d3)=d2(d3);
