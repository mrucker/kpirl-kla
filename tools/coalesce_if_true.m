function k = coalesce_if_true(k, v)
    if k
        k = v();
    end
end