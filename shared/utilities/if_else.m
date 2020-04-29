function V = if_else(bool, true_val, false_val)

    if (isfunc(bool) && bool()) || (bool)
        if isfunc(true_val)
            V = true_val();
        else
            V = true_val;
        end
    else
        if isfunc(false_val)
            V = false_val();
        else
            V = false_val;
        end
    end
end

function is = isfunc(a)
    is = isa(a, 'function_handle');
end
