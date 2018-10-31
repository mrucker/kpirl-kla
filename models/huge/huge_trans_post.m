function s2 = huge_trans_post(s1, a, should_update_targets)

    if(nargin < 3)
        should_update_targets = true;
    end

    if iscell(s1)
        s1 = cell2mat(s1);
    end
    
    %removed for speed
    %huge_states_assert(s1);

    cursor_state = s1(1:8   ,1);
    window_state = s1(9:11  ,1);
    target_state = s1(12:end,1);

    cursor_state = update_cursor_state(cursor_state,a);

    if(should_update_targets)
        target_state = update_target_states(target_state);
    end

    s2 = vertcat(cursor_state, repmat([window_state; target_state], [1 size(cursor_state,2)]));
end

function x2 = update_cursor_state(x1,u)

    %this location to the boundary if we move beyond
    %because we are removing these from actions now
    %this check/correction should no longer be necessary.
    %u(1,(u(1,:) + x1(1)) > x1(9)) = - x1(1) + x1(9);
    %u(1,(u(1,:) + x1(1)) < 0    ) = - x1(1);
    %u(2,(u(2,:) + x1(2)) > x1(10)) = - x1(2) + x1(10);
    %u(2,(u(2,:) + x1(2)) < 0     ) = - x1(2);
    
    B = [
        1 0;
        0 1;
        1 0;
        0 1;
        1 0;
        0 1;
        1 0;
        0 1;
    ];

    A = -[
        0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0;
        1 0 0 0 0 0 0 0;
        0 1 0 0 0 0 0 0;
        1 0 1 0 0 0 0 0;
        0 1 0 1 0 0 0 0;
        1 0 1 0 1 0 0 0;
        0 1 0 1 0 1 0 0;        
    ];

    x2 = A * x1(1:8) + B * (x1(1:2)+u);    
end

function x2 = update_target_states(x1)    

    if(isempty(x1))
        x2 = x1;
        return;
    end

    target_xs = x1(1:3:end,1);
    target_ys = x1(2:3:end,1);
    target_as = x1(3:3:end,1);
    
    %assumes that 33 ms will pass in transition (aka, 30 observations per second)    
    target_as = target_as + 33;
    yet_alive = target_as < 1000;

    target_xs = target_xs(yet_alive);
    target_ys = target_ys(yet_alive);
    target_as = target_as(yet_alive);

    x2 = reshape([target_xs,target_ys,target_as]',[],1);
end