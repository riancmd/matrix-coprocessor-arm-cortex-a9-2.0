#ifndef matrikslib_h
#define matrikslib_h

int operate_buffer_send(int opcode, int position, int start, int data);

int calculate_matriz(int opcode, int size, int start);

int operate_buffer_receive(int opcode, int position, int start);

#endif