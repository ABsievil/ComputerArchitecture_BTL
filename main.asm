.data
var_A_top : .word 0x80000000 # 32 bit đầu của A
var_A_bot : .word 0x00000900 # 32 bit sau của A
var_B_top : .word 0x00100000 # 32 bit đầu của B
var_B_bot : .word 0x00000004 # 32 bit sau của B
int_x: .word 0xFFFFFFFF # Biến dùng để đối dấu bằng xor
int_y: .word 0x10000000 
.text
# từ $t0 đến $t3 lưu trữ giá trị của A
# 64 bit đầu của A hiện bằng 0 nên cho $t0 và $t1 thành 0
add $t0,$zero,$zero 
add $t1,$zero,$zero
# 64 bit sau của A
lw $t2,var_A_top
lw $t3,var_A_bot
# 64 bit của B được lưu trong $t4,$t5
lw $t4,var_B_top
lw $t5,var_B_bot
# Lúc này bit đầu của $t2 chính là bit dấu của A, bit đầu của $t5 chính là bit dấu của B

# Tiến hành đổi dấu để đưa cả A,B về số dương và dùng $t6 để lưu dấu của phép nhân
add $t6,$zero,$zero
check_A:
slt $t7,$t2,$zero # Kiểm tra bit đầu của A
beq $t7,$zero,check_B #Nếu bit đầu của A là 0 thì không cần sửa A, chuyển qua B
addi $t6,$t6,1 # Nếu nit đầu của A là 1 thì cộng 1 vào $t6
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
start_multiply: # bắt đầu quá trình nhân A,B. Lưu ý dấu của phép nhân sẽ là dương nếu $t6 = 0 hoặc 2, nếu $t6 = 1 thì âm
# Đầu tiên để $s0 đến $s3 chứa dữ liệu của phép nhân này
add $s0,$zero,$zero
add $s1,$zero,$zero
add $s2,$zero,$zero
add $s3,$zero,$zero
multiply: # Bắt đầu nhân
# Bước 1: Kiểm tra bit cuối của B
srl $t7,$t5,1
sll $t7,$t5,1
# Nếu $t7 < $t5 tức là bit cuối của B hiện tại phải là 1
slt $t7,$t7,$t5
beq $t7,$zero,end_step
# Nếu $t7 = 1 tức là bit cuối của B là 1 => Thực hiện cộng
add_3: # Cộng t3 và s3
add $t8,$zero,$zero # $t8 là phần nhớ khi phép cộng tràn bit
slt $t7,$t3,$zero
slt $t9,$s3,$zero
add $t7,$t7,$t9
beq $t7,$zero,add_3_no_remainder # Khi cả 2 bit đầu của s3,t3 đều là 0 thì không có khả năng có nhớ
add_3_with_remainder: # Cộng t3,s3 có khả năng có nhớ
addu $s3,$s3,$t3
slt $t7,$s3,$zero
# Nếu $t7 = 1 tức là $s3 có bit đầu là 1 => Cộng không có nhớ
bne $t7,$zero,add_2
addi $t8,$zero,1 # Có nhớ
j add_2
add_3_no_remainder:
addu $s3,$s3,$t3
add_2: # Cộng t2 và s2
