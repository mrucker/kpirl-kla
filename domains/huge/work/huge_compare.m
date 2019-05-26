clear; close all; run(fullfile(fileparts(which(mfilename)), '..', '..', '..', 'qs_paths.m'));

domain = 'huge';

eval_rewds = 5;
eval_gamma = .9;
eval_steps = 10;
eval_samps = 500; %warning: reducing this will make the estimate of V more imprecise -- making performance comparisons more suspect

daps = {
    'kla  ' , 'kla'  ,struct('v_basii', '1a');
    'lspi ' , 'lspi' ,struct('v_basii', '1a');
    'klspi' , 'klspi',struct('v_basii', '1a');
};

algorithm_parameter_compare(domain, daps, @linear_reward_values, eval_rewds, eval_samps, eval_steps, eval_gamma)

function r_v = linear_reward_values(r_p)
    r_v = [1 - 2 * rand(1,size(r_p,1)-1) 0] * r_p;
end

function r_v = nonlinear_reward_values(r_p)
    r_v = [0 1 - 2 * rand(1,size(r_p,2)-1)];
end