/** generic 32-bit code **/

size_t feslite_generic_enum_1x32(size_t n, const uint32_t * const F,
			    uint32_t * solutions, size_t max_solutions,
			    bool verbose);

size_t feslite_generic_eval_32(size_t n, const uint32_t * const F,
			    size_t eq_from, size_t eq_to,
			    uint32_t *input, size_t n_input,
			    uint32_t *solutions, size_t max_solutions,
			    bool verbose);

#if 0
size_t generic_enum_2x16(int n, const uint32_t * const F,
			    uint32_t * solutions, size_t max_solutions,
			    int verbose);

/** generic 64-bit code **/

size_t generic_enum_2x32(int n, const uint32_t * const F,
			    uint32_t * solutions, size_t max_solutions,
			    int verbose);
size_t generic_enum_4x16(int n, const uint32_t * const F,
			    uint32_t * solutions, size_t max_solutions,
			    int verbose);
#endif