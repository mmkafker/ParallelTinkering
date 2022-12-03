# Launch parallel versions of the code and print the rank for each process.

# Call with:
# mpiexec -n 8 python printranks.py

from mpi4py import MPI

comm = MPI.COMM_WORLD
rank = comm.Get_rank()

print(rank)
