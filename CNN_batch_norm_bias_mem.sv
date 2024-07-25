module CNN_batch_norm_bias_mem #(
    parameter           OUTPUT_BRAM_NUM                 =   4,
    parameter           DATA_WIDTH                      =   32,
    parameter           KERNEL_FILTER_WIDTH             =   8,
    parameter           BATCH_NORM_BIAS_WIDTH           =   KERNEL_FILTER_WIDTH
) (
    input                                                   i_clock,
    input                                                   i_reset,
    input                                                   i_enable,
    input           [0:0]                                   i_wenable [0 : OUTPUT_BRAM_NUM - 1],
    input           [DATA_WIDTH - 1 : 0]                    i_bram_data,
    input           [BATCH_NORM_BIAS_WIDTH - 1 : 0]         i_batch_norm_bias_size,
    input           [BATCH_NORM_BIAS_WIDTH - 1 : 0]         i_batch_norm_bias_data_point [0 : OUTPUT_BRAM_NUM - 1],
    output          [DATA_WIDTH - 1 : 0]                    o_batch_norm_bias_data [0 : OUTPUT_BRAM_NUM - 1],
    output                                                  o_reset_busy
);

    logic           [0:0]                                   reset_busy [0 : OUTPUT_BRAM_NUM - 1];
    logic           [BATCH_NORM_BIAS_WIDTH - 1 : 0]         batch_norm_bias_address [0 : OUTPUT_BRAM_NUM - 1];

    assign          o_reset_busy    =   reset_busy[0] || reset_busy[1] || reset_busy[2] || reset_busy[3];
    genvar i;
    for(i = 0; i < OUTPUT_BRAM_NUM; i++) begin
        assign batch_norm_bias_address[i]      =       i_batch_norm_bias_data_point[i] / 4;
        batch_norm_bias_bram batch_norm_bias_bram_inst (
            .clka(i_clock)
            .rsta(!i_reset)
            .ena(i_enable)
            .wea(i_wenable[i])
            .addra(batch_norm_bias_address[i])
            .dina(i_bram_data)
            .douta(o_batch_norm_bias_data[i])
            .rsta_busy(reset_busy[i])
        );
    end
    
endmodule