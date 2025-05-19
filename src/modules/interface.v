//Módulo de interface como nível mais alto para as conexões
module interface(
	input clk, rst, start, //Mesmas entradas e saídas da unidade de controle,
	output ready, overflow,
	output [2:0] state,
	output [2:0] op_code_o
);

	wire rst_neg;
	assign rst_neg = !rst;
	
control_unit control(
	.clk(clk),
	.rst(rst_neg),
	.start(start),
	.ready(ready),
	.overflow_wire(overflow),
	.state_output(state),
	.op_code_o(op_code_o)
);

endmodule