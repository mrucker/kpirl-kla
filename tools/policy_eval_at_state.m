function V = policy_eval_at_state(Pf, state, eval_statistic, gamma, T, transition_pre, sample_count)

    V = cell(1, sample_count);
    
    parfor n = 1:sample_count

        v = zeros(size(eval_statistic(state),1), T);
        s = state;

        for t = 1:T
            v(:, t) = v(:, t) + gamma^(t-1) * eval_statistic(s);
            a       = Pf(s);
            s       = transition_pre(s,a);
        end
        
        V{n} = sum(v,2);
    end
    
end