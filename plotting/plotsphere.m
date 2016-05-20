function plotsphere (x,y,z,scale,color)

    [X2, Y2, Z2] = sphere() ;
    col = repmat(reshape(color,1,1,3), [length(X2), length(X2), 1]) ;
    zl = zlim ;

    for i=1:length(x)
        surf(X2*scale(1) + x(i), Y2*scale(2) + y(i), Z2*scale(3) + z(i), col, ...
         'EdgeColor', 'none', 'FaceAlpha', 1) ;
    end

end

%%
%{
figure; hold on;
for N=1:10;
plot3([xscale*beadxyz(L).time(N,4),xscale*beadxyz(L).time(N,4)],[0,zscale*(10E-3-zmax+beadxyz(L).time(N,6))],[(yscale*(ymax-beadxyz(L).time(N,5))),(yscale*(ymax-beadxyz(L).time(N,5)))],'b-');
end
plot_3D(xscale*beadxyz(L).time(:,4),zscale*(10E-3-zmax+beadxyz(L).time(:,6)),(yscale*(ymax-beadxyz(L).time(:,5))),'18',[1,0,0]);
axis([ceil(xscale*0),ceil(xscale*xmax),0,ceil(zscale*zmax),ceil(yscale*0),ceil(yscale*ymax)]);
xlabel('(mm)')
zlabel('(mm)')
ylabel('Through Focus (mm)')
grid on
box on
view(-150,20)
axis([0,.832,0,6.4,0,.832]);
view(-150,20)
title(['3D Particle Detection']);
colormap gray
hold on
surface('XData',[0 .832; 0 .832],'YData',[0 0; 0 0],...
'ZData',[0 0; .832 .832],'CData',flipdim(imageData,1),...
'FaceColor','texturemap','EdgeColor','none');
hold off
%}
