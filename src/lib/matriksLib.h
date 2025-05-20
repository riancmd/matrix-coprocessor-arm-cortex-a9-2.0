#ifndef matrikslib_h
#define matrikslib_h

#include <stdint.h>

extern void start_program(void);

extern int operate_buffer_send(int opcode, int position, int start, int* data);

extern int calculate_matriz(int opcode, int size, int start);

extern uint32_t operate_buffer_receive(int opcode, int position, int start);

extern void exit_program(void);

#endif