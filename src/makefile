compilar:
	@as -c matriksLib.s -o matriks.o && gcc -c functions.c -o functions.o && gcc -c main.c -o main.o && gcc main.o functions.o matriks.o -o main

run:
	@sudo ./main