function phi = level2scalar(scalar)
    phi = @(level) (level>0).*scalar;
end