module posedge_edge_detector (
    input sig,          // Input signal for which positive edge has to be detected
    input clk,          // Input signal for clock
    output pe           // Output signal that gives a pulse when a positive edge of sig is detected
);

    reg sig_dly;        // Internal signal to store the delayed version of signal

    // This always block ensures that sig_dly is exactly 1 clock behind sig
    always @ (posedge clk) begin
        sig_dly <= sig;
    end

    // Combinational logic where sig is AND with delayed, inverted version of sig
    // Assign statement assigns the evaluated expression in the RHS to the internal net pe
    assign pe = sig & ~sig_dly;

endmodule
