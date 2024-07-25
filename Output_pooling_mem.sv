module Output_pooling_mem #(
    parameter       DATA_WIDTH                          =   32,
    parameter       OUTPUT_CHANNEL_WIDTH                =   7,
    parameter       OUTPUT_ROW_WIDTH                    =   2,
    parameter       OUTPUT_COL_WIDTH                    =   2,
    parameter       OUTPUT_BRAM_NUM                     =   4,
    parameter       OUTPUT_BRAM_DEPTH                   =   1152,
    parameter       OUTPUT_BRAM_ADDRESS_WIDTH           =   $clog2(KERNEL_BRAM_DEPTH)
) (
    input                                                   i_clock,
    input                                                   i_reset,
    input                                                   i_enable,
    input                                                   i_wenable,
    input           [0:0]                                   i_renable   [0 : OUTPUT_BRAM_NUM - 1],
    input           [OUTPUT_CHANNEL_WIDTH - 1 : 0]          i_output_feature_channel,
    input           [OUTPUT_COL_WIDTH - 1 : 0]              i_output_pooling_size,
    input           [OUTPUT_CHANNEL_WIDTH - 1 : 0]          i_output_start_index_channel,
    input           [OUTPUT_CHANNEL_WIDTH - 1 : 0]          i_output_end_index_channel,
    input           [OUTPUT_CHANNEL_WIDTH - 1 : 0]          i_output_channel_data_point,
    input           [OUTPUT_COL_WIDTH - 1 : 0]              i_output_col_data_point,
    input           [OUTPUT_ROW_WIDTH - 1 : 0]              i_output_row_data_point,
    input           [OUTPUT_BRAM_ADDRESS_WIDTH]             i_raddress,
    input           [DATA_WIDTH - 1 : 0]                    i_bram_data,
    output          [DATA_WIDTH - 1 : 0]                    o_bram_data,
    output                                                  o_reset_busy
);
    logic           [OUTPUT_BRAM_ADDRESS_WIDTH]             wraddress;
    logic                                                   reset_busy_a;
    logic                                                   reset_busy_b;

    assign      o_reset_busy    =   reset_busy_a || reset_busy_b;
    
    Output_pooling_mem_decoder #(
        .OUTPUT_CHANNEL_WIDTH(OUTPUT_CHANNEL_WIDTH),
        .OUTPUT_ROW_WIDTH(OUTPUT_ROW_WIDTH),
        .OUTPUT_COL_WIDTH(OUTPUT_COL_WIDTH),
        .OUTPUT_BRAM_NUM(OUTPUT_BRAM_NUM),
        .OUTPUT_BRAM_DEPTH(OUTPUT_BRAM_DEPTH),
        .OUTPUT_BRAM_ADDRESS_WIDTH(OUTPUT_BRAM_ADDRESS_WIDTH)
    ) (
        .i_output_feature_channel(i_output_feature_channel),
        .i_output_pooling_size(i_output_pooling_size),
        .i_output_start_index_channel(i_output_start_index_channel),
        .i_output_end_index_channel(i_output_end_index_channel),
        .i_output_channel_data_point(i_output_channel_data_point),
        .i_output_col_data_point(i_output_col_data_point),
        .i_output_row_data_point(i_output_row_data_point),
        .o_output_address(wraddress)
    );

    output_pooling_bram output_pooling_bram_inst (
        .clka(i_clock),
        .ena(i_enable),
        .wea(i_wenable),
        .addra(wraddress),
        .dina(i_bram_data),
        .clkb(i_clock),
        .rstb(!i_reset),
        .enb(i_enable),
        .addrb(i_raddress),
        .doutb(o_bram_data),
        .rsta_busy(reset_busy_a),
        .rstb_busy(reset_busy_b)
    );
endmodule