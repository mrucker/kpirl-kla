function [Pf, Vf, Xs, Ys, Ks, As, f_time, b_time, m_time, a_time] = approx_policy_iteration_kspi(s_1, actions, reward, value_basii, trans_post, ~, gamma, N, M, T, ~, ~); global INIT_STATES R;

    clear huge_basis_5;

    a_start = tic;
    
    INIT_STATES = arrayfun(@(m) s_1(), 1:M, 'UniformOutput', false);
    R = reward;
    
    f_time = 0;
    m_time = 0;
    b_time = 0;
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Copyright 2000-2002 
    %
    % Michail G. Lagoudakis (mgl@cs.duke.edu)
    % Ronald Parr (parr@cs.duke.edu)
    %
    % Department of Computer Science
    % Box 90129
    % Duke University, NC 27708
    % 
    %
    % [final_policy, all_policies, samples] = chain_learn(maxiterations, ...
    %						  epsilon, samples, ...
    %						  maxepisodes, ...
    %						  maxsteps, discount, ...
    %						  basis, algorithm, policy)
    %
    % Runs LSPI for the chain domain
    %
    % Input:
    %
    % maxiterations - An integer indicating the maximum number of
    %                 LSPI iterations (default = 8)
    % 
    % epsilon - A small real number used as the termination
    %           criterion. LSPI converges if the distance between
    %           weights of consequtive iterations is less than
    %           epsilon (default = 10^-5)
    %
    % samples - The sample set. This should be an array where each
    %            entry samples(i) has the following form: 
    %
    %            samples(i).state     : Arbitrary description of state
    %            samples(i).action    : An integer in [1,|A|]
    %            samples(i).reward    : A real value
    %            samples(i).nextstate : Arbitrary description
    %            samples(i).absorb    : Absorbing nextstate? (0 or 1)
    %
    %            (default = [] - empty)
    %
    % maxepisodes - An integer indicating the maximum number of
    %               episodes from which (additional) samples will be
    %               collected.
    %               (default = 10, if samples is empty, 0 otherwise)
    % 
    % maxsteps - An integer indicating the maximum number of steps of each
    %            episode (an episode may finish earlier if an absorbing
    %            state is encountered). 
    %            (default = 50)
    %
    % discount - A real number in (0,1] to be used as the discount factor
    %            (default = 0.9)
    %
    % basis - The function that computes the basis for a given pair
    %         (state, action) given as a function handle
    %         (e.g. @chain_phi) or as a string (e.g. 'chain_phi')
    %         (default = 'chain_basis_pol')
    % 
    % algorithm - This is a number that indicates which evaluation
    %             algorithm should be used (see the paper):
    %
    %             1-lsq       : The regular LSQ (incremental)
    %             2-lsqfast   : A fast version of LSQ (uses more space)
    %             3-lsqbe     : LSQ with Bellman error minimization 
    %             4-lsqbefast : A fast version of LSQBE (more space)
    %
    %             LSQ is the evaluation algorithm for regular
    %             LSPI. Use lsqfast in general, unless you have
    %             really big sample sets. LSQBE is provided for
    %             comparison purposes and completeness.
    %             (default = 2)
    %
    % policy - (optional argument) A policy to be used for collecting the
    %          (additional) samples and as the initial policy for LSPI. It
    %          should be given as a struct with the following fields (at
    %          least):
    %
    %          explore  : Exploration rate (real number)
    %          discount : Discount factor (real number)
    %          actions  : Total numbers of actions, |A|
    %          basis    : The function handle for the basis
    %                     associated with this policy
    %          weights  : A column array of weights 
    %                     (one for each basis function)
    %
    %          If a policy is not provided, samples will be collected by a
    %          purely random policy initialized with "explore"=1.0,
    %          "discount" and "basis" some dummy values, and "actions" and
    %          "weights" as suggested by the chain domain (in the
    %          chain_initialize_policy function. Notice that the
    %          "basis" used by this policy can be different from the
    %          "basis" above that is used for the LSPI iteration. 
    %
    %
    % Output:
    %
    % final_policy - The learned policy (same struct as above)
    % 
    % all_policies - A cell array of size (iterations+1) containing
    %                all the intermediate policies at each LSPI
    %                iteration, including the initial policy. 
    %
    % samples     - The set of all samples used for this run. Each entry
    %               samples(i) has the following form:
    %
    %               samples(i).state     : Arbitrary description of state
    %               samples(i).action    : An integer in [1,|A|]
    %               samples(i).reward    : A real value
    %               samples(i).nextstate : Arbitrary description
    %               samples(i).absorb    : Absorbing nextstate? (0 or 1)
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %clear functions

        %%% Print some info
        %disp('*************************************************');
        %disp('LSPI : Least-Squares Policy Iteration');
        %disp('-------------------------------------------------');

        domain = 'huge';
        %domain = 'pendulum';
        %disp(['Domain : ' domain]);

        maxiterations = N;
        %disp(['Max LSPI iterations : ' num2str(maxiterations)]);

        epsilon = -1;
        %disp(['Epsilon : ' num2str(epsilon)]);

        samples = [];
        %disp(['Samples in the initial set : ' num2str(length(samples))]);

        maxepisodes = M;
        %disp(['Episodes for sample collection : ' num2str(maxepisodes)]);

        maxsteps = T;
        %disp(['Max steps in each episode : ' num2str(maxsteps)]);

        discount = gamma;
        %disp(['Discount factor : ' num2str(discount)]);

        if(strcmp(domain,'huge'))
        basis = value_basii;
        else
        basis = 'pendulum_kernel_rbf';
        end

        %disp('Basis : ');
        %disp(basis);

        %%% Set the evaluation algorithm
        algorithm = 5;
        %algorithms = ['lsq      '; 'lsqfast  '; 'lsqbe    '; 'lsqbefast'; 'klsq     '];
        %disp(['Selected evaluation algorithm : ' algorithms(algorithm,: )]);

        %disp('No initial policy provided');
        policy = feval([domain '_initialize_policy'], 0.0, discount, basis);  
        policy.weights = 0;

        %%% Collect (additional) samples if requested
        samples = k_collect_samples(domain, maxepisodes, maxsteps);

        %%% Ready to go - Display the total number of samples
        %disp('-------------------------------------------------');
        %disp(['Total number of samples : ' num2str(length(samples))]);

        %%% Run LSPI
        %disp('*************************************************');
        %disp('Starting LSPI ...');
        para(1)=0.5; % sigma
        para(2)=1;   % 
        para(3)=0.3; % Mu for ALD condition in spacification 

        [~, all_policies, Dic_t, para] = klspi(domain, algorithm, maxiterations, epsilon, samples, basis, discount, policy, para, M, T);              
       
        v_p = feval(basis, []);       
        PHI = cell2mat(arrayfun(@(c)exp(-vecnorm(v_p(:,c)-Dic_t').^2/para(1)^2)', 1:size(v_p,2), 'UniformOutput', false));

        Qf = cellfun(@(p) PHI'*p.weights, all_policies, 'UniformOutput', false);
        Pf = cellfun(@(v) policy_function(actions, @(s) v(feval(basis, s)), trans_post) , Qf, 'UniformOutput', false);
        
        m_time = num2cell(cellfun(@(p) p.time, all_policies));
        a_time = toc(a_start);

        %here for backwards compatibility
        Vf = []; Xs = []; Ys = []; Ks = []; As = [];
end