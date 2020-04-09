function circle = feature2circle(level, n_level, arc)

    assert(nargin ~= 0, "level and n_level are required arguments")
    assert(nargin ~= 1, "n_level is a required argument")

    if(nargin==2)
        arc = 2*pi;        
    end

    radians = (level-1)/(n_level-1)*arc;
    circle  = (level>0).*[cos(radians); sin(radians)];
end