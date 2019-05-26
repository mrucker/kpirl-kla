clear; close all; qs_paths;

%WARNING: The distribution of V is unknown making traditional confidence bounds around mean using SE suspect
%WARNING: reducing eval_samps will make the estimate of V less precise -- making performance comparisons more suspect

domain = 'huge';

eval_rewds = 20;
eval_gamma = .9;
eval_steps = 10;
eval_samps = 400;

daps = {
    'kla  ' , 'kla'  , struct('N', 50);
    'lspi ' , 'lspi' , struct('N', 30);
    'klspi' , 'klspi', struct('N', 30);
};

algorithm_parameter_compare(domain, daps, @linear_reward_values, eval_rewds, eval_samps, eval_steps, eval_gamma)

function r_v = linear_reward_values(r_p)
    r_v = [1 - 2 * rand(1,size(r_p,1)-1) 0] * r_p;
end

function r_v = nonlinear_reward_values(r_p)
    r_v = [0 1 - 2 * rand(1,size(r_p,2)-1)];
end