function [b_i, b_p] = multi_feature(partitions, state2feature, feature2level, level2feature)

    if ~iscell(partitions)
        partitions = {partitions};
    end
    
    n_combos_per_partition = cellfun(@prod , partitions);
    partition_index_matrix = create_partition_index_matrix(partitions);

    n_combos_cum_sum = cumsum([0, n_combos_per_partition])';
    n_combos_cum_sum(end) = [];

    b_i = @input2index;
    b_p = @input2feats;

    function index = input2index(input)
        assert(nargin == 0 || is_state(input), 'unsupported input');

        if nargin == 0
            index = sum(cellfun(@prod, partitions));
        else
            index = level2index(features2levels(states2features(input)));
        end
    end

    function feats = input2feats(input)
        assert(nargin == 0 || is_state(input) || is_index(input), 'unsupported input');

        if nargin == 0
            feats = numel(levels2features(index2level(1)));
        elseif is_state(input)
            feats = levels2features(features2levels(states2features(input)));
        else
            feats = levels2features(index2level(input));
        end
    end

    function f = states2features(states)
        f = cell2mat(cellfun(@(s2f) { statefun(s2f, states) }, state2feature));

        assert(~any(all(isnan(f),1)), 'bad features');
    end

    function l = features2levels(features)
        l = nan2zero(cell2mat(rowfuns(feature2level, features)));

        assert(~any(all(l==0,1)), 'bad levels');
        assert( all(all(l>=0,1)), 'bad levels');
    end

    function b = levels2features(levels)
        b = cell2mat(rowfuns(level2feature, levels));
    end

    function l = index2level(index)

        if iscell(index)
            index = cell2mat(index);
        end

        cum               = index - (cumsum(n_combos_per_partition) - n_combos_per_partition)';
        valid_cum         = (cum > 0) & (cum <= n_combos_per_partition');
        partition_indexes = cum .* valid_cum;
        l                 = cell2mat(arrayfun(@(i) { ind2subv(partitions{i}, partition_indexes(i,:)) }, 1:numel(partitions))');
    end

    function i = level2index(level)
        partition_indexes = (partition_index_matrix'*(level - 1));
        current_partition = (partition_indexes >= 0             );
        
        assert(all(sum(current_partition,1)==1), 'bad partitions')

        i = 1 + sum((partition_indexes + n_combos_cum_sum) .* current_partition,1);
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
    output = A;
    output(isnan(output)) = 0;
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