function c = indexable_spd(values, keys)
    assert(nargin >=1, "Not enough input arguments");

    if(nargin == 1)
        my_keys = zeros(1,0);
        my_vals = values;
    else
        my_keys = keys;
        my_vals = values;
    end

    c = @indexable_spd;

    function varargout = indexable_spd(keys,values)

        if(nargin == 0)
            varargout{1} = my_keys;
            varargout{2} = my_vals(:,my_keys);
        end

        if(nargin == 1)
            varargout{1} = my_vals(:,keys);
        end

        if(nargin == 2)
            my_keys = sort(unique([my_keys, keys]));
            my_vals(:,keys) = values;
        end
    end
end