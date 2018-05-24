from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
import numpy as np

def unit_vector(vector):
    """ Returns the unit vector of the vector.  """
    return vector / np.linalg.norm(vector)

def angle_between(v1, v2):
    """ Returns the angle in radians between vectors 'v1' and 'v2'::

            >>> angle_between((1, 0, 0), (0, 1, 0))
            1.5707963267948966
            >>> angle_between((1, 0, 0), (1, 0, 0))
            0.0
            >>> angle_between((1, 0, 0), (-1, 0, 0))
            3.141592653589793
    """
    v1_u = unit_vector(v1)
    v2_u = unit_vector(v2)
    return np.arccos(np.clip(np.dot(v1_u, v2_u), -1.0, 1.0))
    

with open('bv','r') as fh:
    x1 = np.array([float(x) for x in fh.readline().rstrip('\n ').split(' ')])
    y1 = np.array([float(x) for x in fh.readline().rstrip('\n ').split(' ')])
    z1 = np.array([float(x) for x in fh.readline().rstrip('\n ').split(' ')])

with open('bvecs','r') as fh:
    x2 = np.array([float(x) for x in fh.readline().rstrip('\n ').split(' ')])
    y2 = np.array([float(x) for x in fh.readline().rstrip('\n ').split(' ')])
    z2 = np.array([float(x) for x in fh.readline().rstrip('\n ').split(' ')])


tmp = np.array([np.array([x2[i],y2[i],z2[i]]) for i in range(0,len(x2))])
for i in range(0,len(tmp)):
    tmp[i] = unit_vector(tmp[i])
x2u = np.array([tmp[i][0] for i in range(0,len(tmp))])
y2u = np.array([tmp[i][1] for i in range(0,len(tmp))])
z2u = np.array([tmp[i][2] for i in range(0,len(tmp))])

fig = plt.figure()
ax = fig.add_subplot(111,projection='3d')
ax.scatter(x1,y1,z1,c='r')
ax.scatter(x2u,y2u,z2u,c='b')
#ax.scatter(x2[69:-1],y2[69:-1],z2[69:-1],c='b')
plt.show()
"""
for i in range(0,len(x1)):
    a=np.array([x1[i],y1[i],z1[i]])
    b=np.array([x2[i],y2[i],z2[i]])
    b=unit_vector(b)
    c=a-b
    print(c/np.linalg.norm(c))
    print(angle_between(a,b))
    fig=plt.figure()
    ax = fig.add_subplot(111,projection='3d')
    ax.quiver(a)
    plt.show()
"""
