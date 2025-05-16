@ Biblioteca em Assembly p comunicação com o coprocessador aritmético de matrizes
@ São utilizadas 5 PIOs para a comnunicação, são elas:
@ - PIO1
@ - PIO2
@ - PIO3
@ - PIO4
@ - PIO5

@ Ops que usam duas matrizes
.equ SOMA, 0
.equ SUBTRACAO, 1
.equ MULT_MATRIZ, 2
.equ MULT_INT, 3

@ Ops que usam uma matriz
.equ DETERMINANTE, 4
.equ TRANSPOSTA, 5
.equ OPOSTA, 6

@ Tamanhos das matrizes
.equ TAM0, 0
.equ TAM1, 1
.equ TAM2, 2
.equ TAM3, 3

@ Definição de constantes para as syscalls e stdin/o
.equ EXIT,  1
.equ READ,  3
.equ WRITE, 4
.equ OPEN,  5
.equ CLOSE, 6
.equ MUNMAP, 91
.equ MMAP, 192


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

mmap_fail:
    MOV R0,STDO @standard output
    LDR R1,=mmap_error @ Guarda valor da string
    LDR R2,=len1
    MOV R7,WRITE @ Syscall: write
    SWI 0
    MOV R7,EXIT @ Syscall: exit
    SWI 0

invalida_op:
    MOV R0,STDO @ Sinaliza uso de standard output
    LDR R1,=option_error @ Guarda valor da string do erro
    LDR R2,=len7
    MOV R7,WRITE @ Syscall: write
    SWI 0

    B exit_program

exit_program:
    @ Desmapeia a memória
    MOV R0,R8
    MOV R1,#PAGE_SIZE
    MOV R7,#MUNMAP
    SWI 0

    @ Fecha /dev/mem
    MOV R0,R10
    MOV R7,#CLOSE
    SWI 0

    @ Encerra o programa
    MOV R7,EXIT
    MOV R0,#0
    SWI 0