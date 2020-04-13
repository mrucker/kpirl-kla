function k = k_krand(bandwidth)

    if(nargin==0)
        bandwidth=1;
    end

    sizes = [];
    
    k = @kernel;
    
    function G = kernel(U,V)

        if(isempty(sizes))
            edges = krand_discrete('value');
            sizes = cellfun(@numel, edges)-1;        
        end

        U = features2structure(U,sizes);
        V = features2structure(V,sizes);

        G = exp(-pdist2(U',V','squaredeuclidean')/bandwidth);
    end
end

function structure = features2structure(levels,sizes)
    structure = cell2mat({
        feature2simplex(levels(1,:),sizes(1));
        feature2simplex(levels(2,:),sizes(2));
        feature2line(levels(3,:),sizes(3));
        feature2simplex(levels(4,:),sizes(4));
        feature2line(levels(5,:),sizes(5));
        feature2line(levels(6,:),sizes(6));
    });
end