function [t_s, t_p] = huge_transitions()
    
    t_s = @to_s;
    t_p = @to_p;
    
    path = fullfile(fileparts(which(mfilename)), '..', 'data');
    file = 'huge_observed_episodes.json';

    initial_states = read_states_from_file(path, file);
   
    function s = to_s(s,a)
        
        if(nargin == 0)
            s = initial_states{randi(numel(initial_states))};
        end
        
        if(nargin == 1)
            s = p_to_s(s);
        end
        
        if(nargin == 2)
            s = p_to_s(to_p(s,a));
        end
    end
end

function s = to_p(s,a)
    if iscell(s)
        s = cell2mat(s);
    end

    %removed for performance
    %huge_states_assert(s1);

    cursor_state = s(1:8   ,1);
    window_state = s(9:11  ,1);
    target_state = s(12:end,1);

    cursor_state = update_cursor_state(cursor_state,a);
    target_state = update_old_targets_state(target_state);    

    s = vertcat(cursor_state, repmat([window_state; target_state], [1 size(cursor_state,2)]));
end

function s = p_to_s(p)
    if iscell(p)
        s = cellfun(@(p) { update_new_targets_state(p) }, p);
    else
        s = update_new_targets_state(p);
    end
end

function s = update_cursor_state(s,u)

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

    s = A * s(1:8) + B * (s(1:2)+u);    
end

function s = update_old_targets_state(s)

    if(isempty(s))
        return;
    end

    target_xs = s(1:3:end,1);
    target_ys = s(2:3:end,1);
    target_as = s(3:3:end,1);
    
    %assumes that 33 ms will pass in transition (aka, 30 observations per second)    
    target_as = target_as + 33;
    yet_alive = target_as < 1000;

    target_xs = target_xs(yet_alive);
    target_ys = target_ys(yet_alive);
    target_as = target_as(yet_alive);

    s = reshape([target_xs,target_ys,target_as]',[],1);
end

function s = update_new_targets_state(s)

    width  = s(9);
    height = s(10);
    radius = s(11);

    %the actual web app uses an exponential interarrival time to have continous arrivals
    %for easier calculation in matlab I'm using repeated bernoulli trials since n is large and p is small
    %p = @(k,t) exp(-t/200) * ((t/200)^k)/factorial(k); p(2,33) -- https://planetcalc.com/7044/

    n = 33;     %could appear at any ms tick
    p = (1/200);%this is the poisson lambda???? Yes, I think so. That is, 1/200'th of a target arrives each milisecond
    
    n_targets_to_create = binornd(n,p);

    if n_targets_to_create == 0
        return;
    end
    
    new_targets_rands = rand(2,n_targets_to_create);
    new_targets_scale = diag([(width  - radius*2), (height - radius*2)]);
    
    new_targets_point = new_targets_scale * new_targets_rands;
    new_targets_age   = 10 * ones(1, n_targets_to_create); %we make age 10 because 10+(33*30) = 1000
            
    if(size(s,2) >  1)
        s = vertcat(s, repmat(reshape([new_targets_point;new_targets_age],[],1), 1, size(s,2)));
    else 
        s = vertcat(s, reshape([new_targets_point;new_targets_age],[],1));
    end
end

function states = read_states_from_file(path, file)

    observations = jsondecode(fileread([path filesep file]));

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

        x = [s(1:8); o(3); o(4); o(5)];
        u = o(1:2) - s(1:2);
        t = o(6:end);

        states{i+1} = [to_p(x,u); t];
    end

    %remove the zero state because it is invalid
    states = states(2:end);
end