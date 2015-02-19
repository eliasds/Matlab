function [Xman,Yman,Zman] = pd_click(E0, z1, z2, numz, lambda, eps)

Xman = [];
Yman = [];
Zman = [];

figure(98);colormap gray;

z = linspace(z1,z2,numz);

for j=1:numel(z)
    E1 = fp_fresnelprop(E0, lambda, z(j), eps);
    
    imagesc(abs(E1));
    title(['Z = ',num2str(z(j)),' (',num2str(j),'/',num2str(numel(z)),')']);
    hold on;
    isactive = true;
    
    x = [];
    y = [];
    
    %
    plot(Xman,Yman,'rx');
    
    while isactive
        [xnew,ynew] = ginput(1);
        if ~isempty(xnew)
            plot(xnew,ynew,'wo');
            x = [x, xnew];
            y = [y, ynew];
        else
            isactive = false;
        end
    end
    
    hold off;
    
    Xman = [Xman, x];
    Yman = [Yman, y];
    Zman = [Zman, ones(size(x))*z(j)];
end

%T = abs(E1)<thresh;
%T2 = imerode(T,ones(3,3));
%imdilate
%L = bwlabel(T2);
%R = regionprops(L, 'centroid','area','pixelidxlist','boundingbox');
