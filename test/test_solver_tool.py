import subprocess
import sys

PREFIX = "#EXPECTED "


############

if __name__ == '__main__':
	if len(sys.argv) != 3:
		print("Bail out! No executable/filename provided")
		sys.exit(1)

	executable = sys.argv[1]
	filename = sys.argv[2]
	
	# read example system, extract expected solutions
	with open(filename) as f:
		payload = f.read()
	expected_output = []
	for l in payload.splitlines():
		if l.startswith(PREFIX):
			expected_output.append(l[len(PREFIX):])

	# test plan
	print('0..{}'.format(len(expected_output)))
	
	# run solver
	print(f"# running {executable} < {filename}")
	call = subprocess.run(executable, input=payload.encode(), capture_output=True)
	if call.returncode != 0:
		print(f"not ok 0 {filename} - non-zero return code")
		print("Bail out! Not going to examine output")
		sys.exit(0)
	
	# check output
	wanted = set(expected_output)
	i = 1
	for l in call.stdout.decode().splitlines():
		if l in wanted:
			print(f'ok {i} - {l}')
			wanted.remove(l)
			i += 1
		else:
			print(f"Bail out! unexpected: {l}")
			sys.exit(0)

	# report
	if wanted == set(): 
		print(f"# all expected solutions found")
		sys.exit(0)

	for x in wanted:
		print(f'not ok {i} - {x}')
		i += 1
