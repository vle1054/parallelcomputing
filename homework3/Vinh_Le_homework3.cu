/*
	Vinh Le
	CSCI 440 - Parallel Computing
	Homework 3 - Sparse Vector Matrix
	Colorado School of Mines 2018
*/

#include <stdio.h>
#include <cmath>
#include <iostream>

//Set tolerance for the check
#define TOLERANCE 0.001

__global__ void spmv (int * ptr, int * indices, float * data, float * b, float * t) {
	int i = blockIdx.x;
	int tid = threadIdx.x;
	__shared__ float pSum[32];
	pSum[tid] = 0;

//utilize memory coalescing by using 32 threads and 32 data elements at a time
	for (int a = ptr[i] + tid; a<ptr[i+1]; a+= blockDim.x) {
		pSum[tid] +=  data[a] * b[indices[a]];
	}
	__syncthreads();//Sync threads for correctness

//utilize load balancing by using only 32 threads at a time and uses half the threads
	for (int b = blockDim.x/2; b > 0; b /=2) {
		if (tid < b) {
			pSum[tid] += pSum[tid+b];
		}
		__syncthreads();//Sync threads for correctness
	}
	t[i] = pSum[0];
}

main (int argc, char **argv) {
  FILE *fp;
  char line[1024];
  int *ptr, *indices;
  float *data, *b, *t;
  int i,j;
  int n; // number of nonzero elements in data
  int nr; // number of rows in matrix
  int nc; // number of columns in matrix

  // Open input file and read to end of comments
  if (argc !=2) abort();

  if ((fp = fopen(argv[1], "r")) == NULL) {
    abort();
  }

  fgets(line, 128, fp);
  while (line[0] == '%') {
    fgets(line, 128, fp);
  }

  // Read number of rows (nr), number of columns (nc) and
  // number of elements and allocate memory for ptr, indices, data, b and t.
  sscanf(line,"%d %d %d\n", &nr, &nc, &n);
  ptr = (int *) malloc ((nr+1)*sizeof(int));
  indices = (int *) malloc(n*sizeof(int));
  data = (float *) malloc(n*sizeof(float));
  b = (float *) malloc(nc*sizeof(float));
  t = (float *) malloc(nr*sizeof(float));

  // Read data in coordinate format and initialize sparse matrix
  int lastr=0;
  for (i=0; i<n; i++) {
    int r;
    fscanf(fp,"%d %d %f\n", &r, &(indices[i]), &(data[i]));
    indices[i]--;  // start numbering at 0
    if (r!=lastr) {
      ptr[r-1] = i;
      lastr = r;
    }
  }
  ptr[nr] = n;

  // initialize t to 0 and b with random data
  for (i=0; i<nr; i++) {
    t[i] = 0.0;
  }

  for (i=0; i<nc; i++) {
    b[i] = (float) rand()/1111111111;
  }

  // MAIN COMPUTATION, SEQUENTIAL VERSION
  for (i=0; i<nr; i++) {
    for (j = ptr[i]; j<ptr[i+1]; j++) {
      t[i] = t[i] + data[j] * b[indices[j]];
    }
  }

  // TODO: Compute result on GPU and compare output

//	A CUDA implementation of SpMV which optimizes for memory coalescing or load balancing.

//initialize and allocate memory for host copy of data
float * t_h;
t_h = (float *) malloc(nr*sizeof(float));

//initialize and allocate memory for device same set as host
int * ptr_d, * indices_d;
float * data_d, * b_d, *t_d;

cudaMalloc((void**) & ptr_d, (nr+1)*sizeof(int));
cudaMalloc((void**) & indices_d, n*sizeof(int));
cudaMalloc((void**) & data_d, n*sizeof(float));
cudaMalloc((void**) & b_d, nc*sizeof(float));
cudaMalloc((void**) & t_d, nr*sizeof(float));

//copy data from host to device
cudaMemcpy(ptr_d, ptr, (nr+1)*sizeof(int), cudaMemcpyHostToDevice);
cudaMemcpy(indices_d, indices, n*sizeof(int), cudaMemcpyHostToDevice);
cudaMemcpy(data_d, data, n*sizeof(float), cudaMemcpyHostToDevice);
cudaMemcpy(b_d, b, nc*sizeof(float), cudaMemcpyHostToDevice);
spmv<<<nr, 32>>>(ptr_d, indices_d, data_d, b_d, t_d);
cudaMemcpy(t_h, t_d, nr*sizeof(float), cudaMemcpyDeviceToHost);


//TODO: You should use the CPU implementation (sparse_matvec.c) to check whether the results produced by your GPU code are correct.

//Compares t (CPU) with t_h (GPU) to determine accuracy
int tfail = 0;
for (int i = 0; i < nr; i++) {
  if (abs(t_h[i] - t[i]) > TOLERANCE) {//take abs value and compare with tolerance
    tfail += 1;//if difference exceeds tolerance
  }
}

std::cout << "Number of failures: " << tfail <<"\n";//print the number of failures

}
