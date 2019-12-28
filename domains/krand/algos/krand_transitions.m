function [t_s, t_p] = krand_transitions()
    t_s = @to_s;
    t_p = @to_p;
    
    episodes = krand_expert_episodes();
    
    function s = to_s(s, a)

        if(nargin == 0)
            s = random_state(random_episode(episodes));
        end

        if(nargin == 1)
            s = p_to_s(s);
        end

        if(nargin == 2)
            s = p_to_s(to_p(s,a));
        end
    end

end

function p = to_p(s, a)

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

function s = p_to_s(p)
    s = p;
end

function s = random_state(trajectory)
    s = trajectory(randi(size(trajectory,2)));
end

function t = random_episode(episodes)
    t = episodes{randi(size(episodes,2))};
end