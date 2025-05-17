#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <time.h>
#include "matriksLib.h"
#include "functions.h"

void showMenu(){
    //Aloca espaço para opcao
    char* option;
    option = (char *)malloc(51*sizeof(char));

    //Aloca espaço para matrizes
    int* matrixA;
    int* matrixB;
    int* result;
    matrixA = (int *)malloc(25*sizeof(int));
    matrixB = (int *)malloc(25*sizeof(int));
    result = (int *)malloc(25*sizeof(int));
    
    while(1){
        //LEMBRETE: Trocar usleep por nanosleep para usar no Linux
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
        scanf("%s", option);
        
        if (option == NULL || ((*option) != '2' && (*option) != '1')){
            printf("\n Opção inválida.\n");
            clean();
            continue;
        }
        
        switch (*option){
            case '1': menuOperation(option, matrixA, matrixB, result);
            case '2': exit(0);
        }
    }
}

void menuOperation(char* option, int* matrixA, int* matrixB, int* result){
    int qty; // variável guarda se op precisa de 2 ou 1 matriz
    int size;
    int i,j; // iteradores
    int opcode;
    int matrizConcatenada;
    int tempM[25];

    clean();
    printf("\n\nOperações:\n\n(1) Soma\n(2) Subtração\n(3) Multiplicação de matrizes\n(4) Multiplicação por inteiro\n(5) Determinante\n(6) Transposta\n(7) Oposta\n");
    printf("\nDigite uma opção: ");
    scanf("%s", option);

    qty = ((*option) > 4) ? 1 : 2; // verifica qtd de matrizes
    opcode = (*option);

    printf("\nQual o tamanho da matriz?: ");
    scanf("%d", &size);

    printf("\nDigite a(s) matriz(es) em ordem de M[i,j].\n\n");

    // recebe matrizes
    for(i = 0; i < (size*size); i++){
        printf("matrizA[%d][%d]: ", (i/size), (i%size)); // printa a posição do elemento
        scanf("%d", &(tempM[i]));
    }

    // passa para matriz A
    for (i = 0; i < 5; i++) {
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

    // recebe o input da matriz B ou de número
    if((*option) == 4){
        printf("\n Digite o número: ");
        scanf("%d", &(matrixB[0]));
    }else if (qty == 2){
        for(i = 0; i < (size*size); i++){
        printf("matrizB[%d][%d]: ", (i/size), (i%size)); // printa a posição do elemento
        scanf("%d", &(matrixB[i]));
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
    for (i = 0; i < 5; i++){
        flagOK = operate_buffer_send(storeMatrixA, pos1, START, matrixA);
    }
    for (i = 0; i < 5; i++){
        flagOK = operate_buffer_send(storeMatrixB, pos1, START, matrixB);
    }

    int pos = 0; // posição atual no array

    // envia operação
    if (flagOK){
        calculate_matriz(opcode, size, START);

        int8_t byte0, byte1, byte2, byte3; // variaveis que recebem os números separados do pacote de 32bits
        uint32_t packed_data; // variavel que recebe o pacote de 32bits

        // recebe o resultado da operação
        for (i = 0; i < 5; i++){
            packed_data = operate_buffer_receive(loadMatrixResult, pos2, START);
        
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
}

void printarMatriz(int* matriz, int size){
    int i, count;
    count = 0;

    printf("Resultante: \n");

    for (i = 0; i < (size*size); i++){
        if ((i+1)%size == 0) printf("\n");
        printf("    %3d    ", matriz[i]);
    }

    printf("\n");
}

void clean(){
    system("clear");
}