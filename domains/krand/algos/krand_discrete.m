function [edges, parts] = krand_discrete(func)
    
    params = krand_parameters();
      
    parts = {};
    edges = {};

    if(strcmp(func,'reward'))
        edges = {
            bin_values(1:9);
            bin_values(1:30);
            bin_range(0,150,21);
            bin_values(1:31);
            bin_range(0, 1, 96);
            bin_values(1:7);
        };
    end

    if(strcmp(func,'value'))
        if params.v_feats == 0
            edges = {
                bin_values(1); 
            };
        elseif params.v_feats == 1
            edges = {
                bin_values(1:9);
                bin_values(1:30);
                bin_range(0,150,21);
                bin_values(1:31);
                bin_range(0, 1, 96);
                bin_values(1:7);
            };
        end
    end
end