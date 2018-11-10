function [feature_expectation] = expectation_from_simulations(policy, trans, rand_state, features, steps, samples, gamma)

    feature_expectation = 0;

    for m = 1:samples
        state = rand_state();
        
        for t = 1:steps
            feature_expectation = feature_expectation + gamma^(t-1) * features(state);
            
            state = rand_state_from_simulation(state, policy, trans);
        end
    end

    feature_expectation = feature_expectation/samples;
end