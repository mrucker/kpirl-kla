run(fullfile(fileparts(which(mfilename)), '..', '..', '..', 'shared', 'paths.m'));

%WARNING: reducing n_rewds will make the estimate of E[V|DAP  ] less precise causing performance comparisons to be more suspect
%WARNING: reducing n_samps will make the estimate of E[V|DAP,R] less precise causing performance comparisons to be more suspect

domain = 'huge';

for i = 1:56

    n_rewds = 36;
    n_samps = 64;
    n_steps = 10;
      gamma = .9;

    rewards    = random_linear_reward(domain, n_rewds, @(n) [1 - 2 * rand(1,n-1) 0]);
    attributes = { policy_iteration_index() policy_value(domain, n_samps, n_steps, gamma) policy_time() };
    statistics = { };
    outputs    = { attributes_to_file("kla.csv") };

    daps = {    
        'kla, Monte Carlo, explore, W=1', @kla_spd, struct('N', 30, 'M', 90 , 'T', 3, 'v_feats', 1, 'W', 1, 'explore', 1, 'target', 0);
        'kla, Monte Carlo, explore, W=2', @kla_spd, struct('N', 30, 'M', 90 , 'T', 3, 'v_feats', 1, 'W', 2, 'explore', 1, 'target', 0);
        'kla, Monte Carlo, explore, W=3', @kla_spd, struct('N', 30, 'M', 90 , 'T', 3, 'v_feats', 1, 'W', 3, 'explore', 1, 'target', 0);        
        'kla, Monte Carlo, exploit, W=3', @kla_spd, struct('N', 30, 'M', 90 , 'T', 3, 'v_feats', 1, 'W', 3, 'explore', 0, 'target', 0);
        'kla, bootstrap, explore, W=3'  , @kla_spd, struct('N', 30, 'M', 90 , 'T', 3, 'v_feats', 1, 'W', 3, 'explore', 1, 'target', 1);
        'lspi, polynomial=2'            , @lspi   , struct('N', 30, 'M', 90 , 'T', 6, 'v_feats', 1, 'resample', true, 'basis', poly_basis(2));
        'klspi, bandwidth=1.2, mu=0.2'  , @klspi  , struct('N', 30, 'M', 90 , 'T', 6, 'v_feats', 1, 'resample', true, 'kernel', k_gaussian(k_norm(),1.2), 'mu', 0.2);
    }';

    fprintf('\nIteration %i\n',i);

    a = tic;

    analyze_policies(domain, daps, rewards, attributes, statistics, outputs);

    toc(a);
end