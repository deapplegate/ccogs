#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include <math.h>
#include <unistd.h>


#include <cuda.h>
#include <cuda_runtime_api.h>
//#include "cutil.h"
using namespace std;




int checkDeviceSpecs(int number_of_galaxies, int grid_size);


//KERNEL
__global__ void integrandKernel(double* x, double* funcEval){

  int idx = threadIdx.x;
	   
  funcEval[idx] = sin(x[idx]);


}



double doIntegral(){

  double sum;
  int nevals = 32*10000;
  int i;

  double xlow, xhigh;
  xlow = 0.;
  xhigh = M_PI/2.;

  int sizeneeded = nevals*sizeof(double);
    
  
  //CPU Memory
  double* h_xvals = (double*)malloc(sizeneeded);
  double* h_funcEvals = (double*)malloc(sizeneeded);
  
  
  for (i=0; i < nevals; i++){
    h_xvals[i] = (xhigh - xlow)*i/nevals;
    h_funcEvals[i] = 0.;
  }


  printf("a\n");



  /// first, I need to test whether the device is busy. If so, it can wait a little while.
  while(1){
    size_t testsize = 1*sizeof(float); 
    float *d_test;
    cudaMalloc(&d_test, testsize);
    cudaError_t err = cudaGetLastError();
    if( cudaSuccess != err){
      printf("gotta wait for a bit!: %s\n",  cudaGetErrorString( err) );
      sleep(10);
    }
    else break;
  }


  printf("a\n");


  //GPU memory
  double *d_xvals, *d_funcEvals;
  cudaMalloc(&d_xvals, sizeneeded);
  cudaMalloc(&d_funcEvals, sizeneeded);

  cudaMemcpy(d_xvals, h_xvals, sizeneeded, cudaMemcpyHostToDevice);
  cudaMemcpy(d_funcEvals, h_funcEvals, sizeneeded, cudaMemcpyHostToDevice);

  int threadsPerBlock = nevals;
  int blocksPerGrid = 1.;

  printf("a\n");

  integrandKernel<<<blocksPerGrid, threadsPerBlock>>>(d_xvals,d_funcEvals );

  printf("a\n");


  cudaMemcpy(h_funcEvals, d_funcEvals, sizeneeded, cudaMemcpyDeviceToHost);

  printf("a\n");


  for (i=1; i < nevals-1; i++){
    sum += 2*h_funcEvals[i];
    printf("%f\n", h_funcEvals[i]);
  }

  printf("a\n");


  sum += (h_funcEvals[0] + h_funcEvals[nevals-1]);

  sum *= (xhigh - xlow)/(2.*nevals);

  printf("a\n");

  return sum;

}


int main(int argc, char **argv){

  int nloops = atoi(argv[1]);
  int i;
  double sum = 0;

  for (i=0; i < nloops; i++){
    sum = doIntegral();
  
    printf("%f\n", sum);
  }
  

}
