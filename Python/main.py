import os
import serial
import sys
from funtions import sender
from funtions import receiver
from funtions import printer
import tkinter as tk
from tkinter import filedialog, messagebox
from rich.console import Console


def run_console():
    subprocess.run(['python', 'main.py']) 

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
    print("[FAIL] mode no valido. Ingrese s (STEP) c (CONTINUOUS) e (EXIT)")
    return 'IDLE'

cases = {
    's': case_step,
    'c': case_continuos,
    'e': case_exit
}


def get_file():
    file = filedialog.askopenfilename(title="Seleccionar archivo ASM", filetypes=(("Archivos ASM", "*.asm"), ("Todos los archivos", "*.*")))
    if file:
        return file
    else:
        return None
    
def get_serial_port():
    return port_entry.get()


def send_program_boton():
    #Verificacion de COM y File
    if not selected_file:
        messagebox.showerror("Error", "Por favor, seleccione un archivo primero.")
        return
    
    serial_port = get_serial_port()
    if not serial_port:
        messagebox.showerror("Error", "Por favor, ingrese un puerto COM valido.")
        return

    print(f"Console LOG Interactive")
    print(f"Codigo Asm a enviar: {selected_file} - Puerto COM: {serial_port} - Baudios: 9600")
    file_bin = "code.bin"
    sender.create_bin(selected_file, file_bin)

    ser = serial.Serial(serial_port, 9600)
    print("Envio de instrucciones...")
    sender.send(file_bin, ser)

    mode = 'IDLE'
    memory_data_print = 16
    registers_bank_print = 32

    #Continuar el proceso en consola
    console = Console()

    while True:
        if mode == 'IDLE':
            console.print("\n\nLa consola permite ejecutar el programa en 2 modos posibles")
            console.print("Ingrese el modo que desea ejecutar:", style="bold green")
            console.print("Modo Step by Step ( Ingrese caracter 's' )", style="bold blue")
            console.print("Modo Continuo ( Ingrese caracter 'c' )", style="bold blue")
            console.print("Exit ( Ingrese caracter 'e' ) ", style="bold red")
            input_char = input("Input Mode selector: ")
            previous_data = 0
            mode = cases.get(input_char, default)(ser, input_char)

        elif mode == 'STEP':
            console.print("---------MODO STEP by STEP---------", style="bold blue")
            console.print("Durante este modo puede indicar cuando avanzar un ciclo de reloj en la ejecucion")
            while input_char != 'e':
                console.print("Ingrese el caracter 'n' NEXT para avanzar", style="bold green")
                input_char = input("Clock input: ")
                if input_char == 'n':
                    ser.write(input_char.encode())
                    data_received, err = receiver.receive_result(ser, 65)
                    if err == 1:
                        mode = 'IDLE'
                        console.print("Finish Program", style="bold green")
                        break
                    else:
                        console.print("-------------------------------------", style="bold red")
                        printer.print_data_step(data_received, previous_data, registers_bank_print, memory_data_print)
                        previous_data = data_received

        elif mode == 'CONTINUOUS':
            console.print("---------MODO CONTINUO---------", style="bold red")
            console.print("Durante este modo se ejecuto el programa hasta su ultima intruccion")
            input_char = 'c'
            ser.write(input_char.encode())
            data_received, err = receiver.receive_result(ser, 65)
            printer.print_data_continuo(data_received, registers_bank_print, memory_data_print)
            mode = 'IDLE'


root = tk.Tk()
root.title("Serial Configuration and Program Basys3")

# Ingreso del puerto COM
tk.Label(root, text="Puerto COM (Ej. COM3):").pack(padx=10, pady=5)
port_entry = tk.Entry(root)
port_entry.pack(padx=10, pady=5)

# Variable para almacenar el archivo seleccionado
selected_file = None


def select_file_boton():
    global selected_file
    selected_file = get_file()
    if selected_file:
        print(f"Archivo seleccionado: {selected_file}")
        messagebox.showinfo("Archivo Cargado", f"El archivo '{selected_file}' se cargó exitosamente.")
    else:
        print("No se seleccionó ningún archivo.")

select_file_button = tk.Button(root, text="Seleccionar archivo ASM", command=select_file_boton)
select_file_button.pack(padx=10, pady=5)

#Boton para enviar el programa
send_program_button = tk.Button(root, text="Enviar Programa", command=send_program_boton)
send_program_button.pack(padx=10, pady=20)

root.mainloop()
run_console()