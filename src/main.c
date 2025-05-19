/*
            Para compilar e rodar corretamente, é necessário utilizar as seguintes linhas no terminal:
                as -c lib/matriksLib.s -o lib/matriksLib.o  [MONTA O ASSEMBLY]
                gcc -c lib/functions.c -o lib/functions.o -I./lib [COMPILA O FUNCTIONS]
                gcc -c main.c -o main.o -I./lib [COMPILA A MAIN]
                gcc main.o lib/functions.o lib/matriksLib.o -o main [LINKA TUDO]
                sudo ./main [RODA A MAIN]

            gcc -finput-charset=UTF-8 main.c resources\icon.o -o main.exe [WINDOWS, IGNORE]
*/
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <time.h>
#include "lib/matriksLib.h"
#include "lib/functions.h"


int main(){
    showMenu();
    return 0;
}