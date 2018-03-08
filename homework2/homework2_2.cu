/*
Vinh Le
CSCI 440 - Parallel Computing
Colorado School of Mines 2018
*/
#include <stdio.h>

__global__ void transpose(int *in, int *out, int row, int col) {
  __shared__ int *temp;
  unsigned int tid = threadIdx.x;
if( tid<(row*col)){
 temp[(tid/row)*row+(tid%row)] = in[tid];

printf("tid %d was transposed to %d", tid, ((tid/row)*row+(tid%row)));
  }
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

printf("running transpose\n");
  // Launch add() kernel on GPU
  transpose <<<1, row*col>>> (d_in, d_out, row, col);

printf("Finish transpose\n");
  // Copy result back to host
  cudaMemcpy(out, d_out, size, cudaMemcpyDeviceToHost);

  for (int i = 0; i< col;i++){
    for (int j=0; j< row;j++){
      printf("%d",in[i*col+j]);
    }
    printf("\n");
  }


  for (int i = 0; i< row;i++){
    for (int j=0; j< col;j++){
      printf("%d",out[i*row+j]);
    }
    printf("\n");
  }
  // Cleanup
  free(in); free(out);
  cudaFree(d_in); cudaFree(d_out);
  return 0;
}
