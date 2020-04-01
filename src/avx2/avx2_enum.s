
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


# load the most-frequently used values into vector registers
vmovdqa 0(%rsi), %ymm0   ## %ymm0 = Fl[0]
vmovdqa 32(%rsi), %ymm1   ## %ymm1 = Fl[1]
vmovdqa 64(%rsi), %ymm2   ## %ymm2 = Fl[2]
vmovdqa 96(%rsi), %ymm3   ## %ymm3 = Fl[3]
vmovdqa 128(%rsi), %ymm4   ## %ymm4 = Fl[4]
vmovdqa 160(%rsi), %ymm5   ## %ymm5 = Fl[5]
vmovdqa 192(%rsi), %ymm6   ## %ymm6 = Fl[6]

vmovdqa 0(%rdi), %ymm7   ## %ymm7 = Fq[0]
vmovdqa 32(%rdi), %ymm8   ## %ymm8 = Fq[1]
vmovdqa 64(%rdi), %ymm9   ## %ymm9 = Fq[2]
vmovdqa 96(%rdi), %ymm10   ## %ymm10 = Fq[3]
vmovdqa 128(%rdi), %ymm11   ## %ymm11 = Fq[4]
vmovdqa 160(%rdi), %ymm12   ## %ymm12 = Fq[5]
vmovdqa 256(%rdi), %ymm13   ## %ymm13 = Fq[8]


##### step   0 : Fl[0] ^= (Fl[1] ^= Fq[alpha + 0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_0

._step_0_end:
vpxor 0(%rdi, %rdx), %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step   1 : Fl[0] ^= (Fl[2] ^= Fq[alpha + 1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_1

._step_1_end:
vpxor 32(%rdi, %rdx), %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step   2 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_2

._step_2_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step   3 : Fl[0] ^= (Fl[3] ^= Fq[alpha + 2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_3

._step_3_end:
vpxor 64(%rdi, %rdx), %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step   4 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_4

._step_4_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step   5 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_5

._step_5_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step   6 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_6

._step_6_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step   7 : Fl[0] ^= (Fl[4] ^= Fq[alpha + 3])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_7

._step_7_end:
vpxor 96(%rdi, %rdx), %ymm4, %ymm4
vpxor %ymm4, %ymm0, %ymm0


##### step   8 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_8

._step_8_end:
vpxor %ymm10, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step   9 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_9

._step_9_end:
vpxor %ymm11, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step  10 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_10

._step_10_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  11 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_11

._step_11_end:
vpxor %ymm12, %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step  12 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_12

._step_12_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  13 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_13

._step_13_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step  14 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_14

._step_14_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  15 : Fl[0] ^= (Fl[5] ^= Fq[alpha + 4])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_15

._step_15_end:
vpxor 128(%rdi, %rdx), %ymm5, %ymm5
vpxor %ymm5, %ymm0, %ymm0


##### step  16 : Fl[0] ^= (Fl[1] ^= Fq[6])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_16

._step_16_end:
vpxor 192(%rdi), %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  17 : Fl[0] ^= (Fl[2] ^= Fq[7])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_17

._step_17_end:
vpxor 224(%rdi), %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step  18 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_18

._step_18_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  19 : Fl[0] ^= (Fl[3] ^= Fq[8])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_19

._step_19_end:
vpxor %ymm13, %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step  20 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_20

._step_20_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  21 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_21

._step_21_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step  22 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_22

._step_22_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  23 : Fl[0] ^= (Fl[4] ^= Fq[9])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_23

._step_23_end:
vpxor 288(%rdi), %ymm4, %ymm4
vpxor %ymm4, %ymm0, %ymm0


##### step  24 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_24

._step_24_end:
vpxor %ymm10, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  25 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_25

._step_25_end:
vpxor %ymm11, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step  26 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_26

._step_26_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  27 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_27

._step_27_end:
vpxor %ymm12, %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step  28 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_28

._step_28_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  29 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_29

._step_29_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step  30 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_30

._step_30_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  31 : Fl[0] ^= (Fl[6] ^= Fq[alpha + 5])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_31

._step_31_end:
vpxor 160(%rdi, %rdx), %ymm6, %ymm6
vpxor %ymm6, %ymm0, %ymm0


##### step  32 : Fl[0] ^= (Fl[1] ^= Fq[10])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_32

._step_32_end:
vpxor 320(%rdi), %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  33 : Fl[0] ^= (Fl[2] ^= Fq[11])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_33

._step_33_end:
vpxor 352(%rdi), %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step  34 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_34

._step_34_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  35 : Fl[0] ^= (Fl[3] ^= Fq[12])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_35

._step_35_end:
vpxor 384(%rdi), %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step  36 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_36

._step_36_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  37 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_37

._step_37_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step  38 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_38

._step_38_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  39 : Fl[0] ^= (Fl[4] ^= Fq[13])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_39

._step_39_end:
vpxor 416(%rdi), %ymm4, %ymm4
vpxor %ymm4, %ymm0, %ymm0


##### step  40 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_40

._step_40_end:
vpxor %ymm10, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  41 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_41

._step_41_end:
vpxor %ymm11, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step  42 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_42

._step_42_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  43 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_43

._step_43_end:
vpxor %ymm12, %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step  44 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_44

._step_44_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  45 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_45

._step_45_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step  46 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_46

._step_46_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  47 : Fl[0] ^= (Fl[5] ^= Fq[14])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_47

._step_47_end:
vpxor 448(%rdi), %ymm5, %ymm5
vpxor %ymm5, %ymm0, %ymm0


##### step  48 : Fl[0] ^= (Fl[1] ^= Fq[6])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_48

._step_48_end:
vpxor 192(%rdi), %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  49 : Fl[0] ^= (Fl[2] ^= Fq[7])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_49

._step_49_end:
vpxor 224(%rdi), %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step  50 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_50

._step_50_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  51 : Fl[0] ^= (Fl[3] ^= Fq[8])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_51

._step_51_end:
vpxor %ymm13, %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step  52 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_52

._step_52_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  53 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_53

._step_53_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step  54 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_54

._step_54_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  55 : Fl[0] ^= (Fl[4] ^= Fq[9])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_55

._step_55_end:
vpxor 288(%rdi), %ymm4, %ymm4
vpxor %ymm4, %ymm0, %ymm0


##### step  56 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_56

._step_56_end:
vpxor %ymm10, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  57 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_57

._step_57_end:
vpxor %ymm11, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step  58 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_58

._step_58_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  59 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_59

._step_59_end:
vpxor %ymm12, %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step  60 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_60

._step_60_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  61 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_61

._step_61_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step  62 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_62

._step_62_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  63 : Fl[0] ^= (Fl[7] ^= Fq[alpha + 6])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_63

._step_63_end:
vmovdqa 224(%rsi), %ymm14
vpxor 192(%rdi, %rdx), %ymm14, %ymm14
vmovdqa %ymm14, 224(%rsi)
vpxor %ymm14, %ymm0, %ymm0


##### step  64 : Fl[0] ^= (Fl[1] ^= Fq[15])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_64

._step_64_end:
vpxor 480(%rdi), %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  65 : Fl[0] ^= (Fl[2] ^= Fq[16])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_65

._step_65_end:
vpxor 512(%rdi), %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step  66 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_66

._step_66_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  67 : Fl[0] ^= (Fl[3] ^= Fq[17])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_67

._step_67_end:
vpxor 544(%rdi), %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step  68 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_68

._step_68_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  69 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_69

._step_69_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step  70 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_70

._step_70_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  71 : Fl[0] ^= (Fl[4] ^= Fq[18])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_71

._step_71_end:
vpxor 576(%rdi), %ymm4, %ymm4
vpxor %ymm4, %ymm0, %ymm0


##### step  72 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_72

._step_72_end:
vpxor %ymm10, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  73 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_73

._step_73_end:
vpxor %ymm11, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step  74 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_74

._step_74_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  75 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_75

._step_75_end:
vpxor %ymm12, %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step  76 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_76

._step_76_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  77 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_77

._step_77_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step  78 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_78

._step_78_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  79 : Fl[0] ^= (Fl[5] ^= Fq[19])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_79

._step_79_end:
vpxor 608(%rdi), %ymm5, %ymm5
vpxor %ymm5, %ymm0, %ymm0


##### step  80 : Fl[0] ^= (Fl[1] ^= Fq[6])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_80

._step_80_end:
vpxor 192(%rdi), %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  81 : Fl[0] ^= (Fl[2] ^= Fq[7])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_81

._step_81_end:
vpxor 224(%rdi), %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step  82 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_82

._step_82_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  83 : Fl[0] ^= (Fl[3] ^= Fq[8])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_83

._step_83_end:
vpxor %ymm13, %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step  84 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_84

._step_84_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  85 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_85

._step_85_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step  86 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_86

._step_86_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  87 : Fl[0] ^= (Fl[4] ^= Fq[9])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_87

._step_87_end:
vpxor 288(%rdi), %ymm4, %ymm4
vpxor %ymm4, %ymm0, %ymm0


##### step  88 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_88

._step_88_end:
vpxor %ymm10, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  89 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_89

._step_89_end:
vpxor %ymm11, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step  90 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_90

._step_90_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  91 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_91

._step_91_end:
vpxor %ymm12, %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step  92 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_92

._step_92_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  93 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_93

._step_93_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step  94 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_94

._step_94_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  95 : Fl[0] ^= (Fl[6] ^= Fq[20])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_95

._step_95_end:
vpxor 640(%rdi), %ymm6, %ymm6
vpxor %ymm6, %ymm0, %ymm0


##### step  96 : Fl[0] ^= (Fl[1] ^= Fq[10])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_96

._step_96_end:
vpxor 320(%rdi), %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  97 : Fl[0] ^= (Fl[2] ^= Fq[11])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_97

._step_97_end:
vpxor 352(%rdi), %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step  98 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_98

._step_98_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step  99 : Fl[0] ^= (Fl[3] ^= Fq[12])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_99

._step_99_end:
vpxor 384(%rdi), %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step 100 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_100

._step_100_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 101 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_101

._step_101_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 102 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_102

._step_102_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 103 : Fl[0] ^= (Fl[4] ^= Fq[13])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_103

._step_103_end:
vpxor 416(%rdi), %ymm4, %ymm4
vpxor %ymm4, %ymm0, %ymm0


##### step 104 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_104

._step_104_end:
vpxor %ymm10, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 105 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_105

._step_105_end:
vpxor %ymm11, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 106 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_106

._step_106_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 107 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_107

._step_107_end:
vpxor %ymm12, %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step 108 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_108

._step_108_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 109 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_109

._step_109_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 110 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_110

._step_110_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 111 : Fl[0] ^= (Fl[5] ^= Fq[14])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_111

._step_111_end:
vpxor 448(%rdi), %ymm5, %ymm5
vpxor %ymm5, %ymm0, %ymm0


##### step 112 : Fl[0] ^= (Fl[1] ^= Fq[6])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_112

._step_112_end:
vpxor 192(%rdi), %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 113 : Fl[0] ^= (Fl[2] ^= Fq[7])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_113

._step_113_end:
vpxor 224(%rdi), %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 114 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_114

._step_114_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 115 : Fl[0] ^= (Fl[3] ^= Fq[8])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_115

._step_115_end:
vpxor %ymm13, %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step 116 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_116

._step_116_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 117 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_117

._step_117_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 118 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_118

._step_118_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 119 : Fl[0] ^= (Fl[4] ^= Fq[9])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_119

._step_119_end:
vpxor 288(%rdi), %ymm4, %ymm4
vpxor %ymm4, %ymm0, %ymm0


##### step 120 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_120

._step_120_end:
vpxor %ymm10, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 121 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_121

._step_121_end:
vpxor %ymm11, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 122 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_122

._step_122_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 123 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_123

._step_123_end:
vpxor %ymm12, %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step 124 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_124

._step_124_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 125 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_125

._step_125_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 126 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_126

._step_126_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 127 : Fl[0] ^= (Fl[8] ^= Fq[alpha + 7])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_127

._step_127_end:
vmovdqa 256(%rsi), %ymm14
vpxor 224(%rdi, %rdx), %ymm14, %ymm14
vmovdqa %ymm14, 256(%rsi)
vpxor %ymm14, %ymm0, %ymm0


##### step 128 : Fl[0] ^= (Fl[1] ^= Fq[21])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_128

._step_128_end:
vpxor 672(%rdi), %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 129 : Fl[0] ^= (Fl[2] ^= Fq[22])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_129

._step_129_end:
vpxor 704(%rdi), %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 130 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_130

._step_130_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 131 : Fl[0] ^= (Fl[3] ^= Fq[23])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_131

._step_131_end:
vpxor 736(%rdi), %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step 132 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_132

._step_132_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 133 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_133

._step_133_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 134 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_134

._step_134_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 135 : Fl[0] ^= (Fl[4] ^= Fq[24])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_135

._step_135_end:
vpxor 768(%rdi), %ymm4, %ymm4
vpxor %ymm4, %ymm0, %ymm0


##### step 136 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_136

._step_136_end:
vpxor %ymm10, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 137 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_137

._step_137_end:
vpxor %ymm11, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 138 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_138

._step_138_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 139 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_139

._step_139_end:
vpxor %ymm12, %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step 140 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_140

._step_140_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 141 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_141

._step_141_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 142 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_142

._step_142_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 143 : Fl[0] ^= (Fl[5] ^= Fq[25])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_143

._step_143_end:
vpxor 800(%rdi), %ymm5, %ymm5
vpxor %ymm5, %ymm0, %ymm0


##### step 144 : Fl[0] ^= (Fl[1] ^= Fq[6])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_144

._step_144_end:
vpxor 192(%rdi), %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 145 : Fl[0] ^= (Fl[2] ^= Fq[7])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_145

._step_145_end:
vpxor 224(%rdi), %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 146 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_146

._step_146_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 147 : Fl[0] ^= (Fl[3] ^= Fq[8])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_147

._step_147_end:
vpxor %ymm13, %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step 148 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_148

._step_148_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 149 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_149

._step_149_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 150 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_150

._step_150_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 151 : Fl[0] ^= (Fl[4] ^= Fq[9])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_151

._step_151_end:
vpxor 288(%rdi), %ymm4, %ymm4
vpxor %ymm4, %ymm0, %ymm0


##### step 152 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_152

._step_152_end:
vpxor %ymm10, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 153 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_153

._step_153_end:
vpxor %ymm11, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 154 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_154

._step_154_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 155 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_155

._step_155_end:
vpxor %ymm12, %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step 156 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_156

._step_156_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 157 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_157

._step_157_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 158 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_158

._step_158_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 159 : Fl[0] ^= (Fl[6] ^= Fq[26])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_159

._step_159_end:
vpxor 832(%rdi), %ymm6, %ymm6
vpxor %ymm6, %ymm0, %ymm0


##### step 160 : Fl[0] ^= (Fl[1] ^= Fq[10])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_160

._step_160_end:
vpxor 320(%rdi), %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 161 : Fl[0] ^= (Fl[2] ^= Fq[11])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_161

._step_161_end:
vpxor 352(%rdi), %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 162 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_162

._step_162_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 163 : Fl[0] ^= (Fl[3] ^= Fq[12])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_163

._step_163_end:
vpxor 384(%rdi), %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step 164 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_164

._step_164_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 165 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_165

._step_165_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 166 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_166

._step_166_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 167 : Fl[0] ^= (Fl[4] ^= Fq[13])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_167

._step_167_end:
vpxor 416(%rdi), %ymm4, %ymm4
vpxor %ymm4, %ymm0, %ymm0


##### step 168 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_168

._step_168_end:
vpxor %ymm10, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 169 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_169

._step_169_end:
vpxor %ymm11, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 170 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_170

._step_170_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 171 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_171

._step_171_end:
vpxor %ymm12, %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step 172 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_172

._step_172_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 173 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_173

._step_173_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 174 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_174

._step_174_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 175 : Fl[0] ^= (Fl[5] ^= Fq[14])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_175

._step_175_end:
vpxor 448(%rdi), %ymm5, %ymm5
vpxor %ymm5, %ymm0, %ymm0


##### step 176 : Fl[0] ^= (Fl[1] ^= Fq[6])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_176

._step_176_end:
vpxor 192(%rdi), %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 177 : Fl[0] ^= (Fl[2] ^= Fq[7])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_177

._step_177_end:
vpxor 224(%rdi), %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 178 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_178

._step_178_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 179 : Fl[0] ^= (Fl[3] ^= Fq[8])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_179

._step_179_end:
vpxor %ymm13, %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step 180 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_180

._step_180_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 181 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_181

._step_181_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 182 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_182

._step_182_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 183 : Fl[0] ^= (Fl[4] ^= Fq[9])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_183

._step_183_end:
vpxor 288(%rdi), %ymm4, %ymm4
vpxor %ymm4, %ymm0, %ymm0


##### step 184 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_184

._step_184_end:
vpxor %ymm10, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 185 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_185

._step_185_end:
vpxor %ymm11, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 186 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_186

._step_186_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 187 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_187

._step_187_end:
vpxor %ymm12, %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step 188 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_188

._step_188_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 189 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_189

._step_189_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 190 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_190

._step_190_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 191 : Fl[0] ^= (Fl[7] ^= Fq[27])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_191

._step_191_end:
vmovdqa 224(%rsi), %ymm14
vpxor 864(%rdi), %ymm14, %ymm14
vmovdqa %ymm14, 224(%rsi)
vpxor %ymm14, %ymm0, %ymm0


##### step 192 : Fl[0] ^= (Fl[1] ^= Fq[15])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_192

._step_192_end:
vpxor 480(%rdi), %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 193 : Fl[0] ^= (Fl[2] ^= Fq[16])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_193

._step_193_end:
vpxor 512(%rdi), %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 194 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_194

._step_194_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 195 : Fl[0] ^= (Fl[3] ^= Fq[17])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_195

._step_195_end:
vpxor 544(%rdi), %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step 196 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_196

._step_196_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 197 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_197

._step_197_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 198 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_198

._step_198_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 199 : Fl[0] ^= (Fl[4] ^= Fq[18])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_199

._step_199_end:
vpxor 576(%rdi), %ymm4, %ymm4
vpxor %ymm4, %ymm0, %ymm0


##### step 200 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_200

._step_200_end:
vpxor %ymm10, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 201 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_201

._step_201_end:
vpxor %ymm11, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 202 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_202

._step_202_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 203 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_203

._step_203_end:
vpxor %ymm12, %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step 204 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_204

._step_204_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 205 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_205

._step_205_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 206 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_206

._step_206_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 207 : Fl[0] ^= (Fl[5] ^= Fq[19])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_207

._step_207_end:
vpxor 608(%rdi), %ymm5, %ymm5
vpxor %ymm5, %ymm0, %ymm0


##### step 208 : Fl[0] ^= (Fl[1] ^= Fq[6])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_208

._step_208_end:
vpxor 192(%rdi), %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 209 : Fl[0] ^= (Fl[2] ^= Fq[7])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_209

._step_209_end:
vpxor 224(%rdi), %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 210 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_210

._step_210_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 211 : Fl[0] ^= (Fl[3] ^= Fq[8])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_211

._step_211_end:
vpxor %ymm13, %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step 212 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_212

._step_212_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 213 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_213

._step_213_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 214 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_214

._step_214_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 215 : Fl[0] ^= (Fl[4] ^= Fq[9])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_215

._step_215_end:
vpxor 288(%rdi), %ymm4, %ymm4
vpxor %ymm4, %ymm0, %ymm0


##### step 216 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_216

._step_216_end:
vpxor %ymm10, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 217 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_217

._step_217_end:
vpxor %ymm11, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 218 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_218

._step_218_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 219 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_219

._step_219_end:
vpxor %ymm12, %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step 220 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_220

._step_220_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 221 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_221

._step_221_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 222 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_222

._step_222_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 223 : Fl[0] ^= (Fl[6] ^= Fq[20])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_223

._step_223_end:
vpxor 640(%rdi), %ymm6, %ymm6
vpxor %ymm6, %ymm0, %ymm0


##### step 224 : Fl[0] ^= (Fl[1] ^= Fq[10])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_224

._step_224_end:
vpxor 320(%rdi), %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 225 : Fl[0] ^= (Fl[2] ^= Fq[11])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_225

._step_225_end:
vpxor 352(%rdi), %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 226 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_226

._step_226_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 227 : Fl[0] ^= (Fl[3] ^= Fq[12])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_227

._step_227_end:
vpxor 384(%rdi), %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step 228 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_228

._step_228_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 229 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_229

._step_229_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 230 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_230

._step_230_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 231 : Fl[0] ^= (Fl[4] ^= Fq[13])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_231

._step_231_end:
vpxor 416(%rdi), %ymm4, %ymm4
vpxor %ymm4, %ymm0, %ymm0


##### step 232 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_232

._step_232_end:
vpxor %ymm10, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 233 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_233

._step_233_end:
vpxor %ymm11, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 234 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_234

._step_234_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 235 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_235

._step_235_end:
vpxor %ymm12, %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step 236 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_236

._step_236_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 237 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_237

._step_237_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 238 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_238

._step_238_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 239 : Fl[0] ^= (Fl[5] ^= Fq[14])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_239

._step_239_end:
vpxor 448(%rdi), %ymm5, %ymm5
vpxor %ymm5, %ymm0, %ymm0


##### step 240 : Fl[0] ^= (Fl[1] ^= Fq[6])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_240

._step_240_end:
vpxor 192(%rdi), %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 241 : Fl[0] ^= (Fl[2] ^= Fq[7])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_241

._step_241_end:
vpxor 224(%rdi), %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 242 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_242

._step_242_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 243 : Fl[0] ^= (Fl[3] ^= Fq[8])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_243

._step_243_end:
vpxor %ymm13, %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step 244 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_244

._step_244_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 245 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_245

._step_245_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 246 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_246

._step_246_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 247 : Fl[0] ^= (Fl[4] ^= Fq[9])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_247

._step_247_end:
vpxor 288(%rdi), %ymm4, %ymm4
vpxor %ymm4, %ymm0, %ymm0


##### step 248 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_248

._step_248_end:
vpxor %ymm10, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 249 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_249

._step_249_end:
vpxor %ymm11, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 250 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_250

._step_250_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 251 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_251

._step_251_end:
vpxor %ymm12, %ymm3, %ymm3
vpxor %ymm3, %ymm0, %ymm0


##### step 252 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_252

._step_252_end:
vpxor %ymm8, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0


##### step 253 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_253

._step_253_end:
vpxor %ymm9, %ymm2, %ymm2
vpxor %ymm2, %ymm0, %ymm0


##### step 254 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_254

._step_254_end:
vpxor %ymm7, %ymm1, %ymm1
vpxor %ymm1, %ymm0, %ymm0

#############################
# end of the unrolled chunk #
#############################

# Save the Fl[1:] back to memory
vmovdqa %ymm1, 32(%rsi)     #Fl[1] <-- %ymm1
vmovdqa %ymm2, 64(%rsi)     #Fl[2] <-- %ymm2
vmovdqa %ymm3, 96(%rsi)     #Fl[3] <-- %ymm3
vmovdqa %ymm4, 128(%rsi)     #Fl[4] <-- %ymm4
vmovdqa %ymm5, 160(%rsi)     #Fl[5] <-- %ymm5
vmovdqa %ymm6, 192(%rsi)     #Fl[6] <-- %ymm6

##### special last step 255 : Fl[0] ^= (Fl[beta] ^= Fq[gamma])

vpcmpeqw %ymm0, %ymm15, %ymm15
vpmovmskb %ymm15, %r11d
test %r11d, %r11d
jne ._report_solution_255

._step_255_end:
vmovdqa (%rsi, %rcx), %ymm14
vpxor (%rdi, %r8), %ymm14, %ymm14
vmovdqa %ymm14, (%rsi, %rcx)
vpxor %ymm14, %ymm0, %ymm0

# Save Fl[0] back to memory
vmovdqa %ymm0, (%rsi)     #Fl[0] <-- %ymm0

ret


########### now the code that reports solutions

._report_solution_0:          # GrayCode(i + 0) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $0,  0(%rax)             # buffer.x = 0
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_0_end

._report_solution_1:          # GrayCode(i + 1) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $1,  0(%rax)             # buffer.x = 1
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_1_end

._report_solution_2:          # GrayCode(i + 2) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $2,  0(%rax)             # buffer.x = 2
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_2_end

._report_solution_3:          # GrayCode(i + 3) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $3,  0(%rax)             # buffer.x = 3
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_3_end

._report_solution_4:          # GrayCode(i + 4) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $4,  0(%rax)             # buffer.x = 4
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_4_end

._report_solution_5:          # GrayCode(i + 5) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $5,  0(%rax)             # buffer.x = 5
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_5_end

._report_solution_6:          # GrayCode(i + 6) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $6,  0(%rax)             # buffer.x = 6
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_6_end

._report_solution_7:          # GrayCode(i + 7) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $7,  0(%rax)             # buffer.x = 7
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_7_end

._report_solution_8:          # GrayCode(i + 8) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $8,  0(%rax)             # buffer.x = 8
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_8_end

._report_solution_9:          # GrayCode(i + 9) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $9,  0(%rax)             # buffer.x = 9
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_9_end

._report_solution_10:          # GrayCode(i + 10) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $10,  0(%rax)             # buffer.x = 10
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_10_end

._report_solution_11:          # GrayCode(i + 11) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $11,  0(%rax)             # buffer.x = 11
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_11_end

._report_solution_12:          # GrayCode(i + 12) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $12,  0(%rax)             # buffer.x = 12
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_12_end

._report_solution_13:          # GrayCode(i + 13) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $13,  0(%rax)             # buffer.x = 13
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_13_end

._report_solution_14:          # GrayCode(i + 14) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $14,  0(%rax)             # buffer.x = 14
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_14_end

._report_solution_15:          # GrayCode(i + 15) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $15,  0(%rax)             # buffer.x = 15
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_15_end

._report_solution_16:          # GrayCode(i + 16) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $16,  0(%rax)             # buffer.x = 16
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_16_end

._report_solution_17:          # GrayCode(i + 17) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $17,  0(%rax)             # buffer.x = 17
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_17_end

._report_solution_18:          # GrayCode(i + 18) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $18,  0(%rax)             # buffer.x = 18
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_18_end

._report_solution_19:          # GrayCode(i + 19) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $19,  0(%rax)             # buffer.x = 19
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_19_end

._report_solution_20:          # GrayCode(i + 20) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $20,  0(%rax)             # buffer.x = 20
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_20_end

._report_solution_21:          # GrayCode(i + 21) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $21,  0(%rax)             # buffer.x = 21
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_21_end

._report_solution_22:          # GrayCode(i + 22) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $22,  0(%rax)             # buffer.x = 22
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_22_end

._report_solution_23:          # GrayCode(i + 23) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $23,  0(%rax)             # buffer.x = 23
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_23_end

._report_solution_24:          # GrayCode(i + 24) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $24,  0(%rax)             # buffer.x = 24
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_24_end

._report_solution_25:          # GrayCode(i + 25) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $25,  0(%rax)             # buffer.x = 25
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_25_end

._report_solution_26:          # GrayCode(i + 26) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $26,  0(%rax)             # buffer.x = 26
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_26_end

._report_solution_27:          # GrayCode(i + 27) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $27,  0(%rax)             # buffer.x = 27
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_27_end

._report_solution_28:          # GrayCode(i + 28) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $28,  0(%rax)             # buffer.x = 28
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_28_end

._report_solution_29:          # GrayCode(i + 29) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $29,  0(%rax)             # buffer.x = 29
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_29_end

._report_solution_30:          # GrayCode(i + 30) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $30,  0(%rax)             # buffer.x = 30
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_30_end

._report_solution_31:          # GrayCode(i + 31) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $31,  0(%rax)             # buffer.x = 31
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_31_end

._report_solution_32:          # GrayCode(i + 32) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $32,  0(%rax)             # buffer.x = 32
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_32_end

._report_solution_33:          # GrayCode(i + 33) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $33,  0(%rax)             # buffer.x = 33
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_33_end

._report_solution_34:          # GrayCode(i + 34) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $34,  0(%rax)             # buffer.x = 34
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_34_end

._report_solution_35:          # GrayCode(i + 35) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $35,  0(%rax)             # buffer.x = 35
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_35_end

._report_solution_36:          # GrayCode(i + 36) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $36,  0(%rax)             # buffer.x = 36
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_36_end

._report_solution_37:          # GrayCode(i + 37) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $37,  0(%rax)             # buffer.x = 37
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_37_end

._report_solution_38:          # GrayCode(i + 38) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $38,  0(%rax)             # buffer.x = 38
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_38_end

._report_solution_39:          # GrayCode(i + 39) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $39,  0(%rax)             # buffer.x = 39
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_39_end

._report_solution_40:          # GrayCode(i + 40) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $40,  0(%rax)             # buffer.x = 40
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_40_end

._report_solution_41:          # GrayCode(i + 41) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $41,  0(%rax)             # buffer.x = 41
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_41_end

._report_solution_42:          # GrayCode(i + 42) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $42,  0(%rax)             # buffer.x = 42
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_42_end

._report_solution_43:          # GrayCode(i + 43) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $43,  0(%rax)             # buffer.x = 43
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_43_end

._report_solution_44:          # GrayCode(i + 44) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $44,  0(%rax)             # buffer.x = 44
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_44_end

._report_solution_45:          # GrayCode(i + 45) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $45,  0(%rax)             # buffer.x = 45
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_45_end

._report_solution_46:          # GrayCode(i + 46) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $46,  0(%rax)             # buffer.x = 46
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_46_end

._report_solution_47:          # GrayCode(i + 47) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $47,  0(%rax)             # buffer.x = 47
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_47_end

._report_solution_48:          # GrayCode(i + 48) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $48,  0(%rax)             # buffer.x = 48
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_48_end

._report_solution_49:          # GrayCode(i + 49) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $49,  0(%rax)             # buffer.x = 49
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_49_end

._report_solution_50:          # GrayCode(i + 50) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $50,  0(%rax)             # buffer.x = 50
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_50_end

._report_solution_51:          # GrayCode(i + 51) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $51,  0(%rax)             # buffer.x = 51
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_51_end

._report_solution_52:          # GrayCode(i + 52) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $52,  0(%rax)             # buffer.x = 52
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_52_end

._report_solution_53:          # GrayCode(i + 53) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $53,  0(%rax)             # buffer.x = 53
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_53_end

._report_solution_54:          # GrayCode(i + 54) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $54,  0(%rax)             # buffer.x = 54
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_54_end

._report_solution_55:          # GrayCode(i + 55) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $55,  0(%rax)             # buffer.x = 55
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_55_end

._report_solution_56:          # GrayCode(i + 56) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $56,  0(%rax)             # buffer.x = 56
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_56_end

._report_solution_57:          # GrayCode(i + 57) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $57,  0(%rax)             # buffer.x = 57
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_57_end

._report_solution_58:          # GrayCode(i + 58) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $58,  0(%rax)             # buffer.x = 58
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_58_end

._report_solution_59:          # GrayCode(i + 59) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $59,  0(%rax)             # buffer.x = 59
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_59_end

._report_solution_60:          # GrayCode(i + 60) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $60,  0(%rax)             # buffer.x = 60
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_60_end

._report_solution_61:          # GrayCode(i + 61) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $61,  0(%rax)             # buffer.x = 61
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_61_end

._report_solution_62:          # GrayCode(i + 62) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $62,  0(%rax)             # buffer.x = 62
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_62_end

._report_solution_63:          # GrayCode(i + 63) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $63,  0(%rax)             # buffer.x = 63
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_63_end

._report_solution_64:          # GrayCode(i + 64) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $64,  0(%rax)             # buffer.x = 64
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_64_end

._report_solution_65:          # GrayCode(i + 65) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $65,  0(%rax)             # buffer.x = 65
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_65_end

._report_solution_66:          # GrayCode(i + 66) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $66,  0(%rax)             # buffer.x = 66
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_66_end

._report_solution_67:          # GrayCode(i + 67) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $67,  0(%rax)             # buffer.x = 67
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_67_end

._report_solution_68:          # GrayCode(i + 68) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $68,  0(%rax)             # buffer.x = 68
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_68_end

._report_solution_69:          # GrayCode(i + 69) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $69,  0(%rax)             # buffer.x = 69
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_69_end

._report_solution_70:          # GrayCode(i + 70) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $70,  0(%rax)             # buffer.x = 70
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_70_end

._report_solution_71:          # GrayCode(i + 71) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $71,  0(%rax)             # buffer.x = 71
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_71_end

._report_solution_72:          # GrayCode(i + 72) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $72,  0(%rax)             # buffer.x = 72
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_72_end

._report_solution_73:          # GrayCode(i + 73) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $73,  0(%rax)             # buffer.x = 73
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_73_end

._report_solution_74:          # GrayCode(i + 74) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $74,  0(%rax)             # buffer.x = 74
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_74_end

._report_solution_75:          # GrayCode(i + 75) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $75,  0(%rax)             # buffer.x = 75
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_75_end

._report_solution_76:          # GrayCode(i + 76) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $76,  0(%rax)             # buffer.x = 76
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_76_end

._report_solution_77:          # GrayCode(i + 77) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $77,  0(%rax)             # buffer.x = 77
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_77_end

._report_solution_78:          # GrayCode(i + 78) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $78,  0(%rax)             # buffer.x = 78
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_78_end

._report_solution_79:          # GrayCode(i + 79) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $79,  0(%rax)             # buffer.x = 79
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_79_end

._report_solution_80:          # GrayCode(i + 80) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $80,  0(%rax)             # buffer.x = 80
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_80_end

._report_solution_81:          # GrayCode(i + 81) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $81,  0(%rax)             # buffer.x = 81
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_81_end

._report_solution_82:          # GrayCode(i + 82) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $82,  0(%rax)             # buffer.x = 82
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_82_end

._report_solution_83:          # GrayCode(i + 83) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $83,  0(%rax)             # buffer.x = 83
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_83_end

._report_solution_84:          # GrayCode(i + 84) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $84,  0(%rax)             # buffer.x = 84
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_84_end

._report_solution_85:          # GrayCode(i + 85) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $85,  0(%rax)             # buffer.x = 85
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_85_end

._report_solution_86:          # GrayCode(i + 86) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $86,  0(%rax)             # buffer.x = 86
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_86_end

._report_solution_87:          # GrayCode(i + 87) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $87,  0(%rax)             # buffer.x = 87
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_87_end

._report_solution_88:          # GrayCode(i + 88) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $88,  0(%rax)             # buffer.x = 88
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_88_end

._report_solution_89:          # GrayCode(i + 89) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $89,  0(%rax)             # buffer.x = 89
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_89_end

._report_solution_90:          # GrayCode(i + 90) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $90,  0(%rax)             # buffer.x = 90
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_90_end

._report_solution_91:          # GrayCode(i + 91) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $91,  0(%rax)             # buffer.x = 91
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_91_end

._report_solution_92:          # GrayCode(i + 92) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $92,  0(%rax)             # buffer.x = 92
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_92_end

._report_solution_93:          # GrayCode(i + 93) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $93,  0(%rax)             # buffer.x = 93
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_93_end

._report_solution_94:          # GrayCode(i + 94) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $94,  0(%rax)             # buffer.x = 94
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_94_end

._report_solution_95:          # GrayCode(i + 95) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $95,  0(%rax)             # buffer.x = 95
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_95_end

._report_solution_96:          # GrayCode(i + 96) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $96,  0(%rax)             # buffer.x = 96
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_96_end

._report_solution_97:          # GrayCode(i + 97) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $97,  0(%rax)             # buffer.x = 97
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_97_end

._report_solution_98:          # GrayCode(i + 98) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $98,  0(%rax)             # buffer.x = 98
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_98_end

._report_solution_99:          # GrayCode(i + 99) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $99,  0(%rax)             # buffer.x = 99
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_99_end

._report_solution_100:          # GrayCode(i + 100) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $100,  0(%rax)             # buffer.x = 100
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_100_end

._report_solution_101:          # GrayCode(i + 101) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $101,  0(%rax)             # buffer.x = 101
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_101_end

._report_solution_102:          # GrayCode(i + 102) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $102,  0(%rax)             # buffer.x = 102
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_102_end

._report_solution_103:          # GrayCode(i + 103) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $103,  0(%rax)             # buffer.x = 103
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_103_end

._report_solution_104:          # GrayCode(i + 104) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $104,  0(%rax)             # buffer.x = 104
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_104_end

._report_solution_105:          # GrayCode(i + 105) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $105,  0(%rax)             # buffer.x = 105
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_105_end

._report_solution_106:          # GrayCode(i + 106) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $106,  0(%rax)             # buffer.x = 106
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_106_end

._report_solution_107:          # GrayCode(i + 107) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $107,  0(%rax)             # buffer.x = 107
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_107_end

._report_solution_108:          # GrayCode(i + 108) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $108,  0(%rax)             # buffer.x = 108
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_108_end

._report_solution_109:          # GrayCode(i + 109) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $109,  0(%rax)             # buffer.x = 109
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_109_end

._report_solution_110:          # GrayCode(i + 110) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $110,  0(%rax)             # buffer.x = 110
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_110_end

._report_solution_111:          # GrayCode(i + 111) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $111,  0(%rax)             # buffer.x = 111
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_111_end

._report_solution_112:          # GrayCode(i + 112) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $112,  0(%rax)             # buffer.x = 112
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_112_end

._report_solution_113:          # GrayCode(i + 113) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $113,  0(%rax)             # buffer.x = 113
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_113_end

._report_solution_114:          # GrayCode(i + 114) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $114,  0(%rax)             # buffer.x = 114
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_114_end

._report_solution_115:          # GrayCode(i + 115) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $115,  0(%rax)             # buffer.x = 115
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_115_end

._report_solution_116:          # GrayCode(i + 116) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $116,  0(%rax)             # buffer.x = 116
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_116_end

._report_solution_117:          # GrayCode(i + 117) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $117,  0(%rax)             # buffer.x = 117
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_117_end

._report_solution_118:          # GrayCode(i + 118) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $118,  0(%rax)             # buffer.x = 118
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_118_end

._report_solution_119:          # GrayCode(i + 119) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $119,  0(%rax)             # buffer.x = 119
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_119_end

._report_solution_120:          # GrayCode(i + 120) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $120,  0(%rax)             # buffer.x = 120
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_120_end

._report_solution_121:          # GrayCode(i + 121) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $121,  0(%rax)             # buffer.x = 121
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_121_end

._report_solution_122:          # GrayCode(i + 122) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $122,  0(%rax)             # buffer.x = 122
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_122_end

._report_solution_123:          # GrayCode(i + 123) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $123,  0(%rax)             # buffer.x = 123
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_123_end

._report_solution_124:          # GrayCode(i + 124) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $124,  0(%rax)             # buffer.x = 124
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_124_end

._report_solution_125:          # GrayCode(i + 125) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $125,  0(%rax)             # buffer.x = 125
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_125_end

._report_solution_126:          # GrayCode(i + 126) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $126,  0(%rax)             # buffer.x = 126
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_126_end

._report_solution_127:          # GrayCode(i + 127) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $127,  0(%rax)             # buffer.x = 127
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_127_end

._report_solution_128:          # GrayCode(i + 128) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $128,  0(%rax)             # buffer.x = 128
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_128_end

._report_solution_129:          # GrayCode(i + 129) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $129,  0(%rax)             # buffer.x = 129
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_129_end

._report_solution_130:          # GrayCode(i + 130) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $130,  0(%rax)             # buffer.x = 130
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_130_end

._report_solution_131:          # GrayCode(i + 131) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $131,  0(%rax)             # buffer.x = 131
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_131_end

._report_solution_132:          # GrayCode(i + 132) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $132,  0(%rax)             # buffer.x = 132
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_132_end

._report_solution_133:          # GrayCode(i + 133) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $133,  0(%rax)             # buffer.x = 133
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_133_end

._report_solution_134:          # GrayCode(i + 134) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $134,  0(%rax)             # buffer.x = 134
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_134_end

._report_solution_135:          # GrayCode(i + 135) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $135,  0(%rax)             # buffer.x = 135
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_135_end

._report_solution_136:          # GrayCode(i + 136) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $136,  0(%rax)             # buffer.x = 136
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_136_end

._report_solution_137:          # GrayCode(i + 137) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $137,  0(%rax)             # buffer.x = 137
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_137_end

._report_solution_138:          # GrayCode(i + 138) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $138,  0(%rax)             # buffer.x = 138
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_138_end

._report_solution_139:          # GrayCode(i + 139) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $139,  0(%rax)             # buffer.x = 139
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_139_end

._report_solution_140:          # GrayCode(i + 140) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $140,  0(%rax)             # buffer.x = 140
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_140_end

._report_solution_141:          # GrayCode(i + 141) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $141,  0(%rax)             # buffer.x = 141
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_141_end

._report_solution_142:          # GrayCode(i + 142) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $142,  0(%rax)             # buffer.x = 142
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_142_end

._report_solution_143:          # GrayCode(i + 143) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $143,  0(%rax)             # buffer.x = 143
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_143_end

._report_solution_144:          # GrayCode(i + 144) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $144,  0(%rax)             # buffer.x = 144
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_144_end

._report_solution_145:          # GrayCode(i + 145) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $145,  0(%rax)             # buffer.x = 145
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_145_end

._report_solution_146:          # GrayCode(i + 146) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $146,  0(%rax)             # buffer.x = 146
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_146_end

._report_solution_147:          # GrayCode(i + 147) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $147,  0(%rax)             # buffer.x = 147
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_147_end

._report_solution_148:          # GrayCode(i + 148) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $148,  0(%rax)             # buffer.x = 148
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_148_end

._report_solution_149:          # GrayCode(i + 149) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $149,  0(%rax)             # buffer.x = 149
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_149_end

._report_solution_150:          # GrayCode(i + 150) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $150,  0(%rax)             # buffer.x = 150
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_150_end

._report_solution_151:          # GrayCode(i + 151) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $151,  0(%rax)             # buffer.x = 151
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_151_end

._report_solution_152:          # GrayCode(i + 152) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $152,  0(%rax)             # buffer.x = 152
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_152_end

._report_solution_153:          # GrayCode(i + 153) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $153,  0(%rax)             # buffer.x = 153
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_153_end

._report_solution_154:          # GrayCode(i + 154) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $154,  0(%rax)             # buffer.x = 154
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_154_end

._report_solution_155:          # GrayCode(i + 155) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $155,  0(%rax)             # buffer.x = 155
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_155_end

._report_solution_156:          # GrayCode(i + 156) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $156,  0(%rax)             # buffer.x = 156
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_156_end

._report_solution_157:          # GrayCode(i + 157) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $157,  0(%rax)             # buffer.x = 157
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_157_end

._report_solution_158:          # GrayCode(i + 158) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $158,  0(%rax)             # buffer.x = 158
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_158_end

._report_solution_159:          # GrayCode(i + 159) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $159,  0(%rax)             # buffer.x = 159
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_159_end

._report_solution_160:          # GrayCode(i + 160) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $160,  0(%rax)             # buffer.x = 160
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_160_end

._report_solution_161:          # GrayCode(i + 161) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $161,  0(%rax)             # buffer.x = 161
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_161_end

._report_solution_162:          # GrayCode(i + 162) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $162,  0(%rax)             # buffer.x = 162
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_162_end

._report_solution_163:          # GrayCode(i + 163) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $163,  0(%rax)             # buffer.x = 163
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_163_end

._report_solution_164:          # GrayCode(i + 164) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $164,  0(%rax)             # buffer.x = 164
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_164_end

._report_solution_165:          # GrayCode(i + 165) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $165,  0(%rax)             # buffer.x = 165
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_165_end

._report_solution_166:          # GrayCode(i + 166) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $166,  0(%rax)             # buffer.x = 166
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_166_end

._report_solution_167:          # GrayCode(i + 167) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $167,  0(%rax)             # buffer.x = 167
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_167_end

._report_solution_168:          # GrayCode(i + 168) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $168,  0(%rax)             # buffer.x = 168
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_168_end

._report_solution_169:          # GrayCode(i + 169) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $169,  0(%rax)             # buffer.x = 169
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_169_end

._report_solution_170:          # GrayCode(i + 170) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $170,  0(%rax)             # buffer.x = 170
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_170_end

._report_solution_171:          # GrayCode(i + 171) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $171,  0(%rax)             # buffer.x = 171
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_171_end

._report_solution_172:          # GrayCode(i + 172) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $172,  0(%rax)             # buffer.x = 172
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_172_end

._report_solution_173:          # GrayCode(i + 173) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $173,  0(%rax)             # buffer.x = 173
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_173_end

._report_solution_174:          # GrayCode(i + 174) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $174,  0(%rax)             # buffer.x = 174
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_174_end

._report_solution_175:          # GrayCode(i + 175) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $175,  0(%rax)             # buffer.x = 175
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_175_end

._report_solution_176:          # GrayCode(i + 176) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $176,  0(%rax)             # buffer.x = 176
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_176_end

._report_solution_177:          # GrayCode(i + 177) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $177,  0(%rax)             # buffer.x = 177
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_177_end

._report_solution_178:          # GrayCode(i + 178) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $178,  0(%rax)             # buffer.x = 178
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_178_end

._report_solution_179:          # GrayCode(i + 179) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $179,  0(%rax)             # buffer.x = 179
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_179_end

._report_solution_180:          # GrayCode(i + 180) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $180,  0(%rax)             # buffer.x = 180
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_180_end

._report_solution_181:          # GrayCode(i + 181) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $181,  0(%rax)             # buffer.x = 181
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_181_end

._report_solution_182:          # GrayCode(i + 182) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $182,  0(%rax)             # buffer.x = 182
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_182_end

._report_solution_183:          # GrayCode(i + 183) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $183,  0(%rax)             # buffer.x = 183
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_183_end

._report_solution_184:          # GrayCode(i + 184) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $184,  0(%rax)             # buffer.x = 184
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_184_end

._report_solution_185:          # GrayCode(i + 185) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $185,  0(%rax)             # buffer.x = 185
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_185_end

._report_solution_186:          # GrayCode(i + 186) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $186,  0(%rax)             # buffer.x = 186
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_186_end

._report_solution_187:          # GrayCode(i + 187) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $187,  0(%rax)             # buffer.x = 187
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_187_end

._report_solution_188:          # GrayCode(i + 188) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $188,  0(%rax)             # buffer.x = 188
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_188_end

._report_solution_189:          # GrayCode(i + 189) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $189,  0(%rax)             # buffer.x = 189
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_189_end

._report_solution_190:          # GrayCode(i + 190) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $190,  0(%rax)             # buffer.x = 190
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_190_end

._report_solution_191:          # GrayCode(i + 191) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $191,  0(%rax)             # buffer.x = 191
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_191_end

._report_solution_192:          # GrayCode(i + 192) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $192,  0(%rax)             # buffer.x = 192
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_192_end

._report_solution_193:          # GrayCode(i + 193) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $193,  0(%rax)             # buffer.x = 193
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_193_end

._report_solution_194:          # GrayCode(i + 194) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $194,  0(%rax)             # buffer.x = 194
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_194_end

._report_solution_195:          # GrayCode(i + 195) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $195,  0(%rax)             # buffer.x = 195
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_195_end

._report_solution_196:          # GrayCode(i + 196) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $196,  0(%rax)             # buffer.x = 196
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_196_end

._report_solution_197:          # GrayCode(i + 197) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $197,  0(%rax)             # buffer.x = 197
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_197_end

._report_solution_198:          # GrayCode(i + 198) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $198,  0(%rax)             # buffer.x = 198
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_198_end

._report_solution_199:          # GrayCode(i + 199) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $199,  0(%rax)             # buffer.x = 199
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_199_end

._report_solution_200:          # GrayCode(i + 200) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $200,  0(%rax)             # buffer.x = 200
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_200_end

._report_solution_201:          # GrayCode(i + 201) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $201,  0(%rax)             # buffer.x = 201
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_201_end

._report_solution_202:          # GrayCode(i + 202) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $202,  0(%rax)             # buffer.x = 202
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_202_end

._report_solution_203:          # GrayCode(i + 203) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $203,  0(%rax)             # buffer.x = 203
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_203_end

._report_solution_204:          # GrayCode(i + 204) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $204,  0(%rax)             # buffer.x = 204
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_204_end

._report_solution_205:          # GrayCode(i + 205) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $205,  0(%rax)             # buffer.x = 205
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_205_end

._report_solution_206:          # GrayCode(i + 206) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $206,  0(%rax)             # buffer.x = 206
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_206_end

._report_solution_207:          # GrayCode(i + 207) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $207,  0(%rax)             # buffer.x = 207
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_207_end

._report_solution_208:          # GrayCode(i + 208) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $208,  0(%rax)             # buffer.x = 208
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_208_end

._report_solution_209:          # GrayCode(i + 209) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $209,  0(%rax)             # buffer.x = 209
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_209_end

._report_solution_210:          # GrayCode(i + 210) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $210,  0(%rax)             # buffer.x = 210
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_210_end

._report_solution_211:          # GrayCode(i + 211) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $211,  0(%rax)             # buffer.x = 211
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_211_end

._report_solution_212:          # GrayCode(i + 212) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $212,  0(%rax)             # buffer.x = 212
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_212_end

._report_solution_213:          # GrayCode(i + 213) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $213,  0(%rax)             # buffer.x = 213
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_213_end

._report_solution_214:          # GrayCode(i + 214) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $214,  0(%rax)             # buffer.x = 214
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_214_end

._report_solution_215:          # GrayCode(i + 215) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $215,  0(%rax)             # buffer.x = 215
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_215_end

._report_solution_216:          # GrayCode(i + 216) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $216,  0(%rax)             # buffer.x = 216
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_216_end

._report_solution_217:          # GrayCode(i + 217) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $217,  0(%rax)             # buffer.x = 217
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_217_end

._report_solution_218:          # GrayCode(i + 218) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $218,  0(%rax)             # buffer.x = 218
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_218_end

._report_solution_219:          # GrayCode(i + 219) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $219,  0(%rax)             # buffer.x = 219
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_219_end

._report_solution_220:          # GrayCode(i + 220) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $220,  0(%rax)             # buffer.x = 220
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_220_end

._report_solution_221:          # GrayCode(i + 221) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $221,  0(%rax)             # buffer.x = 221
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_221_end

._report_solution_222:          # GrayCode(i + 222) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $222,  0(%rax)             # buffer.x = 222
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_222_end

._report_solution_223:          # GrayCode(i + 223) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $223,  0(%rax)             # buffer.x = 223
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_223_end

._report_solution_224:          # GrayCode(i + 224) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $224,  0(%rax)             # buffer.x = 224
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_224_end

._report_solution_225:          # GrayCode(i + 225) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $225,  0(%rax)             # buffer.x = 225
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_225_end

._report_solution_226:          # GrayCode(i + 226) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $226,  0(%rax)             # buffer.x = 226
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_226_end

._report_solution_227:          # GrayCode(i + 227) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $227,  0(%rax)             # buffer.x = 227
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_227_end

._report_solution_228:          # GrayCode(i + 228) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $228,  0(%rax)             # buffer.x = 228
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_228_end

._report_solution_229:          # GrayCode(i + 229) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $229,  0(%rax)             # buffer.x = 229
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_229_end

._report_solution_230:          # GrayCode(i + 230) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $230,  0(%rax)             # buffer.x = 230
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_230_end

._report_solution_231:          # GrayCode(i + 231) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $231,  0(%rax)             # buffer.x = 231
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_231_end

._report_solution_232:          # GrayCode(i + 232) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $232,  0(%rax)             # buffer.x = 232
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_232_end

._report_solution_233:          # GrayCode(i + 233) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $233,  0(%rax)             # buffer.x = 233
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_233_end

._report_solution_234:          # GrayCode(i + 234) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $234,  0(%rax)             # buffer.x = 234
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_234_end

._report_solution_235:          # GrayCode(i + 235) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $235,  0(%rax)             # buffer.x = 235
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_235_end

._report_solution_236:          # GrayCode(i + 236) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $236,  0(%rax)             # buffer.x = 236
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_236_end

._report_solution_237:          # GrayCode(i + 237) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $237,  0(%rax)             # buffer.x = 237
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_237_end

._report_solution_238:          # GrayCode(i + 238) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $238,  0(%rax)             # buffer.x = 238
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_238_end

._report_solution_239:          # GrayCode(i + 239) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $239,  0(%rax)             # buffer.x = 239
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_239_end

._report_solution_240:          # GrayCode(i + 240) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $240,  0(%rax)             # buffer.x = 240
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_240_end

._report_solution_241:          # GrayCode(i + 241) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $241,  0(%rax)             # buffer.x = 241
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_241_end

._report_solution_242:          # GrayCode(i + 242) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $242,  0(%rax)             # buffer.x = 242
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_242_end

._report_solution_243:          # GrayCode(i + 243) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $243,  0(%rax)             # buffer.x = 243
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_243_end

._report_solution_244:          # GrayCode(i + 244) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $244,  0(%rax)             # buffer.x = 244
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_244_end

._report_solution_245:          # GrayCode(i + 245) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $245,  0(%rax)             # buffer.x = 245
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_245_end

._report_solution_246:          # GrayCode(i + 246) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $246,  0(%rax)             # buffer.x = 246
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_246_end

._report_solution_247:          # GrayCode(i + 247) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $247,  0(%rax)             # buffer.x = 247
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_247_end

._report_solution_248:          # GrayCode(i + 248) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $248,  0(%rax)             # buffer.x = 248
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_248_end

._report_solution_249:          # GrayCode(i + 249) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $249,  0(%rax)             # buffer.x = 249
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_249_end

._report_solution_250:          # GrayCode(i + 250) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $250,  0(%rax)             # buffer.x = 250
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_250_end

._report_solution_251:          # GrayCode(i + 251) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $251,  0(%rax)             # buffer.x = 251
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_251_end

._report_solution_252:          # GrayCode(i + 252) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $252,  0(%rax)             # buffer.x = 252
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_252_end

._report_solution_253:          # GrayCode(i + 253) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $253,  0(%rax)             # buffer.x = 253
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_253_end

._report_solution_254:          # GrayCode(i + 254) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $254,  0(%rax)             # buffer.x = 254
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_254_end

._report_solution_255:          # GrayCode(i + 255) is a solution
vpxor %ymm15, %ymm15, %ymm15    # reset %ymm15 to zero
movl $255,  0(%rax)             # buffer.x = 255
movl %r11d, 4(%rax)             # buffer.mask = %r11
addq $8, %rax                   # buffer++
jmp ._step_255_end

