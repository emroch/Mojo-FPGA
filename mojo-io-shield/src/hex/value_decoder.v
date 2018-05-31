module value_decoder (
    input clk,
    input [3:0] select,
    input [15:0] data,
    output reg [3:0] value
  );

  always @(posedge clk) begin
    case (select)
      4'b1000: value <= data[15 -: 4];
      4'b0100: value <= data[11 -: 4];
      4'b0010: value <= data[ 7 -: 4];
      4'b0001: value <= data[ 3 -: 4];
      default: value <= 4'bxxxx;
    endcase
  end

endmodule // value_decoder
