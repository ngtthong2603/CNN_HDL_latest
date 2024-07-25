module kernel_mem #(
    parameter       KERNEL_BRAM_NUM                 =       4,
    parameter       KERNEL_BRAM_ADDRESS_WIDTH       =       16,
    parameter       DATA_WIDTH                      =       32,
) (
    input                                                   i_clock,
    input                                                   i_reset,
    input           [0 : 0]                                 i_enable [0 : KERNEL_BRAM_NUM - 1],
    input           [0 : 0]                                 i_renable [0 : KERNEL_BRAM_NUM - 1],
    input           [0 : 0]                                 i_wenable [0 : KERNEL_BRAM_NUM - 1],
    input           [KERNEL_BRAM_ADDRESS_WIDTH - 1 : 0]     i_address [0 : KERNEL_BRAM_NUM - 1],
    input           [DATA_WIDTH - 1 : 0]                    i_bram_data,
    output          [DATA_WIDTH - 1 : 0]                    o_bram_data [0 : KERNEL_BRAM_NUM - 1]
    
);
    genvar i;
    for(i = 0; i <= KERNEL_BRAM_NUM - 1; i++) begin
        kernel_bram kernel_bram_inst(
            .clka(i_clock),
            .ena(i_enable[i]),
            .wea(i_wenable[i]),
            .addra(i_waddress[i]),
            .dina(i_bram_data),
            .clkb(i_clock),
            .rstb(i_reset),
            .enb(i_renable[i]),
            .addrb(i_raddress[i]),
            .doutb(o_bram_data[i]),
            .rsta_busy(),
            .rstb_busy()
        );
    end
endmodule