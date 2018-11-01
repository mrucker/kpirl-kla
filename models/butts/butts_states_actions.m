function [af] = butts_states_actions()
    base = 1:population_size;
    
    source    = base;
    recipient = base;
    
    am = vertcat(reshape(repmat(source,numel(source),1), [1,numel(source)^2]), reshape(repmat(recipient',1,numel(recipient)), [1,numel(recipient)^2]));    
    
    af = @(s) am;
end