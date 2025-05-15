/*
            Para compilar corretamente, é necessário utilizar a seguinte linha no terminal (windows):
            gcc -finput-charset=UTF-8 main.c resources\icon.o -o meu_programa.exe

            LEMBRE: Criar header depois
*/
#include <stdlib.h>
#include <stdio.h>
#include <time.h>

void showMenu();
void clean();
void menuOperation(char* option, int* matrixA, int* matrixB);
void printarMatriz(int* matriz, int size);

int main(){
    //Compilar utilizando gcc -finput-charset=UTF-8 antes do output para sair os caracteres
    SetConsoleOutputCP(65001);  // Força a saída como UTF-8
    showMenu();
    return 0;
}

void showMenu(){
    //Aloca espaço para opcao
    char* option;
    option = (char *)malloc(51*sizeof(char));

    //Aloca espaço para matrizes
    int* matrixA, matrixB;
    matrixA = (int *)malloc(25*sizeof(int));
    matrixB = (int *)malloc(25*sizeof(int));
    
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
            case '1': menuOperation(option, matrixA, matrixB);
            case '2': exit(0);
        }
    }

}

void menuOperation(char* option, int* matrixA, int* matrixB){
    int qty; // variável guarda se op precisa de 2 ou 1 matriz
    int size;
    int i,j; // iteradores

    clean();
    printf("\n\nOperações:\n\n(1) Soma\n(2) Subtração\n(3) Multiplicação de matrizes\n(4) Multiplicação por inteiro\n(5) Determinante\n(6) Transposta\n(7) Oposta\n");
    printf("\nDigite uma opção: ");
    scanf("%s", option);

    qty = ((*option) > 4) ? 1 : 2; // verifica qtd de matrizes

    printf("\nQual o tamanho da matriz?: ");
    scanf("%d", &size);

    printf("\nDigite a(s) matriz(es) em ordem de M[i,j].\n\n");

    // recebe matrizes
    for(i = 0; i < (size*size); i++){
        printf("matrizA[%d][%d]: ", (i/size), (i%size)); // printa a posição do elemento
        scanf("%d", &(matrixA[i]));
    }

    if((*option) == 4){
        printf("\n Digite o número: ");
        scanf("%d", matrixB[0]);
    }else if (qty == 2){
        for(i = 0; i < (size*size); i++){
        printf("matrizB[%d][%d]: ", (i/size), (i%size)); // printa a posição do elemento
        scanf("%d", &(matrixB[i]));
        }
    }
}

void printarMatriz(int* matriz, int size){
    int i, count;
    count = 0;

    for (i = 0; i < (size*size); i++){
        if ((i+1)%size == 0) printf("\n");
        printf("    %3d    ", matriz[i]);
    }

    printf("\n");
}

void clean(){
    system("clear");
}