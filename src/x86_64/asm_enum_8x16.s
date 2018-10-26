.text
.p2align 5

.globl feslite_x86_64_asm_enum_8x16
### void x86_64_asm_enum_4x32(__m128i *F, uint64_t alpha_shift, void *buf, uint64_t *num, uint32_t idx);

# the X86-64 ABI says that...
# A) we should preserve the values of %rbx, %rbp, %r12...%r15 [callee-save registers]
# B) We will receive the arguments of the function in registers :
#       &F in %rdi
#       alpha_shift in %esi
#       &buf in %rdx
#       &num in %rcx
#       idx should be in %r8d

feslite_x86_64_asm_enum_8x16:

# intialize our stack frame
mov %rsp, %r11
and $31, %r11
add $64, %r11
sub %r11, %rsp

# no need to save the callee-save registers (not used)
# variable F maps to %rdi
# variable alpha maps to %rsi
# variable buf maps to %rdx
# variable num_ptr maps to %rcx
# variable idx maps to %r8
# variable num maps to %r9
# variable tmp maps to %rax
# variable ('F', 0) maps to %xmm0
# variable ('F', 1) maps to %xmm1
# variable ('F', 2) maps to %xmm2
# variable ('F', 3) maps to %xmm3
# variable ('F', 4) maps to %xmm4
# variable ('F', 5) maps to %xmm5
# variable ('F', 6) maps to %xmm6
# variable ('F', 7) maps to %xmm7
# variable ('F', 8) maps to %xmm8
# variable ('F', 9) maps to %xmm9
# variable ('F', 10) maps to %xmm10
# variable ('F', 11) maps to %xmm11
# variable ('F', 12) maps to %xmm12
# variable ('F', 13) maps to %xmm13
# variable sum maps to %xmm14
# variable zero maps to %xmm15
# variable mask maps to %r10d

# load the most-frequently used derivatives (F[0]...F[13]) into %xmm registers
movdqa 0(%rdi), %xmm0   ## %xmm0 = F[0]
movdqa 16(%rdi), %xmm1   ## %xmm1 = F[1]
movdqa 32(%rdi), %xmm2   ## %xmm2 = F[2]
movdqa 48(%rdi), %xmm3   ## %xmm3 = F[3]
movdqa 64(%rdi), %xmm4   ## %xmm4 = F[4]
movdqa 80(%rdi), %xmm5   ## %xmm5 = F[5]
movdqa 96(%rdi), %xmm6   ## %xmm6 = F[6]
movdqa 112(%rdi), %xmm7   ## %xmm7 = F[7]
movdqa 128(%rdi), %xmm8   ## %xmm8 = F[8]
movdqa 144(%rdi), %xmm9   ## %xmm9 = F[9]
movdqa 160(%rdi), %xmm10   ## %xmm10 = F[10]
movdqa 176(%rdi), %xmm11   ## %xmm11 = F[11]
movdqa 192(%rdi), %xmm12   ## %xmm12 = F[12]
movdqa 208(%rdi), %xmm13   ## %xmm13 = F[13]
# initialize the last things that remains to be intialized...
movq (%rcx), %r9  ## num = *num_ptr
pxor %xmm15, %xmm15   ## zero = 0


##### step 1 [hw=1]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ alpha + 1 ])))

pxor 16(%rdi,%rsi), %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_1
._step_1_end:

##### step 2 [hw=1]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ alpha + 2 ])))

pxor 32(%rdi,%rsi), %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_2
._step_2_end:

##### step 3 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_3
._step_3_end:

##### step 4 [hw=1]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ alpha + 3 ])))

pxor 48(%rdi,%rsi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_4
._step_4_end:

##### step 5 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_5
._step_5_end:

##### step 6 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_6
._step_6_end:

##### step 7 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_7
._step_7_end:

##### step 8 [hw=1]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ alpha + 4 ])))

pxor 64(%rdi,%rsi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_8
._step_8_end:

##### step 9 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_9
._step_9_end:

##### step 10 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_10
._step_10_end:

##### step 11 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_11
._step_11_end:

##### step 12 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_12
._step_12_end:

##### step 13 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_13
._step_13_end:

##### step 14 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_14
._step_14_end:

##### step 15 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_15
._step_15_end:

##### step 16 [hw=1]
##### F[ 0 ] ^= ( F[ 11 ] ^= ( F[ alpha + 5 ])))

pxor 80(%rdi,%rsi), %xmm11
pxor %xmm11, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_16
._step_16_end:

##### step 17 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 12 ])))

pxor %xmm12, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_17
._step_17_end:

##### step 18 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 13 ])))

pxor %xmm13, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_18
._step_18_end:

##### step 19 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_19
._step_19_end:

##### step 20 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 14 ])))

pxor 224(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_20
._step_20_end:

##### step 21 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_21
._step_21_end:

##### step 22 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_22
._step_22_end:

##### step 23 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_23
._step_23_end:

##### step 24 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 15 ])))

pxor 240(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_24
._step_24_end:

##### step 25 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_25
._step_25_end:

##### step 26 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_26
._step_26_end:

##### step 27 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_27
._step_27_end:

##### step 28 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_28
._step_28_end:

##### step 29 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_29
._step_29_end:

##### step 30 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_30
._step_30_end:

##### step 31 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_31
._step_31_end:

##### step 32 [hw=1]
##### F[ 0 ] ^= ( F[ 16 ] ^= ( F[ alpha + 6 ])))

movdqa 96(%rdi,%rsi), %xmm14
pxor 256(%rdi), %xmm14
movdqa %xmm14, 256(%rdi)
pxor %xmm14, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_32
._step_32_end:

##### step 33 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 17 ])))

pxor 272(%rdi), %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_33
._step_33_end:

##### step 34 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 18 ])))

pxor 288(%rdi), %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_34
._step_34_end:

##### step 35 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_35
._step_35_end:

##### step 36 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 19 ])))

pxor 304(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_36
._step_36_end:

##### step 37 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_37
._step_37_end:

##### step 38 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_38
._step_38_end:

##### step 39 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_39
._step_39_end:

##### step 40 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 20 ])))

pxor 320(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_40
._step_40_end:

##### step 41 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_41
._step_41_end:

##### step 42 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_42
._step_42_end:

##### step 43 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_43
._step_43_end:

##### step 44 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_44
._step_44_end:

##### step 45 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_45
._step_45_end:

##### step 46 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_46
._step_46_end:

##### step 47 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_47
._step_47_end:

##### step 48 [hw=2]
##### F[ 0 ] ^= ( F[ 11 ] ^= ( F[ 21 ])))

pxor 336(%rdi), %xmm11
pxor %xmm11, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_48
._step_48_end:

##### step 49 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 12 ])))

pxor %xmm12, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_49
._step_49_end:

##### step 50 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 13 ])))

pxor %xmm13, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_50
._step_50_end:

##### step 51 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_51
._step_51_end:

##### step 52 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 14 ])))

pxor 224(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_52
._step_52_end:

##### step 53 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_53
._step_53_end:

##### step 54 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_54
._step_54_end:

##### step 55 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_55
._step_55_end:

##### step 56 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 15 ])))

pxor 240(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_56
._step_56_end:

##### step 57 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_57
._step_57_end:

##### step 58 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_58
._step_58_end:

##### step 59 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_59
._step_59_end:

##### step 60 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_60
._step_60_end:

##### step 61 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_61
._step_61_end:

##### step 62 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_62
._step_62_end:

##### step 63 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_63
._step_63_end:

##### step 64 [hw=1]
##### F[ 0 ] ^= ( F[ 22 ] ^= ( F[ alpha + 7 ])))

movdqa 112(%rdi,%rsi), %xmm14
pxor 352(%rdi), %xmm14
movdqa %xmm14, 352(%rdi)
pxor %xmm14, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_64
._step_64_end:

##### step 65 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 23 ])))

pxor 368(%rdi), %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_65
._step_65_end:

##### step 66 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 24 ])))

pxor 384(%rdi), %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_66
._step_66_end:

##### step 67 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_67
._step_67_end:

##### step 68 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 25 ])))

pxor 400(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_68
._step_68_end:

##### step 69 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_69
._step_69_end:

##### step 70 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_70
._step_70_end:

##### step 71 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_71
._step_71_end:

##### step 72 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 26 ])))

pxor 416(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_72
._step_72_end:

##### step 73 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_73
._step_73_end:

##### step 74 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_74
._step_74_end:

##### step 75 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_75
._step_75_end:

##### step 76 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_76
._step_76_end:

##### step 77 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_77
._step_77_end:

##### step 78 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_78
._step_78_end:

##### step 79 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_79
._step_79_end:

##### step 80 [hw=2]
##### F[ 0 ] ^= ( F[ 11 ] ^= ( F[ 27 ])))

pxor 432(%rdi), %xmm11
pxor %xmm11, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_80
._step_80_end:

##### step 81 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 12 ])))

pxor %xmm12, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_81
._step_81_end:

##### step 82 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 13 ])))

pxor %xmm13, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_82
._step_82_end:

##### step 83 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_83
._step_83_end:

##### step 84 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 14 ])))

pxor 224(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_84
._step_84_end:

##### step 85 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_85
._step_85_end:

##### step 86 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_86
._step_86_end:

##### step 87 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_87
._step_87_end:

##### step 88 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 15 ])))

pxor 240(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_88
._step_88_end:

##### step 89 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_89
._step_89_end:

##### step 90 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_90
._step_90_end:

##### step 91 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_91
._step_91_end:

##### step 92 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_92
._step_92_end:

##### step 93 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_93
._step_93_end:

##### step 94 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_94
._step_94_end:

##### step 95 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_95
._step_95_end:

##### step 96 [hw=2]
##### F[ 0 ] ^= ( F[ 16 ] ^= ( F[ 28 ])))

movdqa 448(%rdi), %xmm14
pxor 256(%rdi), %xmm14
movdqa %xmm14, 256(%rdi)
pxor %xmm14, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_96
._step_96_end:

##### step 97 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 17 ])))

pxor 272(%rdi), %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_97
._step_97_end:

##### step 98 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 18 ])))

pxor 288(%rdi), %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_98
._step_98_end:

##### step 99 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_99
._step_99_end:

##### step 100 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 19 ])))

pxor 304(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_100
._step_100_end:

##### step 101 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_101
._step_101_end:

##### step 102 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_102
._step_102_end:

##### step 103 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_103
._step_103_end:

##### step 104 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 20 ])))

pxor 320(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_104
._step_104_end:

##### step 105 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_105
._step_105_end:

##### step 106 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_106
._step_106_end:

##### step 107 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_107
._step_107_end:

##### step 108 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_108
._step_108_end:

##### step 109 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_109
._step_109_end:

##### step 110 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_110
._step_110_end:

##### step 111 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_111
._step_111_end:

##### step 112 [hw=2]
##### F[ 0 ] ^= ( F[ 11 ] ^= ( F[ 21 ])))

pxor 336(%rdi), %xmm11
pxor %xmm11, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_112
._step_112_end:

##### step 113 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 12 ])))

pxor %xmm12, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_113
._step_113_end:

##### step 114 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 13 ])))

pxor %xmm13, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_114
._step_114_end:

##### step 115 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_115
._step_115_end:

##### step 116 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 14 ])))

pxor 224(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_116
._step_116_end:

##### step 117 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_117
._step_117_end:

##### step 118 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_118
._step_118_end:

##### step 119 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_119
._step_119_end:

##### step 120 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 15 ])))

pxor 240(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_120
._step_120_end:

##### step 121 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_121
._step_121_end:

##### step 122 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_122
._step_122_end:

##### step 123 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_123
._step_123_end:

##### step 124 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_124
._step_124_end:

##### step 125 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_125
._step_125_end:

##### step 126 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_126
._step_126_end:

##### step 127 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_127
._step_127_end:

##### step 128 [hw=1]
##### F[ 0 ] ^= ( F[ 29 ] ^= ( F[ alpha + 8 ])))

movdqa 128(%rdi,%rsi), %xmm14
pxor 464(%rdi), %xmm14
movdqa %xmm14, 464(%rdi)
pxor %xmm14, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_128
._step_128_end:

##### step 129 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 30 ])))

pxor 480(%rdi), %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_129
._step_129_end:

##### step 130 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 31 ])))

pxor 496(%rdi), %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_130
._step_130_end:

##### step 131 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_131
._step_131_end:

##### step 132 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 32 ])))

pxor 512(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_132
._step_132_end:

##### step 133 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_133
._step_133_end:

##### step 134 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_134
._step_134_end:

##### step 135 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_135
._step_135_end:

##### step 136 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 33 ])))

pxor 528(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_136
._step_136_end:

##### step 137 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_137
._step_137_end:

##### step 138 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_138
._step_138_end:

##### step 139 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_139
._step_139_end:

##### step 140 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_140
._step_140_end:

##### step 141 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_141
._step_141_end:

##### step 142 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_142
._step_142_end:

##### step 143 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_143
._step_143_end:

##### step 144 [hw=2]
##### F[ 0 ] ^= ( F[ 11 ] ^= ( F[ 34 ])))

pxor 544(%rdi), %xmm11
pxor %xmm11, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_144
._step_144_end:

##### step 145 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 12 ])))

pxor %xmm12, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_145
._step_145_end:

##### step 146 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 13 ])))

pxor %xmm13, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_146
._step_146_end:

##### step 147 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_147
._step_147_end:

##### step 148 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 14 ])))

pxor 224(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_148
._step_148_end:

##### step 149 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_149
._step_149_end:

##### step 150 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_150
._step_150_end:

##### step 151 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_151
._step_151_end:

##### step 152 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 15 ])))

pxor 240(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_152
._step_152_end:

##### step 153 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_153
._step_153_end:

##### step 154 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_154
._step_154_end:

##### step 155 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_155
._step_155_end:

##### step 156 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_156
._step_156_end:

##### step 157 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_157
._step_157_end:

##### step 158 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_158
._step_158_end:

##### step 159 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_159
._step_159_end:

##### step 160 [hw=2]
##### F[ 0 ] ^= ( F[ 16 ] ^= ( F[ 35 ])))

movdqa 560(%rdi), %xmm14
pxor 256(%rdi), %xmm14
movdqa %xmm14, 256(%rdi)
pxor %xmm14, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_160
._step_160_end:

##### step 161 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 17 ])))

pxor 272(%rdi), %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_161
._step_161_end:

##### step 162 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 18 ])))

pxor 288(%rdi), %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_162
._step_162_end:

##### step 163 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_163
._step_163_end:

##### step 164 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 19 ])))

pxor 304(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_164
._step_164_end:

##### step 165 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_165
._step_165_end:

##### step 166 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_166
._step_166_end:

##### step 167 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_167
._step_167_end:

##### step 168 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 20 ])))

pxor 320(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_168
._step_168_end:

##### step 169 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_169
._step_169_end:

##### step 170 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_170
._step_170_end:

##### step 171 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_171
._step_171_end:

##### step 172 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_172
._step_172_end:

##### step 173 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_173
._step_173_end:

##### step 174 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_174
._step_174_end:

##### step 175 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_175
._step_175_end:

##### step 176 [hw=2]
##### F[ 0 ] ^= ( F[ 11 ] ^= ( F[ 21 ])))

pxor 336(%rdi), %xmm11
pxor %xmm11, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_176
._step_176_end:

##### step 177 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 12 ])))

pxor %xmm12, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_177
._step_177_end:

##### step 178 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 13 ])))

pxor %xmm13, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_178
._step_178_end:

##### step 179 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_179
._step_179_end:

##### step 180 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 14 ])))

pxor 224(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_180
._step_180_end:

##### step 181 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_181
._step_181_end:

##### step 182 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_182
._step_182_end:

##### step 183 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_183
._step_183_end:

##### step 184 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 15 ])))

pxor 240(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_184
._step_184_end:

##### step 185 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_185
._step_185_end:

##### step 186 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_186
._step_186_end:

##### step 187 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_187
._step_187_end:

##### step 188 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_188
._step_188_end:

##### step 189 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_189
._step_189_end:

##### step 190 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_190
._step_190_end:

##### step 191 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_191
._step_191_end:

##### step 192 [hw=2]
##### F[ 0 ] ^= ( F[ 22 ] ^= ( F[ 36 ])))

movdqa 576(%rdi), %xmm14
pxor 352(%rdi), %xmm14
movdqa %xmm14, 352(%rdi)
pxor %xmm14, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_192
._step_192_end:

##### step 193 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 23 ])))

pxor 368(%rdi), %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_193
._step_193_end:

##### step 194 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 24 ])))

pxor 384(%rdi), %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_194
._step_194_end:

##### step 195 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_195
._step_195_end:

##### step 196 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 25 ])))

pxor 400(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_196
._step_196_end:

##### step 197 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_197
._step_197_end:

##### step 198 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_198
._step_198_end:

##### step 199 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_199
._step_199_end:

##### step 200 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 26 ])))

pxor 416(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_200
._step_200_end:

##### step 201 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_201
._step_201_end:

##### step 202 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_202
._step_202_end:

##### step 203 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_203
._step_203_end:

##### step 204 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_204
._step_204_end:

##### step 205 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_205
._step_205_end:

##### step 206 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_206
._step_206_end:

##### step 207 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_207
._step_207_end:

##### step 208 [hw=2]
##### F[ 0 ] ^= ( F[ 11 ] ^= ( F[ 27 ])))

pxor 432(%rdi), %xmm11
pxor %xmm11, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_208
._step_208_end:

##### step 209 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 12 ])))

pxor %xmm12, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_209
._step_209_end:

##### step 210 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 13 ])))

pxor %xmm13, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_210
._step_210_end:

##### step 211 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_211
._step_211_end:

##### step 212 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 14 ])))

pxor 224(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_212
._step_212_end:

##### step 213 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_213
._step_213_end:

##### step 214 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_214
._step_214_end:

##### step 215 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_215
._step_215_end:

##### step 216 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 15 ])))

pxor 240(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_216
._step_216_end:

##### step 217 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_217
._step_217_end:

##### step 218 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_218
._step_218_end:

##### step 219 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_219
._step_219_end:

##### step 220 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_220
._step_220_end:

##### step 221 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_221
._step_221_end:

##### step 222 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_222
._step_222_end:

##### step 223 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_223
._step_223_end:

##### step 224 [hw=2]
##### F[ 0 ] ^= ( F[ 16 ] ^= ( F[ 28 ])))

movdqa 448(%rdi), %xmm14
pxor 256(%rdi), %xmm14
movdqa %xmm14, 256(%rdi)
pxor %xmm14, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_224
._step_224_end:

##### step 225 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 17 ])))

pxor 272(%rdi), %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_225
._step_225_end:

##### step 226 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 18 ])))

pxor 288(%rdi), %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_226
._step_226_end:

##### step 227 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_227
._step_227_end:

##### step 228 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 19 ])))

pxor 304(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_228
._step_228_end:

##### step 229 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_229
._step_229_end:

##### step 230 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_230
._step_230_end:

##### step 231 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_231
._step_231_end:

##### step 232 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 20 ])))

pxor 320(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_232
._step_232_end:

##### step 233 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_233
._step_233_end:

##### step 234 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_234
._step_234_end:

##### step 235 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_235
._step_235_end:

##### step 236 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_236
._step_236_end:

##### step 237 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_237
._step_237_end:

##### step 238 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_238
._step_238_end:

##### step 239 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_239
._step_239_end:

##### step 240 [hw=2]
##### F[ 0 ] ^= ( F[ 11 ] ^= ( F[ 21 ])))

pxor 336(%rdi), %xmm11
pxor %xmm11, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_240
._step_240_end:

##### step 241 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 12 ])))

pxor %xmm12, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_241
._step_241_end:

##### step 242 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 13 ])))

pxor %xmm13, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_242
._step_242_end:

##### step 243 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_243
._step_243_end:

##### step 244 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 14 ])))

pxor 224(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_244
._step_244_end:

##### step 245 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_245
._step_245_end:

##### step 246 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_246
._step_246_end:

##### step 247 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_247
._step_247_end:

##### step 248 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 15 ])))

pxor 240(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_248
._step_248_end:

##### step 249 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_249
._step_249_end:

##### step 250 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_250
._step_250_end:

##### step 251 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_251
._step_251_end:

##### step 252 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_252
._step_252_end:

##### step 253 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_253
._step_253_end:

##### step 254 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_254
._step_254_end:

##### step 255 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_255
._step_255_end:

##### step 256 [hw=1]
##### F[ 0 ] ^= ( F[ 37 ] ^= ( F[ alpha + 9 ])))

movdqa 144(%rdi,%rsi), %xmm14
pxor 592(%rdi), %xmm14
movdqa %xmm14, 592(%rdi)
pxor %xmm14, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_256
._step_256_end:

##### step 257 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 38 ])))

pxor 608(%rdi), %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_257
._step_257_end:

##### step 258 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 39 ])))

pxor 624(%rdi), %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_258
._step_258_end:

##### step 259 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_259
._step_259_end:

##### step 260 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 40 ])))

pxor 640(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_260
._step_260_end:

##### step 261 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_261
._step_261_end:

##### step 262 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_262
._step_262_end:

##### step 263 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_263
._step_263_end:

##### step 264 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 41 ])))

pxor 656(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_264
._step_264_end:

##### step 265 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_265
._step_265_end:

##### step 266 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_266
._step_266_end:

##### step 267 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_267
._step_267_end:

##### step 268 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_268
._step_268_end:

##### step 269 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_269
._step_269_end:

##### step 270 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_270
._step_270_end:

##### step 271 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_271
._step_271_end:

##### step 272 [hw=2]
##### F[ 0 ] ^= ( F[ 11 ] ^= ( F[ 42 ])))

pxor 672(%rdi), %xmm11
pxor %xmm11, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_272
._step_272_end:

##### step 273 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 12 ])))

pxor %xmm12, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_273
._step_273_end:

##### step 274 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 13 ])))

pxor %xmm13, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_274
._step_274_end:

##### step 275 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_275
._step_275_end:

##### step 276 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 14 ])))

pxor 224(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_276
._step_276_end:

##### step 277 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_277
._step_277_end:

##### step 278 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_278
._step_278_end:

##### step 279 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_279
._step_279_end:

##### step 280 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 15 ])))

pxor 240(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_280
._step_280_end:

##### step 281 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_281
._step_281_end:

##### step 282 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_282
._step_282_end:

##### step 283 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_283
._step_283_end:

##### step 284 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_284
._step_284_end:

##### step 285 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_285
._step_285_end:

##### step 286 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_286
._step_286_end:

##### step 287 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_287
._step_287_end:

##### step 288 [hw=2]
##### F[ 0 ] ^= ( F[ 16 ] ^= ( F[ 43 ])))

movdqa 688(%rdi), %xmm14
pxor 256(%rdi), %xmm14
movdqa %xmm14, 256(%rdi)
pxor %xmm14, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_288
._step_288_end:

##### step 289 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 17 ])))

pxor 272(%rdi), %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_289
._step_289_end:

##### step 290 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 18 ])))

pxor 288(%rdi), %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_290
._step_290_end:

##### step 291 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_291
._step_291_end:

##### step 292 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 19 ])))

pxor 304(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_292
._step_292_end:

##### step 293 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_293
._step_293_end:

##### step 294 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_294
._step_294_end:

##### step 295 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_295
._step_295_end:

##### step 296 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 20 ])))

pxor 320(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_296
._step_296_end:

##### step 297 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_297
._step_297_end:

##### step 298 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_298
._step_298_end:

##### step 299 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_299
._step_299_end:

##### step 300 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_300
._step_300_end:

##### step 301 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_301
._step_301_end:

##### step 302 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_302
._step_302_end:

##### step 303 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_303
._step_303_end:

##### step 304 [hw=2]
##### F[ 0 ] ^= ( F[ 11 ] ^= ( F[ 21 ])))

pxor 336(%rdi), %xmm11
pxor %xmm11, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_304
._step_304_end:

##### step 305 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 12 ])))

pxor %xmm12, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_305
._step_305_end:

##### step 306 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 13 ])))

pxor %xmm13, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_306
._step_306_end:

##### step 307 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_307
._step_307_end:

##### step 308 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 14 ])))

pxor 224(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_308
._step_308_end:

##### step 309 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_309
._step_309_end:

##### step 310 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_310
._step_310_end:

##### step 311 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_311
._step_311_end:

##### step 312 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 15 ])))

pxor 240(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_312
._step_312_end:

##### step 313 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_313
._step_313_end:

##### step 314 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_314
._step_314_end:

##### step 315 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_315
._step_315_end:

##### step 316 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_316
._step_316_end:

##### step 317 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_317
._step_317_end:

##### step 318 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_318
._step_318_end:

##### step 319 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_319
._step_319_end:

##### step 320 [hw=2]
##### F[ 0 ] ^= ( F[ 22 ] ^= ( F[ 44 ])))

movdqa 704(%rdi), %xmm14
pxor 352(%rdi), %xmm14
movdqa %xmm14, 352(%rdi)
pxor %xmm14, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_320
._step_320_end:

##### step 321 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 23 ])))

pxor 368(%rdi), %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_321
._step_321_end:

##### step 322 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 24 ])))

pxor 384(%rdi), %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_322
._step_322_end:

##### step 323 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_323
._step_323_end:

##### step 324 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 25 ])))

pxor 400(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_324
._step_324_end:

##### step 325 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_325
._step_325_end:

##### step 326 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_326
._step_326_end:

##### step 327 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_327
._step_327_end:

##### step 328 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 26 ])))

pxor 416(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_328
._step_328_end:

##### step 329 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_329
._step_329_end:

##### step 330 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_330
._step_330_end:

##### step 331 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_331
._step_331_end:

##### step 332 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_332
._step_332_end:

##### step 333 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_333
._step_333_end:

##### step 334 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_334
._step_334_end:

##### step 335 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_335
._step_335_end:

##### step 336 [hw=2]
##### F[ 0 ] ^= ( F[ 11 ] ^= ( F[ 27 ])))

pxor 432(%rdi), %xmm11
pxor %xmm11, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_336
._step_336_end:

##### step 337 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 12 ])))

pxor %xmm12, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_337
._step_337_end:

##### step 338 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 13 ])))

pxor %xmm13, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_338
._step_338_end:

##### step 339 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_339
._step_339_end:

##### step 340 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 14 ])))

pxor 224(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_340
._step_340_end:

##### step 341 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_341
._step_341_end:

##### step 342 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_342
._step_342_end:

##### step 343 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_343
._step_343_end:

##### step 344 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 15 ])))

pxor 240(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_344
._step_344_end:

##### step 345 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_345
._step_345_end:

##### step 346 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_346
._step_346_end:

##### step 347 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_347
._step_347_end:

##### step 348 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_348
._step_348_end:

##### step 349 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_349
._step_349_end:

##### step 350 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_350
._step_350_end:

##### step 351 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_351
._step_351_end:

##### step 352 [hw=2]
##### F[ 0 ] ^= ( F[ 16 ] ^= ( F[ 28 ])))

movdqa 448(%rdi), %xmm14
pxor 256(%rdi), %xmm14
movdqa %xmm14, 256(%rdi)
pxor %xmm14, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_352
._step_352_end:

##### step 353 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 17 ])))

pxor 272(%rdi), %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_353
._step_353_end:

##### step 354 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 18 ])))

pxor 288(%rdi), %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_354
._step_354_end:

##### step 355 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_355
._step_355_end:

##### step 356 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 19 ])))

pxor 304(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_356
._step_356_end:

##### step 357 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_357
._step_357_end:

##### step 358 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_358
._step_358_end:

##### step 359 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_359
._step_359_end:

##### step 360 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 20 ])))

pxor 320(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_360
._step_360_end:

##### step 361 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_361
._step_361_end:

##### step 362 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_362
._step_362_end:

##### step 363 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_363
._step_363_end:

##### step 364 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_364
._step_364_end:

##### step 365 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_365
._step_365_end:

##### step 366 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_366
._step_366_end:

##### step 367 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_367
._step_367_end:

##### step 368 [hw=2]
##### F[ 0 ] ^= ( F[ 11 ] ^= ( F[ 21 ])))

pxor 336(%rdi), %xmm11
pxor %xmm11, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_368
._step_368_end:

##### step 369 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 12 ])))

pxor %xmm12, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_369
._step_369_end:

##### step 370 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 13 ])))

pxor %xmm13, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_370
._step_370_end:

##### step 371 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_371
._step_371_end:

##### step 372 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 14 ])))

pxor 224(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_372
._step_372_end:

##### step 373 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_373
._step_373_end:

##### step 374 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_374
._step_374_end:

##### step 375 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_375
._step_375_end:

##### step 376 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 15 ])))

pxor 240(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_376
._step_376_end:

##### step 377 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_377
._step_377_end:

##### step 378 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_378
._step_378_end:

##### step 379 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_379
._step_379_end:

##### step 380 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_380
._step_380_end:

##### step 381 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_381
._step_381_end:

##### step 382 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_382
._step_382_end:

##### step 383 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_383
._step_383_end:

##### step 384 [hw=2]
##### F[ 0 ] ^= ( F[ 29 ] ^= ( F[ 45 ])))

movdqa 720(%rdi), %xmm14
pxor 464(%rdi), %xmm14
movdqa %xmm14, 464(%rdi)
pxor %xmm14, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_384
._step_384_end:

##### step 385 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 30 ])))

pxor 480(%rdi), %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_385
._step_385_end:

##### step 386 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 31 ])))

pxor 496(%rdi), %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_386
._step_386_end:

##### step 387 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_387
._step_387_end:

##### step 388 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 32 ])))

pxor 512(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_388
._step_388_end:

##### step 389 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_389
._step_389_end:

##### step 390 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_390
._step_390_end:

##### step 391 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_391
._step_391_end:

##### step 392 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 33 ])))

pxor 528(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_392
._step_392_end:

##### step 393 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_393
._step_393_end:

##### step 394 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_394
._step_394_end:

##### step 395 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_395
._step_395_end:

##### step 396 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_396
._step_396_end:

##### step 397 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_397
._step_397_end:

##### step 398 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_398
._step_398_end:

##### step 399 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_399
._step_399_end:

##### step 400 [hw=2]
##### F[ 0 ] ^= ( F[ 11 ] ^= ( F[ 34 ])))

pxor 544(%rdi), %xmm11
pxor %xmm11, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_400
._step_400_end:

##### step 401 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 12 ])))

pxor %xmm12, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_401
._step_401_end:

##### step 402 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 13 ])))

pxor %xmm13, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_402
._step_402_end:

##### step 403 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_403
._step_403_end:

##### step 404 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 14 ])))

pxor 224(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_404
._step_404_end:

##### step 405 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_405
._step_405_end:

##### step 406 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_406
._step_406_end:

##### step 407 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_407
._step_407_end:

##### step 408 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 15 ])))

pxor 240(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_408
._step_408_end:

##### step 409 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_409
._step_409_end:

##### step 410 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_410
._step_410_end:

##### step 411 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_411
._step_411_end:

##### step 412 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_412
._step_412_end:

##### step 413 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_413
._step_413_end:

##### step 414 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_414
._step_414_end:

##### step 415 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_415
._step_415_end:

##### step 416 [hw=2]
##### F[ 0 ] ^= ( F[ 16 ] ^= ( F[ 35 ])))

movdqa 560(%rdi), %xmm14
pxor 256(%rdi), %xmm14
movdqa %xmm14, 256(%rdi)
pxor %xmm14, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_416
._step_416_end:

##### step 417 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 17 ])))

pxor 272(%rdi), %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_417
._step_417_end:

##### step 418 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 18 ])))

pxor 288(%rdi), %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_418
._step_418_end:

##### step 419 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_419
._step_419_end:

##### step 420 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 19 ])))

pxor 304(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_420
._step_420_end:

##### step 421 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_421
._step_421_end:

##### step 422 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_422
._step_422_end:

##### step 423 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_423
._step_423_end:

##### step 424 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 20 ])))

pxor 320(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_424
._step_424_end:

##### step 425 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_425
._step_425_end:

##### step 426 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_426
._step_426_end:

##### step 427 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_427
._step_427_end:

##### step 428 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_428
._step_428_end:

##### step 429 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_429
._step_429_end:

##### step 430 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_430
._step_430_end:

##### step 431 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_431
._step_431_end:

##### step 432 [hw=2]
##### F[ 0 ] ^= ( F[ 11 ] ^= ( F[ 21 ])))

pxor 336(%rdi), %xmm11
pxor %xmm11, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_432
._step_432_end:

##### step 433 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 12 ])))

pxor %xmm12, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_433
._step_433_end:

##### step 434 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 13 ])))

pxor %xmm13, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_434
._step_434_end:

##### step 435 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_435
._step_435_end:

##### step 436 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 14 ])))

pxor 224(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_436
._step_436_end:

##### step 437 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_437
._step_437_end:

##### step 438 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_438
._step_438_end:

##### step 439 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_439
._step_439_end:

##### step 440 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 15 ])))

pxor 240(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_440
._step_440_end:

##### step 441 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_441
._step_441_end:

##### step 442 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_442
._step_442_end:

##### step 443 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_443
._step_443_end:

##### step 444 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_444
._step_444_end:

##### step 445 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_445
._step_445_end:

##### step 446 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_446
._step_446_end:

##### step 447 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_447
._step_447_end:

##### step 448 [hw=2]
##### F[ 0 ] ^= ( F[ 22 ] ^= ( F[ 36 ])))

movdqa 576(%rdi), %xmm14
pxor 352(%rdi), %xmm14
movdqa %xmm14, 352(%rdi)
pxor %xmm14, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_448
._step_448_end:

##### step 449 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 23 ])))

pxor 368(%rdi), %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_449
._step_449_end:

##### step 450 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 24 ])))

pxor 384(%rdi), %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_450
._step_450_end:

##### step 451 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_451
._step_451_end:

##### step 452 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 25 ])))

pxor 400(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_452
._step_452_end:

##### step 453 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_453
._step_453_end:

##### step 454 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_454
._step_454_end:

##### step 455 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_455
._step_455_end:

##### step 456 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 26 ])))

pxor 416(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_456
._step_456_end:

##### step 457 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_457
._step_457_end:

##### step 458 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_458
._step_458_end:

##### step 459 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_459
._step_459_end:

##### step 460 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_460
._step_460_end:

##### step 461 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_461
._step_461_end:

##### step 462 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_462
._step_462_end:

##### step 463 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_463
._step_463_end:

##### step 464 [hw=2]
##### F[ 0 ] ^= ( F[ 11 ] ^= ( F[ 27 ])))

pxor 432(%rdi), %xmm11
pxor %xmm11, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_464
._step_464_end:

##### step 465 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 12 ])))

pxor %xmm12, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_465
._step_465_end:

##### step 466 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 13 ])))

pxor %xmm13, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_466
._step_466_end:

##### step 467 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_467
._step_467_end:

##### step 468 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 14 ])))

pxor 224(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_468
._step_468_end:

##### step 469 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_469
._step_469_end:

##### step 470 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_470
._step_470_end:

##### step 471 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_471
._step_471_end:

##### step 472 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 15 ])))

pxor 240(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_472
._step_472_end:

##### step 473 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_473
._step_473_end:

##### step 474 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_474
._step_474_end:

##### step 475 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_475
._step_475_end:

##### step 476 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_476
._step_476_end:

##### step 477 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_477
._step_477_end:

##### step 478 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_478
._step_478_end:

##### step 479 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_479
._step_479_end:

##### step 480 [hw=2]
##### F[ 0 ] ^= ( F[ 16 ] ^= ( F[ 28 ])))

movdqa 448(%rdi), %xmm14
pxor 256(%rdi), %xmm14
movdqa %xmm14, 256(%rdi)
pxor %xmm14, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_480
._step_480_end:

##### step 481 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 17 ])))

pxor 272(%rdi), %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_481
._step_481_end:

##### step 482 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 18 ])))

pxor 288(%rdi), %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_482
._step_482_end:

##### step 483 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_483
._step_483_end:

##### step 484 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 19 ])))

pxor 304(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_484
._step_484_end:

##### step 485 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_485
._step_485_end:

##### step 486 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_486
._step_486_end:

##### step 487 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_487
._step_487_end:

##### step 488 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 20 ])))

pxor 320(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_488
._step_488_end:

##### step 489 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_489
._step_489_end:

##### step 490 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_490
._step_490_end:

##### step 491 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_491
._step_491_end:

##### step 492 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_492
._step_492_end:

##### step 493 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_493
._step_493_end:

##### step 494 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_494
._step_494_end:

##### step 495 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_495
._step_495_end:

##### step 496 [hw=2]
##### F[ 0 ] ^= ( F[ 11 ] ^= ( F[ 21 ])))

pxor 336(%rdi), %xmm11
pxor %xmm11, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_496
._step_496_end:

##### step 497 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 12 ])))

pxor %xmm12, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_497
._step_497_end:

##### step 498 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 13 ])))

pxor %xmm13, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_498
._step_498_end:

##### step 499 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_499
._step_499_end:

##### step 500 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 14 ])))

pxor 224(%rdi), %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_500
._step_500_end:

##### step 501 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_501
._step_501_end:

##### step 502 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_502
._step_502_end:

##### step 503 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_503
._step_503_end:

##### step 504 [hw=2]
##### F[ 0 ] ^= ( F[ 7 ] ^= ( F[ 15 ])))

pxor 240(%rdi), %xmm7
pxor %xmm7, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_504
._step_504_end:

##### step 505 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 8 ])))

pxor %xmm8, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_505
._step_505_end:

##### step 506 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 9 ])))

pxor %xmm9, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_506
._step_506_end:

##### step 507 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_507
._step_507_end:

##### step 508 [hw=2]
##### F[ 0 ] ^= ( F[ 4 ] ^= ( F[ 10 ])))

pxor %xmm10, %xmm4
pxor %xmm4, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_508
._step_508_end:

##### step 509 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 5 ])))

pxor %xmm5, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_509
._step_509_end:

##### step 510 [hw=2]
##### F[ 0 ] ^= ( F[ 2 ] ^= ( F[ 6 ])))

pxor %xmm6, %xmm2
pxor %xmm2, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_510
._step_510_end:

##### step 511 [hw=2]
##### F[ 0 ] ^= ( F[ 1 ] ^= ( F[ 3 ])))

pxor %xmm3, %xmm1
pxor %xmm1, %xmm0
pcmpeqw %xmm0, %xmm15
pmovmskb %xmm15, %r10d
test %r10d, %r10d
jne ._report_solution_511
._step_511_end:
#############################
# end of the unrolled chunk #
#############################
jmp ._ending
########### now the code that reports solutions
# here, it has been found that GrayCode(idx+1) is a solution
._report_solution_1:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $1, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_1_end

# here, it has been found that GrayCode(idx+2) is a solution
._report_solution_2:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $2, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_2_end

# here, it has been found that GrayCode(idx+3) is a solution
._report_solution_3:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $3, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_3_end

# here, it has been found that GrayCode(idx+4) is a solution
._report_solution_4:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $4, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_4_end

# here, it has been found that GrayCode(idx+5) is a solution
._report_solution_5:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $5, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_5_end

# here, it has been found that GrayCode(idx+6) is a solution
._report_solution_6:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $6, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_6_end

# here, it has been found that GrayCode(idx+7) is a solution
._report_solution_7:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $7, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_7_end

# here, it has been found that GrayCode(idx+8) is a solution
._report_solution_8:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $8, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_8_end

# here, it has been found that GrayCode(idx+9) is a solution
._report_solution_9:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $9, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_9_end

# here, it has been found that GrayCode(idx+10) is a solution
._report_solution_10:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $10, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_10_end

# here, it has been found that GrayCode(idx+11) is a solution
._report_solution_11:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $11, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_11_end

# here, it has been found that GrayCode(idx+12) is a solution
._report_solution_12:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $12, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_12_end

# here, it has been found that GrayCode(idx+13) is a solution
._report_solution_13:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $13, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_13_end

# here, it has been found that GrayCode(idx+14) is a solution
._report_solution_14:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $14, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_14_end

# here, it has been found that GrayCode(idx+15) is a solution
._report_solution_15:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $15, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_15_end

# here, it has been found that GrayCode(idx+16) is a solution
._report_solution_16:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $16, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_16_end

# here, it has been found that GrayCode(idx+17) is a solution
._report_solution_17:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $17, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_17_end

# here, it has been found that GrayCode(idx+18) is a solution
._report_solution_18:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $18, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_18_end

# here, it has been found that GrayCode(idx+19) is a solution
._report_solution_19:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $19, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_19_end

# here, it has been found that GrayCode(idx+20) is a solution
._report_solution_20:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $20, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_20_end

# here, it has been found that GrayCode(idx+21) is a solution
._report_solution_21:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $21, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_21_end

# here, it has been found that GrayCode(idx+22) is a solution
._report_solution_22:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $22, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_22_end

# here, it has been found that GrayCode(idx+23) is a solution
._report_solution_23:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $23, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_23_end

# here, it has been found that GrayCode(idx+24) is a solution
._report_solution_24:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $24, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_24_end

# here, it has been found that GrayCode(idx+25) is a solution
._report_solution_25:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $25, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_25_end

# here, it has been found that GrayCode(idx+26) is a solution
._report_solution_26:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $26, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_26_end

# here, it has been found that GrayCode(idx+27) is a solution
._report_solution_27:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $27, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_27_end

# here, it has been found that GrayCode(idx+28) is a solution
._report_solution_28:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $28, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_28_end

# here, it has been found that GrayCode(idx+29) is a solution
._report_solution_29:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $29, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_29_end

# here, it has been found that GrayCode(idx+30) is a solution
._report_solution_30:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $30, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_30_end

# here, it has been found that GrayCode(idx+31) is a solution
._report_solution_31:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $31, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_31_end

# here, it has been found that GrayCode(idx+32) is a solution
._report_solution_32:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $32, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_32_end

# here, it has been found that GrayCode(idx+33) is a solution
._report_solution_33:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $33, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_33_end

# here, it has been found that GrayCode(idx+34) is a solution
._report_solution_34:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $34, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_34_end

# here, it has been found that GrayCode(idx+35) is a solution
._report_solution_35:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $35, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_35_end

# here, it has been found that GrayCode(idx+36) is a solution
._report_solution_36:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $36, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_36_end

# here, it has been found that GrayCode(idx+37) is a solution
._report_solution_37:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $37, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_37_end

# here, it has been found that GrayCode(idx+38) is a solution
._report_solution_38:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $38, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_38_end

# here, it has been found that GrayCode(idx+39) is a solution
._report_solution_39:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $39, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_39_end

# here, it has been found that GrayCode(idx+40) is a solution
._report_solution_40:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $40, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_40_end

# here, it has been found that GrayCode(idx+41) is a solution
._report_solution_41:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $41, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_41_end

# here, it has been found that GrayCode(idx+42) is a solution
._report_solution_42:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $42, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_42_end

# here, it has been found that GrayCode(idx+43) is a solution
._report_solution_43:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $43, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_43_end

# here, it has been found that GrayCode(idx+44) is a solution
._report_solution_44:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $44, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_44_end

# here, it has been found that GrayCode(idx+45) is a solution
._report_solution_45:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $45, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_45_end

# here, it has been found that GrayCode(idx+46) is a solution
._report_solution_46:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $46, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_46_end

# here, it has been found that GrayCode(idx+47) is a solution
._report_solution_47:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $47, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_47_end

# here, it has been found that GrayCode(idx+48) is a solution
._report_solution_48:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $48, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_48_end

# here, it has been found that GrayCode(idx+49) is a solution
._report_solution_49:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $49, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_49_end

# here, it has been found that GrayCode(idx+50) is a solution
._report_solution_50:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $50, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_50_end

# here, it has been found that GrayCode(idx+51) is a solution
._report_solution_51:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $51, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_51_end

# here, it has been found that GrayCode(idx+52) is a solution
._report_solution_52:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $52, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_52_end

# here, it has been found that GrayCode(idx+53) is a solution
._report_solution_53:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $53, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_53_end

# here, it has been found that GrayCode(idx+54) is a solution
._report_solution_54:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $54, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_54_end

# here, it has been found that GrayCode(idx+55) is a solution
._report_solution_55:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $55, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_55_end

# here, it has been found that GrayCode(idx+56) is a solution
._report_solution_56:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $56, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_56_end

# here, it has been found that GrayCode(idx+57) is a solution
._report_solution_57:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $57, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_57_end

# here, it has been found that GrayCode(idx+58) is a solution
._report_solution_58:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $58, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_58_end

# here, it has been found that GrayCode(idx+59) is a solution
._report_solution_59:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $59, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_59_end

# here, it has been found that GrayCode(idx+60) is a solution
._report_solution_60:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $60, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_60_end

# here, it has been found that GrayCode(idx+61) is a solution
._report_solution_61:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $61, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_61_end

# here, it has been found that GrayCode(idx+62) is a solution
._report_solution_62:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $62, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_62_end

# here, it has been found that GrayCode(idx+63) is a solution
._report_solution_63:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $63, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_63_end

# here, it has been found that GrayCode(idx+64) is a solution
._report_solution_64:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $64, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_64_end

# here, it has been found that GrayCode(idx+65) is a solution
._report_solution_65:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $65, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_65_end

# here, it has been found that GrayCode(idx+66) is a solution
._report_solution_66:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $66, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_66_end

# here, it has been found that GrayCode(idx+67) is a solution
._report_solution_67:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $67, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_67_end

# here, it has been found that GrayCode(idx+68) is a solution
._report_solution_68:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $68, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_68_end

# here, it has been found that GrayCode(idx+69) is a solution
._report_solution_69:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $69, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_69_end

# here, it has been found that GrayCode(idx+70) is a solution
._report_solution_70:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $70, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_70_end

# here, it has been found that GrayCode(idx+71) is a solution
._report_solution_71:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $71, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_71_end

# here, it has been found that GrayCode(idx+72) is a solution
._report_solution_72:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $72, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_72_end

# here, it has been found that GrayCode(idx+73) is a solution
._report_solution_73:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $73, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_73_end

# here, it has been found that GrayCode(idx+74) is a solution
._report_solution_74:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $74, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_74_end

# here, it has been found that GrayCode(idx+75) is a solution
._report_solution_75:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $75, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_75_end

# here, it has been found that GrayCode(idx+76) is a solution
._report_solution_76:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $76, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_76_end

# here, it has been found that GrayCode(idx+77) is a solution
._report_solution_77:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $77, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_77_end

# here, it has been found that GrayCode(idx+78) is a solution
._report_solution_78:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $78, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_78_end

# here, it has been found that GrayCode(idx+79) is a solution
._report_solution_79:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $79, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_79_end

# here, it has been found that GrayCode(idx+80) is a solution
._report_solution_80:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $80, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_80_end

# here, it has been found that GrayCode(idx+81) is a solution
._report_solution_81:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $81, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_81_end

# here, it has been found that GrayCode(idx+82) is a solution
._report_solution_82:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $82, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_82_end

# here, it has been found that GrayCode(idx+83) is a solution
._report_solution_83:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $83, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_83_end

# here, it has been found that GrayCode(idx+84) is a solution
._report_solution_84:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $84, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_84_end

# here, it has been found that GrayCode(idx+85) is a solution
._report_solution_85:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $85, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_85_end

# here, it has been found that GrayCode(idx+86) is a solution
._report_solution_86:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $86, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_86_end

# here, it has been found that GrayCode(idx+87) is a solution
._report_solution_87:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $87, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_87_end

# here, it has been found that GrayCode(idx+88) is a solution
._report_solution_88:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $88, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_88_end

# here, it has been found that GrayCode(idx+89) is a solution
._report_solution_89:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $89, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_89_end

# here, it has been found that GrayCode(idx+90) is a solution
._report_solution_90:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $90, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_90_end

# here, it has been found that GrayCode(idx+91) is a solution
._report_solution_91:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $91, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_91_end

# here, it has been found that GrayCode(idx+92) is a solution
._report_solution_92:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $92, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_92_end

# here, it has been found that GrayCode(idx+93) is a solution
._report_solution_93:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $93, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_93_end

# here, it has been found that GrayCode(idx+94) is a solution
._report_solution_94:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $94, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_94_end

# here, it has been found that GrayCode(idx+95) is a solution
._report_solution_95:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $95, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_95_end

# here, it has been found that GrayCode(idx+96) is a solution
._report_solution_96:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $96, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_96_end

# here, it has been found that GrayCode(idx+97) is a solution
._report_solution_97:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $97, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_97_end

# here, it has been found that GrayCode(idx+98) is a solution
._report_solution_98:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $98, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_98_end

# here, it has been found that GrayCode(idx+99) is a solution
._report_solution_99:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $99, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_99_end

# here, it has been found that GrayCode(idx+100) is a solution
._report_solution_100:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $100, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_100_end

# here, it has been found that GrayCode(idx+101) is a solution
._report_solution_101:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $101, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_101_end

# here, it has been found that GrayCode(idx+102) is a solution
._report_solution_102:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $102, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_102_end

# here, it has been found that GrayCode(idx+103) is a solution
._report_solution_103:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $103, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_103_end

# here, it has been found that GrayCode(idx+104) is a solution
._report_solution_104:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $104, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_104_end

# here, it has been found that GrayCode(idx+105) is a solution
._report_solution_105:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $105, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_105_end

# here, it has been found that GrayCode(idx+106) is a solution
._report_solution_106:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $106, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_106_end

# here, it has been found that GrayCode(idx+107) is a solution
._report_solution_107:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $107, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_107_end

# here, it has been found that GrayCode(idx+108) is a solution
._report_solution_108:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $108, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_108_end

# here, it has been found that GrayCode(idx+109) is a solution
._report_solution_109:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $109, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_109_end

# here, it has been found that GrayCode(idx+110) is a solution
._report_solution_110:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $110, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_110_end

# here, it has been found that GrayCode(idx+111) is a solution
._report_solution_111:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $111, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_111_end

# here, it has been found that GrayCode(idx+112) is a solution
._report_solution_112:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $112, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_112_end

# here, it has been found that GrayCode(idx+113) is a solution
._report_solution_113:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $113, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_113_end

# here, it has been found that GrayCode(idx+114) is a solution
._report_solution_114:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $114, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_114_end

# here, it has been found that GrayCode(idx+115) is a solution
._report_solution_115:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $115, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_115_end

# here, it has been found that GrayCode(idx+116) is a solution
._report_solution_116:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $116, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_116_end

# here, it has been found that GrayCode(idx+117) is a solution
._report_solution_117:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $117, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_117_end

# here, it has been found that GrayCode(idx+118) is a solution
._report_solution_118:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $118, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_118_end

# here, it has been found that GrayCode(idx+119) is a solution
._report_solution_119:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $119, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_119_end

# here, it has been found that GrayCode(idx+120) is a solution
._report_solution_120:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $120, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_120_end

# here, it has been found that GrayCode(idx+121) is a solution
._report_solution_121:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $121, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_121_end

# here, it has been found that GrayCode(idx+122) is a solution
._report_solution_122:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $122, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_122_end

# here, it has been found that GrayCode(idx+123) is a solution
._report_solution_123:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $123, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_123_end

# here, it has been found that GrayCode(idx+124) is a solution
._report_solution_124:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $124, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_124_end

# here, it has been found that GrayCode(idx+125) is a solution
._report_solution_125:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $125, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_125_end

# here, it has been found that GrayCode(idx+126) is a solution
._report_solution_126:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $126, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_126_end

# here, it has been found that GrayCode(idx+127) is a solution
._report_solution_127:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $127, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_127_end

# here, it has been found that GrayCode(idx+128) is a solution
._report_solution_128:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $128, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_128_end

# here, it has been found that GrayCode(idx+129) is a solution
._report_solution_129:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $129, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_129_end

# here, it has been found that GrayCode(idx+130) is a solution
._report_solution_130:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $130, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_130_end

# here, it has been found that GrayCode(idx+131) is a solution
._report_solution_131:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $131, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_131_end

# here, it has been found that GrayCode(idx+132) is a solution
._report_solution_132:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $132, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_132_end

# here, it has been found that GrayCode(idx+133) is a solution
._report_solution_133:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $133, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_133_end

# here, it has been found that GrayCode(idx+134) is a solution
._report_solution_134:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $134, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_134_end

# here, it has been found that GrayCode(idx+135) is a solution
._report_solution_135:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $135, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_135_end

# here, it has been found that GrayCode(idx+136) is a solution
._report_solution_136:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $136, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_136_end

# here, it has been found that GrayCode(idx+137) is a solution
._report_solution_137:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $137, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_137_end

# here, it has been found that GrayCode(idx+138) is a solution
._report_solution_138:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $138, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_138_end

# here, it has been found that GrayCode(idx+139) is a solution
._report_solution_139:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $139, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_139_end

# here, it has been found that GrayCode(idx+140) is a solution
._report_solution_140:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $140, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_140_end

# here, it has been found that GrayCode(idx+141) is a solution
._report_solution_141:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $141, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_141_end

# here, it has been found that GrayCode(idx+142) is a solution
._report_solution_142:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $142, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_142_end

# here, it has been found that GrayCode(idx+143) is a solution
._report_solution_143:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $143, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_143_end

# here, it has been found that GrayCode(idx+144) is a solution
._report_solution_144:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $144, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_144_end

# here, it has been found that GrayCode(idx+145) is a solution
._report_solution_145:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $145, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_145_end

# here, it has been found that GrayCode(idx+146) is a solution
._report_solution_146:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $146, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_146_end

# here, it has been found that GrayCode(idx+147) is a solution
._report_solution_147:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $147, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_147_end

# here, it has been found that GrayCode(idx+148) is a solution
._report_solution_148:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $148, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_148_end

# here, it has been found that GrayCode(idx+149) is a solution
._report_solution_149:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $149, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_149_end

# here, it has been found that GrayCode(idx+150) is a solution
._report_solution_150:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $150, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_150_end

# here, it has been found that GrayCode(idx+151) is a solution
._report_solution_151:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $151, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_151_end

# here, it has been found that GrayCode(idx+152) is a solution
._report_solution_152:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $152, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_152_end

# here, it has been found that GrayCode(idx+153) is a solution
._report_solution_153:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $153, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_153_end

# here, it has been found that GrayCode(idx+154) is a solution
._report_solution_154:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $154, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_154_end

# here, it has been found that GrayCode(idx+155) is a solution
._report_solution_155:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $155, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_155_end

# here, it has been found that GrayCode(idx+156) is a solution
._report_solution_156:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $156, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_156_end

# here, it has been found that GrayCode(idx+157) is a solution
._report_solution_157:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $157, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_157_end

# here, it has been found that GrayCode(idx+158) is a solution
._report_solution_158:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $158, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_158_end

# here, it has been found that GrayCode(idx+159) is a solution
._report_solution_159:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $159, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_159_end

# here, it has been found that GrayCode(idx+160) is a solution
._report_solution_160:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $160, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_160_end

# here, it has been found that GrayCode(idx+161) is a solution
._report_solution_161:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $161, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_161_end

# here, it has been found that GrayCode(idx+162) is a solution
._report_solution_162:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $162, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_162_end

# here, it has been found that GrayCode(idx+163) is a solution
._report_solution_163:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $163, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_163_end

# here, it has been found that GrayCode(idx+164) is a solution
._report_solution_164:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $164, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_164_end

# here, it has been found that GrayCode(idx+165) is a solution
._report_solution_165:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $165, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_165_end

# here, it has been found that GrayCode(idx+166) is a solution
._report_solution_166:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $166, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_166_end

# here, it has been found that GrayCode(idx+167) is a solution
._report_solution_167:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $167, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_167_end

# here, it has been found that GrayCode(idx+168) is a solution
._report_solution_168:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $168, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_168_end

# here, it has been found that GrayCode(idx+169) is a solution
._report_solution_169:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $169, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_169_end

# here, it has been found that GrayCode(idx+170) is a solution
._report_solution_170:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $170, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_170_end

# here, it has been found that GrayCode(idx+171) is a solution
._report_solution_171:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $171, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_171_end

# here, it has been found that GrayCode(idx+172) is a solution
._report_solution_172:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $172, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_172_end

# here, it has been found that GrayCode(idx+173) is a solution
._report_solution_173:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $173, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_173_end

# here, it has been found that GrayCode(idx+174) is a solution
._report_solution_174:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $174, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_174_end

# here, it has been found that GrayCode(idx+175) is a solution
._report_solution_175:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $175, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_175_end

# here, it has been found that GrayCode(idx+176) is a solution
._report_solution_176:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $176, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_176_end

# here, it has been found that GrayCode(idx+177) is a solution
._report_solution_177:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $177, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_177_end

# here, it has been found that GrayCode(idx+178) is a solution
._report_solution_178:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $178, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_178_end

# here, it has been found that GrayCode(idx+179) is a solution
._report_solution_179:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $179, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_179_end

# here, it has been found that GrayCode(idx+180) is a solution
._report_solution_180:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $180, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_180_end

# here, it has been found that GrayCode(idx+181) is a solution
._report_solution_181:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $181, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_181_end

# here, it has been found that GrayCode(idx+182) is a solution
._report_solution_182:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $182, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_182_end

# here, it has been found that GrayCode(idx+183) is a solution
._report_solution_183:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $183, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_183_end

# here, it has been found that GrayCode(idx+184) is a solution
._report_solution_184:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $184, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_184_end

# here, it has been found that GrayCode(idx+185) is a solution
._report_solution_185:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $185, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_185_end

# here, it has been found that GrayCode(idx+186) is a solution
._report_solution_186:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $186, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_186_end

# here, it has been found that GrayCode(idx+187) is a solution
._report_solution_187:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $187, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_187_end

# here, it has been found that GrayCode(idx+188) is a solution
._report_solution_188:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $188, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_188_end

# here, it has been found that GrayCode(idx+189) is a solution
._report_solution_189:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $189, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_189_end

# here, it has been found that GrayCode(idx+190) is a solution
._report_solution_190:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $190, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_190_end

# here, it has been found that GrayCode(idx+191) is a solution
._report_solution_191:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $191, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_191_end

# here, it has been found that GrayCode(idx+192) is a solution
._report_solution_192:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $192, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_192_end

# here, it has been found that GrayCode(idx+193) is a solution
._report_solution_193:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $193, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_193_end

# here, it has been found that GrayCode(idx+194) is a solution
._report_solution_194:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $194, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_194_end

# here, it has been found that GrayCode(idx+195) is a solution
._report_solution_195:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $195, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_195_end

# here, it has been found that GrayCode(idx+196) is a solution
._report_solution_196:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $196, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_196_end

# here, it has been found that GrayCode(idx+197) is a solution
._report_solution_197:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $197, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_197_end

# here, it has been found that GrayCode(idx+198) is a solution
._report_solution_198:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $198, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_198_end

# here, it has been found that GrayCode(idx+199) is a solution
._report_solution_199:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $199, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_199_end

# here, it has been found that GrayCode(idx+200) is a solution
._report_solution_200:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $200, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_200_end

# here, it has been found that GrayCode(idx+201) is a solution
._report_solution_201:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $201, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_201_end

# here, it has been found that GrayCode(idx+202) is a solution
._report_solution_202:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $202, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_202_end

# here, it has been found that GrayCode(idx+203) is a solution
._report_solution_203:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $203, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_203_end

# here, it has been found that GrayCode(idx+204) is a solution
._report_solution_204:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $204, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_204_end

# here, it has been found that GrayCode(idx+205) is a solution
._report_solution_205:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $205, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_205_end

# here, it has been found that GrayCode(idx+206) is a solution
._report_solution_206:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $206, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_206_end

# here, it has been found that GrayCode(idx+207) is a solution
._report_solution_207:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $207, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_207_end

# here, it has been found that GrayCode(idx+208) is a solution
._report_solution_208:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $208, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_208_end

# here, it has been found that GrayCode(idx+209) is a solution
._report_solution_209:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $209, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_209_end

# here, it has been found that GrayCode(idx+210) is a solution
._report_solution_210:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $210, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_210_end

# here, it has been found that GrayCode(idx+211) is a solution
._report_solution_211:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $211, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_211_end

# here, it has been found that GrayCode(idx+212) is a solution
._report_solution_212:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $212, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_212_end

# here, it has been found that GrayCode(idx+213) is a solution
._report_solution_213:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $213, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_213_end

# here, it has been found that GrayCode(idx+214) is a solution
._report_solution_214:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $214, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_214_end

# here, it has been found that GrayCode(idx+215) is a solution
._report_solution_215:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $215, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_215_end

# here, it has been found that GrayCode(idx+216) is a solution
._report_solution_216:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $216, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_216_end

# here, it has been found that GrayCode(idx+217) is a solution
._report_solution_217:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $217, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_217_end

# here, it has been found that GrayCode(idx+218) is a solution
._report_solution_218:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $218, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_218_end

# here, it has been found that GrayCode(idx+219) is a solution
._report_solution_219:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $219, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_219_end

# here, it has been found that GrayCode(idx+220) is a solution
._report_solution_220:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $220, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_220_end

# here, it has been found that GrayCode(idx+221) is a solution
._report_solution_221:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $221, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_221_end

# here, it has been found that GrayCode(idx+222) is a solution
._report_solution_222:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $222, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_222_end

# here, it has been found that GrayCode(idx+223) is a solution
._report_solution_223:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $223, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_223_end

# here, it has been found that GrayCode(idx+224) is a solution
._report_solution_224:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $224, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_224_end

# here, it has been found that GrayCode(idx+225) is a solution
._report_solution_225:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $225, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_225_end

# here, it has been found that GrayCode(idx+226) is a solution
._report_solution_226:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $226, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_226_end

# here, it has been found that GrayCode(idx+227) is a solution
._report_solution_227:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $227, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_227_end

# here, it has been found that GrayCode(idx+228) is a solution
._report_solution_228:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $228, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_228_end

# here, it has been found that GrayCode(idx+229) is a solution
._report_solution_229:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $229, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_229_end

# here, it has been found that GrayCode(idx+230) is a solution
._report_solution_230:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $230, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_230_end

# here, it has been found that GrayCode(idx+231) is a solution
._report_solution_231:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $231, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_231_end

# here, it has been found that GrayCode(idx+232) is a solution
._report_solution_232:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $232, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_232_end

# here, it has been found that GrayCode(idx+233) is a solution
._report_solution_233:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $233, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_233_end

# here, it has been found that GrayCode(idx+234) is a solution
._report_solution_234:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $234, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_234_end

# here, it has been found that GrayCode(idx+235) is a solution
._report_solution_235:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $235, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_235_end

# here, it has been found that GrayCode(idx+236) is a solution
._report_solution_236:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $236, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_236_end

# here, it has been found that GrayCode(idx+237) is a solution
._report_solution_237:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $237, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_237_end

# here, it has been found that GrayCode(idx+238) is a solution
._report_solution_238:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $238, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_238_end

# here, it has been found that GrayCode(idx+239) is a solution
._report_solution_239:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $239, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_239_end

# here, it has been found that GrayCode(idx+240) is a solution
._report_solution_240:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $240, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_240_end

# here, it has been found that GrayCode(idx+241) is a solution
._report_solution_241:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $241, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_241_end

# here, it has been found that GrayCode(idx+242) is a solution
._report_solution_242:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $242, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_242_end

# here, it has been found that GrayCode(idx+243) is a solution
._report_solution_243:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $243, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_243_end

# here, it has been found that GrayCode(idx+244) is a solution
._report_solution_244:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $244, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_244_end

# here, it has been found that GrayCode(idx+245) is a solution
._report_solution_245:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $245, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_245_end

# here, it has been found that GrayCode(idx+246) is a solution
._report_solution_246:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $246, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_246_end

# here, it has been found that GrayCode(idx+247) is a solution
._report_solution_247:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $247, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_247_end

# here, it has been found that GrayCode(idx+248) is a solution
._report_solution_248:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $248, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_248_end

# here, it has been found that GrayCode(idx+249) is a solution
._report_solution_249:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $249, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_249_end

# here, it has been found that GrayCode(idx+250) is a solution
._report_solution_250:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $250, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_250_end

# here, it has been found that GrayCode(idx+251) is a solution
._report_solution_251:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $251, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_251_end

# here, it has been found that GrayCode(idx+252) is a solution
._report_solution_252:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $252, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_252_end

# here, it has been found that GrayCode(idx+253) is a solution
._report_solution_253:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $253, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_253_end

# here, it has been found that GrayCode(idx+254) is a solution
._report_solution_254:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $254, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_254_end

# here, it has been found that GrayCode(idx+255) is a solution
._report_solution_255:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $255, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_255_end

# here, it has been found that GrayCode(idx+256) is a solution
._report_solution_256:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $256, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_256_end

# here, it has been found that GrayCode(idx+257) is a solution
._report_solution_257:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $257, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_257_end

# here, it has been found that GrayCode(idx+258) is a solution
._report_solution_258:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $258, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_258_end

# here, it has been found that GrayCode(idx+259) is a solution
._report_solution_259:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $259, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_259_end

# here, it has been found that GrayCode(idx+260) is a solution
._report_solution_260:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $260, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_260_end

# here, it has been found that GrayCode(idx+261) is a solution
._report_solution_261:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $261, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_261_end

# here, it has been found that GrayCode(idx+262) is a solution
._report_solution_262:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $262, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_262_end

# here, it has been found that GrayCode(idx+263) is a solution
._report_solution_263:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $263, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_263_end

# here, it has been found that GrayCode(idx+264) is a solution
._report_solution_264:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $264, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_264_end

# here, it has been found that GrayCode(idx+265) is a solution
._report_solution_265:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $265, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_265_end

# here, it has been found that GrayCode(idx+266) is a solution
._report_solution_266:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $266, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_266_end

# here, it has been found that GrayCode(idx+267) is a solution
._report_solution_267:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $267, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_267_end

# here, it has been found that GrayCode(idx+268) is a solution
._report_solution_268:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $268, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_268_end

# here, it has been found that GrayCode(idx+269) is a solution
._report_solution_269:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $269, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_269_end

# here, it has been found that GrayCode(idx+270) is a solution
._report_solution_270:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $270, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_270_end

# here, it has been found that GrayCode(idx+271) is a solution
._report_solution_271:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $271, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_271_end

# here, it has been found that GrayCode(idx+272) is a solution
._report_solution_272:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $272, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_272_end

# here, it has been found that GrayCode(idx+273) is a solution
._report_solution_273:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $273, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_273_end

# here, it has been found that GrayCode(idx+274) is a solution
._report_solution_274:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $274, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_274_end

# here, it has been found that GrayCode(idx+275) is a solution
._report_solution_275:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $275, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_275_end

# here, it has been found that GrayCode(idx+276) is a solution
._report_solution_276:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $276, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_276_end

# here, it has been found that GrayCode(idx+277) is a solution
._report_solution_277:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $277, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_277_end

# here, it has been found that GrayCode(idx+278) is a solution
._report_solution_278:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $278, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_278_end

# here, it has been found that GrayCode(idx+279) is a solution
._report_solution_279:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $279, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_279_end

# here, it has been found that GrayCode(idx+280) is a solution
._report_solution_280:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $280, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_280_end

# here, it has been found that GrayCode(idx+281) is a solution
._report_solution_281:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $281, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_281_end

# here, it has been found that GrayCode(idx+282) is a solution
._report_solution_282:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $282, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_282_end

# here, it has been found that GrayCode(idx+283) is a solution
._report_solution_283:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $283, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_283_end

# here, it has been found that GrayCode(idx+284) is a solution
._report_solution_284:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $284, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_284_end

# here, it has been found that GrayCode(idx+285) is a solution
._report_solution_285:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $285, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_285_end

# here, it has been found that GrayCode(idx+286) is a solution
._report_solution_286:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $286, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_286_end

# here, it has been found that GrayCode(idx+287) is a solution
._report_solution_287:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $287, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_287_end

# here, it has been found that GrayCode(idx+288) is a solution
._report_solution_288:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $288, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_288_end

# here, it has been found that GrayCode(idx+289) is a solution
._report_solution_289:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $289, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_289_end

# here, it has been found that GrayCode(idx+290) is a solution
._report_solution_290:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $290, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_290_end

# here, it has been found that GrayCode(idx+291) is a solution
._report_solution_291:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $291, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_291_end

# here, it has been found that GrayCode(idx+292) is a solution
._report_solution_292:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $292, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_292_end

# here, it has been found that GrayCode(idx+293) is a solution
._report_solution_293:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $293, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_293_end

# here, it has been found that GrayCode(idx+294) is a solution
._report_solution_294:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $294, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_294_end

# here, it has been found that GrayCode(idx+295) is a solution
._report_solution_295:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $295, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_295_end

# here, it has been found that GrayCode(idx+296) is a solution
._report_solution_296:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $296, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_296_end

# here, it has been found that GrayCode(idx+297) is a solution
._report_solution_297:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $297, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_297_end

# here, it has been found that GrayCode(idx+298) is a solution
._report_solution_298:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $298, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_298_end

# here, it has been found that GrayCode(idx+299) is a solution
._report_solution_299:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $299, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_299_end

# here, it has been found that GrayCode(idx+300) is a solution
._report_solution_300:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $300, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_300_end

# here, it has been found that GrayCode(idx+301) is a solution
._report_solution_301:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $301, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_301_end

# here, it has been found that GrayCode(idx+302) is a solution
._report_solution_302:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $302, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_302_end

# here, it has been found that GrayCode(idx+303) is a solution
._report_solution_303:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $303, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_303_end

# here, it has been found that GrayCode(idx+304) is a solution
._report_solution_304:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $304, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_304_end

# here, it has been found that GrayCode(idx+305) is a solution
._report_solution_305:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $305, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_305_end

# here, it has been found that GrayCode(idx+306) is a solution
._report_solution_306:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $306, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_306_end

# here, it has been found that GrayCode(idx+307) is a solution
._report_solution_307:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $307, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_307_end

# here, it has been found that GrayCode(idx+308) is a solution
._report_solution_308:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $308, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_308_end

# here, it has been found that GrayCode(idx+309) is a solution
._report_solution_309:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $309, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_309_end

# here, it has been found that GrayCode(idx+310) is a solution
._report_solution_310:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $310, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_310_end

# here, it has been found that GrayCode(idx+311) is a solution
._report_solution_311:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $311, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_311_end

# here, it has been found that GrayCode(idx+312) is a solution
._report_solution_312:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $312, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_312_end

# here, it has been found that GrayCode(idx+313) is a solution
._report_solution_313:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $313, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_313_end

# here, it has been found that GrayCode(idx+314) is a solution
._report_solution_314:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $314, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_314_end

# here, it has been found that GrayCode(idx+315) is a solution
._report_solution_315:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $315, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_315_end

# here, it has been found that GrayCode(idx+316) is a solution
._report_solution_316:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $316, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_316_end

# here, it has been found that GrayCode(idx+317) is a solution
._report_solution_317:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $317, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_317_end

# here, it has been found that GrayCode(idx+318) is a solution
._report_solution_318:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $318, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_318_end

# here, it has been found that GrayCode(idx+319) is a solution
._report_solution_319:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $319, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_319_end

# here, it has been found that GrayCode(idx+320) is a solution
._report_solution_320:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $320, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_320_end

# here, it has been found that GrayCode(idx+321) is a solution
._report_solution_321:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $321, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_321_end

# here, it has been found that GrayCode(idx+322) is a solution
._report_solution_322:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $322, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_322_end

# here, it has been found that GrayCode(idx+323) is a solution
._report_solution_323:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $323, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_323_end

# here, it has been found that GrayCode(idx+324) is a solution
._report_solution_324:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $324, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_324_end

# here, it has been found that GrayCode(idx+325) is a solution
._report_solution_325:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $325, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_325_end

# here, it has been found that GrayCode(idx+326) is a solution
._report_solution_326:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $326, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_326_end

# here, it has been found that GrayCode(idx+327) is a solution
._report_solution_327:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $327, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_327_end

# here, it has been found that GrayCode(idx+328) is a solution
._report_solution_328:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $328, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_328_end

# here, it has been found that GrayCode(idx+329) is a solution
._report_solution_329:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $329, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_329_end

# here, it has been found that GrayCode(idx+330) is a solution
._report_solution_330:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $330, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_330_end

# here, it has been found that GrayCode(idx+331) is a solution
._report_solution_331:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $331, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_331_end

# here, it has been found that GrayCode(idx+332) is a solution
._report_solution_332:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $332, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_332_end

# here, it has been found that GrayCode(idx+333) is a solution
._report_solution_333:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $333, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_333_end

# here, it has been found that GrayCode(idx+334) is a solution
._report_solution_334:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $334, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_334_end

# here, it has been found that GrayCode(idx+335) is a solution
._report_solution_335:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $335, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_335_end

# here, it has been found that GrayCode(idx+336) is a solution
._report_solution_336:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $336, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_336_end

# here, it has been found that GrayCode(idx+337) is a solution
._report_solution_337:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $337, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_337_end

# here, it has been found that GrayCode(idx+338) is a solution
._report_solution_338:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $338, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_338_end

# here, it has been found that GrayCode(idx+339) is a solution
._report_solution_339:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $339, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_339_end

# here, it has been found that GrayCode(idx+340) is a solution
._report_solution_340:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $340, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_340_end

# here, it has been found that GrayCode(idx+341) is a solution
._report_solution_341:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $341, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_341_end

# here, it has been found that GrayCode(idx+342) is a solution
._report_solution_342:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $342, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_342_end

# here, it has been found that GrayCode(idx+343) is a solution
._report_solution_343:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $343, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_343_end

# here, it has been found that GrayCode(idx+344) is a solution
._report_solution_344:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $344, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_344_end

# here, it has been found that GrayCode(idx+345) is a solution
._report_solution_345:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $345, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_345_end

# here, it has been found that GrayCode(idx+346) is a solution
._report_solution_346:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $346, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_346_end

# here, it has been found that GrayCode(idx+347) is a solution
._report_solution_347:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $347, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_347_end

# here, it has been found that GrayCode(idx+348) is a solution
._report_solution_348:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $348, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_348_end

# here, it has been found that GrayCode(idx+349) is a solution
._report_solution_349:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $349, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_349_end

# here, it has been found that GrayCode(idx+350) is a solution
._report_solution_350:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $350, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_350_end

# here, it has been found that GrayCode(idx+351) is a solution
._report_solution_351:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $351, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_351_end

# here, it has been found that GrayCode(idx+352) is a solution
._report_solution_352:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $352, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_352_end

# here, it has been found that GrayCode(idx+353) is a solution
._report_solution_353:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $353, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_353_end

# here, it has been found that GrayCode(idx+354) is a solution
._report_solution_354:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $354, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_354_end

# here, it has been found that GrayCode(idx+355) is a solution
._report_solution_355:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $355, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_355_end

# here, it has been found that GrayCode(idx+356) is a solution
._report_solution_356:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $356, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_356_end

# here, it has been found that GrayCode(idx+357) is a solution
._report_solution_357:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $357, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_357_end

# here, it has been found that GrayCode(idx+358) is a solution
._report_solution_358:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $358, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_358_end

# here, it has been found that GrayCode(idx+359) is a solution
._report_solution_359:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $359, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_359_end

# here, it has been found that GrayCode(idx+360) is a solution
._report_solution_360:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $360, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_360_end

# here, it has been found that GrayCode(idx+361) is a solution
._report_solution_361:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $361, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_361_end

# here, it has been found that GrayCode(idx+362) is a solution
._report_solution_362:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $362, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_362_end

# here, it has been found that GrayCode(idx+363) is a solution
._report_solution_363:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $363, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_363_end

# here, it has been found that GrayCode(idx+364) is a solution
._report_solution_364:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $364, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_364_end

# here, it has been found that GrayCode(idx+365) is a solution
._report_solution_365:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $365, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_365_end

# here, it has been found that GrayCode(idx+366) is a solution
._report_solution_366:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $366, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_366_end

# here, it has been found that GrayCode(idx+367) is a solution
._report_solution_367:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $367, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_367_end

# here, it has been found that GrayCode(idx+368) is a solution
._report_solution_368:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $368, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_368_end

# here, it has been found that GrayCode(idx+369) is a solution
._report_solution_369:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $369, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_369_end

# here, it has been found that GrayCode(idx+370) is a solution
._report_solution_370:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $370, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_370_end

# here, it has been found that GrayCode(idx+371) is a solution
._report_solution_371:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $371, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_371_end

# here, it has been found that GrayCode(idx+372) is a solution
._report_solution_372:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $372, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_372_end

# here, it has been found that GrayCode(idx+373) is a solution
._report_solution_373:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $373, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_373_end

# here, it has been found that GrayCode(idx+374) is a solution
._report_solution_374:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $374, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_374_end

# here, it has been found that GrayCode(idx+375) is a solution
._report_solution_375:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $375, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_375_end

# here, it has been found that GrayCode(idx+376) is a solution
._report_solution_376:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $376, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_376_end

# here, it has been found that GrayCode(idx+377) is a solution
._report_solution_377:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $377, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_377_end

# here, it has been found that GrayCode(idx+378) is a solution
._report_solution_378:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $378, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_378_end

# here, it has been found that GrayCode(idx+379) is a solution
._report_solution_379:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $379, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_379_end

# here, it has been found that GrayCode(idx+380) is a solution
._report_solution_380:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $380, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_380_end

# here, it has been found that GrayCode(idx+381) is a solution
._report_solution_381:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $381, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_381_end

# here, it has been found that GrayCode(idx+382) is a solution
._report_solution_382:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $382, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_382_end

# here, it has been found that GrayCode(idx+383) is a solution
._report_solution_383:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $383, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_383_end

# here, it has been found that GrayCode(idx+384) is a solution
._report_solution_384:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $384, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_384_end

# here, it has been found that GrayCode(idx+385) is a solution
._report_solution_385:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $385, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_385_end

# here, it has been found that GrayCode(idx+386) is a solution
._report_solution_386:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $386, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_386_end

# here, it has been found that GrayCode(idx+387) is a solution
._report_solution_387:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $387, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_387_end

# here, it has been found that GrayCode(idx+388) is a solution
._report_solution_388:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $388, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_388_end

# here, it has been found that GrayCode(idx+389) is a solution
._report_solution_389:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $389, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_389_end

# here, it has been found that GrayCode(idx+390) is a solution
._report_solution_390:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $390, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_390_end

# here, it has been found that GrayCode(idx+391) is a solution
._report_solution_391:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $391, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_391_end

# here, it has been found that GrayCode(idx+392) is a solution
._report_solution_392:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $392, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_392_end

# here, it has been found that GrayCode(idx+393) is a solution
._report_solution_393:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $393, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_393_end

# here, it has been found that GrayCode(idx+394) is a solution
._report_solution_394:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $394, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_394_end

# here, it has been found that GrayCode(idx+395) is a solution
._report_solution_395:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $395, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_395_end

# here, it has been found that GrayCode(idx+396) is a solution
._report_solution_396:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $396, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_396_end

# here, it has been found that GrayCode(idx+397) is a solution
._report_solution_397:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $397, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_397_end

# here, it has been found that GrayCode(idx+398) is a solution
._report_solution_398:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $398, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_398_end

# here, it has been found that GrayCode(idx+399) is a solution
._report_solution_399:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $399, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_399_end

# here, it has been found that GrayCode(idx+400) is a solution
._report_solution_400:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $400, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_400_end

# here, it has been found that GrayCode(idx+401) is a solution
._report_solution_401:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $401, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_401_end

# here, it has been found that GrayCode(idx+402) is a solution
._report_solution_402:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $402, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_402_end

# here, it has been found that GrayCode(idx+403) is a solution
._report_solution_403:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $403, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_403_end

# here, it has been found that GrayCode(idx+404) is a solution
._report_solution_404:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $404, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_404_end

# here, it has been found that GrayCode(idx+405) is a solution
._report_solution_405:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $405, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_405_end

# here, it has been found that GrayCode(idx+406) is a solution
._report_solution_406:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $406, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_406_end

# here, it has been found that GrayCode(idx+407) is a solution
._report_solution_407:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $407, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_407_end

# here, it has been found that GrayCode(idx+408) is a solution
._report_solution_408:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $408, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_408_end

# here, it has been found that GrayCode(idx+409) is a solution
._report_solution_409:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $409, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_409_end

# here, it has been found that GrayCode(idx+410) is a solution
._report_solution_410:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $410, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_410_end

# here, it has been found that GrayCode(idx+411) is a solution
._report_solution_411:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $411, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_411_end

# here, it has been found that GrayCode(idx+412) is a solution
._report_solution_412:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $412, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_412_end

# here, it has been found that GrayCode(idx+413) is a solution
._report_solution_413:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $413, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_413_end

# here, it has been found that GrayCode(idx+414) is a solution
._report_solution_414:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $414, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_414_end

# here, it has been found that GrayCode(idx+415) is a solution
._report_solution_415:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $415, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_415_end

# here, it has been found that GrayCode(idx+416) is a solution
._report_solution_416:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $416, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_416_end

# here, it has been found that GrayCode(idx+417) is a solution
._report_solution_417:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $417, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_417_end

# here, it has been found that GrayCode(idx+418) is a solution
._report_solution_418:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $418, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_418_end

# here, it has been found that GrayCode(idx+419) is a solution
._report_solution_419:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $419, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_419_end

# here, it has been found that GrayCode(idx+420) is a solution
._report_solution_420:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $420, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_420_end

# here, it has been found that GrayCode(idx+421) is a solution
._report_solution_421:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $421, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_421_end

# here, it has been found that GrayCode(idx+422) is a solution
._report_solution_422:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $422, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_422_end

# here, it has been found that GrayCode(idx+423) is a solution
._report_solution_423:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $423, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_423_end

# here, it has been found that GrayCode(idx+424) is a solution
._report_solution_424:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $424, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_424_end

# here, it has been found that GrayCode(idx+425) is a solution
._report_solution_425:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $425, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_425_end

# here, it has been found that GrayCode(idx+426) is a solution
._report_solution_426:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $426, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_426_end

# here, it has been found that GrayCode(idx+427) is a solution
._report_solution_427:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $427, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_427_end

# here, it has been found that GrayCode(idx+428) is a solution
._report_solution_428:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $428, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_428_end

# here, it has been found that GrayCode(idx+429) is a solution
._report_solution_429:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $429, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_429_end

# here, it has been found that GrayCode(idx+430) is a solution
._report_solution_430:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $430, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_430_end

# here, it has been found that GrayCode(idx+431) is a solution
._report_solution_431:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $431, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_431_end

# here, it has been found that GrayCode(idx+432) is a solution
._report_solution_432:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $432, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_432_end

# here, it has been found that GrayCode(idx+433) is a solution
._report_solution_433:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $433, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_433_end

# here, it has been found that GrayCode(idx+434) is a solution
._report_solution_434:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $434, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_434_end

# here, it has been found that GrayCode(idx+435) is a solution
._report_solution_435:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $435, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_435_end

# here, it has been found that GrayCode(idx+436) is a solution
._report_solution_436:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $436, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_436_end

# here, it has been found that GrayCode(idx+437) is a solution
._report_solution_437:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $437, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_437_end

# here, it has been found that GrayCode(idx+438) is a solution
._report_solution_438:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $438, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_438_end

# here, it has been found that GrayCode(idx+439) is a solution
._report_solution_439:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $439, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_439_end

# here, it has been found that GrayCode(idx+440) is a solution
._report_solution_440:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $440, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_440_end

# here, it has been found that GrayCode(idx+441) is a solution
._report_solution_441:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $441, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_441_end

# here, it has been found that GrayCode(idx+442) is a solution
._report_solution_442:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $442, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_442_end

# here, it has been found that GrayCode(idx+443) is a solution
._report_solution_443:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $443, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_443_end

# here, it has been found that GrayCode(idx+444) is a solution
._report_solution_444:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $444, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_444_end

# here, it has been found that GrayCode(idx+445) is a solution
._report_solution_445:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $445, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_445_end

# here, it has been found that GrayCode(idx+446) is a solution
._report_solution_446:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $446, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_446_end

# here, it has been found that GrayCode(idx+447) is a solution
._report_solution_447:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $447, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_447_end

# here, it has been found that GrayCode(idx+448) is a solution
._report_solution_448:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $448, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_448_end

# here, it has been found that GrayCode(idx+449) is a solution
._report_solution_449:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $449, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_449_end

# here, it has been found that GrayCode(idx+450) is a solution
._report_solution_450:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $450, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_450_end

# here, it has been found that GrayCode(idx+451) is a solution
._report_solution_451:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $451, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_451_end

# here, it has been found that GrayCode(idx+452) is a solution
._report_solution_452:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $452, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_452_end

# here, it has been found that GrayCode(idx+453) is a solution
._report_solution_453:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $453, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_453_end

# here, it has been found that GrayCode(idx+454) is a solution
._report_solution_454:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $454, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_454_end

# here, it has been found that GrayCode(idx+455) is a solution
._report_solution_455:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $455, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_455_end

# here, it has been found that GrayCode(idx+456) is a solution
._report_solution_456:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $456, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_456_end

# here, it has been found that GrayCode(idx+457) is a solution
._report_solution_457:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $457, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_457_end

# here, it has been found that GrayCode(idx+458) is a solution
._report_solution_458:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $458, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_458_end

# here, it has been found that GrayCode(idx+459) is a solution
._report_solution_459:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $459, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_459_end

# here, it has been found that GrayCode(idx+460) is a solution
._report_solution_460:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $460, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_460_end

# here, it has been found that GrayCode(idx+461) is a solution
._report_solution_461:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $461, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_461_end

# here, it has been found that GrayCode(idx+462) is a solution
._report_solution_462:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $462, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_462_end

# here, it has been found that GrayCode(idx+463) is a solution
._report_solution_463:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $463, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_463_end

# here, it has been found that GrayCode(idx+464) is a solution
._report_solution_464:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $464, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_464_end

# here, it has been found that GrayCode(idx+465) is a solution
._report_solution_465:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $465, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_465_end

# here, it has been found that GrayCode(idx+466) is a solution
._report_solution_466:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $466, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_466_end

# here, it has been found that GrayCode(idx+467) is a solution
._report_solution_467:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $467, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_467_end

# here, it has been found that GrayCode(idx+468) is a solution
._report_solution_468:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $468, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_468_end

# here, it has been found that GrayCode(idx+469) is a solution
._report_solution_469:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $469, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_469_end

# here, it has been found that GrayCode(idx+470) is a solution
._report_solution_470:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $470, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_470_end

# here, it has been found that GrayCode(idx+471) is a solution
._report_solution_471:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $471, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_471_end

# here, it has been found that GrayCode(idx+472) is a solution
._report_solution_472:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $472, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_472_end

# here, it has been found that GrayCode(idx+473) is a solution
._report_solution_473:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $473, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_473_end

# here, it has been found that GrayCode(idx+474) is a solution
._report_solution_474:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $474, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_474_end

# here, it has been found that GrayCode(idx+475) is a solution
._report_solution_475:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $475, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_475_end

# here, it has been found that GrayCode(idx+476) is a solution
._report_solution_476:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $476, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_476_end

# here, it has been found that GrayCode(idx+477) is a solution
._report_solution_477:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $477, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_477_end

# here, it has been found that GrayCode(idx+478) is a solution
._report_solution_478:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $478, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_478_end

# here, it has been found that GrayCode(idx+479) is a solution
._report_solution_479:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $479, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_479_end

# here, it has been found that GrayCode(idx+480) is a solution
._report_solution_480:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $480, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_480_end

# here, it has been found that GrayCode(idx+481) is a solution
._report_solution_481:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $481, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_481_end

# here, it has been found that GrayCode(idx+482) is a solution
._report_solution_482:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $482, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_482_end

# here, it has been found that GrayCode(idx+483) is a solution
._report_solution_483:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $483, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_483_end

# here, it has been found that GrayCode(idx+484) is a solution
._report_solution_484:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $484, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_484_end

# here, it has been found that GrayCode(idx+485) is a solution
._report_solution_485:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $485, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_485_end

# here, it has been found that GrayCode(idx+486) is a solution
._report_solution_486:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $486, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_486_end

# here, it has been found that GrayCode(idx+487) is a solution
._report_solution_487:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $487, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_487_end

# here, it has been found that GrayCode(idx+488) is a solution
._report_solution_488:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $488, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_488_end

# here, it has been found that GrayCode(idx+489) is a solution
._report_solution_489:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $489, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_489_end

# here, it has been found that GrayCode(idx+490) is a solution
._report_solution_490:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $490, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_490_end

# here, it has been found that GrayCode(idx+491) is a solution
._report_solution_491:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $491, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_491_end

# here, it has been found that GrayCode(idx+492) is a solution
._report_solution_492:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $492, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_492_end

# here, it has been found that GrayCode(idx+493) is a solution
._report_solution_493:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $493, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_493_end

# here, it has been found that GrayCode(idx+494) is a solution
._report_solution_494:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $494, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_494_end

# here, it has been found that GrayCode(idx+495) is a solution
._report_solution_495:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $495, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_495_end

# here, it has been found that GrayCode(idx+496) is a solution
._report_solution_496:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $496, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_496_end

# here, it has been found that GrayCode(idx+497) is a solution
._report_solution_497:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $497, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_497_end

# here, it has been found that GrayCode(idx+498) is a solution
._report_solution_498:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $498, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_498_end

# here, it has been found that GrayCode(idx+499) is a solution
._report_solution_499:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $499, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_499_end

# here, it has been found that GrayCode(idx+500) is a solution
._report_solution_500:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $500, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_500_end

# here, it has been found that GrayCode(idx+501) is a solution
._report_solution_501:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $501, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_501_end

# here, it has been found that GrayCode(idx+502) is a solution
._report_solution_502:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $502, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_502_end

# here, it has been found that GrayCode(idx+503) is a solution
._report_solution_503:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $503, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_503_end

# here, it has been found that GrayCode(idx+504) is a solution
._report_solution_504:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $504, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_504_end

# here, it has been found that GrayCode(idx+505) is a solution
._report_solution_505:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $505, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_505_end

# here, it has been found that GrayCode(idx+506) is a solution
._report_solution_506:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $506, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_506_end

# here, it has been found that GrayCode(idx+507) is a solution
._report_solution_507:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $507, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_507_end

# here, it has been found that GrayCode(idx+508) is a solution
._report_solution_508:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $508, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_508_end

# here, it has been found that GrayCode(idx+509) is a solution
._report_solution_509:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $509, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_509_end

# here, it has been found that GrayCode(idx+510) is a solution
._report_solution_510:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $510, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_510_end

# here, it has been found that GrayCode(idx+511) is a solution
._report_solution_511:
pxor %xmm15, %xmm15      #zero = 0
shl $3, %r9        #num <<= 3
mov %r8, %rax       #tmp = idx
add $511, %rax      #tmp += i
mov %rax, (%rdx, %r9)      # buf[num].idx = tmp
add $4, %r9        #num += 4
movl %r10d, (%rdx, %r9)    #buf[num].mask = mask 
shr $3, %r9        #num >>= 3
add  $1, %r9       #num += 1
jmp ._step_511_end

._ending:


# copy back to memory the (most-frequently used) derivatives that were held in registers
movdqa %xmm0, 0(%rdi)
movdqa %xmm1, 16(%rdi)
movdqa %xmm2, 32(%rdi)
movdqa %xmm3, 48(%rdi)
movdqa %xmm4, 64(%rdi)
movdqa %xmm5, 80(%rdi)
movdqa %xmm6, 96(%rdi)
movdqa %xmm7, 112(%rdi)
movdqa %xmm8, 128(%rdi)
movdqa %xmm9, 144(%rdi)
movdqa %xmm10, 160(%rdi)
movdqa %xmm11, 176(%rdi)
movdqa %xmm12, 192(%rdi)
movdqa %xmm13, 208(%rdi)

# store the number of solutions found in this chunk
movq %r9, 0(%rcx)

# restore the stack frame
add %r11,%rsp

ret
