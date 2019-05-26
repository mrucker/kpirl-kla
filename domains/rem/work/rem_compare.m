clear; close all; run(fullfile(fileparts(which(mfilename)), '..', '..', '..', 'qs_paths.m'));

%WARNING: The distribution of V is unknown making traditional confidence bounds around mean using SE more suspect
%WARNING: reducing eval_samps will make the estimate of V less precise -- making performance comparisons more suspect

domain = 'rem';

eval_rewds = 3;
eval_gamma = 1;
eval_steps = 10;
eval_samps = 400;

daps = {
    'kla T=1 W=4;' , 'kla' , struct('v_basii', '1a', 'N', 20, 'M', 090, 'T', 1 , 'W', 4, 'gamma', 1);
    'kla T=1 W=3;' , 'kla' , struct('v_basii', '1a', 'N', 20, 'M', 090, 'T', 1 , 'W', 3, 'gamma', 1);
    'kla T=3 W=2;' , 'kla' , struct('v_basii', '1a', 'N', 20, 'M', 090, 'T', 3 , 'W', 2, 'gamma', 1);    
};

algorithm_parameter_compare(domain, daps, @linear_reward_values, eval_rewds, eval_samps, eval_steps, eval_gamma)

function r_v = linear_reward_values(r_p)
    r_v = (2*rand(1, size(r_p,1)) - 1) * r_p;
end

function r_v = nonlinear_reward_values(r_p)
    r_v = 1 - rand(1,size(r_p,2))*2;
end