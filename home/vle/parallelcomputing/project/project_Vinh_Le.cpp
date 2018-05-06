/*
Parallel Computing 2018
Final Project
Vinh Le

1. You should choose an algorithm (e.g., breadth first search or quick sort) and write a serial program for it.
2. You should then parallelize your implementation by using pthreads, CilkPlus, or CUDA.
3. You should write a 3-page report (double column, single space, 10 pt font) to describe 1) the algorithm, 2) the serial implementation, 3) the parallel implementation, and 4) the results.
4. You should upload in Canvas your code (serial and parallel) and report in PDF by May 6.

Algorithm Chosen: Quick sort
Parallelization Method: CilkPlus
*/

#include <iostream>
#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include <cilk/cilk.h>
#include <algorithm>
#include <ratio>
#include <chrono>

using namespace std;

void sswap(int* a, int* b){
    int t = *a;
    *a = *b;
    *b = t;
}

int spartition (int arr[], int low, int high){
    int pivot = arr[high];
    int i = (low - 1);

    for (int j = low; j <= high- 1; j++){
        if (arr[j] <= pivot){
            i++;
            sswap(&arr[i], &arr[j]);
        }
    }
    sswap(&arr[i + 1], &arr[high]);
    return (i + 1);
}

void sequential_quickSort(int arr[], int low, int high){
    if (low < high){

        int pi = spartition(arr, low, high);

        sequential_quickSort(arr, low, pi - 1);
        sequential_quickSort(arr, pi + 1, high);
    }
}

void parallel_quicksort(int arr[], int low, int high){
    if (low < high){

        int pi = spartition(arr, low, high);

        cilk_spawn parallel_quicksort(arr, low, pi - 1);
         parallel_quicksort(arr, pi + 1, high);
        cilk_sync;
    }
}

int main(int argc, char *argv[]){
    float tdiff1, tdiff2;

	   srand(time(NULL));

	  int n = atoi(argv[1]);

    int* a = new int[n];
    int* b = new int[n];
    cilk_for (int i = 0; i< n; i++){
        a[i] = i;
    }

//shuffle
  random_shuffle(a, a + n);

  cilk_for (int i = 0; i< n; i++){
      b[i] = a[i];
  }


//sequential sort
  chrono::high_resolution_clock::time_point t1 = chrono::high_resolution_clock::now();
    sequential_quickSort(a, 0, n-1);
  chrono::high_resolution_clock::time_point t2 = chrono::high_resolution_clock::now();
  chrono::duration<double> time_span1 = chrono::duration_cast<chrono::duration<double>>(t2 - t1);
    printf("Time it took for Sequential run: %3.5f with %d elements\n", time_span1.count(), n);




//parallel sort
    chrono::high_resolution_clock::time_point t3 = chrono::high_resolution_clock::now();
    parallel_quicksort(b, 0, n-1);
    chrono::high_resolution_clock::time_point t4 = chrono::high_resolution_clock::now();
    chrono::duration<double> time_span2 = chrono::duration_cast<chrono::duration<double>>(t4 - t3);
        printf("Time it took for Parallel run: %3.5f with %d elements\n", time_span2.count(), n);




//Check
  bool afail = false;
    bool bfail = false;

    for(int i = 0; i<n;i++){
      if (a[i] != i){afail = true;}
      if (b[i] != i){bfail = true;}
    }


  if(afail == true){
    printf("Sequential Sorting Has Failed.\n");
  }else{
    printf("Sequential Sorting Has Succeeded.\n" );
  }


  if(bfail == true) {
    printf("Parallel Sorting Has Failed.\n");
  }else{
    printf("Parallel Sorting Has Succeeded.\n" );
  }


  return 0;
}
