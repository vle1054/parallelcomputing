/*
Vinh Le
CSCI 440 - Parallel Computing
Homework 2.2 - transpose matrix
Colorado School of Mines 2018
*/
#include <stdio.h>

__global__ void transpose(int *in, int *out, int row, int col) {
  unsigned int tid = threadIdx.x;
  if( tid<(row*col)){
    int newid = ((tid%row)*col+(tid/row));
    out[newid] = in[tid];
  }
  __syncthreads();


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
  transpose <<<1, row*col>>> (d_in, d_out, row, col);

  // Copy result back to host
  cudaMemcpy(out, d_out, size, cudaMemcpyDeviceToHost);


  for (int i = 0 ; i < row*col;i++){
    if (i%row==0){
      printf("\n");
    }
    printf("%d ", in[i]);

  }
  printf("\n");

  for (int i = 0 ; i < row*col;i++){
    if (i%col==0){
      printf("\n");
    }

    printf("%d ", out[i]);
  }


  // Cleanup
  free(in); free(out);
  cudaFree(d_in); cudaFree(d_out);
  return 0;
}
