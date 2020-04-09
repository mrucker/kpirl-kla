function k = k_huge_val(bandwidth)

    if(nargin == 0)
        bandwidth = 1;
    end

    k = @kernel;
    
    function G = kernel(U,V)
        U = features2structure(U);
        V = features2structure(V);

        G = exp(-pdist2(U',V','squaredeuclidean')/bandwidth);
    end
end

function structure = features2structure(levels)
    structure = cell2mat({
        feature2line(levels(1,:),3);
        feature2line(levels(2,:),3);
        feature2line(levels(3,:),3);
        feature2line(levels(4,:),3);
        feature2line(levels(5,:),3);
        feature2line(levels(6,:),3);
        feature2simplex(levels(7,:),3);
        feature2line(levels(8,:),6);
    });
end