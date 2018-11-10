function p_out = butts_paramaters(p_in); persistent paramaters;

    if(nargin == 1)
        paramaters = p_in;
    end

    p_out = fill_default_params(paramaters, default_params());

end

function d = default_params()
    d = struct(...
         'epsilon' ,.001 ...
        ,'gamma'   , 0.9 ...
        ,'steps'   ,  10 ...
        ,'samples' , 100 ...
        ,'pop_size',  50 ...
        ,'max_rand',  40 ...
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