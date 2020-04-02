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
.p2align 6

.globl feslite_avx512bw_asm_enum
### static inline struct solution_t * UNROLLED_CHUNK(const __m512i * Fq, __m512i * Fl, u64 alpha, 
###                                                  u64 beta, u64 gamma, struct solution_t *local_buffer)

# the System V AMD64 ABI says that :
# A) The first six integer or pointer arguments are passed in registers RDI, RSI, RDX, RCX, R8, R9
# B) we should preserve the values of %rbx, %rbp, %r12...%r15 [callee-save registers]
# C) We will receive the arguments of the function in registers :
#       Fq           in %rdi
#       Fl           in %rsi
#       64*alpha     in %rdx
#       64*beta      in %rcx
#       64*gamma     in %r8
#       local_buffer in %r9
# D) we return local_buffer in %rax

# no need to save the callee-save registers (we do not touch them)
# Load the 30 most used values into ZMM0-ZMM29
# %zmm31 is pinned to zero
# me move %r9 to %rax because it will be the return value.
# we may still use %9, %r10 and %r11
# %r11 contains the comparison output mask 
# %r9 and %r10 are available
# Let's go

feslite_avx512bw_asm_enum:
shlq $6, %rdx
shlq $6, %rcx
shlq $6, %r8
vpxord %zmm31, %zmm31, %zmm31
movq %r9, %rax         
"""

Fl = {}
Fl[0] = "%zmm0"   # 1
Fl[1] = "%zmm1"   # 1/2
Fl[2] = "%zmm2"   # 1/4
Fl[3] = "%zmm3"   # 1/8
Fl[4] = "%zmm4"   # 1/16
Fl[5] = "%zmm5"   # 1/32
Fl[6] = "%zmm6"   # 1/64
Fl[7] = "%zmm7"   # 1/128
Fl[8] = "%zmm8"   # 1/256


Fq = {}
Fq[idxq(0, 1)] = "%zmm9"     # 1/4
Fq[idxq(0, 2)] = "%zmm10"    # 1/8
Fq[idxq(1, 2)] = "%zmm11"    # 1/8
Fq[idxq(0, 3)] = "%zmm12"    # 1/16
Fq[idxq(1, 3)] = "%zmm13"    # 1/16
Fq[idxq(2, 3)] = "%zmm14"    # 1/16
Fq[idxq(0, 4)] = "%zmm15"    # 1/32
Fq[idxq(1, 4)] = "%zmm16"    # 1/32
Fq[idxq(2, 4)] = "%zmm17"    # 1/32
Fq[idxq(3, 4)] = "%zmm18"    # 1/32
Fq[idxq(0, 5)] = "%zmm19"    # 1/64
Fq[idxq(1, 5)] = "%zmm20"    # 1/64
Fq[idxq(2, 5)] = "%zmm21"    # 1/64
Fq[idxq(3, 5)] = "%zmm22"    # 1/64
Fq[idxq(4, 5)] = "%zmm23"    # 1/64
Fq[idxq(0, 6)] = "%zmm24"    # 1/128
Fq[idxq(1, 6)] = "%zmm25"    # 1/128
Fq[idxq(2, 6)] = "%zmm26"    # 1/128
Fq[idxq(3, 6)] = "%zmm27"    # 1/128
Fq[idxq(4, 6)] = "%zmm28"    # 1/128
Fq[idxq(5, 6)] = "%zmm29"    # 1/128

def output_comparison(i):
    # before the XORs, the comparison
    print('vpcmpequw %zmm0, %zmm31, %k0')
    print('ktestd %k0, %k0')
    print('jne ._report_solution_{0}'.format(i))
    print()
    print('._step_{0}_end:'.format(i))



###################""

assert Fl[0] == "%zmm0"
print(PROLOGUE)
print()

print( "# load the most-frequently used values into vector registers" )
for i, reg in Fl.items():
    print("vmovdqa32 {offset}(%rsi), {reg}   ## {reg} = Fl[{i}]".format(offset=i*64, reg=reg, i=i))
print()
for x, reg in Fq.items():
    print("vmovdqa32 {offset}(%rdi), {reg}   ## {reg} = Fq[{idx}]".format(offset=x*64, reg=reg, idx=x))
print()

alpha = 0
for i in range((1 << L) - 1):
    ########################## UNROLLED LOOP #######################################
    idx1 = ffs(i + 1)                       
    idx2 = ffs((i + 1) ^ (1 << idx1))
    a = idx1 + 1                              # offset dans Fl
    Fq_memref = None
    if idx2 == -1:
        Fq_memref = "{offset}(%rdi, %rdx)".format(offset=64*alpha)
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
            print("vpxord {src}, {dst}, {dst}".format(src=Fq[b], dst=Fl[a]))
        elif Fq_memref is None: # mem / reg
            print("vpxord {offset}(%rdi), {dst}, {dst}".format(offset=64*b, dst=Fl[a]))
        else: # mem(alpha) / reg
            print("vpxord {src}, {dst}, {dst}".format(src=Fq_memref, dst=Fl[a]))
        print("vpxord {src}, %zmm0, %zmm0".format(src=Fl[a]))
    
    elif a not in Fl:
        assert b not in Fq
        print("vmovdqa32 {offset}(%rsi), %zmm30".format(offset=64*a)) # load Fl[a]
        if Fq_memref is None: 
            print("vpxord {offset}(%rdi), %zmm30, %zmm30".format(offset=64*b))
        else:
            print("vpxord {src}, %zmm30, %zmm30".format(src=Fq_memref))
        print("vmovdqa32 %zmm30, {offset}(%rsi)".format(offset=64*a)) # store Fl[a]
        print("vpxord %zmm30, %zmm0, %zmm0")
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
    print("vmovdqa32 {reg}, {offset:2d}(%rsi)     #Fl[{i}] <-- {reg}".format(offset=i*64, reg=reg, i=i))
print()
print('##### special last step {:3d} : Fl[0] ^= (Fl[beta] ^= Fq[gamma])'.format((1 << L) - 1))
print()
output_comparison((1 << L) - 1)
print("vmovdqa32 (%rsi, %rcx), %zmm30")     # load Fl[beta]
print("vpxord (%rdi, %r8), %zmm30, %zmm30")        # xor Fq[gamma]
print("vmovdqa32 %zmm30, (%rsi, %rcx)")     # store Fl[beta]
print("vpxord %zmm30, %zmm0, %zmm0")
print()
print("# Save Fl[0] back to memory")
print("vmovdqa32 %zmm0, (%rsi)     #Fl[0] <-- %zmm0")
print()
print('ret')
print()
print()

########################## WHEN SOLUTION FOUND #######################################

print('########### now the code that reports solutions')
print()

for i in range(1<<L):
    # the mask is in %k0.
    # available registers: %r9, %r10, %r11
    print('._report_solution_{i}:          # GrayCode(i + {i}) is a solution'.format(i=i))
    # we no longer need to reset %zmm31
    print('movl ${i}, 0(%rax)               # buffer.x = {i}'.format(i=i))
    print('kmovd %k0, 4(%rax)               # buffer.mask = %r11')
    print('addq $8, %rax                    # buffer++'); 
    print('jmp ._step_{i}_end'.format(i=i))  # return to the enumeration 
    print()