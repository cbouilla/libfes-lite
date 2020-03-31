#include <stdio.h>
#include <stdlib.h>

#include "feslite.h"
#include "cycleclock.h"
	
/* Show list of available kernels */

int main()
{
	/* query the library */
	int nkernels = feslite_num_kernels();
	
	for (int kernel = 0; kernel < nkernels; kernel++) {
		const char *name = feslite_kernel_name(kernel);
		if (!feslite_kernel_is_available(kernel)) {
			printf("%d : [%s] is not available on this machine\n", kernel, name);
			continue;
		}
		int m = feslite_kernel_batch_size(kernel);
		printf("kernel %d [%s] : %d lane(s)\n", kernel, name, m);
	}

	return EXIT_SUCCESS;
}