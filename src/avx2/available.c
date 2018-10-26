#include <inttypes.h>
#include <stdbool.h>
#include <immintrin.h>

#include "avx2.h"

#ifdef __AVX2__
static void run_cpuid(uint32_t eax, uint32_t ecx, uint32_t* abcd) 
{
	#if defined(_MSC_VER)
 		__cpuidex(abcd, eax, ecx);
	#else
 		uint32_t ebx = 0, edx;
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

bool feslite_avx2_available()
{
	uint32_t abcd[4];
	uint32_t avx2_mask = (1 << 5);
	/* CPUID.(EAX=07H, ECX=0H):EBX.AVX2[bit 5]==1 */
	run_cpuid(7, 0, abcd);
	return abcd[1] & avx2_mask;
}
// #else
// bool has_avx2()
// {
// 	return false;
// }
#endif