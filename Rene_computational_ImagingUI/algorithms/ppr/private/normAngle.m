function [ phase] = normAngle( field )
%NORMANGLE Summary of this function goes here
%   Detailed explanation goes here

phase = angle(field) ;
phase = phase - min(phase(:)) ;

end

