size_t generic_enum_1x32(int n, const uint32_t * const F,
			    uint32_t * solutions, size_t max_solutions,
			    int verbose);
size_t generic_enum_2x16(int n, const uint32_t * const F,
			    uint32_t * solutions, size_t max_solutions,
			    int verbose);
size_t generic_eval_32(int n, const uint32_t * const F,
			    size_t eq_from, size_t eq_to,
			    uint32_t *input, size_t n_input,
			    uint32_t *solutions, size_t max_solutions,
			    int verbose);