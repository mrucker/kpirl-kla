function [a_v] = huge_actions()

    a_m = get_actions_matrix();
    a_v = @(s) get_valid_actions(s, a_m);

end

function a = get_actions_matrix()
    base = [150,100,75,50,25,10,8,5,2,0];
    dx = base;
    dy = base;

    dx = horzcat(dx,0,-dx);
    dy = horzcat(dy,0,-dy);

    a = vertcat(reshape(repmat(dx,numel(dx),1), [1,numel(dx)^2]), reshape(repmat(dy',1,numel(dy)), [1,numel(dy)^2]));
end

function a_m = get_valid_actions(state, a_m)

    if(isempty(state))
        return;
    end

    %huge_states_assert(s);
    assert(size(state,2) == 1 || (iscell(state) && numel(state)==1), 'This function wasn`t designed for multiple states');
    
    if iscell(state)
        state = state{1};
    end
    
    np = state(1:2) + a_m;

    np_too_small_x = np(1,:) < 0;
    np_too_small_y = np(2,:) < 0;
    np_too_large_x = np(1,:) > state(9);
    np_too_large_y = np(2,:) > state(10);

    valid_actions = ~(np_too_small_x|np_too_small_y|np_too_large_x|np_too_large_y);

    a_m = a_m(:, valid_actions);
end