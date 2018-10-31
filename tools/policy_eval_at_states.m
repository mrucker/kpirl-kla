function V = policy_eval_at_states(Pf, eval_states, eval_stat, gamma, T, transition_pre, sample_count)
    V = 0;
    
    for i = 1:size(eval_states,2)
        eval_stats = policy_eval_at_state(Pf, eval_states{i}, eval_stat, gamma, T, transition_pre, sample_count);
        V = V + mean(cell2mat(eval_stats),2);
    end
    
    V = V/size(eval_states,2);
end