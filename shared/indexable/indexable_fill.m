function c = indexable_fill(indexable, filler)

    assert(size(filler,2) == 1, 'default value of incorrect dimension');

    c = @indexable_default;

    function varargout = indexable_default(keys,values)

        if(nargin == 0)
            [varargout{1}, varargout{2}] = indexable();
        end
        
        if(nargin == 1)

            values  = indexable(keys);
            missing = all(isnan(values),1);

            if(any(missing))
                values(:,missing) = repmat(filler,1,sum(missing));
            end

            varargout{1} = values;
        end

        if(nargin == 2)
            indexable(keys,values)            
        end
    end
end