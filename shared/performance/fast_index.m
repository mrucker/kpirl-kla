function c = fast_index(default_if_none)

    assert(size(default_if_none,2) == 1, 'default value of incorrect dimension');

    my_keys = [];
    my_vals = [];

    c = @fast_index;

    function varargout = fast_index(keys,values)

        if(nargin == 0)
            varargout{1} = my_keys;
            varargout{2} = my_vals;
        end
        
        if(nargin == 1)
            if(numel(keys) < 500)
                loc = my_find_fasts(keys, my_keys);
            else
                [~, loc] = ismember(keys, my_keys);
            end

            v = repmat(default_if_none,1,numel(keys));
            v(:,loc~=0) = my_vals(:,loc(loc~=0));
            
            if(iscell(v))
                varargout = v;
            else
                varargout = num2cell(v,2);
            end 
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
                my_vals(:,loc(is_update)) = values;
            end

            if(any(is_insert))
                my_keys   = [my_keys keys];
                my_vals = [my_vals values];
                
                [my_keys, I] = sort(my_keys);
                [my_vals ] = my_vals(:,I);
            end
        end
    end

    function loc = my_find_fasts(x,A)
        n_x = numel(x);
        loc = zeros(1, n_x);

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