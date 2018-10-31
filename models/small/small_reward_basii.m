function basii = small_reward_basii(states, actions, radius, deriv)

    A = [
        1  0  0  0  0  0;
        0  1  0  0  0  0;
        1  0 -1  0  0  0;
        0  1  0 -1  0  0;
        1  0 -2  0  1  0;
        0  1  0 -2  0  1;
    ];

    df = A(1:deriv*2,1:deriv*2) * states(1:deriv*2,:);

    state_points = df(1:2,:);
    world_points = actions;

    p1 = state_points;
    p2 = world_points;

    state_point_distance_matrix = sqrt(dot(p1,p1,1) + dot(p2,p2,1)' - 2*(p2' * p1));

    tf = sum(and(state_point_distance_matrix <= radius, logical(states((deriv*2+3+1):end,:))));

    dummy = [];
    
    for i = 1:deriv*2
        unique_cnt = numel(unique(df(i,:)));
        dummy      = [dummy; repmat(df(i,:), [unique_cnt, 1]) == unique(df(i,:))'];
    end
    
    basii = [dummy; tf;];
end