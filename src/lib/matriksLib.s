@ Biblioteca em Assembly p comunicação com o coprocessador aritmético de matrizes
@ São utilizadas 5 PIOs para a comnunicação, são elas:
@ - PIO1
@ - PIO2
@ - PIO3
@ - PIO4
@ - PIO5

@ Definição de constantes para as syscalls e stdin/o
.equ EXIT,  1
.equ READ,  3
.equ WRITE, 4
.equ OPEN,  5
.equ CLOSE, 6

.equ STDI, 0 @ Standard input
.equ STDO, 1 @ Standard output

@ Definição dos endereços físicos da De1-SoC
.equ FPGA_BRIDGE_PHYS,  0xFF200  @ Endereço físico base
.equ PIO_OUTPUT_OFFSET, 0x0000      @ Offset do PIO de saída (HPS->FPGA)
.equ PIO_INPUT_OFFSET,  0x0010      @ Offset do PIO de entrada (FPGA->HPS)
.equ PAGE_SIZE,         4096        @ Tamanho da página

@ Constantes para o mmap

@ Dados
.data
dev_mem:
    .asciz "/dev/mem"
input_buffer: 
    .space 4
menu1: 
    .string "|*****| matriks |*****|\n" //o mesmo que .asciz
len1 = 
    .-menu1
menu2: 
    .string "(1) Operação\n"
len2 = 
    .-menu2
menu3:  
    .string "(2) Sair\n"
len3 = 
    .-menu3
menu4: 
    .string "Operações: (1) Soma, (2) Subtração, (3) Multiplicação de matrizes\n"
len4 = 
    .-menu4
menu5: 
    .string "(4) Multiplicação por inteiro, (5) Determinante, (6) Transposta, (7) Oposta\n"
len5 = 
    .-menu5

.global _start

_start:
    

    @ Termina o programa
    MOV R7,#1  @ Syscall: exit
    SWI 0

@ Procedimento que exibe o menu
menu:
    @ Exibe informações do menu
    MOV R0,STDO @standard output
    LDR R1,=menu1 @ Guarda valor da string
    LDR R2,=len1
    MOV R7,WRITE @ Syscall: write
    SWI 0

    LDR R1,=menu2
    LDR R2,=len2
    MOV R7,WRITE @ Syscall: write
    SWI 0

    LDR R1,=menu3
    LDR R2,=len3
    MOV R7,WRITE @ Syscall: write
    SWI 0

    LDR R1,=menu4
    LDR R2,=len4
    MOV R7,WRITE @ Syscall: write
    SWI 0

    LDR R1,=menu5
    LDR R2,=len5
    MOV R7,WRITE @ Syscall: write
    SWI 0

    @Recebe input do usuário
    mov r7,READ @syscall: read
    mov r0,STDI @standard input
    ldr r1,=input_buffer
    mov r2,#4
    svc #0
    mov r10,r0 @salva os bits lidos em r10, p preservar entre chamadas

    B menu