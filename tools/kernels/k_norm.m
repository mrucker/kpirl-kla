function k = k_norm()
    k = @(x1,x2) squareform(pdist(x1'));
end