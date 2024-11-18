from rich.console import Console

def print_data_continuo(data_received, registers_to_show, mem_data_to_show):
    if data_received:
        console = Console()
        data = []
        for i in range(0, len(data_received), 4):
            data.append(data_received[i:i+4])  #Armo bloques de 4 elementos (4 bytes)

        #el primer bloque de DATA para PC en binario
        pc = []
        for byte in data[0]:
            pc.append(format(byte, '08b'))
        pc = ' '.join(pc)

        #segundo bloque en clk
        clk_count = []
        for byte in data[1]:
            clk_count.append(format(byte, '08b'))
        clk_count = ' '.join(clk_count)

        #Inicializar 'registers_value'
        registers_value = []
        for i in range(0, registers_to_show):
            registers_value.append(' '.join([format(byte, '08b') for byte in data[i+2]]))

        memory = []
        for i in range(0, mem_data_to_show):
            memory.append(' '.join([format(byte, '08b') for byte in data[i+34]]))              

        #Print the extracted information
        print(
            f"\nClockCycles: {clk_count} = {int(clk_count.replace(' ',''), 2)}")
        print(f"\nPC: {pc} = {int(pc.replace(' ',''), 2)}")
        if (registers_to_show > 0):
            console.print("REGISTER FILE",style="bold red")
            for i in range(registers_to_show):
                print(f"{i}:  {registers_value[i]} = {int(registers_value[i].replace(' ',''), 2)}")                  
        if (mem_data_to_show > 0):
            console.print("DATA MEMORY",style="bold red")
            for i in range(mem_data_to_show):
                print(f"{i}:  {memory[i]} = {int(memory[i].replace(' ',''), 2)}")

#Cuando es por pasos
def print_data_step(data_received, prev_data_received, registers_to_show, mem_data_to_show):
    if data_received:
        console = Console()
        #Dividir 'data_received' en bloques de 4 elementos (4 bytes)
        data = []
        for i in range(0, len(data_received), 4):
            data.append(data_received[i:i+4])

        #Datos del step anterior
        if prev_data_received != 0:
            prev_data = []
            for i in range(0, len(prev_data_received), 4):
                prev_data.append(prev_data_received[i:i+4])
        else:
            prev_data = 0

        #el primer bloque de 'data' para PC en binario
        pc = []
        for byte in data[0]:
            pc.append(format(byte, '08b'))
        pc = ' '.join(pc)
        #segundo bloque de 'data' (clk_count)
        clk_count = []
        for byte in data[1]:
            clk_count.append(format(byte, '08b'))
        clk_count = ' '.join(clk_count)

        #primer bloque de 'prev_data' (pc_prev)
        pc_prev = 0
        if prev_data != 0:
            pc_prev = []
            for byte in prev_data[0]:
                pc_prev.append(format(byte, '08b'))
            pc_prev = ' '.join(pc_prev)


        #Inicializar 'registers_value' como una lista vacía
        registers_value = []
        prev_registers_value = []
        for i in range(0, 32):
            registers_value.append(' '.join([format(byte, '08b') for byte in data[i+2]]))
            if(prev_data != 0):
                prev_registers_value.append(' '.join([format(byte, '08b') for byte in prev_data[i+2]]))

        memory = []
        prev_memory = []
        for i in range(0, 16):
            memory.append(' '.join([format(byte, '08b') for byte in data[i+34]]))
            if(prev_data != 0):   
                prev_memory.append(' '.join([format(byte, '08b') for byte in prev_data[i+34]]))                

        print(f"\nClockCycles: {clk_count} = {int(clk_count.replace(' ',''), 2)}")

        if(prev_data != 0):
            if( pc == pc_prev):
                console.print("PC",style="white")
                console.print(f"{pc} = {int(pc.replace(' ',''), 2)}", style="bold underline red on red")  #Fondo rojo para burbuja
            elif(int(pc.replace(' ',''), 2) != int(pc_prev.replace(' ',''), 2)+4):
                console.print(f"{pc} = {int(pc.replace(' ',''), 2)}",style="bold underline red on green") #si hago un salto, cambio de pc, fondo verde
            else:
                print(f"\nPC: \n{pc} = {int(pc.replace(' ',''), 2)}")
        else:
            print(f"\nPC: \n{pc} = {int(pc.replace(' ',''), 2)}")

        if (registers_to_show > 0):
            console.print("REGISTER FILE",style="bold red")
            for i in range(registers_to_show):
                if(prev_data != 0):                    
                    if(registers_value[i] == prev_registers_value[i] ):
                        print(f"r{i}:  {registers_value[i]} = {int(registers_value[i].replace(' ',''), 2)}") #si no cambia no lo pinto de otro color
                    else:
                        console.print(f"r{i}: {registers_value[i]} = {int(registers_value[i].replace(' ',''), 2)}",style="bold yellow") #cuando cambia un registro cambio en amarillo
                else:
                    print(f"r{i}:  {registers_value[i]} = {int(registers_value[i].replace(' ',''), 2)}")                   

        if (mem_data_to_show > 0):
            console.print("DATA MEMORY",style="bold red")
            for i in range(mem_data_to_show):
                if(prev_data != 0): 
                    if(memory[i] == prev_memory[i] or prev_data == 0):
                        print(f"r{i}:  {memory[i]} = {int(memory[i].replace(' ',''), 2)}")
                    else:
                        console.print(f"r{i}: {memory[i]} = {int(memory[i].replace(' ',''), 2)}",style="bold yellow") #cuando cambia un registro en la memoria cambio en amarillo
                else:
                    print(f"r{i}:  {memory[i]} = {int(memory[i].replace(' ',''), 2)}")                  
