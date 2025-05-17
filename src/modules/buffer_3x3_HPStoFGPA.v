module buffer_3x3_HPStoFGPA(
	input [199:0] matrix1_in, matrix2_in, //Matrizes vindo sem organização
	output [199:0] matrix1_out, matrix2_out //Matrizes organizadas com base no tamanho
);
	
	//Organizando a matriz 1
	assign matrix1_out[199:176] = matrix1_in[199:176];
	assign matrix1_out[159:136] = matrix1_in[175:152];
	assign matrix1_out[119:96] = matrix1_in[151:128];
	
	assign matrix1_out[175:160] = 0;
	assign matrix1_out[135:120] = 0;
	assign matrix1_out[95:0] = 0;
	
	//Organizando a matriz 2
	assign matrix2_out[199:176] = matrix2_in[199:176];
	assign matrix2_out[159:136] = matrix2_in[175:152];
	assign matrix2_out[119:96] = matrix2_in[151:128];
	
	assign matrix2_out[175:160] = 0;
	assign matrix2_out[135:120] = 0;
	assign matrix2_out[95:0] = 0;
	
endmodule