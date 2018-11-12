function [a_v, a_m] = butts_actions()

    paramaters = butts_paramaters();

    a_m = actions_matrix(paramaters.pop_size);
    a_v = @(s) a_m;
end

function a = actions_matrix(pop_size)
    
    source    = 1:pop_size;
    recipient = 1:pop_size;

    a = vertcat(reshape(repmat(source,numel(source),1), [1,numel(source)^2]), reshape(repmat(recipient',1,numel(recipient)), [1,numel(recipient)^2]));
end