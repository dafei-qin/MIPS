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
pre_inst = ['j main', 'j interrupt', 'j exception', 'interrupt:', 'exception:', 'main:']
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
def register_str2bin(reg_name):
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
        m = re.match(r'(.*)[ ]+\$(.*)[ ]*,[ ]*\$(.*),[ ]*\$(.*)', inst)
        if m:
            #print(1)
            return opcode[m.group(1)] + register_str2bin(m.group(3)) + register_str2bin(m.group(4)) + register_str2bin(m.group(2)) + '00000' + funccode[m.group(1)]
        #lw,sw
        m = re.match(r'(.*)[ ]+\$(.*)[ ]*,[ ]*(.*)\(\$(.*)\)', inst)
        if m:
            #print(2)
            return opcode[m.group(1)] + register_str2bin(m.group(4)) + register_str2bin(m.group(2)) + imm_str2bin(m.group(3))
        #sll,srl,sra
        m = re.match(r'(sll|srl|sra)[ ]*\$(.+)[ ]*,[ ]*\$(.+)[ ]*,[ ]*(.+)', inst)
        if m:
            #print(3)
            return opcode[m.group(1)] + '00000' + register_str2bin(m.group(3)) + register_str2bin(m.group(2)) + shamt_str2bin(m.group(4)) + funccode[m.group(1)]
        #beq,bne
        m = re.match(r'(beq|bne)[ ]+\$(.*)[ ]*,[ ]*\$(.*)[ ]*,[ ]*([^\$]+)', inst)
        if m:
            #print(4)
            return opcode[m.group(1)] + register_str2bin(m.group(2)) + register_str2bin(m.group(3)) + label_str2bin(label_set, inst, inst_addr, m.group(4))
        #jal,j
        m = re.match(r'(jal|j)[ ]+(.+)', inst) 
        if m:
            #print(5)
            return opcode[m.group(1)] + label_str2bin(label_set, inst, inst_addr, m.group(2))
        #addi,addiu,andi,slti,sltiu
        m = re.match(r'(.*)[ ]+\$(.*)[ ]*,[ ]*\$(.*)[ ]*,[ ]*([^\$]+)', inst)
        if m:
            #print(6)
            return opcode[m.group(1)] + register_str2bin(m.group(3)) + register_str2bin(m.group(2)) + imm_str2bin((m.group(4)))
        #lui
        m = re.match(r'lui[ ]+\$(.*)[ ]*,[ ]*([^\$]+)', inst)
        if m: 
            #print(7)
            return opcode['lui'] + '00000' + register_str2bin(m.group(1)) + imm_str2bin(m.group(2))
        #jalr
        m = re.match(r'jalr[ ]+\$(.+)[ ]*,[ ]*\$(.+)', inst)
        if m: 
            #print(8)
            return opcode['jalr'] + register_str2bin(m.group(2)) + '00000' + register_str2bin(m.group(1)) + '00000' + funccode['jalr']
        #blez,bgtz,bltz
        m = re.match(r'(.*)[ ]+\$(.*)[ ]*,[ ]*([^\$]+)', inst)
        if m: 
            #print(9)
            return opcode[m.group(1)] + register_str2bin(m.group(2)) + '00000' + label_str2bin(label_set, inst, inst_addr, m.group(3))
        #jr
        m = re.match(r'(jr)[ ]+\$(.+)', inst)
        if m:
            #print(10) 
            return opcode['jr'] + register_str2bin(m.group(2)) + '0' * 15 + funccode['jr']
        m = re.match(r'(nop)', inst)
        if m:
            #print(11)
            return opcode['nop'] + '00000' + register_str2bin('zero') + register_str2bin('zero') + '00000' + '00000'
        print(inst, '\nInvalid systax!')
    except ValueError as e:
        print("Error in line:" + e.args[0].split()[0] + "is not a register name!")
        return None
    except KeyError as e:
        print("Error in line:" + e.args[0].split()[0] + " is not a instruction or the way using it is unproper")
        return None
    except Exception as e:
        print("Unknown Error!", e)
        return None

if __name__ == '__main__':
    instruction_set = []
    label_set = []
    instruction_bin = []
    with open('./inst.s', 'w+') as f:
        for line in pre_inst:
            if line[-1] == ':':
               f.write(line + '\n')
            else:
                f.write('\t' + line + '\n')
        for line in open("./data.txt"):
            f.write(line)
    with open('./inst.s', 'r') as f:
        for line in f:
            if (line.strip() != '' and line.strip()[0] != '#'):
                m = re.match(r'[\s]*(.*):[\s]*[\n]', line)
                if m:
                    label_set.append((len(instruction_set), m.group(1)))
                    continue
               # if (line.strip()[-1] == ':'):
               #     label_set.append((len(instruction_set), line.strip()[:-1]))
                m = re.match(r'[\s]*(.*):[\s]*([^#]+)[ ]*[#]*[.]*', line.strip())
                if m:
                    label_set.append((len(instruction_set), m.group(1)))
                    instruction_set.append(m.group(2))
                    continue
                m = re.match(r'[\s]*([^#]+)[ ]*[#]*', line.strip())
                if m:
                    instruction_set.append(m.group(1))
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