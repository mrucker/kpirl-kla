function [t_d, t_s, t_b] = krand_transitions()

    %if you read in your gridworld from your file here then you only need to read it one time
    %this will make look up super fast when the MDP takes an action, since it doesn't have
    %to read from file again. There two ways you can read in from file, one you make every element
    %in your 2d-matrix a struct. Then you can just reference the values like we did for your episodes.
    %Unfortunately, I'm not really familiar with how to make a 2d-matrix of structs so you'd have to look
    %that up. The second option is to load a 2d matrix of numbers for every single column. Then you'd look
    %up each column values in each of the matrices. You will want to convert all the string values to numbers.
    %If you keep the string values as strings it'll take up too much memory. That's because two characters use as much memory as
    %a single number. So, for example, "primary" takes up as much memory as the vector [1,2,3] since primary has approx 6 characters.
        
    t_d = @krand_trans_post;
    t_s = @krand_trans_pre;
    t_b = @(s,a) t_s(t_d(s,a));
    
end

function new_s = krand_trans_post(s, a)

    parameters = krand_parameters();
    
    gw_sz = parameters.grid_world_size;
    grid_world = parameters.grid_world;

    old_x = s.row; %get the x coordinate from the previous state
    old_y = s.col; %get the y coordinate from the previous state
    
    old_location = [old_x;old_y];
      
    new_location = old_location + a;
    
    %this is what it'd more or less look like if your grid_world was a single matrix of structs
    
    i = sub2ind([gw_sz gw_sz], new_location(1,:), new_location(2,:));
    
    new_s = table2struct(grid_world(i,:));
    
    for i = 1:size(new_s,1)
        new_s(i).time = s.time+5;
    end
    
    R = num2cell(new_location(1,:));
    C = num2cell(new_location(2,:));
    
    [new_s(:).row] = R{:};
    [new_s(:).col] = C{:};

    new_s = new_s';
    
end

function s = krand_trans_pre(s)
    %empty because your model is deterministic
end