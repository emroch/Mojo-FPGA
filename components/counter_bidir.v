module counter_bidir #(
    parameter LENGTH = 8
  )(
    input clk,
    input enable,
    input rst,
    input up_down,
    output [LENGTH-1:0] out
  );

  reg [LENGTH-1:0] ctr_d, ctr_q;
  assign out = ctr_q;

  always @(*) begin
    if (up_down) begin
      ctr_d = ctr_q + 1'b1;
    end else begin
      ctr_d = ctr_q - 1'b1;
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      ctr_q <= {LENGTH{1'b0}};
    end else if (enable) begin
      ctr_q <= ctr_d;
    end
  end

endmodule // counter_bidir
