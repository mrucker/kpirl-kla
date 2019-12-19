function [t_s, t_p] = rem_transitions()
    t_s = @rem_s;
    t_p = @rem_p;
end

function p = rem_p(s, a)

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

function s = rem_s(s,a)
    if(nargin == 2)
        s = rem_p(s,a);
    end
end