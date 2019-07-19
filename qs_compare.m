clear; close all; qs_paths;

%WARNING: reducing eval_rwds will  make the expected average estimate of V less precise making performance comparisons more suspect
%WARNING: reducing eval_samps will make each individual estimate of V less precise making performance comparisons more suspect

domain = 'huge';

eval_rewds = 4;
eval_gamma = .9;
eval_steps = 10;
eval_samps = 400;

daps = {
    'kla_spd' , 'kla_spd', struct('N', 10);
    'kla_mem' , 'kla_mem', struct('N', 10);
    'lspi '   , 'lspi'   , struct('N', 10);
    'klspi'   , 'klspi'  , struct('N', 10);
};

algorithm_parameter_compare(domain, daps, @random_linear_reward, eval_rewds, eval_samps, eval_steps, eval_gamma)

function r_f = random_linear_reward(r_i, r_p)

    r_w = [1 - 2 * rand(1,r_p()-1) 0];
    r_v = r_w * r_p(1:r_i());

    r_f = @(s) r_v(r_i(s));

end