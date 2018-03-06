/*
Parallel Computing 2018
Assignment 1-1
N Random Numbers
Vinh Le

The executable should 1) take a positive integer N as an argument, 2) create an integer array
of size N, 3) populate the array with random integers from range [1,1000], 4) find the
largest integer and the sum of the array in parallel, and 5) print the largest integer AND the
sum of the array.
*/


#include <iostream>
#include <ctime>
#include <stdlib.h>
#include <cilk/cilk.h>

using namespace std;

int main(int argc, char *argv[]){
	
	int sum =0;
	int maxele=0;
	int n = atoi(argv[1]);
	int randarr [n];
	srand(time(NULL));
	
	cout<<"Generating "<<n<< " random numbers"<<endl;
	
	cilk_for (int i = 0; i<n; i++){
		randarr[i]= rand()%1000 + 1;
	}
	
	
	cilk_for (int j = 0; j<n;j++){
		if (randarr[j]>maxele){
			maxele = randarr[j];
		}
		
		sum += randarr [j];
		
	}
	
	cout <<"Maximum: "<< maxele<< endl;
	cout <<"Sum: " <<sum << endl;
	
	return 0;
}
