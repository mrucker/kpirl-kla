function f = policy_iteration_index()

    f = @policy_iteration_index_closure;

    function v = policy_iteration_index_closure(~, ~, policy, policies, ~, ~)

        if nargin == 0
            v = "PI";
        else
            v = find(cellfun(@(p) isequal(p,policy), policies));
        end
    end
end