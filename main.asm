.data
    prompt_A: .asciiz "Nhap gia tri cho thanh ghi A: "
    prompt_B: .asciiz "Nhap gia tri cho thanh ghi B: "
    result_hex: .asciiz "Ket qua (HEX): "
    result_dec: .asciiz "Ket qua (DEC): "

.text
    main:
        # Nhập giá trị cho thanh ghi A
        li $v0, 4               # Sử dụng syscall để in chuỗi
        la $a0, prompt_A        # Load địa chỉ của chuỗi prompt_A
        syscall

        li $v0, 5               # Sử dụng syscall để đọc số nguyên từ bàn phím
        syscall
        move $t0, $v0           # Lưu giá trị được nhập vào thanh ghi A

        # Nhập giá trị cho thanh ghi B
        li $v0, 4               # Sử dụng syscall để in chuỗi
        la $a0, prompt_B        # Load địa chỉ của chuỗi prompt_B
        syscall

        li $v0, 5               # Sử dụng syscall để đọc số nguyên từ bàn phím
        syscall
        move $t1, $v0           # Lưu giá trị được nhập vào thanh ghi B

        # Gọi hàm nhân
        move $a0, $t0           # Load giá trị của thanh ghi A vào $a0
        move $a1, $t1           # Load giá trị của thanh ghi B vào $a1
        jal multiply
li $v0, 1               # Sử dụng syscall để in số DEC 64-bit
move $a0, $s0           # Load thanh ghi kết quả vào $a0
syscall
        # In kết quả
        li $v0, 4               # Sử dụng syscall để in chuỗi
        la $a0, result_hex      # Load địa chỉ của chuỗi HEX
        syscall

        li $v0, 34              # Sử dụng syscall để in số HEX 64-bit
        move $a0, $s0           # Load thanh ghi kết quả vào $a0
        syscall

        li $v0, 4               # Sử dụng syscall để in chuỗi
        la $a0, result_dec      # Load địa chỉ của chuỗi DEC
        syscall

        li $v0, 1               # Sử dụng syscall để in số DEC 64-bit
        move $a0, $s0           # Load thanh ghi kết quả vào $a0
        syscall

        # Kết thúc chương trình
        li $v0, 10              # Sử dụng syscall để thoát chương trình
        syscall

    multiply:
        # Đặt thanh ghi kết quả về 0
        li $s0, 0

        # Lặp qua từng bit của thanh ghi B
        li $t0, 0               # Biến đếm bit
    loop:
        beqz $a1, end_loop      # Nếu bit của B là 0 thì bỏ qua
        add $s0, $s0, $a0       # Cộng A vào kết quả nếu bit của B là 1

    end_loop:
        sll $a0, $a0, 1         # Dịch trái thanh ghi A
        srl $a1, $a1, 1         # Dịch phải thanh ghi B
        addi $t0, $t0, 1        # Tăng biến đếm bit
        blt $t0, 32, loop       # Lặp lại cho đến khi đã xử lý tất cả các bit

        jr $ra                  # Trả về từ hàm multiply

