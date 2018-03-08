#include <stdio.h>

__global__ void countones(int *in, int *out) {
  __shared__ int temp;
  unsigned int tid = threadIdx.x;
  if (in[tid]==1){
    atomicAdd(&temp,1);
  }
  __syncthreads();
  *out = temp;
}

int main(int argc, char *argv[]){

  FILE *file = fopen(argv[1], "r");
  int row, col;
  fscanf(file, "%d",&row);
  fscanf(file, "%d", &col);

  int size = row * col * sizeof(int);

  int *in, *out; // host copies in and cout
  in = (int *)malloc(size);
  out = (int *)malloc(sizeof(int));



    for (int i = 0; i < row*col; i++)  {
    fscanf(file, "%d", &in[i]);
  }

  fclose(file);

  int *d_in, *d_out; // device copies
  cudaMalloc((void **)&d_in, size);
  cudaMalloc((void **)&d_out, sizeof(int));

  // Copy inputs to device
  cudaMemcpy(d_in, in, size, cudaMemcpyHostToDevice);

  // Launch add() kernel on GPU
  countones <<<1, row*col>>> (d_in, d_out);

  // Copy result back to host
  cudaMemcpy(out, d_out, sizeof(int), cudaMemcpyDeviceToHost);

  printf("There are %d ones.\n", *out);

  // Cleanup
  free(in); free(out);
  cudaFree(d_in); cudaFree(d_out);
  return 0;
}
