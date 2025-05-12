module main_buffer(
    // Clock e reset
    input wire clk,
    input wire rst,
    
    // Interface de dados
    input wire [31:0] matrix1_data,
    input wire [31:0] matrix2_data,
    input wire [5:0] instruction,
    
    // Controle HPS -> FPGA
    input wire save_data,        // HPS está enviando dados válidos
    input wire start,            // Iniciar processamento
    input wire hps_busy,         // HPS não pode receber dados no momento
    
    // Controle FPGA -> HPS
    output reg fpga_wait,        // FPGA não pode receber mais dados agora
    output reg fpga_ready,       // FPGA pronto para processar
    output reg [31:0] result_data,
    output reg result_valid,     // Dado de resultado válido
    output reg processing_done   // Operação completa
);

// Parâmetros da matriz
localparam ROWS = 5;
localparam COLS = 5;
localparam ELEMENT_BITS = 8;
localparam MATRIX_BITS = ROWS * COLS * ELEMENT_BITS; // 200 bits
localparam WORDS = (MATRIX_BITS + 31) / 32;          // 7 palavras

// Registradores
reg [MATRIX_BITS-1:0] matrix1_reg;
reg [MATRIX_BITS-1:0] matrix2_reg;
reg [5:0] instruction_reg;

// Máquina de estados principal
typedef enum {
    IDLE,
    RECEIVE_DATA,
    READY_TO_PROCESS,
    PROCESSING,
    SEND_RESULTS,
    DONE
} state_t;

state_t state, next_state;

// Contadores
reg [2:0] receive_counter;
reg [2:0] send_counter;

// Lógica de transição de estados
always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        matrix1_reg <= 0;
        matrix2_reg <= 0;
        instruction_reg <= 0;
        receive_counter <= 0;
        send_counter <= 0;
        fpga_wait <= 0;
        fpga_ready <= 0;
        result_data <= 0;
        result_valid <= 0;
        processing_done <= 0;
    end else begin
        state <= next_state;
        
        // Lógica específica de cada estado
        case (state)
            IDLE: begin
                fpga_ready <= 0;
                processing_done <= 0;
                if (save_data) begin
                    receive_counter <= 0;
                end
            end
            
            RECEIVE_DATA: begin
                if (save_data && !fpga_wait) begin
                    // Armazena dados das duas matrizes
                    matrix1_reg[MATRIX_BITS-1-32*receive_counter -: 32] <= matrix1_data;
                    matrix2_reg[MATRIX_BITS-1-32*receive_counter -: 32] <= matrix2_data;
                    
                    // Última palavra inclui a instrução
                    if (receive_counter == WORDS-1)
                        instruction_reg <= instruction;
                    
                    receive_counter <= receive_counter + 1;
                end
                
                // Atualiza sinal de wait
                fpga_wait <= (receive_counter == WORDS-1) ? 0 : 1;
            end
            
            READY_TO_PROCESS: begin
                fpga_ready <= 1;
                fpga_wait <= 0;
            end
            
            PROCESSING: begin
                fpga_ready <= 0;
                // Implemente aqui sua operação matricial
                // ...
                send_counter <= 0;
            end
            
            SEND_RESULTS: begin
                if (!hps_busy) begin
                    result_data <= matrix1_reg[MATRIX_BITS-1-32*send_counter -: 32]; // Exemplo
                    result_valid <= 1;
                    send_counter <= send_counter + 1;
                end else begin
                    result_valid <= 0;
                end
                
                fpga_wait <= (send_counter == WORDS-1) ? 1 : 0;
            end
            
            DONE: begin
                processing_done <= 1;
                result_valid <= 0;
            end
        endcase
    end
end

// Lógica de próximo estado
always @(*) begin
    next_state = state;
    case (state)
        IDLE: 
            if (save_data) next_state = RECEIVE_DATA;
        
        RECEIVE_DATA: 
            if (receive_counter == WORDS) next_state = READY_TO_PROCESS;
        
        READY_TO_PROCESS: 
            if (start) next_state = PROCESSING;
        
        PROCESSING: 
            next_state = SEND_RESULTS; // Substitua por sua lógica real
        
        SEND_RESULTS: 
            if (send_counter == WORDS) next_state = DONE;
        
        DONE: 
            next_state = IDLE;
    endcase
end

endmodule