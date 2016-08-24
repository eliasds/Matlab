function [S]=bond_order_parameters_two(x_particle, y_particle, point_indices, nn, num_nn)

S=zeros(1,length(x_particle));

for cnt1=1:length(point_indices)
        for cnt2=1:2
            h=x_particle(nn{point_indices(cnt1)}(cnt2))-x_particle(point_indices(cnt1));
            v=y_particle(nn{point_indices(cnt1)}(cnt2))-y_particle(point_indices(cnt1));
            if (h~=0)
                theta = atan(v/h);
            else
                theta = atan(sign(v)*inf);
            end
            S(cnt1) = S(cnt1) + exp(sqrt(-1)*(2*theta));
        end
    S(cnt1)=S(cnt1)/num_nn(cnt1);
end
