function k = k_exponential_compact(b,s)
    n = k_norm();
    c = @(x1,x2) max((1-(n(x1,x2)/2)).^(round((size(x1,1)+1)/1.5)+1),0); %(2001 Genton) Classes of kernels for machine learning -- a statistics perspective pg. 306
    k = @(x1,x2) sparse(exp(-b(x1,x2)./s).*c(x1,x2));
end

