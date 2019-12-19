function [t_s, t_p] = krand_transitions()
    t_s = @krand_s;
    t_p = @krand_p;
end

function p = krand_p(s, a)

    parameters = krand_parameters();
    
    gw_sz = parameters.grid_world_size;
    grid_world = parameters.grid_world;

    old_x = s.row; %get the x coordinate from the previous state
    old_y = s.col; %get the y coordinate from the previous state
    
    old_location = [old_x;old_y];
      
    new_location = old_location + a;
    
    %this is what it'd more or less look like if your grid_world was a single matrix of structs
    
    i = sub2ind([gw_sz gw_sz], new_location(1,:), new_location(2,:));
    
    p = table2struct(grid_world(i,:));
    
    for i = 1:size(p,1)
        p(i).time = s.time+5;
    end
    
    R = num2cell(new_location(1,:));
    C = num2cell(new_location(2,:));
    
    [p(:).row] = R{:};
    [p(:).col] = C{:};

    p = p';
    
end

function s = krand_s(s, a)
    if(nargin == 2)
        s = krand_p(s,a);
    end
end