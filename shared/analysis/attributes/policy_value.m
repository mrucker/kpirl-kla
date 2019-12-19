function f = policy_value(domain, episode_count, episode_length, gamma)

    f = @policy_value_closure;
   
    function v = policy_value_closure(reward, ~, policy, ~, ~, ~)        
        
        if nargin == 0
            v = "V";
        else
            s_1 = feval([domain '_initiator']);
            t_s = feval([domain '_transitions']);
            
            episodes  = policy2episodes(policy, t_s, s_1, episode_count, episode_length);
            exp_value = episodes2expect(episodes, reward, gamma);
            
            v = exp_value;
        end
    end
end
