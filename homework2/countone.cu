#include <stdio.h>

#define N (2048*2048)
#define THREADS_PER_BLOCK 512

__global__ void countones(int *in, int *out) {

  __shared__ int *temp = 0;

  unsigned int tid = threadIdx.x;

  if (in[tid]==1){
    atomicadd(*temp,1);

  }

  __syncthreads();

  *out = *temp;
}

int main(int argc, char *argv[]){

  int *in, *out; // host copies in and cout
  int *d_in, *d_out; // device copies
  int size = N * sizeof(int);

  // Alloc space for device copies of a, b, c
  cudaMalloc((void **)&d_in, size);
  cudaMalloc((void **)&d_out, size);
  // Alloc space for host copies of a, b, c and setup input values
  in = (int *)malloc(size);
  out = (int *)malloc(size);

  FILE *file = fopen(argv[1], "r");

  int data, row, col;
fscanf(file, "%d", &row)
fscanf(file, "%d", &col)


  for (int i = 0; i < row*col; i++)  {
    fscanf(file, "%d", &data);
    *in[i] = data;
  }

  fclose(file);

  int *in = *array;



  // Copy inputs to device
  cudaMemcpy(d_in, in, size, cudaMemcpyHostToDevice);

  // Launch add() kernel on GPU
  countones <<<N/THREADS_PER_BLOCK,THREADS_PER_BLOCK>>> (d_in, d_out);

  // Copy result back to host
  cudaMemcpy(out, d_out, size, cudaMemcpyDeviceToHost);

  // Cleanup
  free(in); free(out);
  cudaFree(d_in); cudaFree(d_out);
  return 0;
}
