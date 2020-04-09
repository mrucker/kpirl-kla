function onehot = feature2simplex(level, n_level)
    onehot = (level>0).*double(1:n_level == level')';
end