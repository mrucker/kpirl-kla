function [t_d, t_s, t_b] = butts_transitions()

    t_d = @butts_trans_post;
    t_s = @butts_trans_pre;
    t_b = @(s,a) t_s(t_d(s,a));

end

function s2 = butts_trans_post(s1, a);persistent max_hist;

    if(isempty(max_hist))
        param = butts_paramaters();
        max_hist = param.max_hist;
    end

    s2 = s1;

    if(size(s1,1)/2 >= max_hist)
        s2 = circshift(s1,-2,1);
        s2 = repmat(s2,1,size(a,2));
        
        s2(39:40, :) = a;
    else
        s2 = repmat(s2,1,size(a,2));
        s2 = vertcat(s2,a);
    end
end

function s2 = butts_trans_pre(s1)

    s2 = s1;
    
end