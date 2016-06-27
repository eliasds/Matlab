function [handlefig, handleimg, handlex, handley, xprofile, yprofile] = improfile2( img, ncent, mcent, proflength )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[m,n] = size(img);
iter = 0; % 5 makes smoother graphs;
% mcent = round(size(img)/2);
% ncent = mcent(2); % x-position
% mcent = mcent(1); % y-position

handlefig = figure;
handleimg = subplot(9,8,[1:7,9:15,17:23,25:31,33:39,41:47,49:55]);
imagesc(img); axis image; axis ij, axis off
hold on
line([0 n],[mcent mcent],'Color',[1 0 0]);
line([ncent ncent],[0 m],'Color',[0 1 0]);
hold off

xprofile = improfile(img,[1 n],[mcent mcent]);
yprofile = improfile(img,[ncent ncent],[1 m]);
for L = 1:iter
    xprofile = xprofile + improfile(img,[1 n],[mcent-1*L mcent-1*L]);
    xprofile = xprofile + improfile(img,[1 n],[mcent+1*L mcent+1*L]);
    yprofile = yprofile + improfile(img,[ncent-1*L ncent-1*L],[1 m]);
    yprofile = yprofile + improfile(img,[ncent+1*L ncent+1*L],[1 m]);
end
if isequal(L,[])
    L = 0;
end
xprofile = xprofile / (2*L+1);
yprofile = yprofile / (2*L+1);

%Set Length of Profile
xprofile = xprofile(ncent-proflength(1)/2:ncent+proflength(1)/2);
yprofile = yprofile(mcent-proflength(2)/2:mcent+proflength(2)/2);

minprofile = min(min([xprofile, yprofile]));
maxprofile = max(max([xprofile, yprofile]));

handlex = subplot(9,8,[58:62]);
plot(xprofile,'Color',[1 0 0])
axis([0,numel(xprofile),minprofile,maxprofile])

handley2 = subplot(9,8,[66:70]);
plot(yprofile,'Color',[0 1 0])
axis([0,numel(yprofile),minprofile,maxprofile])

handley = subplot(9,8,[8,16,24,32,40,48,56]);
plot(yprofile,[1:numel(yprofile)],'Color',[0 1 0])
axis([minprofile,maxprofile,0,numel(yprofile)])

end

