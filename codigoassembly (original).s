@ Código Assembly ARMv7 para DE1-SoC
@ Menu com duas opções:
@   1 - Soma de dois números (comunicação com FPGA via AXI)
@   0 - Sair do programa

@ Definições de endereços
.equ AXI_BASE,      0xFF200      @ Endereço base do barramento AXI
.equ AXI_DATA_REG,  0x00            @ Offset para registro de dados
.equ AXI_STATUS_REG, 0x04           @ Offset para registro de status
.equ AXI_READY_BIT, 0x01            @ Bit de pronto no registro de status

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
    .asciz "\nDigite o primeiro numero: "
num2_prompt:
    .asciz "Digite o segundo numero: "
result_text:
    .asciz "\nResultado recebido da FPGA: "
newline:
    .asciz "\n"
input_buffer:
    .space 16
result_buffer:
    .space 16

.text
.global _start

_start:
    @ Configuração inicial
    ldr r8, =AXI_BASE           @ Carrega endereço base AXI em r8

menu_loop:
    @ Exibe o menu
    ldr r1, =menu_text
    bl print_string

    @ Lê a escolha do usuário
    ldr r1, =input_buffer
    mov r2, #2                  @ Lê até 2 caracteres (opção + \n)
    bl read_input

    ldrb r0, [r1]               @ Carrega o primeiro caractere digitado
    cmp r0, #'1'
    beq op_soma                 @ Se opção 1, vai para soma
    cmp r0, #'0'
    beq exit_program            @ Se opção 0, sai do programa
    b menu_loop                 @ Se outra coisa, repete o menu

op_soma:
    @ Pede o primeiro número
    ldr r1, =num1_prompt
    bl print_string
    ldr r1, =input_buffer
    mov r2, #16
    bl read_input
    bl ascii_to_int             @ Converte para inteiro em r0
    mov r4, r0                  @ Salva primeiro número em r4

    @ Pede o segundo número
    ldr r1, =num2_prompt
    bl print_string
    ldr r1, =input_buffer
    mov r2, #16
    bl read_input
    bl ascii_to_int             @ Converte para inteiro em r0
    mov r5, r0                  @ Salva segundo número em r5

    @ Envia números para FPGA via AXI
    str r4, [r8, #AXI_DATA_REG] @ Envia primeiro número
    str r5, [r8, #AXI_DATA_REG] @ Envia segundo número

    @ Espera resposta da FPGA
wait_response:
    ldr r6, [r8, #AXI_STATUS_REG]
    tst r6, #AXI_READY_BIT      @ Verifica bit de pronto
    beq wait_response

    @ Lê resultado da FPGA
    ldr r6, [r8, #AXI_DATA_REG] @ Lê resultado

    @ Exibe resultado
    ldr r1, =result_text
    bl print_string
    mov r0, r6
    ldr r1, =result_buffer
    bl int_to_ascii             @ Converte resultado para ASCII
    bl print_string
    ldr r1, =newline
    bl print_string

    b menu_loop                 @ Volta para o menu

exit_program:
    @ Sai do programa
    mov r7, #SYSCALL_EXIT
    mov r0, #0
    swi 0

@ Função para imprimir string
@ Entrada: r1 = endereço da string
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

@ Função para ler entrada do teclado
@ Entrada: r1 = buffer, r2 = tamanho máximo
read_input:
    push {r0, r7, lr}
    mov r0, #STDIN
    mov r7, #SYSCALL_READ
    swi 0
    pop {r0, r7, pc}

@ Função para converter ASCII para inteiro
@ Entrada: r1 = endereço da string ASCII
@ Saída: r0 = valor inteiro
ascii_to_int:
    push {r1, r2, r3, lr}
    mov r0, #0
    mov r2, #0
convert_loop:
    ldrb r3, [r1, r2]
    cmp r3, #0xA                @ Verifica newline
    beq convert_done
    cmp r3, #0xD                @ Verifica carriage return
    beq convert_done
    sub r3, r3, #'0'            @ Converte ASCII para dígito
    mov r0, r0, lsl #3          @ r0 = r0 * 8
    add r0, r0, r0, lsl #1      @ r0 = r0 + (r0 * 2) = r0 * 10
    add r0, r0, r3              @ Adiciona dígito
    add r2, r2, #1
    b convert_loop
convert_done:
    pop {r1, r2, r3, pc}

@ Função para converter inteiro para ASCII
@ Entrada: r0 = valor inteiro, r1 = endereço do buffer
@ Saída: buffer preenchido com string ASCII
int_to_ascii:
    push {r0, r2, r3, r4, lr}
    mov r2, #10
    mov r3, #0
    mov r4, r1
    @ Primeiro conta os dígitos
count_digits:
    add r3, r3, #1
    mov r1, r0
    bl divide
    cmp r0, #0
    bne count_digits
    @ Agora converte
    mov r0, r4
    add r0, r0, r3
    mov r1, #0
    strb r1, [r0]               @ Terminador nulo
    sub r0, r0, #1
    mov r1, r4                  @ Salva valor original
    mov r4, r0                  @ r4 aponta para o final do buffer
    mov r0, r1                  @ Restaura valor
convert_digits:
    mov r1, r0
    bl divide
    add r1, r1, #'0'            @ Converte resto para ASCII
    strb r1, [r4]               @ Armazena dígito
    sub r4, r4, #1              @ Move ponteiro para trás
    cmp r0, #0
    bne convert_digits
    pop {r0, r2, r3, r4, pc}

@ Função de divisão por 10
@ Entrada: r0 = dividendo
@ Saída: r0 = quociente, r1 = resto
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