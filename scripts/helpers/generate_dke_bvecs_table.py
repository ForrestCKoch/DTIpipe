#!/usr/bin/env python3
import sys
with open(sys.argv[1],'r') as fh:
	bvecs = [line.rstrip('\n ').split('  ') for line in fh]

toremove = [140, 120, 100, 80, 60, 40, 20, 0]
for i in toremove:
	for j in range(0,len(bvecs)):
		del bvecs[j][i]

with open('25.dat','w') as fh:
	for i in range(0,25):
		print(bvecs[0][i],bvecs[1][i],bvecs[2][i],sep=' ',file=fh)

with open('40.dat','w') as fh:
	for i in range(25,65):
		print(bvecs[0][i],bvecs[1][i],bvecs[2][i],sep=' ',file=fh)

with open('75.dat','w') as fh:
	for i in range(65,140):
		print(bvecs[0][i],bvecs[1][i],bvecs[2][i],sep=' ',file=fh)

