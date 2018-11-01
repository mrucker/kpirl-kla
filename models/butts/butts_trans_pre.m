function s2 = butts_trans_pre(s1, a)

    %removed for speed
    butts_states_assert(s1);

    if(nargin < 2)
        a = [];
    end

    if ~isempty(a)
        s2 = butts_trans_post(s1,a);
    else
        s2 = s1;
    end
end