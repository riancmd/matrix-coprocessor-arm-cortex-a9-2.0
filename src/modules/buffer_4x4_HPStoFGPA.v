module buffer_4x4_HPStoFGPA(
	input [199:0] matrix1_in, matrix2_in, //Matrizes vindo sem organização
	output [199:0] matrix1_out, matrix2_out //Matrizes organizadas com base no tamanho
);
	
	//Organizando a matriz 1
	assign matrix1_out[199:168] = matrix1_in[199:168];
	assign matrix1_out[159:128] = matrix1_in[167:136];
	assign matrix1_out[119:88] = matrix1_in[135:104];
	assign matrix1_out[79:48] = matrix1_in[103:72];
	
	assign matrix1_out[167:160] = 0;
	assign matrix1_out[127:120] = 0;
	assign matrix1_out[87:80] = 0;
	assign matrix1_out[47:0] = 0;
	
	//Organizando a matriz 2
	assign matrix2_out[199:168] = matrix2_in[199:168];
	assign matrix2_out[159:128] = matrix2_in[167:136];
	assign matrix2_out[119:88] = matrix2_in[135:104];
	assign matrix2_out[79:48] = matrix2_in[103:72];
	
	assign matrix2_out[167:160] = 0;
	assign matrix2_out[127:120] = 0;
	assign matrix2_out[87:80] = 0;
	assign matrix2_out[47:0] = 0;
	
endmodule