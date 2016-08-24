function y=g_graph(x,symb,c_e,c_x,c_y);
%--------------------------------------------------------------------
% gedit function       graph ploting and editing using the mouse.
%                      -the left button for deleting a point.
%                      -the second button for getting the
%                       row in which the x and y values of the point 
%		        are the closest to the mouse location.
%                       (to the screen, and optionally - to a file)
%		       -the right button to exit the editing
%                       mode.
% Input  : - sorted column matrix to plot.
%          - symb is the graph symbol: '.','o','*' etc.
%            default is solid line.
%          - c_e, the column of error bar. default is no error bar.
%          - c_x, the column of time. default is 1.
%          - c_y, the column of magnitudes. default is 2.
% Output : - new matrix after editing. (deleting points)
% Tested : Matlab 5.0
%     By : Eran O. Ofek
%                         last modified by Orly Gnat  July 1997          
%    URL : http://wise-obs.tau.ac.il/~eran/matlab.html
%--------------------------------------------------------------------

c=input('Do you want data to be written to file? (y/n)   ','s');
if (c == 'y'),
	s=input('Enter the file''s name (all data now in the file will be deleted):   ','s');
	fid = fopen(s,'w');
end;


if nargin==1,
   c_x = 1;
   c_y = 2;
   symb = '-';
elseif nargin==2,
   c_x = 1;
   c_y = 2;
elseif nargin==3,
   wid=length(x(1,:));
   if c_e>wid,
      error('error bar column, no such column');
   end
   c_x = 1;
   c_y = 2;
elseif nargin>5,
   error('1, 2, 3 or 5 args only');
elseif nargin==4,
   error('1, 2, 3 or 5 args only');
end
plot(x(:,c_x),x(:,c_y),symb);
if nargin>2,
   hold on;
   errorbar(x(:,c_x),x(:,c_y),x(:,c_e));
   hold off;
end
y = x;

[raw,col] = size(y);

for i=1:1:100,
   [xp,yp,b]=ginput(1);
   if b==3,
      break;
   end
   [d,ind] = min((y(:,c_x) - xp).^2 + (y(:,c_y) - yp).^2);
   ly = length(y(:,c_x));
   if b==1,
      if ind==1,
         y = y(2:ly,:);
      elseif ind==ly,
         y = y(1:ly-1,:);
      else
         y = [y(1:ind-1,:); y(ind+1:ly,:)];
      end
   elseif b==2,
       [y(ind,:)]
  	if  (c == 'y'),
		for my_index = 1:col,
			fprintf(fid,'%8.3f   ',y(ind,my_index));
		end
		fprintf(fid,'\n');
	end
   else
       error('unknown mouse button');
   end
end

if (c == 'y'), 
	fclose(fid);
end
