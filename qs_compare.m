clear; close all; qs_paths;

%WARNING: reducing eval_rewds will make the estimate of E[V|DAP  ] less precise causing performance comparisons to be more suspect
%WARNING: reducing eval_samps will make the estimate of E[V|DAP,R] less precise causing performance comparisons to be more suspect

domain = 'huge';

%evaluation parameters for the below `daps`
eval_rewds = 10;
eval_gamma = .9;
eval_steps = 10;
eval_samps = 200;

%'D'escription, 'A'lgorithm, 'P'arameters (DAP)
daps = {
    %generate a policy using kla_spd and basis '1b' (aka, shared/single_basis) which gives a policy of random actions.
    'random' , 'kla_spd' , struct('N', 01, 'M', 01 , 'T', 01, 'v_basis', '1b', 'W', 01                                                       );

    %generate a policy using kla_spd and basis '1a' (this kla implementation decreases computation by increasing memory use)
    'kla_spd' , 'kla_spd', struct('N', 10, 'M', 90 , 'T', 04, 'v_basis', '1a', 'W', 04                                                       );

    %generate a policy using kla_mem and basis '1a' (this kla implementation decreases memory use by increasing computation)
    'kla_mem' , 'kla_mem', struct('N', 10, 'M', 90 , 'T', 04, 'v_basis', '1a', 'W', 04                                                       );

    %generate a policy using lspi and basis '1a' with a third order polynomial transform applied to the basis 
    'lspi '   , 'lspi'   , struct('N', 10, 'M', 100, 'T', 32, 'v_basis', '1a', 'resample', true, 'transform', polynomial(3)                   );

    %generate a policy using klspi and basis '1a' with the provided kernel function
    'klspi'   , 'klspi'  , struct('N', 10, 'M', 100, 'T', 15, 'v_basis', '1a', 'resample', true, 'kernel', k_gaussian(k_norm(),0.5), 'mu', 0.3);
};

algorithm_parameter_compare(domain, daps, @random_linear_reward, eval_rewds, eval_samps, eval_steps, eval_gamma)

function r_f = random_linear_reward(r_i, r_p)

    r_w = [1 - 2 * rand(1,r_p()-1) 0];
    r_v = r_w * r_p(1:r_i());

    r_f = @(s) r_v(r_i(s));

end