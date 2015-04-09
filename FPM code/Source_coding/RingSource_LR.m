function [ S ] = RingSource_LR( rot_an, NA_outer, NA_inner, lambda, u, v)
%DSOURCE_LR calculates the effective source S given
%   Inputs:
%   rot_an: rotation angle of the asymmetric axis
%   NA_illum: illumination NA
%   lambda: wavelength
%   u,v: spaital frequency axes

% support of the source
illum_na = sqrt(u.^2+v.^2)*lambda;
S0 = illum_na<=NA_outer&illum_na>=NA_inner;

LR = zeros(size(u));
% asymmetric mask based on illumination angle
LR(v>(u*tand(rot_an)))=1;
LR(v<(u*tand(rot_an)))=-1;
if rot_an == 180
    LR = -LR;
end

S = S0.*LR;

end

