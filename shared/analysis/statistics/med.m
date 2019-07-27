function f = med()

    f = @med_closure;
    
    function f = med_closure(metrics)
        if(nargin == 0)
            f = "med";
        else
            f = median(metrics);
        end
    end
end