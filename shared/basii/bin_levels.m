function bl = bin_levels(val, min_val, max_val, bins)

    %?????????????????????????
    %bl = ceil(vals/bin_size);
    %bl = max (bl, min_level);
    %bl = min (bl, max_level);

    %fastest
    val = max([val;min_val*ones(1,size(val,2))],[], 1);
    val = min([val;max_val*ones(1,size(val,2))],[], 1);
    bl  = floor((val-min_val)*bins/(max_val-min_val+1));
    bl  = bl + 1; % 1-based rather than 0-based

    %%second fastest
    %bl = min(ceil((vals+.01)/bin_s), bin_n);
    %%second fastest

    %%third fastest
    %[~, bl] = max(vals <= [1:bin_n-1, inf]' * bin_s);
    %%third fastest

    %%fourth fastest (close 3rd)
    %r_bins = [   1:bin_n-1, inf]' * bin_s;
    %l_bins = [0, 1:bin_n-1     ]' * bin_s;

    %bin_ident = l_bins <= vals & vals < r_bins;
    %bl = (1:bin_n) * bin_ident;
    %%fourth fastest (close 3rd)

    %%fifth fastest
    %bins = (1:bin_n-1) * bin_s;
    %bl = discretize(vals,[0,bins,inf]);
    %%fifth fastest
end