function s_1 = huge_random()
    s_1 = v2();
end

function s_1 = v2()

    path = fullfile(fileparts(which(mfilename)), '..', '..', 'data');
    file = 'huge_observed_trajectories.json';

    initial_states = read_initial_states_from_file(path, file);

    s_1 = @() initial_states{randi(numel(initial_states))};
end

function states = read_initial_states_from_file(path, file)

    observations = jsondecode(fileread([path filesep file]));
    states       = huge_states_from(observations);

end

function s = huge_states_from(observations)

    td = huge_transitions();

    %assumed observation = [x, y, w, h, r, \forall targets {x, y, age}]
    assert(all(cellfun(@(o) isnumeric(o) && iscolumn(o), observations)), 'each observation must be a numeric col vector');
    assert(all(cellfun(@(o) mod(numel(o)-5, 3) == 0    , observations)), 'each observation must have 5 global features and 3x target features');

    %states = [x, y, dx, dy, ddx, ddy, dddx, dddy, width, height, radius, targets{x,y,age}]
    states = cell(1,numel(observations)+1);
    
    %add a zero state for derivative calculations
    states{1} = zeros(11,1);

    for i = 1:numel(observations)
        o = observations{i};
        s = states{i};

        x  = [s(1:8); o(3); o(4); o(5)];
        u  = o(1:2) - s(1:2);
        ts = o(6:end);

        states{i+1} = [td(x,u); ts];
    end

    %remove the zero state because it is invalid
    s = states(2:end);
end