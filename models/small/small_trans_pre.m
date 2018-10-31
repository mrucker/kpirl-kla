function s_2 = small_trans_pre(s_1, a_1, targets, target2index, target_cdf)

    t_1   = s_1((end-size(targets,1)+1):end);
    t_1_i = target2index(t_1);
    t_2_i = find(rand <= target_cdf(t_1_i,:), 1);
    t_2   = targets(:,t_2_i);
    
    if ~isempty(a_1)
        s_2 = small_trans_post(s_1, a_1);
    else
        s_2 = s_1;
    end
    
    s_2 = [s_2(1:(end-size(targets,1)));t_2];
end