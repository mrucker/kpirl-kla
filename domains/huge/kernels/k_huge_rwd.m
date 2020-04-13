function k = k_huge_rwd(bandwidth)

    k = @kernel;

    edges = huge_discrete('reward');
    sizes = cellfun(@numel, edges)-1;

    function G = kernel(U,V)
        U = features2structure(U,sizes);
        V = features2structure(V,sizes);

        G = exp(-pdist2(U',V','squaredeuclidean')/bandwidth);
    end
end

function structure = features2structure(levels,sizes)
    structure = cell2mat({
        feature2circle(levels(1,:), sizes(1),   pi);
        feature2circle(levels(2,:), sizes(2),   pi);
        feature2circle(levels(3,:), sizes(3),   pi);
        feature2circle(levels(4,:), sizes(4),   pi);
        feature2circle(levels(5,:), sizes(5), 2*pi);
        feature2line(levels(5,:), sizes(6));
    });
end