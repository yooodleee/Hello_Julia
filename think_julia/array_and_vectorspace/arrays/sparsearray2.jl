using SparseArrays

A1 = spzeros(1000, 1000); A1[700, 300] = 7;

B1 = spzeros(1000, 1000); B1[300, 700] = 3;

A2 = zeros(1000, 1000); A2[700, 300] = 7;

B2 = zeros(1000, 1000); B2[300, 700] = 3;

sizeof(A1 + B1)
# 40

sizeof(A2 + B2)
# 8000000 

@time A1 + B1;
#   0.000009 seconds (8 allocations: 8.234 KiB)

@time A2 + B2;
#   0.017848 seconds (3 allocations: 7.629 MiB, 89.17% gc time)