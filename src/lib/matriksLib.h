#ifndef matrikslib_h
#define matrikslib_h
#include <stdint.h>

int operate_buffer_send(int opcode, int position, int start, int* data);

int calculate_matriz(int opcode, int size, int start);

uint32_t operate_buffer_receive(int opcode, int position, int start);

#endif