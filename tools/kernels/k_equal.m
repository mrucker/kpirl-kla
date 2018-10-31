function k = k_equal(b)    
    k = @(x1,x2) double(b(x1,x2) == 0);
end
