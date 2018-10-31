function s_2 = small_trans_post(s_1, actions)
    if size(actions,2) == 1
        s_2 = vertcat(repmat(actions, [1 size(s_1,2)]), s_1([1:4,7:end],:));
    elseif size(s_1,2) == 1
        s_2 = vertcat(actions, repmat(s_1([1:4,7:end]), [1 size(actions,2)]));
    else
        assert('cannot currently handle more than one action and state');
    end
    
end