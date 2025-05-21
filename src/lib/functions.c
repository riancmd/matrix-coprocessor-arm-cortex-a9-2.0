#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <time.h>
#include "matriksLib.h"
#include "functions.h"

/*
extern void start_program();

extern int operate_buffer_send(int opcode, int position, int start, int* data);

extern int calculate_matriz(int opcode, int size, int start);

extern uint32_t operate_buffer_receive(int opcode, int position, int start);

extern void exit_program();
*/
void showMenu(){
    //Aloca espaço para opcao
    char* option;
    option = (char *)calloc(1, sizeof(char));

    //Aloca espaço para matrizes
    int* matrixA;
    int* matrixB;
    int* result;
    matrixA = (int *)calloc(25, sizeof(int));
    matrixB = (int *)calloc(25, sizeof(int));
    result = (int *)calloc(25, sizeof(int));
    
    while(1){
        printf("                ___  ___   __  __         _          _  _           ___  ___\n");
        usleep(250000);
        printf("               |  _||  _| |  \\/  |       | |        (_)| |         |_  ||_  |\n");
        usleep(250000);
        printf("               | |  | |   | \\  / |  __ _ | |_  _ __  _ | | __ ___    | |  | |\n");
        usleep(250000);
        printf("               | |  | |   | |\\/| | / _` || __|| '__|| || |/ // __|   | |  | |\n");
        usleep(250000);
        printf("               | |  | |   | |  | || (_| || |_ | |   | ||   < \\__ \\   | |  | |\n");
        usleep(250000);
        printf("               | |_ | |_  |_|  |_| \\__,_| \\__||_|   |_||_|\\_\\|___/  _| | _| |\n");
        usleep(250000);
        printf("               |___||___|                                          |___||___|\n");
        usleep(250000);
        printf("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
        usleep(1000000);
        printf("Seja bem vindo à biblioteca Matriks.\n");
        usleep(250000);
        printf("Para realizar operações com matrizes nxn, n<=5, prossiga.\n");
        printf("\n");
        usleep(250000);
        printf("(1) - Realizar operação");
        printf("\n(2) - Sair");
        printf("\n");
        printf("\nDigite uma opção: ");
        scanf("%c", option);
            
        
        switch (*option){
            case '1': 
                    start_program();
                    menuOperation(matrixA, matrixB, result);
                    break;            
            case '2': 
                    exit(0);
                    break;
            default: 
                    printf("\n Opção inválida.\n");
                    clean();
        }
    }
}

void menuOperation(int* matrixA, int* matrixB, int* result){
    int qty; // variável guarda se op precisa de 2 ou 1 matriz
    int size;
    int option2;
    int i,j; // iteradores
    int opcode;
    int matrizConcatenada;
    int* ptr_pos; // Ponteiro para percorrer pelos pacotes de números da matriz
    int tempM[25];

    printf("\n\nOperações:\n\n(1) Soma\n(2) Subtração\n(3) Multiplicação de matrizes\n(4) Multiplicação por inteiro\n(5) Determinante\n(6) Transposta\n(7) Oposta\n");
    printf("\nDigite uma opção: ");
    scanf("%d", option2);

    qty = (option2 > 4) ? 1 : 2; // verifica qtd de matrizes
    opcode = option2;

    printf("\nTamanhos: \n");
    for (i=0;i<4;i++){
        printf("(%d) Matriz %dx%d \n", (i+2), (i+2), (i+2));
    }

    printf("\nQual o tamanho da matriz?: ");
    scanf("%d", &size);

    printf("\nDigite a(s) matriz(es) em ordem de M[i,j].\n\n");

    // recebe matrizes
    printf("%d", size);
    for(i = 0; i < (size*size); i++){
        printf("matrizA[%d][%d]: ", (i/size), (i%size)); // printa a posição do elemento
        scanf("%d", &(tempM[i]));
    }

    printf("\nEnviou todos os elementos.\n");

    // passa para matriz A
    for (i = 0; i < 5; i++) {
        printf("Loop.");
        for (j = 0; j < 5; j++) {
            if (i < size && j < size) {
                // copia os valores da matriz original
                matrixA[i*5 + j] = tempM[i*size + j];
            } else {
                // preenche com zeros
                matrixA[i*5 + j] = 0;
            }
        }
    }

    printf("Passou todos os elementos.");

    // recebe o input da matriz B ou de número
    if((option2) == 4){
        printf("\n Digite o número: ");
        scanf("%d", &(matrixB[0]));
    }else if (qty == 2){
        for(i = 0; i < (size*size); i++){
        printf("matrizB[%d][%d]: ", (i/size), (i%size)); // printa a posição do elemento
        scanf("%d", &(tempM[i]));
        }

        // passa para matriz B
        for (i = 0; i < 5; i++) {
            for (j = 0; j < 5; j++) {
                if (i < size && j < size) {
                    // copia os valores da matriz original
                    matrixB[i*5 + j] = tempM[i*size + j];
                } else {
                    // preenche com zeros
                    matrixB[i*5 + j] = 0;
                }
            }
        }
    }

    int flagOK;
    flagOK = 0;

    // envia os dados com o opcode
    ptr_pos = matrixA;
    for (i = 0; i < 7; i++){
        flagOK = operate_buffer_send(storeMatrixA, i, START, ptr_pos);
        ptr_pos = ptr_pos + 4;
    }

    ptr_pos = matrixB;
    for (i = 0; i < 7; i++){
        flagOK = operate_buffer_send(storeMatrixB, i, START, ptr_pos);
        ptr_pos = ptr_pos + 4;
    }

    int pos = 0; // posição atual no array

    // envia operação
    if (flagOK){
        calculate_matriz(opcode, (size-2), START);

        int8_t byte0, byte1, byte2, byte3; // variaveis que recebem os números separados do pacote de 32bits
        uint32_t packed_data; // variavel que recebe o pacote de 32bits

        // recebe o resultado da operação
        for (i = 0; i < 7; i++){
            packed_data = operate_buffer_receive(loadMatrixResult, i, START);
        
            // Extrai cada byte e converte para int8_t (com extensão de sinal para int)
            byte0 = (packed_data >> 24) & 0xFF;
            byte1 = (packed_data >> 16) & 0xFF;
            byte2 = (packed_data >> 8)  & 0xFF;
            byte3 = packed_data & 0xFF;
            
            // Armazena no array (se ainda houver espaço)
            if (pos < 25) result[pos++] = byte0;
            if (pos < 25) result[pos++] = byte1;
            if (pos < 25) result[pos++] = byte2;
            if (pos < 25) result[pos++] = byte3;
        }
    }
    
    printarMatriz(result, size);

    // printf("\nDeseja continuar?: ");
    // scanf("%d", option);
}

void printarMatriz(int* matriz, int size){ //Por enquanto, printa a matriz como sendo 5x5 independente do tamanho
    int i, count;
    count = 0;

    printf("\n\nResultante: \n");

    for (i = 0; i < (25); i++){
        printf("    %3d    ", matriz[i]);
        if ((i+1)%5 == 0) printf("\n");
    }

    printf("\n");
}

void clean(){
    system("clear");
}