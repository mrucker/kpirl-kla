function m = k_pwise(x1, x2, k)
    m = zeros(size(x1,2),size(x2,2));
    
    x1 = x1';
    
    for c = 1:size(x2,2)
        for r = 1:size(x1,1)
            m(r,c) = k(x1(r,:)', x2(:,c));
        end
    end
end