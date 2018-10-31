function s = huge_states_from(observations)

    %assumed observation = [x, y, w, h, r, \forall targets {x, y, age}]
    assert(all(cellfun(@(o) isnumeric(o) && iscolumn(o), observations)), 'each observation must be a numeric col vector');
    assert(all(cellfun(@(o) mod(numel(o)-5, 3) == 0    , observations)), 'each observation must have 5 global features and 3x target features');

    %states = [x, y, dx, dy, ddx, ddy, dddx, dddy, width, height, radius, targets{x,y,age}]
    states    = cell(1,numel(observations)+1);
    states{1} = zeros(11,1);

    %calculates all my cursor basis, now I need to calculate touch basis
    for i = 1:numel(observations)
        o = observations{i};
        s = states{i};

        x  = [s(1:8); o(3); o(4); o(5)];
        u  = o(1:2) - s(1:2);
        ts = o(6:end);

        %states{i+1} = [adp_transition_post_decision(x,u); ts];
        states{i+1} = [huge_trans_post(x,u); ts];
    end

    s = states;
end