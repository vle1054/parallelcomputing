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
  int *in, *out; // host copies in and cout
  int *d_in, *d_out; // device copies
FILE *file = fopen(argv[1], "r");
  int data, row, col;
fscanf(file, "%d",&row);
fscanf(file, "%d", &col);

 int size = row * col * sizeof(int);

cudaMalloc((void **)&d_in, size);
  cudaMalloc((void **)&d_out, size);
  // Alloc space for host copies of a, b, c and setup input values
  in = (int *)malloc(size);
  out = (int *)malloc(size);

for (int i = 0; i < row*col; i++)  {
    fscanf(file, "%d", &in[i]);
  }

  fclose(file);

// Copy inputs to device
  cudaMemcpy(d_in, in, size, cudaMemcpyHostToDevice);

  // Launch add() kernel on GPU
  countones <<<1, row*col>>> (d_in, d_out);

  // Copy result back to host
  cudaMemcpy(out, d_out, size, cudaMemcpyDeviceToHost);

printf("There are %d ones.\n", *out);

  // Cleanup
  free(in); free(out);
  cudaFree(d_in); cudaFree(d_out);
  return 0;
}
