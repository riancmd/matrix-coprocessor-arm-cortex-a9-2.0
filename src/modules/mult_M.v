//O módulo mult_M encontra 4 números por vez, recebendo duas linhas de M1 e duas colunas de M2
module mult_M(input signed [199:0] lin, col, //linhas da matriz 1, colunas da matriz 2
		input rst, //sinal de reset
		output signed [199:0] n_out, //resultado da mult
		output signed ovf); //overflow
		
		wire signed [7:0] n_11, n_12, n_13, n_14, n_15, 
						  n_21, n_22, n_23, n_24, n_25
						  n_31, n_32, n_33, n_34, n_35
						  n_41, n_42, n_43, n_44, n_45
						  n_51, n_52, n_53, n_54, n_55; //valores parciais dos produtos internos
		wire ovf1, ovf2, ovf3, ovf4, ovf5, 
			 ovf6, ovf7, ovf8, ovf9, ovf10, 
			 ovf11, ovf12, ovf13, ovf14, ovf15, 
			 ovf16, ovf17, ovf18, ovf19, ovf20, 
			 ovf21, ovf22, ovf23, ovf24, ovf25;
		
		//ORDEM É A00, A01, A10, A11 (elementos da matriz)
		intProd_M intprod1 (lin[79:40], col[79:40], rst, n_11, ovf1);
		
		
		assign ovf = ovf1 || ovf2 || ovf3 || ovf4; //se houve overflow, sinalizar
		assign n_out = {n_11, n_12, n_21, n_22}; //concatena os quatro resultados
		
		
endmodule