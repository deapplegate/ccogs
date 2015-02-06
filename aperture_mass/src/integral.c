#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include <math.h>


double integrand(double x){

  return sin(x);

}

double doIntegral(){

  double sum;
  int nevals = 100000000;
  int i;

  double xlow, xhigh;
  xlow = 0.;
  xhigh = M_PI/2.;
    
  

  double* xvals = (double*)malloc(nevals*sizeof(double));
  double* funcEvals = (double*)malloc(nevals*sizeof(double));
  
  for (i=0; i < nevals; i++){
    xvals[i] = (xhigh - xlow)*i/nevals;
    funcEvals[i] = integrand(xvals[i]);

  }

  for (i=1; i < nevals-1; i++){
    sum += 2*funcEvals[i];
  }



  sum += (funcEvals[0] + funcEvals[nevals-1]);

  sum *= (xhigh - xlow)/(2.*nevals);

  return sum;

}


int main(int argc, char **argv){

  int nloops = atoi(argv[5]);
  int i;

  for (i=0; i < nloops; i++){
    double sum = doIntegral();
  
    printf("%f\n", sum);
  }
  

}
