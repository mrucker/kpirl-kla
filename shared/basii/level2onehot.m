function phi = level2onehot(n_level)

    phi = @(level) (level~=0) .* double(1:n_level == level')';

end