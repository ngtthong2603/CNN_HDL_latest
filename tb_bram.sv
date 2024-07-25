module tb_bram;

  // Signal Declarations
  reg clk, ena, enb, rstb, wea;
  reg [3:0] addra, addrb;
  reg [0:0] wea_vec;
  reg [15:0] dina;
  wire [15:0] doutb;
  wire rsta_busy, rstb_busy;

  // Instantiate the VHDL module
  bram uut (
    .clka(clk),
    .ena(ena),
    .wea(wea_vec),
    .addra(addra),
    .dina(dina),
    .clkb(clk),
    .rstb(rstb),
    .enb(enb),
    .addrb(addrb),
    .doutb(doutb),
    .rsta_busy(rsta_busy),
    .rstb_busy(rstb_busy)
  );

  // Clock generation for clk
  initial begin
    clk = 1;
    forever #5 clk = ~clk; // 100 MHz Clock
  end

  // Reset generation
  initial begin
    rstb = 1;
    #15;
    rstb = 0;
  end

  // Test Sequence
  initial begin
    // Initialize inputs
    ena = 0;
    wea_vec = 0;
    addra = 0;
    dina = 0;
    enb = 0;
    addrb = 4'b0010;

    // Apply reset
    #20;
    rstb = 1;
    #20;
    rstb = 0;

    // Write data to port A
    #10;
    ena = 1;
    wea_vec = 1'b1;
    addra = 4'b0010;
    dina = 16'hA5A5;
    #10;
    wea_vec = 1'b0;
    #20;
    dina = 16'h0;
    enb = 1;
    wea_vec = 1'b0;
    addrb = 4'b0010;

    // Observe output
    #10;
    $display("Read data: %h", doutb);
    
    // End simulation
    #100;
    $finish;
  end

endmodule
