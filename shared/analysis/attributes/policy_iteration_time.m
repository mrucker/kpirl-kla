function f = policy_iteration_time()

    f = @policy_iteration_time_closure;

    function v = policy_iteration_time_closure(~, ~, policy, policies, ~, times)

        if nargin == 0
            v = "PT";
        else
            index = find(cellfun(@(p) isequal(p,policy), policies));

            if(index == 1)
                v = sum(times(:,index));
            else
                v = sum(times(:,index)-times(:,index-1));
            end
        end
    end
end
