/**
 * Parameterized 1-of-n Binary Decoder.
 * Defaults to a 3-to-8 one-hot decoder.
 *
 * This module accepts a binary input of the specified
 * width and produces an output of 2^n width.  If ACTIVE_HIGH
 * is set to 1, the output will be one-hot, otherwise it
 * will be one-cold.  Due to the parametric nature of this decoder,
 * the decoding is performed by shifting a single bit by the input
 * value, rather than using a multiplexer.
 */
module binary_decoder #(
    parameter WIDTH = 3,        // choose number of input (address) lines
    parameter ACTIVE_HIGH = 0   // choose one-hot (1) or one-cold (0) encoding
  )(
    input  [WIDTH-1 : 0]      in,
    input                     enable,
    output [OUT_WIDTH-1 : 0]  out
  );
  localparam OUT_WIDTH = 1 << WIDTH;

  wire [OUT_WIDTH-1 : 0] one_hot = (enable) ? (1'b1 << in) : 1'b0;
  assign out = (ACTIVE_HIGH) ? one_hot : ~one_hot;

endmodule // binary_decoder
