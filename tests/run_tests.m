run(fullfile(fileparts(which(mfilename)), '..', 'shared', 'paths.m'));

n_rows = 1;
n_cols = 20;

test_indexable(nan (n_rows,1), n_rows, indexable_mem(nan(n_rows,1)));
test_indexable(ones(n_rows,1), n_rows, indexable_mem(@(is) ones(n_rows,numel(is))));
test_indexable(nan (n_rows,1), n_rows, indexable_spd(nan(n_rows, n_cols)));
test_indexable(ones(n_rows,1), n_rows, indexable_spd(ones(n_rows, n_cols)));

n_rows = 2;

test_indexable(nan (n_rows,1), n_rows, indexable_mem(nan(n_rows,1)));
test_indexable(ones(n_rows,1), n_rows, indexable_mem(@(is) ones(n_rows,numel(is))));
test_indexable(nan (n_rows,1), n_rows, indexable_spd(nan(n_rows, n_cols)));
test_indexable(ones(n_rows,1), n_rows, indexable_spd(ones(n_rows, n_cols)));
