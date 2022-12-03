// https://www.youtube.com/watch?v=2EbHSCvGFM0
#include <stdlib.h>
#include <stdio.h>
#define SIZE	1024

__global__ void VectorAdd(int *a, int *b, int *c, int n)
{
	int i = threadIdx.x;
	printf("blockDim.x = %d\n",blockDim.x);
	printf("gridDim.x = %d\n", gridDim.x);

	if (i<n)
	    c[i] = a[i] + b[i];
}

int main()
{
	int *a, *b, *c;
	
	cudaMallocManaged(&a, SIZE * sizeof(int)); // Memory for both CPU and GPU
	cudaMallocManaged(&b, SIZE * sizeof(int));
	cudaMallocManaged(&c, SIZE * sizeof(int));
	
	for (int i = 0; i < SIZE; ++i)
	{
		a[i] = i;
		b[i] = i;
		c[i] = 0;
	}
	
	VectorAdd<<<1,SIZE>>>(a, b, c, SIZE);
	cudaDeviceSynchronize(); // Ensure CPU waits

	for (int i = 0; i < 10; ++i)
		printf("c[%d] = %d\n", i, c[i]);

	cudaFree(a);
	cudaFree(b);
	cudaFree(c);

	return 0;
}
