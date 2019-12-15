function bin_func = bin_continuous(min_val, max_val, bins)
    bin_size = (max_val-min_val)/bins;
    bin_func = @(val) min(max(ceil((val-min_val)/bin_size), 1, 'includenan'), bins, 'includenan');
end