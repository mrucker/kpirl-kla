function [af] = s_act_4_2()
    am = actions_matrix();
    af = @(s) actions_valid(s, am);
end

function a = actions_matrix()
    base = [150,100,75,50,25,10,8,5,2,0];
    dx = base;
    dy = base;

    dx = horzcat(dx,0,-dx);
    dy = horzcat(dy,0,-dy);

    a = vertcat(reshape(repmat(dx,numel(dx),1), [1,numel(dx)^2]), reshape(repmat(dy',1,numel(dy)), [1,numel(dy)^2]));
end

function a = actions_valid(s, a)

    if(isempty(s))
        return;
    end

    %huge_states_assert(s);
    assert(size(s,2) == 1 || (iscell(s) && numel(s)==1), 'This function wasn`t designed for multiple states');
    
    if iscell(s)
        s = s{1};
    end
    
    np = s(1:2) + a;

    np_too_small_x = np(1,:) < 0;
    np_too_small_y = np(2,:) < 0;
    np_too_large_x = np(1,:) > s(9);
    np_too_large_y = np(2,:) > s(10);

    valid_actions = ~(np_too_small_x|np_too_small_y|np_too_large_x|np_too_large_y);

    a = a(:, valid_actions);
end