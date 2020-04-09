function k = k_gauss(bandwidth)

    if(nargin == 0)
        bandwidth = 1;
    end

    k = @(U,V) exp(-pdist2(U',V','squaredeuclidean')./bandwidth);
end