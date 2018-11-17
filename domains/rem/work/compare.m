clear; close all; run([fullfile(fileparts(which(mfilename))) '/../../../paths.m']);

domain = 'rem';

eval_rewds = 30;
eval_gamma = .9;
eval_steps = 10;
eval_samps = 500; %warning: reducing this will make the estimate of V more imprecise -- making performance comparisons more suspect

daps = {
    'kla_1a', 'kla', struct('v_basii', '1a', 'N', 10);
    'kla_1a', 'kla', struct('v_basii', '1b', 'N', 10);
    'kla_1a', 'kla', struct('v_basii', '1c', 'N', 10);
};

[s_1          ] = feval([domain '_random']);
[t_d, t_s, t_b] = feval([domain '_transitions']);
[r_i, r_p, r_l] = feval([domain '_reward_basii']);

rwds = arrayfun(@(i) get_random_reward_function(r_p, r_i)  , 1:eval_rewds, 'UniformOutput', false)';

for ai = 1:size(daps,1)
    average_value = 0;
    average_time  = 0;
    for ri = 1:size(rwds,1)
        desc = daps{ai,1};
        algo = daps{ai,2};
        parm = daps{ai,3};
        rewd = rwds{ri,1};

        [    parm    ] = feval([domain '_paramaters'], parm);
        [policy, time] = feval(strtrim(algo), domain, rewd);
        [ this_value ] = expectation_from_simulations(policy, t_b, s_1, rewd, eval_steps, eval_samps, eval_gamma);

        average_value = (1-1/ri) *average_value + (1/ri) * this_value;
        average_time  = (1-1/ri) *average_time  + (1/ri) * sum(time);
    end
    p_results(desc, average_time, average_value);
end

fprintf('\n');

function r_f = get_random_reward_function(r_p, r_i) 
    %r_v = (2*rand(size(r_p,1),1) - 1)' * r_p;
    r_v = 1 - rand(1,size(r_p,2))*2;
    r_f = @(s) r_v(r_i(s));
end

function p_results(A, T, V)
    fprintf('%s'          , A);
    fprintf('\tT = %5.2f;', T);
    fprintf('\tV = %7.3f;', V);
    fprintf('\n');
end