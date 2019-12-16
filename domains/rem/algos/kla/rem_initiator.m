function [s_1] = rem_initiator()

    episodes = rem_expert_episodes();
    parameters   = rem_parameters();

    trajectory_count  = numel(episodes);
    trajectory_length = size(episodes{1},2);

    rand_states = arrayfun(@(i) episodes{randi(trajectory_count)}{randi(trajectory_length)}, 1:parameters.rand_ns, 'UniformOutput', false);

    s_1 = @() rand_states{randi(parameters.rand_ns)};
end