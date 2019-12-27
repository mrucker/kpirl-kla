function [t_s, t_p] = rem_transitions()
    t_s = @to_s;
    t_p = @to_p;
    
    episodes   = rem_expert_episodes();
    parameters = rem_parameters();

    epi_count  = numel(episodes);
    epi_length = size(episodes{1},2);

    rand_states = arrayfun(@(i) { episodes{randi(epi_count)}(randi(epi_length)) }, 1:parameters.rand_ns);

    function s = to_s(s,a)

        if(nargin == 0)
            s = rand_states{randi(numel(rand_states))};
        end

        if(nargin == 1)
            s = p_to_s(s);
        end

        if(nargin == 2)
            s = p_to_s(to_p(s,a));
        end
    end
end

function s = p_to_s(p)
    s = p;
end

function p = to_p(s, a)

    if iscell(s)
        s = cell2mat(s);
    end

    param = rem_parameters();
    max_hist = param.max_hist;

    p = s;

    if(size(s,1)/2 >= max_hist)
        p = circshift(s,-2,1);
        p = repmat(p,1,size(a,2));
        
        p(39:40, :) = a;
    else
        p = repmat(p,1,size(a,2));
        p = vertcat(p,a);
    end
end