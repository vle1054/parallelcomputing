/*
Vinh Le
CSCI 440 - Parallel Computing
Homework 4 - CPU GPU SCAN
Colorado School of Mines 2018
*/
#include <iostream>
#include <ctime>
#include <stdlib.h>
#include <math.h>

using namespace std;

//Set tolerance for the check
#define TOLERANCE 0.001

__global__ void scan (int * arr, int * arr_gpu, int n) {
   __shared__ float temp[1024]; // allocated on invocation
   int tid = threadIdx.x;
    for (int stride = 1; stride>1024;stride*=2){
      __syncthreads();
      if(tid+stride<1024){
          temp[tid+stride] += arr[tid];
        }
      __syncthreads();
    }
  arr_gpu[tid] = temp[tid];
}

int main(int argc, char *argv[]){

srand(time(NULL));

int n = atoi(argv[1]);

//Generate array
cout<<"Generating "<<n<< " random numbers"<<endl;

int *arr, * arr_cpu, * arr_gpu;
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


cudaMalloc((void**) & arr_d, n*sizeof(int));
cudaMalloc((void**) & arr_gpu_d, n*sizeof(int));


//copy data from host to device
cudaMemcpy(arr_d, arr, n*sizeof(int), cudaMemcpyHostToDevice);
//GPU SCAN
scan<<<1, 1024>>>(arr_d, arr_gpu_d, n);
//copy data from device to host
cudaMemcpy(arr_gpu, arr_gpu_d, n*sizeof(float), cudaMemcpyDeviceToHost);

for(int i = 0; i<n;i++){
cout<<arr_cpu[i]<<",";
}
cout<<endl;
for(int i = 0; i< n;i++){
cout<<arr_gpu[i]<<",";
}
cout<<endl;
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
