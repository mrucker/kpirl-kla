function [b_i, b_p] = basic_basii(partitions, state2levels, level2features)

    if ~iscell(partitions)
        partitions = {partitions};
    end

    n_levels_per_partition = cellfun(@numel, partitions);
    n_combos_per_partition = cellfun(@prod , partitions);
    partition_index_matrix = create_partition_index_matrix(partitions);

    n_combos_cum_sum = cumsum([0, n_combos_per_partition])';
    n_combos_cum_sum(end) = [];

    b_i = @in2indexes;
    b_p = @in2features;

    function indexes = in2indexes(in)
        assert(nargin == 0 || is_states(in), 'unsupported input');

        if nargin == 0
            indexes = sum(cellfun(@prod, partitions));
        else
            indexes = levels2indexes(states2levels(in));
        end
    end

    function features = in2features(in)
        assert(nargin == 0 || is_states(in) || is_indexes(in), 'unsupported input');

        if nargin == 0
            features = numel(levels2features(indexes2levels(1)));
        elseif is_states(in)
            features = levels2features(states2levels(in));
        else
            features = levels2features(indexes2levels(in));
        end
    end

    function levels = states2levels(states)
        if(numel(state2levels) == 1)
            levels = statesfun(state2levels{1}, states);
        else
            levels = cell2mat(cellfun(@(state2level) statesfun(state2level, states), state2levels, 'UniformOutput', false));
        end

        assert(all(levels(:)>=0), 'bad levels');
    end

    function levels = indexes2levels(indexes)
        cum               = indexes - cumsum(n_combos_per_partition') + n_combos_per_partition';
        valid_cum         = (cum > 0) & (cum <= n_combos_per_partition');
        partition_indexes = cum .* valid_cum;
        levels            = cell2mat(arrayfun(@(i) ind2subv(partitions{i}, partition_indexes(i,:)), 1:numel(partitions), 'UniformOutput',false)');
    end

    function features = levels2features(levels)
        if(numel(level2features) == 1)
            features = level2features{1}(levels);
        else
            features = cell2mat(arrayfun(@(i) level2features{i}(levels(i,:)), 1:sum(n_levels_per_partition), 'UniformOutput', false)'); 
        end
    end

    function indexes = levels2indexes(levels)
        partition_indexes = partition_index_matrix'*(levels - 1);
        current_partition = (partition_indexes >= 0);
        assert(all(sum(current_partition,1)==1), 'bad partitions')

        indexes = 1 + sum((partition_indexes + n_combos_cum_sum) .* current_partition,1);
    end
end

function is = is_states(in)
    is = size(in,1) > 1 || iscell(in) || isstruct(in);
end

function is = is_indexes(in)
    is = size(in,1) == 1 && ~iscell(in) && isnumeric(in) && all(floor(in) == in);
end

function partition_index_matrix = create_partition_index_matrix(partitions)

    n_levels_per_partition = cellfun(@numel, partitions);

    partition_offsets      = cumsum(horzcat(1, n_levels_per_partition(1:end-1)));
    partition_index_matrix = zeros(sum(n_levels_per_partition), numel(partitions));

    for i = 1:numel(partitions)

        partition        = partitions{i};
        partition(1    ) = [];
        partition(end+1) = 1;

        partition_indexer_loc = partition_offsets(i):partition_offsets(i)+n_levels_per_partition(i)-1;

        partition_index_matrix(partition_indexer_loc, i) = cumprod(partition,'reverse')';
    end
end

function output = statesfun(func, states)
    if iscell(states)
        output = cell2mat(cellfun(func, states, 'UniformOutput',false));
    else
        output = func(states);
    end
end

function subv = ind2subv(siz,ndx)
    
    [out{1:length(siz)}] = ind2sub(siz,ndx); 
    
    subv = cell2mat(out') .* (ndx > 0);
end