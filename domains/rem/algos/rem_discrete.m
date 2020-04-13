function [edges, parts] = rem_discrete(func)
    
    params = rem_parameters();

    parts = {};
    edges = {};

    if(strcmp(func,'reward'))
        edges = {
            bin_values(0:1);
            bin_range(0,1,30);
            bin_values(0:1);
            bin_range(0,1,30);
        };
    elseif(strcmp(func,'value') && params.v_feats == 0)
        edges = {
            bin_values(1); 
        };
    elseif(strcmp(func,'value') && params.v_feats == 1)
        edges = {
            bin_values(0:1);
            bin_range(0,1,30);
            bin_values(0:1);
            bin_range(0,1,30);
        };
    elseif(strcmp(func,'value') && params.v_feats == 2)
        edges = {
            bin_values(0:1);
            bin_values(0:1);
        }; 
    end
end