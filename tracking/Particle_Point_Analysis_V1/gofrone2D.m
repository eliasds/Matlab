function d=gofrone2D(data1); 
%This gofr program actually works.  A little slow, but not too bad.  
%The value of g(r) goes to 1 at large radii as required by theory.
	% data1 = dataset number 1, 2+ columns    
    % calculation of g(r) based on description from Chaikin and Lubenski, p37.
    % modified for 2D vs 3D by MLK (Maria Kilfoil @ McGill) 8.6.03
    % minor modifications by Stephanie 10/10/2007
    %
    % Code optimization by Ian Dean Hosein @ Cornell August 23, 2008:
    % Optimized by replacing the for loop calculating the radial distance
    % r(n) within each iteration (slow part of the code) with a radial
    % distance array R(m,n) which contains pair-wise distances
    % between all particles. This array is determined before beginning the 
    % calculating of the pair correlation function. This avoids repetitive 
    % calculations in the loop, thus improving the speed of the calculation 
    % by approximately  O(n).
    
    Pos1 = [data1(:,1) data1(:,2)]; %read in the (x,y) coordinates
    
    pi = 3.1415926;
    
    maxX1 = max(Pos1(:,1));
    maxY1 = max(Pos1(:,2));
    minX1 = min(Pos1(:,1));
    minY1 = min(Pos1(:,2));
    
    [num1,junk1] = size(Pos1)   %num1 = number of coordinates/points; junk1 = useless info
    
    vol = (maxX1-minX1)*(maxY1-minY1); %only approximate for non-square
    dens1 = num1/vol;                  %computes average density in area of interest
    
    r = zeros(num1,1);
    

    parfor m=1:num1
        for n=1:num1
            R(m,n)=norm(Pos1(m,:)-Pos1(n,:));
        end
    end
    

    gofr = zeros(100,4);
    for i = 1:1200  %300 steps
        radius = i*0.025; %of 0.1 microns
        inn = radius-0.025;
        count=0;
        aannulus = 0;
        for m=1:num1    %do this for every single particle i.e. num1
            if ((Pos1(m,1)-radius < minX1) | (Pos1(m,1)+radius > maxX1)) %if particle is out of bounds
                continue
            elseif ((Pos1(m,2)-radius < minY1) | (Pos1(m,2)+radius > maxY1))
                continue   
            else
                aannulus = aannulus + pi*radius*radius - pi*inn*inn;    %calculate area of ring
            end
%             for n=1:num1
%                 r(n) = norm(Pos1(m,:)-Pos1(n,:)); This is the slow part
%             end
            r = R(m,:); % Replaced with a radial distance array
            lessth = [r<radius];
            greaterth = [lessth.*r>inn];
            count = count+sum(greaterth);       %count number of particles in annulus
        end
        aannulus
        gofr(i,1) = radius;
        gofr(i,2) = count/(aannulus*dens1); %normalize count/probability (maybe off by factor due to dens)
        gofr(i,3) = count;
        gofr(i,4) = aannulus;
    end
    
 d = gofr;
 
 % to plot the graph afterwards i type the following lines into the command
 % prompt:
 
 % x=1:300;
 % y=d(:,2);         
 % plot(x,y)