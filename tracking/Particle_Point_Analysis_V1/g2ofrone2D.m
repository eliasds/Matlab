function d=g2ofrone2D(data1)

xx = data1(:,1)';
yy = data1(:,2)';

fprintf('Determining Nearest Neighbours...\n');
[point_indices, nn, num_nn]=nearest_neighbour_two(xx,yy);

fprintf('Calculating Bond Order Parameters...\n');
S = bond_order_parameters_two(xx, yy, point_indices, nn, num_nn);

Pos1 = [xx(point_indices)' yy(point_indices)'] %read in the (x,y) coordinates

% figure
% scatter(xx(point_indices)', yy(point_indices)');

pi = 3.1415926;

maxX1 = max(Pos1(:,1));
maxY1 = max(Pos1(:,2));
minX1 = min(Pos1(:,1));
minY1 = min(Pos1(:,2));

[num1,junk1] = size(Pos1);   %num1 = number of coordinates/points; junk1 = useless info

vol = (maxX1-minX1)*(maxY1-minY1); %only approximate for non-square
dens1 = num1/vol;                  %computes average density in area of interest

R = zeros(num1,num1);

fprintf('Determining Radial Distances...\n');
cnt=0;
parfor m=1:num1
    for n=1:num1
        R(m,n)=norm(Pos1(m,:)-Pos1(n,:));
        cnt=cnt+1;
    end
end

fprintf('Performing Correlation Calculation...\n');
r = zeros(num1,1);              % List of particle particle distances
s = zeros(num1,1);              % List of pair wise particle dot products
dens1
point_density(xx,yy)
gofr = zeros(100,5);
for i = 1:1200  %300 steps
    radius = i*0.1; %of 0.1 microns
    inn = radius-0.1;
    count=0;
    aannulus = 0;
    sum_of_S=0;
    for m=1:length(point_indices)    %do this for every single particle i.e. num1
        if ((Pos1(m,1)-radius < minX1) || (Pos1(m,1)+radius > maxX1)) %if particle is out of bounds
            continue
        elseif ((Pos1(m,2)-radius < minY1) || (Pos1(m,2)+radius > maxY1))
            continue
        else
            aannulus = aannulus + pi*radius*radius - pi*inn*inn;    %calculate area of ring
        end
%         for n=1:num1
%             r(n) = norm(Pos1(m,:)-Pos1(n,:)); % This is the slow part
%         end
        r = R(m,:); % Replace with a radial distance array
        lessth = [r<radius];
        greaterth = [lessth.*r>inn];
        count = count+sum(greaterth);       %count number of particles in annulus
        indices = find(greaterth==1);
        if (isempty(indices)==0)
            dot_of_S = abs(conj(S(m))*S(indices));
            sum_of_S = sum_of_S + sum(dot_of_S);
        end
    end
    aannulus;
    fprintf('%g \n', i/300*100);
    gofr(i,1) = radius;
    gofr(i,2) = count/(aannulus*dens1); %normalize count/probability (maybe off by factor due to dens)
    gofr(i,3) = count;
    gofr(i,4) = aannulus;
    gofr(i,5) = sum_of_S/count;
end

indices=find(isnan(gofr(:,5))==1);
gofr(indices,5)=0;

d = gofr


