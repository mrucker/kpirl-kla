function line = feature2line(level, n_level)
    %this isn't ideal for partitioned levels one possible solution is to use a semicircle
    %if this were to work I'd need to show the derivative of distance is a constant just like with the line
    line = (level>0).*(level-1)/(n_level-1);
end