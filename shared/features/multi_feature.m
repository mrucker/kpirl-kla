function [s_p, s_i] = multi_feature(partitions, state2feature, feature2level)

    if ~iscell(partitions)
        partitions = {partitions};
    end
    
    n_combos_per_partition = cellfun(@prod , partitions);
    partition_index_matrix = create_partition_index_matrix(partitions);

    n_combos_cum_sum = cumsum([0, n_combos_per_partition])';
    n_combos_cum_sum(end) = [];

    s_p = @input2feature;
    s_i = @input2indexes;

    function indexes = input2indexes(input)
        assert(nargin == 0 || is_state(input), 'unsupported input');

        if nargin == 0
            indexes = sum(cellfun(@prod, partitions));
        else
            indexes = levels2indexes(features2levels(states2features(input)));
        end
    end

    function features = input2feature(input)
        assert(nargin == 0 || is_state(input) || is_index(input), 'unsupported input');

        if nargin == 0
            features = numel(indexes2levels(1));
        elseif is_state(input)
            features = features2levels(states2features(input));
        else
            features = indexes2levels(input);
        end
    end

    function features = states2features(states)
        features = cell2mat(cellfun(@(s2f) { statefun(s2f, states) }, state2feature));

        assert(~any(all(isnan(features),1)), 'bad features');
    end

    function levels = features2levels(features)
        levels = nan2zero(cell2mat(rowfuns(feature2level, features)));

        assert(~any(all(levels==0,1)), 'bad levels');
        assert( all(all(levels>=0,1)), 'bad levels');
    end

    function levels = indexes2levels(indexes)

        if iscell(indexes)
            indexes = cell2mat(indexes);
        end

        cum               = indexes - (cumsum(n_combos_per_partition) - n_combos_per_partition)';
        valid_cum         = (cum > 0) & (cum <= n_combos_per_partition');
        partition_indexes = cum .* valid_cum;
        levels                 = cell2mat(arrayfun(@(i) { ind2subv(partitions{i}, partition_indexes(i,:)) }, 1:numel(partitions))');
    end

    function indexes = levels2indexes(levels)
        partition_indexes = (partition_index_matrix'*(levels - 1));
        current_partition = (partition_indexes >= 0             );
        
        assert(all(sum(current_partition,1)==1), 'bad partitions')

        indexes = 1 + sum((partition_indexes + n_combos_cum_sum) .* current_partition,1);
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

function B = nan2zero(A)
    B = A;
    B(isnan(B)) = 0;
end

function output = rowfuns(funs, rows)
    n_funs = size(funs,1);
    output = cell(n_funs,1);

    if n_funs == 1
        output = {funs{1}(rows)};
    else
        for i = 1:n_funs
            output{i} = funs{i}(rows(i,:));
        end
    end
end

function output = statefun(fun, states)

    if iscell(states)
        output = cell2mat(cellfun(@(s) {fun(s)}, states));
    elseif isstruct(states)
        output = cell2mat(arrayfun(@(s) {fun(s)}, states));
    else
        output = fun(states);
    end
end

function subv = ind2subv(siz,index)

    [out{1:numel(siz)}] = ind2sub(flip(siz),index);
    subv = flip(cell2mat(out'),1) .* (index > 0);

    %if numel(siz) > 1
    %    test = num2cell(flip(subv)',1);
    %    assert(all(sub2ind(flip(siz), test{:})' == index))
    %else
    %    assert(all(subv == index))
    %end
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