module clk_divider(
	input wire clk_in, //Clock de entrada da placa
	input wire rst, //Sinal de reset
	output reg clk_out //Clock de saída
);

	reg [3:0] counter; //Contador para trocar sinal de saída após 16 ciclos

	always @(posedge clk_in or posedge rst) begin
		if (rst) begin
			counter = 4'b0;
			clk_out = 1'b0;
		end
		
		else begin
			if (counter == 4'b1111) begin //Quando chegar a 15
				counter = 4'b0;
				clk_out = ~clk_out;
			end
			else begin
				counter = counter + 1; //Incrementa o contador 
			end
		end
	end

endmodule