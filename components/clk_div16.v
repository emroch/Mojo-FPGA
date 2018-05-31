module clk_div16 (
    input clk,
    output reg clkdiv
  );

  reg [15:0] count_d, count_q;

  initial clkdiv = 1'b0;

  always @(*) begin
    count_d = count_q + 1'b1;
  end

  always @(posedge clk) begin
    count_q <= count_d;

    if (&count_q) begin
      clkdiv <= ~clkdiv;
    end
  end

endmodule // clk_div16
