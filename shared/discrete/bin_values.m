function edges = bin_values(values)
    [~,edges] = discretize(values,numel(values));
end