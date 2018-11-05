function [rand_state] = rand_state_from_simulation(state, policy, trans)
    rand_state = trans(state, policy(state));
end