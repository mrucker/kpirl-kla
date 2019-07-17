function phi = level2circle(n_level, turn)

    x = @(level) cos( (turn+level-1)*pi/(n_level) );
    y = @(level) sin( (turn+level-1)*pi/(n_level) );

    phi = @(level) (level>0).*[x(level); y(level)];
end