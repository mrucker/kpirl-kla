function [s2d, s2i] = discretes(posts2features, edges, partitions)

    if(isempty(partitions))
        partitions = {1:numel(edges)};
    end

    if(size(edges,2) == 1)
        edges = edges';
    end
    
    sizes = cellfun(@numel, edges)-1;

    partition_feature_indexes = partitions;
    partition_sizes           = cellfun(@(partition) {sizes(partition)}, partitions);

    n_discrete_features = numel(sizes);
    n_discrete_vectors  = sum(cellfun(@prod,partition_sizes));

    partition_feature_starts  = num2cell(cumsum([1 cellfun(@numel, partition_sizes(1:end-1))]));
    partition_feature_stops   = num2cell(cumsum(   cellfun(@numel, partition_sizes(1:end  )) ));
    
    partition_vector_starts   = cumsum([1 cellfun(@prod, partition_sizes(1:end-1))]);
        
    vector2index_partitionscale  = @(sz, start, stop){[zeros(start-1,1); 1; cumprod(sz(1:end-1)'); zeros(n_discrete_features-stop,1)]};
    vector2index_partitionscales = cellfun(vector2index_partitionscale, partition_sizes, partition_feature_starts, partition_feature_stops);
    vector2index_scales          = cell2mat(vector2index_partitionscales);
    
    vector2index_partitionshift  = @(start){[ones(start-1,1); 0; ones(n_discrete_features-start,1)]};
    vector2index_partitionshifts = cell2mat(cellfun(vector2index_partitionshift, partition_feature_starts));
    vector2index_shifts          = prod(vector2index_partitionshifts,2); 
    
    s2d = @input2discretes;
    s2i = @input2indexes;

    function discrete_vectors = input2discretes(input)
                
        assert(nargin == 0 || is_state(input) || is_index(input), 'unsupported input');

        if nargin == 0
            discrete_vectors = n_discrete_features;
        elseif is_state(input)
            discrete_vectors = nan2zero(features2discretes(posts2features(input)));
        else
            discrete_vectors = indexes2discretes(input);
        end
    end
    
    function discrete_vector_indexes = input2indexes(input)
        assert(nargin == 0 || is_state(input), 'unsupported input');

        if nargin == 0
            discrete_vector_indexes = n_discrete_vectors;
        else
            discrete_vector_indexes = discretes2indexes(features2discretes(posts2features(input)));
        end
    end

    function discrete_vectors = features2discretes(feature_vectors)
        
        discrete_vectors = zeros(size(feature_vectors));
        
        for i = 1:numel(edges)
            discrete_vectors(i,:) = discretize(feature_vectors(i,:),edges{i});
        end

        assert(~any(all(isnan(discrete_vectors)                     ,1)), 'bad discrete vectors');
        assert( all(all(isnan(discrete_vectors) | discrete_vectors>0,1)), 'bad discrete vectors');
    end

    function discrete_vectors = indexes2discretes(discrete_vector_indexes)

        if iscell(discrete_vector_indexes)
            discrete_vector_indexes = cell2mat(discrete_vector_indexes);
        end
        
        discrete_vector_partitions       = discretize(discrete_vector_indexes,[partition_vector_starts, n_discrete_vectors]);
        discrete_vector_relative_indexes = discrete_vector_indexes - partition_vector_starts(discrete_vector_partitions) + 1;
        
        discrete_vectors = zeros(n_discrete_features, numel(discrete_vector_indexes));
        
        for partition = unique(discrete_vector_partitions)
            
            is_index_in_partition     = (discrete_vector_partitions == partition);
            is_feature_in_partition   = (partition_feature_indexes{partition});
            discrete_partition_vector = ind2subvec(partition_sizes{partition}, discrete_vector_relative_indexes(is_index_in_partition));
            
            discrete_vectors(is_feature_in_partition, is_index_in_partition) = discrete_partition_vector;
        end
    end

    function discrete_vector_indexes = discretes2indexes(discrete_vectors)
        partition_indexes = vector2index_scales' * nan2zero(discrete_vectors-vector2index_shifts);
        discrete_vector_indexes    = sum(partition_indexes + (partition_vector_starts-1)'.*(partition_indexes > 0),1);

        assert(all(0 < discrete_vector_indexes & discrete_vector_indexes <= n_discrete_vectors), 'bad indexes')
    end
end

function is = is_state(input)
    % we assume the following in this check:
        % structs will always represent a state
        % states will always have more than one feature
        % all vectorized input should be interpretted as collections of column vectors
        % cells can contain either states or indexes

    if iscell(input)
       input = input{1};
    end

    is_struct_states = isstruct(input);
    is_vector_states = size(input,1) > 1;

    is = is_struct_states || is_vector_states;
end

function is = is_index(input)
    % we assume the following in this check:
        % structs will always represent a state
        % states will always have more than one feature
        % all vectorized input should be interpretted as collections of column vectors
        % cells can contain either states or indexes

    if iscell(input)
       input = input{1};
    end

    is = ~isstruct(input) && size(input,1) == 1;
end

function A = nan2zero(A)
    A(isnan(A)) = 0;
end

function subv = ind2subvec(sz,indexes)
    [out{1:numel(sz)}] = ind2sub(sz,indexes);
    subv = cell2mat(out');
end