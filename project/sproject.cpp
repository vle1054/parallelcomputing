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

int main(int argc, char *argv[]){
    clock_t t1, t2;
    float tdiff1, tdiff2;

	srand(time(NULL));

	   int n = atoi(argv[1]);

    int* a = new int[n];
    cilk_for (int i = 0; i< n; i++){
      a[i] = i;
    }
//shuffle
    random_shuffle(a, a + n);

//sequential sort
      t1 = clock();
    sequential_quickSort(a, 0, n-1);
      t1 = clock() - t1;
    tdiff1 = (((float)t1)/CLOCKS_PER_SEC);
      printf("Time it took for Sequential run: %3.5f with %d elements\n", tdiff1, n);




//Check
    bool afail = false;

    for(int i = 0; i<n;i++){
      if (a[i] != i){afail = true;}
    }

  if(afail == true){
    printf("Sequential Sorting Has Failed.\n");
  }else{
    printf("Sequential Sorting Has Succeeded.\n" );
  }



  return 0;
}
