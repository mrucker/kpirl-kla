function p_out = huge_parameters(p_in, force); persistent parameters;

    if((nargin == 2 && force) || (nargin == 1 && isempty(parameters)))
        parameters = fill_default_params(p_in, default_params());
    elseif(nargin == 0 && isempty(parameters))
        parameters = fill_default_params(struct(), default_params());
    end

    p_out = parameters;
end

function d = default_params()
    d = struct(...
         'n_random' , 500    ...
        ,'epsilon'  ,   0    ... % when to exit kpirl, lspi and klspi
        ,'gamma'    , 0.9    ...
        ,'steps'    ,  10    ... 
        ,'samples'  , 100    ...
        ,'N'        ,  30    ... % policy iterations in kla, lspi and klspi
        ,'M'        ,  90    ... % episode count in kla, lspi and klspi
        ,'T'        ,  04    ... % episode length in kla, lspi and klspi
        ,'W'        ,  04    ... % 
        ,'v_basis'  , '1a'   ... % the basis for value function approximation in kla, lspi, klspi
        ,'kernel'   , k_dot()... % the kernel function used in kpirl and klspi
        ,'mu'       , 0.3    ... % the decision criteria used in klspi ald analysis
        ,'transform', ident()... % the transform applied to the basis in lspi
        ,'resample' , false  ... % whether lspi-klspi should resample each policy iteration
    );
end

function params = fill_default_params(params,defaults)

    % Get default field names.
    defaultfields = fieldnames(defaults);

    % Step over all fields in the defaults structure.
    for i=1:length(defaultfields)
        if ~isfield(params,defaultfields{i})
            params.(defaultfields{i}) = defaults.(defaultfields{i});
        end
    end
    
end