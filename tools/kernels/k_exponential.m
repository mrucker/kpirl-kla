function k = k_exponential(b,s)
    k = @(x1,x2) exp(-b(x1,x2)./s);
end