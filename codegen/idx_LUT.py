#*****************************************************************************
# *       Copyright (C) 2012 Ralf Zimmermann <Ralf.Zimmermann@rub.de>
# *       Copyright (C) 2012 Charles Bouillaguet <charles.bouillaguet@gmail.com>
#
# *
# * Distributed under the terms of the GNU General Public License (GPL)
# * as published by the Free Software Foundation; either version 2 of
# * the License, or (at your option) any later version.
# *                 http://www.gnu.org/licenses/
# *****************************************************************************

def init(n, d):
    errors = n - 1 - d # possible errors to correct
    binomials = []
    for i in range(n):
        binomials.append( [0] * n )
    
  # first computes the binomial coefficients
    binomials[0][0] = 1
        
    for i in range(1,n):
        binomials[i][0] = 1
        for j in range(1,i):
            binomials[i][j] = binomials[i-1][j] + binomials[i-1][j-1]
        binomials[i][i] = 1
                    
    LUT = []
    for i in range(d):
        LUT.append( [0] * n )
	
    # save pos[0] = 1
    LUT[0][0] = 1

    # generate the first step values
    # this fixes the highest possible value correctly
    for i in range(1,n): 
        LUT[0][i] = (LUT[0][i-1] << 1) - binomials[i-1][d]
	
    # generate remaining steps until depth-1
    # this corrects the offset for the highest possible value per step
    for step in range(1,d-1):

        # copy the values which are not modified
        for i in range(n - step - errors):
            LUT[step][i] = LUT[step-1][i]
	  
        # now correct the values
        # the first offset fix is (d - step) choose (d - step) = 1
        correction = 1
        for i in range(n - step - errors, n - step):
            LUT[step][i] = LUT[step-1][i] - correction
            correction += binomials[i][d - step]	
	
  # last step uses (offset of the last number) + 1
    for i in range(n-d+1):
        LUT[d-1][i] = i+1

    return LUT


def idx(LUT, indices):
    d = len(indices)
    if d == 0:
        return 0
    else:
        return sum([ LUT[i][ indices[d-1-i] ] for i in range(d) ])
