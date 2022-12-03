// https://www.youtube.com/watch?v=2EbHSCvGFM0
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#define SIZE	1024

__global__ void invsqrt(double *a, double *b, int n)
{
	//int i = threadIdx.x;
	int i;
	for(i=threadIdx.x;i<n;i+=blockDim.x)
        {	
	    b[i] = 1.0/sqrt(a[i]);
	}
}

int main()
{
	double *a, *b;
        int i,num;
        num = 100000*SIZE;	
	cudaMallocManaged(&a, num * sizeof(double)); // Memory for both CPU and GPU
	cudaMallocManaged(&b, num * sizeof(double));
	
	for (i = 0; i < num; ++i)
	{
		a[i] = i;
		b[i] = 0.0;
	}
	
	invsqrt<<<1,SIZE>>>(a, b, num);
	cudaDeviceSynchronize(); // Ensure CPU waits
        double tot;
	tot = 0.0;
	for (i = 1; i < num; ++i)
		tot+=b[i];
        printf("tot = %.17f\n",tot);

	cudaFree(a);
	cudaFree(b);

	return 0;
}
