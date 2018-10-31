function [trans_pre, trans_post, target_pmf] = small_trans_matrix(movements, targets, actions, state2index, ticks, time_on_screen, expected_interarrival)    

    target_max_count  = size(targets  , 1);
    target_perm_count = size(targets  , 2);
    movement_count    = size(movements, 2);
    state_count       = movement_count * target_perm_count;
    
    %we put this here because it is somewhat time consuming 
    %to recompute it below in each loop of our transitions    
    %all_target_layouts = dec2bin((1:target_perms)-1)' - '0';
    
    sub_add_sty_pmf = my_sub_add_sty_pmf(ticks, target_max_count, time_on_screen, expected_interarrival);
    
    target_pmf = my_target_pmf(targets, sub_add_sty_pmf);
    target_pmf = round(target_pmf, 3);
    
    target_pmf_rows = reshape(repmat(1:target_perm_count, [target_perm_count 1]), [target_perm_count^2 1]);
    target_pmf_cols = repmat((1:target_perm_count)', [target_perm_count 1]);
    target_pmf_vals = reshape(target_pmf', [target_perm_count^2 1]);

    target_row_col_val = [target_pmf_rows, target_pmf_cols, target_pmf_vals];    
    target_row_col_val = target_row_col_val( target_row_col_val(:,3) ~=0 ,:);

    non_zero_transition_count = movement_count * size(target_row_col_val,1);

    post = zeros(non_zero_transition_count, 3);

    for m_i = 1:movement_count
        m_curr = movements(:,m_i);

        i_curr = state2index([m_curr;0;0;0;targets(:,1)]); %i_curr == the post_state
        i_next = state2index([m_curr;0;0;0;targets(:,1)]); %i_next == i_curr since we didn't take an action 

        p_start   = (m_i-1) * size(target_row_col_val,1) + 1;
        p_stop    = p_start + size(target_row_col_val,1) - 1;
        p_indexes = p_start:p_stop;

        my_transitions      = target_row_col_val; %all the possible transitions assuming we didn't take an action (aka, i_next == i_curr)
        my_transitions(:,1) = my_transitions(:,1) + i_curr - 1;
        my_transitions(:,2) = my_transitions(:,2) + i_next - 1;

        post(p_indexes,:) = my_transitions;
    end
    
    trans_post = sparse(post(:,1),post(:,2),post(:,3), state_count, state_count);    
    trans_pre  = cell(1,size(actions,2));
    
    for a_i = 1:size(actions,2)
                        
        pre  = zeros(non_zero_transition_count, 3);
        
        %tic
        for m_i = 1:movement_count

            a = actions  (:,a_i);
            
            m_curr = movements(:,m_i);
            m_next = [a; m_curr(1:end-2)];
                        
            i_curr = state2index([m_curr;0;0;0;targets(:,1)]);
            i_next = state2index([m_next;0;0;0;targets(:,1)]);

            p_start   = (m_i-1) * size(target_row_col_val,1) + 1;
            p_stop    = p_start + size(target_row_col_val,1) - 1;
            p_indexes = p_start:p_stop;

            my_transitions      = target_row_col_val;
            my_transitions(:,1) = my_transitions(:,1) + i_curr - 1;
            my_transitions(:,2) = my_transitions(:,2) + i_next - 1;

            pre(p_indexes,:) = my_transitions;
        end
        %toc
        trans_pre{a_i} = sparse(pre(:,1),pre(:,2),pre(:,3), state_count, state_count);
    end
end

function v = my_nchoosek(n,k)
    v = factorial(n)./(factorial(n-k) .* factorial(k));
end

function target_perms_pmf = my_target_pmf(target_perms, sub_add_sty_pmf)

    target_perms_count = size(target_perms,2);
    target_perms_pmf   = zeros(target_perms_count, target_perms_count);

    for t_i = 1:target_perms_count

        target_perm = target_perms(:,t_i);
   
        add_k = sum(target_perms-target_perm == +1);
        sub_k = sum(target_perms-target_perm == -1);
        sty_k = sum(target_perms+target_perm == +2);

        target_perms_prob_lambda = @(s_i) factorial(add_k(s_i)) * sub_add_sty_pmf(add_k(s_i), sub_k(s_i), sty_k(s_i));
        target_perms_pmf(t_i,:)  = arrayfun(target_perms_prob_lambda, 1:target_perms_count);

        if all(target_perm == 1)
            target_perms_prob_lambda = @(s_i) factorial(add_k(s_i) + 1) * sub_add_sty_pmf(add_k(s_i)+1, sub_k(s_i), sty_k(s_i));
            target_perms_pmf(t_i,:)  = target_perms_pmf(t_i,:) + arrayfun(target_perms_prob_lambda, 1:target_perms_count);
        end        
    end
    
    %when changing logic I may want to remove this temporarily for testing
    target_perms_pmf = diag(1./sum(target_perms_pmf,2)) * target_perms_pmf;    
end

function sub_add_sty_pmf = my_sub_add_sty_pmf(ticks, max_targs, time_on_screen, expected_interarrival)
    
    %adds  \in [0, max_adds]
    %subs  \in [0, max_subs]
    
    %puts  \in [0, max_adds]
    %stays \in [0, max_subs]
    
    add_n = ticks;
    add_k = 0:add_n;

    add_prob = 1/expected_interarrival;

    sub_prob = 1/time_on_screen;
    sty_prob = 1 - sub_prob;

    %This is the probability of k being added in n ticks at k specific locations.

    add_k_prob = my_nchoosek(add_n, add_k) .* add_prob.^add_k .* (1-add_prob).^(add_n-add_k);
    add_k_prob = [add_k_prob, zeros(1,50)]; %we add a bunch of zeros in case somebody tries to add more than is possible
    
    %intentionally changed my put distribution so that it no longer
    %considers with replacement. This makes calculations much faster and
    %simpler since I don't have to enumerate combinations.
    %for historical purposes the old pmf was (1/max_targs).^(add_k);
    put_k_prob = tril(ones(ticks+10, max_targs+1));
    for adds = 0:(ticks+9)
        for open  = 0:max_targs
            if(open >= adds)
                put_k_prob(adds+1,open+1) = factorial(open-adds)/factorial(open);
            end
        end
    end
    
    %Two outcomes can happen to a target in a step, it either goes away or
    %stays. Therefore these add up to one. However, because targets operate
    %independently at each tick and once they are gone they stay gone, we
    %don't need nchoosek. We just need the partial geometric series for all
    %sequences that end in a subtraction event. We can then raise this to a
    %power since each target's probability is independent of all others.
    sub_ticks_prob = sub_prob * (1-sty_prob^ticks)/(1-sty_prob);
    sty_ticks_prob = sty_prob^ticks;

    sub_add_sty_pmf = @(add_k,sub_k,sty_k) add_k_prob(add_k+1) * put_k_prob(add_k + 1, max_targs - (sub_k + sty_k) + 1) * sub_ticks_prob^(sub_k) * sty_ticks_prob^(sty_k);
end
