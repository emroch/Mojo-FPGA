module seven_seg #(
    parameter ACTIVE_HIGH = 0   // specify whether a segment is lit with a 1 or 0 (active high or low)
  )(
    input  [3:0] in,    // 4 bit input hexadecimal digit
    output [6:0] out    // 7 bit output segment vector
  );

  reg [6:0] segments;
  assign out = (ACTIVE_HIGH) ? segments : ~segments;

  always @(*) begin
    case (in)
      4'b0000: segments = 7'b0111111; // '0'
      4'b0001: segments = 7'b0000110; // '1'
      4'b0010: segments = 7'b1011011; // '2'
      4'b0011: segments = 7'b1001111; // '3'
      4'b0100: segments = 7'b1100110; // '4'
      4'b0101: segments = 7'b1101101; // '5'
      4'b0110: segments = 7'b1111101; // '6'
      4'b0111: segments = 7'b0000111; // '7'
      4'b1000: segments = 7'b1111111; // '8'
      4'b1001: segments = 7'b1101111; // '9'
      4'b1010: segments = 7'b1110111; // 'A'
      4'b1011: segments = 7'b1111100; // 'b'
      4'b1100: segments = 7'b0111001; // 'C'
      4'b1101: segments = 7'b1011110; // 'd'
      4'b1110: segments = 7'b1111001; // 'E'
      4'b1111: segments = 7'b1110001; // 'F'
      default: segments = 7'bxxxxxxx; // undefined
    endcase
  end

endmodule // seven_seg

module hex_driver (
    input         clk,    // clock
    input         rst,    // reset
    input  [15:0] values, // values to display (4 element vector of 4 bit values, flattened to 16 bits)
    output [6:0]  seg,    // LED segment data, active low
    output [3:0]  sel     // one-cold digit select
  );

  /**
   * Local nets to communicate between decoders and module IO.
   *  - digit is a 2 bit value describing the currently active digit (0-3)
   *  - value is a 4 bit slice of the input values, starting at bit (4 * (digit+1)) - 1,
   *    corresponding to the active digit.
   *    --> 4 * (digit+1) - 1 == 4 * digit + 3 == digit << 2 + 3
   */
  wire [1:0] digit;
  wire [3:0] value;
  assign value = values[(digit<<2)+3 -: 4];

  // counter for the multiplexed digit selection
  up_down_counter #(.SIZE(2), .DIV(16)) counter (
    .clk(clk),
    .rst(rst),
    .value(digit)
  );

  // decode the integer digit to a one-cold selection vector
  binary_decoder #(.WIDTH(2)) digit_decoder (
    .in(digit),
    .enable(1'b1),
    .out(sel)
  );

  // decode the input data to the corresponding segments
  seven_seg seg_dec (
    .in(value),
    .out(seg)
  );

endmodule // hex_driver


module up_down_counter #(
    parameter SIZE = 8,       // width of counter, in bits
    parameter DIV = 16,       // divisor, number of bits to count before incrementing
    parameter TOP = 0,        // maximum value
    parameter UP = 1          // up or down
  )(
    input               clk,  // clock input
    input               rst,  // reset to 0
    output [SIZE-1 : 0] value // output value
  );

  localparam WIDTH = SIZE + DIV;
  localparam MAX_VALUE = { TOP, {DIV{1'b1}} };

  reg [WIDTH-1 : 0] ctr;

  assign value = ctr[WIDTH-1 -: SIZE];

  always @(posedge clk) begin
    if (rst) begin
      ctr <= {WIDTH{1'b0}};
    end else begin
      if (UP) begin
        ctr <= ctr + 1'b1;
        if (TOP != 0 && ctr == MAX_VALUE) begin
          ctr <= 0;
        end
      end else begin
        ctr <= ctr - 1'b1;
        if (TOP != 0 && ctr == 0) begin
          ctr <= MAX_VALUE;
        end
      end
    end
  end

endmodule // up_down_counter

module binary_decoder #(
    parameter WIDTH = 3,        // choose number of input (address) lines
    parameter ACTIVE_HIGH = 0   // choose one-hot (1) or one-cold (0) encoding
  )(
    input  [WIDTH-1 : 0]      in,
    input                     enable,
    output [OUT_WIDTH-1 : 0]  out
  );
  // given an input width of n, the output will have width 2^n == 1<<n
  localparam OUT_WIDTH = 1 << WIDTH;

  // calculate the decoded output by shifting a 1 to the in-th position
  wire [OUT_WIDTH-1 : 0] one_hot = (enable) ? (1'b1 << in) : 1'b0;

  // if 1-COLD encoding is desired, output the inverted decoded value
  assign out = (ACTIVE_HIGH) ? one_hot : ~one_hot;

endmodule // binary_decoder
