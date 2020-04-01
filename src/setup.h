
static inline void setup32(int n, int L, const u32 *Fq, const u32 *Fl, u32 *Fq_, u32 *Fl_)
{
	/* Setup Fq */
	int N = idxq(0, n);
	for (int i = 0; i < N; i++)
		for (int j = 0; j < L; j++)
			Fq_[i*L + j] = Fq[i];
	int k = idxq(0, n);
	for (int j = 0; j < L; j++)
		Fq_[k*L + j] = 0;
	for (int i = 1; i < n; i++) {
		int u = idxq(i, n);
		int v = idxq(i-1, i);
		for (int j = 0; j < L; j++)
			Fq_[u*L + j] = Fq[v];
	}
	int m = idxq(n, n);
	for (int j = 0; j < L; j++)
		Fq_[m*L + j] = 0;
	/* Copy Fl */
	for (int i = 0; i < (n + 1) * L; i++)
		Fl_[i] = Fl[i];
}

static inline void setup16(int n, int L, const u32 *Fq, const u32 *Fl, u16 *Fq_, u16 *Fl_)
{
	/* Setup Fq */
	int N = idxq(0, n);
	for (int i = 0; i < N; i++)
		for (int j = 0; j < L; j++)
			Fq_[i*L + j] = Fq[i] & 0x0000ffff;
	int k = idxq(0, n);
	for (int j = 0; j < L; j++)
		Fq_[k*L + j] = 0;
	for (int i = 1; i < n; i++) {
		int u = idxq(i, n);
		int v = idxq(i-1, i);
		for (int j = 0; j < L; j++)
			Fq_[u*L + j] = Fq_[v*L + j];
	}
	int m = idxq(n, n);
	for (int j = 0; j < L; j++)
		Fq_[m*L + j] = 0;
	/* Copy Fl */
	for (int i = 0; i < (n + 1)*L; i++)
		Fl_[i] = Fl[i] & 0x0000ffff;
}