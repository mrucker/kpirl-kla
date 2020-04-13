function edges = bin_range(min_val, max_val, n_bins)
    %this seemed like it'd be idea but it returns weird bins  
    %[~,edges] = discretize([min_val max_val], n_bins);

    %so I'm calculating bins by hand
    bin_size = (max_val-min_val)/n_bins;
    edges = min_val + (0:n_bins)*bin_size;

    edges(1  ) = -Inf;
    edges(end) = +Inf;
end