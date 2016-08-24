function [row1b,column1b,correlation,velvector]=candicorrcc(row1,column1,canpos,im1,im2,l)
% Algorithm made by PhD Wernher Brevis
% Modify for this interface by MSc Antoine Patalano (2012)

try
    handles=guihandles(getappdata(0,'hgui'));
catch
end
imsize=size(im1);
totpart=length(row1);

for i=1:totpart
        try
              set(handles.progress, 'string' , ['Frame progress: ' int2str(i/totpart*100) '% p:2']);drawnow;
          catch
              fprintf('.');
        end
		r1=round(row1(i));
		c1=round(column1(i));
		subm1=0;
		subm2=0;
		R=0;
        sizecanpos=size(canpos(i).data);
        
		for j=1:sizecanpos(1)
			
			r2=round(canpos(i).data(j,1));
			c2=round(canpos(i).data(j,2));

			vec1=[r1 c1 r2 c2];
			vec2=[r1 r2];
			vec3=[c1 c2];

			minim=round(vec1-l(i));
			maximrow=round(vec2+l(i));
			maximcol=round(vec3+l(i));
			
			posminim=find(minim<1);    % Finding a position out of the image
			posmaximrow=find(maximrow>imsize(1));
			posmaximcol=find(maximcol>imsize(2));


			minim(posminim)=1;
			maximrow(posmaximrow)=imsize(1);
			maximcol(posmaximcol)=imsize(2);

			deltaminim=vec1-minim;
			deltamaximrow=maximrow-vec2;
			deltamaximcol=maximcol-vec3;

			deltar_a=min([deltaminim(1) deltaminim(3)]);
			deltar_b=min(deltamaximrow);

			deltac_a=min([deltaminim(2) deltaminim(4)]);
			deltac_b=min(deltamaximcol);

			subm1=im1((r1-deltar_a):(r1+deltar_b),(c1-deltac_a):(c1+deltac_b));
			subm2=im2((r2-deltar_a):(r2+deltar_b),(c2-deltac_a):(c2+deltac_b));
			

            R(j)=corr2(subm1,subm2);


    	end
		

		pospart=find(R==max(R));
        
        if length(pospart)~=0
        row1b(i)=canpos(i).data(pospart(1),1);
		column1b(i)=canpos(i).data(pospart(1),2);
        velvector(i).data(1)=canpos(i).data(pospart(1),4);
        velvector(i).data(2)=canpos(i).data(pospart(1),3);
        correlation(i)=R(pospart(1));
        end
           
        if length(pospart)==0
        row1b(i)=NaN;
		column1b(i)=NaN;
        velvector(i).data(1)=NaN;
        velvector(i).data(2)=NaN;
        correlation(i)=NaN;
        end


end