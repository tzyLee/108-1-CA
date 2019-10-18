.data
	str1: .asciiz "The highest score is: "
	str2: .asciiz "Traceback result:\n"
	nextline: .asciiz "\n"
	tab:  .asciiz "\t"
	
######################################################

#2

	seq1: .asciiz "CAAGAATGTCACAGGTCCAT"
	seq2: .asciiz "CAGCATCACACTTA"
	score: .word 0:315	#(len1 + 1) * (len2 + 1)
	dir: .word 0:315


.text
	main:	
		li $s0, 20		#seq 1 length
		li $s1, 14		#seq 2 length
		
		
######################################################		
		
		la      $s2, seq1
		la      $s3, seq2
		la      $s4, score                 # int* h = score; // h goes from score[0][0] to score[-2][-2]
		la      $s5, dir                   # int* d = dir;   // d goes from dir[1][1] to dir[-1][-1]
# Calculate score and dir, recording the max score
		li      $t6, 0                     # int max = 0;    // $t6 records the maximum score
		la      $t7, dir                   # int* max_pos;   // $t7 records the position of dir of maximum score
		sll     $t5, $s0, 2                # $t5 = seq1.length() * sizeof(int); // offset of an entire row
		add     $s5, $s5, $t5              # d += seq1.length() * sizeof(int);  // Move d to dir[0][-1]
		addi    $s5, $s5, 8                # d += 2 * sizeof(int);              // Move d to dir[1][1]
		move    $s6, $zero                 # int i = 0;                         // $s6;
	fill_row_for:
		bge     $s6, $s1, fill_row_for_end # while (i < seq2.length()) {
		li      $s7, 0                     #   int j = 0;          // $s7
	fill_col_for: 
		bge     $s7, $s0, fill_col_for_end #   while (j < seq1.length()) {
		lw      $t0, 0($s4)                #     $t0 = h[0];       // $t0 = H[i][j]
		add     $t1, $s2, $s7              #     $t1 = seq1 + j;
		lbu     $t1, 0($t1)                #     $t1 = seq1[j+1];
		add     $t2, $s3, $s6              #     $t2 = seq2 + i;
		lbu     $t2, 0($t2)				   #     $t2 = seq2[i+1];	
		bne     $t1, $t2, mismatch         #     if (seq1[j+1] == seq2[i]+1) {
		addi    $t0, $t0, 3                #       $t0 += 3;       // Match score: 3
		j       gap                        #     }
	mismatch:                              #     else {
		addi    $t0, $t0, -1               #       $t0 -= 1;       // Mismatch score: -1
	gap:								   #     }
		lw      $t2, 4($s4)                #     $t2 = h[1];       // $t2 = H[i][j+1]
		add     $t4, $s4, $t5              #     $t4 = h + seq1.length() * sizeof(int);
		lw      $t3, 4($t4)                #     $t3 = $t4[1];     // $t3 = H[i+1][j]
		bge     $t2, $t3, right            #     if ($t2 <= $t3) { // H[i+1][j] >= H[i][j+1]
		move    $t1, $t3                   #       $t1 = $t3;
		li      $t3, 1
		sw      $t3, 0($s5)                #       *d = 2;
		j       store                      #     }
	right:                                 #     else {            // H[i+1][j] < H[i][j+1]
		move    $t1, $t2                   #       $t1 = $t2;
		li      $t3, 2
		sw      $t3, 0($s5)                #       *d = 1;
	store:								   #     }
		addi    $t1, $t1, -2               #     $t1 -= 2;         // Gap score: -2
		bge     $t0, $t1, diag             #     if ($t0 < $t1) {
		move    $t0, $t1                   #       $t0 = $t1;
		j       nonnegative                #     }
	diag:                                  #     else {
		li      $t3, 3
		sw      $t3, 0($s5)                #       *d = 3;
	nonnegative:                           #     }
		bgt     $t0, $zero, positive       #     if ($t0 <= $zero) {
		move    $t0, $zero                 #       $t0 = $zero;
		li      $t3, 0
		sw      $t3, 0($s5)                #       *d = 0;
	positive:							   #     }
		sw      $t0, 8($t4)                #     $t4[2] = $t0;     // H[i+1][j+1] = $t0;
		ble     $t0, $t6, not_max          #     if ($t0 > max) {
		move    $t6, $t0                   #       max = $t0;
		move    $t7, $s5                   #       max_pos = d;
	not_max:							   #     }
		addi    $s5, $s5, 4                #     d += sizeof(int);
		addi    $s4, $s4, 4                #     h += sizeof(int);
		addi    $s7, $s7, 1                #     ++j;
		j       fill_col_for               #   }
	fill_col_for_end:
		addi    $s5, $s5, 4                #   d += sizeof(int);
		addi    $s4, $s4, 4                #   h += sizeof(int);
		addi    $s6, $s6, 1                #   ++i;
		j       fill_row_for               # }
	fill_row_for_end:
	# $t0 ~ $t4 can be used, $t5, $t6, $t7 is in use

# Print maximum
		la      $a0, str1
		li      $v0, 4
		syscall                            # puts("The highest score is: ");
		move    $a0, $t6
		li      $v0, 1
		syscall                            # printf("%d", max);

# Backtrace
		la      $a0, nextline
		li      $v0, 4
		syscall
		la      $a0, str2
		li      $v0, 4
		syscall                            # puts("Traceback result:\n");
		lw      $t0, 0($t7)                # int $t0 = *max_pos;    // $t0 = $t6, $t0 stores the direction on dir[i][j]
	backtrace_while:
		beq     $t0, $zero, backtrace_end  # while ($t0 != 0) {
		move    $a0, $t0                   #   $a0 = $t0;
		li      $v0, 1
		syscall                            #   print("%d", dir[i][j]);
		addi    $t7, $t7, -4               #   max_pos -= sizeof(int);
		beq     $t0, 1, update             #   if ($t0 != 1) {
		sub     $t7, $t7, $t5              #     max_pos -= seq1.length() * sizeof(int);
		beq     $t0, 2, update             #     if ($t0 != 2)
		addi    $t7, $t7, -4               #       max_pos -= sizeof(int);
	update:                                #   }
		lw      $t0, 0($t7)                #   $t0 = *max_pos;
		j       backtrace_while            # }
	backtrace_end:
# Exit
		li      $v0, 10
		syscall
