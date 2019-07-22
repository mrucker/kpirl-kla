clear; close all; run(fullfile(fileparts(which(mfilename)), '..', '..', '..', 'qs_paths.m'));

%WARNING: reducing eval_rewds will make the estimate of E[V | DAP   ] less precise making performance comparisons more suspect
%WARNING: reducing eval_samps will make the estimate of E[V | DAP, R] less precise making performance comparisons more suspect

domain = 'huge';

rng(4)

eval_rewds = 1;
eval_gamma = .9;
eval_steps = 10;
eval_samps = 500;

daps = {
    %'kla_spd  1a' , 'kla_spd'  ,struct('v_basis', '1a');
    %'kla_spd  1b' , 'kla_spd'  ,struct('v_basis', '1b');
    'kla_mem  1a' , 'kla_mem'  ,struct('v_basis', '1a');
    %'kla_mem  1b' , 'kla_mem'  ,struct('v_basis', '1b');
};

algorithm_parameter_compare(domain, daps, @random_linear_reward, eval_rewds, eval_samps, eval_steps, eval_gamma)

function r_f = random_linear_reward(r_i, r_p)

    r_w = [1 - 2 * rand(1,r_p()-1) 0];
    r_v = r_w * r_p(1:r_i());

    r_f = @(s) r_v(r_i(s));
end