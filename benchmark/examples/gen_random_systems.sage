for n in range(32, 81):
	R = BooleanPolynomialRing(n, 'x')
	
	# planted solution
	V = GF(2)**n 
	x = V.random_element() 
	I = [] 
	
	def random_quad_poly(R):
	    K = R.base_ring()
	    v = vector(R.gens())
	    n = len(v) 
	    Mq = matrix.random(K, n, n)
	    Ml = matrix.random(K, 1, n)
	    f = v * Mq * v + (Ml*v)[0] + K.random_element()
	    return f
	
	# n random polynomials
	for _ in range(n): 
	    f = random_quad_poly(R) 
	    f += f(*x) 
	    I.append(f)
	
	with open(f"random_{n}_quad.in", 'w') as f:
		# print polynomials in desired format
		f.write(",".join(map(str, R.gens())) + "\n")
		
		f.write(f"# planted solution: {x}\n")
		for p in I:
		    f.write(f'{p}\n')
