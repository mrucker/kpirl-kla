function  Mat_new  = UpdateMatrix( A_t, a_t, b_t, c_t, row_dim1, col_dim1, row_dim2, col_dim2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Mat_new=zeros(row_dim2, col_dim2);
Mat_new(1:row_dim1, 1:col_dim1) = A_t;
if (col_dim2>col_dim1)
   Mat_new(1:row_dim1, col_dim2) = a_t;
end
if  (row_dim2>row_dim1)
    Mat_new(row_dim2, 1:col_dim1) = b_t';
end
if row_dim2>row_dim1 && col_dim2>col_dim1
   Mat_new(row_dim2, col_dim2) = c_t;
end
return
