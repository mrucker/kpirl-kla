function k = k_krand(bandwidth)

    if(nargin==0)
        bandwidth=1;
    end

    k = @kernel;
    
    function G = kernel(U,V)
        U = features2structure(U);
        V = features2structure(V);

        G = exp(-pdist2(U',V','squaredeuclidean')/bandwidth);
    end
end

function structure = features2structure(levels)
    n_levels = [9, 30, 21, 31, 96, 7];
    
    structure = cell2mat({
        feature2simplex(levels(1,:),n_levels(1));
        feature2simplex(levels(2,:),n_levels(2));
        feature2line(levels(3,:),n_levels(3));
        feature2simplex(levels(4,:),n_levels(4));
        feature2line(levels(5,:),n_levels(5));
        feature2line(levels(6,:),n_levels(6));
    });
end