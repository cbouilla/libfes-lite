
#define MODE_A  // The Fls are untouched and Fq setup correctly
                // mode B : the Fl are affected by the Fqs, more Fqs are zero.

/*
 #iteration    x (tested)     #updater       a     b       reads          updates
 -------------------------------------------------------------------------
 0000          0000           10|0001        0     n+1     Fq[0, n+1]     Fl[1]     
 0001          0001           10|0010        1     n+1     Fq[1, n+1]     Fl[2]
 0010          0011           10|0011        0     1       Fq[0,   1]     Fl[1]
 0011          0010           10|0100        2     n+1     Fq[2, n+1]     Fl[3]
 0100          0110           10|0101        0     2       Fq[0,   2]     Fl[1]
 0101          0111           10|0110        1     2       Fq[1,   2]     Fl[2]
 0110          0101           10|0111        0     1       Fq[0,   1]     Fl[1]
 0111          0100           10|1000        3     n+1     Fq[3, n+1]     Fl[4] (n)
 1000          1100           10|1001        0     3       Fq[0,   3]     Fl[1]
 1001          1101           10|1010        1     3       Fq[1,   3]     Fl[2]
 1010          1111           10|1011        0     2       Fq[0,   2]     Fl[1]
 1011          1110           10|1100        2     3       Fq[2,   3]     Fl[3]
 1100          1010           10|1101        0     2       Fq[0,   2]     Fl[1]
 1101          1011           10|1110        1     2       Fq[1,   2]     Fl[2]
 1110          1001           10|1111        0     2       Fq[0,   2]     Fl[1]
 1111          1000           11|0000        n     n+1     Fq[n, n+1]     Fl[n+1]
 -----------------------------------------------------------------------------------
 Fq[n, n+1] can be arbitrary, because it won't affect the outcome of anything.
 
 Fq[*,n] is never accessed.
*/

// TODO : decouple setup and broadcast for Fq

/* Fq_ must be of size 561, Fl_ must be of size 34 */
static inline void setup32(int n, int L, const u32 *Fq, const u32 *Fl, u32 *Fq_, u32 *Fl_)
{
	/* Setup Fq */
	int N = idxq(0, n);
	for (int i = 0; i < N; i++) /* broadcast in each lane */
		for (int j = 0; j < L; j++)
			Fq_[i*L + j] = Fq[i];
	
	/* now deal with the "fictive" variables n and n+1 */
	
	/* Fq[*,n] = arbitrary (never accessed by the enumeration code).
	             but the quadratic function does not depend on it, so leave it to zero. */
	for (int i = 0; i < n; i++) {
		int u = idxq(i, n);
		for (int j = 0; j < L; j++)
			Fq_[u*L + j] = 0;
	}
	
	/* Fq[0,n+1] = 0 */
	int k = idxq(0, n+1);
	for (int j = 0; j < L; j++)
		Fq_[k*L + j] = 0;
	/* Fq[i,n+1] = Fq[i-1, i] */
	for (int i = 1; i < n; i++) {
		int u = idxq(i, n+1);
		int v = idxq(i-1, i);
		for (int j = 0; j < L; j++)
			Fq_[u*L + j] = Fq[v];
	}
	/* Fq[n,n+1] = arbitrary */
	int u = idxq(n, n+1);
	for (int j = 0; j < L; j++)
		Fq_[u*L + j] = 0; // 0xDeadBeef
	/* Copy Fl */
	for (int i = 0; i < (n + 1)*L; i++)
		Fl_[i] = Fl[i];
	/* fix values of the extra item so that we don't read uninitialized memory */
	for (int i = 0; i < L; i++)
		Fl_[(n+1)*L + i] = 0; //Fl[n] ^ Fl[L];
}

static inline void setup16(int n, int L, const u32 *Fq, const u32 *Fl, u16 *Fq_, u16 *Fl_)
{
	/* Setup Fq */
	int N = idxq(0, n);
	for (int i = 0; i < N; i++)
		for (int j = 0; j < L; j++)
			Fq_[i*L + j] = Fq[i] & 0x0000ffff;
	/* Fq[0,n+1] = 0 */
	int k = idxq(0, n+1);
	for (int j = 0; j < L; j++)
		Fq_[k*L + j] = 0;
	/* Fq[i,n+1] = Fq[i-1, i] */
	for (int i = 1; i < n; i++) {
		int u = idxq(i, n+1);
		int v = idxq(i-1, i);
		for (int j = 0; j < L; j++)
			Fq_[u*L + j] = Fq_[v*L + j];
	}
	/* Fq[n,n+1] = arbitrary */
	int m = idxq(n, n+1);
	for (int j = 0; j < L; j++)
		Fq_[m*L + j] = 0xDead;

	/* Copy Fl */
	for (int i = 0; i < (n + 1)*L; i++)
		Fl_[i] = Fl[i] & 0x0000ffff;
	/* fix values of the extra item so that we don't read uninitialized memory */
	for (int i = 0; i < L; i++)
		Fl_[(n+1)*L + i] = 0xCafe;
}

static inline void setup16x2(int n, int L, const u32 *Fq, const u32 *Fl, u16 *Fq_, u16 *Fl_)
{
        /* Setup Fq */
        int N = idxq(0, n);
        for (int i = 0; i < N; i++)
		for (int j = 0; j < L; j++)
                        Fq_[i*L + j] = Fq[i] & 0x0000ffff;
        /* Fq[0,n+1] = 0 */
        int k = idxq(0, n+1);
        for (int j = 0; j < L; j++)
                Fq_[k*L + j] = 0;
        /* Fq[i,n+1] = Fq[i-1, i] */
        for (int i = 1; i < n; i++) {
                int u = idxq(i, n+1);
                int v = idxq(i-1, i);
                for (int j = 0; j < L; j++)
                        Fq_[u*L + j] = Fq_[v*L + j];
        }
        /* Fq[n,n+1] = arbitrary */
        int m = idxq(n, n+1);
        for (int j = 0; j < L; j++)
                Fq_[m*L + j] = 0xDead;
        /* Copy Fl */
        for (int i = 0; i < (n + 1)*L*2; i++)
                Fl_[i] = Fl[i] & 0x0000ffff;
        /* fix values of the extra item so that we don't read uninitialized memory */
        // TODO...                                                                                                                          
}
