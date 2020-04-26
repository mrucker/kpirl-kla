run(fullfile(fileparts(which(mfilename)), 'shared', 'paths.m'));

%WARNING: reducing n_rewds will make the estimate of E[V|DAP  ] less precise causing performance comparisons to be more suspect
%WARNING: reducing n_samps will make the estimate of E[V|DAP,R] less precise causing performance comparisons to be more suspect

domain = 'huge';

n_rewds = 3;
n_samps = 64;
n_steps = 10;
  gamma = .9;

rewards    = random_linear_reward(domain, n_rewds, @(n) [1 - 2 * rand(1,n-1) 0]);
attributes = { policy_time() policy_value(domain, n_samps, n_steps, gamma) };
statistics = { avg() SEM() med() };
outputs    = { statistics_to_screen() };

%(D)escription (A)lgorithm (P)arameters
daps = {
    %generate a policy using kla_spd and feature set 0 (aka, shared/features/single_feature) which gives a policy of random actions.
    'random' , @kla_spd, struct('N', 10, 'M', 01, 'T', 01, 'v_feats', 0, 'W', 01, 'v_kernel', 'rbf');

    %generate a policy using kla_spd and feature set 1 (this kla implementation decreases computation by increasing memory use)
    'kla_spd', @kla_spd, struct('N', 10, 'M', 90, 'T', 03, 'v_feats', 1, 'W', 03, 'v_kernel', k_huge_val());

    %generate a policy using kla_mem and feature set 1 (this kla implementation decreases memory use by increasing computation)
    'kla_mem', @kla_mem, struct('N', 10, 'M', 90, 'T', 03, 'v_feats', 1, 'W', 03, 'v_kernel', k_huge_val());

    %generate a policy using lspi and feature set 1 with a second order polynomial transform applied to the basis 
    'lspi'   , @lspi   , struct('N', 10, 'M', 90, 'T', 06, 'v_feats', 1, 'resample', true, 'basis', poly_basis(2));

    %generate a policy using klspi and feature set 1 with the provided kernel function
    %'klspi'  , @klspi  , struct('N', 10, 'M', 90, 'T', 06, 'v_feats', 1, 'resample', true, 'v_kernel', k_huge_val(1.2,'continuous'), 'mu', 0.2);
}';

a = tic;

analyze_policy(domain, daps, rewards, attributes, statistics, outputs);

toc(a);