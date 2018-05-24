import numpy as np

with open('bvecs') as fh:
    x = np.array([float(x) for x in fh.readline().rstrip('\n ').split('\t')])
    y = np.array([float(x) for x in fh.readline().rstrip('\n ').split('\t')])
    z = np.array([float(x) for x in fh.readline().rstrip('\n ').split('\t')])

tmp = np.array([np.array([x[i],y[i],z[i]]) for i in range(0,len(x))])
for i in range(0,len(tmp)):
    tmp[i] = tmp[i] / np.linalg.norm(tmp[i])

for i in range(0,3):
    print('\t'.join([str(tmp[j][i]) for j in range(0,len(tmp))]))
