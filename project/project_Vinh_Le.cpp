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
#include <ctime>
#include <stdlib.h>
#include <stdio.h>
#include <cilk/cilk.h>

using namespace std;

void swap(int* a, int* b){
    int t = *a;
    *a = *b;
    *b = t;
}

int partition (int arr[], int low, int high){
    int pivot = arr[high];
    int i = (low - 1);

    for (int j = low; j <= high- 1; j++){
        if (arr[j] <= pivot){
            i++;
            swap(&arr[i], &arr[j]);
        }
    }
    swap(&arr[i + 1], &arr[high]);
    return (i + 1);
}

void quickSort(int arr[], int low, int high){
    if (low < high){

        int pi = partition(arr, low, high);

        quickSort(arr, low, pi - 1);
        quickSort(arr, pi + 1, high);
    }
}

int main(int argc, char *argv[]){
    int n = 10;

    int* a = new int[n];
    cilk_for (int i = 0; i< n; i++){
      a[i] = i;
    }
    
    random_shuffle(a, a + n);

    sequential_quickSort(a, 0, n-1);

  //  parallel_quicksort()


    bool fail = false;
    for(int i = 0; i<size;i++){
      if (a[i] != i){
        fail = true;
      }
    }

  if(fail == true){
    printf("Sorting Has Failed.\n");
  }

    return 0;
}
