module d_ff (
    input clk, d,
    output reg q
  );

  always @(posedge clk) begin
    q <= d;
  end

endmodule // d_ff


module t_ff (
    input clk, t,
    output reg q
  );

  always @(posedge clk) begin
    q <= t ^ q;
  end

endmodule // t_ff


module jk_ff (
    input clk, j, k,
    output reg q
  );

  always @(posedge clk) begin
    q <= (j & ~q) | (~k & q);
  end

endmodule // jk_ff
