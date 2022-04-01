########################################################################
# CP1521 20T3 --- assignment 1: a cellular automaton renderer
#
# Written by <<Tuan Kiet Phan-z5237616>>, <<10/10/2020>>.


# Maximum and minimum values for the 3 parameters.

MIN_WORLD_SIZE	=    1
MAX_WORLD_SIZE	=  128
MIN_GENERATIONS	= -256
MAX_GENERATIONS	=  256
MIN_RULE	=    0
MAX_RULE	=  255

# Characters used to print alive/dead cells.

ALIVE_CHAR	= '#'
DEAD_CHAR	= '.'

# Maximum number of bytes needs to store all generations of cells.

MAX_CELLS_BYTES	= (MAX_GENERATIONS + 1) * MAX_WORLD_SIZE

	.data

# `cells' is used to store successive generations.  Each byte will be 1
# if the cell is alive in that generation, and 0 otherwise.

cells:	.space MAX_CELLS_BYTES


# Some strings you'll need to use:

prompt_world_size:	.asciiz "Enter world size: "
error_world_size:	.asciiz "Invalid world size\n"
prompt_rule:		.asciiz "Enter rule: "
error_rule:		.asciiz "Invalid rule\n"
prompt_n_generations:	.asciiz "Enter how many generations: "
error_n_generations:	.asciiz "Invalid number of generations\n"

	.text

	#
	# $s0 = world_size
	# $s1 = rule
	# $s2 = n_generations
	# $s3 = cells
	#
	# YOU SHOULD ALSO NOTE WHICH REGISTERS DO NOT HAVE THEIR
	# ORIGINAL VALUE WHEN `run_generation' FINISHES
	#

main:
    # prologue
    addi $sp, $sp, -4
    sw   $fp, ($sp)
    la   $fp, ($sp)
    addi $sp, $sp, -4
    sw   $ra, ($sp)
    addi $sp, $sp, -4
    sw   $s0, ($sp)
    addi $sp, $sp, -4
    sw   $s1, ($sp)
    addi $sp, $sp, -4
    sw   $s2, ($sp)
    addi $sp, $sp, -4
    sw   $s3, ($sp)
    
    la      $a0, prompt_world_size          # printf("Enter world size: ");
    li      $v0, 4
    syscall
    li      $v0, 5
    syscall                                 # scanf("%d", &world_size);
    move    $s0, $v0                        # $s0 = world_size

check_world_size:
    blt     $s0, MIN_WORLD_SIZE, wrong_world_size
    bgt     $s0, MAX_WORLD_SIZE, wrong_world_size
    
    
    la      $a0, prompt_rule                # printf("Enter rule: ");
    li      $v0, 4
    syscall
    li      $v0, 5
    syscall                                 # scanf("%d", &rule);
    move    $s1, $v0                        # $s1 = rule

check_rule:
    blt     $s1, MIN_RULE, wrong_rule
    bgt     $s1, MAX_RULE, wrong_rule
    
 
    la      $a0, prompt_n_generations       # printf("Enter no of generations: ");
    li      $v0, 4
    syscall
    li      $v0, 5
    syscall                                 # scanf("%d", &n_generations);
    move    $s2, $v0                        # $s2 = n_generations

check_n_generation:
    blt     $s2, MIN_GENERATIONS, wrong_generation
    bgt     $s2, MAX_GENERATIONS, wrong_generation

    li      $a0, '\n'                       # putchar('\n')
    li      $v0, 11
    syscall
        
    la      $s3, cells                      # $s3 = cells[][]
    
    li      $t0, 0                          # $t0 = 0
    li      $t1, -1                         # $t1 = -1
check_neg_n_gen:
    bgez    $s2, go_on
    li      $t0, 1                          # $t0 = 1
    mul     $s2, $s2, $t1                   # n_generations = -n_generations
    
go_on: 

    move    $t3, $s0                        # $t3 = world_size    
    li      $t2, 2                          # $t2 = 2
    div     $t3, $t3, $t2                   # $t3 = $t3/2

    add     $t3, $t3, $s3                   # cell[][world_size/2]
    li      $t5, 1                          # $t5 = 1
    sb      $t5, ($t3)                      # cells[][world_size/2] = 1
    
    
    li      $t2, 1                          # g = $t2 = 1
while_run_gen:
    bgt     $t2, $s2, end_while_run_gen     # if g > n_generations, go to end_while_run_gen
    move    $a0, $s0                      
    move    $a1, $t2
    move    $a2, $s1
   
    jal run_generation 
    
    addi    $t2, $t2, 1                     # $t2 = $t2 + 1
    j while_run_gen
    
end_while_run_gen: 
if_reverse:    
    beqz    $t0, else_if                    # if reverse = 0, go to else_if
    
    move    $t4, $s2                        # $t4 = g = n_generations
while_print_gen_1:
    bltz    $t4, end_main                   # if g <= 0, go to end_main
    
    move    $a0, $s0                        # $a0 = world_size
    move    $a1, $t4                        # $a1 = which_generation
  
    jal print_generation
    
    addi    $t4, $t4, -1
    j while_print_gen_1
       
else_if:    
    li      $t4, 0                          # $t4 = which_generation = 0
while_print_gen_2:
    bgt     $t4, $s2, end_main              # if g > n_generations, go to end_main
    
    move    $a0, $s0                        # $a0 = world_size
    move    $a1, $t4                        # $a1 = which_generation
 
    jal print_generation
    
    addi    $t4, $t4, 1                     # $t4 = $t4+1
    j while_print_gen_2
    
    
wrong_generation:
    la      $a0, error_n_generations      # printf("Invalid number of generations\n"); 
    li      $v0, 4
    syscall
    j end_main
     
wrong_rule:
    la      $a0, error_rule               # printf("Invalid rule\n");
    li      $v0, 4
    syscall
    j end_main   
    
wrong_world_size:  
    la      $a0, error_world_size         # printf("Invalid world size\n");
    li      $v0, 4
    syscall
    j end_main
    
end_main:
    # epilogue
   lw   $s3, ($sp)
   addi $sp, $sp, 4
   lw   $s2, ($sp)
   addi $sp, $sp, 4
   lw   $s1, ($sp)
   addi $sp, $sp, 4
   lw   $s0, ($sp)
   addi $sp, $sp, 4
   lw   $ra, ($sp)
   addi $sp, $sp, 4
   lw   $fp, ($sp)
   addi $sp, $sp, 4
   
	li	$v0, 0
	jr	$ra



	#
	# Given `world_size', `which_generation', and `rule', calculate
	# a new generation according to `rule' and store it in `cells'.
	#

	# $a0 = $s0 = world_size
	# $a1 = $t2 = $s1 = which_generation
	# $a2 = $s1 = rule
	# $t1, $t5, 6 7 
	# $s4, 5, 6, 7

run_generation:
    # prologue
    addi $sp, $sp, -4
    sw   $fp, ($sp)
    la   $fp, ($sp)
    addi $sp, $sp, -4
    sw   $ra, ($sp)
    addi $sp, $sp, -4
    sw   $s4, ($sp)
    addi $sp, $sp, -4
    sw   $s5, ($sp)
    addi $sp, $sp, -4
    sw   $s6, ($sp)
    addi $sp, $sp, -4
    sw   $s7, ($sp)


    move $s4, $a0                   # world_size
    move $s5, $a1                   # which_generation
    move $s6, $a2                   # rule

    li      $s7, 0                  # x = $s7 = 0
while_run_function:
    move $s5, $a1
    move $t8, $s5                   # $t8 = which_generation
    move $t9, $s5                   # $t9 = which_generation
    bge $s7, $s4, end_while_run_function
    
    li      $t5, 0                  # int left = 0
                                 
if_left: 
                             
    blez    $s7, end_if_left
    addi    $t8, $t8, -1
    addi    $s7, $s7, -1            # x=x-1
    add     $t8, $t8, $s7
    add     $t8, $t8, $s3
    lb      $t5, ($t8)              # $t5 = left = cells[which_generation -1 ][x-1]

    addi    $s7, $s7, 1             # x=x+1
end_if_left:

    addi    $s5, $s5, -1
    add     $s5, $s5, $s7
    add     $s5, $s5, $s3
    lb      $t6, ($s5)              # $t6 = centre = cells[which_generation -1 ][x]
    addi    $s5, $s5, 1
    
    li      $t7, 0                  # t7 = right = 0
if_right:
    addi    $s4, $s4, -1            # world_size = world_size -1
    bge     $s7, $s4, end_if_right  # if x >= world_size - 1, go to end_if_right
    addi    $t9, $t9, -1
    addi    $s7, $s7, 1             # x=x+1
    add     $t9, $t9, $s7
    add     $t9, $t9, $s3
    lb      $t7, ($t9)              # $t7 = centre = cells[which_generation -1 ][x+1]
    addi    $s4, $s4, 1             # world_size = world_size +1
    addi    $s7, $s7, -1            # x=x-1
end_if_right:    
                
    sll     $t5, $t5, 2             # left << 2
    sll     $t6, $t6, 1             # centre << 1
    sll     $t7, $t7, 0             # right << 0
    
    or      $t5, $t5, $t6           # left << 2 | centre << 1
    or      $t5, $t5, $t7           # left << 2 | centre << 1 | right << 0
    
    li      $t6, 1
    sllv    $t5, $t5, $t6          # int bit = 1 << state;
    
    and     $t5, $s6, $t5           # set = rule & bit;
    
    move    $s5, $a1
 if_set:
    beqz    $t5, else_set
    li      $t7, 1
    add     $s5, $s5, $s7
    add     $s5, $s5, $s3
    sb      $t7, ($s5)              # cells[which_generation][x] = 1;
    j function_continue
 else_set:
    li      $t7, 0
    add     $s5, $s5, $s7
    add     $s5, $s5, $s3           # cells[which_generation][x] = 0;
    sb      $t7, ($s5)
      
function_continue:    
    addi    $s7, $s7, 1
    j while_run_function
end_while_run_function:  
   # epilogue

   lw   $s7, ($sp)
   addi $sp, $sp, 4
   lw   $s6, ($sp)
   addi $sp, $sp, 4
   lw   $s5, ($sp)
   addi $sp, $sp, 4
   lw   $s4, ($sp)
   addi $sp, $sp, 4
   lw   $ra, ($sp)
   addi $sp, $sp, 4
   lw   $fp, ($sp)
   addi $sp, $sp, 4
    li $v0, 0
	jr	$ra


	#
	# Given `world_size', and `which_generation', print out the
	# specified generation.
	#

	# $a0 = world_size
	# $a1 = which_generation

print_generation:
    # prologue
    
    addi $sp, $sp, -4
    sw   $fp, ($sp)
    la   $fp, ($sp)
    addi $sp, $sp, -4
    sw   $ra, ($sp)
    addi $sp, $sp, -4
    sw   $s4, ($sp)
    addi $sp, $sp, -4
    sw   $s5, ($sp)
    addi $sp, $sp, -4
    sw   $s6, ($sp)
    addi $sp, $sp, -4
    sw   $s7, ($sp)


    move $s4, $a0                       # $s4 = world_size
    move $s5, $a1                       # $s5 = which_generation
    
    move    $a0, $s5                    # printf("%d", which_generation);
    li      $v0, 1
    syscall
    li      $a0, '\t'
    li      $v0, 11                     # putchar('\t')
    syscall
    
    li      $t7, 0
    
while_print_function:
    bge     $t7, $s4, end_print_function
    
    move    $t6, $s4
    add     $t6, $t6, $t7
    add     $t6, $t6, $s3
    lb      $t8, ($t6)                 # $t8 = cells[which_generation][x]

    beqz    $t8, print_dead_char       # if $t8 = 0, go to print_dead_char
    
    li      $a0, ALIVE_CHAR
    li      $v0, 11                    # putchar('#')
    syscall
    j continue_print
print_dead_char:
    li      $a0, DEAD_CHAR              # putchar('.')
    li      $v0, 11
    syscall
continue_print:
    addi    $t7, $t7, 1
    j while_print_function
end_print_function:
    li      $a0, '\n'
    li      $v0, 11
    syscall                             # putchar('\n')
    
   # epilogue
 
   lw   $s7, ($sp)
   addi $sp, $sp, 4
   lw   $s6, ($sp)
   addi $sp, $sp, 4
   lw   $s5, ($sp)
   addi $sp, $sp, 4
   lw   $s4, ($sp)
   addi $sp, $sp, 4
   lw   $ra, ($sp)
   addi $sp, $sp, 4
   lw   $fp, ($sp)
   addi $sp, $sp, 4
    li $v0, 0
	jr	$ra
