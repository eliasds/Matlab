
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Left - Right
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[~,J]=ismember(idx_left,idx_bf); J(J==0) = []; bfleft = 0; for L=idx_bf(J)'; bfleft = bfleft + Imea(:,:,L); end; figure(98); imagesc(real(bfleft)); colormap gray; colorbar; axis image; axis ij; title(L); drawnow
title('Bright Field (Left)')

[~,J]=ismember(idx_right,idx_bf); J(J==0) = []; bfright = 0; for L=idx_bf(J)'; bfright = bfright + Imea(:,:,L); end; figure(99); imagesc(real(bfright)); colormap gray; colorbar; axis image; axis ij; title(L); drawnow
title('Bright Field (Right)')

figure(100); imagesc(real(bfleft-bfright)); colormap gray; colorbar; axis image; axis ij; title(L); drawnow
title('Bright Field (Left - Right)')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Top - Bottom
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[~,J]=ismember(idx_top,idx_bf); J(J==0) = []; bftop = 0; for L=idx_bf(J)'; bftop = bftop + Imea(:,:,L); end; figure(198); imagesc(real(bftop)); colormap gray; colorbar; axis image; axis ij; title(L); drawnow
title('Bright Field (Top)')

[~,J]=ismember(idx_bottom,idx_bf); J(J==0) = []; bfbottom = 0; for L=idx_bf(J)'; bfbottom = bfbottom + Imea(:,:,L); end; figure(199); imagesc(real(bfbottom)); colormap gray; colorbar; axis image; axis ij; title(L); drawnow
title('Bright Field (Bottom)')

figure(200); imagesc(real(bftop-bfbottom)); colormap gray; colorbar; axis image; axis ij; title(L); drawnow
title('Bright Field (Top - Bottom)')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Diagonal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[~,J]=ismember(idx_bottom,idx_bf); J(J==0) = []; bfbottom = 0; for L=idx_bf(J)'; bfbottom = bfbottom + Imea(:,:,L); end; figure(198); imagesc(real(bfbottom)); colormap gray; colorbar; axis image; axis ij; title(L); drawnow
title('Bright Field (ULeftBRight)')

[~,J]=ismember(idx_top,idx_bf); J(J==0) = []; bftop = 0; for L=idx_bf(J)'; bftop = bftop + Imea(:,:,L); end; figure(199); imagesc(real(bftop)); colormap gray; colorbar; axis image; axis ij; title(L); drawnow
title('Bright Field (URightBLeft)')

figure(200); imagesc(real(bftop-bfbottom)); colormap gray; colorbar; axis image; axis ij; title(L); drawnow
title('Bright Field (ULeftBRight - URightBLeft)')




