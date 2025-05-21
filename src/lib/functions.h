#ifndef functions_h
#define functions_h

// definição das operações load e store
#define storeMatrixA 0b00
#define storeMatrixB 0b01
#define loadMatrixResult 0b10
#define START 0b1

// definição das operações (IS - instruction set)
#define SOM 0b000;
#define SUB 0b001;
#define MULM 0b010;
#define MULI 0b011;
#define DET 0b100;
#define TRANS 0b101;
#define OPP 0b110;

// protótipo das funções
void showMenu();
void clean();
void menuOperation(int* matrixA, int* matrixB, int* result);
void printarMatriz(int* matriz, int size);

#endif