function p_out = krand_parameters(p_in); persistent parameters;

    if(nargin == 1)
         if isfield(parameters,'grid_world')
            p_in.grid_world      = parameters.grid_world;
            p_in.grid_world_size = parameters.grid_world_size;
         end

%          if isfield(parameters,'buff_vals')
%             p_in.buff_vals      = parameters.buff_vals;
%             p_in.buff_vals_size = parameters.buff_vals_size;
%         end

        parameters = p_in;
    end

    if ~isfield(parameters,'grid_world')
        grid_world = (fullfile(fileparts(which(mfilename)), 'data', 'allowed3.csv'));
        grid_world = readtable(grid_world);
        grid_world = grid_world(:,3:6);  %Rail type, street type, street maxspeed, building type
        %grid_world = table2struct(grid_world);

        parameters.grid_world      = grid_world;
        parameters.grid_world_size = sqrt(size(grid_world, 1));
    end

%     if ~isfield(parameters,'buff_vals')
%         buff_vals = (fullfile(fileparts(which(mfilename)), 'data', 'krand_bufferedstates.csv'));
%         buff_vals = readtable(buff_vals);
%         buff_vals = buff_vals(:,2:5);  %Rail type, street type, street maxspeed, building type
%         buff_vals = table2struct(buff_vals);
% 
%         parameters.buff_vals      = buff_vals;
%         parameters.buff_vals_size = sqrt(size(buff_vals, 1));
%     end

    p_out = fill_default_params(parameters, default_params());

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