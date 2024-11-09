import os
import serial
from funtions import sender
from funtions import configprint
from rich.console import Console


def case_step(ser,input_char):
    ser.write(input_char.encode())
    return 'STEP'

def case_continuos(ser,input_char):
    ser.write(input_char.encode())
    return 'CONTINUOUS'

def case_exit(ser,input_char):
    print("Modo EXIT")
    sys.exit()

def default(ser,input_char):
    print("[FAIL] mode no valida,  Ingrese s (STEP) c (CONTINUOUS) e (EXIT)")
    return 'IDLE'

cases = {
    's': case_step,
    'c': case_continuos,
    'e': case_exit
}


def get_file():
    while True:
        file = input("Indicar el nombre del archivo .asm para enviar a Basys3: ")
        if os.path.isfile(file):
            return file
        else:
            print("El archivo no existe. Por favor, ingrese de nuevo un filename valido")

def get_serial_port():
    return input("Introduce el puerto COM a usar (ej. COM3): ")




def main():


    file_bin = "code.bin"
    file_asm = get_file()
    serial_port = get_serial_port()
    print(f"Codigo Asm a enviar: {file_asm} - Puerto COM: {serial_port} - Baudios: 9600")

    total_instructions= sender.create_bin(file_asm, file_bin)

    ser = serial.Serial(serial_port, 9600)
    print("Envio de instrucciones...")
    sender.send(file_bin, ser)
    memory_val = 16
    register_val = 32
    

    mode = 'IDLE'

    while True:
        console = Console()

        if (mode == 'IDLE'):
            console.print("Ingrese el modo que desea ejecutar",style="bold red")
            console.print("s (STEP) c (CONTINUOUS) e (EXIT)" ,style="bold blue")
            input_char = input("Mode :")
            previous_data = 0
            mode = cases.get(input_char, default)(ser,input_char)

        elif (mode == 'STEP'):
            console.print("---------MODO STEP---------",style="bold red")
            while (input_char != 'e'):
                console.print("##### presione n para el siguiente step #####",style="bold red")
                input_char = input("Mode :")
                if (input_char == 'n'):
                    ser.write(input_char.encode())
                    data_received, err = sender.receive_result(ser, 50)
                if(err == 1):
                    mode = 'IDLE'
                    break
                else:
                    console.print("#############################################",style="bold red")
                    configprint.print_data_dif( data_received, previous_data, register_val,memory_val)
                    previous_data = data_received
            sys.exit()
        
        
        elif (mode == 'CONTINUOUS'):
            console.print("---------MODO CONTINUO---------",style="bold red")
            input_char == 'c'
            ser.write(input_char.encode())
            data_received, err = sender.receive_result(ser, 50)
            configprint.print_data(data_received , register_val ,memory_val)
            mode = 'IDLE'


if __name__ == "__main__":
    main()
