
[filesort,numfiles] = filesortstruct('15um*','dir');
for L = 3:numfiles
    cd(filesort(L).name)
    makevideo('Bas*.tiff','rescale',[768 768],'fps',10,'skipframes',5,'output',filesort(L).name);
    rollingbg( 'Bas*.tiff', 100 );
    removebg( 'Bas*' );
    cd holofiles
    makevideo('Bas*.mat','rescale',[768 768],'fps',5,'skipframes',2,'output',[filesort(L).name,'_Holofile']);
    cd ..
    cd ..
end