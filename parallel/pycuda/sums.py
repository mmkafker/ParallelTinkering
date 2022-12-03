import pycuda.driver as cuda
import pycuda.autoinit
from pycuda.compiler import SourceModule

import numpy as np

N = 10000

a = np.array([1 for _ in range(N)])
b = 2*np.copy(a)
a = a.astype(np.float32)
b = b.astype(np.float32)

a_gpu = cuda.mem_alloc(a.nbytes)
b_gpu = cuda.mem_alloc(b.nbytes)
c_gpu = cuda.mem_alloc(a.nbytes)


cuda.memcpy_htod(a_gpu,a)
cuda.memcpy_htod(b_gpu,b)

mod = SourceModule("""
  __global__ void adddd(float *a, float *b,float *c)
  {
    int idx = blockIdx.x;
    c[idx] = a[idx] + b[idx] ;
  }
  """)

# Okay, so each block refers to a separate parallel call of the
# function. A thread is parallelism within a single block.
# The grid is the collection of blocks.



func = mod.get_function("adddd")
func(a_gpu,b_gpu,c_gpu, block=(1,1,1),grid=(1,1))

c_sum = np.empty_like(a)
cuda.memcpy_dtoh(c_sum,c_gpu)
print(np.sum(c_sum))
