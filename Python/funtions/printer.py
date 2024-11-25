from rich.console import Console

def print_data_continuo(data_received, registers_to_show, mem_data_to_show):

###Codigo mas lento en el clok por el append
#       data = []
#        for i in range(0, len(data_received), 4):
#            data.append(data_received[i:i+4])  #Armo bloques de 4 elementos (4 bytes)

        #el primer bloque de DATA para PC en binario
#        pc = []
#        for byte in data[0]:
#            pc.append(format(byte, '08b'))
#        pc = ' '.join(pc)

        #segundo bloque en clk
#        clk_count = []
#        for byte in data[1]:
#            clk_count.append(format(byte, '08b'))
#        clk_count = ' '.join(clk_count)

        #Inicializar 'registers_value'
#        registers_value = []
#        for i in range(0, registers_to_show):
#            registers_value.append(' '.join([format(byte, '08b') for byte in data[i+2]]))

#       memory = []
#        for i in range(0, mem_data_to_show):
#            memory.append(' '.join([format(byte, '08b') for byte in data[i+34]]))              
        
##########################################################################################################

    if data_received:
        console = Console()

        #Dividir data_received en bloques de 4 elementos. 4 bytes
        data = [data_received[i:i+4] for i in range(0, len(data_received), 4)]

        #Primer bloque para PC en formato binario
        pc = ' '.join(format(byte, '08b') for byte in data[0])

        #Segundo bloque para el contador de clock en formato binario
        clk_count = ' '.join(format(byte, '08b') for byte in data[1])

        registers_value = [
            ' '.join(format(byte, '08b') for byte in data[i+2]) 
            for i in range(registers_to_show)
        ]

        # Inicializar 'memory'
        memory = [
            ' '.join(format(byte, '08b') for byte in data[i+34]) 
            for i in range(mem_data_to_show)
        ]

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
        data = [data_received[i:i+4] for i in range(0, len(data_received), 4)]

        #Dividir 'prev_data_received'
        prev_data = (
            [prev_data_received[i:i+4] for i in range(0, len(prev_data_received), 4)]
            if prev_data_received != 0 else 0
        )

        #Primer bloque de 'data' para PC en binario
        pc = ' '.join(format(byte, '08b') for byte in data[0])
        pc_prev = (
            ' '.join(format(byte, '08b') for byte in prev_data[0]) 
            if prev_data != 0 else 0
        )

        #Segundo bloque de 'data' para clk_count en binario
        clk_count = ' '.join(format(byte, '08b') for byte in data[1])

        registers_value = [
            ' '.join(format(byte, '08b') for byte in data[i+2]) 
            for i in range(32)
        ]

        prev_registers_value = (
            [
                ' '.join(format(byte, '08b') for byte in prev_data[i+2]) 
                for i in range(32)
            ] if prev_data != 0 else []
        )

        memory = [
            ' '.join(format(byte, '08b') for byte in data[i+34]) 
            for i in range(16)
        ]

        prev_memory = (
            [
                ' '.join(format(byte, '08b') for byte in prev_data[i+34]) 
                for i in range(16)
            ] if prev_data != 0 else []
        )
        print(f"\nClockCycles: {clk_count} = {int(clk_count.replace(' ',''), 2)}")

        if(prev_data != 0):
            if( pc == pc_prev):
                console.print("PC",style="white")
                console.print(f"{pc} = {int(pc.replace(' ',''), 2)}", style="bold underline red on red")  #Fondo rojo para burbuja
            elif(int(pc.replace(' ',''), 2) != int(pc_prev.replace(' ',''), 2)+4):
                console.print("PC",style="white")
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
