function [trajectories] = trajectories_from_simulations(policy, transition, rand_state_generator, trajectory_count, trajectory_length)

    trajectories = cell(1, trajectory_count);

    parfor t = 1:trajectory_count
        trajectory = cell(1, trajectory_length);
        trajectory{1} = rand_state_generator();

        for s = 2:trajectory_length            
            trajectory{s} = transition(trajectory{s-1}, policy(trajectory{s-1}));
        end

        trajectories{t} = trajectory;
    end
end