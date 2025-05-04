`timescale 1ns / 1ps

module testMultM();
    reg rst;
    reg signed [79:0] lin, col;  // 80 bits = 10 números de 8 bits
    wire signed [31:0] n_out;    // 32 bits = 4 números de 8 bits
    wire ovf;
    
    // Instância do módulo de multiplicação

    mult_M uut(
        .lin(lin),
        .col(col),
        .rst(rst),
        .n_out(n_out),
        .ovf(ovf)
    );
    
    
    // Gera sinal de reset
    initial begin
        $display("Inicia reset");
        rst = 1'b1;
        #10 rst = 1'b0;
    end
    
    // Testa os estímulos
    initial begin
        $display("Testa valores");
        $monitor("tempo=%3d, rst=%b, lin=%80b, col=%80b, n_out=%32b, ovf=%b", 
                 $time, rst, lin, col, n_out, ovf);
            
        #15; // Espera reset terminar
            
        // CASO 1: Valores pequenos positivos (sem overflow)
        // lin = [2,3,4,5,0,0,0,0,0,0] - apenas os 4 primeiros importam
        lin = 80'b00000010_00000011_00000100_00000101_00000000_00000000_00000000_00000000_00000000_00000000;
        // col = [3,0,4,0,0,0,0,0,0,0] 
        col = 80'b00000011_00000000_00000100_00000000_00000000_00000000_00000000_00000000_00000000_00000000;
        // n_out esperado:
        // 2*3=6 (00000110), 2*0=0 (00000000), 3*3=9 (00001001), 3*0=0 (00000000)
        // Resultado esperado: 00010110_00000000_00000000_00000000
        
        #20;
        
        // CASO 2: Valores pequenos com negativos (sem overflow)
        // lin = [2,-3,4,-5,0,0,0,0,0,0]
        lin = 80'b00000010_11111101_00000100_11111011_00000000_00000000_00000000_00000000_00000000_00000000;
        // col = [-3,0,4,0,0,0,0,0,0,0]
        col = 80'b11111101_00000000_00000100_00000000_00000000_00000000_00000000_00000000_00000000_00000000;
        // n_out esperado: a00 (elemento linha 0, coluna 0 da resultante) = 2 * (-3) + 4*4 = 10
        // Resultado esperado: 00001010_00000000_00000000_00000000
        
        #20;
        
        // CASO 3: Valores no limite (com overflow)
        // lin = [10,11,12,13,0,0,0,0,0,0]
        lin = 80'b00001010_00001011_00001100_00001101_00000000_00000000_00000000_00000000_00000000_00000000;
        // col = [10,0,11,0,0,0,0,0,0,0]
        col = 80'b00001010_00000000_00001011_00000000_00000000_00000000_00000000_00000000_00000000_00000000;
        // n_out esperado:
        // 10*10=100 (01100100), 10*0=0, 11*10=110 (01101110), 11*0=0
        // Resultado esperado: 11101000_00000000_00000000_00000000
    end
endmodule