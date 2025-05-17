/*
            Para compilar corretamente, é necessário utilizar a seguinte linha no terminal (windows):
            gcc -finput-charset=UTF-8 main.c resources\icon.o -o main.exe
*/
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <time.h>
#include "lib/matriksLib.h"
#include "lib/functions.h"


int main(){
    //Compilar utilizando gcc -finput-charset=UTF-8 antes do output para sair os caracteres
    SetConsoleOutputCP(65001);  // Força a saída como UTF-8
    showMenu();
    return 0;
}