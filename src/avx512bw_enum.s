
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


# load the most-frequently used values into vector registers
vmovdqa32 0(%rsi), %zmm0   ## %zmm0 = Fl[0]
vmovdqa32 64(%rsi), %zmm1   ## %zmm1 = Fl[1]
vmovdqa32 128(%rsi), %zmm2   ## %zmm2 = Fl[2]
vmovdqa32 192(%rsi), %zmm3   ## %zmm3 = Fl[3]
vmovdqa32 256(%rsi), %zmm4   ## %zmm4 = Fl[4]
vmovdqa32 320(%rsi), %zmm5   ## %zmm5 = Fl[5]
vmovdqa32 384(%rsi), %zmm6   ## %zmm6 = Fl[6]
vmovdqa32 448(%rsi), %zmm7   ## %zmm7 = Fl[7]
vmovdqa32 512(%rsi), %zmm8   ## %zmm8 = Fl[8]

vmovdqa32 0(%rdi), %zmm9   ## %zmm9 = Fq[0]
vmovdqa32 64(%rdi), %zmm10   ## %zmm10 = Fq[1]
vmovdqa32 128(%rdi), %zmm11   ## %zmm11 = Fq[2]
vmovdqa32 192(%rdi), %zmm12   ## %zmm12 = Fq[3]
vmovdqa32 256(%rdi), %zmm13   ## %zmm13 = Fq[4]
vmovdqa32 320(%rdi), %zmm14   ## %zmm14 = Fq[5]
vmovdqa32 384(%rdi), %zmm15   ## %zmm15 = Fq[6]
vmovdqa32 448(%rdi), %zmm16   ## %zmm16 = Fq[7]
vmovdqa32 512(%rdi), %zmm17   ## %zmm17 = Fq[8]
vmovdqa32 576(%rdi), %zmm18   ## %zmm18 = Fq[9]
vmovdqa32 640(%rdi), %zmm19   ## %zmm19 = Fq[10]
vmovdqa32 704(%rdi), %zmm20   ## %zmm20 = Fq[11]
vmovdqa32 768(%rdi), %zmm21   ## %zmm21 = Fq[12]
vmovdqa32 832(%rdi), %zmm22   ## %zmm22 = Fq[13]
vmovdqa32 896(%rdi), %zmm23   ## %zmm23 = Fq[14]
vmovdqa32 960(%rdi), %zmm24   ## %zmm24 = Fq[15]
vmovdqa32 1024(%rdi), %zmm25   ## %zmm25 = Fq[16]
vmovdqa32 1088(%rdi), %zmm26   ## %zmm26 = Fq[17]
vmovdqa32 1152(%rdi), %zmm27   ## %zmm27 = Fq[18]
vmovdqa32 1216(%rdi), %zmm28   ## %zmm28 = Fq[19]
vmovdqa32 1280(%rdi), %zmm29   ## %zmm29 = Fq[20]


##### step   0 : Fl[0] ^= (Fl[1] ^= Fq[alpha + 0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_0

._step_0_end:
vpxord 0(%rdi, %rdx), %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step   1 : Fl[0] ^= (Fl[2] ^= Fq[alpha + 1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_1

._step_1_end:
vpxord 64(%rdi, %rdx), %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step   2 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_2

._step_2_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step   3 : Fl[0] ^= (Fl[3] ^= Fq[alpha + 2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_3

._step_3_end:
vpxord 128(%rdi, %rdx), %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step   4 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_4

._step_4_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step   5 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_5

._step_5_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step   6 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_6

._step_6_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step   7 : Fl[0] ^= (Fl[4] ^= Fq[alpha + 3])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_7

._step_7_end:
vpxord 192(%rdi, %rdx), %zmm4, %zmm4
vpxord %zmm4, %zmm0, %zmm0


##### step   8 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_8

._step_8_end:
vpxord %zmm12, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step   9 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_9

._step_9_end:
vpxord %zmm13, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step  10 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_10

._step_10_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  11 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_11

._step_11_end:
vpxord %zmm14, %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step  12 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_12

._step_12_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  13 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_13

._step_13_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step  14 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_14

._step_14_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  15 : Fl[0] ^= (Fl[5] ^= Fq[alpha + 4])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_15

._step_15_end:
vpxord 256(%rdi, %rdx), %zmm5, %zmm5
vpxord %zmm5, %zmm0, %zmm0


##### step  16 : Fl[0] ^= (Fl[1] ^= Fq[6])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_16

._step_16_end:
vpxord %zmm15, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  17 : Fl[0] ^= (Fl[2] ^= Fq[7])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_17

._step_17_end:
vpxord %zmm16, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step  18 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_18

._step_18_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  19 : Fl[0] ^= (Fl[3] ^= Fq[8])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_19

._step_19_end:
vpxord %zmm17, %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step  20 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_20

._step_20_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  21 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_21

._step_21_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step  22 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_22

._step_22_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  23 : Fl[0] ^= (Fl[4] ^= Fq[9])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_23

._step_23_end:
vpxord %zmm18, %zmm4, %zmm4
vpxord %zmm4, %zmm0, %zmm0


##### step  24 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_24

._step_24_end:
vpxord %zmm12, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  25 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_25

._step_25_end:
vpxord %zmm13, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step  26 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_26

._step_26_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  27 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_27

._step_27_end:
vpxord %zmm14, %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step  28 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_28

._step_28_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  29 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_29

._step_29_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step  30 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_30

._step_30_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  31 : Fl[0] ^= (Fl[6] ^= Fq[alpha + 5])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_31

._step_31_end:
vpxord 320(%rdi, %rdx), %zmm6, %zmm6
vpxord %zmm6, %zmm0, %zmm0


##### step  32 : Fl[0] ^= (Fl[1] ^= Fq[10])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_32

._step_32_end:
vpxord %zmm19, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  33 : Fl[0] ^= (Fl[2] ^= Fq[11])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_33

._step_33_end:
vpxord %zmm20, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step  34 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_34

._step_34_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  35 : Fl[0] ^= (Fl[3] ^= Fq[12])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_35

._step_35_end:
vpxord %zmm21, %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step  36 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_36

._step_36_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  37 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_37

._step_37_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step  38 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_38

._step_38_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  39 : Fl[0] ^= (Fl[4] ^= Fq[13])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_39

._step_39_end:
vpxord %zmm22, %zmm4, %zmm4
vpxord %zmm4, %zmm0, %zmm0


##### step  40 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_40

._step_40_end:
vpxord %zmm12, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  41 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_41

._step_41_end:
vpxord %zmm13, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step  42 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_42

._step_42_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  43 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_43

._step_43_end:
vpxord %zmm14, %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step  44 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_44

._step_44_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  45 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_45

._step_45_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step  46 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_46

._step_46_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  47 : Fl[0] ^= (Fl[5] ^= Fq[14])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_47

._step_47_end:
vpxord %zmm23, %zmm5, %zmm5
vpxord %zmm5, %zmm0, %zmm0


##### step  48 : Fl[0] ^= (Fl[1] ^= Fq[6])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_48

._step_48_end:
vpxord %zmm15, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  49 : Fl[0] ^= (Fl[2] ^= Fq[7])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_49

._step_49_end:
vpxord %zmm16, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step  50 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_50

._step_50_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  51 : Fl[0] ^= (Fl[3] ^= Fq[8])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_51

._step_51_end:
vpxord %zmm17, %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step  52 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_52

._step_52_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  53 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_53

._step_53_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step  54 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_54

._step_54_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  55 : Fl[0] ^= (Fl[4] ^= Fq[9])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_55

._step_55_end:
vpxord %zmm18, %zmm4, %zmm4
vpxord %zmm4, %zmm0, %zmm0


##### step  56 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_56

._step_56_end:
vpxord %zmm12, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  57 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_57

._step_57_end:
vpxord %zmm13, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step  58 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_58

._step_58_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  59 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_59

._step_59_end:
vpxord %zmm14, %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step  60 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_60

._step_60_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  61 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_61

._step_61_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step  62 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_62

._step_62_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  63 : Fl[0] ^= (Fl[7] ^= Fq[alpha + 6])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_63

._step_63_end:
vpxord 384(%rdi, %rdx), %zmm7, %zmm7
vpxord %zmm7, %zmm0, %zmm0


##### step  64 : Fl[0] ^= (Fl[1] ^= Fq[15])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_64

._step_64_end:
vpxord %zmm24, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  65 : Fl[0] ^= (Fl[2] ^= Fq[16])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_65

._step_65_end:
vpxord %zmm25, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step  66 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_66

._step_66_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  67 : Fl[0] ^= (Fl[3] ^= Fq[17])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_67

._step_67_end:
vpxord %zmm26, %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step  68 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_68

._step_68_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  69 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_69

._step_69_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step  70 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_70

._step_70_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  71 : Fl[0] ^= (Fl[4] ^= Fq[18])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_71

._step_71_end:
vpxord %zmm27, %zmm4, %zmm4
vpxord %zmm4, %zmm0, %zmm0


##### step  72 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_72

._step_72_end:
vpxord %zmm12, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  73 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_73

._step_73_end:
vpxord %zmm13, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step  74 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_74

._step_74_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  75 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_75

._step_75_end:
vpxord %zmm14, %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step  76 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_76

._step_76_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  77 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_77

._step_77_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step  78 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_78

._step_78_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  79 : Fl[0] ^= (Fl[5] ^= Fq[19])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_79

._step_79_end:
vpxord %zmm28, %zmm5, %zmm5
vpxord %zmm5, %zmm0, %zmm0


##### step  80 : Fl[0] ^= (Fl[1] ^= Fq[6])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_80

._step_80_end:
vpxord %zmm15, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  81 : Fl[0] ^= (Fl[2] ^= Fq[7])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_81

._step_81_end:
vpxord %zmm16, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step  82 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_82

._step_82_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  83 : Fl[0] ^= (Fl[3] ^= Fq[8])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_83

._step_83_end:
vpxord %zmm17, %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step  84 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_84

._step_84_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  85 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_85

._step_85_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step  86 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_86

._step_86_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  87 : Fl[0] ^= (Fl[4] ^= Fq[9])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_87

._step_87_end:
vpxord %zmm18, %zmm4, %zmm4
vpxord %zmm4, %zmm0, %zmm0


##### step  88 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_88

._step_88_end:
vpxord %zmm12, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  89 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_89

._step_89_end:
vpxord %zmm13, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step  90 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_90

._step_90_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  91 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_91

._step_91_end:
vpxord %zmm14, %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step  92 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_92

._step_92_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  93 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_93

._step_93_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step  94 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_94

._step_94_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  95 : Fl[0] ^= (Fl[6] ^= Fq[20])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_95

._step_95_end:
vpxord %zmm29, %zmm6, %zmm6
vpxord %zmm6, %zmm0, %zmm0


##### step  96 : Fl[0] ^= (Fl[1] ^= Fq[10])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_96

._step_96_end:
vpxord %zmm19, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  97 : Fl[0] ^= (Fl[2] ^= Fq[11])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_97

._step_97_end:
vpxord %zmm20, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step  98 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_98

._step_98_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step  99 : Fl[0] ^= (Fl[3] ^= Fq[12])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_99

._step_99_end:
vpxord %zmm21, %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step 100 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_100

._step_100_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 101 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_101

._step_101_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 102 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_102

._step_102_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 103 : Fl[0] ^= (Fl[4] ^= Fq[13])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_103

._step_103_end:
vpxord %zmm22, %zmm4, %zmm4
vpxord %zmm4, %zmm0, %zmm0


##### step 104 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_104

._step_104_end:
vpxord %zmm12, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 105 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_105

._step_105_end:
vpxord %zmm13, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 106 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_106

._step_106_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 107 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_107

._step_107_end:
vpxord %zmm14, %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step 108 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_108

._step_108_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 109 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_109

._step_109_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 110 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_110

._step_110_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 111 : Fl[0] ^= (Fl[5] ^= Fq[14])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_111

._step_111_end:
vpxord %zmm23, %zmm5, %zmm5
vpxord %zmm5, %zmm0, %zmm0


##### step 112 : Fl[0] ^= (Fl[1] ^= Fq[6])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_112

._step_112_end:
vpxord %zmm15, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 113 : Fl[0] ^= (Fl[2] ^= Fq[7])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_113

._step_113_end:
vpxord %zmm16, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 114 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_114

._step_114_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 115 : Fl[0] ^= (Fl[3] ^= Fq[8])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_115

._step_115_end:
vpxord %zmm17, %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step 116 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_116

._step_116_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 117 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_117

._step_117_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 118 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_118

._step_118_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 119 : Fl[0] ^= (Fl[4] ^= Fq[9])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_119

._step_119_end:
vpxord %zmm18, %zmm4, %zmm4
vpxord %zmm4, %zmm0, %zmm0


##### step 120 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_120

._step_120_end:
vpxord %zmm12, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 121 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_121

._step_121_end:
vpxord %zmm13, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 122 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_122

._step_122_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 123 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_123

._step_123_end:
vpxord %zmm14, %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step 124 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_124

._step_124_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 125 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_125

._step_125_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 126 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_126

._step_126_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 127 : Fl[0] ^= (Fl[8] ^= Fq[alpha + 7])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_127

._step_127_end:
vpxord 448(%rdi, %rdx), %zmm8, %zmm8
vpxord %zmm8, %zmm0, %zmm0


##### step 128 : Fl[0] ^= (Fl[1] ^= Fq[21])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_128

._step_128_end:
vpxord 1344(%rdi), %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 129 : Fl[0] ^= (Fl[2] ^= Fq[22])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_129

._step_129_end:
vpxord 1408(%rdi), %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 130 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_130

._step_130_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 131 : Fl[0] ^= (Fl[3] ^= Fq[23])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_131

._step_131_end:
vpxord 1472(%rdi), %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step 132 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_132

._step_132_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 133 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_133

._step_133_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 134 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_134

._step_134_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 135 : Fl[0] ^= (Fl[4] ^= Fq[24])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_135

._step_135_end:
vpxord 1536(%rdi), %zmm4, %zmm4
vpxord %zmm4, %zmm0, %zmm0


##### step 136 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_136

._step_136_end:
vpxord %zmm12, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 137 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_137

._step_137_end:
vpxord %zmm13, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 138 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_138

._step_138_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 139 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_139

._step_139_end:
vpxord %zmm14, %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step 140 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_140

._step_140_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 141 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_141

._step_141_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 142 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_142

._step_142_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 143 : Fl[0] ^= (Fl[5] ^= Fq[25])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_143

._step_143_end:
vpxord 1600(%rdi), %zmm5, %zmm5
vpxord %zmm5, %zmm0, %zmm0


##### step 144 : Fl[0] ^= (Fl[1] ^= Fq[6])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_144

._step_144_end:
vpxord %zmm15, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 145 : Fl[0] ^= (Fl[2] ^= Fq[7])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_145

._step_145_end:
vpxord %zmm16, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 146 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_146

._step_146_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 147 : Fl[0] ^= (Fl[3] ^= Fq[8])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_147

._step_147_end:
vpxord %zmm17, %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step 148 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_148

._step_148_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 149 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_149

._step_149_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 150 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_150

._step_150_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 151 : Fl[0] ^= (Fl[4] ^= Fq[9])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_151

._step_151_end:
vpxord %zmm18, %zmm4, %zmm4
vpxord %zmm4, %zmm0, %zmm0


##### step 152 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_152

._step_152_end:
vpxord %zmm12, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 153 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_153

._step_153_end:
vpxord %zmm13, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 154 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_154

._step_154_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 155 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_155

._step_155_end:
vpxord %zmm14, %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step 156 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_156

._step_156_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 157 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_157

._step_157_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 158 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_158

._step_158_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 159 : Fl[0] ^= (Fl[6] ^= Fq[26])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_159

._step_159_end:
vpxord 1664(%rdi), %zmm6, %zmm6
vpxord %zmm6, %zmm0, %zmm0


##### step 160 : Fl[0] ^= (Fl[1] ^= Fq[10])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_160

._step_160_end:
vpxord %zmm19, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 161 : Fl[0] ^= (Fl[2] ^= Fq[11])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_161

._step_161_end:
vpxord %zmm20, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 162 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_162

._step_162_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 163 : Fl[0] ^= (Fl[3] ^= Fq[12])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_163

._step_163_end:
vpxord %zmm21, %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step 164 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_164

._step_164_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 165 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_165

._step_165_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 166 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_166

._step_166_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 167 : Fl[0] ^= (Fl[4] ^= Fq[13])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_167

._step_167_end:
vpxord %zmm22, %zmm4, %zmm4
vpxord %zmm4, %zmm0, %zmm0


##### step 168 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_168

._step_168_end:
vpxord %zmm12, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 169 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_169

._step_169_end:
vpxord %zmm13, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 170 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_170

._step_170_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 171 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_171

._step_171_end:
vpxord %zmm14, %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step 172 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_172

._step_172_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 173 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_173

._step_173_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 174 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_174

._step_174_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 175 : Fl[0] ^= (Fl[5] ^= Fq[14])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_175

._step_175_end:
vpxord %zmm23, %zmm5, %zmm5
vpxord %zmm5, %zmm0, %zmm0


##### step 176 : Fl[0] ^= (Fl[1] ^= Fq[6])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_176

._step_176_end:
vpxord %zmm15, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 177 : Fl[0] ^= (Fl[2] ^= Fq[7])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_177

._step_177_end:
vpxord %zmm16, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 178 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_178

._step_178_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 179 : Fl[0] ^= (Fl[3] ^= Fq[8])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_179

._step_179_end:
vpxord %zmm17, %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step 180 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_180

._step_180_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 181 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_181

._step_181_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 182 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_182

._step_182_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 183 : Fl[0] ^= (Fl[4] ^= Fq[9])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_183

._step_183_end:
vpxord %zmm18, %zmm4, %zmm4
vpxord %zmm4, %zmm0, %zmm0


##### step 184 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_184

._step_184_end:
vpxord %zmm12, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 185 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_185

._step_185_end:
vpxord %zmm13, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 186 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_186

._step_186_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 187 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_187

._step_187_end:
vpxord %zmm14, %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step 188 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_188

._step_188_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 189 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_189

._step_189_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 190 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_190

._step_190_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 191 : Fl[0] ^= (Fl[7] ^= Fq[27])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_191

._step_191_end:
vpxord 1728(%rdi), %zmm7, %zmm7
vpxord %zmm7, %zmm0, %zmm0


##### step 192 : Fl[0] ^= (Fl[1] ^= Fq[15])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_192

._step_192_end:
vpxord %zmm24, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 193 : Fl[0] ^= (Fl[2] ^= Fq[16])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_193

._step_193_end:
vpxord %zmm25, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 194 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_194

._step_194_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 195 : Fl[0] ^= (Fl[3] ^= Fq[17])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_195

._step_195_end:
vpxord %zmm26, %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step 196 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_196

._step_196_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 197 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_197

._step_197_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 198 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_198

._step_198_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 199 : Fl[0] ^= (Fl[4] ^= Fq[18])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_199

._step_199_end:
vpxord %zmm27, %zmm4, %zmm4
vpxord %zmm4, %zmm0, %zmm0


##### step 200 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_200

._step_200_end:
vpxord %zmm12, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 201 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_201

._step_201_end:
vpxord %zmm13, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 202 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_202

._step_202_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 203 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_203

._step_203_end:
vpxord %zmm14, %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step 204 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_204

._step_204_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 205 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_205

._step_205_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 206 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_206

._step_206_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 207 : Fl[0] ^= (Fl[5] ^= Fq[19])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_207

._step_207_end:
vpxord %zmm28, %zmm5, %zmm5
vpxord %zmm5, %zmm0, %zmm0


##### step 208 : Fl[0] ^= (Fl[1] ^= Fq[6])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_208

._step_208_end:
vpxord %zmm15, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 209 : Fl[0] ^= (Fl[2] ^= Fq[7])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_209

._step_209_end:
vpxord %zmm16, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 210 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_210

._step_210_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 211 : Fl[0] ^= (Fl[3] ^= Fq[8])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_211

._step_211_end:
vpxord %zmm17, %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step 212 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_212

._step_212_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 213 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_213

._step_213_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 214 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_214

._step_214_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 215 : Fl[0] ^= (Fl[4] ^= Fq[9])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_215

._step_215_end:
vpxord %zmm18, %zmm4, %zmm4
vpxord %zmm4, %zmm0, %zmm0


##### step 216 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_216

._step_216_end:
vpxord %zmm12, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 217 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_217

._step_217_end:
vpxord %zmm13, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 218 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_218

._step_218_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 219 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_219

._step_219_end:
vpxord %zmm14, %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step 220 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_220

._step_220_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 221 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_221

._step_221_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 222 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_222

._step_222_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 223 : Fl[0] ^= (Fl[6] ^= Fq[20])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_223

._step_223_end:
vpxord %zmm29, %zmm6, %zmm6
vpxord %zmm6, %zmm0, %zmm0


##### step 224 : Fl[0] ^= (Fl[1] ^= Fq[10])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_224

._step_224_end:
vpxord %zmm19, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 225 : Fl[0] ^= (Fl[2] ^= Fq[11])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_225

._step_225_end:
vpxord %zmm20, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 226 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_226

._step_226_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 227 : Fl[0] ^= (Fl[3] ^= Fq[12])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_227

._step_227_end:
vpxord %zmm21, %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step 228 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_228

._step_228_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 229 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_229

._step_229_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 230 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_230

._step_230_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 231 : Fl[0] ^= (Fl[4] ^= Fq[13])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_231

._step_231_end:
vpxord %zmm22, %zmm4, %zmm4
vpxord %zmm4, %zmm0, %zmm0


##### step 232 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_232

._step_232_end:
vpxord %zmm12, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 233 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_233

._step_233_end:
vpxord %zmm13, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 234 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_234

._step_234_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 235 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_235

._step_235_end:
vpxord %zmm14, %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step 236 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_236

._step_236_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 237 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_237

._step_237_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 238 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_238

._step_238_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 239 : Fl[0] ^= (Fl[5] ^= Fq[14])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_239

._step_239_end:
vpxord %zmm23, %zmm5, %zmm5
vpxord %zmm5, %zmm0, %zmm0


##### step 240 : Fl[0] ^= (Fl[1] ^= Fq[6])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_240

._step_240_end:
vpxord %zmm15, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 241 : Fl[0] ^= (Fl[2] ^= Fq[7])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_241

._step_241_end:
vpxord %zmm16, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 242 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_242

._step_242_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 243 : Fl[0] ^= (Fl[3] ^= Fq[8])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_243

._step_243_end:
vpxord %zmm17, %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step 244 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_244

._step_244_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 245 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_245

._step_245_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 246 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_246

._step_246_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 247 : Fl[0] ^= (Fl[4] ^= Fq[9])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_247

._step_247_end:
vpxord %zmm18, %zmm4, %zmm4
vpxord %zmm4, %zmm0, %zmm0


##### step 248 : Fl[0] ^= (Fl[1] ^= Fq[3])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_248

._step_248_end:
vpxord %zmm12, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 249 : Fl[0] ^= (Fl[2] ^= Fq[4])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_249

._step_249_end:
vpxord %zmm13, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 250 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_250

._step_250_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 251 : Fl[0] ^= (Fl[3] ^= Fq[5])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_251

._step_251_end:
vpxord %zmm14, %zmm3, %zmm3
vpxord %zmm3, %zmm0, %zmm0


##### step 252 : Fl[0] ^= (Fl[1] ^= Fq[1])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_252

._step_252_end:
vpxord %zmm10, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0


##### step 253 : Fl[0] ^= (Fl[2] ^= Fq[2])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_253

._step_253_end:
vpxord %zmm11, %zmm2, %zmm2
vpxord %zmm2, %zmm0, %zmm0


##### step 254 : Fl[0] ^= (Fl[1] ^= Fq[0])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_254

._step_254_end:
vpxord %zmm9, %zmm1, %zmm1
vpxord %zmm1, %zmm0, %zmm0

#############################
# end of the unrolled chunk #
#############################

# Save the Fl[1:] back to memory
vmovdqa32 %zmm1, 64(%rsi)     #Fl[1] <-- %zmm1
vmovdqa32 %zmm2, 128(%rsi)     #Fl[2] <-- %zmm2
vmovdqa32 %zmm3, 192(%rsi)     #Fl[3] <-- %zmm3
vmovdqa32 %zmm4, 256(%rsi)     #Fl[4] <-- %zmm4
vmovdqa32 %zmm5, 320(%rsi)     #Fl[5] <-- %zmm5
vmovdqa32 %zmm6, 384(%rsi)     #Fl[6] <-- %zmm6
vmovdqa32 %zmm7, 448(%rsi)     #Fl[7] <-- %zmm7
vmovdqa32 %zmm8, 512(%rsi)     #Fl[8] <-- %zmm8

##### special last step 255 : Fl[0] ^= (Fl[beta] ^= Fq[gamma])

vpcmpequw %zmm0, %zmm31, %k0
ktestd %k0, %k0
jne ._report_solution_255

._step_255_end:
vmovdqa32 (%rsi, %rcx), %zmm30
vpxord (%rdi, %r8), %zmm30, %zmm30
vmovdqa32 %zmm30, (%rsi, %rcx)
vpxord %zmm30, %zmm0, %zmm0

# Save Fl[0] back to memory
vmovdqa32 %zmm0, (%rsi)     #Fl[0] <-- %zmm0

ret


########### now the code that reports solutions

._report_solution_0:          # GrayCode(i + 0) is a solution
movl $0, 0(%rax)               # buffer.x = 0
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_0_end

._report_solution_1:          # GrayCode(i + 1) is a solution
movl $1, 0(%rax)               # buffer.x = 1
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_1_end

._report_solution_2:          # GrayCode(i + 2) is a solution
movl $2, 0(%rax)               # buffer.x = 2
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_2_end

._report_solution_3:          # GrayCode(i + 3) is a solution
movl $3, 0(%rax)               # buffer.x = 3
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_3_end

._report_solution_4:          # GrayCode(i + 4) is a solution
movl $4, 0(%rax)               # buffer.x = 4
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_4_end

._report_solution_5:          # GrayCode(i + 5) is a solution
movl $5, 0(%rax)               # buffer.x = 5
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_5_end

._report_solution_6:          # GrayCode(i + 6) is a solution
movl $6, 0(%rax)               # buffer.x = 6
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_6_end

._report_solution_7:          # GrayCode(i + 7) is a solution
movl $7, 0(%rax)               # buffer.x = 7
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_7_end

._report_solution_8:          # GrayCode(i + 8) is a solution
movl $8, 0(%rax)               # buffer.x = 8
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_8_end

._report_solution_9:          # GrayCode(i + 9) is a solution
movl $9, 0(%rax)               # buffer.x = 9
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_9_end

._report_solution_10:          # GrayCode(i + 10) is a solution
movl $10, 0(%rax)               # buffer.x = 10
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_10_end

._report_solution_11:          # GrayCode(i + 11) is a solution
movl $11, 0(%rax)               # buffer.x = 11
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_11_end

._report_solution_12:          # GrayCode(i + 12) is a solution
movl $12, 0(%rax)               # buffer.x = 12
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_12_end

._report_solution_13:          # GrayCode(i + 13) is a solution
movl $13, 0(%rax)               # buffer.x = 13
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_13_end

._report_solution_14:          # GrayCode(i + 14) is a solution
movl $14, 0(%rax)               # buffer.x = 14
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_14_end

._report_solution_15:          # GrayCode(i + 15) is a solution
movl $15, 0(%rax)               # buffer.x = 15
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_15_end

._report_solution_16:          # GrayCode(i + 16) is a solution
movl $16, 0(%rax)               # buffer.x = 16
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_16_end

._report_solution_17:          # GrayCode(i + 17) is a solution
movl $17, 0(%rax)               # buffer.x = 17
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_17_end

._report_solution_18:          # GrayCode(i + 18) is a solution
movl $18, 0(%rax)               # buffer.x = 18
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_18_end

._report_solution_19:          # GrayCode(i + 19) is a solution
movl $19, 0(%rax)               # buffer.x = 19
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_19_end

._report_solution_20:          # GrayCode(i + 20) is a solution
movl $20, 0(%rax)               # buffer.x = 20
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_20_end

._report_solution_21:          # GrayCode(i + 21) is a solution
movl $21, 0(%rax)               # buffer.x = 21
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_21_end

._report_solution_22:          # GrayCode(i + 22) is a solution
movl $22, 0(%rax)               # buffer.x = 22
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_22_end

._report_solution_23:          # GrayCode(i + 23) is a solution
movl $23, 0(%rax)               # buffer.x = 23
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_23_end

._report_solution_24:          # GrayCode(i + 24) is a solution
movl $24, 0(%rax)               # buffer.x = 24
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_24_end

._report_solution_25:          # GrayCode(i + 25) is a solution
movl $25, 0(%rax)               # buffer.x = 25
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_25_end

._report_solution_26:          # GrayCode(i + 26) is a solution
movl $26, 0(%rax)               # buffer.x = 26
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_26_end

._report_solution_27:          # GrayCode(i + 27) is a solution
movl $27, 0(%rax)               # buffer.x = 27
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_27_end

._report_solution_28:          # GrayCode(i + 28) is a solution
movl $28, 0(%rax)               # buffer.x = 28
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_28_end

._report_solution_29:          # GrayCode(i + 29) is a solution
movl $29, 0(%rax)               # buffer.x = 29
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_29_end

._report_solution_30:          # GrayCode(i + 30) is a solution
movl $30, 0(%rax)               # buffer.x = 30
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_30_end

._report_solution_31:          # GrayCode(i + 31) is a solution
movl $31, 0(%rax)               # buffer.x = 31
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_31_end

._report_solution_32:          # GrayCode(i + 32) is a solution
movl $32, 0(%rax)               # buffer.x = 32
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_32_end

._report_solution_33:          # GrayCode(i + 33) is a solution
movl $33, 0(%rax)               # buffer.x = 33
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_33_end

._report_solution_34:          # GrayCode(i + 34) is a solution
movl $34, 0(%rax)               # buffer.x = 34
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_34_end

._report_solution_35:          # GrayCode(i + 35) is a solution
movl $35, 0(%rax)               # buffer.x = 35
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_35_end

._report_solution_36:          # GrayCode(i + 36) is a solution
movl $36, 0(%rax)               # buffer.x = 36
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_36_end

._report_solution_37:          # GrayCode(i + 37) is a solution
movl $37, 0(%rax)               # buffer.x = 37
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_37_end

._report_solution_38:          # GrayCode(i + 38) is a solution
movl $38, 0(%rax)               # buffer.x = 38
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_38_end

._report_solution_39:          # GrayCode(i + 39) is a solution
movl $39, 0(%rax)               # buffer.x = 39
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_39_end

._report_solution_40:          # GrayCode(i + 40) is a solution
movl $40, 0(%rax)               # buffer.x = 40
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_40_end

._report_solution_41:          # GrayCode(i + 41) is a solution
movl $41, 0(%rax)               # buffer.x = 41
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_41_end

._report_solution_42:          # GrayCode(i + 42) is a solution
movl $42, 0(%rax)               # buffer.x = 42
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_42_end

._report_solution_43:          # GrayCode(i + 43) is a solution
movl $43, 0(%rax)               # buffer.x = 43
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_43_end

._report_solution_44:          # GrayCode(i + 44) is a solution
movl $44, 0(%rax)               # buffer.x = 44
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_44_end

._report_solution_45:          # GrayCode(i + 45) is a solution
movl $45, 0(%rax)               # buffer.x = 45
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_45_end

._report_solution_46:          # GrayCode(i + 46) is a solution
movl $46, 0(%rax)               # buffer.x = 46
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_46_end

._report_solution_47:          # GrayCode(i + 47) is a solution
movl $47, 0(%rax)               # buffer.x = 47
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_47_end

._report_solution_48:          # GrayCode(i + 48) is a solution
movl $48, 0(%rax)               # buffer.x = 48
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_48_end

._report_solution_49:          # GrayCode(i + 49) is a solution
movl $49, 0(%rax)               # buffer.x = 49
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_49_end

._report_solution_50:          # GrayCode(i + 50) is a solution
movl $50, 0(%rax)               # buffer.x = 50
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_50_end

._report_solution_51:          # GrayCode(i + 51) is a solution
movl $51, 0(%rax)               # buffer.x = 51
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_51_end

._report_solution_52:          # GrayCode(i + 52) is a solution
movl $52, 0(%rax)               # buffer.x = 52
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_52_end

._report_solution_53:          # GrayCode(i + 53) is a solution
movl $53, 0(%rax)               # buffer.x = 53
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_53_end

._report_solution_54:          # GrayCode(i + 54) is a solution
movl $54, 0(%rax)               # buffer.x = 54
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_54_end

._report_solution_55:          # GrayCode(i + 55) is a solution
movl $55, 0(%rax)               # buffer.x = 55
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_55_end

._report_solution_56:          # GrayCode(i + 56) is a solution
movl $56, 0(%rax)               # buffer.x = 56
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_56_end

._report_solution_57:          # GrayCode(i + 57) is a solution
movl $57, 0(%rax)               # buffer.x = 57
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_57_end

._report_solution_58:          # GrayCode(i + 58) is a solution
movl $58, 0(%rax)               # buffer.x = 58
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_58_end

._report_solution_59:          # GrayCode(i + 59) is a solution
movl $59, 0(%rax)               # buffer.x = 59
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_59_end

._report_solution_60:          # GrayCode(i + 60) is a solution
movl $60, 0(%rax)               # buffer.x = 60
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_60_end

._report_solution_61:          # GrayCode(i + 61) is a solution
movl $61, 0(%rax)               # buffer.x = 61
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_61_end

._report_solution_62:          # GrayCode(i + 62) is a solution
movl $62, 0(%rax)               # buffer.x = 62
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_62_end

._report_solution_63:          # GrayCode(i + 63) is a solution
movl $63, 0(%rax)               # buffer.x = 63
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_63_end

._report_solution_64:          # GrayCode(i + 64) is a solution
movl $64, 0(%rax)               # buffer.x = 64
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_64_end

._report_solution_65:          # GrayCode(i + 65) is a solution
movl $65, 0(%rax)               # buffer.x = 65
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_65_end

._report_solution_66:          # GrayCode(i + 66) is a solution
movl $66, 0(%rax)               # buffer.x = 66
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_66_end

._report_solution_67:          # GrayCode(i + 67) is a solution
movl $67, 0(%rax)               # buffer.x = 67
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_67_end

._report_solution_68:          # GrayCode(i + 68) is a solution
movl $68, 0(%rax)               # buffer.x = 68
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_68_end

._report_solution_69:          # GrayCode(i + 69) is a solution
movl $69, 0(%rax)               # buffer.x = 69
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_69_end

._report_solution_70:          # GrayCode(i + 70) is a solution
movl $70, 0(%rax)               # buffer.x = 70
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_70_end

._report_solution_71:          # GrayCode(i + 71) is a solution
movl $71, 0(%rax)               # buffer.x = 71
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_71_end

._report_solution_72:          # GrayCode(i + 72) is a solution
movl $72, 0(%rax)               # buffer.x = 72
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_72_end

._report_solution_73:          # GrayCode(i + 73) is a solution
movl $73, 0(%rax)               # buffer.x = 73
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_73_end

._report_solution_74:          # GrayCode(i + 74) is a solution
movl $74, 0(%rax)               # buffer.x = 74
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_74_end

._report_solution_75:          # GrayCode(i + 75) is a solution
movl $75, 0(%rax)               # buffer.x = 75
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_75_end

._report_solution_76:          # GrayCode(i + 76) is a solution
movl $76, 0(%rax)               # buffer.x = 76
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_76_end

._report_solution_77:          # GrayCode(i + 77) is a solution
movl $77, 0(%rax)               # buffer.x = 77
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_77_end

._report_solution_78:          # GrayCode(i + 78) is a solution
movl $78, 0(%rax)               # buffer.x = 78
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_78_end

._report_solution_79:          # GrayCode(i + 79) is a solution
movl $79, 0(%rax)               # buffer.x = 79
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_79_end

._report_solution_80:          # GrayCode(i + 80) is a solution
movl $80, 0(%rax)               # buffer.x = 80
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_80_end

._report_solution_81:          # GrayCode(i + 81) is a solution
movl $81, 0(%rax)               # buffer.x = 81
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_81_end

._report_solution_82:          # GrayCode(i + 82) is a solution
movl $82, 0(%rax)               # buffer.x = 82
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_82_end

._report_solution_83:          # GrayCode(i + 83) is a solution
movl $83, 0(%rax)               # buffer.x = 83
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_83_end

._report_solution_84:          # GrayCode(i + 84) is a solution
movl $84, 0(%rax)               # buffer.x = 84
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_84_end

._report_solution_85:          # GrayCode(i + 85) is a solution
movl $85, 0(%rax)               # buffer.x = 85
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_85_end

._report_solution_86:          # GrayCode(i + 86) is a solution
movl $86, 0(%rax)               # buffer.x = 86
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_86_end

._report_solution_87:          # GrayCode(i + 87) is a solution
movl $87, 0(%rax)               # buffer.x = 87
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_87_end

._report_solution_88:          # GrayCode(i + 88) is a solution
movl $88, 0(%rax)               # buffer.x = 88
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_88_end

._report_solution_89:          # GrayCode(i + 89) is a solution
movl $89, 0(%rax)               # buffer.x = 89
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_89_end

._report_solution_90:          # GrayCode(i + 90) is a solution
movl $90, 0(%rax)               # buffer.x = 90
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_90_end

._report_solution_91:          # GrayCode(i + 91) is a solution
movl $91, 0(%rax)               # buffer.x = 91
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_91_end

._report_solution_92:          # GrayCode(i + 92) is a solution
movl $92, 0(%rax)               # buffer.x = 92
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_92_end

._report_solution_93:          # GrayCode(i + 93) is a solution
movl $93, 0(%rax)               # buffer.x = 93
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_93_end

._report_solution_94:          # GrayCode(i + 94) is a solution
movl $94, 0(%rax)               # buffer.x = 94
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_94_end

._report_solution_95:          # GrayCode(i + 95) is a solution
movl $95, 0(%rax)               # buffer.x = 95
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_95_end

._report_solution_96:          # GrayCode(i + 96) is a solution
movl $96, 0(%rax)               # buffer.x = 96
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_96_end

._report_solution_97:          # GrayCode(i + 97) is a solution
movl $97, 0(%rax)               # buffer.x = 97
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_97_end

._report_solution_98:          # GrayCode(i + 98) is a solution
movl $98, 0(%rax)               # buffer.x = 98
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_98_end

._report_solution_99:          # GrayCode(i + 99) is a solution
movl $99, 0(%rax)               # buffer.x = 99
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_99_end

._report_solution_100:          # GrayCode(i + 100) is a solution
movl $100, 0(%rax)               # buffer.x = 100
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_100_end

._report_solution_101:          # GrayCode(i + 101) is a solution
movl $101, 0(%rax)               # buffer.x = 101
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_101_end

._report_solution_102:          # GrayCode(i + 102) is a solution
movl $102, 0(%rax)               # buffer.x = 102
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_102_end

._report_solution_103:          # GrayCode(i + 103) is a solution
movl $103, 0(%rax)               # buffer.x = 103
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_103_end

._report_solution_104:          # GrayCode(i + 104) is a solution
movl $104, 0(%rax)               # buffer.x = 104
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_104_end

._report_solution_105:          # GrayCode(i + 105) is a solution
movl $105, 0(%rax)               # buffer.x = 105
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_105_end

._report_solution_106:          # GrayCode(i + 106) is a solution
movl $106, 0(%rax)               # buffer.x = 106
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_106_end

._report_solution_107:          # GrayCode(i + 107) is a solution
movl $107, 0(%rax)               # buffer.x = 107
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_107_end

._report_solution_108:          # GrayCode(i + 108) is a solution
movl $108, 0(%rax)               # buffer.x = 108
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_108_end

._report_solution_109:          # GrayCode(i + 109) is a solution
movl $109, 0(%rax)               # buffer.x = 109
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_109_end

._report_solution_110:          # GrayCode(i + 110) is a solution
movl $110, 0(%rax)               # buffer.x = 110
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_110_end

._report_solution_111:          # GrayCode(i + 111) is a solution
movl $111, 0(%rax)               # buffer.x = 111
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_111_end

._report_solution_112:          # GrayCode(i + 112) is a solution
movl $112, 0(%rax)               # buffer.x = 112
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_112_end

._report_solution_113:          # GrayCode(i + 113) is a solution
movl $113, 0(%rax)               # buffer.x = 113
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_113_end

._report_solution_114:          # GrayCode(i + 114) is a solution
movl $114, 0(%rax)               # buffer.x = 114
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_114_end

._report_solution_115:          # GrayCode(i + 115) is a solution
movl $115, 0(%rax)               # buffer.x = 115
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_115_end

._report_solution_116:          # GrayCode(i + 116) is a solution
movl $116, 0(%rax)               # buffer.x = 116
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_116_end

._report_solution_117:          # GrayCode(i + 117) is a solution
movl $117, 0(%rax)               # buffer.x = 117
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_117_end

._report_solution_118:          # GrayCode(i + 118) is a solution
movl $118, 0(%rax)               # buffer.x = 118
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_118_end

._report_solution_119:          # GrayCode(i + 119) is a solution
movl $119, 0(%rax)               # buffer.x = 119
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_119_end

._report_solution_120:          # GrayCode(i + 120) is a solution
movl $120, 0(%rax)               # buffer.x = 120
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_120_end

._report_solution_121:          # GrayCode(i + 121) is a solution
movl $121, 0(%rax)               # buffer.x = 121
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_121_end

._report_solution_122:          # GrayCode(i + 122) is a solution
movl $122, 0(%rax)               # buffer.x = 122
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_122_end

._report_solution_123:          # GrayCode(i + 123) is a solution
movl $123, 0(%rax)               # buffer.x = 123
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_123_end

._report_solution_124:          # GrayCode(i + 124) is a solution
movl $124, 0(%rax)               # buffer.x = 124
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_124_end

._report_solution_125:          # GrayCode(i + 125) is a solution
movl $125, 0(%rax)               # buffer.x = 125
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_125_end

._report_solution_126:          # GrayCode(i + 126) is a solution
movl $126, 0(%rax)               # buffer.x = 126
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_126_end

._report_solution_127:          # GrayCode(i + 127) is a solution
movl $127, 0(%rax)               # buffer.x = 127
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_127_end

._report_solution_128:          # GrayCode(i + 128) is a solution
movl $128, 0(%rax)               # buffer.x = 128
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_128_end

._report_solution_129:          # GrayCode(i + 129) is a solution
movl $129, 0(%rax)               # buffer.x = 129
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_129_end

._report_solution_130:          # GrayCode(i + 130) is a solution
movl $130, 0(%rax)               # buffer.x = 130
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_130_end

._report_solution_131:          # GrayCode(i + 131) is a solution
movl $131, 0(%rax)               # buffer.x = 131
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_131_end

._report_solution_132:          # GrayCode(i + 132) is a solution
movl $132, 0(%rax)               # buffer.x = 132
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_132_end

._report_solution_133:          # GrayCode(i + 133) is a solution
movl $133, 0(%rax)               # buffer.x = 133
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_133_end

._report_solution_134:          # GrayCode(i + 134) is a solution
movl $134, 0(%rax)               # buffer.x = 134
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_134_end

._report_solution_135:          # GrayCode(i + 135) is a solution
movl $135, 0(%rax)               # buffer.x = 135
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_135_end

._report_solution_136:          # GrayCode(i + 136) is a solution
movl $136, 0(%rax)               # buffer.x = 136
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_136_end

._report_solution_137:          # GrayCode(i + 137) is a solution
movl $137, 0(%rax)               # buffer.x = 137
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_137_end

._report_solution_138:          # GrayCode(i + 138) is a solution
movl $138, 0(%rax)               # buffer.x = 138
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_138_end

._report_solution_139:          # GrayCode(i + 139) is a solution
movl $139, 0(%rax)               # buffer.x = 139
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_139_end

._report_solution_140:          # GrayCode(i + 140) is a solution
movl $140, 0(%rax)               # buffer.x = 140
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_140_end

._report_solution_141:          # GrayCode(i + 141) is a solution
movl $141, 0(%rax)               # buffer.x = 141
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_141_end

._report_solution_142:          # GrayCode(i + 142) is a solution
movl $142, 0(%rax)               # buffer.x = 142
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_142_end

._report_solution_143:          # GrayCode(i + 143) is a solution
movl $143, 0(%rax)               # buffer.x = 143
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_143_end

._report_solution_144:          # GrayCode(i + 144) is a solution
movl $144, 0(%rax)               # buffer.x = 144
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_144_end

._report_solution_145:          # GrayCode(i + 145) is a solution
movl $145, 0(%rax)               # buffer.x = 145
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_145_end

._report_solution_146:          # GrayCode(i + 146) is a solution
movl $146, 0(%rax)               # buffer.x = 146
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_146_end

._report_solution_147:          # GrayCode(i + 147) is a solution
movl $147, 0(%rax)               # buffer.x = 147
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_147_end

._report_solution_148:          # GrayCode(i + 148) is a solution
movl $148, 0(%rax)               # buffer.x = 148
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_148_end

._report_solution_149:          # GrayCode(i + 149) is a solution
movl $149, 0(%rax)               # buffer.x = 149
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_149_end

._report_solution_150:          # GrayCode(i + 150) is a solution
movl $150, 0(%rax)               # buffer.x = 150
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_150_end

._report_solution_151:          # GrayCode(i + 151) is a solution
movl $151, 0(%rax)               # buffer.x = 151
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_151_end

._report_solution_152:          # GrayCode(i + 152) is a solution
movl $152, 0(%rax)               # buffer.x = 152
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_152_end

._report_solution_153:          # GrayCode(i + 153) is a solution
movl $153, 0(%rax)               # buffer.x = 153
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_153_end

._report_solution_154:          # GrayCode(i + 154) is a solution
movl $154, 0(%rax)               # buffer.x = 154
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_154_end

._report_solution_155:          # GrayCode(i + 155) is a solution
movl $155, 0(%rax)               # buffer.x = 155
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_155_end

._report_solution_156:          # GrayCode(i + 156) is a solution
movl $156, 0(%rax)               # buffer.x = 156
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_156_end

._report_solution_157:          # GrayCode(i + 157) is a solution
movl $157, 0(%rax)               # buffer.x = 157
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_157_end

._report_solution_158:          # GrayCode(i + 158) is a solution
movl $158, 0(%rax)               # buffer.x = 158
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_158_end

._report_solution_159:          # GrayCode(i + 159) is a solution
movl $159, 0(%rax)               # buffer.x = 159
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_159_end

._report_solution_160:          # GrayCode(i + 160) is a solution
movl $160, 0(%rax)               # buffer.x = 160
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_160_end

._report_solution_161:          # GrayCode(i + 161) is a solution
movl $161, 0(%rax)               # buffer.x = 161
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_161_end

._report_solution_162:          # GrayCode(i + 162) is a solution
movl $162, 0(%rax)               # buffer.x = 162
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_162_end

._report_solution_163:          # GrayCode(i + 163) is a solution
movl $163, 0(%rax)               # buffer.x = 163
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_163_end

._report_solution_164:          # GrayCode(i + 164) is a solution
movl $164, 0(%rax)               # buffer.x = 164
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_164_end

._report_solution_165:          # GrayCode(i + 165) is a solution
movl $165, 0(%rax)               # buffer.x = 165
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_165_end

._report_solution_166:          # GrayCode(i + 166) is a solution
movl $166, 0(%rax)               # buffer.x = 166
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_166_end

._report_solution_167:          # GrayCode(i + 167) is a solution
movl $167, 0(%rax)               # buffer.x = 167
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_167_end

._report_solution_168:          # GrayCode(i + 168) is a solution
movl $168, 0(%rax)               # buffer.x = 168
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_168_end

._report_solution_169:          # GrayCode(i + 169) is a solution
movl $169, 0(%rax)               # buffer.x = 169
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_169_end

._report_solution_170:          # GrayCode(i + 170) is a solution
movl $170, 0(%rax)               # buffer.x = 170
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_170_end

._report_solution_171:          # GrayCode(i + 171) is a solution
movl $171, 0(%rax)               # buffer.x = 171
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_171_end

._report_solution_172:          # GrayCode(i + 172) is a solution
movl $172, 0(%rax)               # buffer.x = 172
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_172_end

._report_solution_173:          # GrayCode(i + 173) is a solution
movl $173, 0(%rax)               # buffer.x = 173
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_173_end

._report_solution_174:          # GrayCode(i + 174) is a solution
movl $174, 0(%rax)               # buffer.x = 174
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_174_end

._report_solution_175:          # GrayCode(i + 175) is a solution
movl $175, 0(%rax)               # buffer.x = 175
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_175_end

._report_solution_176:          # GrayCode(i + 176) is a solution
movl $176, 0(%rax)               # buffer.x = 176
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_176_end

._report_solution_177:          # GrayCode(i + 177) is a solution
movl $177, 0(%rax)               # buffer.x = 177
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_177_end

._report_solution_178:          # GrayCode(i + 178) is a solution
movl $178, 0(%rax)               # buffer.x = 178
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_178_end

._report_solution_179:          # GrayCode(i + 179) is a solution
movl $179, 0(%rax)               # buffer.x = 179
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_179_end

._report_solution_180:          # GrayCode(i + 180) is a solution
movl $180, 0(%rax)               # buffer.x = 180
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_180_end

._report_solution_181:          # GrayCode(i + 181) is a solution
movl $181, 0(%rax)               # buffer.x = 181
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_181_end

._report_solution_182:          # GrayCode(i + 182) is a solution
movl $182, 0(%rax)               # buffer.x = 182
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_182_end

._report_solution_183:          # GrayCode(i + 183) is a solution
movl $183, 0(%rax)               # buffer.x = 183
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_183_end

._report_solution_184:          # GrayCode(i + 184) is a solution
movl $184, 0(%rax)               # buffer.x = 184
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_184_end

._report_solution_185:          # GrayCode(i + 185) is a solution
movl $185, 0(%rax)               # buffer.x = 185
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_185_end

._report_solution_186:          # GrayCode(i + 186) is a solution
movl $186, 0(%rax)               # buffer.x = 186
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_186_end

._report_solution_187:          # GrayCode(i + 187) is a solution
movl $187, 0(%rax)               # buffer.x = 187
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_187_end

._report_solution_188:          # GrayCode(i + 188) is a solution
movl $188, 0(%rax)               # buffer.x = 188
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_188_end

._report_solution_189:          # GrayCode(i + 189) is a solution
movl $189, 0(%rax)               # buffer.x = 189
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_189_end

._report_solution_190:          # GrayCode(i + 190) is a solution
movl $190, 0(%rax)               # buffer.x = 190
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_190_end

._report_solution_191:          # GrayCode(i + 191) is a solution
movl $191, 0(%rax)               # buffer.x = 191
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_191_end

._report_solution_192:          # GrayCode(i + 192) is a solution
movl $192, 0(%rax)               # buffer.x = 192
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_192_end

._report_solution_193:          # GrayCode(i + 193) is a solution
movl $193, 0(%rax)               # buffer.x = 193
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_193_end

._report_solution_194:          # GrayCode(i + 194) is a solution
movl $194, 0(%rax)               # buffer.x = 194
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_194_end

._report_solution_195:          # GrayCode(i + 195) is a solution
movl $195, 0(%rax)               # buffer.x = 195
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_195_end

._report_solution_196:          # GrayCode(i + 196) is a solution
movl $196, 0(%rax)               # buffer.x = 196
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_196_end

._report_solution_197:          # GrayCode(i + 197) is a solution
movl $197, 0(%rax)               # buffer.x = 197
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_197_end

._report_solution_198:          # GrayCode(i + 198) is a solution
movl $198, 0(%rax)               # buffer.x = 198
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_198_end

._report_solution_199:          # GrayCode(i + 199) is a solution
movl $199, 0(%rax)               # buffer.x = 199
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_199_end

._report_solution_200:          # GrayCode(i + 200) is a solution
movl $200, 0(%rax)               # buffer.x = 200
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_200_end

._report_solution_201:          # GrayCode(i + 201) is a solution
movl $201, 0(%rax)               # buffer.x = 201
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_201_end

._report_solution_202:          # GrayCode(i + 202) is a solution
movl $202, 0(%rax)               # buffer.x = 202
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_202_end

._report_solution_203:          # GrayCode(i + 203) is a solution
movl $203, 0(%rax)               # buffer.x = 203
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_203_end

._report_solution_204:          # GrayCode(i + 204) is a solution
movl $204, 0(%rax)               # buffer.x = 204
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_204_end

._report_solution_205:          # GrayCode(i + 205) is a solution
movl $205, 0(%rax)               # buffer.x = 205
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_205_end

._report_solution_206:          # GrayCode(i + 206) is a solution
movl $206, 0(%rax)               # buffer.x = 206
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_206_end

._report_solution_207:          # GrayCode(i + 207) is a solution
movl $207, 0(%rax)               # buffer.x = 207
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_207_end

._report_solution_208:          # GrayCode(i + 208) is a solution
movl $208, 0(%rax)               # buffer.x = 208
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_208_end

._report_solution_209:          # GrayCode(i + 209) is a solution
movl $209, 0(%rax)               # buffer.x = 209
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_209_end

._report_solution_210:          # GrayCode(i + 210) is a solution
movl $210, 0(%rax)               # buffer.x = 210
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_210_end

._report_solution_211:          # GrayCode(i + 211) is a solution
movl $211, 0(%rax)               # buffer.x = 211
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_211_end

._report_solution_212:          # GrayCode(i + 212) is a solution
movl $212, 0(%rax)               # buffer.x = 212
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_212_end

._report_solution_213:          # GrayCode(i + 213) is a solution
movl $213, 0(%rax)               # buffer.x = 213
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_213_end

._report_solution_214:          # GrayCode(i + 214) is a solution
movl $214, 0(%rax)               # buffer.x = 214
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_214_end

._report_solution_215:          # GrayCode(i + 215) is a solution
movl $215, 0(%rax)               # buffer.x = 215
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_215_end

._report_solution_216:          # GrayCode(i + 216) is a solution
movl $216, 0(%rax)               # buffer.x = 216
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_216_end

._report_solution_217:          # GrayCode(i + 217) is a solution
movl $217, 0(%rax)               # buffer.x = 217
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_217_end

._report_solution_218:          # GrayCode(i + 218) is a solution
movl $218, 0(%rax)               # buffer.x = 218
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_218_end

._report_solution_219:          # GrayCode(i + 219) is a solution
movl $219, 0(%rax)               # buffer.x = 219
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_219_end

._report_solution_220:          # GrayCode(i + 220) is a solution
movl $220, 0(%rax)               # buffer.x = 220
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_220_end

._report_solution_221:          # GrayCode(i + 221) is a solution
movl $221, 0(%rax)               # buffer.x = 221
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_221_end

._report_solution_222:          # GrayCode(i + 222) is a solution
movl $222, 0(%rax)               # buffer.x = 222
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_222_end

._report_solution_223:          # GrayCode(i + 223) is a solution
movl $223, 0(%rax)               # buffer.x = 223
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_223_end

._report_solution_224:          # GrayCode(i + 224) is a solution
movl $224, 0(%rax)               # buffer.x = 224
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_224_end

._report_solution_225:          # GrayCode(i + 225) is a solution
movl $225, 0(%rax)               # buffer.x = 225
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_225_end

._report_solution_226:          # GrayCode(i + 226) is a solution
movl $226, 0(%rax)               # buffer.x = 226
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_226_end

._report_solution_227:          # GrayCode(i + 227) is a solution
movl $227, 0(%rax)               # buffer.x = 227
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_227_end

._report_solution_228:          # GrayCode(i + 228) is a solution
movl $228, 0(%rax)               # buffer.x = 228
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_228_end

._report_solution_229:          # GrayCode(i + 229) is a solution
movl $229, 0(%rax)               # buffer.x = 229
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_229_end

._report_solution_230:          # GrayCode(i + 230) is a solution
movl $230, 0(%rax)               # buffer.x = 230
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_230_end

._report_solution_231:          # GrayCode(i + 231) is a solution
movl $231, 0(%rax)               # buffer.x = 231
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_231_end

._report_solution_232:          # GrayCode(i + 232) is a solution
movl $232, 0(%rax)               # buffer.x = 232
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_232_end

._report_solution_233:          # GrayCode(i + 233) is a solution
movl $233, 0(%rax)               # buffer.x = 233
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_233_end

._report_solution_234:          # GrayCode(i + 234) is a solution
movl $234, 0(%rax)               # buffer.x = 234
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_234_end

._report_solution_235:          # GrayCode(i + 235) is a solution
movl $235, 0(%rax)               # buffer.x = 235
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_235_end

._report_solution_236:          # GrayCode(i + 236) is a solution
movl $236, 0(%rax)               # buffer.x = 236
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_236_end

._report_solution_237:          # GrayCode(i + 237) is a solution
movl $237, 0(%rax)               # buffer.x = 237
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_237_end

._report_solution_238:          # GrayCode(i + 238) is a solution
movl $238, 0(%rax)               # buffer.x = 238
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_238_end

._report_solution_239:          # GrayCode(i + 239) is a solution
movl $239, 0(%rax)               # buffer.x = 239
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_239_end

._report_solution_240:          # GrayCode(i + 240) is a solution
movl $240, 0(%rax)               # buffer.x = 240
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_240_end

._report_solution_241:          # GrayCode(i + 241) is a solution
movl $241, 0(%rax)               # buffer.x = 241
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_241_end

._report_solution_242:          # GrayCode(i + 242) is a solution
movl $242, 0(%rax)               # buffer.x = 242
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_242_end

._report_solution_243:          # GrayCode(i + 243) is a solution
movl $243, 0(%rax)               # buffer.x = 243
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_243_end

._report_solution_244:          # GrayCode(i + 244) is a solution
movl $244, 0(%rax)               # buffer.x = 244
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_244_end

._report_solution_245:          # GrayCode(i + 245) is a solution
movl $245, 0(%rax)               # buffer.x = 245
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_245_end

._report_solution_246:          # GrayCode(i + 246) is a solution
movl $246, 0(%rax)               # buffer.x = 246
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_246_end

._report_solution_247:          # GrayCode(i + 247) is a solution
movl $247, 0(%rax)               # buffer.x = 247
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_247_end

._report_solution_248:          # GrayCode(i + 248) is a solution
movl $248, 0(%rax)               # buffer.x = 248
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_248_end

._report_solution_249:          # GrayCode(i + 249) is a solution
movl $249, 0(%rax)               # buffer.x = 249
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_249_end

._report_solution_250:          # GrayCode(i + 250) is a solution
movl $250, 0(%rax)               # buffer.x = 250
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_250_end

._report_solution_251:          # GrayCode(i + 251) is a solution
movl $251, 0(%rax)               # buffer.x = 251
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_251_end

._report_solution_252:          # GrayCode(i + 252) is a solution
movl $252, 0(%rax)               # buffer.x = 252
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_252_end

._report_solution_253:          # GrayCode(i + 253) is a solution
movl $253, 0(%rax)               # buffer.x = 253
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_253_end

._report_solution_254:          # GrayCode(i + 254) is a solution
movl $254, 0(%rax)               # buffer.x = 254
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_254_end

._report_solution_255:          # GrayCode(i + 255) is a solution
movl $255, 0(%rax)               # buffer.x = 255
kmovd %k0, 4(%rax)               # buffer.mask = %r11
addq $8, %rax                    # buffer++
jmp ._step_255_end

