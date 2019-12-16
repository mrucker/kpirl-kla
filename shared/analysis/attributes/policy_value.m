function f = policy_value(domain, episode_count, episode_length, gamma)

    f = @policy_value_closure;
   
    function v = policy_value_closure(reward, ~, policy, ~, ~, ~)        
        
        if nargin == 0
            v = "V";
        else
            [s_1     ] = feval([domain '_initiator']);
            [~,~, t_b] = feval([domain '_transitions']);
            
            trajectories    = policy2episodes(policy, t_b, s_1, episode_count, episode_length);
            expected_reward = episodes2expect(trajectories, reward, gamma);
            
            v = expected_reward;
        end
    end
end
