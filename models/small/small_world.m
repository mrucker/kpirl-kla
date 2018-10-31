function [states, movements, targets, actions, state2index, target2index, pre, post, targ] = small_world(d, w, h, r, ticks, survive, arrive)

xs = (1:w)';
ys = (1:h)';

all_xy = vertcat(reshape(repmat(xs',h,1), [1,w*h]), repmat(ys',1,w));

movements = zeros(2*d, (w*h)^d);

i = 0;

%this represents all potential movements
for xy1 = all_xy
    if d == 1
        i = i+1;
        movements(:,i) = vertcat(xy1);
    else
        for xy2 = all_xy
            if d == 2
                i = i+1;
                movements(:,i) = vertcat(xy1,xy2);
            else
                for xy3 = all_xy
                    if d == 3
                        i = i+1;
                        movements(:,i) = vertcat(xy1,xy2,xy3);
                    else
                        for xy4 = all_xy
                            i = i+1;
                            movements(:,i) = vertcat(xy1,xy2,xy3,xy4);
                        end
                    end
                end
            end
        end
    end
end

%this represents all potential target positions

targets = dec2bin((1:2^((w-2*r)*(h-2*r)))-1)' - '0';

%combining all movements and targets

move_cnt = size(movements,2);
targ_cnt = size(targets,2);

moves_for_each_targ = reshape(repmat(movements,[targ_cnt,1]), [2*d move_cnt * targ_cnt]);
targs_for_each_move = repmat(targets, [1 move_cnt]);
whr_for_moves_targs = repmat([w;h;r], [1, targ_cnt * move_cnt]);

%a given movement pattern indexes me by target count
%[m1,m1,m1,m2,m2,m2]
%[t1,t2,t3,t1,t2,t3] 
move_index_map = reshape(([w*h;w*h] .^ ([d:-1:1;d:-1:1]-1)) .* [h;1], [1 d*2]);
targ_index_map = power(2, ((w-2*r)*(h-2*r) - 1):-1:0);

state_move_index = @(s) move_index_map * (s(1:2*d,:)     - ones(2*d,1)) + 1;
state_targ_index = @(s) targ_index_map * (s((2*d+4):end,:)            ) + 1;

states       = vertcat(moves_for_each_targ, whr_for_moves_targs, targs_for_each_move);
state2index  = @(s) (state_move_index(s) - 1) * targ_cnt + state_targ_index(s);
target2index = @(t) targ_index_map * t + 1;

x_actions = reshape(repmat(1:w, [h 1]), [1, w*h]);
y_actions = repmat(1:h, [1 w]);

actions = vertcat(x_actions, y_actions);

assert(all(state2index(states) == 1:size(states,2)), 'There is a problem with the state to index function. This will brake the one step matrix.')

[pre,post,targ] = small_trans_matrix(movements, targets, actions, state2index, ticks, survive, arrive);

end