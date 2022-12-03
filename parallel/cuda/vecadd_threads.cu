#include <cuda.h>
#include <stdio.h>
#include <stdlib.h>

#define N 512 
__global__ void mykernel(void) 
{

}

__global__ void add(int *a, int *b, int *c)
{
    c[threadIdx.x] = a[threadIdx.x] + b[threadIdx.x];
}


int main(void)
{

    int *a,*b,*c;
    int *d_a, *d_b, *d_c;
    int size = N * sizeof(int);

    int i;
    cudaMalloc( (void **)&d_a,size);
    cudaMalloc( (void **)&d_b,size);
    cudaMalloc( (void **)&d_c,size);
    
    a = (int *)malloc(size); 
    b = (int *)malloc(size); 
    c = (int *)malloc(size);

    for (i=0;i<N;i++) 
    {
        a[i] = rand();

        b[i] = rand();

    }
    cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);

    add<<<1,N>>>(d_a,d_b,d_c);

    cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);


    free(a); free(b); free(c);
    cudaFree(d_a); cudaFree(d_b); cudaFree(d_c);
    for(i=0;i<100;i++)printf("%d\n",c[i]); 
    return 0;
}
