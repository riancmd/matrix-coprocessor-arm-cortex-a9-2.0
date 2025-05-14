//Módulo de controle para leitura, decodificação, execução e escrita de dados
module control_unit(
	input [199:0] matrix1, matrix2, //Dados das 2 matrizes
	input [4:0] instruction, //Instrução requisitada (3 bits de op_code e 2 do tamanho da matriz)
	input clk, rst, start, //Sinal de clock, reset e início de uma nova operação
	output [199:0] matrix_result, //Matriz resultado da operação
	output reg ready, //Sinal para indicar que o resultado final está pronto
	output overflow_wire //Sinal de overflow da operação
);
		
	//Instância do divisor de clock
	clk_divider clk_divider(
		.clk_in(clk),
		.rst(rst),
		.clk_out(clk_coprocessor)
	);
	
	
	//Instâncias dos buffers para matriz 2x2, 3x3 e 4x4 do HPS-FPGA
	//Servem para organizar os dados vindo do buffer principal para o formato do coprocessador
	buffer_2x2_HPStoFGPA buffer_2x2_HPStoFGPA(
		.matrix1_in(matrix1),
		.matrix2_in(matrix2),
		.matrix1_out(matrix1_bff2x2),
		.matrix2_out(matrix2_bff2x2),

	);
	
	
	buffer_3x3_HPStoFGPA buffer_3x3_HPStoFGPA(
		.matrix1_in(matrix1),
		.matrix2_in(matrix2),
		.matrix1_out(matrix1_bff3x3),
		.matrix2_out(matrix2_bff3x3),

	);
	
	
	buffer_4x4_HPStoFGPA buffer_4x4_HPStoFGPA(
		.matrix1_in(matrix1),
		.matrix2_in(matrix2),
		.matrix1_out(matrix1_bff4x4),
		.matrix2_out(matrix2_bff4x4),

	);
	
	
	//Instâncias dos buffers para matriz 2x2, 3x3 e 4x4 do FPGA-HPS
	//Servem para organizar os dados vindo do FPGA para o formato lido pelo HPS
	buffer_2x2_FPGAtoHPS buffer_2x2_FPGAtoHPS(
		.matrix_result_in(result_reg),
		.matrix_result_out(result_bff2x2)
	);
	
	
	buffer_3x3_FPGAtoHPS buffer_3x3_FPGAtoHPS(
		.matrix_result_in(result_reg),
		.matrix_result_out(result_bff3x3)
	);
	
	
	buffer_4x4_FPGAtoHPS buffer_4x4_FPGAtoHPS(
		.matrix_result_in(result_reg),
		.matrix_result_out(result_bff4x4)
	);
		
	
	//Definição dos estados da máquina de estados
	localparam IDLE = 3'b000;
	localparam FETCH = 3'b001;
	localparam DECODE = 3'b010;
	localparam EXECUTE = 3'b011;
	localparam WRITEBACK = 3'b100;
	localparam CLN = 3'b101;

	reg [2:0] state;
	reg overflow;
	assign overflow_wire = overflow;
	
	//Definição dos códigos de operação
	localparam SOMA = 3'b000;
	localparam SUBTRACAO = 3'b001;
	localparam MULT_MATRIZ = 3'b010;
	localparam MULT_INT = 3'b011;
	localparam DETERMINANTE = 3'b100;
	localparam TRANSPOSTA = 3'b101;
	localparam OPOSTA = 3'b110;
	
	//Definição dos códigos para cada tamanho
	localparam M2 = 2'b00;
	localparam M3 = 2'b01;
	localparam M4 = 2'b10;
	localparam M5 = 2'b11;

	
	//Fios intermediários correspondentes às saídas dos módulos de operação
	//Soma
	wire [39:0] adder_result1, adder_result2, adder_result3, adder_result4, adder_result5; //Resultados da soma
	wire adder_ovf1, adder_ovf2, adder_ovf3, adder_ovf4, adder_ovf5; //Overflow da soma
	
	//Subtração
	wire [39:0] sub_result1, sub_result2, sub_result3, sub_result4, sub_result5; //Resultados da subtraçaõ
	wire sub_ovf1, sub_ovf2, sub_ovf3, sub_ovf4, sub_ovf5; //Overflow da subtraçaõ
	
	//Multiplicação entre matrizes
	wire [199:0] multMA_result; //Resultado da multiplicação entre matrizes
	wire multMA_ovf; //Overflow da multiplicação entre matrizes
	
	//Multiplicação por inteiro
	wire [39:0] multMI_result1, multMI_result2, multMI_result3, multMI_result4, multMI_result5; //Resultados da multiplicação por inteiro
	wire multMI_ovf1, multMI_ovf2, multMI_ovf3, multMI_ovf4, multMI_ovf5; //Overflow da multiplicação por inteiro
	
	//Determinante 2x2
	wire [7:0] det2x2_result; //Resultado da determinante 2x2
	wire det2x2_ovf; //Overflow da determinante 2x2
	
	//Determinante 3x3
	wire [7:0] det3x3_result; //Resultado da determinante 3x3
	wire det3x3_ovf; //Overflow da determinante 3x3
	
	//Determinante 4x4
	wire [7:0] det4x4_result; //Resultado da determinante 4x4
	wire det4x4_ovf; //Overflow da determinante 4x4
	
	//Determinante 5x5
	wire [7:0] det5x5_result; //Resultado da determinante 5x5
	wire det5x5_ovf; //Overflow da determinante 5x5
	
	//Transposta
	reg [39:0] trans_result1, trans_result2, trans_result3, trans_result4, trans_result5; //Resultados da Transposta
	
	//Oposta
	wire [39:0] opp_result1, opp_result2, opp_result3, opp_result4, opp_result5; //Resultados da oposta
	wire opp_ovf1, opp_ovf2, opp_ovf3, opp_ovf4, opp_ovf5; //Overflow da oposta caso exista elemento igual a -128
	
	
	//Colunas temporárias da multiplicaçao entre matrizes
	reg [39:0] m2_c0, m2_c1, m2_c2, m2_c3, m2_c4; //Primeira coluna até a última nessa ordem
	
	
	
	//Módulos responsáveis por operar os dados
	//Módulos de soma para cada linha
	add_M adderL1(matrix1_reg[199:160], matrix2_reg[199:160], rst, adder_result1, adder_ovf1);
	add_M adderL2(matrix1_reg[159:120], matrix2_reg[159:120], rst, adder_result2, adder_ovf2);
	add_M adderL3(matrix1_reg[119:80], matrix2_reg[119:80], rst, adder_result3, adder_ovf3);
	add_M adderL4(matrix1_reg[79:40], matrix2_reg[79:40], rst, adder_result4, adder_ovf4);
	add_M adderL5(matrix1_reg[39:0], matrix2_reg[39:0], rst, adder_result5, adder_ovf5);
	
	//Módulos de subtração para cada linha
	sub_M subtractorL1(matrix1_reg[199:160], matrix2_reg[199:160], rst, sub_result1, sub_ovf1);
	sub_M subtractorL2(matrix1_reg[159:120], matrix2_reg[159:120], rst, sub_result2, sub_ovf2);
	sub_M subtractorL3(matrix1_reg[119:80], matrix2_reg[119:80], rst, sub_result3, sub_ovf3);
	sub_M subtractorL4(matrix1_reg[79:40], matrix2_reg[79:40], rst, sub_result4, sub_ovf4);
	sub_M subtractorL5(matrix1_reg[39:0], matrix2_reg[39:0], rst, sub_result5, sub_ovf5);
	
	//Módulos de multiplicação entre matrizes para cada 2 linhas e 2 colunas 
	//Insere a matriz A inteira como input e a matriz B organizada em colunas
	mult_M multi_MA(matrix1_reg[199:0], {m2_c0, m2_c1, m2_c2, m2_c3, m2_c4}, rst, multMA_result, multMA_ovf);
	
	//Módulos de multiplicação por inteiro para cada linha
	mult_MI multi_MIL1(matrix1_reg[199:160], matrix2_reg[7:0], rst, multMI_result1, multMI_ovf1);
	mult_MI multi_MIL2(matrix1_reg[159:120], matrix2_reg[7:0], rst, multMI_result2, multMI_ovf2);
	mult_MI multi_MIL3(matrix1_reg[119:80], matrix2_reg[7:0], rst, multMI_result3, multMI_ovf3);
	mult_MI multi_MIL4(matrix1_reg[79:40], matrix2_reg[7:0], rst, multMI_result4, multMI_ovf4);
	mult_MI multi_MIL5(matrix1_reg[39:0], matrix2_reg[7:0], rst, multMI_result5, multMI_ovf5);
	
	//Módulo de determinante 2x2
	det2 determinant2x2(matrix1_reg[199:184], matrix1_reg[159:144], rst, det2x2_result, det2x2_ovf);
	
	//Modulo de determinante 3x3
	det3 determinant3x3({matrix1_reg[199:176], matrix1_reg[159:136], matrix1_reg[119:96]}, rst, det3x3_result, det3x3_ovf);
	
	//Modulo de determinante 4x4
	det4 determinant4x4({matrix1_reg[199:168], matrix1_reg[159:128], matrix1_reg[119:88], matrix1_reg[79:48]}, rst, det4x4_result, det4x4_ovf);
	
	//Modulo de determinante 5x5
	det5 determinant5x5({matrix1_reg[199:160], matrix1_reg[159:120], matrix1_reg[119:80], matrix1_reg[79:40], matrix1_reg[39:0]}, rst, det5x5_result, det5x5_ovf);
	
	//Modulos de oposta para cada linha
	opp_M oppL1(matrix1_reg[199:160], rst, opp_result1, opp_ovf1);
	opp_M oppL2(matrix1_reg[159:120], rst, opp_result2, opp_ovf2);
	opp_M oppL3(matrix1_reg[119:80], rst, opp_result3, opp_ovf3);
	opp_M oppL4(matrix1_reg[79:40], rst, opp_result4, opp_ovf4);
	opp_M oppL5(matrix1_reg[39:0], rst, opp_result5, opp_ovf5);
	
	//Transposiçao da matriz
	always @(*) begin
		trans_result1[39:32] = matrix1_reg[199:192];
		trans_result1[31:24] = matrix1_reg[159:152];
		trans_result1[23:16] = matrix1_reg[119:112];
		trans_result1[15:8] = matrix1_reg[79:72];
		trans_result1[7:0] = matrix1_reg[39:32];
		
		trans_result2[39:32] = matrix1_reg[191:184];
		trans_result2[31:24] = matrix1_reg[151:144];
		trans_result2[23:16] = matrix1_reg[111:104];
		trans_result2[15:8] = matrix1_reg[71:64];
		trans_result2[7:0] = matrix1_reg[31:24];
		
		trans_result3[39:32] = matrix1_reg[183:176];
		trans_result3[31:24] = matrix1_reg[143:136];
		trans_result3[23:16] = matrix1_reg[103:96];
		trans_result3[15:8] = matrix1_reg[63:56];
		trans_result3[7:0] = matrix1_reg[23:16];
		
		trans_result4[39:32] = matrix1_reg[175:168];
		trans_result4[31:24] = matrix1_reg[135:128];
		trans_result4[23:16] = matrix1_reg[95:88];
		trans_result4[15:8] = matrix1_reg[55:38];
		trans_result4[7:0] = matrix1_reg[15:8];
		
		trans_result5[39:32] = matrix1_reg[167:160];
		trans_result5[31:24] = matrix1_reg[127:120];
		trans_result5[23:16] = matrix1_reg[87:80];
		trans_result5[15:8] = matrix1_reg[37:30];
		trans_result5[7:0] = matrix1_reg[7:0];
	end
	
	//Cria colunas de m2
	always@(*) begin
		m2_c0 = {matrix2_reg[199:192], matrix2_reg[159:152], matrix2_reg[119:112], matrix2_reg[79:72], matrix2_reg[39:32]};
		m2_c1 = {matrix2_reg[191:184], matrix2_reg[151:144], matrix2_reg[111:104], matrix2_reg[71:64], matrix2_reg[31:24]};
		m2_c2 = {matrix2_reg[183:176], matrix2_reg[143:136], matrix2_reg[103:96], matrix2_reg[63:56], matrix2_reg[23:16]};
		m2_c3 = {matrix2_reg[175:168], matrix1_reg[135:128], matrix2_reg[95:88], matrix2_reg[55:48], matrix2_reg[15:8]};
		m2_c4 = {matrix2_reg[167:160], matrix2_reg[127:120], matrix2_reg[87:80], matrix2_reg[47:40], matrix2_reg[7:0]};
	end
	
	
	
	//Registradores intermediários
	reg [1:0] msize_reg;
	reg [2:0] opcode_reg;
	reg [199:0] matrix1_reg, matrix2_reg;
	reg [199:0] result_reg;
	reg operation_active;

	always @(posedge clk_coprocessor or posedge rst) begin
		if (rst) begin
			state = IDLE;
			msize_reg = 0;
			opcode_reg = 0;
			matrix1_reg = 0;
			matrix2_reg = 0;
			result_reg = 0;
			overflow = 0;
			ready = 0;
			operation_active = 0;
		end 
		else begin
			case (state)
				//Estado inicial IDLE, sendo um estado de espera para uma nova operação
				IDLE: begin
					if (start && !operation_active) begin
						operation_active = 1;
						ready = 0;
						state = FETCH;
					end
					else begin
						state = IDLE;
					end
				end
				
				//Estado FETCH para receber as intruções e os dados do buffer
				FETCH: begin
					msize_reg = instruction[1:0];
					opcode_reg = instruction[4:2];
					state = DECODE;
				end
				
				//Estado de decodificação do buffer
				DECODE: begin
					case (msize_reg) //Decodificando o tamanho
						M2: begin //Matriz 2x2
							matrix1_reg = matrix1_bff2x2;
							matrix2_reg = matrix2_bff2x2;
						end
						
						M3: begin //Matriz 3x3
							matrix1_reg = matrix1_bff3x3;
							matrix2_reg = matrix2_bff3x3;
						end
						
						M4: begin //Matriz 4x4
							matrix1_reg = matrix1_bff4x4;
							matrix2_reg = matrix2_bff4x4;
						end
						
						M5: begin //Matriz 5x5
							matrix1_reg = matrix1;
							matrix2_reg = matrix2;
						end
						
						default: begin
							matrix1_reg = 0;
							matrix2_reg = 0;
						end
					endcase
					
					state = EXECUTE;
				end
				
				//Estado de execução da operação
				EXECUTE: begin
					case (opcode_reg)
						SOMA: begin 
							result_reg[199:160] = adder_result1;
							result_reg[159:120] = adder_result2;
							result_reg[119:80] = adder_result3;
							result_reg[79:40] = adder_result4;
							result_reg[39:0] = adder_result5;
							overflow = adder_ovf1 || adder_ovf2 || adder_ovf3 || adder_ovf4 || adder_ovf5;
						end
						
						SUBTRACAO: begin
							result_reg[199:160] = sub_result1;
							result_reg[159:120] = sub_result2;
							result_reg[119:80] = sub_result3;
							result_reg[79:40] = sub_result4;
							result_reg[39:0] = sub_result5;
							overflow = sub_ovf1 || sub_ovf2 || sub_ovf3 || sub_ovf4 || sub_ovf5;
						end
						
						MULT_MATRIZ: begin
							result_reg[199:0] = multMA_result;
							overflow = multMA_ovf;
						end
						
						MULT_INT: begin
							result_reg[199:160] = multMI_result1;
							result_reg[159:120] = multMI_result2;
							result_reg[119:80] = multMI_result3;
							result_reg[79:40] = multMI_result4;
							result_reg[39:0] = multMI_result5;
							overflow = multMI_ovf1 || multMI_ovf2 || multMI_ovf3 || multMI_ovf4 || multMI_ovf5;
						end
						
						DETERMINANTE: begin
							//Matriz 2x2
							if (msize_reg == 0) begin
								result_reg = det2x2_result;
								overflow = det2x2_ovf;
							end
							//Matriz 3x3
							else if (msize_reg == 1) begin
								result_reg = det3x3_result;
								overflow = det3x3_ovf;
							end
							//Matriz 4x4
							else if (msize_reg == 2) begin
								result_reg = det4x4_result;
								overflow = det4x4_ovf;
							end
							//Matriz 5x5
							else begin
								result_reg = det5x5_result;
								overflow = det5x5_ovf;
							end
						end
						
						TRANSPOSTA: begin
							result_reg[199:160] = trans_result1;
							result_reg[159:120] = trans_result2;
							result_reg[119:80] = trans_result3;
							result_reg[79:40] = trans_result4;
							result_reg[39:0] = trans_result5;
						end
					
						OPOSTA: begin
							result_reg[199:160] = opp_result1;
							result_reg[159:120] = opp_result2;
							result_reg[119:80] = opp_result3;
							result_reg[79:40] = opp_result4;
							result_reg[39:0] = opp_result5;
							overflow = opp_ovf1 || opp_ovf2 || opp_ovf3 || opp_ovf4 || opp_ovf5;
						end
					
						default: begin
							result_reg = 0;
						end
						
					endcase
					
					if(counter_det == 0) begin
						state = WRITEBACK;
					end
					else begin
						counter_det = counter_det + 1;
					end
				end
				
				//Estado de sáida dos dados para o buffer principal
				WRITEBACK: begin
					case (msize_reg) //Decodificando o tamanho
						M2: begin //Matriz 2x2
							matrix_result = result_bff2x2;
						end
						
						M3: begin //Matriz 3x3
							matrix_result = result_bff3x3;
						end
						
						M4: begin //Matriz 4x4
							matrix_result = result_bff4x4;
						end
						
						M5: begin //Matriz 5x5
							matrix_result = result_reg;
						end
						
						default: begin
							matrix_result = 0;
						end
					endcase
					
					ready = 1;
					operation_active = 0;
					state = CLN;
				end
				
				CLN: begin
					ready = 0;
					overflow = 0;
					msize_reg = 0;
					opcode_reg = 0;
					result_reg = 0;
					matrix1_reg = 0;
					matrix2_reg = 0;
					state = IDLE;					
				end
				
				default: begin
					if (start && !operation_active) begin
						operation_active = 1;
						ready = 0;
						state = FETCH;
					end
					else begin
						state = IDLE;
					end
				end
			endcase
		end
	end
endmodule
