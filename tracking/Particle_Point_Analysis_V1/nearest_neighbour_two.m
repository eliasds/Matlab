function [point_indices, nn, num_nn]=nearest_neighbour_two(x_particle, y_particle)

[nn, num_nn]=nearest_neighbour(x_particle, y_particle);

% fprintf('Nearest Neighbours:\n')
% for i=1:length(nn), disp(nn{i}), end
cnt=1;
i=0;
while (cnt <= length(nn))
    if (length(nn{cnt})==6)
        i=i+1;
        point_indices(i)=cnt;
        for cnt1=1:6
            d(cnt1)=norm([x_particle(nn{cnt}(cnt1)) y_particle(nn{cnt}(cnt1))]-[x_particle(cnt) y_particle(cnt)]);
        end
        min1 = find(d==min(d));
        if (length(min1)>=2)
            nn{cnt}=[nn{cnt}(min1(1)) nn{cnt}(min1(2))];
        else
            d(min1)=Inf;
            min2 = find(d==min(d));
            nn{cnt}=[nn{cnt}(min1) nn{cnt}(min2)];
        end
        
    else
        nn{cnt}=[Inf];
    end
    cnt=cnt+1;
end

num_nn(1,:)=2;

% fprintf('2 Nearest Neighbours:\n')
% for i=1:length(nn)
%     if nn{i}~=Inf
%         fprintf('%g:',i);
%         for j=1:2
%             fprintf('(%g, %g) ',x_particle(nn{i}(j)), y_particle(nn{i}(j)));
%         end
%         fprintf('\n')
%     end
% end

