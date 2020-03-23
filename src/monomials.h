#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

/* practical schemes with constant, linear and quadratic terms are packed together.
 0 : []
 1 : [0]
 2 : [1]
 3 : [0,1]
 4 : [2]
 5 : [0,2]
 6 : [1,2]
 7 : [3]
 8 : [0, 3]
 9 : [1, 3]
10 : [2, 3]
11 : [4]
12 : [0, 4]
13 : [1, 4]
14 : [2, 4]
15 : [3, 4]
16 : [5]
17 : [0, 5]
18 : [1, 5]
19 : [2, 5]
20 : [3, 5]
21 : [4, 5]
22 : [6]
......
*/


/*  numbering only the quadratic terms + 32 extra "slack" terms
 0  : [0,  1]           
 1  : [0,  2]           
 2  : [1,  2]        
 3  : [0,  3]          
 4  : [1,  3] 
 5  : [2,  3]
 6  : [0,  4]
 7  : [1,  4]
 8  : [2,  4]
 9  : [3,  4]
10  : [0,  5]         
11  : [1,  5]
12  : [2,  5]
13  : [3,  5]
14  : [4,  5]
      .......           [0, i] is at i * (i + 1) / 2
496 : [0, 31]
      ....... 
528 : [0, 32]
      ....... 
560 :  stop
*/

// the C code uses indices up to 529 (excluded : this is [33])

#define unlikely(x)     __builtin_expect(!!(x), 0)
#define min(x,y) (((x) > (y)) ? (y) : (x)) 


static inline int idx_1(int i)
{
  return i * (i + 1) / 2 + 1;
}

static inline int idx_2(int i, int j)
{
  // assert(i < j);
  return idx_1(j) + 1 + i;
}

static inline uint32_t to_gray(uint32_t i)
{
  return (i ^ (i >> 1));
}

