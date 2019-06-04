function [v_l, v_i, v_p] = basic_basii(partitions, state2levels, level2features)

    if ~iscell(partitions)
        partitions = {partitions};
    end
    
    n_levels_per_partition = cellfun(@numel, partitions);
    n_combos_per_partition = cellfun(@prod , partitions);
    indexers_per_partition = cell2mat(arrayfun(@i_partition2indexer, 1:numel(partitions), 'UniformOutput', false));

    n_combos_cum_sum = cumsum([0, n_combos_per_partition])';
    n_combos_cum_sum(end) = [];

    v_l = @states2levels;
    v_i = @levels2indexes;
    v_p = @levels2features;

    function levels = states2levels(states)
        if nargin == 0
            i_levels = 1;
            i_combos = 1;
            levels = zeros(sum(n_levels_per_partition), sum(n_combos_per_partition));

            for partition_ranges = partitions
                
                partition_levels = arrayfun(@(n) 1:n, partition_ranges{1}, 'UniformOutput',false);
                partition_combos = cartesian(partition_levels{:});

                n_levels = size(partition_levels,2);
                n_combos = size(partition_combos,2);

                levels(i_levels:i_levels+n_levels-1, i_combos:i_combos+n_combos-1) = partition_combos;

                i_levels = i_levels + n_levels;
                i_combos = i_combos + n_combos;
            end

        else
            levels = cell2mat(cellfun(@(state2level) statesfun(state2level, states), state2levels, 'UniformOutput', false));
        end
    end

    function indexes = levels2indexes(levels)
        if nargin == 0
            indexes = sum(cellfun(@prod, partitions));
        else
            partition_indexes = indexers_per_partition'*(levels - 1);
            current_partition = (partition_indexes >= 0);
            indexes = 1 + sum((partition_indexes + n_combos_cum_sum) .* current_partition,1);
        end
    end

    function features = levels2features(levels)
        if nargin == 0
            features = sum(cellfun(@(l2f) numel(l2f(1)), level2features));
        else
           assert(all(levels(:)>=0), 'bad levels');
           features = cell2mat(arrayfun(@(i) level2features{i}(levels(i,:)), 1:n_levels_per_partition, 'UniformOutput', false)'); 
        end
    end

    function indexer = i_partition2indexer(i_partition)

        i_level  = 1 + sum(arrayfun(@(i) numel(partitions{i}), 1:i_partition-1));
        n_levels = sum(cellfun(@numel, partitions));    

        partition = partitions{i_partition};
        partition(1    ) = [];
        partition(end+1) = 1;

        indexer                                     = zeros(n_levels,1);    
        indexer(i_level:i_level+numel(partition)-1) = cumprod(partition,'reverse');
    end
end

function permutations = cartesian(varargin)
    n = nargin;

    [F{1:n}] = ndgrid(varargin{:});

    for i=n:-1:1
        G(:,i) = F{i}(:);
    end

    permutations = unique(G , 'rows')';
end

function output = statesfun(func, states)
    if iscell(states)
        output = cell2mat(cellfun(func, states, 'UniformOutput',false));
    else
        output = func(states);
    end
end