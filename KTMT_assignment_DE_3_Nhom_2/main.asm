.data
   var_A_top : .word 0x90077000 # 32 bit đầu của A
   var_A_bot : .word 0x00ee0009 # 32 bit sau của A
   var_B_top : .word 0x70807000 # 32 bit đầu của B
   var_B_bot : .word 0x00867050 # 32 bit sau của B

   int_x: .word 0xFFFFFFFF # Biến dùng để đối dấu bằng xor
   int_y: .word 0x80000000

   int_10_pow_9: .word 0x3b9aca00
   int_10_pow_18_top: .word 0x0de0b6b3
   int_10_pow_18_bot: .word 0xa7640000
   int_10_pow_19_top: .word 0x8ac72304 # 10^19. Sử dụng để in kết quả hệ 10
   int_10_pow_19_bot: .word 0x89e80000 # 10^19. Sử dụng để in kết quả hệ 10

   dec_result: .asciiz "Result in dec: "
   minus_sign: .asciiz "- ("
   closing: .asciiz ")"
   hex_result: .asciiz "Result in hex: (Each line corresponds to 8 characters in the result)\n"
   space: .asciiz "   "
   enter: .asciiz "\n"

   int_dec_result_0: .word 0x00000000
   int_dec_result_1: .word 0x00000000
   int_dec_result_2: .word 0x00000000
   int_dec_result_3: .word 0x00000000
   int_dec_result_4: .word 0x00000000
   int_dec_result_5: .word 0x00000000

   print_10_pow_37: .asciiz "x10^37 + "
   print_10_pow_28: .asciiz "x10^28 + "
   print_10_pow_19: .asciiz "x10^19 + "
   print_10_pow_18: .asciiz "x10^18 + "
   print_10_pow_9: .asciiz "x10^9 + "

.text
   # từ $t0 đến $t3 lưu trữ giá trị của A
   # 64 bit đầu của A hiện bằng 0 nên cho $t0 và $t1 thành 0
   add $t0,$zero,$zero 
   add $t1,$zero,$zero

   # 64 bit sau của A
   lw $t2, var_A_top
   lw $t3, var_A_bot

   # 64 bit của B được lưu trong $t4,$t5
   lw $t4, var_B_top
   lw $t5, var_B_bot

   # Lúc này bit đầu của $t2 chính là bit dấu của A, bit đầu của $t5 chính là bit dấu của B
   # Tiến hành đổi dấu để đưa cả A,B về số dương và dùng $t6 để lưu dấu của phép nhân
   add $t6,$zero,$zero
   check_A:
	slt $t7,$t2,$zero # Kiểm tra bit đầu của A
	beq $t7,$zero,check_B #Nếu bit đầu của A là 0 thì không cần sửa A, chuyển qua B
	addi $t6,$t6,1 # Nếu bit đầu của A là 1 thì cộng 1 vào $t6
	# đảo bit của t2,t3 bằng xor, rồi cộng 1 vào $t3
	lw $t7,int_x
	xor $t2,$t2,$t7
	xor $t3,$t3,$t7
	addiu $t3,$t3,1
	bne $t3,$zero,check_B
	# Nếu sau quá trình cộng $t3 = 0 thì cộng thêm 1 cho A
	addiu $t2,$t2,1
   check_B:
	slt $t7,$t4,$zero # Kiểm tra dấu của B
	beq $t7,$zero,start_multiply
	addi $t6,$t6,1 # Nếu B âm thì cộng 1 vào $t6
	# đảo bit của t4,t5 bằng xor, cộng 1 vào $t5
	lw $t7,int_x
	xor $t4,$t4,$t7
	xor $t5,$t5,$t7
	addiu $t5,$t5,1
	bne $t5,$zero,start_multiply
	# Nếu sau quá trình cộng $t5 = 0 thì cộng thêm 1 cho A
	addiu $t4,$t4,1
	
   start_multiply:
   jal multiply_64_64_unsigned
   j print_result
   
   print_result:
   #Đưa giá trị từ $a0-$a3 vào $s0-$s3
   add $s0,$a0,$zero
   add $s1,$a1,$zero
   add $s2,$a2,$zero
   add $s3,$a3,$zero

   #In dưới dạng thập phân:
   lw $t2,int_10_pow_19_top
   lw $t3,int_10_pow_19_bot
   jal divide_128_64_unsigned # Chia A*B thành 10^19 để nhận 64 bit int_dec_result_01 và còn lại
   add $s6,$v0,$zero
   add $s7,$v1,$zero

   #Ghi 64 bit trong in_dec_result
   sw $s6,int_dec_result_0
   sw $s7,int_dec_result_1

   #Bắt đầu phân chia phần còn lại thành 10^18
   lw $t2,int_10_pow_18_top
   lw $t3,int_10_pow_18_bot
   jal divide_128_64_unsigned
   add $s6,$v0,$zero
   add $s7,$v1,$zero
   sw $s7,int_dec_result_3

   #Bắt đầu phân chia phần còn lại thành 10^9
   lw $t3,int_10_pow_9
   add $t2,$zero,$zero
   jal divide_128_64_unsigned
   add $s6,$v0,$zero
   add $s7,$v1,$zero
   sw $s7,int_dec_result_4
   sw $a3,int_dec_result_5

   lw $a2,int_dec_result_0
   lw $a3,int_dec_result_1
   add $a0,$zero,$zero
   add $a1,$zero,$zero

   #Bắt đầu phân chia phần còn lại thành 10^18
   lw $t2,int_10_pow_18_top
   lw $t3,int_10_pow_18_bot
   jal divide_128_64_unsigned
   add $s6,$v0,$zero
   add $s7,$v1,$zero
   sw $s7,int_dec_result_0

   #Bắt đầu phân chia phần còn lại thành 10^9
   lw $t3,int_10_pow_9
   add $t2,$zero,$zero
   jal divide_128_64_unsigned
   add $s6,$v0,$zero
   add $s7,$v1,$zero
   sw $s7,int_dec_result_1
   sw $a3,int_dec_result_2


   #In dưới dạng (result_1 x 10^37) + (result_2 x 10^28) + (result_3 x 10^19) + (result_4 x 10^18) + (result_5 x 10^9 + result_6)
   li $v0,4
   la $a0,dec_result
   syscall
   li $t7,1
   bne $t6,$t7,print
   li $v0,4
   la $a0,minus_sign
   syscall
   print:
   li $v0,1
   lw $a0,int_dec_result_0
   syscall
   li $v0,4
   la $a0,print_10_pow_37
   syscall
   li $v0,1
   lw $a0,int_dec_result_1
   syscall
   li $v0,4
   la $a0,print_10_pow_28
   syscall
   li $v0,1
   lw $a0,int_dec_result_2
   syscall
   li $v0,4
   la $a0,print_10_pow_19
   syscall
   li $v0,1
   lw $a0,int_dec_result_3
   syscall
   li $v0,4
   la $a0,print_10_pow_18
   syscall
   li $v0,1
   lw $a0,int_dec_result_4
   syscall
   li $v0,4
   la $a0,print_10_pow_9
   syscall
   li $v0,1
   lw $a0,int_dec_result_5
   syscall
   bne $t6,$t7,enter_step
   li $v0,4
   la $a0,closing
   syscall
   enter_step:
   li $v0,4
   la $a0,enter
   syscall

   #In dưới dạng hex: Mỗi dòng là tương ứng cho 8 kí tự trong kết quả
   li $t7,1
   bne $t6,$t7,continue
   lw $t7,int_x
   xor $a0,$s0,$t7
   xor $a1,$s1,$t7
   xor $a2,$s2,$t7
   xor $a3,$s3,$t7
   add $t0,$zero,$zero
   add $t1,$zero,$zero
   add $t2,$zero,$zero
   addi $t3,$zero,1
   jal add_128_bit_unsigned
   add $s0,$a0,$zero
   add $s1,$a1,$zero
   add $s2,$a2,$zero
   add $s3,$a3,$zero
   continue:
   li $v0,4
   la $a0,hex_result
   syscall
   li $v0,34
   add $a0,$s0,$zero
   syscall
   li $v0,4
   la $a0,enter
   syscall
   li $v0,34
   add $a0,$s1,$zero
   syscall
   li $v0,4
   la $a0,enter
   syscall
   li $v0,34
   add $a0,$s2,$zero
   syscall
   li $v0,4
   la $a0,enter
   syscall
   li $v0,34
   add $a0,$s3,$zero
   syscall
   j end
   add_128_bit_unsigned: # Thêm 128 bit a0-a3 với 128 bit t0-t3 và lưu trong a0-a3
	add_3: # Cộng t3 và a3
		add $t8,$zero,$zero # $t8 là phần nhớ khi phép cộng tràn bit
		slt $t7,$t3,$zero
		slt $t9,$a3,$zero
		add $t7,$t7,$t9
		beq $t7,$zero,add_3_no_remainder # Khi cả 2 bit đầu của a3,t3 đều là 0 thì không có khả năng có nhớ
	add_3_with_remainder: # Cộng t3,a3 có khả năng có nhớ
		addu $a3,$a3,$t3
		sltu $t7,$a3,$t3
		# Nếu $t7 = 1 tức là $a3 sau khi cộng $t3 thì nhỏ hơn $t3 => Cộng có nhớ
		beq $t7,$zero,add_2
		addi $t8,$zero,1 # Có nhớ
		j add_2
	add_3_no_remainder:
		addu $a3,$a3,$t3
	
	add_2: # Cộng t2 và a2
		slt $t7,$t2,$zero
		slt $t9,$a2,$zero
		add $t7,$t7,$t9
		beq $t7,$zero,add_2_no_remainder # Khi cả 2 bit đầu của a2,t2 đều là 0 thì không có khả năng có nhớ
	add_2_with_remainder: # Cộng t2,a2 có khả năng có nhớ
		addu $a2,$a2,$t2
		sltu $t7,$a2,$t2
		addu $a2,$a2,$t8
		add $t8,$zero,$zero
		bne $a2,$zero,zero_case_2 #Trường hợp sau khi cộng a2 thành 0 -> có nhớ
		addi $t7,$zero,1
		zero_case_2:
		# Nếu $t7 = 1 tức là $a2 sau khi cộng $t2 thì nhỏ hơn $t2 => Cộng có nhớ
		beq $t7,$zero,add_1
		addi $t8,$zero,1 # Có nhớ
		j add_1
	add_2_no_remainder:
		addu $a2,$a2,$t2
		addu $a2,$a2,$t8
		add $t8,$zero,$zero
		
	add_1: # Cộng t1 và a1
		slt $t7,$t1,$zero
		slt $t9,$a1,$zero
		add $t7,$t7,$t9
		beq $t7,$zero,add_1_no_remainder # Khi cả 2 bit đầu của a1,t1 đều là 0 thì không có khả năng có nhớ
	add_1_with_remainder: # Cộng t1,a1 có khả năng có nhớ
		addu $a1,$a1,$t1
		addu $a1,$a1,$t8
		sltu $t7,$a1,$t1
		add $t8,$zero,$zero
		bne $a1,$zero,zero_case_1 #Trường hợp sau khi cộng a1 thành 0 -> có nhớ
		addi $t7,$zero,1
		# Nếu $t7 = 1 tức là $a1 sau khi cộng $t1 thì nhỏ hơn $t1 => Cộng có nhớ
		zero_case_1:
		beq $t7,$zero,add_0
		addi $t8,$zero,1 # Có nhớ
		j add_0
	add_1_no_remainder:
		addu $a1,$a1,$t1
		addu $a1,$a1,$t8
		add $t8,$zero,$zero

	add_0: # Cộng t0 và a0, đảm bảo không có nhớ
		addu $a0,$a0,$t0
		addu $a0,$a0,$t8
		add $t8,$zero,$zero
	jr $ra

   multiply_64_64_unsigned: # Nhân 64 bit A với $t2-$t3 và 64 bit B trong $t4-$t5
	#Điều chỉnh-Stack
	#Lưu địa chỉ trả về trước vì sử dụng các hàm khác
	addi $sp, $sp, -4 # Điều chỉnh stack cho 1 mục
	sw $ra, 0($sp) # Lưu trả về địa chỉ
	add $a0,$zero,$zero
	add $a1,$zero,$zero
	add $a2,$zero,$zero
	add $a3,$zero,$zero
	start_mul:
	# Bước 1: Kiểm tra bit cuối của B
	srl $t7,$t5,1
	sll $t7,$t7,1
	# Nếu $t7 < $t5 tức là bit cuối của B hiện tại phải là 1
	sltu $t7,$t7,$t5
	beq $t7,$zero,shift_step
	# Nếu $t7 = 1 tức là bit cuối của B là 1 => Thực hiện cộng 
	jal add_128_bit_unsigned
	shift_step:
	# Bước 2: Dịch trái A, dịch phải B
		# Dịch trái A :
		# Nếu $t7 = 1 => Bit đầu của $t1 là 1 => Dịch trái 1 lên $t0, Nếu không dịch 0 lên $t0
		sll $t0,$t0,1
		slt $t7,$t1,$zero
		add $t0,$t0,$t7
		# Tương tự cho $t1,$t2
		sll $t1,$t1,1
		slt $t7,$t2,$zero
		add $t1,$t1,$t7
		
		sll $t2,$t2,1
		slt $t7,$t3,$zero
		add $t2,$t2,$t7
		
		sll $t3,$t3,1
		
		# Dịch phải B:
		# Kiểm tra bit cuối của $t4
		srl $t7,$t4,1
		sll $t7,$t7,1
		# Nếu $t7 < $t4 tức là bit cuối của $t4 hiện tại phải là 1
		sltu $t7,$t7,$t4
		srl $t4,$t4,1
		srl $t5,$t5,1
		beq $t7,$zero,check_step
		lw $t7,int_y
		add $t5,$t5,$t7
	check_step:
	#Bước 3: Kiểm tra giá trị của B, nếu B = 0 dừng phép nhân lại
		slt $t7,$t4,$zero
		slt $t8,$zero,$t4
		add $t7,$t7,$t8
		slt $t8,$zero,$t5
		slt $t9,$t5,$zero
		add $t7,$t7,$t8
		add $t7,$t7,$t9
		beq $t7,$zero,end_multiply
		j start_mul
	end_multiply:
	lw $ra, 0($sp) # Khôi phục địa chỉ trả về
	addi $sp, $sp, 4 # Xóa 1 mục khỏi stack
	jr $ra

   divide_128_64_unsigned: #Chia 128 bit A (a0-a3) thành 64 bit B (t2-t3), kết quả được ghi trong $v0,$v1 và phần còn lại trong t2-t3
	#Điều chỉnh-Stack
	#Lưu địa chỉ trả về trước vì sử dụng các hàm khác
	addi $sp, $sp, -4 # Điều chỉnh stack cho 1 mục
	sw $ra, 0($sp) # Lưu trả về địa chỉ
	add $t0,$t2,$zero
	add $t1,$t3,$zero
	add $t2,$zero,$zero
	add $t3,$zero,$zero
	lw $t9,int_y
	addi $s5,$zero,65
	start_v0_v1:
	sltu $t7,$a0,$t0
	sltu $t8,$t0,$a0
	bne $t7,$zero,shift_down_step #a<t => Chuyển sang shift down
	bne $t8,$zero,sub_step #a>t => Trừ
	
	sltu $t7,$a1,$t1
	sltu $t8,$t1,$a1
	bne $t7,$zero,shift_down_step #a<t => Chuyển sang shift down
	bne $t8,$zero,sub_step #a>t => Trừ
	
	sltu $t7,$a2,$t2
	sltu $t8,$t2,$a2
	bne $t7,$zero,shift_down_step #a<t => Chuyển sang shift down
	bne $t8,$zero,sub_step #a>t => Trừ
	
	sltu $t7,$a3,$t3
	sltu $t8,$t3,$a3
	bne $t7,$zero,shift_down_step #a<t => Chuyển sang shift down
	bne $t8,$zero,sub_step #a>t => Trừ
	
	sub_step:
		add $v1,$v1,$t8
		jal sub_128_bit_unsigned
	shift_down_step:
		# Kiểm tra bit cuối của $t0
		shift_0:
		srl $t4,$t0,1
		sll $t4,$t4,1
		sltu $t4,$t4,$t0
		srl $t0,$t0,1
		beq $t4,$zero,shift_1
		li $t5,1
		
		shift_1:
		srl $t4,$t1,1
		sll $t4,$t4,1
		sltu $t4,$t4,$t1
		srl $t1,$t1,1
		beq $t5,$zero,next_shift_1
		addu $t1,$t1,$t9
		next_shift_1:
		add $t5,$zero,$zero
		beq $t4,$zero,shift_2
		li $t5,1
		
		shift_2:
		srl $t4,$t2,1
		sll $t4,$t4,1
		sltu $t4,$t4,$t2
		srl $t2,$t2,1
		beq $t5,$zero,next_shift_2
		addu $t2,$t2,$t9
		next_shift_2:
		add $t5,$zero,$zero
		beq $t4,$zero,shift_3
		li $t5,1
		
		shift_3:
		srl $t4,$t3,1
		sll $t4,$t4,1
		sltu $t4,$t4,$t3
		srl $t3,$t3,1
		beq $t5,$zero,next_shift_3
		addu $t3,$t3,$t9
		next_shift_3:
		add $t5,$zero,$zero
		beq $t4,$zero,end_shift_down_step
		li $t5,1
	end_shift_down_step:
		subi $s5,$s5,1
		beq $s5,$zero,end_step_v0_v1
		sll $v0,$v0,1
		slt $t8,$v1,$zero
		sll $v1,$v1,1
		add $v0,$v0,$t8
		j start_v0_v1
	end_step_v0_v1:
	lw $ra, 0($sp) # Khôi phục địa chỉ trả về
	addi $sp, $sp, 4 # Xóa 1 mục khỏi stack
	jr $ra
	
   sub_128_bit_unsigned: # Chia 128 bit a0-a3 với 128 bit t0-t3 lưu trong a0-a3 (a>t) 
	sltu $t7,$a3,$t3
	subu $a3,$a3,$t3
	
	sltu $t8,$a2,$t7
	subu $a2,$a2,$t7
	sltu $t7,$a2,$t2
	subu $a2,$a2,$t2
	add $t7,$t7,$t8
	
	sltu $t8,$a1,$t7
	subu $a1,$a1,$t7
	sltu $t7,$a1,$t1
	subu $a1,$a1,$t1
	add $t7,$t7,$t8
	
	subu $a0,$a0,$t7
	subu $a0,$a0,$t0
	
	jr $ra
   end:
	# Thoát chương trình
    	li $v0, 10             
    	syscall



