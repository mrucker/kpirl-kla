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
         'epsilon'  ,   0    ...       % when to exit kpirl, lspi and klspi
        ,'gamma'    , 0.9    ...
        ,'steps'    ,  10    ...
        ,'samples'  , 100    ...
        ,'N'        ,  30    ...       % policy iterations in kla, lspi and klspi
        ,'M'        ,  90    ...       % episode count in kla, lspi and klspi
        ,'T'        ,  04    ...       % episode length in kla, lspi and klspi
        ,'W'        ,  04    ...       % 
        ,'v_basis'  , '1a'   ...       % the basis for value function approximation in kla, lspi, klspi
        ,'kernel'   , k_dot()...       % the kernel function used in kpirl and klspi
        ,'mu'       , 0.3    ...       % the decision criteria used in klspi ald analysis
        ,'basis'    , ident_basis()... % the transform applied to the basis in lspi
        ,'resample' , false  ...       % whether lspi-klspi should resample each policy iteration
        ,'target'   , 0      ...       % whether KLA estimates q via (0) one-step bootstrap or (1) T-step Monte Carlo
        ,'explore'  , 1      ...       % whether KLA explores a_0 via (0) exploit, (1) upper-bound heuristic or (2) random selection
		,'smooth'   , 1      ...       % whether KLA smooths q via(0) alpha=1/n or (1) alpha=OSA
    );
end