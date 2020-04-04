#include <stdint.h>
#include <stdbool.h>

#if defined(_MSC_VER)
# include <intrin.h>
#endif

static void run_cpuid(uint32_t eax, uint32_t ecx, uint32_t* abcd)
{
#if defined(_MSC_VER)
    __cpuidex(abcd, eax, ecx);
#else
    uint32_t ebx=0, edx=0;
# if defined( __i386__ ) && defined ( __PIC__ )
     /* in case of PIC under 32-bit EBX cannot be clobbered */
    __asm__ ( "movl %%ebx, %%edi \n\t cpuid \n\t xchgl %%ebx, %%edi" : "=D" (ebx),
# else
    __asm__ ( "cpuid" : "+b" (ebx),
# endif
              "+a" (eax), "+c" (ecx), "=d" (edx) );
    abcd[0] = eax; abcd[1] = ebx; abcd[2] = ecx; abcd[3] = edx;
#endif
}     

#if defined(__INTEL_COMPILER) && (__INTEL_COMPILER >= 1300)

#include <immintrin.h>

bool feslite_avx2_available()
{
	return _may_i_use_cpu_feature(_FEATURE_AVX2);
}

bool feslite_avx512_available()
{
	return _may_i_use_cpu_feature(_FEATURE_AVX512F | _FEATURE_AVX512BW);
}

#else /* non-Intel compiler */

bool feslite_avx2_available()
{
    uint32_t abcd[4];
    uint32_t fma_movbe_osxsave_mask = ((1U << 12) | (1U << 22) | (1U << 27));
    uint32_t avx2_bmi12_mask = (1U << 5) | (1U << 3) | (1U << 8);

    /* CPUID.(EAX=01H, ECX=0H):ECX.FMA[bit 12]==1   && 
       CPUID.(EAX=01H, ECX=0H):ECX.MOVBE[bit 22]==1 && 
       CPUID.(EAX=01H, ECX=0H):ECX.OSXSAVE[bit 27]==1 */
    run_cpuid( 1, 0, abcd );
    if ( (abcd[2] & fma_movbe_osxsave_mask) != fma_movbe_osxsave_mask ) 
        return 0;

    /*  CPUID.(EAX=07H, ECX=0H):EBX.AVX2[bit 5]==1  &&
        CPUID.(EAX=07H, ECX=0H):EBX.BMI1[bit 3]==1  &&
        CPUID.(EAX=07H, ECX=0H):EBX.BMI2[bit 8]==1  */
    run_cpuid( 7, 0, abcd );
    if ( (abcd[1] & avx2_bmi12_mask) != avx2_bmi12_mask ) 
        return 0;

    /* CPUID.(EAX=80000001H):ECX.LZCNT[bit 5]==1 */
    run_cpuid( 0x80000001, 0, abcd );
    if ( (abcd[2] & (1U << 5)) == 0)
        return 0;

    return 1;
}

bool feslite_avx512_available() {
    uint32_t abcd[4];
    uint32_t osxsave_mask = (1U << 27); /* OSX. */
    uint32_t avx512f_mask = (1U << 16) | (1U << 30); /* AVX-512F + AVX-512BW*/
        
    /* CPUID.(EAX=01H, ECX=0H):ECX.OSXSAVE[bit 27]==1 */
    run_cpuid( 1, 0, abcd );
    if ( (abcd[2] & osxsave_mask) != osxsave_mask ) 
        return 0;

    /*  CPUID.(EAX=07H, ECX=0H):EBX.AVX-512F [bit 16]==1  &&
        CPUID.(EAX=07H, ECX=0H):EBX.AVX-512PF[bit 26]==1  &&
        CPUID.(EAX=07H, ECX=0H):EBX.AVX-512ER[bit 27]==1  &&
        CPUID.(EAX=07H, ECX=0H):EBX.AVX-512CD[bit 28]==1  */
    run_cpuid( 7, 0, abcd );
    if ( (abcd[1] & avx512f_mask) != avx512f_mask ) 
        return 0;

    return 1;
}
#endif /* non-Intel compiler */


bool feslite_sse2_available()
{
    uint32_t info[4];
    uint32_t nIds;

    run_cpuid(0, 0, info);
    nIds = info[0];

    /*  Detect Instruction Set */
    if (nIds >= 1){
        run_cpuid(0x00000001, 0, info);
        return (info[3] & (1U << 26)) != 0;
    }

    return 0;
}
