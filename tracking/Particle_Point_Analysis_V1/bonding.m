function bonding()

a1=1.0;
a2=1.0;
theta=60;

expansion_a = 9;
expansion_b = 7;
a = -expansion_a:1:expansion_a;
b = -expansion_b:1:expansion_b;

x_limit = a1*expansion_a;
y_limit = a2*sin(theta*pi/180)*expansion_b;

count = 1;
        for cnt3=1:length(a)
            for cnt4=1:length(b)
                x_particle(count)=a(cnt3)*a1+b(cnt4)*a2*cos(theta*pi/180);
                y_particle(count)=b(cnt4)*a2*sin(theta*pi/180);
                count=count+1;
            end
        end



a=delaunay(x_particle,y_particle);

nn = cell(length(x_particle), 1);
num_nn = zeros(1,length(x_particle));

for n_tri=1:length(a)
    for index=1:3
        for neighbour=1:3
            if index~=neighbour
                if isempty(nn{a(n_tri,index)})
                    nn{a(n_tri,index)}=zeros(1,1);
                    num_nn(a(n_tri,index))=num_nn(a(n_tri,index))+1;
                    nn{a(n_tri,index)}(num_nn(a(n_tri,index)))=a(n_tri,neighbour);
                else if isempty(find(nn{a(n_tri,index)}==a(n_tri,neighbour)))
                    num_nn(a(n_tri,index))=num_nn(a(n_tri,index))+1;
                    nn{a(n_tri,index)}(num_nn(a(n_tri,index)))=a(n_tri,neighbour);
                    end
                end
            end
        end
    end
end


S1=0;
for cnt1=1:length(x_particle)
    S2=0;
    for cnt2=1:num_nn(cnt1)
        h=x_particle(nn{cnt1}(cnt2))-x_particle(cnt1);
        v=y_particle(nn{cnt1}(cnt2))-y_particle(cnt1);
        if (h==0)
            theta = (atan(inf));
        else
            theta = (atan(v/h));
        end
        S2 = S2 + exp(sqrt(-1)*(6*theta));
    end
    S2=S2/num_nn(cnt1);
    S1=S1+S2;
end

S1=abs(S1)/length(x_particle);

disp(S1);


S=0;
count=0;
for cnt1=1:length(a(:,1));
    x1=x_particle(a(cnt1,1));
    y1=y_particle(a(cnt1,1));
    x2=x_particle(a(cnt1,2));
    y2=y_particle(a(cnt1,2));
    x3=x_particle(a(cnt1,3));
    y3=y_particle(a(cnt1,3));
    %%%%%%%%%%%%%%%% Take into account edge effects %%%%%%%%%%%%%%%%
    aa = sqrt((x2-x1)^2+(y2-y1)^2);
    b = sqrt((x3-x1)^2+(y3-y1)^2);
    c = sqrt((x3-x2)^2+(y3-y2)^2);
    theta1 = acos(((x2-x1)*(x3-x1) + (y2-y1)*(y3-y1))/(aa*b))*180/pi;
    theta2 = acos(((x2-x1)*(x3-x2) + (y2-y1)*(y3-y2))/(aa*c))*180/pi;
    theta3 = acos(((x3-x1)*(x3-x2) + (y3-y1)*(y3-y2))/(b*c))*180/pi;
    x = [theta1 theta2 theta3];
    
    i = find(x==max(x));
    if i==1
            theta1=180-theta2-theta3;
    else if i==2
            theta2=180-theta1-theta3;
        else
            theta3=180-theta1-theta2;
        end
    end
    
    if (theta1 < 90 && theta2 < 90 && theta3 < 90)
        count=count+1;
        S = S + 0.5*abs((x1-x2)*(y1-y3)-(y1-y2)*(x1-x3));
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

N_density=count/(2*S);

disp(N_density);