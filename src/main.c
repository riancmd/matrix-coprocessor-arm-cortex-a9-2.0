#include <stdlib.h>
#include <stdio.h>
#include <time.h>

void showMenu();
void clear();
void menuOperation();

int main(){
    //Compilar utilizando gcc -finput-charset=UTF-8 antes do output para sair os caracteres
    showMenu();
    return 0;
}

void showMenu(){
    //Aloca espaço para opcao
    char* option;
    option = (char *)malloc(51*sizeof(char));
    //Aloca espaço para matriz
    int* matrix;
    matrix = (int *)malloc(25*sizeof(int));
    
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
        printf("(2) - Sair");
        printf("\n");
        printf("Digite uma opção: ");
        scanf("%s", option);
        
        if (option == NULL || ((*option) != '2' && (*option) != '1')){
            printf("\n Opção inválida.\n");
            //clear();
            continue;
        }
        
        switch (*option){
            case '1': menuOperation(option);
            case '2': exit(0);
        }
    }

}

void menuOperation(char* option){
    clear();
    printf("Operações:\n(1) Soma\n(2) Subtração\n(3) Multiplicação de matrizes\n(4) Multiplicação por inteiro\n(5) Determinante\n(6) Transposta\n(7) Oposta\n");
    printf("Digite uma opção: ");
    scanf("%s", option);

}

void clear(){
    system("clear");
}