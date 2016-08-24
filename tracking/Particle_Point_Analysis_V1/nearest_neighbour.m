function [nn, num_nn]=nearest_neighbour(x_particle, y_particle)
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