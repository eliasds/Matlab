function [ passed_time ] = clocktime( clock_name, op )
%CLOCKTIME Count a cumulative timer
    persistent data ;
    if isempty(data), data = struct() ; end
    if ~isfield(data, clock_name), data.(clock_name) = struct('start', nan, 'total', 0) ; end
    
    if nargin == 2
        switch op
            case 'start'
                data.(clock_name).start = cputime ;
            case 'stop'
                data.(clock_name).total = data.(clock_name).total + cputime - data.(clock_name).start ;
            case 'clear'
                data.(clock_name).total = 0 ;
        end
    end
    passed_time = data.(clock_name).total ;
end

