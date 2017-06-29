#include <assert.h>
#include "cycleclock.h"

/*
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

// the C code uses indices up to 529 (excluded : this is [33])

#define unlikely(x)     __builtin_expect(!!(x), 0)
#define min(x,y) (((x) > (y)) ? (y) : (x)) 


static inline size_t idx_1(int i)
{
  return i * (i + 1) / 2 + 1;
}

static inline size_t idx_2(int i, int j)
{
  // assert(i < j);
  return idx_1(j) + 1 + i;
}

static inline uint64_t to_gray(uint64_t i)
{
  return (i ^ (i >> 1ll));
}

