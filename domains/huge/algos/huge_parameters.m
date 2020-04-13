function p_out = huge_parameters(p_in); persistent parameters;

    if(nargin == 1)
        parameters = set_or_default(p_in, defaults());
    end
    
    if(nargin == 0 && isempty(parameters))
        parameters = set_or_default(struct(), defaults());        
    end

    p_out = parameters;
end

function d = defaults()
    d = struct(...
         'gamma'    , 0.9          ... (pirl, kpirl, kla, lspi, klspi) discount factor for all MDP's 
        ,'r_kernel' , k_gauss()    ... (    , kpirl,    ,     ,      ) the kernel function applied to the reward features
        ,'v_kernel' , k_gauss()    ... (    ,      , kla,     , klspi) the kernel function applied to the value features
        ,'epsilon'  , 0            ... (pirl, kpirl,    ,     ,      ) when to end the algorithm
        ,'steps'    , 10           ... (pirl, kpirl,    ,     ,      ) how many steps to use when estimating feature expectation
        ,'samples'  , 100          ... (pirl, kpirl,    ,     ,      ) how many episodes to use when estimating feature expectation
        ,'N'        , 30           ... (    ,      , kla, lspi, klspi) how many policy iterations 
        ,'M'        , 90           ... (    ,      , kla, lspi, klspi) how many episodes to use when evaluating a policy
        ,'T'        , 04           ... (    ,      , kla, lspi, klspi) how many steps to use when evaluating a policy
        ,'W'        , 04           ... (    ,      , kla,     ,      ) how many windows to use when evaluating a policy
        ,'target'   , 0            ... (    ,      , kla,     ,      ) update target: (0) one-step bootstrap and (1) T-step Monte Carlo
        ,'explore'  , 1            ... (    ,      , kla,     ,      ) exploration: (0) exploit, (1) upper-bound heuristic or (2) random selection
		,'smooth'   , 1            ... (    ,      , kla,     ,      ) learning rate: (0) alpha=1/n or (1) alpha=OSA
        ,'resample' , false        ... (    ,      ,    , lspi, klspi) whether lspi-klspi should resample each policy iteration    
        ,'mu'       , 0.3          ... (    ,      ,    ,     , klspi) the decision criteria used for ald analysis
        ,'basis'    , ident_basis()... (    ,      ,    , lspi, klspi) the basis transforms applied to the features
        ,'v_feats'  , 1            ... (    ,      , kla, lspi, klspi) which value features to use [DOMAIN SPECIFIC]
    );
end