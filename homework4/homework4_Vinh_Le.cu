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
#include <cstdio>

using namespace std;

//Set tolerance for the check
#define TOLERANCE 0.001
#define BLOCK_SIZE 1024


__global__ void scan (int * arr, int * arr_gpu, int * aux, int n){
	
	__shared__ float temp[BLOCK_SIZE];
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	int bid = blockIdx.x;
	int tid = threadIdx.x;
	
	if (i < n && i > 0) {
		temp[tid] = arr[i-1];
		}else{
		temp[0]= 0;
	}
	int tempint;
	
	for (unsigned int stride = 1; stride < blockDim.x; stride *= 2) {
		__syncthreads();
		if(tid>=stride){
			tempint = temp[tid - stride];
		}
		__syncthreads();
		if(tid>=stride){
			temp[tid] += tempint;
		}
	}
	__syncthreads();
	
	if(i < n) {
		arr_gpu[i] = temp[tid];
	}
	if(tid == 0 && aux != NULL){
		aux[bid]=temp[1023];
	}
}


__global__ void finish (int * arr,int *aux, int NUM_BLOCK){
	int bid = blockIdx.x;
	int tid = threadIdx.x;
	if (bid>=1){
		arr[bid*BLOCK_SIZE+tid] += aux[bid];
	}
	__syncthreads();
}


/*
	__global__ void finish (int * arr, int NUM_BLOCK){
	int tid = threadIdx.x;
	for(int j = 1; j<NUM_BLOCK;j++){
	arr[j*BLOCK_SIZE+tid] += arr[j*BLOCK_SIZE-1];
	__syncthreads();
	}
	}
*/
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
		//arr[i]=1;//for debug
	}
	
	cout<<"CPU SCAN"<<endl;
	
	//set 0th element
	arr_cpu[0]=0;
	
	// CPU SCAN
	for (int i=1; i<n; i++) {
		arr_cpu[i]= arr_cpu[i-1]+arr[i-1];
	}
	
	cout<<"GPU SCAN"<<endl;
	
	//initialize and allocate memory for device same set as host
	int * arr_d, * arr_gpu_d;
	
	cudaMalloc((void**) & arr_d, n*sizeof(int));
	cudaMalloc((void**) & arr_gpu_d, n*sizeof(int));
	
	int NUM_BLOCK = ceil((float)n/BLOCK_SIZE);
	
	int * aux_d;
	cudaMalloc((void**) & aux_d, NUM_BLOCK*sizeof(int));
	
	//copy data from host to device
	cudaMemcpy(arr_d, arr, n*sizeof(int), cudaMemcpyHostToDevice);
	
	//GPU SCAN
	scan<<<NUM_BLOCK, BLOCK_SIZE>>>(arr_d, arr_gpu_d, aux_d, n);//Scan main array
	scan<<<1, BLOCK_SIZE>>>(aux_d, aux_d, NULL, n);//scan aux array
	finish<<<NUM_BLOCK, BLOCK_SIZE>>>(arr_gpu_d, aux_d, NUM_BLOCK);//add aux array to main array
	
	//copy data from device to host
	cudaMemcpy(arr_gpu, arr_gpu_d, n*sizeof(int), cudaMemcpyDeviceToHost);
	
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
