function phi = level2linear(denominator)
    phi = @(level) (level>0).*(level-1)/(denominator-1);
end