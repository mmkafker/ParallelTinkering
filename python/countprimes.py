# Count the number of primes between N*rank and (N+1)*rank
# Code for prime counting stolen from the internet

# Can be verified in Mathematica using: 
# M=100000;({#,PrimePi[(#+1)*M]-PrimePi[#*M]})&/@Range[0,15]

# Call with
# mpiexec -n 8 python countprimes.py

from mpi4py import MPI
import numpy as np

comm = MPI.COMM_WORLD
rank = comm.Get_rank()

N = 1000000

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

print(f"rank = {rank}: # = {countPrimes([i for i in range(rank*N,(rank+1)*N)])}")
