clear; close all; run([fullfile(fileparts(which(mfilename))) '\..\..\paths.m']);

domain = 'huge';

eval_rewds = 2;
eval_gamma = .9;
eval_steps = 10;
eval_inits = 30;
eval_samps = 500; %warning: reducing this will make the estimate of V more imprecise, making comparisons more suspect

algos_parms = {
    'kla  ', struct();
    'lspi ', struct();
    'klspi', struct();
};

[s_1          ] = feval([domain '_random']);
[t_d, t_s, t_b] = feval([domain '_transitions']);
[r_i, r_p, r_l] = feval([domain '_reward_basii']);

evals_rewards = arrayfun(@(i) get_random_reward_function(r_p, r_i)  , 1:eval_rewds, 'UniformOutput', false)';

for ai = 1:size(algos_parms,1)
    average_value = 0;
    average_time  = 0;
    for ri = 1:size(eval_rewds,1)
        algo = algos_parms{ai,1};
        parm = algos_parms{ai,2};
        rewd = evals_rewards{ri};

        [    parm    ] = feval([domain '_paramaters'], parm);
        [policy, time] = feval(strtrim(algo), domain, rewd);
        [ this_value ] = expectation_from_simulations(policy, t_b, s_1, rewd, eval_steps, eval_samps, eval_gamma);

        average_value = (1-1/ri) *average_value + (1/ri) * this_value;
        average_time  = (1-1/ri) *average_time  + (1/ri) * sum(time);
    end
    p_results(algo, average_time, average_value);
end

fprintf('\n');

function r_f = get_random_reward_function(r_p, r_i) 
    r_v = (2*rand(size(r_p,1),1) - 1)' * r_p;
    r_f = @(s) r_v(r_i(s));
end

function p_results(A, T, V)
    fprintf('%s\t'        , A);
    fprintf('T = %5.2f;\t', T);
    fprintf('V = %7.3f;\t', V );
    fprintf('\n');
end