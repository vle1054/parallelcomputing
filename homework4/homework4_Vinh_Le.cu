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



}

int main(int argc, char *argv[]){

srand(time(NULL));

int n = atoi(argv[1]);
int arr[n];
cout<<"Size of Array"<<sizeof(arr)<<endl;

//Generate array
cout<<"Generating "<<n<< " random numbers"<<endl;

int *arr, * arr_cpu, * arr_gpu;
arr = (int *) malloc(n*sizeof(int));
arr_cpu = (int *) malloc(n*sizeof(int));
arr_gpu = (int *) malloc(n*sizeof(int));
cout<<"Size of Array"<<sizeof(arr)<<endl;

//fill arr with rnd nums between 1-1000
for (int i = 0; i<n; i++){
  arr[i]= rand()%1000 + 1;
  cout<<arr[i]<<endl;
}
cout<<"Size of Array"<<sizeof(arr)<<endl;
cout<<"CPU SCAN"<<endl;

//set 0th element
arr_cpu[0]=arr[0];

// CPU SCAN
for (int i=1; i<n; i++) {
  arr_cpu[i]= arr_cpu[i-1]+arr[i];
}

cout<<"GPU SCAN"<<endl;


for(int i = 0; i<sizeof(arr_cpu)-1;i++){
cout<<arr_cpu[i]<<",";
}
cout<<endl;
for(int i = 0; i< sizeof(arr_gpu);i++){
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
