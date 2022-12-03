# Count primes up to N*(highest rank +1). Split up by rank, and reduce at the end.

# 

from mpi4py import MPI
import numpy as np

comm = MPI.COMM_WORLD
rank = comm.Get_rank()

N = 10000000

def isPrime(n):
    if (n % 2 == 0):
        return False
    for i in range(3, int(n**0.5 + 1), 2):
        if (n % i == 0):
            return False
    return True

def countPrimes(list_of_numbers):
    count = 0
    for num in list_of_numbers:
        if isPrime(num):
            count = count + 1
    return count

tally = countPrimes([i for i in range(rank*N,(rank+1)*N)])
comm.Barrier()
tally = np.array([tally])
tot = np.array([0])
comm.Reduce(tally,tot,op=MPI.SUM)
if rank ==0:
    print(tot[0])
