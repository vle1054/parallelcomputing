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

__global__ void scan (int * arr, int * arr_gpu, int n) {
  extern __shared__ float temp[]; // allocated on invocation
   int thid = threadIdx.x;
  int1 pout = 0, pin = 1;
  // Load input into shared memory.
   // This is exclusive scan, so shift right by one
   // and set first element to 0
  temp[pout*n + thid] = (thid > 0) ? arr[thid-1] : 0;
  __syncthreads();
  for (int offset = 1; offset < n; offset *= 2)
  {
    pout = 1 - pout; // swap double buffer indices
    pin = 1 - pout;
    if (thid >= offset)
      temp[pout*n+thid] += temp[pin*n+thid - offset];
    else
      temp[pout*n+thid] = temp[pin*n+thid];
    __syncthreads();
  }
  arr_gpu[thid] = temp[pout*n+thid]; // write output


}

int main(int argc, char *argv[]){

srand(time(NULL));

int n = atoi(argv[1]);
n = (int) malloc(sizeof(int));
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

cout<<"GPU SCAN"<<endl;

//initialize and allocate memory for device same set as host
int * arr_d, * arr_gpu_d;
int * n_d;

cudaMalloc((void**) & arr_d, n*sizeof(int));
cudaMalloc((void**) & arr_gpu_d, n*sizeof(int));
cudaMalloc((void**) & n_d, sizeof(int));

//copy data from host to device
cudaMemcpy(arr_d, arr, n*sizeof(int), cudaMemcpyHostToDevice);
cudaMemcpy(n_d, &n, sizeof(int), cudaMemcpyHostToDevice);
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
