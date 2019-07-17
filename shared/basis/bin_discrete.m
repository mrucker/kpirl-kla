function bin_func = bin_discrete(min_val, bins)
    bin_func = @(val) min (max(val - min_val + 1, 1, 'includenan'), bins, 'includenan');    
end