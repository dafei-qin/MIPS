


def MachineCodeTranslate(assemblecode):
    print(assemblecode)
    try:
        a = re.match(r'(.*)[ ]+\$(.*)[ ]*,[ ]*\$(.*),[ ]*\$(.*)', assemblecode)   #
        if a: return opcode[a.group(1)] + register_translated(a.group(3)) + register_translated(
            a.group(4)) + register_translated(a.group(2)) + '00000' + funccode[a.group(1)]
        a = re.match(r'(.*)[ ]+\$(.*)[ ]*,[ ]*(.*)\(\$(.*)\)', assemblecode)
        if a: return opcode[a.group(1)] + register_translated(a.group(4)) + register_translated(
            a.group(2)) + imme_translated((lambda x: int(x, 16) if x.startswith('0x') else int(x, 10))(a.group(3)))
        a = re.match(r'(sll|srl|sra)[ ]*\$(.+)[ ]*,[ ]*\$(.+)[ ]*,[ ]*(.+)', assemblecode)
        if a: return opcode[a.group(1)] + '0' * 5 + register_translated(a.group(3)) + register_translated(
            a.group(2)) + sha_translate(int(a.group(4))) + funccode[a.group(1)]
        a = re.match(r'(beq|bne)[ ]+\$(.*)[ ]*,[ ]*\$(.*)[ ]*,[ ]*([^\$]+)', assemblecode)
        if a: return opcode[a.group(1)] + register_translated(a.group(2)) + register_translated(
             a.group(3)) + imme_translated((lambda x: int(x, 16) if x.startswith('0x') else int(x, 10))(a.group(4)))
        a = re.match(r'(.*)[ ]+\$(.*)[ ]*,[ ]*\$(.*)[ ]*,[ ]*([^\$]+)', assemblecode)
        if a: return opcode[a.group(1)] + register_translated(a.group(3)) + register_translated(
            a.group(2)) + imme_translated((lambda x: int(x, 16) if x.startswith('0x') else int(x, 10))(a.group(4)))
        a = re.match(r'lui[ ]+\$(.*)[ ]*,[ ]*([^\$]+)', assemblecode)
        if a: return opcode['lui'] + '0' * 5 + register_translated(a.group(1)) + imme_translated(
            (lambda x: int(x, 16) if x.startswith('0x') else int(x, 10))(a.group(2)))
        a = re.match(r'(.*)[ ]+\$(.*)[ ]*,[ ]*([^\$]+)', assemblecode)
        if a: return opcode[a.group(1)] + register_translated(a.group(2)) + '0' * 5 + imme_translated(
            (lambda x: int(x, 16) if x.startswith('0x') else int(x, 10))(a.group(3)))
        a = re.match(r'(jal|j)[ ]+(.+)', assemblecode)
        if a: return opcode[a.group(1)] + imme_translated_26(
            (lambda x: int(x, 16) if x.startswith('0x') else int(x, 10))(a.group(2)))
        a = re.match(r'(jr)[ ]+\$(.+)', assemblecode)
        if a: return opcode['jr'] + register_translated(a.group(2)) + '0' * 15 + funccode['jr']
        a = re.match(r'jalr[ ]+\$(.+)[ ]*,[ ]*\$(.+)', assemblecode)
        if a: return opcode['jalr'] + register_translated(a.group(1)) + '0' * 5 + register_translated(
            a.group(2)) + '0' * 5 + funccode['jalr']
    except ValueError as e:
        print("Error in line:" + e.args[0].split()[0] + "is not a register name!")
        return None
    except KeyError as e:
        print("Error in line:" + e.args[0].split()[0] + " is not a instruction or the way using it is unproper")
        return None
    except Exception as e:
        print("Unknown Error!", e)
        return None


register_translated = lambda register: (bin(register_name.index(register))[2:]).zfill(5)    #对应寄存器
imme_translated = lambda imme: (bin(imme)[2:]).zfill(16)  if imme>=0 else bin(2**16-abs(imme))[2:]
imme_translated_26 = lambda imme: (bin(imme)[2:]).zfill(26)  if imme>=0 else bin(2**26-abs(imme))[2:]
sha_translate = lambda num: (bin(num)[2:]).zfill(5)  if num>=0 else bin(2**26-abs(num))[2:]

instruction_set = []
for line in open("./data.txt"):
    if (line.strip() != ''):
        instruction_set.append(line.strip())

pos_dict = {}
pos = 0

for (m, instruction) in enumerate(instruction_set):
    a = re.match(r'^(.+):(.*)$', instruction)   #标号
    if a:
        if a.group(1) in pos_dict.keys():
            print("Error! ReDefine the name of a block")
        else:
            pos_dict[a.group(1)] = pos
            instruction_set[m] = re.sub(r'.+:', '', instruction_set[m])
        if a.group(2) == '':
            continue
    pos += 1

instruction_set = [instruction for instruction in instruction_set if instruction]

for (m, instruction) in enumerate(instruction_set):
    try:
        instruction_set[m] = re.sub(r'((?:beq|bne)[ ]*\$.+,[ ]*\$.+,[ ]*)(.+)', lambda matched: matched.group(1) + str(
            pos_dict[matched.group(2)] - m - 1) if not re.match(r'-?(0x[0-9a-e]+|[0-9]+)',
                                                                matched.group(2)) else matched.group(1) + matched.group(
            2), instruction)
        instruction_set[m] = re.sub(r'((?:jal[ ]|j[ ])[ ]*)(.+)',
                                    lambda matched: matched.group(1) + str(pos_dict[matched.group(2)]) if not re.match(
                                        r'-?(0x[0-9a-e]+|[0-9]+)', matched.group(2)) else matched.group(
                                        1) + matched.group(2), instruction_set[m])
        instruction_set[m] = re.sub(r'((?:blez|bgtz|bltz)[ ]+\$.+,[ ]*)(.+)', lambda matched: matched.group(1) + str(
            pos_dict[matched.group(2)] - m - 1) if not re.match(r'-?(0x[0-9a-e]+|[0-9]+)',
                                                                matched.group(2)) else matched.group(1) + matched.group(
            2), instruction_set[m])
    except Exception as e:
        print('Error!', e)


machine_instruction_set = [MachineCodeTranslate(instruction) for instruction in instruction_set]
machine_instruction_set = [instruction for instruction in machine_instruction_set if instruction]
verilogline=[]
machine_instruction_set = [ '32\'h'+(hex(int(instruction,2))[2:]).zfill(8) for instruction in machine_instruction_set]
for (m , instruction) in enumerate(machine_instruction_set):
    verilogline.append('8\'d'+ str(m) +': Instruction <= '+instruction)
with open("m_code.txt", 'w') as f:
    for instruction in verilogline:
        f.write(instruction)
        f.write('\n')
for instruction in verilogline:
    print(instruction)