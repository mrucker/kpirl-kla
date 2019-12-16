run(fullfile(fileparts(which(mfilename)), '..', '..', '..', 'shared', 'paths.m'));

kernel = k_gaussian(k_norm(), .6);

krand_parameters(struct('v_basii', '1a', 'N', 20, 'M', 40, 'T', 25, 'W', 5, 'steps',200, 'samples',100, 'gamma',.9, 'epsilon',.001, 'kernel',kernel));

reward = kpirl_mem('krand');
policy = kla_mem('krand', reward);

[s_1        ] = krand_initiator();
[  ~, ~, t_b] = krand_transitions();

trajectory_count  = 200;
trajectory_length = 2000;

states = zeros(trajectory_count*trajectory_length, 5);

for i = 1:trajectory_count
    state = s_1();
    
    states((i-1)*trajectory_length+1, :) = [state.row, state.col, state.time, i, 1];
    
    for j = 2:trajectory_length
        action = policy(state);
        state  = t_b(state,action);
        
        states((i-1)*trajectory_length+j, :) = [state.row, state.col, state.time, i, j];
    end
end

header = {'row', 'col', 'time', 'trajectory', 'step'};
writetable(cell2table([header; num2cell(states)]), 'trajectory.csv');