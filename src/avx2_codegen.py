L = 8

def ffs(i):
    if i == 0:
        return -1
    k = 0
    while i & 0x0001 == 0:
        k += 1
        i >>= 1
    return k

def idxq(i, j):
    assert i < j
    return i + j * (j - 1) // 2


PROLOGUE = """
.text
.p2align 5

.globl feslite_avx2_asm_enum
### static inline struct solution_t * UNROLLED_CHUNK(const __m256i * Fq, __m256i * Fl, u64 alpha, 
###                                                  u64 beta, u64 gamma, struct solution_t *local_buffer)

# the System V AMD64 ABI says that :
# A) The first six integer or pointer arguments are passed in registers RDI, RSI, RDX, RCX, R8, R9
# B) we should preserve the values of %rbx, %rbp, %r12...%r15 [callee-save registers]
# C) We will receive the arguments of the function in registers :
#       Fq           in %rdi
#       Fl           in %rsi
#       alpha        in %rdx
#       beta         in %rcx
#       gamma        in %r8
#       local_buffer in %r9
# D) we return local_buffer in %rax

# no need to save the callee-save registers (we do not touch them)
# Load the 14 most used values into XMM0-XMM13
# %ymm15 is pinned to zero
# me move %r9 to %rax because it will be the return value.
# we may still use %9, %r10 and %r11
# %r11 contains the comparison output mask 
# %r9 and %r10 are available

# Let's go

feslite_avx2_asm_enum:
shlq $5, %rdx
shlq $5, %rcx
shlq $5, %r8
vpxor %ymm15, %ymm15, %ymm15
movq %r9, %rax         
"""

Fl = {}
Fl[0] = "%ymm0"   # 1
Fl[1] = "%ymm1"   # 1/2
Fl[2] = "%ymm2"   # 1/4
Fl[3] = "%ymm3"   # 1/8
Fl[4] = "%ymm4"   # 1/16
Fl[5] = "%ymm5"   # 1/32
Fl[6] = "%ymm6"   # 1/64

Fq = {}
Fq[idxq(0, 1)] = "%ymm7"  # 1/4
Fq[idxq(0, 2)] = "%ymm8"  # 1/8
Fq[idxq(1, 2)] = "%ymm9"  # 1/8
Fq[idxq(0, 3)] = "%ymm10"  # 1/16
Fq[idxq(1, 3)] = "%ymm11" # 1/16
Fq[idxq(2, 3)] = "%ymm12" # 1/16
Fq[idxq(2, 4)] = "%ymm13" # 1/32



def output_comparison(i):
    # before the XORs, the comparison
    #if mode == "8x32":
    #    print('vpcmpeqd %ymm0, %ymm15, %ymm15'.format())
    #elif mode == "16x16":
    print('vpcmpeqw %ymm0, %ymm15, %ymm15'.format())
    #else:
    #    raise ValueError("bad mode!")
    print('vpmovmskb %ymm15, %r11d')
    print('test %r11d, %r11d')
    print('jne ._report_solution_{0}'.format(i))
    print()
    print('._step_{0}_end:'.format(i))



###################""

assert Fl[0] == "%ymm0"
print(PROLOGUE)
print()

print( "# load the most-frequently used values into vector registers" )
for i, reg in Fl.items():
    print("vmovdqa {offset}(%rsi), {reg}   ## {reg} = Fl[{i}]".format(offset=i*32, reg=reg, i=i))
print()
for x, reg in Fq.items():
    print("vmovdqa {offset}(%rdi), {reg}   ## {reg} = Fq[{idx}]".format(offset=x*32, reg=reg, idx=x))
print()

alpha = 0
for i in range((1 << L) - 1):
    ########################## UNROLLED LOOP #######################################
    idx1 = ffs(i + 1)                       
    idx2 = ffs((i + 1) ^ (1 << idx1))
    a = idx1 + 1                              # offset dans Fl
    Fq_memref = None
    if idx2 == -1:
        Fq_memref = "{offset}(%rdi, %rdx)".format(offset=32*alpha)
        b = "alpha + {}".format(alpha)
        alpha += 1
    else:
        assert idx1 < idx2
        b = idxq(idx1, idx2)                  # offset dans Fq
    
    print()
    print('##### step {:3d} : Fl[0] ^= (Fl[{}] ^= Fq[{}])'.format(i, a, b))
    print()
    output_comparison(i)


    # There are 3 possible cases :
    # 1a. Fq in register, Fl in register
    # 1b. Fq in memory,   Fl in register
    #  2. Fq in memory,   Fl in memory

    if a in Fl:
        if b in Fq: # reg / reg
            print("vpxor {src}, {dst}, {dst}".format(src=Fq[b], dst=Fl[a]))
        elif Fq_memref is None: # mem / reg
            print("vpxor {offset}(%rdi), {dst}, {dst}".format(offset=32*b, dst=Fl[a]))
        else: # mem(alpha) / reg
            print("vpxor {src}, {dst}, {dst}".format(src=Fq_memref, dst=Fl[a]))
        print("vpxor {src}, %ymm0, %ymm0".format(src=Fl[a]))
    
    elif a not in Fl:
        assert b not in Fq
        print("vmovdqa {offset}(%rsi), %ymm14".format(offset=32*a)) # load Fl[a]
        if Fq_memref is None: 
            print("vpxor {offset}(%rdi), %ymm14, %ymm14".format(offset=32*b))
        else:
            print("vpxor {src}, %ymm14, %ymm14".format(src=Fq_memref))
        print("vmovdqa %ymm14, {offset}(%rsi)".format(offset=32*a)) # store Fl[a]
        print("vpxor %ymm14, %ymm0, %ymm0")
    print()

####### ne pas oublier le dernier tour special
print('#############################')
print('# end of the unrolled chunk #')
print('#############################')
print()
print("# Save the Fl[1:] back to memory")
for i, reg in Fl.items():
    if i == 0:
        continue
    print("vmovdqa {reg}, {offset:2d}(%rsi)     #Fl[{i}] <-- {reg}".format(offset=i*32, reg=reg, i=i))
print()
print('##### special last step {:3d} : Fl[0] ^= (Fl[beta] ^= Fq[gamma])'.format((1 << L) - 1))
print()
output_comparison((1 << L) - 1)
print("vmovdqa (%rsi, %rcx), %ymm14")     # load Fl[beta]
print("vpxor (%rdi, %r8), %ymm14, %ymm14")        # xor Fq[gamma]
print("vmovdqa %ymm14, (%rsi, %rcx)")     # store Fl[beta]
print("vpxor %ymm14, %ymm0, %ymm0")
print()
print("# Save Fl[0] back to memory")
print("vmovdqa %ymm0, (%rsi)     #Fl[0] <-- %ymm0")
print()
print('ret')
print()
print()

########################## WHEN SOLUTION FOUND #######################################

print('########### now the code that reports solutions')
print()

for i in range(1<<L):
    # the mask is in %r11.
    # available registers: %r9, %r10
    # à améliorer : pourquoi contourner l'adressage?
    print('._report_solution_{i}:          # GrayCode(i + {i}) is a solution'.format(i=i))
    print('vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero')
    print('movl ${i},  0(%rax)             # buffer.x = {i}'.format(i=i))
    print('movl %r11d, 4(%rax)             # buffer.mask = %r11')
    print('addq $8, %rax                   # buffer++'); 
    print('jmp ._step_{i}_end'.format(i=i))  # return to the enumeration 
    print()