
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Left - Right (Duets)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[~,J]=ismember(idx_left,idx_bf); J(J==0) = []; bfleft = 0; for L=idx_bf(J)'; bfleft = bfleft + Imea(:,:,L); end; figure(98); imagesc(real(bfleft)); colormap gray; colorbar; axis image; axis ij; title(L); drawnow
title('Bright Field (Left)')

[~,J]=ismember(idx_right,idx_bf); J(J==0) = []; bfright = 0; for L=idx_bf(J)'; bfright = bfright + Imea(:,:,L); end; figure(99); imagesc(real(bfright)); colormap gray; colorbar; axis image; axis ij; title(L); drawnow
title('Bright Field (Right)')

figure(100); imagesc(real(bfleft-bfright)); colormap gray; colorbar; axis image; axis ij; title(L); drawnow
title('Bright Field (Left - Right)')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Top - Bottom (Duets)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[~,J]=ismember(idx_top,idx_bf); J(J==0) = []; bftop = 0; for L=idx_bf(J)'; bftop = bftop + Imea(:,:,L); end; figure(198); imagesc(real(bftop)); colormap gray; colorbar; axis image; axis ij; title(L); drawnow
title('Bright Field (Top)')

[~,J]=ismember(idx_bottom,idx_bf); J(J==0) = []; bfbottom = 0; for L=idx_bf(J)'; bfbottom = bfbottom + Imea(:,:,L); end; figure(199); imagesc(real(bfbottom)); colormap gray; colorbar; axis image; axis ij; title(L); drawnow
title('Bright Field (Bottom)')

figure(200); imagesc(real(bftop-bfbottom)); colormap gray; colorbar; axis image; axis ij; title(L); drawnow
title('Bright Field (Top - Bottom)')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Diagonal (Quartets)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[~,J]=ismember(idx_top,idx_left); J(J==0) = [];
[~,J]=ismember(idx_left(J),idx_bf); J(J==0) = [];
[~,K]=ismember(idx_bottom,idx_right); K(K==0) = [];
[~,K]=ismember(idx_right(K),idx_bf); K(K==0) = [];
J = cat(1,J,K);
bftlbr = 0; for L=idx_bf(J)'; bftlbr = bftlbr + Imea(:,:,L); end; figure(298); imagesc(real(bftlbr)); colormap gray; colorbar; axis image; axis ij; title(L); drawnow
title('Bright Field (TopLeftBottomRight)')

[~,J]=ismember(idx_top,idx_right); J(J==0) = [];
[~,J]=ismember(idx_right(J),idx_bf); J(J==0) = [];
[~,K]=ismember(idx_bottom,idx_left); K(K==0) = [];
[~,K]=ismember(idx_left(K),idx_bf); K(K==0) = [];
J = cat(1,J,K);
bftrbl = 0; for L=idx_bf(J)'; bftrbl = bftrbl + Imea(:,:,L); end; figure(299); imagesc(real(bftrbl)); colormap gray; colorbar; axis image; axis ij; title(L); drawnow
title('Bright Field (TopRightBottomLeft)')

figure(300); imagesc(real(bftlbr-bftrbl)); colormap gray; colorbar; axis image; axis ij; title(L); drawnow
title('Bright Field (TopLeftBottomRight - TopRightBottomLeft)')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sextets (Under Construction)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[~,J]=ismember(idx_top,idx_left); J(J==0) = [];
[~,J]=ismember(idx_left(J),idx_bf); J(J==0) = [];
[~,K]=ismember(idx_bottom,idx_right); K(K==0) = [];
[~,K]=ismember(idx_right(K),idx_bf); K(K==0) = [];
J = cat(1,J,K);
bftlbr = 0; for L=idx_bf(J)'; bftlbr = bftlbr + Imea(:,:,L); end; figure(298); imagesc(real(bftlbr)); colormap gray; colorbar; axis image; axis ij; title(L); drawnow
title('Bright Field (TopLeftBottomRight)')

[~,J]=ismember(idx_top,idx_right); J(J==0) = [];
[~,J]=ismember(idx_right(J),idx_bf); J(J==0) = [];
[~,K]=ismember(idx_bottom,idx_left); K(K==0) = [];
[~,K]=ismember(idx_left(K),idx_bf); K(K==0) = [];
J = cat(1,J,K);
bftrbl = 0; for L=idx_bf(J)'; bftrbl = bftrbl + Imea(:,:,L); end; figure(299); imagesc(real(bftrbl)); colormap gray; colorbar; axis image; axis ij; title(L); drawnow
title('Bright Field (TopRightBottomLeft)')

figure(300); imagesc(real(bftlbr-bftrbl)); colormap gray; colorbar; axis image; axis ij; title(L); drawnow
title('Bright Field (TopLeftBottomRight - TopRightBottomLeft)')


