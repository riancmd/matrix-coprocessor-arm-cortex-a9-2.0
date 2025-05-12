@ Código Assembly ARMv7 para DE1-SoC
@ Comunicação com FPGA via PIOs:
@ - PIO1 (Output): 0x0000 (17 bits: bit 16 = start, bits [15:8] = num1, bits [7:0] = num2)
@ - PIO2 (Input): 0x0010 (9 bits: bit 8 = ready, bits [7:0] = resultado)

@ Definições de endereços
.equ HPS_TO_FPGA_BASE, 0xFF200000  @ Endereço base do bridge HPS-to-FPGA
.equ PIO_OUTPUT_OFFSET, 0x0000     @ Offset do PIO de saída (HPS->FPGA)
.equ PIO_INPUT_OFFSET, 0x0010      @ Offset do PIO de entrada (FPGA->HPS)

@ Constantes para chamadas de sistema
.equ SYSCALL_EXIT,  1
.equ SYSCALL_READ,  3
.equ SYSCALL_WRITE, 4
.equ STDIN,         0
.equ STDOUT,        1

.data
menu_text:
    .asciz "\nMenu:\n1 - Somar dois numeros\n0 - Sair\nEscolha: "
num1_prompt:
    .asciz "\nDigite o primeiro numero (0-255): "
num2_prompt:
    .asciz "Digite o segundo numero (0-255): "
result_text:
    .asciz "\nResultado recebido da FPGA: "
error_text:
    .asciz "\nErro: Numero invalido! Deve ser entre 0 e 255\n"
newline:
    .asciz "\n"
input_buffer:
    .space 16
result_buffer:
    .space 16

.text
.global _start

_start:
    @ Configura ponte AXI
    ldr r8, =HPS_TO_FPGA_BASE     @ Endereço base
    add r9, r8, #PIO_INPUT_OFFSET @ Endereço do PIO de entrada

menu_loop:
    @ Exibe menu
    ldr r1, =menu_text
    bl print_string

    @ Lê escolha do usuário
    ldr r1, =input_buffer
    mov r2, #2
    bl read_input

    ldrb r0, [r1]
    cmp r0, #'1'
    beq op_soma
    cmp r0, #'0'
    beq exit_program
    b menu_loop

op_soma:
    @ Pede primeiro número
    ldr r1, =num1_prompt
    bl print_string
    ldr r1, =input_buffer
    mov r2, #16
    bl read_input
    bl ascii_to_int
    cmp r0, #0
    blt invalid_input
    cmp r0, #255
    bgt invalid_input
    mov r4, r0                  @ Armazena num1

    @ Pede segundo número
    ldr r1, =num2_prompt
    bl print_string
    ldr r1, =input_buffer
    mov r2, #16
    bl read_input
    bl ascii_to_int
    cmp r0, #0
    blt invalid_input
    cmp r0, #255
    bgt invalid_input
    mov r5, r0                  @ Armazena num2

    @ Prepara dados para FPGA (17 bits):
    @ bit[16] = start, bits[15:8] = num1, bits[7:0] = num2
    lsl r4, r4, #8              @ num1 -> bits[15:8]
    orr r4, r4, r5              @ num2 -> bits[7:0]
    orr r4, r4, #(1 << 16)      @ Ativa bit de start

    @ Envia para FPGA
    str r4, [r8, #PIO_OUTPUT_OFFSET]

    @ Aguarda resultado
wait_ready:
    ldr r6, [r9]                @ Lê PIO de entrada
    tst r6, #(1 << 8)           @ Verifica bit ready
    beq wait_ready

    @ Obtém resultado (bits[7:0])
    and r0, r6, #0xFF

    @ Exibe resultado
    ldr r1, =result_text
    bl print_string
    
    ldr r1, =result_buffer
    bl int_to_ascii
    ldr r1, =result_buffer
    bl print_string
    
    ldr r1, =newline
    bl print_string

    b menu_loop

invalid_input:
    ldr r1, =error_text
    bl print_string
    b menu_loop

exit_program:
    mov r7, #SYSCALL_EXIT
    mov r0, #0
    swi 0

@ ----------------------------
@ Função: print_string
@ Entrada: r1 = endereço da string
@ ----------------------------
print_string:
    push {r0, r2, r7, lr}
    mov r0, #STDOUT
    mov r2, #0
count_length:
    ldrb r3, [r1, r2]
    cmp r3, #0
    addne r2, r2, #1
    bne count_length
    mov r7, #SYSCALL_WRITE
    swi 0
    pop {r0, r2, r7, pc}

@ ----------------------------
@ Função: read_input
@ Entrada: r1 = buffer, r2 = tamanho
@ ----------------------------
read_input:
    push {r0, r7, lr}
    mov r0, #STDIN
    mov r7, #SYSCALL_READ
    swi 0
    pop {r0, r7, pc}

@ ----------------------------
@ Função: ascii_to_int
@ Entrada: r1 = string ASCII
@ Saída: r0 = valor inteiro
@ ----------------------------
ascii_to_int:
    push {r1-r4, lr}
    mov r0, #0
    mov r2, #0
    mov r4, #10
convert_loop:
    ldrb r3, [r1, r2]
    cmp r3, #0xA        @ Newline
    beq convert_done
    cmp r3, #0xD        @ Carriage return
    beq convert_done
    sub r3, r3, #'0'
    mul r0, r0, r4
    add r0, r0, r3
    add r2, r2, #1
    b convert_loop
convert_done:
    pop {r1-r4, pc}

@ ----------------------------
@ Função: int_to_ascii
@ Entrada: r0 = número, r1 = buffer
@ ----------------------------
int_to_ascii:
    push {r0-r5, lr}
    mov r2, #10
    mov r3, #0
    mov r4, r1
    cmp r0, #0
    bne convert_digits
    mov r2, #'0'
    strb r2, [r1]
    mov r2, #0
    strb r2, [r1, #1]
    b conversion_done
convert_digits:
    mov r2, #10
    bl divide
    add r1, r1, #'0'
    strb r1, [r4, r3]
    add r3, r3, #1
    cmp r0, #0
    bne convert_digits
    mov r2, #0
    strb r2, [r4, r3]
    sub r3, r3, #1
    mov r0, r4
reverse_loop:
    cmp r0, r4, r3
    bge conversion_done
    ldrb r2, [r0]
    ldrb r5, [r4, r3]
    strb r5, [r0]
    strb r2, [r4, r3]
    add r0, r0, #1
    sub r3, r3, #1
    b reverse_loop
conversion_done:
    pop {r0-r5, pc}

@ ----------------------------
@ Função: divide
@ Entrada: r0 = dividendo
@ Saída: r0 = quociente, r1 = resto
@ ----------------------------
divide:
    push {r2}
    mov r1, #0
    mov r2, #10
divide_loop:
    cmp r0, r2
    blt divide_done
    sub r0, r0, r2
    add r1, r1, #1
    b divide_loop
divide_done:
    mov r2, r0
    mov r0, r1
    mov r1, r2
    pop {r2}
    bx lr

.end