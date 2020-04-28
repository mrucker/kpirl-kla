function [f2i, i2d] = discrete(edges, partitions)

    if(isempty(partitions))
        partitions = {1:numel(edges)};
    end

    if(size(edges,2) == 1)
        edges = edges';
    end

    sizes = cellfun(@numel, edges)-1;

    partition_feature_indexes = partitions;
    partition_sizes           = cellfun(@(partition) {sizes(partition)}, partitions);

    n_features  = numel(sizes);
    n_discretes = sum(cellfun(@prod,partition_sizes));

    partition_feature_starts  = num2cell(cumsum([1 cellfun(@numel, partition_sizes(1:end-1))]));
    partition_feature_stops   = num2cell(cumsum(   cellfun(@numel, partition_sizes(1:end  )) ));
    
    partition_vector_starts   = cumsum([1 cellfun(@prod, partition_sizes(1:end-1))]);
        
    vector2index_partitionscale  = @(sz, start, stop){[zeros(start-1,1); 1; cumprod(sz(1:end-1)'); zeros(n_features-stop,1)]};
    vector2index_partitionscales = cellfun(vector2index_partitionscale, partition_sizes, partition_feature_starts, partition_feature_stops);
    vector2index_scales          = cell2mat(vector2index_partitionscales);
    
    vector2index_partitionshift  = @(start){[ones(start-1,1); 0; ones(n_features-start,1)]};
    vector2index_partitionshifts = cell2mat(cellfun(vector2index_partitionshift, partition_feature_starts));
    vector2index_shifts          = prod(vector2index_partitionshifts,2);         
    
    i2d = @out_indexes2discretes;
    f2i = @out_features2indexes;

    function discretes = out_indexes2discretes(indexes)
        if nargin == 0
            discretes = indexes2discretes(1:n_discretes);
        else
            discretes = indexes2discretes(indexes);
        end
    end

    function indexes = out_features2indexes(features)
        if nargin == 0
            indexes = 1:n_discretes;
        else
            indexes = discretes2indexes(features2discretes(features));
        end
    end

    function discretes = indexes2discretes(indexes)

        if iscell(indexes)
            indexes = cell2mat(indexes);
        end

        discrete_vector_partitions       = discretize(indexes,[partition_vector_starts, n_discretes]);
        discrete_vector_relative_indexes = indexes - partition_vector_starts(discrete_vector_partitions) + 1;

        discretes = zeros(n_features, numel(indexes));

        for partition = unique(discrete_vector_partitions)
            
            is_index_in_partition     = (discrete_vector_partitions == partition);
            is_feature_in_partition   = (partition_feature_indexes{partition});
            discrete_partition_vector = ind2subvec(partition_sizes{partition}, discrete_vector_relative_indexes(is_index_in_partition));
            
            discretes(is_feature_in_partition, is_index_in_partition) = discrete_partition_vector;
        end
    end

    function discretes = features2discretes(features)
        
        discretes = zeros(size(features));
        
        for i = 1:numel(edges)
            discretes(i,:) = discretize(features(i,:),edges{i});
        end

        assert(~any(all(isnan(discretes)                     ,1)), 'bad discrete vectors');
        assert( all(all(isnan(discretes) | discretes>0,1)), 'bad discrete vectors');
    end

    function indexes = discretes2indexes(discretes)
        partition_indexes = vector2index_scales' * nan2zero(discretes-vector2index_shifts);
        indexes    = sum(partition_indexes + (partition_vector_starts-1)'.*(partition_indexes > 0),1);

        assert(all(0 < indexes & indexes <= n_discretes), 'bad indexes')
    end
end

function A = nan2zero(A)
    A(isnan(A)) = 0;
end

function subv = ind2subvec(sz,indexes)
    [out{1:numel(sz)}] = ind2sub(sz,indexes);
    subv = cell2mat(out');
end