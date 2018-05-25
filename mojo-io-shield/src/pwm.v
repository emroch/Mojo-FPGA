module pwm #(
    parameter LENGTH = 8
  )(
    input clk,
    input rst,
    input [LENGTH-1 : 0] level,
    output reg pwm
  );

  reg [LENGTH-1 : 0] ctr;

  always @(posedge clk) begin
    if (rst) begin
      ctr <= 1'b0;
    end else begin
      ctr <= ctr + 1'b1;
    end

    pwm <= (level > ctr);
  end

endmodule // pwm
