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
.EQU MMAP, 192

.equ STDI, 0 @ Standard input
.equ STDO, 1 @ Standard output

@ Definição dos endereços físicos da De1-SoC
.equ FPGA_BRIDGE_PHYS,  0xFF200  @ Endereço físico base
.equ PIO_OUTPUT_OFFSET, 0x0000      @ Offset do PIO de saída (HPS->FPGA)
.equ PIO_INPUT_OFFSET,  0x0010      @ Offset do PIO de entrada (FPGA->HPS)
.equ PAGE_SIZE,         4096        @ Tamanho da página

@ Constantes para o mmap
.equ PROT_READ,      1
.equ PROT_WRITE,     2
.equ MAP_SHARED,     1
.equ O_RDWR,         2
.equ O_SYNC,         0x1000
.equ MAP_FAILED,     -1

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
mmap_error:
    .string "Erro no mapeamento de memória. Finalizando...\n"
len6 =
    .-mmap_error

.global _start

_start:
    LDR R0,=dev_mem @ Utiliza o dev/mem para acessar a memória física
    LDR R1,O_RDWR @ "open for read and write"
    MOV R7,OPEN
    SWI 0

    CMP R0,#0
    BLT mmap_fail @ Caso haja algum erro no mapeamento, encerra o programa

    @ Mapeamento da memória
    MOV R0,#0 @ Kernel escolhe qual endereço utilizar
    MOV R1,#PAGE_SIZE @ Tamanho do mapeamento = 4096b
    MOV R2,#3
    MOV R3,#MAP_SHARED
    MOV R4,R10 @ File descriptor do /dev/mem
    MOV R5,#FPGA_BRIDGE_BASE @ Endereço físico base
    MOV R7,#MMAP
    SWI 0
    CMP R0,#MAP_FAILED
    BEQ mmap_fail
    MOV R8, R0 @ Endereço virtual mapeado em r8
    ADD R9, R8, #PIO_INPUT_OFFSET @ r9 = endereço do PIO de entrada

@ Procedimento que exibe o menu
menu:
    MOV R0,STDO @ Sinaliza uso de standard output
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
    MOV R7,READ @syscall: read
    MOV R0,STDI @standard input
    LDR R1,=input_buffer
    MOV R2,#4
    SVC #0
    MOV R10,R0 @salva os bits lidos em r10, p preservar entre chamadas



    B menu

mmap_fail:
    MOV R0,STDO @standard output
    LDR R1,=mmap_error @ Guarda valor da string
    LDR R2,=len1
    MOV R7,WRITE @ Syscall: write
    SWI 0
    MOV R7,EXIT @ Syscall: exit
    SWI 0