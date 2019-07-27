clear; close all; qs_paths;

%WARNING: reducing n_rewds will make the estimate of E[V|DAP  ] less precise causing performance comparisons to be more suspect
%WARNING: reducing n_samps will make the estimate of E[V|DAP,R] less precise causing performance comparisons to be more suspect

domain = 'huge';

n_rewds = 2;
n_samps = 64;
n_steps = 10;
  gamma = .9;

rewards    = random_linear_reward(domain, n_rewds);
attributes = { policy_time() policy_value(domain, n_samps, n_steps, gamma) };
statistics = { avg() SEM() med() };
outputs    = { statistics_to_screen() };

algorithms = {
    %generate a policy using kla_spd and basis '1b' (aka, shared/single_basis) which gives a policy of random actions.
    'random'  , @kla_spd, struct('N', 10, 'M', 01 , 'T', 01, 'v_basis', '1b', 'W', 00);

    %generate a policy using kla_spd and basis '1a' (this kla implementation decreases computation by increasing memory use)
    'kla_spd' , @kla_spd, struct('N', 10, 'M', 90 , 'T', 04, 'v_basis', '1a', 'W', 03);

    %generate a policy using kla_mem and basis '1a' (this kla implementation decreases memory use by increasing computation)
    'kla_mem' , @kla_mem, struct('N', 10, 'M', 90 , 'T', 04, 'v_basis', '1a', 'W', 03);

    %generate a policy using lspi and basis '1a' with a third order polynomial transform applied to the basis 
    'lspi '   , @lspi   , struct('N', 10, 'M', 90, 'T', 07, 'v_basis', '1a', 'resample', true, 'transform', polynomial(3));

    %generate a policy using klspi and basis '1a' with the provided kernel function
    'klspi'   , @klspi  , struct('N', 10, 'M', 90, 'T', 07, 'v_basis', '1a', 'resample', true, 'kernel', k_gaussian(k_norm(),0.5), 'mu', 0.3);
}';

a = tic;

analyze_policy(domain, algorithms, 10, rewards, attributes, statistics, outputs);

toc(a);