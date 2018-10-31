run '../../paths.m';

deriv  = 3;
width  = 2;
height = 2;
radius = 0;

OPS     = 30;
ticks   = floor(1000/OPS);
arrive  = 200;
survive = 1000;

[states, movements, targets, actions, state2index, target2index, T] = small_world(deriv, width, height ,radius, ticks, survive, arrive);

for a_i = 1:size(actions,2)
    t_actual = sum(T{a_i},2);
    t_target = 1;
    t_error  = abs(t_actual - t_target);
    
    t_size1 = size(T{a_i}, 1);
    t_size2 = size(T{a_i}, 2);
    s_size2 = size(states,2);

    assert(all(t_error < .02)                      , 'One of the transition probabilities is far off the target of 1');
    assert(t_size1 == s_size2 && t_size2 == s_size2, 'One of the transition dimensions is off');

    for s1_i = 1:size(states,2)
        for s2_i = 1:size(states,2)
            if T{a_i}(s1_i, s2_i) ~= 0
                assert(all(states (1:4,s1_i) == states(3:6,s2_i)), 'A transition has an incorrect movement');
                assert(all(actions(1:2,a_i ) == states(1:2,s2_i)), 'A transition has an incorrect action');
            end
        end
    end
end

RB = small_reward_basii(states, actions, radius);