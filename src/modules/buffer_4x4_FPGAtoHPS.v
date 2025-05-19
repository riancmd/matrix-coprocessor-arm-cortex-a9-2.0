module buffer_4x4_FPGAtoHPS(
	input [199:0] matrix_result_in, //Matriz resultado para ser organizada
	output [199:0] matrix_result_out //Matriz resultado organizada
);

	assign matrix_result_out[199:168] = matrix_result_in[199:168];
	assign matrix_result_out[167:136] = matrix_result_in[159:128];
	assign matrix_result_out[135:104] = matrix_result_in[119:88];
	assign matrix_result_out[103:72] = matrix_result_in[79:48];
	assign matrix_result_out[71:0] = 0;
	
endmodule