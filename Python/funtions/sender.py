import time
from rich.progress import track

REGISTERS = {
    'r0': '00000',
    'r1': '00001',
    'r2': '00010',
    'r3': '00011',
    'r4': '00100',
    'r5': '00101',
    'r6': '00110',
    'r7': '00111',
    'r8': '01000',
    'r9': '01001',
    'r10': '01010',
    'r11': '01011',
    'r12': '01100',
    'r13': '01101',
    'r14': '01110',
    'r15': '01111',
    'r16': '10000',
    'r17': '10001',
    'r18': '10010',
    'r19': '10011',
    'r20': '10100',
    'r21': '10101',
    'r22': '10110',
    'r23': '10111',
    'r24': '11000',
    'r25': '11001',
    'r26': '11010',
    'r27': '11011',
    'r28': '11100',
    'r29': '11101',
    'r30': '11110',
    'r31': '11111'
}

RISC_DICTIONARY = {
    'add':  ['r', '100000', 'null'],
    'addi': ['i', '001000', 'null'],
    'addu': ['r', '100001', 'null'],
    'sub':  ['r', '100010', 'null'],
    'subu': ['r', '100011', 'null'],
    'nor':  ['r', '100111', 'null'],
    'or':   ['r', '100101', 'null'],
    'ori':  ['i', '001101', 'null'],
    'and':  ['r', '100100', 'null'],
    'andi': ['i', '001100', 'null'],
    'beq':  ['i', '000100', 'branch'],
    'bne':  ['i', '000101', 'branch'],
    'j':    ['i', '000010', 'jump'],
    'jal':  ['i', '000011', 'jump'],
    'jalr': ['j', '001001', 'null'],
    'jr':   ['j', '001000', 'null'],
    'lb':   ['i', '100000', 'offset'],
    'lbu':  ['i', '100100', 'offset'],
    'lh':   ['i', '100001', 'offset'],
    'lhu':  ['i', '100101', 'offset'],
    'lui':  ['i', '001111', 'lui'],
    'lw':   ['i', '100011', 'offset'],
    'lwu':  ['i', '100111', 'offset'],
    'sb':   ['i', '101000', 'offset'],
    'sh':   ['i', '101001', 'offset'],
    'sll':  ['r', '000000', 'shift'],
    'sllv': ['r', '000100', 'shiftv'],
    'slt':  ['r', '101010', 'null'],
    'slti': ['i', '001010', 'null'],
    'sra':  ['r', '000011', 'shift'],
    'srav': ['r', '000111', 'shiftv'],
    'srl':  ['r', '000010', 'shift'],
    'srlv': ['r', '000110', 'shiftv'],
    'sw':   ['i', '101011', 'offset'],
    'xor':  ['r', '100110', 'null'],
    'xori': ['i', '001110', 'null']
}

def send(file_bin, serial):

    #La r (RUN) se envia para indicar el estado a la unit debug para cargar
    serial.write('r'.encode())

    time.sleep(0.1)
    with open(file_bin, 'rb') as file:
        data = file.read().replace(b'\r\n', b'')
        num_byte = []
        for i in track(range(int(len(data)/8)), description="ENVIANDO..."):
            num = int(data[i*8:(i+1)*8], 2).to_bytes(1, byteorder='big')
            serial.write(num)
            time.sleep(0.05)


# Las intrucciones se crearan a partir de las siguientes funciones:
#   -type_R
#   -type_I
#   -type_J

# Se recibe como @param 
#   -instruction=  PART[0] 
#   -args=  PART[1] 

def type_I(instruction, args):
    opcode = RISC_DICTIONARY[instruction][1]
    syntax = RISC_DICTIONARY[instruction][2]   

    if (syntax == 'offset'):
        rt, iargs = map(str.strip, args.split(','))
        #obtengo el entero entre ()
        offset, reg_base = iargs.strip(')').split('(')
        base = REGISTERS[reg_base]
        rt = REGISTERS[rt]
        boffset = bin(int(offset) & 0b1111111111111111)[2:].zfill(16) #Se arma el binario y se elimina el '0b', me aseguro de llenar con 0 la izq
        instruction_bin = f"{opcode}{base}{rt}{boffset}"  

    elif (syntax == 'branch'):
        rs, rt, offset = map(str.strip, args.split(','))
        rs = REGISTERS[rs]
        rt = REGISTERS[rt]
        boffset = bin(int(offset) & 0b1111111111111111)[2:].zfill(16)
        instruction_bin = f"{opcode}{rs}{rt}{boffset}"  

    elif (syntax == 'jump'):
        btarget = bin(int(args) & 0b11111111111111111111111111)[2:].zfill(26) #convierte al numero entero a bin y lo multiplico con 1 para luego garantizar 26 bits
        instruction_bin = f"{opcode}{btarget}" #sumos los 6 de opcode

    elif (syntax == 'lui'):
        rt, immediate = map(str.strip, args.split(','))
        rt = REGISTERS[rt]
        immediate = bin(int(immediate) & 0b1111111111111111)[2:].zfill(16)
        instruction_bin = f"{opcode}00000{rt}{immediate}"
        
    else:
        rt, rs, immediate = map(str.strip, args.split(','))
        rt = REGISTERS[rt]
        rs = REGISTERS[rs]
        immediate = bin(int(immediate) & 0b1111111111111111)[2:].zfill(16)
        instruction_bin = f"{opcode}{rs}{rt}{immediate}"
    return instruction_bin


def type_R(instruction, args):   
    funct = RISC_DICTIONARY[instruction][1]
    syntax = RISC_DICTIONARY[instruction][2]

    if (syntax == 'shiftv'):
        rd, rt, rs = map(str.strip, args.split(','))
        rs = REGISTERS[rs]
        rt = REGISTERS[rt]
        rd = REGISTERS[rd]
        instruction_bin = f"000000{rs}{rt}{rd}00000{funct}"
    elif (syntax == 'shift'):
        rd, rt, shift = map(str.strip, args.split(','))
        rt = REGISTERS[rt]
        rd = REGISTERS[rd]
        shift = bin(int(shift) & 0b11111)[2:].zfill(5)
        instruction_bin = f"00000000000{rt}{rd}{shift}{funct}"
    else:
        rd, rs, rt = map(str.strip, args.split(','))  
        rs = REGISTERS[rs]
        rt = REGISTERS[rt]
        rd = REGISTERS[rd]
        instruction_bin = f"000000{rs}{rt}{rd}00000{funct}"
    return instruction_bin


def type_J(instruction, args):
    funct = RISC_DICTIONARY[instruction][1]

    if funct == RISC_DICTIONARY['jalr'][1]:
        rs = REGISTERS[args]
        instruction_bin = f"000000{rs}000001111100000{funct}"
    else:
        rs = REGISTERS[args]
        instruction_bin = f"000000{rs}000000000000000{funct}"
    return instruction_bin

def create_bin(file_asm, file_bin):
    with open(file_asm, 'r') as f:
        with open(file_bin, 'w') as out:
            for line in f:
                #Haremos lectura de cada linea separando las partes de las intruccion de la siguiente manera
                #add r0,r1,r2
                #PART[0] PART[1] (operacion y argumentos)
                parts = line.strip().split(' ')
                instruction_BIN = 0
                if parts:
                    if (parts[0] == 'nop'):
                        instruction_BIN = f"00000000000000000000000000000000"
                        out.write( instruction_BIN + '\n' )
                    elif (parts[0] == 'halt'):
                        out.write(f"11111111111111111111111111111111")                       
                    else:
                        instruction_type = RISC_DICTIONARY[parts[0]][0]
                        if (instruction_type == 'r'):
                            instruction_BIN = type_R(parts[0], parts[1])
                        elif (instruction_type == 'i'):
                            instruction_BIN = type_I(parts[0], parts[1])
                        elif (instruction_type == 'j'):
                            instruction_BIN = type_J(parts[0], parts[1])
                        else:
                            print("FAIL: El tipo de instruccion no pertenece al set disponible")
                            sys.exit(1)
                        out.write( instruction_BIN + '\n')
            
            out.write(f"11111111111111111111111111111111")  #Halt last instruction
    

