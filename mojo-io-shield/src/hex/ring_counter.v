module ring_counter #(
    parameter LEN = 4,      // number of output bits (i.e. one-hot states)
    parameter DIV = 16      // clock divisor in bits (shifts every 2^DIV clk pulses)
  )(
    input clk,
    input rst,
    output [LEN-1:0] out
  );

  reg [LEN-1:0] ring_d, ring_q;       // register for output values
  reg [DIV-1:0] count_d, count_q;     // internal count register
  wire shift = &count_q;              // shift signal triggered when count is at maximum
  assign out = ring_q;                // assign the output

  initial begin
    ring_q = {1'b1, {LEN-1{1'b0}}};   // output starts with the leftmost output enabled
    count_q = {DIV{1'b0}};            // clock counter starts at zero
  end

  // register input logic
  always @(*) begin
    count_d = count_q + 1'b1;
    ring_d = {ring_q[0], ring_q[LEN-1:1]};
  end

  // update the count register
  always @(posedge clk) begin
    if (rst) begin
      count_q <= {DIV{1'b0}};
    end else begin
      count_q <= count_d;
    end
  end

  // update the circular shift register
  always @(posedge clk) begin
    if (rst) begin
      ring_q <= {1'b1, {LEN-1{1'b0}}};
    end else if (shift) begin
      ring_q <= ring_d;
    end
  end

endmodule // ring_counter
