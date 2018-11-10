function k = k_gaussian(b,s)
    k = @(x1,x2) exp(-(b(x1,x2).^2)./s);
end