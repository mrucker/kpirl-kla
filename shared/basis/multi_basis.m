function [b_i, b_p] = multi_basis(partitions, state2feature, feature2level, level2basis)

    if ~iscell(partitions)
        partitions = {partitions};
    end
    
    feature2basis = make_feature2basis();

    n_combos_per_partition = cellfun(@prod , partitions);
    partition_index_matrix = create_partition_index_matrix(partitions);

    n_combos_cum_sum = cumsum([0, n_combos_per_partition])';
    n_combos_cum_sum(end) = [];

    b_i = @input2index;
    b_p = @input2basis;

    function index = input2index(input)
        assert(nargin == 0 || is_state(input), 'unsupported input');

        if nargin == 0
            index = sum(cellfun(@prod, partitions));
        else
            index = states2index(input);
        end
    end

    function basis = input2basis(input)
        assert(nargin == 0 || is_state(input) || is_index(input), 'unsupported input');

        if nargin == 0
            basis = numel(levels2basis(index2level(1)));
        elseif is_state(input)
            basis = states2basis(input);
        else
            basis = levels2basis(index2level(input));
        end
    end

    function f = states2basis(states)
        features = states2feature(states);
                
        f = cell2mat(rowfuns(feature2basis, features));
    end

    function f = states2index(states)
        features = states2feature(states);
        f = level2index(features2level(features));
    end

    function f = states2feature(states)
        f = cell2mat(cellfun(@(s2f) { statesfun(s2f, states) }, state2feature));

        assert(~any(all(isnan(f),1)), 'bad features');
    end

    function l = features2level(features)
        l = nan2zero(cell2mat(rowfuns(feature2level, features)));

        assert(~any(all(l==0,1)), 'bad levels');
        assert( all(all(l>=0,1)), 'bad levels');
    end

    function b = levels2basis(levels)
        b = cell2mat(rowfuns(level2basis, levels));
    end

    function l = index2level(index)
        
        if iscell(index)
            index = cell2mat(index);
        end
        
        cum               = index - cumsum(n_combos_per_partition') + n_combos_per_partition';
        valid_cum         = (cum > 0) & (cum <= n_combos_per_partition');
        partition_indexes = cum .* valid_cum;
        l             = cell2mat(arrayfun(@(i) ind2subv(partitions{i}, partition_indexes(i,:)), 1:numel(partitions), 'UniformOutput',false)');
    end

    function i = level2index(level)
        partition_indexes = (partition_index_matrix'*(level - 1));
        current_partition = (partition_indexes >= 0             );
        
        assert(all(sum(current_partition,1)==1), 'bad partitions')

        i = 1 + sum((partition_indexes + n_combos_cum_sum) .* current_partition,1);
    end
    
    function f = make_feature2basis()
        n_feature2basis = max(numel(feature2level), numel(level2basis));
        f               = cell(n_feature2basis,1);
    
        for i = 1:n_feature2basis

            if numel(feature2level) == 1
                f2l = feature2level{1};
            else
                f2l = feature2level{i};
            end
            
            if numel(level2basis) == 1
                l2b = level2basis{1};
            else
                l2b = level2basis{i};
            end
            
            f{i} = @(feature) l2b(nan2zero(f2l(feature)));
        end
    end
end

function is = is_state(input)

    if iscell(input) && ~isstruct(input{1}) && size(input{1},1) == 1
        is = false;
    elseif ~iscell(input) && ~isstruct(input) && size(input,1) == 1
        is = false;
    else
        is = true;
    end

end

function is = is_index(input)

    if iscell(input) && size(input{1},1) == 1 && size(input{1},2) == 1
        is = true;
    elseif size(input,1) == 1
        is = true;
    else
        is = false;
    end
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

function output = nan2zero(A)
    output=A;
    output(isnan(output)) = 0;
end

function output = rowfuns(funcs, rows)
    n_funcs = size(funcs,1);

    output = cell(n_funcs,1);

    if n_funcs == 1
        output = {funcs{1}(rows)};
    else
        for i = 1:n_funcs
            output{i} = funcs{i}(rows(i,:));
        end
    end

end

function output = statesfun(func, states)
    
    if iscell(states)
        output = cell2mat(cellfun(func, states, 'UniformOutput', false));
    elseif isstruct(states)
        output = cell2mat(arrayfun(func, states, 'UniformOutput', false));
    else
        output = func(states);
    end
end

function subv = ind2subv(siz,index)
    %https://homepages.inf.ed.ac.uk/imurray2/code/imurray-matlab/ind2subv.m
    [out{1:length(siz)}] = ind2sub(flip(siz),index); 
    subv = flip(cell2mat(out'),1) .* (index > 0);
end