import time

#N=50 (32 registers, 16 data memory, PC and clock)
def receive_result(serial, n):
    byte_counter= 0
    error= 0
    data= b''
    while byte_counter < n*4:
        if serial.in_waiting != 0:
            data += serial.read()
            byte_counter += 1
            error= 0
        else:
            time.sleep(0.1)  #tiempo waiting data
            error += 1
            if(error == 5):
                return data, 1
    return data, 0