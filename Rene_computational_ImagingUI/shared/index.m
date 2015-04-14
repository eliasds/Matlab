function [ v ] = index( a, i, new_val )
    if exist('new_val', 'var')
        v = a ;
        v(i) = new_val ;
    else
        v = a(i) ;
    end
end

