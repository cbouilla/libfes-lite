import sys
import string
import idx_LUT
import itertools
import get_idx_list
from copy import copy

def popcount(n):
    b=0
    while n>0:
        b += 1
        n &= n-1
    return b


def b_k(k, n):
    result = 0
    for i in range(k):
        while (n & 0x01) == 0:
            if n == 0:
                return -1
            n >>= 1
            result += 1
        n >>= 1
        result += 1
    return result-1

greek = [ "alpha" ]


def gen_start_asm(T):
    
    print( ".text" )
    print( ".p2align 6" )
    print( '' )
    print( ".globl avx2_asm_enum_8x32")
    print( '### void avx2_asm_enum_8x32(__m256i *F, uint64_t alpha_shift, void *buf, uint64_t *num, uint64_t idx);')
    print( '' )
    print( '# the X86-64 ABI says that...'  )
    print( '# A) we should preserve the values of %rbx, %rbp, %r12...%r15 [callee-save registers]' )
    print( '# B) We will receive the arguments of the function in registers :' )
    print( '#       &F in %rdi' )
    print( '#       alpha_shift in %rsi' )
    print( '#       &buf in %rdx' )
    print( '#       &num in %rcx' )
    print( '#       idx should be in %r8' )
    print( '' )
    print( "avx2_asm_enum_8x32:" )
    print( '' )
    print( '# intialize our stack frame' )
    print( "mov %rsp, %r11" )
    print( "and $31, %r11" )
    print( "add $64, %r11" )
    print( "sub %r11, %rsp" )
    print( '' )
    print( '# no need to save the callee-save registers (not used)' )
    #print( "movq %r11, 0(%rsp)" ) # apparently useless ?
    #print( "movq %r12, 8(%rsp)" )
    #print( "movq %r13, 16(%rsp)" )
    #print( "movq %r14, 24(%rsp)" )
    #print( "movq %r15, 32(%rsp)" )
    #print( "movq %rbx, 40(%rsp)" )
    #print( "movq %rbp, 48(%rsp)" )

def gen_end_asm():
    #print( '# restore the callee-save registers' )
    #print(  "movq 0(%rsp),%r11" )
    #print(  "movq 8(%rsp),%r12" )
    #print(  "movq 16(%rsp),%r13" )
    #print(  "movq 24(%rsp),%r14" )
    #print(  "movq 32(%rsp),%r15" )
    #print(  "movq 40(%rsp),%rbx" )
    #print(  "movq 48(%rsp),%rbp" )
    #print( '' )
    print( '# restore the stack frame' )
    print( "add %r11,%rsp" )
    print( '' )
    #print( '# prepare the return value (?!?)' )
    #print( 'mov %rdi,%rax' )#    <---- if I understand correctly, this is useless, because %rdi is not callee-save, and the return type is void
    #print( 'mov %rsi,%rdx' )#    <---- if I understand correctly, this is useless, because %rsi is not callee-save, and the return type is void
    print( 'ret' )

varMap = {} # mapping from variable names to registers

xmms_ptr = 0;
regs_ptr = 0;

xmms = [ '%ymm' + str(i) for i in range(16) ]

regs = [ '%rdi', '%rsi', '%rdx', '%rcx', '%r8', '%r9', '%rax', '%r10', '%r11', '%r12', '%r13', '%r14', '%r15', '%rbx', '%rbp' ]
regs32 = [ '%edi', '%esi', '%edx', '%ecx', '%r8d', '%r9d', '%eax', '%r10d', '%r11d', '%r12d', '%r13d', '%r14d', '%r15d', '%ebx', '%ebp' ]


def dec_xmm(var):
    global xmms_ptr
    assert(xmms_ptr < len(xmms))
    assert(var not in varMap.keys())
    varMap[var] = xmms[ xmms_ptr ]
    xmms_ptr += 1
    print( "# variable {0} maps to {1}".format(var, varMap[var]) )

def dec_reg(var, bits=64):
    global regs_ptr
    assert(regs_ptr < len(regs))
    assert(var not in varMap.keys())
    assert(bits == 64 or bits == 32)
    if bits == 64:
        varMap[var] = regs[ regs_ptr ]
    else:
        varMap[var] = regs32[ regs_ptr ]
    regs_ptr += 1
    print( "# variable {0} maps to {1}".format(var, varMap[var]) )



### generates the main function
def gen_asm(L, T):
    
    LUT = idx_LUT.init(128, 2)

    # list of cancelled degree-d derivatives
    cancelled_indices = get_idx_list.get_degD_idx_list(2, L, 0)  # new candidate name cancelled_indices

    # list of the most used derivatives (all degrees), in order
    mfu_indices = get_idx_list.get_mfu_idx_list(2, L, 0)  # new candidate name : mfu_indices

    dec_reg('F')
    dec_reg('alpha')
    dec_reg('buf')
    dec_reg('num_ptr')
    dec_reg('idx')
    dec_reg('num')
    dec_reg('tmp')

    for i in mfu_indices:
        dec_xmm( ('F', i) )

    #for i in range(degree-1):
    #    dec_reg( greek[i] );

    dec_xmm('sum')
    dec_xmm('zero')
    dec_reg('mask', bits=32)

    ############################# INIT #########################################

    print( '' )
    print( "# load the most-frequently used derivatives (F[0]...F[13]) into %xmm registers" )
    for i in mfu_indices:
        print( ("vmovdqa {0}({1}), {2}   ## {2} = F[{3}]".format(i*32, varMap['F'], varMap['F',i], i)) )

    #print( '' )
    #print( '# loads the ''greek letters'', i.e. indices of the derivatives that do not fit into registers' )
    #for i in range(degree-1):
    #   print( 'movq {0}({1}), {2}   ## {2} = {3}'.format(i*8, varMap['F_sp'], varMap[greek[i]], greek[i]) )
        
    #print( '' )
    #print( '# note that at this point, the register holding `F_sp` ['  + varMap['F_sp'] + '] could be used for something else' )
    #print( '' )

    print( '# initialize the last things that remains to be intialized...' )
    print( 'movq ({0}), {1}  ## num = *num_ptr'.format(varMap[ 'num_ptr' ], varMap[ 'num' ]) )
    print( 'vpxor {0}, {0}, {0}   ## zero = 0'.format(varMap['zero']) )



    ########################## UNROLLED LOOP #######################################

    # each time a greek letter is used, the offset is increased by one. This table stores the offsets
    # WARNING : these are initialized to one because the first step is done outside of the asm code
    current_counter = [1]

    #this actually unrols the loop
    print( '' )
    for unroll_step in range(1, 1 << L):   

        
            hw = min(2, popcount(unroll_step))
            print( '' )
            print( '##### step {0} [hw={1}]'.format(unroll_step, hw) )
    
            # computes the set of indices for this step
            # the first `hw` ones can be determined at compile-time (i.e. b_k(unroll_step) is defined for k<=hw),
            # but b_i( unroll_step ) is not defined when i>hw, so that we have to rely on the (runtime) value of the k_i variable

            # all the indices (of the derivatives...) are represented by a triplet (i, X, Y)
            # such an index represents a reference to X[ i + Y ]
            # if Y == None, then it is a reference to X[ i ]
            # the latter case mostly corresponds to the case where the actual derivarive index can be known at compile-time

            # this function takes an index in the above format and returns a string representation thereof
            def mem_reference( index ):
                i, X, Y = index
                if Y == None:
                    return '{0}({1})'.format(i*32 , varMap[X])
                else:
                    return '{0}({1},{2})'.format(i*32 , varMap[X], varMap[Y])
                
            # as mentionned earlier, the first `hw` indices can be computed
            known_ks = [ b_k(i, unroll_step) for i in range(1, hw+1) ]
            known_indices = [ (0, 'F', None) ] + [ (idx_LUT.idx(LUT, known_ks[:i]), 'F', None) for i in range(1,hw+1) ] 

            # `unknown_indices` denotes F[ [int]+[greek letter] ]
            unknown_indices = []
            for k in range(hw, 2):
                unknown_indices.append( (current_counter[k-hw], 'F', greek[k-hw]) )  ## What I want
#                unknown_indices.append( (current_counter[k-hw], greek[k-hw], None) )  ## What I have now || known to work
                current_counter[k-hw] += 1
        
            # the list the indices of all derivatives accessed during the step, known or unknown
            indices = known_indices + unknown_indices

            # decorate the assembly code, print( summary of the step )
            stuff = []
            for (offset, X, Y) in indices:
                if Y != None:
                    stuff.append( '{0}[ {1} + {2} ]'.format(X, Y, offset) )
                else:
                    stuff.append( '{0}[ {1} ]'.format(X, offset) )
            print( '##### {0}{1}'.format( ' ^= ( '.join(stuff), ')'*3 ) )

            # know, we start worrying about the implementation of the unformal statement we just printed

            # We know which derivatives are needed, and here we determine where they are stored (i.e. register or memory)
            # the rule is simple: they are all stored in memory except the happy few whose index is in `mfu_indices`
            locations = [ 'mem' ] * 3
            for i, (idx,X,Y) in enumerate(known_indices):
                if idx in mfu_indices:
                    locations[ i ] = 'reg'

            # we actually print( the XORs )
            print( '' )
            for i in range(len(indices)-2, -1,-1):

                first_xor = (i == len(indices)-2) # first XOR of the step ?

                # here, we print( F[ indices[i] ] ^= F[ indices[i+1] ] )
                source = i+1
                target = i
                source_offset, F_in_principle, source_var = indices[source]
                target_offset, F_in_principle, target_var = indices[target]


                assert not (locations[source] == 'reg' and locations[target] == 'mem') 

                # reg ^= reg
                if locations[source] == 'reg':
                    print( 'vpxor {0}, {1}, {1}'.format(varMap['F', source_offset],  varMap['F', target_offset]) )

                #reg ^= mem
                elif locations[target] == 'reg': 
                    if first_xor:
                        # no need to fire up the `sum` machinery, because there is a single XOR from memory
                        print( 'vpxor {0}, {1}, {1}'.format(mem_reference(indices[source]), varMap['F', target_offset]) )

                    else:
                        print( 'vpxor {0}, {1}, {1}'.format(varMap['sum'], varMap['F', target_offset] ) )
                        
                # mem ^= mem
                else: 
                    if first_xor:
                        # initialize the `sum` register
                        print( 'vmovdqa {0}, {1}'.format(mem_reference(indices[source]), varMap['sum']))

                    # implicitly, `sum` already contains the "source"
                    print( 'vpxor {0}, {1}, {1}'.format( mem_reference( indices[target]), varMap['sum'] ) )
                    print( 'vmovdqa {0}, {1}'.format( varMap['sum'], mem_reference( indices[target] )) )


            # after the XORs, the comparison

            if (T == 2):
                print( 'vpcmpeqd {0}, {1}, {1}'.format(varMap['F',0], varMap['zero']) )
            elif(T == 3):
                print( 'vpcmpeqw {0}, {1}, {1}'.format(varMap['F',0], varMap['zero']) )

            print( 'vpmovmskb {0}, {1}'.format(varMap['zero'], varMap['mask'])) ########## MODIFY MODIFY MODIFY #### 
            print( 'test {0}, {0}'.format(varMap['mask']) )
            print( 'jne ._report_solution_{0}'.format(unroll_step) )
            print( '._step_{0}_end:'.format(unroll_step) )

    print( '#############################' )
    print( '# end of the unrolled chunk #' )
    print( '#############################' )
 
    print( ('jmp ._ending') )
    #varMap['tmp'] = varMap['F'] ########## SPECIAL SITUATION ########


    ########################## WHEN SOLUTION FOUND #######################################

    print( '########### now the code that reports solutions' )
    for i in range(1, (1<<L)):

        print( '# here, it has been found that GrayCode(idx+{0}) is a solution'.format(i) )

        # à améliorer : pourquoi contourner l'adressage?
        print( '._report_solution_{0}:'.format(i) )
        print( 'vpxor {0}, {0}, {0}      #zero = 0'.format(varMap['zero']))  
        print( 'shl $3, {0}        #num <<= 3'.format(varMap['num'])) 
        print( 'mov {0}, {1}       #tmp = idx'.format(varMap['idx'], varMap['tmp']))         
        print( 'add ${0}, {1}      #tmp += i'.format(i, varMap['tmp']))         
        print( 'mov {0}, ({1}, {2})      # buf[num].idx = tmp'.format(varMap['tmp'], varMap['buf'], varMap['num'])) 
        print( 'add $4, {0}        #num += 4'.format(varMap['num'])) 
        print( 'movl {0}, ({1}, {2})    #buf[num].mask = mask '.format(varMap['mask'], varMap['buf'], varMap['num'])) 
        print( 'shr $3, {0}        #num >>= 3'.format(varMap['num'])) 
        print( 'add  $1, {0}       #num += 1'.format(varMap['num'])) 
        print( 'jmp ._step_{0}_end'.format(i))  # we return to the enumeration 
        print( '' )

    ################### End of the function #########################"
    print( "._ending:\n" )

    print( '' )
    print( '# copy back to memory the (most-frequently used) derivatives that were held in registers' )
    for i in mfu_indices:
        print( 'vmovdqa {0}, {1}({2})'.format(varMap['F', i], i*32, varMap['F']) )

    print( '' )
    print( '# store the number of solutions found in this chunk' )
    print( 'movq {0}, 0({1})'.format(varMap['num'], varMap['num_ptr']) )
    print( '' )


################### Execute ########################

T = 2   # 4x32
#T = 3   # 8x16

gen_start_asm(T)
gen_asm(9, T)
gen_end_asm()
