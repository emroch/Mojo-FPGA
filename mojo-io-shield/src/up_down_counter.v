module up_down_counter #(
    parameter LEN = 8
  )(
    input clk,
    input enable,
    input up_down,
    input load,
    input [LEN-1:0] data,
    output [LEN-1:0] out
  );

  reg [LEN-1:0] count_d, count_q;
  assign out = count_q;

  always @(*) begin
    if (up_down) begin
      count_d = count_q + 1'b1;
    end else begin
      count_d = count_q - 1'b1;
    end
  end

  always @(posedge clk) begin
    if (load) begin
      count_q <= data;
    end else if (enable) begin
      count_q <= count_d;
    end
  end

endmodule // up_down_counter
