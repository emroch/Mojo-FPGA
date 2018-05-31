module hex_driver (
    input         clk,    // clock
    input         rst,    // reset
    input  [15:0] values, // values to display (4 element vector of 4 bit values, flattened to 16 bits)
    output [6:0]  seg,    // LED segment data, active low
    output [3:0]  sel     // one-cold digit select
  );

  wire [3:0] value;
  wire [3:0] select;
  assign sel = ~select;


  // cycle through the hex displays
  ring_counter digit_select (
    .clk(clk),
    .rst(rst),
    .out(select)
  );

  // decode the input data to the corresponding segments
  decoder_7_segment seg_dec (
    .clk(clk),
    .in(value),
    .out(seg)
  );

  // provide the correct digit's data to the segment decoder
  value_decoder value_dec (
    .clk(clk),
    .select(select),
    .data(values),
    .value(value)
  );

endmodule // hex_driver
