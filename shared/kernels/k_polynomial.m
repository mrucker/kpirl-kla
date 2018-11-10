function k = k_polynomial(b,p,c)

    assert( p > 0, 'p must be greater than 0');

    if p == 1
        k = @(x1,x2) b(x1,x2);
    else        
        k = @(x1,x2) 2^(-p)*(b(x1,x2)./max(max(b(x1,x2))) + c).^p;
    end
end