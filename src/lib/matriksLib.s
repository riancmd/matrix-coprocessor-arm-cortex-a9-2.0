.global _start

_start:
    @ Exibe informações do menu
    MOV R0,#1 @standard output
    LDR R1,=menu1 @ Guarda valor da string
    LDR R2,=len1
    MOV R7,#4 @ Syscall: write
    SWI 0

    LDR R1,=menu2
    LDR R2,=len2
    MOV R7,#4 @ Syscall: write
    SWI 0

    LDR R1,=menu3
    LDR R2,=len3
    MOV R7,#4 @ Syscall: write
    SWI 0

    LDR R1,=menu4
    LDR R2,=len4
    MOV R7,#4 @ Syscall: write
    SWI 0

    LDR R1,=menu5
    LDR R2,=len5
    MOV R7,#4 @ Syscall: write
    SWI 0

    @Recebe input do usuário
    mov r7,#3 @syscall: read
    mov r0,#0 @standard input
    ldr r1,=buffer
    mov r2,#4
    svc #0
    mov r10,r0 @salva os bits lidos em r10, p preservar entre chamadas

    @ Termina o programa
    MOV R7,#1  @ Syscall: exit
    SWI 0

    
.data //Seção de dados
buffer: .space 4
menu1: .string "|*****| matriks |*****|\n" //o mesmo que .asciz
len1 = .-menu1
menu2: .string "(1) Operação\n"
len2 = .-menu2
menu3: .string "(2) Sair\n"
len3 = .-menu3
menu4: .string "Operações: (1) Soma, (2) Subtração, (3) Multiplicação de matrizes\n"
len4 = .-menu4
menu5: .string "(4) Multiplicação por inteiro, (5) Determinante, (6) Transposta, (7) Oposta\n"
len5 = .-menu5