module CIM (
    input logic signed [11:0] PE_tile_i [0:5][0:5],    // 36 12-bit numbers                    
    input logic [7:0] PE_addr_i,
    input logic PE_valid_i,                           

    input logic [511:0] memory_data_i,                // 512-bit memory data
    input logic [7:0] memory_addr_i,                  // Memory address (not used in this logic)
    input logic memory_valid_i,                       // Memory valid (not used in this logic)

    output logic [511:0] result_o,                    // 512-bit output
    output logic result_valid_o,                      // Result valid (not used in this logic)
    output logic [7:0] result_addr_o                  // Result address (not used in this logic)
);

    // Internal variables
    logic signed [11:0] memory_tile_i [0:5][0:5]; // Extracted 36 numbers from memory_data_i
    logic signed [11:0] sum [0:5][0:5];           // Sum of PE_tile_i and memory_tile_i

    // Extract 36 12-bit numbers from memory_data_i (last 432 bits)
    logic [8:0] temp1;
    always_comb begin
        for (int i = 0; i < 6; i++) begin
            for (int j = 0; j < 6; j++) begin
                temp1 = 9'd35 - (i * 6 + j);
                memory_tile_i[i][j] = memory_data_i[temp1 * 12 +: 12];
            end
        end
    end

    // Perform element-wise addition between PE_tile_i and memory_tile_i
    always_comb begin
        for (int i = 0; i < 6; i++) begin
            for (int j = 0; j < 6; j++) begin
                sum[i][j] = PE_tile_i[i][j] + memory_tile_i[i][j];
            end
        end
    end

    // Flatten the 6x6 array of sums into a 512-bit output
    logic [8:0] temp2;
    always_comb begin
        result_o = 512'b0; // Initialize the output
        for (int i = 0; i < 6; i++) begin
            for (int j = 0; j < 6; j++) begin
                temp2 = 9'd35 - (i * 6 + j);
                result_o[temp2 * 12 +: 12] = sum[i][j];
            end
        end
        result_valid_o = PE_valid_i && memory_valid_i && (PE_addr_i == memory_addr_i);
        result_addr_o = PE_addr_i;
    end

endmodule
