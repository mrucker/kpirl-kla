function p_out = krand_parameters(p_in); persistent parameters;

    if(nargin == 1)
         if isfield(parameters,'grid_world')
            p_in.grid_world      = parameters.grid_world;
            p_in.grid_world_size = parameters.grid_world_size;
         end
        parameters = set_or_default(p_in, defaults());
    end
   
    if(nargin == 0 && isempty(parameters))
        parameters = set_or_default(struct(), defaults());
    end

    if ~isfield(parameters,'grid_world')
        grid_world = (fullfile(fileparts(which(mfilename)), '..', 'data', 'allowed3.csv'));
        grid_world = readtable(grid_world);
        grid_world = grid_world(:,3:6);  %Rail type, street type, street maxspeed, building type

        parameters.grid_world      = grid_world;
        parameters.grid_world_size = sqrt(size(grid_world, 1));
    end

    p_out = parameters;

end

function d = defaults()
    d = struct(...
         'epsilon' ,.001        ...
        ,'gamma'   , 0.9        ...
        ,'steps'   ,   2        ...
        ,'samples' , 100        ...
        ,'N'       ,  30        ... %5
        ,'M'       ,  90        ...
        ,'T'       ,  01        ... %0
        ,'W'       ,  04        ...
        ,'v_feats' ,  01        ...
        ,'v_kernel',  k_krand() ...
        ,'r_kernel',  k_krand() ...
    );
end