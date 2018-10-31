function huge_states_assert(states)
    
    %assumed state = [x; y; dx; dy; ddx; ddy; dddx; dddy; w; h; r; \forall targets {x; y; age}]
            
    isRightDataTypes = @(o) isnumeric(o) && iscolumn(o);
    isRightDimension = @(o) numel(o) == 11 || (numel(o) > 11 && mod(numel(o)-11, 3) == 0);
    
    if iscell(states)
        assert(all(cellfun(isRightDataTypes, states)), 'each state must be a numeric column vector');
        assert(all(cellfun(isRightDimension, states)), 'each state must have 8 cursor features + 3 size features + 3x target features]');
    elseif ismatrix(states)    
        assert(isnumeric(states), 'each state must be a numeric column vector');
        assert(mod(size(states,1)-11, 3) == 0, 'each state must have 8 cursor features + 3 size features + 3x target features]');
    else
        assert(false, 'invalid state type');
    end
end