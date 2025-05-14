module buffer_3x3_FPGAtoHPS(
	input [199:0] matrix_result_in, //Matriz resultado para ser organizada
	output [199:0] matrix_result_out //Matriz resultado organizada
);

	assign matrix_result_out[199:176] = matrix_result_in[199:176];
	assign matrix_result_out[175:152] = matrix_result_in[159:136];
	assign matrix_result_out[151:128] = matrix_result_in[119:96];
	assign matrix_result_out[127:0] = 0;
	
endmodule