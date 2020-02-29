function f = reward_index()

    f = @reward_index_closure;

    function v = reward_index_closure(reward, rewards, ~, ~, ~, ~)        

        if nargin == 0
            v = "RI";
        else
            v = find(cellfun(@(r) isequal(r,reward), rewards));
        end
    end
end
