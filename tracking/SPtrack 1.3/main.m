function main
showwindow('SPtrack','hide');
showwindow('instructions','minimize');
showwindow('Slicer','shownormal');


%open the file with parameters.
fid = fopen('parameter.m','r');
A = fscanf(fid,'%f');
fclose(fid);
sz = A(1,1);          % size of the blobs
itcf = A(2,1);        % intensity threshold
m = A(3,1);            %Number of frames to be worked upon
fps = A(4,1);          %frames per second
p = 0                 % dummy counter
for i = 1:m
[fileName,pathname] = uigetfile('*.tif;*.jpg')
fileName = [ pathname, fileName ];
%scrsz = get(0,'ScreenSize');
%figure('Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2])
%imshow(imread(fileName))
a = double(imread(fileName));
%colormap('gray'), imagesc(a);
t = i/fps ;

b = bpass(a,1,sz);
%colormap('gray'), image(b);
pk = pkfnd(b,itcf,sz);
%pk incase you wanna display the peak values

cnt = cntrd(b,pk,sz);
cnt
q = size(cnt);
cntpk = q(1,1); %number of peaks found.
display('the number of peaks is');
display(cntpk);
if cntpk ~= 0
    
x_final = cnt(1,1) ;
y_final = cnt(1,2) ;
%button = questdlg('The peak values are written on the command line.DO you wanna accept?','congrats','yes','no','default');
%switch button
 %   case 'yes'
       p = p + 1
        fid = fopen('x.txt','a+');
       fprintf(fid,'\n %12.8f ',x_final);
       fid = fopen('y.txt','a+');
       fprintf(fid,'\n %12.8f ',y_final);
       fid = fopen('time.txt', 'a+');
       fprintf(fid,'\n %12.8f ',t);
       fid = fopen('xy-data.txt', 'a+');
       fprintf(fid,'\n %12.8f %12.8f',x_final,y_final);
       %fprintf(fid,'%6.2f ',i); if u wanna print the frame.
    
  %  case 'no'
 %   ;   
%end
else
  p = p + 1
        fid = fopen('x.txt','a+');
       fprintf(fid,'\n %s ','   ');
       fid = fopen('y.txt','a+');
       fprintf(fid,'\n %s ','   ');
       fid = fopen('time.txt', 'a+');
       fprintf(fid,'\n %12.8f ',t);  
        fid = fopen('xy-data.txt', 'a+');
       fprintf(fid,'\n %12.8f %12.8f','   ','   ');
end
end


%if u wanna plot in matlab..not recommended....use openoffice instead.
%plotvalues
adios