import sys
import string
import idx_LUT
import itertools
from copy import copy



def monomial_convert(m):
 
    # ex: converting [1, 0, 1, 1] to [0, 2, 3]

    ret = []

    for i in range(len(m)):

        if(m[i] == 1):
            ret.append(i)

    return ret



def next_monomial(m):

    # find point, and move all the 1's prior to the
    # point to the left

    n = len(m); d = sum(m);

    for i in range(n):

        assert i != n-1

        if m[i] == 1 and m[i+1] == 0:
           point = i
           break

    m[ point ] = 0; m[point + 1] = 1

    count = 0

    for i in range(point):
        if m[i] == 1: 
            m[i] = 0
            m[count] = 1
            count += 1



#
# this returns the list of the indices of the first `el` highest-degree derivatives
#
def get_degD_idx_list(d, unroll, el=0):
    LUT = idx_LUT.init(128, d)
    bound = idx_LUT.idx(LUT, [ unroll ]);

    n = 64
    m = [ 1 for i in range(d) ] + [ 0 for i in range(n-d) ]
    ret = []    

    for i in range(el):
    
        idx = idx_LUT.idx(LUT, monomial_convert(m[:]))
        if idx < bound:
            ret.append( idx )
        else:
            sys.stderr.write('warning: get_degD_idx_list() returns only {0} indices while el={1}\n'.format(len(ret), el))  
            break
        next_monomial(m)
    return ret


#
# this returns the list of the first 14 Most Frequently Used derivatives
#
def get_mfu_idx_list(d, unroll, el=0): 
    LUT = idx_LUT.init(128, d)
    bound = idx_LUT.idx(LUT, [ unroll ]);

    S0 = set(range(bound)) 
    S1 = set(get_degD_idx_list(d, unroll, el))
    S = S0 - S1
    L = list(S)
    L.sort()

    length = len(L[0:14])

    if(length < 14):
        sys.stderr.write('warning: get_mfu_idx_list() returns only {0} indices\n'.format(length))  

    return L[0:14] # the range can change



############## Execute ################

#d = int(sys.argv[1])
#unroll = int(sys.argv[2])
#el = int(sys.argv[3])

#Dlist = get_degD_idx_list(d, unroll, el)

#print Dlist

#dlist = get_mfu_idx_list(d, unroll, el) 

#print dlist

