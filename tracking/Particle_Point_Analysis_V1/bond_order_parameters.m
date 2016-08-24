function [S]=bond_order_parameters(x_particle, y_particle, nn, num_nn)

S=zeros(1,length(x_particle));

for cnt1=1:length(x_particle)
    for cnt2=1:num_nn(cnt1)
        h=x_particle(nn{cnt1}(cnt2))-x_particle(cnt1);
        v=y_particle(nn{cnt1}(cnt2))-y_particle(cnt1);
        if (h~=0)
            theta = atan(v/h);
        else
            theta = atan(sign(v)*inf); 
        end
        S(cnt1) = S(cnt1) + exp(sqrt(-1)*(6*theta));
    end
    S(cnt1)=S(cnt1)/num_nn(cnt1);
end

S';

N = sum([num_nn==6]); % Determine all the particles that have 6 nearest neighbours
Savg = 0;
for cnt1=1:length(x_particle)
    if (num_nn(cnt1)==6)
        Savg = Savg + S(cnt1)/N;
    end
end

% for cnt1=1:length(x_particle)
%         Savg = Savg + S(cnt1)/length(x_particle);
% end

Savg=abs(Savg)