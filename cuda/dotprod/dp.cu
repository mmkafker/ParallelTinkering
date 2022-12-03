// https://www.youtube.com/watch?v=2EbHSCvGFM0
#include <stdlib.h>
#include <stdio.h>
#define SIZE	1024

__global__ void dotprod(int *a, int *b,int *c, int n)
{
	int i = threadIdx.x;
	__shared__ int d;
	d=0;
	if (i<n)
	{
	    c[i] = a[i]* b[i];
	    d += a[i]*b[i];
	}
	__syncthreads();
	printf("d = %d\n",d);

}

int main()
{
	int *a, *b, *c;
        int i;	
	cudaMallocManaged(&a, SIZE * sizeof(int)); // Memory for both CPU and GPU
	cudaMallocManaged(&b, SIZE * sizeof(int));
        	
	cudaMallocManaged(&c, SIZE * sizeof(int));

	
	for (i = 0; i < SIZE; ++i)
	{
		a[i] = i;
		b[i] = i;
		c[i] = 0;
	}
	
	dotprod<<<1,SIZE>>>(a, b, c,SIZE);
	cudaDeviceSynchronize(); // Ensure CPU waits

	for (i=0;i<20;i++)printf("c[%d] = %d\n",i,c[i]);
	cudaFree(a);
	cudaFree(b);
	cudaFree(c);

	return 0;
}
