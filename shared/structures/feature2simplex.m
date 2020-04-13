function onehot = feature2simplex(value, size)
    onehot = double(1:size == value')';
end