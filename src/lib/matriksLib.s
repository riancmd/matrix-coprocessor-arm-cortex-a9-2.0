@ Biblioteca em Assembly p comunicação com o coprocessador aritmético de matrizes
@ São utilizadas 5 PIOs para a comnunicação, são elas:
@ - PIO1 (Dados de entrada para FPGA - OFFSET 0x0000) - 32bits
@ - PIO2 (Instrução do buffer - OFFSET 0x0010) - 2 bits_Opcode, 3 bits_Position, 1 bit_start
@ - PIO3 (Instrução do coprocessador- OFFSET 0x0020) - 3 bits_Opcode, 2 bits_tamanho, 1 bit_start)
@ - PIO4 (Dados de saída do FPGA - OFFSET 0x0030) - 32bits
@ - PIO5 (Sinais de controle do FPGA - OFFSET 0x0040) - 1 bit_readybuffer, 1 bit_ready_coprocessor


@ Definição de constantes para as syscalls e stdin/o
.equ EXIT,  1
.equ READ,  3
.equ WRITE, 4
.equ OPEN,  5
.equ CLOSE, 6
.equ MUNMAP, 91
.equ MMAP, 192

@ Definição da quantidade de iterações do loop de delay
.equ DELAY_LOOPS, 1

.equ STDI, 0 @ Standard input
.equ STDO, 1 @ Standard output

@ Definição dos endereços físicos da De1-SoC
.equ FPGA_BRIDGE_PHYS,  0xFF200  @ Endereço físico base
.equ PIO_DATA_IN_OFFSET, 0x0000      @ Offset do PIO de dados(HPS->FPGA)
.equ PIO_BUFFER_INSTRUCTION_OFFSET, 0x0010      @ Offset do PIO de instrução do buffer(HPS->FPGA)
.equ PIO_COPROCESSOR_INSTRUCTION_OFFSET, 0x0020      @ Offset do PIO instrução do coprocessador(HPS->FPGA)
.equ PIO_DATA_OUT_OFFSET, 0x0030      @ Offset do PIO de dados(FPGA->HPS)
.equ PIO_READY_SIGNALS_OFFSET,  0x0040      @ Offset do PIO de de sinais de ready (FPGA->HPS)
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
axi_lw_adrss: 
    .word 0
mmap_error:
    .asciz "Erro no mapeamento de memória. Finalizando...\n"
len1: .word .-mmap_error


@ Procedimento de Mapeamento dos endereços virtuais dos PIOs
.global start_program
.type start_program, %function
start_program:
    PUSH {R1-R10, LR} @ Salva os registradores que devem ser preservados e o Registrador de retorno (LR)

    LDR R0,=dev_mem @ Utiliza o dev/mem para acessar a memória física
    MOV R1, #2 @ "open for read and write"
    MOV R7, #OPEN
    SWI 0
    MOV R10, R0 @ Salva o File Descriptor
    
    CMP R0, #0
    BLT mmap_fail @ Caso haja algum erro no mapeamento, encerra o programa

    @ Mapeamento da memória
    MOV R0, #0 @ Kernel escolhe qual endereço utilizar
    LDR R1, =PAGE_SIZE @ Tamanho do mapeamento = 4096b
    MOV R2, #3
    MOV R3, #MAP_SHARED
    MOV R4, R10 @ File descriptor do /dev/mem
    LDR R5,=FPGA_BRIDGE_PHYS @ Endereço físico base
    MOV R7, #MMAP
    SWI 0
    CMP R0, #MAP_FAILED
    BEQ mmap_fail
    LDR R8, =axi_lw_adrss
    STR R0, [R8] @ Endereço virtual mapeado na variàvel
       
    POP {R4-R10, LR} @ Restaura registradores e retorna para o antigo LR
    BX LR
.size start_program, .-start_program

mmap_fail:
    MOV R0, #STDO @standard output
    LDR R1,=mmap_error @ Guarda valor da string
    LDR R2,=len1
    MOV R7, #WRITE @ Syscall: write
    SWI 0
    MOV R7, #EXIT @ Syscall: exit
    SWI 0


@ Procedimento para finalizar o programa
.global exit_program
.type exit_program, %function
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
    MOV R7, #EXIT
    MOV R0, #0
    SWI 0

@ Procedimentos de envio de dados
.global operate_buffer_send
.type operate_buffer_send, %function
operate_buffer_send:
    PUSH {R4-R8, LR} @ Salva os registradores que devem ser preservados e o Registrador de retorno (LR)

    @ Concatena os argumentos em uma única instrução
    MOV R4, #0
    LSL R4, R0, #4 		@ Opcode[5:4]
    ORR R4, R4, R1, LSL #1 	@ Position[3:1]
    ORR R4, R4, R2		@ Start[0]

    @ R3 contém o endereço do array de inteiros (int*)
    LDR R5, [R3, #0]    @ Carrega o primeiro inteiro (32 bits)
    LDR R6, [R3, #4]    @ Carrega o segundo inteiro
    LDR R7, [R3, #8]    @ Carrega o terceiro inteiro
    LDR R0, [R3, #12]   @ Carrega o quarto inteiro

    @ Extrai apenas o byte menos significativo (LSB) de cada inteiro
    AND R5, R5, #0xFF   @ Pega apenas o byte 0 do primeiro int
    AND R6, R6, #0xFF   @ Pega apenas o byte 0 do segundo int
    AND R7, R7, #0xFF   @ Pega apenas o byte 0 do terceiro int
    AND R0, R0, #0xFF   @ Pega apenas o byte 0 do quarto int

    @ Concatena os 4 bytes em R3 (R5=byte0, R6=byte1, R7=byte2, R0=byte3)
    MOV R3, #0            @ Zera R3
    ORR R3, R3, R5, LSL #24  @ Coloca byte0 em [31:24]
    ORR R3, R3, R6, LSL #16  @ Coloca byte1 em [23:16]
    ORR R3, R3, R7, LSL #8   @ Coloca byte2 em [15:8]
    ORR R3, R3, R0            @ Coloca byte3 em [7:0]

    @ Escreve nos PIOs de dados de entrada e instrução do buffer
    STR R3, [R8]
    STR R4, [R8, #PIO_BUFFER_INSTRUCTION_OFFSET]

    @ Delay antes de zerar o sinal de start da instrução
    MOV R5, #DELAY_LOOPS
    
delay_loop_buffer_send:
    SUBS R5, R5, #1
    BNE delay_loop_buffer_send

    @ Zera o start
    BIC R4, R4, #1
    STR R4, [R8, #PIO_BUFFER_INSTRUCTION_OFFSET]

    @ Aguarda a resposta do buffer
wait_response_buffer_send:
    LDR R5, [R8, #PIO_READY_SIGNALS_OFFSET]
    TST R5, #0b10
    BEQ wait_response_buffer_send

    MOV R0, #1 @ Retorno de sucesso
    POP {R4-R8, LR} @ Restaura registradores e retorna para o antigo LR
    BX LR
.size operate_buffer_send, .-operate_buffer_send

@ Procedimento de iniciar operação com matriz
.global calculate_matriz
.type calculate_matriz, %function
calculate_matriz:
    PUSH {R4-R8, LR} @Salva os registradores que devem ser preservados e o Registrador de retorno (LR)

    @ Concatena os argumentos em uma única instrução
    MOV R4, #0
    LSL R4, R0, #3 		@ Opcode[5:3]
    ORR R4, R4, R1, LSL #1 	@ Tamanho_matriz[2:1]
    ORR R4, R4, R2		@ Start[0]      

    @ Escreve no PIO de instrução do coprocessador
    STR R4, [R8, #PIO_COPROCESSOR_INSTRUCTION_OFFSET]

    @Delay antes de zerar o bit de start
    MOV R5, #DELAY_LOOPS
delay_loop_coprocessor:
    SUBS R5, R5, #1
    BNE delay_loop_coprocessor

    @ Zera o start
    BIC R4, R4, #1
    STR R4, [R8, #PIO_COPROCESSOR_INSTRUCTION_OFFSET]

    @ Aguarda resposta do coprocessador
wait_coprocessor:
    LDR R5, [R8, #PIO_READY_SIGNALS_OFFSET]
    TST R5, #0b01 
    BEQ wait_coprocessor

    MOV R0, #1 @ Retorno de sucesso
    POP {R4-R8, LR} @ Restaura registradores e retorna para o antigo LR
    BX LR

.size calculate_matriz, .-calculate_matriz

@ Procedimentos de recebimento de dados
.global operate_buffer_receive
.type operate_buffer_receive, %function
operate_buffer_receive:
    PUSH {R4-R8, LR} @ Salva os registradores que devem ser preservados e o Registrador de retorno (LR)

    @ Concatena os argumentos em uma única instrução
    MOV R4, #0
    LSL R4, R0, #4 		@ Opcode[5:4]
    ORR R4, R4, R1, LSL #1 	@ Position[3:1]
    ORR R4, R4, R2		@ Start[0]

    @ Escreve nos PIOs de instrução do buffer
    STR R4, [R8, #PIO_BUFFER_INSTRUCTION_OFFSET]

    @ Delay antes de zerar o sinal de start da instrução
    MOV R5, #DELAY_LOOPS
delay_loop_buffer_receive:
    SUBS R5, R5, #1
    BNE delay_loop_buffer_receive

    @ Zera o start
    BIC R4, R4, #1
    STR R4, [R8, #PIO_BUFFER_INSTRUCTION_OFFSET]

    @ Aguarda a resposta do buffer
wait_response_buffer_receive:
    LDR R5, [R8, #PIO_READY_SIGNALS_OFFSET]
    TST R5, #0b10
    BEQ wait_response_buffer_receive
    
    @ Retorna o pacote de 32 bits
    LDR R0, [R8, #PIO_DATA_OUT_OFFSET]
    POP {R4-R8, LR} @ Restaura registradores e retorna para o antigo LR
    BX LR
.size operate_buffer_receive, .-operate_buffer_receive