using eecs-hpc-1 server

run g++ project_Vinh_Le.cpp -o project -fcilkplus -std=c++11

run ./project n 

n is the number of elements in array

evaluates using Sequential, cilk_spawn in front, cilk_spawn in back, and cilk_spawn for both 

checks for correctness

include -O3 for more optimization

can be found online at github.com/vle1054/parallel_computing_final.git