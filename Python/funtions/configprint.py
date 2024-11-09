from rich.console import Console

#Se lo llama cuando es continuo porque en este caso no puedo ver los cambios que van ocurriendo, hago todo el recorrido sin pausas 
def print_data(data_received, show_reg_file_max, show_mem_max):
    if data_received:
        console = Console()
        # Obtenemos los 32 bits de data_received
        data = [data_received[i:i+4] for i in range(0, len(data_received), 4)]
        #Obtenemos pc, contador de clock, registros y memory data
        pc = ' '.join([format(byte, '08b') for byte in data[0]])
        clk_count = ' '.join([format(byte, '08b') for byte in data[1]])
        registers_val = []
        for i in range(0, 32):
            registers_val.append(' '.join([format(byte, '08b') for byte in data[i+2]]))

        memory = []
        for i in range(0, 16):
            memory.append(' '.join([format(byte, '08b') for byte in data[i+34]]))              

        # Print the extracted information
        print(
            f"\nClockCycles: {clk_count} = {int(clk_count.replace(' ',''), 2)}")
        print(f"\nPC: {pc} = {int(pc.replace(' ',''), 2)}")

        if (show_reg_file_max > 0):
            console.print("REGISTER FILE",style="bold red")
            for i in range(show_reg_file_max):
                print(f"{i}:  {registers_val[i]} = {int(registers_val[i].replace(' ',''), 2)}")                  

        if (show_mem_max > 0):
            console.print("DATA MEMORY",style="bold red")
            for i in range(show_mem_max):
                print(f"{i}:  {memory[i]} = {int(memory[i].replace(' ',''), 2)}")

#Cuando es por pasos
def print_data_dif(data_received, prev_data_received, show_reg_file_max, show_mem_max):
    if data_received:
        console = Console()
        # Obtenemos los 32 bits de data_received
        data = [data_received[i:i+4] for i in range(0, len(data_received), 4)]
        
        if(prev_data_received != 0):
            prev_data = [prev_data_received[i:i+4] for i in range(0, len(prev_data_received), 4)]
        else:
            prev_data = 0
        #Obtenemos pc, contador de clock, registros y memory data
        pc = ' '.join([format(byte, '08b') for byte in data[0]])
        pc_prev = 0
        if(prev_data != 0):
            pc_prev = ' '.join([format(byte, '08b') for byte in prev_data[0]])

        clk_count = ' '.join([format(byte, '08b') for byte in data[1]])

        registers_val = []
        prev_registers_val = []
        for i in range(0, 32):
            registers_val.append(' '.join([format(byte, '08b') for byte in data[i+2]]))
            if(prev_data != 0):
                prev_registers_val.append(' '.join([format(byte, '08b') for byte in prev_data[i+2]]))

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
                console.print(f"{pc} = {int(pc.replace(' ',''), 2)}",style="bold underline red on black")#cuando tengo una burbuja, osea me quedo en el mismo pc, pinto fondo negro
            elif(int(pc.replace(' ',''), 2) != int(pc_prev.replace(' ',''), 2)+4):
                console.print(f"{pc} = {int(pc.replace(' ',''), 2)}",style="bold underline red on green")#si hago un salto, cambio de pc, fondo verde
            else:
                print(f"\nPC: \n{pc} = {int(pc.replace(' ',''), 2)}")
        else:
            print(f"\nPC: \n{pc} = {int(pc.replace(' ',''), 2)}")

        if (show_reg_file_max > 0):
            console.print("REGISTER FILE",style="bold red")
            for i in range(show_reg_file_max):
                if(prev_data != 0):                    
                    if(registers_val[i] == prev_registers_val[i] ):
                        print(f"r{i}:  {registers_val[i]} = {int(registers_val[i].replace(' ',''), 2)}")#si no cambia no lo pinto de otro color
                    else:
                        console.print(f"r{i}: {registers_val[i]} = {int(registers_val[i].replace(' ',''), 2)}",style="bold yellow")#cuando cambia un registro, pinto flecha amarillo
                else:
                    print(f"r{i}:  {registers_val[i]} = {int(registers_val[i].replace(' ',''), 2)}")                   

        if (show_mem_max > 0):
            console.print("DATA MEMORY",style="bold red")
            for i in range(show_mem_max):
                if(prev_data != 0): 
                    if(memory[i] == prev_memory[i] or prev_data == 0):
                        print(f"r{i}:  {memory[i]} = {int(memory[i].replace(' ',''), 2)}")
                    else:
                        console.print(f"r{i}: {memory[i]} = {int(memory[i].replace(' ',''), 2)}",style="bold yellow") ##cuando cambia un registro en la memoria, pinto flecha amarillo q
                else:
                    print(f"r{i}:  {memory[i]} = {int(memory[i].replace(' ',''), 2)}")                  
