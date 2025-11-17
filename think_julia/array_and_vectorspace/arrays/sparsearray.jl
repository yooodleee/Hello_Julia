using SparseArrays

A1 = spzeros(1000, 1000); A1[700, 300] = 7;

B1 = spzeros(1000, 1000); B1[300, 700] = 3;

sum(A1 + B1)
# 10.0

size(A1 + B1)
# (1000, 1000)
