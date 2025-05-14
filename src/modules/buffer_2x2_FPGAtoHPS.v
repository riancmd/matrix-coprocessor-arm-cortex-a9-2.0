module buffer_2x2_FPGAtoHPS(
	input [199:0] matrix_result_in, //Matriz resultado para ser organizada
	output [199:0] matrix_result_out //Matriz resultado organizada
);

	assign matrix_result_out[199:184] = matrix_result_in[199:184];
	assign matrix_result_out[183:168] = matrix_result_in[159:144];
	assign matrix_result_out[167:0] = 0;
	
endmodule