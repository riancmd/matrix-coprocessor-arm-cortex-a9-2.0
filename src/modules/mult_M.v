//O módulo mult_M encontra 4 números por vez, recebendo duas linhas de M1 e duas colunas de M2
module mult_M(input signed [79:0] lin, col, //linhas da matriz 1, colunas da matriz 2
		input rst, //sinal de reset
		output signed [31:0] n_out, //resultado da mult
		output signed ovf); //overflow
		
		wire signed [7:0] n_11, n_12, n_21, n_22; //valores parciais dos produtos internos
		wire ovf1, ovf2, ovf3, ovf4;
		
		//ORDEM É A00, A01, A10, A11 (elementos da matriz)
		intProd_M intprod1 (lin[79:40], col[79:40], rst, n_11, ovf1);
		intProd_M intprod2 (lin[79:40], col[39:0], rst, n_12, ovf2);
		intProd_M intprod3 (lin[39:0], col[79:40], rst, n_21, ovf3);
		intProd_M intprod4 (lin[39:0], col[39:0], rst, n_22, ovf4);
		
		assign ovf = ovf1 || ovf2 || ovf3 || ovf4; //se houve overflow, sinalizar
		assign n_out = {n_11, n_12, n_21, n_22}; //concatena os quatro resultados
		
		
endmodule