function v = fast_index(keys, values, default_if_none)

    [my_keys, I] = sort(keys);
    [my_values ] = values(:,I);

    v = @fast_index;

    function v = fast_index(keys,values)
        
        if(nargin == 0)
            v = my_keys;
        end
        
        if(nargin == 1)
            if(numel(keys) < 500)
                loc = my_find_fasts(keys, my_keys);
            else
                [~, loc] = ismember(keys, my_keys);
            end

            v = repmat(default_if_none,1,numel(keys));
            v(:,loc~=0) = my_values(:,loc(loc~=0));            
        end

        if(nargin == 2)
            if(numel(keys) < 500)
                loc = my_find_fasts(keys, my_keys);
            else
                [~, loc] = ismember(keys, my_keys);
            end

            is_update = loc ~= 0;
            is_insert = loc == 0;

            if(any(is_update))
                my_values(:,loc(is_update)) = values;
            end

            if(any(is_insert))
                my_keys   = [my_keys keys];
                my_values = [my_values values];
                
                [my_keys, I] = sort(keys);
                [my_values ] = values(:,I);
            end
        end
    end

    function loc = my_find_fasts(x,A)
        n_x = numel(x);
        loc = zeros(1,n_x);

        for i = 1:n_x
            loc(i) = my_find_fast(x(i),A);
        end
    end

    function loc = my_find_fast(x,A)
        L = 1;
        R = numel(A);

        if(R == 0)
            loc = 0;
            return
        end
        
        if(A(1) == x)
           loc = 1;
           return
        end

        while L+1 < R
            m = floor((L+R)/2);
            if(A(m)<x)
                L = m;
            else
                R = m;
            end
        end
        
        if(A(R) ~= x)
            loc = 0;
        else
            loc = R;
        end
    end
end