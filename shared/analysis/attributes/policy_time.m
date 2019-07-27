function f = policy_time()

    f = @policy_time_closure;

    function v = policy_time_closure(~,~,~,~,time,~)
        if(nargin == 0)
            v = "T";
        else
            v = sum(time);
        end
    end
end
