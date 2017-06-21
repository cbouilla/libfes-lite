static unsigned long next = 1;

/* pseudo-random number in the range 0--32767 */
int myrand_15(void) {
  next = next * 1103515245 + 12345;
  return((unsigned)(next/65536) % 32768);
}

/* pseudo-random number in the range 0--2^32 - 1 */
int myrand(void) {
  return  (myrand_15() << 24) ^ (myrand_15() << 10) ^ myrand_15();
}

void mysrand(unsigned long seed) {
  next = seed;
}
