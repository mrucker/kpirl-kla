function p_out = krand_parameters(p_in, force); persistent parameters;

    if((nargin == 2 && force) || (nargin == 1 && isempty(parameters)))
         if isfield(parameters,'grid_world')
            p_in.grid_world      = parameters.grid_world;
            p_in.grid_world_size = parameters.grid_world_size;
         end
        parameters = fill_default_params(p_in, default_params());
    elseif(nargin == 0 && isempty(parameters))
        parameters = fill_default_params(struct(), default_params());
    end

    if ~isfield(parameters,'grid_world')
        grid_world = (fullfile(fileparts(which(mfilename)), 'data', 'allowed3.csv'));
        grid_world = readtable(grid_world);
        grid_world = grid_world(:,3:6);  %Rail type, street type, street maxspeed, building type

        parameters.grid_world      = grid_world;
        parameters.grid_world_size = sqrt(size(grid_world, 1));
    end

    p_out = parameters;

end

function d = default_params()
    d = struct(...
         'epsilon' ,.001    ...
        ,'gamma'   , 0.9    ...
        ,'steps'   ,   2    ...
        ,'samples' , 100    ...
        ,'N'       ,  30    ... %50
        ,'M'       ,  90    ...
        ,'T'       ,  01    ... %04
        ,'W'       ,  04    ...
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