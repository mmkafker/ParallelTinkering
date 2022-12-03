// https://www.youtube.com/watch?v=2EbHSCvGFM0
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#define SIZE	1024

#define DEBUG

__global__ void invsqrt(double *a, double *b, int n)
{
	int i = threadIdx.x + blockDim.x*blockIdx.x;
        int stride = blockDim.x * gridDim.x;

	for(i= threadIdx.x + blockDim.x*blockIdx.x;i<n;i+=stride) b[i] = 1.0/sqrt(a[i]);
	
}

int main()
{
	double *a, *b, *d_a, *d_b;
        int i,num;
        num = 100000*SIZE;
        a = (double *)malloc(num * sizeof(double));

        b = (double *)malloc(num * sizeof(double));	
	cudaMalloc((void **)&d_a, num * sizeof(double)); 
	cudaMalloc((void **)&d_b, num * sizeof(double));
	
	for (i = 0; i < num; ++i)
	{
		a[i] = i;
		b[i] = 0.0;
	}

	cudaMemcpy(d_a, a, num * sizeof(double), cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, b, num * sizeof(double), cudaMemcpyHostToDevice);

	invsqrt<<<1000,SIZE>>>(d_a, d_b, num);
	cudaDeviceSynchronize(); // Ensure CPU waits


	cudaMemcpy(a, d_a, num * sizeof(double), cudaMemcpyDeviceToHost);
	cudaMemcpy(b, d_b, num * sizeof(double), cudaMemcpyDeviceToHost);

//#ifndef DEBUG
        double tot;
	tot = 0.0;
	for (i = 1; i < num; ++i)
		tot+=b[i];
        printf("tot = %.17f\n",tot);

//#endif
	cudaFree(d_a);
	cudaFree(d_b);
        free(a); free(b);
	return 0;
}
