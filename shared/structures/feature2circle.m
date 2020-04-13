function circle = feature2circle(value, size, arc)

    assert(nargin ~= 0, "level and n_level are required arguments")
    assert(nargin ~= 1, "n_level is a required argument")

    if(nargin==2)
        arc = 2*pi;        
    end

    radians = value/size*arc;
    circle  = [cos(radians); sin(radians)];
end