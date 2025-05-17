#ifndef functions_h
#define functions_h

#define storeMatrixA 0b00
#define storeMatrixB 0b01
#define loadMatrixResult 0b10
#define pos1 0b00
#define pos2 0b000
#define START 0b1

void showMenu();
void clean();
void menuOperation(char* option, int* matrixA, int* matrixB, int* result);
void printarMatriz(int* matriz, int size);

#endif