function k = k_huge_rwd(bandwidth)

    k = @kernel;
    
    function G = kernel(U,V)
        U = features2structure(U);
        V = features2structure(V);

        G = exp(-pdist2(U',V','squaredeuclidean')/bandwidth);
    end
end

function structure = features2structure(levels)
    structure = cell2mat({
        feature2circle(levels(1,:), 3,   pi);
        feature2circle(levels(2,:), 3,   pi);
        feature2circle(levels(3,:), 3,   pi);
        feature2circle(levels(4,:), 3,   pi);
        feature2circle(levels(5,:), 6, 2*pi);
        feature2point(levels(5,:));
    });
end