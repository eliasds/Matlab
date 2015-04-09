function [ S ] = Dsource_LR( rot_an, NA_illum, lambda, u, v)
%DSOURCE_LR calculates the effective source S given
%   Inputs:
%   rot_an: rotation angle of the asymmetric axis
%   NA_illum: illumination NA
%   lambda: wavelength
%   u,v: spaital frequency axes

% support of the source
S0 = sqrt(u.^2+v.^2)*lambda<=NA_illum;

LR = zeros(size(u));
% asymmetric mask based on illumination angle
LR(v>(u*tand(rot_an)))=1;
LR(v<(u*tand(rot_an)))=-1;
if rot_an == 270
    LR = -LR;
end

S = S0.*LR;

end

