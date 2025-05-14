module main_buffer(
	input clk, rst, //Sinai de clock e reset
	input [31:0] package_data_in, //Pacote de dados em 32 bits do HPS-FPGA
	input [5:0] buffer_instruction, //Instruçao de store ou load para os dados alocados em pacotes
	input [5:0] coprocessor_instruction, //Instruçao do operaçao o coprocessador
	output [31:0] package_data_out, //Pacote de dados de 32 bits do FPGA-HPS
	output reg buffer_ready, coprocessor_ready, //Sinal de termino da operaçao do buffer e da operaçao do coprocessador, respectivamente
	output overflow //Sinal de overflow
);

	//Definiçao dos estados da maquina de estados do buffer
	localparam IDLE = 2'b00;
	localparam FETCH_DECODE = 2'b01;
	localparam EXECUTE = 2'b10;
	localparam FINISHED = 2'b11;
	
	reg [1:0] state;
	
	//Definição dos códigos do OPCODE do buffer
	localparam STORE_MATRIX1 = 2'b00;
	localparam STORE_MATRIX2 = 2'b01;
	localparam LOAD_MATRIXRESULT = 2'b10;
	
	/*//Definição dos códigos das posições dos registradores de dados
	localparam OFFSET0 = 3'b000;
	localparam OFFSET1 = 3'b001;
	localparam OFFSET2 = 3'b010;
	localparam OFFSET3 = 3'b011;
	localparam OFFSET4 = 3'b100;
	localparam OFFSET5 = 3'b101;
	localparam OFFSET6 = 3'b110;
	*/
	
	//Registradores para armazenar os dados decodificados das instruções do buffer
	reg [1:0] opcode_buffer;
	reg [2:0] register_position;
	
	//Registradores para armazenar os dados das matrizes
	reg [199:0] matrix1_reg, matrix2_reg, matrixresult_reg;
	
	//Instancia do coprocessador
	control_unit coprocessor(
		.matrix1(matrix1_reg),
		.matrix2(matrix2_reg),
		.instruction(coprocessor_instruction[5:1]),
		.clk(clk),
		.rst(rst),
		.matrix_result(matrixresult_reg),
		.ready(coprocessor_ready),
		.overflow_wire(overflow),
		.start(coprocessor_instruction[0])
	);
	
	//Máquina de estados
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			state = IDLE;
			opcode_buffer = 0;
			register_position = 0;
			matrix1_reg = 0;
			matrix2_reg = 0;
			matrixresult_reg = 0;
			buffer_ready = 0;
			coprocessor_ready = 0;
		end
		else begin
			case (state)
				//Estado inicial IDLE, sendo um estado de espera para uma nova operação
				IDLE: begin
					if (buffer_instruction[0]) begin
						buffer_ready = 0;
						state = FETCH_DECODE;
					end
					else begin
						state = IDLE;
					end
				end
				
				//Estado FETCH_DECODE para receber as intruções 
				FETCH_DECODE: begin
					opcode_buffer = buffer_instruction[5:4];
					register_position = buffer_instruction[3:1];
					state = EXECUTE;
				end
				
				//Estado de execução da instrução do buffer
				EXECUTE: begin
					case (opcode_buffer) 
						//Armazenar valores da matriz 1 na posiçao especificada
						STORE_MATRIX1: begin
							if (register_position < 6) begin
								matrix1_reg[199 - 32*register_position : 168 - 32*register_position] = package_data_in;
							end
							else begin
								matrix1_reg[7:0] = package_data_in[31:24];
							end
						end
						
						//Armazenar valores da matriz 2 na posiçao especificada
						STORE_MATRIX2: begin
							if (register_position < 6) begin
								matrix2_reg[199 - 32*register_position : 168 - 32*register_position] = package_data_in;
							end
							else begin
								matrix2_reg[7:0] = package_data_in[31:24];
							end
						end
						
						//Ler valores da matriz resultado da posiçao especificada
						LOAD_MATRIXRESULT: begin
							if (register_position < 6) begin
								package_data_out = matrixresult_reg[199 - 32*register_position : 168 - 32*register_position];
							end
							else begin
								package_data_out[31:24] = matrixresult_reg[7:0];
							end
						end
						
						default: begin
							buffer_ready = 1;
						end
					endcase
					
					state = FINISHED;
				end
				
				//Estado de termino da operaçao do buffer
				FINISHED: begin
					buffer_ready = 1;
					state = IDLE;
				end
				
				default: begin
					state = IDLE;
				end
			endcase
		end
	end
	
endmodule