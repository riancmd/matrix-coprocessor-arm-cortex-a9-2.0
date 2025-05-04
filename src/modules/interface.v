//Módulo de interface como nível mais alto para as conexões
module interface(
	input clk, rst, start, //Mesmas entradas e saídas da unidade de controle
	input clk_button,
	output ready, overflow,
	output [2:0] state,
	output [2:0] op_code_o
);

	wire rst_neg, clk_b_neg;
	assign rst_neg = !rst;
	assign clk_b_neg = !clk_button;
	
control_unit control(
	.clk(clk),
	.rst(rst_neg),
	.start(start),
	.clk_button(clk_b_neg),
	.ready(ready),
	.overflow_wire(overflow),
	.state_output(state),
	.op_code_o(op_code_o)
);

endmodule