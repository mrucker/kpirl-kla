function [s2a] = krand_actions()
    s2a = @actions_valid;
end

%Early version - any action is permitted.  Come back later and restric
%(constraints
function a = actions_valid(state)

    parameters = krand_parameters();
 
    a = [1,1;1,0;1,-1;0,1;0,0;0,-1;-1,1;-1,0;-1,-1]';
   
    if state.row == 1
        a = a(:,a(1,:)~=-1);
    end
   
    if state.col == 1
        a = a(:, a(2,:)~=-1);
    end
   
    if state.row == parameters.grid_world_size
        a = a(:,a(1,:)~=1);
    end
   
    if state.col == parameters.grid_world_size
        a = a(:, a(2,:)~=1);
    end
end