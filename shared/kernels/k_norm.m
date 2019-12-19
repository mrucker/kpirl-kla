function k = k_norm()
    k = @norm;
end

function n = norm(x1,x2)
    
    if(all(size(x1) == size(x2)) && all(all(x1 == x2)))
        if(size(x1,2) == 1)
            n = 0;
        else
            n = squareform(pdist(x1'));
        end
    else
            
        n = (dot(x1,x1,1)'+dot(x2,x2,1)-2*(x1'*x2)).^(1/2);
    end
end