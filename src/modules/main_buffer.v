module main_buffer(
	input clk, rst, //Sinai de clock e reset
	input [31:0] package_data_in, //Pacote de dados em 32 bits do HPS-FPGA
	input [5:0] buffer_instruction, //Instruçao de store ou load para os dados alocados em pacotes
	input [5:0] coprocessor_instruction, //Instruçao do operaçao o coprocessador
	output reg [31:0] package_data_out, //Pacote de dados de 32 bits do FPGA-HPS
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
	
	//Definição dos códigos das posições dos registradores de dados
	localparam OFFSET0 = 3'b000;
	localparam OFFSET1 = 3'b001;
	localparam OFFSET2 = 3'b010;
	localparam OFFSET3 = 3'b011;
	localparam OFFSET4 = 3'b100;
	localparam OFFSET5 = 3'b101;
	localparam OFFSET6 = 3'b110;
	
	
	//Registradores para armazenar os dados decodificados das instruções do buffer
	reg [1:0] opcode_buffer;
	reg [2:0] register_position;
	
	//Registradores para armazenar os dados das matrizes
	reg [199:0] matrix1_reg, matrix2_reg, matrixresult_reg;
	
	//Fios de saida do coprocessador
	wire [199:0] matrixresult_reg_wire;
	wire coprocessor_ready_wire;
	
	//Ligar o registrador coprocessor_ready de saida do modulo do buffer para a saida de ready do coprocessador
	always @(*) begin
		coprocessor_ready = coprocessor_ready_wire;
	end
	
	//Instancia do coprocessador
	control_unit coprocessor(
		.matrix1(matrix1_reg),
		.matrix2(matrix2_reg),
		.instruction(coprocessor_instruction[5:1]),
		.clk(clk),
		.rst(rst),
		.matrix_result(matrixresult_reg_wire),
		.ready(coprocessor_ready_wire),
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
						buffer_ready = 1;
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
							case (register_position)
								OFFSET0: begin
									matrix1_reg[199:168] = package_data_in;
								end
								
								OFFSET1: begin
									matrix1_reg[167:136] = package_data_in;
								end
								
								OFFSET2: begin
									matrix1_reg[135:104] = package_data_in;
								end
								
								OFFSET3: begin
									matrix1_reg[103:72] = package_data_in;
								end
								
								OFFSET4: begin
									matrix1_reg[71:40] = package_data_in;
								end
								
								OFFSET5: begin
									matrix1_reg[39:8] = package_data_in;
								end
								
								OFFSET6: begin
									matrix1_reg[7:0] = package_data_in;
								end
								
								default: begin
									matrix1_reg = 0;
								end
							endcase
						end
						
						//Armazenar valores da matriz 2 na posiçao especificada
						STORE_MATRIX2: begin
							case (register_position)
								OFFSET0: begin
									matrix2_reg[199:168] = package_data_in;
								end
								
								OFFSET1: begin
									matrix2_reg[167:136] = package_data_in;
								end
								
								OFFSET2: begin
									matrix2_reg[135:104] = package_data_in;
								end
								
								OFFSET3: begin
									matrix2_reg[103:72] = package_data_in;
								end
								
								OFFSET4: begin
									matrix2_reg[71:40] = package_data_in;
								end
								
								OFFSET5: begin
									matrix2_reg[39:8] = package_data_in;
								end
								
								OFFSET6: begin
									matrix2_reg[7:0] = package_data_in;
								end
								
								default: begin
									matrix2_reg = 0;
								end
							endcase
						end
						
						//Ler valores da matriz resultado da posiçao especificada
						LOAD_MATRIXRESULT: begin
							case (register_position)
								OFFSET0: begin
									package_data_out = matrixresult_reg_wire[199:168];
								end
								
								OFFSET1: begin
									package_data_out = matrixresult_reg_wire[167:136];
								end
								
								OFFSET2: begin
									package_data_out = matrixresult_reg_wire[135:104];
								end
								
								OFFSET3: begin
									package_data_out = matrixresult_reg_wire[103:72];
								end
								
								OFFSET4: begin
									package_data_out = matrixresult_reg_wire[71:40];
								end
								
								OFFSET5: begin
									package_data_out = matrixresult_reg_wire[39:8];
								end
								
								OFFSET6: begin
									package_data_out[31:24] = matrixresult_reg_wire[7:0];
									package_data_out[23:0] = 0;
								end
								
								default: begin
									package_data_out = 0;
								end
							endcase
						end
						
						default: begin
							buffer_ready = 0;
						end
					endcase
					
					state = FINISHED;
				end
				
				//Estado de termino da operaçao do buffer
				FINISHED: begin
					state = IDLE;
				end
				
				default: begin
					state = IDLE;
				end
			endcase
		end
	end
	
endmodule