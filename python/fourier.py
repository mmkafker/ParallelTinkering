# Implement spectral second derivative using communications.

# Compare time python fourier.py with "parallel=False"
# to time mpiexec -n 8 python fourier.py with "parallel=True"

from mpi4py import MPI
import numpy as np

parallel=True



if parallel==True:
    comm = MPI.COMM_WORLD
    rank = comm.Get_rank()
    #print(f"rank = {rank}",flush=True)
    #comm.Barrier()
    blocksize=128

L = 10
dx=L/1024
xmin, xmax = 0, L
x_arr = np.arange(xmin,xmax,dx)  
N = len(x_arr)

kmax = np.pi/dx
kmin = 2*np.pi/L
k_arr = np.arange(-kmax, kmax, kmin)

sig = L/20
f_arr = (2*np.pi*sig**2)**(-0.5)*np.exp(-((x_arr-L/2)**2.0)/(2*sig**2))
f_deriv_anly = (1/(4*np.sqrt(2*np.pi)*sig**5))*(-4*sig**2+(L-2*x_arr)**2)*np.exp(-((x_arr-L/2)**2.0)/(2*sig**2)) 
ftilde = np.zeros(N,dtype=np.complex)
ftildetot = np.zeros(N,dtype=np.complex)
fderiv = np.zeros(N)
fderivtot = np.zeros(N)

if parallel==False:
    for i in range(N):
        for j in range(N):
            ftilde[i] += f_arr[j]*np.exp(-1j*x_arr[j]*k_arr[i])*dx
        ftilde[i] *= -k_arr[i]**2
    
    for i in range(N):
        for j in range(N):
            fderiv[i] += np.real(ftilde[j]*np.exp(1j*x_arr[i]*k_arr[j]))
        fderiv[i]*=kmin/(2*np.pi)



    wfile = open("fderiv.bin","wb")
    wfile.write(fderiv)
    wfile.close()

    wfile = open("fderiv_anly.bin","wb")
    wfile.write(f_deriv_anly)
    wfile.close()


if parallel==True:
    for i in range(rank*blocksize,(rank+1)*blocksize):
        for j in range(N):
            ftilde[i] += f_arr[j]*np.exp(-1j*x_arr[j]*k_arr[i])*dx
        ftilde[i] *= -k_arr[i]**2
    comm.Barrier()
    #print(f"rank = {rank}, np.sum(|ftilde|) = {np.sum(np.abs(ftilde))}",flush=True)
    comm.Allreduce([ftilde,MPI.DOUBLE_COMPLEX],[ftildetot,MPI.DOUBLE_COMPLEX],op=MPI.SUM)
    #print(f"rank = {rank}, np.sum(|ftildetot|) = {np.sum(np.abs(ftildetot))}",flush=True)

    for i in range(rank*blocksize,(rank+1)*blocksize):
        for j in range(N):
            fderiv[i] += np.real(ftildetot[j]*np.exp(1j*x_arr[i]*k_arr[j]))
        fderiv[i] *= kmin/(2*np.pi)
    comm.Barrier()
    #print(f"rank = {rank}, np.sum(fderiv) = {np.sum(fderiv)}",flush=True)
    comm.Reduce(fderiv,fderivtot,op=MPI.SUM)
    if rank==0:
        wfile = open("fderiv.bin","wb")
        wfile.write(fderivtot)
        wfile.close()

        wfile = open("fderiv_anly.bin","wb")
        wfile.write(f_deriv_anly)
        wfile.close()

