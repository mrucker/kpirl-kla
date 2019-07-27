function f = policy_value(domain, n_episodes, n_steps, gamma)

    f = @policy_value_closure;
   
    function v = policy_value_closure(reward, ~, policy, ~, ~, ~)        
        
        if nargin == 0
            v = "V";
        else
            [s_1     ] = feval([domain '_random']);
            [~,~, t_b] = feval([domain '_transitions']);
            
            trajectories    = trajectories_from_simulations(policy, t_b, s_1, n_episodes, n_steps);
            expected_reward = expectation_from_trajectories(trajectories, reward, gamma);
            
            v = expected_reward;
        end
    end
end
