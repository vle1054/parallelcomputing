/*
Vinh Le
CSCI 440 - Parallel Computing
Homework 4 - CPU GPU SCAN
Colorado School of Mines 2018
*/


#include <iostream>
#include <ctime>
#include <stdlib.h>

using namespace std;

//Set tolerance for the check
#define TOLERANCE 0.001

//avoid bank conflicts
#define NUM_BANKS 16
#define LOG_NUM_BANKS 4
#ifdef ZERO_BANK_CONFLICTS
#define CONFLICT_FREE_OFFSET(n) \
 ((n) >> NUM_BANKS + (n) >> (2 * LOG_NUM_BANKS))
#else
#define CONFLICT_FREE_OFFSET(n) ((n) >> LOG_NUM_BANKS)
#endif

__global__ void SCAN (int * arr, int * arr_gpu, int * n) {
  extern __shared__ float temp[];// allocated on invocation
  int thid = threadIdx.x;
  int offset = 1;

  int ai = thid;
  int bi = thid + (n/2);
  int bankOffsetA = CONFLICT_FREE_OFFSET(ai);
  int bankOffsetB = CONFLICT_FREE_OFFSET(ai);
  temp[ai + bankOffsetA] = arr[ai];
  temp[bi + bankOffsetB] = arr[bi];

  int *d;
  for (d = n>>1; d > 0; d >>= 1){ // build sum in place up the tree

  __syncthreads();

  if (thid < d){
    int ai = offset*(2*thid+1)-1;
    int bi = offset*(2*thid+2)-1;
    ai += CONFLICT_FREE_OFFSET(ai);
    bi += CONFLICT_FREE_OFFSET(bi);

    temp[bi] += temp[ai];
  }

  offset *= 2;

  }
  if (thid==0) { temp[n – 1 + CONFLICT_FREE_OFFSET(n - 1)] = 0; }
  for (int d = 1; d < n; d *= 2){ // traverse down tree & build scan

     offset >>= 1;
     __syncthreads();
     if (thid < d){
       int ai = offset*(2*thid+1)-1;
       int bi = offset*(2*thid+2)-1;
       ai += CONFLICT_FREE_OFFSET(ai);
       bi += CONFLICT_FREE_OFFSET(bi);

       float t = temp[ai];
       temp[ai] = temp[bi];
       temp[bi] += t;
      }
   }
   __syncthreads();

  arr_gpu[ai] = temp[ai + bankOffsetA];
  arr_gpu[bi] = temp[bi + bankOffsetB];

}

int main(int argc, char *argv[]){

srand(time(NULL));

int * n;
n = (int *) malloc(sizeof(int));
n = atoi(argv[1]);

//Generate array
cout<<"Generating "<<n<< " random numbers"<<endl;

int * arr, * arr_cpu, * arr_gpu;
arr = (int *) malloc(n*sizeof(int));
arr_cpu = (int *) malloc(n*sizeof(int));
arr_gpu = (int *) malloc(n*sizeof(int));

//fill arr with rnd nums between 1-1000
for (int i = 0; i<n; i++){
  arr[i]= rand()%1000 + 1;
}

cout<<"CPU SCAN"<<endl;

//set 0th element
arr_cpu[0]=arr[0];

// CPU SCAN
for (int i=1; i<n; i++) {
  arr_cpu[i]= arr_cpu[i-1]+arr[i];
}

//initialize and allocate memory for device same set as host
int * arr_d, * arr_gpu_d;
int * n_d;

cudaMalloc((void**) & arr_d, n*sizeof(int));
cudaMalloc((void**) & arr_gpu_d, n*sizeof(int));
cudaMalloc((void**) & n_d, sizeof(int));

cout<<"GPU SCAN"<<endl;

//copy data from host to device
cudaMemcpy(arr_d, arr, n*sizeof(int), cudaMemcpyHostToDevice);
cudaMemcpy(n_d, n, sizeof(int), cudaMemcpyHostToDevice);
//GPU SCAN
scan<<<n, 32>>>(arr_d, arr_gpu_d, n_d);
//copy data from device to host
cudaMemcpy(arr_gpu, arr_gpu_d, n*sizeof(float), cudaMemcpyDeviceToHost);


//Compares arr_cpu with arr_gpu to determine accuracy
int tfail = 0;
for (int i = 0; i < n; i++) {
  if (abs(arr_gpu[i] - arr_cpu[i]) > TOLERANCE) {//take abs value and compare with tolerance
    tfail += 1;//if difference exceeds tolerance
  }
}

//print the number of failures
cout << "Number of Failures: " << tfail <<"\n";

return 0;
}
