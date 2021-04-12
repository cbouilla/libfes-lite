n = 34
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

# first 20 polynomial are random
for _ in range(8): 
    f = random_quad_poly(R) 
    f += f(*x) 
    I.append(f)

# next 80 polynomials are random linear combinations of the first 28 ones
M = matrix.random(GF(2), 8, 8)
J = M * vector(I)
I.extend(J)

# first 20 polynomial are random
for _ in range(8): 
    f = random_quad_poly(R) 
    f += f(*x) 
    I.append(f)

# next 80 polynomials are random linear combinations of the first 28 ones
M = matrix.random(GF(2), 8, 24)
J = M * vector(I)
I.extend(J)

# last 20 polynomial are random
for _ in range(20): 
    f = random_quad_poly(R) 
    f += f(*x) 
    I.append(f)


with open(f"structured_{n}.in", 'w') as f:
    # print polynomials in desired format
    f.write(",".join(map(str, R.gens())) + "\n")
    
    f.write(f"# planted solution: {x}\n")
    for p in I:
        f.write(f'{p}\n')