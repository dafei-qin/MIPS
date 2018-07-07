#UART READ
#伪指令： uart_r $reg
	led 00000001
	addi $at, $zero, 2 #00010
	sw $t0, -4($ra) # store original t0
	lui $t0, 0x4000
	addi $t0, $t0, 0x0020 #UART_CON
	sw $at, 0($gp)
UART_R:
	lw $at, 0($t0) 
	addi $at, $at, -10  # $at == 01010
	bne $at, $zero, UART_R
	lw $reg, -4($t0) #UART_RXD
	addi $at, $zero, 0
	sw $at, 0($t0)
	lw $t0, -4($ra) # restore t0
	led 00000000
#UART WRITE
#伪指令 uart_w $reg
	led 00000010
	sw $t0, -4($ra) #store original t0
	lui $t0, 0x4000
	addi $t0, $t0, 0x0020 #UART_CON
UART_W:
	lw $at, 0($t0)
	bne $at, $zero, UART_W
	sw $reg, -8($t0)  #UART_TXD
	addi $at, $zero, 1 #00001
	sw $at, 0($t0)
	lw $t0, -4($ra)
	led 00000000
#LED
#伪指令: led LED0-7
	sw $t0, -4($ra) #store original t0
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
	lw $t0, -4($ra) # restore $t0
#伪指令 ledr $reg
	sw $t0, -4($ra) #store original t0
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
	lw $t0, -4($ra)


