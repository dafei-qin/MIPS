#UART READ
#伪指令： uart_r $reg
	led 00000001
	addi $at, $zero, 2 #00010
	sw $t0, 4($sp) # store original t0
	lui $t0, 0x4000
	addi $t0, $t0, 0x0020 #UART_CON
	sw $at, 0($t0)
UART_R:
	lw $at, 0($t0) 
	addi $at, $at, -10  # $at == 01010
	bne $at, $zero, UART_R
	lw $reg, -4($t0) #UART_RXD
	addi $at, $zero, 0
	sw $at, 0($t0) # $at = 00000
	lw $t0, 4($sp) # restore t0
	led 00000000
#UART WRITE
#伪指令 uart_w $reg
	led 00000010
	sw $t0, 4($sp) #store original t0
	lui $t0, 0x4000
	addi $t0, $t0, 0x0020 #UART_CON
UART_W:
	lw $at, 0($t0)
	bne $at, $zero, UART_W
	sw $reg, -8($t0)  #UART_TXD
	addi $at, $zero, 1 #00001
	sw $at, 0($t0)
UART_WF:
	lw $at, 0($t0) 
	addi $at, $at, -22 #10110
	bne $at, $zero, UART_WF
	sw $zero, 0($t0) #00000
	lw $t0, 4($sp)
	led 00000000
#LED
#伪指令: led LED0-7
	sw $t0, 4($sp) #store original t0
	lui $t0, 0x4000
	addi $t0, $t0, 0x0010 #load switch
	lw $at, 0($t0)
	lui $t0, 0x4000
	addi $t0, $t0, 0x000C #LED addr
	beq $at, $zero LED_0 
	addi $at, $zero,  LED0-7 # if switch !=0, light up LEDs
	sw $at, 0($t0)
	j LED_END
LED_0:
	addi $at, $zero,  0 # if switch == 0, LED = 0 
	sw $at, 0($t0)
LED_END:
	lw $t0, 4($sp) # restore $t0
#伪指令 ledr $reg
	sw $t0, 4($sp) #store original t0
	lui $t0, 0x4000
	addi $t0, $t0, 0x0010 #load switch
	lw $at, 0($t0)
	lui $t0, 0x4000
	addi $t0, $t0, 0x000C #LED addr
	beq $at, $zero, LEDR_0 
	sw $reg, 0($t0) # if switch !=0, light up LEDs
	j LEDR_END
LEDR_0:
	sw $zero, 0($t0)  # if switch == 0, LED = 0 
LEDR_END:
	lw $t0, 4($sp)
#伪指令 digi1 $reg 
	lui $at, 0x4000
	addi $at, $at, 8
	sw $zero, 0($at) # TCON <= 0
	sw $t0, 4($sp) #store original t0
	sw $t1, 8($sp) #store original t1
	lui $at, 0x0000 
	addiu $at, $at, 0x400
	lui $t1, 0xFF00
	srl $t1, $t1, 16 #t1 = 0x0000FF00
	lw $t0, -4($at)
	and $t0, $t0, $t1 #t0 = {16{0}, t0[15:8], 8{0}}
	add $t0, $t0, $reg #t0 = {16{0},t0[15:8], reg[7:0]}
	sw $t0, -4($at)
	#open clock
	lui $at, 0x4000
	addi $at, $at, 8
	addiu $t0, $zero, -10001 #t0 = 0xFFFFD8EF 
	sw $t0, -8($at) #TH <= 0xFFFFD8EF
	sw $t0, -4($at) #TL <= 0xFFFFD8EF
	addi $t0, $zero, 3
	sw $t0, 0($at) #TCON <= 3
	lw $t0, 4($sp) #restore $t0
	lw $t1, 8($sp) #restore $t1
#伪指令 digi2 $reg
	lui $at, 0x4000
	addi $at, $at, 8
	sw $zero, 0($at) # TCON <= 0
	sw $t0, 4($sp) #store original t0
	sw $t1, 8($sp) #store original t1
	lui $at, 0x0000 
	addiu $at, $at, 0x400
	lui $t0, 0x00FF
	srl $t0, $t0, 16 #t0 = 0x000000FF
	lui $t1, 0xFFFF
	add $t1, $t1, $t0 #t1 = FFFF00FF
	lw $t0, -4($at)
	sll $reg, $reg, 8
	
	and $t0, $t1, $t0  #t0 = {24{0}, t0[7:0]}
	add $t0, $t0, $reg #t0 = {16{0},reg[7:0], t0[7:0]}
	srl $reg, $reg, 8 #restore $reg
	sw $t0, -4($at)
	#open clock
	lui $at, 0x4000
	addi $at, $at, 8
	addi $t0, $zero, -10001 #t0 = 0xFFFFD8EF
	sw $t0, -8($at) #TH <= 0xFFFFD8EF
	sw $t0, -4($at) #TL <= 0xFFFFD8EF 
	addi $t0, $zero, 3
	sw $t0, 0($at) #TCON <= 3
	lw $t0, 4($sp) #restore $t0
	lw $t1, 8($sp) #restore $t1

#中断程序
	lui $at, 0x4000
	addi $at, $at, 8
	sw $t0, 4($sp) #store original t0
	sw $t1, 8($sp) #store original t1
	sw $t2, 12($sp) #store original t2
	sw $ra, 16($sp) #store original ra
	addi $t1, $zero, -7 #t1 = 0xFFFFFFF9
	lw $t0, 0($at)
	and $t0, $t0, $t1
	sw $t0, 0($at) #TCON &= 0xFFFFFFF9

	lui $at, 0x0000
	addiu $at, $at, 0x400
	lw $t0, -4($at) #$t0 = digitube_data
DT_OP:
	lui $at, 0x4000
	addi $at, $at, 0x0014
	addiu $t1, $zero, 15 #t1 = 0x0000000F
	and $t1, $t1, $t0 #t1 = {28{0}, t0[3:0]}
	jal DT_TAB
	addi $t1,  $t1, 0x100 #digi_0
	sw $t1, 0($at)

	addiu $t1, $zero, 240 #t1 = 0x000000F0
	and $t1, $t1, $t0 #t1 = {24{0}, t0[7:4], 4{0}}
	srl $t1, $t1, 4 #t1 = {28{0}, t0[7:4]}
	jal DT_TAB
	addi $t1, $t1, 0x200 #digi_1
	sw $t1, 0($at)

	addiu $t1, $zero, 3840 #t1 = 0x00000F00
	and $t1, $t1, $t0 #t1 = {20{0}, t0[11:8], 8{0}}
	srl $t1, $t1, 8 #t1 = {28{0}, t0[11:8]}
	jal DT_TAB
	addi $t1, $t1, 0x400 #digi_2
	sw $t1, 0($at)

	lui $t1, 0x000F
	srl $t1, $t1, 4 #t1 = 0x0000F000
	and $t1, $t1, $t0 #t1 = {16{0}, t0[15:12], 12{0}}

	srl $t1, $t1, 12 #t1 = {28{0}, t0[15:12]}
	jal DT_TAB
	addi $t1, $t1, 0x800 #digi_3
	sw $t1, 0($at)

	lui $at, 0x4000
	addi $at, $at, 8
	lw $t1, 0($at) #t1 = TCON
	addi $t2, $zero, 2
	or $t1, $t1, $t2 #t1 |= 0x00000002
	sw $t1, 0($at)
	lw $t0, 4($sp) #restore original t0
	lw $t1, 8($sp) #restore original t1
	lw $t2, 12($sp) #restore original t2
	lw $ra, 16($sp) #restore original ra
	jr $26
DT_TAB:
	beq $t1, $zero, DT_0
	addi $t1, $t1, -1
	beq $t1, $zero, DT_1
	addi $t1, $t1, -1
	beq $t1, $zero, DT_2
	addi $t1, $t1, -1
	beq $t1, $zero, DT_3
	addi $t1, $t1, -1
	beq $t1, $zero, DT_4
	addi $t1, $t1, -1
	beq $t1, $zero, DT_5
	addi $t1, $t1, -1
	beq $t1, $zero, DT_6
	addi $t1, $t1, -1
	beq $t1, $zero, DT_7
	addi $t1, $t1, -1
	beq $t1, $zero, DT_8
	addi $t1, $t1, -1
	beq $t1, $zero, DT_9
	addi $t1, $t1, -1
	beq $t1, $zero, DT_A
	addi $t1, $t1, -1
	beq $t1, $zero, DT_B
	addi $t1, $t1, -1
	beq $t1, $zero, DT_C
	addi $t1, $t1, -1
	beq $t1, $zero, DT_D
	addi $t1, $t1, -1
	beq $t1, $zero, DT_E
	addi $t1, $t1, -1
	beq $t1, $zero, DT_F
DT_0:
	addiu $t1, $zero, 0x40
	jr $ra
DT_1:
	addiu $t1, $zero, 0x79
	jr $ra
DT_2:
	addiu $t1, $zero, 0x24
	jr $ra
DT_3:
	addiu $t1, $zero, 0x30
	jr $ra
DT_4:
	addiu $t1, $zero, 0x19
	jr $ra
DT_5:
	addiu $t1, $zero, 0x12
	jr $ra
DT_6:
	addiu $t1, $zero, 0x02
	jr $ra
DT_7:
	addiu $t1, $zero, 0x78
	jr $ra
DT_8:
	addiu $t1, $zero, 0x00
	jr $ra
DT_9:
	addiu $t1, $zero, 0x10
	jr $ra
DT_A:
	addiu $t1, $zero, 0x08
	jr $ra
DT_B:
	addiu $t1, $zero, 0x03
	jr $ra
DT_C:
	addiu $t1, $zero, 0x46
	jr $ra
DT_D:
	addiu $t1, $zero, 0x21
	jr $ra
DT_E:
	addiu $t1, $zero, 0x06
	jr $ra
DT_F:
	addiu $t1, $zero, 0x0E
	jr $ra