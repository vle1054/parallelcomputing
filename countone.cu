#include <string>
#include <fstream>
#include <iostream>
#include <Vector>
#include <cuda.h>
#include <stdio.h>
#include <time.h>

#define N (2048*2048)
#define THREADS_PER_BLOCK 512

__global__ void countones(int *in, int *out) {

  __shared__ int *temp;

  unsigned int tid = threadIdx.x;
  unsigned int i = blockIdx.x*blockDim.x + threadIdx.x;

if (in[tid]==1){
  atomicadd(*temp,1);

}

  __syncthreads();

  *out = *temp;
}
int main(int argc, char *argv[]){

  int row, col, temp;
  vector<int> array;

  string infile = argv[1];

  ifstream fin;
  fin.open(infile);
  fin >> row >> col;

  for(ini=0; i<(row*col); i++){
    fin<<temp;
    array[i]=temp;
  }

  cout << "DONE\n";

  fin.close();



  int *a, *b, *c; // host copies of a, b, c
  int *d_a, *d_b, *d_c; // device copies of a, b, c
  int size = N * sizeof(int);

  // Alloc space for device copies of a, b, c
  cudaMalloc((void **)&d_a, size);
  cudaMalloc((void **)&d_b, size);
  cudaMalloc((void **)&d_c, size);
  // Alloc space for host copies of a, b, c and setup input values
  a = (int *)malloc(size); random_ints(a, N);
  b = (int *)malloc(size); random_ints(b, N);
  c = (int *)malloc(size);

  // Copy inputs to device
  cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
  cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);

  // Launch add() kernel on GPU
  countones <<<N/THREADS_PER_BLOCK,THREADS_PER_BLOCK>>> (d_a, d_b, d_c);

  // Copy result back to host
  cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);

  // Cleanup
  free(a); free(b); free(c);
  cudaFree(d_a); cudaFree(d_b); cudaFree(d_c);
  return 0;
}
