L = 8

def ffs(i):
    if i == 0:
        return -1
    k = 0
    while i & 0x0001 == 0:
        k += 1
        i >>= 1
    return k

alpha = 0
for i in range((1 << L)):
    idx1 = ffs(i + 1)
    idx2 = ffs((i + 1) ^ (1 << idx1))
    a = idx1 + 1
    if idx2 == -1:
        b = "alpha + {}".format(alpha)
        alpha += 1
    else:
        assert idx1 < idx2
        b = idx1 + idx2 * (idx2 - 1) // 2
    print("\tSTEP_2(context, {}, {}, i + {});   /* Fl[0] ^= (Fl[{}] ^= Fq[{}] */".format(a, b, i, a, b))