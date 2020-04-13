function [s2s, s2p] = rem_transitions()
    s2s = @to_s;
    s2p = @to_p;
    
    e_t    = rem_episodes();

    function s = to_s(s,a)

        if(nargin == 0)
            s = random_state(random_episode(e_t()));
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

function s = random_state(episode)
    s = episode{randi(size(episode,2))};
end

function t = random_episode(episodes)
    t = episodes{randi(size(episodes,2))};
end