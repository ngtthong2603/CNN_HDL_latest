module Kernel_Conv_FIFO #(
  parameter   DATA_WIDTH              = 32,
  parameter   INPUT_CHANNEL_WIDTH     = 8,
  parameter   FIFO_DEPTH              = 16,
  parameter   READ_PORTS              = 9,
  parameter   POINTER_WIDTH           = $clog2(FIFO_DEPTH)
) (
  input                                     i_clock,
  input                                     i_reset,
  input                                     i_wenable,
  input    [DATA_WIDTH - 1 : 0]             i_wdata,
  input                                     i_renable,
  input    [INPUT_CHANNEL_WIDTH - 1 : 0]    i_input_feature_channel,                        
  output   logic [DATA_WIDTH - 1 : 0]       o_rdata [0 : READ_PORTS - 1],
  output                                    o_fifo_full,
  output                                    o_fifo_empty,
  output   logic                            o_read_data_valid,
  output   logic [POINTER_WIDTH : 0]        o_element_count,
  output   logic                            o_fifo_almost_full
);

  logic [DATA_WIDTH - 1 : 0]      mem [0 : FIFO_DEPTH - 1];
  logic [POINTER_WIDTH : 0]   w_pointer, w_next_pointer;
  logic [POINTER_WIDTH : 0]   r_pointer, r_next_pointer;
  logic [POINTER_WIDTH : 0]       element_count, next_element_count;
  logic                           read_data_valid;

  always @(posedge i_clock) begin
    if (!i_reset) begin
      w_pointer <= '0;
      r_pointer <= '0;
//      element_count <= '0;
      read_data_valid <= 0;
      for (int i = 0; i < READ_PORTS; i++) begin
        o_rdata[i] <= '0;
      end
      for(int i = 0; i < FIFO_DEPTH; i++) begin
        mem[i]  <=  '0;
      end
    end else begin
      w_pointer <= w_next_pointer;
      r_pointer <= r_next_pointer;
//      element_count <= next_element_count;
      if (i_wenable && !o_fifo_full) begin
        mem[w_pointer[POINTER_WIDTH - 1 : 0]] <= i_wdata;
      end
      if (i_renable && (element_count >= READ_PORTS)) begin
        read_data_valid <=  1;
        for (int i = 0; i < READ_PORTS; i++) begin
          o_rdata[i] <= mem[(r_pointer[POINTER_WIDTH - 1 : 0] + i) % FIFO_DEPTH];
        end
      end 
      else if(i_renable && !(element_count >= READ_PORTS))begin
        read_data_valid <=  0;
        o_rdata <= o_rdata;
      end
      else if(!i_renable) begin
        read_data_valid <=  read_data_valid;
        o_rdata <= o_rdata;
      end
    end
  end

  always_comb begin
    w_next_pointer      = w_pointer;
    r_next_pointer      = r_pointer;
//    next_element_count  = element_count;

    if (i_wenable && !o_fifo_full) begin
      w_next_pointer = w_pointer + 1;
//      next_element_count = w_next_pointer > r_next_pointer;
    end

    if (i_renable && (element_count >= READ_PORTS)) begin
      r_next_pointer = r_pointer + READ_PORTS;
//      next_element_count = w_next_pointer > r_next_pointer;
    end

    // Handle simultaneous read and write
    if (i_wenable && i_renable && (element_count >= READ_PORTS) && !o_fifo_full) begin
      w_next_pointer = (w_pointer + 1);
      r_next_pointer = (r_pointer + READ_PORTS);
//      next_element_count = w_next_pointer > r_next_pointer;
    end
  end

  assign o_fifo_empty       = (w_pointer == r_pointer);
  assign o_fifo_full        = (w_pointer[POINTER_WIDTH] != r_pointer[POINTER_WIDTH] && w_pointer[POINTER_WIDTH - 1 : 0] == r_pointer[POINTER_WIDTH - 1 : 0]);
  assign o_fifo_almost_full = (element_count >= FIFO_DEPTH - 3);
  assign element_count      =   (!i_reset) ? POINTER_WIDTH'('b0) : (w_pointer[POINTER_WIDTH] == r_pointer[POINTER_WIDTH]) ? (w_pointer - r_pointer) : (2*FIFO_DEPTH - r_pointer + w_pointer);
  assign o_element_count    = element_count;
  assign o_read_data_valid  = read_data_valid;

endmodule
