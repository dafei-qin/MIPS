import math
import re
#MIPS assemblier
register_name = ['zero', 'at', 'v0', 'v1', 'a0', 'a1', 'a2', 'a3', 't0',
				 't1', 't2', 't3', 't4', 't5', 't6', 't7', 's0', 's1',
				 's2', 's3', 's4', 's5', 's6', 's7', 't8', 't9', 'k0',
				 'k1', 'gp', 'sp', 'fp', 'ra']
opcode = {
	'nop': '000000',
	'lw': '100011', 'sw': '101011', 'lui': '001111',
	'add': '000000', 'addu': '000000', 'sub': '000000', 'and': '000000', 'or': '000000', 'xor': '000000',
	'nor': '000000',
	'addi': '001000', 'addiu': '001001', 'andi': '001100',
	'sll': '000000', 'srl': '000000', 'sra': '000000',
	'slt': '000000', 'slti': '001010', 'sltiu': '001011',
	'beq': '000100', 'bne': '000101', 'blez': '000110', 'bgtz': '000111', 'bltz': '000001',
	'j': '000010', 'jal': '000011', 'jr': '000000', 'jalr': '000000'
}

funccode = {
	'nop': '000000',
	'add': '100000', 'addu': '100001', 'sub': '100010', 'and': '100100', 'or': '100101', 'xor': '100110',
	'nor': '100111',
	'sll': '000000', 'srl': '000010', 'sra': '000011',
	'slt': '101010', 'jr': '001000', 'jalr': '001001'
}
pre_inst = ['j main', 
			'j interrupt', 
			'j exception', 
			'interrupt:', 
			'	lui $at, 0x4000',
			'	addi $at, $at, 8',
			'	sw $t0, 4($sp) #store original t0',
			'	sw $t1, 8($sp) #store original t1',
			'	sw $t2, 12($sp) #store original t2',
			'	sw $ra, 16($sp) #store original ra',
			'	addi $t1, $zero, -7 #t1 = 0xFFFFFFF9',
			'	lw $t0, 0($at)',
			'	and $t0, $t0, $t1',
			'	sw $t0, 0($at) #TCON &= 0xFFFFFFF9',
			'	lui $at, 0x0000',
			'	addiu $at, $at, 0x400',
			'	lw $t0, -4($at) #$t0 = digitube_data',
			'DT_OP:',
			'	lui $at, 0x4000',
			'	addi $at, $at, 0x0014',
			'	addiu $t1, $zero, 15 #t1 = 0x0000000F',
			'	and $t1, $t1, $t0 #t1 = {28{0}, t0[3:0]}',
			'	jal DT_TAB',
			'	addi $t1,  $t1, 0x100 #digi_0',
			'	sw $t1, 0($at)',
			#digi_0
			'	addiu $t1, $zero, 240 #t1 = 0x000000F0',
			'	and $t1, $t1, $t0 #t1 = {24{0}, t0[7:4], 4{0}}',
			'	srl $t1, $t1, 4 #t1 = {28{0}, t0[7:4]}',
			'	jal DT_TAB',
			'	addi $t1, $t1, 0x200 #digi_1',
			'	sw $t1, 0($at)',
			#digi_1
			'	addiu $t1, $zero, 3840 #t1 = 0x00000F00',
			'	and $t1, $t1, $t0 #t1 = {20{0}, t0[11:8], 8{0}}',
			'	srl $t1, $t1, 8 #t1 = {28{0}, t0[11:8]}',
			'	jal DT_TAB',
			'	addi $t1, $t1, 0x400 #digi_2',
			'	sw $t1, 0($at)',
			#digi_2
			'	lui $t1, 0x000F',
			'	srl $t1, $t1, 4 #t1 = 0x0000F000',
			'	and $t1, $t1, $t0 #t1 = {16{0}, t0[15:12], 12{0}}',
			'	srl $t1, $t1, 12 #t1 = {28{0}, t0[15:12]}',
			'	jal DT_TAB',
			'	addi $t1, $t1, 0x800 #digi_3',
			'	sw $t1, 0($at)',
			#digi_3
			'	lui $at, 0x4000',
			'	addi $at, $at, 8',
			'	lw $t1, 0($at) #t1 = TCON',
			'	addi $t2, $zero, 2',
			'	or $t1, $t1, $t2 #t1 |= 0x00000002',
			'	sw $t1, 0($at)',
			'	lw $t0, 4($sp) #restore original t0',
			'	lw $t1, 8($sp) #restore original t1',
			'	lw $t2, 12($sp) #restore original t2',
			'	lw $ra, 16($sp) #restore original ra',
			'	jr $26',
			'DT_TAB:',
			'	beq $t1, $zero, DT_0',
			'	addi $t1, $t1, -1',
			'	beq $t1, $zero, DT_1',
			'	addi $t1, $t1, -1',
			'	beq $t1, $zero, DT_2',
			'	addi $t1, $t1, -1',
			'	beq $t1, $zero, DT_3',
			'	addi $t1, $t1, -1',
			'	beq $t1, $zero, DT_4',
			'	addi $t1, $t1, -1',
			'	beq $t1, $zero, DT_5',
			'	addi $t1, $t1, -1',
			'	beq $t1, $zero, DT_6',
			'	addi $t1, $t1, -1',
			'	beq $t1, $zero, DT_7',
			'	addi $t1, $t1, -1',
			'	beq $t1, $zero, DT_8',
			'	addi $t1, $t1, -1',
			'	beq $t1, $zero, DT_9',
			'	addi $t1, $t1, -1',
			'	beq $t1, $zero, DT_A',
			'	addi $t1, $t1, -1',
			'	beq $t1, $zero, DT_B',
			'	addi $t1, $t1, -1',
			'	beq $t1, $zero, DT_C',
			'	addi $t1, $t1, -1',
			'	beq $t1, $zero, DT_D',
			'	addi $t1, $t1, -1',
			'	beq $t1, $zero, DT_E',
			'	addi $t1, $t1, -1',
			'	beq $t1, $zero, DT_F',
			'DT_0:',
			'	addiu $t1, $zero, 0x40',
			'	jr $ra',
			'DT_1:',
			'	addiu $t1, $zero, 0x79',
			'	jr $ra',
			'DT_2:',
			'	addiu $t1, $zero, 0x24',
			'	jr $ra',
			'DT_3:',
			'	addiu $t1, $zero, 0x30',
			'	jr $ra',
			'DT_4:',
			'	addiu $t1, $zero, 0x19',
			'	jr $ra',
			'DT_5:',
			'	addiu $t1, $zero, 0x12',
			'	jr $ra',
			'DT_6:',
			'	addiu $t1, $zero, 0x02',
			'	jr $ra',
			'DT_7:',
			'	addiu $t1, $zero, 0x78',
			'	jr $ra',
			'DT_8:',
			'	addiu $t1, $zero, 0x00',
			'	jr $ra',
			'DT_9:',
			'	addiu $t1, $zero, 0x10',
			'	jr $ra',
			'DT_A:',
			'	addiu $t1, $zero, 0x08',
			'	jr $ra',
			'DT_B:',
			'	addiu $t1, $zero, 0x03',
			'	jr $ra',
			'DT_C:',
			'	addiu $t1, $zero, 0x46',
			'	jr $ra',
			'DT_D:',
			'	addiu $t1, $zero, 0x21',
			'	jr $ra',
			'DT_E:',
			'	addiu $t1, $zero, 0x06',
			'	jr $ra',
			'DT_F:',
			'	addiu $t1, $zero, 0x0E',
			'	jr $ra',
			'exception:', 
			'main:']
pre_rom = ['`timescale 1ns/1ps',
		'module ROM (addr,data);',
		'input [31:0] addr;',
		'output [31:0] data;',
		'reg [31:0] data;',
		'localparam ROM_SIZE = 32;',
		'reg [31:0] ROM_DATA[ROM_SIZE-1:0];',
		'always@(*)',
		'\tcase(addr[10:2])']
past_rom = ['\tendcase','endmodule']
pseudo = {
	'uart_r': 	['	addi $at, $zero, 2 #00010',
				'	sw $t0, 4($sp) # store original t0',
				'	lui $t0, 0x4000',
				'	addi $t0, $t0, 0x0020 #UART_CON',
				'	sw $at, 0($t0)',
				'UART_R:',
				'	lw $at, 0($t0) ',
				'	addi $at, $at, -10  # $at == 01010',
				'	bne $at, $zero, UART_R',
				'	lw $reg, -4($t0) #UART_RXD',
				'	addi $at, $zero, 0',
				'	sw $at, 0($t0)',
				'	lw $t0, 4($sp) # restore t0'],

	'uart_w':	['	sw $t0, 4($sp) #store original t0',
				'	lui $t0, 0x4000',
				'	addi $t0, $t0, 0x0020 #UART_CON',
				'UART_W:',
				'	lw $at, 0($t0)',
				'	bne $at, $zero, UART_W #00000',
				'	sw $reg, -8($t0)  #UART_TXD',
				'	addi $at, $zero, 1 #00001',
				'	sw $at, 0($t0)',
				'UART_WF:',
				'	lw $at, 0($t0)',
				'	addi $at, $at, -21 #10101',
				'	bne $at, $zero, UART_WF',
				'	sw $zero, 0($t0) #00000',
				'	lw $t0, 4($sp) #restore t0'],

	'led':		['	sw $t0, 4($sp) #store original t0',
				'	lui $t0, 0x4000',
				'	addi $t0, $t0, 0x0010 #load switch',
				'	lw $at, 0($t0)',
				'	lui $t0, 0x4000',
				'	addi $t0, $t0, 0x000C #LED addr',
				'	beq $at, $zero, LED_0 ',
				'	addi $at, $zero,  LED0-7 # if switch !=0, light up LEDs',
				'	sw $at, 0($t0)',
				'	j LED_END',
				'LED_0:',
				'	addi $at, $zero,  0 # if switch == 0, LED = 0 ',
				'	sw $at, 0($t0)',
				'LED_END:',
				'	lw $t0, 4($sp) # restore $t0'],

	'ledr':	['	sw $t0, 4($sp) #store original t0',
			'	lui $t0, 0x4000',
			'	addi $t0, $t0, 0x0010 #load switch',
			'	lw $at, 0($t0)',
			'	lui $t0, 0x4000',
			'	addi $t0, $t0, 0x000C #LED addr',
			'	beq $at, $zero, LEDR_0 ',
			'	sw $reg, 0($t0) # if switch !=0, light up LEDs',
			'	j LEDR_END',
			'LEDR_0:',
			'	sw $zero, 0($t0)  # if switch == 0, LED = 0 ',
			'LEDR_END:',
			'	lw $t0, 4($sp)'],

	'digi1': ['	lui $at, 0x4000',
			'	addi $at, $at, 8',
			'	sw $zero, 0($at) # TCON <= 0',
			'	sw $t0, 4($sp) #store original t0',
			'	sw $t1, 8($sp) #store original t1',
			'	lui $at, 0x0000 ',
			'	addiu $at, $at, 0x400',
			'	lui $t1, 0xFF00',
			'	srl $t1, $t1, 16 #t1 = 0x0000FF00',
			'	lw $t0, -4($at)',
			'	and $t0, $t0, $t1 #t0 = {16{0}, t0[15:8], 8{0}}',
			'	add $t0, $t0, $reg #t0 = {16{0},t0[15:8], reg[7:0]}',
			'	sw $t0, -4($at)',
			'	#open clock',
			'	lui $at, 0x4000',
			'	addi $at, $at, 8',
			'	addiu $t0, $zero, -10001 #t0 = 0xFFFFD8EF',
			'	sw $t0, -8($at) #TH <= 0xFFFFD8EF',
			'	sw $t0, -4($at) #TL <= 0xFFFFD8EF',
			'	addi $t0, $zero, 3',
			'	sw $t0, 0($at) #TCON <= 3',
			'	lw $t0, 4($sp) #restore $t0',
			'	lw $t1, 8($sp) #restore $t1'],

	'digi2': ['	lui $at, 0x4000',
			'	addi $at, $at, 8',
			'	sw $zero, 0($at) # TCON <= 0',
			'	sw $t0, 4($sp) #store original t0',
			'	sw $t1, 8($sp) #store original t1',
			'	lui $at, 0x0000 ',
			'	addiu $at, $at, 0x400',
			'	lui $t0, 0x00FF',
			'	srl $t0, $t0, 16 #t0 = 0x000000FF',
			'	lui $t1, 0xFFFF',
			'	add $t1, $t1, $t0 #t1 = FFFF00FF',
			'	lw $t0, -4($at)',
			'	sll $reg, $reg, 8',
			'	and $t0, $t1, $t0  #t0 = {24{0}, t0[7:0]}',
			'	add $t0, $t0, $reg #t0 = {16{0},reg[7:0], t0[7:0]}',
			'	srl $reg, $reg, 8 #restore $reg',
			'	sw $t0, -4($at)',
			'	#open clock',
			'	lui $at, 0x4000',
			'	addi $at, $at, 8',
			'	addi $t0, $zero, -10001 #t0 = 0xFFFFD8EF ',
			'	sw $t0, -8($at) #TH <= 0xFFFFD8EF',
			'	sw $t0, -4($at) #TL <= 0xFFFFD8EF',
			'	addi $t0, $zero, 3',
			'	sw $t0, 0($at) #TCON <= 3',
			'	lw $t0, 4($sp) #restore $t0',
			'	lw $t1, 8($sp) #restore $t1'],
}
def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        pass
def register_str2bin(reg_name):
	if is_number(reg_name):
		if int(reg_name) > 31:
			print('Error!' + reg_name + 'is not a valid register!')
			exit(-1)
		return bin(int(reg_name))[2:].zfill(5)
	else:
		return bin(register_name.index(reg_name))[2:].zfill(5)
def imm_str2bin(imm):
	imm = int(imm, 16) if imm.startswith('0x') else int(imm, 10)
	return bin(imm)[2:].zfill(16) if imm >= 0 else bin(2**16 - abs(imm))[2:].zfill(16)
def imm26_str2bin(imm):
	imm = int(imm, 16) if imm.startswith('0x') else int(imm, 10)
	return bin(imm)[2:].zfill(26) if imm >= 0 else bin(2**26 - abs(imm))[2:].zfill(26)
def shamt_str2bin(shamt):
	shamt = int(shamt)
	return bin(shamt)[2:].zfill(5) if shamt >=0 else bin(2**5 - abs(shamt))[2:].zfill(5)
def label_str2bin(label_set, inst, inst_addr, label):
	for x in label_set:
		if x[1] == label:
			label_addr = x[0]
			break
	if (inst[0] == 'b'):
		addr = str(label_addr - inst_addr - 1)
		return imm_str2bin(addr)
	elif (inst[0] == 'j'):
		addr = str(label_addr)
		return imm26_str2bin(addr)
def inst_str2bin(inst, inst_addr):
	#print(inst)
	try:
		#add,addu,sub,subu,and,or,xor,nor,slt
		m = re.match(r'([^#]*)[ ]+\$([^#]*)[ ]*,[ ]*\$([^#]*),[ ]*\$([^#]*)[ ]*[#]*', inst)
		if m:
			return opcode[m.group(1)] + register_str2bin(m.group(3)) + register_str2bin(m.group(4).strip()) + register_str2bin(m.group(2)) + '00000' + funccode[m.group(1)]
		#lw,sw
		m = re.match(r'([^#]*)[ ]+\$([^#]*)[ ]*,[ ]*([^#]*)\(\$([^#]*)\)[ ]*[#]*', inst)
		if m:
			#print(2)
			return opcode[m.group(1)] + register_str2bin(m.group(4).strip()) + register_str2bin(m.group(2)) + imm_str2bin(m.group(3))
		#sll,srl,sra
		m = re.match(r'(sll|srl|sra)[ ]*\$([^#]+)[ ]*,[ ]*\$([^#]+)[ ]*,[ ]*([^#]+)[ ]*[#]*', inst)
		if m:
			#print(3)
			return opcode[m.group(1)] + '00000' + register_str2bin(m.group(3)) + register_str2bin(m.group(2)) + shamt_str2bin(m.group(4).strip()) + funccode[m.group(1)]
		#beq,bne
		m = re.match(r'(beq|bne)[ ]+\$([^#]*)[ ]*,[ ]*\$([^#]*)[ ]*,[ ]*([^\$#]+)[ ]*[#]*', inst)
		if m:
			#print(4)
			return opcode[m.group(1)] + register_str2bin(m.group(2)) + register_str2bin(m.group(3)) + label_str2bin(label_set, inst, inst_addr, m.group(4).strip())
		#jal,j
		m = re.match(r'(jal|j)[ ]+([^#]+)[ ]*[#]*', inst) 
		if m:
			#print(5)
			return opcode[m.group(1)] + label_str2bin(label_set, inst, inst_addr, m.group(2).strip())
		#addi,addiu,andi,slti,sltiu
		m = re.match(r'([^#]*)[ ]+\$([^#]*)[ ]*,[ ]*\$([^#]*)[ ]*,[ ]*([^\$#]+)[ ]*[#]*', inst)
		if m:
			#print(6)
			#print(m.group(4))
			return opcode[m.group(1)] + register_str2bin(m.group(3)) + register_str2bin(m.group(2)) + imm_str2bin((m.group(4).strip()))
		#lui
		m = re.match(r'lui[ ]+\$([^#]*)[ ]*,[ ]*([^\$#]+)[ ]*[#]*', inst)
		if m: 
			#print(7)
			return opcode['lui'] + '00000' + register_str2bin(m.group(1)) + imm_str2bin(m.group(2).strip())
		#jalr
		m = re.match(r'jalr[ ]+\$([^#]+)[ ]*,[ ]*\$([^#]+)[ ]*[#]*', inst)
		if m: 
			#print(8)
			return opcode['jalr'] + register_str2bin(m.group(2).strip()) + '00000' + register_str2bin(m.group(1)) + '00000' + funccode['jalr']
		#blez,bgtz,bltz
		m = re.match(r'([^#]*)[ ]+\$([^#]*)[ ]*,[ ]*([^\$#]+)[ ]*[#]*', inst)
		if m: 
			#print(9)
			return opcode[m.group(1)] + register_str2bin(m.group(2)) + '00000' + label_str2bin(label_set, inst, inst_addr, m.group(3).strip())
		#jr
		m = re.match(r'(jr)[ ]+\$([^#]+)[ ]*[#]*', inst)
		if m:
			#print(10) 
			return opcode['jr'] + register_str2bin(m.group(2)) + '0' * 15 + funccode['jr']
		m = re.match(r'(nop)[ ]*[#]*', inst)
		if m:
			#print(11)
			return opcode['nop'] + '00000' + register_str2bin('zero') + register_str2bin('zero') + '00000' + '00000'
		print(inst, '\nInvalid systax!')
	except ValueError as e:
		print("Error in line:" + e.args[0].split()[0] + " is not a register name!")
		return None
	except KeyError as e:
		print("Error in line:" + e.args[0].split()[0] + " is not a instruction or the way using it is unproper")
		return None
	except Exception as e:
		print("Unknown Error!", e)
		return None
def preprocessing():
	uart_r_count = 0
	uart_w_count = 0
	led_count = 0
	ledr_count = 0
	with open('./inst.s', 'w+') as f:
		for line in pre_inst:
			if line[-1] == ':':
			   f.write(line + '\n')
			else:
				f.write('\t' + line + '\n')
		for line in open('./data.txt'):
			if (line.strip() != '' and line.strip()[0] != '#'):
				m = re.match(r'(uart_r)[ ]*\$([^#]*)[ ]*[#]*', line.strip())
				if m:
					for inst in pseudo['led']:
						if inst == '	beq $at, $zero, LED_0 ':
							f.write('\tbeq $at, $zero, LED_0' + str(led_count) + '\n')
							continue
						if inst == '	addi $at, $zero,  LED0-7 # if switch !=0, light up LEDs':
							f.write('	addi $at, $zero,  1 # if switch !=0, light up LEDs' + '\n')
							continue
						if inst == '	j LED_END':
							f.write('	j LED_END' + str(led_count) + '\n')
							continue
						if inst == 'LED_0:':
							f.write('LED_0' + str(led_count) + ':\n')
							continue
						if inst == 'LED_END:':
							f.write('LED_END' + str(led_count) + ':\n')
							continue
						f.write(inst + '\n')
					led_count += 1
					for inst in pseudo['uart_r']:
						if inst == 'UART_R:':
							f.write('UART_R' + str(uart_r_count) + ':\n')
							continue
						if inst == '	bne $at, $zero, UART_R':
							f.write('	bne $at, $zero, UART_R' + str(uart_r_count) + '\n')
							continue
						if inst == '	lw $reg, -4($t0) #UART_RXD':
							#print(m.group(2))
							f.write('\tlw $' + m.group(2) + ', -4($t0) #UART_RXD' + '\n')
							continue
						f.write(inst + '\n')
					uart_r_count += 1
					for inst in pseudo['led']:
						if inst == '	beq $at, $zero, LED_0 ':
							f.write('\tbeq $at, $zero, LED_0' + str(led_count) + '\n')
							continue
						if inst == '	addi $at, $zero,  LED0-7 # if switch !=0, light up LEDs':
							f.write('	addi $at, $zero,  0 # if switch !=0, light up LEDs' + '\n')
							continue
						if inst == '	j LED_END':
							f.write('	j LED_END' + str(led_count) + '\n')
							continue
						if inst == 'LED_0:':
							f.write('LED_0' + str(led_count) + ':\n')
							continue
						if inst == 'LED_END:':
							f.write('LED_END' + str(led_count) + ':\n')
							continue
						f.write(inst + '\n')		
					led_count += 1
					continue
				m = re.match(r'(uart_w)[ ]*\$([^#]*)[ ]*[#]*', line.strip())
				if m:
					for inst in pseudo['led']:
						if inst == '	beq $at, $zero, LED_0 ':
							f.write('\tbeq $at, $zero, LED_0' + str(led_count) + '\n')
							continue
						if inst == '	addi $at, $zero,  LED0-7 # if switch !=0, light up LEDs':
							f.write('	addi $at, $zero,  2 # if switch !=0, light up LEDs' + '\n')
							continue
						if inst == '	j LED_END':
							f.write('	j LED_END' + str(led_count) + '\n')
							continue
						if inst == 'LED_0:':
							f.write('LED_0' + str(led_count) + ':\n')
							continue
						if inst == 'LED_END:':
							f.write('LED_END' + str(led_count) + ':\n')
							continue
						f.write(inst + '\n')
					led_count += 1
					for inst in pseudo['uart_w']:
						if inst == 'UART_W:':
							f.write('UART_W' + str(uart_w_count) + ':\n')
							continue
						if inst == '	bne $at, $zero, UART_W #00000':
							f.write('	bne $at, $zero, UART_W' + str(uart_w_count) + ' #00000\n')
							continue
						if inst == 'UART_WF:':
							f.write('UART_WF' + str(uart_w_count) + ':\n')
							continue
						if inst == '	bne $at, $zero, UART_WF':
							f.write('	bne $at, $zero, UART_WF' + str(uart_w_count) + '\n')
							continue
						if inst == '	sw $reg, -8($t0)  #UART_TXD':
							f.write('\tsw $' + m.group(2) + ', -8($t0) #UART_TXD' + '\n')
							continue
						f.write(inst + '\n')
					uart_w_count += 1
					for inst in pseudo['led']:
						if inst == '	beq $at, $zero, LED_0 ':
							f.write('\tbeq $at, $zero, LED_0' + str(led_count) + '\n')
							continue
						if inst == '	addi $at, $zero,  LED0-7 # if switch !=0, light up LEDs':
							f.write('	addi $at, $zero,  0 # if switch !=0, light up LEDs' + '\n')
							continue
						if inst == '	j LED_END':
							f.write('	j LED_END' + str(led_count) + '\n')
							continue
						if inst == 'LED_0:':
							f.write('LED_0' + str(led_count) + ':\n')
							continue
						if inst == 'LED_END:':
							f.write('LED_END' + str(led_count) + ':\n')
							continue
						f.write(inst + '\n')
					led_count += 1
					continue
				m = re.match(r'(ledr)[ ]*\$([^#]*)[ ]*[#]*', line)
				if m:
					for inst in pseudo['ledr']:
						if inst == '	beq $at, $zero, LEDR_0 ':
							f.write('	beq $at, $zero, LEDR_0' + str(ledr_count) + '\n')
							continue
						if inst == '	sw $reg, 0($t0) # if switch !=0, light up LEDs':
							f.write('	sw $' + m.group(2) + ', 0($t0) # if switch !=0, light up LEDs' + '\n')
							continue
						if inst == '	j LEDR_END':
							f.write('	j LEDR_END' + str(ledr_count) + '\n')
							continue
						if inst == 'LEDR_0:':
							f.write('LEDR_0' + str(ledr_count) + ':\n')
							continue
						if inst == 'LEDR_END:':
							f.write('LEDR_END' + str(ledr_count) + ':\n')
							continue
						f.write(inst + '\n')
					ledr_count += 1
					continue
				m = re.match(r'(led)[ ]*([^#]*)[ ]*[#]*', line)
				if m:
					for inst in pseudo['led']:
						if inst == '	beq $at, $zero, LED_0 ':
							f.write('\tbeq $at, $zero, LED_0' + str(led_count) + '\n')
							continue
						if inst == '	addi $at, $zero,  LED0-7 # if switch !=0, light up LEDs':
							f.write('	addi $at, $zero,  ' + str(int(m.group(2), 2)) + ' # if switch !=0, light up LEDs' + '\n')
							continue
						if inst == '	j LED_END':
							f.write('	j LED_END' + str(led_count) + '\n')
							continue
						if inst == 'LED_0:':
							f.write('LED_0' + str(led_count) + ':\n')
							continue
						if inst == 'LED_END:':
							f.write('LED_END' + str(led_count) + ':\n')
							continue
						f.write(inst + '\n')
					led_count += 1
					continue
				m = re.match(r'(digi1)[ ]*\$([^#]*)[ ]*[#]*', line)
				if m:
					for inst in pseudo['digi1']:
						if inst == '	add $t0, $t0, $reg #t0 = {16{0},t0[15:8], reg[7:0]}':
							f.write('	add $t0, $t0, $' + m.group(2).strip() + ' #t0 = {16{0},t0[15:8], reg[7:0]}' + '\n')
							continue
						f.write(inst + '\n')
					continue
				m = re.match(r'(digi2)[ ]*\$([^#]*)[ ]*[#]*', line)
				if m:
					for inst in pseudo['digi2']:
						if inst == '	add $t0, $t0, $reg #t0 = {16{0},reg[7:0], t0[7:0]}':
							f.write('	add $t0, $t0, $' + m.group(2).strip() + ' #t0 = {16{0},reg[7:0], t0[7:0]}' + '\n')
							continue
						if inst == '	sll $reg, $reg, 8':
							f.write('	sll $' + m.group(2).strip() + ', $' + m.group(2).strip() + ', 8' + '\n')
							continue
						if inst == '	srl $reg, $reg, 8 #restore $reg':
							f.write('	srl $' + m.group(2).strip() + ', $' + m.group(2).strip() + ', 8 #restore $reg' + '\n')
							continue
						f.write(inst + '\n')
					continue
				m = re.match(r'[\s]*([^#]*):[\s]*[\n]', line)
				if m:
					f.write(m.group(1) + ':' + '\n')
					continue
			   # if (line.strip()[-1] == ':'):
			   #     label_set.append((len(instruction_set), line.strip()[:-1]))
				m = re.match(r'[\s]*([^#]*):[\s]*([^#]+)[ ]*[#]*[.]*', line.strip())
				if m:
					f.write(m.group(1) + ':' + '\n')
					f.write('\t' + m.group(2) + '\n')
					continue
				m = re.match(r'[\s]*([^#]+)[ ]*[#]*', line.strip())
				if m:
					f.write('\t' + m.group(1) + '\n')
					continue
				print(line)
				print('error! Invalid systax.')
				exit(-1)	 
if __name__ == '__main__':
	instruction_set = []
	label_set = []
	instruction_bin = []
	preprocessing()
	with open('./inst.s', 'r') as f:
		for line in f:
			if (line.strip() != '' and line.strip()[0] != '#'):
				if (line.strip()[-1] == ':'):
					label_set.append((len(instruction_set), line.strip()[:-1]))
					continue
				else:
					instruction_set.append(line.strip())
					continue
				print('error! Invalid systax.')
   # for x in instruction_set: print(x)
   # for x in label_set: print(x)
	for i in range(len(instruction_set)):
		#print(instruction_set[i])
	   # print(hex(int(inst_str2bin(instruction_set[i], i),2))[2:].zfill(8))
		instruction_bin.append(hex(int(inst_str2bin(instruction_set[i], i),2))[2:].zfill(8))
	with open('rom.v', 'w+') as f:
		for line in pre_rom:
			f.write(line + '\n')
		for i in range(len(instruction_bin)):
			f.write('\t\t' + str(i)+ ': data <= 32\'h'+instruction_bin[i]+';' + '\n')
		for line in past_rom:
			f.write(line + '\n')