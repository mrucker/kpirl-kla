function p_out = huge_parameters(p_in); persistent parameters;

    if(nargin == 1)
        parameters = p_in;
    end

    p_out = fill_default_params(parameters, default_params());

end

function d = default_params()
    d = struct(...
         'rand_ns', 10     ...
        ,'epsilon', .001   ... //when to exit kpirl
        ,'gamma'  , 0.9    ...
        ,'steps'  ,  10    ... 
        ,'samples', 100    ...
        ,'N'      ,  30    ... //policy iterations in KLA
        ,'M'      ,  90    ... //trajectory samples on each policy iteration in KLA
        ,'T'      ,  04    ... //trajectory length for each sample in KLA
        ,'W'      ,  04    ... //
        ,'v_basis', '1a'   ... //
        ,'kernel' , k_dot()... //the kernel function used in kpirl
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