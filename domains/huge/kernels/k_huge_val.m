function k = k_huge_val(bandwidth,type)

    assert(nargin < 3, 'incorrect number of arguments')
    assert(nargin < 2 || any(strcmp(type, {'discrete','continuous'})), 'unrecognized type');

    if(nargin == 0)
        bandwidth = 1;
    end
    
    if(nargin < 2)
        type = 'discrete';
    end
    
    sizes = [];
    
    k = @kernel;
    
    function G = kernel(U,V)
        
        if(isempty(sizes))
            sizes = get_sizes(type);
        end
        
        U = features2structure(U,sizes);
        V = features2structure(V,sizes);

        G = exp(-pdist2(U',V','squaredeuclidean')/bandwidth);
    end
end

function sizes = get_sizes(type)
    if(strcmp(type,'discrete'))
        edges = huge_discrete('value');
        sizes = cellfun(@numel, edges)-1;
    else
        sizes = [1,1,2,2,2,2,3,6];        
    end
end

function structure = features2structure(value,sizes)
    structure = cell2mat({
        feature2line(value(1,:),sizes(1));
        feature2line(value(2,:),sizes(2));
        feature2line(value(3,:),sizes(3));
        feature2line(value(4,:),sizes(4));
        feature2line(value(5,:),sizes(5));
        feature2line(value(6,:),sizes(6));
        feature2simplex(value(7,:),sizes(7));
        feature2line(value(8,:),sizes(8));
    });
end