function [edges, parts] = huge_discrete(func)

    params = huge_parameters();

    parts = {};
    edges = {};

    if(strcmp(func,'reward'))
        parts = {1:5,6};
        edges = {
            bin_range(0, 1   ,3);
            bin_range(0, 1   ,3);
            bin_range(0, 48  ,8);
            bin_range(0, 60  ,6);
            bin_range(0, 2*pi,8);
            bin_range(0, 1   ,1);
        };
    end

    if(strcmp(func,'value'))
        if params.v_feats == 0
            parts = {};
            edges = {
                bin_values(1); 
            };
        elseif params.v_feats == 1
            parts = {};
            edges = {
                bin_range( 0,1,3);
                bin_range( 0,1,3);
                bin_range(-1,1,3);
                bin_range(-1,1,3);
                bin_range(-1,1,3);
                bin_range(-1,1,3);
                bin_values(1:3);
                bin_values(0:5);
            };
        end
    end
end