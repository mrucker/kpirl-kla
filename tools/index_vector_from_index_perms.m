function [index_vector] = index_vector_from_index_perms(index, perms)

    index_vector = double((1:size(perms,2))' == index);

end