A = Set([2, 3, 5, 7]);

a = 9;

b = 7;

b ∈ A
# true 

a ∈ A
# false

a ∉ A
# true 

b ∉ A 
# false

B = Set([2, 3]);

C = Set([7, 3, 2, 5]);

B ⊆ C 
# true 

C ⊆ B
# false

B ⊊ A
# true 

C ⊊ A
# false 

isequal([2, 3, 1], [1, 2, 3])
# false

issetequal([2, 3, 1], [1, 2, 3])
# true