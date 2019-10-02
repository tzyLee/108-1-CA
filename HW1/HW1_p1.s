.data
str1: .asciiz	"Before sorting: \n"
str2: .asciiz	"\nResult:\n"
str3: .asciiz	"\n"
num: .word -1 3 -5 7 -9 2 -4 6 -8 10

.text
main:
	#print initiate
	li      $v0, 4
	la      $a0, str1
	syscall
	la      $a0, num	    # a0=num
	la      $a1, 10
	jal     prints
	
	#TODO
	la      $a0, num
	li      $a1, 10
	jal     sort            # sort(num, 10)
	
	
	#print result
	li      $v0, 4
	la      $a0, str2
	syscall
	la      $a0, num	    # a0=num
	la      $a1, 10
	jal     prints
	
# -----
#  Done, terminate program.
	li	    $v0, 10			# terminate
	syscall					# system call

.end main

prints:
	addi    $sp, $sp, -16
	sw      $s3, 12($sp)
	sw      $s2, 8($sp)
	sw      $s1, 4($sp)
	sw      $s0, 0($sp)

	move    $s0, $zero
	move    $s2, $a0
	move    $s3, $a1
printloop:
	bge     $s0, $s3, printexit
	sll     $s1, $s0, 2
	add     $t2, $s2, $s1
	lw      $t3, 0($t2)
	li      $v0, 1 # print_int
	move    $a0, $t3
	syscall
	
	li      $v0, 4
	la      $a0, str3
	syscall 
	
	addi    $s0, $s0, 1
	j       printloop
printexit:
	lw      $s0, 0($sp)
	lw      $s1, 4($sp)
	lw      $s2, 8($sp)
	lw      $s3, 12($sp)
	addi    $sp, $sp, 16
	jr      $ra

swap:
	# $a0: array, $a1: offset
	add     $t0, $a0, $a1  # $t0 = &array[index] = array + offset
	lw      $t1, 0($t0)    # $t1 = array[index]
	lw      $t2, 4($t0)    # $t2 = array[index+1]
	sw      $t2, 0($t0)    # array[index] = $t2
	sw      $t1, 4($t0)    # array[index+1] = $t1
	jr      $ra            # return

sort:
	# save and registers
	addi    $sp, $sp, -16              # $sp -= 4*4;
	sw      $s0, 12($sp)               # save $s0  
	sw      $s1, 8($sp)                # save $s1
	sw      $s2, 4($sp)                # save $s2
	sw      $ra, 0($sp)                # save $ra
	# $a0: array, $a1: length
	move    $s2, $a1                   # $s2 = length;
	move    $s0, $zero                 # int i = 0; // $s0
outer_for:
	bge     $s0, $s2, outer_for_end    # jump if i >= n {
	addi    $s1, $s0, -1               #   int j = i - 1; // $s1
inner_for:
	blt     $s1, $zero, inner_for_end  #   jump if j < 0
	sll     $t1, $s1, 2                #   offset = j*4;
	add     $t2, $a0, $t1              #   $s2 = array + offset;
	lw      $t3, 0($t2)                #   $t3 = v[j];
	lw      $t4, 4($t2)				   #   $t4 = v[j+1];
	ble     $t3, $t4, inner_for_end    #   jump if v[j] <= v[j+1] {
	move    $a1, $t1
	jal     swap                       #     swap(v, j);
	addi    $s1, $s1, -1               #     j -= 1;
	j       inner_for                  #   }
inner_for_end:
	addi    $s0, $s0, 1                #   i += 1;
	j       outer_for                  # }
outer_for_end:
	lw      $ra, 0($sp)                # save $ra
	lw      $s2, 4($sp)                # save $s2
	lw      $s1, 8($sp)                # save $s1
	lw      $s0, 12($sp)               # save $s0  
	addi    $sp, $sp, 16               # $sp += 4*4;
	jr      $ra                        # return