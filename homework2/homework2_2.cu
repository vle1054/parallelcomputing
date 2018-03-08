/*
Vinh Le
CSCI 440 - Parallel Computing
Colorado School of Mines 2018
*/
#include <stdio.h>

__global__ void transpose(int *in, int *out, int row) {
  __shared__ int *temp;
  unsigned int tid = threadIdx.x;

  out[(tid/row)*row+(tid%row)] = in[tid]

  __syncthreads();
  *out = *temp;
}

int main(int argc, char *argv[]){

  FILE *file = fopen(argv[1], "r");
  int row, col;
  fscanf(file, "%d",&row);
  fscanf(file, "%d", &col);

  int size = row * col * sizeof(int);

  int *in, *out; // host copies in and cout
  in = (int *)malloc(size);
  out = (int *)malloc(size);

  for (int i = 0; i < row*col; i++)  {
    fscanf(file, "%d", &in[i]);
  }

  fclose(file);

  int *d_in, *d_out; // device copies
  cudaMalloc((void **)&d_in, size);
  cudaMalloc((void **)&d_out, size);

  // Copy inputs to device
  cudaMemcpy(d_in, in, size, cudaMemcpyHostToDevice);

  // Launch add() kernel on GPU
  transpose <<<1, row*col>>> (d_in, d_out, row);

  // Copy result back to host
  cudaMemcpy(out, d_out, size, cudaMemcpyDeviceToHost);

  for (int i = 0; i<col;i++){
    for (int j=0; j< row;j++){
      printf(out[i*col+j])
    }
  }
  // Cleanup
  free(in); free(out);
  cudaFree(d_in); cudaFree(d_out);
  return 0;
}
